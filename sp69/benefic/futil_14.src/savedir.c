/* savedir.c -- save the list of files in a directory in a string
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

/* Written by David MacKenzie <djm@ai.mit.edu>. */

/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
   This port is also distributed under the terms of the
   GNU General Public License as published by the
   Free Software Foundation.

   Please note that this file is not identical to the
   original GNU release, you should have received this
   code as patch to the official release.

   $Header: e:/gnu/fileutil/RCS/savedir.c 1.4.0.2 90/09/17 09:28:48 tho Exp $
 */

#include <sys/types.h>

#ifdef DIRENT
#include <dirent.h>
#ifdef direct
#undef direct
#endif
#define direct dirent
#define NLENGTH(direct) (strlen((direct)->d_name))
#else
#define NLENGTH(direct) ((direct)->d_namlen)
#ifdef USG
#ifdef SYSNDIR
#include <sys/ndir.h>
#else
#include <ndir.h>
#endif
#else
#include <sys/dir.h>
#endif
#endif

#ifdef STDC_HEADERS
#include <stdlib.h>
#include <string.h>
#else
char *malloc ();
char *realloc ();
int strlen ();
#ifndef NULL
#define NULL 0
#endif
#endif

#ifdef MSDOS
#include <stdio.h>
extern char *savedir (char *dir, unsigned name_size);
static char *stpcpy (char *dest, char *source);
#endif /* MSDOS */

static char *stpcpy ();

/* Return a freshly allocated string containing the filenames
   in directory DIR, separated by '\0' characters;
   the end is marked by two '\0' characters in a row.
   NAME_SIZE is the number of bytes to initially allocate
   for the string; it will be enlarged as needed.
   Return NULL if DIR cannot be opened or if out of memory. */

char *
savedir (dir, name_size)
     char *dir;
     unsigned name_size;
{
  DIR *dirp;
  struct direct *dp;
  char *name_space;
  char *namep;

  dirp = opendir (dir);
  if (dirp == NULL)
    return NULL;

#ifdef MSDOS	 			/* stat () it ourselves ... */
  name_size = 0;
  for (dp = readdir (dirp); dp != NULL; dp = readdir (dirp))
	name_size += strlen(dp->d_name) + 1;
  seekdir(dirp, 0L);
#endif /* MSDOS */

  name_space = (char *) malloc (name_size);
  if (name_space == NULL)
    return NULL;
  namep = name_space;

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

	      new_name_space = realloc (name_space, name_size);
	      if (new_name_space == NULL)
		{
		  closedir (dirp);
		  return NULL;
		}
	      namep += new_name_space - name_space;
	      name_space = new_name_space;
	    }
	  namep = stpcpy (namep, dp->d_name) + 1;
	}
    }
  *namep = '\0';
  closedir (dirp);
  return name_space;
}

/* Copy SOURCE into DEST, stopping after copying the first '\0', and
   return a pointer to the '\0' at the end of DEST;
   in other words, return DEST + strlen (SOURCE). */

static char *
stpcpy (dest, source)
     char *dest;
     char *source;
{
  while ((*dest++ = *source++) != '\0')
    /* Do nothing. */ ;
  return dest - 1;
}
