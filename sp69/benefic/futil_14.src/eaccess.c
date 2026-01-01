/* eaccess -- check if effective user id can access file
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

/* David MacKenzie and Torbjorn Granlund */

/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
   This port is also distributed under the terms of the
   GNU General Public License as published by the
   Free Software Foundation.

   Please note that this file is not identical to the
   original GNU release, you should have received this
   code as patch to the official release.

   $Header: e:/gnu/fileutil/RCS/eaccess.c 1.4.0.2 90/09/19 12:27:30 tho Exp $
 */

#include <sys/types.h>
#include <sys/stat.h>
#ifdef _POSIX_SOURCE
#include <unistd.h>
#else
#ifdef MSDOS
#include <pwd.h>
#else /* not MSDOS */
#include <sys/param.h>
#endif /* not MSDOS */
#endif
#include <errno.h>
#if defined(EACCES) && !defined(EACCESS)
#define EACCESS EACCES
#endif

#ifdef MSDOS
#include <stdlib.h>
extern  int eaccess (char *path, int mode);
extern  int eaccess_stat (struct stat *statp, int mode);
#endif /* MSDOS */

#ifndef _POSIX_SOURCE
#define F_OK 0
#define X_OK 1
#define W_OK 2
#define R_OK 4
#endif

#ifndef STDC_HEADERS
extern int errno;
#endif

int eaccess_stat ();

/* The user's effective user id. */
static unsigned short euid;

/* The user's effective group id. */
static unsigned short egid;

/* NGROUPS is defined in sys/param.h on systems with multiple groups. */
#ifdef NGROUPS
static int in_group ();

/* Array of group id's that the user is in. */
static unsigned int groups[NGROUPS];

/* The number of valid elements in `groups'. */
static int ngroups;
#endif

/* Nonzero if the other static variables have valid values. */
static int initialized = 0;

/* Return 0 if the user has permission of type MODE on file PATH;
   otherwise, return -1 and set `errno' to EACCESS.
   Like access, except that it uses the effective user and group
   id's instead of the real ones, and it does not check for read-only
   filesystem, text busy, etc. */

int
eaccess (path, mode)
     char *path;
     int mode;
{
  struct stat stats;

  if (stat (path, &stats))
    return -1;

  return eaccess_stat (&stats, mode);
}

/* Like eaccess, except that a pointer to a filled-in stat structure
   describing the file is provided instead of a filename. */

int
eaccess_stat (statp, mode)
     struct stat *statp;
     int mode;
{
  int granted;

  mode &= (X_OK | W_OK | R_OK);	/* Clear any bogus bits. */

  if (mode == F_OK)
    return 0;			/* The file exists. */

  if (initialized == 0)
    {
      initialized = 1;
      euid = geteuid ();
      egid = getegid ();
#ifdef NGROUPS
      ngroups = getgroups (NGROUPS, groups);
#endif
    }
  
  /* The super-user can read and write any file, and execute any file
     that anyone can execute. */
  if (euid == 0 && ((mode & X_OK) == 0 || (statp->st_mode & 0111)))
    return 0;
  if (euid == statp->st_uid)
    granted = (statp->st_mode & (mode << 6)) >> 6;
  else if (egid == statp->st_gid
#ifdef NGROUPS
	   || in_group (statp->st_gid)
#endif
	   )
    granted = (statp->st_mode & (mode << 3)) >> 3;
  else
    granted = (statp->st_mode & mode);
  if (granted == mode)
    return 0;
  errno = EACCESS;
  return -1;
}

#ifdef NGROUPS
static int
in_group (gid)
     int gid;
{
  int i;

  for (i = 0; i < ngroups; i++)
    if (gid == groups[i])
      return 1;
  return 0;
}
#endif

#ifdef TEST
main (argc, argv)
     char **argv;
{
  printf ("%d\n", eaccess (argv[1], atoi (argv[2])));
}
#endif
