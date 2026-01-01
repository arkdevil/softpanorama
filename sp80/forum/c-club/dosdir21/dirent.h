/*  dirent.h

    Definitions for POSIX directory operations.

*/

/*
 *      C/C++ Run Time Library - Version 6.0
 *
 *      Copyright (c) 1991, 1993 by Borland International
 *      All Rights Reserved.
 *
 * Modification History:
 *  15-Feb-94  Borland    Original version.
 *  22-Jun-94  J Mathews  Support VMS, non-Borland compilers,
 *			  and older Turbo C compilers;
 *			  Added d_namlen member to struct dirent.
 */

#ifndef __DIRENT_H
#define __DIRENT_H

/* Set up portability */
#include "tailor.h"

#if defined(MSDOS)
#  define DIR_CUR "."
#  define DIR_PARENT ".."
#  define DIR_END '\\'
#  include <dos.h>
#  if (defined(__GO32__) || defined(__EMX__))
#    include <dirent.h>        /* use readdir() */
#    ifdef __EMX__
#      define GETDRIVE(d)	d = _getdrive()
#      define SETDRIVE(d,n)	_setdrive(d, n)
#    else
#      define GETDRIVE(d)	_dos_getdrive(&d)
#      define SETDRIVE(d,n)	_dos_setdrive(d, n)
#    endif
#  else /* !(__GO32__ || __EMX__) */
#    define DEFINE_DIRENT
#    ifdef __TURBOC__
#      include <dir.h>
#      define GETDRIVE(d)	d=getdisk()
#      define SETDRIVE(d,n)	setdisk(d)
#    else
#      include <direct.h>
#      define GETDRIVE(d)	_dos_getdrive(&d)
#      define SETDRIVE(d,n)	_dos_setdrive(d, n)
#    endif
#  endif /* __GO32__ || __EMX__ */
#elif defined(VMS)
#  define DEFINE_DIRENT
#  define DIR_CUR	"[]"
#  define DIR_PARENT	"[-]"
#  define DIR_END	']'
#  include <rms.h>
#else /* ?unix */
#  define DIR_CUR	"."
#  define DIR_PARENT	".."
#  define DIR_END	'/'
#  include <dirent.h>
#endif

#if defined(VMS)
#  define MAXNAMLEN	NAM$C_MAXRSS
#  define MAXPATH	NAM$C_MAXRSS
#elif defined(MSDOS)
#  if defined(__OS2__)
#    define MAXNAMLEN	256
#  elif defined(__WIN32__) || defined(__DPMI32__)
#    define MAXNAMLEN	260
#  else
#    define MAXNAMLEN	13
#  endif /* ?MSDOS */
#  ifdef __FLAT__
#    define MAXPATH	260
#  else
#    define MAXPATH	80
#  endif /* ?__FLAT__ */
#else /* ?unix */
#  ifndef MAXPATH
#    define MAXPATH	255
#  endif
#  ifndef MAXNAMLEN
#    define MAXNAMLEN	255
#  endif
#endif /* ?VMS */

#ifdef DEFINE_DIRENT /* do we need to define dirent structures/functions? */

/* dirent structure returned by readdir().  The first member (d_name)
 * cannot be moved, because it is part of the DOS DTA structure used by
 * findfirst() and findnext().
 */
struct dirent
{
#ifdef MSDOS
    char           d_name[MAXNAMLEN];
#else /* ?VMS */
    char*          d_name;
#endif
    unsigned short d_namlen;
};

#if defined(VMS)

/* DIR type returned by opendir().  The members of this structure
 * must not be accessed by application programs.
 */
typedef struct {
    struct FAB	   _d_fab;		/* file access block */
    struct NAM	   _d_nam;		/* name block */
    char	   _d_esa[MAXNAMLEN];	/* extended string area */
    char	   _d_rsa[MAXNAMLEN];	/* resultant string area */
    struct dirent  _d_dirent;		/* filename part of DTA */
    char          *_d_dirname;		/* directory name */
    unsigned char  _d_magic;		/* magic cookie for verifying handle */
} DIR;

#elif defined(MSDOS)

/* DIR type returned by opendir().  The first two members cannot
 * be separated, because they make up the DOS DTA structure used
 * by findfirst() and findnext().
 */
typedef struct
{
    char           _d_reserved[30];	/* reserved part of DTA */
    struct dirent  _d_dirent;		/* filename part of DTA */
    char          *_d_dirname;		/* directory name */
    char           _d_first;		/* first file flag */
    unsigned char  _d_magic;		/* magic cookie for verifying handle */
} DIR;

#endif  /* ?VMS */

#ifdef __cplusplus
extern "C" {
#endif

/* Prototypes.
 */
DIR                 * opendir   OF((const char *dirname));
struct dirent       * readdir   OF((DIR *dir));
int                   closedir  OF((DIR *dir));
void                  rewinddir OF((DIR *dir));

#ifdef __cplusplus
}
#endif

#endif /* DEFINE_DIRENT */

#endif  /* __DIRENT_H */
