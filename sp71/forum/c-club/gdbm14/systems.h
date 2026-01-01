/* systems.h - Most of the system dependant code and defines are here. */

/*  This file is part of GDBM, the GNU data base manager, by Philip A. Nelson.
    Copyright (C) 1990  Free Software Foundation, Inc.

    GDBM is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 1, or (at your option)
    any later version.

    GDBM is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with GDBM; see the file COPYING.  If not, write to
    the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

    You may contact the author by:
       e-mail:  phil@wwu.edu
      us-mail:  Philip A. Nelson
                Computer Science Department
                Western Washington University
                Bellingham, WA 98226
        phone:  (206) 676-3035
       
*************************************************************************/

/*
 * MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
 *
 * To this port, the same copying conditions apply as to the
 * original release.
 *
 * IMPORTANT:
 * This file is not identical to the original GNU release!
 * You should have received this code as patch to the official
 * GNU release.
 *
 * MORE IMPORTANT:
 * This port comes with ABSOLUTELY NO WARRANTY.
 *
 * $Header: e:/gnu/gdbm/RCS/systems.h'v 1.4.0.1 90/08/16 09:23:07 tho Exp $
 */

/* To use this file, you must have included <sys/types.h>.  */


/*         System V changes and defines.          */
/**************************************************/

#ifdef SYSV

/* File seeking needs L_SET defined .*/
#ifdef MSDOS
#include <malloc.h>
#include <io.h>
#else /* not MSDOS */
#include <unistd.h>
#endif /* not MSDOS */
#define L_SET SEEK_SET

/* Some files need fcntl.h for locking. */
#include <fcntl.h>
#ifdef MSDOS
#define UNLOCK_FILE(dbf)	/* later !!!  */
#define READLOCK_FILE(dbf)	lock_val = 0;
#define WRITELOCK_FILE(dbf)	lock_val = 0;
#else /* not MSDOS */
#define UNLOCK_FILE(dbf) \
	{					\
	  struct flock flock;			\
	  flock.l_type = F_UNLCK;		\
	  flock.l_whence = 0;			\
	  flock.l_start = flock.l_len = 0L;	\
	  fcntl (dbf->desc, F_SETLK, &flock);	\
	}
#define READLOCK_FILE(dbf) \
	{					\
	  struct flock flock;			\
	  flock.l_type = F_RDLCK;		\
	  flock.l_whence = 0;			\
	  flock.l_start = flock.l_len = 0L;	\
	  lock_val = fcntl (dbf->desc, F_SETLK, &flock);	\
	}
#define WRITELOCK_FILE(dbf) \
	{					\
	  struct flock flock;			\
	  flock.l_type = F_WRLCK;		\
	  flock.l_whence = 0;			\
	  flock.l_start = flock.l_len = 0L;	\
	  lock_val = fcntl (dbf->desc, F_SETLK, &flock);	\
	}
#endif /* not MSDOS */

/* Send bcmp to the right place. */
#include <memory.h>
#define bcmp(d1, d2, n)	memcmp(d1, d2, n)
#define bcopy(d1, d2, n) memcpy(d2, d1, n)

/* Sys V does not have fsync. */
#ifdef MSDOS
#define fsync(f)
#else /* not MSDOS */
#define fsync(f) sync(); sync()
#endif /* not MSDOS */

/* Stat does not have a st_blksize field. */
#define STATBLKSIZE 512

/* Does not have rename(). */
#ifndef MSDOS
#define NEED_RENAME
#endif /* not MSDOS */
#endif

/*      End of System V changes and defines.      */
/**************************************************/


#ifndef MSDOS
/* Alloca is builtin in gcc.  Use the builtin alloca if compiled with gcc. */
#ifdef __GNUC__
#define BUILTIN_ALLOCA
#endif

/* Also, if this is a sun spark, use the builtin alloca. */
#ifdef sun
#ifdef sparc
#define BUILTIN_ALLOCA
#endif
#endif

/* Define the proper alloca procedure. */
#ifdef BUILTIN_ALLOCA
#define alloca(x) __builtin_alloca(x)
#else
extern char *alloca();
#endif

/* Malloc definition. */
extern char *malloc();
#endif /* not MSDOS */


/* The BSD defines are the default defines.  If something is not
   defined above in the above conditional code, it will be set
   in the following code to the BSD code.  */

/* Default block size.  Some systems do not have blocksize in their
   stat record. This code uses the BSD blocksize from stat. */

#ifndef STATBLKSIZE
#define STATBLKSIZE file_stat.st_blksize
#endif


/* Locking is done differently on different systems.  Here is the BSD
   locking routines.  */

#ifndef UNLOCK_FILE
#define UNLOCK_FILE(dbf) flock (dbf->desc, LOCK_UN)
#define READLOCK_FILE(dbf) lock_val = flock (dbf->desc, LOCK_SH + LOCK_NB)
#define WRITELOCK_FILE(dbf) lock_val = flock (dbf->desc, LOCK_EX + LOCK_NB)
#endif
