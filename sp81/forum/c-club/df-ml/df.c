/* Program to simulate a df on unix.
 *
 * Copyright (C) 1994 Marty Leisner   leisner@sdsp.mc.xerox.com
 *

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  


 */

#include <stdio.h>
#include <regs.h>
#include "lstolist.h"
typedef enum { FALSE, TRUE } bool_t;

static const char *VERSION = "1.0";


/* if TRUE, tell more info about drive. */
static bool_t show_info = FALSE;
static bool_t int32_drives = FALSE;	/* perform dos
					function 32 */
/* try to status floppies (may fail) */
static bool_t stat_everything = FALSE;
static const char *progname;

static bool_t volume_labels = FALSE;

typedef struct {
	char drive_number;	/* A = 0 */
	char unit_number;
	unsigned short bytes_per_sector;
	char max_sector_in_cluster;
	char shift_count;
	short reserved_sectors;
	char num_fats;
	unsigned root_entries;
	unsigned short first_data_sector;
	unsigned short highest_cluster;
	unsigned short num_sectors_per_fat;
	unsigned short sector_of_first_dir_entry;
	void far *device_header;
	char media_id;
	char disk_accessed; /* 0 if true, ff is not */
 	void far *next_dpb;
	unsigned short cluster_to_search;
	unsigned short free_clusters;
} DPB;	
		
typedef struct {
	char cur_path[0x43];
	/* 0x8000 -- remote
         * 0x4000 -- valid
	 * 0x2000 -- joined
         * 0x1000 -- SUBST
 	 * 0x0080 -- hidden and redirected ?? */
#define VALID_DRIVE -0x4000
#define JOINED_DRIVE 0x2000
#define REMOTE_DRIVE 0x8000
	short flags;	
	void far *dpb;
	/* 000 = root, 0xffff never accessed */
	short cluster;
	short ignore;
	short remote_user;
	short roots_chars;
	char remote_device_type;
	void far *ifs_driver;
	short ifs_space;
} CDS;	

typedef struct {
	int code;	/* A=1 */
	bool_t removable;
	/* true if drive is present */
	bool_t have;
	CDS far *cds;
	long total_bytes;
	long bytes_used;
} DRIVE_INFO;

static DRIVE_INFO drives['Z' - 'A'];	/* 26 drives */

static int lastdrive; 	/* for now */

static void show_header(void)
{
	printf("Drive    Free K     Total K   %%Free    Mount");
	if(volume_labels == TRUE)
		printf("         Label");
	printf("\n");
}

static void show_bytes(const long bytes)
{
	if(bytes != -1L) 
		printf("%-10ld", bytes/1024L);
	else	printf("%10s", ""); 
}

static void show_percent(long used, long total)
{
	int percent;

	if(used == -1L || percent == -1L) {
		printf("%-6s", "");
		return;
	}
	/* scale */
	used /= 1024;
	total /= 1024;
	percent = (used * 100L)/total;
	printf("%-6d", percent);
}

/*
INT 21 69-- - DOS 4+ internal - GET/SET DISK SERIAL NUMBER


undocumented function

Category: D - DOS kernel

Inp.:
	AH = 69h
	AL = subfunction
	    00h get serial number
	    01h set serial number
	BL = drive (0=default, 1=A, 2=B, etc)
	DS:DX -> disk info (see #0866)
Return: CF set on error
	    AX = error code (see #0789 at AH=59h)
	CF clear if successful
	    AX destroyed
	    (AL = 00h) buffer filled with appropriate values from extended BPB
	    (AL = 01h) extended BPB on disk set to values from buffer
Notes:	does not generate a critical error; all errors are returned in AX
	error 0005h given if no extended BPB on disk
	does not work on network drives (error 0001h)
	buffer after first two bytes is exact copy of bytes 27h thru 3Dh of
	  extended BPB on disk

	this function is supported under Novell NetWare versions 2.0A through
	  3.11; the returned serial number is the one a DIR would display,
	  the volume label is the NetWare volume label, and the file system
	  is set to "FAT16".
	the serial number is computed from the current date and time when the
	  disk is created; the first part is the sum of the seconds/hundredths
	  and month/day, the second part is the sum of the hours/minutes and
	  year
	the volume label which is read or set is the one stored in the extended
	  BPB on disks formatted with DOS 4.0+, rather than the special root
	  directory entry used by the DIR command in COMMAND.COM (use AH=11h
	  to find that volume label)

SeeAlso: AX=440Dh

Copied from Ralf Brown's Interrupt List
21 69-- Format of disk info:


Format of disk info:
Offset	Size	Description	(Table 0866)
 00h	WORD	info level (zero)
 02h	DWORD	disk serial number (binary)
 06h 11 BYTEs	volume label or "NO NAME    " if none present
 11h  8 BYTEs	(AL=00h only) filesystem type--string "FAT12   " or "FAT16   "
INT 21 69--
Copied from Ralf Brown's Interrupt List
*/
static void show_volume_label(char drive)
{
	REGS regs;
	struct {
		int info_level;
		long serial_number;
		char volume_label[11];
		char type_fat[8];
	} drive_info;
	int result;
	extern int _dsval;

	drive -= 'A';	/* adjust drive */
	drive++;
	regs.AX = 0x6900;
	regs.BX = drive;	
	regs.DX = &drive_info;
	regs.DS = _dsval;
	result  = dos_interrupt(&regs);
	if(! result ) {
		printf("%.11s", drive_info.volume_label);
	} 
	
}	

static void show_disk_drive(const char drive,	/* starts with A */
		      const char *mount,
		      const long used_bytes, /* -1 is unknown */
		      const long total_bytes /* -1 is unknown */)
{
	long used_k, total_k;
	long percent;

	percent = (used_k * 100)/total_k ;
	printf("%c:        ", drive);
	show_bytes(used_bytes);
	show_bytes(total_bytes);
	show_percent(used_bytes, total_bytes);
	printf("   %-15s", mount ? mount : "");
	if(volume_labels == TRUE)
		show_volume_label(drive);
	printf("\n");
}

static int count_drives(void)
{
	REGS regs;
	int result;

	/* find the current drive */
	regs.AX = 0x1900;
	result = dos_interrupt(&regs);

	regs.DX = regs.AX & 0xff;
	regs.AX = 0xe00;
	result = dos_interrupt(&regs);

	return regs.AX & 0xff;
}
	

static void status_drive(DRIVE_INFO *pdrive)
{
	printf("Drive %c = %s\n", pdrive->code + 'A' -1, 
			(pdrive->removable == TRUE) ? 
				"removable" : "fixed");

}


typedef enum { UNKNOWN, HAVE_SIZE, HAVE_FREE } size_state;

/* Return true if total bytes and used_bytes are meaningful,
 * FALSE otherwise
 */	
static size_state compute_dpb(DPB far *p, long *total_bytes,
					long *used_bytes)
{
	long bytes_per_cluster;
	long used_space;
	unsigned short used_clusters;

	*total_bytes = -1;
	*used_bytes = -1;

	if(p->max_sector_in_cluster < 0) {
		return UNKNOWN;
	}
	
	bytes_per_cluster = p->bytes_per_sector *
				(p->max_sector_in_cluster + 1);

	*total_bytes = bytes_per_cluster * p->highest_cluster;

	if(p->free_clusters == 0xffff)
		return HAVE_SIZE;

	used_clusters = p->highest_cluster - p->free_clusters;

	*used_bytes = used_clusters * bytes_per_cluster;
	return HAVE_FREE;
		
}	
	
static void copy_string(char *local, const char far *p)
{
	while(1) {
		*local =  *p;
		if(!*p)
			return;
		local++;
		p++;
	}
}

static void show_drive_info(DRIVE_INFO *pdrive)
{
	if(pdrive->cds->flags & JOINED_DRIVE)
		printf("JOINED ");
#if 0
	if(pdrive->cds->flags & SUBST)
		printf("SUBST ");
#endif
	if(pdrive->cds->flags & VALID_DRIVE)
		printf("VALID ");
	if(pdrive->cds->flags & REMOTE_DRIVE)
		printf("remote");
	if(pdrive->removable == TRUE)
		printf("REMOVABLE ");
	if(pdrive->have == TRUE)
		printf("HAVE ");
	printf("\n");
}

static DPB far *do_int32(int drive)
{
	DPB far *p = NULL;
	REGS regs;

	regs.AX = 0x3200;
	regs.DX = drive;
	dos_interrupt(&regs);
	if((regs.AX & 0xff) == 0) {
		p = (((long) regs.DS) << 16) + (regs.BX);
	}

	return p;
	
}

static void do_int36(int code, long *total, long *free)
{
	REGS regs;

	regs.AX = 0x3600;
	regs.DX = code;

	dos_interrupt(&regs);
	if(regs.AX != 0xffff) {
		long bytes_per_cluster;

		bytes_per_cluster = (long) regs.AX *
				(long) regs.CX;
		*total = bytes_per_cluster * (long) regs.DX;
		*free = bytes_per_cluster * (long) regs.BX;
	} else {
		*total = -1;
		*free = -1;
	}
}

	

static void show_drive(DRIVE_INFO *pdrive)
{
	char letter;
	CDS far *cds;
	long bytes_used, total_bytes;
	char path[64];
	char *use_path = NULL;
	size_state state;
	
	letter = pdrive->code + 'A' - 1;  
	cds = pdrive->cds;

	if(pdrive->have == TRUE && (pdrive->removable == FALSE)
				|| (stat_everything == TRUE) ) {
		do_int36(pdrive->code, &pdrive->total_bytes,
				&pdrive->bytes_used);
	}
`	else	compute_dpb(cds->dpb, &pdrive->total_bytes,
				&pdrive->bytes_used);

	if(cds->flags & JOINED_DRIVE) {
		copy_string(path, cds);
		use_path = path;
	}
	show_disk_drive(letter, use_path, pdrive->bytes_used,
			pdrive->total_bytes);

	if(show_info == TRUE)
		show_drive_info(pdrive);

		
}
	


static void status_drives(void)
{
	DRIVE_INFO *pdrive;
	int i;

	for(i = 0, pdrive = &drives; 
		i <= lastdrive;
		i++, pdrive++) {
		if(pdrive->have == TRUE && (pdrive->removable == FALSE ||
						stat_everything == TRUE))
			do_int32(i + 1);
		
	}
}


static void show_all_drives(void)
{
	DRIVE_INFO *pdrive;
	int i;

	for(i = 0, pdrive = &drives;
		i < lastdrive;
		i++, pdrive++) 
		show_drive(pdrive);
}

static void figure_out_floppies(void)
{
	REGS regs;
	DRIVE_INFO *pdrive;
	LIST_OF_LISTS far *listolist;
	CDS far *cds;
	
	int i;
	pdrive = &drives[0];
	listolist = dos_list_of_lists();
	lastdrive = listolist->num_block;
	cds = listolist->cds_list;
	for(i = 1; i <= lastdrive; pdrive++, i++) {
		int result;

		pdrive->code = i;
		regs.AX = 0x4408;
		regs.BX = i;
		result = dos_interrupt(&regs);
		if(result < 0)
			pdrive->have = FALSE;
		else {
			pdrive->have = TRUE;
			if(regs.AX == 0)
				pdrive->removable =  TRUE;
			else 	pdrive->removable =  FALSE;
			
		}	
		pdrive->cds = cds++;
	}

}


static void usage(void)
{
	fprintf(stderr, "Usage: %s [-e] [-l] [-v] [-i] [-s]\n", progname);
	fprintf(stderr, "\t-s\tStatus with function 32\n");
	fprintf(stderr, "\t-i\tShow drive information\n");
	fprintf(stderr, "\t-v\tShow version and quit\n");
	fprintf(stderr, "\t-e\ttry to stat everything\n");
	fprintf(stderr, "\t-l\tdisplay volume lables\n");
	exit();
}


static void hook_int24(void)
{
	
	extern unsigned _csval;
	extern int24_handler();
	REGS regs;

	regs.AX = (0x25 << 8) + 0x24;
	regs.DS = _csval;
	regs.DX = &int24_handler;

	dos_interrupt(&regs);
}

	
main(int argc, char **argv)
{
	int c;

	progname = argv[0];

	hook_int24();

	while(1) {
		c = getopt(argc, argv, "elvis");
		if(c == - 1)
			break;
		switch(c) {
			case 'e':
				stat_everything = TRUE;
				break;
			case 'l':
				volume_labels = TRUE;
				break;
			case 's':
				int32_drives = TRUE;
				break;
			case 'i':
				show_info = TRUE;
				break;
			case 'v':
				printf("another df version %s\n", VERSION);
				printf("Made %s %s\n", __DATE__, __TIME__);
				exit(1);
			default:
				usage();
		}
	}

	show_header();
	figure_out_floppies();
	if(int32_drives)	
		status_drives();
	show_all_drives();
}

