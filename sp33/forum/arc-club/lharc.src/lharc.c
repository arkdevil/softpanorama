/*----------------------------------------------------------------------*/
/*		LHarc Archiver Driver for UNIX				*/
/*									*/
/*		Copyright(C) MCMLXXXIX  Yooichi.Tagawa			*/
/*		Thanks to H.Yoshizaki. (MS-DOS LHarc)			*/
/*									*/
/*  V0.00  Original				1988.05.23  Y.Tagawa	*/
/*  V0.01  Alpha Version (for 4.2BSD)		1989.05.28  Y.Tagawa	*/
/*  V0.02  Alpha Version Rel.2			1989.05.29  Y.Tagawa	*/
/*  V0.03  Release #3  Beta Version		1989.07.02  Y.Tagawa	*/
/*  V0.03a Fix few bug				1989.07.03  Y.Tagawa	*/
/*----------------------------------------------------------------------*/


#include <stdio.h>
#include <ctype.h>

#include <sys/types.h>
#include <sys/time.h>
#include <sys/file.h>
#include <sys/stat.h>

/* most of System V,  define SYSTIME_HAS_NO_TM */
#ifdef SYSTIME_HAS_NO_TM
#include <time.h>
#endif

/* #include <strings.h> */
/* #include <string.h> */


/*----------------------------------------------------------------------*/
/*			DIRECTORY ACCESS STUFF				*/
/*----------------------------------------------------------------------*/
#ifndef NODIRECTORY
#ifdef SYSV_SYSTEM_DIR

#include <dirent.h>
#define DIRENTRY	struct dirent
#define NAMREN(p)	strlen (p->d_name)

#else	/* not SYSV_SYSTEM_DIR */

#ifdef NONSYSTEM_DIR_LIBRARY
#include "lhdir.h"
#else	/* not NONSYSTEM_DIR_LIBRARY */
#include <sys/dir.h>
#endif	/* not NONSYSTEM_DIR_LIBRARY */

#define DIRENTRY	struct direct
#define NAMLEN(p)	p->d_namlen

extern DIR *opendir ();
extern struct direct *readdir ();

#endif	/* not SYSV_SYSTEM_DIR */
#endif

/*----------------------------------------------------------------------*/
/*			FILE ATTRIBUTES					*/
/*----------------------------------------------------------------------*/

/* If file mode is not compatible between your Machine/OS and
   LHarc standard UNIX file mode.
   (See UNIX Manual stat(1), <sys/stat.h>,
   and/or below UNIX_* difinitions. ) */
/* #define NOT_COMPATIBLE_MODE */


/*----------------------------------------------------------------------*/
/*			MEMORY FUNCTIONS 				*/
/*----------------------------------------------------------------------*/

#ifdef NOBSTRING
#ifdef __ANSI__
#include "mem.h"
#define bcmp(a,b,n) memcmp ((a),(b),(n))
#define bcopy(s,d,n) memmove((d),(s),(n))
#define bzero(d,n) memset((d),0,(n))
#else	/* not __ANSI__ */
#include "memory.h"
#define bcmp(a,b,n) memcmp ((a),(b),(n))
#define bcopy(s,d,n) memcpy ((d),(s),(n))	/* movmem((s),(d),(n)) */
#define bzero(d,n) memset((d),0,(n))
#endif	/* not __ANSI__ */
#endif	/* NOBSTRING */


/*----------------------------------------------------------------------*/
/*			YOUR CUSTOMIZIES				*/
/*----------------------------------------------------------------------*/
/* These difinitions are changable to you like. */
/* #define ARCHIVENAME_EXTENTION	".LZH"		*/
/* #define TMP_FILENAME_TEMPLATE	"/tmp/lhXXXXXX"	*/
/* #define BACKUPNAME_EXTENTION		".BAK"		*/
/* #define MULTIBYTE_CHAR				*/
/* #define USE_PROF					*/



#define SJC_FIRST_P(c)			\
  (((unsigned char)(c) >= 0x80) &&	\
   (((unsigned char)(c) < 0xa0) ||	\
    ((unsigned char)(c) >= 0xe0) &&	\
    ((unsigned char)(c) < 0xfd)))
#define SJC_SECOND_P(c)			\
  (((unsigned char)(c) >= 0x40) &&	\
   ((unsigned char)(c) < 0xfd) &&	\
   ((ungigned char)(c) != 0x7f))

#ifdef MULTIBYTE_CHAR
#define MULTIBYTE_FIRST_P	SJC_FIRST_P
#define MULTIBYTE_SECOND_P	SJC_SECOND_P
#endif MULTIBYTE_CHAR

/*----------------------------------------------------------------------*/
/*			OTHER DIFINITIONS				*/
/*----------------------------------------------------------------------*/

#ifndef SEEK_SET
#define SEEK_SET	0
#define SEEK_CUR	1
#define SEEK_END	2
#endif

#define FILENAME_LENGTH	1024


/* non-integral functions */
extern struct tm *localtime ();
extern char *getenv ();
extern char *malloc ();
extern char *realloc ();


/* external variables */
extern int errno;


#define	FALSE	0
#define TRUE	1
typedef int boolean;


/*----------------------------------------------------------------------*/
/*		LHarc FILE DIFINITIONS					*/
/*----------------------------------------------------------------------*/
#define METHOD_TYPE_STRAGE	5
#define LZHUFF0_METHOD		"-lh0-"
#define LZHUFF1_METHOD		"-lh1-"
#define LARC4_METHOD		"-lz4-"
#define LARC5_METHOD		"-lz5-"

#define I_HEADER_SIZE			0
#define I_HEADER_CHECKSUM		1
#define I_METHOD			2
#define I_PACKED_SIZE			7
#define I_ORIGINAL_SIZE			11
#define I_LAST_MODIFIED_STAMP		15
#define I_ATTRIBUTE			19
#define I_NAME_LENGTH			21
#define I_NAME				22

#define I_CRC				22 /* + name_length */
#define I_EXTEND_TYPE			24 /* + name_length */
#define I_MINOR_VERSION			25 /* + name_length */
#define I_UNIX_LAST_MODIFIED_STAMP	26 /* + name_length */
#define I_UNIX_MODE			30 /* + name_length */
#define I_UNIX_UID			32 /* + name_length */
#define I_UNIX_GID			34 /* + name_length */
#define I_UNIX_EXTEND_BOTTOM		36 /* + name_length */



#define EXTEND_GENERIC	0
#define EXTEND_UNIX	'U'
#define EXTEND_MSDOS	'M'
#define EXTEND_MACOS	'm'
#define EXTEND_OS9	'9'
#define EXTEND_OS2	'2'
#define EXTEND_OS68K	'K'
#define EXTEND_OS386	'3'
#define EXTEND_HUMAN	'H'
#define EXTEND_CPM	'C'
#define EXTEND_FLEX	'F'

#define GENERIC_ATTRIBUTE		0x20
#define GENERIC_DIRECTORY_ATTRIBUTE	0x10

#define CURRENT_UNIX_MINOR_VERSION	0x00



typedef struct LzHeader {
  unsigned char		header_size;
  char			method[METHOD_TYPE_STRAGE];
  long			packed_size;
  long			original_size;
  long			last_modified_stamp;
  unsigned short	attribute;
  char			name[256];
  unsigned short	crc;
  boolean		has_crc;
  unsigned char		extend_type;
  unsigned char		minor_version;
  /*  extend_type == EXTEND_UNIX  and convert from other type. */
  time_t		unix_last_modified_stamp;
  unsigned short	unix_mode;
  unsigned short	unix_uid;
  unsigned short	unix_gid;
} LzHeader;

#define UNIX_FILE_TYPEMASK	0170000
#define UNIX_FILE_REGULAR	0100000
#define UNIX_FILE_DIRECTORY	0040000
#define UNIX_SETUID		0004000
#define UNIX_SETGID		0002000
#define UNIX_STYCKYBIT		0001000
#define UNIX_OWNER_READ_PERM	0000400
#define UNIX_OWNER_WRITE_PERM	0000200
#define UNIX_OWNER_EXEC_PERM	0000100
#define UNIX_GROUP_READ_PERM	0000040
#define UNIX_GROUP_WRITE_PERM	0000020
#define UNIX_GROUP_EXEC_PERM	0000010
#define UNIX_OTHER_READ_PERM	0000004
#define UNIX_OTHER_WRITE_PERM	0000002
#define UNIX_OTHER_EXEC_PERM	0000001
#define UNIX_RW_RW_RW		0000666

#define LZHEADER_STRAGE		256

/*----------------------------------------------------------------------*/
/*		PROGRAM 						*/
/*----------------------------------------------------------------------*/


#define CMD_UNKNOWN	0
#define CMD_EXTRACT	1
#define CMD_APPEND	2
#define CMD_VIEW	3

static int	cmd = CMD_UNKNOWN; 
static char	**cmd_filev;
static int	cmd_filec;
static char	*archive_name;
static char	expanded_archive_name[FILENAME_LENGTH];
static char	temporary_name[FILENAME_LENGTH];


/* options */
boolean	quiet = FALSE;
boolean	text_mode = FALSE;
/*static boolean  verbose = FALSE; */
static boolean	noexec = FALSE;	/* debugging option */
static boolean	force = FALSE;
static boolean	prof = FALSE;


/* view flags */
static boolean	long_format_listing = FALSE;

/* extract flags */
static boolean	output_to_stdout = FALSE;

/* append flags */
static boolean	new_archive = FALSE;
static boolean	update_if_newer = FALSE;
static boolean	delete_after_append = FALSE;
static boolean	delete_from_archive = FALSE;

static boolean	remove_temporary_at_error = FALSE;


/*----------------------------------------------------------------------*/
/* NOTES :	Text File Format					*/
/*	GENERATOR		NewLine					*/
/*	[generic]		0D 0A					*/
/*	[MS-DOS]		0D 0A					*/
/*	[MacOS]			0D					*/
/*	[UNIX]			0A					*/
/*----------------------------------------------------------------------*/


main (argc, argv)
     int argc;
     char *argv[];
{
  char *p;

  if (argc < 3)
    print_tiny_usage_and_exit ();

  /* commands */
  switch (argv[1][0])
    {
    case 'x':
    case 'e':
      cmd = CMD_EXTRACT;
      break;

    case 'p':
      output_to_stdout = TRUE;
      cmd = CMD_EXTRACT;
      break;

    case 'c':
      new_archive = TRUE;
      cmd = CMD_APPEND;
      break;

    case 'a':
      cmd = CMD_APPEND;
      break;

    case 'd':
      delete_from_archive = TRUE;
      cmd = CMD_APPEND;
      break;

    case 'u':
      update_if_newer = TRUE;
      cmd = CMD_APPEND;
      break;

    case 'm':
      delete_after_append = TRUE;
      cmd = CMD_APPEND;
      break;

    case 'v':
      cmd = CMD_VIEW;
      break;

    case 'l':
      long_format_listing = TRUE;
      cmd = CMD_VIEW;
      break;

    case 'h':
    default:
      print_tiny_usage_and_exit ();
    }

  /* options */
  p = &argv[1][1];
  for (p = &argv[1][1]; *p; )
    {
      switch (*p++)
	{
	case 'q':	quiet = TRUE; break;
	case 'f':	force = TRUE; break;
	case 'p':	prof = TRUE; break;
/*	case 'v':	verbose = TRUE; break; */
	case 't':	text_mode = TRUE; break;
	case 'n':	noexec = TRUE; break;

	default:
	  fprintf (stderr, "unknown option '%c'.\n", p[-1]);
	  exit (1);
	}
    }

  /* archive file name */
  archive_name = argv[2];

  /* target file name */
  cmd_filec = argc - 3;
  cmd_filev = argv + 3;
  sort_files ();

  switch (cmd)
    {
    case CMD_EXTRACT:	cmd_extract ();	break;
    case CMD_APPEND:	cmd_append ();	break;
    case CMD_VIEW:	cmd_view ();	break;
    }

#ifdef USE_PROF
  if (!prof)
    exit (0);
#endif

  exit (0);
}

print_tiny_usage_and_exit ()
{
  fprintf (stderr, "\
LHarc for UNIX  V0.03 (Beta Version)   Copyright(C) 1989  Y.Tagawa\n\
usage: lharc {axevludmcp}[qnft] archive_file [files or directories...]\n\
commands:		options:				\n\
 a   Append		 q   quiet				\n\
 x,e EXtract		 n   no execute				\n\
 v,l View/List		 f   force (over write at extract)	\n\
 u   Update newer files						\n\
 d   Delete		 t   FILES are TEXT file		\n\
 m   Move							\n\
 c   re-Construct new archive					\n\
 p   Print to STDOUT						\n\
");
  exit (1);
}

message (title, msg)
     char *title, *msg;
{
  fprintf (stderr, "LHarc: ");
  if (errno == 0)
    fprintf (stderr, "%s %s\n", title, msg);
  else
    perror (msg);
}

warning (msg)
     char *msg;
{
  message ("Warning :", msg);
}

error (msg)
     char *msg;
{
  message ("Error :", msg);

  if (remove_temporary_at_error)
    unlink (temporary_name);

  exit (1);
}

static char *writting_filename;
static char *reading_filename;

write_error ()
{
  error (writting_filename);
}

read_error ()
{
  error (reading_filename);
}



/*----------------------------------------------------------------------*/
/*									*/
/*----------------------------------------------------------------------*/

static boolean expand_archive_name (dst, src)
     char *dst, *src;
{
  register char *p, *dot;

  strcpy (dst, src);

  for (p = dst, dot = (char*)0; *p; p++)
    if (*p == '.')
      dot = p;
    else if (*p == '/')
      dot = (char*)0;

  if (dot)
    p = dot;

#ifdef ARCHIVENAME_EXTENTION
  strcpy (p, ARCHIVENAME_EXTENTION);
#else
  strcpy (p, ".lzh");
#endif
  return (strcmp (dst, src) != 0);
}

#define STRING_COMPARE(a,b) strcmp((a),(b))

static int sort_by_ascii (a, b)
     char **a, **b;
{
  return STRING_COMPARE (*a, *b);
}

sort_files ()
{
  qsort (cmd_filev, cmd_filec, sizeof (char*), sort_by_ascii);
}

static char *strdup (string)
     char *string;
{
  int	len = strlen (string) + 1;
  char	*p = malloc (len);
  bcopy (string, p, len);
  return p;
}

#ifdef NODIRECTORY
/* please need your imprementation */
static boolean find_files (name, v_filec, v_filev)
     char	*name;
     int	*v_filec;
     char	***v_filev;
{
  return FALSE;			/* DUMMY */
}
#else
static boolean find_files (name, v_filec, v_filev)
     char	*name;
     int	*v_filec;
     char	***v_filev;
{
  char		newname[FILENAME_LENGTH];
  int 		len, n;
  DIR		*dirp;
  DIRENTRY	*dp;
  int		alloc_size = sizeof (char**) * 61; /* any (^_^) */
  char		**filev;
  int		filec = 0;

  strcpy (newname, name);
  len = strlen (name);

  dirp = opendir (name);
  if (dirp)
    {
      filev = (char**)malloc (alloc_size);
      if (!filev)
	error ("not enough memory");

      for (dp = readdir (dirp); dp != NULL; dp = readdir (dirp))
	{
	  n = NAMLEN (dp);
	  if ((dp->d_ino != 0) &&
	      ((dp->d_name[0] != '.') ||
	       ((n != 1) &&
		((dp->d_name[1] != '.') ||
		 (n != 2)))) &&			/* exclude '.' and '..' */
	      (strcmp (dp->d_name, temporary_name) != 0) &&
	      (strcmp (dp->d_name, archive_name) != 0))
	    {
	      if ((len != 0) && (newname[len-1] != '/'))
		{
		  newname[len] = '/';
		  strncpy (newname+len+1, dp->d_name, n);
		  newname[len+n+1] = '\0';
		}
	      else
		{
		  strncpy (newname+len, dp->d_name, n);
		  newname[len+n] = '\0';
		}


	      filev[filec++] = strdup (newname);
	      if (filec == alloc_size)
		{
		  alloc_size *= 2;
		  filev = (char**)realloc (filev, alloc_size);
		}
	    }
	}
      closedir (dirp);
    }

  *v_filev = filev;
  *v_filec = filec;
  if (dirp)
    {
      qsort (filev, filec, sizeof (char*), sort_by_ascii);
      return TRUE;
    }
  else
    return FALSE;
}
#endif

static free_files (filec, filev)
     int	filec;
     char	**filev;
{
  int		i;

  for (i = 0; i < filec; i ++)
    free (filev[i]);

  free (filev);
}


/*----------------------------------------------------------------------*/
/*									*/
/*----------------------------------------------------------------------*/

static int calc_sum (p, len)
     register char *p;
     register int len;
{
  register int sum;

  for (sum = 0; len; len--)
    sum += *p++;

  return sum & 0xff;
}

static unsigned char *get_ptr;
#define setup_get(PTR) get_ptr = (unsigned char*)(PTR)
#define get_byte() (*get_ptr++)
#define put_ptr	get_ptr
#define setup_put(PTR) put_ptr = (unsigned char*)(PTR)
#define put_byte(c) *put_ptr++ = (unsigned char)(c)

static unsigned short get_word ()
{
  int b0, b1;

  b0 = get_byte ();
  b1 = get_byte ();
  return (b1 << 8) + b0;
}

static put_word (v)
     unsigned int	v;
{
  put_byte (v);
  put_byte (v >> 8);
}

static long get_longword ()
{
  long b0, b1, b2, b3;

  b0 = get_byte ();
  b1 = get_byte ();
  b2 = get_byte ();
  b3 = get_byte ();
  return (b3 << 24) + (b2 << 16) + (b1 << 8) + b0;
}

static put_longword (v)
     long v;
{
  put_byte (v);
  put_byte (v >> 8);
  put_byte (v >> 16);
  put_byte (v >> 24);
}


static msdos_to_unix_filename (name, len)
     register char *name;
     register int len;
{
  register int i;

#ifdef MULTIBYTE_CHAR
  for (i = 0; i < len; i ++)
    {
      if (MULTIBYTE_FIRST_P (name[i]) &&
	  MULTIBYTE_SECOND_P (name[i+1]))
	i ++;
      else if (name[i] == '\\')
	name[i] = '/';
      else if (isupper (name[i]))
	name[i] = tolower (name[i]);
    }
#else
  for (i = 0; i < len; i ++)
    {
      if (name[i] == '\\')
	name[i] = '/';
      else if (isupper (name[i]))
	name[i] = tolower (name[i]);
    }
#endif
}

static generic_to_unix_filename (name, len)
     register char *name;
     register int len;
{
  register int i;
  boolean	lower_case_used = FALSE;

#ifdef MULTIBYTE_CHAR
  for (i = 0; i < len; i ++)
    {
      if (MULTIBYTE_FIRST_P (name[i]) &&
	  MULTIBYTE_SECOND_P (name[i+1]))
	i ++;
      else if (islower (name[i]))
	{
	  lower_case_used = TRUE;
	  break;
	}
    }
  for (i = 0; i < len; i ++)
    {
      if (MULTIBYTE_FIRST_P (name[i]) &&
	  MULTIBYTE_SECOND_P (name[i+1]))
	i ++;
      else if (name[i] == '\\')
	name[i] = '/';
      else if (!lower_case_used && isupper (name[i]))
	name[i] = tolower (name[i]);
    }
#else
  for (i = 0; i < len; i ++)
    if (islower (name[i]))
      {
	lower_case_used = TRUE;
	break;
      }
  for (i = 0; i < len; i ++)
    {
      if (name[i] == '\\')
	name[i] = '/';
      else if (!lower_case_used && isupper (name[i]))
	name[i] = tolower (name[i]);
    }
#endif
}

static macos_to_unix_filename (name, len)
     register char *name;
     register int len;
{
  register int i;

  for (i = 0; i < len; i ++)
    {
      if (name[i] == ':')
	name[i] = '/';
      else if (name[i] == '/')
	name[i] = ':';
    }
}

/*----------------------------------------------------------------------*/
/*									*/
/*	Generic stamp format:						*/
/*									*/
/*	 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16		*/
/*	|<-------- year ------->|<- month ->|<-- day -->|		*/
/*									*/
/*	 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0		*/
/*	|<--- hour --->|<---- minute --->|<- second*2 ->|		*/
/*									*/
/*----------------------------------------------------------------------*/


static long gettz ()
{
   struct timeval	tp;
   struct timezone	tzp;
   gettimeofday (&tp, &tzp);	/* specific to 4.3BSD */
/* return (tzp.tz_minuteswest * 60 + (tzp.tz_dsttime != 0 ? 60L * 60L : 0));*/
   return (tzp.tz_minuteswest * 60);
}

#ifdef NOT_USED
static struct tm *msdos_to_unix_stamp_tm (a)
     long a;
{
  static struct tm t;
  t.tm_sec	= ( a          & 0x1f) * 2;
  t.tm_min	=  (a >>    5) & 0x3f;
  t.tm_hour	=  (a >>   11) & 0x1f;
  t.tm_mday	=  (a >>   16) & 0x1f;
  t.tm_mon	=  (a >> 16+5) & 0x0f - 1;
  t.tm_year	= ((a >> 16+9) & 0x7f) + 80;
  return &t;
}
#endif

static time_t generic_to_unix_stamp (t)
     long t;
{
  int			year, month, day, hour, min, sec;
  long			longtime;
  static unsigned int	dsboy[12] = { 0, 31, 59, 90, 120, 151, 181, 212,
					243, 273, 304, 334};
  unsigned int		days;

  year  = ((int)(t >> 16+9) & 0x7f) + 1980;
  month =  (int)(t >> 16+5) & 0x0f;	/* 1..12 means Jan..Dec */
  day   =  (int)(t >> 16)   & 0x1f;	/* 1..31 means 1st,...31st */

  hour  =  ((int)t >> 11) & 0x1f;
  min   =  ((int)t >> 5)  & 0x3f;
  sec   = ((int)t         & 0x1f) * 2;

				/* Calculate days since 1970.01.01 */
  days = (365 * (year - 1970) + /* days due to whole years */
	  (year - 1970 + 1) / 4 + /* days due to leap years */
	  dsboy[month-1] +	/* days since beginning of this year */
	  day-1);		/* days since beginning of month */

  if ((year % 4 == 0) &&
      (year % 400 != 0) &&
      (month >= 3))		/* if this is a leap year and month */
    days++;			/* is March or later, add a day */

  /* Knowing the days, we can find seconds */
  longtime = (((days * 24) + hour) * 60 + min) * 60 + sec;
  longtime += gettz ();      /* adjust for timezone */

  /* special case:  if MSDOS format date and time were zero, then we set
     time to be zero here too. */
  if (t == 0)
    longtime = 0;

  /* LONGTIME is now the time in seconds, since 1970/01/01 00:00:00.  */
  return (time_t)longtime;
}

static long unix_to_generic_stamp (t)
     time_t t;
{
  struct tm *tm = localtime (&t);

  return ((((long)(tm->tm_year - 80)) << 25) +
	  (((long)(tm->tm_mon + 1)) << 21) +
	  (((long)tm->tm_mday) << 16) +
	  (long)((tm->tm_hour << 11) +
		 (tm->tm_min << 5) +
		 (tm->tm_sec / 2)));
}

/*----------------------------------------------------------------------*/
/*									*/
/*----------------------------------------------------------------------*/

static boolean get_header (fp, hdr)
     FILE *fp;
     register LzHeader *hdr;
{
  int		header_size;
  int		name_length;
  char		data[LZHEADER_STRAGE];
  int		checksum;
  int		i;

  bzero (hdr, sizeof (LzHeader));

  if (((header_size = getc (fp)) == EOF) || (header_size == 0))
    {
      return FALSE;		/* finish */
    }

  if (fread (data + I_HEADER_CHECKSUM,
		  sizeof (char), header_size + 1, fp) < header_size + 1)
    {
      error ("Invalid header (LHarc file ?)");
      return FALSE;		/* finish */
    }

  setup_get (data + I_HEADER_CHECKSUM);
  checksum = calc_sum (data + I_METHOD, header_size);
  if (get_byte () != checksum)
    warning ("Checksum error (LHarc file?)");

  hdr->header_size = header_size;
  bcopy (data + I_METHOD, hdr->method, METHOD_TYPE_STRAGE);
#ifdef OLD
  if ((bcmp (hdr->method, LZHUFF1_METHOD, METHOD_TYPE_STRAGE) != 0) &&
      (bcmp (hdr->method, LZHUFF0_METHOD, METHOD_TYPE_STRAGE) != 0) &&
      (bcmp (hdr->method, LARC5_METHOD, METHOD_TYPE_STRAGE) != 0) &&
      (bcmp (hdr->method, LARC4_METHOD, METHOD_TYPE_STRAGE) != 0))
    {
      warning ("Unknown method (LHarc file ?)");
      return FALSE;		/* invalid method */
    }
#endif
  setup_get (data + I_PACKED_SIZE);
  hdr->packed_size	= get_longword ();
  hdr->original_size	= get_longword ();
  hdr->last_modified_stamp = get_longword ();
  hdr->attribute	= get_word ();
  name_length		= get_byte ();
  for (i = 0; i < name_length; i ++)
    hdr->name[i] =(char)get_byte ();
  hdr->name[name_length] = '\0';

  /* defaults for other type */
  hdr->unix_mode	= UNIX_FILE_REGULAR | UNIX_RW_RW_RW;
  hdr->unix_gid 	= 0;
  hdr->unix_uid		= 0;

  if (header_size - name_length >= 24)
    {				/* EXTEND FORMAT */
      hdr->crc				= get_word ();
      hdr->extend_type			= get_byte ();
      hdr->minor_version		= get_byte ();
      hdr->has_crc = TRUE;
    }
  else if (header_size - name_length == 22)
    {				/* Generic with CRC */
      hdr->crc				= get_word ();
      hdr->extend_type			= EXTEND_GENERIC;
      hdr->has_crc = TRUE;
    }
  else if (header_size - name_length == 20)
    {				/* Generic no CRC */
      hdr->extend_type			= EXTEND_GENERIC;
      hdr->has_crc = FALSE;
    }
  else
    {
      warning ("Unknown header (LHarc file ?)");
      return FALSE;
    }

  switch (hdr->extend_type)
    {
    case EXTEND_MSDOS:
      msdos_to_unix_filename (hdr->name, name_length);
      hdr->unix_last_modified_stamp	=
	generic_to_unix_stamp (hdr->last_modified_stamp);
      break;

    case EXTEND_UNIX:
      hdr->unix_last_modified_stamp	= (time_t)get_longword ();
      hdr->unix_mode			= get_word ();
      hdr->unix_uid			= get_word ();
      hdr->unix_gid			= get_word ();
      break;

    case EXTEND_MACOS:
      macos_to_unix_filename (hdr->name, name_length);
      hdr->unix_last_modified_stamp	=
	generic_to_unix_stamp (hdr->last_modified_stamp);
      break;

    default:
      generic_to_unix_filename (hdr->name, name_length);
      hdr->unix_last_modified_stamp	=
	generic_to_unix_stamp (hdr->last_modified_stamp);
    }

  return TRUE;
}

static init_header (name, v_stat, hdr)
     char *name;
     struct stat *v_stat;
     LzHeader *hdr;
{
  bcopy (LZHUFF1_METHOD, hdr->method, METHOD_TYPE_STRAGE);
  hdr->packed_size		= 0;
  hdr->original_size		= v_stat->st_size;
  hdr->last_modified_stamp	= unix_to_generic_stamp (v_stat->st_mtime);
  hdr->attribute		= GENERIC_ATTRIBUTE;
  strcpy (hdr->name, name);
  hdr->crc			= 0x0000;
  hdr->extend_type		= EXTEND_UNIX;
  hdr->unix_last_modified_stamp	= v_stat->st_mtime;
				/* 00:00:00 since JAN.1.1970 */
#ifdef NOT_COMPATIBLE_MODE
  Please need your modification in this space.
#else
  hdr->unix_mode		= v_stat->st_mode;
#endif

  hdr->unix_uid			= v_stat->st_uid;
  hdr->unix_gid			= v_stat->st_gid;

  if ((v_stat->st_mode & S_IFMT) == S_IFDIR)
    {
      bcopy (LZHUFF0_METHOD, hdr->method, METHOD_TYPE_STRAGE);
      hdr->attribute = GENERIC_DIRECTORY_ATTRIBUTE;
      hdr->original_size = 0;
      strcat (hdr->name, "/");
    }
}

/* Write only unix extended header. */
write_header (nafp, hdr)
     FILE *nafp;
     LzHeader *hdr;
{
  int		header_size;
  int		name_length;
  char		data[LZHEADER_STRAGE];

  bzero (data, LZHEADER_STRAGE);
  bcopy (hdr->method, data + I_METHOD, METHOD_TYPE_STRAGE);
  setup_put (data + I_PACKED_SIZE);
  put_longword (hdr->packed_size);
  put_longword (hdr->original_size);
  put_longword (hdr->last_modified_stamp);
  put_word (hdr->attribute);
  name_length = strlen (hdr->name);
  put_byte (name_length);
  bcopy (hdr->name, data + I_NAME, name_length);
  setup_put (data + I_NAME + name_length);
  put_word (hdr->crc);
  put_byte (EXTEND_UNIX);
  put_byte (CURRENT_UNIX_MINOR_VERSION);
  put_longword ((long)hdr->unix_last_modified_stamp);
  put_word (hdr->unix_mode);
  put_word (hdr->unix_uid);
  put_word (hdr->unix_gid);
  header_size = I_UNIX_EXTEND_BOTTOM - 2 + name_length;
  data[I_HEADER_SIZE] = header_size;
  data[I_HEADER_CHECKSUM] = calc_sum (data + I_METHOD, header_size);
  if (fwrite (data, sizeof (char), header_size + 2, nafp) == NULL)
    error ("cannot write to temporary file");
}

static boolean archive_is_msdos_sfx1 (name)
     char *name;
{
  int	len = strlen (name);
  return ((len >= 4) &&
	  (strcmp (name + len - 4, ".com") == 0 ||
	   strcmp (name + len - 4, ".exe") == 0));
}

static boolean skip_msdos_sfx1_code (fp)
     FILE *fp;
{
  unsigned char buffer[2048];
  unsigned char *p, *q;
  int	n;

  n = fread (buffer, sizeof (char), 2048, fp);

  for (p = buffer + 2, q = buffer + n - 5; p < q; p ++)
    {
      /* found "-l??-" keyword (as METHOD type string) */
      if (p[0] == '-' && p[1] == 'l' && p[4] == '-')
	{
	  /* size and checksum validate check */
	  if (p[-2] > 20 && p[-1] == calc_sum (p, p[-2]))
	    {
	      fseek (fp, ((p - 2) - buffer) - n, SEEK_CUR);
	      return TRUE;
	    }
	}
    }

  fseek (fp, -n, SEEK_CUR);
  return FALSE;
}


/*----------------------------------------------------------------------*/
/*									*/
/*----------------------------------------------------------------------*/

make_tmp_name (original, name)
     char *original;
     char *name;
{
#ifdef TMP_FILENAME_TEMPLATE
  /* "/tmp/lhXXXXXX" etc. */
  strcpy (name, TMP_FILENAME_TEMPLATE);
#else
  char *p, *s;

  strcpy (name, original);
  for (p = name, s = (char*)0; *p; p++)
    if (*p == '/')
      s = p;

  strcpy ((s ? s+1 : name), "#..lhXXXXXX");
#endif

  mktemp (name);
}

make_backup_name (name, orginal)
     char *name;
     char *orginal;
{
  register char *p, *dot;

  strcpy (name, orginal);
  for (p = name, dot = (char*)0; *p; p ++)
    {
      if (*p == '.')
	dot = p;
      else if (*p == '/')
	dot = (char*)0;
    }

  if (dot)
    p = dot;

#ifdef BACKUPNAME_EXTENTION
  strcpy (p, BACKUPNAME_EXTENTION) 
#else
  strcpy (p, ".bak");
#endif
}

static make_standard_archive_name (name, orginal)
     char *name;
     char *orginal;
{
  register char *p, *dot;

  strcpy (name, orginal);
  for (p = name, dot = (char*)0; *p; p ++)
    {
      if (*p == '.')
	dot = p;
      else if (*p == '/')
	dot = (char*)0;
    }

  if (dot)
    p = dot;

#ifdef ARCHIVENAME_EXTENTION
  strcpy (p, ARCHIVENAME_EXTENTION);
#else
  strcpy (p, ".lzh");
#endif
}

/*----------------------------------------------------------------------*/
/*									*/
/*----------------------------------------------------------------------*/


boolean need_file (name)
     char *name;
{
  int	i;

  if (cmd_filec == 0)
    return TRUE;

  for (i = 0; i < cmd_filec; i ++)
    {
      if (strcmp (cmd_filev[i], name) == 0)
	return TRUE;
    }

  return FALSE;
}

FILE *xfopen (name, mode)
     char *name, *mode;
{
  FILE *fp;

  if ((fp = fopen (name, mode)) == NULL)
    error (name);

  return fp;
}


/*----------------------------------------------------------------------*/
/*		Listing Stuff						*/
/*----------------------------------------------------------------------*/

/* need 14 or 22 (when long_format_listing is TRUE) column spaces */
print_size (packed_size, original_size)
     long packed_size, original_size;
{
  if (long_format_listing)
    printf ("%7d ", packed_size);

  printf ("%7d ", original_size);

  if (original_size == 0L)
    printf ("******");
  else
    printf ("%3d.%1d%%",
	    (int)((packed_size * 100L) / original_size),
	    (int)((packed_size * 1000L) / original_size) % 10);
}

/* need 12 or 17 (when long_format_listing is TRUE) column spaces */
print_stamp (t)
     time_t t;
{
  static boolean	got_now = FALSE;
  static time_t		now;
  static unsigned int	threshold;
  static char	t_month[12*3+1] = "JanFebMarAprMayJunJulAugSepOctDecNov";
  struct tm		*p;

  if (t == 0)
    {
      if (long_format_listing)
	printf ("                 "); /* 17 spaces */
      else
	printf ("            ");	/* 12 spaces */

      return;
    }

  if (!got_now)
    {
      now = time ((time_t*)0);
      p = localtime (&now);
      threshold = p->tm_year * 12 + p->tm_mon - 6;
      got_now = TRUE;
    }

  p = localtime (&t);

  if (long_format_listing)
    printf ("%.3s %2d %02d:%02d %04d",
	    &t_month[p->tm_mon * 3], p->tm_mday,
	    p->tm_hour, p->tm_min, p->tm_year + 1900);
  else
    if (p->tm_year * 12 + p->tm_mon > threshold)
      printf ("%.3s %2d %02d:%02d",
	      &t_month[p->tm_mon * 3], p->tm_mday, p->tm_hour, p->tm_min);
    else
      printf ("%.3s %2d  %04d",
	      &t_month[p->tm_mon * 3], p->tm_mday, p->tm_year + 1900);
}

print_bar ()
{
  /* 17+1+(0 or 7+1)+7+1+6+1+(0 or 1+4)+(12 or 17)+1+20 */
  /*       12345678901234567_  1234567_123456  _123456789012   1234      */
  if (long_format_listing)
    printf ("----------------- ------- ------- ------ ---- ----------------- -------------\n");
  else
    printf ("----------------- ------- ------ ------------ --------------------\n");
}


/*
  view
 */
cmd_view ()
{
  FILE		*fp;
  LzHeader	hdr;
  register char	*p;
  long		a_packed_size = 0L;
  long		a_original_size = 0L;
  int		n_files = 0;
  struct stat	v_stat;

  if ((fp = fopen (archive_name, "rb")) == NULL)
    if (!expand_archive_name (expanded_archive_name, archive_name))
      error (archive_name);
    else
      {
	errno = 0;
	fp = xfopen (expanded_archive_name, "rb");
	archive_name = expanded_archive_name;
      }

  if (archive_is_msdos_sfx1 (archive_name))
    {
      skip_msdos_sfx1_code (fp);
    }

  if (!quiet)
    {
      /*       12345678901234567_  1234567_123456  _  123456789012  1234 */
      printf (" PERMSSN  UID GID %s   SIZE  RATIO%s %s    STAMP   %s NAME\n",
	      long_format_listing ? " PACKED " : "", /* 8,0 */
	      long_format_listing ? "  CRC" : "", /* 5,0 */
	      long_format_listing ? "  " : "", /* 2,0 */
	      long_format_listing ? "   " : ""); /* 3,0 */
      print_bar ();
    }

  while (get_header (fp, &hdr))
    {
      if (need_file (hdr.name))
	{
	  if (hdr.extend_type == EXTEND_UNIX)
	    {
	      printf ("%c%c%c%c%c%c%c%c%c%4d/%-4d",
		  ((hdr.unix_mode & UNIX_OWNER_READ_PERM)  ? 'r' : '-'),
		  ((hdr.unix_mode & UNIX_OWNER_WRITE_PERM) ? 'w' : '-'),
		  ((hdr.unix_mode & UNIX_OWNER_EXEC_PERM)  ? 'x' : '-'),
		  ((hdr.unix_mode & UNIX_GROUP_READ_PERM)  ? 'r' : '-'),
		  ((hdr.unix_mode & UNIX_GROUP_WRITE_PERM) ? 'w' : '-'),
		  ((hdr.unix_mode & UNIX_GROUP_EXEC_PERM)  ? 'x' : '-'),
		  ((hdr.unix_mode & UNIX_OTHER_READ_PERM)  ? 'r' : '-'),
		  ((hdr.unix_mode & UNIX_OTHER_WRITE_PERM) ? 'w' : '-'),
		  ((hdr.unix_mode & UNIX_OTHER_EXEC_PERM)  ? 'x' : '-'),
		  hdr.unix_uid, hdr.unix_gid);
	    }
	  else
	    {
	      switch (hdr.extend_type)
		{			/* max 18 characters */
		case EXTEND_GENERIC:	p = "[generic]"; break;

		case EXTEND_CPM:	p = "[CP/M]"; break;

		  /* OS-9 and FLEX's CPU is MC-6809. I like it. :-)  */
		case EXTEND_FLEX:	p = "[FLEX]"; break;

		case EXTEND_OS9:	p = "[OS-9]"; break;

		  /* I guessed from this ID.  Is this right? */
		case EXTEND_OS68K:	p = "[OS-9/68K]"; break;

		case EXTEND_MSDOS:	p = "[MS-DOS]"; break;

		  /* I have Macintosh. :-)  */
		case EXTEND_MACOS:	p = "[Mac OS]"; break;

		case EXTEND_OS2:	p = "[OS/2]"; break;

		case EXTEND_HUMAN:	p = "[Human68K]"; break;

		case EXTEND_OS386:	p = "[OS-386]"; break;

#ifdef EXTEND_TOWNSOS
		  /* This ID isn't fixed */
		case EXTEND_TOWNSOS:	p = "[TownsOS]"; break;
#endif

		  /* Ouch!  Please customize it's ID.  */
		default: 		p = "[unknown]"; break;
		}
	      printf ("%-18.18s", p);
	    }

	  print_size (hdr.packed_size, hdr.original_size);

	  if (long_format_listing)
	    if (hdr.has_crc)
	      printf (" %04x", hdr.crc);
	    else
	      printf (" ****");

	  printf (" ");
	  print_stamp (hdr.unix_last_modified_stamp);
	  printf (" %s\n", hdr.name);
	  n_files ++;
	  a_packed_size += hdr.packed_size;
	  a_original_size += hdr.original_size;
	}
      fseek (fp, hdr.packed_size, SEEK_CUR);
    }

  fclose (fp);
  if (!quiet)
    {
      print_bar ();

      printf (" Total %4d file%c ",
	      n_files, (n_files == 1) ? ' ' : 's');
      print_size (a_packed_size, a_original_size);
      printf (" ");

      if (long_format_listing)
	printf ("     ");

      if (stat (archive_name, &v_stat) < 0)
	print_stamp ((time_t)0);
      else
	print_stamp (v_stat.st_mtime);

      printf ("\n");
    }

  return;
}


static boolean make_parent_path (name)
     char *name;
{
  char		path[FILENAME_LENGTH];
  struct stat	v_stat;
  register char	*p;

 /* make parent directory name into PATH for recursive call */
  strcpy (path, name);
  for (p = path + strlen (path); p > path; p --)
    if (p[-1] == '/')
      {
	p[-1] = '\0';
	break;
      }

  if (p == path)
    return FALSE;		/* no more parent. */

  if (stat (path, &v_stat) >= 0)
    {
      if ((v_stat.st_mode & S_IFMT) != S_IFDIR)
	return FALSE;		/* already exist. but it isn't directory. */
      return TRUE;		/* already exist its directory. */
    }

  errno = 0;

  if (!quiet)
    message ("Making Directory", path);

  if (mkdir (path, 0777) >= 0)	/* try */
    return TRUE;		/* successful done. */

  errno = 0;

  if (!make_parent_path (path))
    return FALSE;

  if (mkdir (path, 0777) < 0)		/* try again */
    return FALSE;

  return TRUE;
}

static FILE *open_with_make_path (name)
     char *name;
{
  FILE		*fp;
  struct stat	v_stat;
  char		buffer[1024];

  if (stat (name, &v_stat) >= 0)
    {
      if ((v_stat.st_mode & S_IFMT) != S_IFREG)
	return NULL;

      if (!force)
	{
	  for (;;)
	    {
	      fprintf (stderr, "%s OverWrite ?(Yes/No/All) ", name);
	      fflush (stderr);
	      gets (buffer);
	      if (buffer[0] == 'N' || buffer[0] == 'n')
		return NULL;
	      if (buffer[0] == 'Y' || buffer[0] == 'y')
		break;
	      if (buffer[0] == 'A' || buffer[0] == 'a')
		{
		  force = TRUE;
		  break;
		}
	    }
	}
    }

  fp = fopen (name, "wb");
  if (!fp)
    {
      errno = 0;
      if (!make_parent_path (name))
	return NULL;

      fp = fopen (name, "wb");
      if (!fp)
	message ("Error :", name);
    }
  return fp;
}

extern int decode_lzhuf (), decode_larc ();
extern int decode_stored_crc (), decode_stored_nocrc ();

extract_one (fp, hdr)
     FILE *fp;
     LzHeader *hdr;
{
  FILE		*ofp;		/* output file */
  char		name[1024];
  time_t	utimebuf[2];
  int		crc;
  int		(*decode_proc)(); /* (ifp,ofp,original_size,name) */
  int		save_quiet;

  strcpy (name, hdr->name);
  if ((hdr->unix_mode & UNIX_FILE_TYPEMASK) == UNIX_FILE_REGULAR)
    {
      if (bcmp (hdr->method, LZHUFF1_METHOD, METHOD_TYPE_STRAGE) == 0)
	decode_proc = decode_lzhuf;
      else if ((bcmp (hdr->method, LZHUFF0_METHOD, METHOD_TYPE_STRAGE) == 0) ||
	       (bcmp (hdr->method, LARC4_METHOD, METHOD_TYPE_STRAGE) == 0))
	decode_proc = (hdr->has_crc) ? decode_stored_crc : decode_stored_nocrc;
      else if (bcmp (hdr->method, LARC5_METHOD, METHOD_TYPE_STRAGE) == 0)
	decode_proc = decode_larc;
      else
	message ("Error :", "Sorry, Cannot Extract this method.");

      reading_filename = archive_name;
      writting_filename = name;
      if (output_to_stdout)
	{
	  if (!quiet)
	    printf ("::::::::\n%s\n::::::::\n", name);

	  save_quiet = quiet;
	  quiet = TRUE;
	  crc = (*decode_proc) (fp, stdout, hdr->original_size, name);
	  quiet = save_quiet;
	}
      else
	{
	  if ((ofp = open_with_make_path (name)) == NULL)
	    return;
	  else
	    {
	      crc = (*decode_proc) (fp, ofp, hdr->original_size, name);
	      fclose (ofp);
	    }
	}

      if (hdr->has_crc && (crc != hdr->crc))
	error ("CRC Error");

    }
  else
    {
      /* NAME has trailing SLASH '/', (^_^) */
      if (!output_to_stdout &&
	  !make_parent_path (name))
	error (name);
    }

  if (!output_to_stdout)
    {
      utimebuf[0] = utimebuf[1] = hdr->unix_last_modified_stamp;
      utime (name, utimebuf);

#ifdef NOT_COMPATIBLE_MODE
      Please need your modification in this space.
#else
      chmod (name, hdr->unix_mode);
#endif

      chown (name, hdr->unix_uid, hdr->unix_gid);
      errno = 0;
    }
}


/*
  extract
 */
cmd_extract ()
{
  LzHeader	hdr;
  long		pos;
  FILE		*fp;

  if ((fp = fopen (archive_name, "rb")) == NULL)
    if (!expand_archive_name (expanded_archive_name, archive_name))
      error (archive_name);
    else
      {
	errno = 0;
	fp = xfopen (expanded_archive_name, "rb");
	archive_name = expanded_archive_name;
      }

  if (archive_is_msdos_sfx1 (archive_name))
    {
      skip_msdos_sfx1_code (fp);
    }

  while (get_header (fp, &hdr))
    {
      if (need_file (hdr.name))
	{
	  pos = ftell (fp);
	  extract_one (fp, &hdr);
	  fseek (fp, pos + hdr.packed_size, SEEK_SET);
	} else {
	  fseek (fp, hdr.packed_size, SEEK_CUR);
	}
    }

  fclose (fp);

  return;
}

/*----------------------------------------------------------------------*/
/*									*/
/*----------------------------------------------------------------------*/

extern int encode_lzhuf ();
extern int encode_storerd_crc ();

append_one (fp, nafp, hdr)
     FILE *fp, *nafp;
     LzHeader *hdr;
{
  long	header_pos, next_pos, org_pos, data_pos;
  long	v_original_size, v_packed_size;

  reading_filename = hdr->name;
  writting_filename = temporary_name;

  org_pos = ftell (fp);
  header_pos = ftell (nafp);
  write_header (nafp, hdr);	/* DUMMY */

  if (hdr->original_size == 0)
    return;			/* previous write_header is not DUMMY. (^_^) */

  data_pos = ftell (nafp);
  hdr->crc = encode_lzhuf (fp, nafp, hdr->original_size,
			   &v_original_size, &v_packed_size, hdr->name);
  if (v_packed_size < v_original_size)
    {
      next_pos = ftell (nafp);
    }
  else
    {				/* retry by stored method */
      fseek (fp, org_pos, SEEK_SET);
      fseek (nafp, data_pos, SEEK_SET);
      hdr->crc = encode_stored_crc (fp, nafp, hdr->original_size,
				    &v_original_size, &v_packed_size);
      fflush (nafp);
      next_pos = ftell (nafp);
      ftruncate (fileno (nafp), next_pos);
      bcopy (LZHUFF0_METHOD, hdr->method, METHOD_TYPE_STRAGE);
    }
  hdr->original_size = v_original_size;
  hdr->packed_size = v_packed_size;
  fseek (nafp, header_pos, SEEK_SET);
  write_header (nafp, hdr);
  fseek (nafp, next_pos, SEEK_SET);
}

write_tail (nafp)
     FILE *nafp;
{
  putc (0x00, nafp);
}

static copy_old_one (oafp, nafp, hdr)
     FILE *oafp, *nafp;
     LzHeader *hdr;
{
  if (noexec)
    {
      fseek (oafp, (long)(hdr->header_size + 2) + hdr->packed_size, SEEK_CUR);
    }
  else
    {
      reading_filename = archive_name;
      writting_filename = temporary_name;
      copy_file (oafp, nafp, (long)(hdr->header_size + 2) + hdr->packed_size);
    }
}


FILE *append_it (name, oafp, nafp)
     char *name;
     FILE *oafp, *nafp;
{
  LzHeader	ahdr, hdr;
  FILE		*fp;
  long		old_header;
  int		cmp;
  int		filec;
  char		**filev;
  int		i;

  struct stat	v_stat;
  boolean	directory;

  if (stat (name, &v_stat) < 0)
    {
      message ("Error : ", name);
      return oafp;
    }

  directory = ((v_stat.st_mode & S_IFMT) == S_IFDIR);

  init_header (name, &v_stat, &hdr);

  if (!delete_from_archive && !directory && !noexec)
    fp = xfopen (name, "rb");

  while (oafp)
    {
      old_header = ftell (oafp);
      if (!get_header (oafp, &ahdr))
	{
	  fclose (oafp);
	  oafp = NULL;
	  break;
	}
      else
	{
	  cmp = STRING_COMPARE (ahdr.name, hdr.name);
	  if (cmp < 0)
	    {		/* SKIP */
	      fseek (oafp, old_header, SEEK_SET);
	      copy_old_one (oafp, nafp, &ahdr);
	    }
	  else if (cmp == 0)
	    {		/* REPLACE */
	      fseek (oafp, ahdr.packed_size, SEEK_CUR);
	      break;
	    }
	  else		/* cmp > 0, INSERT */
	    {
	      fseek (oafp, old_header, SEEK_SET);
	      break;
	    }
	}
    }

  if (!delete_from_archive)
    {
      if (!oafp ||				/* not in archive */
	  cmp > 0 ||				/* // */
	  !update_if_newer ||			/* always update */
	  (ahdr.unix_last_modified_stamp <	/* newer than archive's */
	   hdr.unix_last_modified_stamp))
	{
	  if (noexec)
	    fprintf (stderr, "APPEND %s\n", name);
	  else
	    append_one (fp, nafp, &hdr);
	}
      else
	{					/* archive has old one */
	  fseek (oafp, old_header, SEEK_SET);
	  copy_old_one (oafp, nafp, &ahdr);
	}

      if (!directory)
	{
	  if (!noexec)
	    fclose (fp);
	}
      else
	{			/* recurcive call */
	  if (find_files (name, &filec, &filev))
	    {
	      for (i = 0; i < filec; i ++)
		oafp = append_it (filev[i], oafp, nafp);
	      free_files (filec, filev);
	    }
	  return oafp;
	}
    }

  return oafp;
}


remove_it (name)
     char *name;
{
  struct stat	v_stat;
  int		i;
  char		**filev;
  int		filec;

  if (stat (name, &v_stat) < 0)
    {
      fprintf (stderr, "cannot access \"%s\".\n", name);
      return;
    }

  if ((v_stat.st_mode & S_IFMT) == S_IFDIR)
    {
      if (!find_files (name, &filec, &filev))
	{
	  fprintf (stderr, "cannot open directory \"%s\".\n", name);
	  return;
	}

      for (i = 0; i < filec; i ++)
	remove_it (filev[i]);

      free_files (filec, filev);

      if (noexec)
	printf ("REMOVE DIRECTORY \"%s\"\n", name);
      else if (rmdir (name) < 0)
	fprintf (stderr, "cannot remove directory \"%s\".\n", name);
      else if (!quiet)
	printf ("Erased \"%s\".\n", name);
    }
  else
    {
      if (noexec)
	printf ("ERASE \"%s\".\n", name);
      else if (unlink (name) < 0)
	fprintf (stderr, "cannot remove \"%s\".\n", name);
      else if (!quiet)
	printf ("Erased \"%s\".\n", name);
    }
}

cmd_append ()
{
  LzHeader	ahdr;
  FILE		*oafp, *nafp;
  char		backup_archive_name [ FILENAME_LENGTH ];
  char		new_archive_name_buffer [ FILENAME_LENGTH ];
  char		*new_archive_name;
  int		i;
  long		old_header;
  struct stat	v_stat;
  boolean	old_archive_exist;

  if (cmd_filec == 0)
    return;

  make_tmp_name (archive_name, temporary_name);

  if ((oafp = fopen (archive_name, "rb")) == NULL)
    if (expand_archive_name (expanded_archive_name, archive_name))
      {
	errno = 0;
	oafp = fopen (expanded_archive_name, "rb");
	archive_name = expanded_archive_name;
      }

  old_archive_exist = (oafp) ? TRUE : FALSE;
  if (new_archive && oafp)
    {
      fclose (oafp);
      oafp = NULL;
    }

  if (oafp && archive_is_msdos_sfx1 (archive_name))
    {
      skip_msdos_sfx1_code (oafp);
      make_standard_archive_name (new_archive_name_buffer, archive_name);
      new_archive_name = new_archive_name_buffer;
    }
  else
    {
      new_archive_name = archive_name;
    }

  errno = 0;
  if (!noexec)
    {
      nafp = xfopen (temporary_name, "wb");
      remove_temporary_at_error = TRUE;
    }

  for (i = 0; i < cmd_filec; i ++)
    oafp = append_it (cmd_filev[i], oafp, nafp);

  if (oafp)
    {
      old_header = ftell (oafp);
      while (get_header (oafp, &ahdr))
	{
	  fseek (oafp, old_header, SEEK_SET);
	  copy_old_one (oafp, nafp, &ahdr);
	  old_header = ftell (oafp);
	}
      fclose (oafp);
    }

  if (!noexec)
    {
      write_tail (nafp);
      fclose (nafp);
    }

  make_backup_name (backup_archive_name, archive_name);

  if (!noexec && old_archive_exist)
    if (rename (archive_name, backup_archive_name) < 0)
      error (archive_name);

  if (!quiet && new_archive_name == new_archive_name_buffer)
    {				/* warning at old archive is SFX */
      printf ("New Archive File is \"%s\"\n", new_archive_name);
    }

  if (!noexec && rename (temporary_name, new_archive_name) < 0)
    {
      if (stat (temporary_name, &v_stat) < 0)
	error (temporary_name);

      oafp = xfopen (temporary_name, "rb");
      nafp = xfopen (archive_name, "wb");
      reading_filename = temporary_name;
      writting_filename = archive_name;
      copy_file (oafp, nafp, (long)v_stat.st_size);
      fclose (nafp);
      fclose (oafp);

      unlink (temporary_name);
    }
  remove_temporary_at_error = FALSE;

  if (delete_after_append)
    {
      if (!quiet && !noexec)
	printf ("Erasing...\n");
      for (i = 0; i < cmd_filec; i ++)
	remove_it (cmd_filev[i]);
    }

  return;
}
