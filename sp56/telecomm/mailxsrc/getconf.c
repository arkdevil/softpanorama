/*
 * $Log: getconf.c,v $
 * Revision 1.8  1991/08/25  18:06:03  ache
 * DOS fix
 *
 * Revision 1.7  1991/07/22  16:36:47  ache
 * Port to Borland C
 *
 * Revision 1.6  1990/12/07  07:14:45  ache
 * Переделана обработка временных файлов и мелочи
 *
 * Revision 1.5  90/12/03  03:02:11  ache
 * В досе: переходит в домашний каталог, прежде чем позвать sendmail
 * 
 * Revision 1.4  90/11/11  20:06:16  ache
 * Исправлено распознавание имен файлов
 * 
 * Revision 1.3  90/10/04  04:47:22  ache
 * SPOOLDIR removed, UUPC... -> UU...
 * 
 * Revision 1.2  90/09/21  21:58:45  ache
 * MS-DOS extends + some new stuff
 * 
 * Revision 1.1  90/09/13  07:48:06  ache
 * Initial revision
 *
 */

# include <assert.h>
# include	"rcv.h"

/*NOXSTR*/
static char rcsid[] = "$Header: /usr/src/Relcom/relcom/mailx/RCS/getconf.c,v 1.8 1991/08/25 18:06:03 ache Exp $";
/*YESXSTR*/
#ifdef	MSDOS
#ifdef __TURBOC__
#include <dir.h>
#else
#include <direct.h>
#define MAXDRIVE _MAX_DRIVE
#define MAXDIR _MAX_DIR
#define MAXFILE _MAX_FNAME
#define MAXEXT _MAX_EXT
#define MAXPATH _MAX_PATH
#define fnsplit _splitpath
#endif

typedef char boolean;
#define TRUE 1
#define FALSE 0
extern char *strdup();
#ifdef	__TURBOC__
extern char *getcwd();
#else
extern char *_getdcwd();
#endif

static	void  getconfig(FILE*, int);
static void getrcnames();
void mkfilename();

/* the following table contols the configurations files processing */

static struct	Table {
	char*	sym;
	char	must;
	char    sys;
	char	dir;
	char	std;
	char	*suff;
} table[] = {
	"COMSPEC",		FALSE,	FALSE, FALSE, FALSE, NULL,
	"DOMAIN",		TRUE,	TRUE,  FALSE, FALSE, NULL,
	"HOME", 		FALSE,	FALSE, TRUE,  FALSE, NULL,
	"MAILDIR",		TRUE,	TRUE,  TRUE,  TRUE, "mail",
	"MSG",			FALSE,	FALSE, FALSE, FALSE, NULL,
	"SHARE",	    FALSE,  FALSE, TRUE,  FALSE, NULL,
	"SHELL",		FALSE,	FALSE, FALSE, FALSE, NULL,
	"TMP",			TRUE,	FALSE, TRUE,  TRUE, "tmp",
	"TZ",			TRUE,	FALSE, FALSE, FALSE, NULL,
	"USER", 		FALSE,	FALSE, FALSE, FALSE, NULL,
	NOSTR
}; /* table */

char	calldir[MAXPATH];
char	*_tz;

static void AssignDefaultDirs(void)
{
	struct Table*	tptr;
	char buf[MAXPATH];

	for (tptr = table; tptr->sym != NULL; tptr++) {
		if (tptr->std && value(tptr->sym) == NULL) {
				mkfilename(buf, calldir, tptr->suff);
				assign(tptr->sym, buf);
		}
	}
}

/*
   getconfig - process a configuration file
*/

static void	getconfig(FILE* fp, int sysmode) {
	struct Table*	tptr;
	char	buff[80];
	char*	cp, *s;

	for (;;) {
		if (fgets(buff, sizeof buff, fp) == NOSTR)
			break;				/* end of file */
		if ((*buff == '\n') || (*buff == '#'))
			continue;			/* comment line */
		if (*(cp = buff + strlen(buff) - 1) == '\n')
			*cp = '\0';
		if ((cp = strchr(buff, '=')) == NOSTR)
			continue;
		*cp++ = '\0';
		for (tptr = table; tptr->sym != NOSTR; tptr++) {
			if (icequal(buff, tptr->sym)) {
				if (tptr->sys && !sysmode)
					(void) fprintf(stderr, ediag(
"User specified system parameter `%s' ignored.\n",
"Указание пользователем системного параметра `%s' игнорируется.\n"),
tptr->sym);
				else {
					if (tptr->dir) {
						for (s = cp; *s; s++)
							if (*s == '/')
								*s = SEPCHAR;
						strlwr(s);
					}
					assign(tptr->sym, cp);
				}
				break;
			}
		}
	} /*for*/
	for (tptr = table; tptr->sym != NOSTR; tptr++) {
		if (   !tptr->sys
			&& (s = getenv(tptr->sym)) != NULL
		   ) {
			if (tptr->dir) {
				for (cp = s; *cp; cp++)
					if (*cp == '/')
						*cp = SEPCHAR;
				strlwr(s);
			}
			assign(tptr->sym, s);
		}
	}
} /*getconfig*/

/*
   configure - define the global parameters of UUPC
*/

void configure(void) {
	FILE*		fp;
	char*		sysrc;
	char*		usrrc;
	int		ok;
	int		success;
	struct Table*	tptr;
	char            *s;

	getrcnames(&sysrc, &usrrc);
	if ((fp = fopen(sysrc, "r")) == NULL) {
		(void) fprintf(stderr, ediag (
"Cannot open system configuration file `%s'\n",
"Нельзя открыть системный файл конфигурации `%s'\n"),
				   sysrc);
		exit(1);
	}
	getconfig(fp, TRUE);
	fclose(fp);
	if ((fp = fopen(usrrc, "r")) != NULL) {
		getconfig(fp, FALSE);
		fclose(fp);
	}

	if (   (s = value("MSG")) != NOSTR
		&& *s != '\0'
		&& strchr("RrрР", *s) != NOSTR
	   )
		_ediag = 0;

	success = TRUE;
	for (tptr = table; tptr->sym != NOSTR; tptr++) {
		if (tptr->must && value(tptr->sym) == NOSTR) {
			(void) fprintf(stderr, ediag(
"Configuration parameter `%s' must be set.\n",
"Должен быть задан параметр конфигурации `%s'.\n"),
tptr->sym);
			success = FALSE;
		}
	}
	if (success == FALSE)
		exit(1);

	_tz = value("TZ");
	tzset();

	if (stricmp(value("SHARE"), "NO") == 0) {
		static char *args[2] = {"SHARE", NULL};

		unset(args);
	}

} /*configure*/

/*
   mkfilename - build a path name out of a directory name and a file name
*/

void mkfilename(char* pathname, char* path, char* name) {
	char *s;

	for (s = path; *s; s++)
		if (*s == '/')
			*s = SEPCHAR;
	if (s[-1] != SEPCHAR)
		sprintf(pathname, "%s%c%s", path, SEPCHAR, name);
	else
		sprintf(pathname, "%s%s", path, name);
	strlwr(pathname);
} /*mkfilename*/

/*
   getrcnames - return the name of the configuration files
*/

# define        SYSRCSYM        "UUSYSRC"
# define        USRRCSYM        "UUUSRRC"
extern char *argv0;

static void getrcnames(char** sysp, char** usrp) {
	int	lvl;
	char	drv[MAXDRIVE];
	char	dir[MAXDIR];
	char	fname[MAXFILE];
	char	ext[MAXEXT];
	char	buf[MAXPATH];
	static char pers[] = "personal.rc";
	static char sub_conf[] = "conf\\";
	char homedir[MAXPATH];
	char confdir[MAXPATH];
	char *cp;

	fnsplit(argv0, drv, dir, fname, ext);
	strcpy(calldir, drv);
	strcat(calldir, dir);
	if ((*sysp = getenv(SYSRCSYM)) != NOSTR) {
		*sysp = strdup(*sysp);
		fnsplit(*sysp, drv, dir, fname, ext);
		strcpy(confdir, drv);
		strcat(confdir, dir);
		strcpy(buf, confdir);
		mkfilename(calldir, buf, "..\\");
	}
	else {
		strcpy(confdir, calldir);
		strcat(confdir, sub_conf);
		mkfilename(buf, confdir, "uupc.rc");
		*sysp = strdup(buf);
	}
	if ((*usrp = getenv(USRRCSYM)) != NULL) {
		*usrp = strdup(*usrp);
		fnsplit(*usrp, drv, dir, fname, ext);
	}
	else
		*usrp = strdup(pers);
	AssignDefaultDirs();
} /*getrcnames*/

#define MAXDEPTH 10

static char *dirstack[MAXDEPTH];
static depth = 0;

/*--------------------------------------------------------------------*/
/*            Change to a directory and push on our stack             */
/*--------------------------------------------------------------------*/

PushDir( char *directory )
{
   assert ( depth < MAXDEPTH );
#ifdef __TURBOC__
   dirstack[depth] = getcwd( NULL , MAXPATH );
#else
   dirstack[depth] = _getdcwd( 0, NULL , MAXPATH );
#endif
   if (dirstack[depth] == NULL )
   {
	  perror("PushDir");
	  abort();
   }
   depth++;
   if (strcmp(directory, ".") == 0)
	return 0;
   return changedir( directory );
} /* PushDir */

/*--------------------------------------------------------------------*/
/*               Return to a directory saved by PushDir               */
/*--------------------------------------------------------------------*/

PopDir( void )
{
   assert ( depth > 0 );
   changedir( dirstack[--depth] );
   free( dirstack[depth] );
} /* PopDir */

int real_flush(int fd)
{
    int nf;

    if ((nf = dup(fd)) < 0)
	return -1;
    if (close(nf) < 0)
	return -1;
    return 0;
}

#endif  /* MSDOS */
