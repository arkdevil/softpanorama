/*
 * Mail -- a mail program
 *
 * File I/O.
 *
 * $Log:	fio.c,v $
 * Revision 1.10  93/01/04  02:15:05  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.9  92/08/24  02:19:19  ache
 * Основательные правки и перенос в разные системы
 * 
 * Revision 1.18  1991/07/22  16:36:47  ache
 * Port to Borland C
 *
 * Revision 1.17  1991/04/26  17:01:10  ache
 * Cosmetic changes
 *
 * Revision 1.16  1991/04/19  22:45:31  asa
 * Изменения для Демос 32
 *
 * Revision 1.15  1991/01/25  18:04:45  ache
 * Убраны старые (4.1) сигналы
 *
 * Revision 1.14  1991/01/19  15:38:23  ache
 * убраны буфера 16к, как не оправдавшие доверия народа
 *
 * Revision 1.13  90/12/23  21:12:10  ache
 * Буферизация IO по 16 К
 *
 * Revision 1.12  90/12/22  22:52:58  ache
 * Сортировка + выдача ФИО
 * 
 * Revision 1.11  90/12/07  14:12:32  ache
 * Правлена обработка временных файлов и мелочи
 * 
 * Revision 1.10  90/11/11  20:05:26  ache
 * Исправлено распознавание имен файлов
 * 
 * Revision 1.9  90/10/16  09:02:10  ache
 * Введено автоисправление некорректных сообщений.
 * 
 * Revision 1.8  90/10/13  20:26:46  ache
 * O_BINARY for DOS
 * 
 * Revision 1.7  90/09/21  21:58:39  ache
 * MS-DOS extends + some new stuff
 * 
 * Revision 1.6  90/09/13  13:19:05  ache
 * MS-DOS & Unix together...
 * 
 * Revision 1.5  90/06/26  17:13:02  avg
 * Теперь для обработки expand всегда вызывается /bin/sh.
 * 
 * Revision 1.4  88/07/23  20:32:50  ache
 * Русские диагностики
 * 
 * Revision 1.3  88/02/19  16:05:33  avg
 * Для экономии памяти в поле m_size заменен long на unsigned
 * для машин типа pdp11.
 *
 * Revision 1.2  88/01/11  12:26:01  avg
 * Добавлены куски для работы с PMCS.
 * У rcsid поставлены комментарии NOXSTR.
 *
 * Revision 1.1  87/12/25  15:59:14  avg
 * Initial revision
 *
 */

#include "rcv.h"
#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>

/*NOXSTR*/
static char rcsid[] = "$Header: fio.c,v 1.10 93/01/04 02:15:05 ache Exp $";
/*YESXSTR*/

#ifdef  UNPACK_MAILBOX
#define UNPACK_MAIL             1
#define UNCOMPRESS_MAIL 	2
#define NOTUNPACK_MAIL  	0
#endif
extern char tempSet[], tempMesg[];
extern char *udate(), *BestBuffer(), *malloc();
static int append();
static void makemessage();
extern long GetDate();
int SortAsInFile(), SortByDate(), SortBySubject(), SortByAuthor();

/*
 * Set up the input pointers while copying the mail file into
 * /tmp.
 */
void
setptr(ibuf)
	FILE *ibuf;
{
	register int c;
	register char *cp, *cp2;
	register int count;
	long s, l;
	off_t offset;
	char linebuf[LINESIZE+1];
	char wbuf[LINESIZE];
	int maybe, flag, inhead, firstline, verbose;
	FILE *mestmp;
	struct message this;
#ifdef UNPACK_MAILBOX
	int notunpack = 0;
	int unpacking = NOTUNPACK_MAIL;
	int len;
	long SaveLin = 0L;
	long SaveSize = 0L;
	int SaveFlag;
	extern long SaveSeek;
	extern long SaveOld;
	long SaveTemp = 0L;
	int SaveCnt = 0;
	int EnableUnpack;
	char FromLine [LINESIZE+1];
#else
#ifdef	MSDOS
	int savret = 0;
#endif
#endif	/* UNPACK_MAILBOX */

	flush();        /* Force any printouts */
#ifdef  MSDOS
	maketemp(tempSet);
#endif
	if (   fclear(tempSet) < 0
#ifdef UNPACK_MAILBOX
#ifndef MSDOS
		|| (mestmp = TmpOpen(tempSet, "w+")) == NULL
#else
		|| (mestmp = TmpOpen(tempSet, "w+b")) == NULL
#endif
#else
#ifndef MSDOS
		|| (mestmp = TmpOpen(tempSet, "a+")) == NULL
#else
		|| (mestmp = TmpOpen(tempSet, "a+b")) == NULL
#endif
#endif
	   ) {
		perror(tempSet);
		remove(tempSet);
		exit(1);
	}
	if (fseek (tf, (off_t)0, 2) != 0) {
		ioerror(tempMesg, 2);
		panic("Temp file seeking");
	}
	msgCount = 0;
	offset = 0;
	s = 0;
	l = 0;
	maybe = 1;
	inhead = 0;
	firstline = 1;
	flag = MUSED|MNEW;
#ifdef UNPACK_MAILBOX
	SaveFlag = flag;
	EnableUnpack = (value("unpack-batch") != NOSTR);
#endif
	verbose = intty && outtty && (value("quiet") == NOSTR);
	for (;;) {
		cp = linebuf;

		/*** Get Line From Mailbox */
#ifndef UNPACK_MAILBOX
		c = getc(ibuf);
#ifdef	MSDOS
		if (c == CTRL_Z)
			c = EOF;
#endif
		while (c != EOF && c != '\n') {
#ifdef	MSDOS
			if (c == '\r') {
				if (!savret)
					savret = 1;
				else
					*cp++ = '\r';
			}
			else {
				if (savret) {
					*cp++ = '\r';
					savret = 0;
				}
#endif
			if (cp - linebuf >= LINESIZE - 1) {
				ungetc(c, ibuf);
				break;
			}
			*cp++ = c;
#ifdef	MSDOS
			}
#endif
			c = getc(ibuf);
		}
#ifdef	MSDOS
		if (c == EOF && savret)
			*cp++ = '\r';
#endif
		*cp = '\0';
#else	/* !UNPACK_MAILBOX */
		switch (unpacking) {
		case NOTUNPACK_MAIL:
			len = GetMailboxLine (linebuf, ibuf);
			if (len > 0 && linebuf[len-1]  == '\n') {
				linebuf[len-1] = 0;
				len--;
			}
			break;

		case UNPACK_MAIL:
			len = GetMailboxLine (linebuf, ibuf);
			goto Process;

		case UNCOMPRESS_MAIL:
			len = GetUncompressLine (linebuf);
Process:
			if (len < 0) {
				if (UncompressError ()) {
Error:
					fprintf (stderr, ediag("Cannot uncompress. Message saved.\n",
								   "Не могу pаспаковать письмо. Пишем как есть.\n"));
					fseek (tf, SaveSeek, 0);
					fseek (ibuf, SaveOld, 0);
					fseek (mestmp, SaveTemp, 0);
					offset = SaveSeek;
					s = SaveSize;
					l = SaveLin;
					flag = SaveFlag;
					msgCount = SaveCnt;
					strcpy (linebuf, FromLine);
					len = strlen (linebuf);
					notunpack = 1;
					unpacking = NOTUNPACK_MAIL;
				} else {
					unpacking = NOTUNPACK_MAIL;
					notunpack = 0;
					continue;
				}
			} else {
				if (len > 0 && linebuf[len-1]  == '\n') {
					linebuf[len-1] = 0;
					len--;
				}
				if (maybe && linebuf[0] == 'F' && ishead(linebuf))
					unpacking = NOTUNPACK_MAIL;

				if (   unpacking != NOTUNPACK_MAIL
					&& linebuf[0] == 'F'
				    && !strncmp(linebuf, "From_", 5)
				   )
					linebuf[4] = ' ';
			}
			break;
		}

		cp = linebuf+len;
		if (len < 0) {
			c = EOF;
			cp = linebuf;
		} else
			c = '\n';
#endif
		/*** End Of Mailbox Found ***/

		if (cp == linebuf && c == EOF) {
			if (!maybe) {
			       fprintf(stderr, ediag("WARNING: wrong ended mailbox -- corrected\n",
							 "ПРЕДУПРЕЖДЕНИЕ: неверно законченый почтовый ящик -- исправлено\n"));
				   putc('\n', tf);
				   s++;
				   l++;
			}
			(void) fflush(tf);
			if (ferror(tf)) {
				ioerror(tempMesg, 1);
				panic("Can't made temp file");
			}
#ifdef	UNPACK_MAILBOX
			if (unpacking != NOTUNPACK_MAIL)
				flag |= MODIFY;
#endif
			this.m_flag = flag;
			flag = MUSED|MNEW;
			this.m_offset = offset;
			this.m_size = s;
			this.m_lines = l;

			if (verbose && msgCount > 0)
				putc('\n', stderr);

			if (append(&this, mestmp)) {
				ioerror(tempSet, 1);
				panic("Can't append mesg header");
			}
			makemessage(mestmp);
			TmpDel(mestmp);
			return;
		}

		count = cp - linebuf + 1;

		/*** Parse Header Lines ***/

		if (maybe && linebuf[0] == 'F' && ishead(linebuf)) {
			firstline = 0;
			maybe = 0;
#ifdef UNPACK_MAILBOX
			if (unpacking == NOTUNPACK_MAIL) {
				SaveSeek = offset;
				SaveOld  = ftell(ibuf);
				SaveTemp = ftell(mestmp);
				SaveCnt = msgCount;
				SaveSize = s;
				SaveLin = l;
				SaveFlag = flag;
				strncpy (FromLine, linebuf, LINESIZE);
			}
#endif
			inhead = 1;
			this.m_lines = l;
			l = 0;
	Header:
			msgCount++;
#ifdef	UNPACK_MAILBOX
			if (unpacking != NOTUNPACK_MAIL)
				flag |= MODIFY;
#endif
			this.m_flag = flag;
			flag = MUSED|MNEW;
			this.m_offset = offset;
			this.m_size = s;
			s = 0;

			if (verbose)
#ifdef	UNPACK_MAILBOX
				switch (unpacking) {
				case NOTUNPACK_MAIL:
#endif
					fprintf (stderr, ediag ("\rReading message: %10d ",
											"\rЧтение письма: %12d "), msgCount);
#ifdef	UNPACK_MAILBOX
					break;

				case UNCOMPRESS_MAIL:
					fprintf (stderr, ediag ("\rUncompressing message: %4d ",
											"\rРаспаковка письма: %8d "), msgCount);
					break;

				case UNPACK_MAIL:
					fprintf (stderr, ediag ("\rUnbatching message: %7d ",
											"\rРазбор письма: %12d "), msgCount);
					break;
				}
#endif

			if (append(&this, mestmp)) {
				ioerror(tempSet, 1);
				panic("Can't append mesg header");
			}
			if (firstline) {
				firstline = 0;
				goto BadFrom;
			}
		}
		else if (firstline) {
			char buf[80];

			fprintf(stderr, ediag("WARNING: wrong started mailbox -- corrected\n",
						  "ПРЕДУПРЕЖДЕНИЕ: неверно начатый почтовый ящик -- исправлено\n"));
			(void) sprintf(buf, "From postmaster %s\n\n", udate());
			count += strlen(buf);
			inhead = 0;
			this.m_lines = 0;
			l += 2;
			fputs(buf, tf);
			goto Header;
		}
		else
	BadFrom:
		if (ishead(linebuf)) {
			putc('>', tf);
			count++;
		}

		if (linebuf[0] == '\0')
			inhead = 0;
#ifdef  UNPACK_MAILBOX
		if (   inhead
		    && maybe
		    && !notunpack
		    && unpacking != NOTUNPACK_MAIL
		    )
			continue;
#endif
		cp[0] = '\n';
		cp[1] = '\0';
		fputs(linebuf, tf);
		if (ferror(tf)) {
			ioerror(tempMesg, 1);
			panic("Can't write mesg to temp");
		}
		cp[0] = '\0';

		if (inhead && index(linebuf, ':')) {
			cp = linebuf;
			cp2 = wbuf;
			while (isalpha(*cp))
				*cp2++ = *cp++;
			*cp2 = '\0';
			if (icequal(wbuf, "status")) {
				cp = index(linebuf, ':');
				if (index(cp, 'R'))
					flag |= MREAD;
				if (index(cp, 'O'))
					flag &= ~MNEW;
				inhead = 0;
			}
#ifdef UNPACK_MAILBOX
			else if (   EnableUnpack && !notunpack
				 && icequal (linebuf, "x-batch: compress")
				) {

				fseek (tf, SaveSeek, 0);
				fseek (mestmp, SaveTemp, 0);
				offset = SaveSeek;
				s = SaveSize;
				l = SaveLin;
				flag = SaveFlag;
				msgCount = SaveCnt;
				if (SetUncompress(ibuf))
					goto Error;
				unpacking = UNCOMPRESS_MAIL;
				maybe = 1;
				inhead = 0;
				continue;

			}
			else if (   EnableUnpack && !notunpack
				 && icequal (linebuf, "x-batch: pack")
				) {

				fseek (tf, SaveSeek, 0);
				fseek (mestmp, SaveTemp, 0);
				offset = SaveSeek;
				s = SaveSize;
				l = SaveLin;
				flag = SaveFlag;
				msgCount = SaveCnt;
				unpacking = UNPACK_MAIL;
				maybe = 1;
				continue;

			}
			else if (   notunpack
				 && (   icequal (linebuf, "x-batch: compress")
					 || icequal (linebuf, "x-batch: pack")
				    )
				)
				notunpack = 0;
#endif  /* UNPACK_MAILBOX */
		}
		offset = ftell(tf);
		s += count;
		l++;
		maybe = (linebuf[0] == '\0');   /* Last line, maybe new will be */
	}
}

/*
 * Drop the passed line onto the passed output buffer.
 * If a write error occurs, return -1, else the count of
 * characters written, including the newline.
 */

putline(obuf, linebuf)
	FILE *obuf;
	char *linebuf;
{
	register int c;

	c = strlen(linebuf);
	fputs(linebuf, obuf);
	putc('\n', obuf);
	if (ferror(obuf))
		return(-1);
	return(c+1);
}

/*
 * Quickly read a line from the specified input into the line
 * buffer; return characters read.
 */

freadline(ibuf, linebuf)
	register FILE *ibuf;
	register char *linebuf;
{
	register int c;
	register char *cp;

	c = getc(ibuf);
	cp = linebuf;
	while (c != '\n' && c != EOF) {
		if (c == 0) {
			c = getc(ibuf);
			continue;
		}
		if (cp - linebuf >= BUFSIZ-1) {
			*cp = 0;
			return(cp - linebuf + 1);
		}
		*cp++ = c;
		c = getc(ibuf);
	}
	if (c == EOF && cp == linebuf)
		return(0);
	*cp = 0;
	return(cp - linebuf + 1);
}

/*
 * Read up a line from the specified input into the line
 * buffer.  Return the number of characters read.  Do not
 * include the newline at the end.
 */

readline(ibuf, linebuf)
	FILE *ibuf;
	char *linebuf;
{
	register char *cp;
	register int c;

	do {
		clearerr(ibuf);
		c = getc(ibuf);
		for (cp = linebuf; c != '\n' && c != EOF; c = getc(ibuf)) {
			if (c == 0)
				continue;
			if (cp - linebuf < LINESIZE-2)
				*cp++ = c;
		}
	} while (ferror(ibuf) && ibuf == stdin);
	*cp = 0;
	if (c == EOF && cp == linebuf)
		return(0);
	return(cp - linebuf + 1);
}

/*
 * Return a file buffer all ready to read up the
 * passed message pointer.
 */

FILE *
setinput(mp)
	register struct message *mp;
{
	if (fseek(tf, mp->m_offset, 0) != 0) {
		ioerror(tempSet, 2);
		panic("temporary file seek");
	}
	return(tf);
}

/*
 * Take the data out of the passed ghost file and toss it into
 * a dynamically allocated message structure.
 */

static
void
makemessage(f)
FILE *f;
{
	register struct message *m;
	char *s;
	int (*compar) ();

	if (message != NULL)
		cfree((char *) message);
	m = (struct message *)calloc((unsigned)(msgCount + 1), sizeof *m);
	if (m == (struct message *)NULL) {
		fprintf(stderr, ediag(
"Insufficient memory for %d messages\n",
"Не хватает памяти для %d сообщений\n"),
msgCount);
		exit(1);
	}
	message = m;
	dot = message;
	rewind(f);
	if (fread((char *)message, sizeof *m, msgCount + 1, f) != msgCount + 1) {
		ioerror(tempSet, 0);
		panic("Can't read mesg headers");
	}
	for (m = &message[0]; m < &message[msgCount]; m++) {
		m->m_size = (m+1)->m_size;
		m->m_lines = (m+1)->m_lines;
		m->m_flag = (m+1)->m_flag;
	}
	message[msgCount].m_size = 0;
	message[msgCount].m_lines = 0;
	if ((s = value("sort")) == NOSTR) {
		if (value("separate-news") != NOSTR)
			s = "file";
	}
	if (s != NOSTR)
		(void) SortMessages(s);
}

static int SeparateNewsgroups;

SortMessages (SortOrder)
char *SortOrder;
{
	int (*compar) ();
	register struct message *mp;
	long offset;
	int modify;

	SeparateNewsgroups = (value("separate-news") != NOSTR);
	if (SortOrder == NOSTR)
		goto trick;
again:
	switch (*SortOrder) {
	case 'f':
		compar = SortAsInFile;
		break;
	case 'd':
		compar = SortByDate;
		break;
	case 's':
		compar = SortBySubject;
		break;
	case 'a':
		compar = SortByAuthor;
		break;
	case '\0':
	trick:
		if ((SortOrder = value("sort")) == NOSTR) {
			if (SeparateNewsgroups)
				SortOrder = "file";
		}
		if (SortOrder == NOSTR || !*SortOrder) {
			printf(ediag("sort kind not defined or separate-news not present\n",
				     "не указан вид сортировки или separate-news\n"));
			return 1;
		}
		goto again;

	default:
		printf(ediag("\"%s\" bad sort order, must be one of the \"file\", \"date\", \"subject\", \"author\"\n",
			     "\"%s\" -- ошибка, должно быть \"file\", \"date\", \"subject\" или \"author\"\n"),
			      SortOrder);
		return 1;
	}

	qsort((char *)message, msgCount, sizeof(struct message), compar);
	dot = &message[0];

	offset = 0;
	modify = 0;
	for (mp = &message[0]; mp < &message[msgCount]; mp++) {
		if (mp->m_offset < offset) {
			modify = 1;
			break;
		}
		else
			offset = mp->m_offset;
	}
	if (modify) {
		for (mp = &message[0]; mp < &message[msgCount]; mp++)
			mp->m_flag |= MODIFY;
	}

	return 0;
}


/*
 * Append the passed message descriptor onto the temp file.
 * If the write fails, return 1, else 0
 */

static
int
append(mp, f)
FILE *f;
struct message *mp;
{
	return (fwrite((char *) mp, sizeof *mp, 1, f) != 1);
}

#if !defined(MSDOS) && !defined(SVR4) && !defined(__386BSD__)
/*
 * Delete a file, but only if the file is a plain file.
 */

remove(name)
	char name[];
{
	struct stat statb;
	extern int errno;

	if (stat(name, &statb) < 0)
		return(-1);
	if ((statb.st_mode & S_IFMT) != S_IFREG) {
		errno = EISDIR;
		return(-1);
	}
	return(unlink(name));
}
#endif  /* not MSDOS && not SVR4 */

/*
 * Terminate an editing session by attempting to write out the user's
 * file from the temporary.  Save any new stuff appended to the file.
 */
void
edstop()
{
	register int gotcha, c, savret;
	register struct message *mp;
	FILE *obuf, *ibuf, *readstat;
	char *vbuf;
	struct stat statb;
	char *id;
	extern char tempBack[];

	if (readonly)
		return;
	holdsigs();
	if (Tflag != NOSTR) {
		if ((readstat = Fopen(Tflag, "w")) == NULL)
			Tflag = NOSTR;
	}
	for (mp = &message[0], gotcha = 0; mp < &message[msgCount]; mp++) {
		if (mp->m_flag & MNEW) {
			mp->m_flag &= ~MNEW;
			mp->m_flag |= MSTATUS;
		}
		if (mp->m_flag & (MODIFY|MDELETED|MSTATUS))
			gotcha++;
		if (Tflag != NOSTR && (mp->m_flag & (MREAD|MDELETED)) != 0) {
			if ((id = hfield("message-id", mp)) != NOSTR)
				fprintf(readstat, "%s\n", id);
		}
	}
	if (Tflag != NOSTR)
		Fclose(readstat);
	if (!gotcha || Tflag != NOSTR)
		goto done;
	ibuf = NULL;
#ifndef MSDOS
	if ((obuf = Fopen(editfile, "r+")) == NULL) {
		fclear(editfile);
		obuf = Fopen(editfile, "r+");
	}
#else
	file_lock(editfile, -1); /* DOS lock must be before open */
	if ((obuf = Fopen(editfile, "r+b")) == NULL) {
		file_unlock();
		fclear(editfile);
		file_lock(editfile, -1); /* DOS lock must be before open */
		obuf = Fopen(editfile, "r+b");
	}
#endif
	if (obuf == NULL) {
		perror(editfile);
#ifdef	MSDOS
		file_unlock();
#endif
		relsesigs();
		reset(0);
	}
	file_lock(editfile, fileno(obuf)); /* Unix lock must be after open */
	vbuf = BestBuffer(obuf);
	printf("\"%s\" ", editfile);
	if (fstat(fileno(obuf), &statb) >= 0 && statb.st_size > mailsize) {
		printf(ediag(
"[has new mail] ",
"[есть новая почта] "));
		flush();        /* Force printouts */
#ifdef  MSDOS
		maketemp(tempBack);
#endif
		if (   fclear(tempBack) < 0
#ifndef	MSDOS
			|| (ibuf = TmpOpen(tempBack, "a+")) == NULL
#else
			|| (ibuf = TmpOpen(tempBack, "a+b")) == NULL
#endif
		   ) {
			perror(tempBack);
			remove(tempBack);
	err1:
#ifndef MSDOS
			file_unlock();
#endif
			Fclose(obuf);
#ifdef  MSDOS
			file_unlock();
#endif
			if (vbuf != NULL)
				free(vbuf);
			relsesigs();
			reset(0);
		}
		if (fseek(obuf, mailsize, 0) != 0) {
			ioerror(editfile, 2);
			TmpDel(ibuf);
			goto err1;
		}
#ifdef  MSDOS
		savret = 0;
#endif
		while ((c = getc(obuf)) != EOF) {
#ifdef	MSDOS
			if (c == CTRL_Z)
				break;
			else if (c == '\r') {
				if (!savret)
					savret = 1;
				else
					putc('\r', ibuf);
			}
			else if (c == '\n') {
				savret = 0;
				putc(c, ibuf);
			}
			else {
				if (savret) {
					putc('\r', ibuf);
					savret = 0;
				}
#endif
				putc(c, ibuf);
#ifdef	MSDOS
			}
#endif
			if (ferror(ibuf)) {
				ioerror(tempBack, 1);
				clearerr(ibuf);
				break;
			}
		}
		if (ferror(obuf)) {
			ioerror(editfile, 0);
			clearerr(ibuf);
		}
		rewind(ibuf);
	}
	else
		flush();
#ifndef FTRUNCATE
	if (fclear(editfile) < 0)
		ioerror(editfile, 1);
#endif
	rewind(obuf);
	c = 0;
	for (mp = &message[0]; mp < &message[msgCount]; mp++) {
		if ((mp->m_flag & MDELETED) != 0)
			continue;
		c++;
		if (send(mp, obuf, SF_BINARY) < 0) {
			ioerror(editfile, 1);
			clearerr(obuf);
			break;
		}
	}
	gotcha = (c == 0 && ibuf == NULL);
	if (ibuf != NULL) {
		while ((c = getc(ibuf)) != EOF) {
#ifdef  MSDOS
			if (c == '\n')
				putc('\r', obuf);
#endif
			putc(c, obuf);
			if (ferror(obuf)) {
				ioerror(editfile, 1);
				clearerr(obuf);
				break;
			}
		}
		TmpDel(ibuf);
	}
	fflush(obuf);
	if (ferror(obuf)) {
		ioerror(editfile, 1);
		clearerr(obuf);
	}
#ifdef  FTRUNCATE
	if (FTRUNCATE(fileno(obuf), ftell(obuf)) < 0)
		ioerror(editfile, 1);
#endif
#ifndef  MSDOS
	file_unlock();
#endif
	Fclose(obuf);
#ifdef  MSDOS
	file_unlock();
#endif
	if (vbuf != NULL)
		free(vbuf);
	if (gotcha) {
		remove(editfile);
		printf(ediag("removed\n","удален\n"));
	}
	else
		printf(ediag("complete\n","завершен\n"));

done:
	relsesigs();
}

static int sigdepth = 0;                /* depth of holdsigs() */
#ifndef MSDOS
static sigtype (*oldhup)();
#endif
static sigtype (*oldint)();
static sigtype (*oldquit)();
/*
 * Hold signals SIGHUP - SIGQUIT.
 */
holdsigs()
{
	register int i;

	if (sigdepth++ == 0) {
#ifndef MSDOS
		oldhup = signal(SIGHUP, SIG_IGN);
#endif
		oldint = signal(SIGINT, SIG_IGN);
		oldquit = signal(SIGQUIT, SIG_IGN);
	}
}

/*
 * Release signals SIGHUP - SIGQUIT
 */
relsesigs()
{
	register int i;

	if (--sigdepth == 0) {
#ifndef MSDOS
		signal(SIGHUP, oldhup);
#endif
		signal(SIGINT, oldint);
		signal(SIGQUIT, oldquit);
	}
}

/*
 * Empty the output buffer.
 */

clrbuf(buf)
	register FILE *buf;
{
	rewind(buf);
}


/*
 * Flush the standard output.
 */

flush()
{
	fflush(stdout);
	fflush(stderr);
}

/*
 * Determine the size of the file possessed by
 * the passed buffer.
 */

off_t
fsize(iob)
	FILE *iob;
{
	off_t curpos, length;

	if ((curpos = ftell(iob)) < 0) {
		ioerror("ftell_cur", 2);
		return 0;
	}
	if (fseek(iob, 0L, 2) != 0) {
		ioerror("fseek_end", 2);
		return 0;
	}
	if ((length = ftell(iob)) < 0) {
		ioerror("ftell_end", 2);
		return 0;
	}
	if (fseek(iob, curpos, 0) != 0) {
		ioerror("fseek_cur", 2);
		return 0;
	}
	return length;
}

off_t
sizef(name)
char *name;
{
	struct stat sbuf;

	if (stat(name, &sbuf) < 0)
		return(0);
	return(sbuf.st_size);
}

extern char prevfile[];

/*
 * Evaluate the string given as a new mailbox name.
 * Supported meta characters:
 *	%	for my system mail box
 *	%user	for user's system mail box
 *	#	for previous file
 *	&	invoker's mbox file
 *	+file	file in folder directory
 *	any shell meta character
 * Return the file name as a dynamic string.
 */
char *
expand(name)
	char name[];
{
	static char xname[BUFSIZ];
	static char cmdbuf[BUFSIZ];
	static char savename[PATHSIZE];
	static char oldmailname[PATHSIZE];
	register char *cp;
#ifndef MSDOS
	register int pid, l, rc;
	int s, pivec[2];
	sigtype (*sigint)();
	struct stat sbuf;
#endif

	/*
	 * The order of evaluation is "%" and "#" expand into constants.
	 * "&" can expand into "+".  "+" can expand into shell meta characters.
	 * Shell meta characters expand into constants.
	 * This way, we make no recursive expansion.
	 */
	switch (*name) {
	case '%':
		if (name[1] != 0) {
			strcpy(savename, myname);
			strcpy(oldmailname, mailname);
			strncpy(myname, name+1, PATHSIZE-1);
			myname[PATHSIZE-1] = 0;
			findmail();
			cp = savestr(mailname);
			strcpy(myname, savename);
			strcpy(mailname, oldmailname);
			return cp;
		}
		strcpy(oldmailname, mailname);
		findmail();
		cp = savestr(mailname);
		strcpy(mailname, oldmailname);
		return cp;
	case '#':
		if (name[1] != 0)
			break;
		if (prevfile[0] == 0) {
			printf(ediag("No previous file\n","Не было предыдущего файла\n"));
			return NOSTR;
		}
		return savestr(prevfile);
	case '&':
		if (name[1] == 0 && (name = value("MBOX")) == NOSTR)
			name = "~/mbox";
		/* fall through */
	}
	if (name[0] == '+' && getfold(cmdbuf) >= 0) {
		cp = copy(cmdbuf, xname);
		copy(name + 1, cp);
		name = savestr(xname);
	}
#ifdef PMCS
	else if (name[0] == '=') {
		if((cp = value("projspool")) == NOSTR)
			cp = PROJSPOOL;
		sprintf(xname, "%s%c%s", cp, SEPCHAR, name + 1);
		name = savestr(xname);
	}
#endif
	else if (name[0] == '~') {
		strcpy(xname, name);
		if (!fill_homedir(xname))
			return(NOSTR);
		name = savestr(xname);
	}
#ifdef  MSDOS
	return name;
#else
	if (!anyof(name, "~{[*?$`'\"\\"))
		return(name);
	if (pipe(pivec) < 0) {
		perror("pipe");
		return(name);
	}
	sprintf(cmdbuf, "echo %s", name);
	if ((pid = vfork()) == 0) {
		close(pivec[0]);
		close(1);
		dup(pivec[1]);
		close(pivec[1]);
		close(2);
		execl("/bin/sh", "sh", "-c", cmdbuf, NULL);
		_exit(1);
	}
	if (pid == -1) {
		perror("fork");
		close(pivec[0]);
		close(pivec[1]);
		return(NOSTR);
	}
	close(pivec[1]);
	l = read(pivec[0], xname, BUFSIZ);
	close(pivec[0]);
	while (wait(&s) != pid);
		;
	s &= 0377;
	if (s != 0 && s != SIGPIPE) {
		fprintf(stderr, ediag("\"%s\": Expansion failed\n",
				      "\"%s\": не удалось расширить\n"), name);
		return NOSTR;
	}
	if (l < 0) {
		ioerror("pipe", 0);
		return NOSTR;
	}
	if (l == 0) {
		fprintf(stderr, ediag(
"\"%s\": No match\n",
"\"%s\": не совпадает\n"),
name);
		return NOSTR;
	}
	if (l == BUFSIZ) {
		fprintf(stderr, ediag(
"Buffer overflow expanding \"%s\"\n",
"Переполнился буфер во время расширения \"%s\"\n"),
name);
		return NOSTR;
	}
	xname[l] = 0;
	for (cp = &xname[l-1]; *cp == '\n' && cp > xname; cp--)
		;
	*++cp = '\0';
	if (any(' ', xname) && stat(xname, &sbuf) < 0) {
		fprintf(stderr, ediag(
"\"%s\": Ambiguous\n",
"\"%s\": неоднозначно\n"),
name);
		return NOSTR;
	}
	return savestr(xname);
#endif  /* not MSDOS */
}

/*
 * Determine the current folder directory name.
 */
getfold(name)
	char *name;
{
	char *folder, *cp;

	if ((folder = value("folder")) == NOSTR)
		return(-1);
	if (*folder == '/'
#ifdef	MSDOS
		|| *folder == SEPCHAR
		|| folder[0] != '\0' && folder[1] == ':'
#endif
	   )
		cp = copy(folder, name);
	else {
		cp = copy(homedir, name);
		if (cp[-1] != '/'
#ifdef	MSDOS
			&& cp[-1] != SEPCHAR
#endif
		   )
			*cp++ = SEPCHAR;
		cp = copy(folder, cp);
	}
	if (cp[-1] != '/'
#ifdef	MSDOS
		&& cp[-1] != SEPCHAR
#endif
	   )
		*cp++ = SEPCHAR;
	*cp = '\0';
#ifdef	MSDOS
	for (cp = name; *cp; cp++)
		if (*cp == '/')
			*cp = SEPCHAR;
#endif
	return(0);
}

fclear(name)
char *name;
{
	struct stat st;
	int mode;
	int f;

	if (stat(name, &st) < 0)
		mode = 0600;
	else
		mode = st.st_mode;

	if ((f = open(name, O_WRONLY|O_TRUNC|O_CREAT, mode)) < 0)
		return -1;
	if (close(f) < 0)
		return -1;
	return f;
}

#ifdef  MSDOS
void
seekctlz(f)
FILE *f;
{
	long size, offset;

	fseek(f, 0L, 2);
	size = ftell(f);
	for (offset = 1; offset <= size; offset++) {
		fseek(f, -offset, 2);
		if (getc(f) != CTRL_Z) {
			fseek(f, 0L, 1);	/* One seek between read and write */
			return;
		}
	}
	rewind(f);
}
#endif

ioerror(name, mode)
char *name;
{
	char *s;

	switch (mode) {
	case 0:
		s = ediag("write","чтения");
		break;
	case 1:
		s = ediag("read","записи");
		break;
	case 2:
		s = ediag("seek","позиционирования");
		break;
	default:
		s = ediag("program","программы");
		break;
	}
	if (name == NULL)
		fprintf(stderr, ediag(": %s error!\n", ": ошибка %s!\n"),
			s);
	else
		fprintf(stderr, ediag("%s: %s error!\n", "%s: ошибка %s!\n"),
			name, s);
}

/*
 * Return the name of the dead.letter file.
 */
char *
getdeadletter()
{
	register char *cp;

	if ((cp = value("DEAD")) == NOSTR || (cp = expand(cp)) == NOSTR)
#ifndef MSDOS
		cp = expand("~/dead.letter");
#else
		cp = expand("~/dead.let");
#endif
	else if (!isfileaddr(cp)) {
		char buf[PATHSIZE];

		(void) sprintf(buf, "~/%s", cp);
		cp = expand(buf);
	}
	return cp;
}

int
SortByDate(a, b)
struct message *a, *b;
{
	long date1, date2;
	char *s1, *s2;
	int cmp, SavSep;

	date1 = GetDate(a);
	date2 = GetDate(b);

	if (SeparateNewsgroups) {
		if ((s1 = hfield("newsgroups", a)) == NOSTR)
			s1 = "";
		if ((s2 = hfield("newsgroups", b)) == NOSTR)
			s2 = "";
		if ((cmp = strcmp (s1, s2)) != 0) {
			sreset();
			return cmp;
		}
	}
	cmp = (date1 < date2 ? -1 : (date1 > date2 ? 1 : 0));
	if (cmp != 0) {
		sreset();
		return cmp;
	}

	SavSep = SeparateNewsgroups;
	SeparateNewsgroups = 0;
	cmp = SortAsInFile(a, b);
	SeparateNewsgroups = SavSep;
	sreset();

	return cmp;
}

int
SortAsInFile(a, b)
struct message *a, *b;
{
	int cmp;
	char *s1, *s2;

	if (SeparateNewsgroups) {
		if ((s1 = hfield("newsgroups", a)) == NOSTR)
			s1 = "";
		if ((s2 = hfield("newsgroups", b)) == NOSTR)
			s2 = "";
		if ((cmp = strcmp (s1, s2)) != 0) {
			sreset();
			return cmp;
		}
	}
	return (a->m_offset < b->m_offset ? -1 : (a->m_offset > b->m_offset ? 1 : 0));
}

int
SortBySubject(a, b)
struct message *a, *b;
{
	char *s1, *s2;
	int i, SavSep;

	if (SeparateNewsgroups) {
		if ((s1 = hfield("newsgroups", a)) == NOSTR)
			s1 = "";
		if ((s2 = hfield("newsgroups", b)) == NOSTR)
			s2 = "";
		if ((i = strcmp (s1, s2)) != 0) {
			sreset();
			return i;
		}
	}

	s1 = hfield("subject", a);
	if (s1 == NOSTR)
		s1 = hfield("subj", a);
	s2 = hfield("subject", b);
	if (s2 == NOSTR)
		s2 = hfield("subj", b);

	if (s1) {
		while (isspace(*s1))
			s1++;
		if (!*s1)
			s1 = NOSTR;
	}
	if (s2) {
		while (isspace(*s2))
			s2++;
		if (!*s2)
			s2 = NOSTR;
	}
	if (s1 == NOSTR && s2 == NOSTR)
		goto Ret;
	if (s1 == NOSTR) {
		sreset();
		return -1;
	}
	if (s2 == NOSTR) {
		sreset();
		return 1;
	}

	for ( ; ; ) {
		if (s1[0] == '[' && strncmp("[NEWS] ", s1, 7) == 0)
			s1 += 7;
		else if (s1[0] == '[' && strncmp("[News] ", s1, 7) == 0)
			s1 += 7;
		else if (s1[0] == 'R' && strncmp("Re: ", s1, 4) == 0)
			s1 += 4;
		else if (s1[0] == 'r' && strncmp("re: ", s1, 4) == 0)
			s1 += 4;
		else
			break;
	}

	for ( ; ; ) {
		if (s2[0] == '[' && strncmp("[NEWS] ", s2, 7) == 0)
			s2 += 7;
		else if (s2[0] == '[' && strncmp("[News] ", s2, 7) == 0)
			s2 += 7;
		else if (s2[0] == 'R' && strncmp("Re: ", s2, 4) == 0)
			s2 += 4;
		else if (s2[0] == 'r' && strncmp("re: ", s2, 4) == 0)
			s2 += 4;
		else
			break;
	}

	if ((i = inumlcmp(s1, s2)) != 0) {
		sreset();
		return i;
	}

Ret:
	SavSep = SeparateNewsgroups;
	SeparateNewsgroups = 0;
	i = SortByDate(a, b);
	SeparateNewsgroups = SavSep;

	return i;
}

extern InHeaderList;

int
SortByAuthor(a, b)
struct message *a, *b;
{
	char *s1, *s2;
	int i, SavSep;

	if (SeparateNewsgroups) {
		if ((s1 = hfield("newsgroups", a)) == NOSTR)
			s1 = "";
		if ((s2 = hfield("newsgroups", b)) == NOSTR)
			s2 = "";
		if ((i = strcmp (s1, s2)) != 0) {
			sreset();
			return i;
		}
	}

	InHeaderList = 1;
	s1 = nameof(a, FOR_display);
	s2 = nameof(b, FOR_display);
	InHeaderList = 0;

	if ((i = istrlcmp(s1, s2)) != 0) {
		sreset();
		return i;
	}

	SavSep = SeparateNewsgroups;
	SeparateNewsgroups = 0;
	i = SortByDate(a, b);
	SeparateNewsgroups = SavSep;

	return i;
}
