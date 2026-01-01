// winapp.c

//*******************************************************************
//
// program - winapp.c
// purpose - sample Windows application.
//
//*******************************************************************

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "winapp.h"

HANDLE   hInst;
char     szAppName[] = "WinApp";

//*******************************************************************
// WinMain - WinApp main
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
		  szAppName,               // window class name
		  szAppName,               // window title
		  WS_OVERLAPPEDWINDOW,     // type of window
		  CW_USEDEFAULT,           // x  window location
		  0,                       // y
		  CW_USEDEFAULT,           // cx and size
		  0,                       // cy
		  NULL,                    // no parent for this window
		  NULL,                    // use the class menu
		  hInstance,               // who created this window
		  NULL                     // no parms to pass on
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
  PAINTSTRUCT  ps;
  HDC          hDC;
  RECT	       rect;
  FARPROC      lpproc;        // pointer to thunk for dialog box

  switch (message)
  {
    case WM_COMMAND:
	    switch (wParam)
	    {
		case IDM_NEW:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_OPEN:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_MOVE:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_COPY:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_DEL:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_PROP:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_EXIT: // Exit application

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_AUTO:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_MINI:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_CASC:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_TILE:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_MOVW:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_NDX:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_KEYB:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_SKIL: // Display message

		    MessageBox(hWnd, "  This is a sample program which\n"
				     "demonstrates how to write Windows\n"
				     "   applications with Borland C++",
				     "WinApp Help", MB_OK | MB_ICONASTERISK);
		    break;

		case IDM_COMM:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_PROC:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_GLOS:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_USIN:

		    PostMessage(hWnd, WM_CLOSE, 0, 0L);
		    break;

		case IDM_ABOUT: // Display about box.

		    lpproc = MakeProcInstance(About, hInst);
		    DialogBox(hInst,
			      MAKEINTRESOURCE(ABOUT),
			      hWnd,
			      lpproc);
		    FreeProcInstance(lpproc);
		    break;

		default:
		    break;
	  }
	  break;

    case WM_PAINT: // Go paint the client area of the window with
		   // the appropriate part of the selected file.

	   hDC = BeginPaint(hWnd, (LPPAINTSTRUCT)&ps);
	   GetClientRect(hWnd, (LPRECT)&rect);
	   DrawText(hDC, "Copyright (C) 1992 by Alex Fodchuk, Chernivtsi",
		    -1, &rect, DT_SINGLELINE | DT_CENTER | DT_VCENTER);
	   EndPaint(hWnd, (LPPAINTSTRUCT)&ps);
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
