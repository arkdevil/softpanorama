/*
   hlib.c

   Host dependent library routines for UUPC/extended

   Change history:

   08 Sep 90 - Split from local\host.c                            ahd
 */

#include <dos.h>
#include <fcntl.h>
#include <io.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

#include <direct.h>

#include "lib.h"
#include "ndir.h"
#include "hlib.h"
#include "hostable.h"

extern char program[];

currentfile();

/*
   mkfilename - build a path name out of a directory name and a file name
*/

void mkfilename(char *pathname, const char *path, const char *name)
{
	char *lastc = path + strlen(path) - 1;

	if (*lastc != '\\' && *lastc != '/')
		sprintf(pathname, "%s\\%s", path, name);
	else
		sprintf(pathname, "%s%s", path, name);
	strlwr(pathname);
	for (lastc = pathname; *lastc; lastc++)
		if (*lastc == '/')
			*lastc = '\\';
} /*mkfilename*/


/*
   m k t e m p n a m e

   Generate a temporary name with a pre-defined extension
 */

char *mktempname( char *buf, char *extension)
{
   size_t file;
   static char buf2[FILENAME_MAX];
   char *name;
   int f;

   if (buf == NULL)           /* Do we need to allocate buffer?         */
   {
	  buf = malloc(strlen(tempdir) + 14 );
	  checkref(buf);
   } /* if */

   name = program;
   if (strnicmp(name, "uu", 2) == 0)
	  name += 2;

   for (file = 1; file < INT_MAX; file++)
   {
	  sprintf(buf2, "%.4s%04.4X.%s", name, file, extension);
	  mkfilename(buf, tempdir, buf2);
	  if ((f = open(buf, O_RDONLY)) < 0)
		break;
	  close(f);
   } /* for */

   if ( file >= INT_MAX )
	panic();
   printmsg(5,"Generated temporary name: %s",buf);
   return buf;

} /* mktempname */

void cleantmp(void)
{
	DIR *dirp;
	char pat[20], *name;
	static char buf[FILENAME_MAX];
	struct direct *dp;

	name = program;
	if (strnicmp(name, "uu", 2) == 0)
	   name += 2;
	sprintf(pat, "%.4s*.*", name);
	if ((dirp = opendirx(tempdir, pat)) == NULL)
		return;

	while ((dp = readdir(dirp)) != NULL) {
		mkfilename(buf, tempdir, dp->d_name);
		unlink(buf);
	}

	closedir(dirp);
}

/*--------------------------------------------------------------------*/
/*    g e t r c n a m e s                                             */
/*                                                                    */
/*    Return the name of the configuration files                      */
/*--------------------------------------------------------------------*/

# define	SYSRCSYM	"UUSYSRC"
# define	USRRCSYM	"UUUSRRC"
# define	SYSDEBUG	"UUDEBUG"

extern char *homedir, *calldir;
extern void AssignDefaultDirs(void);

void getrcnames(char** sysp, char** usrp) {
	char*	debugp;		/* Pointer to debug environment variable  */
	int	lvl;
	char	drv[MAXDRIVE];
	char	dir[MAXDIR];
	char	ext[MAXEXT];
	char	fname[MAXFILE];
	char	buf[MAXPATH];
	static char pers[] = "PERSONAL.RC";
	static char sub_conf[] = "CONF\\";

	if (debuglevel == 0) {
		lvl = 0;
		debugp = getenv(SYSDEBUG);
		if(debugp != nil(char)) /* Debug specified in environment? */
			lvl = atoi(debugp); /* Yes --> preset debuglevel for user */
		if(lvl < 0) {
			logecho = TRUE;
			debuglevel = (-lvl);
		} else if (lvl > 0) {
			logecho = FALSE;
			debuglevel = lvl;
		}
	}
	if ((*sysp = getenv(SYSRCSYM)) != nil(char)) {
		*sysp = strdup(*sysp);
		fnsplit(*sysp, drv, dir, fname, ext);
		confdir = malloc(strlen(drv) + strlen(dir) + 1);
		strcpy(confdir, drv);
		strcat(confdir, dir);
	}
	else {
		confdir = malloc(strlen(calldir) + strlen(sub_conf) + 1);
		strcpy(confdir, calldir);
		strcat(confdir, sub_conf);
		mkfilename(buf, confdir, "UUPC.RC");
		*sysp = strdup(buf);
	}
	printmsg(30, "Look in '%s' (CONFDIR?) directory", confdir);
	if ((*usrp = getenv(USRRCSYM)) != nil(char)) {
		*usrp = strdup(*usrp);
		fnsplit(*usrp, drv, dir, fname, ext);
		homedir = malloc(strlen(drv) + strlen(dir) + 1);
		strcpy(homedir, drv);
		strcat(homedir, dir);
	}
	else {
		*usrp = strdup(pers);
		homedir = strdup(getcwd(buf, MAXPATH));
	}
	printmsg(30, "Look in '%s' (HOME?) directory", homedir);
	AssignDefaultDirs();
} /*getrcnames*/


/*
   filemode - default the text/binary mode for subsequently opened files
*/

void filemode(char mode)
{
   if (mode != BINARY && mode != TEXT)
		panic();
   _fmode = (mode == TEXT) ? O_TEXT : O_BINARY;

} /*filemode*/
