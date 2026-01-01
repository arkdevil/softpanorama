/* touch -- change modification and access times of files
   Copyright (C) 1987, 1989, 1990, Free Software Foundation Inc.

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
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  */

/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
   This port is also distributed under the terms of the
   GNU General Public License as published by the
   Free Software Foundation.

   Please note that this file is not identical to the
   original GNU release, you should have received this
   code as patch to the official release.  */

#ifdef MSDOS
static char RCS_Id[] =
  "$Header: e:/gnu/fileutil/RCS/touch.c 1.4.0.2 90/09/19 12:09:27 tho Exp $";

static char Program_Id[] = "touch";
static char RCS_Revision[] = "$Revision: 1.4.0.2 $";

#define VERSION \
  "GNU %s, Version %.*s (compiled %s %s for MS-DOS)\n", Program_Id, \
  (sizeof RCS_Revision - 14), (RCS_Revision + 11), __DATE__, __TIME__

#define COPYING \
  "This is free software, distributed under the terms of the\n" \
  "GNU General Public License.  For details, see the file COPYING.\n"
#endif /* MSDOS */

/* Usage: touch [-acm] [-r reference-file] [-t MMDDhhmm[[CC]YY][.ss]]
          [-d time] [+time {atime,access,use,mtime,modify}] [+date time]
          [+file reference-file] [+no-create] file...

   Options:
   -a, +time={atime,access,use}	Change access time only.
   -c, +no-create		Do not create files that do not exist.
   -d, +date TIME		Specify time and date in various formats.
   -m, +time={mtime,modify}	Change modification time only.
   -r, +file FILE		Use the time and date of reference file FILE.
   -t TIME			Specify time and date in the form
				`MMDDhhmm[[CC]YY][.ss]'.
   
   If no options are given, -am is the default, using the current time.
   The -r, -t, and -d options are mutually exclusive.  If a file does not
   exist, create it unless -c is given.

   Written by Paul Rubin, Arnold Robbins, Jim Kingdon, David MacKenzie,
   and Randy Smith. */

#include <stdio.h>
#include <ctype.h>
#include <getopt.h>
#include <errno.h>
#include <sys/types.h>
#include "system.h"

#ifdef STDC_HEADERS
#include <stdlib.h>
#include <time.h>
#else
char *malloc ();
char *realloc ();
time_t mktime ();
time_t time ();

extern int errno;
#endif

#ifndef _POSIX_SOURCE
long lseek ();
#endif


#ifdef MSDOS

#include <io.h>
#include <gnulib.h>

extern int argmatch (char *arg, char **optlist);
extern void invalid_arg (char *kind, char *value, int problem);
extern time_t posixtime (char *s);
extern time_t getdate (char *p, struct timeb *now);
void main (int argc, char **argv);
int touch (char *file);
void usage (void);

#else /* not MSDOS */

int argmatch ();
int touch ();
time_t getdate ();
time_t posixtime ();
void error ();
void invalid_arg ();
void usage ();

#endif /* not MSDOS */

/* Bitmasks for `change_times'. */
#define CH_ATIME 1
#define CH_MTIME 2

/* Which timestamps to change. */
int change_times;

/* (-c) If nonzero, don't create if not already there. */
int no_create;

/* (-d) If nonzero, date supplied on command line in getdate formats. */
int flexible_date;

/* (-r) If nonzero, use times from a reference file. */
int use_ref;

/* (-t) If nonzero, date supplied on command line in POSIX format. */
int posix_date;

/* If nonzero, the only thing we have to do is change both the
   modification and access time to the current time, so we don't
   have to own the file, just be able to read and write it.  */
int amtime_now;

/* New time to use when setting time. */
time_t newtime;

/* File to use for -r. */
char *ref_file;

/* Info about the reference file. */
struct stat ref_stats;

/* The name by which this program was run. */
char *program_name;

struct option longopts[] =
{
#ifdef MSDOS
  {"copying", 0, NULL, 30},
  {"version", 0, NULL, 31},
#endif
  {"time", 1, 0, 130},
  {"no-create", 0, 0, 'c'},
  {"date", 1, 0, 'd'},
  {"file", 1, 0, 'r'},
  {0, 0, 0, 0}
};

/* Valid arguments to the `+time' option. */
char *time_args[] =
{
  "atime", "access", "use", "mtime", "modify", 0
};

/* The bits in `change_times' that those arguments set. */
int time_masks[] =
{
  CH_ATIME, CH_ATIME, CH_ATIME, CH_MTIME, CH_MTIME
};

void
main (argc, argv)
     int argc;
     char **argv;
{
  int c;
  int longind;
  int date_set = 0;
  int err = 0;

  program_name = argv[0];
  change_times = no_create = use_ref = posix_date = flexible_date = 0;
  newtime = (time_t) -1;

  while ((c = getopt_long (argc, argv, "acd:mr:t:", longopts, &longind))
	 != EOF)
    {
      switch (c)
	{
	case 'a':
	  change_times |= CH_ATIME;
	  break;

	case 'c':
	  no_create++;
	  break;

	case 'd':
	  flexible_date++;
	  newtime = getdate (optarg, NULL);
	  if (newtime == (time_t) -1)
	    error (1, 0, "invalid date format `%s'", optarg);
	  date_set++;
	  break;

	case 'm':
	  change_times |= CH_MTIME;
	  break;

	case 'r':
	  use_ref++;
	  ref_file = optarg;
	  break;

	case 't':
	  posix_date++;
	  newtime = posixtime (optarg);
	  if (newtime == (time_t) -1)
	    error (1, 0, "invalid date format `%s'", optarg);
	  date_set++;
	  break;

	case 130:
	  longind = argmatch (optarg, time_args);
	  if (longind < 0)
	    {
	      invalid_arg ("time selector", optarg, longind);
	      usage ();
	    }
	  change_times |= time_masks[longind];
	  break;

#ifdef MSDOS
	case 30:
	  fprintf (stderr, COPYING);
	  exit (0);
	  break;

	case 31:
	  fprintf (stderr, VERSION);
	  exit (0);
	  break;
#endif

	default:
	  usage ();
	}
    }

  if (change_times == 0)
    change_times = CH_ATIME | CH_MTIME;

  if ((use_ref && (posix_date || flexible_date))
      || (posix_date && flexible_date))
    {
      error (0, 0, "cannot specify times from more than one source");
      usage ();
    }

  if (use_ref)
    {
      if (stat (ref_file, &ref_stats))
	error (1, errno, "%s", ref_file);
      date_set++;
    }

  if (!date_set && optind < argc && strcmp (argv[optind - 1], "--"))
    {
      newtime = posixtime (argv[optind]);
      if (newtime != (time_t) -1)
	{
	  optind++;
	  date_set++;
	}
    }
  if (!date_set)
    {
      if ((change_times & (CH_ATIME | CH_MTIME)) == (CH_ATIME | CH_MTIME))
	amtime_now = 1;
      else
	time (&newtime);
    }

  if (optind == argc)
    {
      error (0, 0, "file arguments missing");
      usage ();
    }

  for (; optind < argc; ++optind)
    err += touch (argv[optind]);

  exit (err != 0);
}

/* Update the time of file FILE according to the options given.
   Return 0 if successful, 1 if an error occurs. */

int
touch (file)
     char *file;
{
  int status;
  struct stat sbuf;
  int fd;

  if (stat (file, &sbuf))
    {
      if (errno != ENOENT)
	{
	  error (0, errno, "%s", file);
	  return 1;
	}
      if (no_create)
	return 0;
      fd = creat (file, 0666);
      if (fd == -1)
	{
	  error (0, errno, "%s", file);
	  return 1;
	}
      if (amtime_now)
	{
	  close (fd);
	  return 0;		/* We've done all we have to. */
	}
      if (fstat (fd, &sbuf))
	{
	  error (0, errno, "%s", file);
	  close (fd);
	  return 1;
	}
      close (fd);
    }
  else if ((sbuf.st_mode & S_IFMT) != S_IFREG)
    {
      error (0, 0, "`%s' is not a regular file", file);
      return 1;
    }

  if (amtime_now)
    {
      /* Need to pass NULL to utime so it will not fail if we just have
	 write access to the file, but don't own it.  */
#if defined (UTIME_NULL_MISSING)
      /* This system won't take utime (file, NULL) (e.g., BSD4.3).
	 Emulate it.  */
      int fd;
      char c;

      status = 0;
      fd = open (file, O_RDWR, 0666);
      if (fd < 0
	  || read (fd, &c, sizeof (char)) < 0
	  || lseek (fd, 0, L_SET) < 0
	  || write (fd, &c, sizeof (char)) < 0
	  || ftruncate (fd, sbuf.st_size) < 0)
	status = -1;
      if (fd >= 0)
	close (fd);
#else
      status = utime (file, NULL);
#endif
    }
  else
    {
      struct utimbuf utb;

      if (use_ref)
	{
	  utb.actime = ref_stats.st_atime;
	  utb.modtime = ref_stats.st_mtime;
	}
      else
	utb.actime = utb.modtime = newtime;

      if (!(change_times & CH_ATIME))
	utb.actime = sbuf.st_atime;

      if (!(change_times & CH_MTIME))
	utb.modtime = sbuf.st_mtime;

      status = utime (file, &utb);
    }
  
  if (status)
    {
      error (0, errno, "%s", file);
      return 1;
    }

  return 0;
}

/*  Use the one from gnulib */
#ifndef MSDOS

/* Like malloc but get error if no storage available. */

char *
xmalloc (size)
     unsigned size;
{
  register char *val = (char *) malloc (size);

  if (!val)
    error (1, 0, "virtual memory exhausted");
  return val;
}

/* Like realloc but get error if no storage available.  */

char *
xrealloc (ptr, size)
     char *ptr;
     unsigned size;
{
  register char *val = (char *) realloc (ptr, size);

  if (!val)
    error (1, 0, "virtual memory exhausted");
  return val;
}

#endif /* not MSDOS */

void
usage ()
{
#ifdef MSDOS
  fprintf (stderr, "\
Usage: %s [-acm] [-r reference-file] [-t MMDDhhmm[[CC]YY][.ss]]\n\
       [-d time] [+time {atime,access,use,mtime,modify}] [+date time]\n\
       [+file reference-file] [+no-create] [+copying] [+version] file...\n",
#else /* not MSDOS */
  fprintf (stderr, "\
Usage: %s [-acm] [-r reference-file] [-t MMDDhhmm[[CC]YY][.ss]]\n\
       [-d time] [+time {atime,access,use,mtime,modify}] [+date time]\n\
       [+file reference-file] [+no-create] file...\n",
#endif /* not MSDOS */
	   program_name);
  exit (1);
}
