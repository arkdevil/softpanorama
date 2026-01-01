/* listfile.c -- display a long listing of a file
   Copyright (C) 1985, 1988, 1989, 1990 Free Software Foundation, Inc.

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
   code as patch to the official release.

   $Header: e:/gnu/find/RCS/listfile.c 1.2.0.3 90/09/23 16:09:41 tho Exp $
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#ifndef MSDOS
struct passwd *getpwuid ();
#include <grp.h>
struct group *getgrgid ();
#include <time.h>
#endif /* not MSDOS */
#ifdef USG
#ifdef MSDOS
#define minor(n) (n)
#define major(n) (n)
#else /* not MSDOS */
#include <sys/sysmacros.h>
#endif /* not MSDOS */
#include <string.h>
#else
#include <strings.h>
#endif

#ifdef MSDOS
#include <time.h>

extern void list_file (char *name, struct stat *statp);
extern char *xmalloc (unsigned n);
extern void mode_string (unsigned short mode, char *str);
extern char *copystring (char *string);
extern void print_name_with_quoting (char *p);
extern char *getuser (int uid);
extern char *getgroup (int gid);
#endif /* MSDOS */

extern int errno;

long time ();
void free ();

char *xmalloc ();
void error ();
void mode_string ();

char *copystring ();
char *get_link_name ();
char *getgroup ();
char *getuser ();
void print_name_with_quoting ();

void
list_file (name, statp)
     char *name;
     struct stat *statp;
{
  char modebuf[20];
  char timebuf[40];
  long current_time = time ((time_t *) 0);

  mode_string (statp->st_mode, modebuf);
  modebuf[10] = '\0';

  strcpy (timebuf, ctime (&statp->st_mtime));
  if (current_time - statp->st_mtime > 6L * 30L * 24L * 60L * 60L
      || current_time - statp->st_mtime < 0L)
    {
      /* The file is fairly old or in the future.
	 POSIX says the cutoff is 6 months old;
	 approximate this by 6*30 days.
	 Show the year instead of the time of day.  */
      strcpy (timebuf + 11, timebuf + 19);
    }
  timebuf[16] = 0;

#ifdef MSDOS			/* poor MS-DOS has no inodes, links, etc. . */

  printf ("%s ", modebuf);

  if ((statp->st_mode & S_IFMT) == S_IFCHR)
    printf ("%3u, %3u ", major (statp->st_rdev), minor (statp->st_rdev));
  else
    printf ("%8lu ", statp->st_size);

#else /* not MSDOS */

  printf ("%6u ", statp->st_ino);

  /* The space between the mode and the number of links is the POSIX
     "optional alternate access method flag". */
  printf ("%s %3u ", modebuf, statp->st_nlink);

  printf ("%-8.8s ", getuser (statp->st_uid));

  printf ("%-8.8s ", getgroup (statp->st_gid));

  if ((statp->st_mode & S_IFMT) == S_IFCHR
      || (statp->st_mode & S_IFMT) == S_IFBLK)
    printf ("%3u, %3u ", major (statp->st_rdev), minor (statp->st_rdev));
  else
    printf ("%8lu ", statp->st_size);

#endif /* MSDOS */

  printf ("%s ", timebuf + 4);

  print_name_with_quoting (name);

#ifdef S_IFLNK
  if ((statp->st_mode & S_IFMT) == S_IFLNK)
    {
      char *linkname = get_link_name (name, statp);

      if (linkname)
	{
	  fputs (" -> ", stdout);
	  print_name_with_quoting (linkname);
	  free (linkname);
	}
    }
#endif
  putchar ('\n');
}

void
print_name_with_quoting (p)
     register char *p;
{
  register unsigned char c;

  while (c = *p++)
    {
      switch (c)
	{
	case '\\':
	  printf ("\\\\");
	  break;

	case '\n':
	  printf ("\\n");
	  break;

	case '\b':
	  printf ("\\b");
	  break;

	case '\r':
	  printf ("\\r");
	  break;

	case '\t':
	  printf ("\\t");
	  break;

	case '\f':
	  printf ("\\f");
	  break;

	case ' ':
	  printf ("\\ ");
	  break;

	case '"':
	  printf ("\\\"");
	  break;

	default:
	  if (c > 040 && c < 0177)
	    putchar (c);
	  else
	    printf ("\\%03o", (unsigned int) c);
	}
    }
}

#ifdef S_IFLNK
char *
get_link_name (filename, statp)
     char *filename;
     struct stat *statp;
{
  register char *linkbuf;
  register int bufsiz = statp->st_size;

  linkbuf = (char *) xmalloc (bufsiz + 1);
  linkbuf[bufsiz] = 0;
  if (readlink (filename, linkbuf, bufsiz) < 0)
    {
      error (0, errno, "%s", filename);
      free (linkbuf);
      return 0;
    }
  return linkbuf;
}
#endif

struct userid
{
  int uid;
  char *name;
  struct userid *next;
};

struct userid *user_alist;

/* Translate `uid' to a login name, with cache.  */

char *
getuser (uid)
     int uid;
{
  register struct userid *tail;
  struct passwd *pwent;
  char usernum_string[20];

  for (tail = user_alist; tail; tail = tail->next)
    if (tail->uid == uid)
      return tail->name;

  pwent = getpwuid (uid);
  tail = (struct userid *) xmalloc (sizeof (struct userid));
  tail->uid = uid;
  tail->next = user_alist;
  if (pwent == 0)
    {
      sprintf (usernum_string, "%u", uid);
      tail->name = copystring (usernum_string);
    }
  else
    tail->name = copystring (pwent->pw_name);
  user_alist = tail;
  return tail->name;
}

/* We use the same struct as for userids.  */
struct userid *group_alist;

/* Translate `gid' to a group name, with cache.  */

char *
getgroup (gid)
     int gid;
{
  register struct userid *tail;
  struct group *grent;
  char groupnum_string[20];

  for (tail = group_alist; tail; tail = tail->next)
    if (tail->uid == gid)
      return tail->name;

  grent = getgrgid (gid);
  tail = (struct userid *) xmalloc (sizeof (struct userid));
  tail->uid = gid;
  tail->next = group_alist;
  if (grent == 0)
    {
      sprintf (groupnum_string, "%u", gid);
      tail->name = copystring (groupnum_string);
    }
  else
    tail->name = copystring (grent->gr_name);
  group_alist = tail;
  return tail->name;
}

/* Return a newly allocated copy of `string'. */

char *
copystring (string)
     char *string;
{
  return strcpy ((char *) xmalloc (strlen (string) + 1), string);
}
