//===========================================================
// FDDLLS.H -- Header File 
// Copyright (c) 1994 Douglas Boling
//===========================================================
// Equates used by program
#define MAXCOUNT          16384
#define MAXFNAMELEN       256
#define FUNCTYPES         3

#define DOSERROFFSET      16
#define ERR_CANCELED      -1
#define ERR_OUTOFMEM      -2
#define ERR_TOOMANYFILES  -3
#define ERR_TOODEEP       -4
#define ERR_DISKFULL      -5
#define ERR_NAMETOOLONG   -6
#define ERR_BADNAME       -7 
#define ERR_BADSIZE       -8 
#define ERR_BADDATE       -9 
#define ERR_NOOPENEXE    -10
#define ERR_BADSETUP     -11

#define ATTR_DUP          0x40
#define ATTR_DELETED      0x80

#define MYMSG_SCAN        WM_USER+10
//-----------------------------------------------------------
// Generic defines and data types
//-----------------------------------------------------------
#define WIN16     TRUE

#define INT       int
#define UINT      WORD
#define APIENTRY  PASCAL
#define WNDPROC   FARPROC

typedef UINT  *PUINT;
typedef UINT far *LPUINT;

struct decodeUINT {                         // structure associates
    UINT Code;                              // messages 
    LONG (*Fxn)(HWND, UINT, UINT, LONG);    // with a function
}; 
struct decodeCMD {                          // structure associates
    UINT Code;                              // menu IDs with a 
    LONG (*Fxn)(HWND, UINT, HWND, UINT);    // function
};
//
// Function prototypes used by generic template
//
INT  APIENTRY WinMain(HANDLE, HANDLE, LPSTR, INT);
LONG CALLBACK MainWndProc(HWND, UINT, UINT, LONG);

INT  InitApp(HANDLE);
INT  InitInstance(HANDLE, LPSTR, INT);
INT  TermInstance(HANDLE, INT);
INT  MyDisplayDialog (HINSTANCE, LPCSTR, HWND, WNDPROC, LPARAM);
BOOL MyWritePrivateProfileInt (char *, char *, int, int, char *);
WNDPROC MySubClassWindow (HWND, WNDPROC);
INT MyCopyFile (char *, char *);
//
// Data types needed for program
//
typedef struct {
	UINT selNext;
	UINT usEnd;
	UINT usSize;
} BUFFHDR;
typedef BUFFHDR far *LPBUFFHDR;

typedef struct {
	LPVOID lpParent;
	LONG lUseCnt;
	INT sType;
	UINT usChildCnt;
	UINT usBadCnt;
	char szModName[14];
	BYTE ucAttrib;                           // The remainder of this structure
	UINT usTime;                             // must match the C file search 
	UINT usDate;                             // structure.
	LONG lSize;
	char szName[13];
} MYDIRENTRY;	   
typedef MYDIRENTRY far * LPMYDIRENTRY;
typedef LPMYDIRENTRY huge * LPLPMYDIRENTRY;

typedef DWORD huge *HPDWORD;

typedef struct find_t FIND_T;
typedef struct DOSERROR DOSERR;
//
// Program specific prototypes
//
// Dialog functions
BOOL CALLBACK AboutDlgProc (HWND, UINT, UINT, LONG);
BOOL CALLBACK ScanDlgProc (HWND, UINT, UINT, LONG);
BOOL CALLBACK SelDisksDlgProc (HWND, UINT, UINT, LONG);
BOOL CALLBACK FileInfoDlgProc (HWND, UINT, UINT, LONG);
// Message handler functions
LONG DoCreateMain (HWND, UINT, UINT, LONG);
LONG DoInitMenuMain (HWND, UINT, UINT, LONG);
LONG DoSizeMain (HWND, UINT, UINT, LONG);
LONG DoPaintMain (HWND, UINT, UINT, LONG);
LONG DoSetFocusMain (HWND, UINT, UINT, LONG);
LONG DoDrawItemMain (HWND, UINT, UINT, LONG);
LONG DoMeasureItemMain (HWND, UINT, UINT, LONG);
LONG DoCompareItemMain (HWND, UINT, UINT, LONG);
LONG DoCloseMain (HWND, UINT, UINT, LONG);
LONG DoDestroyMain (HWND, UINT, UINT, LONG);
LONG DoMyMsgScanMain (HWND, UINT, UINT, LONG);
LONG DoCommandMain (HWND, UINT, UINT, LONG);
// Control function Prototypes
LONG DoMainCtlFList (HWND, UINT, HWND, UINT);
LONG DoMainMenuScan (HWND, UINT, HWND, UINT);
LONG DoMainMenuSelDisks (HWND, UINT, HWND, UINT);
LONG DoMainMenuStop (HWND, UINT, HWND, UINT);
LONG DoMainMenuOpen (HWND, UINT, HWND, UINT);
LONG DoMainMenuExit (HWND, UINT, HWND, UINT);
LONG DoMainMenuShow (HWND, UINT, HWND, UINT);
LONG DoMainMenuShowPath (HWND, UINT, HWND, UINT);
LONG DoMainMenuSort (HWND, UINT, HWND, UINT);
LONG DoMainMenuAbout (HWND, UINT, HWND, UINT);
// Utility function prototypes
INT ChkFile (UINT, BOOL);
INT CheckAllFiles (HWND);
INT FreeBuffer (UINT);
void Date2asc (UINT, UINT, char *);
void Attr2asc (BYTE, char *);
INT CreatePath (LPMYDIRENTRY, char *, INT);
void DisplayCurrStatus (HWND);
BOOL MyYield (void);
INT ScanDisk (HWND, LPMYDIRENTRY, char);
INT ScanMachine (HWND, INT, INT *);
void FillLB (HWND);
void PrintError (HWND, INT);
//
// Profile String Names
//
#define     PRO_XPOS      "WinPosX"
#define     PRO_YPOS      "WinPosY"
#define     PRO_XSIZE     "WinSizeX"
#define     PRO_YSIZE     "WinSizeY"
//
// Resource Identifiers
//
#define     MENU_VIEW        2

#define     IDD_FLIST        100

#define     IDM_SCAN         200
#define     IDM_SELDISKS     201
#define     IDM_STOP	     202
#define     IDM_OPEN	     203
#define     IDM_EXIT	     204

#define     IDM_SHOWBOTH     221
#define     IDM_SHOWEXES     222
#define     IDM_SHOWDLLS     223
#define     IDM_SHOWPATH     224

#define     IDM_SORTNAME     230     //Keep sort IDs in this order
#define     IDM_SORTEXTS     231
#define     IDM_SORTPATH     232
#define     IDM_SORTMOD      233
#define     IDM_SORTREFS     234

#define     IDM_ABOUT	     260

#define     IDD_TEXT         301
#define     IDD_SELDISKS     302

#define     IDD_DRVLIST      401
#define     IDD_SCAN         402

#define     IDD_IFILENAME    500
#define     IDD_IFILEPATH    501
#define     IDD_IFILESIZE    502
#define     IDD_IFILEDATE    503
#define     IDD_IFILEATTRS   504
#define     IDD_IFILEMODNAME 505
#define     IDD_IFILEREFS    506
#define     IDD_IFILEDEP     507
#define     IDD_IFILEBACK    508
#define     IDD_IFILECA      509

#define     IDD_PROGSTR      600
#define     IDD_COPYRIGHT    601
#define     IDD_COPYDATE     602



