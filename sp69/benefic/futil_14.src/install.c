/* install - copy files and set attributes
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

/* Copy files and set their permission modes and, if possible,
   their owner and group.  Used similarly to `cp'; typically
   used in Makefiles to copy programs into their destination
   directories.  It can also be used to create the destination
   directories and any leading directories, and to set the final
   directory's modes.  It refuses to copy files onto themselves.

   Usage: install [-cs] [-g group] [-m mode] [-o owner]
          [+strip] [+group group] [+mode mode] [+owner owner] file1 file2

          install [-cs] [-g group] [-m mode] [-o owner]
          [+strip] [+group group] [+mode mode] [+owner owner] file... dir

          install -d [-g group] [-m mode] [-o owner]
          +directory [+group group] [+mode mode] [+owner owner] dir

   Options:
   -g, +group GROUP
	Set the group ownership of the installed file or directory
	to the group ID of GROUP (default is process's current
	group).  GROUP may also be a numeric group ID.

   -m, +mode MODE
	Set the permission mode for the installed file or directory
	to MODE, which is an octal number (default is 0755).

   -o, +owner OWNER
	If run as root, set the ownership of the installed file to
	the user ID of OWNER (default is root).  OWNER may also be
	a numeric user ID.

   -c	No effect.  For compatibility with old Unix versions of install.

   -s, +strip
	Strip the symbol tables from installed files.

   -d, +directory
	Create a directory and its leading directories, if they
	do not already exist.  Set the owner, group and mode
	as given on the command line.  Any leading directories
	that are created are also given those attributes.
	This is different from the SunOs 4.0 install, which gives
	directories that it creates the default attributes.

   David MacKenzie <djm@ai.mit.edu> */

#include <stdio.h>
#include <getopt.h>
#include <ctype.h>
#include <sys/types.h>
#include <pwd.h>
#include <grp.h>
#include <errno.h>
#include "system.h"

#ifdef STDC_HEADERS
#include <stdlib.h>
#else
char *malloc ();

extern int errno;
#endif

#ifdef _POSIX_SOURCE
#include <sys/wait.h>
#else
struct passwd *getpwnam ();
struct group *getgrnam ();
unsigned short getuid ();
unsigned short getgid ();
int wait ();
#endif
void endpwent ();
void endgrent ();

/* True if C is an ASCII octal digit. */
#define isodigit(c) ((c) >= '0' && c <= '7')

/* Number of bytes of a file to copy at a time. */
#define READ_SIZE (32 * 1024)

char *basename ();
char *xmalloc ();
int atoo ();
int change_attributes ();
int copy_file ();
int install_dir ();
int install_file_in_dir ();
int install_file_in_file ();
int isdir ();
int isnumber ();
void error ();
void get_ids ();
void strip ();
void usage ();

/* The name this program was run with, for error messages. */
char *program_name;

/* The user name that will own the files, or NULL to make the owner
   the current user ID. */
char *owner_name;

/* The user ID corresponding to `owner_name'. */
int owner_id;

/* The group name that will own the files, or NULL to make the group
   the current group ID. */
char *group_name;

/* The group ID corresponding to `group_name'. */
int group_id;

/* The permissions to which the files will be set.  The umask has
   no effect. */
int mode;

/* If nonzero, strip executable files after copying them. */
int strip_files;

/* If nonzero, install a directory instead of a regular file. */
int dir_mode;

struct option long_options[] =
{
  {"strip", 0, NULL, 's'},
  {"directory", 0, NULL, 'd'},
  {"group", 1, NULL, 'g'},
  {"mode", 1, NULL, 'm'},
  {"owner", 1, NULL, 'o'},
  {NULL, 0, NULL, 0}
};

void
main (argc, argv)
     int argc;
     char **argv;
{
  int optc;
  int longind;
  int errors = 0;

  program_name = argv[0];
  owner_name = NULL;
  group_name = NULL;
  mode = 0755;
  strip_files = 0;
  dir_mode = 0;
  umask (0);

  while ((optc = getopt_long (argc, argv, "csdg:m:o:", long_options, &longind))
	 != EOF)
    {
      switch (optc)
	{
	case 'c':
	  break;
	case 's':
	  strip_files = 1;
	  break;
	case 'd':
	  dir_mode = 1;
	  break;
	case 'g':
	  group_name = optarg;
	  break;
	case 'm':
	  mode = atoo (optarg);
	  if (mode < 0 || mode > 07777)
	    error (1, 0, "invalid file mode `%s'", optarg);
	  break;
	case 'o':
	  owner_name = optarg;
	  break;
	default:
	  usage ();
	}
    }

  switch (argc - optind)
    {
    case 0:
      usage ();
      break;
    case 1:
      if (!dir_mode || strip_files)
	usage ();
      get_ids ();
      errors = install_dir (argv[optind]);
      break;
    case 2:
      if (dir_mode)
	usage ();
      get_ids ();
      if (!isdir (argv[argc - 1]))
	errors = install_file_in_file (argv[optind], argv[argc - 1]);
      else
	errors = install_file_in_dir (argv[optind], argv[argc - 1]);
      break;
    default:
      if (dir_mode || !isdir (argv[argc - 1]))
	usage ();
      get_ids ();
      for (; optind < argc - 1; ++optind)
	errors |= install_file_in_dir (argv[optind], argv[argc - 1]);
      break;
    }

  exit (errors);
}

/* Make sure directory `path' and all leading directories exist,
   and give it the appropriate attributes.
   If any leading directories are created, they too are given the
   specified attributes.
   Return 0 if successful, 1 if an error occurs. */

int
install_dir (path)
     char *path;
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
	      if (mkdir (path, 0777))
		{
		  error (0, errno, "cannot make directory `%s'", path);
		  return 1;
		}
	      change_attributes (path);
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

  return change_attributes (path);
}

/* Copy file `from' onto file `to' and give `to' the appropriate
   attributes.
   Return 0 if successful, 1 if an error occurs. */

int
install_file_in_file (from, to)
     char *from;
     char *to;
{
  if (copy_file (from, to))
    return 1;
  if (strip_files)
    strip (to);
  return 0;
}

/* Copy file `from' into directory `to_dir', keeping its same name,
   and give the copy the appropriate attributes.
   Return 0 if successful, 1 if not. */

int
install_file_in_dir (from, to_dir)
     char *from;
     char *to_dir;
{
  char *from_base;
  char *to;
  int ret;

  from_base = basename (from);
  to = xmalloc ((unsigned) (strlen (to_dir) + strlen (from_base) + 2));
  sprintf (to, "%s/%s", to_dir, from_base);
  ret = install_file_in_file (from, to);
  free (to);
  return ret;
}

/* A chunk of a file being copied. */
static char buffer[READ_SIZE];

/* Copy file `from' onto file `to', creating `to' if necessary.
   Return 0 if the copy is successful, 1 if not. */

int
copy_file (from, to)
     char *from;
     char *to;
{
  int fromfd, tofd;
  int bytes;
  struct stat from_stats, to_stats;

  if (stat (from, &from_stats))
    {
      error (0, errno, "%s", from);
      return 1;
    }
  if ((from_stats.st_mode & S_IFMT) != S_IFREG)
    {
      error (0, 0, "`%s' is not a regular file", from);
      return 1;
    }
  if (stat (to, &to_stats) == 0)
    {
      if ((to_stats.st_mode & S_IFMT) != S_IFREG)
	{
	  error (0, 0, "`%s' is not a regular file", to);
	  return 1;
	}
      if (from_stats.st_dev == to_stats.st_dev
	  && from_stats.st_ino == to_stats.st_ino)
	{
	  error (0, 0, "`%s' and `%s' are the same file", from, to);
	  return 1;
	}
      if (unlink (to))
	{
	  /* If unlink fails, try to proceed anyway.  If we can't change the
	     mode and maybe the owner and group, there is no point in
	     continuing; leave the original file contents unchanged. */
	  if (change_attributes (to))
	    return 1;
	}
    }

  fromfd = open (from, O_RDONLY, 0);
  if (fromfd == -1)
    {
      error (0, errno, "%s", from);
      return 1;
    }

  /* Make sure to open the file in a mode that allows writing. */
  tofd = open (to, O_WRONLY | O_CREAT | O_TRUNC, 0600);
  if (tofd == -1)
    {
      error (0, errno, "%s", to);
      close (fromfd);
      return 1;
    }

  while ((bytes = read (fromfd, buffer, READ_SIZE)) > 0)
    if (write (tofd, buffer, bytes) != bytes)
      {
	error (0, errno, "%s", to);
	goto copy_error;
      }

  if (bytes == -1)
    {
      error (0, errno, "%s", from);
      goto copy_error;
    }

  close (fromfd);
  close (tofd);
  return change_attributes (to);

 copy_error:
  close (fromfd);
  close (tofd);
  return 1;
}

/* Set the attributes of file or directory `path'.
   Return 0 if successful, 1 if not. */

int
change_attributes (path)
     char *path;
{
  if (chmod (path, mode)
      || (chown (path, owner_id, group_id) && errno != EPERM))
    {
      error (0, errno, "%s", path);
      return 1;
    }
  return 0;
}

/* Strip the symbol table from the file `path'.
   We could dig the magic number out of the file first to
   determine whether to strip it, but the header files and
   magic numbers vary so much from system to system that making
   it portable would be very difficult.  Not worth the effort. */

void
strip (path)
     char *path;
{
  int pid, status;

  pid = fork ();
  switch (pid)
    {
    case -1:
      error (1, errno, "cannot fork");
      break;
    case 0:			/* Child. */
      execlp ("strip", "strip", path, (char *) NULL);
      error (1, errno, "cannot run strip");
      break;
    default:			/* Parent. */
      /* Parent process. */
      while (pid != wait (&status))	/* Wait for kid to finish. */
	/* Do nothing. */ ;
      break;
    }
}

/* Initialize the user and group ownership of the files to install. */

void
get_ids ()
{
  struct passwd *pw;
  struct group *gr;

  if (owner_name)
    {
      pw = getpwnam (owner_name);
      if (pw == NULL)
	{
	  if (!isnumber (owner_name))
	    error (1, 0, "invalid user `%s'", owner_name);
	  owner_id = atoi (owner_name);
	}
      else
	owner_id = pw->pw_uid;
      endpwent ();
    }
  else
    owner_id = getuid ();

  if (group_name)
    {
      gr = getgrnam (group_name);
      if (gr == NULL)
	{
	  if (!isnumber (group_name))
	    error (1, 0, "invalid group `%s'", group_name);
	  group_id = atoi (group_name);
	}
      else
	group_id = gr->gr_gid;
      endgrent ();
    }
  else
    group_id = getgid ();
}

/* Return nonzero if `str' is an ASCII representation of a positive
   decimal integer, zero if not. */

int
isnumber (str)
     char *str;
{
  if (*str == 0)
    return 0;
  for (; *str; str++)
    if (!isdigit (*str))
      return 0;
  return 1;
}

/* If `path' is an existing directory or symbolic link to a directory,
   return nonzero, else 0. */

int
isdir (path)
     char *path;
{
  struct stat stats;

  return stat (path, &stats) == 0 && (stats.st_mode & S_IFMT) == S_IFDIR;
}

/* Return the value of the octal digit string `str'.
   Return -1 if `str' does not represent a valid octal number. */

int
atoo (str)
     char *str;
{
  int num;

  if (*str == 0)
    return -1;
  for (num = 0; isodigit (*str); ++str)
    num = num * 8 + *str - '0';
  return *str ? -1 : num;
}

/* Return `name' with any leading path stripped off. */

char *
basename (name)
     char *name;
{
  char *base;

  base = rindex (name, '/');
  return base ? base + 1 : name;
}

/* Allocate `n' bytes of memory dynamically, with error checking. */

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

void
usage ()
{
   fprintf (stderr, "\
Usage: %s [-cs] [-g group] [-m mode] [-o owner]\n\
       [+strip] [+group group] [+mode mode] [+owner owner] file1 file2\n\
\n\
       %s [-cs] [-g group] [-m mode] [-o owner]\n\
       [+strip] [+group group] [+mode mode] [+owner owner] file... dir\n\
\n\
       %s -d [-g group] [-m mode] [-o owner]\n\
       +directory [+group group] [+mode mode] [+owner owner] dir\n",
	    program_name, program_name, program_name);
  exit (1);
}
