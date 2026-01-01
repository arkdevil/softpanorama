// snap.h

// string table definitions

#define IDS_NAME      1

// menu defines

#define IDM_START	101
#define IDM_CLEAR	102
#define IDM_ABOUT	103
#define IDM_HELP	104

// dialog box resource id'S

#define ABOUT         1

// function declarations

long FAR PASCAL WndProc(HWND hWnd, WORD message, WORD wParam, LONG lParam);
BOOL FAR PASCAL About(HWND hDlg, WORD message, WORD wParam, LONG lParam);
void		OutlineBlock(HWND hWnd, POINT beg, POINT end);
