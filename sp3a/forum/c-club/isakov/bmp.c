                                /* BMP.C */
/* /////////////////////////////////////////////////////////////////////// */
/*                    Small Test for "BMPClass" module.                    */
/*  15-Nov-91 :        Konstantin E. Isakov  (C)1991.        : 25-Nov-91   */
/* /////////////////////////////////////////////////////////////////////// */
#include <Windows.h>
#include "N_Wirth.h"
#include "Message.h"    /* #define CALLBACK  */
#include "BMPClass.h"
/* /////////////////////////////////////////////////////////////////////// */

#define DLG_TITLE   100

static  FARPROC  OriginWnd = NULL;
static  HWND     hWnd = 0;
static  HWND     hDlg = 0;

/* /////////////////////////////////////////////////////////////////////// */

LONG CALLBACK SubClassWndProc (HWND hDlg, WORD Msg, WORD wParam, LONG lParam) IS
BEGIN
  IF Msg == WM_CLOSE THEN
    DestroyWindow (hWnd);
    DestroyWindow (hDlg);
  END;
  IF Msg == WM_DESTROY THEN
    PostQuitMessage (0);
  END;
  return (CallWindowProc (OriginWnd, hDlg, Msg, wParam, lParam));
END/* DlgWndProc */;

/* /////////////////////////////////////////////////////////////////////// */

int PASCAL WinMain (HANDLE hInst, HANDLE hPrev, LPSTR Cmd, int Show) IS
  BOOL  ret;
  MSG   Msg;
BEGIN
  hPrev; Cmd; Show;  // unused params; '#pragma argsused' for Borland C++

  ret = BMP_Register (hInst);
  // assert (ret);

  hWnd = CreateWindow ("BitmapWnd", "TEST_BITMAP",
                       WS_OVERLAPPEDWINDOW | WS_VISIBLE,
                       100, 20, 140, 200, 0, 0, hInst, 0);

  hDlg = CreateDialog (hInst, "BMP_DIALOG", 0, NULL);
  // assert (hDlg);

  OriginWnd = (FARPROC) SetWindowLong (hDlg, GWL_WNDPROC,
            (DWORD) MakeProcInstance ((FARPROC) SubClassWndProc, hInst) );

#ifdef __BORLANDC__
  SetWindowText (GetDlgItem (hDlg, DLG_TITLE), "Borland C++");
#endif

  WHILE GetMessage (&Msg, 0, 0, 0) DO
    TranslateMessage (&Msg);
    DispatchMessage  (&Msg);
  END_WHILE;
  return (Msg.wParam);

END/* WinMain */

/* /////////////////////////////////////////////////////////////////////// */
/*                          End of file "BMP.C"                            */
/* /////////////////////////////////////////////////////////////////////// */
