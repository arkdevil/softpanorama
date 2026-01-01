/*
 ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
 █ PROJECT:  Mouse & video_access primitives.                                █
 █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
 █ MODULE:  VIDEOMOU.H                                                       █
 █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
 █ DESCRIPTION:                                                              █
 █   Header file for the mouse & video_access routines.                      █
 █                                                                           █
 █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
 █ MODIFICATION NOTES:                                                       █
 █    Date     Author Comment                                                █
 █ 08-Feb-1993   ap   Initial file.                                          █
 █                                                                           █
 █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
 █                                                                           █
 █ DISCLAIMER:                                                               █
 █                                                                           █
 █ Copyright (C) 1993, by Alex Pestunovich.  You may use this program, or    █
 █ code or tables extracted from it, as desired without restriction.         █
 █ I can not and will not be held responsible for any damage caused from     █
 █ the use of this software.                                                 █
 █                                                                           █
 █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
 █ This source works with Turbo C 2.0 or MSC 6.0 and above.                  █
 █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
*/
#define	FALSE	0
#define	TRUE	(!FALSE)

#ifdef __TURBOC__
  #define FAST	pascal      /* For fast calling of functions -- Turbo C */
#else
  #define FAST  _fastcall   /* For fast calling of functions -- MSC     */
  #define asm   _asm
#endif
#define LOCAL	near    /* Function can't be called outside of module */
#define PRIVATE static  /* Private function */          
#define STATIC	static  /* Private variable */

extern short int scols, srows;   /* Public - rows and cols at the screen */
extern short int point;          /* Public - nbr of points in char heght */
extern int	 mouseinstalled; /* Public - mouse in system */

#ifndef poke
#define MK_FP(seg,ofs)	((void far *) \
			   (((unsigned long)(seg) << 16) | (unsigned)(ofs)))

#define poke(a,b,c)	(*((int  far*)MK_FP((a),(b))) = (int)(c))
#define pokeb(a,b,c)	(*((char far*)MK_FP((a),(b))) = (char)(c))
#define peek(a,b)	(*((int  far*)MK_FP((a),(b))))
#define peekb(a,b)	(*((char far*)MK_FP((a),(b))))
#endif

/* Common function for initialize if you wish to use both video & mouse */
void FAST videomous_init(void);

/* Video functions */

/* Initialize video routines - must be called */
void FAST video_init(void);

/* Write character & attribute to the screen */
void FAST write_char(int y, int x, char symb, int attr);

/* Change attribute on the screen */
void FAST write_attr(int y, int x, int attr);

/* Write string to the screen. String must be initialized */
/*       I.e. it must have zero at the end.               */
void FAST write_string(int y, int x, char *str, int attr);

/* Draw shadow around the window. */
void FAST draw_shadow(int yb, int xb, int ye, int xe);

/* Draw border.Left top, right bottom. */
void FAST draw_border(int yb, int xb, int ye, int xe, int attr, char *bord);

/* Save part of the screen.Left top, right bottom into buffer with pointer */
void FAST save_video(int yb, int xb, int ye, int xe, char *p);

/* Restore part of the screen from buffer */
void FAST restore_video(int yb, int xb, int ye, int xe, char *p);

/* Fill part of the screen with symbol and color in attr */
void FAST fill_window(int yb, int xb, int ye, int xe, char symb, int attr);

/* Draw cursor (set = 1), erase cursor (set = 0) */
void FAST setcursor(int set);

/* Set cursor to position y, x */
void FAST goto_yx(int y, int x);

/* Set background 16 color for EGA/VGA */
void FAST set16on();

/* Set background 8 color & blinking text for EGA/VGA */
void FAST set16off();


/* Mouse functions */

/* Check is mouse in system - must be called */
void FAST mous_check(void);

/* Show mouse at the screen */
void FAST mous_show(void);

/* Erase mouse from the screen */
void FAST mous_hide(void);

/* Set mouse to the position */
void FAST mous_set(int y, int x);

/* Show mouse events - returns pressed button and mouse coords */
int  FAST mous_event(int *y, int *x);

/* Draw mouse text cursor */
void FAST mous_draw(int ms, int mc, int tp);

/* Extended mouse events - twice click, click at the same coord are 0 etc */
int  FAST inmouse(int *y, int *x, int *b);