#ifndef _DEFINE
#   define _DEFINE
#   ifndef COLOR_EXTERN
#      define COLOR_EXTERN
#   endif
#   define TRUE     1
#   define FALSE    0
#   define ERROR    (-1)
#   define dim(x)   (sizeof(x)/sizeof((x)[0]))
#   define ESC      '\033'
#   define ESCAPE   27
#   define ERR      '\377'
#   define BEEP()   scrputc(7)
#   define NOCURSOR 0x3F1F

#   define BR_CHAR 188 /* '╝' */

#   define BRIGHT_BW   15
#   define NORMAL_BW   7
#   define INVERT_BW   0x70
#   define ITALIC_BW   13
#   define EMPTY_BW    7
#   define BORDER_BW   15
#   define HLIGHT_BW   (INVERT_BW | BRIGHT_BW)
#   define TSNAME_BW   15

#   define BRIGHT_COLOR   0x1F
#   define NORMAL_COLOR   0x17
#   define INVERT_COLOR   0x70
#   define ITALIC_COLOR   0x1C
#   define EMPTY_COLOR    0x07
#   define BORDER_COLOR   0x13 /* 0x17 */
#   define HLIGHT_COLOR (INVERT_COLOR | BRIGHT_COLOR)
#   define TSNAME_COLOR   0x1F
#   ifdef MONOCHROME
#      define BRIGHT BRIGHT_BW
#      define NORMAL NORMAL_BW
#      define INVERT INVERT_BW
#      define ITALIC ITALIC_BW
#      define EMPTY  EMPTY_BW
#      define BORDER BORDER_BW
#      define HLIGHT (INVERT_BW | BRIGHT_BW)
#      define TSNAME TSNAME_BW
#   else
       COLOR_EXTERN int BRIGHT, NORMAL, INVERT, ITALIC, EMPTY, BORDER,
                        HLIGHT, TSNAME;
#   endif

    extern void fillside(int, int);
    extern int  keyserv (int);
    extern void scrline (short, short, char*, int);
    extern void scrprint(char*, int);
    extern void colorset(int, char**);

#   ifdef MONOCHROME
#      define setcolor(c,v)
#   endif
#endif
