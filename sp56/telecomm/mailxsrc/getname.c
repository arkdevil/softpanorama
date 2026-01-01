/*
 * Getname / getuserid for those with no
 * hashed passwd data base).
 * Do not compile this module in if you DO have hashed
 * passwd's -- this is slower.
 *
 * Also provided here is a getpw routine which can share
 * the open file.  This is used for the Version 6 getenv
 * implementation.
 *
 * $Log:	getname.c,v $
 * Revision 1.7  93/01/04  02:15:24  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.6  92/08/24  02:19:41  ache
 * Основательные правки и перенос в разные системы
 * 
 * Revision 1.3  1990/09/13  13:19:20  ache
 * MS-DOS & Unix together...
 *
 * Revision 1.2  88/01/11  12:41:52  avg
 * Добавлен NOXSTR у rcsid.
 * 
 * Revision 1.1  87/12/25  15:59:29  avg
 * Initial revision
 * 
 */

#include "rcv.h"
#ifdef  GETPWENT
#include <pwd.h>
#ifndef __386BSD__
struct passwd *getpwnam(), *getpwuid();
#endif
#endif

/*NOXSTR*/
static char rcsid[] = "$Header: getname.c,v 1.7 93/01/04 02:15:24 ache Exp $";
/*YESXSTR*/

#ifndef GETPWENT
static FILE *pwfile =   NULL;           /* Pw file held open */
#ifndef MSDOS
static char *pwname =   "/etc/passwd";  /* Name of passwd file */
#else
static char *pwname = NOSTR;
extern void mkfilename();
extern char calldir[];

static char *initpwname()
{
	static char buf[256];

	mkfilename(buf, calldir, "conf\\passwd");
	return buf;
}
#endif  /* MSDOS */
#endif  /* !GETPWENT */

/*
 * Search the passwd file for a uid.  Return name through ref parameter
 * if found, indicating success with 0 return.  Return -1 on error.
 * If -1 is passed as the user id, close the passwd file.
 */

getname(uid, namebuf)
	char namebuf[];
{
#ifdef  GETPWENT
	struct passwd *pw;

	if (uid == -1) {
		endpwent();
		return 0;
	}

	if ((pw = getpwuid(uid)) == NULL)
		return -1;

	strcpy(namebuf, pw->pw_name);
	return 0;
#else   /* !GETPWENT */
	register char *cp, *cp2;
	char linebuf[BUFSIZ];

	if (uid == -1) {
		if (pwfile != NULL) {
			Fclose(pwfile);
			pwfile = NULL;
		}
		return(0);
	}
	if (pwfile == NULL) {
#ifdef  MSDOS
		if (pwname == NOSTR)
			pwname = initpwname();
#endif
		if ((pwfile = Fopen(pwname, "r")) == NULL)
			return(-1);
	}

	rewind(pwfile);
	while (fgets(linebuf, BUFSIZ, pwfile) != NULL)
		if (pweval(linebuf) == uid) {
			for (cp = linebuf, cp2 = namebuf; *cp != ':';
			    *cp2++ = *cp++)
				;
			*cp2 = '\0';
			return(0);
		}
	return(-1);
#endif  /* !GETPWENT */
}

#ifndef GETPWENT
/*
 * Read the users password file line into the passed line
 * buffer.
 */

getpw(uid, linebuf)
	char linebuf[];
{
	register char *cp, *cp2;

	if (uid == -1) {
		if (pwfile != NULL) {
			Fclose(pwfile);
			pwfile = NULL;
		}
		return(0);
	}
	if (pwfile == NULL) {
#ifdef  MSDOS
		if (pwname == NOSTR)
			pwname = initpwname();
#endif
		if ((pwfile = Fopen(pwname, "r")) == NULL)
			return(-1);
	}
	rewind(pwfile);
	while (fgets(linebuf, BUFSIZ, pwfile) != NULL)
		if (pweval(linebuf) == uid) {
			if (linebuf[0] != '\0')
				linebuf[strlen(linebuf)-1] = '\0';
			return(0);
		}
	return(-1);
}

/*
 * Look for passwd line belonging to 'name'
 */

getpwn(name, linebuf)
	char name[], linebuf[];
{
	register char *cp, *cp2;

	if (name == NOSTR) {
		if (pwfile != NULL) {
			Fclose(pwfile);
			pwfile = NULL;
		}
		return(0);
	}
	if (pwfile == NULL) {
#ifdef  MSDOS
		if (pwname == NOSTR)
			pwname = initpwname();
#endif
		if ((pwfile = Fopen(pwname, "r")) == NULL)
			return(-1);
	}
	rewind(pwfile);
	while (fgets(linebuf, BUFSIZ, pwfile) != NULL) {
		cp = linebuf;
		cp2 = name;
		while (*cp2++ == *cp++)
			;
		if (*--cp == ':' && *--cp2 == 0)
			return(0);
	}
	return(-1);
}
#endif  /* !GETPWENT */

/*
 * Convert the passed name to a user id and return it.  Return -1
 * on error.  Iff the name passed is -1 (yech) close the pwfile.
 */

getuserid(name)
	char name[];
{
#ifdef  GETPWENT
	struct passwd *pw;

	if (name == (char *) -1) {
		endpwent();
		return 0;
	}

	if ((pw = getpwnam(name)) == NULL)
		return -1;

	return pw->pw_uid;
#else   /* !GETPWENT */
	register char *cp, *cp2;
	char linebuf[BUFSIZ];

	if (name == (char *) -1) {
		if (pwfile != NULL) {
			Fclose(pwfile);
			pwfile = NULL;
		}
		return(0);
	}
	if (pwfile == NULL) {
#ifdef  MSDOS
		if (pwname == NOSTR)
			pwname = initpwname();
#endif
		if ((pwfile = Fopen(pwname, "r")) == NULL)
			return(-1);
	}
	rewind(pwfile);
	while (fgets(linebuf, BUFSIZ, pwfile) != NULL) {
		for (cp = name, cp2 = linebuf; *cp++ == *cp2++;)
			;
		if (*--cp == '\0' && *--cp2 == ':')
			return(pweval(linebuf));
	}
	return(-1);
#endif  /* !GETPWENT */
}

#ifndef GETPWENT
/*
 * Evaluate the user id of the passed passwd line and return it.
 */

static
pweval(line)
	char line[];
{
	register char *cp;
	register int i;
	register int uid;

	for (cp = line, i = 0; i < 2; i += (*cp++ == ':'))
		;
	uid = atoi(cp);

#ifdef UIDGID
	while (*cp && *cp != ':')
		cp++;
	cp++;
	uid |= atoi(cp) << 8;
#endif

	return(uid);
}
#endif  /* !GETPWENT */
