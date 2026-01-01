// snap.c

//*******************************************************************
//
// program - snap.c
// purpose - Capture screen to clipboard.
//
//*******************************************************************

#include <windows.h>
#include <stdlib.h>
#include "snap.h"

static   char   szAppName[] = "Snap";
static   short  xSize, ySize;
static   BOOL   bCapturing = FALSE, bBlocking = FALSE;
static   POINT  beg, end, oldend;
static   HANDLE hInst;

//*******************************************************************
// WinMain - snap main
//
// paramaters:
//             hInstance     - The instance of this instance of this
//                             application.
//             hPrevInstance - The instance of the previous instance
//                             of this application. This will be 0
//                             if this is the first instance.
//             lpszCmdLine   - A long pointer to the command line that
//                             started this application.
//             cmdShow       - Indicates how the window is to be shown
//                             initially. ie. SW_SHOWNORMAL, SW_HIDE,
//                             SW_MIMIMIZE.
//
// returns:
//             wParam from last message.
//
//*******************************************************************
#pragma argsused

int PASCAL WinMain(HANDLE hInstance, HANDLE hPrevInstance,
		   LPSTR lpszCmdLine, int cmdShow)
{
  HWND  hWnd;
  MSG   msg;

// Go init this application.

  if (!hPrevInstance)
  {
    WNDCLASS wndclass;

  // Define the window class for this application.

    wndclass.style         = CS_HREDRAW | CS_VREDRAW;
    wndclass.lpfnWndProc   = WndProc;
    wndclass.cbClsExtra    = 0;
    wndclass.cbWndExtra    = 0;
    wndclass.hInstance     = hInstance;
    wndclass.hIcon         = LoadIcon(hInstance, szAppName);
    wndclass.hCursor       = LoadCursor(NULL, IDC_ARROW);
    wndclass.hbrBackground = GetStockObject(WHITE_BRUSH);
    wndclass.lpszMenuName  = szAppName;
    wndclass.lpszClassName = szAppName;

  // Register the class

    if(!RegisterClass(&wndclass))
      return FALSE;;
  }

// Save for use by window procs

    hInst = hInstance;

// Create applications main window.

  hWnd = CreateWindow(
		  szAppName,               	   // window class name
		  szAppName,               	   // window title
		  WS_OVERLAPPEDWINDOW,     	   // type of window
		  CW_USEDEFAULT,           	   // x  window location
		  0,		           	   // y
		  GetSystemMetrics(SM_CXSCREEN)/2, // cx and size
		  GetSystemMetrics(SM_CYMENU)*8,   // cy
		  NULL,                    	   // no parent for this window
		  NULL,                    	   // use the class menu
		  hInstance,               	   // who created this window
		  NULL                     	   // no parms to pass on
	       );

// Update display of main window.

  ShowWindow(hWnd, cmdShow);
  UpdateWindow(hWnd);

// Get and dispatch messages for this applicaton.

  while (GetMessage(&msg, NULL, 0, 0))
  {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }

  return msg.wParam;
}

//*******************************************************************
// About - handle about dialog messages
//
// paramaters:
//             hDlg          - The window handle for this message
//             message       - The message number
//             wParam        - The WORD parmater for this message
//             lParam        - The LONG parmater for this message
//
//*******************************************************************
#pragma argsused

BOOL FAR PASCAL About(HWND hDlg, WORD message, WORD wParam, LONG lParam)
{
  switch(message)
  {
    case WM_INITDIALOG:
      return TRUE;

    case WM_COMMAND:
      switch (wParam)
      {
	case IDOK: EndDialog(hDlg, TRUE);
		   return TRUE;

	default:   return TRUE;
      }
  }
  return FALSE;
}

//*******************************************************************
// WndProc - handles messages for this application
//
// paramaters:
//             hWnd          - The window handle for this message
//             message       - The message number
//             wParam        - The WORD parmater for this message
//             lParam        - The LONG parmater for this message
//
// returns:
//             depends on message.
//
//*******************************************************************

long FAR PASCAL WndProc(HWND hWnd, WORD message,
			WORD wParam, LONG lParam)
{
  HDC          hDC, hMemDC;
  BITMAP       bm;
  HBITMAP      hBitmap;
  PAINTSTRUCT  ps;
  FARPROC      lpproc;        // pointer to thunk for dialog box

  switch (message)
  {
    case WM_COMMAND: // One of the menu items

	    switch (wParam)
	    {
		case IDM_START: // Start capture

		    bCapturing = TRUE;
		    bBlocking = FALSE;
		    SetCapture(hWnd);		  // grab mouse
		    SetCursor(LoadCursor(NULL, IDC_CROSS));
		    CloseWindow(hWnd);            // minimize window
		    break;

		case IDM_CLEAR: // Clear Snap window & clipboard

		    OpenClipboard(hWnd);
		    EmptyClipboard();
		    CloseClipboard();
		    InvalidateRect(hWnd, NULL, TRUE);
		    break;

		case IDM_ABOUT: // Display about box.

		    lpproc = MakeProcInstance(About, hInst);
		    DialogBox(hInst,
			      MAKEINTRESOURCE(ABOUT),
			      hWnd,
			      lpproc);
		    FreeProcInstance(lpproc);
		    break;

		case IDM_HELP: // Display help message

		    MessageBox(hWnd, "                       Using Snap\n\n"
				     "      After you click  the  Start Capture  menu\n"
				     "item,  move  the  mouse  to the  upper left\n"
				     "corner of the  area  you want to copy to the\n"
				     "clipboard. Hold down the left mouse button\n"
				     "while  you  drag  the  mouse to  the  lower\n"
				     "right corner of the area.  Once you release\n"
				     "the mouse button,  the area is  sent  to the\n"
				     "clipboard  and  shown in Snap's window.",
				     "Snap Help", MB_OK);
		    break;

		default:
		    break;
	  }
	  break;

    case WM_LBUTTONDOWN: // Start capturing

	   if(bCapturing)
	   {
	     bBlocking = TRUE;
	     oldend = beg = MAKEPOINT(lParam);
	     OutlineBlock(hWnd, beg, oldend);
	     SetCursor(LoadCursor(NULL, IDC_CROSS));
	   }
	   break;

    case WM_MOUSEMOVE: // Show area as rectangle

	   if(bBlocking)
	   {
	     end = MAKEPOINT(lParam);
	     OutlineBlock(hWnd, beg, oldend);  // erase old block
	     OutlineBlock(hWnd, beg, end);     // draw new one
	     oldend = end;
	   }
	   break;

    case WM_LBUTTONUP: // Capture & send to clipboard

	   if(bBlocking)
	   {
	     bBlocking = bCapturing = FALSE;
	     SetCursor(LoadCursor(NULL, IDC_ARROW));
	     ReleaseCapture();		       // release mouse
	     end = MAKEPOINT(lParam);
	     OutlineBlock(hWnd, beg, oldend);  // erase old block
	     xSize = abs(beg.x - end.x);
	     ySize = abs(beg.y - end.y);
	     hDC = GetDC(hWnd);
	     hMemDC = CreateCompatibleDC(hDC);
	     hBitmap = CreateCompatibleBitmap(hDC, xSize, ySize);
	     if(hBitmap)
	     {
	       SelectObject(hMemDC, hBitmap);
	       StretchBlt(hMemDC, 0, 0, xSize, ySize, hDC, beg.x, beg.y,
			  xSize, ySize, SRCCOPY);
	       OpenClipboard(hWnd);
	       EmptyClipboard();
	       SetClipboardData(CF_BITMAP, hBitmap);  // copy to clipboard
	       CloseClipboard();
	       InvalidateRect(hWnd, NULL, TRUE);      // request paint
	     }
	     else
	       MessageBeep(0);
	     DeleteDC(hMemDC);
	     ReleaseDC(hWnd, hDC);
	   }
	   ShowWindow(hWnd, SW_RESTORE);              // unminimize window
	   break;

    case WM_PAINT: // Go paint the client area of the window

	   hDC = BeginPaint(hWnd, &ps);
	   OpenClipboard(hWnd);
	   if(hBitmap = GetClipboardData(CF_BITMAP))
	   {
	     hMemDC = CreateCompatibleDC(hDC);
	     SelectObject(hMemDC, hBitmap);
	     GetObject(hBitmap, sizeof(BITMAP), (LPSTR)&bm);
	     SetStretchBltMode(hDC, COLORONCOLOR);
	     StretchBlt(hDC, 0, 0, xSize, ySize, hMemDC, 0, 0,
			bm.bmWidth, bm.bmHeight, SRCCOPY);
	     DeleteDC(hMemDC);
	   }
	   CloseClipboard();
	   EndPaint(hWnd, &ps);
	   break;

    case WM_DESTROY: // This is the end if we were closed by a
		     // DestroyWindow call.

	    PostQuitMessage(0);   // this is the end...
	    break;

    case WM_CLOSE: // Tell windows to destroy our window.

	    DestroyWindow(hWnd);
	    break;

    default: // Let windows handle all messages we choose to ignore.

	    return DefWindowProc(hWnd, message, wParam, lParam);
  }
  return 0L;
}

//*******************************************************************
// OutlineBlock - writes a rectangle on screen
//
// paramaters:
//             hWnd          - The window handle
//             beg           - Starting point
//             end           - Ending point
//
//*******************************************************************

void OutlineBlock(HWND hWnd, POINT beg, POINT end)
{
  HDC   hDC;

  hDC = CreateDC("DISPLAY", NULL, NULL, NULL);
  ClientToScreen(hWnd, &beg);
  ClientToScreen(hWnd, &end);
  SetROP2(hDC, R2_NOT);
  MoveTo(hDC, beg.x, beg.y);
  LineTo(hDC, end.x, beg.y);
  LineTo(hDC, end.x, end.y);
  LineTo(hDC, beg.x, end.y);
  LineTo(hDC, beg.x, beg.y);
  DeleteDC(hDC);
}
