/*
 * Mail -- a mail program
 *
 * Mail to others.
 *
 * $Log:	send.c,v $
 * Revision 1.19  93/01/04  02:23:52  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.18  92/08/24  02:22:00  ache
 * Основательные правки и перенос в разные системы
 * 
 * Revision 1.39  1991/12/09  11:34:14  ache
 * Параметры в DOS передаются теперь в том же файле
 *
 * Revision 1.38  1991/12/08  22:44:35  ache
 * Добавлено закрывание файла для DOS
 *
 * Revision 1.37  1991/08/25  18:06:03  ache
 * DOS fix
 *
 * Revision 1.36  1991/07/22  16:36:47  ache
 * Port to Borland C
 *
 * Revision 1.35  1991/07/19  20:00:14  ache
 * Добавлена рассылка сообщений в телеконференции
 *
 * Revision 1.34  1991/07/17  19:55:29  ache
 * wait.h non needed in XENIX
 *
 * Revision 1.33  1991/04/28  14:29:43  ache
 * asa damaged MSDOS
 *
 * Revision 1.32  1991/04/19  22:49:53  asa
 * Изменения для Демос 32
 *
 * Revision 1.31  1991/02/07  01:44:26  ache
 * Для Дос добавлена проверка, достаточно ли памяти
 * для запуска sendmail
 *
 * Revision 1.30  1991/01/25  18:50:28  ache
 * Запрос Cc: по askcc переставлен из send.c в collect.c
 *
 * Revision 1.29  1991/01/25  18:04:45  ache
 * Убраны старые (4.1) сигналы
 *
 * Revision 1.28  1991/01/19  15:38:23  ache
 * убраны буфера 16к, как не оправдавшие доверия народа
 *
 * Revision 1.27  90/12/23  21:27:21  ache
 * Буферизация IO по 16 K
 * 
 * Revision 1.26  90/12/22  22:54:33  ache
 * Сортировка + выдача ФИО
 * 
 * Revision 1.25  90/12/07  07:15:31  ache
 * Переделана обработка временных файлов и мелочи
 * 
 * Revision 1.24  90/12/03  03:01:33  ache
 * В досе: переходит в домашний каталог, прежде чем позвать sendmail
 * 
 * Revision 1.23  90/11/07  17:57:38  ache
 * При resent не надо signature
 * 
 * Revision 1.22  90/11/02  20:02:47  ache
 * Splitting long argument list.
 * 
 * Revision 1.21  90/10/16  09:13:38  ache
 * Чуть ускорена обработка >From
 * 
 * Revision 1.20  90/10/13  20:29:01  ache
 * handling 'From '
 *
 * Revision 1.19  90/10/04  03:38:41  ache
 * Now 48 -- magic number form DOS sendmail -- remote spooled
 * 
 * Revision 1.18  90/09/29  18:22:46  ache
 * <ctype.h> kicked out...
 * 
 * Revision 1.17  90/09/26  22:15:52  ache
 * Signature added like in INEWS
 * 
 * Revision 1.16  90/09/21  22:00:25  ache
 * MS-DOS extends + some new stuff
 * 
 * Revision 1.15  90/09/13  13:20:31  ache
 * MS-DOS & Unix together...
 * 
 * Revision 1.14  90/09/08  13:39:53  avg
 * set record игнорируется если ввод не с терминала.
 * 
 * Revision 1.13  90/08/16  18:52:13  avg
 * *** empty log message ***
 * 
 * Revision 1.12  90/08/16  17:37:25  avg
 * В built-in pager добавлена команда d.
 * 
 * Revision 1.11  90/08/16  17:32:15  avg
 * Добавлена команда forward.
 * 
 * Revision 1.10  90/08/15  19:45:19  avg
 * Вделан встроенный pager.
 *
 * Revision 1.9  90/08/10  13:47:23  avg
 * Добавлен ключ -x для передачи больших файлов.
 * 
 * Revision 1.8  90/08/08  17:14:40  avg
 * SENDMAIL->NETMAIL
 * 
 * Revision 1.7  90/05/31  23:19:43  avg
 * Исправлена ошибка - потерялся конец строки при переходе от
 * ctime к udate.
 *
 * Revision 1.6  90/05/31  19:49:40  avg
 * Новая версия gethostname для XENIXа.
 * 
 * Revision 1.5  90/05/18  14:22:48  avg
 * Добавлена возможность убирать печать строки 'From ...'
 * при помощи команды 'dis -from'.
 * 
 * Revision 1.4  90/04/30  19:44:44  avg
 * Починен режим rmail
 *
 * Revision 1.3  88/07/23  20:38:04  ache
 * Русские диагностики
 * 
 * Revision 1.2  88/01/11  12:33:30  avg
 * Поправлена запись в файл исходящей почты, дата всегда теперь
 * записывается в англ. формате, добавлены NOXSTR у rcsid.
 * 
 * Revision 1.1  87/12/25  16:00:39  avg
 * Initial revision
 *
 */

#include "rcv.h"
#ifndef M_XENIX
#if defined(VMUNIX) || defined(M_SYSV)
#include <sys/wait.h>
#else
#ifndef MSDOS
#include <wait.h>
#else
#ifndef __TURBOC__
#define freemem _dos_freemem
#define allocmem _dos_allocmem
#define ALLOCOK 0
#else
#define ALLOCOK (-1)
#endif
#endif  /*MSDOS*/
#endif  /*VMUNIX*/
#endif  /*M_XENIX*/
#include <sys/stat.h>

/*NOXSTR*/
static char rcsid[] = "$Header: send.c,v 1.19 93/01/04 02:23:52 ache Exp $";
/*YESXSTR*/

#ifdef  NETMAIL
extern char sendprog[];
#endif
extern char localmail[];
#ifdef	MSDOS
#include	<dos.h>
#include	<process.h>
#include	<errno.h>
extern SpoolRemote;
#define SKBSIZE 100  /* Memory(KB) needed for rmail.exe */
#endif
#ifndef _NFILE
#define _NFILE 20
#endif

extern char *udate(), *BestBuffer();
extern struct name* make_to_list();
static ListAlreadyDone = 0;
static FILE *infix();
#ifdef MSDOS
static FILE *putlist();
#endif

/*
 * Send message described by the passed pointer to the
 * passed output buffer.  Return -1 on error, but normally
 * the number of lines written.  Adjust the status: field
 * if need be.  If SF_DOIGN is set, suppress ignored header fields.
 * If SF_PAGER is set, emulate a MORE with 20 lines per screeen.
 */
long
send(mailp, obuf, sflags)
	struct message *mailp;
	FILE *obuf;
{
	register struct message *mp;
	register int t, i;
	long c;
	FILE *ibuf;
	char line[LINESIZE], field[BUFSIZ];
	long lc;
	int is_head, infld, fline, dostat, linecnt, binary;
	char *cp, *cp2;
	int cc, fc;
	extern crt_lines;

	linecnt = (value("quiet") == NOSTR);    /* Message %d: */
again:  mp = mailp;
	ibuf = setinput(mp);
	c = mp->m_size;
	if (sflags & SF_DOIGN)
		c--;    /* Don't print last \n */
	binary = !!(sflags & SF_BINARY);
	is_head = 1;
	dostat = 1;
	linecnt--;      /* because of Status: field */
	infld = 0;
	fline = 1;
	lc = 0;
	while (c > 0) {
		if (fgets(line, sizeof(line), ibuf) == NOSTR)
			return(-1L);
		c -= strlen(line);
		if ((cp = index(line, '\n')) != NOSTR)
			*cp = '\0';
		lc++;
		if (is_head) {
			/*
			 * First line is the From line, so no headers
			 * there to worry about
			 */
			if (fline) {
				/* fline = 0; do it below... */
				/* Skip the first From line */
				if((sflags & SF_DOIGN) && isign("-from")) {
					fline = 0;
					continue;
				}
				goto writeit;
			}
			/*
			 * If line is blank, we've reached end of
			 * headers, so force out status: field
			 * and note that we are no longer in header
			 * fields
			 */
			if (!line[0]) {
				if (dostat) {
					i = statusput(mailp, obuf, sflags & (SF_DOIGN|SF_BINARY));
					lc += i;
					linecnt += i;
					dostat = 0;
				}
				is_head = 0;
				goto writeit;
			}
			/*
			 * If this line is a continuation (via space or tab)
			 * of a previous header field, just echo it
			 * (unless the field should be ignored).
			 */
			if (infld && isspace(line[0])) {
				if ((sflags & SF_DOIGN) && isign(field)) continue;
				goto writeit;
			}
			infld = 0;
			/*
			 * If we are no longer looking at real
			 * header lines, force out status:
			 * This happens in uucp style mail where
			 * there are no headers at all.
			 */
			if (!headerp(line)) {
				if (dostat) {
					i = statusput(mailp, obuf, sflags & (SF_DOIGN|SF_BINARY));
					lc += i;
					linecnt += i;
					dostat = 0;
				}
#ifdef  MSDOS
				if (binary)
					putc('\r', obuf);
#endif
				putc('\n', obuf);
				is_head = 0;
				goto writeit;
			}
			infld++;

			/*
			 * Pick up the header field.
			 * If it is an ignored field and
			 * we care about such things, skip it.
			 */
			cp = line;
			cp2 = field;
			while (*cp && *cp != ':' && !isspace(*cp))
				*cp2++ = *cp++;
			*cp2 = 0;
			if ((sflags & SF_DOIGN) && isign(field))
				continue;

			/*
			 * If the field is "status," go compute and print the
			 * real Status: field
			 */
			if (icequal(field, "status")) {
				if (dostat) {
					i = statusput(mailp, obuf, sflags & (SF_DOIGN|SF_BINARY));
					lc += i;
					linecnt += i;
					dostat = 0;
				}
				continue;
			}
		}
writeit:
		get_screen_dims();
		/*
		 * Built-in pager
		 */
		if( (sflags & SF_PAGER) && ++linecnt >= crt_lines-1 ) {
			linecnt = 0;
promptagain:            fputs(ediag("?More? ", "?Дальше? "), obuf);
			fflush(obuf);
			if ((cc = getchar()) != '\n')
				while( (fc = getchar()) != EOF && fc != '\n' )
					;
			if( cc == 'q' || cc == 'Q' || cc == EOF )
				goto flushall;
			if( cc == 'g' || cc == 'G' ) {
				if (value("quiet") == NOSTR) {
					fprintf(obuf, ediag("Message %d:\n",
							    "Письмо %d:\n"),
					     mp - &message[0] + 1);
					linecnt = 1;
				}
				goto again;
			}
			if( cc == 'd' || cc == 'D' )
				linecnt += crt_lines/2;
			if( cc == '?' ) {
				fputs(ediag("\n\tCR or Enter  - show next screen.\n",
					    "\n\tВК или Enter - показать следующий экран.\n"), obuf);
				fputs(ediag("\tg            - show the message from the beginning.\n",
					    "\tg            - показать письмо сначала.\n"), obuf);
				fputs(ediag("\td            - show next half-screen.\n",
					    "\td            - показать следуюшие пол-экрана.\n"), obuf);
				fputs(ediag("\tq            - quit printing message.\n",
					    "\tq            - закончить просмотр письма.\n"), obuf);
				fputs(ediag("\t?            - prints this help.\n\n",
					    "\t?            - выдает эту подсказку.\n\n"), obuf);
				goto promptagain;
			}
		}
		if (!fline && ishead(line))
			putc('>', obuf);
		fline = 0;
		if (sflags & SF_PAGER)
			safeputs(line, obuf);
		else
			fputs(line, obuf);
#ifdef  MSDOS
		if (binary)
			putc('\r', obuf);
#endif
		putc('\n', obuf);
		if (ferror(obuf))
			return(-1L);
	}
flushall:
	(void) fflush(obuf);
	if (ferror(obuf))
		return(-1L);
	if (is_head && (mailp->m_flag & MSTATUS))
		printf(ediag(
"WARNING: bad header, failed to fix up status field\n",
"ПРЕДУПРЕЖДЕНИЕ: плохой заголовок, неудача с полем status\n"));
	return(lc);
}

/*
 * Test if the passed line is a header line, RFC 733 style.
 */
headerp(line)
	register char *line;
{
	register char *cp = line;

	while (*cp && !isspace(*cp) && *cp != ':')
		cp++;
	while (*cp && isspace(*cp))
		cp++;
	return(*cp == ':');
}

/*
 * Output a reasonable looking status field.
 * But if "status" is ignored and doign, forget it.
 */
statusput(mp, obuf, sflags)
	register struct message *mp;
	register FILE *obuf;
{
	char statout[3];
	int doign = !!(sflags & SF_DOIGN);
	int binary = !!(sflags & SF_BINARY);

	if (doign && isign("status"))
		return 0;
	if ((mp->m_flag & (MNEW|MREAD)) == MNEW)
		return 0;
	if (mp->m_flag & MREAD)
		strcpy(statout, "R");
	else
		strcpy(statout, "");
	if ((mp->m_flag & MNEW) == 0)
		strcat(statout, "O");
	fprintf(obuf, "Status: %s", statout);
#ifdef  MSDOS
	if (binary)
		putc('\r', obuf);
#endif
	putc('\n', obuf);
	return 1;
}


/*
 * Interface between the argument list and the mail1 routine
 * which does all the dirty work.
 */

mail(people)
	char **people;
{
	register char *cp2;
	register int s;
	char *buf, **ap;
	struct header head;
	extern char *cc_line, *bcc_line;

	if (*people != NOSTR) {
		for (s = 0, ap = people; *ap != (char *) -1; ap++)
			s += strlen(*ap) + 2;
		buf = salloc(s);
		cp2 = buf;
		for (ap = people; *ap != (char *) -1; ap++) {
			cp2 = copy(*ap, cp2);
			cp2 = copy(", ", cp2);
		}
		if (cp2 != buf)
			cp2 -= 2;
		*cp2 = '\0';

		head.h_to_template = blankline(buf) ? NOSTR : buf;
	}
	else
		head.h_to_template = NOSTR;
	head.h_cc_template = cc_line;
	head.h_bcc_template = bcc_line;
	head.h_bcc = head.h_cc = head.h_to = NOSTR;
	if (sflag != NOSTR)
		head.h_subject = savestr(sflag);
	else
		head.h_subject = NOSTR;
	head.h_refs = NOSTR;
	head.h_newsgroups = NOSTR;
	head.h_distribution = NOSTR;
	head.h_keywords = NOSTR;
	head.h_summary = NOSTR;
	head.h_inreplyto = NOSTR;
	head.h_seq = 0;
	head.h_resent = 0;
	mail1(&head);
	return(0);
}


/*
 * Send mail to a bunch of user names.  The interface is through
 * the mail1 routine below.
 */

sendmail(str)
	char *str;
{
	struct header head;

	if (blankline(str))
		head.h_to_template = NOSTR;
	else
		head.h_to_template = str;
	head.h_to = NOSTR;
	head.h_cc = head.h_cc_template = NOSTR;
	head.h_bcc = head.h_bcc_template = NOSTR;
	head.h_subject = NOSTR;
	head.h_refs = NOSTR;
	head.h_newsgroups = NOSTR;
	head.h_distribution = NOSTR;
	head.h_keywords = NOSTR;
	head.h_summary = NOSTR;
	head.h_inreplyto = NOSTR;
	head.h_seq = 0;
	head.h_resent = 0;
	mail1(&head);
	return(0);
}

/*
 * Forward the current message
 * to the given list of addressees.
 */
Forward(str)
	char *str;
{
	struct header head;

	if( blankline(str) ) {
		printf(ediag("No recipients specified.\n",
			     "Не указаны адресаты.\n"));
		return 1;
	}

	head.h_to_template = savestr(str);
	head.h_to = NOSTR;
	head.h_cc = head.h_cc_template = NOSTR;
	head.h_bcc = head.h_bcc_template = NOSTR;
	head.h_subject = NOSTR;
	head.h_refs = NOSTR;
	head.h_newsgroups = NOSTR;
	head.h_distribution = NOSTR;
	head.h_keywords = NOSTR;
	head.h_summary = NOSTR;
	head.h_inreplyto = NOSTR;
	head.h_seq = 0;
	head.h_resent = 1;
	mail1(&head);
	return(0);
}

/*
 * Collect the forwarded message and put it into the temp. file
 */
FILE *fcollect(hp)
{
	extern char tempMail[];
	FILE *buf, *inp;
	register struct message *mp;
	char line[LINESIZE];
	int msg, firstl, inhdr, ignfield, t;
	long bcnt;
	char c;

	/*
	 * Scan for applicable message
	 */
	msg = first(0, MMNDEL);
	if( msg == (int)NULL ) {
		printf(ediag("No applicable messages\n",
			     "Нет подходящих писем\n"));
		return NULL;
	}
	mp = &message[msg-1];

	/*
	 * Create temp. file
	 */
	buf = NULL;
#ifdef  MSDOS
	maketemp(tempMail);
#endif
	if (   fclear(tempMail) < 0
#ifndef	MSDOS
		|| (buf = TmpOpen(tempMail, "a+")) == NULL
#else
		|| (buf = TmpOpen(tempMail, "a+b")) == NULL
#endif
	   ) {
		perror(tempMail);
		remove(tempMail);
		return NULL;
	}

	/*
	 * Copy the message into temp. file
	 */
	bcnt = mp->m_size;
	inp = setinput(mp);
	firstl = 1;
	inhdr = 1;
	ignfield = 0;
	while (bcnt > 0) {
		if (fgets(line, sizeof(line), inp) == NOSTR)
			goto err;
		bcnt -= strlen(line);
#ifdef  MSDOS
		bcnt--;
#endif
		if( firstl ) {  /* Ugly From header line */
			firstl = 0;
			continue;
		}
		if( inhdr ) {
			if( line[0] == '\n' )
				inhdr = 0;
			else if( isspace(line[0]) ) {
				if( ignfield )
					continue;
			} else {
				ignfield = 0;
				c = line[7];
				line[7] = '\0';
				if( icequal(line, "resent-") ||
					icequal(line, "status:") ) {
					ignfield++;
					continue;
				}
				line[7] = c;
			}
		}
		if (ishead(line))
			putc('>', buf);
		fputs(line, buf);
		if (ferror(buf))
			goto err;
	}
	(void) fflush(buf);
	if (ferror(buf))
		goto err;
	rewind(buf);

	return buf;
err:
	perror("fcollect");
	TmpDel(buf);

	return NULL;
}

/*
 * Mail a message on standard input to the people indicated
 * in the passed header.  (Internal interface).
 */

mail1(hp)
	struct header *hp;
{
	register char *cp, *pp;
	int pid, i, s, p, gotcha;
	char **namelist, *deliver;
	struct name *to, *np;
	struct stat sbuf;
	FILE *mtf, *postage, *fbuf;
	int remote = (rflag != NOSTR) || rmail;
	char **t;
	extern int filetransfer;
	char linebuf[LINESIZE];
#ifdef	MSDOS
	unsigned segbuf;
	off_t begin;
#endif

	/*
	 * Collect user's mail from standard input.
	 * Get the result as mtf.
	 */

	pid = -1;
	if ((mtf = hp->h_resent ? fcollect(hp) : collect(hp)) == NULL)
		return(-1);
	hp->h_seq = 1;
	if (intty && outtty && !hp->h_resent) {
		printf(ediag("EOT\n","КОНЕЦ ПЕРЕДАЧИ\n"));
		flush();
	}

	/*
	 *  Copy out signature file
	 */

	if (   !hp->h_resent
	    && value("autosign") != NOSTR
	    && (fbuf = Fopen(signature, "r")) != NULL
	   ) {
		fseek(mtf, 0L, 2);
		fputs("-- \n", mtf);
		for (i = 0; i < 4; i++)
			if (fgets(linebuf, sizeof(linebuf), fbuf) == NOSTR)
				break;
			else {
				if (ishead(linebuf))
					putc('>', mtf);
				fputs(linebuf, mtf);
			}
		Fclose(fbuf);
	}

	/*
	 * Now, take the user names from the combined
	 * to and cc lists and do all the alias
	 * processing.
	 */

	senderr = 0;
	to = make_to_list(hp);
	ListAlreadyDone = 1;

	if (to == NIL) {
		printf(ediag(
"No recipients specified\n",
"Не указаны получатели\n"));
		goto topdog;
	}

	/*
	 * Look through the recipient list for names with /'s
	 * in them which we write to as files directly.
	 */

	to = outof(to, mtf, hp);
	if (senderr && !remote) {
topdog:
		if (fsize(mtf) != 0) {
			rewind(mtf);
			remove(getdeadletter());
			exwrite(getdeadletter(), mtf, 1);
		}
	}
	rewind(mtf);
	for (gotcha = 0, np = to; np != NIL; np = np->n_flink)
		if ((np->n_type & GDEL) == 0) {
			gotcha++;
			break;
		}
	mechk(to);

	if (hp->h_seq > 0 && !remote) {
		if (fsize(mtf) == 0)
		    if (hp->h_subject == NOSTR)
			printf(ediag(
"No message, no subject; hope that's ok!\n",
"Ни текста письма, ни темы; наверное так и надо!\n"));
			else
			printf(ediag(
"Null message body; hope that's ok!\n",
"Пустое письмо; наверное так и надо!\n"));
		if ((mtf = infix(hp, mtf)) == NULL) {
Lost:
			fprintf(stderr, ediag(
". . . message lost, sorry.\n",
". . . письмо пропало, извините.\n"));
			ListAlreadyDone = 0;
			return(-1);
		}
	}
	ListAlreadyDone = 0;

	if ((cp = value("record")) != NOSTR && !filetransfer) {
		if ((pp = expand(cp)) != NOSTR) {
			if (isdir(pp))
				fprintf(stderr, ediag("'record' %s is a directory\n",
						      "'record' %s -- каталог\n"),
						pp);
			else
				savemail(pp, hp, mtf);
		}
	}

	if (!gotcha)
		goto out;

	while ((namelist = unpack(&to)) != (char **) NULL) {
		if (debug) {
			printf(ediag(
"Recipients of message:\n",
"Получатели письма:\n"));
			for (t = namelist; *t != NOSTR; t++)
				printf(" \"%s\"", *t);
			printf("\n");
			flush();
			continue;
		}
#ifndef MSDOS
	/*
	 * Wait, to absorb a potential zombie, then
	 * fork, set up the temporary mail file as standard
	 * input for "mail" and exec with the user list we generated
	 * far above. Return the process id to caller in case he
	 * wants to await the completion of mail.
	 */

#ifdef VMUNIX
#ifdef  pdp11
		while (wait2(&s, WNOHANG) > 0)
#endif
#if defined(vax) || defined(sun)
		while (wait3(&s, WNOHANG, 0) > 0)
#endif
		;
#else
		wait(&s);
#endif
		rewind(mtf);
		pid = fork();
		if (pid == -1) {
			perror("fork");
			remove(getdeadletter());
			exwrite(getdeadletter(), mtf, 1);
			goto out;
		}
		if (pid == 0) {
#ifdef VMUNIX
			if (remote == 0) {
				sigset(SIGTSTP, SIG_IGN);
				sigset(SIGTTIN, SIG_IGN);
				sigset(SIGTTOU, SIG_IGN);
			}
#endif
			signal(SIGHUP, SIG_IGN);
			signal(SIGINT, SIG_IGN);
			signal(SIGQUIT, SIG_IGN);
			if (!stat(POSTAGE, &sbuf))
				if ((postage = Fopen(POSTAGE, "a")) != NULL) {
					fprintf(postage, "%s %d %d\n", myname,
						count(to), fsize(mtf));
					Fclose(postage);
				}
			s = fileno(mtf);
			for (i = 3; i < _NFILE; i++)
				if (i != s)
					close(i);
			close(0);
			dup(s);
			close(s);
#ifdef CC
			submit(getpid());
#endif
#ifdef NETMAIL
			if ((deliver = value("sendmail")) == NOSTR)
				deliver = sendprog;
			execv(deliver, namelist);
#endif
			execv(localmail, namelist);
			perror(localmail);
			exit(1);
		}
#else   /* MSDOS */
#ifdef NETMAIL
		if ((deliver = value("sendmail")) == NOSTR)
			deliver = sendprog;
#endif
		if ((mtf = putlist(namelist, mtf, &begin)) == NULL)
			goto Lost;
		(void) fflush(mtf);
		if (ferror(mtf) || real_flush(fileno(mtf)) < 0) {
			perror("write");
			TmpDel(mtf);
			goto Lost;
		}
		rewind(mtf);
		PushDir(value("HOME"));
		p = dup (fileno (stdin));
		close (fileno (stdin));
		dup (fileno (mtf));
		if (	allocmem((unsigned)((SKBSIZE * 1024L) >> 4), &segbuf) != ALLOCOK
			 || freemem(segbuf)
		   )
			goto NotStarted;
		s = spawnlp (P_WAIT, deliver, deliver, "-l", NOSTR);
		PopDir();
		if (s < 0) {
			int nomem;

		NotStarted:
			nomem = (errno == ENOMEM);
			perror(deliver);
			dup2 (p, fileno (stdin));
			close (p);
			if (nomem)
				fprintf(stderr, ediag(
					"I need %dKb of free memory to run SENDMAIL\n",
					"Нужно %dКб свободной памяти, чтобы запустить SENDMAIL\n"),
					SKBSIZE);
ddump:
			fseek(mtf, begin, 0);
			remove(getdeadletter());
			exwrite(getdeadletter(), mtf, 1);
			goto out;
		}
		dup2 (p, fileno (stdin));
		close (p);
		if (s == 48) {	/* MAGIC number -- remote spooled */
			SpoolRemote++;
			s = 0;
		}
		pid = 1;
		if (s != 0)
			goto ddump;
		if (!stat(POSTAGE, &sbuf))
			if ((postage = Fopen(POSTAGE, "a")) != NULL) {
				fprintf(postage, "%s %d %d\n", myname,
					count(to), fsize(mtf));
				Fclose(postage);
			}
#endif  /* MSDOS */

out:
		if (remote || (value("verbose") != NOSTR)) {
#ifndef MSDOS
			while ((p = wait(&s)) != pid && p != -1)
				;
#endif
			if (s != 0)
				senderr++;
			pid = 0;
		}
	}   /* End While Args */

	TmpDel(mtf);

	return(pid);
}

/*
 * Fix the header by glopping all of the expanded names from
 * the distribution list into the appropriate fields.
 * If there are any ARPA net recipients in the message,
 * we must insert commas, alas.
 */

fixhead(hp, tolist)
	struct header *hp;
	struct name *tolist;
{
	hp->h_to = detract(tolist, GTO);
	hp->h_cc = detract(tolist, GCC);
	hp->h_bcc = detract(tolist, GBCC);
}

/*
 * Prepend a header in front of the collected stuff
 * and return the new file.
 */

static
FILE *
infix(hp, fi)
	struct header *hp;
	FILE *fi;
{
	extern char tempMail[];
	register FILE *nf;
	register int c;

	rewind(fi);
#ifdef  MSDOS
	maketemp(tempMail);
#endif
	if (   fclear(tempMail) < 0
#ifndef	MSDOS
		|| (nf = TmpOpen(tempMail, "a+")) == NULL
#else
		|| (nf = TmpOpen(tempMail, "a+b")) == NULL
#endif
	   ) {
		perror(tempMail);
		remove(tempMail);
		TmpDel(fi);
		return NULL;
	}
	(void) puthead(hp, nf, GMASK|GNL);
	while ((c = getc(fi)) != EOF)
		putc(c, nf);
	if (ferror(fi)) {
		ioerror("temp", 0);
		TmpDel(nf);
		TmpDel(fi);
		return NULL;
	}
	fflush(nf);
	if (ferror(nf)) {
		ioerror(tempMail, 1);
		TmpDel(nf);
		TmpDel(fi);
		return NULL;
	}
	TmpDel(fi);
	rewind(nf);

	return(nf);
}

#ifdef MSDOS
/*
 * Prepend a namelist in front of the collected stuff
 * and return the new file.
 */

static
FILE *
putlist(list, fi, begin)
	char **list;
	FILE *fi;
	long *begin;
{
	extern char tempMail[];
	FILE *nf;
	int c;
	char **t;

	rewind(fi);
	maketemp(tempMail);
	if (   fclear(tempMail) < 0
		|| (nf = TmpOpen(tempMail, "a+")) == NULL
	   ) {
		perror(tempMail);
		remove(tempMail);
		TmpDel(fi);
		return NULL;
	}
	for (t = list; *t != NOSTR; t++) {
		fputs(*t, nf);
		if (ferror(nf))
			goto nferr;
		putc('\n', nf);
	}
	fputs("<<NULL>>\n", nf);
	if (ferror(nf))
		goto nferr;

	*begin = ftell(nf);

	while ((c = getc(fi)) != EOF) {
		putc(c, nf);
		if (ferror(nf))
			goto nferr;
	}
	if (ferror(fi)) {
		ioerror("temp", 0);
		TmpDel(nf);
		TmpDel(fi);
		return NULL;
	}
	fflush(nf);
	if (ferror(nf)) {
nferr:
		ioerror(tempMail, 1);
		TmpDel(nf);
		TmpDel(fi);
		return NULL;
	}
	TmpDel(fi);
	rewind(nf);

	return(nf);
}
#endif	/* MSDOS */

/*
 * Dump the to, subject, cc header on the
 * passed file buffer.
 */
int
puthead(hp, fo, w)
	struct header *hp;
	FILE *fo;
{
	register int gotcha;

	gotcha = 0;

	if (!ListAlreadyDone)
		(void) make_to_list(hp);

	if (hp->h_to != NOSTR && (w & GTO))
		gotcha += fmt(hp->h_resent?"Resent-To: ": "To: ", hp->h_to, fo);
	if (hp->h_newsgroups != NOSTR && (w & GNGR))
		gotcha += fmt("Newsgroups: ", hp->h_newsgroups, fo);
	if (hp->h_cc != NOSTR && (w & GCC))
		gotcha += fmt(hp->h_resent?"Resent-Cc: ": "Cc: ", hp->h_cc, fo);
	if (hp->h_bcc != NOSTR && (w & GBCC))
		gotcha += fmt(hp->h_resent?"Resent-Bcc: ": "Bcc: ", hp->h_bcc, fo);
	if (hp->h_refs != NOSTR && (w & GREFS) && !hp->h_resent)
		gotcha += fmt("References: ", hp->h_refs, fo);
	if (hp->h_inreplyto != NOSTR && (w & GIRTO) && !hp->h_resent)
		gotcha += fmt("In-Reply-To: ", hp->h_inreplyto, fo);

	if ( w & GADD )
		gotcha += putaddhlines(fo, hp->h_resent);

	if (hp->h_subject != NOSTR && (w & GSUBJECT))
		gotcha += fmt("Subject: ", hp->h_subject, fo);
	if (hp->h_keywords != NOSTR && (w & GNEWS))
		gotcha += fmt("Keywords: ", hp->h_keywords, fo);
	if (hp->h_summary != NOSTR && (w & GNEWS))
		gotcha += fmt("Summary: ", hp->h_summary, fo);
	if (hp->h_distribution != NOSTR && (w & GNEWS))
		gotcha += fmt("Distribution: ", hp->h_distribution, fo);

	if (gotcha && (w & GNL) && !hp->h_resent) {
		if (fo != NULL)
			putc('\n', fo);
		gotcha++;
	}

	return(gotcha);
}

/*
 * Format the given text to not exceed 72 characters.
 */
int
fmt(str, txt, fo)
	register char *str, *txt;
	register FILE *fo;
{
	register int col, lcnt = 0;
	register char *bg, *bl, *pt, ch;

	if (txt == NOSTR || !*txt)
		return 0;
	col = strlen(str);
	if (col > 0 && fo != NULL) {
		if (fo == stdout)
			safeputs(str, fo);
		else
			fputs(str, fo);
	}
	pt = bg = txt;
	bl = NOSTR;
	while (*bg) {
		pt++;
		if (++col >72) {
			if (!bl) {
				bl = bg;
				while (*bl && !isspace((unsigned char)*bl))
					bl++;
			}
			if (!*bl)
				goto finish;
			ch = *bl;
			*bl = '\0';
			if (fo != NULL) {
				if (fo == stdout)
					safeputs(bg, fo);
				else
					fputs(bg, fo);
				fputs("\n    ", fo);
			}
			lcnt++;
			col = 4;
			*bl = ch;
			pt = bg = ++bl;
			bl = NOSTR;
		}
		if (!*pt) {
finish:
			if (fo != NULL) {
				if (fo == stdout)
					safeputs(bg, fo);
				else
					fputs(bg, fo);
				putc('\n', fo);
			}
			lcnt++;

			return lcnt;
		}
		if (isspace((unsigned char)*pt))
			bl = pt;
	}
}

/*
 * Save the outgoing mail on the passed file.
 */

savemail(name, hp, fi)
	char name[];
	struct header *hp;
	FILE *fi;
{
	register FILE *fo;
	char *n, line[LINESIZE];
	char *vbuf;

#ifndef MSDOS
	if ((fo = Fopen(name, "a")) == NULL) {
#else
	if (   (fo = Fopen(name, "r+b")) == NULL
	    && (fclear(name), fo = Fopen(name, "r+b")) == NULL
	   ) {
#endif
		perror(name);
		return(-1);
	}
	vbuf = BestBuffer(fo);
#ifdef  MSDOS
	seekctlz(fo);
#endif
	n = rflag;
	if (n == NOSTR)
		n = myname;
	fprintf(fo, "From %s %s", n, udate());
#ifdef  MSDOS
	putc('\r', fo);
#endif
	putc('\n', fo);
	rewind(fi);
	while (fgets(line, sizeof(line), fi) != NOSTR) {
		if ((n = index(line, '\n')) != NOSTR)
			*n = '\0';
		if (ishead(line))
			putc('>', fo);
		fputs(line, fo);
#ifdef  MSDOS
		putc('\r', fo);
#endif
		putc('\n', fo);
		if (ferror(fo))
			goto err;
	}
#ifdef  MSDOS
	putc('\r', fo);
#endif
	putc('\n', fo);
	(void) fflush(fo);
	if (ferror(fo)) {
	err:
		ioerror(name, 1);
		Fclose(fo);
		if (vbuf != NULL)
			free(vbuf);
		return(-1);
	}
	Fclose(fo);
	if (vbuf != NULL)
		free(vbuf);
	return(0);
}
