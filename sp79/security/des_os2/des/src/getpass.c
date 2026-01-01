#include <stdio.h>
#include <signal.h>
#include <sgtty.h>

/*#define	TTY	"/dev/tty"*/   /* Change to "con" for OS/2 or MS-DOS */
#define TTY "con"

/* Issue prompt and read reply with echo turned off */
char *
getpass(prompt)
char *prompt;
{
#ifndef IBMPC
	struct sgttyb ttyb,ttysav;
#endif
	register char *cp;
	int c;
	FILE *tty;
	static char pbuf[128];
	int (*sig)();

	if ((tty = fdopen(open(TTY, 2), "r")) == NULL)
		tty = stdin;
	else
		setbuf(tty, (char *)NULL);
	sig = signal(SIGINT, SIG_IGN);
#ifndef IBMPC
	ioctl(fileno(tty), TIOCGETP, &ttyb);
	ioctl(fileno(tty), TIOCGETP, &ttysav);
	ttyb.sg_flags |= RAW;
	ttyb.sg_flags &= ~ECHO;
	ioctl(fileno(tty), TIOCSETP, &ttyb);
#endif
	fprintf(stderr, "%s", prompt);
	fflush(stderr);
	cp = pbuf;
	for (;;) {
		c = getc(tty);
		if(c == '\r' || c == '\n' || c == EOF)
			break;
		if (cp < &pbuf[127])
			*cp++ = c;
	}
	*cp = '\0';
	fprintf(stderr,"\r\n");
	fflush(stderr);
#ifndef IBMPC
	ioctl(fileno(tty), TIOCSETP, &ttysav);
#endif
	signal(SIGINT, sig);
	if (tty != stdin)
		fclose(tty);
	return(pbuf);
}
