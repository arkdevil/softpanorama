/*
 * Mail -- a mail program
 *
 * Auxiliary functions.
 *
 * $Log:	maux.c,v $
 * Revision 1.12  93/01/04  02:16:44  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.11  92/08/24  02:20:51  ache
 * Основательные правки и перенос в разные системы
 * 
 * Revision 1.17  1991/07/22  16:36:47  ache
 * Port to Borland C
 *
 * Revision 1.16  1991/04/19  22:49:39  asa
 * Изменения для Демос 32
 *
 * Revision 1.15  1991/01/18  02:18:26  ache
 * Добавлены переменные:
 * headerfield -- поле, выдаваемое по h
 * headername -- выдавать имя, а не адрес по h
 * 
 * Revision 1.14  90/12/25  03:52:50  ache
 * Правлена древняя ошибка с затиранием памяти
 *
 * Revision 1.13  90/12/22  22:55:08  ache
 * Сортировка + выдача ФИО
 * 
 * Revision 1.12  90/10/13  20:27:27  ache
 * long line count
 * 
 * Revision 1.11  90/09/29  18:22:15  ache
 * <ctype.h> kicked out...
 * 
 * Revision 1.10  90/09/21  21:59:24  ache
 * MS-DOS extends + some new stuff
 *
 * Revision 1.9  90/09/13  13:20:00  ache
 * MS-DOS & Unix together...
 * 
 * Revision 1.8  90/06/26  17:11:45  avg
 * Добавлено просекание вложенных скобок в комментариях по RFC822.
 * 
 * Revision 1.7  90/06/10  00:39:52  avg
 * Добавлена обработка команд @Reply @reply @from @headers.
 * 
 * Revision 1.6  90/06/05  20:09:24  avg
 * Правлена выдача команды headers.
 *
 * Revision 1.5  90/04/20  19:16:24  avg
 * Прикручено под System V
 * 
 * Revision 1.4  88/07/23  22:57:18  ache
 * теперь source без параметров читает .mailrc, а раньше бред
 * 
 * Revision 1.3  88/07/23  20:29:15  ache
 * Русские диагностики
 * 
 * Revision 1.2  88/01/11  12:38:31  avg
 * Добавлен NOXSTR у rcsid.
 *
 * Revision 1.1  87/12/25  15:58:12  avg
 * Initial revision
 * 
 */

#include "rcv.h"
#include <time.h>
#include <sys/stat.h>
#ifdef __TURBOC__
#include <io.h>
#include <fcntl.h>
#endif

/*NOXSTR*/
static char rcsid[] = "$Header: maux.c,v 1.12 93/01/04 02:16:44 ache Exp $";
/*YESXSTR*/
static long gethfield();
static char *name1();
char *canonada();

/*
 * Return a pointer to a dynamic copy of the argument.
 */

char *
savestr(str)
	char *str;
{
	register char *cp, *cp2, *top;

	for (cp = str; *cp; cp++)
		;
	top = salloc(cp-str + 1);
	if (top == NOSTR)
		return(NOSTR);
	for (cp = str, cp2 = top; *cp; cp++)
		*cp2++ = *cp;
	*cp2 = 0;
	return(top);
}

/*
 * Copy the name from the passed header line into the passed
 * name buffer.  Null pad the name buffer.
 */

copyname(linebuf, nbuf)
	char *linebuf, *nbuf;
{
	register char *cp, *cp2;

	for (cp = linebuf + 5, cp2 = nbuf; *cp != ' ' && cp2-nbuf < 8; cp++)
		*cp2++ = *cp;
	while (cp2-nbuf < 8)
		*cp2++ = 0;
}

/*
 * Announce a fatal error and die.
 */

panic(str)
	char *str;
{
	prs(ediag("panic: ","паника: "));
	prs(str);
	prs("\n");
	exit(1);
}

/*
 * Catch stdio errors and report them more nicely.
 */

_error(str)
	char *str;
{
	prs(ediag("Internal Error: ", "Внутренняя ошибка: "));
	prs(str);
	prs("\n");
	abort();
}

/*
 * Print a string on diagnostic output.
 */

prs(str)
	char *str;
{
	register char *s;

	for (s = str; *s; s++)
		;
	write(2, str, s-str);
}

/*
 * Touch the named message by setting its MTOUCH flag.
 * Touched messages have the effect of not being sent
 * back to the system mailbox on exit.
 */
void
touch(mesg)
{
	register struct message *mp;

	if (mesg < 1 || mesg > msgCount)
		return;
	mp = &message[mesg-1];
	mp->m_flag |= MTOUCH;
	if ((mp->m_flag & MREAD) == 0)
		mp->m_flag |= MREAD|MSTATUS;
}

/*
 * Test to see if the passed file name is a directory.
 * Return true if it is.
 */

isdir(name)
	char name[];
{
	struct stat sbuf;

	if (stat(name, &sbuf) < 0)
		return(0);
	return((sbuf.st_mode & S_IFMT) == S_IFDIR);
}

/*
 * Count the number of arguments in the given string raw list.
 */

argcount(argv)
	char **argv;
{
	register char **ap;

	for (ap = argv; *ap != NOSTR; ap++)
		;
	return(ap-argv);
}

#if 0
/*
 * Determine if the passed file is actually a tty, via a call to
 * gtty.  This is not totally reliable, but . . .
 */

isatty(f)
{
#ifdef M_SYSV
	struct termio buf;

	if (ioctl(f, TCGETA, &buf) < 0)
		return(0);
#else
	struct sgttyb buf;

	if (gtty(f, &buf) < 0)
		return(0);
#endif
	return(1);
}
#endif

/*
 * Return the desired header line from the passed message
 * pointer (or NOSTR if the desired header field is not available).
 */

char *
hfield(field, mp)
	char field[];
	struct message *mp;
{
	register FILE *ibuf;
	char linebuf[LINESIZE];
	long lc;

	if ((lc = mp->m_lines) <= 0)
		return(NOSTR);
	ibuf = setinput(mp);
	if (readline(ibuf, linebuf) < 0)        /* Skip first From */
		return(NOSTR);
	lc--;
	do {
		lc = gethfield(ibuf, linebuf, lc);
		if (lc < 0)
			return(NOSTR);
		if (ishfield(linebuf, field))
			return(savestr(hcontents(linebuf)));
	} while (lc > 0);
	return(NOSTR);
}

/*
 * Return the next header field found in the given message.
 * Return > 0 if something found, <= 0 elsewise.
 * Must deal with \ continuations & other such fraud.
 */

static
long
gethfield(f, linebuf, rem)
	register FILE *f;
	char linebuf[];
	long rem;
{
	char line2[LINESIZE];
	long loc;
	register char *cp, *cp2;
	register int c;


	for (;;) {
		if (rem <= 0)
			return(-1);
		if (readline(f, linebuf) < 0)
			return(-1);
		rem--;
		if (strlen(linebuf) == 0)
			return(-1);
		if (isspace(linebuf[0]))
			continue;
		if (linebuf[0] == '>')
			continue;
		cp = index(linebuf, ':');
		if (cp == NOSTR)
			continue;
		for (cp2 = linebuf; cp2 < cp; cp2++)
			if (isdigit(*cp2))
				continue;

		/*
		 * I guess we got a headline.
		 * Handle wraparounding
		 */

		for (;;) {
			if (rem <= 0)
				break;
#ifdef CANTELL
			loc = ftell(f);
			if (readline(f, line2) < 0)
				break;
			rem--;
			if (!isspace(line2[0])) {
				fseek(f, loc, 0);
				rem++;
				break;
			}
#else
			c = getc(f);
			ungetc(c, f);
			if (!isspace(c) || c == '\n')
				break;
			if (readline(f, line2) < 0)
				break;
			rem--;
#endif
			cp2 = line2;
			for (cp2 = line2; *cp2 && isspace(*cp2); cp2++)
				;
			if (strlen(linebuf) + strlen(cp2) >= LINESIZE-2)
				break;
			cp = &linebuf[strlen(linebuf)];
			while (cp > linebuf &&
			    (isspace(cp[-1]) || cp[-1] == '\\'))
				cp--;
			*cp++ = ' ';
			strcpy(cp, cp2);
		}
		if ((c = strlen(linebuf)) > 0) {
			cp = &linebuf[c-1];
			while (cp > linebuf && isspace(*cp))
				cp--;
			*++cp = '\0';
		}
		return(rem);
	}
	/* NOTREACHED */
}

/*
 * Check whether the passed line is a header line of
 * the desired breed.
 */

ishfield(linebuf, field)
	char linebuf[], field[];
{
	register char *cp;
	register int c;

	if ((cp = index(linebuf, ':')) == NOSTR)
		return(0);
	if (cp == linebuf)
		return(0);
	cp--;
	while (cp > linebuf && isspace(*cp))
		cp--;
	c = *++cp;
	*cp = 0;
	if (icequal(linebuf, field)) {
		*cp = c;
		return(1);
	}
	*cp = c;
	return(0);
}

/*
 * Extract the non label information from the given header field
 * and return it.
 */

char *
hcontents(hfield)
	char hfield[];
{
	register char *cp;

	if ((cp = index(hfield, ':')) == NOSTR)
		return(NOSTR);
	cp++;
	while (*cp && isspace(*cp))
		cp++;
	return(cp);
}

/*
 * Compare two strings, ignoring case.
 */

icequal(s1, s2)
	register char *s1, *s2;
{

	while (toupper(*s1++) == toupper(*s2))
		if (*s2++ == '\0')
			return(1);
	return(0);
}

/*
 * Copy a string, lowercasing it as we go.
 */
istrcpy(dest, src)
	char *dest, *src;
{
	register char *cp, *cp2;

	cp2 = dest;
	cp = src;
	do {
		*cp2++ = tolower(*cp);
	} while (*cp++ != 0);
}


char *upperstr(src)
char *src;
{
	char *s;
	register char *p;

	if (src == NOSTR || (s = savestr(src)) == NOSTR)
		return NOSTR;
	for (p = s; *p != '\0'; p++)
		*p = toupper(*p);
	return s;
}

/*
 * The following code deals with input stacking to do source
 * commands.  All but the current file pointer are saved on
 * the stack.
 */

#ifndef _NFILE
#define _NFILE  20
#endif

static  int     ssp = -1;               /* Top of file stack */
struct sstack {
	FILE    *s_file;                /* File we were in. */
	int     s_cond;                 /* Saved state of conditionals */
	int     s_loading;              /* Loading .mailrc, etc. */
} sstack[_NFILE];

/*
 * Pushdown current input file and switch to a new one.
 * Set the global flag "sourcing" so that others will realize
 * that they are no longer reading from a tty (in all probability).
 */

source(name)
	char *name;
{
	register FILE *fi;
	register char *cp;

	if (!name[0])
		name = mailrc;
	if ((cp = expand(name)) == NOSTR)
		return(1);
	if (isdir(cp)) {
		fprintf(stderr, ediag(
"%s is a directory\n",
"%s -- каталог\n"), cp);
		return(1);
	}
	if ((fi = Fopen(cp, "r")) == NULL) {
		perror(cp);
		return(1);
	}
	if (ssp >= _NFILE-2) {
		printf(ediag(
"Too much \"sourcing\" going on.\n",
"Слишком большая вложенность \"source\".\n"));
		Fclose(fi);
		return(1);
	}
	sstack[++ssp].s_file = input;
	sstack[ssp].s_cond = cond;
	sstack[ssp].s_loading = loading;
	loading = 0;
	cond = CANY;
	input = fi;
	sourcing++;
	return(0);
}

/*
 * Source a file, but do nothing if the file cannot be opened.
 */

source1(name)
	char name[];
{
	register int f;

	if ((f = open(name, 0)) < 0)
		return(0);
	close(f);
	source(name);
}

/*
 * Pop the current input back to the previous level.
 * Update the "sourcing" flag as appropriate.
 */

unstack()
{
	if (ssp < 0) {
		printf(ediag(
"\"Source\" stack over-pop.\n",
"Стэк \"source\" уже пуст.\n"));
		sourcing = 0;
		return(1);
	}
	Fclose(input);
	if (cond != CANY)
		printf(ediag(
"Unmatched \"if\"\n",
"Незакрытый \"if\"\n"));
	cond = sstack[ssp].s_cond;
	loading = sstack[ssp].s_loading;
	input = sstack[ssp--].s_file;
	if (ssp < 0)
		sourcing = loading;
	return(0);
}

/*
 * Touch the indicated file.
 * This is nifty for the shell.
 * If we have the utime() system call, this is better served
 * by using that, since it will work for empty files.
 * On non-utime systems, we must sleep a second, then read.
 */
void
alter(name)
	char name[];
{
#ifndef MSDOS
#ifdef  UTIME
	struct stat statb;
	long time();
	time_t time_p[2];
#else
	register f;
	char w;
#endif

#ifdef UTIME
	if (stat(name, &statb) < 0)
		return;
	time_p[0] = time((long *) 0) + 1;
	time_p[1] = statb.st_mtime;
	utime(name, time_p);
#else
	sleep(1);
	if ((f = open(name, 0)) < 0)
		return;
	read(f, &w, 1);
	close(f);
#endif
#endif  /*!MSDOS*/
}

/*
 * Examine the passed line buffer and
 * return true if it is all blanks and tabs.
 */

blankline(linebuf)
	char linebuf[];
{
	register char *cp;

	for (cp = linebuf; *cp; cp++)
		if (!any(*cp, " \t"))
			return(0);
	return(1);
}

/*
 * Get sender's name from this message.  If the message has
 * a bunch of arpanet stuff in it, we may have to skin the name
 * before returning it.
 */

extern InHeaderList;

char *
nameof(mp, reptype)
	register struct message *mp;
{
	register char *cp, *cp1, *cp2;
	char *cp3, *cp4;
	char myhost[80];
	char *head, *tail, *s;
	int quote;

	if (   InHeaderList
	    && reptype == FOR_display
	    && (s = value("headerfield")) != NOSTR
	   ) {
		if ((cp = hfield(s, mp)) == NOSTR)
			return "";
	}
	else
		cp = name1(mp, reptype);

	if (reptype != FOR_display)
		return cp;

	if (*cp && (!InHeaderList || value("headername") != NOSTR)) {

		/* Check for "phrase" <route> */
		if (   (cp2 = rindex(cp, '>')) != NOSTR
		    && (cp1 = rindex(cp, '<')) != NOSTR
		    && (   (cp3 = rindex(cp, ')')) == NOSTR
			|| cp3 < cp1
			|| (cp3 = rindex(cp, '(')) == NOSTR
			|| cp3 > cp2 && cp3[-1] != '\\'
		       )
		   ) {
			/* Skip leading blanks and quotas */
			quote = 0;
			for (head = cp; any(*head, " \t\""); head++) {
				if (*head == '"')
					quote = !quote;
			}
			/* Copy first part */
			for (tail = s = head;
			     *tail && !isdigit(*tail) && !any(*tail, ",<");
			     tail++
			    ) {
				if (s > head && isspace(*tail) && isspace(s[-1]))
					continue;
				if (*tail == '"' && (tail == head || tail[-1] != '\\')) {
					quote = !quote;
					if (s > head && !isspace(s[-1]))
						*s++ = ' ';
					continue;
				}
				if (*tail == ')' && (tail == head || tail[-1] != '\\'))
					continue;
				if (*tail == '(') {
					if (   quote
					    && *(tail + 1)
					    && (cp2 = rindex(tail + 1, ')')) != NOSTR
					    && (   (cp3 = index(tail + 1, '"')) == NOSTR
						|| cp3 > cp2 && cp3[-1] != '\\'
					       )
					   )
						tail = cp2;
					if (s > head && !isspace(s[-1]))
						*s++ = ' ';
					continue;
				}
				if (s > head && *tail == '-' && isspace(s[-1]))
					break;
				*s++ = *tail;
			}
			/* Skip trailing blanks */
			while (s > head && isspace(s[-1]))
				s--;
			if (s > head) {
				*s = '\0';
				return head;
			}
		}
		/* Looking for comment part */
		else if (   (head = index(cp, '(')) != NOSTR
			 && *(head + 1)
			 && (tail = rindex(head + 1, ')')) != NOSTR
			) {
			*tail = '\0';
			/* Skip leading blanks */
			for (head++; isspace(*head); head++)
				;
			for (tail = s = head;
			     *tail && !isdigit(*tail) && *tail != ',';
			     tail++
			    ) {
				if (s > head && isspace(*tail) && isspace(s[-1]))
					continue;
				if (*tail == '(' && (tail == head || tail[-1] != '\\')) {
					if (   *(tail + 1)
					    && (cp2 = rindex(tail + 1, ')')) != NOSTR
					   )
						tail = cp2;
					if (s > head && !isspace(s[-1]))
						*s++ = ' ';
					continue;
				}
				if (*tail == '"' && (tail == head || tail[-1] != '\\')) {
					if (   *(tail + 1)
					    && (cp2 = index(tail + 1, '"')) != NOSTR
					    && cp2[-1] != '\\'
					   )
						tail = cp2;
					if (s > head && !isspace(s[-1]))
						*s++ = ' ';
					continue;
				}
				if (*tail == ')' && (tail == head || tail[-1] != '\\'))
					continue;
				if (s > head && *tail == '-' && isspace(s[-1]))
					break;
				*s++ = *tail;
			}
			/* Skip trailing blanks */
			while (s > head && isspace(s[-1]))
				s--;
			if (s > head) {
				*s = '\0';
				return head;
			}
		}
	}
	cp = skin(cp);

	if (   (cp2 = index(cp, ' ')) != NOSTR
	    || (cp2 = index(cp, '\t')) != NOSTR
	   )
		*cp2 = '\0';

#ifdef  GETHOST
	/* Parse ARPA stuff */
	if ( (cp2 = index(cp, '@')) != NULL ||
	     (cp2 = index(cp, '%')) != NULL ) {
		if( index(cp, '!') == NULL ) {
			cp2++;

			/* Plain ARPAnet-style address */
			gethostname(myhost, sizeof myhost);

			/*
			 * Cut off tails
			 */
			while( (cp3 = rindex(cp2, '.')) != NULL &&
			       (cp4 = rindex(myhost, '.')) != NULL &&
			       icequal(cp3+1, cp4+1) ) {
				*cp3 = '\0';
				*cp4 = '\0';
			}
			if( icequal(cp2, myhost) ) {
				*--cp2 = '\0';  /* purely local address */
				return cp;
			}

			/*
			 * Cut until appropriate length
			 */
			while( strlen(cp) > 20 ) {
				if( (cp3 = rindex(cp2, '.')) != NULL ) {
					*cp3 = '\0';
				} else {
					*--cp2 = '\0';  /* strip whole user/domain part */
					break;
				}
			}
			return cp;
		}
		*cp2 = '\0';
	}
#endif  /* GETHOST */

	/* Parse UUCP stuff */
	while( strlen(cp) > 20 ) {
		if( (cp2 = index(cp, '!')) == NULL )
			break;
		cp = cp2+1;
	}
	return cp;
}

/*
 * Skin an arpa net address according to the RFC 822 interpretation
 * of "host-phrase."
 */
char *
skin(name)
	char *name;
{
	register int c;
	register char *cp, *cp1, *cp2, *cp3;
	int gotlt;
	char nbuf[BUFSIZ];
	int level;

	if (name == NOSTR || !*name || blankline(name))
		return(NOSTR);

	/* Handle "phrase" <route-addr> */
	if (   (cp2 = rindex(name, '>')) != NOSTR
	    && (cp1 = rindex(name, '<')) != NOSTR
	    && (   (cp3 = rindex(name, ')')) == NOSTR
		|| cp3 < cp1
		|| (cp3 = rindex(name, '(')) == NOSTR
		|| cp3 > cp2 && cp3[-1] != '\\'
	       )
	   ) {
	      *cp2 = '\0';
	      cp = savestr(cp1 + 1);
	      *cp2 = '>';
	      return cp;
	}

	/* Skip all comments and spaces */
	if (   index(name, '(') == NOSTR
	    && index(name, ' ') == NOSTR
	    && index(name, '\t') == NOSTR
	   )
		return(name);

	gotlt = 0;
	for (cp = name, cp2 = nbuf; c = *cp++;) {
		switch (c) {
		case '(':
			level = 1;
			while (*cp && level)  {
				switch (*cp++) {
				    case '(':
					if (cp > name && cp[-1] != '\\')
						level++;
					break;
				    case ')':
					if (cp > name && cp[-1] != '\\')
						level--;
					break;
				}
			}
			break;

		case ' ':
		case '\t':
			if (cp2 > nbuf && !isspace(cp2[-1]))
				*cp2++ = ' ';
			break;

		case '<':
			cp2 = nbuf;
			gotlt++;
			break;

		case '>':
			if (gotlt)
				goto done;

			/* Fall into . . . */

		default:
			*cp2++ = c;
			break;
		}
	}
done:
	*cp2 = '\0';
	while (--cp2 >= nbuf && isspace(*cp2))
		*cp2 = '\0';

	if (!*nbuf)
		return(NOSTR);

	return savestr(nbuf);
}

/*
 * Fetch the sender's name from the passed message.
 * Reptype can be
 *      FOR_display -- get sender's name for display purposes
 *      FOR_reply --  get sender's name for reply, one address
 *      FOR_Reply --  get sender's name for reply, multiply addresses
 */

static char *name1(mp, reptype)
	register struct message *mp;
{
	static char namebuf[LINESIZE];
	static char linebuf[LINESIZE];
	register char *cp, *cp1, *cp2, *cp3;
	register FILE *ibuf;
	int first = 1;
	extern int uglyfromflag;

	if( !uglyfromflag ) {
		if (   reptype != FOR_display
		    && (cp = hfield("reply-to", mp)) != NOSTR
		   )
			return canonada(cp);
		if ((cp = hfield("from", mp)) != NOSTR) {
			if (reptype == FOR_display)
				return cp;
			return canonada(cp);
		}
		if (   reptype == FOR_display
		    && (cp = hfield("sender", mp)) != NOSTR
		   )
			return cp;
	}
	ibuf = setinput(mp);
	copy("", namebuf);
	if (readline(ibuf, linebuf) <= 0)       /* First From */
		return(savestr(namebuf));
newname:
	for (cp = linebuf; *cp != ' '; cp++)
		;
	while (any(*cp, " \t"))
		cp++;
	for (cp2 = &namebuf[strlen(namebuf)]; *cp && !any(*cp, " \t") &&
	    cp2-namebuf < LINESIZE-1; *cp2++ = *cp++)
		;
	*cp2 = '\0';
	if (readline(ibuf, linebuf) <= 0)
		return(savestr(namebuf));
	if ((cp = index(linebuf, 'F')) == NOSTR)
		return(savestr(namebuf));
	if (strncmp(cp, "From", 4) != 0)
		return(savestr(namebuf));
	while ((cp = index(cp, 'r')) != NULL) {
		if (strncmp(cp, "remote", 6) == 0) {
			if ((cp = index(cp, 'f')) == NULL)
				break;
			if (strncmp(cp, "from", 4) != 0)
				break;
			if ((cp = index(cp, ' ')) == NULL)
				break;
			cp++;
			if (first) {
				copy(cp, namebuf);
				first = 0;
			} else
				strcpy(rindex(namebuf, '!')+1, cp);
			strcat(namebuf, "!");
			goto newname;
		}
		cp++;
	}
	return(savestr(namebuf));
}

char *strip_comments(s)
register char *s;
{
	register char *t, *h;
	int level;

	if (s == NOSTR || !*s)
		return NOSTR;
	while(isspace(*s))
		s++;
	for (h = t = s; *s; s++) {
		if (*s == '(') {
			s++;
			level = 1;
			while (*s && level) {
				switch (*s++) {
					case ')':
						if (s[-2] != '\\')
							level--;
						break;
					case '(':
						if (s[-2] != '\\')
							level++;
						break;
				}
			}
			if (!*s)
				break;
			if (t > h && !isspace(t[-1]))
				*t++ = ' ';
			continue;
		}
		if (t > h && isspace(*s) && isspace(t[-1]))
			continue;
		*t++ = *s;
	}
	while (t > h && isspace(t[-1]))
		t--;
	if (t == h)
		return NOSTR;
	*t = '\0';
	return h;
}

char *strip_quotes(s)
register char *s;
{
	register char *t, *h;

	if (s == NOSTR || !*s)
		return NOSTR;
	while(isspace(*s))
		s++;
	for (h = t = s; *s; s++) {
		if (*s == '"' && (s == h || s[-1] != '\\')) {
			if (t > h && !isspace(t[-1]))
				*t++ = ' ';
			continue;
		}
		if (t > h && isspace(*s) && isspace(t[-1]))
			continue;
		*t++ = *s;
	}
	while (t > h && isspace(t[-1]))
		t--;
	if (t == h)
		return NOSTR;
	*t = '\0';
	return h;
}

char *extract_comments(s)
register char *s;
{
	register char *t, *h, *cp;
	int level, quoted;

	if (s == NOSTR || !*s)
		return NOSTR;
	quoted = 0;
	h = NOSTR;
	for (cp = s; *s; s++) {
		if (*s == '"' && (s == cp || s[-1] != '\\'))
			quoted = !quoted;
		if (*s == '(' && !quoted) {
			s++;
			while(isspace(*s))
				s++;
			if (h == NOSTR)
				h = t = s;
			else if (t > h && !isspace(t[-1]))
				*t++ = ' ';
			level = 1;
			while (*s && level) {
				switch (*s++) {
					case ')':
						if (s[-2] != '\\')
							level--;
						break;
					case '(':
						if (s[-2] != '\\')
							level++;
						break;
				}
				if (level)
					*t++ = s[-1];
			}
			while (t > h && isspace(t[-1]))
				t--;
			if (!*s)
				break;
		}
	}
	if (h == NOSTR || h == t)
		return NOSTR;
	*t = '\0';
	return h;
}

char *canonada(cp)
char *cp;
{
	char *cp1, *cp2, *cp3, *phrase, *comment, *address;

	cp = savestr(cp);

	if (   (cp2 = rindex(cp, '>')) != NOSTR
	    && (cp1 = rindex(cp, '<')) != NOSTR
	    && (   (cp3 = rindex(cp, ')')) == NOSTR
		|| cp3 < cp1
		|| (cp3 = rindex(cp, '(')) == NOSTR
		|| cp3 > cp2 && cp3[-1] != '\\'
	       )
	   ) {
		*cp1 = *cp2 = '\0';
		address = savestr(cp1 + 1);
		*cp2 = '>';
		phrase = strip_quotes(strip_comments(savestr(cp)));
		if (phrase == NOSTR) {
			*cp1 = '<';
			comment = extract_comments(cp);
			if (comment == NOSTR)
				return address;

			cp2 = cp3 = salloc(  strlen(address)
					   + 1/* */
					   + 1/*(*/ + strlen(comment) + 1/*)*/
					   + 1/*\0*/
					  );
			cp3 = copy(address, cp3);
			cp3 = copy(" (", cp3);
			cp3 = copy(comment, cp3);
			*cp3++ = ')';
		}
		else {
			cp2 = cp3 = salloc(  1/*"*/ + strlen(phrase) + 1/*"*/
					   + 1/* */
					   + 1/*<*/ + strlen(address) + 1/*>*/
					   + 1/*\0*/
					  );
			*cp3++ = '"';
			cp3 = copy(phrase, cp3);
			cp3 = copy("\" <", cp3);
			cp3 = copy(address, cp3);
			*cp3++ = '>';
		}
		*cp3 = '\0';

		return cp2;
	}

	return cp;
}

/*
 * Count the occurances of c in str
 */
charcount(str, c)
	char *str;
{
	register char *cp;
	register int i;

	for (i = 0, cp = str; *cp; cp++)
		if (*cp == c)
			i++;
	return(i);
}

/*
 * See if the string is a number.
 */

numeric(str)
	char str[];
{
	register char *cp = str;

	while (*cp)
		if (!isdigit(*cp++))
			return(0);
	return(1);
}

/*
 * Are any of the characters in the two strings the same?
 */

anyof(s1, s2)
	register char *s1, *s2;
{
	register int c;

	while (c = *s1++)
		if (any(c, s2))
			return(1);
	return(0);
}

/*
 * See if the given header field is supposed to be ignored.
 */
isign(field)
	char *field;
{
	char realfld[BUFSIZ];
	register int h;
	register struct ignore *igp;

	istrcpy(realfld, field);
	h = hash(realfld);
	for (igp = ignore[h]; igp != 0; igp = igp->i_link) {
		h = strlen(igp->i_field);
		if (strncmp(igp->i_field, realfld, h) == 0)
			return(1);
	}
	return(0);
}


#ifdef  MSDOS
gethostname (name, size)
char *name;
{
	char *str;

	name[0] = '\0';
	if (str = value("DOMAIN"))
		strncpy (name, str, size);
}
#endif
