                               /* Message.h */
/* //////////////////////////////////////////////////////////////////////// */
/*               A little module to manage Windows messages                 */
/*  16-Oct-91 :        Konstantin E. Isakov  (C)1991.         : 16-Oct-91   */
#ifndef __MESSAGE_H /*///////////////////////////////////////////////////// */
#define __MESSAGE_H

#ifndef  CALLBACK
#define  CALLBACK    far pascal _export

typedef  LONG  (FAR PASCAL *WNDPROC) (HWND, WORD, WORD, LONG);
typedef  BOOL  (FAR PASCAL *DLGPROC) (HWND, WORD, WORD, LONG);
#endif

/* //////////////////////////////////////////////////////////////////////// */

typedef struct {
   LONG  result;
   LONG  lParam;
   WORD  wParam;
   WORD  message;
   HWND  hwnd;
} TMESSAGE, *PMESSAGE;

WORD  MakeMessage (TMESSAGE *Msg, LONG *lParamAddr);
VOID  wmDefault (PMESSAGE Msg);

#endif /*////////////////////////////////////////////////////////////////// */
/*                         End of file "Message.h"                          */
/* //////////////////////////////////////////////////////////////////////// */
