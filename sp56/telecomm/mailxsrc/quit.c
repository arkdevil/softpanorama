/*
 * Rcv -- receive mail rationally.
 *
 * Termination processing.
 *
 * $Log:	quit.c,v $
 * Revision 1.8  93/01/04  02:23:23  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.7  92/08/24  02:21:36  ache
 * Основательные правки и перенос в разные системы
 * 
 * Revision 1.10  1991/07/22  16:36:47  ache
 * Port to Borland C
 *
 * Revision 1.9  1991/01/19  15:38:23  ache
 * убраны буфера 16к, как не оправдавшие доверия народа
 *
 * Revision 1.8  90/12/23  21:09:40  ache
 * Буферизация IO по 16 К
 * 
 * Revision 1.7  90/12/07  07:15:28  ache
 * Переделана обработка временных файлов и мелочи
 * 
 * Revision 1.6  90/09/22  20:09:50  avg
 * int p ---> long p
 *
 * Revision 1.5  90/09/21  22:00:19  ache
 * MS-DOS extends + some new stuff
 *
 * Revision 1.4  90/09/13  17:50:31  ache
 * MS-DOS & Unix together...
 *
 * Revision 1.3  88/07/23  20:37:41  ache
 * Русские диагностики
 *
 * Revision 1.2  88/01/11  12:45:02  avg
 * Добавлен NOXSTR у rcsid.
 *
 * Revision 1.1  87/12/25  16:00:32  avg
 * Initial revision
 *
 */

#include "rcv.h"
#include <sys/stat.h>

static void writeback();
extern char *BestBuffer(), *cnts();

/*NOXSTR*/
static char rcsid[] = "$Header: quit.c,v 1.8 93/01/04 02:23:23 ache Exp $";
/*YESXSTR*/

/*
 * Save all of the undetermined messages at the top of "mbox"
 * Save all untouched messages back in the system mailbox.
 * Remove the system mailbox, if none saved there.
 */
void
quit()
{
	int mcount, p, modify, autohold, anystat, holdbit, nohold;
	long lp;
	FILE *ibuf = NULL, *obuf = NULL, *abuf = NULL, *fbuf = NULL, *rbuf = NULL, *readstat;
	char *vbuf = NULL, *v_fbuf = NULL, *mbox;
	register struct message *mp;
	register int c;
	extern char tempQuit[], tempResid[];
	struct stat minfo;
	char *id;
#ifdef	MSDOS
	int savret;
#endif

	/*
	 * If we are read only, we can't do anything,
	 * so just return quickly.
	 */

	if (readonly)
		return;
	/*
	 * See if there any messages to save in mbox.  If no, we
	 * can save copying mbox to /tmp and back.
	 *
	 * Check also to see if any files need to be preserved.
	 * Delete all untouched messages to keep them out of mbox.
	 * If all the messages are to be preserved, just exit with
	 * a message.
	 *
	 * If the luser has sent mail to himself, refuse to do
	 * anything with the mailbox, unless mail locking works.
	 */

#ifndef CANLOCK
	if (selfsent) {
		printf(ediag("You have new mail.\n",
			     "Вам есть новая почта.\n"));
		return;
	}
#endif
	ibuf = rbuf = NULL;
#ifndef MSDOS
	if ((fbuf = Fopen(mailname, "r+")) == NULL) {
		fclear(mailname);
		fbuf = Fopen(mailname, "r+");
	}
#else
	file_lock(mailname, -1); /* DOS lock must be before open */
	if ((fbuf = Fopen(mailname, "r+b")) == NULL) {
		file_unlock();
		fclear(mailname);
		file_lock(mailname, -1); /* DOS lock must be before open */
		fbuf = Fopen(mailname, "r+b");
	}
#endif
	if (fbuf == NULL)
		goto newmail;
	file_lock(mailname, fileno(fbuf)); /* Unix lock must be after open */
	v_fbuf = BestBuffer(fbuf);
	if (fstat(fileno(fbuf), &minfo) >= 0 && minfo.st_size > mailsize) {
		printf(ediag(
"New mail has arrived.\n",
"Пришла новая почта.\n"));
		flush();        /* Force printouts */
#ifdef  MSDOS
		maketemp(tempResid);
#endif
		if (   fclear(tempResid) < 0
#ifndef	MSDOS
			|| (rbuf = TmpOpen(tempResid, "a+")) == NULL
#else
			|| (rbuf = TmpOpen(tempResid, "a+b")) == NULL
#endif
		   ) {
			perror(tempResid);
			remove(tempResid);
			goto newmail;
		}
#ifdef MSDOS
		savret = 0;
#endif
#ifdef APPEND
		if (fseek(fbuf, mailsize, 0) != 0) {
			ioerror(mailname, 2);
			goto newmail;
		}
		while ((c = getc(fbuf)) != EOF) {
#ifdef	MSDOS
			if (c == CTRL_Z)
				break;
			else if (c == '\r') {
				if (!savret)
					savret = 1;
				else
					putc('\r', rbuf);
			}
			else if (c == '\n') {
				savret = 0;
				putc(c, rbuf);
			}
			else {
				if (savret) {
					putc('\r', rbuf);
					savret = 0;
				}
#endif
				putc(c, rbuf);
#ifdef	MSDOS
			}
#endif
			if (ferror(rbuf)) {
				ioerror(tempResid, 1);
				clearerr(rbuf);
				break;
			}
		}
#else   /*!APPEND*/
		lp = minfo.st_size - mailsize;
		while (lp-- > 0) {
			c = getc(fbuf);
			if (   c == EOF
#ifdef	MSDOS
			    || c == CTRL_Z
#endif
			   )
				goto newmail;
#ifdef	MSDOS
			else if (c == '\r') {
				if (!savret)
					savret = 1;
				else
					putc('\r', rbuf);
			}
			else if (c == '\n') {
				savret = 0;
				putc(c, rbuf);
			}
			else {
				if (savret) {
					putc('\r', rbuf);
					savret = 0;
				}
#endif
				putc(c, rbuf);
#ifdef	MSDOS
			}
#endif
			if (ferror(rbuf)) {
				ioerror(tempResid, 1);
				clearerr(rbuf);
				break;
			}
		}
#endif  /*!APPEND*/
		rewind(rbuf);
		if (ferror(fbuf)) {
			ioerror(mailname, 0);
			clearerr(fbuf);
		}
	}

	/*
	 * Adjust the message flags in each message.
	 */

	anystat = 0;
	autohold = value("hold") != NOSTR;
	holdbit = autohold ? MPRESERVE : MBOX;
	nohold = MBOX|MSAVED|MDELETED|MPRESERVE;
	if (value("keepsave") != NOSTR)
		nohold &= ~MSAVED;
	for (mp = &message[0]; mp < &message[msgCount]; mp++) {
		if (mp->m_flag & MNEW) {
			mp->m_flag &= ~MNEW;
			mp->m_flag |= MSTATUS;
		}
		if (mp->m_flag & MSTATUS)
			anystat++;
		if ((mp->m_flag & MTOUCH) == 0)
			mp->m_flag |= MPRESERVE;
		if ((mp->m_flag & nohold) == 0)
			mp->m_flag |= holdbit;
	}
	modify = 0;
	if (Tflag != NOSTR) {
		if ((readstat = Fopen(Tflag, "w")) == NULL)
			Tflag = NOSTR;
	}
	for (c = 0, p = 0, mp = &message[0]; mp < &message[msgCount]; mp++) {
		if (mp->m_flag & MBOX)
			c++;
		if (mp->m_flag & MPRESERVE)
			p++;
		if (mp->m_flag & MODIFY)
			modify++;
		if (Tflag != NOSTR && (mp->m_flag & (MREAD|MDELETED)) != 0) {
			id = hfield("message-id", mp);
			if (id != NOSTR)
				fprintf(readstat, "%s\n", id);
		}
	}
	if (Tflag != NOSTR)
		Fclose(readstat);

	if (p == msgCount && !modify && !anystat) {
		if (p > 0)
			printf(ediag("Held %d message%s%s in %s\n",
				     "%d пис%s оста%s в %s\n"),
			       p,
			       cnts(p, ediag("", "ьмо"), ediag("s", "ьма"), ediag("s", "ем")),
			       ediag("", p > 1 ? "ются" : "ется"),
			       mailname);
		goto xit;
	}

	if (c == 0) {
		if (p != 0) {
			writeback(rbuf, fbuf);
			goto xit;
		}
		goto cream;
	}

	if ((mcount = c) <= 0)
		goto no_mbox;
	/*
	 * Create another temporary file and copy user's mbox file
	 * darin.  If there is no mbox, copy nothing.
	 * If he has specified "append" don't copy his mailbox,
	 * just copy saveable entries at the end.
	 */

	mbox = expand("&");
	printf("\"%s\": ", mbox);
	if (   value("append") == NOSTR
#ifndef	MSDOS
	    && (obuf = Fopen(mbox, "r+")) != NULL
#else
	    && (obuf = Fopen(mbox, "r+b")) != NULL
#endif
	   ) {
#ifdef  MSDOS
		savret = 0;
		maketemp(tempQuit);
#endif
		flush();        /* Force printouts */
		if (   fclear(tempQuit) < 0
#ifndef	MSDOS
			|| (ibuf = TmpOpen(tempQuit, "a+")) == NULL
#else
			|| (ibuf = TmpOpen(tempQuit, "a+b")) == NULL
#endif
		   ) {
			perror(tempQuit);
			remove(tempQuit);
			goto xit;
		}
		vbuf = BestBuffer(obuf);
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
				ioerror(tempQuit, 1);
				clearerr(ibuf);
				break;
			}
		}
		if (ferror(obuf)) {
			ioerror(mbox, 0);
			clearerr(obuf);
		}
		rewind(ibuf);
		if (ferror(ibuf)) {
			ioerror(tempQuit, 1);
			clearerr(ibuf);
		}
#ifndef FTRUNCATE
		if (fclear(mbox) < 0)
			ioerror(mbox, 1);
#endif
		rewind(obuf);
	}
#ifndef MSDOS
	else if ((obuf = Fopen(mbox, "a")) == NULL) {
#else
	else if (   (obuf = Fopen(mbox, "r+b")) == NULL
		 && (fclear(mbox), obuf = Fopen(mbox, "r+b")) == NULL
		) {
#endif
			perror(mbox);
			goto xit;
		}
	else {
		vbuf = BestBuffer(obuf);
		flush();        /* Force printouts */
#ifdef  MSDOS
		seekctlz(obuf);
#endif
	}

	for (mp = &message[0]; mp < &message[msgCount]; mp++)
		if (mp->m_flag & MBOX)
			if (send(mp, obuf, SF_BINARY) < 0) {
				ioerror(mbox, 1);
				clearerr(obuf);
				break;
			}

	/*
	 * Copy the user's old mbox contents back
	 * to the end of the stuff we just saved.
	 * If we are appending, this is unnecessary.
	 */

	if (value("append") == NOSTR) {
		while ((c = getc(ibuf)) != EOF) {
#ifdef  MSDOS
			if (c == '\n')
				putc('\r', obuf);
#endif
			putc(c, obuf);
			if (ferror(obuf)) {
				ioerror(mbox, 1);
				clearerr(obuf);
				break;
			}
		}
		TmpDel(ibuf);
		ibuf = NULL;
	}
	fflush(obuf);
	if (ferror(obuf)) {
		ioerror(mbox, 1);
		clearerr(obuf);
	}
#ifdef  FTRUNCATE
	if (FTRUNCATE(fileno(obuf), ftell(obuf)) < 0)
		ioerror(mbox, 1);
#endif
	Fclose(obuf);
	if (vbuf != NULL) {
		free(vbuf);
		vbuf = NULL;
	}
	printf(ediag("%s%d message%s saved\n",
		     "записан%s %d пис%s\n"),
	       ediag("", mcount > 1 ? "ы" : "о"),
	       mcount,
	       cnts(mcount, ediag("", "ьмо"), ediag("s", "ьма"), ediag("s", "ем"))
	       );

no_mbox:
	/*
	 * Now we are ready to copy back preserved files to
	 * the system mailbox, if any were requested.
	 */

	if (p != 0) {
		writeback(rbuf, fbuf);
		goto xit;
	}

	/*
	 * Finally, remove his /usr/mail file.
	 * If new mail has arrived, copy it back.
	 */

cream:
	if (rbuf != NULL) {
		flush();        /* flush any printouts */
#ifndef FTRUNCATE
		if (fclear(mailname) < 0)
			ioerror(mailname, 1);
#endif
		rewind(fbuf);
		while ((c = getc(rbuf)) != EOF) {
#ifdef	MSDOS
			if (c == '\n')
				putc('\r', fbuf);
#endif
			putc(c, fbuf);
			if (ferror(fbuf)) {
				ioerror(mailname, 1);
				clearerr(fbuf);
				break;
			}
		}
		fflush(fbuf);
		if (ferror(fbuf)) {
			ioerror(mailname, 1);
			clearerr(fbuf);
		}
#ifdef  FTRUNCATE
		if (FTRUNCATE(fileno(fbuf), ftell(fbuf)) < 0)
			ioerror(mailname, 1);
#endif
		alter(mailname);
	}
	else {
#ifdef MSDOS
		/* Can't remove opened files */
		if (fbuf != NULL) {
			Fclose(fbuf);
			fbuf = NULL;
		}
		file_unlock();
#endif
		demail();
	}
	goto xit;

newmail:
	printf(ediag("Thou hast new mail.\n","Вам пришла новая почта.\n"));
xit:
	if (abuf != NULL)
		Fclose(abuf);
	if (obuf != NULL)
		Fclose(obuf);
	if (fbuf != NULL) {
#ifndef MSDOS
		file_unlock();
#endif
		Fclose(fbuf);
#ifdef  MSDOS
		file_unlock();
#endif
	}
	if (vbuf != NULL)
		free(vbuf);
	if (v_fbuf != NULL)
		free(v_fbuf);
	TmpDel(rbuf);
	TmpDel(ibuf);
}

/*
 * Preserve all the appropriate messages back in the system
 * mailbox, and print a nice message indicated how many were
 * saved.  On any error, just return -1.  Else return 0.
 * Incorporate the any new mail that we found.
 */
static
void
writeback(res, obuf)
	register FILE *res, *obuf;
{
	register struct message *mp;
	register int p, c;

	p = 0;
	flush();        /* flush any printouts */
#ifndef FTRUNCATE
	if (fclear(mailname) < 0)
		ioerror(mailname, 1);
#endif
	rewind(obuf);
#ifndef APPEND
	if (res != NULL) {
		while ((c = getc(res)) != EOF) {
#ifdef	MSDOS
			if (c == '\n')
				putc('\r', obuf);
#endif
			putc(c, obuf);
			if (ferror(obuf)) {
				ioerror(mailname, 1);
				clearerr(obuf);
				break;
			}
		}
	}
#endif  /*!APPEND*/
	for (mp = &message[0]; mp < &message[msgCount]; mp++)
		if ((mp->m_flag&MPRESERVE)||(mp->m_flag&MTOUCH)==0) {
			p++;
			if (send(mp, obuf, SF_BINARY) < 0) {
				ioerror(mailname, 1);
				clearerr(obuf);
				break;
			}
		}
#ifdef APPEND
	if (res != NULL) {
		while ((c = getc(res)) != EOF) {
#ifdef	MSDOS
			if (c == '\n')
				putc('\r', obuf);
#endif
			putc(c, obuf);
			if (ferror(obuf)) {
				ioerror(mailname, 1);
				clearerr(obuf);
				break;
			}
		}
	}
#endif  /*APPEND*/
	fflush(obuf);
	if (ferror(obuf)) {
		ioerror(mailname, 1);
		clearerr(obuf);
	}
#ifdef  FTRUNCATE
	if (FTRUNCATE(fileno(obuf), ftell(obuf)) < 0)
		ioerror(mailname, 1);
#endif
	alter(mailname);
	if (p > 0)
		printf(ediag("Held %d message%s%s in %s\n",
			     "%d пис%s оста%s в %s\n"),
		       p,
		       cnts(p, ediag("", "ьмо"), ediag("s", "ьма"), ediag("s", "ем")),
		       ediag("", p > 1 ? "ются" : "ется"),
		       mailname);
}
