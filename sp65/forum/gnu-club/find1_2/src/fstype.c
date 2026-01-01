/* fstype.c -- determine type of filesystems that files are on
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

/* Written by David MacKenzie (djm@ai.mit.edu). */

#ifndef MNTENT_MISSING
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <mntent.h>

#if !defined(MOUNTED) && defined(MNT_MNTTAB)
#define MOUNTED MNT_MNTTAB
#endif

char *strcpy ();

int xatoi ();
char *dupstr ();
char *strstr ();
char *xmalloc ();

extern int errno;

/* Structure for holding a mount table entry. */

struct mount_entry
{
  char *me_dir;
  char *me_type;
  dev_t me_dev;
  struct mount_entry *me_next;
};

/* Linked list of mounted filesystems. */
static struct mount_entry *mount_list;
#endif

/* Read the list of currently mounted filesystems into `mount_list'.
   Add each entry to the tail of the list so that they stay in order.  */

void
read_mtab ()
{
#ifndef MNTENT_MISSING
  char *table = MOUNTED;	/* /etc/mtab, usually. */
  char *cp;
  FILE *mfp;
  struct mntent *mnt;
  struct mount_entry *me;
  struct mount_entry *mtail;

  /* Start the list off with a dummy entry. */
  me = (struct mount_entry *) xmalloc (sizeof (struct mount_entry));
  me->me_next = NULL;
  mount_list = mtail = me;

  mfp = setmntent (table, "r");
  if (mfp == NULL)
    error (1, errno, "%s", table);

  while ((mnt = getmntent (mfp)))
    {
      me = (struct mount_entry *) xmalloc (sizeof (struct mount_entry));
      me->me_dir = dupstr (mnt->mnt_dir);
      me->me_type = dupstr (mnt->mnt_type);
      cp = strstr (mnt->mnt_opts, "dev=");
      if (cp)
	me->me_dev = xatoi (cp + 4);
      else
	me->me_dev = -1;	/* Magic; means not known yet. */
      me->me_next = NULL;

      /* Add to the linked list. */
      mtail->me_next = me;
      mtail = me;
    }

  if (endmntent (mfp) == 0)
    error (0, errno, "error closing %s", table);

  /* Free the dummy head. */
  me = mount_list;
  mount_list = mount_list->me_next;
  free (me);
#endif
}

/* Return the type of filesystem that the file described by STATP
   is on.  Return NULL if its filesystem type is unknown. */

char *
filesystem_type (statp)
     struct stat *statp;
{
#ifndef MNTENT_MISSING
  struct stat disk_stats;
  struct mount_entry *me;

  for (me = mount_list; me; me = me->me_next)
    {
      if (me->me_dev == -1)
	{
	  if (stat (me->me_dir, &disk_stats) == 0)
	    me->me_dev = disk_stats.st_dev;
	  else
	    {
	      error (0, errno, "%s", me->me_dir);
	      me->me_dev = -2;	/* So we won't try and fail repeatedly. */
	    }
	}
      if (statp->st_dev == me->me_dev)
	return me->me_type;
    }
#endif
  return 0;
}

#ifndef MNTENT_MISSING
/* Return the value of the hexadecimal number represented by CP.
   No prefix (like '0x') or suffix (like 'h') is expected to be
   part of CP. */

int
xatoi (cp)
     char *cp;
{
  int val;
  
  val = 0;
  while (*cp)
    {
      if (*cp >= 'a' && *cp <= 'f')
	val = val * 16 + *cp - 'a' + 10;
      else if (*cp >= 'A' && *cp <= 'F')
	val = val * 16 + *cp - 'A' + 10;
      else if (*cp >= '0' && *cp <= '9')
	val = val * 16 + *cp - '0';
      else
	break;
      cp++;
    }
  return val;
}

char *
dupstr (s)
     char *s;
{
  return strcpy (xmalloc (strlen (s) + 1), s);
}

/* Return address of the first substring SUBSTR in string STRING,
   or NULL if there is none. */

char *
strstr (string, substr)
     char *string, *substr;
{
  int length;

  length = strlen (substr);
  for (; *string; ++string)
    if (!strncmp (string, substr, length))
      return string;
  return NULL;
}
#endif
