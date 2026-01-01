/* chmod -- change permission modes of files
   Copyright (C) 1989, 1990 Free Software Foundation, Inc.

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
  "$Header: e:/gnu/fileutil/RCS/chmod.c 1.4.0.2 90/09/19 11:17:44 tho Exp $";

static char Program_Id[] = "chmod";
static char RCS_Revision[] = "$Revision: 1.4.0.2 $";

#define VERSION \
  "GNU %s, Version %.*s (compiled %s %s for MS-DOS)\n", Program_Id, \
  (sizeof RCS_Revision - 14), (RCS_Revision + 11), __DATE__, __TIME__

#define COPYING \
  "This is free software, distributed under the terms of the\n" \
  "GNU General Public License.  For details, see the file COPYING.\n"
#endif /* MSDOS */

/* Usage: chmod [-Rcdfv] mode file...
          mode is [ugoa...][[+-=][rwxXstugo...]...][,...] or octal number.

   Options:
   -R	Recursively change modes of directory contents.
   -c	Verbosely describe only files whose modes actually change.
   -d	Dereference symbolic links (recursively change the modes of
	directories pointed to by symbolic links).
   -f	Do not print error messages about files.
   -v	Verbosely describe changed modes.

   David MacKenzie <djm@ai.mit.edu> */

#include <stdio.h>
#include <getopt.h>
#include <sys/types.h>
#include "modechange.h"
#include "system.h"

#ifdef STDC_HEADERS
#include <errno.h>
#include <stdlib.h>
#else
char *malloc ();
char *realloc ();

extern int errno;
#endif

#ifdef MSDOS

#include <malloc.h>
#include <io.h>

#define lstat stat

extern void main (int argc, char **argv);
extern void filemodestring (struct stat *,char *);
extern void error (int status, int errnum, char *message, ...);
extern void mode_string (unsigned short mode, char *str);

static int change_file_mode (char *file, struct mode_change *changes);
static int change_dir_mode (char *dir, struct mode_change *changes,\
			    struct stat *statp);
extern char *savedir (char *dir, unsigned name_size);
static char *stpcpy (char *dest, char *source);
static void describe_change (char *file, unsigned short mode, int changed);
static char *xmalloc (unsigned int n);
static char *xrealloc (char *p, unsigned n);
static char *stp_cpy (char *dest, char *source);
static void usage (void);

#else /* not MSDOS */

int lstat ();
int stat ();

char *savedir ();
char *xmalloc ();
char *xrealloc ();
int change_file_mode ();
int change_dir_mode ();
void describe_change ();
void error ();
void mode_string ();
void usage ();

#endif /* not MSDOS */

typedef enum
{
  false = 0, true = 1
} boolean;

/* The name the program was run with. */
char *program_name;

/* If true, change the modes of directories recursively. */
boolean recurse;

/* If true, force silence (no error messages). */
boolean force_silent;

/* If true, describe the modes we set. */
boolean verbose;

/* If true, describe only modes that change. */
boolean changes_only;

/* A pointer to either lstat or stat. */
#ifdef MSDOS
int (*xstat) (char *, struct stat *);
#else
int (*xstat) ();
#endif

/* Parse the ASCII mode given on the command line into a linked list
   of `struce mode_change' and apply that to each file argument. */

void
main (argc, argv)
     int argc;
     char **argv;
{
  extern int optind;
  struct mode_change *changes;
  int errors = 0;
  int modeind = 0;		/* Index of the mode argument in `argv'. */
  int thisind;
  int c;

  program_name = argv[0];
  recurse = force_silent = verbose = changes_only = false;
  xstat = lstat;

  while (1)
    {
      thisind = optind ? optind : 1;

#ifdef MSDOS
      c = getopt (argc, argv, "RcdfvrwxXstugoa,+-=CV");
#else
      c = getopt (argc, argv, "RcdfvrwxXstugoa,+-=");
#endif
      if (c == EOF)
	break;

      switch (c)
	{
	case 'r':
	case 'w':
	case 'x':
	case 'X':
	case 's':
	case 't':
	case 'u':
	case 'g':
	case 'o':
	case 'a':
	case ',':
	case '+':
	case '-':
	case '=':
	  if (modeind != 0 && modeind != thisind)
	    error (1, 0, "invalid mode");
	  modeind = thisind;
	  break;
	case 'R':
	  recurse = true;
	  break;
	case 'c':
	  verbose = true;
	  changes_only = true;
	  break;
	case 'd':
	  xstat = stat;
	  break;
	case 'f':
	  force_silent = true;
	  break;
	case 'v':
	  verbose = true;
	  break;
#ifdef MSDOS
	case 'C':
	  fprintf (stderr, COPYING);
	  exit (0);
	  break;
	case 'V':
	  fprintf (stderr, VERSION);
	  exit (0);
	  break;
#endif
	default:
	  usage ();
	}
    }

  if (modeind == 0)
    modeind = optind++;
  if (optind >= argc)
    usage ();

  changes = mode_compile (argv[modeind],
			  MODE_MASK_EQUALS | MODE_MASK_PLUS | MODE_MASK_MINUS);
  if (changes == MODE_INVALID)
    error (1, 0, "invalid mode");
  else if (changes == MODE_MEMORY_EXHAUSTED)
    error (1, 0, "virtual memory exhausted");

  for (; optind < argc; ++optind)
    errors |= change_file_mode (argv[optind], changes);

  exit (errors);
}

/* Change the mode of `file' according to the list of operations `changes'.
   Return 0 if successful, 1 if errors occurred. */

int
change_file_mode (file, changes)
     char *file;
     struct mode_change *changes;
{
  struct stat file_stats;
  unsigned short newmode;
  int errors = 0;

  if ((*xstat) (file, &file_stats))
    {
      if (force_silent == false)
	error (0, errno, "%s", file);
      return 1;
    }
#ifdef S_IFLNK
  if ((file_stats.st_mode & S_IFMT) == S_IFLNK)
    return 0;
#endif

  newmode = mode_adjust (file_stats.st_mode, changes);

  if (newmode != (file_stats.st_mode & 07777))
    {
      if (verbose)
	describe_change (file, newmode, 1);
      if (chmod (file, (int) newmode))
	{
	  if (force_silent == false)
	    error (0, errno, "%s", file);
	  errors = 1;
	}
    }
  else if (verbose && changes_only == false)
    describe_change (file, newmode, 0);

  if (recurse && (file_stats.st_mode & S_IFMT) == S_IFDIR)
    errors |= change_dir_mode (file, changes, &file_stats);
  return errors;
}

/* Recursively change the modes of the files in directory `dir'
   according to the list of operations `changes'.
   `statp' points to the results of lstat or stat on `dir'.
   Return 0 if successful, 1 if errors occurred. */

int
change_dir_mode (dir, changes, statp)
     char *dir;
     struct mode_change *changes;
     struct stat *statp;
{
  char *name_space, *namep;
  char *path;			/* Full path of each entry to process. */
  unsigned dirlength;		/* Length of `dir' and '\0'. */
  unsigned filelength;		/* Length of each pathname to process. */
  unsigned pathlength;		/* Bytes allocated for `path'. */
  int errors = 0;

  errno = 0;
  name_space = savedir (dir, statp->st_size);
  if (name_space == NULL)
    {
      if (errno)
	{
	  if (force_silent == false)
	    error (0, errno, "%s", dir);
	  return 1;
	}
      else
	error (1, 0, "virtual memory exhausted");
    }

  dirlength = strlen (dir) + 1;	/* + 1 is for the trailing '/'. */
  pathlength = dirlength + 1;
  /* Give `path' a dummy value; it will be reallocated before first use. */
  path = xmalloc (pathlength);
  strcpy (path, dir);
  path[dirlength - 1] = '/';

  for (namep = name_space; *namep; namep += filelength - dirlength)
    {
      filelength = dirlength + strlen (namep) + 1;
      if (filelength > pathlength)
	{
	  pathlength = filelength * 2;
	  path = xrealloc (path, pathlength);
	}
      strcpy (path + dirlength, namep);
      errors |= change_file_mode (path, changes);
    }
  free (path);
  free (name_space);
  return errors;
}

/* Tell the user the mode `mode' that file `file' has been set to;
   if `changed' is zero, `file' had that mode already. */

void
describe_change (file, mode, changed)
     char *file;
     unsigned short mode;
     int changed;
{
  char perms[11];		/* "-rwxrwxrwx" ls-style modes. */

  mode_string (mode, perms);
  perms[10] = '\0';		/* `mode_string' does not null terminate. */
  if (changed)
    printf ("mode of %s changed to %04o (%s)\n",
	    file, mode & 07777, &perms[1]);
  else
    printf ("mode of %s retained as %04o (%s)\n",
	    file, mode & 07777, &perms[1]);
}

/* Allocate `n' bytes of memory dynamically, with error checking.  */

char *
xmalloc (n)
     unsigned n;
{
  char *p;

  p = malloc (n);
  if (p == 0)
    error (1, 0, "virtual memory exhausted");
  return p;
}

char *
xrealloc (p, n)
     char *p;
     unsigned n;
{
  p = realloc (p, n);
  if (p == 0)
    error (1, 0, "virtual memory exhausted");
  return p;
}

void
usage ()
{
#ifdef MSDOS
  fprintf (stderr, "\
Usage: %s [-RcdfvCV] mode file...\n\
       mode is [ugoa...][[+-=][rwxXstugo...]...][,...] or octal number\n",
	   program_name);
#else /* not MSDOS */
  fprintf (stderr, "\
Usage: %s [-Rcdfv] mode file...\n\
       mode is [ugoa...][[+-=][rwxXstugo...]...][,...] or octal number\n",
	   program_name);
#endif /* not MSDOS */
  exit (1);
}
