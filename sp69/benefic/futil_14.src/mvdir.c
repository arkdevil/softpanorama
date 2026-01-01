/* mvdir -- rename directory
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

/* Helper program for GNU mv on machines that lack the rename system call.

   Usage: mvdir from to

   FROM must be an existing directory.
   TO must not exist, but its parent must exist.

   Must be setuid root.

   Ian Dall (ian@sibyl.eleceng.ua.oz.au)
   and David MacKenzie (djm@ai.mit.edu) */

#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <signal.h>
#include "system.h"

#ifdef STDC_HEADERS
#include <stdlib.h>
#include <errno.h>
#else
char *malloc ();

extern int errno;
#endif

#ifndef HIPRI
#define HIPRI -10
#endif

#ifdef DEBUG
#define link(FROM, TO) (printf("Linking %s to %s\n", FROM, TO), 0)
#define unlink(FILE) (printf("Unlinking %s\n", FILE), 0)
#endif

/* The name this program was run with. */
char *program_name;

char *basename ();
char *fullpath ();
char *parent_dir ();
char *xmalloc ();
void error ();
void strip_trailing_slashes ();

void
main (argc, argv)
     int argc;
     char **argv;
{
  char *from, *from_parent, *from_base;
  char *to, *to_parent, *to_parent_path;
  struct stat from_stats, to_stats;
  char *slash, temp;
  int i;

  program_name = argv[0];
  if (argc != 3)
    {
      fprintf (stderr, "Usage: %s existing-dir new-dir\n", program_name);
      exit (2);
    }
  from = argv[1];
  to = argv[2];
  strip_trailing_slashes (from);
  strip_trailing_slashes (to);
  from_parent = parent_dir (from);
  to_parent = parent_dir (to);

  /* Make sure `from' is not "." or "..". */
  from_base = basename (from);
  if (!strcmp (from_base, ".") || !strcmp (from_base, ".."))
    error (1, 0, "cannot rename `.' or `..'");
  
  /* Even with an effective uid of root, link fails if the target exists.
     That is what we want, so don't unlink `to' first.
     However, we do need to check that the directories that link and unlink
     will modify exist and are writable by the user. */

  if (stat (from, &from_stats))
    error (1, errno, "%s", from);
  if ((from_stats.st_mode & S_IFMT) != S_IFDIR)
    error (1, 0, "`%s' is not a directory", from);
  if (access (from_parent, W_OK))
    error (1, errno, "cannot write to `%s'", from_parent);
  if (access (to_parent, W_OK))
    error (1, errno, "cannot write to `%s'", to_parent);

  /* To prevent disconnecting the tree rooted at `from' from its parent,
     quit if any of the directories in `to' are the same (dev and ino)
     as the directory `from'. */
  
  slash = to_parent_path = fullpath (to_parent);
  while (*slash)
    {
      slash = index (slash, '/');
      if (slash)
	{
	  ++slash;
	  temp = *slash;
	  *slash = '\0';
	  if (stat (to_parent_path, &to_stats))
	    error (1, errno, "%s", to_parent_path);
	  *slash = temp;
	}
      else
	{
	  /* Last element of path. */
	  slash = "";
	  if (stat (to_parent_path, &to_stats))
	    error (1, errno, "%s", to_parent_path);
	}
      
      if (to_stats.st_dev == from_stats.st_dev
	  && to_stats.st_ino == from_stats.st_ino)
	error (1, 0, "`%s' is an ancestor of `%s'", from, to);
    }

  /* We can't make the renaming atomic, but we do our best. */
  for (i = NSIG; i > 0; i--)
    if (i != SIGKILL)
      signal (i, SIG_IGN);
  setuid (0);			/* Make real uid 0 so it is harder to kill. */
  nice (HIPRI - nice (0));	/* Raise priority. */

  if (link (from, to))
    error (1, errno, "cannot link `%s' to `%s'", from, to);
  if (unlink (from))
    error (1, errno, "cannot unlink `%s'", from);

  /* Replace the directory's `..' entry.  It used to be a link to
     the parent of `from'; make it a link to the parent of `to' instead. */
  i = strlen (to);
  slash = xmalloc (i + 4);
  strcpy (slash, to);
  strcpy (slash + i, "/..");
  if (unlink (slash) && errno != ENOENT)
    error (1, errno, "cannot unlink `%s'", slash);
  if (link (to_parent, slash))
    error (1, errno, "cannot link `%s' to `%s'", to_parent, slash);

  exit (0);
}

/* Return the name of the directory containing PATH. */

char *
parent_dir (path)
     char *path;
{
  char *dir;
  char *base;
  int length;

  base = rindex (path, '/');
  if (base == NULL)
    return ".";

  if (base > path)
    base--;
  length = base - path + 1;
  dir = xmalloc (length + 1);
  strncpy (dir, path, length);
  dir[length] = '\0';
  return dir;
}

/* Return NAME with any leading path stripped off.  */

char *
basename (name)
     char *name;
{
  char *base;

  base = rindex (name, '/');
  return base ? base + 1 : name;
}

/* Return the full pathname (from /) of the directory DIR,
   as static data. */

char *
fullpath (dir)
     char *dir;
{
  char wd[PATH_MAX + 2];
  static char path[PATH_MAX + 2];

  if (getwd (wd) == NULL)
    error (1, errno, "cannot get current directory");
  if (chdir (dir))
    error (1, errno, "%s", dir);
  if (getwd (path) == NULL)
    error (1, errno, "cannot get current directory");
  if (chdir (wd))
    error (1, errno, "%s", wd);

  return path;
}

/* Allocate N bytes of memory dynamically, with error checking.  */

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

/* Remove any trailing slashes from STR. */

void
strip_trailing_slashes (str)
     char *str;
{
  int last = strlen (str) - 1;

  while (last > 0 && str[last] == '/')
    str[last--] = '\0';
}
