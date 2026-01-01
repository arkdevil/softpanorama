/*
 * Mail -- a mail program
 *
 * Give names to all the temporary files that we will need.
 *
 * $Log:	temp.c,v $
 * Revision 1.8  93/01/04  02:24:25  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.7  92/08/24  02:22:57  ache
 * Основательные правки и перенос в разные системы
 * 
 * Revision 1.10  1991/07/22  16:36:47  ache
 * Port to Borland C
 *
 * Revision 1.9  1991/04/19  22:50:11  asa
 * Изменения для Демос 32
 *
 * Revision 1.8  1990/12/07  14:01:09  ache
 * Правлена обработка временных файлов и мелочи
 * 
 * Revision 1.7  90/09/29  18:22:33  ache
 * <ctype.h> kicked out...
 * 
 * Revision 1.6  90/09/25  18:57:08  ache
 * atexit(unlock) added
 * 
 * Revision 1.5  90/09/21  22:00:44  ache
 * MS-DOS extends + some new stuff
 * 
 * Revision 1.4  90/09/13  13:20:51  ache
 * MS-DOS & Unix together...
 * 
 * Revision 1.3  88/07/23  20:38:45  ache
 * Русские диагностики
 * 
 * Revision 1.2  88/01/11  12:46:03  avg
 * Добавлен NOXSTR у rcsid.
 * 
 * Revision 1.1  87/12/25  16:00:59  avg
 * Initial revision
 * 
 */

#include "rcv.h"

/*NOXSTR*/
static char rcsid[] = "$Header: temp.c,v 1.8 93/01/04 02:24:25 ache Exp $";
/*YESXSTR*/

char    tempMail[PATHSIZE];
char    tempQuit[PATHSIZE];
char    tempEdit[PATHSIZE];
char    tempSet[PATHSIZE];
char    tempResid[PATHSIZE];
char    tempMesg[PATHSIZE];
char    tempBack[PATHSIZE];
/*NOXSTR*/
char    tmp[PATHSIZE] = "/tmp";
#ifndef MSDOS
char    master[PATHSIZE] = RLIB;
#else
char    master[PATHSIZE];
#endif
char    localmail[PATHSIZE];
char    aliases[PATHSIZE] = ALIASES;
char    hlp[PATHSIZE];
char    rhelp[PATHSIZE];
char    helpt[PATHSIZE];
char    rhelpt[PATHSIZE];
#ifdef  NETMAIL
char    sendprog[PATHSIZE] = "";
#endif
#ifdef  MSDOS
extern int deltftemp(), uuiocall(), PopDir();
extern char calldir[];
extern int close_all_files();
#endif
#ifdef  ATEXIT
extern void file_unlock();
#endif
/*YESXSTR*/

tinit()
{
	register char *cp, *cp2;
	char uname[PATHSIZE];
#ifndef MSDOS
	register int err = 0;
	int i;
#endif

#ifndef MSDOS
	strcpy(tempMail, tempnam(tmp, "Rs"));
	strcpy(tempResid, tempnam(tmp, "Rq"));
	strcpy(tempQuit, tempnam(tmp, "Rm"));
	strcpy(tempEdit, tempnam(tmp, "Re"));
	strcpy(tempSet, tempnam(tmp, "Rx"));
	strcpy(tempMesg, tempnam(tmp, "Ry"));
	strcpy(tempBack, tempnam(tmp, "Rb"));

	i = strlen(master);
	if (master[i - 1] != '/')
		master[i] = '/';
	strcpy(localmail, master);
	if (*SENDMAIL != '/')
		strcpy(sendprog, master);
#else   /* MSDOS */
	PushDir(".");
	if ((cp = value("MAILDIR")) == NOSTR)
		cp = ".";
	cp = copy(cp, master);
	if (cp[-1] != SEPCHAR)
		*cp++ = SEPCHAR;
	*cp = '\0';
	/*strcpy(aliases, master);*/
	strcpy(sendprog, calldir);
	strcpy(localmail, calldir);
#endif  /* MSDOS */

	strcpy(hlp, master);
	strcpy(rhelp, master);
	strcpy(helpt, master);
	strcpy(rhelpt, master);

	strcat(master, MASTER);
	strcat(localmail, MAIL);
	strcat(hlp, HELPFILE);
	strcat(rhelp, RHELPFILE);
	strcat(helpt, THELPFILE);
	strcat(rhelpt, RTHELPFILE);

#ifdef  NETMAIL
	strcat(sendprog, SENDMAIL);
#endif
#ifdef MSDOS
	(void) atexit(uuiocall);
	(void) atexit(PopDir);
#endif
#ifdef  ATEXIT
	atexit(file_unlock);
#endif
#ifdef	MSDOS
	(void) atexit(close_all_files);
	(void) atexit(TmpDelAll);
	(void) atexit(deltftemp);
#endif  /* MSDOS */

Again:
	if (strlen(myname) > 0) {
		uid = getuserid(myname);
		if (uid == -1) {
			fprintf(stderr, ediag(
"\"%s\" is not a user of this system\n",
"\"%s\" не пользователь этой системы\n"),
			    myname);
			exit(1);
		}
	}
	else {
#ifndef MSDOS
		uid = getuid() & UIDMASK;
#else
		uid = -1;
#endif
		if (username(uid, uname) < 0) {
#ifndef MSDOS
			copy("ubluit", myname);
			err++;
			if (rcvmode) {
				printf(ediag("Who are you!?\n","Кто вы!?\n"));
				exit(1);
			}
#else
			printf(ediag("Who are you? ","Кто вы? "));
			if (!intty)
			    printf(ediag("(user name required)\n",
					 "(должно быть имя пользователя)\n"));
			if (!intty || (flush (), fgets(myname, sizeof(myname), stdin)) == NOSTR)
				exit(1);
			if ((cp = index(myname, '\n')) != NOSTR)
				*cp = '\0';
			goto Again;
#endif
		}
		else
			copy(uname, myname);

	}
	if ((cp = value("HOME")) == NOSTR) {
		if ((cp = expand("~")) == NOSTR)
			cp = ".";
		assign("HOME", cp);
	}
	cp = copy(cp, homedir);
	if (cp[-1] != SEPCHAR)
		*cp++ = SEPCHAR;
	*cp = '\0';
	findmail();
	cp = copy(homedir, mailrc);
#ifndef MSDOS
	copy(".mailrc", cp);
#else
	copy("mailrc", cp);
#endif
	cp = copy(homedir, signature);
#ifndef MSDOS
	copy(".signature", cp);
#else
	copy("personal.sig", cp);
#endif
	if (debug) {
		printf("uid = %d, user = %s, mailname = %s\n",
			uid, myname, mailname);
		printf("deadletter = %s, mailrc = %s, mbox = %s\n",
			getdeadletter(), mailrc, expand("&"));
		flush();
	}
}

#ifdef  MSDOS
maketemp(temp)
char *temp;
{
	register char *cp;
	int trick;

	if ((cp = value("TMP")) == NOSTR)
		if ((cp = value("TEMP")) == NOSTR)
			if ((cp = value("TEMPDIR")) == NOSTR)
				cp = value("HOME");
	strcpy(tmp, cp);
	cp = copy(cp, temp);
	if (cp[-1] != SEPCHAR)
		*cp++ = SEPCHAR;
	copy("R$XXXXXX", cp);
	trick = 0;
	do {
		if (trick++ >= 100)
			panic("Not enough temporary names");
		mktemp(temp);
	}
	while (access(temp, 0) == 0);
}

/*
   changedir - like chdir() but also changes the current drive
*/

int changedir(path)
char* path;
{
	if ((*path != '\0') && (path[1] == ':')) {
		unsigned char   drive;

		if (((drive = toupper(*path)) >= 'A') && (drive <= 'Z'))
# if defined(__MSDOS__)
			setdisk(drive - (unsigned char)'A');
# else
# if defined(MSDOS)
		{
			unsigned    tdrives = 26;

			_dos_setdrive(drive - 'A' + 1, &tdrives);
		}
# else
  Unsupported OS/compiler
# endif
# endif
		else
			return -1;
		if (path[2] == '\0')
			return 0;
	}
	return chdir(path);
} /*changedir*/

deltftemp()
{
	TmpDel(tf);
}
#endif  /* MSDOS */
