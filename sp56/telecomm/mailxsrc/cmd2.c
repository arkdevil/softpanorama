/*
 * Mail -- a mail program
 *
 * More user commands.
 *
 * $Log:	cmd2.c,v $
 * Revision 1.15  93/01/04  02:12:40  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.13  92/08/24  02:15:53  ache
 * Основательные правки и перенос в разные системы
 * 
 * Revision 1.32  1992/03/10  11:02:23  ache
 * Для Дос убран chmod из-за конфликтов с share
 *
 * Revision 1.31  1992/03/10  08:00:32  ache
 * Вызов uuio заменен на вызов uupc.bat
 *
 * Revision 1.30  1991/08/25  19:53:51  ache
 * Remove first blank line in 'write'
 *
 * Revision 1.29  1991/08/24  15:13:58  ache
 * Теперь по 'write' не пишутся заголовки
 *
 * Revision 1.28  1991/07/22  16:36:47  ache
 * Port to Borland C
 *
 * Revision 1.27  1991/07/18  20:48:02  ache
 * В серии для uudecode может быть теперь несколько begin--end
 *
 * Revision 1.26  1991/07/17  19:58:33  ache
 * Теперь uudecode умеет обрабатывать файл из нескольких сообщений
 *
 * Revision 1.25  1991/01/25  18:04:45  ache
 * Убраны старые (4.1) сигналы
 *
 * Revision 1.24  1991/01/19  15:38:23  ache
 * убраны буфера 16к, как не оправдавшие доверия народа
 *
 * Revision 1.23  90/12/26  23:47:01  ache
 * Вынесено все для даты в date.c
 * 
 * Revision 1.22  90/12/23  21:12:19  ache
 * Буферизация IO по 16 К
 *
 * Revision 1.21  90/12/07  07:14:49  ache
 * Переделана обработка временных файлов и мелочи
 * 
 * Revision 1.20  90/11/18  02:35:42  ache
 * Правлена печать заголовков по поводу адреса, даты, длины
 * 
 * Revision 1.19  90/11/17  23:13:35  ache
 * Теперь uudecode передается ДО КУДА декодировать
 * 
 * Revision 1.18  90/11/04  02:24:55  ache
 * uudecode, strncmp bugs fixed
 *
 * Revision 1.17  90/11/02  22:22:26  ache
 * Исправлена выдача имени зоны.
 * 
 * Revision 1.16  90/10/16  09:12:29  ache
 * Чуть ускорена обработка >From
 * 
 * Revision 1.15  90/10/13  20:21:36  ache
 * Deleting 'From ', del not disturb mbox
 * 
 * Revision 1.14  90/10/07  18:58:35  ache
 * Added confirmation for autocall.
 * 
 * Revision 1.13  90/10/04  03:37:32  ache
 * Now 48 -- magic number form DOS sendmail -- remote spooled
 * 
 * Revision 1.12  90/09/21  23:10:19  ache
 * little bug
 * 
 * Revision 1.11  90/09/21  21:57:56  ache
 * MS-DOS extends + some new stuff
 * 
 * Revision 1.10  90/09/13  17:50:09  ache
 * MS-DOS & Unix together...
 *
 * Revision 1.9  90/08/23  16:49:47  avg
 * Правлен ARPA-овский формат даты.
 * 
 * Revision 1.8  90/08/16  17:31:11  avg
 * Добавлена команда forward.
 * 
 * Revision 1.7  90/06/26  17:12:26  avg
 * Добавлена переменная realname.
 * 
 * Revision 1.6  90/06/21  23:23:25  avg
 * Добавлено отрезание реального имени по запятой.
 * 
 * Revision 1.5  90/05/31  19:42:18  avg
 * Добавлена возможность вставки дополнительных строк в заголовки
 * сообщений.
 * 
 * Revision 1.4  90/04/20  19:16:31  avg
 * Прикручено под System V
 *
 * Revision 1.3  88/07/23  20:30:22  ache
 * Русские диагностики
 * 
 * Revision 1.2  88/01/11  12:39:34  avg
 * Добавлен NOXSTR у rcsid.
 * 
 * Revision 1.1  87/12/25  15:58:27  avg
 * Initial revision
 * 
 */

#include "rcv.h"
#include <string.h>
#include <sys/stat.h>
#ifdef  GETPWENT
#include <pwd.h>
struct passwd *getpwnam();
#endif
#ifdef	MSDOS
#include <process.h>
#endif

/*NOXSTR*/
static char rcsid[] = "$Header: cmd2.c,v 1.15 93/01/04 02:12:40 ache Exp $";
/*YESXSTR*/

static void clob1();
extern off_t sizef();
extern char *malloc(), *BestBuffer();
#ifdef	MSDOS
/*static void LoadRealNameFromAliases();*/
extern void mkfilename();
extern char calldir[];
#endif

/*
 * If any arguments were given, go to the next applicable argument
 * following dot, otherwise, go to the next applicable message.
 * If given as first command with no arguments, print first message.
 */

next(msgvec)
	int *msgvec;
{
	register struct message *mp;
	register int *ip, *ip2;
	int list[2], mdot;

	if (*msgvec != (int)NULL) {

		/*
		 * If some messages were supplied, find the
		 * first applicable one following dot using
		 * wrap around.
		 */

		mdot = dot - &message[0] + 1;

		/*
		 * Find the first message in the supplied
		 * message list which follows dot.
		 */

		for (ip = msgvec; *ip != (int)NULL; ip++)
			if (*ip > mdot)
				break;
		if (*ip == (int)NULL)
			ip = msgvec;
		ip2 = ip;
		do {
			mp = &message[*ip2 - 1];
			if ((mp->m_flag & MDELETED) == 0) {
				dot = mp;
				goto hitit;
			}
			if (*ip2 != (int)NULL)
				ip2++;
			if (*ip2 == (int)NULL)
				ip2 = msgvec;
		} while (ip2 != ip);
		printf(ediag(
"No messages applicable\n",
"Нет подходящих писем\n"));
		return(1);
	}

	/*
	 * If this is the first command, select message 1.
	 * Note that this must exist for us to get here at all.
	 */

	if (!sawcom)
		goto hitit;

	/*
	 * Just find the next good message after dot, no
	 * wraparound.
	 */

	for (mp = dot+1; mp < &message[msgCount]; mp++)
		if ((mp->m_flag & (MDELETED|MSAVED)) == 0)
			break;
	if (mp >= &message[msgCount]) {
		printf(ediag("At EOF\n","Конец списка\n"));
		return(0);
	}
	dot = mp;
hitit:
	/*
	 * Print dot.
	 */

	list[0] = dot - &message[0] + 1;
	list[1] = (int)NULL;
	return(type(list));
}

/*
 * Save a message in a file.  Mark the message as saved
 * so we can discard when the user quits.
 */
save(str)
	char str[];
{

	return(save1(str, 1));
}

/*
 * Copy a message to a file without affected its saved-ness
 */
copycmd(str)
	char str[];
{

	return(save1(str, 0));
}

/*
 * Save/copy the indicated messages at the end of the passed file name.
 * If mark is true, mark the message "saved."
 */
save1(str, mark)
	char str[];
{
	register int *ip, mesg;
	register struct message *mp;
	char *file, *disp, *cmd;
	int f, *msgvec;
	long lc, t;
	long cc;
	FILE *obuf;
	struct stat statb;
	char *vbuf;

	cmd = mark ? "save" : "copy";
	msgvec = (int *) salloc((msgCount + 2) * sizeof *msgvec);
	if ((file = snarf(str, &f)) == NOSTR)
		return(1);
	if (!f) {
		*msgvec = first(0, MMNDEL);
		if (*msgvec == (int)NULL) {
			printf(ediag(
"No messages to %s\n",
"Не задан список писем для команды \"%s\"\n"),
cmd);
			return(1);
		}
		msgvec[1] = (int)NULL;
	}
	if (f && getmsglist(str, msgvec, 0) < 0)
		return(1);
	if ((file = expand(file)) == NOSTR)
		return(1);
	if (isdir(file)) {
		fprintf(stderr, ediag("%s is a directory\n",
				      "%s -- каталог\n"), file);
		return(1);
	}
	printf("\"%s\" ", file);
	flush();
	if (stat(file, &statb) >= 0)
		disp = ediag("[Appended]","[добавлено]");
	else
		disp = ediag("[New file]","[новый файл]");
#ifdef  MSDOS
	if ((obuf = Fopen(file, "a")) == NULL) {
		perror(NOSTR);
		return(1);
	}
	Fclose(obuf);
	file_lock(file, -1);
#endif
#ifndef MSDOS
	if ((obuf = Fopen(file, "a")) == NULL) {
#else
	if ((obuf = Fopen(file, "r+b")) == NULL) {
#endif
		perror(NOSTR);
#ifdef  MSDOS
		file_unlock();
#endif
		return(1);
	}
	file_lock(file, fileno(obuf));
	vbuf = BestBuffer(obuf);
#ifdef  MSDOS
	seekctlz(obuf);
#endif
	cc = 0;
	lc = 0;
	for (ip = msgvec; *ip && ip-msgvec < msgCount; ip++) {
		mesg = *ip;
		touch(mesg);
		mp = &message[mesg-1];
		if ((t = send(mp, obuf, SF_BINARY)) < 0)
			goto err;
		lc += t;
		cc += mp->m_size;
		if (mark)
			mp->m_flag |= MSAVED;
	}
	(void) fflush(obuf);
	if (ferror(obuf)) {
err:
		ioerror(NOSTR, 1);
#ifndef MSDOS
		file_unlock();
#endif
		Fclose(obuf);
#ifdef  MSDOS
		file_unlock();
#endif
		if (vbuf != NULL)
			free(vbuf);
		return(1);
	}
#ifndef MSDOS
	file_unlock();
#endif
	Fclose(obuf);
#ifdef  MSDOS
	file_unlock();
#endif
	if (vbuf != NULL)
		free(vbuf);
	printf("%s %ld/%ld\n", disp, lc, cc);
	return(0);
}

/*
 * Write the indicated messages at the end of the passed
 * file name, minus header and trailing blank line.
 */

swrite(str)
	char str[];
{
	register int *ip, mesg;
	register struct message *mp;
	register char *file, *disp;
	char line[LINESIZE];
	int f, *msgvec, body;
	long lc, cc, t;
	FILE *obuf, *mesf;
	struct stat statb;
	char *vbuf;

	msgvec = (int *) salloc((msgCount + 2) * sizeof *msgvec);
	if ((file = snarf(str, &f)) == NOSTR)
		return(1);
	if ((file = expand(file)) == NOSTR)
		return(1);
	if (isdir(file)) {
		fprintf(stderr, ediag("%s is a directory\n",
				      "%s -- каталог\n"), file);
		return(1);
	}
	if (!f) {
		*msgvec = first(0, MMNDEL);
		if (*msgvec == (int)NULL) {
			printf(ediag(
"No messages to \"write\".\n",
"Не задан список писем для команды \"write\".\n"));
			return(1);
		}
		msgvec[1] = (int)NULL;
	}
	if (f && getmsglist(str, msgvec, 0) < 0)
		return(1);
	printf("\"%s\" ", file);
	flush();
	if (stat(file, &statb) >= 0)
		disp = ediag("[Appended]","[добавлено]");
	else
		disp = ediag("[New file]","[новый файл]");
	if ((obuf = Fopen(file, "a")) == NULL) {
		perror(NOSTR);
		return(1);
	}
	vbuf = BestBuffer(obuf);
	cc = lc = 0;
	for (ip = msgvec; *ip && ip-msgvec < msgCount; ip++) {
		mesg = *ip;
		touch(mesg);
		mp = &message[mesg-1];
		mesf = setinput(mp);
		t = mp->m_lines - 2;
		readline(mesf, line);   /* Get rid of first line */
		body = 0;
		while (t-- > 0) {
			if (fgets(line, sizeof(line), mesf) == NOSTR)
				goto err;
			if (!body && *line == '\n')
				body = 1;
			else if (body) {
				lc++;
				cc += strlen(line);
				fputs(line, obuf);
				if (ferror(obuf))
					goto err;
			}
		}
		mp->m_flag |= MSAVED;
	}
	if (fflush(obuf) == EOF) {
	err:
		ioerror(NOSTR, 1);
		Fclose(obuf);
		if (vbuf != NULL)
			free(vbuf);
		return(1);
	}
	Fclose(obuf);
	if (vbuf != NULL)
		free(vbuf);
	printf("%s %ld/%ld\n", disp, lc, cc);
	return(0);
}

/*
 * Snarf the file from the end of the command line and
 * return a pointer to it.  If there is no file attached,
 * just return NOSTR.  Put a null in front of the file
 * name so that the message list processing won't see it,
 * unless the file name is the only thing on the line, in
 * which case, return 0 in the reference flag variable.
 */

char *
snarf(linebuf, flag)
	char linebuf[];
	int *flag;
{
	register char *cp;

	*flag = 1;
	cp = strlen(linebuf) + linebuf - 1;

	/*
	 * Strip away trailing blanks.
	 */

	while (*cp == ' ' && cp > linebuf)
		cp--;
	*++cp = 0;

	/*
	 * Now search for the beginning of the file name.
	 */

	while (cp > linebuf && !any(*cp, "\t "))
		cp--;
	if (*cp == '\0') {
		printf(ediag(
"No file specified\n",
"Не указан файл\n"));
		return(NOSTR);
	}
	if (any(*cp, " \t"))
		*cp++ = 0;
	else
		*flag = 0;
	return(cp);
}

/*
 * Delete messages.
 */

delete(msgvec)
	int msgvec[];
{
	return(delm(msgvec));
}

/*
 * Delete messages, then type the new dot.
 */

deltype(msgvec)
	int msgvec[];
{
	int list[2];

	if (delm(msgvec) >= 0) {
		list[0] = dot - &message[0];
		list[0]++;
		touch(list[0]);
		list[1] = (int)NULL;

		return type(list);
	}
	else {
		printf(ediag("No more messages\n","Больше нет писем\n"));

		return(0);
	}
}

/*
 * Delete the indicated messages.
 * Set dot to some nice place afterwards.
 * Internal interface.
 */

delm(msgvec)
	int *msgvec;
{
	register struct message *mp;
	register *ip, mesg;
	int last;

	last = (int)NULL;
	for (ip = msgvec; *ip != (int)NULL; ip++) {
		mesg = *ip;
		touch(mesg);
		mp = &message[mesg-1];
		mp->m_flag |= MDELETED|MTOUCH;
		mp->m_flag &= ~(MPRESERVE|MSAVED/*|MBOX*/);
		last = mesg;
	}
	if (last != (int)NULL) {
		dot = &message[last-1];
		last = first(0, MMNDEL);
		if (last != (int)NULL) {
			dot = &message[last-1];
			return(0);
		}
		else {
			dot = &message[0];
			return(-1);
		}
	}

	/*
	 * Following can't happen -- it keeps lint happy
	 */

	return(-1);
}

/*
 * Undelete the indicated messages.
 */

void
undelete(msgvec)
	int *msgvec;
{
	register struct message *mp;
	register *ip, mesg;

	for (ip = msgvec; ip-msgvec < msgCount; ip++) {
		mesg = *ip;
		if (mesg == 0)
			return;
		touch(mesg);
		mp = &message[mesg-1];
		dot = mp;
		mp->m_flag &= ~MDELETED;
	}
}

/*
 * Interactively dump core on "core"
 */

core()
{
	register int pid;
	int status;

#ifndef MSDOS
	if ((pid = vfork()) == -1) {
		perror("fork");
		return(1);
	}
	if (pid == 0) {
		abort();
		_exit(1);
	}
#endif
	printf(ediag("Okie dokie!", "Захотели -- получили!"));
	flush();
#ifndef MSDOS
	while (wait(&status) != pid)
		;
	if (status & 0200)
		fprintf(stderr, ediag(" -- Core dumped\n"," -- Память дампирована\n"));
	else
		printf("\n");
#else
	abort();
	_exit(1);
#endif
}

/*
 * Clobber as many bytes of stack as the user requests.
 */
clobber(argv)
	char **argv;
{
	register int times;

	if (argv[0] == 0)
		times = 1;
	else
		times = (atoi(argv[0]) + 511) / 512;
	clob1(times);
}

/*
 * Clobber the stack.
 */
static
void
clob1(n)
{
	char buf[512];
	register char *cp;

	if (n <= 0)
		return;
	for (cp = buf; cp < &buf[512]; *cp++ = 0xFF)
		;
	clob1(n - 1);
}

/*
 * Add the given header fields to the ignored list.
 * If no arguments, print the current list of ignored fields.
 */
igfield(list)
	char *list[];
{
	char field[BUFSIZ];
	register int h;
	register struct ignore *igp;
	char **ap;

	if (argcount(list) == 0)
		return(igshow());
	for (ap = list; *ap != 0; ap++) {
		if (isign(*ap))
			continue;
		istrcpy(field, *ap);
		h = hash(field);
		igp = (struct ignore *) calloc(1, sizeof (struct ignore));
		igp->i_field = calloc(strlen(field) + 1, sizeof (char));
		strcpy(igp->i_field, field);
		igp->i_link = ignore[h];
		ignore[h] = igp;
	}
	return(0);
}

/*
 * Print out all currently ignored fields.
 */
igshow()
{
	register int h, count;
	struct ignore *igp;
	char **ap, **ring;
	int igcomp();

	count = 0;
	for (h = 0; h < HSHSIZE; h++)
		for (igp = ignore[h]; igp != 0; igp = igp->i_link)
			count++;
	if (count == 0) {
		printf(ediag(
"No fields currently being ignored\n",
"Нет полей, которые сейчас игнорируются\n"));
		return(0);
	}
	ring = (char **) salloc((count + 1) * sizeof (char *));
	ap = ring;
	for (h = 0; h < HSHSIZE; h++)
		for (igp = ignore[h]; igp != 0; igp = igp->i_link)
			*ap++ = igp->i_field;
	*ap = 0;
	qsort(ring, count, sizeof (char *), igcomp);
	for (ap = ring; *ap != 0; ap++)
		printf("%s\n", *ap);
	return(0);
}

/*
 * Compare two names for sorting ignored field list.
 */
igcomp(l, r)
	char **l, **r;
{

	return(strcmp(*l, *r));
}

struct ADD_HLINE {
	struct ADD_HLINE *ah_next;       /* Next additional line */
	char             *ah_field;      /* Field */
	char             *ah_txt;        /* Text */
}
	*ahlines = NULL, *ahtail = NULL;

/*
 * Add a given line to all headers of new messages
 */
headline(list)
	char *list[];
{
	register struct ADD_HLINE *ah;
	struct ADD_HLINE *oah;
	char    *word;
	int     acnt;
	char    buf[BUFSIZ];
	char  **lscan;
	char   *p, *q;

	if( (acnt = argcount(list)) == 0 ) {
		/*
		 * Show all additional header lines
		 */
		for( ah = ahlines ; ah != NULL ; ah = ah->ah_next ) {
			strcpy(buf, ah->ah_field);
			strcat(buf, ": ");
			(void) fmt(buf, ah->ah_txt, stdout);
		}
		return 0;
	}
	word = list[0];

	/*
	 * Delete line from list
	 */
	oah = NULL;
	for( ah = ahlines ; ah != NULL ; ah = ah->ah_next ) {
		if( icequal(ah->ah_field, word) ) {
			if( oah == NULL )
				ahlines = ah->ah_next;
			else
				oah->ah_next = ah->ah_next;
			if( ah == ahtail )
				ahtail = oah;
			free(ah);
			break;
		}
		oah = ah;
	}

	if( acnt == 1 )
		return 0;

	/*
	 * Add a new line
	 */
	q = buf;
	lscan = &list[1];
	while( (p = *lscan++) != NULL ) {
		while( *q++ = *p++ );
		q--;
		*q++ = ' ';
	}
	*--q = '\0';

	p = (char *)malloc( strlen(word) + strlen(buf) + 2 +
			    sizeof(struct ADD_HLINE) );
	if( p == NULL )
		return 1;

	ah = (struct ADD_HLINE *)p;
	p += sizeof(struct ADD_HLINE);
	strcpy(p, word);
	ah->ah_field = p;
	p += strlen(word)+1;
	strcpy(p, buf);
	ah->ah_txt = p;
	ah->ah_next = NULL;

	if( ahlines == NULL )
		ahlines = ah;
	else
		ahtail->ah_next = ah;
	ahtail = ah;
	return 0;
}

/*
 * Print out all additional header lines
 */
int putaddhlines(of, resent)
	FILE *of;
{
	register struct ADD_HLINE *ah;
	char    oline[BUFSIZ];
	static char ofield[100] = "Resent-";
	register char *p, *q;
	char   *r;
	int lcnt = 0;
	extern char *udate(), *adate(), *r_name(),
		    *h_name(), *uniqueid(), *mailer();

	if( ahlines == NULL )
		return lcnt;
	for( ah = ahlines ; ah != NULL ; ah = ah->ah_next ) {
		q = oline;
		*q++ = ':';
		*q++ = ' ';
		p = ah->ah_txt;
		while( *p ) {
			if( *p == '$' ) {
				switch( *++p ) {
				    case 'd':   /* Unix Date */
					r = udate();
					break;

				    case 'a':   /* Arpa Date */
					r = adate();
					break;

				    case 'u':   /* User name */
					r = myname;
					break;

				    case 'r':   /* Real user name */
					r = r_name();
					break;

				    case 'h':   /* Official host name */
					r = h_name();
					break;

				    case 'i':   /* Unique ID */
					r = uniqueid();
					break;

				    case 'm':   /* Mailer version */
					r = mailer();
					break;

				    default:
					*q++ = '$';
				    case '$':
					*q++ = *p;
					continue;
				}
				p++;
				while( *q++ = *r++ ) ;
				q--;
				continue;
			}
			*q++ = *p++;
		}
		*q = '\0';
		if( resent ) {
			strcpy(&ofield[7], ah->ah_field);
			lcnt += fmt(ofield, oline, of);
		} else
			lcnt += fmt(ah->ah_field, oline, of);
	}
	return lcnt;
}


/*
 * Return the real user name
 */
char *r_name()
{
	static char pline[BUFSIZ];
	register char *p, *q;
#ifdef  GETPWENT
	struct passwd *pw;
#endif

	if( (p = value("realname")) != NOSTR
#ifdef  MSDOS
		|| (p = value("NAME")) != NOSTR
#endif
	   ) {
		strcpy(pline, p);
		return pline;
	}
	pline[0] = '\0';
#ifndef GETPWENT
	if ( getpwn(myname, pline) < 0 )
		goto ret;
	if( (p = index(pline, ':')) == NULL ||
		(p = index(p+1,   ':')) == NULL ||
		(p = index(p+1,   ':')) == NULL ||
		(p = index(p+1,   ':')) == NULL ||
		(q = index(p+1,   ':')) == NULL )
		goto ret;
	p++;
	*q = '\0';
#else   /* GETPWENT */
	if ((pw = getpwnam(myname)) == NULL)
		goto ret;
	p = pw->pw_gecos;
	if (p == NOSTR || !*p)
		goto ret;
	q = p + strlen(p);
#endif  /* GETPWENT */
	while( *--q == ' ' )
		*q = '\0';
	if( (q = index(p, ',')) != NOSTR ) {
		*q = '\0';
		while( *--q == ' ' )
			*q = '\0';
	}
	if (!*p) {
ret:
		strcpy(pline, myname);
		return pline;
	}
	return p;
}

/*
 * Return the official host name
 */
char *h_name()
{
#ifdef GETHOST
	static char host[70];

	gethostname(host, sizeof(host));
	return host;
#else
	return "";
#endif
}

/*
 * Return the unique name
 */
char *uniqueid()
{
	static char uq[11];
	static char ss[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_";
	static char zs[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	static unsigned ucntr = 0;
	unsigned long tt;
	unsigned pid = getpid();

#define nss     (sizeof ss - 1)         /* 64 */
#define nzs     (sizeof zs - 1)         /* 52 */

	if (ucntr == 0)
		ucntr = msgCount;
	if (ucntr ==  0)
		ucntr = uid;
	uq[0] = zs[ucntr % nzs];
	uq[1] = zs[(ucntr>>4) % nzs];
	ucntr++;
	time((time_t *)&tt);
	uq[2] = ss[ tt      % nss];
	uq[3] = ss[(tt>> 6) % nss];
	uq[4] = ss[(tt>>12) % nss];
	uq[5] = ss[(tt>>18) % nss];
	uq[6] = ss[(tt>>24) % nss];
	uq[7] = ss[((tt>>30)|(pid<<2)) % nss];
	uq[8] = ss[(pid>>4) % nss];
	uq[9] = ss[(pid>>8) % nss];

	return uq;
}

/*
 * Return mailer version
 */
char *mailer()
{
	extern char *os;
	extern revision, subrevision;
	static char buf[80];

	sprintf(buf, "Mail [v%d.%d %s]", revision, subrevision, os);
	return buf;
}

/* ENC is the basic 1 character encoding function to make a char printing */
#define ENC(c) ((c) ? ((c) & 077) + ' ': '`')
static void encode();
static void endec();
static int fr();

uuencode(name, in, out, lc, cc)
char *name;
FILE *in, *out;
long *lc, *cc;
{
	struct stat sbuf;
	int mode;

	/* figure out the input file mode */
	fstat(fileno(in), &sbuf);
	mode = sbuf.st_mode & 0777;

	fprintf(out, "begin %o %s\n", mode, name);
	encode(in, out, lc, cc);
	fprintf(out, "end\nsize %ld\n", fsize(in));
	fflush(out);

	return !ferror(out);
}

/*
 * copy from in to out, encoding as you go along.
 */
static
void
encode(in, out, lc, cc)
FILE *in, *out;
long *lc, *cc;
{
	char buf[80];
	int i, n;

	for (;;) {
		/* 1 (up to) 45 character line */
		n = fr(in, buf, 45);
		putc(ENC(n), out);
		(*cc)++;

		for (i=0; i<n; i += 3) {
			endec(&buf[i], out);
			(*cc)+=4;
		}

		putc('\n', out);
		(*cc)++;
		(*lc)++;
		if (n <= 0)
			break;
	}
}

/*
 * output one group of 3 bytes, pointed at by p, on file f.
 */
static
void
endec(p, f)
char *p;
FILE *f;
{
	int c1, c2, c3, c4;

	c1 = *p >> 2;
	c2 = (*p << 4) & 060 | (p[1] >> 4) & 017;
	c3 = (p[1] << 2) & 074 | (p[2] >> 6) & 03;
	c4 = p[2] & 077;
	putc(ENC(c1), f);
	putc(ENC(c2), f);
	putc(ENC(c3), f);
	putc(ENC(c4), f);
}

/* fr: like read but stdio */
static
int
fr(fd, buf, cnt)
FILE *fd;
char *buf;
int cnt;
{
	int c, i;

	for (i=0; i<cnt; i++) {
		c = getc(fd);
		if (c == EOF)
			return(i);
		buf[i] = c;
	}
	return (cnt);
}


/* single character decode */
#define DEC(c)	(((c) - ' ') & 077)
#define LENGTH	150
#define TRUE 1
#define FALSE 0

static void decode();
static void outdec();

int
fill_homedir(dest)
char *dest;
{
	char *sl, *el, *bl;
	char savename[128];
#ifdef  GETPWENT
	struct passwd *pw;
#else
	char linebuf[LINESIZE];
#endif

	sl = index(dest, '/');
#ifdef MSDOS
	el = index(dest, '\\');
	if (el != NOSTR && (sl == NOSTR || el < sl))
		sl = el;
#endif
	if (sl != NOSTR) {
		*sl++ = '\0';
		(void) strcpy(savename, sl);
	}
	else
		*savename = '\0';
	if (!*(dest + 1))
		strcat(dest + 1, myname);
#ifdef GETPWENT
	if ((pw = getpwnam(dest + 1)) == NULL) {
#else
	if (getpwn(dest + 1, linebuf) != 0) {
nouser:
#endif  /* !GETPWENT */
		fprintf(stderr, ediag("No such user as %s in this system\n",
				      "В этой системе нет пользователя %s\n"), dest + 1);
		return 0;
	}
#ifdef  GETPWENT
	bl = pw->pw_dir;
#else
	if ((bl = index(linebuf, ':')) == NOSTR ||
	    (bl = index(bl+1, ':')) == NOSTR ||
	    (bl = index(bl+1, ':')) == NOSTR ||
	    (bl = index(bl+1, ':')) == NOSTR ||
	    (bl = index(bl+1, ':')) == NOSTR ||
	    (el = index(++bl, ':')) == NOSTR)
		goto nouser;
#ifdef  MSDOS
	/* Skip disk:\catalog part */
	if ((*(el - 1) >= 'A' && *(el - 1) <= 'Z' ||
	     *(el - 1) >= 'a' && *(el - 1) <= 'z') &&
	     *(el + 1) == SEPCHAR
	    )
		if ((el = index(++el, ':')) == NOSTR)
			goto nouser;
#endif
	*el = '\0';
#ifdef  MSDOS
	if (!*bl) {
		mkfilename(linebuf, calldir, "public");
		bl = linebuf;
	}
#endif
#endif  /* !GETPWENT */
	el = copy(bl, dest);
	if (*savename) {
		*el++ = SEPCHAR;
		(void) copy(savename, el);
	}
#ifdef	MSDOS
	strlwr(dest);
#endif
	return 1;
}

int
uudecode(part, msg, buf, in, tail)
char *buf;
FILE *in;
off_t tail;
{
	static int mode;
	static char dest[128];
	static FILE *out = NULL;
	static char *vbuf = NULL;
	char *s2, *s1, *s0, *tmp_s;
	int length;
	static char s[3 * (LENGTH + 1)];
	static int echo_on, started, just_finished;
	static int line_length, lines_to_go;

Again:
	if (part & 1) {        /* First part */
		if (out != NULL) {
			Fclose(out);
			out = NULL;
		}
		if (vbuf != NULL) {
			free(vbuf);
			vbuf = NULL;
		}
		echo_on = started = TRUE;
		just_finished = FALSE;
		line_length = lines_to_go = 0;

		if (sscanf(buf, "begin %o %s", &mode, dest) != 2) {
			fprintf(stderr, ediag("Incorrect 'begin' line\n",
					      "Неверная строка 'begin'\n"));
			return 0;
		}

		/* handle ~user/file format */
		if (dest[0] == '~')
			if (!fill_homedir(dest))
				return 0;
		if (isdir(dest)) {
			fprintf(stderr, ediag("%s is a directory\n",
					      "%s -- каталог\n"),
					dest);
			return 0;
		}

		/* create output file */
#ifdef	MSDOS
		out = Fopen(dest, "wb");
#else
		out = Fopen(dest, "w");
#endif
		if (out == NULL) {
			perror(dest);
			return 0;
		}
		vbuf = BestBuffer(out);
	}

	s0 = s;
	s1 = s0 + (LENGTH + 1);
	s2 = s1 + (LENGTH + 1);

	s0[0] = s1[0] = s2[0] = '\0';  /* Clear strings */

	while (ftell(in) < tail) {

		if (fgets(s0, LENGTH, in) == NULL) {
			ioerror("mailbox", 0);
			break;
		}

		s0[LENGTH] = '\0';  /* Make sure string is terminated */

		if (just_finished)
		{
		  if (strncmp(s0, "size ", 5) == 0)
		  {
		    off_t file_size, l;

		    if (sscanf(s0 + 5, "%ld", &file_size) != 1)
			fprintf(stderr, ediag("Incorrect 'size' line\n",
					      "Неверная строка 'size'\n"));
		    else if ((l = sizef(dest)) == file_size) {
			if (intty && outtty && value("quiet") == NOSTR)
				printf(ediag("%s size %ld\n", "Длина %s %ld\n"),
				       dest, file_size);
		    }
		    else
			fprintf(stderr, ediag("%s size %ld must be %ld\n",
					      "Длина %s %ld, а должна быть %ld\n"),
					dest, l, file_size);
		    s0[0] = '\0';
		  }
		  just_finished = FALSE;
		}

		if (started) {
			length = strlen(s0);
			if (line_length == 0)
			  line_length = length;

			if (echo_on)
			{
			  lines_to_go = 0;
			  if (s0[0] != 'M' || length != line_length)
			  {
			    echo_on = FALSE;
			    lines_to_go = 2;  /* Lines to go before 'end' is expected */
			    if (s0[0] == ' ' || s0[0] == '`')
			      lines_to_go = 1;
			  }
			}
			else  /* !echo_on */
			{
			  if (s0[0] == 'M' && length == line_length)
			    echo_on = TRUE;
			  else if (lines_to_go > 0)
			  {
			    if (lines_to_go == 2)
			    {
			      if (s0[0] == ' ' || s0[0] == '`')
				lines_to_go = 1;
			      else
				lines_to_go = 0;  /* Unexpected line, so break off */
			    }
			    else if (lines_to_go == 1)
			    {
			      if (strcmp(s0, "end\n") == 0)
			      {
				decode(s2, out);
				decode(s1, out);
				fflush(out);
				if (ferror(out)) {
					ioerror(dest, 1);
					Fclose(out);
					out = NULL;
					if (vbuf != NULL) {
						free(vbuf);
						vbuf = NULL;
					}
					return 0;
				}
				Fclose(out);
				out = NULL;
				if (vbuf != NULL) {
					free(vbuf);
					vbuf = NULL;
				}

				chmod(dest, mode);  /* Change modes */

				lines_to_go = 0;  /* Done. Break off */
				just_finished = TRUE;
				started = FALSE;
			      }
			      else
				lines_to_go = 0;  /* Unexpected line, so break off */
			    }
			  }
			}
		}

		if (echo_on)
		{
		  decode(s0, out);
		  s0[0] = '\0';
		}
		else if (!started && strncmp(s0, "begin ", 6) == 0) {
			part |= 1;
			strcpy(buf, s0);
			goto Again;
		}

		tmp_s = s2;
		s2 = s1;
		s1 = s0;
		s0 = tmp_s;
	}

	if ((part & 2) && started) {                /* Last part */
		fprintf(stderr, ediag("No 'end' line in %d message\n",
				      "Нет строки 'end' в %d письме\n"), msg);
		Fclose(out);
		out = NULL;
		if (vbuf != NULL) {
			free(vbuf);
			vbuf = NULL;
		}
		return 0;
	}

	return (out == NULL) ? 2 : 1;
}

/*
 * copy from in to out, decoding as you go along.
 */
static
void
decode(buf, out)
FILE *out;
char *buf;
{
	char *bp;
	int n;

	n = DEC(buf[0]);
	if (n <= 0)
		return;

	bp = &buf[1];
	while (n > 0) {
		outdec(bp, out, n);
		bp += 4;
		n -= 3;
	}
}

/*
 * output a group of 3 bytes (4 input characters).
 * the input chars are pointed to by p, they are to
 * be output to file f.  n is used to tell us not to
 * output all of them at the end of the file.
 */
static
void
outdec(p, f, n)
char *p;
FILE *f;
{
	int c1, c2, c3;

	c1 = DEC(*p) << 2 | DEC(p[1]) >> 4;
	c2 = DEC(p[1]) << 4 | DEC(p[2]) >> 2;
	c3 = DEC(p[2]) << 6 | DEC(p[3]);
	if (n >= 1)
		putc(c1, f);
	if (n >= 2)
		putc(c2, f);
	if (n >= 3)
		putc(c3, f);
}


#if  0
extern char aliases[];
extern char *strtok();

static
void
LoadRealNameFromAliases(pline)
char *pline;
{
	FILE *ff;
	char buf[BUFSIZ];
	register char *token;

	if ((ff = Fopen(aliases, "r")) == NULL)
		return;
	while (fgets(buf, sizeof(buf), ff) != NULL) {
		token = strtok(buf, " \t\n");
		if (token == NULL)	/* Any data? */
			continue;	/* No --> read another line */
		if (token[0] == '#')
			continue;	/* Line is a comment; loop again */
		if (strcmp(token, myname) != 0)
			continue;
		if ((token = strtok(NULL, "\"")) != NULL) {
			strcpy(pline, token);
			break;
		}
	}
	Fclose(ff);
}
#endif

#ifdef	MSDOS
extern char calldir[];
int SpoolRemote = 0;

void
uuiocall(void)
{
	char buf[128];
	char *Shell;

	if (value("autocall") == NOSTR)
		return;
	if (!SpoolRemote)
		return;
	if (!intty || !outtty)
		return;
	printf(ediag("Do you want to call mail delivering program? (y/n) [y] ",
		     "Вызвать программу доставки почты? (y/n) [y] "));
	flush();
	(void) fgets(buf, sizeof(buf), stdin);
	if (*buf && *buf != '\n' && *buf != 'Y' && *buf != 'y')
		return;
	if ((Shell = value("SHELL")) == NOSTR)
		if ((Shell = value("COMSPEC")) == NOSTR)
			Shell = SHELL;
	(void) execlp(Shell, Shell, "/C", "UUPC.BAT", NULL);
	perror(Shell);
}

#endif  /* MSDOS */
