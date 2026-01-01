/***************************************************************/
/*                                                             */
/*             KIVLIB include file   WINS.H                    */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/

#ifndef ___WINS_H___
#define ___WINS_H___


#if ( __TINY__ || __SMALL__ || __COMPACT__ )
#define ___FUNCS  near
#else
#define ___FUNCS  far
#endif

#include <fastw.h>

typedef struct {
	  int sx;
	  int sy;
	  int ex;
	  int ey;
	  int frattr;
	  int wattr;
	  int hattr;
	  int sattr;
	  int shad;
	  frametype fr;
	  int * buf;
	  int * sbuf;
	  unsigned char * SH;
	  char * header;
	  void * next;
	  void * prev;
	  int saved;
	  } Window;

#ifdef __cplusplus
extern "C" {
#endif

Window * cdecl makeWindow(  //alloc memory for Window !
		int sr,      //start row          Warning!
		int sc,      //start column       You must take measures
		int er,      //end row            for end values >=
		int ec,      //end column         start values!!!
		int shadowed,
		frametype fram,
		int winattr,
		int frameattr,
		int headattr,
		int shadattr,
		char * Header);


int cdecl WindowIsDisplayed(Window * W);

void cdecl displayWindow(Window * W); //will be TOP window !!

Window * cdecl eraseTopWindow();

void cdecl deleteWindow(Window * W); //только из памяти и только если не displayed

void cdecl eraseWindow(Window * W); //erase from screen

void cdecl wipeWindow(Window * W);

void cdecl InsertWindowAfter(Window * W, Window * after);

void cdecl MoveWindow(Window * W, int dx, int dy);

int  cdecl ResizeWindow(Window * W, int dx, int dy);

void cdecl wcolorwrite(Window * w, char * s, int row, int col, int attr);

void cdecl wwrite(Window * w, char * s, int row, int col);

void cdecl _clrwin(Window * w, char s);

void cdecl clrwin(Window * w);

int cdecl scrollW(Window * W, int up);



char * cdecl editStr(char * prompt,
	       char * str,
	       int row,
	       int col,
	       int width,
	       int pattr,
	       int sattr,
	       void ___FUNCS (*helpfunc)());

char * cdecl WinEditStr(char * header, char * prompt, char * str,
		  int len,
		  int wattr,
		  int hattr,
		  int fattr,
		  int eattr,
		  int shadowed,
		  int shattr,
		  int row,
		  int col,
		  void ___FUNCS (*helpfunc)());


void cdecl ViewMem(char * Mem,
	     unsigned len,
	     int sr,
	     int sc,
	     int er,
	     int ec,
	     int shadowed,
	     frametype fr,
	     int wattr,
	     int fattr,
	     int hattr,
	     int shattr,
	     char * header,
	     void ___FUNCS (*HELP)());


#define mwError  0x01
#define mwInfo   0x02
#define mwHelp   0x04


unsigned int cdecl messageWindow(char * message, unsigned flag);
void cdecl messageWindowPar(int flag, char * param, ...);


Window * cdecl makeDesk(int attr,char * header);



int cdecl PickListV( int sr, int sc,
		    int er, int ec,
		    int usattr,
		    int sattr,
		    int fattr,
		    int hattr,
		    int shadowed,
		    int shattr,
		    frametype FR,
		    char * Header,
		    char * ___FUNCS (*RF)(int),
		    int Max);



char * cdecl GetFileName(char * mask,
                   char * name,
                   int sr, int sc,
                   int er, int wa,
                   int fa, int ha,
                   int sh, int sha,
                   int sa, frametype FR,
                   int sortby, //0 - by name, 1 - by ext, 2 - by size
                   int viewshort, int * error);


/********************************************
     Do'nt use follow functions directly !
********************************************/

void cdecl A2Vseg();
void cdecl V2Aseg();

void StartupWindows();

#ifdef __cplusplus
  }
#endif


#endif
