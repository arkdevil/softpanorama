/*-----------------------------------------------------------------------*
 * filename - dirent.c
 *
 * functions:
 *        opendir       - opens a directory stream
 *        readdir       - read entry from directory stream
 *        rewinddir     - position directory stream at first entry
 *        closedir      - close directory stream
 *-----------------------------------------------------------------------*/

/*
 *      C/C++ Run Time Library - Version 6.0
 *
 *      Copyright (c) 1991, 1993 by Borland International
 *      All Rights Reserved.
 *
 * Modification History:
 *  V1.0  15-Feb-94  Borland    Original version.
 *  V1.1  22-Jun-94  J Mathews  Support VMS, non-Borland compilers,
 *				and older Turbo C compilers;
 *				Set d_namlen in readdir().
 */

#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include "dirent.h"

#define DIRMAGIC 0xdd

#if defined(MSDOS)
#  ifdef __TURBOC__
#    define FATTR		FA_HIDDEN|FA_SYSTEM|FA_RDONLY|FA_DIREC
#    define FFIRST(n,d,a)	findfirst(n,(struct ffblk*)d,a)
#    define FNEXT(d)		findnext((struct ffblk*)d)
#    define FNAME		ff_name
#  else /* !__TURBOC__ */
#    define FATTR		_A_HIDDEN|_A_SYSTEM|_A_RDONLY|_A_SUBDIR
#    define FFIRST(n,d,a)	_dos_findfirst(n,a,(struct find_t*)d)
#    define FNEXT(d)		_dos_findnext((struct find_t*)d)
#    define FNAME		name
#  endif /* ?__TURBOC__ */
#endif /* ?MSDOS */

#if defined(MSDOS)

DIR *  opendir(const char *dirname)
{
    char *name;
    DIR *dir;
    int len;

    /* Allocate space for a copy of the directory name, plus
     * room for the "*.*" we will concatenate to the end.
     */
    len = strlen(dirname);
    if ((name = malloc(len+5)) == NULL)
        {
            errno = ENOMEM;
            return (NULL);
        }
    strcpy(name,dirname);
    if (len-- && name[len] != ':' && name[len] != '\\' && name[len] != '/')
            strcat(name,"\\*.*");
    else
            strcat(name,"*.*");

    /* Allocate space for a DIR structure.
     */
    if ((dir = malloc(sizeof(DIR))) == NULL)
        {
            errno = ENOMEM;
            free(name);
            return (NULL);
        }

    /* Search for the first file to see if the directory exists,
     * and to set up the DTA for future _dos_findnext() calls.
     */
    if (FFIRST(name, &dir->_d_reserved, FATTR) != 0)
        {
            free(name);
            free(dir);
            return (NULL);              /* findfirst sets errno for us */
        }

    /* Everything is OK.  Save information in the DIR structure, return it.
     */
    dir->_d_dirname = name;
    dir->_d_first = 1;
    dir->_d_magic = DIRMAGIC;
    return dir;
}

void  rewinddir(DIR *dir)
{
    /* Verify the handle.
     */
    if (dir->_d_magic != DIRMAGIC)
            return;

    /* Search for the first file and set up the DTA for future
     * findnext() calls.
     */
    FFIRST(dir->_d_dirname, &dir->_d_reserved, FATTR);
    dir->_d_first = 1;
}

struct dirent *  readdir(DIR *dir)
{
    /* Verify the handle.
     */
    if (dir->_d_magic != DIRMAGIC)
        {
            errno = EBADF;
            return (NULL);
        }

    /* If this isn't the first file, call findnext() to get the next
     * directory entry.  Opendir() fetches the first one.
     */
    if (!dir->_d_first)
        {
            if (FNEXT(&dir->_d_reserved) != 0)
                return (NULL);
	}
    dir->_d_dirent.d_namlen = strlen(dir->_d_dirent.d_name);
    dir->_d_first = 0;
    return &dir->_d_dirent;
}

#elif defined(VMS)

DIR *  opendir(const char *dirname)
{
    char *name;
    DIR *dir;
    int len;
    char *s;

    /* Allocate space for a copy of the directory name, plus
     * room for the "*.*" we will concatenate to the end.
     */
    len = strlen(dirname);
    if ((name = malloc(len+4)) == NULL)
        {
            errno = ENOMEM;
            return (NULL);
        }
    strcpy(name,dirname);
    strcpy(name+len, "*.*");

    /* Allocate space for a DIR structure.
     */
    if ((dir = malloc(sizeof(DIR))) == NULL)
        {
            errno = ENOMEM;
            free(name);
            return (NULL);
        }

    dir->_d_fab = cc$rms_fab;
    dir->_d_fab.fab$l_dna = name;
    dir->_d_fab.fab$b_dns = len + 3;
    dir->_d_fab.fab$l_nam = &dir->_d_nam;
    dir->_d_nam = cc$rms_nam;
    dir->_d_nam.nam$l_esa = dir->_d_esa;
    dir->_d_nam.nam$b_ess = MAXNAMLEN;
    dir->_d_nam.nam$l_rsa = dir->_d_rsa;
    dir->_d_nam.nam$b_rss = MAXNAMLEN;

    /* Parse the directory to see if the directory exists,
     * and to set up the FAB for readdir() calls.
     */
    if (SYS$PARSE(&dir->_d_fab, 0, 0) != RMS$_NORMAL)
	{
            free(name);
            free(dir);
	    errno = ENOENT;		/* No file found */
	    return (NULL);
	}

    /* Everything is OK.  Save information in the DIR structure, return it.
     */
    dir->_d_dirname = name;
    dir->_d_magic = DIRMAGIC;
    return dir;
}

struct dirent *  readdir(DIR *dir)
{
    char* s;
    /* Verify the handle.
     */
    if (dir->_d_magic != DIRMAGIC)
        {
            errno = EBADF;
            return (NULL);
        }

    /* Search the directory for the next directory entry.
     */
    if (SYS$SEARCH(&dir->_d_fab, 0, 0) != RMS$_NORMAL)
	{
	    return NULL;
	}

    /* Everything is OK.  Save filename information and return it.
     */
    dir->_d_rsa[dir->_d_nam.nam$b_rsl] = '\0';
    s = strchr(dir->_d_rsa, DIR_END);
    /* The directory name located in the filename is stripped with
     * respect to readdir().
     */
    if (s != NULL) {
	dir->_d_dirent.d_name   = ++s;  /* point to the filename */
	dir->_d_dirent.d_namlen = dir->_d_nam.nam$b_rsl - (s - dir->_d_rsa);
    }
    else {
	dir->_d_dirent.d_name   = dir->_d_rsa;
	dir->_d_dirent.d_namlen = dir->_d_nam.nam$b_rsl;
    }

    return &dir->_d_dirent;
}

void  rewinddir(DIR *dir)
{
    /* Verify the handle.
     */
    if (dir->_d_magic == DIRMAGIC)
	{
	    SYS$PARSE(&dir->_d_fab, 0, 0);
	}
}

#endif /* ?MSDOS */

#if defined(MSDOS) || defined(VMS)

int  closedir(DIR* dir)
{
    /* Verify the handle.
     */
    if (dir == NULL || dir->_d_magic != DIRMAGIC)
        {
            errno = EBADF;
            return (-1);
        }
    dir->_d_magic = 0;          /* prevent use after closing */

    free(dir->_d_dirname);
    free(dir);
    return 0;
}

#endif /* ?MSDOS|VMS */
