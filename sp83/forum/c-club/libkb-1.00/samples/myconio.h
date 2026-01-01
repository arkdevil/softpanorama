/* myconio.h -- include file used by 'libkb' test programs
 * Copyright (C) 1995, 1996 Markus F.X.J. Oberhumer
 * For conditions of distribution and use, see copyright notice in kb.h 
 */

/* WARNING: this file should *not* be used by applications. It is
   part of the implementation of the keyboard library and is
   subject to change. Applications should only use kb.h.
 */


/***********************************************************************
// portability wrapper for conio terminal stuff
************************************************************************/

#if defined(__WATCOMC__)

#include <graph.h>

#define _SOLIDCURSOR		0x0007
#define _NORMALCURSOR		0x0607
#define _NOCURSOR			0x2000

#define gotoxy(x,y)			_settextposition(y,x)
#define cputs(x)			_outtext(x)
#define clrscr()			_clearscreen(0)
#define textcolor(x)		_settextcolor(x)
#define _setcursortype(x)	_settextcursor(x)

#endif /* __WATCOMC__ */



#if defined(__EMX__)

#include <sys/video.h>

#define _SOLIDCURSOR		2
#define _NORMALCURSOR		1
#define _NOCURSOR			0

#define cinit()				v_init()
#define gotoxy(x,y)			v_gotoxy((x)-1,(y)-1)
#define cputs(x)			v_puts(x)
#define clrscr()			v_clear()
#define textcolor(x)		v_attrib((x) & 0xf)
#define _setcursortype(x)	((void)(x == _NOCURSOR && (v_hidecursor(),1)))

#endif /* __EMX__ */



#if defined(__KB_LINUX)

#include <curses.h>

#define _SOLIDCURSOR		2
#define _NORMALCURSOR		1
#define _NOCURSOR			0

#if defined(__NCURSES_H)
#  define cinit()			(initscr(), start_color(), 0)
#  define cexit()			(attrset(A_NORMAL), endwin())
#  define textcolor(x)		attrset(x)
#  define _setcursortype(x)	curs_set(x)
#  define cputsa(x,len)		(waddchnstr(stdscr,x,len), refresh())
#else
#  define cinit()			(initscr(), 0)
#  define cexit()			endwin()
#  define textcolor(x)		((void)0)
#  define _setcursortype(x)	((void)0)
#  define init_pair(a,b,c)	((void)0)
#endif
#define gotoxy(x,y)			move((y)-1,(x)-1)
#define cputs(x)			(addstr(x), refresh())
#define clrscr()			(clear(), refresh())

#endif /* __KB_LINUX */



/***********************************************************************
//
************************************************************************/

#if !defined(BLACK)
#if defined(__WATCOMC__) || defined(__EMX__) || defined(__KB_LINUX)

#if defined(__NCURSES_H)

/* dark colors */
#define BLACK             (COLOR_PAIR(COLOR_BLACK))
#define BLUE              (COLOR_PAIR(COLOR_BLUE))
#define GREEN             (COLOR_PAIR(COLOR_GREEN))
#define CYAN              (COLOR_PAIR(COLOR_CYAN))
#define RED               (COLOR_PAIR(COLOR_RED))
#define MAGENTA           (COLOR_PAIR(COLOR_MAGENTA))
#define BROWN             (COLOR_PAIR(COLOR_YELLOW))
#define LIGHTGRAY         (COLOR_PAIR(COLOR_WHITE))
 /* light colors */
#define DARKGRAY          (COLOR_PAIR(COLOR_BLACK) | A_BOLD)
#define LIGHTBLUE         (COLOR_PAIR(COLOR_BLUE) | A_BOLD)
#define LIGHTGREEN        (COLOR_PAIR(COLOR_GREEN) | A_BOLD)
#define LIGHTCYAN         (COLOR_PAIR(COLOR_CYAN) | A_BOLD)
#define LIGHTRED          (COLOR_PAIR(COLOR_RED) | A_BOLD)
#define LIGHTMAGENTA      (COLOR_PAIR(COLOR_MAGENTA) | A_BOLD)
#define YELLOW            (COLOR_PAIR(COLOR_YELLOW) | A_BOLD)
#define WHITE             (COLOR_PAIR(COLOR_WHITE) | A_BOLD)

#else

enum {
    BLACK,          /* dark colors */
    BLUE,
    GREEN,
    CYAN,
    RED,
    MAGENTA,
    BROWN,
    LIGHTGRAY,
    DARKGRAY,       /* light colors */
    LIGHTBLUE,
    LIGHTGREEN,
    LIGHTCYAN,
    LIGHTRED,
    LIGHTMAGENTA,
    YELLOW,
    WHITE
};

#endif

#endif
#endif


#ifndef cputsa
#  define cputsa(x,len)		cputs(x)
#endif
#ifndef cbeep
#  define cbeep()			((void)(putchar('\a'), fflush(stdout)))
#endif
#ifndef cexit
#  define cexit()			((void)0)
#endif

/*
vi:ts=4
*/
