/***************************************************************/
/*                                                             */
/*               KIVLIB include file  FASTW.H                  */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/
#ifndef ___FAST_H___
#define ___FAST_H___


typedef char frametype[7];

#define NOFRAME        "      "
#define STANDARDFRAME  "╔╗╝╚═║"
#define THINFRAME      "┌┐┘└─│"
#define VTHINFRAME     "╒╕╛╘═│"
#define HTHINFRAME     "╓╖╜╙─║"


#ifdef __cplusplus
extern "C" {
#endif

void cdecl check_vid();
void cdecl clear_region(int sr, int sc, int er, int ec, char s, int attr);
void cdecl _fastwrite(char  * s, int len, int row, int col, int attr);
void cdecl _fastcenter(char *s, int row, int sc, int ec, int attr);
void cdecl fastread (char *s, int row, int col, int len);
void cdecl fastreadattr(char *s, int row, int col, int len);
void cdecl save_region(int * buf, int sx, int sy, int ex, int ey);
void cdecl restore_region(int * buf, int sx, int sy, int ex, int ey);
void cdecl drawframe(frametype f, int sr, int sc, int er, int ec, int attr);
void cdecl drawheadframe(frametype fr,int sr, int sc, int er, int ec, int fattr,
		   char * head, int hattr);
void cdecl fastwrite(char* s, int row, int col, int attr);
void cdecl changeattr(int attr, int row, int col, int len);

unsigned int cdecl getcursorshape();
void cdecl setcursorshape(unsigned w);
// 0x2000 - invisible

void setBlink( int On);


#ifdef __cplusplus
}
#endif


#endif
