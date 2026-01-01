#include <windows.h>
#include <assert.h>    /* required for all Windows applications */
#include <commdlg.h>
#include <dlgs.h>

/* Main include file for  Windows Unzip: unzip.h
 * This include file is copied into all `C' source modules specific to 
 * Windows Info-ZIP Unzip, version 2.0.
 * Author: Robert A. Heath, 157 Chartwell Rd., Columbia, SC 29210
 * I, Robert A. Heath, place this module, wizunzip.h, in the public domain.
 */

#define WIZUNZIP_MAX_PATH 128	/* max total file or directory name path	*/
#define OPTIONS_BUFFER_LEN 256	/* buffer to hold .INI file options			*/

/* These two are dependent on zip directory listing format string.
 * They help find the filename in the listbox entry.
 */
#define SHORT_FORM_FNAME_INX    27
#define LONG_FORM_FNAME_INX 58

#define MIN_SHORT_FORMAT_CHARS (SHORT_FORM_FNAME_INX+12)
#define MIN_LONG_FORMAT_CHARS (LONG_FORM_FNAME_INX+12)

/* Arbitrary Constants
 */
#define BG_SYS_COLOR COLOR_GRAYTEXT /* background color is a system color */

/* Main window menu item positions
 */
#define EDIT_MENUITEM_POS		1	/* edit menu position in main menu */
#define HELP_MENUITEM_POS       5   /* the Help menu                */

/* Main Window Message Codes
 */

#define IDM_OPEN            101
#define IDM_EXIT            102

#define IDM_SHORT           104
#define IDM_LONG            105


#define IDM_HELP            106
#define IDM_ABOUT           107

#define IDM_RECR_DIR_STRUCT 108
#define IDM_OVERWRITE       109
#define IDM_TRANSLATE       110
#define IDM_UNZIP_TO_ZIP_DIR 111

#define IDM_EDIT            112
#define IDM_PATH            113


#define IDM_COMMENT         117
#define IDM_SOUND_OPTIONS   118
#define IDM_COPY			119
#define IDM_SELECT_ALL      120

/* These six items are the tab-stop windows whose ID's must be kept
 * in order.
 */
#define IDM_LISTBOX         121
#define IDM_EXTRACT         122
#define IDM_DISPLAY         123
#define IDM_TEST            124
#define IDM_SHOW_COMMENT    125
#define IDM_STATUS          126
#define TABSTOP_ID_BASE IDM_LISTBOX


#define IDM_AUTOCLEAR_STATUS 129
#define IDM_SELECT_BY_PATTERN 130

/* Keep these 3 in order */
#define IDM_SPLIT			131
#define IDM_MAX_LISTBOX		132
#define IDM_MAX_STATUS		133

/* Keep these 3 in order */
#define IDM_LB_EXTRACT      135
#define IDM_LB_DISPLAY      136
#define IDM_LB_TEST         137

#define IDM_DESELECT_ALL    138
#define IDM_CLEAR_STATUS    139
#define IDM_HELP_KEYBOARD   140
#define IDM_HELP_HELP       141
#define IDM_CHDIR           142
#define IDM_SETFOCUS_ON_STATUS 143 /* internal: posted after extraction to Status window */


/* Help Window Menu and Message ID's
 */
#define INDEX_MENU_ITEM_POS 0

#define IDM_FORWARD 100
#define IDM_BACKWARD 101 


/* Tab-stop table is used to sub-class those main window items to
 * which the tab and back-tab keys will tab and stop.
 */
typedef struct TabStop_tag {
    FARPROC lpfnOldFunc;        /* original function                */
    HWND hWnd ;         
} TabStopEntry;

typedef TabStopEntry *PTABSTOPENTRY;
#define TABSTOP_TABLE_ENTRIES 6


#ifndef NDEBUG
#define WinAssert(exp) \
        {\
        if (!(exp))\
            {\
            char szBuffer[40];\
            sprintf(szBuffer, "File %s, Line %d",\
                    __FILE__, __LINE__) ;\
            if (IDABORT == MessageBox((HWND)NULL, szBuffer,\
                "Assertion Error",\
                MB_ABORTRETRYIGNORE|MB_ICONSTOP))\
                    FatalExit(-1);\
            }\
        }

#else

#define WinAssert(exp)

#endif


/* Unzip Flags */
typedef struct
{
    unsigned int    fRecreateDirs : 1;
    unsigned int    fTranslate : 1;
    unsigned int    fFormatLong : 1;
    unsigned int    fOverwrite : 1;
    unsigned int    fUnzipToZipDir : 1;
    unsigned int    fBeepOnFinish : 1;
    unsigned int    fDoAll : 1;
    unsigned int    fIconSwitched : 1;
    unsigned int    fHelp : 1;
    unsigned int    fCanDragDrop : 1;
	unsigned int	fAutoClearStatus : 1;
    unsigned int    fUnused : 5;
} UF, *PUF;

/* Unzip Miscellaneous Buffers */
typedef struct
{
    char szFileName[WIZUNZIP_MAX_PATH];     /* fully-qualified archive file name in OEM char set */
    char szDirName[WIZUNZIP_MAX_PATH];		/* directory of archive file in ANSI char set */
    char szUnzipToDirName[WIZUNZIP_MAX_PATH];  /* extraction ("unzip to") directory name in ANSI */
    char szUnzipToDirNameTmp[WIZUNZIP_MAX_PATH]; /* temp extraction ("unzip to") directory name in ANSI */
    char szTotalsLine[80];      			/* text for totals of zip archive */
    char szBuffer[OPTIONS_BUFFER_LEN];      /* option strings from .INI, & gen'l scratch buf */
	char szSoundName[WIZUNZIP_MAX_PATH];	/* wave file name or sound from WIN.INI [sounds] in ANSI */
    OPENFILENAME ofn;
    OPENFILENAME wofn;						/* wave open file name struct */
    MSG msg;
    OFSTRUCT of;							/* archive open file struct */
    OFSTRUCT wof;							/* wave open file struct	*/
} UMB, __far *LPUMB;

extern TabStopEntry TabStopTable[]; /* tab-stop control table           */

extern short dxChar, dyChar;    /* size of char in SYSTEM font in pixels    */

extern HANDLE hFixedFont;

extern HWND hWndComment;        /* comment window                       */
extern HWND hWndList;       /* listbox handle                       */

extern HWND hWndMain;        /* the main window handle.         */

extern HWND hExtract;           /* extract button               */
extern HWND hDisplay;           /*display button                */
extern HWND hTest;              /* test button                  */
extern HWND hShowComment;       /* show comment button          */
extern HWND hPatternSelectDlg; /* pattern select modeless dialog	*/
extern HANDLE hInst;                       /* current instance                      */
extern HMENU  hMenu;                /* main menu handle         */
extern HANDLE hAccTable;

extern HANDLE hHourGlass;             /* handle to hourglass cursor      */
extern HANDLE hSaveCursor;            /* current cursor handle       */
extern HANDLE hHelpCursor;          /* help cursor              */
extern HANDLE hFixedFont;           /* handle to fixed font             */
extern HANDLE hOldFont;         /* handle to old font               */

extern int hFile;                 /* file handle             */
extern HWND hWndList;             /* list box handle        */
extern HWND hWndStatus;     /* status   */
extern BOOL bRealTimeMsgUpdate; /* update messages window in real-time */
extern BOOL gfCancelDisplay;	/* cancel ongoing display operation */
extern UF uf;

extern WORD wLBSelection;   /* default listbox selection action */
extern WORD wWindowSelection; /* window selection: listbox, status, both	*/

extern HBRUSH hBrush ;          /* brush for  standard window backgrounds  */

extern char __based(__segname("STRINGS_TEXT")) szAppName[];     /* application name             */
extern char __based(__segname("STRINGS_TEXT")) szDefaultUnzipToDir[]; /* default unzip to dir */
extern char __based(__segname("STRINGS_TEXT")) szStatusClass[]; /* status class name                */
extern char __based(__segname("STRINGS_TEXT")) szFormatKey[];       /* Format .INI keyword       */
extern char __based(__segname("STRINGS_TEXT")) szOverwriteKey[];    /* Overwrite .INI keyword        */
extern char __based(__segname("STRINGS_TEXT")) szTranslateKey[];    /* Translate .INI keyword        */
extern char __based(__segname("STRINGS_TEXT")) szLBSelectionKey[];  /* LBSelection keyword in .INI */
extern char __based(__segname("STRINGS_TEXT")) szRecreateDirsKey[]; /* re-create directory structure 
                                    .INI keyword             */
extern char __based(__segname("STRINGS_TEXT")) szUnzipToZipDirKey[];   /* unzip to .ZIP dir .INI keyword */
extern char __based(__segname("STRINGS_TEXT")) szAutoClearStatusKey[];   /* autoclear status .INI keyword */
extern char * LBSelectionTable[];
extern char __based(__segname("STRINGS_TEXT")) szNoMemory[] ;       /* error message            */
extern char __based(__segname("STRINGS_TEXT")) szHelpFileName[];        /* help file name                       */
extern char __based(__segname("STRINGS_TEXT")) szWizUnzipIniFile[];	/* WizUnzip Private .INI file */
extern char __based(__segname("STRINGS_TEXT")) szYes[];
extern char __based(__segname("STRINGS_TEXT")) szNo[];
extern char * Headers[][2] ;        /* headers to display           */

extern WORD cchComment; /* length of comment in .ZIP file   */

extern LPUMB lpumb;

/* List box stuff
 */
extern WORD cZippedFiles;       /* total personal records in file   */
extern WORD cListBoxLines; /* max list box lines showing on screen */
extern WORD cLinesMessageWin; /* max visible lines on message window  */

/* Function Prototypes */

void SetCaption(HWND hWnd);

/* some global functions */
void Action(HWND hWnd, WORD wActionCode);
void CenterDialog(HWND hwndParent, HWND hwndDlg);
void CopyStatusToClipboard(HWND hWnd);
void DisplayComment(HWND hWnd);
int CLBItemsGet(HWND hListBox, int __far * __far *ppnSelItems, HANDLE *phnd);
void ReselectLB(HWND hListBox, int nSelCount, int __far *pnSelItems);
BOOL FSetUpToProcessZipFile(int ncflag, int ntflag, int nvflag, int nUflag, 
                            int nzflag, int ndflag, int noflag, int naflag,
                            int argc, LPSTR lpszZipFN, PSTR *FNV);
void InitSoundOptions(void); /* initialize sound options (sound.c)	*/
void MigrateSoundOptions(void); /* translate beep into new option (sound.c) */
void TakeDownFromProcessZipFile(void);
void SetStatusTopWndPos(void);
void SizeWindow(HWND hWnd, BOOL bOKtoMovehWnd);
void SoundAfter(void);
void SoundDuring(void);
BOOL StatusInWindow(void);
void UpdateButtons(HWND hWnd);
void UpdateListBox(HWND hWnd);
void UpdateMsgWndPos(void);
BOOL WizUnzipInit(HANDLE hInst);
void WriteBufferToMsgWin(LPSTR buffer, int nBufferLen, BOOL bUpdate);
void WriteStringToMsgWin(PSTR String, BOOL bUpdate);

/* Far Proc's */
BOOL FAR PASCAL AboutProc(HWND, WORD, WORD, LONG);
BOOL FAR PASCAL SelectDirProc(HWND, WORD, WORD, LONG);
long FAR PASCAL KbdProc(HWND, WORD, WORD, LONG);
BOOL FAR PASCAL PatternSelectProc(HWND, WORD, WORD, LONG);
BOOL FAR PASCAL ReplaceProc(HWND, WORD, WORD, LONG);
BOOL FAR PASCAL SoundProc(HWND, WORD, WORD, LONG);
long FAR PASCAL StatusProc (HWND, WORD, WORD, LONG); 
BOOL FAR PASCAL RenameProc (HWND, WORD, WORD, LONG); 
