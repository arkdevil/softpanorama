/*
 * Mail -- a mail program
 *
 * Handle name lists.
 *
 * $Log:	names.c,v $
 * Revision 1.17  93/01/04  02:17:20  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.16  92/08/24  02:21:03  ache
 * Основательные правки и перенос в разные системы
 * 
 * Revision 1.25  1991/12/09  11:34:14  ache
 * Параметры в DOS передаются теперь в том же файле
 *
 * Revision 1.24  1991/07/22  16:36:47  ache
 * Port to Borland C
 *
 * Revision 1.23  1991/07/19  20:00:14  ache
 * Добавлена рассылка сообщений в телеконференции
 *
 * Revision 1.22  1991/04/26  16:47:41  ache
 * Добавлена передача флага для кодировки Волапюк.
 *
 * Revision 1.21  1991/01/25  18:04:45  ache
 * Убраны старые (4.1) сигналы
 *
 * Revision 1.20  90/12/08  20:13:15  ache
 * Добавлена обработка кавычек
 * 
 * Revision 1.19  90/12/07  14:00:24  ache
 * Правлена обработка временных файлов и мелочи
 * 
 * Revision 1.18  90/11/11  20:06:34  ache
 * Исправлено распознавание имен файлов
 * 
 * Revision 1.17  90/11/02  20:02:19  ache
 * Splitting long argument list.
 * 
 * Revision 1.16  90/10/16  09:13:08  ache
 * Чуть ускорена обработка >From
 * 
 * Revision 1.15  90/10/13  20:28:17  ache
 * handling From
 * 
 * Revision 1.14  90/09/21  21:59:29  ache
 * MS-DOS extends + some new stuff
 * 
 * Revision 1.13  90/09/13  13:20:07  ache
 * MS-DOS & Unix together...
 * 
 * Revision 1.12  90/08/23  16:50:32  avg
 * Выкинута забытая отладочная выдача.
 * 
 * Revision 1.11  90/08/20  00:36:07  avg
 * Some patches.
 * 
 * Revision 1.10  90/08/10  13:47:29  avg
 * Добавлен ключ -x для передачи больших файлов.
 * 
 * Revision 1.9  90/08/08  17:14:23  avg
 * SENDMAIL->NETMAIL
 * 
 * Revision 1.8  90/08/07  18:22:03  avg
 * правлена ошибка при трансляции без PMCS\
 * 
 * Revision 1.7  90/06/26  17:18:10  avg
 * Сделана обработка вложенных () в комментариях по RFC822.
 * 
 * Revision 1.6  90/05/31  23:18:29  avg
 * Исправлена ошибка - потерялся конец строки при переходе от
 * ctime к udate.
 * 
 * Revision 1.5  90/05/31  19:47:50  avg
 * Правлена обработка Internet-овских имен.
 * 
 * Revision 1.4  90/04/30  19:44:34  avg
 * Починен режим rmail
 * 
 * Revision 1.3  88/07/23  20:36:08  ache
 * Русские диагностики
 * 
 * Revision 1.2  88/01/11  12:26:32  avg
 * Добавлены куски для работы с PMCS.
 * У rcsid поставлены комментарии NOXSTR.
 * 
 * Revision 1.1  87/12/25  16:00:11  avg
 * Initial revision
 *
 */

#include "rcv.h"
#ifdef  MSDOS
#include    <process.h>
#endif

/*NOXSTR*/
static char rcsid[] = "$Header: names.c,v 1.17 93/01/04 02:17:20 ache Exp $";
/*YESXSTR*/
extern char *BestBuffer(), *canonada();
static char *yankword();

/*
 * Allocate a single element of a name list,
 * initialize its name field to the passed
 * name and return it.
 */

static
struct name *
nalloc(str)
	char str[];
{
	register struct name *np;

	np = (struct name *) salloc(sizeof *np);
	np->n_flink = NIL;
	np->n_blink = NIL;
	np->n_type = -1;
	np->n_name = canonada(str);
	if ((np->n_address = skin(np->n_name)) == NOSTR)/* Non-Internet? */
		np->n_address = np->n_name = str;       /* then raw...   */

	return(np);
}

/*
 * Find the tail of a list and return it.
 */

struct name *
tailof(name)
	struct name *name;
{
	register struct name *np;

	np = name;
	if (np == NIL)
		return(NIL);
	while (np->n_flink != NIL)
		np = np->n_flink;
	return(np);
}

/*
 * Extract a list of names from a line,
 * and make a list of names from it.
 * Return the list or NIL if none found.
 */

struct name *
extract(line, ntype)
	char line[];
{
	register char *cp, *head, *tail;
	register struct name *top, *np, *t;
	static char nbuf[BUFSIZ];
	int comma;

	if (line == NOSTR || !*line)
		return(NIL);

	top = NIL;
	np = NIL;
	cp = line;
	comma = !!(ntype & GCOMMA);
	ntype &= ~GCOMMA;

	/*
	 * Process list of addresses
	 */
	while ((cp = yankword(cp, nbuf, comma)) != NOSTR) {
		for (head = nbuf; isspace(*head); head++)
			;
		for (tail = head + strlen(head) - 1;
		     tail >= head && isspace(*tail);
		     tail--
		    )
			*tail = '\0';
		if (!*head)
			continue;
		t = nalloc(head);
		t->n_type = ntype;
		if (top == NIL)
			top = t;
		else
			np->n_flink = t;
		t->n_blink = np;
		np = t;
	}
	return(top);
}

/*
 * Turn a list of names into a string of the same names.
 */
char *
detract(np, ntype)
	register struct name *np;
{
	register int s;
	register char *cp, *top;
	register struct name *p;
	register int comma;

	if (np == NIL)
		return(NOSTR);

	s = 0;

	comma = !!(ntype & GCOMMA);
	ntype &= ~GCOMMA;
	if (!comma) {
		for (p = np; p != NIL; p = p->n_flink) {
			if (ntype && (p->n_type & (GMASK|GBCC)) != ntype)
				continue;
			if (any('@', p->n_address)) {
				comma = 1;
				break;
			}
		}
	}

	if (debug && comma)
		fprintf(stderr, ediag(
"detract asked to insert commas\n",
"detract вызван со вставкой запятых\n"));

	for (p = np; p != NIL; p = p->n_flink) {
		if (ntype && (p->n_type & (GMASK|GBCC)) != ntype)
			continue;
		s += strlen(p->n_name) + 1;
		if (comma)
			s++;
	}
	if (s == 0)
		return(NOSTR);
	top = salloc(s);
	cp = top;
	for (p = np; p != NIL; p = p->n_flink) {
		if (ntype && (p->n_type & (GMASK|GBCC)) != ntype)
			continue;
		cp = copy(p->n_name, cp);
		if (comma)
			*cp++ = ',';
		*cp++ = ' ';
	}
	*--cp = '\0';
	if (comma && *--cp == ',')
		*cp = '\0';
	return(top);
}

/*
 * Grab a single word (liberal word)
 * Throw away things between () and ""
 */
static
char *
yankword(ap, wbuf, comma)
	char *ap, wbuf[];
{
	register char *cp, *cp2;
	char q;
	int Comment, Address, Quote;

	cp = ap;
	Comment = Address = Quote = 0;

SkipComment:
	do {
		while(isspace(*cp))
			cp++;
		if ((!Address || !Comment) && *cp == '(') {
			int level;

			level = 1;
			cp++;
			while (*cp && level) {
				switch (*cp++) {
					case ')':
						if (cp[-2] != '\\')
							level--;
						break;
					case '(':
						if (cp[-2] != '\\')
							level++;
						break;
				}
			}
			Comment = 1;
		}

		if (!*cp)
			goto CopyAddress;

	} while (any(*cp, " \t("));

SkipQuote:
	/* Quotes only BEFORE <...> */
	if (!Address && *cp == '"') {
		cp++;
		while (*cp && *cp != '"') {
			if (*cp == '\\' && *(cp + 1) == '"')
				cp++;
			cp++;
		}
		if (*cp == '"')
			cp++;
		Quote = 1;
		goto SkipComment;
	}

	if (   (!Address || comma)
	    && *cp == '<'
	    && *(cp + 1)
	    && (cp = index(cp + 1, '>')) != NOSTR
	   ) {
		cp++;
FoundAddress:
		Address = 1;
		while (isspace(*cp))
			cp++;
		if (!Comment && *cp == '(')
			goto SkipComment;
	}

	if (*cp == ',' || !*cp) {
CopyAddress:
		if (!Address && !Quote && !Comment)
			return NOSTR;
		q = *cp;
		*cp = '\0';
		for (cp2 = copy(ap, wbuf) - 1;
		     cp2 > wbuf && isspace(*cp2);
		     cp2--
		    )
			;
		*++cp2 = '\0';

		*cp = q;
		while (any(*cp, " \t,"))
			cp++;
		return cp;
	}

	if (Address && !comma)
		goto CopyAddress;

	for ( ; *cp && !any(*cp, " \t,(\""); cp++)
		;

	goto FoundAddress;
}


/*
 * For each recipient in the passed name list with a /
 * in the name, append the message to the end of the named file
 * and remove him from the recipient list.
 *
 * Recipients whose name begins with | are piped through the given
 * program and removed.
 */

struct name *
outof(names, fo, hp)
	struct name *names;
	FILE *fo;
	struct header *hp;
{
	register int c;
	register struct name *np, *top, *t, *x;
	char *fname, *shell, *udate(), *addr;
	FILE *fout, *fin;
	char *vbuf;
	int ispipe, s, pid;
	extern char tempEdit[];
	char line[LINESIZE];
	int remote = rflag != NOSTR || rmail;
#ifdef PMCS
	int isproject;
	long HdrOffset, ftell();
#endif

	top = names;
	np = names;
	while (np != NIL) {
		addr = np->n_address;
		if (!isfileaddr(addr) && addr[0] != '|'
#ifdef PMCS
				      && addr[0] != '='
#endif
		   ) {
			np = np->n_flink;
			continue;
		}
		if (fo == NULL)
			goto cant;

#ifdef PMCS
		HdrOffset = 0l;
#endif
		ispipe    = addr[0] == '|';
#ifdef PMCS
		isproject = addr[0] == '=';
		if (ispipe || isproject)
#else
		if (ispipe)
#endif
			fname = addr + 1;
		else {
			if ((fname = expand(addr)) == NOSTR) {
				senderr++;
				goto cant;
			}
			if (isdir(fname)) {
				fprintf(stderr, ediag("%s is a directory\n",
						      "%s -- каталог\n"),
						fname);
				senderr++;
				goto cant;
			}
		}

		/*
		 * See if we have copied the complete message out yet.
		 * If not, do so.
		 */

		if (image == NULL) {
#ifdef  MSDOS
			maketemp(tempEdit);
#endif
			if (   fclear(tempEdit) < 0
				|| (image = TmpOpen(tempEdit, "a+")) == NULL
			   ) {
				perror(tempEdit);
				remove(tempEdit);
				senderr++;
				goto cant;
			}
			if( !remote ) {
				fprintf(image, "From %s %s\n", myname, udate());
#ifdef PMCS
				HdrOffset = ftell(image);
#endif
				puthead(hp, image, GMASK|GNL);
			}
			rewind(fo);
			while (fgets(line, sizeof(line), fo) != NOSTR) {
				if (ishead(line))
					putc('>', image);
				fputs(line, image);
			}
			putc('\n', image);
			fflush(image);
			if (ferror(image)) {
		im_err:
				ioerror(tempEdit, 1);
				senderr++;
				TmpDel(image);
				image = NULL;
				goto cant;
			}
		}

		/*
		 * Now either copy "image" to the desired file
		 * or give it as the standard input to the desired
		 * program as appropriate.
		 */

#ifndef PMCS
		if(ispipe) {
#else
		if(ispipe || isproject) {
#endif
#ifdef  MSDOS
			if ((shell = value("SHELL")) == NULL)
				if ((shell = value("COMSPEC")) == NULL)
					shell = SHELL;
			(void) fflush(image);
			if (ferror(image) || real_flush(fileno(image)) < 0)
				goto im_err;
			c = dup (fileno(stdin));
			close(fileno(stdin));
			rewind(image);
			dup(fileno(image));
			s = spawnlp (P_WAIT, shell, "mail-pipe", "/C", fname, NULL);
			if (s < 0) {
				perror(shell);
				dup2 (c, fileno(stdin));
				senderr++;
				goto cant;
			}
			dup2 (c, fileno(stdin));
#else   /* not MSDOS */
			wait(&s);
			rewind(image);
			switch (pid = fork()) {
			case 0:
				sigsys(SIGHUP, SIG_IGN);
				sigsys(SIGINT, SIG_IGN);
				sigsys(SIGQUIT, SIG_IGN);
				close(0);
				dup(fileno(image));
				close(fileno(image));
#ifdef PMCS
				if (isproject) {
					lseek(0, HdrOffset, 0);
					if((shell = value("projmailer")) == NOSTR)
						shell = PROJMAILER;
					execlp(shell, shell, fname, rflag? rflag : myname, NULL);
					perror(shell);
					exit(1);
				}
#endif
				if ((shell = value("SHELL")) == NOSTR)
					shell = SHELL;
				execlp(shell, shell, "-c", fname, NULL);
				perror(shell);
				exit(1);
				break;

			case -1:
				perror("fork");
				senderr++;
				goto cant;
			}
#endif  /* not MSDOS */
		}
		else {
			if ((fout = Fopen(fname, "a")) == NULL) {
				perror(fname);
				senderr++;
				goto cant;
			}
			vbuf = BestBuffer(fout);
#ifdef  MSDOS
			seekctlz(fout);
#endif
			rewind(image);
			while ((c = getc(image)) != EOF)
				putc(c, fout);
			fflush(fout);
			if (ferror(fout)) {
				ioerror(fname, 1);
				senderr++;
			}
			Fclose(fout);
			if (vbuf != NULL)
				free(vbuf);
		}

cant:

		/*
		 * In days of old we removed the entry from the
		 * the list; now for sake of header expansion
		 * we leave it in and mark it as deleted.
		 */

#ifdef CRAZYWOW
		if (np == top) {
			top = np->n_flink;
			if (top != NIL)
				top->n_blink = NIL;
			np = top;
			continue;
		}
		x = np->n_blink;
		t = np->n_flink;
		x->n_flink = t;
		if (t != NIL)
			t->n_blink = x;
		np = t;
#endif

		np->n_type |= GDEL;
		np = np->n_flink;
	}

	if (fo != NULL)
		TmpDel(image);

	return(top);
}

/*
 * Determine if the passed address is a local "send to file" address.
 * If any of the network metacharacters precedes any slashes, it can't
 * be a filename.  We cheat with .'s to allow path names like ./...
 */
isfileaddr(name)
	char *name;
{
	register char *cp;
	extern char *metanet;

	if (any('@', name))
		return(0);
	if (*name == '+')
		return(1);
#ifdef	MSDOS
	if (name[0] && name[1] == ':')
		return(1);
#endif
	for (cp = name; *cp; cp++) {
		if (any(*cp, metanet))
			return(0);
		if (*cp == '/'
#ifdef	MSDOS
			|| *cp == SEPCHAR
#endif
		   )
			return(1);
	}
	return(0);
}

/*
 * Map all of the aliased users in the invoker's mailrc
 * file and insert them into the list.
 * Changed after all these months of service to recursively
 * expand names (2/14/80).
 */

struct name *
usermap(names)
	struct name *names;
{
	register struct name *new, *np, *cp;
	struct grouphead *gh;
	register int metoo;
	char *addr;

	new = NIL;
	np = names;
	metoo = (value("metoo") != NOSTR);
	while (np != NIL) {
		addr = np->n_address;
		if (addr[0] == '\\') {
			cp = np->n_flink;
			new = put(new, np);
			np = cp;
			continue;
		}
		gh = findgroup(addr);
		cp = np->n_flink;
		if (gh != NOGRP)
			new = gexpand(new, gh, metoo, np->n_type);
		else
			new = put(new, np);
		np = cp;
	}
	return(new);
}

/*
 * Recursively expand a group name.  We limit the expansion to some
 * fixed level to keep things from going haywire.
 * Direct recursion is not expanded for convenience.
 */

struct name *
gexpand(nlist, gh, metoo, ntype)
	struct name *nlist;
	struct grouphead *gh;
{
	struct group *gp;
	struct grouphead *ngh;
	struct name *np;
	static int depth;
	char *cp;

	if (depth > MAXEXP) {
		printf(ediag(
"Expanding alias to depth larger than %d\n",
"Синонимы расширяются на глубину больше чем %d\n"),
MAXEXP);
		return(nlist);
	}
	depth++;
	for (gp = gh->g_list; gp != NOGE; gp = gp->ge_link) {
		cp = gp->ge_name;
		if (*cp == '\\')
			goto quote;
		if (strcmp(cp, gh->g_name) == 0)
			goto quote;
		if ((ngh = findgroup(cp)) != NOGRP) {
			nlist = gexpand(nlist, ngh, metoo, ntype);
			continue;
		}
quote:
		np = nalloc(cp);
		np->n_type = ntype;
		/*
		 * At this point should allow to expand
		 * to self if only person in group
		 */
		if (gp == gh->g_list && gp->ge_link == NOGE)
			goto skip;
		if (!metoo && strcmp(cp, myname) == 0)
			np->n_type |= GDEL;
skip:
		nlist = put(nlist, np);
	}
	depth--;
	return(nlist);
}


/*
 * Compute the length of the passed name list and
 * return it.
 */

static
int
lengthof(name)
	struct name *name;
{
	register struct name *np;
	register int c;

	if (name == NIL)
		return 0;
	for (c = 0, np = name; np != NIL; np = np->n_flink) {
		if (np->n_type & GDEL)
			continue;
		c++;
	}
	return(c);
}

/*
 * Concatenate the two passed name lists, return the result.
 */

struct name *
cat(n1, n2)
	struct name *n1, *n2;
{
	register struct name *tail;

	if (n1 == NIL)
		return(n2);
	if (n2 == NIL)
		return(n1);
	tail = tailof(n1);
	tail->n_flink = n2;
	n2->n_blink = tail;
	return(n1);
}

/*
 * Unpack the name list onto a vector of strings.
 * Return an error if the name list won't fit.
 */

char **
unpack(np)
	struct name **np;
{
	register char **ap, **top;
	register struct name *n;
	char *cp, *addr;
	char hbuf[10];
	int t, extra, metoo, verbose, volapyuk, cnt;
	extern int filetransfer;

	n = *np;
	if ((t = lengthof(n)) == 0)
		return (char **) NULL;

	/*
	 * Compute the number of extra arguments we will need.
	 * We need at least two extra -- one for "mail" and one for
	 * the terminating 0 pointer.  Additional spots may be needed
	 * to pass along -r and -f to the host mailer.
	 */

	extra = 2;
	if (rflag != NOSTR)
		extra += 2;
#ifdef NETMAIL
	extra++;
	metoo = value("metoo") != NOSTR;
	if (metoo)
		extra++;
	verbose = value("verbose") != NOSTR;
	if (verbose)
		extra++;
	volapyuk = value("volapyuk") != NOSTR;
	if (volapyuk)
		extra++;
#ifndef MSDOS
	if (filetransfer)
		extra++;
#endif  /*MSDOS*/
#endif  /*NETMAIL*/
	if (hflag)
		extra += 2;
	top = (char **) salloc((t + extra) * sizeof cp);
	ap = top;
	*ap++ = "send-mail";
	cnt = strlen(*top);
	if (rflag != NOSTR) {
		*ap++ = "-r";
		*ap++ = rflag;
		cnt += 1 + 2 + 1 + strlen(rflag);
	}
#ifdef NETMAIL
	if (metoo) {
		*ap++ = "-m";
		cnt += 1 + 2;
	}
	if (verbose) {
		*ap++ = "-i";
		*ap++ = "-v";
		cnt += 1 + 2 + 1 + 2;
	}
	if (volapyuk) {
		*ap++ = "-V";
		cnt += 1 + 2;
	}
#ifndef MSDOS
	if (filetransfer) {
		*ap++ = "-odq";
		cnt += 1 + 4;
	}
#endif  /*MSDOS*/
#endif  /*NETMAIL*/
	if (hflag) {
		*ap++ = "-h";
		sprintf(hbuf, "%d", hflag);
		cnt += 1 + 2 + 1 + strlen(hbuf);
		*ap++ = savestr(hbuf);
	}
	for ( ; n != NIL; n = n->n_flink ) {
		if (n->n_type & GDEL)
			continue;
		addr = n->n_address;
		cnt += 1 + strlen(addr);
#ifndef	MSDOS
		if (cnt >= 1000)        /* Unix stack size */
			break;
#endif
		*ap++ = addr;
	}
	*np = n;
	*ap = NOSTR;
	return(top);
}

/*
 * See if the user named himself as a destination
 * for outgoing mail.  If so, set the global flag
 * selfsent so that we avoid removing his mailbox.
 */
void
mechk(names)
	struct name *names;
{
	register struct name *np;
	char *name;

	name = skin(myname);
	for (np = names; np != NIL; np = np->n_flink)
		if ((np->n_type & GDEL) == 0 && equal(np->n_address, name)) {
			selfsent++;
			return;
		}
}

/*
 * Remove all of the duplicates from the passed name list by
 * insertion sorting them, then checking for dups.
 * Return the head of the new list.
 */

struct name *
elide(names)
	struct name *names;
{
	register struct name *np, *t, *new;
	struct name *x;

	if (names == NIL)
		return(NIL);
	new = names;
	np = names;
	np = np->n_flink;
	if (np != NIL)
		np->n_blink = NIL;
	new->n_flink = NIL;
	while (np != NIL) {
		t = new;
		while (istrlcmp(t->n_address, np->n_address) < 0) {
			if (t->n_flink == NIL)
				break;
			t = t->n_flink;
		}

		/*
		 * If we ran out of t's, put the new entry after
		 * the current value of t.
		 */

		if (istrlcmp(t->n_address, np->n_address) < 0) {
			t->n_flink = np;
			np->n_blink = t;
			t = np;
			np = np->n_flink;
			t->n_flink = NIL;
			continue;
		}

		/*
		 * Otherwise, put the new entry in front of the
		 * current t.  If at the front of the list,
		 * the new guy becomes the new head of the list.
		 */

		if (t == new) {
			t = np;
			np = np->n_flink;
			t->n_flink = new;
			new->n_blink = t;
			t->n_blink = NIL;
			new = t;
			continue;
		}

		/*
		 * The normal case -- we are inserting into the
		 * middle of the list.
		 */

		x = np;
		np = np->n_flink;
		x->n_flink = t;
		x->n_blink = t->n_blink;
		t->n_blink->n_flink = x;
		t->n_blink = x;
	}

	/*
	 * Now the list headed up by new is sorted.
	 * Go through it and remove duplicates.
	 */

	np = new;
	while (np != NIL) {
		t = np;
		while (t->n_flink!=NIL &&
		    icequal(np->n_address, t->n_flink->n_address))
			t = t->n_flink;
		if (t == np || t == NIL) {
			np = np->n_flink;
			continue;
		}

		/*
		 * Now t points to the last entry with the same name
		 * as np.  Make np point beyond t.
		 */

		np->n_flink = t->n_flink;
		if (t->n_flink != NIL)
			t->n_flink->n_blink = np;
		np = np->n_flink;
	}
	return(new);
}

/*
 * Put another node onto a list of names and return
 * the list.
 */

struct name *
put(list, node)
	struct name *list, *node;
{
	node->n_flink = list;
	node->n_blink = NIL;
	if (list != NIL)
		list->n_blink = node;
	return(node);
}

/*
 * Determine the number of elements in
 * a name list and return it.
 */

count(np)
	register struct name *np;
{
	register int c = 0;

	while (np != NIL) {
		c++;
		np = np->n_flink;
	}
	return(c);
}

/*
 * Delete the given name from a namelist, using the passed
 * function to compare the names.
 */
struct name *
delname(np, name, cmpfun)
	register struct name *np;
	char name[];
	int (* cmpfun)();
{
	register struct name *p;

	name = skin(name);
	for (p = np; p != NIL; p = p->n_flink)
		if ((* cmpfun)(p->n_address, name)) {
			if (p->n_blink == NIL) {
				if (p->n_flink != NIL)
					p->n_flink->n_blink = NIL;
				np = p->n_flink;
				continue;
			}
			if (p->n_flink == NIL) {
				if (p->n_blink != NIL)
					p->n_blink->n_flink = NIL;
				continue;
			}
			p->n_blink->n_flink = p->n_flink;
			p->n_flink->n_blink = p->n_blink;
		}
	return(np);
}

/*
 * Call the given routine on each element of the name
 * list, replacing said value if need be.
 */

mapf(np, from)
	register struct name *np;
	char *from;
{
	register struct name *p;

	from = skin(from);
	for (p = np; p != NIL; p = p->n_flink)
		p->n_address = netmap(p->n_address, from);
}

/*
 * Pretty print a name list
 * Uncomment it if you need it.
 */

prettyprint(parm, name)
	char *parm;
	struct name *name;
{
	register struct name *np;

	np = name;
	while (np != NIL) {
		fprintf(stderr, "%s: %s: %s (%0o)\n",
			parm, np->n_name, np->n_address, np->n_type);
		np = np->n_flink;
	}
}

struct name *make_to_list(hp)
struct header *hp;
{
	struct name *to;

	to = usermap(cat(extract(hp->h_bcc_template, GBCC),
			 cat(extract(hp->h_to_template, GTO),
			 extract(hp->h_cc_template, GCC))));

	if (to == NIL) {
		hp->h_to = hp->h_cc = hp->h_bcc = NOSTR;
		return to;
	}

	to = outof(to, NULL, hp);
	to = elide(to);
	if (hp->h_seq == 0 && count(to) > 1)
		hp->h_seq++;
	fixhead(hp, to);

	return to;
}
