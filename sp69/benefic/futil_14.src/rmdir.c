/* rmdir -- remove directories
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
  "$Header: e:/gnu/fileutil/RCS/rmdir.c 1.4.0.2 90/09/19 12:09:14 tho Exp $";

static char Program_Id[] = "rmdir";
static char RCS_Revision[] = "$Revision: 1.4.0.2 $";

#define VERSION \
  "GNU %s, Version %.*s (compiled %s %s for MS-DOS)\n", Program_Id, \
  (sizeof RCS_Revision - 14), (RCS_Revision + 11), __DATE__, __TIME__

#define COPYING \
  "This is free software, distributed under the terms of the\n" \
  "GNU General Public License.  For details, see the file COPYING.\n"
#endif /* MSDOS */

/* Usage: rmdir [-p] [+path] dir...

   Options:
   -p, +path		Remove any parent dirs that are explicitly mentioned
			in an argument, if they become empty after the
			argument file is removed.

   David MacKenzie <djm@ai.mit.edu>  */

#include <stdio.h>
#include <getopt.h>
#include <sys/types.h>
#include "system.h"

#ifdef STDC_HEADERS
#include <errno.h>
#include <stdlib.h>
#else
extern int errno;
#endif

#ifdef MSDOS

#include <direct.h>
#include <gnulib.h>

extern void main (int argc, char * *argv);
static void remove_parents (char *path);
static void strip_trailing_slashes (char *path);
static void usage (void);

#else /* not MSDOS */

void remove_parents ();
void error ();
void strip_trailing_slashes ();
void usage ();

#endif /* not MSDOS */

/* If nonzero, remove empty parent directories. */
int empty_paths;

/* The name this program was run with. */
char *program_name;

struct option longopts[] =
{
#ifdef MSDOS
  {"copying", 0, NULL, 30},
  {"version", 0, NULL, 31},
#endif
  {"path", 0, &empty_paths, 1},
  {NULL, 0, NULL, 0}
};

void
main (argc, argv)
     int argc;
     char **argv;
{
  int errors = 0;
  int optc;
  int ind;

  program_name = argv[0];
  empty_paths = 0;

  while ((optc = getopt_long (argc, argv, "p", longopts, &ind)) != EOF)
    {
      switch (optc)
	{
	case 0:			/* Long option. */
	  break;
	case 'p':
	  empty_paths = 1;
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
  
  for (; optind < argc; ++optind)
    {
      strip_trailing_slashes (argv[optind]);
      if (rmdir (argv[optind]) != 0)
	{
	  error (0, errno, "%s", argv[optind]);
	  errors = 1;
	}
      else if (empty_paths)
	remove_parents (argv[optind]);
    }

  exit (errors);
}

/* Remove any empty parent directories of `path'.
   Replaces '/' characters in `path' with NULs. */

void
remove_parents (path)
     char *path;
{
  char *slash;

  do
    {
      slash = rindex (path, '/');
      if (slash == NULL)
	break;
      /* Remove any characters after the slash, skipping any extra
	 slashes in a row. */
      while (slash > path && *slash == '/')
	--slash;
      slash[1] = 0;
    }
  while (rmdir (path) == 0);
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
  fprintf (stderr, "Usage: %s [-p] [+path] [+copying] [+version] dir...\n",
#else /* not MSDOS */
  fprintf (stderr, "Usage: %s [-p] [+path] dir...\n",
#endif /* not MSDOS */
	   program_name);
  exit (1);
}
