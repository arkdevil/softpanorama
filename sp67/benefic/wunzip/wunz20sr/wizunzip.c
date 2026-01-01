/****************************************************************************

    PROGRAM: WizUnZip.c

    PURPOSE:  Windows Info-ZIP Unzip, an Unzipper for Windows
    FUNCTIONS:

        WinMain() - calls initialization function, processes message loop
        WizUnzipInit() - initializes window data and registers window
        WizUnzipWndProc() - processes messages
        About() - processes messages for "About" dialog box

    AUTHOR: Robert A. Heath,  157 Chartwell Rd. Columbia, SC 29210
    I place this source module, WizUnzip.c, in the public domain.  Use it as you will.
****************************************************************************/

#include <sys\types.h>
#include <sys\stat.h>
#include <time.h>                
#include <string.h>             
#include "wizunzip.h"


static char __based(__segname("STRINGS_TEXT")) szFirstUse[] = "FirstUse"; /* first use keyword in WIN.INI */
char __based(__segname("STRINGS_TEXT")) szDefaultUnzipToDir[] = "DefaultUnzipToDir";
char __based(__segname("STRINGS_TEXT")) szFormatKey[] = "Format";       /* Format keyword in WIN.INI        */
char __based(__segname("STRINGS_TEXT")) szOverwriteKey[] = "Overwrite"; /* Overwrite keyword in WIN.INI     */
char __based(__segname("STRINGS_TEXT")) szTranslateKey[] = "Translate"; /* Translate keyword in WIN.INI     */
char __based(__segname("STRINGS_TEXT")) szLBSelectionKey[] = "LBSelection"; /* LBSelection keyword in WIN.INI */
char __based(__segname("STRINGS_TEXT")) szRecreateDirsKey[] = "Re-createDirs"; /* re-create directory structure WIN.INI keyword             */
char __based(__segname("STRINGS_TEXT")) szUnzipToZipDirKey[] = "UnzipToZipDir"; /* unzip to .ZIP dir WIN.INI keyword */
char __based(__segname("STRINGS_TEXT")) szHideStatus[] = "HideStatusWindow";
char __based(__segname("STRINGS_TEXT")) szAutoClearStatusKey[] = "AutoClearStatus";
char __based(__segname("STRINGS_TEXT")) szHelpFileName[] = "WIZUNZIP.HLP";
char __based(__segname("STRINGS_TEXT")) szWizUnzipIniFile[] = "WIZUNZIP.INI";
char __based(__segname("STRINGS_TEXT")) szYes[] = "yes";
char __based(__segname("STRINGS_TEXT")) szNo[] = "no";

/* File and Path Name variables */
char __based(__segname("STRINGS_TEXT")) szAppName[] = "WizUnZip";       /* application title        */
char __based(__segname("STRINGS_TEXT")) szStatusClass[] = "MsgWndw";/* status window class  */
                                                
/* Values for listbox selection WIN.INI keyword
 */
char * LBSelectionTable[] = {
    "extract", "display", "test" 
};
#define LBSELECTIONTABLE_ENTRIES (sizeof(LBSelectionTable)/sizeof(char *))

HANDLE hInst;               /* current instance */
HMENU  hMenu;               /* main menu handle */
HANDLE hAccTable;

HANDLE hHourGlass;          /* handle to hourglass cursor        */
HANDLE hSaveCursor;         /* current cursor handle         */
HANDLE hHelpCursor;         /* help cursor                      */
HANDLE hFixedFont;          /* handle to fixed font             */
HANDLE hOldFont;            /* handle to old font               */

int hFile;                /* file handle             */
HWND hWndMain;        /* the main window handle.                */
HWND hWndList;            /* list box handle        */
HWND hWndStatus;        /* status   (a.k.a. Messages) window */
HWND hExtract;          /* extract button               */
HWND hDisplay;          /*display button                */
HWND hTest;             /* test button              */
HWND hShowComment;          /* show comment button          */

UF  uf;


WORD wLBSelection = IDM_LB_DISPLAY; /* default listbox selection action */
WORD wWindowSelection = IDM_SPLIT; /* window selection: listbox, status, both	*/


HBRUSH hBrush ;         /* brush for  standard window backgrounds  */

LPUMB   lpumb;
HANDLE  hStrings;

int ofretval;       /* return value from initial open if filename given */

WORD cZippedFiles;      /* total personal records in file   */
WORD cListBoxLines; /* max list box lines showing on screen */
WORD cLinesMessageWin; /* max visible lines on message window  */
WORD cchComment;            /* length of comment in .ZIP file   */


/* Forward References */
int PASCAL WinMain(HANDLE, HANDLE, LPSTR, int);
long FAR PASCAL WizUnzipWndProc(HWND, WORD, WORD, LONG);


/****************************************************************************

    FUNCTION: WinMain(HANDLE, HANDLE, LPSTR, int)

    PURPOSE: calls initialization function, processes message loop

    COMMENTS:

        This will initialize the window class if it is the first time this
        application is run.  It then creates the window, and processes the
        message loop until a WM_QUIT message is received.  It exits the
        application by returning the value passed by the PostQuitMessage.

****************************************************************************/

int PASCAL WinMain(hInstance, hPrevInstance, lpCmdLine, nCmdShow)
HANDLE hInstance;         /* current instance             */
HANDLE hPrevInstance;     /* previous instance            */
LPSTR lpCmdLine;          /* command line                 */
int nCmdShow;             /* show-window type (open/icon) */
{
    int i;
	BOOL fFirstUse;			/* first use if TRUE			*/


    if (!hPrevInstance)                 /* Has application been initialized? */
        if (!WizUnzipInit(hInstance))
            return 0;              /* Exits if unable to initialize     */


    hStrings = GlobalAlloc( GPTR, (DWORD)sizeof(UMB));
    if ( !hStrings )
        return 0;

    lpumb = (LPUMB)GlobalLock( hStrings );
    if ( !lpumb )
    {
        GlobalFree( hStrings );
        return 0;
    }

    uf.fCanDragDrop = FALSE;
    if (hHourGlass = GetModuleHandle("SHELL"))
    {
        if (GetProcAddress(hHourGlass, "DragAcceptFiles" ))
            uf.fCanDragDrop = TRUE;
    }
    
    if (_fstrlen(lpCmdLine))            /* if filename passed on start-up   */
    {
        if ((ofretval = OpenFile(lpCmdLine, &lpumb->of, OF_EXIST)) >= 0)
			lstrcpy(lpumb->szFileName, lpumb->of.szPathName); /* save file name */

    }

	/* If first time using WizUnzip 2.0, migrate any of earlier WizUnZip options from WIN.INI 
	 * to WIZUNZIP.INI.
	 */
    GetPrivateProfileString(szAppName, szFirstUse, szYes, lpumb->szBuffer, 256, szWizUnzipIniFile);
    if (fFirstUse = !lstrcmpi(lpumb->szBuffer, szYes)) /* first time used as WizUnZip 2.0	*/
	{

   		GetProfileString(szAppName, szRecreateDirsKey, szYes, lpumb->szBuffer, OPTIONS_BUFFER_LEN);
		WritePrivateProfileString(szAppName, szRecreateDirsKey, lpumb->szBuffer, szWizUnzipIniFile);

		/* Don't propagate translate option. Its meaning has changed. Use default: No	*/

	    GetProfileString(szAppName, szOverwriteKey, szNo, lpumb->szBuffer, OPTIONS_BUFFER_LEN);
		WritePrivateProfileString(szAppName, szOverwriteKey, lpumb->szBuffer, szWizUnzipIniFile);

		GetProfileString(szAppName, szFormatKey, "long", lpumb->szBuffer, OPTIONS_BUFFER_LEN);
		WritePrivateProfileString(szAppName, szFormatKey, lpumb->szBuffer, szWizUnzipIniFile);

    	GetProfileString(szAppName, szUnzipToZipDirKey, szNo, lpumb->szBuffer, OPTIONS_BUFFER_LEN);
		WritePrivateProfileString(szAppName, szUnzipToZipDirKey, lpumb->szBuffer, szWizUnzipIniFile);
    
		GetProfileString(szAppName, szLBSelectionKey, "display", lpumb->szBuffer, OPTIONS_BUFFER_LEN);
		WritePrivateProfileString(szAppName, szLBSelectionKey, lpumb->szBuffer, szWizUnzipIniFile);

 		MigrateSoundOptions();	/* Translate former beep option to new sound option	*/

		WriteProfileString(szAppName, NULL, NULL); /* delete [wizunzip] section of WIN.INI file */

		/* Flag that this is no longer the first time.										*/
		WritePrivateProfileString(szAppName, szFirstUse, szNo, szWizUnzipIniFile);

		/* After first use, all options come out of WIZUNZIP.INI file						*/
	}

    /* Get initial Re-create dirs format */
    GetPrivateProfileString(szAppName, szRecreateDirsKey, szYes, lpumb->szBuffer, OPTIONS_BUFFER_LEN, szWizUnzipIniFile);
    uf.fRecreateDirs = (BOOL)(!lstrcmpi(lpumb->szBuffer, szYes));

    /* Get translate flag */
    GetPrivateProfileString(szAppName, szTranslateKey, szNo, lpumb->szBuffer, OPTIONS_BUFFER_LEN, szWizUnzipIniFile);
    uf.fTranslate = (BOOL)(!lstrcmpi(lpumb->szBuffer, szYes));

    /* Get initial display format: short or long */
    GetPrivateProfileString(szAppName, szFormatKey, "long", lpumb->szBuffer, OPTIONS_BUFFER_LEN, szWizUnzipIniFile);
    uf.fFormatLong = (WORD)(!lstrcmpi(lpumb->szBuffer, "long") ? 1 : 0);

    /* Get overwrite option: yes=IDM_OVERWRITE, no=IDM_PROMPT */
    GetPrivateProfileString(szAppName, szOverwriteKey, szNo, lpumb->szBuffer, OPTIONS_BUFFER_LEN, szWizUnzipIniFile);
    uf.fOverwrite = (BOOL)(!lstrcmpi(lpumb->szBuffer, szYes));

    /* Get Unzip to .ZIP dir option: yes or no  */
    GetPrivateProfileString(szAppName, szUnzipToZipDirKey, szNo, lpumb->szBuffer, OPTIONS_BUFFER_LEN, szWizUnzipIniFile);
    uf.fUnzipToZipDir = (BOOL)(!lstrcmpi(lpumb->szBuffer, szYes));
	/* Get default "unzip-to" directory */
	GetPrivateProfileString(szAppName, szDefaultUnzipToDir, "", lpumb->szUnzipToDirName, WIZUNZIP_MAX_PATH, szWizUnzipIniFile);
    /* Get Automatically Clear Status Window option */
    GetPrivateProfileString(szAppName, szAutoClearStatusKey, szNo, lpumb->szBuffer, OPTIONS_BUFFER_LEN, szWizUnzipIniFile);
    uf.fAutoClearStatus = (BOOL)(!lstrcmpi(lpumb->szBuffer, szYes));

    /* Get default listbox selection operation */
    GetPrivateProfileString(szAppName, szLBSelectionKey, "display", lpumb->szBuffer, OPTIONS_BUFFER_LEN, szWizUnzipIniFile);

    for (i = 0; i < LBSELECTIONTABLE_ENTRIES &&
        lstrcmpi(LBSelectionTable[i], lpumb->szBuffer) ; i++)
    {
        ;
    }
	InitSoundOptions();					/* initialize sound options			*/
    wLBSelection = IDM_LB_DISPLAY;      /* assume default is to display     */
    if (i < LBSELECTIONTABLE_ENTRIES)
        wLBSelection = IDM_LB_EXTRACT + i;

    hWndMain = CreateWindow(szAppName,  /* window class     */
        szAppName,                      /* window name      */
        WS_OVERLAPPEDWINDOW,            /* window style     */
        0,                              /* x position       */
        0,                              /* y position       */
        CW_USEDEFAULT,                  /* width            */
        0,                              /* height           */
        (HWND)0,                        /* parent handle    */
        (HWND)0,                        /* menu or child ID */
        hInstance,                      /* instance         */
        NULL);                          /* additional info  */

    if ( !hWndMain )
        return 0;

    /* On first use, throw up About box, saying what WizUnZip is, etc.
     */
    if (fFirstUse)
    {
        PostMessage(hWndMain, WM_COMMAND, IDM_ABOUT, 0L);
    }
    hHelpCursor = LoadCursor(hInstance, "HelpCursor");

    ShowWindow(hWndMain, nCmdShow);
    UpdateWindow(hWndMain);

    while ( GetMessage(&lpumb->msg, 0, 0, 0) )
    {
		if (hPatternSelectDlg == 0 || /* Pattern select dialog is non-modal	*/
			!IsDialogMessage(hPatternSelectDlg, &lpumb->msg))
		{
        	if ( !TranslateAccelerator(hWndMain, hAccTable, &lpumb->msg) )
        	{
        	    TranslateMessage(&lpumb->msg);
        	    DispatchMessage(&lpumb->msg);
        	}
		}
    }
    /* Don't turn on compiler aliasing or C7 will move */
    /* the following assignment after the GlobalFree() */
    /* which contains the memory for pumb! */
    i = (int)lpumb->msg.wParam;

    GlobalUnlock( hStrings );
    GlobalFree( hStrings );

    return i;
}
