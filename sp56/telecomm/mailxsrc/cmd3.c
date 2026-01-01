/*
 * Mail -- a mail program
 *
 * Still more user commands.
 *
 * $Log:	cmd3.c,v $
 * Revision 1.17  93/01/04  02:13:00  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.16  92/08/24  02:16:15  ache
 * Основательные правки и перенос в разные системы
 * 
 * Revision 1.19  1991/12/31  01:47:11  ache
 * mp omitted in hfield
 *
 * Revision 1.18  1991/12/08  23:27:51  ache
 * Пропускается [NEWS] при [Rr]eply & newsgroups
 *
 * Revision 1.17  1991/07/22  16:36:47  ache
 * Port to Borland C
 *
 * Revision 1.16  1991/07/19  20:00:14  ache
 * Добавлена рассылка сообщений в телеконференции
 *
 * Revision 1.15  1991/01/25  18:04:45  ache
 * Убраны старые (4.1) сигналы
 *
 * Revision 1.14  90/09/21  21:58:05  ache
 * MS-DOS extends + some new stuff
 * 
 * Revision 1.13  90/09/13  13:18:28  ache
 * MS-DOS & Unix together...
 *
 * Revision 1.12  90/08/20  00:14:15  avg
 * Some patches.
 * 
 * Revision 1.11  90/08/16  17:31:38  avg
 * Добавлена команда forward.
 *
 * Revision 1.10  90/06/14  13:43:54  avg
 * Правлена команда Reply - не делался skin на Cc: .
 * 
 * Revision 1.9  90/06/10  00:41:13  avg
 * Добавлены команды @Reply и @reply.
 * 
 * Revision 1.8  90/05/31  19:43:19  avg
 * Правлены команды [Rr]espond, добавлена обработка Message-ID и
 * References:.
 * 
 * Revision 1.7  90/04/20  19:16:34  avg
 * Прикручено под System V
 *
 * Revision 1.6  88/08/23  16:35:27  avg
 * Сделан двуязычный help и правлены русские диагностики.
 * 
 * Revision 1.5  88/07/23  22:10:05  ache
 * теперь не берутся каталоги по "fi"
 *
 * Revision 1.4  88/07/23  20:30:54  ache
 * Русские диагностики
 *
 * Revision 1.3  88/02/19  16:02:13  avg
 * Для экономии памяти в поле m_size заменен long на unsigned
 * для машин типа pdp11.
 *
 * Revision 1.2  88/01/11  12:40:03  avg
 * Добавлен NOXSTR у rcsid.
 *
 * Revision 1.1  87/12/25  15:58:34  avg
 * Initial revision
 *
 */

#ifdef  MSDOS
#include        <process.h>
#endif
#include "rcv.h"
#include <sys/stat.h>

/*NOXSTR*/
static char rcsid[] = "$Header: cmd3.c,v 1.17 93/01/04 02:13:00 ache Exp $";
/*YESXSTR*/
extern char hlp[], rhelp[];
extern char *scalloc();
static void sort();
static char *reedit();

/*
 * Process a shell escape by saving signals, ignoring signals,
 * and forking a sh -c
 */

shell(str)
	char *str;
{
	sigtype (*sig[2])();
	int stat[1];
	register int t;
	char *Shell;
	char cmd[BUFSIZ];

	strcpy(cmd, str);
	if (bangexp(cmd) < 0)
		return(-1);
	if ((Shell = value("SHELL")) == NOSTR)
#ifndef MSDOS
		Shell = SHELL;
	for (t = 2; t < 4; t++)
		sig[t-2] = signal(t, SIG_IGN);
	t = vfork();
	if (t == 0) {
		for (t = 2; t < 4; t++)
			if (sig[t-2] != SIG_IGN)
				sigsys(t, SIG_DFL);
		execlp(Shell, Shell, "-c", cmd, NULL);
		perror(Shell);
		_exit(1);
	}
	while (wait(stat) != t)
		;
	if (t == -1)
		perror("fork");
	for (t = 2; t < 4; t++)
		signal(t, sig[t-2]);
#else
		if ((Shell = value("COMSPEC")) == NOSTR)
			Shell = SHELL;
	sig[0] = signal(SIGINT, SIG_IGN);
	sig[1] = signal(SIGQUIT, SIG_IGN);
	t = spawnlp (P_WAIT, Shell, "mail-shell", "/C", cmd, NULL);
	if (t < 0)
		perror(Shell);
	signal(SIGINT, sig[0]);
	signal(SIGQUIT, sig[1]);
#endif
	printf("!\n");
	return(0);
}

/*
 * Fork an interactive shell.
 */

dosh(str)
	char *str;
{
	sigtype (*sig[2])();
	int stat[1];
	register int t;
	char *Shell;

	if ((Shell = value("SHELL")) == NOSTR)
#ifndef MSDOS
		Shell = SHELL;
	for (t = 2; t < 4; t++)
		sig[t-2] = signal(t, SIG_IGN);
	t = vfork();
	if (t == 0) {
		for (t = 2; t < 4; t++)
			if (sig[t-2] != SIG_IGN)
				sigsys(t, SIG_DFL);
		execlp(Shell, Shell, NULL);
		perror(Shell);
		_exit(1);
	}
	while (wait(stat) != t)
		;
	if (t == -1)
		perror("fork");
	for (t = 2; t < 4; t++)
		signal(t, sig[t-2]);
#else
		if ((Shell = value("COMSPEC")) == NOSTR)
			Shell = SHELL;
	sig[0] = signal(SIGINT, SIG_IGN);
	sig[1] = signal(SIGQUIT, SIG_IGN);
	t = spawnlp (P_WAIT, Shell, "mail-shell", NULL);
	if (t < 0)
		perror(Shell);
	signal(SIGINT, sig[0]);
	signal(SIGQUIT, sig[1]);
#endif
	putchar('\n');
	return(0);
}

/*
 * Expand the shell escape by expanding unescaped !'s into the
 * last issued command where possible.
 */

char    lastbang[128];

bangexp(str)
	char *str;
{
	char bangbuf[BUFSIZ];
	register char *cp, *cp2;
	register int n;
	int changed = 0;

	cp = str;
	cp2 = bangbuf;
	n = BUFSIZ;
	while (*cp) {
		if (*cp == '!') {
			if (n < strlen(lastbang)) {
overf:
				printf(ediag(
"Command buffer overflow\n",
"Переполнился буфер команды\n"));
				return(-1);
			}
			changed++;
			strcpy(cp2, lastbang);
			cp2 += strlen(lastbang);
			n -= strlen(lastbang);
			cp++;
			continue;
		}
		if (*cp == '\\' && cp[1] == '!') {
			if (--n <= 1)
				goto overf;
			*cp2++ = '!';
			cp += 2;
			changed++;
		}
		if (--n <= 1)
			goto overf;
		*cp2++ = *cp++;
	}
	*cp2 = 0;
	if (changed) {
		printf("!%s\n", bangbuf);
		fflush(stdout);
	}
	strcpy(str, bangbuf);
	strncpy(lastbang, bangbuf, 128);
	lastbang[127] = 0;
	return(0);
}

/*
 * Print out a nice help message from some file or another.
 */

help()
{
	register c;
	register FILE *f;

	if ((f = Fopen(ediag(hlp, rhelp), "r")) == NULL) {
		perror(ediag(hlp, rhelp));
		return(1);
	}
	while ((c = getc(f)) != EOF)
		putchar(c);
	Fclose(f);
	return(0);
}

/*
 * Change user's working directory.
 */

schdir(str)
	char *str;
{
	register char *cp;

	for (cp = str; *cp == ' ' || *cp == '\t'; cp++)
		;
	if (*cp == '\0')
		cp = homedir;
	else
		if ((cp = expand(cp)) == NOSTR)
			return(1);
	if (!isdir(cp)) {
		fprintf(stderr, ediag("%s not a directory\n",
				      "%s не каталог\n"), cp);
		return(1);
	}
#ifdef  MSDOS
	if (changedir(cp) < 0) {
#else
	if (chdir(cp) < 0) {
#endif
		perror(cp);
		return(1);
	}
	return(0);
}

int uglyfromflag = 0;   /* Use ugly old-styled From line instead of From: */
int OnlyYou = 0;        /* Send reply only to you */
#define VALID_REF_LEN 512       /* Valid length of References: */

/*
 * Reply to a list of messages.  Extract each name from the
 * message header and send them off to mail1()
 */
XRespond(msgvec)
	int msgvec[];
{
	uglyfromflag = 1;
	Respond(msgvec);
	uglyfromflag = 0;
}

Respond(msgvec)
	int *msgvec;
{
	struct message *mp;
	char *cp, *cp2, *cp3, *rcv, *newsgroups;
	char **ap;
	static char buf[BUFSIZ];
	struct name *np;
	struct header head;
	int s;

	if (msgvec[1] != (int)NULL) {
		printf(ediag(
"Sorry, can't global reply to multiple messages at once, use \"reply\"\n",
"Нельзя глобально ответить на несколько писем сразу, используйте \"reply\"\n"));
		return(1);
	}
	mp = &message[msgvec[0] - 1];
	dot = mp;
	rcv = NOSTR;
	newsgroups = hfield("newsgroups", mp);
	if (newsgroups != NOSTR) {      /* News Reply */
		if ((rcv = value("news-server")) == NOSTR) {
			printf(ediag(
"Undefined value of 'news-server' variable\n",
"Не задано значение переменной 'news-server'\n"));
			return(1);
		}
		if ((cp = hfield("followup-to", mp)) != NOSTR)
			newsgroups = cp;
		newsgroups = savestr(newsgroups);
		head.h_to_template = savestr(rcv);
	}
	else {          /* Pure Reply */
		head.h_seq = 1;
		rcv = nameof(mp, FOR_reply);
		cp = hfield("to", mp);
		if (cp != NOSTR) {
			np = elide(extract(cp, GTO|GCOMMA));
			mapf(np, rcv);
			/*
			 * Delete my name from the reply list,
			 * and with it, all my alternate names.
			 */
			np = delname(np, myname, icequal);
			if (altnames)
				for (ap = altnames; *ap; ap++)
					np = delname(np, *ap, icequal);
			cp = detract(np, 0);
		}
		OnlyYou = (cp == NOSTR);
		s = strlen(rcv);
		if (cp != NOSTR)
			s += strlen(cp) + 2;
		cp2 = salloc(s + 1);
		cp3 = copy(rcv, cp2);
		if (cp != NOSTR) {
			cp3 = copy(", ", cp3);
			cp3 = copy(cp, cp3);
		}
		*cp3 = '\0';
		head.h_to_template = cp2;
	}

	head.h_bcc_template = NOSTR;

	head.h_cc_template = NOSTR;
	if (newsgroups == NOSTR) {
		cp = hfield("cc", mp);
		if (cp != NOSTR) {
			np = elide(extract(cp, GCC|GCOMMA));
			mapf(np, rcv);
			np = delname(np, myname, icequal);
			if (altnames != 0)
				for (ap = altnames; *ap; ap++)
					np = delname(np, *ap, icequal);
			head.h_cc_template = detract(np, 0);
			(void) make_to_list(&head);
			if (head.h_cc != NOSTR)
				OnlyYou = 0;
		}
	}

	head.h_subject = hfield("subject", mp);
	if (head.h_subject == NOSTR)
		head.h_subject = hfield("subj", mp);
	head.h_subject = reedit(head.h_subject);

	head.h_refs = NOSTR;
	s = 0;
	if ((cp2 = hfield("message-id", mp)) != NOSTR)
		s += strlen(cp2) + 1;
	if ((cp = hfield("references", mp)) != NOSTR)
		s += strlen(cp) + 1;
	if (s > 0) {
		head.h_refs = scalloc(s + 2);
		if (cp != NOSTR) {
			cp = copy(cp, head.h_refs);
			*cp++ = ' ';
		}
		else
			cp = head.h_refs;
		if (cp2 != NOSTR && !instr(head.h_refs, cp2)) {
			cp = copy(cp2, cp);
			*cp++ = ' ';
		}
		*--cp = '\0';
		while (strlen(head.h_refs) > VALID_REF_LEN)
			if ((head.h_refs = index(head.h_refs + 1, '<')) == NOSTR)
				break;
		if (head.h_refs != NOSTR && !*(head.h_refs))
			head.h_refs = NOSTR;
	}

	head.h_newsgroups = newsgroups;
	head.h_distribution = NOSTR;
	head.h_keywords = NOSTR;
	head.h_summary = NOSTR;
	if (newsgroups != NOSTR) {
		if ((cp = hfield("distribution", mp)) != NOSTR)
			head.h_distribution = savestr(cp);
		else
			head.h_distribution = "su";
		if ((cp = hfield("keywords", mp)) != NOSTR)
			head.h_keywords = savestr(cp);
		if ((cp = hfield("summary", mp)) != NOSTR)
			head.h_summary = savestr(cp);
	}

	head.h_inreplyto = NOSTR;
	rcv = nameof(mp, FOR_display);
	cp2 = hfield("message-id", mp);
	cp3 = hfield("date", mp);
	cp = buf;
	if (cp2 != NOSTR) {
		cp = copy(cp2, cp);
		cp = copy("; ", cp);
	}
	if (rcv != NOSTR) {
		cp = copy("from \"", cp);
		cp = copy(rcv, cp);
		cp = copy("\" ", cp);
	}
	if (cp3 != NOSTR) {
		cp = copy("at ", cp);
		cp = copy(cp3, cp);
		*cp++ = ' ';
	}
	if (cp != buf) {
		*--cp = '\0';
		head.h_inreplyto = savestr(buf);
	}

	head.h_resent = 0;
	mail1(&head);
	OnlyYou = 0;
	return(0);
}

submit(str)
char *str;
{
	char *rcv, *cp;
	struct header head;

	if ((rcv = value("news-server")) == NOSTR) {
		printf(ediag(
"Undefined value of 'news-server' variable\n",
"Не задано значение переменной 'news-server'\n"));
		return(1);
	}
	head.h_to_template = savestr(rcv);
	head.h_cc_template = NOSTR;
	head.h_bcc_template = NOSTR;

	head.h_newsgroups = NOSTR;
	if (str == NOSTR)
		goto Grab;
	for (cp = str; *cp == ' ' || *cp == '\t'; cp++)
		;
	if (*cp == '\0')
Grab:
		grabh(&head, GNGR);
	else
		head.h_newsgroups = savestr(cp);
	if (head.h_newsgroups == NOSTR) {
NoGR:
		printf(ediag("Newsgroup not setted\n",
			     "Не задана телеконференция\n"));
		return(1);
	}
	for (cp = head.h_newsgroups; *cp == ' ' || *cp == '\t'; cp++)
		;
	if (*cp == '\0')
		goto NoGR;
	head.h_newsgroups = cp;

	head.h_distribution = "su";
	head.h_keywords = NOSTR;
	head.h_summary = NOSTR;
	head.h_refs = NOSTR;
	head.h_subject = NOSTR;
	head.h_inreplyto = NOSTR;
	head.h_seq = 0;
	head.h_resent = 0;
	mail1(&head);
	return(0);
}

/*
 * Modify the subject we are replying to to begin with Re: if
 * it does not already.
 */

static
char *
reedit(subj)
	char *subj;
{
	char sbuf[10];
	register char *newsubj, *cp;

	if (subj == NOSTR)
		return(NOSTR);
Again:
	strncpy(sbuf, subj, 3);
	sbuf[3] = '\0';
	if (icequal(sbuf, "re:"))
		return(savestr(subj));

	strncpy(sbuf, subj, 7);
	sbuf[7] = '\0';
	if (icequal(sbuf, "[news] ")) {
		subj += 7;
		goto Again;
	}

	while (*subj == ' ' || *subj == '\t')
		subj++;
	if (!*subj)
		return(NOSTR);
	newsubj = salloc(strlen(subj) + 5);
	cp = copy("Re: ", newsubj);
	(void) copy(subj, cp);
	return(newsubj);
}

/*
 * Preserve the named messages, so that they will be sent
 * back to the system mailbox.
 */

preserve(msgvec)
	int *msgvec;
{
	register struct message *mp;
	register int *ip, mesg;

	if (edit) {
		printf(ediag(
"Cannot \"preserve\" in edit mode\n",
"Нельзя выполнить \"preserve\" в режиме редактирования\n"));
		return(1);
	}
	for (ip = msgvec; *ip != (int)NULL; ip++) {
		mesg = *ip;
		mp = &message[mesg-1];
		mp->m_flag |= MPRESERVE;
		mp->m_flag &= ~MBOX;
		dot = mp;
	}
	return(0);
}

/*
 * Print the size of each message.
 */

messize(msgvec)
	int *msgvec;
{
	register struct message *mp;
	register int *ip, mesg;

	for (ip = msgvec; *ip != (int)NULL; ip++) {
		mesg = *ip;
		mp = &message[mesg-1];
		printf("%d: %ld\n", mesg, (long)mp->m_size);
	}
	return(0);
}

/*
 * Quit quickly.  If we are sourcing, just pop the input level
 * by returning an error.
 */

rexit(e)
{
	if (sourcing)
		return(1);
	if (Tflag != NOSTR)
		fclear(Tflag);
	exit(e);
}

/*
 * Set or display a variable value.  Syntax is similar to that
 * of csh.
 */

set(arglist)
	char **arglist;
{
	register struct var *vp;
	register char *cp, *cp2;
	char varbuf[BUFSIZ], **ap, **p;
	int errs, h, s;

	if (argcount(arglist) == 0) {
		for (h = 0, s = 1; h < HSHSIZE; h++)
			for (vp = variables[h]; vp != NOVAR; vp = vp->v_link)
				s++;
		ap = (char **) salloc(s * sizeof *ap);
		for (h = 0, p = ap; h < HSHSIZE; h++)
			for (vp = variables[h]; vp != NOVAR; vp = vp->v_link)
				*p++ = vp->v_name;
		*p = NOSTR;
		sort(ap);
		for (p = ap; *p != NOSTR; p++)
			printf("%s\t%s\n", *p, value(*p));
		return(0);
	}
	errs = 0;
	for (ap = arglist; *ap != NOSTR; ap++) {
		cp = *ap;
		cp2 = varbuf;
		while (*cp != '=' && *cp != '\0')
			*cp2++ = *cp++;
		*cp2 = '\0';
		if (*cp == '\0')
			cp = "";
		else
			cp++;
		if (equal(varbuf, "")) {
			printf(ediag(
"Non-null variable name required\n",
"Требуется непустое имя переменной\n"));
			errs++;
			continue;
		}
		assign(varbuf, cp);
	}
	return(errs);
}

/*
 * Unset a bunch of variable values.
 */

unset(arglist)
	char **arglist;
{
	register struct var *vp, *vp2;
	register char *cp;
	int errs, h;
	char **ap;

	errs = 0;
	for (ap = arglist; *ap != NOSTR; ap++) {
		if ((vp2 = lookup(*ap)) == NOVAR) {
			if (!sourcing) {
				printf(ediag(
"\"%s\": undefined variable\n",
"\"%s\": неопределенная переменная\n"),
*ap);
				errs++;
			}
			continue;
		}
		if (equal(*ap, "MSG"))
			_setediag();
		else if(equal(*ap, "debug"))
			debug = 0;
		h = hash(*ap);
		if (vp2 == variables[h]) {
			variables[h] = variables[h]->v_link;
			vfree(vp2->v_name);
			vfree(vp2->v_value);
			cfree(vp2);
			continue;
		}
		for (vp = variables[h]; vp->v_link != vp2; vp = vp->v_link)
			;
		vp->v_link = vp2->v_link;
		vfree(vp2->v_name);
		vfree(vp2->v_value);
		cfree(vp2);
	}
	return(errs);
}

/*
 * Put add users to a group.
 */

group(argv)
	char **argv;
{
	register struct grouphead *gh;
	register struct group *gp;
	register int h;
	int s;
	char **ap, *gname, **p, *tail, *head;

	if (argcount(argv) == 0) {
		for (h = 0, s = 1; h < HSHSIZE; h++)
			for (gh = groups[h]; gh != NOGRP; gh = gh->g_link)
				s++;
		ap = (char **) salloc(s * sizeof *ap);
		for (h = 0, p = ap; h < HSHSIZE; h++)
			for (gh = groups[h]; gh != NOGRP; gh = gh->g_link)
				*p++ = gh->g_name;
		*p = NOSTR;
		sort(ap);
		for (p = ap; *p != NOSTR; p++)
			printgroup(*p);
		return(0);
	}
	if (argcount(argv) == 1) {
		printgroup(*argv);
		return(0);
	}
	gname = *argv;
	h = hash(gname);
	if ((gh = findgroup(gname)) == NOGRP) {
		gh = (struct grouphead *) calloc(sizeof *gh, 1);
		gh->g_name = vcopy(gname);
		gh->g_list = NOGE;
		gh->g_link = groups[h];
		groups[h] = gh;
	}

	/*
	 * Insert names from the command list into the group.
	 * Who cares if there are duplicates?  They get tossed
	 * later anyway.
	 */

	for (ap = argv+1; *ap != NOSTR; ap++) {
		for (head = *ap; any(*head, " \t,"); head++)
			;
		for (tail = head + strlen(head) - 1;
		     tail >= head && any(*tail, " \t,");
		     tail--
		    )
			*tail = '\0';
		if (!*head)
			continue;
		gp = (struct group *) calloc(sizeof *gp, 1);
		gp->ge_name = vcopy(head);
		gp->ge_link = gh->g_list;
		gh->g_list = gp;
	}
	return(0);
}

/*
 * Sort the passed string vecotor into ascending dictionary
 * order.
 */
static
void
sort(list)
	char **list;
{
	register char **ap;
	int diction();

	for (ap = list; *ap != NOSTR; ap++)
		;
	if (ap-list < 2)
		return;
	qsort(list, ap-list, sizeof *list, diction);
}

/*
 * Do a dictionary order comparison of the arguments from
 * qsort.
 */

diction(a, b)
	register char **a, **b;
{
	return(strcmp(*a, *b));
}

/*
 * The do nothing command for comments.
 */

null(e)
{
	return(0);
}

/*
 * Print out the current edit file, if we are editing.
 * Otherwise, print the name of the person who's mail
 * we are reading.
 */

file(argv)
	char **argv;
{
	register char *cp;
	char fname[BUFSIZ];
	int edit;

	if (argv[0] == NOSTR) {
		newfileinfo();
		return(0);
	}

	/*
	 * Acker's!  Must switch to the new file.
	 * We use a funny interpretation --
	 *      # -- gets the previous file
	 *      % -- gets the invoker's post office box
	 *      %user -- gets someone else's post office box
	 *      & -- gets invoker's mbox file
	 *      string -- reads the given file
	 */

	cp = getfilename(argv[0], &edit);
	if (cp == NOSTR)
		return(-1);
	if (setfile(cp, edit)) {
		perror(cp);
		return(-1);
	}
	newfileinfo();
}

/*
 * Evaluate the string given as a new mailbox name.
 * Ultimately, we want this to support a number of meta characters.
 */

char    prevfile[PATHSIZE];

char *
getfilename(name, aedit)
	char *name;
	int *aedit;
{
	register char *cp;

	/*
	 * Assume we will be in "edit file" mode, until
	 * proven wrong.
	 */
	*aedit = 1;
	switch (*name) {
	case '%':
		*aedit = 0;
		/* Fall... */
	default:
		if ((cp = expand(name)) != NOSTR) {
			if (isdir(cp)) {
				fprintf(stderr, ediag("%s is a directory\n",
						      "%s -- каталог\n"), cp);
				return(NOSTR);
			}
			strcpy(prevfile, mailname);
		}
		break;
	}
	return cp;
}

/*
 * Expand file names like echo
 */

echo(argv)
	char **argv;
{
	register char **ap;
	register char *cp;
	int noNL = 0;
	int first = 1;

	for (ap = argv; *ap != NOSTR; ap++) {
		cp = *ap;
		if (strcmp(cp, "-n") == 0) {
			noNL = 1;
			continue;
		}
		if ((cp = expand(cp)) != NOSTR) {
			if (!first)
				putchar(' ');
			fputs(cp, stdout);
		}
		first = 0;
	}
	if (!noNL)
		putchar('\n');
	return(0);
}

/*
 * Reply to a series of messages by simply mailing to the senders
 * and not messing around with the To: and Cc: lists as in normal
 * reply.
 */
Xrespond(msgvec)
	int msgvec[];
{
	uglyfromflag = 1;
	respond(msgvec);
	uglyfromflag = 0;
}

respond(msgvec)
	int msgvec[];
{
	struct header head;
	struct message *mp;
	register int s, *ap;
	register char *cp, *cp2, *cp3, *rcv, *subject;
	char buf[BUFSIZ];

	OnlyYou = (msgvec[1] == (int)NULL);

	s = 0;
	for (ap = msgvec; *ap != (int)NULL; ap++) {
		mp = &message[*ap - 1];
		dot = mp;
		s += strlen(nameof(mp, FOR_reply)) + 2;
	}
	if (s == 0)
		return(0);

	head.h_to_template = cp = salloc(s);
	for (ap = msgvec; *ap != (int)NULL; ap++) {
		mp = &message[*ap - 1];
		cp2 = nameof(mp, FOR_reply);
		cp = copy(cp2, cp);
		cp = copy(", ", cp);
	}
	cp -= 2;
	*cp = '\0';
	head.h_cc_template = NOSTR;
	head.h_bcc_template = NOSTR;

	mp = &message[msgvec[0] - 1];
	head.h_seq = 0;
	subject = hfield("subject", mp);
	if (subject == NOSTR)
		subject = hfield("subj", mp);
	head.h_subject = reedit(subject);
	if (head.h_subject != NOSTR)
		head.h_seq++;

	head.h_refs = NOSTR;
	s = 0;
	for (ap = msgvec; *ap != (int)NULL; ap++) {
		mp = &message[*ap - 1];
		if ((cp = hfield("message-id", mp)) != NOSTR)
			s += strlen(cp) + 1;
		if ((cp = hfield("references", mp)) != NOSTR)
			s += strlen(cp) + 1;
	}
	if (s > 0) {
		head.h_refs = cp = scalloc(s + 2);
		for (ap = msgvec; *ap != (int)NULL; ap++) {
			mp = &message[*ap - 1];
			if (   (cp2 = hfield("references", mp)) != NOSTR
			    && !instr(head.h_refs, cp2)
			   ) {
				cp = copy(cp2, cp);
				*cp++ = ' ';
			}
		}
		for (ap = msgvec; *ap != (int)NULL; ap++) {
			mp = &message[*ap - 1];
			if (   (cp2 = hfield("message-id", mp)) != NOSTR
			    && !instr(head.h_refs, cp2)
			   ) {
				cp = copy(cp2, cp);
				*cp++ = ' ';
			}
		}
		*--cp = '\0';
		while (strlen(head.h_refs) > VALID_REF_LEN)
			if ((head.h_refs = index(head.h_refs + 1, '<')) == NOSTR)
				break;
		if (head.h_refs != NOSTR && !*(head.h_refs))
			head.h_refs = NOSTR;
	}

	head.h_newsgroups = NOSTR;
	head.h_distribution = NOSTR;
	head.h_keywords = NOSTR;
	head.h_summary = NOSTR;
	head.h_inreplyto = NOSTR;

	if (OnlyYou) {
		mp = &message[*msgvec - 1];
		rcv = nameof(mp, FOR_display);
		cp2 = hfield("message-id", mp);
		cp3 = hfield("date", mp);
		cp = buf;
		if (cp2 != NOSTR) {
			cp = copy(cp2, cp);
			cp = copy("; ", cp);
		}
		if (rcv != NOSTR) {
			cp = copy("from \"", cp);
			cp = copy(rcv, cp);
			cp = copy("\" ", cp);
		}
		if (cp3 != NOSTR) {
			cp = copy("at ", cp);
			cp = copy(cp3, cp);
			*cp++ = ' ';
		}
		if (cp != buf) {
			*--cp = '\0';
			head.h_inreplyto = savestr(buf);
		}
	}

	head.h_resent = 0;
	mail1(&head);
	OnlyYou = 0;
	return(0);
}

/*
 * Conditional commands.  These allow one to parameterize one's
 * .mailrc and do some things if sending, others if receiving.
 */

ifcmd(argv)
	char **argv;
{
	register char *cp;

	if (cond != CANY) {
		printf(ediag(
"Illegal nested \"if\"\n",
"Неверная вложенность \"if\"\n"));
		return(1);
	}
	cond = CANY;
	cp = argv[0];
	switch (*cp) {
	case 'r': case 'R':
		cond = CRCV;
		break;

	case 's': case 'S':
		cond = CSEND;
		break;

	default:
		printf(ediag(
"Unrecognized if-keyword: \"%s\"\n",
"Неверное слово для if: \"%s\"\n"),
cp);
		return(1);
	}
	return(0);
}

/*
 * Implement 'else'.  This is pretty simple -- we just
 * flip over the conditional flag.
 */

elsecmd()
{

	switch (cond) {
	case CANY:
		printf(ediag(
"\"Else\" without matching \"if\"\n",
"\"Else\" без \"if\"\n"));
		return(1);

	case CSEND:
		cond = CRCV;
		break;

	case CRCV:
		cond = CSEND;
		break;

	default:
		printf(ediag(
"Mail's idea of conditions is screwed up\n",
"Обойдены соглашения Mail об условиях\n"));
		cond = CANY;
		break;
	}
	return(0);
}

/*
 * End of if statement.  Just set cond back to anything.
 */

endifcmd()
{

	if (cond == CANY) {
		printf(ediag(
"\"Endif\" without matching \"if\"\n",
"\"Endif\" без \"if\"\n"));
		return(1);
	}
	cond = CANY;
	return(0);
}

/*
 * Set the list of alternate names.
 */
alternates(namelist)
	char **namelist;
{
	register int c;
	register char **ap, **ap2, *cp;

	c = argcount(namelist) + 1;
	if (c == 1) {
		if (altnames == 0)
			return(0);
		for (ap = altnames; *ap; ap++)
			printf("%s ", *ap);
		printf("\n");
		return(0);
	}
	if (altnames != 0)
		cfree((char *) altnames);
	altnames = (char **) calloc(c, sizeof (char *));
	for (ap = namelist, ap2 = altnames; *ap; ap++, ap2++) {
		cp = (char *) calloc(strlen(*ap) + 1, sizeof (char));
		strcpy(cp, *ap);
		*ap2 = cp;
	}
	*ap2 = 0;
	return(0);
}
