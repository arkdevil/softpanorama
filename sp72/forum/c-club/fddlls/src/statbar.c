//===========================================================
// StatBar - A set of routines that adds a status bar to a
// client window.
// Copyright (C) 1993 Douglas Boling
//
//	To Use:
//   Include Statbar.h in source file
//
//
//
// Revision History:
//
// 1.0   Initial Release
//===========================================================
// Returns no. of elements
#define dim(x) (sizeof(x) / sizeof(x[0]))   

#include "windows.h"
#include "string.h"
#include "stdlib.h"

#define INT       int
#define UINT      WORD
#define APIENTRY  PASCAL
#define WNDPROC   FARPROC

#include "statbar.h"

#define TEXTBUFFSIZE   512

struct decodeUINT {                         // structure associates
    UINT Code;                              // messages 
    LONG (*Fxn)(HWND, UINT, UINT, LONG);    // with a function
}; 
typedef struct {
	INT sWidth;
	char far *lpszText;
} FIELDENT;
typedef struct {
	HFONT	hFont;
	INT	sHeight;
	LPSTR lpEnd;
	INT	sFreeSpace;
	INT	sNumFields;
	FIELDENT feField[1];
} STATUSBARDATA;
typedef STATUSBARDATA far * LPSTATUSBARDATA;

//-----------------------------------------------------------
// NonPublic procedure declarations
//----------------------------------------------------------
// Message handler functions for client subclass proc
LONG DoSizeClient (HWND, UINT, UINT, LONG);
LONG DoMenuSelectClient (HWND, UINT, UINT, LONG);
LONG DoDestroyClient (HWND, UINT, UINT, LONG);
// Message handler functions for status bar window proc
LONG DoSetTextStatBar (HWND, UINT, UINT, LONG);
LONG DoGetTextStatBar (HWND, UINT, UINT, LONG);
LONG DoPaintStatBar (HWND, UINT, UINT, LONG);
//LONG DoSizeStatBar (HWND, UINT, UINT, LONG);
LONG DoDestroyStatBar (HWND, UINT, UINT, LONG);
//Status bar functions
HFONT GetStatusBarFont (void);
void GetFieldRect (LPSTATUSBARDATA, INT, RECT *, RECT *);
void DrawFieldText (LPSTATUSBARDATA, HWND, LPSTR, RECT *);
void DrawSBText (HWND, char far *, INT);
void Draw3DRect (HDC, HPEN, HPEN, RECT *);

// Utility routines
WNDPROC MySubClassWindow (HWND, WNDPROC);

//-----------------------------------------------------------
// Global data
//-----------------------------------------------------------
// Message dispatch table for ClientSCProc
struct decodeUINT ClientSCMessages[] = {
	WM_SIZE, DoSizeClient,
	WM_MENUSELECT, DoMenuSelectClient,
	WM_DESTROY, DoDestroyClient,
};
// Message dispatch table for StatbarWndProc
struct decodeUINT StatBarMessages[] = {
	WM_SETTEXT, DoSetTextStatBar,
	WM_GETTEXT, DoGetTextStatBar,
	WM_PAINT, DoPaintStatBar,
	WM_DESTROY, DoDestroyStatBar,
};
extern HANDLE hInst;
FARPROC lpfnClientSCProc, lpfnOldClientWndProc;
//============================================================
// Status Bar Public functions
//============================================================
//-----------------------------------------------------------
// StatusBarInit - Initialization code for the status bar.
//-----------------------------------------------------------
INT StatusBarInit(HANDLE hInstance) {
	WNDCLASS 	wc;

	hInst = hInstance;
	//
	// Register status bar window class
	//
	wc.style = CS_HREDRAW;                    // Class style
	wc.lpfnWndProc = StatBarWinProc;          // Callback function
	wc.cbClsExtra = 0;                        // Extra class data
	wc.cbWndExtra = sizeof (HGLOBAL);         // Extra window data
	wc.hInstance = hInst;                     // Owner handle
	wc.hIcon = 0;                             // Application icon
	wc.hCursor = LoadCursor(NULL, IDC_ARROW); // Default cursor
	wc.hbrBackground = CreateSolidBrush (GetSysColor (COLOR_BTNFACE));
	wc.lpszMenuName =  0;                     // Menu name
	wc.lpszClassName = "StatusBarCls";        // Window class name
	if (RegisterClass(&wc) == 0)
		return 1;
		
		
	return 0;
}
//-----------------------------------------------------------
// StatusBarCreate - Creates a status bar window
//-----------------------------------------------------------
INT StatusBarCreate (HWND hWndClient, INT sNumFields, INT *sFieldArray) {
   INT x, y, cx, cy;
	HWND hwndStatBar;
	RECT rect;
	HGLOBAL hData;
	LPSTATUSBARDATA lpStatData;
	//
	//Alloc memory for status window info block
	//
	hData = GlobalAlloc (GHND, sizeof (STATUSBARDATA) + 
	                     sNumFields * sizeof(FIELDENT) +
	                     TEXTBUFFSIZE);
	if (!hData)
		return 11;
	lpStatData = (LPSTATUSBARDATA) GlobalLock (hData);
	//
	//Init memory block
	//
	lpStatData->sFreeSpace = TEXTBUFFSIZE; 
	lpStatData->lpEnd = (LPSTR) lpStatData + sizeof (STATUSBARDATA) + 
                       sNumFields * sizeof(FIELDENT);
	lpStatData->sNumFields = sNumFields;
	
	for (x = 0; x < sNumFields; x++) {
		lpStatData->feField[x].sWidth = sFieldArray[x];
		lpStatData->feField[x].lpszText = 0;
	}	
	//
	//Create the status bar font
	//
	lpStatData->hFont = GetStatusBarFont ();
	lpStatData->sHeight = GetStatusBarHeight ();
	//									
	// Create status bar window
	//
	GetClientRect (hWndClient, &rect);
	x = rect.left;
	y = rect.bottom - lpStatData->sHeight;
	cx = rect.right - rect.left;
	cy = lpStatData->sHeight;
	hwndStatBar = CreateWindow ("StatusBarCls", NULL, 
	                           WS_CHILD | WS_VISIBLE, x, y, cx, cy, 
	                           hWndClient, IDD_STATBAR, hInst, NULL);

	if(!hwndStatBar) {
		OutputDebugString ("Status Bar create fail\n");	
		return 0x10;
	}
	SetWindowWord (hwndStatBar, 0, hData);
	GlobalUnlock (hData);

	lpfnClientSCProc = MakeProcInstance ((FARPROC) ClientSCProc, hInst);
	lpfnOldClientWndProc = MySubClassWindow (hWndClient, lpfnClientSCProc);
	return 0;                         // return success flag
}
//------------------------------------------------------------
// GetStatusBarHeight - returns the height of the status bar
//------------------------------------------------------------
INT GetStatusBarHeight (void) {
	HDC hdc;
	HFONT hFont, hOld;
	TEXTMETRIC tm;
	//
	//Create the status bar font and compute its size
	//
	hFont = GetStatusBarFont ();
	hdc = GetDC(NULL);
	hOld = SelectObject(hdc, hFont);
	GetTextMetrics(hdc, &tm);
	SelectObject(hdc, hOld);
	DeleteObject (hFont);
	ReleaseDC(NULL, hdc);
	return tm.tmHeight + tm.tmExternalLeading + 10;
}
//------------------------------------------------------------
// ModifyClientRect - Modifies a rect structure filled with
// the client window dimentions to reflect the status bar
//------------------------------------------------------------
INT ModifyClientRect (HWND hWnd, RECT *rectOut) {
	RECT rect;
	HWND hwndStatBar;

	hwndStatBar = GetDlgItem (hWnd, IDD_STATBAR);
	if (hwndStatBar == 0)
		return 0;
	GetClientRect (hwndStatBar, &rect);
	rectOut->bottom -= (rect.bottom - rect.top);
	return 0;
}
//------------------------------------------------------------
// SetStatusBarLong - Displays a number in a status bar field
// status bar.
//------------------------------------------------------------ 
INT SetStatusBarLong (HWND hWnd, char *pszText, LONG lNum, INT sField) {
	char szTemp[256];
	
	strcpy (szTemp, pszText);
	ltoa (lNum, &szTemp[strlen(szTemp)], 10);
	return SetStatusBarText (hWnd, szTemp, sField);
}
//------------------------------------------------------------
// SetStatusBarText - Sets the texts for a field in the 
// status bar.
//------------------------------------------------------------ 
INT SetStatusBarText (HWND hWnd, char *pszText, INT sField) {
	HWND hwndStatBar;
	LPSTATUSBARDATA lpStatData;
	INT i, sLen, sSrcLen;
	LPSTR lpSrc; 
	LPSTR lpDest;
	
	hwndStatBar = GetDlgItem (hWnd, IDD_STATBAR);
	if (hwndStatBar == 0)
		return 1;

	lpStatData = (LPSTATUSBARDATA) GlobalLock (GetWindowWord (hwndStatBar, 0));
	//
	//Copy the text into the status bar global buffer
	//		
	if (lpStatData->feField[sField].lpszText != 0) {
		//
		//If field already has text, remove and collapse the buffer
		//strings over the string being removed.		
		//
		lpDest = lpStatData->feField[sField].lpszText;
		sLen = lstrlen (lpDest) + 1;
		lpSrc = lpDest + sLen;
		while (lpSrc < lpStatData->lpEnd) {
			//
			//Search array for pointer to this string
			//
			for (i = 0; i < lpStatData->sNumFields; i++)  
				if (lpSrc == lpStatData->feField[i].lpszText)
					break;
			//
			//Move string and update pointer.
			//
			lpStatData->feField[i].lpszText = lpDest;
			lstrcpy (lpDest, lpSrc);
			sSrcLen = lstrlen (lpSrc) + 1;
			lpDest += sSrcLen;
			lpSrc += sSrcLen;
		}
		lpStatData->lpEnd = lpDest;
		lpStatData->sFreeSpace += sLen;
	}		
	sLen = strlen (pszText) + 1;
	if (sLen < lpStatData->sFreeSpace) {
		lstrcpy (lpStatData->lpEnd, pszText);
		lpStatData->feField[sField].lpszText = lpStatData->lpEnd;
		lpStatData->lpEnd += sLen;
		lpStatData->sFreeSpace -= sLen;
	} else
		return 2;
	DrawSBText (hwndStatBar, pszText, sField);	
	return 0;
}
//============================================================
// Client window subclass procedures
//============================================================
//------------------------------------------------------------
// ClientSCProc - Callback subclass function for client window
//------------------------------------------------------------
LONG CALLBACK ClientSCProc(HWND hWnd, UINT wMsg, UINT wParam, 
                           LONG lParam) {
	INT i;
	//
	// Search message list to see if we need to handle this
	// message.  If in list, call procedure.
	//
	for(i = 0; i < dim(ClientSCMessages); i++) {
		if(wMsg == ClientSCMessages[i].Code)
			return (*ClientSCMessages[i].Fxn)(hWnd, wMsg, wParam, lParam);
	}
	return CallWindowProc (lpfnOldClientWndProc, hWnd, wMsg,
	                       wParam, lParam);
}
//------------------------------------------------------------
// DoSizeClient - process WM_SIZE message for client window.
//------------------------------------------------------------ 
LONG DoSizeClient (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
	
   INT x,y, cx, cy;
	RECT rect;
	LPSTATUSBARDATA lpStatData;
	HGLOBAL hData;
	HWND hwndStatBar;

	hwndStatBar = GetDlgItem (hWnd, IDD_STATBAR);
	if (hwndStatBar == 0)
		return CallWindowProc (lpfnOldClientWndProc, hWnd, wMsg,
		                       wParam, lParam);
	hData = GetWindowWord (hwndStatBar, 0);
	lpStatData = (LPSTATUSBARDATA) GlobalLock (hData);

	// Compute size of window
	GetClientRect (hWnd, &rect);
	x = rect.left;
	y = rect.bottom - lpStatData->sHeight;
	cx = rect.right - rect.left;
	cy = lpStatData->sHeight;
	SetWindowPos (hwndStatBar, NULL, x, y, cx, cy, SWP_NOZORDER);
	GlobalUnlock (hData);	

	return CallWindowProc (lpfnOldClientWndProc, hWnd, wMsg,
	                       wParam, lParam);
}
//------------------------------------------------------------
// DoMenuSelectClient - process WM_MENUSELECT message for client window.
//------------------------------------------------------------ 
LONG DoMenuSelectClient (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
	HWND hwndStatBar;
	char szText[128];
	UINT usFlags, usMenu;
	LPSTATUSBARDATA lpStatData;

	hwndStatBar = GetDlgItem (hWnd, IDD_STATBAR);
	if (hwndStatBar == 0)
		return CallWindowProc (lpfnOldClientWndProc, hWnd, wMsg,
		                       wParam, lParam);
	usFlags = LOWORD (lParam);
	usMenu = wParam;
	szText[0] = '\0';
	
	if ((usFlags & MF_SYSMENU) && (usMenu == NULL)) {
		lpStatData = (LPSTATUSBARDATA) GlobalLock (GetWindowWord (hwndStatBar, 0));
		if (lpStatData->feField[0].lpszText)
			DrawSBText (hwndStatBar, lpStatData->feField[0].lpszText, 0);
		else 	
			DrawSBText (hwndStatBar, "", 0);
		GlobalUnlock (GetWindowWord (hwndStatBar, 0));
	} else if (!(usFlags & MF_SEPARATOR)) {
		if ((usFlags & MF_SYSMENU) && (usFlags & MF_POPUP))
			LoadString (hInst, IDM_SYSMENUACTIVE, szText, sizeof (szText));
		else if (!(usFlags & MF_POPUP))
			LoadString (hInst, usMenu+MENUTEXT, szText, sizeof (szText));
			
		DrawSBText (hwndStatBar, szText, 0);
	}
	return CallWindowProc (lpfnOldClientWndProc, hWnd, wMsg,
	                       wParam, lParam);
}	
//------------------------------------------------------------
// DoDestroyClient - process WM_DESTROY message for client window.
//------------------------------------------------------------ 
LONG DoDestroyClient (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
	LONG lRC;

	DestroyWindow (GetDlgItem (hWnd, IDD_STATBAR));
	
	lRC = CallWindowProc (lpfnOldClientWndProc, hWnd, wMsg,
	                       wParam, lParam);

	MySubClassWindow (hWnd, lpfnOldClientWndProc);
	FreeProcInstance ((FARPROC) lpfnClientSCProc);
	
	return lRC;
}
//============================================================
// Status Bar Window functions
//============================================================
//------------------------------------------------------------
// StatBarWinProc - Callback function for status bar window
//------------------------------------------------------------
LONG CALLBACK StatBarWinProc(HWND hWnd, UINT wMsg, UINT wParam, 
                             LONG lParam) {
	INT i;
	//
	// Search message list to see if we need to handle this
	// message.  If in list, call procedure.
	//
	for(i = 0; i < dim(StatBarMessages); i++) {
		if(wMsg == StatBarMessages[i].Code)
			return (*StatBarMessages[i].Fxn)(hWnd, wMsg, wParam, lParam);
	}
	return DefWindowProc(hWnd, wMsg, wParam, lParam);
}
//------------------------------------------------------------
// DoSetTextStatBar - process WM_SETTEXT message for StatBar window.
// Place default text in field 0
//------------------------------------------------------------ 
LONG DoSetTextStatBar (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
	char szTemp[256];

	lstrcpyn (szTemp, (LPSTR) lParam, sizeof (szTemp) - 1);
	szTemp[255] = '\0';
	SetStatusBarText (GetParent (hWnd), szTemp, 0);
	return 0;
}
//------------------------------------------------------------
// DoGetTextStatBar - process WM_GETTEXT message for StatBar window.
// Return text from field 0
//------------------------------------------------------------ 
LONG DoGetTextStatBar (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
	LPSTATUSBARDATA lpStatData;
	UINT usLen;
	LPSTR lpSrc; 
	
	lpStatData = (LPSTATUSBARDATA) GlobalLock (GetWindowWord (hWnd, 0));
	//
	//Copy the text into the status bar global buffer
	//		
	usLen = 0;
	if (lpStatData->feField[0].lpszText != 0) {
		lpSrc = lpStatData->feField[0].lpszText;
		usLen = min ((UINT)lstrlen (lpSrc), wParam-1);
		lstrcpyn ((LPSTR) lParam, lpSrc, usLen);
		*((LPSTR)lParam+usLen) = '\0';
	}	
	GlobalUnlock (GetWindowWord (hWnd, 0));
	return usLen;
}
//------------------------------------------------------------
// DoPaintStatBar - process WM_PAINT message for StatBar window.
//------------------------------------------------------------ 
LONG DoPaintStatBar (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
	INT i;
	LPSTATUSBARDATA lpStatData;
	HDC hdc;
	PAINTSTRUCT ps;
	RECT rect, rectOut;
	HPEN hLPen, hDPen, hOldPen;

	lpStatData = (LPSTATUSBARDATA) GlobalLock (GetWindowWord (hWnd, 0));
	
	GetClientRect (hWnd, &rect);
	hdc = BeginPaint (hWnd, &ps);

	hDPen = CreatePen (PS_SOLID, 1, GetSysColor (COLOR_BTNSHADOW));
	hLPen = CreatePen (PS_SOLID, 1, GetSysColor (COLOR_BTNHIGHLIGHT));
	//
	//Draw sep line across the top of the status bar
	//	
	hOldPen = SelectObject (hdc, hDPen);
	MoveTo (hdc, rect.left, rect.top);
	LineTo (hdc, rect.right, rect.top);
	SelectObject (hdc, hLPen);
	MoveTo (hdc, rect.left, rect.top+1);
	LineTo (hdc, rect.right, rect.top+1);
	SelectObject (hdc, hOldPen);
	//
	//Draw the individual fields
	//
	for (i = 0; i < lpStatData->sNumFields; i++) {
		GetFieldRect (lpStatData, i, &rect, &rectOut);
		Draw3DRect (hdc, hDPen, hLPen, &rectOut);
		DrawFieldText (lpStatData, hWnd, lpStatData->feField[i].lpszText, 
		               &rectOut);
	}	
	DeleteObject (hDPen);
	DeleteObject (hLPen);
	EndPaint (hWnd, &ps);
	GlobalUnlock (GetWindowWord (hWnd, 0));
	return 0;
}
//------------------------------------------------------------
// DoDestroyStatBar - process WM_DESTROY message for status bar 
// window.
//------------------------------------------------------------ 
LONG DoDestroyStatBar (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
	LPSTATUSBARDATA lpStatData;

	lpStatData = (LPSTATUSBARDATA) GlobalLock (GetWindowWord (hWnd, 0));
	DeleteObject (lpStatData->hFont);			
	GlobalUnlock (GetWindowWord (hWnd, 0));
	GlobalFree (GetWindowWord (hWnd, 0));
	return DefWindowProc(hWnd, wMsg, wParam, lParam);
}
//------------------------------------------------------------
// GetStatusBarFont - returns a font handle for the status
// bar font.
//------------------------------------------------------------
HFONT GetStatusBarFont (void) {
	HDC hdc;
   INT sFHeight;
	//
	//Create the status bar font and compute its size
	//
	hdc = GetDC(NULL);
	sFHeight = MulDiv(-10, GetDeviceCaps(hdc, LOGPIXELSY), 72);
	ReleaseDC(NULL, hdc);
	return CreateFont(sFHeight, 0, 0, 0, FW_BOLD, 0, 0, 0,
	              ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
	              DEFAULT_QUALITY, VARIABLE_PITCH | FF_SWISS, "Helv");
}
//------------------------------------------------------------
// DrawFieldText - Draws text in a status bar field
//------------------------------------------------------------ 
void DrawFieldText (LPSTATUSBARDATA lpStatData, HWND hWnd, 
                    LPSTR lpszText, RECT *rect) {
	HDC hdc;
	HFONT hOldFont;
	
	rect->top += 2;
	rect->bottom -= 2;
	rect->left += 5;
	rect->right -= 5;

	hdc = GetDC (hWnd);		
	hOldFont = SelectObject (hdc, lpStatData->hFont);
	SetTextColor (hdc, GetSysColor (COLOR_BTNTEXT));
	SetBkColor (hdc, GetSysColor (COLOR_BTNFACE));
	if (lpszText)
		ExtTextOut (hdc, rect->left, rect->top, ETO_CLIPPED | ETO_OPAQUE,
		            rect, lpszText, lstrlen (lpszText), NULL);
	else					
		ExtTextOut (hdc, rect->left, rect->top, ETO_CLIPPED | ETO_OPAQUE,
		            rect, "", 0, NULL);

	SelectObject (hdc, hOldFont);
	ReleaseDC (hWnd, hdc);
	return;
}	
//------------------------------------------------------------
// GetFieldRect - Computes the rectangle for a given field.
//------------------------------------------------------------ 
void GetFieldRect (LPSTATUSBARDATA lpStatData, INT sField, 
                   RECT *rect, RECT *rectOut) {
	INT i, sRight;

	*rectOut = *rect;
	rectOut->top += 3;
	rectOut->bottom -= 3;
	rectOut->left += 3;
	rectOut->right -= 3;
	sRight = rectOut->right;
	
	for (i = 0; i < sField; i++) 
		if (lpStatData->feField[i].sWidth)
			rectOut->left += lpStatData->feField[i].sWidth + 3;
		else
			break;
			
	if (lpStatData->feField[i].sWidth == 0) {
		for (i = lpStatData->sNumFields - 1;  i > sField; i--)
			rectOut->right -= lpStatData->feField[i].sWidth + 3;
			
		if (lpStatData->feField[sField].sWidth != 0)
			rectOut->left = rectOut->right - lpStatData->feField[sField].sWidth;

	} else if (sField == lpStatData->sNumFields - 1)
		rectOut->right = sRight;
	else	
		rectOut->right = rectOut->left + lpStatData->feField[i].sWidth - 3;
		
	return;
}	
//------------------------------------------------------------
// DrawSBText - Displays text in a status bar field
//------------------------------------------------------------ 
void DrawSBText (HWND hWnd, char far *lpszText, INT sField) {
	LPSTATUSBARDATA lpStatData;
	RECT rect;

	lpStatData = (LPSTATUSBARDATA) GlobalLock (GetWindowWord (hWnd, 0));
	GetClientRect (hWnd, &rect);
	GetFieldRect (lpStatData, sField, &rect, &rect);
	DrawFieldText (lpStatData, hWnd, lpszText, &rect);
	GlobalUnlock (GetWindowWord (hWnd, 0));
	return;
}	
//------------------------------------------------------------
// Draw3DRect - Routine that draws a 3D effect rectangle
//------------------------------------------------------------ 
void Draw3DRect (HDC hdc, HPEN hDPen, HPEN hLPen, RECT *rect) {
	HPEN hOldPen;
	//Start at bottom left, draw dark pen up and over top.
	hOldPen = SelectObject (hdc, hDPen);
	MoveTo (hdc, rect->left, rect->bottom);
	LineTo (hdc, rect->left, rect->top);
	LineTo (hdc, rect->right+1, rect->top);
	//Start at bottom left, draw light pen over and up.
	SelectObject (hdc, hLPen);
	MoveTo (hdc, rect->left+1, rect->bottom);
	LineTo (hdc, rect->right, rect->bottom);
	LineTo (hdc, rect->right, rect->top);
	SelectObject (hdc, hOldPen);
}		
//============================================================  
// General Helper Routines 
//============================================================  
