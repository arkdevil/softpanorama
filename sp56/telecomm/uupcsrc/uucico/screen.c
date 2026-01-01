#include <conio.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>
#include <sys/timeb.h>
#include "lib.h"
#include "hlib.h"
#include "hostable.h"
#include "screen.h"

#define SIZE_FMT "%8ld"
#define CPS_FMT "%4s"

static MAXX = 80;
#define MAXINF (MAXX - 1)

static MAXY = 25;

struct HostStats remote_stats;
extern char *nodename;
char *brand, *rate, *S_sysspeed;
long ticks, bytes; 		/* from dcpxfer.c */
struct timeb start_time;/* from dcpxfer.c */
extern char rmtname[];

static void Sinitdebugwin(void);
static void Sinittranswin(void);
static void Sinitlinkwin(void);
static void ClearLastErr(void);
static int dist(int, int);

int screen = 1;
static nextcall = 0;
static time_t errtime = 0;

static int modemline = 4;
static int linkline = 5;
static int errline = 17;
static int debline = 20;
static int ftrline = 9;
static int miscline = 17;
static int packline = 19;

static int file1col = 20;
static int perrcol = 1;
static int terrcol = 32;
static int bytescol = 60;
static int cpscol = 67;
static int countcol = 73;
static int arrowcol = 32;
static int nodecol = 14;
static int remotecol = 34;
static int timecol = 50;

static short filcolor = WHITE;
static short hdrcolor = GREEN;
static short attcolor = LIGHTCYAN;
static short bitcolor = YELLOW;
static short fgbase = BLUE;

static boolean wasnl[NWINS];
static struct rccoord begs[NWINS];
static struct rccoord ends[NWINS];
static struct rccoord curr[NWINS];
static short wcol[NWINS] = {
	BROWN,
	LIGHTCYAN,
	LIGHTCYAN
};
static boolean inited[NWINS];
static void (*initfuncs[NWINS])(void) = {
	Sinitdebugwin,
	Sinittranswin,
	Sinitlinkwin,
};

static boolean colors = FALSE;

static void fgcolor(int);
static void bkcolor(int);

static int tail[2] = {0, 0};
static int head[2] = {0, 0};

static void fgcolor(int col)
{
	if (!colors || !screen)
		return;
	textcolor(col);
}

static void bkcolor(int col)
{
	if (!colors || !screen)
		return;
	textbackground(col);
}

void Sclear (void)
{
	if (!screen)
		return;
	window (1, 1, MAXX, MAXY);
	fgcolor(WHITE);
	bkcolor(BLACK);
	clrscr();
	errtime = 0;
}

void Sbot(char *s)
{
	if (!screen) {
		fputs(s, stderr);
		putc('\n', stderr);
		return;
	}
	fgcolor(LIGHTRED);
	window(1, MAXY, MAXX, MAXY);
	clrscr();
	gotoxy(1, 1);
	cputs(s);
	window(1, 1, MAXX, MAXY);
}

void Sheader(const char *str)
{
	char *s;
	int len;
	extern boolean remote_debug;

	s = strdup(str);
	len = strlen(s);
	while (len > 0 && s[len - 1] == '\n')
		s[--len] = '\0';
	if (!screen) {
		fputs(s, stderr);
		putc('\n', stderr);
		free(s);
		return;
	}
	window (1, 1, MAXX, nextcall == 0 ? MAXY : 1);
	clrscr();
	fgcolor(LIGHTCYAN);
	gotoxy (1, 1);
	if (len > MAXX)
		s[MAXX-1] = '\0';
	cputs(s);
	free(s);
	if (!remote_debug)
		s = "Press Ctrl+C to abort program, ESC to stop waiting.";
	else
		s = "Press d:new debug level & file echo, t:enable/disable port data log";
	Sbot(s);
}

void Sinfo(const char *str)
{
	int len;
	char *s;

	s = strdup(str);
	len = strlen(s);
	while (len > 0 && s[len - 1] == '\n')
		s[--len] = '\0';
	if (!screen) {
		fputs(s, stderr);
		putc('\n', stderr);
	}
	else {
		window (1, 2, MAXX, 2);
		gotoxy (1,1);
		fgcolor(WHITE);
		clrscr();
		if (len > MAXX)
			s[MAXX-1] = '\0';
		cputs (s);
	}
	free(s);
	if (screen)
		ClearLastErr();
}

static struct text_info vc;

void Ssaveplace (int next)
{
	boolean first = TRUE;

	if (!screen)
		return;
	nextcall = next;
Again:
	gettextinfo( &vc );
	MAXX = vc.screenwidth;
	MAXY = vc.screenheight;
	if (MAXX < 80 || MAXY < 25) {
		if (!first) {
			screen = 0;
			printmsg(0,"Ssaveplace: can't switch to CO80 mode");
			return;
		}
		first = FALSE;
		textmode(C80);
		goto Again;
	}
	colors =	vc.currmode != BW40
			 && vc.currmode != BW80
			 && vc.currmode != MONO
		   ;

	_setcursortype(_NOCURSOR);
	_wscroll = 0;
	directvideo = 0; /* made it DescView compatible... */

	if (debuglevel == 0) {
		errline = miscline = MAXY - 3;
		packline = errline + 2;
	}
	if (next) {
		errline++;
		miscline++;
	}
}

void Srestoreplace (void)
{
	if (!screen) return;

	_setcursortype(_NORMALCURSOR);
	fgcolor(WHITE);
	bkcolor(BLACK);
	textattr(vc.normattr);
	window (vc.winleft, vc.winbottom - 1, vc.winright, vc.winbottom);
	clrscr();
	window (vc.winleft, vc.wintop, vc.winright, vc.winbottom);
	gotoxy (1, vc.winbottom - 2);
}

static void Sinittranswin(void)
{
	if (!screen)
		return;
	begs[WTRANS].row = ftrline + 1; begs[WTRANS].col = 1;
	ends[WTRANS].row = errline - 2 - nextcall; ends[WTRANS].col = MAXX;
	fgcolor (BLACK);
	bkcolor(hdrcolor);
	window (begs[WTRANS].col, begs[WTRANS].row - 1,
			ends[WTRANS].col, begs[WTRANS].row - 1);
	clrscr();
	gotoxy (1,1);
	cputs ("TRANSFER");
	gotoxy (arrowcol, 1);
	cputs ("FILE");
	gotoxy (cpscol, 1);
	cputs (" CPS");
	gotoxy (countcol, 1);
	cputs ("   BYTES");
	bkcolor(BLACK);
}

static void Sinitdebugwin (void)
{
	if (!screen)
		return;
	begs[WDEBUG].row = debline + 1; begs[WDEBUG].col = 1;
	ends[WDEBUG].row = MAXY - 1; ends[WDEBUG].col = MAXX;
	fgcolor(BLACK);
	bkcolor(hdrcolor);
	window (begs[WDEBUG].col, begs[WDEBUG].row - 1,
			ends[WDEBUG].col, begs[WDEBUG].row - 1);
	clrscr();
	gotoxy (1,1);
	cputs ("DEBUG WINDOW");
	if (!colors)
		cputs (" ───────────────────────────────────────────────────────────────");
	bkcolor(BLACK);
}

static void Sinitlinkwin(void)
{
	if (!screen)
		return;
	begs[WLINK].row = linkline + 1; begs[WLINK].col = 1;
	ends[WLINK].row = linkline + 2; ends[WLINK].col = MAXX;
	fgcolor(BLACK);
	bkcolor(hdrcolor);
	window (begs[WLINK].col, begs[WLINK].row - 1,
			ends[WLINK].col, begs[WLINK].row - 1);
	clrscr();
	gotoxy (1,1);
	cputs ("LINK");
	gotoxy (nodecol, 1);
	cputs ("NODE");
	gotoxy (remotecol, 1);
	cputs ("REMOTE");
	gotoxy (timecol, 1);
	cputs ("TIME");
	bkcolor(BLACK);
}

void Sundo(void) {

	if (!screen) return;

	window (1, modemline, MAXX, modemline);
	clrscr();
	window (1, errline - 1 - nextcall, timecol - 1, errline - 1 - nextcall);
	clrscr();
	window (1, packline - 1, MAXX, packline);
	clrscr();
	tail[0] = tail[1] = head[0] = head[1] = 0;

	ClearLastErr();
}

void Slink(Slmesg master, const char *rmtname, const char *stime)
{
	char *s;
	char buf[50];
	static char link_count = 0;

	switch (master) {
	case SL_CONNECTED:
		if (!screen)
			(void) fprintf(stderr, "%d: (%s) %s connected to host %s at %s\n",
						   link_count, S_sysspeed, nodename, rmtname, stime);
		else {
			s = nodename;
			sprintf(buf, "\r\f%d %s", link_count, S_sysspeed);
			Swputs(WLINK, buf);
		}
		break;
	case SL_CALLEDBY:
		link_count++;
		if (!screen)
			(void) fprintf(stderr, "%d: %s called by %s at %s\n",
						   link_count, nodename, rmtname, stime);
		else {
			s = nodename;
			sprintf(buf, "\n\f%d called", link_count);
			Swputs(WLINK, buf);
		}
		break;
	case SL_CALLING:
		link_count++;
		if (!screen)
			(void) fprintf(stderr, "%d: calling host %s via %s at %s\n",
						   link_count, rmtname, brand, stime);
		else {
			s = brand;
			sprintf(buf, "\n\f%d call via", link_count);
			Swputs(WLINK, buf);
		}
		break;
	}
	if (screen) {
		fgcolor(WHITE);
		gotoxy (nodecol, curr[WLINK].row);
		cputs (s);
		gotoxy (remotecol, curr[WLINK].row);
		cputs (rmtname);
		fgcolor(wcol[WLINK]);
		gotoxy (timecol, curr[WLINK].row);
		cputs (stime);
		curr[WLINK].row = wherey();
		curr[WLINK].col = wherex();
		ClearLastErr();
	}
}

void Smodem(Smdmesg answer, int mode)
{
	char buf[10];

	if (screen) {
		window (1, modemline, MAXX, modemline);
		clrscr();
		fgcolor(BLACK);
		bkcolor(hdrcolor);
		gotoxy (1,1);
		cputs ("MODEM:");
		bkcolor(BLACK);
		fgcolor(WHITE);
		gotoxy (nodecol, 1);
	}
	else
		fprintf(stderr, "Modem:\t");
	switch (answer) {
		case SM_CONNECT:
			if (!screen)
				(void) fprintf(stderr, "connection established at %s baud\n", rate);
			else {
				fgcolor(attcolor);
				cputs ("CONNECT ");
				fgcolor(bitcolor);
				cputs(rate);
				fgcolor(WHITE);
				cputs (" baud.");
			}
			break;
		case SM_BUSY:
			if (!screen)
				(void) fprintf(stderr, "Attempt %d. Line busy, redialing\n", mode);
			else {
				cputs ("Attempt ");
				cputs(itoa(mode, buf, 10));
				cputs (". Line ");
				fgcolor(attcolor);
				cputs ("BUSY");
				fgcolor(WHITE);
				cputs (", redialing.");
			}
			break;
		case SM_NOREPLY:
			if (!screen)
				(void) fprintf(stderr, "Attempt %d. No reply, aborting\n", mode);
			else {
				cputs ("Attempt ");
				cputs(itoa(mode, buf, 10));
				cputs (". ");
				fgcolor(attcolor);
				cputs ("NO REPLY");
				fgcolor(WHITE);
				cputs (", aborting.");
			}
			break;
		case SM_NOCARRY:
			if (!screen)
				(void) fprintf(stderr, "Attempt %d. No carrier, redialing\n", mode);
			else {
				cputs ("Attempt ");
				cputs(itoa(mode, buf, 10));
				cputs (". ");
				fgcolor(attcolor);
				cputs ("NO CARRIER");
				fgcolor(WHITE);
				cputs (", redialing.");
			}
			break;
		case SM_NOTONE:
			if (!screen)
				(void) fprintf(stderr,
						   "Attempt %d. No dialtone. Check phone cable.\n",
						mode);
			else {
				cputs ("Attempt ");
				cputs(itoa(mode, buf, 10));
				cputs (". ");
				fgcolor(attcolor);
				cputs ("NO DIALTONE");
				fgcolor(WHITE);
				cputs (". Check phone cable.");
			}
			break;
		case SM_NOPOWER:
			if (!screen)
				fprintf(stderr, "No reply from modem. Check power and/or cable.\n");
			else {
				fgcolor(attcolor);
				cputs ("NO REPLY");
				fgcolor(WHITE);
				cputs (". Check power and/or cable.");
			}
			break;
		case SM_INIT:
			if (!screen)
				fprintf(stderr, "%s baud initialize: %d\n", rate, mode);
			else {
				fgcolor(bitcolor);
				cputs(rate);
				fgcolor(attcolor);
				cputs (" baud initialize: ");
				fgcolor(bitcolor);
				cputs(itoa(mode, buf, 10));
			}
			break;
		case SM_NOBAUD:
			if (!screen)
				(void) fprintf(stderr, "no reply at %s baud. \n", rate);
			else {
				fgcolor(attcolor);
				cputs ("NO REPLY");
				fgcolor(WHITE);
				cputs (" at ");
				fgcolor(bitcolor);
				cputs (rate);
				fgcolor(WHITE);
				cputs (" baud.");
			}
			break;
		case SM_DIALING:
			if (!screen)
				(void)fprintf(stderr,"Dialing %s, wait for %d sec.\n",S_sysspeed,mode);
			else {
				cputs ("Dialing ");
				fgcolor(bitcolor);
				cputs (S_sysspeed);
				fgcolor(WHITE);
				cputs (", wait for ");
				fgcolor(bitcolor);
				cputs(itoa(mode, buf, 10));
				fgcolor(WHITE);
				cputs (" sec.");
			}
			break;
		default:
			answer = -1;
	}
	if (screen)
		ClearLastErr();
}

/*VARARGS1*/
void Serror (const char *fmt, ...)
{
		va_list args;
		char msg[BUFSIZ];
		char *s;
		int len;

		va_start(args, fmt);
		vsprintf(msg, fmt, args);
		va_end(args);
		s = msg;
		len = strlen(s);
		if (len > 0 && s[len - 1] == '\n')
			s[--len] = '\0';
		if (!screen) {
			fputs(s, stderr);
			putc('\n', stderr);
			return;
		}
		if (len > MAXX-7)
			s[MAXX-1-7/*ERROR: */] = '\0';
		window (1, errline, MAXX, errline);
		clrscr();
		fgcolor(BLACK);
		bkcolor(hdrcolor);
		gotoxy (1,1);
		cputs ("ERROR:");
		bkcolor(BLACK);
		putch(' ');
		fgcolor(YELLOW);
		bkcolor(RED);
		cputs (s);
		bkcolor(BLACK);
		(void)time(&errtime);
}

/*VARARGS1*/
void Smisc(const char *fmt, ...)
{
		va_list args;
		char msg[BUFSIZ];
		char *s;
		int len;

		va_start(args, fmt);
		vsprintf(msg, fmt, args);
		va_end(args);
		s = msg;
		len = strlen(s);
		if (len > 0 && s[len - 1] == '\n')
			s[--len] = '\0';
		if (!screen) {
			fputs(s, stderr);
			putc('\n', stderr);
			return;
		}
		if (len > MAXX-9)
			s[MAXX-1-9/*MESSAGE: */] = '\0';
		window (1, miscline, MAXX, miscline);
		clrscr();
		gotoxy (1,1);
		fgcolor(BLACK);
		bkcolor(hdrcolor);
		cputs ("MESSAGE:");
		fgcolor(LIGHTCYAN);
		bkcolor(BLACK);
		putch(' ');
		cputs (s);
		(void)time(&errtime);
}

void Swputs(int num, const char *msg)
{
	char *s;

	if (!screen) {
		fputs(msg, stderr);
		return;
	}
	if (!inited[num])
		(*initfuncs[num])();
	window (begs[num].col, begs[num].row,
				 ends[num].col, ends[num].row);
	if (num == WDEBUG)
		_wscroll = 1;
	fgcolor(wcol[num]);
	if (!inited[num]) {
		curr[num].row = 1;
		curr[num].col = 1;
		clrscr();
		inited[num] = TRUE;
		wasnl[num] = FALSE;
	}
	gotoxy (curr[num].col, curr[num].row);
	for (s = msg; *s; s++) {
		if (wasnl[num]) {
		wasnl[num] = FALSE;
		curr[num].col = wherex();
		curr[num].row = wherey();
		if (curr[num].row != 1 ||
			curr[num].col != 1
		   )
			   cputs("\r\n");
		}
		switch(*s) {
		case '\n':
			wasnl[num] = TRUE;
			break;
		case '\r':
			curr[num].col = wherex();
			curr[num].row = wherey();
			gotoxy (1, curr[num].row);
			break;
		case '\t':
			curr[num].col = wherex();
			curr[num].row = wherey();
			gotoxy (
					 ((curr[num].col - 1) & ~07) + 8,
					 curr[num].row
			);
			putch(' ');
			break;
		case '\f':
			window (
					begs[num].col,
					begs[num].row + curr[num].row - 1,
					ends[num].col,
					ends[num].row
			);
			clrscr();
			window (begs[num].col, begs[num].row,
					ends[num].col, ends[num].row);
			break;
		default:
			putch(*s);
			break;
		}
	}
	curr[num].col = wherex();
	curr[num].row = wherey();
	if (num == WDEBUG)
		_wscroll = 0;
}

static short transstate = -1;

void Saddbytes(long count, Sfmesg state)
{
	char buf[20];
	struct timeb now;
	long cps;

	if (!screen || state != transstate)
		return;
	ftime(&now);
	ticks = (now.time - start_time.time) * 1000 +
		   ((long) now.millitm - (long) start_time.millitm);
	if (ticks <= 0)
		ticks = 1;

	Swputs(WTRANS, "");
	fgcolor(bitcolor);
	cps = bytes * 1000 / ticks;
	cprintf(CPS_FMT, cps < 9999 ? ltoa(cps, buf, 10) : "****");

	gotoxy(countcol, curr[WTRANS].row);
	cprintf(SIZE_FMT, count);

	ClearLastErr();
}

void Sftrans(Sfmesg mode, const char *fromfile, const char *hostfile)
{
	switch (mode) {
		case SF_SEND:
			if (!screen) {
				(void) fprintf(stderr, "Sending %s to %s\n", fromfile, hostfile);
				return;
			}
			transstate = SF_SEND;
			Swputs (WTRANS, "\nSEND:");
			break;

		case SF_RECV:
			if (!screen) {
				(void) fprintf(stderr, "Receiving %s from %s\n", fromfile, hostfile);
				return;
			}
			transstate = SF_RECV;
			Swputs(WTRANS, "\nRECEIVE:");
			break;

		case SF_SDONE:
			if (!screen) {
				(void) fprintf(stderr, "Sending %s to %s completed.\n", fromfile, hostfile);
				return;
			}
			Swputs(WTRANS, "\rSENDING DONE:");
			break;

		case SF_RDONE:
			if (!screen) {
				(void) fprintf(stderr, "Receiving %s from %s completed.\n", fromfile, hostfile);
				return;
			}
			Swputs(WTRANS, "\rRECEIVING DONE:");
			break;

		case SF_DELIVER:
			if (!screen) {
				(void) fprintf(stderr, "Deliver message from %s to%s\n", fromfile, hostfile);
				return;
			}
			Swputs(WTRANS, "\nMail from ");
			fgcolor(filcolor);
			cputs (fromfile);
			fgcolor(wcol[WTRANS]);
			cputs (" to");
			fgcolor(filcolor);
			cputs (hostfile);
			curr[WTRANS].col = wherex();
			curr[WTRANS].row = wherey();
			ClearLastErr();
			return;
	}
	if (mode == SF_RDONE || mode == SF_SDONE) {
		char buf[20];
		time_t connected;
		unsigned long cps, bytes;

		transstate = 0;
		connected = time(NULL) - remote_stats.lconnect;
		bytes = remote_stats.bsent + remote_stats.breceived;
		if ( connected <= 0 )
		   connected = 1;
		cps = bytes / connected;
		window (bytescol, errline - 1, MAXX, errline - 1);
		fgcolor(wcol[WTRANS]);
		clrscr();
		gotoxy (1, 1);
		cputs ("Total:");
		fgcolor(bitcolor);
		gotoxy (cpscol - bytescol + 1, 1);
		cprintf(CPS_FMT, cps < 9999 ? ltoa(cps, buf, 10) : "****");
		gotoxy (countcol - bytescol + 1, 1);
		cprintf(SIZE_FMT, bytes);

		ClearLastErr();
		return;
	}
	gotoxy (file1col, curr[WTRANS].row);
	fgcolor(filcolor);
	if (mode == SF_SEND && (*hostfile == 'X' || *hostfile == 'D')) {
		FILE *f;

		if ((f = fopen(fromfile, "rb")) != nil(FILE)) {
			static char buf[256], sbuf[256];
			char *s = nil(char);
			boolean first;

			first = TRUE;
			while(fgets(buf, sizeof(buf), f) != nil(char)) {
				if (first) {
					first = FALSE;
					if (   *hostfile == 'D' && strncmp(buf, "From ", 5) != 0
						|| *hostfile == 'X' && strncmp(buf, "U ", 2) != 0)
						break;
					if (*hostfile == 'D') {
						strcpy(sbuf, buf);
						s = sbuf;
					}
				}
				else if (   *hostfile == 'X' && strncmp(buf, "C ", 2) == 0
					 || *hostfile == 'D' && strncmp(buf, "From: ", 6) == 0)
				{
					int olen, slen;
					char *p;

					s = buf;
					if (*hostfile == 'X')
						s += 2;
			Found:
					fclose(f);
					slen = strlen(s);
					if (slen > 0 && s[slen - 1] == '\n')
						s[--slen] = '\0';
					olen = cpscol - file1col - 1;
					s[olen] = '\0';
					if (slen > olen)
						s[olen - 1] = s[olen - 2] = s[olen - 3] = '.';
					for (p = s; *p; p++)
						if (*p < ' ' || *p >= 0177)
						*p = '.';
					cputs (s);
					goto Skip;
				}
				else if (*buf == '\n')
					break;
			}
			if (*hostfile == 'D' && s != nil(char))
				goto Found;
			fclose(f);
		}
	}
	gotoxy (arrowcol, curr[WTRANS].row);
	fgcolor(filcolor);
	cputs (hostfile);

Skip:
	gotoxy(cpscol, curr[WTRANS].row);
	curr[WTRANS].col = wherex();
	curr[WTRANS].row = wherey();

	gotoxy(countcol, curr[WTRANS].row);
	fgcolor(bitcolor);
	cprintf(SIZE_FMT, 0L);

	ClearLastErr();
}


void Spakerr(int nerr)
{
	char buf[20];

	if (!screen)
		return;
	window (perrcol, errline - 1, terrcol - 1, errline - 1);
	fgcolor(BLACK);
	clrscr();
	if (nerr == 0)
		return;
	gotoxy (1, 1);
	fgcolor(RED);
	cputs ("Errors per packet: ");
	fgcolor (bitcolor);
	cputs(itoa(nerr, buf, 10));

	ClearLastErr();
}

void Stoterr(int nerrt)
{
	char buf[20];

	if (!screen)
		return;
	window (terrcol, errline - 1, timecol - 1, errline - 1);
	fgcolor(BLACK);
	clrscr();
	if (nerrt == 0)
		return;
	gotoxy (1, 1);
	fgcolor(RED);
	cputs ("Total errors: ");
	fgcolor (bitcolor);
	cputs(itoa(nerrt, buf, 10));

	ClearLastErr();
}

static int dist(int tail, int head)
{
	if (tail < head)
		return head - tail;
	else
		return MAXINF - tail + head;
}

void Spacket(int tp, char c, int fg)
{
	static struct {
		unsigned char chr;
		unsigned char fgc;
	} infs[2][132], *inf;
	register int i, hd, tl;

	if (!screen)
		return;
	inf = infs[tp];
	hd = head[tp];
	tl = tail[tp];
	if (fg >= 0)
		inf[hd].fgc = (fg + fgbase) % NCOLORS;
	else
		inf[hd].fgc = -fg;
	if (islower(c))
		inf[hd].fgc |= BLINK;
	inf[hd].chr = toupper(c);
	hd = (hd + 1) % MAXINF;
	bkcolor(BLACK);
	window (MAXX, packline - !tp, MAXX, packline - !tp);
	clrscr();
	window (1, packline - tp, MAXX, packline - tp);
	fgcolor(bitcolor);
	gotoxy (MAXX, 1);
	putch ('>');
	if (hd > tl) {
	  gotoxy (MAXINF - hd + tl + 1, 1);
	  for (i = tl; i < hd; i++) {
		fgcolor(inf[i].fgc);
		putch(inf[i].chr);
	   }
	}
	else {
	  gotoxy (1, 1);
	  for (i = tl; i < MAXINF; i++) {
		fgcolor(inf[i].fgc);
		putch(inf[i].chr);
	  }
	  for (i = 0; i < hd; i++) {
		fgcolor(inf[i].fgc);
		putch(inf[i].chr);
	  }
	}
	if (dist(tl, hd) >= MAXINF)
		tl = (tl + 1) % MAXINF;
	head[tp] = hd;
	tail[tp] = tl;
}

static
void ClearLastErr(void)
{
	if (!screen)
		return;
	if (errtime && time((time_t *)NULL) - errtime > 30) {
		errtime = 0;
		window (1, errline, MAXX, errline);
		clrscr();
	}
}
