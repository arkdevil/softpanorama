/* mkdir -- make directories
   Copyright (C) 1990 Free Software Foundation, Inc.

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
  "$Header: e:/gnu/fileutil/RCS/mkdir.c 1.4.0.2 90/09/19 12:10:16 tho Exp $";

static char Program_Id[] = "mkdir";
static char RCS_Revision[] = "$Revision: 1.4.0.2 $";

#define VERSION \
  "GNU %s, Version %.*s (compiled %s %s for MS-DOS)\n", Program_Id, \
  (sizeof RCS_Revision - 14), (RCS_Revision + 11), __DATE__, __TIME__

#define COPYING \
  "This is free software, distributed under the terms of the\n" \
  "GNU General Public License.  For details, see the file COPYING.\n"
#endif /* MSDOS */

/* Usage: mkdir [-p] [-m mode] [+path] [+mode mode] dir...

   Options:
   -p, +path		Ensure that the given path(s) exist:
			Make any missing parent directories for each argument.
			Parent dirs default to umask modified by `u+wx'.
			Do not consider an argument directory that already
			exists to be an error.
   -m, +mode mode	Set the mode of created directories to `mode', which is
			symbolic as in chmod and uses the umask as a point of
			departure.

   David MacKenzie <djm@ai.mit.edu>  */

#include <stdio.h>
#include <getopt.h>
#include <sys/types.h>
#include "system.h"
#include "modechange.h"

#ifdef STDC_HEADERS
#include <errno.h>
#include <stdlib.h>
#else
extern int errno;
#endif

#ifdef MSDOS

#include <direct.h>
#include <io.h>
#include <gnulib.h>

extern void main (int argc, char **argv);
static int make_path (char *path, unsigned short mode,\
		      unsigned short parent_mode);
static void strip_trailing_slashes (char *path);
static void usage (void);

#define mkdir(path, mode)	mkdir (path)

#else /* not MSDOS */

int make_path ();
void error ();
void strip_trailing_slashes ();
void usage ();

#endif /* not MSDOS */

/* If nonzero, ensure that a path exists.  */
int path_mode;

/* The name this program was run with. */
char *program_name;

struct option longopts[] =
{
#ifdef MSDOS
  {"copying", 0, NULL, 30},
  {"version", 0, NULL, 31},
#endif
  {"mode", 1, NULL, 'm'},
  {"path", 0, &path_mode, 1},
  {NULL, 0, NULL, 0}
};

void
main (argc, argv)
     int argc;
     char **argv;
{
  unsigned short newmode;
  unsigned short parent_mode;
  struct mode_change *change;
  char *symbolic_mode;
  int errors = 0;
  int optc;
  int ind;

  program_name = argv[0];
  path_mode = 0;
  symbolic_mode = NULL;

  while ((optc = getopt_long (argc, argv, "pm:", longopts, &ind)) != EOF)
    {
      switch (optc)
	{
	case 0:			/* Long option. */
	  break;
	case 'p':
	  path_mode = 1;
	  break;
	case 'm':
	  symbolic_mode = optarg;
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

  if (optind == argc)
    usage ();
  
  newmode = 0777 & ~umask (0);
  parent_mode = newmode | 0300;	/* u+wx */
  if (symbolic_mode)
    {
      change = mode_compile (symbolic_mode, 0);
      if (change == MODE_INVALID)
	error (1, 0, "invalid mode");
      else if (change == MODE_MEMORY_EXHAUSTED)
	error (1, 0, "virtual memory exhausted");
      newmode = mode_adjust (newmode, change);
    }

  for (; optind < argc; ++optind)
    {
      strip_trailing_slashes (argv[optind]);
      if (path_mode)
	errors |= make_path (argv[optind], newmode, parent_mode);
      else if (mkdir (argv[optind], newmode))
	{
	  error (0, errno, "cannot make directory `%s'", argv[optind]);
	  errors = 1;
	}
    }

  exit (errors);
}

/* Make sure directory `path' and all leading directories exist,
   and give it permission mode `mode'.
   If any leading directories are created, give them permission
   mode `parent_mode'.
   Return 0 if successful, 1 if errors occur. */

int
make_path (path, mode, parent_mode)
     char *path;
     unsigned short mode;
     unsigned short parent_mode;
{
  char *slash;
  struct stat stats;

  if (stat (path, &stats))
    {
      slash = path;
      while (*slash == '/')
	slash++;
      while (slash = index (slash, '/'))
	{
	  *slash = 0;
	  if (stat (path, &stats))
	    {
	      if (mkdir (path, parent_mode))
		{
		  error (0, errno, "cannot make directory `%s'", path);
		  return 1;
		}
	    }
	  else if ((stats.st_mode & S_IFMT) != S_IFDIR)
	    {
	      error (0, 0, "`%s' is not a directory", path);
	      return 1;
	    }
	  *slash++ = '/';
	}

      if (mkdir (path, mode))
	{
	  error (0, errno, "cannot make directory `%s'", path);
	  return 1;
	}
    }
  else if ((stats.st_mode & S_IFMT) != S_IFDIR)
    {
      error (0, 0, "`%s' is not a directory", path);
      return 1;
    }
  else if (chmod (path, mode))
    {
      error (0, errno, "cannot change mode of `%s'", path);
      return 1;
    }
  return 0;
}

/* Remove trailing slashes from PATH; they cause some system calls to fail. */

void
strip_trailing_slashes (path)
     char *path;
{
  int last;

  last = strlen (path) - 1;
  while (last > 0 && path[last] == '/')
    path[last--] = '\0';
}

void
usage ()
{
#ifdef MSDOS
  fprintf (stderr, "\
Usage: %s [-p] [-m mode] [+path] [+mode mode] [+copying] \n\
       [+version] dir...\n", program_name);
#else
  fprintf (stderr, "\
Usage: %s [-p] [-m mode] [+path] [+mode mode] dir...\n",
	   program_name);
#endif
  exit (1);
}
