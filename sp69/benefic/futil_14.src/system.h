/* system-dependent definitions for fileutils programs.
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

/* Include sys/types.h before this file.  */

/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
   This port is also distributed under the terms of the
   GNU General Public License as published by the
   Free Software Foundation.

   Please note that this file is not identical to the
   original GNU release, you should have received this
   code as patch to the official release.

   $Header: e:/gnu/fileutil/RCS/system.h 1.4.0.2 90/09/19 12:27:45 tho Exp $
 */

#include <sys/stat.h>

#ifdef _POSIX_SOURCE
#include <unistd.h>
#include <limits.h>
#else

#ifdef USG
#ifdef MSDOS
#include <time.h>
#else /* not MSDOS */
#include <sys/times.h>
#endif /* not MSDOS */
#else
#include <sys/time.h>
#endif

#ifndef MSDOS
#include <sys/param.h>
#endif /* not MSDOS */
#define _POSIX_PATH_MAX 255
#define _POSIX_NAME_MAX 14

#ifndef PATH_MAX
#ifdef MAXPATHLEN
#define PATH_MAX MAXPATHLEN
#else
#define PATH_MAX _POSIX_PATH_MAX
#endif
#endif

#ifndef NAME_MAX
#ifdef MAXNAMLEN
#define NAME_MAX MAXNAMLEN
#else
#define NAME_MAX _POSIX_NAME_MAX
#endif
#endif

#endif

/* Filesystem device blocksize. */
#ifndef DEV_BSIZE
#ifdef BSIZE
#define DEV_BSIZE BSIZE
#else
#define DEV_BSIZE 512
#endif
#endif

#ifdef _POSIX_SOURCE
#define major(dev)  (((dev) >> 8) & 0xff)
#define minor(dev)  ((dev) & 0xff)
#define makedev(maj, min)  (((maj) << 8) | (min))
#else
#ifdef USG
#ifdef MSDOS
#define major(dev)  (((dev) >> 8) & 0xff)
#define minor(dev)  ((dev) & 0xff)
#else /* not MSDOS */
#include <sys/sysmacros.h>
#endif /* not MSDOS */
#endif
#endif

#ifdef _POSIX_SOURCE
#include <utime.h>
#else
struct utimbuf
{
  long actime;
  long modtime;
};
#ifdef MSDOS
int utime(char *, struct utimbuf *);
#endif /* MSDOS */
#endif

#if defined(USG) || defined(STDC_HEADERS)
#include <string.h>
#define index strchr
#define rindex strrchr
#define bcopy(from, to, len) memcpy ((to), (from), (len))
#define bzero(s, n) memset ((s), 0, (n))
#endif

#if defined(USG) || defined(_POSIX_SOURCE)
#ifndef _POSIX_SOURCE
/* Args for access. */
#define F_OK 0
#define X_OK 1
#define W_OK 2
#define R_OK 4

char *getcwd ();
#endif
#define getwd(buf) getcwd ((buf), PATH_MAX + 2)

/* Args for lseek. */
#define L_SET 0
#define L_INCR 1
#define L_XTND 2
#else
#include <strings.h>
#include <sys/file.h>

char *getwd ();
#endif

#include <fcntl.h>

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


#ifdef MSDOS

#define ST_BLKSIZE(statbuf) BLKSIZE
#define ST_NBLOCKS(statbuf) (((statbuf).st_size + DEV_BSIZE - 1) / DEV_BSIZE)

#else /* not MSDOS */

/* Extract data from a `struct stat'.
   ST_BLKSIZE: Optimal I/O blocksize for the file.
   ST_NBLOCKS: Number of blocks in the file (including indirect blocks). */
#ifdef _POSIX_SOURCE
#define ST_BLKSIZE(statbuf) DEV_BSIZE
#define ST_NBLOCKS(statbuf) (((statbuf).st_size + DEV_BSIZE - 1) / DEV_BSIZE)
#else
#ifdef STBLOCKS_MISSING
#define ST_BLKSIZE(statbuf) DEV_BSIZE
#define ST_NBLOCKS(statbuf) (st_blocks ((statbuf).st_size))
#else
/* Some systems, like Sequents, return st_blksize of 0 on pipes. */
#define ST_BLKSIZE(statbuf) ((statbuf).st_blksize > 0 \
			     ? (statbuf).st_blksize : DEV_BSIZE)
#define ST_NBLOCKS(statbuf) ((statbuf).st_blocks)
#endif
#endif

#endif /* not MSDOS */

/* Convert B blocks of DEV_BSIZE bytes
   to kilobytes if K is nonzero, otherwise to blocks of 512 bytes. */

#if DEV_BSIZE == 512
#define convert_blocks(b, k) ((k) ? ((b) + 1) / 2 : (b))
#else
#if DEV_BSIZE == 1024
#define convert_blocks(b, k) ((k) ? (b) : (b) * 2)
#else
#define convert_blocks(b, k) ((k) \
			      ? ((b) * DEV_BSIZE + 1023) / 1024 \
			      : ((b) * DEV_BSIZE + 511) / 512)
#endif
#endif

#ifndef S_IFLNK
#define lstat stat
#endif

#ifndef SIGTYPE
#define SIGTYPE void
#endif

#ifdef __GNUC__
#define alloca __builtin_alloca
#else
#ifdef sparc
#include <alloca.h>
#else
#ifdef MSDOS
#include <malloc.h>
#else
char *alloca ();
#endif
#endif
#endif
