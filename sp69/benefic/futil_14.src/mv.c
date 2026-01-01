/* mv -- move or rename files
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
/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
   This port is also distributed under the terms of the
   GNU General Public License as published by the
   Free Software Foundation.

   Please note that this file is not identical to the
   original GNU release, you should have received this
   code as patch to the official release.  */

#ifdef MSDOS
static char RCS_Id[] =
  "$Header: e:/gnu/fileutil/RCS/mv.c 1.4.0.2 90/09/19 12:11:15 tho Exp $";

static char Program_Id[] = "mv";
static char RCS_Revision[] = "$Revision: 1.4.0.2 $";

#define VERSION \
  "GNU %s, Version %.*s (compiled %s %s for MS-DOS)\n", Program_Id, \
  (sizeof RCS_Revision - 14), (RCS_Revision + 11), __DATE__, __TIME__

#define COPYING \
  "This is free software, distributed under the terms of the\n" \
  "GNU General Public License.  For details, see the file COPYING.\n"
#endif /* MSDOS */

/* Options:
   -f, +force		Assume a 'y' answer to all questions it would
			normally ask, and not ask the questions.

   -i, +interactive	Require confirmation from the user before
			performing any move that would destroy an
			existing file. 

   -u, +update		Do not move a nondirectory that has an
			existing destination with the same or newer
			modification time.  

   -v, +verbose		List the name of each file as it is moved, and
			the name it is moved to. 

   -b, +backup
   -S, +suffix
   -V, +version-control
			Backup file creation.  See README.

   Written by Mike Parker and David MacKenzie */

#include <stdio.h>
#include <getopt.h>
#include <errno.h>
#include <sys/types.h>
#include "system.h"
#include "backupfile.h"

#ifdef STDC_HEADERS
#include <stdlib.h>
#else
char *getenv ();

extern int errno;
#endif

#ifdef MSDOS

#include <io.h>
#include <gnulib.h>

extern  void main (int argc, char **argv);
extern  void error (int status, int errnum, char *message, ...);
extern  int eaccess_stat (struct stat *statp, int mode);
extern  enum backup_type get_version (char *version);
static  int isdir (char *fn);
static  int movefile (char *from, char *to);
static  int do_move (char *from, char *to);
static  int copy (char *from, char *to);
static  int yesno (void );
static  void strip_trailing_slashes (char **path);
static  int force_unlink (char *filename);
static  void usage (void );

#define unlink(name)		force_unlink (name)
#define rename(from, to)	(unlink (to) || rename (from, to))
#define strip_trailing_slashes(path)	strip_trailing_slashes (&path)

#else /* not MSDOS */

enum backup_type get_version ();
int copy ();
int do_move ();
int isdir ();
int movefile ();
int yesno ();
void error ();
void strip_trailing_slashes ();
void usage ();

#endif /* not MSDOS */

/* The name this program was run with. */
char *program_name;

/* If nonzero, query the user before overwriting files. */
int interactive;

/* If nonzero, do not move a nondirectory that has an existing destination
   with the same or newer modification time. */
int update = 0;

/* If nonzero, list each file as it is moved. */
int verbose;

struct option long_options[] =
{
#ifdef MSDOS
  {"copying", 0, NULL, 30},
  {"version", 0, NULL, 31},
#endif
  {"backup", 0, NULL, 'b'},
  {"force", 0, NULL, 'f'},
  {"interactive", 0, NULL, 'i'},
  {"suffix", 1, NULL, 'S'},
  {"update", 0, &update, 1},
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
  interactive = verbose = update = 0;
  errors = 0;

  while ((c = getopt_long (argc, argv, "bfiuvS:V:", long_options, &ind))
	 != EOF)
    {
      switch (c)
	{
	case 0:
	  break;
	case 'b':
	  make_backups = 1;
	  break;
	case 'f':
	  interactive = 0;
	  break;
	case 'i':
	  interactive = 1;
	  break;
	case 'u':
	  update = 1;
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
  if (argc < optind + 2)
    usage ();

  if (make_backups)
    backup_type = get_version (version);

  strip_trailing_slashes (argv[argc - 1]);

  if (argc > optind + 2 && !isdir (argv[argc - 1]))
    error (1, 0, "when moving multiple files, last argument must be a directory");

  /* Move each arg but the last onto the last. */
  for (; optind < argc - 1; ++optind)
    errors |= movefile (argv[optind], argv[argc - 1]);

  exit (errors);
}

/* Move file FROM onto TO.  Handles the case when TO is a directory.
   Return 0 if successful, 1 if an error occurred.  */

int
movefile (from, to)
     char *from;
     char *to;
{
  strip_trailing_slashes (from);
  if (isdir (to))
    {
      /* Target is a directory; build full target filename. */
      char *cp;
      char *newto;

      cp = rindex (from, '/');
      if (cp)
	cp++;
      else
	cp = from;

      newto = (char *) alloca (strlen (to) + 1 + strlen (cp) + 1);
#ifdef MSDOS
      /* Here a trailing slash might still be present (needed for
	 stat()'ing root directories), take care of that. */
      if (to[strlen(to) - 1] == '/')
	sprintf (newto, "%s%s", to, cp);
      else
#endif /* MSDOS */
      sprintf (newto, "%s/%s", to, cp);
      return do_move (from, newto);
    }
  else
    return do_move (from, to);
}

struct stat to_stats, from_stats;

/* Move FROM onto TO.  Handles cross-filesystem moves.
   If TO is a directory, FROM must be also.
   Return 0 if successful, 1 if an error occurred.  */

int
do_move (from, to)
     char *from;
     char *to;
{
  char *to_backup = NULL;

  if (lstat (from, &from_stats) != 0)
    {
      error (0, errno, "%s", from);
      return 1;
    }

  if (lstat (to, &to_stats) == 0)
    {
#ifdef MSDOS
      if (strcmp (to, from) == 0)
	{
	  error (0, 0, "`%s': can't move file to itself", from);
	  return 1;
	}
#else /* not MSDOS */
      if (from_stats.st_dev == to_stats.st_dev
	  && from_stats.st_ino == to_stats.st_ino)
	{
	  error (0, 0, "`%s' and `%s' are the same file", from, to);
	  return 1;
	}
#endif /* not MSDOS */

      if ((to_stats.st_mode & S_IFMT) == S_IFDIR)
	{
	  error (0, 0, "%s: cannot overwrite directory", to);
	  return 1;
	}

      if ((from_stats.st_mode & S_IFMT) != S_IFDIR && update
	  && from_stats.st_mtime <= to_stats.st_mtime)
	return 0;

      if (interactive)
	{
	  fprintf (stderr, "%s: replace `%s'? ", program_name, to);
	  if (!yesno ())
	    return 0;
	}

      if (backup_type != none)
	{
	  to_backup = find_backup_file_name (to);
	  if (to_backup == NULL)
	    error (1, 0, "virtual memory exhausted");
	  if (rename (to, to_backup))
	    {
	      if (errno != ENOENT)
		{
		  error (0, errno, "cannot backup `%s'", to);
		  free (to_backup);
		  return 1;
		}
	      else
		{
		  free (to_backup);
		  to_backup = NULL;
		}
	    }
	}
    }
  else if (errno != ENOENT)
    {
      error (0, errno, "%s", to);
      return 1;
    }

  if (verbose)
    printf ("%s -> %s\n", from, to);

  if (rename (from, to) == 0)
    {
      if (to_backup)
	free (to_backup);
      return 0;
    }

  if (errno != EXDEV)
    {
      error (0, errno, "cannot move `%s' to `%s'", from, to);
      goto un_backup;
    }

  /* rename failed on cross-filesystem link.  Copy the file instead. */

  if (copy (from, to))
    goto un_backup;
  
  if (to_backup)
    free (to_backup);

  if (unlink (from))
    {
      error (0, errno, "cannot remove `%s'", from);
      return 1;
    }

  return 0;

 un_backup:
  if (to_backup)
    {
      if (rename (to_backup, to))
	error (0, errno, "cannot un-backup `%s'", to);
      free (to_backup);
    }
  return 1;
}

/* Copy file FROM onto file TO.
   Return 1 if an error occurred, 0 if successful. */

int
copy (from, to)
     char *from, *to;
{
  int ifd;
  int ofd;
  char buf[1024 * 8];
  int len;			/* Number of bytes read into `buf'. */
  
  if ((from_stats.st_mode & S_IFMT) != S_IFREG)
    {
      error (0, 0, "cannot move `%s' across filesystems: Not a regular file",
	     from);
      return 1;
    }
  
  if (unlink (to) && errno != ENOENT)
    {
      error (0, errno, "cannot remove `%s'", to);
      return 1;
    }

#ifdef MSDOS
  ifd = open (from, O_RDONLY | O_BINARY, 0);
#else /* not MSDOS */
  ifd = open (from, O_RDONLY, 0);
#endif /* not MSDOS */
  if (ifd < 0)
    {
      error (0, errno, "%s", from);
      return 1;
    }

#ifdef MSDOS
  ofd = open (to, O_WRONLY | O_CREAT | O_TRUNC | O_BINARY, 0777);
#else /* not MSDOS */
  ofd = open (to, O_WRONLY | O_CREAT | O_TRUNC, 0777);
#endif /* not MSDOS */
  if (ofd < 0)
    {
      error (0, errno, "%s", to);
      close (ifd);
      return 1;
    }
  if (
#ifdef FCHMOD_MISSING
      chmod (to, from_stats.st_mode & 0777)
#else
      fchmod (ofd, from_stats.st_mode & 0777)
#endif
      )
      {
	error (0, errno, "%s", to);
	close (ifd);
	close (ofd);
	unlink (to);
	return 1;
      }
  
  while ((len = read (ifd, buf, sizeof (buf))) > 0)
    {
      int wrote = 0;
      char *bp = buf;
      
      do
	{
	  wrote = write (ofd, bp, len);
	  if (wrote < 0)
	    {
	      error (0, errno, "%s", to);
	      close (ifd);
	      close (ofd);
	      unlink (to);
	      return 1;
	    }
	  bp += wrote;
	  len -= wrote;
	} while (len > 0);
    }
  if (len < 0)
    {
      error (0, errno, "%s", from);
      close (ifd);
      close (ofd);
      unlink (to);
      return 1;
    }
  close (ifd);
  close (ofd);
  
  /* Try to copy the old file's modtime and access time.  */
  {
    struct utimbuf tv;

    tv.actime = from_stats.st_atime;
    tv.modtime = from_stats.st_mtime;
    if (utime (to, &tv))
      {
	error (0, errno, "%s", to);
	return 1;
      }
  }
  return 0;
}

/* Read one line from standard input
   and return nonzero if that line begins with y or Y,
   otherwise return 0. */

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

/* Return nonzero if FN is a directory or a symlink to a directory,
   zero if not. */

int
isdir (fn)
     char *fn;
{
  struct stat stats;

  return (stat (fn, &stats) == 0 && (stats.st_mode & S_IFMT) == S_IFDIR);
}

/* Remove trailing slashes from PATH. */


#ifdef MSDOS
#undef strip_trailing_slashes

void
strip_trailing_slashes (char **path)
{
  char *new_path = _fullpath (NULL, *path, 0);
  free (*path);
  *path = msdos_format_filename (new_path);
}

#else /* not MSDOS */

void
strip_trailing_slashes (path)
     char *path;
{
  int last;

  last = strlen (path) - 1;
  while (last > 0 && path[last] == '/')
    path[last--] = '\0';
}

#endif /* not MSDOS */

void
usage ()
{
#ifdef MSDOS
  fprintf (stderr, "\
Usage: %s [-bfiuv] [-S backup-suffix] [-V {numbered,existing,simple}]\n\
       [+backup] [+force] [+interactive] [+update] [+verbose]\n\
       [+suffix backup-suffix] [+version-control {numbered,existing,simple}]\n\
       [+copying] [+version] source dest\n\
\n\
       %s [-bfiuv] [-S backup-suffix] [-V {numbered,existing,simple}]\n\
       [+backup] [+force] [+interactive] [+update] [+verbose]\n\
       [+suffix backup-suffix] [+version-control {numbered,existing,simple}]\n\
       [+copying] [+version] source... directory\n",
	   program_name, program_name);
#else /* not MSDOS */
  fprintf (stderr, "\
Usage: %s [-bfiuv] [-S backup-suffix] [-V {numbered,existing,simple}]\n\
       [+backup] [+force] [+interactive] [+update] [+verbose]\n\
       [+suffix backup-suffix] [+version-control {numbered,existing,simple}]\n\
       source dest\n\
\n\
       %s [-bfiuv] [-S backup-suffix] [-V {numbered,existing,simple}]\n\
       [+backup] [+force] [+interactive] [+update] [+verbose]\n\
       [+suffix backup-suffix] [+version-control {numbered,existing,simple}]\n\
       source... directory\n",
	   program_name, program_name);
#endif /* not MSDOS */
  exit (1);
}

#ifdef MSDOS
#undef unlink					/* nasty tricks ... */

int
force_unlink (char *filename)
{
  if (access (filename, 0))	/* file doesn't exist, pretend success */
    return 0;
  else
    {
      if (access (filename, 2)			  /* no write permission */
	  && chmod (filename, S_IREAD|S_IWRITE))  /* can't force it ...  */
	{
	  error (0, errno, "can't force write permission for %s", filename);
	  return -1;
	}
      else
	return unlink (filename);
    }
}
#endif /* MSDOS */
