/* kbtst.c -- test program for the libkb keyboard library
 * Copyright (C) 1995, 1996 Markus F.X.J. Oberhumer
 * For conditions of distribution and use, see copyright notice in kb.h 
 */

/* note: this file has become somewhat messy, but I don't
 * want to split it into different programs because it is really a pain to
 * keep various Makefiles for various variants of Make up to date.
 */

#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <signal.h>
#if defined(__KB_LINUX) || defined(__DJGPP__)
#  include <unistd.h>
#endif

#include <kb.h>
#include "intro.h"	
#include "myconio.h"


/*************************************************************************
// signal handler
// (this may not get called if you use the ncurses library)
**************************************************************************/

static void my_signal_handler(int signum)
{
	/* file I/O is somewhat dangerous within a signal handler ... */
	fflush(stderr);
	if (signum == SIGINT)
		fprintf(stderr,"SIGINT received.\n");
#if defined(SIGBREAK)
	else if (signum == SIGBREAK)
		fprintf(stderr,"SIGBREAK received.\n");
#endif
	else 
		fprintf(stderr,"SIGNAL %d received.\n",signum);
	fflush(stderr);

	exit(128 + (signum & 0x7f));
}


/***********************************************************************
// 
************************************************************************/

static int mode;

static int KBHIT(void)
{
	kb_update();

	if (mode <= 2)
		return kb_kbhit();
	else if (mode == 3)
		return kb_os_kbhit();
	else if (mode == 4)
		return kb_bios_kbhit();
#if defined(__KB_MSDOS)
	else if (mode == 5)
		return kbhit();
#endif
	else
		return 0;
}


static unsigned long GETKEY(void)
{
	kb_update();

	if (mode == 1)
		return kb_inkey();
	else if (mode == 2)
		return kb_getkey();
	else if (mode == 3)
		return kb_os_getkey();
	else if (mode == 4)
		return kb_bios_getkey();
#if defined(__KB_MSDOS)
	else if (mode == 5)
		return getch();
#endif
	else
		return 0;
}


static int q_pressed(void)
{
	kb_update();

	if (kb_key(KB_SCAN_Q))
	{
		if ((kb_key(KB_SCAN_LCONTROL) || kb_key(KB_SCAN_RCONTROL)) &&
			(kb_key(KB_SCAN_LSHIFT) || kb_key(KB_SCAN_RSHIFT)))
			return 1;
		if (kb_key(KB_SCAN_ALTGR))
			return 1;
	}
	return 0;
}


/***********************************************************************
// cheating
************************************************************************/

static int cheat(unsigned key, const char *cheat_str, int *cheat_pos)
{
	if (key == 0)
		return 0;
	if (key == (unsigned char) cheat_str[*cheat_pos])
	{
		(*cheat_pos)++;
		if (cheat_str[*cheat_pos] == 0)
		{
			*cheat_pos = 0;
			return 1;			/* cheat activated */
		}
	}
	else
		*cheat_pos = 0;
	return 0;
}


/***********************************************************************
// conio interface
************************************************************************/

#define cputtext(x,y,text)		((void)(gotoxy(x,y), cputs(text)))
#define cputtexta(x,y,text,n)	((void)(gotoxy(x,y), cputsa(text,n)))

static int conio_interface(unsigned long kflags)
{
	int i, x, y;
	unsigned k;
	char m[255];
	int do_beep = 0;
	unsigned color = LIGHTGRAY;

#if defined(__TURBOC__) || defined(__GO32__)
	struct text_info ti;
	gettextinfo(&ti);
	if (ti.screenwidth < 80 || ti.screenheight < 25)
		return 0;
#endif

	if (kb_install(kflags) != 0)
		return -1;

#if defined(cinit)
	if (cinit() != 0)
		return -2;
#endif
	
#if defined(__NCURSES_H)
	/* init colors */
	for (i = 0; i < COLORS && i < COLOR_PAIRS; i++)
		init_pair(i, i, COLOR_BLACK);
#endif
	_setcursortype(_NOCURSOR);
	clrscr();

/* write intro */
	x = 1; y = 1;
	textcolor(YELLOW);
	cputtext(x,y++,_kb_intro_text(m));
	cputtext(x,y++,"libkb -- a free, advanced and portable low-level keyboard library");

	textcolor(color);
	y++;
	cputtext(x,y++,"Please send your bug reports, fixes, enhancements or suggestions to:\n");
	cputtext(x,y++,"Markus F.X.J. Oberhumer <markus.oberhumer@jk.uni-linz.ac.at>\n");
	y++;
	cputtext(x,y++,KB_INSTALLED_MSG);
	cputtext(x,y++,"Hit any key to test, Ctrl-Shift-Q or AltGr-Q to quit");

/* write constant text */
	y += 2;
	x = 12;
	cputtext(x,y++,"          1         2         3         ");
	cputtext(x,y++,"0123456789012345678901234567890123456789");
	y += 2;
	cputtext(x,y++,"4         5         6         7         ");
	cputtext(x,y++,"0123456789012345678901234567890123456789");
	cputtext(x+46,y-1,"last key pressed");
	y += 2;
	cputtext(x,y++,"                    1         1");
	cputtext(x,y++,"8         9         0         1         ");
	cputtext(x,y++,"0123456789012345678901234567890123456789");
	cputtext(x+46,y-1,"shift flags");


/* let's begin */
	while (!q_pressed())
	{
#if defined(__NCURSES_H)
		chtype mm[80+1];
		const chtype kk = ACS_DIAMOND;
#elif defined(__KB_LINUX)
		char *mm = m;
		const char kk = 'o';
#else
		char *mm = m;
		const char kk = 0x1e;
#endif
		unsigned code;

	/* clear information bits if Esc pressed */
		if (kb_key(KB_SCAN_ESC))
			kb_shift_off(KB_SHIFT_OVERFLOW | KB_SHIFT_UNKNOWN);

	/* print keys */
		textcolor(GREEN);
		mm[40] = 0;
		for (i = 0; i < 40; i++)
			mm[i] = kb_key(i) ? kk : ' ';
		cputtexta(x,y-9,mm,40);
		for ( ; i < 80; i++)
			mm[i-40] = kb_key(i) ? kk : ' ';
		cputtexta(x,y-5,mm,40);
		for ( ; i < 120; i++)
			mm[i-80] = kb_key(i) ? kk : ' ';
		cputtexta(x,y,mm,40);

	/* print shift flags */
		textcolor(LIGHTRED);
		k = kb_shift() & KB_SHIFT_ANY;
		for (i = 0; i < 12; i++, k >>= 1)
			mm[i] = k & 1 ? kk : ' ';
		mm[i] = 0;
		cputtexta(x+46,y,mm,i);
		textcolor(LIGHTMAGENTA);
		k = kb_shift();
		i = 0;
		mm[i++] = ' '; mm[i++] = ' ';
		mm[i++] = k & KB_SHIFT_OVERFLOW ? 'o' : ' ';
		mm[i++] = k & KB_SHIFT_UNKNOWN ?  'u' : ' ';
		mm[i] = 0;
		cputsa(mm,i);

	/* print name of last key pressed */
		textcolor(CYAN);
		k = kb_last_key();
		strcpy(m,kb_keyname(k));
		if (m[0] == 0) {
			textcolor(RED);
			if (do_beep)
				cbeep(), do_beep = 0;	/* beep if no name found */
		} else
			do_beep = 1;
		for (i = strlen(m); i < 20; i++)
			m[i] = ' ';
		m[20] = 0;
		code = kb_keycode(k);
		if (code >= 32 && code < 127)
			i = 16, m[i++] = '\'', m[i++] = code, m[i++] ='\'';
		cputtext(x+46,y-5,m);
		sprintf(m,"%3d  0x%04x  0x%04x", k & 0x7f, k, code);
		cputtext(x+46,y-4,m);

	/* print scan codes of all pressed keys */
		textcolor(color);
		sprintf(m,"%2d keys now pressed: ", kb_keys_pressed());
		for (i = 0; i < 128; i++)
			if (kb_key(i))
				sprintf(m+strlen(m), "%d ", i);
		for (i = strlen(m); i < 80; i++)
			m[i] = ' ';
		m[80] = 0;
		cputtext(1,y+2,m);

	/* cheat section */
		if (kb_kbhit())
		{
			static char cheat_str[] = "cheat";
			static char mfx_str[] = "mfx";
			static int cheat_pos = 0, mfx_pos = 0;

			k = kb_keypress();			/* get key (scancode) */
			k &= 0x7f;					/* ignore shift state */
			k = kb_keycode(k);			/* convert to ASCII code */
			if (k & 0xff00)				/* not a 'simple' key */
				k = 0;

			if (cheat(k,cheat_str,&cheat_pos))
				color = (color != LIGHTGRAY) ? LIGHTGRAY : LIGHTBLUE;
			if (cheat(k,mfx_str,&mfx_pos))
				color = (color != LIGHTGRAY) ? LIGHTGRAY : LIGHTGREEN;
		}
	}

/* restore terminal */
	gotoxy(1,25);
	_setcursortype(_NORMALCURSOR);
#if defined(__TURBOC__) || defined(__GO32__)
	textattr(ti.attribute);
#else
	textcolor(LIGHTGRAY);
#endif
	cexit();

	return 0;
}


/***********************************************************************
// show a keypress
************************************************************************/

static void show_keys(unsigned long c, unsigned long c2)
{
	int a = (int)c & 0xff;

	printf("num=%3d  st=%04x  ", kb_keys_pressed(), kb_shift() & KB_SHIFT_ANY);

	if (a >= 32 && a < 127)
		printf("'%c'", (char) a);
	else
		printf("   ");

	printf("  key=%08lx", c);

	/* Extended character ? (from getch()) */
	if (c2 != 0)
		printf(" %08lx", c2);

	printf("  ");
	_kb_port_debug();
	printf("\n");
	fflush(stdout);
}


/***********************************************************************
// run a simple benchmark
************************************************************************/

static void benchmarck(void)
{
	clock_t t1, t2;
	long i, n, k;

	printf("Running speed test (this can take a while)...\n");
	i = n = 100000L;
	k = 0;
	t1 = clock();
	do {
		if (KBHIT())
		{
			GETKEY();
			k++;
		}
	} while (--i > 0);
	t2 = clock();

	printf("%ld keys were hit (%ld, %ld millisecs)\n",
		k, n, ((t2-t1)*1000L)/(long)(CLOCKS_PER_SEC));
}


/***********************************************************************
// argument handling is a little bit messy ...
************************************************************************/

int main(int argc, char *argv[])
{
	unsigned long c1, c2;
	int i;
	char s[80+1];

	signal(SIGINT, my_signal_handler);
#if defined(SIGBREAK)
	signal(SIGBREAK, my_signal_handler);
#endif

	fputs("\n",stdout);
	fputs(_kb_intro_text(s),stdout);
	fputs("\n\n",stdout);
	printf("Please send your bug reports, fixes, enhancements or suggestions to:\n");
	printf("Markus F.X.J. Oberhumer <markus.oberhumer@jk.uni-linz.ac.at>\n");
	printf("\n");

	if (!isatty(0) || !isatty(1))	
	{
		fprintf(stderr,"stdin and stdout must be connected to a terminal\n");
		exit(1);
	}

	mode = 0;
	if (argc > 1)
		mode = atoi(argv[1]);
	if (mode < 0)				/* allow '-1' */
		mode = -mode;
	if (mode < 1 || mode > 6)
		mode = 6;				/* default */

	if (mode == 6)
	{
		/* use default flags - no dangerous stuff here */
		unsigned long f = 0;
		int r;

		/* this is for testing - take care */
		if (argc >= 3)
			f |= KB_FLAG_SIGINT |
			     KB_FLAG_EMERGENCY_EXIT |
			     KB_FLAG_LINUX_NO_VT |
			     KB_FLAG_DJGPP_NO_RM;
		if (argc >= 4)
		{
			f |= KB_FLAG_EMERGENCY_SIGALRM;
			f &= ~KB_FLAG_LINUX_NO_VT;
		}

		r = conio_interface(f);
		if (r == 0)
			exit(0);
		mode = (r == -1) ? 3 : 1;
	}

	if (mode == 1)
	{
		if (kb_install(0) != 0)
			mode = 3;
	}
	else if (mode == 2)
	{
		if (kb_install(KB_FLAG_REPEAT_OFF) != 0)
			mode = 3;
	}

	if (mode <= 2)
	{
		printf(KB_INSTALLED_MSG);
		printf("\nHit any key to test, Ctrl-Shift-Q or AltGr-Q to quit\n\n");
	}
	else if (mode == 3)
	{
		printf("Using kb_os_getkey().\n");
		printf("Hit any key to test, 'Q' to quit\n\n");
	}
	else if (mode == 4)
	{
		printf("Using kb_bios_getkey().\n");
		printf("Hit any key to test, 'Q' to quit\n\n");
	}
	else if (mode == 5)
	{
		printf("Using getch().\n");
		printf("Hit any key to test, 'Q' to quit\n\n");
	}


	if (argc > 2)
	{
		benchmarck();
		exit(0);
	}


	while (!q_pressed())
	{
		while (!KBHIT())
		{
			if (kb_shift() & KB_SHIFT_CONTROL_BREAK)
			{
				printf("Control-Break pressed\n");
				show_keys(0,0);
				kb_shift_off(KB_SHIFT_CONTROL_BREAK);
			}
			if (kb_shift() & KB_SHIFT_PAUSE)
			{
				if (KB_ALL_MASK(kb_shift(), KB_SHIFT_ANY_CONTROL))
					printf("LControl-RControl-Break pressed\n");
				else
					printf("Pause pressed\n");
				show_keys(0,0);
				kb_shift_off(KB_SHIFT_PAUSE);
			}
		}

		c1 = GETKEY();
		c2 = c1 ? 0 : GETKEY();
		if (c1 || c2)
			show_keys(c1,c2);

		if (!kb_mode() && (c1 == 'q' || c1 == 'Q'))
			break;
	}

	if (kb_mode())
	{
		printf("\n");
		printf("%d keys now pressed: ", kb_keys_pressed());
		for (i = 0; i < 128; i++)
			if (kb_key(i))
				printf("%02x ", i);
		printf("\n");
	}
	if (_kb_iswin() > 0)
		printf("\ninfo: I am running in a Windows DOS box.\n");
	fflush(stdout);

	return 0;
}


/*
vi:ts=4
*/
