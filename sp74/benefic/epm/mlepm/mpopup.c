/***************************************************************************\
* popup.c - this is the pm part of the PopUp project
*
* Copyright (c) 1994 Martin Lafaix. All Rights Reserved.
\***************************************************************************/

#define INCL_WIN

#include <os2.h>

/***************************************************************************/
/* global variables                                                        */ 
/***************************************************************************/

HAB hab;
HWND hwndEPM;

/***************************************************************************/
/* window proc                                                             */
/***************************************************************************/
MRESULT EXPENTRY wpMenu(HWND hwnd, ULONG msg, MPARAM mp1, MPARAM mp2)
{
  switch(msg)
    {
    case WM_USER+1:                                      /* sent by mpopup */
      {
      POINTL pointl;
 
      WinQueryPointerPos(HWND_DESKTOP, &pointl);
        
      hwndEPM = HWNDFROMMP(mp1);
      WinPopupMenu(HWND_DESKTOP, hwnd,
                   WinLoadMenu(HWND_DESKTOP, NULLHANDLE, SHORT1FROMMP(mp2)*100),
                   pointl.x, pointl.y, 0,
                   PU_MOUSEBUTTON1 | PU_HCONSTRAIN | PU_VCONSTRAIN | PU_KEYBOARD);
      }
      break;
    case WM_USER+2:                  /* autohiliting delay (half a second) */
      hwndEPM = HWNDFROMMP(mp1);
      WinStartTimer(hab, hwnd, 1, 500);
      break;
    case WM_TIMER:                    /* timer has expired, so do hiliting */
      WinPostMsg(hwndEPM, WM_COMMAND, MPFROMSHORT(9299), MPVOID);
      WinStopTimer(hab, hwnd, 1);
      break;
    case WM_COMMAND:
      WinPostMsg(hwndEPM, WM_COMMAND, mp1, MPVOID);
      break;
    case WM_MENUSELECT:              /* update status line -- if available */
      WinPostMsg(hwndEPM, WM_MENUSELECT, mp1, mp2);
      return (MRESULT)TRUE;
      break;
    case WM_MENUEND:
    default: 
      return WinDefWindowProc(hwnd, msg, mp1, mp2);
    }
  return (MRESULT)FALSE;
}

/***************************************************************************/
/* main function - starts MLPOPUP server.                                  */
/***************************************************************************/
int main(int argc, char *argv[], char *envp[])
{
  HMQ hmq;
  QMSG qmsg;
  ULONG flCreate = FCF_TITLEBAR | FCF_TASKLIST;
  HWND hwndFrame;
  HWND hwnd;

  hab = WinInitialize(0);
  hmq = WinCreateMsgQueue(hab, 0);

  WinRegisterClass(hab, "MLC_POPUP", (PFNWP)wpMenu, 0, 0);
 
  hwndFrame = WinCreateStdWindow(HWND_DESKTOP, 0,
                                 &flCreate, "MLC_POPUP",
                                 "MLPOPUP", 0,
                                 (HMODULE)0, 1234,
                                 &hwnd);
 
  while(WinGetMsg(hab, &qmsg, 0, 0, 0))
    WinDispatchMsg(hab, &qmsg);
 
  WinDestroyWindow(hwndFrame);

  WinDestroyMsgQueue(hmq);
  WinTerminate(hab);
 
  return 0;
}
