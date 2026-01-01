/*  cp.h  -- file copying (data definitions)
    Copyright (C) 1989, 1990 Free Software Foundation.

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
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

    Written by Torbjorn Granlund, Sweden (tege@sics.se). */

/*  MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
    This port is also distributed under the terms of the
    GNU General Public License as published by the
    Free Software Foundation.

    Please note that this file is not identical to the
    original GNU release, you should have received this
    code as patch to the official release.

    $Header: e:/gnu/fileutil/RCS/cp.h 1.4.0.2 90/09/19 12:27:43 tho Exp $
 */

#include <sys/types.h>

#include "system.h"

struct dir_list
{
  struct dir_list *parent;
  ino_t ino;
  dev_t dev;
};

struct entry
{
  ino_t ino;
  dev_t dev;
  char *node;			/* Path name, or &new_file for new inodes.  */
  struct entry *coll_link;	/* 0 = entry not occupied.  */
};

struct htab
{
  unsigned modulus;		/* Size of the `hash' pointer vector.  */
  struct entry *entry_tab;	/* Pointer to dynamically growing vector.  */
  unsigned entry_tab_size;	/* Size of current `entry_tab' allocation.  */
  unsigned first_free_entry;	/* Index in `entry_tab'.  */
  struct entry *hash[1];	/* Vector of pointers in `entry_tab'.  */
};

extern int exit_status;
extern struct htab *htab;

#ifdef MSDOS

#include <gnulib.h>

extern void forget_all (void);
extern int copy_reg (char *, char *);
extern void hash_init (unsigned int, unsigned int);
extern int remember_created (char *);
extern char *remember_copied (char *, unsigned short, short);

#else /* not MSDOS */

extern char *xmalloc ();
extern char *xrealloc ();
extern void forget_copied ();
extern void forget_all ();
extern int copy_reg ();
extern void hash_init ();
extern char *remember_copied ();
extern int remember_created ();

#endif /* not MSDOS */

/* For created inodes, a pointer in the search structure to this
   character identifies that the inode as new.  */
extern char new_file;

#ifdef MSDOS
extern  void main (int, char **);
extern  void usage (char *);
extern  void error (int status, int errnum, char *message, ...);
extern  int yesno (void);
extern  char *stpcpy (char *, char *);
extern  int user_confirm_overwriting (char *);
extern  int member (int);
extern  int do_copy (int, char **);
extern  int copy (char *, char *, int, short, struct dir_list *);
extern  int copy_dir(char *,char *,int,struct stat *,struct dir_list *);
extern  void strip_trailing_slashes (char **path);
#endif /* MSDOS */

extern void error ();
extern void usage ();
extern char *savedir ();
extern char *stpcpy ();
extern int yesno ();
extern int do_copy ();
extern int copy ();
extern int copy_dir ();
extern void strip_trailing_slashes ();
extern int is_ancestor ();

/* System calls.  */

#ifdef MSDOS

#include <direct.h>
#include <io.h>
#include <malloc.h>
#include <pwd.h>

/* Very "interesting" system calls ... */
#define	link(a, b)			(-1)
#define chown(path, uid, gid)		0
#define mkdir(path, mode)		mkdir (path)
#define ftruncate			chsize

extern  int eaccess_stat (struct stat *statp, int mode);

#else /* not MSDOS */

extern int mknod ();

#ifdef _POSIX_SOURCE
#define S_IWRITE S_IWUSR
#define S_IEXEC S_IXUSR
#else
extern int open ();
extern int close ();
extern int fstat ();
extern int stat ();
extern int lstat ();
extern int read ();
extern int write ();
extern int symlink ();
extern int readlink ();
extern int mkdir ();
extern unsigned short umask ();
extern int unlink ();
extern int link ();
extern int chmod ();
extern int chown ();
extern int access ();
extern int utime ();
extern int ftruncate ();
extern int isatty ();
extern off_t lseek ();
#endif

#endif /* not MSDOS */

/* Library calls.  */
#include <errno.h>
#ifdef STDC_HEADERS
#include <stdlib.h>
#else
extern char *getenv ();
extern char *malloc ();
extern char *realloc ();
extern void exit ();
extern void free ();
extern int fputs ();

extern int errno;
#endif
