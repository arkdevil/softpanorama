/* backupfile.c -- make Emacs style backup file names
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

/* David MacKenzie <djm@ai.mit.edu>.
   Some algorithms adapted from GNU Emacs. */
/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
   This port is also distributed under the terms of the
   GNU General Public License as published by the
   Free Software Foundation.

   Please note that this file is not identical to the
   original GNU release, you should have received this
   code as patch to the official release.  */

#ifdef MSDOS
static char RCS_Id[] =
  "$Header: e:/gnu/fileutil/RCS/backupfi.c 1.4.0.2 90/09/19 12:27:27 tho Exp $";
#endif /* MSDOS */

#include <stdio.h>
#include <ctype.h>
#include <sys/types.h>
#include "backupfile.h"
#if defined(USG) || defined(_STDC_HEADERS)
#define index strchr
#define rindex strrchr
#include <string.h>
#else
#include <strings.h>
#endif

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
#else /* must be BSD */
#include <sys/dir.h>
#endif
#endif

#ifdef STDC_HEADERS
#include <stdlib.h>
#define ISDIGIT(c) (isdigit ((unsigned char) (c)))
#else
#define ISDIGIT(c) (isascii (c) && isdigit (c))

char *malloc ();
#endif

#ifdef MSDOS
extern char *find_backup_file_name (char *file);
static int max_backup_version (char *file, char *dir);
static char *make_version_name (char *file, int version);
static int version_number (char *base, char *backup, int base_length);
static char *dirname (char *path);
static char *basename (char *name);
static char *concat (char *str1, char *str2);
static char *copystring (char *str);
static char *chop_filename (char *path, int n);
#endif /* MSDOS */

/* Which type of backup file names are generated. */
enum backup_type backup_type = none;

/* The extension added to file names to produce a simple (as opposed
   to numbered) backup file name. */
char *simple_backup_suffix = "~";

static char *basename ();
static char *concat ();
static char *copystring ();
static char *dirname ();
char *find_backup_file_name ();
static char *make_version_name ();
static int max_backup_version ();
static int version_number ();

/* Return the name of the new backup file for file FILE,
   allocated with malloc.  Return 0 if out of memory.
   FILE must not end with a '/' unless it is the root directory.
   Do not call this function if backup_type == none. */

char *
find_backup_file_name (file)
     char *file;
{
  char *dir;
  char *base_versions;
  int highest_backup;

  if (backup_type == simple)
    return concat (file, simple_backup_suffix);
  base_versions = concat (basename (file), ".~");
  if (base_versions == 0)
    return 0;
  dir = dirname (file);
  if (dir == 0)
    {
      free (base_versions);
      return 0;
    }
  highest_backup = max_backup_version (base_versions, dir);
  free (base_versions);
  free (dir);
  if (backup_type == numbered_existing && highest_backup == 0)
    return concat (file, simple_backup_suffix);
  return make_version_name (file, highest_backup + 1);
}

/* Return the number of the highest-numbered backup file for file
   FILE in directory DIR.  If there are no numbered backups
   of FILE in DIR, return 0.
   FILE should already have ".~" appended to it. */

static int
max_backup_version (file, dir)
     char *file, *dir;
{
  DIR *dirp;
  struct direct *dp;
  int highest_version;
  int this_version;
  int file_name_length;
  
  dirp = opendir (dir);
  if (!dirp)
    return 0;
  
  highest_version = 0;
  file_name_length = strlen (file);

  while ((dp = readdir (dirp)) != 0)
    {
#ifdef MSDOS
      if (NLENGTH (dp) <= file_name_length)
#else /* not MSDOS */
      if (dp->d_ino == 0 || NLENGTH (dp) <= file_name_length)
#endif /* not MSDOS */
	continue;
      
      this_version = version_number (file, dp->d_name, file_name_length);
      if (this_version > highest_version)
	highest_version = this_version;
    }
  closedir (dirp);
  return highest_version;
}

#ifdef MSDOS
static char suffix[5];
#endif /* not MSDOS */

/* Return a string, allocated with malloc, containing
   "FILE.~VERSION~".  Return 0 if out of memory. */

static char *
make_version_name (file, version)
     char *file;
     int version;
{
#ifdef MSDOS
  sprintf (suffix, ".~%.1d~", version);
  return concat (file, suffix);
#else /* not MSDOS */
  char *backup_name;

  backup_name = malloc (strlen (file) + 16);
  if (backup_name == 0)
    return 0;
  sprintf (backup_name, "%s.~%d~", file, version);
  return backup_name;
#endif /* not MSDOS */
}

/* If BACKUP is a numbered backup of BASE, return its version number;
   otherwise return 0.  BASE_LENGTH is the length of BASE.
   BASE should already have ".~" appended to it. */

static int
version_number (base, backup, base_length)
     char *base;
     char *backup;
     int base_length;
{
  int version;
  char *p;

  version = 0;
  if (!strncmp (base, backup, base_length) && ISDIGIT (backup[base_length]))
    {
      for (p = &backup[base_length]; ISDIGIT (*p); ++p)
	version = version * 10 + *p - '0';
#ifdef MSDOS
      if (*p && *p != '~')
#else /* not MSDOS */
      if (p[0] != '~' || p[1])
#endif /* not MSDOS */
	version = 0;
    }
  return version;
}

/* Return the leading directories part of PATH,
   allocated with malloc.  If out of memory, return 0. */

static char *
dirname (path)
     char *path;
{
  char *newpath;
  char *slash;

  slash = rindex (path, '/');
  if (slash == 0)
    return copystring (".");

  newpath = malloc (strlen (path) + 1);
  if (newpath == 0)
    return 0;
  strcpy (newpath, path);
  slash += newpath - path;
  /* Remove any trailing slashes and final element. */
  while (slash > newpath && *slash == '/')
    --slash;
  slash[1] = 0;
  return newpath;
}

/* Return NAME with any leading path stripped off.  */

static char *
basename (name)
     char *name;
{
  char *base;

  base = rindex (name, '/');
  return base ? base + 1 : name;
}

/* Return the newly-allocated concatenation of STR1 and STR2.
   If out of memory, return 0. */

static char *
concat (str1, str2)
     char *str1, *str2;
{
  char *newstr;
  char str1_length = strlen (str1);

#ifdef MSDOS
  /* The MS-DOS version tries to squeeze the given string into a valid
     MS-DOS patch name.  STR1 is chopped and a leading period is removed
     from STR2.  Kludge: a leading period is counted in the length of STR2,
     this is because we will know, that in this case a digit will be appended
     afterwards.  */
  /* chop_filename () might add a '.', so allocate one more byte.  */
  newstr = malloc (str1_length + strlen (str2) + 2);
  if (newstr == 0)
    return 0;
  strcpy (newstr, str1);
  chop_filename (newstr, min (2, strlen(str2)));
  if (*str2 == '.')
    str2++;
  strcat (newstr, str2);
#else /* not MSDOS */
  newstr = malloc (str1_length + strlen (str2) + 1);
  if (newstr == 0)
    return 0;
  strcpy (newstr, str1);
  strcpy (newstr + str1_length, str2);
#endif /* not MSDOS */
  return newstr;
}

/* Return a newly allocated copy of STR. */

static char *
copystring (str)
     char *str;
{
  char *newstr;
  
  newstr = malloc (strlen (str) + 1);
  if (newstr == 0)
    return 0;
  strcpy (newstr, str);
  return newstr;
}


#ifdef MSDOS
/* Shorten a MS-DOS path to accomodate a backup suffix.  */

char *
chop_filename (char *path, int n)
{
  char *base;
  char *suffix;

  base = strrchr (path, '/');
  if (base == (char *)0)
    base = path;
  else
    base++;

  suffix = strchr (base, '.');
  if (suffix == (char *)0)
    strcat (base, ".");		/* is ok, since we have allocated enough! */
  else if (strlen (suffix) >= 4 - n)
    suffix[4-n] = '\0';

  return path;
}
#endif /* MSDOS */



