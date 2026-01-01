/* --- SLICK!.H -------------------------------------------------
**
** (C) by MacSoft 1990, 1991
**
** Version 3.2, part of SLICK!
*/
#define SINGLEFRAME "┌─┐│ │└─┘"
#define DOUBLEFRAME "╔═╗║ ║╚═╝"
#define HMIXFRAME   "╒═╕│ │╘═╛"
#define VMIXFRAME   "╓─╖║ ║╙─╜"
#define FATFRAME    "█▀██ ██▄█"
#define FULLFRAME   "████ ████"

/*
** These are in-line functions.  These prototypes just clean up
** some syntax checks and code generation. From TC's <dos.h>
*/
#ifdef __cplusplus
extern "C" {
#endif
void cdecl __cli__(void);
void cdecl __sti__(void);
unsigned char cdecl __inportb__(int portid);
void cdecl __outportb__(int portid, unsigned char value);
void cdecl __int__(int interruptnum);
void __emit__();
#ifdef __cplusplus
}
#endif

/*
** Define NULL, from TC's <stdio.h>
*/
#ifndef NULL
#  if defined(__TINY__) || defined(__SMALL__) || defined(__MEDIUM__)
#    define NULL 0
#  else
#    define NULL 0L
#  endif
#endif

/*
** Some useful macros.
*/
#define cursoroff()   {_AH=1;_CX=0x2000;__int__(0x10);}
#define cursoron()    {_CX=_curntwnd->cursize;_AH=1;__int__(0x10);}
#define restorcur()   {_DX=_curntwnd->curpos;_BH=0;_AH=2;__int__(0x10);}
#define framesoff()   {_curntwnd->vx1=_curntwnd->x1; \
                       _curntwnd->vy1=_curntwnd->y1; \
                       _curntwnd->vx2=_curntwnd->x2; \
                       _curntwnd->vy2=_curntwnd->y2;}

/*
** Macros for DESQview.
*/
#define DVpause()  {_AX=0x1000;__int__(0x15);} /* give away timeslice */
#define DVbeginc() {_AX=0x101b;__int__(0x15);} /* begin critical section */
#define DVendc()   {_AX=0x101c;__int__(0x15);} /* end critical section */

/*
** Video control structure
*/
typedef struct    {
        unsigned int base;      /* physical/virtual screen segment */
        char mode;              /* physical video mode */
        char cols;              /* columns on physical/virtual screen */
        char rows;              /* rows on physical screen */
        char snow;              /* bit0=1 forces snow check if colour mode */ 
        char ega;               /* 0 - no EGA, 1 - EGA color, 2 - EGA mono */
} VIDEO;

/*
** Window header structure.
*/
typedef struct    {
        int    x1,y1,x2,y2;     /* frame corners */
        int vx1,vy1,vx2,vy2;    /* viewport corners */
        unsigned int curpos,    /* cursor pos & size */
                    cursize;    /* before opening ... */
        unsigned int color;     /* used to open */
        void far *last;         /* to previous window */
        void far *next;         /* to next window */
        unsigned int cursor;    /* current cursor position */
        unsigned int pushcursor;/* cursor position saved here by pushwnd */
        int space[1];           /* data, expands ... */
} WINDOW;

/*
** Menu structures.
** This is for "vertical" menus used to create pulldown menus.
** These structures and functions are left here just for compatibility,
** menueng() does much better job...
*/
typedef struct {
        int makenew     :1;     /* 1 for open window, 0 if exist on screen */
        int center      :1;     /* 1 if you want items centered */
        int leavemenu   :1;     /* 1 if you don't want menu closed on exit */
        char far *frame;        /* frame for window */
        int wndcolor;           /* color for window (frame&fill) */
        char normcolor;         /* color for normal items */
        char invcolor;          /* color for selection bar */
        char hicolor;           /* color for hot keys */
        int defchoice;          /* item selected by default when entering */
        int reserved;           /* empty space on each side of item */
} VMENU;
/*
** Raw menu item structure.
*/
typedef struct {
    int x,y;                    /* absolute screen coordinates for cursor */
    int xlen;                   /* field length */
    char far *text;             /* menu selection text */
    char normcolor;             /* color for normal text */
    char invcolor;              /* color for cursor bar */
    char hicolor;               /* color for highlited character */
    int textoff;                /* text offset in cursor bar */
    int highoff;                /* offset in string for highlited character */
} MEITEM;

/*
** This are very important variables, you can freely read them but
** overwriting them may cause very funny effects...
*/
extern WINDOW far *_curntwnd;                /* active window pointer */
extern VIDEO _videocblk;                 /* video control block */
extern unsigned char _mouseinst,mousedvparm; /* mouse status & DV param. */
extern void far (*_showhook)(void);          /* hook to show mouse cursor */
extern void far (*_hidehook)(void);          /* hook to hide mouse cursor */

/*
** Function prototypes
**
** Memory management.
*/
#ifdef __cplusplus
extern "C" {
#endif
void far * far _mymalloc(long nbytes);
void far _myfree(void far *adr);
void far _myfail(unsigned int got, unsigned int wanted);
long far _mycoreleft(void);
/*
** User timer suppport.
*/
void interrupt far _timer(void);
void far _inittimer(int count,int far *where);
void far _deinittimer(void);
void far _eventtimer(void far (*func)(int channel));
/*
** Keyboard.
*/
int far waitkey(void);
int far testkey(void);
/*
** Generic functions.
*/
int far DVactive(void);
int far vidmode(int newmode);
char far * far wndversio(void);
/*
** Fast pseudo-random generator.
*/
unsigned int far _myrand(void);
unsigned int far _myseed(unsigned int newseed);
/*
** Screen management.
*/
int far rawmenu(int items,int def,MEITEM menu[],int leavebar,
				int far (*scan)(int curnt));
int far putcwnd(int character);
int far shrnkwnd(int step);
int far statwnd(char far *s,char far *frame,unsigned int color);
int far pushwnd(void);
int far popwnd(void);
void far snowtest(int flag);
int far makemenu(int x1,int y1,VMENU far *flags,
                 char far *items,int far (*scan)(int curnt));
int far getswnd(int x1,int y1,char far *prompt,char far *dest,
                char far *frame,unsigned int pattr,int len,
                unsigned int ipad,int far (*scan)(void));
int far getwinp(int x1,int y1,unsigned int pad,char far *dest,
                int len,int far (*scan)(void));
int far locate(int x1,int y1);
int far clearwnd(unsigned int charattr);
int far scrollup(unsigned int charattr);
int far scrolldn(unsigned int charattr);
int far prtcwnd(int y1,char far *s,int color);
int far prtwnd(int x1,int y1,char far *s,int color);
int far makewnd(int x1,int y1,int x2,int y2,char far *frame,
                unsigned int color,int zoom);
int far closewnd(void);
int far forgetwnd(void);
void far _drawbox(int x1,int y1,int x2,int y2,char far *frame,
                  unsigned int color,int infill);
/*
** Low level video drivers, assembly language.
*/
void far _recolor(int x,int y,int len,int color);
void far _vputs(int x,int y,char far *s,int a);
void far _vputsc(int x,int y,char far *s,int a,int maxlen);
void far _vputscp(int x,int y,char far *s,int a,int maxlen);
void far _tovid(int x,int y,int far *s,unsigned int wcount);
void far _fromvid(int x,int y,int far *s,unsigned int wcount);
void far _vlwrite(int x,int y,unsigned int char_attr,unsigned int wcount);
void far _vputc(int x,int y,unsigned int char_attr);
unsigned int far _vgetc(int x,int y);
int far * far _scrbase(void);
int far * far _videoparm(void);
#ifdef __cplusplus
}
#endif
