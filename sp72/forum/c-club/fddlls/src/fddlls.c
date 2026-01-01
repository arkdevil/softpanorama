//===========================================================
// FDDLLS - A Program to find orphaned DLLs
// Copyright (C) 1994 Douglas Boling
//
// Revision History:
//
// 1.0   Initial Release
//
//===========================================================
// Returns no. of elements
#define dim(x) (sizeof(x) / sizeof(x[0]))   
#define BUFFSIZE    4096
#define MAXEXTS     20
#define MAXXREF     16384

#define ETYPE_COM   7
#define ETYPE_EXE   8
#define ETYPE_WIN   10
#define ETYPE_OS21  11
#define ETYPE_WINEN 12
#define ETYPE_OS22  13
#define ETYPE_WINNT 14
#define ETYPE_OS2   15

#define SHOW_BOTH   3
#define SHOW_EXES   1
#define SHOW_DLLS   2
#define SHOW_PATH   4

#define SORT_NAME   0
#define SORT_EXTS   1
#define SORT_PATH   2
#define SORT_MOD    3
#define SORT_REFS   4
//-----------------------------------------------------------
// Include flags for WINDOWS.H
//-----------------------------------------------------------
#define NOCOMM             1    Comm driver APIs and definitions
#define NOMINMAX           1    min() and max() macros
#define NOLOGERROR         1    LogError() and related definitions
#define NOPROFILER         1    Profiler APIs
#define NORESOURCE         1    Resource management
#define NOATOM             1    Atom management
#define NOLANGUAGE         1    Character test routines
#define NODBCS             1    Double-byte character set routines
#define NOGDICAPMASKS      1    GDI device capability constants
//#define NODRAWTEXT         1    DrawText() and related definitions
//#define NOTEXTMETRIC       1    TEXTMETRIC and related APIs
#define NOSCALABLEFONT     1    Truetype scalable font support
#define NOBITMAP           1    Bitmap support
#define NORASTEROPS        1    GDI Raster operation definitions
#define NOMETAFILE         1    Metafile support
#define NOSYSTEMPARAMSINFO 1    SystemParametersInfo() and SPI_#define definitions
#define NODEFERWINDOWPOS   1    DeferWindowPos and related definitions
#define NOKEYSTATES        1    MK_* message key state flags
#define NOWH               1    SetWindowsHook and related WH_* definitions
#define NOSCROLL           1    Scrolling APIs and scroll bar control
//#define NOVIRTUALKEYCODES  1    VK_* virtual key codes
//#define NOMENUS            1    Menu APIs
//#define NOKEYBOARDINFO     1    Keyboard driver routines
//#define NOCOLOR            1    COLOR_#define color values
//#define NOGDIOBJ           1    GDI pens, brushes, fonts
//#define NOMSG              1    APIs and definitions that use MSG structure
//#define NOWINSTYLES        1    Window style definitions

//-----------------------------------------------------------
// Include files
//-----------------------------------------------------------
#include "windows.h"
#include "dos.h"
#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "direct.h"
#include "ctype.h"

#include "FDDLLS.h"
#include "statbar.h"
//-----------------------------------------------------------
// Global data
//-----------------------------------------------------------
// Message dispatch table for MainWindowProc
struct decodeUINT MainMessages[] = {
	WM_CREATE, DoCreateMain,
	WM_DRAWITEM, DoDrawItemMain,
	WM_MEASUREITEM, DoMeasureItemMain,
	WM_COMPAREITEM, DoCompareItemMain,
	WM_INITMENU, DoInitMenuMain,
	WM_SETFOCUS, DoSetFocusMain,
	WM_SIZE, DoSizeMain,
	WM_PAINT, DoPaintMain,
	MYMSG_SCAN, DoMyMsgScanMain,
	WM_COMMAND, DoCommandMain,
	WM_CLOSE, DoCloseMain,
	WM_DESTROY, DoDestroyMain,
};
// Command Message dispatch for MainWindowProc
struct decodeCMD MainMenuItems[] = {
	IDD_FLIST, DoMainCtlFList,
	IDM_SCAN, DoMainMenuScan,
	IDM_SELDISKS, DoMainMenuSelDisks,
	IDM_STOP, DoMainMenuStop,
	IDM_OPEN, DoMainMenuOpen,
	IDM_EXIT, DoMainMenuExit,
	IDM_SHOWBOTH, DoMainMenuShow,
	IDM_SHOWEXES, DoMainMenuShow,
	IDM_SHOWDLLS, DoMainMenuShow,
	IDM_SHOWPATH, DoMainMenuShowPath,
	IDM_SORTNAME, DoMainMenuSort,
	IDM_SORTEXTS, DoMainMenuSort,
	IDM_SORTPATH, DoMainMenuSort,
	IDM_SORTMOD, DoMainMenuSort,
	IDM_SORTREFS, DoMainMenuSort,
	IDM_ABOUT, DoMainMenuAbout,
};
HANDLE	hInst;
HWND		hMain;
UINT		wVersion = 9;
BOOL		fFirst = TRUE;

char	szAppName[] = "WinFDDLLS";         // Application name
char	szTitleText[] = "FDDLLS";          // Application window title
char	szMenuName[] = "WinFDDLLSMenu";    // Menu name
char	szIconName[] = "WinFDDLLSIcon";    // Icon name
char	szProfileName[] = "FDDLLS.ini";    // INI file name

INT sLItemHeight;
INT fViewFlags = 0x0f;	
INT sSortParam = 0;
//
// Global pointers used in recursive directory scan
//
BOOL fDupScan, fSearching = FALSE;
char szSearchDir[MAXFNAMELEN] = "";
char szStatText[80] = "";
char *pszStatEnd;
char szProgExts[MAXEXTS][4] = {"EXE", "DLL"};
INT sNumProgExts = 2;
//
// Directory entry block items
//
LPMYDIRENTRY lpDirEntry;
LPBUFFHDR lpCurrBuff;
BUFFHDR Buff = {0,0,0};

HGLOBAL hDirSeg = 0;
LPUINT lpDirBasePtr;
INT sDirSegCnt = 0;

HGLOBAL hChildSeg = 0;
DWORD huge *lpChildPtr;
LONG lChildCnt;

HGLOBAL hLostSeg = 0;
LPSTR lpLostPtr;
LONG sLostIndex;

HGLOBAL hMasterSeg = 0;
LPLPMYDIRENTRY lpMasterPtr;
INT sMasterCount = 0;
INT sListCount = 0;
INT sProgress, sOldProgress;

#define NUMSTDLIBS  7
char *szStdLibs[NUMSTDLIBS] = {"KERNEL","DISPLAY","KEYBOARD","MOUSE",
                               "USER","GDI","SYSTEM"};
INT sStdLibPtrs[NUMSTDLIBS];
INT sInfoDlgDepth = 0;
//
// Temp buffer used by many routines
//
char szTemp[256];

INT sDrives[26];
INT sDrvCnt;
//============================================================
// WinMain -- entry point for this application from Windows.
//============================================================
INT APIENTRY WinMain(HANDLE hInstance, HANDLE hPrevInstance, 
                     LPSTR lpCmdLine, INT nCmdShow) {
	MSG	msg;
	INT	rc;
	HANDLE hAccel;

	hInst = hInstance;
	//
	// If first instance, perform any init processing
	//
   if(!hPrevInstance)
		if((rc = InitApp(hInstance)) != 0)
			return rc;
	//
	// Initialize this instance
	//
	if((rc = InitInstance(hInstance, lpCmdLine, nCmdShow)) != 0)
		return rc;
	//
	// Application message loop
	//
	hAccel = LoadAccelerators (hInstance, szAppName);
	while (GetMessage (&msg, NULL, 0, 0)) {
		if (!TranslateAccelerator (hMain, hAccel, &msg)) {
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}	
	}
	fSearching = FALSE;
	// Instance cleanup
	return TermInstance(hInstance, msg.wParam);
}
//-----------------------------------------------------------
// InitApp - Global initialization code for this application.
//-----------------------------------------------------------
INT InitApp(HANDLE hInstance) {
	WNDCLASS 	wc;
	//
	// Register App Main Window class
	//		
	wc.style = CS_HREDRAW | CS_VREDRAW;       // Window style
	wc.lpfnWndProc = MainWndProc;             // Callback function
	wc.cbClsExtra = 0;                        // Extra class data
	wc.cbWndExtra = 0;                        // Extra window data
	wc.hInstance = hInstance;                 // Owner handle
	wc.hIcon = LoadIcon(hInst, szIconName);   // Application icon
	wc.hCursor = LoadCursor(NULL, IDC_ARROW); // Default cursor
	wc.hbrBackground = COLOR_WINDOW + 1;
	wc.lpszMenuName =  szMenuName;            // Menu name
	wc.lpszClassName = szAppName;             // Window class name
	if (RegisterClass(&wc) == 0)
		return 1;
	
	StatusBarInit (hInstance);
	return 0;
}
//-----------------------------------------------------------
// InitInstance - Instance initialization code for this app.
//-----------------------------------------------------------
INT InitInstance(HANDLE hInstance, LPSTR lpCmdLine, INT nCmdShow) {
   INT x, y, cx, cy;
	HDC hdc;
	TEXTMETRIC tm;
	INT sField[4];
	RECT rect;
	//
	//Determine the size of the system font to set the sizes of the
	//window controls.
	//
	hdc = GetDC (NULL);
	SelectObject (hdc, GetStockObject (SYSTEM_FONT));
	GetTextMetrics (hdc, &tm);
	sLItemHeight = tm.tmHeight + tm.tmExternalLeading;
	ReleaseDC (NULL, hdc);
	//Read INI file info
	GetWindowRect (GetDesktopWindow(), &rect);
	x = (rect.right - rect.left)/8;
	y = (rect.bottom - rect.top)/8;
	cx = x * 6;
	cy = y * 6;
	x = GetPrivateProfileInt (szAppName, PRO_XPOS, x, szProfileName);
	y = GetPrivateProfileInt (szAppName, PRO_YPOS, y, szProfileName);
	cx = GetPrivateProfileInt (szAppName, PRO_XSIZE, cx, szProfileName);
	cy = GetPrivateProfileInt (szAppName, PRO_YSIZE, cy, szProfileName);

	//Check all drives to determine which are fixed.
	sDrvCnt = 0;
	for (x = 0; x < 26; x++) {
		y = GetDriveType (x);
		if (y == DRIVE_FIXED)
			sDrives[sDrvCnt++] = x + 'A';
	}
	//Load Programs key from WIN.INI to determine executable extensions
	GetProfileString ("windows", "Programs", "EXE ", szStatText,
	                  sizeof (szStatText));
	strupr (szStatText);
	pszStatEnd = szStatText;
	for (x = 0; (x < MAXEXTS) && (*pszStatEnd != '\0'); x++) {
		while (*pszStatEnd == ' ')
			pszStatEnd++;
		for (y = 0; (y < sizeof (szProgExts[x]) - 1) && 
		            (*pszStatEnd != ' ') && 
		            (*pszStatEnd != '\0'); y++)
			szProgExts[x][y] = *pszStatEnd++;
		szProgExts[x][y] = '\0';
		//Don't allow BAT, COM or PIF extensions
		if ((strcmp (szProgExts[x], "BAT") == 0) ||
		    (strcmp (szProgExts[x], "COM") == 0) ||
		    (strcmp (szProgExts[x], "PIF") == 0))
			 x--;
	}
   strcpy (szProgExts[x++], "DLL");
   strcpy (szProgExts[x++], "DRV");
	sNumProgExts = x;
	// Create main window
	hMain = CreateWindow (szAppName, szTitleText, WS_OVERLAPPEDWINDOW,
	                      x, y, cx, cy, NULL, NULL, hInstance, NULL);
	if(!hMain) return 0x10;

	//Create status bar
	sField[0] = 0;
	sField[1] = 195;
	x = StatusBarCreate (hMain, 2, sField);
	if (x) return x;
	ShowWindow(hMain, nCmdShow | SW_SHOW);
	UpdateWindow(hMain);              // force WM_PAINT message
	return 0;                         // return success flag
}
//------------------------------------------------------------
// TermInstance - Instance termination code for this app.
//------------------------------------------------------------
INT TermInstance(HANDLE hinstance, int sDefRC) {

	//Free old buffers	
	FreeBuffer (Buff.selNext);
	if (hMasterSeg) {
	 	GlobalUnlock (hMasterSeg);
	 	GlobalFree (hMasterSeg);
	}		
	if (hChildSeg) {
		GlobalUnlock (hChildSeg);
		GlobalFree (hChildSeg);
	}	
	if (hLostSeg) {
		GlobalUnlock (hLostSeg);
		GlobalFree (hLostSeg);
	}	
	return sDefRC;
}
//============================================================
// Message handling procedures for MainWindow
//============================================================
//------------------------------------------------------------
// MainWndProc - Callback function for application window
//------------------------------------------------------------
LONG CALLBACK MainWndProc(HWND hWnd, UINT wMsg, UINT wParam, 
                          LONG lParam) {
	INT i;
	//
	// Search message list to see if we need to handle this
	// message.  If in list, call procedure.
	//
	for(i = 0; i < dim(MainMessages); i++) {
		if(wMsg == MainMessages[i].Code)
			return (*MainMessages[i].Fxn)(hWnd, wMsg, wParam, lParam);
	}
	return DefWindowProc(hWnd, wMsg, wParam, lParam);
}
//------------------------------------------------------------
// DoCreateMain - process WM_CREATE message for frame window.
//------------------------------------------------------------ 
LONG DoCreateMain (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
   RECT rect;

	GetClientRect (hWnd, &rect);
	ModifyClientRect (hWnd, &rect);
	CreateWindow ("listbox", NULL, WS_CHILD | WS_VISIBLE | 
	              LBS_NOTIFY | LBS_OWNERDRAWFIXED | WS_VSCROLL | LBS_SORT,
	              rect.left, rect.top + sLItemHeight, 
	              rect.right, rect.bottom - sLItemHeight, 
	              hWnd, IDD_FLIST, hInst, NULL);
	return 0;
}
//------------------------------------------------------------
// DoSizeMain - process WM_SIZE message for frame window.
//------------------------------------------------------------ 
LONG DoSizeMain (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
   RECT rect;

	if (wParam != SIZE_MINIMIZED) {
		GetClientRect (hWnd, &rect);
		ModifyClientRect (hWnd, &rect);
		SetWindowPos (GetDlgItem (hWnd, IDD_FLIST), NULL, rect.left, 
		              rect.top + sLItemHeight, rect.right, 
		              rect.bottom - sLItemHeight, SWP_NOZORDER);

		FillLB (hWnd);
		DisplayCurrStatus (hWnd);
		if (fFirst) {
			fFirst = FALSE;
			PostMessage (hWnd, WM_COMMAND, IDM_SCAN, 0);
		}
	}	
	return 0;
}
//------------------------------------------------------------
// DoPaintMain - process WM_PAINT message for frame window.
//------------------------------------------------------------ 
LONG DoPaintMain (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
	PAINTSTRUCT ps;
	HDC hdc;
	INT sWidth;
   RECT rect;
	HPEN hPen, hOldPen;
	char szOut[64];
	
	hdc = BeginPaint (hWnd, &ps);
	
	GetClientRect (hWnd, &rect);
	sWidth = rect.right;
	SetTextColor (hdc, GetSysColor (COLOR_WINDOWTEXT));
	SetBkColor (hdc, GetSysColor (COLOR_WINDOW));
	rect.left = 0;
	rect.top = 0;
	rect.right = 0;
	rect.bottom = sLItemHeight;

	strcpy (szOut, "Filename");
	rect.right += 135;
	DrawText (hdc, szOut, -1, &rect, DT_LEFT | DT_SINGLELINE); 
	
	rect.left = rect.right;
	rect.right += 100;
	DrawText (hdc, "File Type", -1, &rect, DT_LEFT | DT_SINGLELINE);

	rect.left = rect.right;
	rect.right += 150;
	DrawText (hdc, "Reference Count", -1, &rect,DT_LEFT | DT_SINGLELINE); 

//	if (fViewFlags & SHOW_SIZE) {
		strcpy (szOut, "Size");
		rect.left = rect.right;
		rect.right += 100;
		DrawText (hdc, szOut, -1, &rect, DT_LEFT | DT_SINGLELINE); 
//	} 
		
	if (fViewFlags & SHOW_PATH) {
		strcpy (szOut, "Path");
		rect.left = rect.right;
		rect.right += 100;
		DrawText (hdc, szOut, -1, &rect, DT_LEFT | DT_SINGLELINE); 
	} 

	//Draw underscore
	hPen = CreatePen (PS_SOLID, 1, RGB (0, 0, 0));
	hOldPen = SelectObject (hdc, hPen);
	MoveTo (hdc, 0, rect.bottom-1);
	LineTo (hdc, sWidth, rect.bottom-1);
	SelectObject (hdc, hOldPen);
	DeleteObject (hPen);
	
	EndPaint (hWnd, &ps);
	return 0;
}
//------------------------------------------------------------
// DoSetFocusMain - process WM_SETFOCUS message for frame window.
//------------------------------------------------------------ 
LONG DoSetFocusMain (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {

	SetFocus (GetDlgItem (hWnd, IDD_FLIST));
	return 0;
}
//------------------------------------------------------------
// DoMeasureItemMain - process WM_MEASUREITEM message for frame window.
//------------------------------------------------------------ 
LONG DoMeasureItemMain (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {

	((LPMEASUREITEMSTRUCT) lParam)->itemHeight = sLItemHeight;
	return 0;
}
//------------------------------------------------------------
// DoCompareItemMain - process WM_COMPAREITEM message for frame window.
//------------------------------------------------------------ 
LONG DoCompareItemMain (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
	LPCOMPAREITEMSTRUCT lpCmpItem;
	LPMYDIRENTRY lpEntry1;
	LPMYDIRENTRY lpEntry2;
	char szName1[MAXFNAMELEN], szName2[MAXFNAMELEN];
	char *pszExt1, *pszExt2;
	LONG lUseCnt;
	
	if (fSearching)
		return 0;
	if (hMasterSeg == 0)
		return 0;
	lpCmpItem = (LPCOMPAREITEMSTRUCT) lParam;
	if (((UINT)lpCmpItem->itemData1 > (UINT)sMasterCount) ||
	    ((UINT)lpCmpItem->itemData2 > (UINT)sMasterCount))
		return 0;

	lpEntry1 = *(lpMasterPtr + (UINT)lpCmpItem->itemData1);
	lpEntry2 = *(lpMasterPtr + (UINT)lpCmpItem->itemData2);

	switch (sSortParam) {
		case SORT_NAME:
			lUseCnt = lstrcmp (lpEntry1->szName, lpEntry2->szName);
			if (lUseCnt)
				return lUseCnt;
			lUseCnt = lpEntry1->lSize - lpEntry2->lSize;
			if (lUseCnt > 0)
				return -1;
			if (lUseCnt < 0)
				return 1;
			return 0;
			
		case SORT_MOD:
			return lstrcmp (lpEntry1->szModName, lpEntry2->szModName);
			
		case SORT_EXTS:
			lstrcpy (szName1, lpEntry1->szName);
			lstrcpy (szName2, lpEntry2->szName);
			pszExt1 = strchr (szName1, '.');
			pszExt2 = strchr (szName2, '.');
			if (pszExt1 && pszExt2)
				return strcmp (pszExt1, pszExt2);
			else if (pszExt1)				
				return -1;
			else if (pszExt2)				
				return 1;
			else	
				return strcmp (szName1, szName2);
				
		case SORT_PATH:
			CreatePath (lpEntry1, szName1, sizeof (szName1));
			CreatePath (lpEntry2, szName2, sizeof (szName2));
			return strcmp (szName1, szName2);
				
		case SORT_REFS:		
			lUseCnt = lpEntry1->lUseCnt - lpEntry2->lUseCnt;
			if (lUseCnt > 0)
				return -1;
			if (lUseCnt < 0)
				return 1;
			else	
				return lstrcmp (lpEntry1->szName, lpEntry2->szName);
	}			
	return 0;
}
//------------------------------------------------------------
// OutputDebugLong - Write a number to the debug console
//------------------------------------------------------------
void OutputDebugLong (LONG lNum) {
   char szStr[34];

	ltoa (lNum, szStr, 16);
	OutputDebugString (szStr);
	return;
}				               
//------------------------------------------------------------
// DoDrawItemMain - process WM_DRAWITEM message for frame 
// window.  This routine handles drawing of the list box
// items.
//------------------------------------------------------------ 
LONG DoDrawItemMain (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
	LPDRAWITEMSTRUCT lpdiPtr;
	LPMYDIRENTRY lpDrawEnt;
	LPLPMYDIRENTRY lpIndexPtr;
	char szOut[256], szTemp[33];
	char *pszOut;
	RECT rectOut;
	HANDLE hBrush;
	INT i, sNumLen;
	HPEN hPen, hOldPen;
	
	if (fSearching)
		return FALSE;

	if (hMasterSeg == 0)
		return 0;
		
	lpdiPtr = (LPDRAWITEMSTRUCT) lParam;
	if ((UINT)lpdiPtr->itemData > (UINT)sMasterCount)
		return 0;

	if (lpdiPtr->itemState & ODS_SELECTED) {
		SetTextColor (lpdiPtr->hDC, GetSysColor (COLOR_HIGHLIGHTTEXT));
		SetBkColor (lpdiPtr->hDC, GetSysColor (COLOR_HIGHLIGHT));
		hBrush = CreateSolidBrush (GetSysColor (COLOR_HIGHLIGHT));
	} else {	
		SetTextColor (lpdiPtr->hDC, GetSysColor (COLOR_WINDOWTEXT));
		SetBkColor (lpdiPtr->hDC, GetSysColor (COLOR_WINDOW));
		hBrush = CreateSolidBrush (GetSysColor (COLOR_WINDOW));
	}
	rectOut = lpdiPtr->rcItem;
	FillRect (lpdiPtr->hDC, &rectOut, hBrush);
	DeleteObject (hBrush);
	rectOut.right = lpdiPtr->rcItem.left;
	rectOut.bottom = lpdiPtr->rcItem.bottom;

	lpIndexPtr = lpMasterPtr;

	lpIndexPtr += (INT)lpdiPtr->itemData;
	lpDrawEnt = *lpIndexPtr;
	// If program missing a dll reference, highlight with red text
	if (lpDrawEnt->usBadCnt)
		SetTextColor (lpdiPtr->hDC, RGB (255, 0, 0));
	// If program is a dup, highlight with green text
	else if (lpDrawEnt->ucAttrib & ATTR_DUP)
		SetTextColor (lpdiPtr->hDC, RGB (255, 255, 0));

	// Display file name 
	lstrcpy (szOut, lpDrawEnt->szName);
	rectOut.right += 145;
	DrawText (lpdiPtr->hDC, szOut, -1, &rectOut, DT_LEFT | DT_SINGLELINE); 
	
	// Display file type
	if (lpDrawEnt->sType > 0x100)
		strcpy (szOut, "DLL ");
	else
		strcpy (szOut, "Program ");

	rectOut.left = rectOut.right;
	rectOut.right += 100;
	DrawText (lpdiPtr->hDC, szOut, -1, &rectOut,	DT_LEFT | DT_SINGLELINE);

	// Display file reference count
	ltoa (lpDrawEnt->lUseCnt, szTemp, 10);
	sNumLen = strlen (szTemp);
	pszOut = szOut;
	for (i = 0; i < sNumLen; i++) {
		if ((sNumLen - i) % 3 == 0 && i != 0)
			*pszOut++ = ',';
		*pszOut++ = szTemp[i];
	}
	*pszOut = '\0';
	rectOut.left = rectOut.right;
	rectOut.right += 50;
	DrawText (lpdiPtr->hDC, szOut, -1, &rectOut,	DT_RIGHT | DT_SINGLELINE); 
	rectOut.right += 30;

	// Display file size
//	if (fViewFlags & SHOW_SIZE) {
		ltoa (lpDrawEnt->lSize, szTemp, 10);
		sNumLen = strlen (szTemp);
		pszOut = szOut;
		for (i = 0; i < sNumLen; i++) {
			if ((sNumLen - i) % 3 == 0 && i != 0)
				*pszOut++ = ',';
			*pszOut++ = szTemp[i];
		}
		*pszOut = '\0';
		rectOut.left = rectOut.right;
		rectOut.right += 90;
		DrawText (lpdiPtr->hDC, szOut, -1, &rectOut,	DT_RIGHT | DT_SINGLELINE); 
		rectOut.right += 15;
//	}	

	// Display path
	if (fViewFlags & SHOW_PATH) {
		if (lpDrawEnt->lpParent) {
			CreatePath (lpDrawEnt, szOut, sizeof (szOut));
		} else {
			lstrcpy (szOut, lpDrawEnt->szName);
		}					
		rectOut.left = rectOut.right + 50;
		rectOut.right += 500;
		DrawText (lpdiPtr->hDC, szOut, -1, &rectOut, DT_LEFT | DT_SINGLELINE); 
	}		

	if (lpdiPtr->itemState & ODS_FOCUS) {
		if (lpdiPtr->itemState & ODS_SELECTED)
			hPen = CreatePen (PS_DOT, 1, GetSysColor (COLOR_HIGHLIGHTTEXT));
		else	
			hPen = CreatePen (PS_DOT, 1, GetSysColor (COLOR_WINDOWTEXT));
		hOldPen = SelectObject (lpdiPtr->hDC, hPen);
		MoveTo (lpdiPtr->hDC, lpdiPtr->rcItem.left, lpdiPtr->rcItem.bottom-1);
		LineTo (lpdiPtr->hDC, lpdiPtr->rcItem.left, lpdiPtr->rcItem.top);
		LineTo (lpdiPtr->hDC, lpdiPtr->rcItem.right-1, lpdiPtr->rcItem.top);
		LineTo (lpdiPtr->hDC, lpdiPtr->rcItem.right-1, lpdiPtr->rcItem.bottom-1);
		LineTo (lpdiPtr->hDC, lpdiPtr->rcItem.left, lpdiPtr->rcItem.bottom-1);
		SelectObject (lpdiPtr->hDC, hOldPen);
		DeleteObject (hPen);
	}	
	return 0;
}
//------------------------------------------------------------
// DoInitMenuMain - process WM_INITMENU message for frame window.
//------------------------------------------------------------
LONG DoInitMenuMain (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
	HMENU hMenu;

	hMenu = GetMenu (hWnd);
/*
	if (fViewFlags & SHOW_PATH) 
		CheckMenuItem (hMenu, IDM_SHOWPATH, MF_BYCOMMAND | MF_CHECKED);
	else	
		CheckMenuItem (hMenu, IDM_SHOWPATH, MF_BYCOMMAND | MF_UNCHECKED);
*/
	CheckMenuItem (hMenu, IDM_SHOWBOTH, MF_BYCOMMAND | MF_UNCHECKED);
	CheckMenuItem (hMenu, IDM_SHOWEXES, MF_BYCOMMAND | MF_UNCHECKED);
	CheckMenuItem (hMenu, IDM_SHOWDLLS, MF_BYCOMMAND | MF_UNCHECKED);
	switch (fViewFlags & 0x03) {
		case SHOW_BOTH:
			CheckMenuItem (hMenu, IDM_SHOWBOTH, MF_BYCOMMAND | MF_CHECKED);
			break;

		case SHOW_EXES:
			CheckMenuItem (hMenu, IDM_SHOWEXES, MF_BYCOMMAND | MF_CHECKED);
			break;

		case SHOW_DLLS:
			CheckMenuItem (hMenu, IDM_SHOWDLLS, MF_BYCOMMAND | MF_CHECKED);
			break;
	}
	CheckMenuItem (hMenu, IDM_SORTNAME, MF_BYCOMMAND | MF_UNCHECKED);
	CheckMenuItem (hMenu, IDM_SORTEXTS, MF_BYCOMMAND | MF_UNCHECKED);
	CheckMenuItem (hMenu, IDM_SORTPATH, MF_BYCOMMAND | MF_UNCHECKED);
	CheckMenuItem (hMenu, IDM_SORTMOD, MF_BYCOMMAND | MF_UNCHECKED);
	CheckMenuItem (hMenu, IDM_SORTREFS, MF_BYCOMMAND | MF_UNCHECKED);
	CheckMenuItem (hMenu, IDM_SORTNAME + sSortParam, 
	               MF_BYCOMMAND | MF_CHECKED);
	//
	// If searching, disable most menus
	//
	if (fSearching) {
		EnableMenuItem (hMenu, IDM_SHOWEXES, MF_BYCOMMAND | MF_GRAYED);
		EnableMenuItem (hMenu, IDM_SHOWDLLS, MF_BYCOMMAND | MF_GRAYED);
		EnableMenuItem (hMenu, IDM_SHOWPATH, MF_BYCOMMAND | MF_GRAYED);
		EnableMenuItem (hMenu, IDM_SORTNAME, MF_BYCOMMAND | MF_GRAYED);
		EnableMenuItem (hMenu, IDM_SORTEXTS, MF_BYCOMMAND | MF_GRAYED);
		EnableMenuItem (hMenu, IDM_SORTPATH, MF_BYCOMMAND | MF_GRAYED);
		EnableMenuItem (hMenu, IDM_SORTMOD, MF_BYCOMMAND | MF_GRAYED);
		EnableMenuItem (hMenu, IDM_SORTREFS, MF_BYCOMMAND | MF_GRAYED);
		EnableMenuItem (hMenu, IDM_SELDISKS, MF_BYCOMMAND | MF_GRAYED);
		EnableMenuItem (hMenu, IDM_OPEN, MF_BYCOMMAND | MF_GRAYED);
	} else {
		EnableMenuItem (hMenu, IDM_SHOWEXES, MF_BYCOMMAND | MF_ENABLED);
		EnableMenuItem (hMenu, IDM_SHOWDLLS, MF_BYCOMMAND | MF_ENABLED);
		EnableMenuItem (hMenu, IDM_SHOWPATH, MF_BYCOMMAND | MF_ENABLED);
		EnableMenuItem (hMenu, IDM_SORTNAME, MF_BYCOMMAND | MF_ENABLED);
		EnableMenuItem (hMenu, IDM_SORTEXTS, MF_BYCOMMAND | MF_ENABLED);
		EnableMenuItem (hMenu, IDM_SORTPATH, MF_BYCOMMAND | MF_ENABLED);
		EnableMenuItem (hMenu, IDM_SORTMOD, MF_BYCOMMAND | MF_ENABLED);
		EnableMenuItem (hMenu, IDM_SORTREFS, MF_BYCOMMAND | MF_ENABLED);
		EnableMenuItem (hMenu, IDM_SELDISKS, MF_BYCOMMAND | MF_ENABLED);
		if (SendDlgItemMessage (hWnd, IDD_FLIST, LB_GETCURSEL, 0, 0) != LB_ERR)
			EnableMenuItem (hMenu, IDM_OPEN, MF_BYCOMMAND | MF_ENABLED);
		else	
			EnableMenuItem (hMenu, IDM_OPEN, MF_BYCOMMAND | MF_GRAYED);
	}	
	return 0;
}
//------------------------------------------------------------
// DoMyMsgScanMain - Process MYMSG_SCAN message
//------------------------------------------------------------ 
LONG DoMyMsgScanMain (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
	INT rc;
	HMENU hMenu;

	hMenu = GetMenu (hWnd);
	ModifyMenu (hMenu, IDM_SCAN, MF_STRING, IDM_STOP, "&Stop");
	fSearching = TRUE;
	rc = ScanMachine (hWnd, sDrvCnt, sDrives);
	if (!rc)
		rc = CheckAllFiles (hWnd);
	if (rc) {
		PrintError (hWnd, rc);
		sMasterCount = 0;
	}	
	fSearching = FALSE;
	fDupScan = FALSE;
	MyYield();
	FillLB (hWnd);
	DisplayCurrStatus (hWnd);
	ModifyMenu (hMenu, IDM_STOP, MF_STRING, IDM_SCAN, "&Scan Disks");
	return 0;
}
//------------------------------------------------------------
// DoCommandMain - process WM_COMMAND message for frame window 
// by decoding the menubar item with the menuitems[] array, 
// then running the corresponding function to process the command.
//------------------------------------------------------------ 
LONG DoCommandMain (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
	INT	i;
	UINT	idItem, wNotifyCode;
	HWND	hwndCtl;

	idItem = (UINT) wParam;                      // Parse Parameters
	hwndCtl = (HWND) LOWORD(lParam);
	wNotifyCode = (UINT) HIWORD(lParam);
	//
	// Call routine to handle control message
	//
	for(i = 0; i < dim(MainMenuItems); i++) {
		if(idItem == MainMenuItems[i].Code)
			return (*MainMenuItems[i].Fxn)(hWnd, idItem, hwndCtl, 
			                               wNotifyCode);
	}
	return DefWindowProc(hWnd, wMsg, wParam, lParam);
}
//------------------------------------------------------------
// DoCloseMain - process WM_CLOSE message for frame window.
//------------------------------------------------------------ 
LONG DoCloseMain (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
	fSearching = FALSE;
	DestroyWindow (hMain);
	return 0;
}
//------------------------------------------------------------
// DoDestroyMain - process WM_DESTROY message for frame window.
//------------------------------------------------------------ 
LONG DoDestroyMain (HWND hWnd, UINT wMsg, UINT wParam, LONG lParam) {
   RECT	rect;

	fSearching = FALSE;
	//Save Window position
	if	(!IsIconic (hWnd) && !IsZoomed (hWnd)) {
		GetWindowRect (hWnd, &rect);
		MyWritePrivateProfileInt (szAppName, PRO_XPOS, rect.left,
		                          10, szProfileName);
		MyWritePrivateProfileInt (szAppName, PRO_YPOS, rect.top,
		                          10, szProfileName);
		MyWritePrivateProfileInt (szAppName, PRO_XSIZE, rect.right - rect.left,
		                          10, szProfileName);
		MyWritePrivateProfileInt (szAppName, PRO_YSIZE, rect.bottom - rect.top,
		                          10, szProfileName);
	}
	PostQuitMessage (0);
	return DefWindowProc(hWnd, wMsg, wParam, lParam);
}
//============================================================
// Control handling procedures for MainWindow
//============================================================
//------------------------------------------------------------
// DoMainCtlFList - Handle messages from Main Window listbox
//------------------------------------------------------------ 
LONG DoMainCtlFList (HWND hWnd, UINT idItem, HWND hwndCtl, 
                     UINT wNotifyCode) {

	if (wNotifyCode != LBN_DBLCLK)
		return 0;
	PostMessage (hWnd, WM_COMMAND, IDM_OPEN, 0);
	return 0;
}
//------------------------------------------------------------
// DoMainMenuScan - Process Scan menu item
//------------------------------------------------------------ 
LONG DoMainMenuScan (HWND hWnd, UINT idItem, HWND hwndCtl, 
                     UINT wNotifyCode) {

	if (MyDisplayDialog(hInst, "Scan", hWnd, 
   	             (WNDPROC) ScanDlgProc, 0)) 
		PostMessage (hWnd, MYMSG_SCAN, 0, 0);
	return 0;
}
//------------------------------------------------------------
// DoMainMenuSelDisks - Process SelDisks menu item
//------------------------------------------------------------ 
LONG DoMainMenuSelDisks (HWND hWnd, UINT idItem, HWND hwndCtl, 
                         UINT wNotifyCode) {

	if (MyDisplayDialog(hInst, "SelDisks", hWnd, 
   	             (WNDPROC) SelDisksDlgProc, 0)) 
		PostMessage (hWnd, MYMSG_SCAN, 0, 0);
	return 0;
}
//------------------------------------------------------------
// DoMainMenuStop - Process Stop menu item
//------------------------------------------------------------ 
LONG DoMainMenuStop (HWND hWnd, UINT idItem, HWND hwndCtl, 
                     UINT wNotifyCode) {
	INT rc;

	rc = MessageBox (hWnd, "Do you want to stop scanning the disks?",
	                 szAppName, MB_YESNO);
	if (rc == IDYES) 
		fSearching = FALSE;						  
	return 0;
}
//------------------------------------------------------------
// DoMainMenuOpen - Process Open menu item
//------------------------------------------------------------ 
LONG DoMainMenuOpen (HWND hWnd, UINT idItem, HWND hwndCtl, 
                     UINT wNotifyCode) {
	INT sIndex;
	LONG lData;

	sIndex = (INT) SendDlgItemMessage (hWnd, IDD_FLIST, LB_GETCURSEL, 0, 0);
	if (sIndex == LB_ERR)
		return 0;
	lData = SendDlgItemMessage (hWnd, IDD_FLIST, LB_GETITEMDATA, sIndex, 0);
	MyDisplayDialog(hInst, "FileInfo", hWnd, (WNDPROC) FileInfoDlgProc, lData); 
	return 0;
}
//------------------------------------------------------------
// DoMainMenuExit - Process Exit menu item
//------------------------------------------------------------ 
LONG DoMainMenuExit (HWND hWnd, UINT idItem, HWND hwndCtl, 
                     UINT wNotifyCode) {

	SendMessage (hWnd, WM_CLOSE, 0, 0);
	return 0;
}
//------------------------------------------------------------
// DoMainMenuShow - Process Show Both/EXEs/DLLs menu items
//------------------------------------------------------------ 
LONG DoMainMenuShow (HWND hWnd, UINT idItem, HWND hwndCtl, 
                     UINT wNotifyCode) {
	switch (idItem) {
		case IDM_SHOWBOTH:
			fViewFlags |= SHOW_EXES | SHOW_DLLS;
			break;
			
		case IDM_SHOWEXES:
			fViewFlags |= SHOW_EXES;
			fViewFlags &= ~SHOW_DLLS;
			break;
			
		case IDM_SHOWDLLS:
			fViewFlags |= SHOW_DLLS;
			fViewFlags &= ~SHOW_EXES;
			break;
			
	}		
	FillLB (hWnd);
	return 0;
}
//------------------------------------------------------------
// DoMainMenuShowPath - Process Show Path menu item
//------------------------------------------------------------ 
LONG DoMainMenuShowPath (HWND hWnd, UINT idItem, HWND hwndCtl, 
                         UINT wNotifyCode) {

	fViewFlags ^= SHOW_PATH;
	InvalidateRect (hWnd, NULL, TRUE);
	return 0;
}
//------------------------------------------------------------
// DoMainMenuSort - Process Sort menu items.
//------------------------------------------------------------ 
LONG DoMainMenuSort (HWND hWnd, UINT idItem, HWND hwndCtl, 
                     UINT wNotifyCode) {

	sSortParam = idItem - IDM_SORTNAME;
	FillLB (hWnd);
	return 0;
}
//------------------------------------------------------------
// DoMainMenuAbout - Process About button
//------------------------------------------------------------ 
LONG DoMainMenuAbout (HWND hWnd, UINT idItem, HWND hwndCtl, 
                     UINT wNotifyCode) {
								
	MyDisplayDialog(hInst, "AboutBox", hWnd, 
   	             (WNDPROC) AboutDlgProc, (LONG) wVersion);
	return 0;
}
//============================================================
// SelDisksDlgProc - SelDisks dialog box dialog procedure
//============================================================
BOOL CALLBACK ScanDlgProc (HWND hWnd, UINT wMsg, UINT wParam, 
                           LONG lParam) {
	INT i;
	char szTemp[128];

	if (wMsg == WM_INITDIALOG) {
		if (sDrvCnt) {
			strcpy (szTemp, "Press Scan to begin scan of machine.\n\nDrives to be scanned: ");
			for (i = 0; i < sDrvCnt; i++) {
				strcat (szTemp, (char *) &sDrives[i]);
				strcat (szTemp, ": ");
			}	
			SetDlgItemText (hWnd, IDD_TEXT, szTemp);
		} else {
			SetDlgItemText (hWnd, IDD_TEXT, "No drives selected.");
			EnableWindow (GetDlgItem (hWnd, IDOK), FALSE);
		}	
	} else if (wMsg == WM_COMMAND) {
		switch (wParam) {

			case IDD_SELDISKS:
				ShowWindow (hWnd, SW_HIDE);
				MyDisplayDialog(hInst, "SelDisks", hMain, 
   	             (WNDPROC) SelDisksDlgProc, 1);
				ShowWindow (hWnd, SW_SHOW);
				if (sDrvCnt) {
					strcpy (szTemp, "Press Scan to begin scan of machine.\n\nDrives to be scanned: ");
					for (i = 0; i < sDrvCnt; i++) {
						strcat (szTemp, (char *) &sDrives[i]);
						strcat (szTemp, ": ");
					}	
					SetDlgItemText (hWnd, IDD_TEXT, szTemp);
					EnableWindow (GetDlgItem (hWnd, IDOK), TRUE);
				} else {
					SetDlgItemText (hWnd, IDD_TEXT, "No drives selected.");
					EnableWindow (GetDlgItem (hWnd, IDOK), FALSE);
				}	
				return TRUE;

			case IDCANCEL:
				EndDialog(hWnd, 0);
				return TRUE;
				
			case IDOK:
				EndDialog(hWnd, 1);
				return TRUE;
		}		
	} 
	return FALSE;
}
//============================================================
// SelDisksDlgProc - SelDisks dialog box dialog procedure
//============================================================
BOOL CALLBACK SelDisksDlgProc (HWND hWnd, UINT wMsg, UINT wParam, 
                              LONG lParam) {
	INT i, rc = 0;
	char szTemp[12];

	switch (wMsg) {
		case WM_INITDIALOG:
			SendDlgItemMessage (hWnd, IDD_DRVLIST, LB_RESETCONTENT, 0, 0);
			SendDlgItemMessage (hWnd, IDD_DRVLIST, LB_DIR, 
			                    DDL_DRIVES | DDL_EXCLUSIVE, (LONG)(LPSTR)"*.*");
			for (i = 0; i < sDrvCnt; i++)
				SendDlgItemMessage (hWnd, IDD_DRVLIST, LB_SETSEL, TRUE,
		                          MAKELONG (sDrives[i] - 'A', 0));
			if (lParam)
				ShowWindow (GetDlgItem (hWnd, IDD_SCAN), SW_HIDE);
			else	
				ShowWindow (GetDlgItem (hWnd, IDD_SCAN), SW_SHOW);
			return TRUE;
			
		case WM_COMMAND:
			switch (wParam) {
				case IDD_SCAN:
					rc = 1;
				case IDOK:
					if (HIWORD(lParam) != BN_CLICKED)
						return FALSE;
				
					sDrvCnt = (INT) SendDlgItemMessage (hWnd, IDD_DRVLIST, 
					                                    LB_GETSELCOUNT, 0, 0);
					if (sDrvCnt == 0) {
						MessageBox (hWnd, "No drives selected.", szTitleText, 
						            MB_OK | MB_ICONASTERISK);
						return 0;
					}
					SendDlgItemMessage (hWnd, IDD_DRVLIST, LB_GETSELITEMS, 26, 
					                    (LONG)(LPINT)sDrives);
					for (i = 0; i < sDrvCnt; i++) {
						SendDlgItemMessage (hWnd, IDD_DRVLIST, LB_GETTEXT, sDrives[i],
						                    (LONG)(LPSTR)szTemp);
						sDrives[i] = szTemp[2]-(BYTE)0x20;
					}	
					EndDialog(hWnd, rc);
					return TRUE;
				
				case IDCANCEL:
					EndDialog(hWnd, 0);
					return TRUE;
			}		
	} 
	return FALSE;
}
//============================================================
// FileInfoDlgProc - File Info dialog box dialog procedure
//============================================================
BOOL CALLBACK FileInfoDlgProc (HWND hWnd, UINT wMsg, UINT wParam, 
                               LONG lParam) {
	INT i, sNumLen;
	LONG l, lIndex;
	LPMYDIRENTRY lpEntryPtr;
	char szOut[256];
	char *pszOut;
	DWORD dwData;

	switch (wMsg) {
		case WM_INITDIALOG:
			if (!hMasterSeg) {
				EndDialog(hWnd, 0);
				return TRUE;
			}
			sInfoDlgDepth++;
			lpEntryPtr = *(lpMasterPtr + LOWORD (lParam));
			// Display file name
			SetDlgItemText (hWnd, IDD_IFILENAME, lpEntryPtr->szName); 
			// Display file path
			if (lpEntryPtr->lpParent) {
				CreatePath (lpEntryPtr, szOut, sizeof (szOut));
			} else {
				lstrcpy (szOut, lpEntryPtr->szName);
			}
			*strrchr (szOut, '\\') = '\0';
			SetDlgItemText (hWnd, IDD_IFILEPATH, szOut); 
			// Display file size
			ltoa (lpEntryPtr->lSize, szTemp, 10);
			sNumLen = strlen (szTemp);
			pszOut = szOut;
			for (i = 0; i < sNumLen; i++) {
				if ((sNumLen - i) % 3 == 0 && i != 0)
					*pszOut++ = ',';
				*pszOut++ = szTemp[i];
			}
			*pszOut = '\0';
			strcat (szOut, " Bytes");
			SetDlgItemText (hWnd, IDD_IFILESIZE, szOut);
			//Display Time and Date
			Date2asc (lpEntryPtr->usDate, lpEntryPtr->usTime, szOut);
			SetDlgItemText (hWnd, IDD_IFILEDATE, szOut);
			//Display attributes
			Attr2asc (lpEntryPtr->ucAttrib, szOut);
			SetDlgItemText (hWnd, IDD_IFILEATTRS, szOut);
			//Display module name
			SetDlgItemText (hWnd, IDD_IFILEMODNAME, lpEntryPtr->szModName);
			//Fill cross reference lists			
			SendDlgItemMessage (hWnd, IDD_IFILEREFS, LB_RESETCONTENT, 0, 0);
			SendDlgItemMessage (hWnd, IDD_IFILEDEP, LB_RESETCONTENT, 0, 0);
			
			for (l = 0; l < lChildCnt; l++) {
				dwData = *(lpChildPtr + l);
				if (LOWORD (dwData) == LOWORD (lParam)) {
					if (HIWORD (dwData) & 0x8000) {
						strcpy (szOut, "Lib not found: ");
						lstrcat (szOut, lpLostPtr + (HIWORD (dwData) & 0x7fff));
					} else	
						lstrcpy (szOut, (*(lpMasterPtr + HIWORD (dwData)))->szName);

					lIndex = SendDlgItemMessage (hWnd, IDD_IFILEDEP, 
					                             LB_ADDSTRING, 0, 
					                             (LPARAM)(LPSTR)szOut);
					SendDlgItemMessage (hWnd, IDD_IFILEDEP, LB_SETITEMDATA,
					                    (UINT) lIndex, (LPARAM) HIWORD (dwData)); 
				}
				if (HIWORD (dwData) == LOWORD (lParam)) {
					lIndex = SendDlgItemMessage (hWnd, IDD_IFILEREFS, LB_ADDSTRING, 0, 
					     (LPARAM)(LPSTR)(*(lpMasterPtr + LOWORD (dwData)))->szName);
					SendDlgItemMessage (hWnd, IDD_IFILEREFS, LB_SETITEMDATA,
					                    (UINT) lIndex, (LPARAM) LOWORD (dwData)); 
				}
			}
			return TRUE;
			
		case WM_COMMAND:
			switch (wParam) {

				case IDD_IFILEDEP:
				case IDD_IFILEREFS:
					if (HIWORD (lParam) != LBN_DBLCLK)
						return TRUE;
					lIndex = SendDlgItemMessage (hWnd, wParam, LB_GETCURSEL, 0, 0);
					dwData = SendDlgItemMessage (hWnd, wParam, LB_GETITEMDATA,
					                             (UINT) lIndex, 0);
					if (sInfoDlgDepth > 8)
						MessageBox (hMain, 
						"You have too many information dialogs open.\nPlease close some before continuing",
						szAppName, MB_OK | MB_ICONASTERISK);
					else if (!(dwData & 0x8000)) {
						if (MyDisplayDialog(hInst, "FileInfo", hMain, 
						                (WNDPROC) FileInfoDlgProc, dwData)) {
							sInfoDlgDepth--;
							EndDialog(hWnd, 1);
						}
					}	
					return TRUE;
					
				case IDD_IFILECA:
					sInfoDlgDepth--;
					EndDialog(hWnd, 1);
					return TRUE;

				case IDOK:
				case IDCANCEL:
					sInfoDlgDepth--;
					EndDialog(hWnd, 0);
					return TRUE;
			}		
	} 
	return FALSE;
}
//============================================================
// AboutDlgProc - About dialog box dialog procedure
//============================================================
BOOL CALLBACK AboutDlgProc (HWND hWnd, UINT msg, UINT wParam, 
                            LONG lParam) {
	char	szAboutStr[128];
	
	HWND	hwndText;
	RECT	rect;
	HDC	hdc;
	PAINTSTRUCT ps;
	HPEN	hDPen, hLPen, hOldPen;

	switch (msg) {                              
		case WM_INITDIALOG:
			GetDlgItemText (hWnd, IDD_PROGSTR, szAboutStr, sizeof (szAboutStr));
			itoa ((INT)lParam/10, &szAboutStr[strlen (szAboutStr)], 10);
			strcat (szAboutStr, ".");
			itoa ((INT)lParam%10, &szAboutStr[strlen (szAboutStr)], 10);
			SetDlgItemText (hWnd, IDD_PROGSTR, szAboutStr);
			return TRUE;
	
		case WM_PAINT:
			hdc = BeginPaint(hWnd, &ps);
			hwndText = GetDlgItem (hWnd, IDD_COPYDATE);
			if (IsWindow (hwndText)) {
				GetClientRect (hwndText, &rect);
				ClientToScreen (hwndText, (LPPOINT)&rect);
				ScreenToClient (hWnd, (LPPOINT)&rect);
				rect.left -= 2;
				rect.top -= 2;
				rect.right += rect.left + 4;
				rect.bottom += rect.top + 4;
				hDPen = CreatePen (PS_SOLID, 1, GetSysColor (COLOR_BTNSHADOW));
				hLPen = CreatePen (PS_SOLID, 1, GetSysColor (COLOR_BTNHIGHLIGHT));

				hOldPen = SelectObject (hdc, hDPen);
				MoveTo (hdc, rect.left, rect.bottom);
				LineTo (hdc, rect.left, rect.top);
				LineTo (hdc, rect.right+1, rect.top);
				//Start at bottom left, draw light pen over and up.
				SelectObject (hdc, hLPen);
				MoveTo (hdc, rect.left+1, rect.bottom);
				LineTo (hdc, rect.right, rect.bottom);
				LineTo (hdc, rect.right, rect.top);
				SelectObject (hdc, hOldPen);

				DeleteObject (hDPen);
				DeleteObject (hLPen);
			}	
			EndPaint(hWnd, &ps);
			return TRUE;
		
		case WM_COMMAND:
		   if ((wParam == IDOK) || (wParam == IDCANCEL)) {
				EndDialog(hWnd, 0);
				return TRUE;
			} 
	} 
	return FALSE;
}
//------------------------------------------------------------
// The following routines are used to convert find data to
// ASCII text strings
//------------------------------------------------------------
//------------------------------------------------------------
// CreatePath - Builds a path string
//------------------------------------------------------------ 
INT CreatePath (LPMYDIRENTRY lpEntry, char *pszOut, int sSize) {
	INT i, sLen;
	
	if (lpEntry->lpParent)
		sLen = CreatePath (lpEntry->lpParent, pszOut, sSize);
	else {
		*pszOut = '\0';
		return 0;
	}		
	if (sLen && (*(pszOut + sLen)	!= '\\')) {
		strcat (pszOut, "\\");
		sLen++;
	}	
	i = lstrlen (lpEntry->szName);		
	if (i + sLen > sSize)
		return sLen;
	lstrcat (pszOut, lpEntry->szName);
	return sLen + i;
}		
//------------------------------------------------------------
// Date2asc - Convert DOS date to ASCII string
// Date              Time 
//    15-9 Year        15-11 Hours
//     8-5 Month       10-5  Minutes
//     4-0 Day          4-0  Seconds * 2
//------------------------------------------------------------ 
void Date2asc (UINT usDate, UINT usTime, char *pszOut) {
	UINT usTemp;
	if (usDate == 0xffff) {
		*pszOut = '\0';
		return;
	}
	*pszOut++ = (char)((((usDate >> 5) & 0x0f) / 10) + 0x30);
	*pszOut++ = (char)((((usDate >> 5) & 0x0f) % 10) + 0x30);
	*pszOut++ = '-';	

	*pszOut++ = (char)(((usDate & 0x1f) / 10) + 0x30);
	*pszOut++ = (char)(((usDate & 0x1f) % 10) + 0x30);
	*pszOut++ = '-';	
	
	usTemp = ((usDate >> 9) & 0x7f) + 1980;
	itoa ((INT) usTemp, pszOut, 10);
	pszOut += 4;
	*pszOut++ = ' ';	
	*pszOut++ = ' ';	
	*pszOut++ = ' ';	
	*pszOut++ = ' ';	
	
	usTemp = ((usTime >> 11) & 0x1f);
	if (usTemp > 11)
		*(pszOut+5) = 'p';
	else	
		*(pszOut+5) = 'a';
	if (usTemp > 12)
		usTemp -= 12;
		
	*pszOut++ = (char)((usTemp / 10) + 0x30);
	*pszOut++ = (char)((usTemp % 10) + 0x30);
	*pszOut++ = ':';	
	usTemp = ((usTime >> 5) & 0x3f);
	*pszOut++ = (char)((usTemp / 10) + 0x30);
	*pszOut++ = (char)((usTemp % 10) + 0x30);
	//Seconds are not displayed
	*(pszOut+1) = '\0';	
		
	return;
}	
//------------------------------------------------------------
// Attr2asc - Convert DOS attribute flags to ASCII string
//------------------------------------------------------------ 
void Attr2asc (BYTE ucAttrib, char *pszOut) {

	strcpy (pszOut, "----");
	if (ucAttrib & _A_RDONLY)
		*pszOut = 'r';
	pszOut++;
	if (ucAttrib & _A_ARCH)
		*pszOut = 'a';
	pszOut++;
	if (ucAttrib & _A_SYSTEM)
		*pszOut = 's';
	pszOut++;
	if (ucAttrib & _A_HIDDEN)
		*pszOut = 'h';
	return;
}	
//------------------------------------------------------------
// PrintError - Displays a message box with an error code
//------------------------------------------------------------ 
void	PrintError (HWND hWnd, INT rc) {
	char szErrStr[80];
	char szTemp[12];
	
	if (rc > 0)
	   rc += DOSERROFFSET;
	else 
	   rc = abs (rc);
	if (LoadString (hInst, rc, szErrStr, sizeof (szErrStr)) == 0) {
		itoa (rc, szTemp, 10);
		strcpy (szErrStr, "Error number: ");
		strcat (szErrStr, szTemp);
	}
	MessageBox (hMain, szErrStr, szTitleText, MB_OK | MB_ICONHAND);
	return;
}
//------------------------------------------------------------
// FillLB - Clears, then refills the hot key listbox
//------------------------------------------------------------ 
void FillLB (HWND hWnd) {
	INT i, j, k, l;
	LPMYDIRENTRY lpEntryPtr;
	LPMYDIRENTRY lpEntryPtr1;

	if (fSearching)
		return;
		
	SendDlgItemMessage (hWnd, IDD_FLIST, LB_RESETCONTENT, 0, 0);
	InvalidateRect (hWnd, 0, TRUE);
	if (sMasterCount == 0)
		return; 
	sListCount = 0;
	for (i = 0; i < sMasterCount; i++) {
		lpEntryPtr = *(lpMasterPtr + i);
		if (((lpEntryPtr->sType == ETYPE_WIN) && (fViewFlags & SHOW_EXES)) ||
		    ((lpEntryPtr->sType == (ETYPE_WIN | 0x100) && (fViewFlags & SHOW_DLLS)))) {
			SendDlgItemMessage (hWnd, IDD_FLIST, LB_ADDSTRING, 0, 
			                    (LPARAM) (LONG) i);
			sListCount++;
		}
	}
	MyYield();
	// Mark duplicates
	if ((sSortParam == SORT_NAME) && !fDupScan) {
		for (i = 0; i < sListCount; i++) {
			k = (INT) SendDlgItemMessage (hWnd, IDD_FLIST, 
			                              LB_GETITEMDATA, i, 0);
			lpEntryPtr = *(lpMasterPtr + k);
			for (j = i+1; j < sListCount; j++) {
				l = (INT) SendDlgItemMessage (hWnd, IDD_FLIST, 
				                              LB_GETITEMDATA, j, 0);
				lpEntryPtr1 = *(lpMasterPtr + l);
				if (lstrcmp (lpEntryPtr->szName, lpEntryPtr1->szName) == 0) {
					lpEntryPtr->ucAttrib |= ATTR_DUP;
					lpEntryPtr1->ucAttrib |= ATTR_DUP;
				} else {
					i = j - 1;
					break;
				}
			}
		}
		fDupScan = TRUE;
	}
	return;
}	
//------------------------------------------------------------
// DisplayCurrStatus - Creates a text string describing the 
// current status, then displays it in the status bar.
//------------------------------------------------------------ 
void DisplayCurrStatus (HWND hWnd) {
	char szTemp[80];
	
	if (sMasterCount == 0)
		SetStatusBarText (hWnd, "Select Scan Disk menu under the Files menu", 0);
	else {
		itoa (sListCount, szTemp, 10);
		strcat (szTemp, " Files");
		SetStatusBarText (hWnd, szTemp, 1);
	}	
	return;
}
//============================================================  
// EXE and DLL examination funcitons
//============================================================  
//-------------------------------------------------------------------
// MyFileOpen - File open wrapper
//-------------------------------------------------------------------
HFILE MyFileOpen (char *szName, INT sFlags, INT *pRC) {
	HFILE handle;
	OFSTRUCT of;	

	handle = OpenFile (szName, &of, sFlags);
	if (handle == HFILE_ERROR) {
		handle = 0;
		*pRC = of.nErrCode;	
	} else	
		*pRC = 0;	
	return handle;
}	
//-------------------------------------------------------------------
// FindInDir - Locates a file in a directory list
//-------------------------------------------------------------------
UINT FindInDir (char *pszName, UINT usParent, UINT usPartial, BOOL fChkMod) {
	LPMYDIRENTRY lpEntry, lpParent;
	char szTemp[14];
	char *pszTemp;
	UINT usCnt;
	BOOL fFound = FALSE;
	
	lpParent = *(lpMasterPtr + usParent);

	if (usPartial) {
		usCnt = usPartial;
		lpEntry = *(lpMasterPtr + usPartial);
		if (lpEntry->ucAttrib & _A_SUBDIR)
			usCnt += lpEntry->usChildCnt;
		usCnt++;	
	} else
		usCnt = usParent + 1;
	if (usCnt >= (UINT)sMasterCount)
		return 0;
	lpEntry = *(lpMasterPtr + usCnt);
	
	while (!fFound) {
		if (fChkMod) {
			if (lstrcmp (lpEntry->szModName, pszName) == 0)
				fFound = TRUE;
		} else {		
			lstrcpy (szTemp, lpEntry->szName);
			if (pszTemp = strchr (szTemp, '.'))
				*pszTemp = '\0';
			if (strcmp (szTemp, pszName) == 0)
				fFound = TRUE;
		}
		if (!fFound) {
			if (lpEntry->ucAttrib & _A_SUBDIR)
				usCnt += lpEntry->usChildCnt + 1;
			else
				usCnt++;	
			if (usCnt >= (UINT)sMasterCount)
				return 0;
			lpEntry = *(lpMasterPtr+usCnt);
			if (lpEntry->lpParent != lpParent)
				return 0;
		}	
	}	
	return usCnt;
}	
//-------------------------------------------------------------------
// FileFileInArray - Searches for a file in the file array
//-------------------------------------------------------------------
UINT FindFileInArray (char *pszName) {
	char *pszNameEnd;
	UINT usFindIndex = 0;

	//Find Dirs
	while (pszNameEnd = strchr (pszName, '\\')) {
		*pszNameEnd = '\0';
		usFindIndex = FindInDir (pszName, usFindIndex, 0, FALSE);
		if (usFindIndex == 0)
			break;
		*pszNameEnd = '\\';
		pszName = pszNameEnd+1;
	}
	//Find file
	if (usFindIndex && strlen (pszName))
		usFindIndex = FindInDir (pszName, usFindIndex, 0, FALSE);
	
	return usFindIndex;
}	
//-------------------------------------------------------------------
// WinSearch - Windows executable search method
//
// Windows search method
//   current dir
//   Win directory
//   Win System directory
//   EXE file's directory
//   path
//-------------------------------------------------------------------
UINT WinSearch (char *pszFName, UINT usProgIndex, BOOL fChkMod) {
	UINT usFindIndex, usParent;
	LPMYDIRENTRY lpFindPtr;
	LPUINT lpDirPtr;
	int i;

	lpDirPtr = lpDirBasePtr;
	usFindIndex = 0;

	// Loop through proper directories.  Note loop index incrimented later in loop.
	for (i = 0; i < sDirSegCnt;) {
		//If 4th entry, sub program's own directory.
		if (i == 3) {
			if (usFindIndex == 0) {
				CreatePath ((*(lpMasterPtr+usProgIndex))->lpParent, szTemp, 
				            sizeof (szTemp));
				usParent = FindFileInArray (szTemp);
			}	
			if (usParent)
				usFindIndex = FindInDir (pszFName, usParent, usFindIndex, fChkMod); 
		} else	
			usFindIndex = FindInDir (pszFName, *lpDirPtr, usFindIndex, fChkMod); 

		if (usFindIndex) {
			lpFindPtr = *(lpMasterPtr + usFindIndex);
			if (lpFindPtr->sType == 0xff)
				ChkFile (usFindIndex, FALSE);

			if ((lpFindPtr->sType & 0x100) || 
			    ((fChkMod) && ((lpFindPtr->sType & 0x0ff) == ETYPE_WIN)))
				return usFindIndex;
		} else {
			usFindIndex = 0;
			lpDirPtr++;
			i++;
		}
	}
	return 0;	
}
//------------------------------------------------------------
// ChkFile - Determines the type of a file
//------------------------------------------------------------ 
INT ChkFile (UINT usIndex, BOOL bChkMod) {
	UINT usFindIndex, usBytesRead;
	LPMYDIRENTRY lpEntryPtr;
	char szName[MAXFNAMELEN], ch;
	char *pszRefName;
	BYTE bRefNameLen;
	INT i, j, sRefs, rc = 0;
	HLOCAL hLocal, h2nd = 0;
	PBYTE pLBuff, p2nd;
	HFILE hFile;
	LONG lFilePtr;
	
	lpEntryPtr = *(lpMasterPtr + usIndex);
	sRefs = 0;
	lpEntryPtr->usChildCnt = 0;
	lpEntryPtr->usBadCnt = 0;
	lpEntryPtr->sType = 0;

	CreatePath (lpEntryPtr, szName, sizeof (szName));
	hFile = MyFileOpen (szName, OF_READ, &rc);
	if (!hFile)
		return ERR_NOOPENEXE;
	
	hLocal = LocalAlloc (LHND, BUFFSIZE);
	if (hLocal == 0) {
		_lclose (hFile);
		return ERR_OUTOFMEM;
	}	
	pLBuff = LocalLock (hLocal);

	usBytesRead = _lread (hFile, pLBuff, 0x40);
	//Check for "MZ" and  check for New EXE header.
	if ((usBytesRead < 0x40) ||
	    (*(PUINT)pLBuff != 0x5a4d) ||
	    (*((PUINT)(pLBuff+0x18)) < 0x40)) {
		LocalUnlock (hLocal);
		LocalFree (hLocal);
		_lclose (hFile);
		return 0;
	} 
	//Read New EXE header
	lFilePtr = *((PLONG)(pLBuff+0x3C));
	_llseek (hFile, lFilePtr, SEEK_SET);
	usBytesRead = _lread (hFile, pLBuff, 0x200);

	//Check for NewEXE (NE)
	if (*(PUINT)pLBuff == 0x454e) {

		if (*(pLBuff+0x36) & 2) 
			lpEntryPtr->sType = ETYPE_WIN;                  //Windows
		else if (*(pLBuff+0x36) & 1) 
			lpEntryPtr->sType = ETYPE_OS21;                 //OS/2 1.x
		if (*(PUINT)(pLBuff+0x0C) & 0x8000) 
			lpEntryPtr->sType += 0x100;                     //Library
		//Get number of references
		sRefs = *((PINT)(pLBuff+0x1E));            
		//Get module name.  It is in the 1st entry in module ref table.
		// This hack works because the mod name has an ordnal number of
		// zero which immediately follows the name providing a terminating 0.
		// The extra byte of seek skips the name length byte.
		_llseek (hFile, lFilePtr + ((LONG)*((PUINT)(pLBuff+0x26)) + 1), SEEK_SET);
		usBytesRead = _lread (hFile, lpEntryPtr->szModName, 
		                      sizeof (lpEntryPtr->szModName));
		AnsiUpper (lpEntryPtr->szModName);
		//Get ptr to Non-Resident Names table			
		lFilePtr += (LONG) *((PUINT)(pLBuff+0x28));
	} else {
		LocalUnlock (hLocal);
		LocalFree (hLocal);
		_lclose (hFile);
		return 0;
	}
	if (((lpEntryPtr->sType & 0xff) == ETYPE_WIN) && (sRefs)) {
		sListCount++;

		_llseek (hFile, lFilePtr, SEEK_SET);
		usBytesRead = _lread (hFile, pLBuff, BUFFSIZE);

		lpEntryPtr->usChildCnt = sRefs;
		lpEntryPtr->usBadCnt = 0;
		
		for (i = 0; i < sRefs; i++) {
			//Get ptr to len,name
			pszRefName = pLBuff + *((PUINT)pLBuff+i) + (sRefs*2);
			//If ptr outside std buffer, chk 2nd buffer.
			if ((pszRefName - pLBuff) > BUFFSIZE) {
				//If no 2nd buffer exists, create one.
				if (h2nd == 0) {
					h2nd = LocalAlloc (LHND, BUFFSIZE);
					if (h2nd == 0) {
						LocalUnlock (hLocal);
						LocalFree (hLocal);
						return ERR_OUTOFMEM;
					}	
					p2nd = LocalLock (h2nd);
					usBytesRead = _lread (hFile, p2nd, BUFFSIZE);
				}
				pszRefName = p2nd - BUFFSIZE + *((PUINT)pLBuff+i) + (sRefs*2);
				if ((pszRefName - p2nd) > BUFFSIZE) {
					lpEntryPtr->usBadCnt = 0;
					LocalUnlock (h2nd);
					LocalFree (h2nd);
					LocalUnlock (hLocal);
					LocalFree (hLocal);
					_lclose (hFile);
					return 0;
				}
			}
			bRefNameLen = (BYTE) *pszRefName++;
			//Terminate name with zero.
			ch = *(pszRefName+bRefNameLen);
			*(pszRefName+bRefNameLen) = '\0';
			//Convert to Ucase.Some linkers leave lc.
			strupr (pszRefName);
			usFindIndex = 0;
			//See if name in std list.
			for (j = 0; j < NUMSTDLIBS; j++) {
				if (strcmp (pszRefName, szStdLibs[j]) == 0) {
					usFindIndex = sStdLibPtrs[j];
					if (usFindIndex)
						(*(lpMasterPtr + usFindIndex))->lUseCnt++;
					break;
				}	
			}		
			if (!usFindIndex) {
				usFindIndex = WinSearch (pszRefName, usIndex, FALSE);
				if (bChkMod) {
					if (usFindIndex == 0) {
						usFindIndex = WinSearch (pszRefName, usIndex, TRUE);
						if (usFindIndex)
							(*(lpMasterPtr + usFindIndex))->lUseCnt++;
						else {
							lpEntryPtr->usBadCnt++;
							if (sLostIndex < (0x8000 - 14)) {
								usFindIndex = (UINT)sLostIndex | 0x8000;
								lstrcpy (lpLostPtr + sLostIndex, pszRefName);
								sLostIndex += (INT) bRefNameLen + 1;
							} else
								usFindIndex = 0x8000;
						}	
						if (lChildCnt < MAXXREF)
							*(lpChildPtr + lChildCnt++) = MAKELONG (usIndex, 
							                                        usFindIndex);
					}
				} else {
					if (usFindIndex)
						(*(lpMasterPtr + usFindIndex))->lUseCnt++;
					else	
						lpEntryPtr->usBadCnt++;
				}		
			}
			if (!bChkMod && usFindIndex && (lChildCnt < MAXXREF))
				*(lpChildPtr + lChildCnt++) = MAKELONG (usIndex, usFindIndex);
			*(pszRefName+bRefNameLen) = ch;					
		}
	}	
	_lclose (hFile);
	LocalUnlock (hLocal);
	LocalFree (hLocal);
	if (h2nd) {
		LocalUnlock (h2nd);
		LocalFree (h2nd);
	}	
	return rc;
}	
//------------------------------------------------------------
// CheckAllFiles - Scans list of files and calls ChkFile for
// all non-directory entries.
//------------------------------------------------------------ 
INT CheckAllFiles (HWND hWnd) {
	INT i, rc = 0;
	char szTemp[256];
	char *pszDir, *pszEnd;
	LPUINT lpDirPtr;
	UINT usFindIndex;
	HANDLE hLib;
	LPMYDIRENTRY lpEntryPtr;

	if (sMasterCount == 0)
		return 0;			
	//
	// Create cross reference block
	//
	if (hChildSeg) {
		GlobalUnlock (hChildSeg);
		GlobalFree (hChildSeg);
	}		
	lChildCnt = 0;
	hChildSeg = GlobalAlloc (GHND, (LONG)MAXXREF * sizeof (DWORD));
	lpChildPtr = (DWORD huge *) GlobalLock (hChildSeg);
	if (lpChildPtr == 0)
		return ERR_OUTOFMEM;
	//
	// Create lost DLLs block
	//
	if (hLostSeg) {
		GlobalUnlock (hLostSeg);
		GlobalFree (hLostSeg);
	}		
	sLostIndex = 0;
	hLostSeg = GlobalAlloc (GHND, 0x8000);
	if (hLostSeg == 0)
		return ERR_OUTOFMEM;
	lpLostPtr = (LPSTR) GlobalLock (hLostSeg);
	//
	// Create directory array
	//
	hDirSeg = GlobalAlloc (GHND, 128 * sizeof (UINT));
	lpDirBasePtr = (LPUINT) GlobalLock (hDirSeg);
	lpDirPtr = lpDirBasePtr;
	
	getcwd (szTemp, sizeof (szTemp));               //Get current dir
	usFindIndex = FindFileInArray (szTemp);
	if (usFindIndex)
		*lpDirPtr++=usFindIndex;
	
	GetWindowsDirectory (szTemp, sizeof (szTemp));  //Get Windows dir
	usFindIndex = FindFileInArray (szTemp);
	if (usFindIndex)
		*lpDirPtr++=usFindIndex; 		
	
	GetSystemDirectory (szTemp, sizeof (szTemp));   //Get Windows System dir
	usFindIndex = FindFileInArray (szTemp);
	if (usFindIndex)
		*lpDirPtr++=usFindIndex;

	*lpDirPtr++=0;                                  //Add blank spot for prog's dir
	strcpy (szTemp, getenv ("PATH"));               //Get Path Directories
	pszEnd = strchr (szTemp, ';');
	pszDir = szTemp;
	while (pszEnd) {
		*pszEnd = '\0';
		if (*pszDir) {
			usFindIndex = FindFileInArray (pszDir);
			if (usFindIndex)
				*lpDirPtr++=usFindIndex;
			pszDir = pszEnd + 1;
		}
		pszEnd = strchr (pszDir, ';');
	}
	sDirSegCnt = lpDirPtr - lpDirBasePtr;
	//
	//Load standard libs, then determine their filenames.
	//
	for (i = 0; i < NUMSTDLIBS; i++) {
		usFindIndex = 0;
		hLib = LoadLibrary (szStdLibs[i]);
		if (hLib) {
			GetModuleFileName (hLib, szTemp, sizeof (szTemp));
			pszDir = strrchr (szTemp, '.');
			if (pszDir)
				*pszDir = '\0';
			FreeLibrary (hLib);
			usFindIndex = FindFileInArray (szTemp);
		}
		sStdLibPtrs[i] = usFindIndex;
	}	
	//
	// Scan all files in array for references
	//
if (sDirSegCnt < 3)
	rc = ERR_BADSETUP;
	
	strcpy (szStatText, "Screening files.   ");
	SetStatusBarText (hWnd, szStatText, 0);
	pszStatEnd = szStatText + strlen (szStatText) - 1;	
	sProgress = 0;
	sListCount = NUMSTDLIBS;
	for (i = 0; (i < sMasterCount) && (rc == 0); i++) {
		//
		//Report progress
		//
		sProgress = (INT) (((LONG)i * 100) / sMasterCount);
		if (sOldProgress != sProgress) {
			itoa (sProgress, pszStatEnd, 10);
			strcat (szStatText, "% Done.");
			SetStatusBarText (hWnd, szStatText, 0);

			itoa (sListCount, pszStatEnd, 10);
			strcat (pszStatEnd, " Windows Executables");
			SetStatusBarText (hWnd, pszStatEnd, 1);

			sOldProgress = sProgress;
		}	
	   MyYield ();										//Yield to other apps
		//
		// Check another file
		//
		if (fSearching) {
			lpEntryPtr = *(lpMasterPtr+i);
			if (!(lpEntryPtr->ucAttrib & _A_SUBDIR) && (lpEntryPtr->sType == 0xff))
				rc = ChkFile (i, FALSE);
		} else 
			rc = ERR_CANCELED;
	}
	//
	// Scan for module names
	//	
	strcpy (szStatText, "Scanning for Module Names.   ");
	SetStatusBarText (hWnd, szStatText, 0);
	pszStatEnd = szStatText + strlen (szStatText) - 1;	
	SetStatusBarText (hWnd, "", 1);
	sProgress = 0;
	for (i = 0; (i < sMasterCount) && (rc == 0); i++) {
		//
		//Report progress
		//
		sProgress = (INT) (((LONG)i * 100) / sMasterCount);
		if (sOldProgress != sProgress) {
			itoa (sProgress, pszStatEnd, 10);
			strcat (szStatText, "% Done.");
			SetStatusBarText (hWnd, szStatText, 0);
			sOldProgress = sProgress;
		}	
	   MyYield ();										//Yield to other apps
		//
		// Check another file
		//
		if (fSearching) {
			lpEntryPtr = *(lpMasterPtr+i);
			if (!(lpEntryPtr->ucAttrib & _A_SUBDIR) && 
			     (lpEntryPtr->usBadCnt))
				rc = ChkFile (i, TRUE);
		} else 
			rc = ERR_CANCELED;
	}
	GlobalUnlock (hDirSeg);
	GlobalFree (hDirSeg);
	SetStatusBarText (hWnd, "Screening Complete", 0);
	return rc;
}	
//============================================================  
// Scan routines
//============================================================  
//------------------------------------------------------------
// FreeBuffer - Frees all buffers
//------------------------------------------------------------ 
INT FreeBuffer (UINT selBuffIn) {
	LPBUFFHDR lpBuffPtr;
	UINT selNext;

	while (selBuffIn) {
		lpBuffPtr = MAKELP (selBuffIn, 0);
		selNext = lpBuffPtr->selNext;
		GlobalUnlock (selBuffIn);
		GlobalFree (selBuffIn);
		selBuffIn = selNext;
	}		
	return 0;
}
//------------------------------------------------------------
// GetBuffBlock - Allocates and inits a buffer.
//------------------------------------------------------------ 
INT GetBuffBlock (LPBUFFHDR lpBuff, UINT usOldSize) {
	HGLOBAL hMem;
	UINT usSize;
	LPBUFFHDR lpNewBuff;
	
	usSize = ((0x10000 - sizeof (BUFFHDR)) / sizeof (MYDIRENTRY)) * 
	         sizeof (MYDIRENTRY);
	hMem = GlobalAlloc (GHND, usSize+6);

	if (hMem == 0)
		return ERR_OUTOFMEM;
	lpNewBuff = (LPBUFFHDR) GlobalLock (hMem);
	
	lpBuff->selNext = SELECTOROF (lpNewBuff);
	lpBuff->usEnd = usOldSize;
	lpNewBuff->usSize = usSize;
	
	lpCurrBuff = MAKELP (SELECTOROF (lpNewBuff), 0);
	lpDirEntry = (LPMYDIRENTRY) (lpCurrBuff + 1);
	return 0;
}
//------------------------------------------------------------
// ScanDir - Copies the contents of a directory into the
// file name buffer.
//------------------------------------------------------------ 
INT ScanDir (HWND hWnd, LPMYDIRENTRY lpParent) {
	LPMYDIRENTRY lpOldEntry;
	FIND_T fs;
	char *pszSrchDirEnd;
	char *pszExt;
	int i, rc;
	UINT far *lpwDest;
	UINT *pwSrc;

	pszSrchDirEnd = szSearchDir + strlen (szSearchDir);
	strcpy (pszSrchDirEnd, "\\*.*");

	rc = _dos_findfirst (szSearchDir, _A_RDONLY | _A_ARCH | 
	                    _A_HIDDEN | _A_SYSTEM | _A_SUBDIR, &fs);

	while ((rc == 0) && (fSearching)) {
		//
		//Display directory count as a progress report
		//
		if ((sProgress != sOldProgress) && (sProgress % 10 == 0)) {
			itoa (sProgress, pszStatEnd, 10);
			SetStatusBarText (hWnd, szStatText, 0);

			itoa (sListCount, pszStatEnd, 10);
			strcat (pszStatEnd, " Executable files");
			SetStatusBarText (hWnd, pszStatEnd, 1);

			sOldProgress = sProgress;
		}	
	   MyYield ();										//Yield to other apps
		if (!fSearching)
			return ERR_CANCELED;
		//
		// See if current buffer filled
		//
		lpDirEntry++;
		if (OFFSETOF (lpDirEntry) >= lpCurrBuff->usSize) {
			rc = GetBuffBlock (lpCurrBuff, OFFSETOF (lpDirEntry));
			if (rc)
				return rc;		
		}
		//
		// Copy directory entry
		//
		//Save parent pointer
		lpDirEntry->lpParent = lpParent;
		//Clear fields;
		lpDirEntry->sType = 0xff;				    //Type
		pwSrc = (UINT *) &fs.attrib;
		lpwDest = (UINT far *)&lpDirEntry->ucAttrib;
		//Copy Dir entry
		for (i = 0; i < 11; i++)
			*lpwDest++ = *pwSrc++;
		//Clear flags I hide in attribute byte
		lpDirEntry->ucAttrib &= ~(ATTR_DELETED | ATTR_DUP);
		//
		//If subdir, recurse
		//
		if (fs.attrib & _A_SUBDIR) {
			sProgress++;
			if ((strcmp (fs.name, ".") != 0) &&
		       (strcmp (fs.name, "..") != 0)) {

				*lpMasterPtr++ = lpDirEntry;
				lpOldEntry = lpDirEntry;
				lpDirEntry->sType = 0;
				sMasterCount++;
				*pszSrchDirEnd = '\\';
				strcpy (pszSrchDirEnd+1, fs.name);
				rc = ScanDir (hWnd, lpDirEntry);
				if (rc == 0x12)
					rc = 0;
				lpParent->usChildCnt += lpOldEntry->usChildCnt + 1;
			}			
		} else {
			pszExt = strchr (fs.name,'.');
			if (pszExt) {
				for (i = 0; i < sNumProgExts; i++)
					if (strcmp (pszExt+1, szProgExts[i]) == 0) {
						*lpMasterPtr++ = lpDirEntry;
						sMasterCount++;
						lpParent->usChildCnt++;
						sListCount++;
						break;
					}	
			}	
		}
		//
		// Add entry to index
		//
		if (sMasterCount > MAXCOUNT)
			rc = ERR_TOOMANYFILES;
		if (rc == 0)	
			rc = _dos_findnext (&fs);
	}
	return rc;
}	
//------------------------------------------------------------
// ScanDisk - Search a specific drive
//------------------------------------------------------------ 
INT ScanDisk (HWND hWnd, LPMYDIRENTRY lpParent, char chDiskNum) {
	INT rc;
	LPMYDIRENTRY lpDrvEntry;

	lpDirEntry++;
	if (OFFSETOF (lpDirEntry) >= lpCurrBuff->usSize) {
		rc = GetBuffBlock (lpCurrBuff, OFFSETOF (lpDirEntry));
		if (rc)
			return rc;		
	}
	sMasterCount++;
	if (sMasterCount > MAXCOUNT)
		rc = ERR_TOOMANYFILES;
	*lpMasterPtr++ = lpDirEntry;
	lpDrvEntry = lpDirEntry;
		
	lpDrvEntry->lpParent = lpParent;
	lpDrvEntry->lUseCnt = 0;
	lpDrvEntry->sType = 0;
	lpDrvEntry->usChildCnt = 0;
	lpDrvEntry->ucAttrib = ATTR_DELETED | _A_SUBDIR;
	lpDrvEntry->usTime = 0;
	lpDrvEntry->usDate = 0;
	lpDrvEntry->lSize = 0;			
	lstrcpy (lpDrvEntry->szName, "C:");
	lpDrvEntry->szName[0] = (chDiskNum);

	_chdrive (chDiskNum - 0x40);
	chdir ("\\");
	szSearchDir[0] = '\0';
	rc = ScanDir (hWnd, lpDirEntry);
	lpParent->usChildCnt += lpDrvEntry->usChildCnt;
	return rc;
}
//------------------------------------------------------------
// ScanMachine - Performs the entire search
//------------------------------------------------------------ 
INT ScanMachine (HWND hWnd, INT sCnt, INT *sDrives) {
	INT i, rc;
	LPMYDIRENTRY lpSrchEntry;
	
	//Free old buffers	
	FreeBuffer (Buff.selNext);
	if (hMasterSeg) {
		GlobalUnlock (hMasterSeg);
		GlobalFree (hMasterSeg);
	}		
	//Alloc buffs for dir entries and index	
	rc = GetBuffBlock (&Buff, 0);
	if (rc) 
		return rc;
	hMasterSeg = GlobalAlloc (GHND, (LONG)MAXCOUNT * sizeof (LPLPMYDIRENTRY));
	if (hMasterSeg == 0)
		rc = ERR_OUTOFMEM;
	sMasterCount = 1;
	lpMasterPtr = (LPLPMYDIRENTRY) GlobalLock (hMasterSeg);
	
	*lpMasterPtr++ = lpDirEntry;
	lpSrchEntry = lpDirEntry;
	
	lpSrchEntry->lpParent = 0;
	lpSrchEntry->lUseCnt = 0;
	lpSrchEntry->sType = 0;
	lpSrchEntry->usChildCnt = 0;
	lpSrchEntry->ucAttrib = ATTR_DELETED | _A_SUBDIR;
	lpSrchEntry->usTime = 0;
	lpSrchEntry->usDate = 0;
	lpSrchEntry->lSize = 0;
	lstrcpy (lpSrchEntry->szName, "Search");
	//Count used for running status messages.
	sListCount = 0;
	sProgress = 0;
	for (i = 0; (i < sCnt) && (rc == 0); i++) {
		strcpy (szStatText, "Scanning Disk C:  Directory Count: ");
		szStatText[14] = (char)sDrives[i];
		SetStatusBarText (hWnd, szStatText, 0);
		pszStatEnd = szStatText + strlen (szStatText);	
		itoa (sProgress, pszStatEnd, 10);
		rc = ScanDisk (hWnd, lpSrchEntry, (char) sDrives[i]);
		if (rc == 0x12)
			rc = 0;
	}
	GlobalUnlock (hMasterSeg);
	//Shrink the index block down to size necessary.
	hMasterSeg = GlobalReAlloc (hMasterSeg, (LONG)sMasterCount * 
	                            sizeof (LPLPMYDIRENTRY), GMEM_ZEROINIT);
	if (hMasterSeg == 0)
		rc = ERR_OUTOFMEM;
	lpMasterPtr = (LPLPMYDIRENTRY) GlobalLock (hMasterSeg);
	return rc;
}
//============================================================  
// General Helper Routines 
//============================================================  
//------------------------------------------------------------
// MyDisplayDialog - Display a dialog box
//------------------------------------------------------------ 
INT MyDisplayDialog (HINSTANCE hInstance, LPCSTR szDlgName,
                     HWND hWnd, WNDPROC lpDialogProc, 
                     LPARAM lParam) {
    WNDPROC lpDlgProcInst;
    INT		rc;

    lpDlgProcInst = MakeProcInstance(lpDialogProc, hInst);
    rc = DialogBoxParam (hInstance, szDlgName, hWnd, 
                         lpDlgProcInst, lParam);
    FreeProcInstance(lpDlgProcInst);
    return rc;                              
}
//------------------------------------------------------------
// MyWritePrivateProfileInt - Writes an integer to the profile
//------------------------------------------------------------
BOOL MyWritePrivateProfileInt (char *szSec, char *szEntry, 
                               int Num, int Base, char *szProfile) {
	char	szStr[33];
	                           
	itoa (Num, szStr, Base);
	return WritePrivateProfileString (szSec, szEntry, szStr, 
	                                  szProfile);
}
//------------------------------------------------------------
// MySubClassWindow - Subclasses a window 
//------------------------------------------------------------
WNDPROC MySubClassWindow (HWND hWnd, WNDPROC lpfnNewProc) {
   WNDPROC lpfnOldProc;

	lpfnOldProc = (WNDPROC) GetWindowLong (hWnd, GWL_WNDPROC);
	SetWindowLong (hWnd, GWL_WNDPROC, (LONG) lpfnNewProc);
	return lpfnOldProc;				               
}				               
//------------------------------------------------------------
// MyYield - Yields control to other programs, but returns
// if Windows is idle.
//------------------------------------------------------------
BOOL MyYield (void) {
   MSG	msg;
   BOOL	bCont;
   
   bCont = TRUE;
	while (PeekMessage (&msg, NULL, 0, 0, PM_REMOVE)) {
	   if (msg.message == WM_QUIT)
	      bCont = FALSE;
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
	return bCont;
}
