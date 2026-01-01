/*
 *      C/C++ Run Time Library - Version 5.0
 *
 *      Copyright (c) 1987, 1992 by Borland International
 *      All Rights Reserved.
 *
 * Modification History:
 *  10-Jun-92  Borland    Original version.
 *  17-May-94  J Mathews  Modified for Unix.
 *   8-Jun-94  J Mathews  Added VMS handling,
 *                        Added path expansion for ~ symbol on UNIX.
 */

#include <string.h>
#include "dosdir.h"

#ifdef UNIX
#  include <pwd.h>
#  define DD_MAXUSERNAME 100
#endif

static void CopyIt   OF((char *dst, const char *src, unsigned maxlen));

/*---------------------------------------------------------------------*

Name            CopyIt - copies a string to another

Prototype in    local to this module

*---------------------------------------------------------------------*/
static void CopyIt(dst, src, maxlen)
     char *dst;
     const char *src;
     unsigned maxlen;
{
	if (dst) {
		if (strlen(src) >= maxlen)
		{
			strncpy(dst, src, maxlen);
			dst[maxlen] = 0;
		}
		else
			strcpy(dst, src);
	}
}

#ifndef VMS
static int  DotFound OF((char *pB));

/*---------------------------------------------------------------------*

Name            DotFound - checks for special directory names

Prototype in    local to this module

*---------------------------------------------------------------------*/
static  int DotFound(pB)
     char *pB;
{
	if (*(pB-1) == '.') pB--;
	switch (*--pB) {
#ifdef MSDOS
	case ':'  :
	  if (*(pB-2) != '\0')
	    break;
	case '\\' :
#endif
	case '/'  :
	case '\0' :
	  return 1;
	}
	return 0;
}
#endif /* ?!VMS */

/*---------------------------------------------------------------------*

Name            dd_fnsplit - splits a full path name into its components

Usage           #include <dosdir.h>
		int dd_fnsplit(const char *path, char * drive, char * dir,
			     char * name, char * ext);

Prototype in    dosdir.h

Description     dd_fnsplit takes a file's full path name (path) as a string
		in the form

		/DIR/SUBDIR/FILENAME			(UNIX)
		X:\DIR\SUBDIR\NAME.EXT			(MS-DOS)
		NODE::DEVICE:[PATH]NAME.EXT;VERSION	(VMS)

		and splits path into its four components. It then stores
		those components in the strings pointed to by dir and
		ext.  (Each component is required but can be a NULL,
		which means the corresponding component will be parsed
		but not stored.)

		The maximum sizes for these strings are given by the
		constants MAXDRIVE, MAXDIR, MAXPATH, MAXNAME and MAXEXT,
		(defined in dosdir.h) and each size includes space for
		the null-terminator.

		Constant        String

		DD_MAXPATH         path
		DD_MAXDRIVE        drive; includes colon; not used by UNIX
		DD_MAXDIR          dir; includes leading and trailing
					backslashes for DOS or slashes for UNIX
		DD_MAXFILE         filename
		DD_MAXEXT          ext; includes leading dot (.)
				   (not used by UNIX)

		dd_fnsplit assumes that there is enough space to store each
		non-NULL component. fnmerge assumes that there is enough
		space for the constructed path name. The maximum constructed
		length is DD_MAXPATH.

		When dd_fnsplit splits path, it treats the punctuation as
		follows:

		* drive keeps the colon attached (C:, A:, etc.).
		  It is not applicable to unix file system.

		* dir keeps the leading and trailing slashes
		  (/usr/local/bin/, /src/, etc.)

		* ext keeps the dot preceding the extension (.c, .doc, etc.)
		  It is not applicable to unix file system.

Return value    dd_fnsplit returns an integer (composed of five flags,
		defined in dosdir.h) indicating which of the full path name
		components were present in path; these flags and the components
		they represent are:

			EXTENSION       an extension
			FILENAME        a filename
			DIRECTORY       a directory (and possibly
					sub-directories)
			DRIVE           a drive specification (see dir.h)
			WILDCARDS       wildcards (* or ? cards)

*---------------------------------------------------------------------*/
int dd_fnsplit(pathP, driveP, dirP, nameP, extP)
     const char *pathP;
     char *driveP, *dirP, *nameP, *extP;
{
	register char   *pB;
	register int    Wrk;
	int     Ret;
	char buf[ DD_MAXPATH+2 ];

	/*
	 * Set all string to default value zero
	 */
	Ret = 0;
	if (driveP) *driveP = 0;
	if (dirP) *dirP = 0;
	if (nameP) *nameP = 0;
	if (extP) *extP = 0;

	/*
	 * Copy filename into template up to DD_MAXPATH characters
	 */
	pB = buf;
	while (*pathP == ' ') pathP++;
	if ((Wrk = strlen(pathP)) > DD_MAXPATH)
		Wrk = DD_MAXPATH;
	*pB++ = 0;
	strncpy(pB, pathP, Wrk);
	*(pB += Wrk) = 0;

	/*
	 * Split the filename and fill corresponding nonzero pointers
	 */
	Wrk = 0;
	for (; ; ) {
		switch (*--pB) {
		case '.':
#ifndef VMS
		  if (!Wrk && (*(pB+1) == '\0')) Wrk = DotFound(pB);
#endif
#if (defined(MSDOS) || defined(VMS))
		  if ((!Wrk) && ((Ret & EXTENSION) == 0)) {
		    Ret |= EXTENSION;
		    CopyIt(extP, pB, DD_MAXEXT - 1);
		    *pB = 0;
		  }
#endif
		  continue;
#if defined(MSDOS)
		case ':'  :
		  if (pB != &buf[2])
		    continue;
#elif defined(UNIX)
		case '~' :
		  if (pB != &buf[1])
		    continue;
		  else {
		    /* expand path as appropriate */
		    struct passwd *pw = NULL;
		    char* tail = strchr (pB, '/');
		    int len;
		    if (tail != NULL) {
		      len = tail - (pB+1);
		      if (len > 0) {
			char username[DD_MAXUSERNAME];
			if (len <= DD_MAXUSERNAME)
			  {
			    strncpy(username, pB+1, len);
			    username[len] = 0;
			    pw = getpwnam(username);
			  }
		      }
		      else
			pw = getpwuid (getuid());

		      if (pw != NULL && (len=strlen(pw->pw_dir)) < DD_MAXDIR)
			{
			  strcpy(dirP, pw->pw_dir);
			  dirP += len;
			}
		      else
			strcpy (dirP++, "?");
		      CopyIt(dirP, tail, DD_MAXDIR - len - 1);
		      dirP += strlen(dirP);
		    }
		    else {
		      Wrk = 1;
		      if (pB[1] != 0)
			pw = getpwnam (pB + 1);
		      else
			pw = getpwuid (getuid());

		      if (pw != NULL && (len=strlen(pw->pw_dir)) < DD_MAXDIR)
			{
			  strcpy(dirP, pw->pw_dir);
			  dirP += len;
			}
		      else
			strcpy (dirP++, "?");
		    }
		    *pB-- = 0;
		    Ret |= DIRECTORY;
		  }
#endif /* ?MSDOS */
		case '\0' :
		  if (Wrk) {
		    if (*++pB)
		      Ret |= DIRECTORY;
		    CopyIt(dirP, pB, DD_MAXDIR - 1);
#ifdef MSDOS
		    *pB-- = 0;
#endif
		    break;
		  }
#ifdef MSDOS
		case '\\' :
#endif
#if (defined(MSDOS) || defined(UNIX))
		case '/':
#endif
#ifdef VMS
		case ']' :
		case ':' :
#endif
		  if (!Wrk) {
		    Wrk++;
		    if (*++pB) Ret |= FILENAME;
		    CopyIt(nameP, pB, DD_MAXFILE - 1);
		    *pB-- = 0;
#ifdef MSDOS
		    if (*pB == 0 || (*pB == ':' && pB == &buf[2]))
#else
		    if (*pB == 0)
#endif
			break;
		  }
		  continue;
#ifndef VMS
		case '[' :
#endif
		case '*' :
#ifdef VMS
		case '%' :
#else
		case '?' :
#endif
		  if (!Wrk) Ret |= WILDCARDS;
		  default :
		    continue;
		}
		break;
	      }

#ifdef MSDOS
	if (*pB == ':') {
	  if (buf[1]) Ret |= DRIVE;
	  CopyIt(driveP, &buf[1], DD_MAXDRIVE - 1);
	}
#endif

	return (Ret);
}
