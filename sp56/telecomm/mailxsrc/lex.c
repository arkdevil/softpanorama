/*
 * Mail -- a mail program
 *
 * Lexical processing of commands.
 *
 * $Log:	lex.c,v $
 * Revision 1.12  93/01/04  02:15:43  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.11  92/08/24  02:19:57  ache
 * Основательные правки и перенос в разные системы
 * 
 * Revision 1.17  1991/07/22  16:36:47  ache
 * Port to Borland C
 *
 * Revision 1.16  1991/04/19  22:48:42  asa
 * Изменения для Демос 32
 *
 * Revision 1.15  1991/01/25  18:04:45  ache
 * Убраны старые (4.1) сигналы
 *
 * Revision 1.14  1991/01/19  15:38:23  ache
 * убраны буфера 16к, как не оправдавшие доверия народа
 *
 * Revision 1.13  90/12/23  21:12:05  ache
 * Буферизация IO по 16 К
 * 
 * Revision 1.12  90/12/22  22:53:39  ache
 * Сортировка + выдача ФИО
 * 
 * Revision 1.11  90/12/07  07:15:16  ache
 * Переделана обработка временных файлов и мелочи
 * 
 * Revision 1.10  90/10/04  04:07:10  ache
 * Исправлена обработка #
 * 
 * Revision 1.9  90/09/21  21:58:57  ache
 * MS-DOS extends + some new stuff
 * 
 * Revision 1.8  90/09/13  13:19:30  ache
 * MS-DOS & Unix together...
 * 
 * Revision 1.7  90/06/14  13:44:37  avg
 * Добавлено обнуление uglyfromflag.
 * (перед выполнением команды).
 * 
 * Revision 1.6  90/04/20  19:16:55  avg
 * Прикручено под System V
 * 
 * Revision 1.5  88/07/24  15:11:17  ache
 * При source теперь не выдается по 10 раз приглашение
 * 
 * Revision 1.4  88/07/23  22:09:17  ache
 * Формат выдачи
 * 
 * Revision 1.3  88/07/23  20:34:18  ache
 * Русские диагностики
 * 
 * Revision 1.2  88/01/11  12:42:41  avg
 * Добавлен NOXSTR у rcsid.
 * 
 * Revision 1.1  87/12/25  15:59:42  avg
 * Initial revision
 *
 */

#include "rcv.h"

/*NOXSTR*/
static char rcsid[] = "$Header: lex.c,v 1.12 93/01/04 02:15:43 ache Exp $";
/*YESXSTR*/

#ifndef MSDOS
sigtype hangup();
#endif
#ifdef  SIGCONT
sigtype contin();
#endif
sigtype stop();
extern char *BestBuffer(), *cnts();

char    *prompt = "& ";

/*
 * Set up editing on the given file name.
 * If isedit is true, we are considered to be editing the file,
 * otherwise we are reading our mail which has signficance for
 * mbox and so forth.
 */

setfile(name, isedit)
	char *name;
{
	FILE *ibuf;
	char *vbuf;
	int i;
	static int shudclob;
	static char efile[128];
	extern char tempMesg[];

/* Not permanently open here, because of lock problems... */
#ifndef	MSDOS
	if ((ibuf = Fopen(name, "r")) == NULL)
#else
	if ((ibuf = Fopen(name, "rb")) == NULL)
#endif
		return(-1);
	else
		Fclose(ibuf);   /* Not now... */

	/*
	 * Looks like all will be well.  We must now relinquish our
	 * hold on the current set of stuff.  Must hold signals
	 * while we are reading the new file, else we will ruin
	 * the message[] data structure.
	 */

	holdsigs();
	if (shudclob) {
		if (edit)
			edstop();
		else
			quit();
	}

	/*
	 * Copy the messages into /tmp
	 * and set pointers.
	 */

	readonly = 0;
	if ((i = open(name, 1)) < 0)
		readonly++;
	else
		close(i);
	if (shudclob)
		TmpDel(tf);
	shudclob = 1;
	edit = isedit;
	strncpy(efile, name, 128);
	editfile = efile;
	if (name != mailname)
		strcpy(mailname, name);
#ifdef  MSDOS
	maketemp(tempMesg);
#endif
	if (   fclear(tempMesg) < 0
#ifndef	UNPACK_MAILBOX
#ifndef	MSDOS
		|| (tf = TmpOpen(tempMesg, "a+")) == NULL
#else
		|| (tf = TmpOpen(tempMesg, "a+b")) == NULL
#endif
#else	/* UNPACK_MAILBOX */
#ifndef	MSDOS
		|| (tf = TmpOpen(tempMesg, "w+")) == NULL
#else
		|| (tf = TmpOpen(tempMesg, "w+b")) == NULL
#endif
#endif	/* UNPACK_MAILBOX */
	   ) {
		perror(tempMesg);
	Terr:
		remove(tempMesg);
		exit(1);
	}
#ifndef	MSDOS
	if ((ibuf = Fopen(name, "r")) == NULL) {
#else
	if ((ibuf = Fopen(name, "rb")) == NULL) {
#endif
		perror(name);
		goto Terr;
	}
	vbuf = BestBuffer(ibuf);
	mailsize = fsize(ibuf);
	setptr(ibuf);
	Fclose(ibuf);
	if (vbuf != NULL)
		free(vbuf);
	setmsize(msgCount);
	relsesigs();
	sawcom = 0;
	return(0);
}

/*
 * Interpret user commands one by one.  If standard input is not a tty,
 * print no prompt.
 */

int     *msgvec;

void
commands()
{
	int eofloop, shudprompt;
	register int n;
	char linebuf[LINESIZE];
	extern int uglyfromflag;

# ifdef SIGCONT
	sigset(SIGCONT, SIG_DFL);
# endif
	if (rcvmode && !sourcing) {
		if (signal(SIGINT, SIG_IGN) != SIG_IGN)
			signal(SIGINT, stop);
#ifndef MSDOS
		if (signal(SIGHUP, SIG_IGN) != SIG_IGN)
			signal(SIGHUP, hangup);
#endif
	}
	for (;;) {
		setexit();

		/*
		 * Print the prompt, if needed.  Clear out
		 * string space, and flush the output.
		 */

		if (!rcvmode && !sourcing)
			return;
		eofloop = 0;
top:
		shudprompt = intty && !sourcing;
		if (shudprompt) {
			printf(prompt);
			flush();
# ifdef SIGCONT
			sigset(SIGCONT, contin);
# endif
		} else
			flush();
		sreset();

		/*
		 * Read a line of commands from the current input
		 * and handle end of file specially.
		 */

		n = 0;
		for (;;) {
			uglyfromflag = 0;
			if (readline(input, &linebuf[n]) <= 0) {
				if (n != 0)
					break;
				if (loading)
					return;
				if (sourcing) {
					unstack();
					goto more;
				}
				if (value("ignoreeof") != NOSTR && shudprompt) {
					if (++eofloop < 25) {
						printf(ediag(
"Use \"quit\" to quit.\n",
"Используйте \"quit\" для выхода.\n"));
						goto top;
					}
				}
				if (edit)
					edstop();
				return;
			}
			if ((n = strlen(linebuf)) == 0)
				break;
			n--;
			if (linebuf[n] != '\\')
				break;
			linebuf[n++] = ' ';
		}
# ifdef SIGCONT
		sigset(SIGCONT, SIG_DFL);
# endif
		if (execute(linebuf, 0)) {
			signal(SIGINT, SIG_IGN);
			return;
		}
more:           ;
	}
}

/*
 * Execute a single command.  If the command executed
 * is "quit," then return non-zero so that the caller
 * will know to return back to main, if he cares.
 * Contxt is non-zero if called while composing mail.
 */

execute(linebuf, contxt)
	char linebuf[];
{
	char word[LINESIZE];
	char *arglist[MAXARGC];
	struct cmd *com;
	register char *cp, *cp2;
	register int c;
	int muvec[2];
	int edstop(), e;

	/*
	 * Strip the white space away from the beginning
	 * of the command, then scan out a word, which
	 * consists of anything except digits and white space.
	 *
	 * Handle ! escapes differently to get the correct
	 * lexical conventions.
	 */

	cp = linebuf;
	while (any(*cp, " \t"))
		cp++;
	if (*cp == '!') {
		if (sourcing) {
			printf(ediag(
"Can't \"!\" while sourcing\n",
"Нельзя \"!\" пока выполняется \"source\"\n"));
			unstack();
			return(0);
		}
		shell(cp+1);
		return(0);
	}
	cp2 = word;
	if (*cp == '#')
		*cp2++ = *cp++;
	else while (*cp && !any(*cp, " \t0123456789$#^.:/-+*'\""))
		*cp2++ = *cp++;
	*cp2 = '\0';

	/*
	 * Look up the command; if not found, bitch.
	 * Normally, a blank command would map to the
	 * first command in the table; while sourcing,
	 * however, we ignore blank lines to eliminate
	 * confusion.
	 */

	if (sourcing && equal(word, ""))
		return(0);
	com = lex(word);
	if (com == NONE) {
		printf(ediag(
"Unknown command: \"%s\"\n",
"Неверная команда: \"%s\"\n"),
word);
		if (loading)
			return(1);
		if (sourcing)
			unstack();
		return(0);
	}

	/*
	 * See if we should execute the command -- if a conditional
	 * we always execute it, otherwise, check the state of cond.
	 */

	if ((com->c_argtype & F) == 0)
		if (cond == CRCV && !rcvmode || cond == CSEND && rcvmode)
			return(0);

	/*
	 * Special case so that quit causes a return to
	 * main, who will call the quit code directly.
	 * If we are in a source file, just unstack.
	 */

	if (com->c_func == edstop && sourcing) {
		if (loading)
			return(1);
		unstack();
		return(0);
	}
	if (!edit && com->c_func == edstop)
		return(1);

	/*
	 * Process the arguments to the command, depending
	 * on the type he expects.  Default to an error.
	 * If we are sourcing an interactive command, it's
	 * an error.
	 */

	if (!rcvmode && (com->c_argtype & M) == 0) {
		printf(ediag(
"May not execute \"%s\" while sending\n",
"Нельзя выполнять \"%s\" во время посылки\n"),
		    com->c_name);
		if (loading)
			return(1);
		if (sourcing)
			unstack();
		return(0);
	}
	if (sourcing && (com->c_argtype & I) != 0) {
		printf(ediag(
"May not execute \"%s\" while sourcing\n",
"Нельзя выполнять \"%s\" во время выполнения \"source\"\n"),
		    com->c_name);
		if (loading)
			return(1);
		unstack();
		return(0);
	}
	if (readonly && (com->c_argtype & W) != 0) {
		printf(ediag(
"May not execute \"%s\" -- message file is read only\n",
"Нельзя выполнять \"%s\" -- почтовый ящик открыт только на чтение\n"),
		   com->c_name);
		if (loading)
			return(1);
		if (sourcing)
			unstack();
		return(0);
	}
	if (contxt && (com->c_argtype & R) != 0) {
		printf(ediag(
"Cannot recursively invoke \"%s\"\n",
"Нельзя рекурсивно вызывать \"%s\"\n"),
com->c_name);
		return(0);
	}
	e = 1;
	switch (com->c_argtype & ~(F|P|I|M|T|W|R)) {
	case MSGLIST:
		/*
		 * A message list defaulting to nearest forward
		 * legal message.
		 */
		if (msgvec == 0) {
			printf(ediag(
"Illegal use of message list\n",
"Нельзя использовать здесь список писем\n"));
			return(-1);
		}
		if ((c = getmsglist(cp, msgvec, com->c_msgflag)) < 0)
			break;
		if (c  == 0) {
			*msgvec = first(com->c_msgflag,
				com->c_msgmask);
			if (*msgvec != (int)NULL)
				msgvec[1] = (int)NULL;
		}
		if (*msgvec == (int)NULL) {
			printf(ediag(
"No applicable messages\n",
"Нет подходящих писем\n"));
			break;
		}
		e = (*com->c_func)(msgvec);
		break;

	case NDMLIST:
		/*
		 * A message list with no defaults, but no error
		 * if none exist.
		 */
		if (msgvec == 0) {
			printf(ediag(
"Illegal use of message list\n",
"Неверное использование списка писем\n"));
			return(-1);
		}
		if (getmsglist(cp, msgvec, com->c_msgflag) < 0)
			break;
		e = (*com->c_func)(msgvec);
		break;

	case STRLIST:
		/*
		 * Just the straight string, with
		 * leading blanks removed.
		 */
		while (any(*cp, " \t"))
			cp++;
		e = (*com->c_func)(cp);
		break;

	case RAWLIST:
		/*
		 * A vector of strings, in shell style.
		 */
		if ((c = getrawlist(cp, arglist)) < 0)
			break;
		if (c < com->c_minargs) {
			printf(ediag(
"%s requires at least %d arg(s)\n",
"%s предполагает по меньшей мере %d аргументов\n"),
				com->c_name, com->c_minargs);
			break;
		}
		if (c > com->c_maxargs) {
			printf(ediag(
"%s takes no more than %d arg(s)\n",
"%s воспринимает не больше чем %d аргументов\n"),
				com->c_name, com->c_maxargs);
			break;
		}
		e = (*com->c_func)(arglist);
		break;

	case NOLIST:
		/*
		 * Just the constant zero, for exiting,
		 * eg.
		 */
		e = (*com->c_func)(0);
		break;

	default:
		panic(ediag("Unknown argtype",
			    "Неизвестный тип аргументов"));
	}

	/*
	 * Exit the current source file on
	 * error.
	 */

	if (e && loading)
		return(1);
	if (e && sourcing)
		unstack();
	if (com->c_func == edstop)
		return(1);
	if (value("autoprint") != NOSTR && (com->c_argtype & P) != 0)
		if ((dot->m_flag & MDELETED) == 0) {
			muvec[0] = dot - &message[0] + 1;
			muvec[1] = 0;
			type(muvec);
		}
	if (!sourcing && (com->c_argtype & T) == 0)
		sawcom = 1;
	return(0);
}

#ifdef  SIGCONT
/*
 * When we wake up after ^Z, reprint the prompt.
 */
sigtype contin(s)
{
#ifdef SVR3
	if (s == SIGCONT) {
		sigset (s, SIG_DFL);
		kill (getpid(), s);
		sigset (s, contin);
	}
#endif
	printf(prompt);
	flush();
}
#endif

#ifndef MSDOS
/*
 * Branch here on hangup signal and simulate quit.
 */
sigtype hangup(s)
{

	holdsigs();
	if (setexit())
		goto ex;
	if (rcvmode)
		stop(s);
ex:
#ifndef ATEXIT
	file_unlock();
#endif
	exit(1);
}
#endif

/*
 * Set the size of the message vector used to construct argument
 * lists to message list functions.
 */

setmsize(sz)
{

	if (msgvec != NULL)
		cfree(msgvec);
	msgvec = (int *) calloc((unsigned) (sz + 1), sizeof *msgvec);
	if (msgvec == NULL)
		panic(ediag("No memory for mesg list",
			    "Нет памяти для списка писем"));
}

/*
 * Find the correct command in the command table corresponding
 * to the passed command "word"
 */

struct cmd *
lex(word)
	char word[];
{
	register struct cmd *cp;
	extern struct cmd cmdtab[];

	for (cp = &cmdtab[0]; cp->c_name != NOSTR; cp++)
		if (isprefix(word, cp->c_name))
			return(cp);
	return(NONE);
}

/*
 * Determine if as1 is a valid prefix of as2.
 * Return true if yep.
 */

isprefix(as1, as2)
	char *as1, *as2;
{
	register char *s1, *s2;

	s1 = as1;
	s2 = as2;
	while (*s1++ == *s2)
		if (*s2++ == '\0')
			return(1);
	return(*--s1 == '\0');
}

/*
 * The following gets called on receipt of a rubout.  This is
 * to abort printout of a command, mainly.
 * Dispatching here when command() is inactive crashes rcv.
 * Close all open files except 0, 1, 2, and the temporary.
 * The special call to getuserid() is needed so it won't get
 * annoyed about losing its open file.
 * Also, unstack all source files.
 */

int     inithdr;                        /* am printing startup headers */

sigtype stop(s)
{
	register FILE *fp;

	noreset = 0;
	if (!inithdr)
		sawcom++;
	inithdr = 0;
	while (sourcing)
		unstack();
	getuserid((char *) -1);
#ifndef MSDOS
	if (pipef != NULL) {
		pclose(pipef);
		pipef = NULL;
		signal(SIGPIPE, SIG_DFL);
	}
#endif
	TmpDelAll();
	close_all_files();
	file_unlock();
	clrbuf(stdout);
	fprintf(stderr, ediag("Interrupt\n","Прерывание\n"));
	signal(s, stop);
	reset(0);
}

/*
 * Announce the presence of the current Mail version,
 * give the message count, and print a header listing.
 */
extern int revision, subrevision;
static char    *e_greeting       = "Mail v%d.%d  Type ? for help, 'list' for command list.\n";
static char    *r_greeting       = "Почта v%d.%d  Наберите ? для подсказки, 'list' для списка команд.\n";

title()
{
	if (   !noheader
	    && value("quiet") == NOSTR
	    && value("noheader") == NOSTR
	   )
		printf(ediag(e_greeting,r_greeting), revision, subrevision);
	flush();
}

announce()
{
	int vec[2], mdot;

	mdot = newfileinfo();
	vec[0] = mdot;
	vec[1] = 0;
	dot = &message[mdot - 1];
	if (msgCount > 0 && !noheader) {
		inithdr++;
		headers(vec);
		inithdr = 0;
	}
}

/*
 * Announce information about the file we are editing.
 * Return a likely place to set dot.
 */
newfileinfo()
{
	register struct message *mp;
	register int u, n, mdot, d, s;
	static char fname[BUFSIZ], zname[BUFSIZ], *ename;

	for (mp = &message[0]; mp < &message[msgCount]; mp++)
		if (mp->m_flag & MNEW)
			break;
	if (mp >= &message[msgCount])
		for (mp = &message[0]; mp < &message[msgCount]; mp++)
			if ((mp->m_flag & MREAD) == 0)
				break;
	if (mp < &message[msgCount])
		mdot = mp - &message[0] + 1;
	else
		mdot = 1;
	s = d = 0;
	for (mp = &message[0], n = 0, u = 0; mp < &message[msgCount]; mp++) {
		if (mp->m_flag & MNEW)
			n++;
		if ((mp->m_flag & MREAD) == 0)
			u++;
		if (mp->m_flag & MDELETED)
			d++;
		if (mp->m_flag & MSAVED)
			s++;
	}
	ename = mailname;
	if (getfold(fname) >= 0) {
		if (strncmp(fname, mailname, strlen(fname)) == 0) {
			sprintf(zname, "+%s", mailname + strlen(fname));
			ename = zname;
		}
	}
	printf("\"%s\": ", ename);
	if (msgCount == 0)
		printf(ediag("no messages", "нет писем"));
	else
		printf(ediag("%d message%s", "%d пис%s"),
		       msgCount,
		       cnts(msgCount, ediag("", "ьмо"), ediag("s", "ьма"), ediag("s", "ем"))
		      );
	if (n > 0)
		printf(ediag(", %d new",(n==1?", 1 новое":", %d новых")), n);
	if (u-n > 0)
		printf(ediag(", %d unread",(u==1?", 1 непрочитанное":", %d непрочитанных")), u);
	if (d > 0)
		printf(ediag(", %d deleted",(d==1?", 1 удаленное":", %d удаленных")), d);
	if (s > 0)
		printf(ediag(", %d saved",(s==1?", 1 записанное":", %d записанных")), s);
	if (readonly)
		printf(ediag(" [Read only]"," [Только чтение]"));
	putchar('\n');
	flush();
	return(mdot);
}

strace() {}

/*
 * Load a file of user definitions.
 */
void
load(name)
	char *name;
{
	register FILE *in, *oldin;

	if ((in = Fopen(name, "r")) == NULL)
		return;
	oldin = input;
	input = in;
	loading = 1;
	sourcing = 1;
	if (debug) fprintf(stderr, "Loading %s\n", name);
	commands();
	loading = 0;
	sourcing = 0;
	input = oldin;
	Fclose(in);
}
