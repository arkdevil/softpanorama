                               /* Message.c */
/* //////////////////////////////////////////////////////////////////////// */
/*               A little module to manage Windows messages                 */
/*  16-Oct-91 :        Konstantin E. Isakov  (C)1991.         : 16-Oct-91   */
/* //////////////////////////////////////////////////////////////////////// */
#include <Windows.h>
#include <string.h>     /* memcpy */
#include "N_Wirth.h"
#include "Message.h"
/* //////////////////////////////////////////////////////////////////////// */

typedef struct {
   LONG  lPar;
   WORD  wPar;
   WORD  msg;
   HWND  wnd;
} TMSG;

WORD MakeMessage (TMESSAGE *Msg, LONG *lParamAddr) IS
BEGIN
  Msg->result = 0L;
  memcpy (&Msg->lParam, lParamAddr, sizeof(TMSG));
  return (Msg->message);
END/* MakeMessage */;

/* //////////////////////////////////////////////////////////////////////// */

VOID  wmDefault (PMESSAGE Msg) IS
BEGIN
  Msg->result = DefWindowProc (Msg->hwnd,   Msg->message,
                               Msg->wParam, Msg->lParam );
END/* wmDefault */;

/* //////////////////////////////////////////////////////////////////////// */

/*                                EXAMPLE :
*
*  LONG CALLBACK WndProc (HWND w, WORD m, WORD w, LONG lParam) IS
*    TMESSAGE M;
*  BEGIN
*    w; m; w; // unused params
*    SWITCH MakeMessage (&M, &lParam) OF
*      case WM_CREATE:     wmCreateProc  (&M);   break;
*      case WM_DESTROY:    wmDestroyProc (&M);   break;
*      default:            wmDefault     (&M);
*    END_SWITCH;
*    return (M.result);
*  END_PROC;
*
*  VOID wmCreateProc (PMESSAGE m) IS
*    int  a, b;
*  BEGIN
*    SetWindowWord (m->hwnd, 0, CreateSolidBrush(RED));
*    ...............
*    m->result = RET_VALUE;
*  END_PROC;
*
*  void wmDestroyProc (PMESSAGE m)
*  {
*     DeleteObject (GetWindowWord (m->hwnd, 0));
*     wmDefault (m); // for example
*  }
*
*/

/* //////////////////////////////////////////////////////////////////////// */
/*                         End of file "Message.c"                          */
/* //////////////////////////////////////////////////////////////////////// */
