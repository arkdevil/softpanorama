/*
 * Mail -- a mail program
 *
 * Generally useful tty stuff.
 *
 * $Log:	tty.c,v $
 * Revision 1.10  93/01/04  02:24:29  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.9  92/08/24  02:23:01  ache
 * Основательные правки и перенос в разные системы
 * 
 * Revision 1.15  1992/05/17  14:48:46  ache
 * Fine port to Ultrix
 *
 * Revision 1.14  1991/07/22  16:36:47  ache
 * Port to Borland C
 *
 * Revision 1.13  1991/07/19  20:00:14  ache
 * Добавлена рассылка сообщений в телеконференции
 *
 * Revision 1.12  1991/04/26  17:10:00  ache
 * Cosmetic changes
 *
 * Revision 1.11  1991/04/19  22:50:22  asa
 * Изменения для Демос 32
 *
 * Revision 1.10  1991/01/25  18:18:41  ache
 * Чтобы пользователи больше не спрашивали
 * 	- Что такое Суб`ект: ?
 * Subject, To, Cc и т.п. запрашиваются по ediag по русски
 *
 * Revision 1.9  1991/01/25  18:04:45  ache
 * Убраны старые (4.1) сигналы
 *
 * Revision 1.8  90/10/25  01:15:19  ache
 * jmp -> VMUNIX
 * 
 * Revision 1.7  90/10/04  02:28:23  ache
 * if (!isprint(c)) then '$' in readtty
 * 
 * Revision 1.6  90/09/13  13:20:56  ache
 * MS-DOS & Unix together...
 * 
 * Revision 1.5  90/05/31  22:22:58  avg
 * Добавлена обработка CTRL/C при вводе полей заголовка.
 * 
 * Revision 1.4  90/04/20  19:17:26  avg
 * Прикручено под System V
 * 
 * Revision 1.3  88/07/23  20:38:56  ache
 * Русские диагностики
 * 
 * Revision 1.2  88/01/11  12:35:07  avg
 * Для ДЕМОС 2 сделан ввод без использования TIOCSTI (т.к. есть разные
 * нюансы в работе ея с русскими буквами).
 * Добавлен NOXSTR у rcsid.
 * 
 * Revision 1.1  87/12/25  16:01:01  avg
 * Initial revision
 *
 */

#include "rcv.h"
#if !defined(USE_TERMIOS) && !defined(MSDOS)
#include <sys/ioctl.h>
#ifdef SVR3
#include <sys/stream.h>
#include <sys/ptem.h>
#endif
#endif

/*NOXSTR*/
static char rcsid[] = "$Header: tty.c,v 1.10 93/01/04 02:24:29 ache Exp $";
/*YESXSTR*/

#ifdef  MSDOS
#include        <conio.h>
#endif

#if !defined(USE_SGTTY) && !defined(MSDOS)
#define sg_erase        c_cc[VERASE]
#define sg_kill         c_cc[VKILL]
static struct sgttyb svm;       /* Saved old modes */
#endif

#define Ctrl(c) ((c)&037)

static  int     crterase = 1;    /* TTY allows CRT BS-ing */
static  int     c_erase = Ctrl('H');            /* Current erase char */
static  int     c_kill =  Ctrl('U');            /* Current kill char */
static  int     c_intr =  Ctrl('C');
static  int     c_quit =  Ctrl('\\');
static  int     hadcont;                /* Saw continue signal */
#ifdef  SIGCONT
static  jmp_buf rewrite;                /* Place to go when continued */
#endif
static char *readtty();

#ifndef TIOCSTI
#ifndef MSDOS
static int sflgs;
static int ttyset;
static struct sgttyb xttybuf;
#endif  /* !MSDOS */
#endif  /* !TIOCSTI */

#ifndef MSDOS
static  struct sgttyb ttybuf;
#endif

/*
 * Read all relevant header fields.
 */
grabh(hp, gflags)
	struct header *hp;
{
#ifdef  SIGCONT
	sigtype sigcont();
	sigtype (*savecont)();
#endif
#if defined(SIGTSTP) && !defined(TIOCSTI)
	sigtype restty();
	sigtype (*savetstp)();
#endif
#ifndef TIOCSTI
	sigtype (*savesigs[2])();
#endif
	register int s;
	int errs;

#if defined(SIGTSTP) && !defined(TIOCSTI)
	savetstp = sigset(SIGTSTP, restty);
# endif
# ifdef SIGCONT
	savecont = sigset(SIGCONT, sigcont);
# endif
	errs = 0;
#ifndef MSDOS
#ifndef TIOCSTI
	ttyset = 0;
#endif
	if (gtty(fileno(stdin), &ttybuf) < 0) {
		perror("gtty");
		return(-1);
	}
	c_erase = ttybuf.sg_erase;
	c_kill = ttybuf.sg_kill;
#ifndef TIOCSTI
	ttybuf.sg_erase = 0;
	ttybuf.sg_kill = 0;
#ifdef USE_SGTTY
	sflgs = ttybuf.sg_flags;
	ttybuf.sg_flags |= CBREAK;
	ttybuf.sg_flags &= ~ECHO;
	crterase = ((ttybuf.sg_local & (LCRTERA|LCRTBS|LPRTERA)) ==
					   (LCRTERA|LCRTBS));
	c_intr = ttybuf.sg_intrc;
	c_quit = ttybuf.sg_quitc;
	ttybuf.sg_intrc = 0;
	ttybuf.sg_quitc = 0;
#else
	svm = ttybuf;
	c_intr = ttybuf.c_cc[VINTR];
	c_quit = ttybuf.c_cc[VQUIT];
	ttybuf.c_cc[VINTR] = 0;
	ttybuf.c_cc[VQUIT] = 0;
	ttybuf.c_lflag &= ~(ICANON|ECHO);
	ttybuf.c_cc[VMIN]  = 1;
	ttybuf.c_cc[VTIME] = 0;
	crterase = (ttybuf.c_lflag & ECHOE) || (c_erase == '\10');
#endif  /* !M_SYSV */
	if ((savesigs[0] = signal(SIGINT, SIG_IGN)) == SIG_DFL)
		signal(SIGINT, SIG_DFL);
	if ((savesigs[1] = signal(SIGQUIT, SIG_IGN)) == SIG_DFL)
		signal(SIGQUIT, SIG_DFL);
#endif  /* !TIOCSTI */
#endif  /* not MSDOS */
	if (gflags & GTO) {
#if !defined(MSDOS) && !defined(TIOCSTI)
		if (!ttyset && hp->h_to_template != NOSTR)
			ttyset++, stty(fileno(stdin), &ttybuf);
#endif
		hp->h_to_template = readtty(ediag("To: ", "Кому: "),
					    hp->h_to_template);
	}
	if (gflags & GNGR) {
#if !defined(MSDOS) && !defined(TIOCSTI)
		if (!ttyset && hp->h_newsgroups != NOSTR)
			ttyset++, stty(fileno(stdin), &ttybuf);
#endif
		hp->h_newsgroups = readtty(ediag("Newsgroups: ", "Телеконференции: "), hp->h_newsgroups);
		if (hp->h_seq == 0 && hp->h_newsgroups != NOSTR)
			hp->h_seq++;
	}
	if (gflags & GSUBJECT) {
#if !defined(MSDOS) && !defined(TIOCSTI)
		if (!ttyset && hp->h_subject != NOSTR)
			ttyset++, stty(fileno(stdin), &ttybuf);
#endif
		hp->h_subject = readtty(ediag("Subject: ", "Тема: "), hp->h_subject);
		if (hp->h_seq == 0 && hp->h_subject != NOSTR)
			hp->h_seq++;
	}
	if (gflags & GNEWS) {
#if !defined(MSDOS) && !defined(TIOCSTI)
		if (!ttyset && hp->h_keywords != NOSTR)
			ttyset++, stty(fileno(stdin), &ttybuf);
#endif
		hp->h_keywords = readtty(ediag("Keywords: ", "Ключевые слова: "), hp->h_keywords);
		if (hp->h_seq == 0 && hp->h_keywords != NOSTR)
			hp->h_seq++;
#if !defined(MSDOS) && !defined(TIOCSTI)
		if (!ttyset && hp->h_summary != NOSTR)
			ttyset++, stty(fileno(stdin), &ttybuf);
#endif
		hp->h_summary = readtty(ediag("Summary: ", "Содержание: "), hp->h_summary);
		if (hp->h_seq == 0 && hp->h_summary != NOSTR)
			hp->h_seq++;
#if !defined(MSDOS) && !defined(TIOCSTI)
		if (!ttyset && hp->h_distribution != NOSTR)
			ttyset++, stty(fileno(stdin), &ttybuf);
#endif
		hp->h_distribution = readtty(ediag("Distribution: ", "Распространение: "), hp->h_distribution);
		if (hp->h_seq == 0 && hp->h_distribution != NOSTR)
			hp->h_seq++;
	}
	if (gflags & GCC) {
#if !defined(MSDOS) && !defined(TIOCSTI)
		if (!ttyset && hp->h_cc_template != NOSTR)
			ttyset++, stty(fileno(stdin), &ttybuf);
#endif
		hp->h_cc_template = readtty(ediag("Cc: ", "Копию: "),
					    hp->h_cc_template);
	}
	if (gflags & GBCC) {
#if !defined(MSDOS) && !defined(TIOCSTI)
		if (!ttyset && hp->h_bcc_template != NOSTR)
			ttyset++, stty(fileno(stdin), &ttybuf);
#endif
		hp->h_bcc_template = readtty(ediag("Bcc: ", "Невидимую копию: "),
					     hp->h_bcc_template);
	}
# ifdef SIGCONT
	sigset(SIGCONT, savecont);
# endif
#if defined(SIGTSTP) && !defined(TIOCSTI)
	sigset(SIGTSTP, savetstp);
#endif
#if !defined(MSDOS) && !defined(TIOCSTI)
#ifdef USE_SGTTY
	ttybuf.sg_flags = sflgs;
	ttybuf.sg_intrc = c_intr;
	ttybuf.sg_quitc = c_quit;
#else
	ttybuf = svm;
#endif
	ttybuf.sg_erase = c_erase;
	ttybuf.sg_kill  = c_kill;
	if (ttyset) {
		stty(fileno(stdin), &ttybuf);
		ttyset = 0;
	}
	signal(SIGINT, savesigs[0]);
	signal(SIGQUIT, savesigs[1]);
#endif  /* not MSDOS */

	return(errs);
}

/*
 * Read up a header from standard input.
 * The source string has the preliminary contents to
 * be read.
 *
 */

static
char *
readtty(pr, src)
	char pr[], src[];
{
	char ch, canonb[BUFSIZ];
	int c;
	register char *cp, *cp2;
	int sigctr = 0;
#ifdef  SIGCONT
	sigtype ttycont (), sigcont ();
#endif

EditAgain:
	fputs(pr, stdout);
	flush();
	if (src != NOSTR && strlen(src) > BUFSIZ - 2) {
		printf(ediag("too long to edit\n",
"слишком длинная для редактирования\n"));
		return(src);
	}
#ifndef TIOCSTI
	if (src != NOSTR)
		cp = copy(src, canonb);
	else
		cp = copy("", canonb);
	fputs(canonb, stdout);
	flush();
#else
	cp = (src == NOSTR) ? "" : src;
	while (c = (unsigned char)*cp++) {
		if (c == c_erase || c == c_kill) {
			ch = '\\';
			ioctl(fileno(stdin), TIOCSTI, &ch);
		}
		ch = c;
		ioctl(fileno(stdin), TIOCSTI, &ch);
	}
	cp = canonb;
	*cp = '\0';
#endif
	cp2 = cp;
	while (cp2 < canonb + BUFSIZ)
		*cp2++ = 0;
	cp2 = cp;
# ifdef SIGCONT
	if (setjmp(rewrite))
		goto redo;
	sigset(SIGCONT, ttycont);
# endif
#ifdef TIOCSTI
	while (cp2 < canonb + BUFSIZ) {
		c = getc(stdin);
		if (c == EOF || c == '\n')
			break;
		*cp2++ = c;
	}
	*cp2 = 0;
#else
	/* SIMULATE SCREEN EDITING FUNCTIONS */
#ifndef MSDOS
	if (!ttyset)
		ttyset++, stty(fileno(stdin), &ttybuf);
#endif
	for( cp2 = canonb; *cp2 ; cp2++ );
	for(;;) {
		static crterf = 0;

#ifndef MSDOS
		c = getchar();
#else
		c = getch();
#endif
		if( c == c_intr || c == c_quit ) {
#ifndef	MSDOS
#ifdef USE_SGTTY
			xttybuf = ttybuf;
			xttybuf.sg_flags = sflgs;
			xttybuf.sg_intrc = c_intr;
			xttybuf.sg_quitc = c_quit;
#else
			xttybuf = svm;
#endif
			xttybuf.sg_erase = c_erase;
			xttybuf.sg_kill  = c_kill;
			stty(fileno(stdin), &xttybuf);
			ttyset = 0;
#endif	/* not MSDOS */
			putchar('\n');

			if( sigctr ) {
				extern hadintr;
				hadintr++;
				collrub(SIGINT);
			}

			printf(ediag("(Interrupt -- one more to kill letter)\n",
					 "(Прерывание -- чтобы уничтожить письмо нужно еще одно)\n"));
			sigctr++;
			goto EditAgain;
		}
		if( c == '\n' || c == '\r' || c == EOF ) {
			putchar('\n');
			break;
		}
		if( c == c_erase ) {
			if( cp2 > canonb ) {
				if( crterase )
					printf( "\b \b" );
				else {
					if( !crterf ) {
						crterf++;
						putchar( '[' );
					}
					putc(cp2[-1], stdout);
				}
				*--cp2 = 0;
			}
		} else if( c == c_kill ) {
			if( crterase ) {
				while( cp2-- > canonb )
					printf( "\b \b" );
			} else
				printf( "^U\n" );
			cp2 = canonb;
			*cp2 = 0;
			crterf = 0;
		} else {
			if( !isprint(c) )
				c = '$';
			if( crterf ) {
				crterf = 0;
				putchar( ']' );
			}
			if( cp2 < canonb + BUFSIZ + 1 ) {
				putc(c, stdout);
				*cp2++ = c;
				*cp2 = '\0';
			}
		}
		flush();
	}
#endif
# ifdef SIGCONT
	sigset(SIGCONT, sigcont);
# endif
	if (c == EOF && ferror(stdin) && hadcont) {
redo:
		hadcont = 0;
		cp = *canonb ? canonb : NOSTR;
		clearerr(stdin);
		return readtty(pr, cp);
	}
	if (equal("", canonb))
		return(NOSTR);
	return(savestr(canonb));
}

# ifdef SIGCONT
/*
 * Receipt continuation.
 */
sigtype ttycont(s)
{
	sigtype signull();

#if defined(SIGTSTP) && !defined(TIOCSTI)
	sigset(SIGTSTP, restty);
#endif
	hadcont++;
	signull(s);
	longjmp(rewrite, 1);
}

/*
 * Null routine to satisfy
 * silly system bug that denies us holding SIGCONT
 */
sigtype sigcont(s)
{
	sigtype signull();

#if defined(SIGTSTP) && !defined(TIOCSTI)
	sigset(SIGTSTP, restty);
#endif
	signull(s);
}

sigtype signull(s)
{
#ifdef SVR3
	if (s == SIGCONT) {
		sigset (s, SIG_DFL);
		kill (getpid(), s);
		sigset (s, sigcont);
	}
#endif
}
# endif

#if defined(SIGTSTP) && !defined(TIOCSTI)
sigtype restty(s)
{
#ifdef USE_SGTTY
	ttybuf.sg_flags = sflgs;
	ttybuf.sg_intrc = c_intr;
	ttybuf.sg_quitc = c_quit;
#else
	ttybuf = svm;
#endif
	ttybuf.sg_erase = c_erase;
	ttybuf.sg_kill  = c_kill;
	if (ttyset) {
		stty(fileno(stdin), &ttybuf);
		ttyset = 0;
	}
#ifdef USE_SGTTY
	ttybuf.sg_flags |= CBREAK;
	ttybuf.sg_flags &= ~ECHO;
	ttybuf.sg_intrc = 0;
	ttybuf.sg_quitc = 0;
#else
	ttybuf.c_cc[VINTR] = 0;
	ttybuf.c_cc[VQUIT] = 0;
	ttybuf.c_lflag &= ~(ICANON|ECHO);
	ttybuf.c_cc[VMIN]  = 1;
	ttybuf.c_cc[VTIME] = 0;
#endif
	sigset (s, SIG_DFL);
	kill (getpid(), s);
}
#endif

int crt_lines, crt_cols;

get_screen_dims()
{
	register char *s;
#ifdef TIOCGWINSZ
	struct winsize  wsz;
#endif

	crt_lines = crt_cols = 0;

	if (   (s = value("LINES")) != NOSTR
	    || (s = value("crt")) != NOSTR
	   )
		crt_lines = atoi(s);
	if ((s = value("COLS")) != NOSTR)
		crt_cols = atoi(s);

	if (crt_lines > 0 && crt_cols > 0)
		return;

#ifdef TIOCGWINSZ
	if ((ioctl(0, TIOCGWINSZ, (caddr_t) &wsz) != -1)) {
		if (crt_cols <= 0 && wsz.ws_col > 0)
			crt_cols = wsz.ws_col;
		if (crt_lines <= 0 && wsz.ws_row > 0)
			crt_lines = wsz.ws_row;
	}
#endif
	if (crt_lines <= 0)
#if defined(MSDOS) || defined(M_XENIX) || defined(ISC)
		crt_lines = 25;
#else
		crt_lines = 24;
#endif
	if (crt_cols <= 0)
		crt_cols = 80;
}
