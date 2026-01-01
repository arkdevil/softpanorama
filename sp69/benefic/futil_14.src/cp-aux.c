/*  cp-aux.c  -- file copying (auxiliary routines)
    Copyright (C) 1989, 1990 Free Software Foundation.

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

    Written by Torbjorn Granlund, Sweden (tege@sics.se).
*/

/*  MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
    This port is also distributed under the terms of the
    GNU General Public License as published by the
    Free Software Foundation.

    Please note that this file is not identical to the
    original GNU release, you should have received this
    code as patch to the official release.

    $Header: e:/gnu/fileutil/RCS/cp-aux.c 1.4.0.2 90/09/19 11:18:11 tho Exp $
 */

#include <stdio.h>

#include "cp.h"

extern char *program_name;

void
usage (reason)
     char *reason;
{
  if (reason != NULL)
    fprintf (stderr, "%s: %s\n", program_name, reason);

#ifdef MSDOS
  fprintf (stderr, "\
Usage: %s [-bdfipruvxR] [-S backup-suffix] [-V {numbered,existing,simple}]\n\
       [+backup] [+no-dereference] [+force] [+interactive] [+one-file-system]\n\
       [+preserve] [+recursive] [+update] [+verbose] [+suffix backup-suffix]\n\
       [+version-control {numbered,existing,simple}] [+copying] [+version]\n\
       source dest\n\
\n\
       %s [-bdfipruvxR] [-S backup-suffix] [-V {numbered,existing,simple}]\n\
       [+backup] [+no-dereference] [+force] [+interactive] [+one-file-system]\n\
       [+preserve] [+recursive] [+update] [+verbose] [+suffix backup-suffix]\n\
       [+version-control {numbered,existing,simple}] [+copying] [+version]\n\
       source... directory\n",
	   program_name, program_name);
#else /* not MSDOS */
  fprintf (stderr, "\
Usage: %s [-bdfipruvxR] [-S backup-suffix] [-V {numbered,existing,simple}]\n\
       [+backup] [+no-dereference] [+force] [+interactive] [+one-file-system]\n\
       [+preserve] [+recursive] [+update] [+verbose] [+suffix backup-suffix]\n\
       [+version-control {numbered,existing,simple}] source dest\n\
\n\
       %s [-bdfipruvxR] [-S backup-suffix] [-V {numbered,existing,simple}]\n\
       [+backup] [+no-dereference] [+force] [+interactive] [+one-file-system]\n\
       [+preserve] [+recursive] [+update] [+verbose] [+suffix backup-suffix]\n\
       [+version-control {numbered,existing,simple}] source... directory\n",
	   program_name, program_name);
#endif /* not MSDOS */

  exit (2);
}

/* Use the one from gnulib */
#ifndef MSDOS

char *
xmalloc (size)
     unsigned size;
{
  char *x = malloc (size);
  if (x == 0)
    error (1, 0, "virtual memory exhausted");
  return x;
}

char *
xrealloc (ptr, size)
     char *ptr;
     unsigned size;
{
  char *x = realloc (ptr, size);
  if (x == 0)
    error (1, 0, "virtual memory exhausted");
  return x;
}

#endif /* not MSDOS */

char *
stpcpy (s1, s2)
     char *s1;
     char *s2;
{
  while ((*s1++ = *s2++) != '\0')
    ;
  return s1 - 1;
}

int
yesno ()
{
  int c, t;

  fflush (stderr);
  c = t = getchar ();
  while (t != EOF && t != '\n')
    t = getchar ();
  return c == 'y' || c == 'Y';
}


#ifndef MSDOS			/* no links ... */

int
is_ancestor (sb, ancestors)
     struct stat *sb;
     struct dir_list *ancestors;
{
  while (ancestors != 0)
    {
      if (ancestors->ino == sb->st_ino && ancestors->dev == sb->st_dev)
	return 1;
      ancestors = ancestors->parent;
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

#else /* MSDOS */

void
strip_trailing_slashes (char **path)
{
  char *new_path = _fullpath (NULL, *path, 0);
  free (*path);
  *path = msdos_format_filename (new_path);
}

#endif /* MSDOS */
