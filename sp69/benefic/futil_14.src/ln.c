/* `ln' program to create links between files.
   Copyright (C) 1986, 1989, 1990 Free Software Foundation, Inc.

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

/* Written by Mike Parker and David MacKenzie. */

#include <stdio.h>
#include <sys/types.h>
#include <errno.h>
#include <getopt.h>
#include "system.h"
#include "backupfile.h"

#ifdef STDC_HEADERS
#include <stdlib.h>
#else
char *getenv ();

extern int errno;
#endif

#ifndef _POSIX_SOURCE
int link ();
#endif

#ifdef S_IFLNK
int symlink ();
#endif

char *basename ();
enum backup_type get_version ();
int do_link ();
int isdir ();
int yesno ();
void error ();
void strip_trailing_slashes ();
void usage ();

/* A pointer to the function used to make links.  This will point to either
   `link' or `symlink'. */
int (*linkfunc) ();

/* If nonzero, make symbolic links; otherwise, make hard links.  */
int symbolic_link;

/* If nonzero, ask the user before removing existing files.  */
int interactive;

/* If nonzero, remove existing files unconditionally.  */
int remove_existing_files;

/* If nonzero, list each file as it is moved. */
int verbose;

/* If nonzero, allow the superuser to make hard links to directories. */
int hard_dir_link;

/* The name by which the program was run, for error messages.  */
char *program_name;

struct option long_options[] = 
{
  {"backup", 0, NULL, 'b'},
  {"directory", 0, &hard_dir_link, 1},
  {"force", 0, NULL, 'f'},
  {"interactive", 0, NULL, 'i'},
  {"suffix", 1, NULL, 'S'},
  {"symbolic", 0, &symbolic_link, 1},
  {"verbose", 0, &verbose, 1},
  {"version-control", 1, NULL, 'V'},
  {NULL, 0, NULL, 0}
};

void
main (argc, argv)
     int argc;
     char **argv;
{
  int c;
  int ind;
  int errors;
  int make_backups = 0;
  char *version;

  version = getenv ("SIMPLE_BACKUP_SUFFIX");
  if (version)
    simple_backup_suffix = version;
  version = getenv ("VERSION_CONTROL");
  program_name = argv[0];
  linkfunc = link;
  symbolic_link = remove_existing_files = interactive = verbose
    = hard_dir_link = 0;
  errors = 0;

  while ((c = getopt_long (argc, argv, "bdfisvFS:V:", long_options, &ind))
	 != EOF)
    {
      switch (c)
	{
	case 0:			/* Long-named option. */
 	  break;
	case 'b':
	  make_backups = 1;
	  break;
	case 'd':
	case 'F':
	  hard_dir_link = 1;
	  break;
	case 'f':
	  remove_existing_files = 1;
	  interactive = 0;
	  break;
	case 'i':
	  remove_existing_files = 0;
	  interactive = 1;
	  break;
	case 's':
#ifdef S_IFLNK
	  symbolic_link = 1;
#else
	  error (0, 0, "symbolic links not supported; making hard links");
#endif
	  break;
	case 'v':
	  verbose = 1;
	  break;
	case 'S':
	  simple_backup_suffix = optarg;
	  break;
	case 'V':
	  version = optarg;
	  break;
	default:
	  usage ();
	  break;
	}
    }
  if (optind == argc)
    usage ();

  if (make_backups)
    backup_type = get_version (version);

#ifdef S_IFLNK
  if (symbolic_link)
    linkfunc = symlink;
#endif

  if (optind == argc - 1)
    errors = do_link (argv[optind], ".");
  else if (optind == argc - 2)
    {
      strip_trailing_slashes (argv[optind + 1]);
      errors = do_link (argv[optind], argv[optind + 1]);
    }
  else
    {
      char *to;

      to = argv[argc - 1];
      strip_trailing_slashes (to);
      if (!isdir (to))
	error (1, 0, "when making multiple links, last argument must be a directory");
      for (; optind < argc - 1; ++optind)
	errors += do_link (argv[optind], to);
    }

  exit (errors != 0);
}

/* Make a link NEW to existing file OLD.
   If NEW is a directory, put the link to OLD in that directory.
   Return 1 if there is an error, otherwise 0.  */

int
do_link (old, new)
     char *old;
     char *new;
{
  struct stat new_stats;
  char *new_backup = NULL;

  strip_trailing_slashes (old);

  /* Since link follows symlinks, isdir uses stat instead of lstat. */
  if (!symbolic_link && !hard_dir_link && isdir (old))
    {
      error (0, 0, "%s: hard link not allowed for directory", old);
      return 1;
    }
  if (isdir (new))
    {
      /* Target is a directory; build the full filename. */
      char *new_new;
      char *old_base;

      old_base = basename (old);
      new_new = (char *) alloca (strlen (old_base) + 1 + strlen (new) + 1);
      sprintf (new_new, "%s/%s", new, old_base);
      new = new_new;
    }

  if (lstat (new, &new_stats) == 0)
    {
      if ((new_stats.st_mode & S_IFMT) == S_IFDIR)
	{
	  error (0, 0, "%s: cannot overwrite directory", new);
	  return 1;
	}
      if (interactive)
	{
	  fprintf (stderr, "%s: replace `%s'? ", program_name, new);
	  if (!yesno ())
	    return 0;
	}
      else if (!remove_existing_files)
	{
	  error (0, 0, "%s: File exists", new);
	  return 1;
	}

      if (backup_type != none)
	{
	  new_backup = find_backup_file_name (new);
	  if (new_backup == NULL)
	    error (1, 0, "virtual memory exhausted");
	  if (rename (new, new_backup))
	    {
	      if (errno != ENOENT)
		{
		  error (0, errno, "cannot backup `%s'", new);
		  free (new_backup);
		  return 1;
		}
	      else
		{
		  free (new_backup);
		  new_backup = NULL;
		}
	    }
	}
      else if (unlink (new) && errno != ENOENT)
	{
	  error (0, errno, "cannot remove old link to `%s'", new);
	  return 1;
	}
    }
  else if (errno != ENOENT)
    {
      error (0, errno, "%s", new);
      return 1;
    }
       
  if (verbose)
    printf ("%s -> %s\n", old, new);

  if ((*linkfunc) (old, new) == 0)
    {
      if (new_backup)
	free (new_backup);
      return 0;
    }

  error (0, errno, "cannot %slink `%s' to `%s'",
#ifdef S_IFLNK
	     linkfunc == symlink ? "symbolic " : "",
#else
	     "",
#endif
	     old, new);

  if (new_backup)
    {
      if (rename (new_backup, new))
	error (0, errno, "cannot un-backup `%s'", new);
      free (new_backup);
    }
  return 1;
}

/* Return 1 if the user gives permission, 0 if not.  */

int
yesno ()
{
  int c;
  int rv;

  fflush (stderr);
  c = getchar ();
  rv = (c == 'y') || (c == 'Y');
  while (c != EOF && c != '\n')
    c = getchar ();

  return rv;
}

/* Return 1 if FILE is a directory or a symlink to a directory;
   otherwise 0. */

int
isdir (file)
     char *file;
{
  struct stat stats;

  return stat (file, &stats) == 0 && (stats.st_mode & S_IFMT) == S_IFDIR;
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

/* Remove trailing slashes from PATH. */

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
  fprintf (stderr, "\
Usage: %s [-bdfisvF] [-S backup-suffix] [-V {numbered,existing,simple}]\n\
       [+version-control {numbered,existing,simple}] [+backup] [+directory]\n\
       [+force] [+interactive] [+symbolic] [+verbose] [+suffix backup-suffix]\n\
       source [dest]\n\
\n\
       %s [-bdfisvF] [-S backup-suffix] [-V {numbered,existing,simple}]\n\
       [+version-control {numbered,existing,simple}] [+backup] [+directory]\n\
       [+force] [+interactive] [+symbolic] [+verbose] [+suffix backup-suffix]\n\
       source... directory\n",
	   program_name, program_name);
  exit (1);
}
