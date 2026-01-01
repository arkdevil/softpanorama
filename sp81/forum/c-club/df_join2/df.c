/* df - dump filesystems.
 *
 * public domain by Russell Nelson.  Don't try to make money off of it, and
 * don't pretend that you wrote it.
 *
 * Compile with: tcc -mc df.c
 *
 * Russ <nelson@clutx.clarkson.edu>
 */

#include <stdio.h>
#include <dos.h>
#include <dir.h>
#include <string.h>
#include <alloc.h>
#include <ctype.h>
#include <stdlib.h>

#define DOS3	1		/* this program requires DOS 3 */


/* the following is undocumented */
struct drive_info {
	char current_path[64];
	char far *foo;
	char flags;			/* ??? Flags? I see 40h, except entry after last valid entry = 00h */
	char far *disk_block;
	int current_track;		/* ??? Current track or block? -1 if never accessed. */
	char far *bar;			/* ??? I see -1 always */
	unsigned baz;			/* ??? I see 2 always */
};


/* the following is undocumented */
struct list_of_lists {
	unsigned first_mcb;
	char far *first_disk_block;
	char far *first_dos_file;
	char far *clock_driver;
	char far *con_driver;
#ifdef DOS2
	char drive_count;	/* Number of logical drives in system */
	unsigned bytes_per_block;	/* Maximum bytes/block of any block device */
	unsigned foo,bar;		/* ??? */
#endif
#ifdef DOS3
	unsigned bytes_per_block;	/* Maximum bytes/block of any block device */
	char far *first_disk_buffer;	/* Pointer to first disk buffer */
	struct drive_info far *first_drive;	/* Pointer to array of drive info: */
	char far *fcb_table;		/* Pointer to FCB table (if CONFIG.SYS contains FCBS=) */
	unsigned fcb_size;		/* Size of FCB table */
	unsigned char block_devices;	/* Number of block devices */
	unsigned char lastdrive;	/* Value of LASTDRIVE command in CONFIG.SYS (default 5) */
#endif
/* NUL device driver appears here */
} *list_ptr;

/* find a volume label.  Search in subdirectory if the disk is mounted there. */
char *
volume_name(int i, char *mounted)
{
	struct ffblk ffblk;
	char root[64];

	if (*mounted) sprintf(root, "%s\\*.*", mounted);
	else sprintf(root, "%c:\\*.*", 'A' + i);
	if (!findfirst(root, &ffblk, FA_LABEL)) {
		char *dot = strchr(ffblk.ff_name, '.');
		if (dot) strcpy(dot, dot+1);
		return ffblk.ff_name;
	}
	else return("");
}

/* given a list of drives, enable those drives */
int
set_drives(char *drives, char *specifier)
{
	char *drive_ptr;

	for (drive_ptr = specifier; *drive_ptr; ) {
		if (drive_ptr[1] == '-' &&
		    tolower(drive_ptr[2]) >= tolower(drive_ptr[0])) {
			memset(&drives[tolower(drive_ptr[0]) - 'a'], 1, tolower(drive_ptr[2]) - tolower(drive_ptr[0]) + 1);
			drive_ptr+=3;
		} else if (isalpha(*drive_ptr)) {
			drives[tolower(*drive_ptr) - 'a'] = 1;
			drive_ptr++;
		} else drive_ptr++;
	}
}

int hard_err, hard_error_number;

int
hard_handler(int errval, int ax, int bp, int si)
{
	hard_err = 1;			/* remember that we got an error. */
	hard_error_number = errval;	/* remember what the error was. */
	return 0;			/* ignore */
}

char *hard_errors[] = {
	"write-protect error",
	"unknown unit",
	"drive not ready",
	"unknown command",
	"data error",
	"bad request",
	"seek error",
	"unknown media",
	"sector not found",
	"out of paper",
	"write fault",
	"general failure",
};

int
main(int argc, char *argv[])
{
	int i, j;
	char *dskbuf;
	char drives[64], *drive_ptr;

	/* enable only the drives that we want */
	memset(drives, 0, sizeof(drives));
	if (argc == 1 && (drive_ptr = getenv("DF")) != NULL)
		set_drives(drives, drive_ptr);
	else if (argc == 1)
		memset(drives, 1, sizeof(drives));
	else set_drives(drives, argv[1]);

	/* establish a hardware error handler */
	harderr(hard_handler);

	/* get MS-LOSS's list of lists (undocumented) */
	_AH = 0x52;
	geninterrupt(0x21);
	list_ptr = MK_FP(_ES, _BX - 2);

	/* ensure that we have a buffer that's big enough for any drive. */
	dskbuf = malloc(list_ptr->bytes_per_block);

	printf(	"      block   total  kbytes  kbytes  percent\n"
		"disk   size  kbytes    used    free    used     volume       mount\n");
	for (i = 0; i < list_ptr->lastdrive; i++) if (drives[i]) {
		struct drive_info *drive_ptr = &(list_ptr->first_drive[i]);
		struct dfree dtable;
		unsigned int block_size, percent;
		unsigned long total, used, free;
		char *mount_point;

		printf("  %c:", 'A' + i);
		j = ioctl(i+1, 0xe) & 0xff;
		if (j != 0 && j != i+1) {
			printf("%42s[Not in drive]\n", "");
		} else if (absread(i, 1, 0, dskbuf) < 0) {
			printf("%42s[Not Ready]\n", "");
		} else {
			/* catch a hard error here, and report it */
			hard_err = 0;
			getdfree(i+1, &dtable);
			if (hard_err) {
				printf("%42s[%s]\n", "", hard_errors[hard_error_number]);
			} else {
				mount_point = drive_ptr->flags & 0x20?drive_ptr->current_path:"";
				block_size = dtable.df_bsec * dtable.df_sclus;
				total = (long)dtable.df_total * (long)block_size;
				used = ((long)dtable.df_total - (long)dtable.df_avail) * (long)block_size;
				free = (long)dtable.df_avail * (long)block_size;
				percent = (long)(dtable.df_total - dtable.df_avail) * 100L / (long)dtable.df_total;
				printf("%6u %7lu %7lu %7lu %6u%%    %-12s %s\n",
					block_size,
					total / 1024L,
					used / 1024L,
					free / 1024L,
					percent,
					volume_name(i, mount_point),
					mount_point);
			}
		}
	}
}
