/*  zipscan.c - scan .zip archives
    Copyright (C) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 1, or (at your option)
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

    IMPORTANT:

    This code is not an official part of the GNU project and the
    author is not affiliated to the Free Software Foundation.
    He just likes their code and spirit.  */

static char RCS_id[] =
"$Header: e:/gnu/make/RCS/zipscan.c'v 0.2 90/07/18 22:23:26 tho Exp $";

/* The following section is taken from the file appnote.txt
   (from the PK(UN)?ZIP v1.1 distribution).  */

/*

General Format of a ZIP file
----------------------------

  Files stored in arbitrary order.  Large zipfiles can span multiple
  diskette media.

  Overall zipfile format:

    [local file header+file data] . . .
    [central directory] end of central directory record


  A.  Local file header:

	local file header signature	4 bytes  (0x04034b50)
	version needed to extract	2 bytes
	general purpose bit flag	2 bytes
	compression method		2 bytes
	last mod file time 		2 bytes
	last mod file date		2 bytes
	crc-32   			4 bytes
	compressed size			4 bytes
	uncompressed size		4 bytes
	filename length			2 bytes
	extra field length		2 bytes

	filename (variable size)
	extra field (variable size)


  B.  Central directory structure:

      [file header] . . .  end of central dir record

      File header:

	central file header signature	4 bytes  (0x02014b50)
	version made by			2 bytes
	version needed to extract	2 bytes
	general purpose bit flag	2 bytes
	compression method		2 bytes
	last mod file time 		2 bytes
	last mod file date		2 bytes
	crc-32   			4 bytes
	compressed size			4 bytes
	uncompressed size		4 bytes
	filename length			2 bytes
	extra field length		2 bytes
	file comment length		2 bytes
	disk number start		2 bytes
	internal file attributes	2 bytes
	external file attributes	4 bytes
	relative offset of local header	4 bytes

	filename (variable size)
	extra field (variable size)
	file comment (variable size)

      End of central dir record:

	end of central dir signature	4 bytes  (0x06054b50)
	number of this disk		2 bytes
	number of the disk with the
	start of the central directory	2 bytes
	total number of entries in
	the central dir on this disk	2 bytes
	total number of entries in
	the central dir			2 bytes
	size of the central directory   4 bytes
	offset of start of central
	directory with respect to
	the starting disk number	4 bytes
	zipfile comment length		2 bytes
	zipfile comment (variable size)




  C.  Explanation of fields:

      version made by

	  The upper byte indicates the host system (OS) for the
	  file.  Software can use this information to determine
	  the line record format for text files etc.  The current
	  mappings are:

	  0 - MS-DOS and OS/2 (F.A.T. file systems)
	  1 - Amiga			2 - VMS
	  3 - *nix			4 - VM/CMS
	  5 - Atari ST                  6 - OS/2 H.P.F.S.
	  7 - Macintosh			8 - Z-System
	  9 - CP/M			10 thru 255 - unused

	  The lower byte indicates the version number of the
	  software used to encode the file.  The value/10
	  indicates the major version number, and the value
	  mod 10 is the minor version number.

      version needed to extract

	  The minimum software version needed to extract the
	  file, mapped as above.

      general purpose bit flag:

          bit 0: If set, indicates that the file is encrypted.
          bit 1: If the compression method used was type 6,
		 Imploding, then this bit, if set, indicates
		 an 8K sliding dictionary was used.  If clear,
		 then a 4K sliding dictionary was used.
          bit 2: If the compression method used was type 6,
		 Imploding, then this bit, if set, indicates
		 an 3 Shannon-Fano trees were used to encode the
		 sliding dictionary output.  If clear, then 2
		 Shannon-Fano trees were used.
	  Note:  Bits 1 and 2 are undefined if the compression
		 method is other than type 6 (Imploding).

          The upper three bits are reserved and used internally
	  by the software when processing the zipfile.  The
	  remaining bits are unused in version 1.0.

      compression method:

	  (see accompanying documentation for algorithm
	  descriptions)

	  0 - The file is stored (no compression)
	  1 - The file is Shrunk
	  2 - The file is Reduced with compression factor 1
	  3 - The file is Reduced with compression factor 2
	  4 - The file is Reduced with compression factor 3
	  5 - The file is Reduced with compression factor 4
          6 - The file is Imploded

      date and time fields:

	  The date and time are encoded in standard MS-DOS
	  format.

      CRC-32:

	  The CRC-32 algorithm was generously contributed by
	  David Schwaderer and can be found in his excellent
	  book "C Programmers Guide to NetBIOS" published by
	  Howard W. Sams & Co. Inc.  The 'magic number' for
	  the CRC is 0xdebb20e3.  The proper CRC pre and post
	  conditioning is used, meaning that the CRC register
	  is pre-conditioned with all ones (a starting value
	  of 0xffffffff) and the value is post-conditioned by
	  taking the one's complement of the CRC residual.
	
      compressed size:
      uncompressed size:

	  The size of the file compressed and uncompressed,
	  respectively.

      filename length:
      extra field length:
      file comment length:

	  The length of the filename, extra field, and comment
	  fields respectively.  The combined length of any
	  directory record and these three fields should not
	  generally exceed 65,535 bytes.

      disk number start:

	  The number of the disk on which this file begins.

      internal file attributes:

	  The lowest bit of this field indicates, if set, that
	  the file is apparently an ASCII or text file.  If not
	  set, that the file apparently contains binary data.
	  The remaining bits are unused in version 1.0.

      external file attributes:

	  The mapping of the external attributes is
	  host-system dependent (see 'version made by').  For
	  MS-DOS, the low order byte is the MS-DOS directory
	  attribute byte.

      relative offset of local header:

	  This is the offset from the start of the first disk on
	  which this file appears, to where the local header should
	  be found.

      filename:

	  The name of the file, with optional relative path.
	  The path stored should not contain a drive or
	  device letter, or a leading slash.  All slashes
	  should be forward slashes '/' as opposed to
	  backwards slashes '\' for compatibility with Amiga
	  and Unix file systems etc.

      extra field:

	  This is for future expansion.  If additional information
	  needs to be stored in the future, it should be stored
	  here.  Earlier versions of the software can then safely
	  skip this file, and find the next file or header.  This
	  field will be 0 length in version 1.0.

	  In order to allow different programs and different types 
	  of information to be stored in the 'extra' field in .ZIP 
	  files, the following structure should be used for all 
	  programs storing data in this field:

	  header1+data1 + header2+data2 . . .

	  Each header should consist of:

	    Header ID - 2 bytes
	    Data Size - 2 bytes

	  Note: all fields stored in Intel low-byte/high-byte order.

	  The Header ID field indicates the type of data that is in 
	  the following data block.
      
	  Header ID's of 0 thru 31 are reserved for use by PKWARE.  
	  The remaining ID's can be used by third party vendors for 
	  proprietary usage.

	  The Data Size field indicates the size of the following 
	  data block. Programs can use this value to skip to the 
	  next header block, passing over any data blocks that are 
	  not of interest.

	  Note: As stated above, the size of the entire .ZIP file
		header, including the filename, comment, and extra
		field should not exceed 64K in size.

	  In case two different programs should appropriate the same 
	  Header ID value, it is strongly recommended that each 
	  program place a unique signature of at least two bytes in 
	  size (and preferably 4 bytes or bigger) at the start of 
	  each data area.  Every program should verify that it's 
	  unique signature is present, in addition to the Header ID 
	  value being correct, before assuming that it is a block of 
	  known type.

      file comment:

	  The comment for this file.

      number of this disk:

	  The number of this disk, which contains central
	  directory end record.

      number of the disk with the start of the central directory:

	  The number of the disk on which the central
	  directory starts.

      total number of entries in the central dir on this disk:

	  The number of central directory entries on this disk.
	
      total number of entries in the central dir:

	  The total number of files in the zipfile.


      size of the central directory:

	  The size (in bytes) of the entire central directory.

      offset of start of central directory with respect to
      the starting disk number:

	  Offset of the start of the central direcory on the
	  disk on which the central directory starts.

      zipfile comment length:

	  The length of the comment for this zipfile.

      zipfile comment:

	  The comment for this zipfile.


  D.  General notes:

      1)  All fields unless otherwise noted are unsigned and stored
	  in Intel low-byte:high-byte, low-word:high-word order.

      2)  String fields are not null terminated, since the
	  length is given explicitly.

      3)  Local headers should not span disk boundries.  Also, even
	  though the central directory can span disk boundries, no
	  single record in the central directory should be split
	  across disks.

      4)  The entries in the central directory may not necessarily
	  be in the same order that files appear in the zipfile.

*/

/* Code starts here */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <fcntl.h>
#include <time.h>
#include <malloc.h>
#include <io.h>


#pragma pack(2)

struct local_zip_header
{
  unsigned long	signature;	/* 0x04034b50 */
  unsigned int	extr_ver;	/* version needed to extract */
  unsigned int	bit_flag;	/* general purpose bit flag */
  unsigned int	method;		/* compression method */
  unsigned int	last_mod_time; 	/* last mod file time */
  unsigned int	last_mod_date;	/* last mod file date */
  unsigned long	crc;		/* crc-32 */
  unsigned long comp_size;	/* compressed size */
  unsigned long uncomp_size;	/* uncompressed size */
  size_t	name_len;	/* filename length */
  size_t	extra_len;	/* extra field length */

  /* filename (variable size) */
  /* extra field (variable size) */
};

struct zip_header
{
  unsigned long	signature;	/* 0x02014b50 */
  unsigned int	creat_ver;	/* version made by */
  unsigned int	extr_ver;	/* version needed to extract */
  unsigned int	bit_flag;	/* general purpose bit flag */
  unsigned int	method;		/* compression method */
  unsigned int	last_mod_time; 	/* last mod file time */
  unsigned int	last_mod_date;	/* last mod file date */
  unsigned long	crc;		/* crc-32 */
  unsigned long comp_size;	/* compressed size */
  unsigned long uncomp_size;	/* uncompressed size */
  size_t	name_len;	/* filename length */
  size_t	extra_len;	/* extra field length */
  size_t	comment_len;	/* file comment length */
  unsigned int	disk_start;	/* disk number start */
  unsigned int	int_attrib;	/* internal file attributes */
  unsigned long	ext_attrib;	/* external file attributes */
  unsigned long offset;		/* relative offset of local header */

  /* filename (variable size) */
  /* extra field (variable size) */
  /* file comment (variable size) */
};

struct central_dir
{
  unsigned long	signature;	/* 0x06054b50 */
  unsigned int	disk_num;	/* number of this disk */
  unsigned int	cd_disk_num;	/* number of the disk with the start
				   of the central directory */
  unsigned int	dir_entries;	/* total number of entries in the
				   central dir on this disk */
  unsigned int	total_entries;	/* total number of entries in the
				   central dir */
  unsigned long	dir_size;	/* size of the central directory */
  unsigned long	dir_offset;	/* offset of start of central directory
				   with respect to the starting disk number */
  size_t	comment_len;	/* zipfile comment length */

  /* zipfile comment (variable size) */
};

#pragma pack()


char *zip_get_first (char *filename, int *fd_ptr,
		     struct local_zip_header *header,
		     long *header_pos, long *data_pos);
char *zip_get_next (int fd, struct local_zip_header *header,
		    long *header_pos, long *data_pos);

long ar_scan (char *archive, long (*f) (int, char *, long, long, long, long,
	      int, int, int, long), long arg);
static long ar_member_pos (int desc, char *name, long hdrpos, long datapos,
			   long size, long date, int uid, int gid, int mode,
			   char *mem);
long ar_name_equal (char *name, char *mem);
long ar_member_touch (char *arname, char *memname);

time_t dos_time (unsigned int time, unsigned int date);

extern void *xmalloc (size_t size);

#ifdef TEST
char *program_name;
void fatal (int code, char *format, ... );
#endif

static int month_offset[12] =
{
    0, /* January */
   31, /* February */
   59, /* March */
   90, /* April */
  120, /* May */
  151, /* June */
  181, /* July */
  212, /* August */
  243, /* September */
  273, /* October */
  304, /* November */
  334, /* December */
};


#define leap_year(n)	(((n) & 0x0600) == 0)	/* 1980 was! */
#define year(n)		(((n) & 0xff00) >> 9)
#define month(n)	(((n) & 0x01e0) >> 5)
#define day(n)		((n) & 0x001f)

#define hour(n)		(((n) & 0xf800) >> 11)
#define minutes(n)	(((n) & 0x07e0) >> 5)
#define seconds(n)	(((n) & 0x001f) << 1)

time_t
dos_time (unsigned int time, unsigned int date)
{
  time_t result = 3652;		/* 1970 - 1980, (incl. 2 leap years) */

  result += year (date) * 365L;
  result += year (date) >> 2;	/* add leap years! */

  result += month_offset[month (date) - 1] + day (date);

  if (leap_year(date) && month (date) > 2)	/* After Feb. in leap year */
    result++;
  result *= 24L;		/* convert to hours */
  result += hour (time);

  result *= 60L;		/* convert to minutes */
  result += minutes (time);

  result *= 60L;		/* convert to seconds */
  result += seconds (time);

  return result + timezone;
}

/* Magic numbers.  */

#define ZIP_HEADER_SIGNATURE	0x02014b50	/* "\x50\x4b" = "PK" !!! */
#define LOCAL_HEADER_SIGNATURE	0x04034b50
#define CENTRAL_DIR_SIGNATURE	0x06054b50

char *
zip_get_first (char *filename, int *fd_ptr, struct local_zip_header *header,
	       long *header_pos, long *data_pos)
{
  tzset ();			/* in case the caller forgot */

  *fd_ptr = open (filename, O_RDONLY|O_BINARY);

  if (*fd_ptr < 0)
    return NULL;

  return zip_get_next (*fd_ptr, header, header_pos, data_pos);
}


char *
zip_get_next (int fd, struct local_zip_header *header,
	      long *header_pos, long *data_pos)
{
  size_t bytes;
  char *member_name = NULL;

  *header_pos = tell (fd);

  bytes = read (fd, (char *) header, sizeof (struct local_zip_header));
  if (bytes != sizeof (struct local_zip_header))
    return NULL;

  if (header->signature != LOCAL_HEADER_SIGNATURE)
    return NULL;

  member_name = (char *) xmalloc (header->name_len + 1);

  bytes = read (fd, member_name, header->name_len);
  if (bytes != header->name_len)
    return NULL;

  member_name[header->name_len] = '\0';

  *data_pos = *header_pos + sizeof (struct local_zip_header)
	      + header->name_len + header->extra_len;

  lseek (fd, header->comp_size + (long) header->extra_len, SEEK_CUR);

  return strlwr (member_name);
}


/* Takes three arguments ARCHIVE, FUNCTION and ARG.

   Open the archive named ARCHIVE, find its members one by one,
   and for each one call FUNCTION with the following arguments:
     archive file descriptor for reading the data,
     member name,
     member header position in file,
     member data position in file,
     member data size,
     member date,
     member uid,
     member gid,
     member protection mode,
     ARG.

   The descriptor is poised to read the data of the member
   when FUNCTION is called.  It does not matter how much
   data FUNCTION reads.

   If FUNCTION returns nonzero, we immediately return
   what FUNCTION returned.

   Returns -1 if archive does not exist,
   Returns -2 if archive has invalid format.
   Returns 0 if have scanned successfully.  */

long
ar_scan (char *archive,
	 long (*f) (int, char *, long, long, long, long, int, int, int, long),
	 long arg)
{
  int fd;
  struct local_zip_header header;
  long header_pos;
  long data_pos;
  char *name = zip_get_first (archive, &fd, &header, &header_pos, &data_pos);

  if (fd < 0)
    return -1L;
  if (name == NULL)
    return -2L;

  while (name && *name)
    {
      time_t time_buf = dos_time (header.last_mod_time, header.last_mod_date);

      long fnval = (*f) (fd, name,
			 header_pos, data_pos,
			 header.uncomp_size,
			 time_buf,
			 0, 0, 0,
			 arg);

      if (fnval)
	{
	  close (fd);
	  return fnval;
	}

      free (name);

      name = zip_get_next (fd, &header, &header_pos, &data_pos);
    }

  close (fd);
  return 0L;
}

/* Return nonzero iff NAME matches MEM.  If NAME is longer than
   sizeof (struct ar_hdr.ar_name), MEM may be the truncated version.  */

long
ar_name_equal (name, mem)
     char *name, *mem;
{
  return (long) !strcmp (name, mem);
}

/* ARGSUSED */
static long int
ar_member_pos (desc, name, hdrpos, datapos, size, date, uid, gid, mode, mem)
     int desc;
     char *name;
     long int hdrpos, datapos, size, date;
     int uid, gid, mode;
     char *mem;
{
  if (!ar_name_equal (name, mem))
    return 0;
  return hdrpos;
}

/* Set date of member MEMNAME in archive ARNAME to current time.
   Returns 0 if successful,
   -1 if file ARNAME does not exist,
   -2 if not a valid archive,
   -3 if other random system call error (including file read-only),
   1 if valid but member MEMNAME does not exist.  */

long
ar_member_touch (arname, memname)
     char *arname, *memname;
{
  /* CODE ME !!! */

  return -3L;
}

#ifdef TEST

long int
describe_member (desc, name, hdrpos, datapos, size, date, uid, gid, mode)
     int desc;
     char *name;
     long int hdrpos, datapos, size, date;
     int uid, gid, mode;
{
  extern char *ctime ();

  printf ("Member %s: %ld bytes at %ld (%ld).\n", name, size, hdrpos, datapos);
  printf ("  Date %s", ctime (&date));
  printf ("  uid = %d, gid = %d, mode = 0%o.\n", uid, gid, mode);

  return 0;
}

void
main (int argc, char **argv)
{
  ar_scan (argv[1], describe_member);
}


void *
xmalloc (size_t size)
{
  register void *ptr = malloc (size);

  if (ptr == (void *)0)
    fatal (2, "out of memory");

  return(ptr);
}

void
fatal (int code, char *format, ... )
{
  va_list arg_ptr;		/* variable-length arguments	*/
  va_start (arg_ptr, format);

  fprintf (stderr, "%s: fatal error: ", program_name);
  vfprintf (stderr, format, arg_ptr);
  fprintf (stderr, ".\n");
  exit (code);
}

#endif /* TEST */

#if 0

/* Look alike to the portable directory functions.*/

struct _zipcontents
{
  char *_z_entry;
  struct _zipcontents *_z_next;
};

typedef struct _zipdesc
{
  int zd_fd;				/* file handle */
  int zd_access;			/* access mode (O_RDWR or O_RDONLY) */
  struct _zipcontents *zd_contents;	/* root of the list of entries */
  struct _zipcontents *zd_cp;		/* current entry */
} ZIP;


#define	rewindzip(zipp)	seekzip (zipp, 0L)

void seekzip (ZIP *zipp, long off);
long tellzip (ZIP *zipp);
ZIP *openzip (char *name);
void closezip (ZIP *zipp);
struct zip_header *readzip (ZIP *zipp);

void
seekzip (ZIP *zipp, long off)
{
  /* CODE ME !!! */

  return lseek (zipp->zd_fd, off, SEEK_SET);

  /* better: seek() for name! */
}

long
tellzip (ZIP *zipp)
{
  /* CODE ME !!! */

  return tell (zipp->zd_fd);
}

/* Open the zipfile NAME, scan through the local headers and check with
   the central directory for consistency.  Put the central directory
   entries into the linked list rooted by zipp->zd_contents.  */

ZIP *
openzip (char *name)
{
  ZIP *zipp;

  zipp->zd_access = O_RDWR;	/* we might want to `touch' the archive  */
  zipp->zd_fd = open (name, zipp->zd_access|O_BINARY);
  if (zipp->zd_fd == -1)
    {				/* at least, try to read the archive  */
      zipp->zd_access = O_RDONLY;
      zipp->zd_fd = open (name, zipp->zd_access|O_BINARY);
      if (zipp->zd_fd == -1)
	return NULL;
    }

  /* CODE ME !!! */

  return zipp;
}

void
closezip (ZIP *zipp)
{
  /* CODE ME !!! */

  close (zipp->zd_fd);
}

struct zip_header *
readzip (ZIP *zipp)
{
  /* CODE ME !!! */
}

#endif /* NEVER */

/* 
 * Local Variables:
 * mode:C
 * ChangeLog:ChangeLog
 * compile-command:cl -DTEST -W4 zipscan.c
 * End:
 */
