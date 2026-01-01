#ifdef __TURBOC__
  #pragma inline
#endif
/*
 ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
 █ PROJECT:  Mouse & video_access primitives.                                █
 █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
 █ MODULE:  VIDEOMOU.C                                                       █
 █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
 █ DESCRIPTION:                                                              █
 █   Main file for the mouse & video_access routines.                        █
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
#include "videomou.h"

STATIC char copyr[] = "(c) 1993, Алексей Пестунович"
		      "606007,г.Дзержинск,Нижегородской обл."
		      "ул.Гастелло, д.9 кв. 56"
		      "(83140) 9-35-75(w), 9-55-38(h)";

/* Save information for CGA/EGA/VGA displays */
STATIC short int desqview  = FALSE;
STATIC short int cgaegavga = FALSE; /* Do we have an CGA/EGA/VGA adapter? */
STATIC short int vseg;              /* Segment of video ram. */

int	mouseinstalled = 0;
short int scols, srows, point;

#define COLS   *((char far *) 0x0000044AL)
#define ROWS   *((char far *) 0x00000484L)
#define POINTS *((char far *) 0x00000485L)

/*
┌───────────────────────────────────────────────────────┐
│  08-Feb-1993 - ap                                     │
│                                                       │
│   Primitive for writing char to the screen.           │
│                                                       │
└───────────────────────────────────────────────────────┘
*/
PRIVATE void LOCAL FAST DIRECT_BIOS_write_char
                                    (int y, int x, char symb, int attr)
{
  /* If monitor CGA/EGA/VGA write direct to video_memory */
  if(cgaegavga) {
    pokeb(vseg, 2 * (y * scols + x)    , symb);/* Write char */
    pokeb(vseg, 2 * (y * scols + x) + 1, attr);/* Write attr */
  }
  /* Not CGA/EGA/VGA - access via BIOS */
  else {
    asm mov ah, 2   	/* Set cursor to */
    asm mov dh, y       /* Symbol's row  */
    asm mov dl, x       /* Symbol's col  */
    asm mov bh, 0  	/* Video page    */
    asm int 10h

    asm mov ah, 9       /* Write char & attr */
    asm mov al, symb    /* Symbol            */
    asm mov bx, attr    /* Attribute         */
    asm mov bh, 0	/* Video_Page        */
    asm mov cx, 1       /* Nbr of symbols    */
    asm int 10h
  }
}

/*
┌───────────────────────────────────────────────────────┐
│  08-Feb-1993 - ap                                     │
│                                                       │
│   Primitive for writing attr to the screen.           │
│                                                       │
└───────────────────────────────────────────────────────┘
*/
PRIVATE void LOCAL FAST DIRECT_BIOS_write_attr(int y, int x, int attr)
{
  register char symb;
  /* If monitor CGA/EGA/VGA work via video_memory */
  if(cgaegavga) {
    /* Write attr - write old char & new attribute */
    symb = peek(vseg, 2 * (y * scols + x));    /* Read old character */
    pokeb(vseg, 2 * (y * scols + x)    , symb);/* Write it again     */
    pokeb(vseg, 2 * (y * scols + x) + 1, attr);/* Write new attr     */
  }
  /* Not CGA/EGA/VGA - access via BIOS */
  else {
    asm mov ah, 2   	/* Set cursor to */
    asm mov dh, y       /* Symbol's row  */
    asm mov dl, x       /* Symbol's col  */
    asm mov bh, 0  	/* Video page    */
    asm int 10h

    asm mov ah, 8       /* Read char & attr */
    asm int 10h         /* ah - symbol, al - attribute */

    asm mov ah, 9       /* Write char & attr */
    asm mov bx, attr    /* Set attribute */
    asm mov bh, 0       /* Video Page */
    asm mov cx, 1       /* Nbr of symbols */
    asm int 10h
  }
}

/*
┌───────────────────────────────────────────────────────────┐
│  08-Feb-1993 - from GRFMOUSE dk                           │
│                                                           │
│   This function checks for the DESQVIEW.                  │
│                                                           │
└───────────────────────────────────────────────────────────┘
*/
PRIVATE short int LOCAL isdesqview(void)
{
  /* Check to see if we are running in DESQview.  If so, don't try to
     use the 'true' EGA/VGA cursor (DV doesn't like it at ALL). */

  asm mov ax, 2b01h;
  asm mov cx, 4445h;
  asm mov dx, 5351h;
  asm int 21h;

  asm cmp al, 0ffh;
  asm je  notdv;

  desqview = TRUE;
  return TRUE;

notdv:
  return FALSE;
}

/*
┌───────────────────────────────────────────────────────────┐
│  08-Feb-1993 - from GRFMOUSE dk                           │
│                                                           │
│   This function checks for the presense of EGA/VGA.       │
│                                                           │
└───────────────────────────────────────────────────────────┘
*/
PRIVATE short int LOCAL isegavga(void)
{

  asm mov ax, 1a00h; /* ROM BIOS video function 1ah -- Read Display Code */
  asm int 10h;
  asm cmp ah, 1ah; /* Is this call supported? */
  asm je checkega; /* Not supported */
  asm cmp bl, 7; /* VGA w/monochrome display? */
  asm je isvga; /* Yup. */
  asm cmp bl, 8; /* VGA w/color display? */
  asm jne checkega; /* Nope */
isvga:
  return TRUE; /* EGA/VGA is installed */
checkega:
  asm mov ah, 12h; /* EGA BIOS function */
  asm mov bl, 10h;
  asm int 10h;
  asm cmp bl, 10h; /* Is EGA BIOS present? */
  asm jne isvga; /* There is an EGA in the system. */
  return FALSE; /* Not EGA or VGA in system. */
}

/*
┌────────────────────────────────────────────┐
│  08-Feb-1993 - ap                          │
│                                            │
│   Initialize the video & mouse routines.   │
│   If you wish to use them both.            │
│                                            │
└────────────────────────────────────────────┘
*/
void FAST videomous_init(void)
{
   /* !!!!! Don't change this order !!!!! */
   mous_check();  		   /* Check if driver in system */
   if(mouseinstalled) {
     mous_show();  		   /* Show mouse on the screen  */
     mous_draw(0xffff, 0x7700, 0); /* Invert char's attribute   */
   }
   video_init();                   /* Init video access         */
}

/*
┌────────────────────────────────────┐
│  08-Feb-1993 - ap                  │
│                                    │
│   Initialize the video routines.   │
│                                    │
└────────────────────────────────────┘
*/
void FAST video_init(void)
{
  char v;

  asm mov ax,0F00h;    /* Video function - get video mode */
  asm int 10h;
  asm mov v,al;

  if (v == 7)       vseg = 0xb000u;             /* Black & White */
  else              vseg = 0xb800u;    		/*     Color     */

  if (ROWS == 0) { /* No value, assume 80x25. */
    srows = 25;
    scols = 80;
    point =  8;
  } else {
    srows = ROWS + 1;
    scols = COLS;
    point = POINTS;
  }
  cgaegavga = (isegavga() | (v < 8)) & (!isdesqview());/* monitor CGA/EGA/VGA */
}

/*
┌────────────────────────────────────┐
│  08-Feb-1993 - ap                  │
│                                    │
│   Write char to video-memory.      │
│                                    │
└────────────────────────────────────┘
*/
void FAST write_char(int y, int x, char symb, int attr)
{
  /* Before writing char we must hide mouse and then show it again */
  mous_hide();
  DIRECT_BIOS_write_char(y, x, symb, attr);
  mous_show();
}

/*
┌────────────────────────────────────┐
│  08-Feb-1993 - ap                  │
│                                    │
│   Write attr to video-memory.      │
│                                    │
└────────────────────────────────────┘
*/
void FAST write_attr(int y, int x, int attr)
{
  /* Before doing anything we must hide mouse and then show it again */
  mous_hide();
  DIRECT_BIOS_write_attr(y, x, attr);
  mous_show();
}

/*
┌────────────────────────────────────┐
│  08-Feb-1993 - ap                  │
│                                    │
│   Write string to video-memory.    │
│                                    │
└────────────────────────────────────┘
*/
void FAST write_string(int y, int x, char *str, int attr)
{
  register char i = 0;

  /* Before doing anything we must hide mouse and then show it again */
  mous_hide();

  while(str[i]) {
    DIRECT_BIOS_write_char(y, x + i, str[i], attr);
    i++;
  }

  mous_show();
}

/*
┌────────────────────────────────────┐
│  08-Feb-1993 - ap                  │
│                                    │
│   Draw shadow around the box.      │
│                                    │
└────────────────────────────────────┘
*/
void FAST draw_shadow(int yb, int xb, int ye, int xe)
{
  register char	i ;
  /* Before doing anything we must hide mouse and then show it again */
  mous_hide();

  for(i = xb + 2; i < xe + 3; i++ )  /* Write shadow after last row of box */
    DIRECT_BIOS_write_attr(ye + 1, i, 0x07);

  for(i = yb + 1; i < ye + 2; i++ ) {/* Write shadow after last column */
    DIRECT_BIOS_write_attr(i, xe + 1, 0x07);
    DIRECT_BIOS_write_attr(i, xe + 2, 0x07);
  }

  mous_show();
}

/*
┌────────────────────────────────────┐
│  08-Feb-1993 - ap                  │
│                                    │
│   Draw border around the box.      │
│                                    │
└────────────────────────────────────┘
*/
void FAST draw_border(int yb, int xb, int ye, int xe,
			int attr, char *bord )
{
  register int i;

  /* Before doing anything we must hide mouse and then show it again */
  mous_hide();

  /* Draw vertical lines of border */
  for(i = yb + 1; i < ye; i++) {
    DIRECT_BIOS_write_char(i, xb, *(bord + 7), attr);
    DIRECT_BIOS_write_char(i, xe, *(bord + 3), attr);
  }

  /* Draw horizontal lines of border */
  for(i = xb + 1; i < xe; i++) {
    DIRECT_BIOS_write_char(yb, i, *(bord + 1), attr);
    DIRECT_BIOS_write_char(ye, i, *(bord + 5), attr);
  }

  /* Draw tops chars of border */
  DIRECT_BIOS_write_char(yb, xb, *(bord + 0), attr);
  DIRECT_BIOS_write_char(yb, xe, *(bord + 2), attr);
  DIRECT_BIOS_write_char(ye, xe, *(bord + 4), attr);
  DIRECT_BIOS_write_char(ye, xb, *(bord + 6), attr);

  mous_show();
}

/*
┌────────────────────────────────────┐
│  08-Feb-1993 - ap                  │
│                                    │
│ Save part of the screen into buffer│
│                                    │
└────────────────────────────────────┘
*/
void FAST save_video(int yb, int xb, int ye, int xe, char *p)
{
  register char i, j;

  /* Before doing anything we must hide mouse and then show it again */
  mous_hide();

  /* If CGA/EGA/VGA access via video_memory */
  if(cgaegavga) {
    for(i = yb; i < ye + 1; i++ )
      for(j = xb; j < xe + 1; j++)  {
	*p++ = peekb(vseg, 2 * (i * scols + j));     /* Here we saved char */
	*p++ = peekb(vseg, 2 * (i * scols + j) + 1); /* And here attribute */
      }
  }

  /* Else via BIOS */
  else {
    for(i = yb; i < ye + 1; i++ )
      for(j = xb; j < xe + 1; j++)  {
	asm mov ah, 2   	/* Set cursor to */
	asm mov dh, i
	asm mov dl, j
	asm mov bh, 0  		/* Video page */
	asm int 10h

	asm mov ah, 8       	/* Read char & attr */
	asm int 10h         	/* ah - symbol, al - attribute */
	_CX  = _AX;
	*p++ = _CH;
	*p++ = _CL;
      }
  }

  mous_show();
}

/*
┌───────────────────────────────────────┐
│  08-Feb-1993 - ap                     │
│                                       │
│Restore part of the screen from buffer │
│                                       │
└───────────────────────────────────────┘
*/
void FAST restore_video(int yb, int xb, int ye, int xe, char *p)
{
  register char i, j ;
  register char symb, attr;

  /* Before doing anything we must hide mouse and then show it again */
  mous_hide();

  /* If CGA/EGA/VGA access via video_memory */
  if(cgaegavga) {
    for(i = yb; i < ye + 1; i++ )
      for(j = xb; j < xe + 1; j++)  {
	pokeb(vseg, 2 * (i * scols + j), *p++);     /* Here we rest  char */
	pokeb(vseg, 2 * (i * scols + j) + 1, *p++); /* And here attribute */
      }
  }

  /* Else via BIOS */
  else {
    for(i = yb; i < ye + 1; i++ )
      for(j = xb; j < xe + 1; j++)  {
	 attr = *p++;
	 symb = *p++;
	 asm mov ah, 2   	/* Set cursor to */
	 asm mov dh, i          /* Symbol's row  */
	 asm mov dl, j          /* Symbol's col  */
	 asm mov bh, 0  	/* Video page    */
	 asm int 10h

	 asm mov ah, 9       /* Write char & attr */
	 asm mov al, symb    /* Symbol            */
	 asm mov bl, attr    /* Attribute         */
	 asm mov bh, 0	     /* Video_Page        */
	 asm mov cx, 1       /* Nbr of symbols    */
	 asm int 10h
    }
  }

  mous_show();
}

/*
┌───────────────────────────────────────┐
│  08-Feb-1993 - ap                     │
│                                       │
│   Fill window with charset            │
│                                       │
└───────────────────────────────────────┘
*/
void FAST fill_window(int yb, int xb, int ye, int xe,
			char symb, int attr)
{
  register int i, j;

  /* Before doing anything we must hide mouse and then show it again */
  mous_hide();

  for(i = yb; i < ye + 1; i++)
    for(j = xb; j < xe + 1; j++)
      DIRECT_BIOS_write_char(i, j, symb, attr);

  mous_show();
}

/*
┌───────────────────────────────────────┐
│  08-Feb-1993 - ap                     │
│                                       │
│   Draw/hide text cursor.              │
│                                       │
└───────────────────────────────────────┘
*/
void FAST setcursor(int set)
{
  asm mov ah, 1
  asm mov ch, 1eh
  if(set)
  asm mov cl, 1fh
  else
  asm mov cl, 20h
  asm int 10h
}

/*
┌───────────────────────────────────────┐
│  08-Feb-1993 - ap                     │
│                                       │
│Place cursor to the selected position. │
│                                       │
└───────────────────────────────────────┘
*/
void FAST goto_yx(int y, int x)
{
  register char i, j;
  i = y, j = x;

  asm mov ah, 2   	/* Set cursor to */
  asm mov dh, i          /* Symbol's row  */
  asm mov dl, j          /* Symbol's col  */
  asm mov bh, 0  	/* Video page    */
  asm int 10h
}

/*
┌───────────────────────────────────────┐
│  08-Feb-1993 - ap                     │
│                                       │
│   Set background 16 colors.           │
│                                       │
└───────────────────────────────────────┘
*/
void FAST set16on()
{
  if(isegavga()) {    /* If monitor EGA/VGA */
    asm mov ah, 10h   /* Fun 10h - work with colors */
    asm mov al, 3     /* Subf 3  - change bgnd color */
    asm mov bl, 0     /* Set 16 background color */
    asm int 10h
  }
}

/*
┌───────────────────────────────────────┐
│  08-Feb-1993 - ap                     │
│                                       │
│   Set blinking on.                    │
│                                       │
└───────────────────────────────────────┘
*/
void FAST set16off()
{
  if(isegavga()) {
    asm mov ah, 10h
    asm mov al, 3
    asm mov bl, 1        /* Set 8 bgnd colors & blinking text */
    asm int 10h
  }
}

/*
┌───────────────────────────────────────┐
│  08-Feb-1993 - ap                     │
│                                       │
│   Is mouse supported ?                │
│                                       │
└───────────────────────────────────────┘
*/
void FAST mous_check()
{
  asm mov ax, 0
  asm int 33h
  asm mov mouseinstalled, ax
  return;
}

/*
┌───────────────────────────────────────┐
│  08-Feb-1993 - ap                     │
│                                       │
│   Show mouse at the screen.           │
│                                       │
└───────────────────────────────────────┘
*/
void FAST mous_show()
{
  if(!mouseinstalled)
    return;
  asm mov ax, 1
  asm int 33h
}

/*
┌───────────────────────────────────────┐
│  08-Feb-1993 - ap                     │
│                                       │
│   Erase mouse from the screen.        │
│                                       │
└───────────────────────────────────────┘
*/
void FAST mous_hide()
{
  if(!mouseinstalled)
    return;
  asm mov ax, 2
  asm int 33h
}

/*
┌───────────────────────────────────────┐
│  08-Feb-1993 - ap                     │
│                                       │
│   Mouse function 3 - is event here ?  │
│                                       │
└───────────────────────────────────────┘
*/
int FAST mous_event(y, x)
int *y, *x;
{
  int ret;
  if(!mouseinstalled) {
    *x = 0;
    *y = 0;
    return 0;
  }
  asm mov ax, 3
  asm int 33h
  asm mov bh, 0
  ret	= _BX ;     /* button pressed */
  *x 	= _CX ;     /* mouse cursor's position (x) in pixels */
  *y    = _DX ;     /* mouse cursor's position (y) in pixels */
  return  ret ;
}

/*
┌───────────────────────────────────────┐
│  08-Feb-1993 - ap                     │
│                                       │
│ Place mouse to the selected position. │
│                                       │
└───────────────────────────────────────┘
*/
void FAST mous_set(y, x)
int  y, x;
{
  if(!mouseinstalled)
    return;
  asm mov ax, 4
  asm mov cx, x       /* mouse cursor's position (x) in pixels */
  asm mov dx, y       /* mouse cursor's position (y) in pixels */
  asm int 33h
}

/*
┌───────────────────────────────────────┐
│  08-Feb-1993 - ap                     │
│                                       │
│   Draw mouse text cursor.             │
│                                       │
└───────────────────────────────────────┘
*/
void FAST mous_draw(ybeg, yend, type)
int  ybeg, yend, type;
{
  if(!mouseinstalled)
    return;
  asm mov ax, 10
  asm mov bx, type   /* 0 - mягкий, 1 - жесткий        */
  asm mov cx, ybeg   /* AND ybeg (bx = 0) or beg line  */
  asm mov dx, yend   /* OR  yend (bx = 0) or end line  */
  asm int 33h        /* см. Teach Help > 4.0           */
}

/*
┌───────────────────────────────────────┐
│  08-Feb-1993 - ap                     │
│                                       │
│   Get current time.                   │
│                                       │
└───────────────────────────────────────┘
*/
PRIVATE long LOCAL FAST	get_time(void)
{
char mm, ss, ts;
  asm mov ah, 2Ch       /* MS-DOS function gettime */
  asm int 21h           /* call MS-DOS    */
  mm	= _CL;          /* minutes  in cl */
  ss	= _DH;          /* seconds  in dh */
  ts	= _DL;          /* hundreds in dl */
  return mm * 60 * 100 + ss * 100 + ts;
}

/*
┌───────────────────────────────────────┐
│  08-Feb-1993 - ap                     │
│                                       │
│   Extended mouse events.              │
│                                       │
└───────────────────────────────────────┘
*/
int FAST inmouse(y, x, work_button)
        int     *work_button, *y, *x;
{
static  int     oldy                    = 0; /* Previous y coordinate */
static  int     oldx                    = 0; /* Previous x coordinate */
static  int     state                   = 0; /* Current  mouse state  */
static  int     last_button_pressed     = 3;
static  long    last_time               = 0; /* Time when button pressed */
int     oldstate;                            /* Previous mouse state     */
long    curr_time;                           /* Current time */
long    interval;        /* Interval from last button pressed */
int     ret = 0;

   if(!mouseinstalled)						return 0;

   /* Check and set mouse work button */
   if(*work_button > 2) *work_button = 2;
   if(*work_button < 1) *work_button = 1;

   /* Remember previous mouse state and get current mouse state */
   oldstate     = state;
   state        = mous_event(y, x);

   /* We pressed work button ? */
   if(*work_button == state)
   {
       curr_time = get_time();            /* Get current time */
       interval  = curr_time - last_time; /* Count interval from last press */

       /* We pressed it twice with interval < 30msc ? */
       if((last_button_pressed == *work_button)&&(oldstate == 0)&&
          (oldy == *y)&&(oldx == *x)&&(interval < 30L))
       {
	  last_time = 0;           /* Time reset */
          last_button_pressed = 0; /* Last pressed button reset */
	  ret = 9;                 /* Return */
       }
       else
       {
          /* May be we pressed in once */
          if((oldy != *y)||(oldx != *x)||(oldstate == 0))
          {
	     last_time = get_time();             /* Set chrono */
             last_button_pressed = *work_button; /* Set button */
             ret = *work_button;                 /* Return pressed button */
          }
          else       ret = 0;        /* Nothing pressed */
       }
       oldy     = *y;
       oldx     = *x;
       return   ret;
   }
   /* Now check other buttons */
   switch(state)
   {
      /* All buttons not pressed. M.b. we release it now ? */
      case  0 :
	   if(oldstate)  ret = -oldstate;   /* Yes */
	   else		 ret = 0;           /* No  */
           break;

      /* Here we returns pressed buttons which is not work button */
      case  1 :
      case  2 :
      case  4 :
      case  3 :
      case  5 :
      case  6 :
      case  7 :
          last_button_pressed  = state;
           if((oldy != *y)||(oldx != *x)||(oldstate == 0))     ret = state;
           else                                                ret = 0;
           break;
  }
   oldy = *y;
   oldx = *x;
   return ret;
}