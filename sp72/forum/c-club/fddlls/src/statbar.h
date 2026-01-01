//===========================================================
// Statbar.h - Include file for status bar lib file
//
// Copyright 1994 Douglas Boling
//===========================================================

#define IDD_STATBAR            10000
#define IDM_SYSMENUACTIVE      10001
#define MENUTEXT               1000


//Needed for Win 3.0 compile.
#ifndef COLOR_BTNHIGHLIGHT
#define COLOR_BTNHIGHLIGHT     4
#endif


LONG CALLBACK ClientSCProc(HWND, UINT, UINT, LONG);
LONG CALLBACK StatBarWinProc(HWND, UINT, UINT, LONG);
//
//Public procedure declarations
//
INT StatusBarInit(HANDLE);
INT StatusBarCreate (HWND, INT, INT *);
INT ModifyClientRect (HWND, RECT *);
INT SetStatusBarText (HWND, char *, INT);
INT SetStatusBarLong (HWND, char *, LONG, INT);
INT GetStatusBarHeight (void);

