// winapp.h

// string table definitions

#define IDS_NAME      1

// menu defines

#define IDM_NEW		101
#define IDM_OPEN	102
#define IDM_MOVE	103
#define IDM_COPY	104
#define IDM_DEL		105
#define IDM_PROP	106
#define IDM_EXIT	107

#define IDM_AUTO	108
#define IDM_MINI	109

#define IDM_CASC	110
#define IDM_TILE	111
#define IDM_MOVW	112

#define IDM_NDX		113
#define IDM_KEYB	114
#define IDM_SKIL	115
#define IDM_COMM	116
#define IDM_PROC	117
#define IDM_GLOS	118
#define IDM_USIN	119
#define IDM_ABOUT	120


// dialog box resource id'S

#define ABOUT         1

// function declarations

long FAR PASCAL WndProc(HWND hWnd, WORD message, WORD wParam, LONG lParam);
BOOL FAR PASCAL About(HWND hDlg, WORD message, WORD wParam, LONG lParam);
