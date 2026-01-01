#include <sys\types.h>
#include <sys\stat.h>
#include <time.h>                
#include <string.h>             
#include "wizunzip.h"
#include "helpids.h"
#include <shellapi.h>


/* Windows Info-ZIP Unzip Window Procedure, wndproc.c.
 * Author: Robert A. Heath, 157 Chartwell Rd., Columbia, SC 29210
 * I, Robert Heath, place this source code module in the public domain.
 */

#define MAKE_TABSTOP_TABLE_ENTRY(WNDHANDLE, ID) \
    { \
        TabStopTable[ID - TABSTOP_ID_BASE].lpfnOldFunc = \
            (FARPROC)GetWindowLong(WNDHANDLE, GWL_WNDPROC); \
        SetWindowLong(WNDHANDLE, GWL_WNDPROC, (LONG)lpfnKbd); \
        TabStopTable[ID - TABSTOP_ID_BASE].hWnd = WNDHANDLE; \
    }

/* Forward Refs
 */
static void GetArchiveDir(LPSTR lpszDestDir);

HWND hPatternSelectDlg; /* pattern select modeless dialog	*/
static UINT uCommDlgHelpMsg;	/* common dialog help message ID */
static DWORD dwCommDlgHelpId = HELPID_HELP; /* what to pass to WinHelp() */

static char szFormatKeyword[2][6] = { "short", "long" };

/* Trailers are the lines just above the totals */
static char * __based(__segname("STRINGS_TEXT")) szTrailers[2] = {
" ------                    -------",
" ------          ------  ---                              -------"
} ;

static char __based(__segname("STRINGS_TEXT")) szCantChDir[] = 
	"Internal error: Cannot change directory. Common dialog error code is 0x%lX.";

/* size of char in SYSTEM font in pixels */
short dxChar, dyChar;

/* button control table -- one entry for 
 * each of 4 entries. Indexed by the window ID relative to
 * the first tabstop (TABSTOP_ID_BASE).         
 */
TabStopEntry TabStopTable[TABSTOP_TABLE_ENTRIES]; 


static LPSTR
lstrrchr(LPSTR lpszSrc, char chFind)
{
    LPSTR   lpszFound = (LPSTR)0;
    LPSTR   lpszT;
    
    if ( lpszSrc )
    {
        for (lpszT = lpszSrc; *lpszT; ++lpszT)
        {
            if ((*lpszT) == chFind)
                lpszFound = lpszT;
        }
    }
    
    return lpszFound;
}

/* Copy only the path portion of current file name into
 * given buffer, lpszDestDir, translate into ANSI.
 */
static void GetArchiveDir(LPSTR lpszDestDir)
{
LPSTR lpchLast;

	/* strip off filename to make directory name    */
	OemToAnsi(lpumb->szFileName, lpszDestDir);
	if (lpchLast = lstrrchr(lpszDestDir, '\\'))
		*lpchLast = '\0';

	else if (lpchLast = lstrrchr(lpszDestDir, ':'))
        *(++lpchLast) = '\0'; /* clobber char AFTER the colon! */

}


/****************************************************************************

    FUNCTION: SetCaption(HWND hWnd)
                

    PURPOSE: Set new caption for main window

****************************************************************************/
void 
SetCaption(HWND hWnd)
{
#define SIMPLE_NAME_LEN 15

    WORD wMenuState;
    char szSimpleFileName[SIMPLE_NAME_LEN+1];  /* just the 8.3 part in ANSI char set */
    LPSTR lpszFileNameT;        /* pointer to simple filename               */
    BOOL    fIconic = IsIconic(hWnd);   /* is window iconic ?   */

    /* point to simple filename in OEM char set                 */
    if ((lpszFileNameT = lstrrchr(lpumb->szFileName, '\\')) ||
        (lpszFileNameT = lstrrchr(lpumb->szFileName, ':')))
        lpszFileNameT++;
    else
        lpszFileNameT = lpumb->szFileName;

	_fstrncpy(szSimpleFileName, lpszFileNameT, SIMPLE_NAME_LEN);
	szSimpleFileName[SIMPLE_NAME_LEN] = '\0'; /* force termination */
    OemToAnsi(szSimpleFileName, szSimpleFileName);
    (void)wsprintf(lpumb->szBuffer, "%s - %s %s %s", 
                    (LPSTR)szAppName, 
                    (LPSTR)(szSimpleFileName[0] ? 
                        szSimpleFileName : "(No .ZIP file)"),
                    (LPSTR)(!fIconic && lpumb->szUnzipToDirName[0] ? " - " : ""),
                    (LPSTR)(!fIconic ? lpumb->szUnzipToDirName : ""));
    SetWindowText(hWnd, lpumb->szBuffer);
    wMenuState = (WORD)(szSimpleFileName[0] ? MF_ENABLED : MF_GRAYED) ;
    EnableMenuItem(hMenu, IDM_SELECT_ALL, wMenuState|MF_BYCOMMAND); 
    EnableMenuItem(hMenu, IDM_DESELECT_ALL, wMenuState|MF_BYCOMMAND); 
    EnableMenuItem(hMenu, IDM_SELECT_BY_PATTERN, wMenuState|MF_BYCOMMAND); 
}

static void ManageStatusWnd(WORD wParam);
static void ManageStatusWnd(WORD wParam)
{
int nWndState;  /* ShowWindow state     */
BOOL fWndEnabled;   /* Enable Window state */

    if (wParam == IDM_SPLIT)
    {
         ShowWindow(hWndStatus, SW_RESTORE);
         UpdateWindow(hWndStatus);
         fWndEnabled = TRUE;
         nWndState = SW_SHOWNORMAL;
    }
    else    /* Message window goes to maximum state     */
	{
         nWndState = SW_HIDE;    /* assume max state     */
         fWndEnabled = FALSE;
    }

	wWindowSelection = wParam; /* window selection: listbox, status, both	*/
    EnableWindow( hWndList, fWndEnabled);
    UpdateWindow( hWndList);
    ShowWindow( hWndList, nWndState);

    if (wParam == IDM_SPLIT) /* uncover buttons    */
    {
        UpdateButtons(hWndMain);    /* restore to proper state  */
    }
    else    /* else Message window occludes buttons         */
    {
        EnableWindow( hExtract, fWndEnabled);
        EnableWindow( hTest, fWndEnabled);
        EnableWindow( hDisplay, fWndEnabled);
        EnableWindow( hShowComment, fWndEnabled);
    }

    UpdateWindow( hExtract);
    ShowWindow( hExtract, nWndState);

    ShowWindow( hTest, nWndState);
    UpdateWindow( hTest);

    ShowWindow( hDisplay, nWndState);
    UpdateWindow( hDisplay);

    ShowWindow( hShowComment, nWndState);
    UpdateWindow( hShowComment);

    if (wParam == IDM_MAX_STATUS)   /* message box max'd out */
    {
        ShowWindow(hWndStatus, SW_SHOWMAXIMIZED);
    }
    SetFocus(hWndStatus);
    SizeWindow(hWndMain, FALSE);
}

/****************************************************************************

    FUNCTION: WizunzipWndProc(HWND, unsigned, WORD, LONG)

    PURPOSE:  Processes messages

    MESSAGES:

    WM_DESTROY      - destroy window
    WM_SIZE         - window size has changed
    WM_QUERYENDSESSION - willing to end session?
    WM_ENDSESSION   - end Windows session
    WM_CLOSE        - close the window
    WM_SIZE         - window resized
    WM_PAINT        - windows needs to be painted
    WM_DROPFILES    - open a dropped file
    COMMENTS:

    WM_COMMAND processing:

        IDM_OPEN -  open a new file.


        IDM_EXIT - query to save current file if there is one and it
               has been changed, then exit.

        IDM_ABOUT - display "About" box.

****************************************************************************/

long FAR PASCAL WizunzipWndProc(HWND hWnd, WORD wMessage, WORD wParam, LONG lParam)
{
    FARPROC lpfnAbout, lpfnSelectDir;

    HDC hDC;                /* device context       */
    TEXTMETRIC    tm;           /* text metric structure    */
    POINT point;
    FARPROC lpfnKbd;
	static int nCxBorder, nCyBorder;



    switch (wMessage)
    {
    case WM_CREATE: /* create  window       */
    	nCxBorder = GetSystemMetrics(SM_CXBORDER);
    	nCyBorder = GetSystemMetrics(SM_CYBORDER);
        hInst = ((LPCREATESTRUCT)lParam)->hInstance;
        lpfnKbd = MakeProcInstance((FARPROC)KbdProc, hInst);
        hAccTable = LoadAccelerators(hInst, "WizunzipAccels");
        hBrush = CreateSolidBrush(GetSysColor(BG_SYS_COLOR)); /* background */

        hMenu = GetMenu(hWnd);
        /* Check Menu items to reflect WIN.INI settings */
        CheckMenuItem(hMenu, IDM_RECR_DIR_STRUCT, MF_BYCOMMAND | 
                            (uf.fRecreateDirs ? MF_CHECKED : MF_UNCHECKED));
        CheckMenuItem(hMenu, (IDM_SHORT+uf.fFormatLong), MF_BYCOMMAND | MF_CHECKED);
        CheckMenuItem(hMenu, IDM_OVERWRITE, MF_BYCOMMAND |
                            (uf.fOverwrite ? MF_CHECKED : MF_UNCHECKED));
        CheckMenuItem(hMenu, IDM_TRANSLATE, MF_BYCOMMAND |
                            (uf.fTranslate ? MF_CHECKED : MF_UNCHECKED));
        CheckMenuItem(hMenu, wLBSelection, MF_BYCOMMAND | MF_CHECKED);
        CheckMenuItem(hMenu, IDM_UNZIP_TO_ZIP_DIR, MF_BYCOMMAND |
                            (uf.fUnzipToZipDir ? MF_CHECKED : MF_UNCHECKED));
        EnableMenuItem(hMenu, IDM_CHDIR, MF_BYCOMMAND |
                            (uf.fUnzipToZipDir ? MF_GRAYED : MF_ENABLED));
       	CheckMenuItem(hMenu, IDM_AUTOCLEAR_STATUS, MF_BYCOMMAND |
                            (uf.fAutoClearStatus ? MF_CHECKED : MF_UNCHECKED));

        /* Get an hourglass cursor to use during file transfers */
        hHourGlass = LoadCursor(0, IDC_WAIT);

        hFixedFont = GetStockObject(SYSTEM_FIXED_FONT);
        hDC = GetDC(hWnd);  /* get device context */
        hOldFont = SelectObject(hDC, hFixedFont);
        GetTextMetrics(hDC, &tm);
        ReleaseDC(hWnd, hDC);
        dxChar = tm.tmAveCharWidth;
        dyChar = tm.tmHeight + tm.tmExternalLeading; 

        hWndList = CreateWindow("listbox", NULL,
                        WS_CHILD | WS_VISIBLE | LBS_NOTIFY | WS_VSCROLL | WS_BORDER| LBS_EXTENDEDSEL,
                        0, 0,
                        0, 0,
                        hWnd, IDM_LISTBOX,
                        GetWindowWord (hWnd, GWW_HINSTANCE), NULL);

        MAKE_TABSTOP_TABLE_ENTRY(hWndList, IDM_LISTBOX);
        SendMessage(hWndList, WM_SETFONT, hFixedFont, FALSE);
        ShowWindow(hWndList, SW_SHOW);
        UpdateWindow(hWndList);         /* show it now! */

        hWndStatus = CreateWindow(szStatusClass, "Status",
                            WS_CHILD|WS_SYSMENU|WS_VISIBLE|WS_BORDER|WS_HSCROLL|WS_VSCROLL|WS_MAXIMIZEBOX|WS_CAPTION,
                            0, 0,
                            0, 0,
                            hWnd, IDM_STATUS,
                            GetWindowWord (hWnd, GWW_HINSTANCE), NULL);
        SendMessage(hWndStatus, WM_SETFONT, hFixedFont, TRUE);
        MAKE_TABSTOP_TABLE_ENTRY(hWndStatus, IDM_STATUS);

        hExtract = CreateWindow("button", "E&xtract",  
                            WS_CHILD | BS_PUSHBUTTON,
                            0, 0,
                            0, 0,
                            hWnd, IDM_EXTRACT,
                            hInst,
                            NULL);
        ShowWindow(hExtract, SW_SHOW);
        MAKE_TABSTOP_TABLE_ENTRY(hExtract, IDM_EXTRACT);


        hDisplay= CreateWindow("button", "&Display",                    
                            WS_CHILD | BS_PUSHBUTTON,
                            0, 0,
                            0, 0,
                            hWnd, IDM_DISPLAY,
                            hInst,
                            NULL);
        ShowWindow(hDisplay, SW_SHOW);
        MAKE_TABSTOP_TABLE_ENTRY(hDisplay, IDM_DISPLAY);

        hTest= CreateWindow("button", "&Test",          
                            WS_CHILD | BS_PUSHBUTTON,
                            0, 0,
                            0, 0,
                            hWnd, IDM_TEST,
                            hInst,
                            NULL);
        ShowWindow(hTest, SW_SHOW);
        MAKE_TABSTOP_TABLE_ENTRY(hTest, IDM_TEST);
    

        hShowComment= CreateWindow("button", "&Show Comment", 
                                    WS_CHILD | BS_PUSHBUTTON,
                                    0, 0,
                                    0, 0,
                                    hWnd, IDM_SHOW_COMMENT,
                                    hInst,
                                    NULL);

        ShowWindow(hShowComment, SW_SHOW);
        MAKE_TABSTOP_TABLE_ENTRY(hShowComment, IDM_SHOW_COMMENT);

        /* if file spec'd on entry */
        if (lpumb->szFileName[0])
        {
            LPSTR lpch;
            extern int ofretval; /* return value from initial open if filename given
                                during WinMain()                 */


            /* If valid filename change dir to where it lives */
            if (ofretval >= 0)
           {
				GetArchiveDir(lpumb->szDirName); /* get archive dir. in ANSI char set */
				if (uf.fUnzipToZipDir || /* unzipping to same directory as archive */
					lpumb->szUnzipToDirName[0] == '\0') /* or no default */
				{
                 	/* take only path portion */
                	lstrcpy(lpumb->szUnzipToDirName, lpumb->szDirName);
				}
				lstrcpy(lpumb->szBuffer, lpumb->szDirName);
                DlgDirList(hWnd, lpumb->szBuffer, 0, 0, 0); /* go to where archive lives */
            }
            else /* bad file name */
            {
			   	OemToAnsi(lpumb->szFileName, lpumb->szFileName); /* temporarily OEM */
                if ((lpch = lstrrchr(lpumb->szFileName, '\\')) ||
                     (lpch = lstrrchr(lpumb->szFileName, ':')))
                    lpch++; /* point to filename */
                else
                    lpch = lpumb->szFileName;
    
                wsprintf (lpumb->szBuffer, "Cannot open %s", lpch);
                MessageBox (hWnd, lpumb->szBuffer, szAppName, MB_ICONINFORMATION | MB_OK);
                lpumb->szFileName[0] = '\0'; /* pretend filename doesn't exist  */
			    lpumb->szDirName[0] = '\0'; /* pretend archive dir. doesn't exist  */

            }
        }
        SetCaption(hWnd);
        UpdateListBox(hWnd);
        SendMessage(hWndList, LB_SETSEL, 1, 0L);
        UpdateButtons(hWnd);
        SizeWindow(hWnd, TRUE);
		uCommDlgHelpMsg = RegisterWindowMessage((LPSTR)HELPMSGSTRING); /* register open help message */

        if ( uf.fCanDragDrop )
            DragAcceptFiles( hWnd, TRUE );
        break;
    
    case WM_SETFOCUS:
        SetFocus((wWindowSelection == IDM_MAX_STATUS) ? hWndStatus : hWndList);
        break;

    case WM_ACTIVATE:
        SetCaption(hWnd);
        return DefWindowProc(hWnd, wMessage, wParam, lParam);

    case WM_SIZE:
        SizeWindow(hWnd, FALSE);
        break;

    case WM_CTLCOLOR: /* color background of buttons and statics */
        if (HIWORD(lParam) == CTLCOLOR_STATIC)
        {
            SetBkMode(wParam, TRANSPARENT);
            SetBkColor(wParam, GetSysColor(BG_SYS_COLOR)); /* custom b.g. color */
            SetTextColor(wParam, GetSysColor(COLOR_WINDOWTEXT));
            UnrealizeObject(hBrush);
            point.x = point.y = 0;
            ClientToScreen(hWnd, &point);
            SetBrushOrg(wParam, point.x, point.y);
            return ((DWORD)hBrush);
        }
        /* fall thru to WM_SYSCOMMAND */
        
    case WM_SYSCOMMAND:
        return DefWindowProc( hWnd, wMessage, wParam, lParam );

	case WM_INITMENUPOPUP: /* popup menu pre-display		*/
	{
	BOOL bOutcome;

		switch  (LOWORD(lParam)) {
		case EDIT_MENUITEM_POS: /* index of Edit pop-up		*/
			bOutcome = EnableMenuItem((HMENU)wParam, IDM_COPY,
				(UINT)(StatusInWindow() ? MF_ENABLED : MF_GRAYED));

			assert(bOutcome != -1);	/* DEBUG */
			break;
		}
		}
		break;

    case WM_COMMAND:
        /* Was F1 just pressed in a menu, or are we in help mode */
        /* (Shift-F1)? */

        if (uf.fHelp)
        {
            DWORD dwHelpContextId =
                (wParam == IDM_OPEN)            ? (DWORD) HELPID_OPEN :
                (wParam == IDM_EXIT)            ? (DWORD) HELPID_EXIT_CMD :
                (wParam == IDM_CHDIR)           ? (DWORD) HELPID_CHDIR :
                (wParam == IDM_SHORT)           ? (DWORD) HELPID_SHORT :
                (wParam == IDM_LONG)            ? (DWORD) HELPID_LONG :
                (wParam == IDM_HELP)            ? (DWORD) HELPID_HELP :
                (wParam == IDM_HELP_HELP)       ? (DWORD) HELPID_HELP_HELP :
                (wParam == IDM_ABOUT)           ? (DWORD) HELPID_ABOUT :
                (wParam == IDM_RECR_DIR_STRUCT) ? (DWORD) HELPID_RECR_DIR_STRUCT :
                (wParam == IDM_OVERWRITE)       ? (DWORD) HELPID_OVERWRITE :
                (wParam == IDM_TRANSLATE)       ? (DWORD) HELPID_TRANSLATE :
                (wParam == IDM_UNZIP_TO_ZIP_DIR)? (DWORD) HELPID_UNZIP_TO_ZIP_DIR :
                (wParam == IDM_LISTBOX)         ? (DWORD) HELPID_LISTBOX :
                (wParam == IDM_EXTRACT)         ? (DWORD) HELPID_EXTRACT :
                (wParam == IDM_DISPLAY)         ? (DWORD) HELPID_DISPLAY :
                (wParam == IDM_TEST)            ? (DWORD) HELPID_TEST :
                (wParam == IDM_SHOW_COMMENT)    ? (DWORD) HELPID_SHOW_COMMENT :
                (wParam == IDM_LB_EXTRACT)      ? (DWORD) HELPID_LB_EXTRACT :
                (wParam == IDM_LB_DISPLAY)      ? (DWORD) HELPID_LB_DISPLAY :
                (wParam == IDM_LB_TEST)         ? (DWORD) HELPID_LB_TEST :
                (wParam == IDM_DESELECT_ALL)    ? (DWORD) HELPID_DESELECT_ALL :
                (wParam == IDM_SELECT_ALL)      ? (DWORD) HELPID_SELECT_ALL :
                (wParam == IDM_SELECT_BY_PATTERN) ? (DWORD) HELPID_SELECT_BY_PATTERN :
                (wParam == IDM_AUTOCLEAR_STATUS) ? (DWORD) HELPID_AUTOCLEAR_STATUS :
                (wParam == IDM_CLEAR_STATUS)    ? (DWORD) HELPID_CLEAR_STATUS :
                (wParam == IDM_SOUND_OPTIONS)  ? (DWORD) HELPID_SOUND_OPTIONS :
                (wParam == IDM_MAX_LISTBOX)  ? (DWORD) HELPID_MAX_LISTBOX :
                (wParam == IDM_MAX_STATUS)  ? (DWORD) HELPID_MAX_STATUS :
                (wParam == IDM_SPLIT)  ? (DWORD) HELPID_SPLIT :
                                                  (DWORD) 0L;

            if (!dwHelpContextId)
            {
                MessageBox( hWnd, "Help not available for Help Menu item",
                            "Help Example", MB_OK);
                return DefWindowProc(hWnd, wMessage, wParam, lParam);
            }

            uf.fHelp = FALSE;
            WinHelp(hWnd,szHelpFileName,HELP_CONTEXT,dwHelpContextId);
        }
        else /* not in help mode */
        {
		RECT    rClient;

            switch (wParam)
            {
            case IDM_OPEN:
                /* If unzipping separately and previous file exists,
                 * go to directory where archive lives.
                 */
                if ( uf.fCanDragDrop )
                    DragAcceptFiles( hWnd, FALSE );

				/* If not unzipping to same directory as archive and
				 * file already open, go to where file lives.
				 * If extracting to different directory, return to 
				 * that directory after selecting archive to open.
				 */
                if (lpumb->szFileName[0])
                {
                    /* strip off filename to make directory name    */
					GetArchiveDir(lpumb->szDirName);
                }
				else
				{
					lpumb->szDirName[0] = '\0'; /* assume no dir	*/
				}
                lpumb->szBuffer[0] = '\0';
				_fmemset(&lpumb->ofn, '\0', sizeof(OPENFILENAME)); /* initialize struct */
                lpumb->ofn.lStructSize = sizeof(OPENFILENAME);
                lpumb->ofn.hwndOwner = hWnd;
                lpumb->ofn.lpstrFilter = "Zip Files (*.zip)\0*.zip\0Self-extracting Files (*.exe)\0*.exe\0All Files (*.*)\0*.*\0\0";
                lpumb->ofn.nFilterIndex = 1;
                lpumb->ofn.lpstrFile = lpumb->szFileName;
				lpumb->szFileName[0] = '\0';	/* no initial filename	*/
                lpumb->ofn.nMaxFile = WIZUNZIP_MAX_PATH;
                lpumb->ofn.lpstrFileTitle = lpumb->szBuffer; /* ignored */
               	lpumb->ofn.lpstrInitialDir = (LPSTR)((uf.fUnzipToZipDir || 
											!lpumb->szDirName[0]) ? NULL : lpumb->szDirName);

                lpumb->ofn.nMaxFileTitle = OPTIONS_BUFFER_LEN;
                lpumb->ofn.Flags = OFN_SHOWHELP | OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | 
									OFN_HIDEREADONLY;
				dwCommDlgHelpId = HELPID_OPEN; /* specify correct help for open dlg	*/
                if (GetOpenFileName(&lpumb->ofn))   /* if successful file open  */
                {
 					
					AnsiToOem(lpumb->szFileName, lpumb->szFileName); /* retain as OEM */
                    GetArchiveDir(lpumb->szDirName); /* get archive dir name in ANSI */

                    if (uf.fUnzipToZipDir || /* unzipping to same directory as archive */
						lpumb->szUnzipToDirName[0] == '\0') /* or no default */
                    {
                         /* strip off filename to make directory name    */
                        lstrcpy(lpumb->szUnzipToDirName, lpumb->szDirName);
                    }

                }
                UpdateListBox(hWnd); /* fill in list box */
                SendMessage(hWndList, LB_SETSEL, 1, 0L);
                UpdateButtons(hWnd); /* update state of buttons */

                GetClientRect( hWndList, &rClient );
                OffsetRect( &rClient, 0, dyChar );
                rClient.top = rClient.bottom;
                rClient.bottom = rClient.top + (2*dyChar);
                InvalidateRect( hWnd, &rClient, TRUE);
                UpdateWindow( hWnd );
                SetCaption(hWnd);
                if ( uf.fCanDragDrop )
                    DragAcceptFiles( hWnd, TRUE );
                break;
            case IDM_CHDIR:
                if ( uf.fCanDragDrop )
                    DragAcceptFiles( hWnd, FALSE );

 				_fmemset(&lpumb->ofn, '\0', sizeof(OPENFILENAME)); /* initialize struct */
                lpumb->ofn.lStructSize = sizeof(OPENFILENAME);
                lpumb->ofn.hwndOwner = hWnd;
                lpumb->ofn.hInstance = hInst;
                lpumb->ofn.lpstrFilter = "All Files (*.*)\0*.*\0\0";
                lpumb->ofn.nFilterIndex = 1;
				lstrcpy(lpumb->szUnzipToDirNameTmp, lpumb->szUnzipToDirName); /* initialize */
				{
				size_t uDirNameLen = _fstrlen(lpumb->szUnzipToDirNameTmp);
				
					/* If '\\' not at end of directory name, add it now.
					 */
					if (uDirNameLen > 0 && lpumb->szUnzipToDirNameTmp[uDirNameLen-1] != '\\')
						lstrcat(lpumb->szUnzipToDirNameTmp, "\\");

				}
				lstrcat(lpumb->szUnzipToDirNameTmp, "johnny\376\376.\375\374\373"); /* fake name */
                lpumb->ofn.lpstrFile = lpumb->szUnzipToDirNameTmp; /* result goes here! */
                lpumb->ofn.nMaxFile = WIZUNZIP_MAX_PATH;
                lpumb->ofn.lpstrFileTitle = NULL;
                lpumb->ofn.nMaxFileTitle = OPTIONS_BUFFER_LEN; /* ignored ! */
                lpumb->ofn.lpstrInitialDir = lpumb->szUnzipToDirName;
                lpumb->ofn.lpstrTitle = (LPSTR)"Unzip To";
                lpumb->ofn.Flags = OFN_SHOWHELP | OFN_PATHMUSTEXIST | OFN_ENABLEHOOK | 
									OFN_HIDEREADONLY|OFN_ENABLETEMPLATE|OFN_NOCHANGEDIR;
                lpumb->ofn.lpfnHook = lpfnSelectDir = MakeProcInstance((FARPROC)SelectDirProc, hInst);
     			lpumb->ofn.lpTemplateName = "SELDIR";	/* see seldir.dlg	*/
				dwCommDlgHelpId = HELPID_CHDIR; /* in case user hits "help" button */
                if (GetSaveFileName(&lpumb->ofn)) /* successfully got dir name ? */
                {
					lstrcpy(lpumb->szUnzipToDirName, lpumb->szUnzipToDirNameTmp); /* save result */
                    SetCaption(hWnd);
                }
                else /* either real error or canceled */
                {
					DWORD dwExtdError = CommDlgExtendedError(); /* debugging */

					if (dwExtdError != 0L) /* if not canceled then real error */
					{
                		wsprintf (lpumb->szBuffer, szCantChDir, dwExtdError);
                		MessageBox (hWnd, lpumb->szBuffer, szAppName, MB_ICONINFORMATION | MB_OK);
					}
                }
                FreeProcInstance(lpfnSelectDir);
                if ( uf.fCanDragDrop )
                    DragAcceptFiles( hWnd, TRUE );
                break;

            case IDM_EXIT:
                SendMessage(hWnd, WM_CLOSE, 0, 0L);
                break;

            case IDM_HELP:  /* Display Help */ 
                WinHelp(hWnd,szHelpFileName,HELP_INDEX,0L);
                break;

            case IDM_HELP_HELP:
                WinHelp(hWnd,"WINHELP.HLP",HELP_INDEX,0L);
                break;

            case IDM_ABOUT:
                if ( uf.fCanDragDrop )
                    DragAcceptFiles( hWnd, FALSE );
                lpfnAbout = MakeProcInstance(AboutProc, hInst);
                DialogBox(hInst, "About", hWnd, lpfnAbout);
                FreeProcInstance(lpfnAbout);
                if ( uf.fCanDragDrop )
                    DragAcceptFiles( hWnd, TRUE );
                break;

            case IDM_LISTBOX:       /* command from listbox     */
                if (cZippedFiles)
                {
                    switch (HIWORD(lParam))
                    {
                    case LBN_SELCHANGE:
                        UpdateButtons(hWnd);
                        break;
                    case LBN_DBLCLK:
                        UpdateButtons(hWnd);
                        if ( uf.fCanDragDrop )
                            DragAcceptFiles( hWnd, FALSE );

						if (uf.fAutoClearStatus && wLBSelection == IDM_LB_DISPLAY) /* if autoclear on display */
							SendMessage(hWndStatus, WM_COMMAND, IDM_CLEAR_STATUS, 0L);

                        Action(hWnd, wLBSelection - IDM_LB_EXTRACT);
                        if ( uf.fCanDragDrop )
                            DragAcceptFiles( hWnd, TRUE );
                        break;
                    }
                }
                break;
            case IDM_LONG:
            case IDM_SHORT:
                /* If format change, uncheck old, check new. */
                if ((wParam - IDM_SHORT) != uf.fFormatLong)
                {
                    WORD wFormatTmp = wParam - IDM_SHORT;
                    int __far *pnSelItems; /* pointer to list of selected items */
                    HANDLE  hnd = 0;
                    int cSelLBItems ; /* no. selected items in listbox */
                    RECT    rClient;

                    cSelLBItems = CLBItemsGet(hWndList, &pnSelItems, &hnd);
                    CheckMenuItem(hMenu, (IDM_SHORT+uf.fFormatLong), MF_BYCOMMAND|MF_UNCHECKED);
                    CheckMenuItem(hMenu, (IDM_SHORT+wFormatTmp), MF_BYCOMMAND|MF_CHECKED);
                    uf.fFormatLong = wFormatTmp;
                    UpdateListBox(hWnd);

                    SizeWindow(hWnd, TRUE);
      				WritePrivateProfileString(szAppName, szFormatKey, 
                                (LPSTR)(szFormatKeyword[uf.fFormatLong]), szWizUnzipIniFile);
             
                    /* anything previously selected ? */
                    if (cSelLBItems > 0)
                    {
                        ReselectLB(hWndList, cSelLBItems, pnSelItems);
                        GlobalUnlock(hnd);
                        GlobalFree(hnd);
                    }

                    /* enable or disable buttons */
                    UpdateButtons(hWnd);

                    /* make sure labels & Zip archive totals get updated */
                    GetClientRect( hWnd, &rClient );
                    rClient.top = 0;
                    rClient.bottom = rClient.top + dyChar;
                    InvalidateRect( hWnd, &rClient, TRUE);
                    GetClientRect( hWndList, &rClient );
                    OffsetRect( &rClient, 0, dyChar );
                    rClient.top = rClient.bottom;
                    rClient.bottom = rClient.top + (2*dyChar);
                    InvalidateRect( hWnd, &rClient, TRUE);
                    UpdateWindow( hWnd );
                }
                break;

            case IDM_OVERWRITE:
                /* Toggle value of overwrite flag. */
                uf.fOverwrite = !uf.fOverwrite;
                CheckMenuItem(hMenu,IDM_OVERWRITE,MF_BYCOMMAND|
                                (WORD)(uf.fOverwrite ? MF_CHECKED: MF_UNCHECKED));
                WritePrivateProfileString(szAppName, szOverwriteKey, 
                        (LPSTR)(uf.fOverwrite ? szYes : szNo ), szWizUnzipIniFile);
                break;

            case IDM_TRANSLATE:
                /* Toggle value of translate flag. */
                uf.fTranslate = !uf.fTranslate;
                CheckMenuItem(hMenu,IDM_TRANSLATE,MF_BYCOMMAND|
                                (WORD)(uf.fTranslate ? MF_CHECKED: MF_UNCHECKED));
                WritePrivateProfileString(szAppName, szTranslateKey, 
                        (LPSTR)(uf.fTranslate ? szYes : szNo ), szWizUnzipIniFile);
                break;
            
            case IDM_UNZIP_TO_ZIP_DIR:
                /* toggle value of Unzip to .ZIP  */
                uf.fUnzipToZipDir = !uf.fUnzipToZipDir;
                CheckMenuItem(hMenu,IDM_UNZIP_TO_ZIP_DIR,MF_BYCOMMAND|
                                    (WORD)(uf.fUnzipToZipDir ? MF_CHECKED:MF_UNCHECKED));
                EnableMenuItem(hMenu,IDM_CHDIR,MF_BYCOMMAND|
                                    (WORD)(uf.fUnzipToZipDir ? MF_GRAYED:MF_ENABLED));
                WritePrivateProfileString(szAppName, szUnzipToZipDirKey, 
                            (LPSTR)(uf.fUnzipToZipDir ? szYes : szNo ), szWizUnzipIniFile);

                if (uf.fUnzipToZipDir && lpumb->szDirName[0])
                {
                    lstrcpy(lpumb->szUnzipToDirName, lpumb->szDirName); /* get new dirname */
                	SetCaption(hWnd);
                }
                break;
            case IDM_SOUND_OPTIONS: /* launch Sound Options dialog box	*/
 				{
				FARPROC lpfnSoundOptions;
				dwCommDlgHelpId = HELPID_SOUND_OPTIONS; /* if someone hits "help" */
                lpfnSoundOptions = MakeProcInstance(SoundProc, hInst);
                DialogBox(hInst, "SOUND", hWnd, lpfnSoundOptions);
                FreeProcInstance(lpfnSoundOptions);
				}
                break;
           case IDM_AUTOCLEAR_STATUS:
                /* automatically clear status window before displaying  */
                uf.fAutoClearStatus = !uf.fAutoClearStatus;
                CheckMenuItem(hMenu,IDM_AUTOCLEAR_STATUS,MF_BYCOMMAND|
                                    (WORD)(uf.fAutoClearStatus ? MF_CHECKED:MF_UNCHECKED));
                WritePrivateProfileString(szAppName, szAutoClearStatusKey, 
                            (LPSTR)(uf.fAutoClearStatus ? szYes : szNo ), szWizUnzipIniFile);

                 break;
  
            case IDM_LB_EXTRACT:
            case IDM_LB_DISPLAY:
            case IDM_LB_TEST:
                /* If overwrite change, uncheck old, check new. */
                /* wParam is the new default action */
                if (wParam != wLBSelection)
                {
				RECT    rClient, rButton;
				POINT	ptUpperLeft, ptLowerRight;

                    CheckMenuItem(hMenu,wLBSelection,MF_BYCOMMAND|MF_UNCHECKED);
                    CheckMenuItem(hMenu,wParam,MF_BYCOMMAND|MF_CHECKED);

                    wLBSelection = wParam;
                    WritePrivateProfileString(szAppName, szLBSelectionKey, 
                        (LPSTR)(LBSelectionTable[wParam - IDM_LB_EXTRACT]), szWizUnzipIniFile);
					GetClientRect(hWnd, &rClient);
					GetWindowRect(hExtract, &rButton); /* any button will do */
					ptUpperLeft.x = rButton.left;
					ptUpperLeft.y = rButton.top;
					ptLowerRight.x = rButton.right;
					ptLowerRight.y = rButton.bottom;
					ScreenToClient(hWnd, &ptUpperLeft);
					ScreenToClient(hWnd, &ptLowerRight);
					rClient.top = ptUpperLeft.y - nCyBorder;
					rClient.bottom = ptLowerRight.y + nCyBorder;
                	InvalidateRect( hWnd, &rClient, TRUE); /* redraw button area */
                	UpdateWindow( hWnd );


                }
                break;

            case IDM_SHOW_COMMENT:
                /* display the archive comment in mesg window */
                if ( uf.fCanDragDrop )
                    DragAcceptFiles( hWnd, FALSE );
                DisplayComment(hWnd);
                if ( uf.fCanDragDrop )
                    DragAcceptFiles( hWnd, TRUE );
                break;
            case IDM_RECR_DIR_STRUCT:
                /* re-create directories structure */
                uf.fRecreateDirs = !uf.fRecreateDirs;
                CheckMenuItem(hMenu, IDM_RECR_DIR_STRUCT, 
                 MF_BYCOMMAND | (uf.fRecreateDirs ? MF_CHECKED : MF_UNCHECKED));
                WritePrivateProfileString(szAppName, szRecreateDirsKey,
                                    (LPSTR)(uf.fRecreateDirs ? szYes : szNo), szWizUnzipIniFile);
                break;

            case IDM_DISPLAY:
            case IDM_TEST:
            case IDM_EXTRACT:
                if ( uf.fCanDragDrop )
                    DragAcceptFiles( hWnd, FALSE );

				if (uf.fAutoClearStatus && wParam == IDM_DISPLAY) /* if autoclear on display */
					SendMessage(hWndStatus, WM_COMMAND, IDM_CLEAR_STATUS, 0L);

                Action(hWnd, wParam - IDM_EXTRACT);
                if ( uf.fCanDragDrop )
                    DragAcceptFiles( hWnd, TRUE );
                break;

            case IDM_SELECT_ALL:
            case IDM_DESELECT_ALL:
                if (cZippedFiles)
                {
                    SendMessage(hWndList , LB_SELITEMRANGE, 
                            (WORD)(wParam == IDM_DESELECT_ALL ? FALSE : TRUE),
                                MAKELONG(0, (cZippedFiles-1)));
                    UpdateButtons(hWnd);
                }
                break;
			case IDM_SELECT_BY_PATTERN:
				if (!hPatternSelectDlg)
				{
				DLGPROC lpfnPatternSelect;

					dwCommDlgHelpId = HELPID_SELECT_BY_PATTERN;
               		lpfnPatternSelect = (DLGPROC)MakeProcInstance(PatternSelectProc, hInst);
					WinAssert(lpfnPatternSelect)
					hPatternSelectDlg = 
					CreateDialog(hInst, "PATTERN", hWnd, lpfnPatternSelect);
					WinAssert(hPatternSelectDlg)
				}
				break;
			case IDM_COPY: /* copy from "Status" window value to clipboard */
				CopyStatusToClipboard(hWnd);
				break;

            case IDM_CLEAR_STATUS:  /* forward to status window */
                PostMessage(hWndStatus, WM_COMMAND, IDM_CLEAR_STATUS, 0L);
                break;
			case IDM_MAX_LISTBOX:
			case IDM_MAX_STATUS:
			case IDM_SPLIT:
				if (wWindowSelection != wParam) /* If state change */
				{
                	CheckMenuItem(hMenu, wWindowSelection, MF_BYCOMMAND | MF_UNCHECKED);
					switch (wWindowSelection) {
					case IDM_MAX_STATUS:
						ManageStatusWnd(IDM_SPLIT);
						break;
					case IDM_MAX_LISTBOX: /* status window has been hidden */
                		EnableWindow( hWndStatus, TRUE );
                   		ShowWindow(hWndStatus, SW_SHOWNORMAL);
						wWindowSelection = IDM_SPLIT; /* save new state	*/
                		SizeWindow(hWnd, FALSE);
						break;
					}
					/* listbox and status window are in split state at this point	*/
					switch (wParam) {
					case IDM_MAX_STATUS:
                  		ManageStatusWnd(wParam);
						break;
					case IDM_MAX_LISTBOX:
               			EnableWindow( hWndStatus, FALSE );
                   		ShowWindow(hWndStatus, SW_HIDE);
						break;
					}
					wWindowSelection = wParam; /* save new state	*/
                	SizeWindow(hWnd, FALSE);
               		CheckMenuItem(hMenu, wWindowSelection, MF_BYCOMMAND | MF_CHECKED);
				}
				break;
			case IDM_SETFOCUS_ON_STATUS: /* posted from Action() following extract-to-Status */
				SetFocus(hWndStatus);	/* set focus on Status so user can scroll */
				break;
            default:

                return DefWindowProc(hWnd, wMessage, wParam, lParam);
            }
        } /* bottom of not in help mode */
        break;
    case WM_SETCURSOR:
        /* In help mode it is necessary to reset the cursor in response */
        /* to every WM_SETCURSOR message.Otherwise, by default, Windows */
        /* will reset the cursor to that of the window class. */

        if (uf.fHelp)
        {
            SetCursor(hHelpCursor);
            break;
        }
        return DefWindowProc(hWnd, wMessage, wParam, lParam);


    case WM_INITMENU:
        if (uf.fHelp)
        {
            SetCursor(hHelpCursor);
        } 
        return TRUE;

    case WM_ENTERIDLE:
        if ((wParam == MSGF_MENU) && (GetKeyState(VK_F1) & 0x8000))
        {
            uf.fHelp = TRUE;
            PostMessage(hWnd, WM_KEYDOWN, VK_RETURN, 0L);
        }
        break;

    case WM_CLOSE:
        DestroyWindow(hWnd);
        break;

    case WM_DESTROY:
        if ( uf.fCanDragDrop )
            DragAcceptFiles( hWnd, FALSE );
        DeleteObject(hBrush);
        WinHelp(hWnd, szHelpFileName, HELP_QUIT, 0L);
        PostQuitMessage(0);
        break;

    case WM_DROPFILES:
        {
            WORD    cFiles;
            WORD    cch;
            
            /* Get the number of files that have been dropped */
            cFiles = DragQueryFile( (HDROP)wParam, (UINT)-1, lpumb->szBuffer, 256);

            /* Only handle one dropped file until MDI-ness happens */
            if (cFiles == 1)
            {
                RECT    rClient;

                cch = DragQueryFile( wParam, 0, lpumb->szFileName, WIZUNZIP_MAX_PATH);
				AnsiToOem(lpumb->szFileName, lpumb->szFileName); /* retain as OEM */
                GetArchiveDir(lpumb->szDirName); /* get archive dir name in ANSI */
                if (uf.fUnzipToZipDir || /* unzipping to same directory as archive */
						lpumb->szUnzipToDirName[0] == '\0') /* or no default */
                {
                 	/* strip off filename to make directory name    */
                	lstrcpy(lpumb->szUnzipToDirName, lpumb->szDirName);
                }
                lstrcpy(lpumb->szBuffer, lpumb->szDirName); /* get scratch copy */
                DlgDirList (hWnd, lpumb->szBuffer, 0, 0, 0); /* change dir */
				UpdateListBox(hWnd); /* fill in list box */
                SendMessage(hWndList, LB_SETSEL, 1, 0L);
                UpdateButtons(hWnd); /* update state of buttons */

                GetClientRect( hWndList, &rClient );
                OffsetRect( &rClient, 0, dyChar );
                rClient.top = rClient.bottom;
                rClient.bottom = rClient.top + (2*dyChar);
                InvalidateRect( hWnd, &rClient, TRUE);
                UpdateWindow( hWnd );
                SetCaption(hWnd);
            }
            DragFinish( (HDROP)wParam );
        }
        break;

    case WM_PAINT:
        if (wWindowSelection != IDM_MAX_STATUS) 
        {
            PAINTSTRUCT ps;
            RECT    rClient;
            DWORD   dwBackColor;
            
            hDC = BeginPaint( hWnd, &ps );
            if ( hDC )
            {
			HWND hLBSelection;	/* button corresponding to LB selection */
			POINT ptUpperLeft, ptLowerRight; /* client coordinates */
			RECT rectDefaultButton;

                GetClientRect( hWndList, &rClient );
                if (RectVisible( hDC, &rClient ))
                    UpdateWindow( hWndList );
                hOldFont = SelectObject ( hDC, hFixedFont);
                GetClientRect( hWnd, &rClient );
                dwBackColor = SetBkColor(hDC,GetSysColor(BG_SYS_COLOR));

                rClient.top = 0;
                rClient.left += dxChar/2;
                DrawText( hDC, (LPSTR)Headers[uf.fFormatLong][0], -1, &rClient, DT_NOPREFIX | DT_TOP);

                GetClientRect( hWndList, &rClient );
                OffsetRect( &rClient, 0, dyChar+2);
                rClient.left += dxChar/2;
                rClient.top = rClient.bottom;
                rClient.bottom = rClient.top + dyChar;
                DrawText( hDC, (LPSTR)szTrailers[uf.fFormatLong], -1, &rClient, DT_NOPREFIX | DT_TOP);

                rClient.top += dyChar;
                rClient.bottom += dyChar;
				if (lpumb->szFileName[0])	/* if file selected */
                	DrawText( hDC, lpumb->szTotalsLine, -1, &rClient, DT_NOPREFIX | DT_TOP);

                SetBkColor(hDC, dwBackColor);
                (void)SelectObject ( hDC, hOldFont);

				/* draw frame around default button	*/
				switch (wLBSelection) {
				case IDM_LB_EXTRACT:	hLBSelection = hExtract;	break;
            	case IDM_LB_TEST:		hLBSelection = hTest;		break;
            	default:				hLBSelection = hDisplay;	break;
				}
				GetWindowRect(hLBSelection, &rectDefaultButton);
				ptUpperLeft.x = rectDefaultButton.left;
				ptUpperLeft.y = rectDefaultButton.top;
				ptLowerRight.x = rectDefaultButton.right;
				ptLowerRight.y = rectDefaultButton.bottom;
				ScreenToClient(hWnd, &ptUpperLeft);
				ScreenToClient(hWnd, &ptLowerRight);
				rectDefaultButton.left = ptUpperLeft.x-nCxBorder;
				rectDefaultButton.top = ptUpperLeft.y-nCyBorder;
				rectDefaultButton.right = ptLowerRight.x+nCxBorder;
				rectDefaultButton.bottom = ptLowerRight.y+nCyBorder;
				FrameRect(hDC, &rectDefaultButton, GetStockObject(BLACK_BRUSH));
            }
            EndPaint(hWnd, &ps);
            break;
        }
        return DefWindowProc(hWnd, wMessage, wParam, lParam);
	default:
		if (wMessage == uCommDlgHelpMsg)	/* common dialog help message ID */
		{	
            WinHelp(hWnd, szHelpFileName, HELP_CONTEXT, dwCommDlgHelpId );
			return 0;
		}
        return DefWindowProc(hWnd, wMessage, wParam, lParam);
    }
    return 0;
}
