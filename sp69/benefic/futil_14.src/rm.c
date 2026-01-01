/* `rm' file deletion utility for GNU.
   Copyright (C) 1988, 1989, 1990 Free Software Foundation, Inc.

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

/* Written by Paul Rubin, David MacKenzie, and Richard Stallman. */

/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
   This port is also distributed under the terms of the
   GNU General Public License as published by the
   Free Software Foundation.

   Please note that this file is not identical to the
   original GNU release, you should have received this
   code as patch to the official release.  */

#ifdef MSDOS
static char RCS_Id[] =
  "$Header: e:/gnu/fileutil/RCS/rm.c 1.4.0.3 90/09/20 08:46:14 tho Exp $";

static char Program_Id[] = "rm";
static char RCS_Revision[] = "$Revision: 1.4.0.3 $";

#define VERSION \
  "GNU %s, Version %.*s (compiled %s %s for MS-DOS)\n", Program_Id, \
  (sizeof RCS_Revision - 14), (RCS_Revision + 11), __DATE__, __TIME__

#define COPYING \
  "This is free software, distributed under the terms of the\n" \
  "GNU General Public License.  For details, see the file COPYING.\n"
#endif /* MSDOS */

#include <stdio.h>
#include <getopt.h>
#include <sys/types.h>
#include <errno.h>
#include "system.h"

#ifdef STDC_HEADERS
#include <stdlib.h>
#else
char *malloc ();
char *realloc ();

extern int errno;
#endif

#ifdef MSDOS
#include <string.h>
#include <malloc.h>
#include <io.h>
#include <direct.h>

#include <gnulib.h>

extern  void main (int argc, char **argv);
static  int rm (void);
static  int remove_file (struct stat *statp);
static  int remove_dir (struct stat *statp);
static  int clear_directory (struct stat *statp);
static  int yesno (void);
static  char *basename (char *name);
static  char *stpcpy (char *dest, char *source);
static  void usage (void);

extern  int eaccess (char *path, int mode);
extern  int eaccess_stat (struct stat *statp, int mode);

static  void strip_trailing_slashes (char **path);
#define strip_trailing_slashes(path)	strip_trailing_slashes (&path)
#define check_stack(stck, ino)		0
#define unlink(name)			force_unlink (name)
static int force_unlink (char *filename);

#else /* not MSDOS */

char *basename ();
char *stpcpy ();
char *xmalloc ();
char *xrealloc ();
int check_stack ();
int clear_directory ();
int eaccess_stat ();
int remove_dir ();
int remove_file ();
int rm ();
int yesno ();
void error ();
void strip_trailing_slashes ();
void usage ();

#endif /* not MSDOS */


/* Path of file now being processed; extended as necessary. */
char *pathname;

/* Number of bytes currently allocated for `pathname';
   made larger when necessary, but never smaller.  */
int pnsize;

/* Name this program was run with.  */
char *program_name;

/* If nonzero, display the name of each file removed. */
int verbose;

/* If nonzero, ignore nonexistant files. */
int ignore_missing_files;

/* If nonzero, recursively remove directories. */
int recursive;

/* If nonzero, query the user about whether to remove each file. */
int interactive;

/* If nonzero, remove directories with unlink instead of rmdir, and don't
   require a directory to be empty before trying to unlink it.
   Only works for the super-user. */
int unlink_dirs;

/* Information for detecting attempted removal of `.' and `..'. */
dev_t dot_dev, dotdot_dev;
ino_t dot_ino, dotdot_ino;

struct option long_opts[] =
{
#ifdef MSDOS
  {"copying", 0, NULL, 30},
  {"version", 0, NULL, 31},
#endif
  {"directory", 0, &unlink_dirs, 1},
  {"force", 0, NULL, 'f'},
  {"interactive", 0, NULL, 'i'},
  {"recursive", 0, &recursive, 1},
  {"verbose", 0, &verbose, 1},
  {NULL, 0, NULL, 0}
};

void
main (argc, argv)
     int argc;
     char **argv;
{
  int err = 0;
  int c;
  int ind;
  struct stat stats;

  verbose = ignore_missing_files = recursive = interactive
    = unlink_dirs = 0;
  pnsize = 256;
  program_name = argv[0];
  pathname = xmalloc (pnsize);

  while ((c = getopt_long (argc, argv, "dfirvR", long_opts, &ind)) != EOF)
    {
      switch (c)
	{
	case 0:			/* Long option. */
	  break;
	case 'd':
	  unlink_dirs = 1;
	  break;
	case 'f':
	  ignore_missing_files = 1;
	  interactive = 0;
	  break;
	case 'i':
	  ignore_missing_files = 0;
	  interactive = 1;
	  break;
	case 'r':
	case 'R':
	  recursive = 1;
	  break;
	case 'v':
	  verbose = 1;
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

#ifndef MSDOS			/* this fails at the root ... */
  if (lstat (".", &stats))
    error (1, errno, ".");
  dot_dev = stats.st_dev;
  dot_ino = stats.st_ino;
  if (lstat ("..", &stats))
    error (1, errno, "..");
  dotdot_dev = stats.st_dev;
  dotdot_ino = stats.st_ino;
#endif /* not MSDOS */

  for (; optind < argc; optind++)
    {
      int len;

      strip_trailing_slashes (argv[optind]);
      len = strlen (argv[optind]);
      if (len + 1 > pnsize)
	{
	  free (pathname);
	  pnsize = 2 * (len + 1);
	  pathname = xmalloc (pnsize);
	}
      strcpy (pathname, argv[optind]);
      err += rm ();
    }

  exit (err > 0);
}

/* Remove file or directory `pathname' after checking appropriate things.
   Return 0 if `pathname' is removed, 1 if not. */

int
rm ()
{
  struct stat path_stats;

  if (lstat (pathname, &path_stats))
    {
      if (errno == ENOENT && ignore_missing_files)
	return 0;
      error (0, errno, "%s", pathname);
      return 1;
    }

#ifndef MSDOS
  if ((path_stats.st_dev == dot_dev && path_stats.st_ino == dot_ino)
      || (path_stats.st_dev == dotdot_dev && path_stats.st_ino == dotdot_ino))
    {
      error (0, 0, "%s: cannot remove current directory or parent", pathname);
      return 1;
    }
#endif /* not MSDOS */

  if ((path_stats.st_mode & S_IFMT) == S_IFDIR && !unlink_dirs)
    return remove_dir (&path_stats);
  else
    return remove_file (&path_stats);
}

/* Query the user if appropriate, and if ok try to remove the
   non-directory `pathname', which STATP contains info about.
   Return 0 if `pathname' is removed, 1 if not. */

int
remove_file (statp)
     struct stat *statp;
{
  if (interactive)
    {
      fprintf (stderr, "%s: remove %s`%s'? ", program_name,
	       (statp->st_mode & S_IFMT) == S_IFDIR ? "directory " : "",
	       pathname);
      if (!yesno ())
	return 1;
    }

  if (verbose)
    printf ("  %s\n", pathname);

  if (unlink (pathname))
    {
      error (0, errno, "%s", pathname);
      return 1;
    }
  return 0;
}

/* If not in recursive mode, print an error message and return 1.
   Otherwise, query the user if appropriate, then try to recursively
   remove directory `pathname', which STATP contains info about.
   Return 0 if `pathname' is removed, 1 if not. */

int
remove_dir (statp)
     struct stat *statp;
{
  int err;
  int writable;

  if (!recursive)
    {
      error (0, 0, "%s: is a directory", pathname);
      return 1;
    }

#ifdef S_IFLNK
  if ((statp->st_mode & S_IFMT) == S_IFLNK)
    writable = 1;
  else
#endif
    writable = eaccess_stat (statp, W_OK) == 0;

  if (!writable)
    {
      error (0, 0, "%s: no write permission for directory", pathname);
      return 1;
    }

  if (interactive)
    {
      fprintf (stderr, "%s: recursively descend directory `%s'? ",
	       program_name, pathname);
      if (!yesno ())
	return 1;
    }

  if (verbose)
    printf ("  %s\n", pathname);

  err = clear_directory (statp);
  if (err == 0)
    {
      if (interactive)
	{
	  fprintf (stderr, "%s: remove directory `%s'? ",
		   program_name, pathname);
	  if (!yesno ())
	    return 1;
	}
      err = rmdir (pathname) != 0;
      if (err != 0)
	error (0, errno, "%s", pathname);
    }
  return err;
}

/* An element in a stack of pointers into `pathname'.
   `pathp' points to where in `pathname' the terminating '\0' goes
   for this level's directory name. */
struct pathstack
{
  struct pathstack *next;
  char *pathp;
  ino_t inum;
};

/* Linked list of pathnames of directories in progress in recursive rm.
   The entries actually contain pointers into `pathname'.
   `pathstack' is the current deepest level. */
static struct pathstack *pathstack = NULL;

/* Read directory `pathname' and remove all of its entries,
   avoiding use of chdir.
   On entry, STATP points to the results of stat on `pathname'.
   Return 0 for success, error count for failure.
   Upon return, `pathname' will have the same contents as before,
   but its address might be different; in that case, `pnsize' will
   be larger, as well. */

int
clear_directory (statp)
     struct stat *statp;
{
  DIR *dirp;
  struct direct *dp;
  char *name_space;		/* Copy of directory's filenames. */
  char *namep;			/* Current entry in `name_space'. */
  unsigned name_size;		/* Bytes allocated for `name_space'. */
  ino_t *inode_space;		/* Copy of directory's inodes. */
  ino_t *inodep;		/* Current entry in `inode_space'. */
  unsigned inode_size;		/* Bytes allocated for `inode_space'. */
  int name_length;		/* Length of filename in `namep' plus '\0'. */
  int pathname_length;		/* Length of `pathname'. */
  int err = 0;			/* Return status. */
  struct pathstack pathframe;	/* New top of stack. */
  struct pathstack *pp;		/* Temporary. */

  errno = 0;
  dirp = opendir (pathname);
  if (dirp == NULL)
    {
      error (0, errno, "%s", pathname);
      return 1;
    }

#ifdef MSDOS				/* stat () it ourselves ... */
  statp->st_size = 0L;
  for (dp = readdir (dirp); dp != NULL; dp = readdir (dirp))
	statp->st_size += strlen(dp->d_name) + 1;
  seekdir(dirp, 0L);
#endif /* MSDOS */

  name_size = statp->st_size;
  name_space = (char *) xmalloc (name_size);
  namep = name_space;

#ifndef MSDOS
  inode_size = statp->st_size;
  inode_space = (ino_t *) xmalloc (inode_size);
  inodep = inode_space;
#endif /* not MSDOS */

  while ((dp = readdir (dirp)) != NULL)
    {
      /* Skip "." and ".." (some NFS filesystems' directories lack them). */
      if (dp->d_name[0] != '.'
	  || (dp->d_name[1] != '\0'
	      && (dp->d_name[1] != '.' || dp->d_name[2] != '\0')))
	{
	  unsigned size_needed = (namep - name_space) + NLENGTH (dp) + 2;

	  if (size_needed > name_size)
	    {
	      char *new_name_space;

	      while (size_needed > name_size)
		name_size += 1024;

	      new_name_space = xrealloc (name_space, name_size);
	      namep += new_name_space - name_space;
	      name_space = new_name_space;
	    }
	  namep = stpcpy (namep, dp->d_name) + 1;

#ifndef MSDOS
	  if (inodep == inode_space + inode_size)
	    {
	      ino_t *new_inode_space;

	      inode_size += 1024;
	      new_inode_space = (ino_t *) xrealloc (inode_space, inode_size);
	      inodep += new_inode_space - inode_space;
	      inode_space = new_inode_space;
	    }
	  *inodep++ = dp->d_ino;
#endif /* not MSDOS */
	}
    }
  *namep = '\0';
  closedir (dirp);
  
  pathname_length = strlen (pathname);

  for (namep = name_space, inodep = inode_space; *namep != '\0';
       namep += name_length, inodep++)
    {
      name_length = strlen (namep) + 1;

      /* Satisfy GNU requirement that filenames can be arbitrarily long. */
      if (pathname_length + 1 + name_length > pnsize)
	{
	  char *new_pathname;

	  pnsize = (pathname_length + 1 + name_length) * 2;
	  new_pathname = xrealloc (pathname, pnsize);
	  /* Update the all the pointers in the stack to use the new area. */
	  for (pp = pathstack; pp != NULL; pp = pp->next)
	    pp->pathp += new_pathname - pathname;
	  pathname = new_pathname;
	}

      /* Add a new frame to the top of the path stack. */
      pathframe.pathp = pathname + pathname_length;
      pathframe.inum = *inodep;
      pathframe.next = pathstack;
      pathstack = &pathframe;

      /* Append '/' and the filename to current pathname, take care of the
	 file (which could result in recursive calls), and take the filename
	 back off. */

      *pathstack->pathp = '/';
      strcpy (pathstack->pathp + 1, namep);

      /* If the i-number has already appeared, there's an error. */
      if (check_stack (pathstack->next, pathstack->inum) || rm ())
	err++;

      *pathstack->pathp = '\0';
      pathstack = pathstack->next;	/* Pop the stack. */
    }
  free (name_space);
#ifndef MSDOS
  free (inode_space);
#endif /* not MSDOS */
  return err;
}

#ifndef MSDOS
/* If STACK does not already have an entry with the same i-number as INUM,
   return 0. Otherwise, ask the user whether to continue;
   if yes, return 1, and if no, exit.
   This assumes that no one tries to remove filesystem mount points;
   doing so could cause duplication of i-numbers that would not indicate
   a corrupted file system. */

int
check_stack (stack, inum)
     struct pathstack *stack;
     ino_t inum;
{
  struct pathstack *p;

  for (p = stack; p != NULL; p = p->next)
    {
      if (p->inum == inum)
	{
	  fprintf (stderr, "\
%s: WARNING: Circular directory structure.\n\
This almost certainly means that you have a corrupted file system.\n\
NOTIFY YOUR SYSTEM MANAGER.\n\
Cycle detected:\n\
%s\n\
is the same file as\n", program_name, pathname);
	  *p->pathp = '\0';	/* Truncate pathname. */
	  fprintf (stderr, "%s\n", pathname);
	  *p->pathp = '/';	/* Put it back. */
	  fprintf (stderr, "%s: continue? ", program_name);
	  if (!yesno ())
	    exit (1);
	  return 1;
	}
    }
  return 0;
}
#endif /* !MSDOS */

/* Query the user for a line from the keyboard;
   return 1 if yes, 0 otherwise. */

int
yesno ()
{
  int c, c2;

  fflush (stderr);
  c = getchar ();
  if (c == '\n')
    return 0;
  while ((c2 = getchar ()) != '\n' && c2 != EOF)
    ;

  return c == 'y' || c == 'Y';
}

/* Remove trailing slashes from PATH; they cause some system calls to fail. */

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

char *
xmalloc (n)
     unsigned n;
{
  char *p;

  p = malloc (n);
  if (p == 0)
    error (2, 0, "virtual memory exhausted");
  return p;
}

char *
xrealloc (p, n)
     char *p;
     unsigned n;
{
  p = realloc (p, n);
  if (p == 0)
    error (2, 0, "virtual memory exhausted");
  return p;
}

#endif /* not MSDOS */

/* Return NAME with any leading path stripped off.  */

char *
basename (name)
     char *name;
{
  char *base;

  base = rindex (name, '/');
  return base ? base + 1 : name;
}

/* Copy SOURCE into DEST, stopping after copying the first '\0', and
   return a pointer to the '\0' at the end of DEST;
   in other words, return DEST + strlen (SOURCE). */

char *
stpcpy (dest, source)
     char *dest;
     char *source;
{
  while ((*dest++ = *source++) != 0)
    /* Do nothing. */ ;
  return dest - 1;
}

void
usage ()
{
#ifdef MSDOS
  fprintf (stderr, "\
Usage: %s [-dfirvR] [+directory] [+force] [+interactive] [+recursive]\n\
       [+verbose] [+copying] [+version] path...\n",
#else /* not MSDOS */
  fprintf (stderr, "\
Usage: %s [-dfirvR] [+directory] [+force] [+interactive] [+recursive]\n\
       [+verbose] path...\n",
#endif /* not MSDOS */
	   program_name);
  exit (1);
}

#ifdef MSDOS
int
force_unlink(char *filename)
{
  if (access( filename, 2))			/* read only */
    if (chmod( filename, S_IREAD|S_IWRITE))
      error (0, errno, "can't force write permission for %s", filename);

#undef unlink					/* nasty tricks ... */
  return unlink (filename);
}
#endif /* MSDOS */
