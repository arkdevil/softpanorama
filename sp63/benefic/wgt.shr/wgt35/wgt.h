#include <stdio.h>
/* WordUp Graphics Toolkit V3.5
   Copyright 1992 Chris Egerter
*/

#ifdef __cplusplus
extern "C" {
#endif

typedef unsigned char far * block;
typedef unsigned char far * wgtfont;
typedef unsigned char far * wgtmap;

#define false 0
#define true 1

#define up 0
#define down 1
#define left 2
#define right 3

#define vertical 0
#define horizontal 1

extern unsigned char currentcolor;
extern block abuf;
extern int but,mx,my;

extern maxsprite;

typedef struct {
	unsigned char r,g,b;
	} color;

// Initializing
extern void vga256(void);

// drawing functions
extern void wbar(int,int,int,int);
extern void wbutt(int,int,int,int);
extern void wcircle(int,int,int);
extern void wclip(int,int,int,int);
extern void wcls(int);
extern void wfastputpixel(int,int);
extern void wfill_circle(int,int,int);
extern void wfline(int,int,int,int);
extern int  wgetpixel(int,int);
extern void wline(int,int,int,int);
extern void wputpixel(int,int);
extern void wrectangle(int,int,int,int);
extern void wregionfill(int,int);
extern void wretrace(void);
extern void wstyleline(int,int,int,int,unsigned int);


// palette functions
extern void wcolrotate(int,int,int,color[256]);
extern void wfade_in(int,int,int,color[256]);
extern void wfade_out(int,int,int,color[256]);
extern void wloadpalette(char *,color *);
extern void wreadpalette(int,int,color *);
extern void wremap(color *, block, color *);
extern void wsavepalette(char *,color *);
extern void wsetcolor(int);
extern void wsetpalette(int,int,color *);
extern void wsetrgb(int,int,int,int,color *);


// block functions

extern void  wflipblock(block ,int);
extern void  wfreeblock(block );
extern int   wgetblockheight(block);
extern int   wgetblockwidth(block);
extern block wloadblock(char *);
extern block wloadcel(char *,color *);
extern block wloadpak(char *);
extern block wloadpcx256(char *,color *);
extern block wnewblock(int,int,int,int);
extern void  wputblock(int,int,block ,int);
extern int   wsaveblock(char *,block );
extern void  wsavecel(char *,block,color[256]);
extern int   wsavepak(char *,block );
extern void  wsavepcx256(char *,block,color[256]);


// mouse functions
extern int  minit(void);
extern void moff(void);
extern void mon(void);
extern void mouseshape(int,int,void far *);
extern void mread(void);
extern void msetbounds(int, int, int, int);
extern void msetspeed(int,int);			
extern void msetthreshhold(int);		 
extern void noclick(void);

// Screen Operations
extern void  wcopyscreen(int,int,int,int,block ,int,int,block );
extern void  wnormscreen(void);
extern void  wsetscreen(block);


// Text functions
extern void    wflashcursor(void);
extern void    wfreefont(wgtfont);
extern int     wgettextheight(char *,wgtfont);
extern int     wgettextwidth(char *,wgtfont);
extern void    wgtprintf(int,int,wgtfont, char *, ... );
extern wgtfont wloadfont(char *);
extern int     woutchar(int, int, int,wgtfont);
extern void    wouttextxy(int,int,char *,wgtfont);
extern void    wsetcursor(int,int);
extern int     wstring (int, int, char *, char *, int);
extern void    wtextbackground(unsigned char);
extern void    wtextcolor(unsigned char);
extern void    wtextgrid(int);
extern void    wtexttransparent(int);
extern int     curspeed,xc,yc;

// special FX
extern void wfade(block ,int *,int);
extern void wmovescreen(int,int,int,int,int,int);
extern void wpan(int);
extern void wresize(int,int,int,int,block);
extern void wskew(int,int,block,int);
extern void wsline(int, int, int, int,int *);
extern void wvertres(int,int,int,block);
extern void warp(int,int,int *,int *,block);
extern void wwipe(int,int,int,int,block);


// library vars
extern FILE *libf;
extern void setlib(char *);
extern char *getlib(void);
extern void setpassword(char *);
extern char *getpassword(void);
extern void *lib2buf(char *);
extern void readheader(void);
extern char *wgtlibrary;
extern char password[16];
extern int  lresult;
extern long lsize;
extern fpos_t lfpos;

// Sprite
extern void wfreesprites(block[1001]);
extern int wloadsprites(color *,char *,block[1001]);


#ifdef __cplusplus
}
#endif
