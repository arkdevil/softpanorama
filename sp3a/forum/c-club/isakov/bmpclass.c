                              /* BMPClass.C */
/* /////////////////////////////////////////////////////////////////////// */
/*        "Bitmap Window" class. The same as "STATIC" with SS_ICON         */
/*  15-Nov-91 :        Konstantin E. Isakov  (C)1991.        : 25-Nov-91   */
/* /////////////////////////////////////////////////////////////////////// */
#define  NDEBUG          /* - assertion off */
#include <Windows.h>
#include <assert.h>
#include "N_Wirth.h"
#include "Message.h"
#include "BMPClass.h"
/* /////////////////////////////////////////////////////////////////////// */

#define  WNDCLSEXTRA    sizeof (HANDLE)
#define  hBmpIdx        0

static   HANDLE  hInst  = 0;

/* /////////////////////////////////////////////////////////////////////// */

LONG CALLBACK BMP_WndProc (HWND, WORD, WORD, LONG);

static VOID CreateBmp (PMESSAGE);
static VOID wmCreate  (PMESSAGE);
static VOID wmSize    (PMESSAGE);
static VOID wmPaint   (PMESSAGE);
static VOID wmDestroy (PMESSAGE);

/* /////////////////////////////////////////////////////////////////////// */

BOOL  BMP_Register (HANDLE hInstance) IS
  WNDCLASS wc;
BEGIN
  hInst = hInstance;
  IF GetClassInfo (hInst, BMP_ClassName, &wc) THEN
    return (TRUE);
  END;
  wc.style         = BMP_ClassStyle;
  wc.lpfnWndProc   = (WNDPROC) BMP_WndProc;
  wc.cbClsExtra    = 0;
  wc.cbWndExtra    = WNDCLSEXTRA;
  wc.hInstance     = hInst;
  wc.hIcon         = 0;
  wc.hCursor       = LoadCursor (0, IDC_ARROW);
  wc.hbrBackground = 0;
  wc.lpszMenuName  = NULL;
  wc.lpszClassName = BMP_ClassName;
  return (RegisterClass (&wc));
END/* BMP_Register */;

/* /////////////////////////////////////////////////////////////////////// */

LONG CALLBACK BMP_WndProc (HWND h, WORD msg, WORD w, LONG lParam) IS
  TMESSAGE  m;
BEGIN
  h; msg; w;   // unused params
  SWITCH MakeMessage (&m, &lParam) OF
    case WM_CREATE:   wmCreate (&m);  break;
    case WM_SIZE:     wmSize (&m);    break;
    case WM_PAINT:    wmPaint (&m);   break;
    case WM_DESTROY:  wmDestroy (&m); break;
    default:          wmDefault (&m);
  END_SWITCH;
  return (m.result);
END/* BMP_WndProc */;

/* /////////////////////////////////////////////////////////////////////// */

static VOID CreateBmp (PMESSAGE m) IS
  RECT   R;    HDC      SrcDC, DstDC;
  BITMAP Bm;   HBITMAP  hBmp,  hSrcBmp, s1, s2;
  char   Buf [80];
BEGIN
  GetWindowText (m->hwnd, (LPSTR)Buf, 80);
  GetClientRect (m->hwnd, &R);

  DstDC = GetDC (m->hwnd);
  hBmp = CreateCompatibleBitmap (DstDC, R.right, R.bottom);
  assert (hBmp);
  ReleaseDC (m->hwnd, DstDC);
  SetWindowWord (m->hwnd, hBmpIdx, (WORD)hBmp);

  DstDC = CreateCompatibleDC (0);
  s1 = SelectObject (DstDC, hBmp);

  hSrcBmp = LoadBitmap (hInst, Buf);
  IF hSrcBmp == 0 THEN
    BitBlt (DstDC, 0,0, R.right, R.bottom, 0, 0,0, BLACKNESS);
    // m->result = 1;                                        { ??????? }
  ELSE
    GetObject (hSrcBmp, sizeof (BITMAP), (LPSTR)&Bm);
    SrcDC = CreateCompatibleDC (0);
    s2 = SelectObject (SrcDC, hSrcBmp);
    StretchBlt (DstDC, 0,0, R.right, R.bottom,
                SrcDC, 0,0, Bm.bmWidth, Bm.bmHeight, SRCCOPY);
    DeleteObject (SelectObject (SrcDC, s2));
    DeleteDC (SrcDC);
  END_IF;

  SelectObject (DstDC, s1);
  DeleteDC (DstDC);
END/* CreateBmp */;

/* / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / */

static VOID wmCreate (PMESSAGE m) IS
BEGIN
  SetWindowWord (m->hwnd, hBmpIdx, 0);
  /* wmSize really create bitmap */
END/* wmCreate */;

/* / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / */

static VOID wmSize (PMESSAGE m) IS
BEGIN
  wmDestroy (m);
  CreateBmp (m);
END/* wmSize */;

/* / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / */

static VOID wmPaint (PMESSAGE m) IS
  HDC     hDC, MemDC;     RECT         R;
  HBITMAP hBmp, sBmp;     PAINTSTRUCT  ps;
BEGIN
  hBmp = GetWindowWord (m->hwnd, hBmpIdx);
  assert (hBmp);
  MemDC = CreateCompatibleDC (0);
  assert (MemDC);
  sBmp = SelectObject (MemDC, hBmp);
  GetClientRect (m->hwnd, &R);
  hDC = BeginPaint (m->hwnd, &ps);
  BitBlt (hDC, 0,0, R.right, R.bottom, MemDC, 0,0, SRCCOPY);
  EndPaint (m->hwnd, &ps);
  SelectObject (MemDC, sBmp);
  DeleteDC (MemDC);
END/* wmPaint */;

/* / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / */

static VOID wmDestroy (PMESSAGE m) IS
  HBITMAP  hBmp;
BEGIN
  IF (hBmp = GetWindowWord (m->hwnd, hBmpIdx)) == 0 THEN return; END;
  DeleteObject (hBmp);
  SetWindowWord (m->hwnd, hBmpIdx, 0);
END/* wmDestroy */;

/* /////////////////////////////////////////////////////////////////////// */
/*                        End of file "BMPClass.C"                         */
/* /////////////////////////////////////////////////////////////////////// */
