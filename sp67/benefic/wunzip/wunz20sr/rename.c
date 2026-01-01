#include "wizunzip.h"
#include "rename.h"
#include "helpids.h"

/****************************************************************************

    FUNCTION: RenameProc(HWND, WORD, WORD, LONG)

    PURPOSE:  Processes messages for "Rename" dialog box

    MESSAGES:

    WM_INITDIALOG - initialize dialog box
    WM_COMMAND    - Input received

****************************************************************************/

BOOL FAR PASCAL RenameProc(HWND hDlg, WORD wMessage, WORD wParam, LONG lParam)
{
    static char __far *lpsz;

    switch (wMessage)
    {
    case WM_INITDIALOG:
        lpsz = (char __far *)lParam;
        wsprintf(lpumb->szBuffer, "Rename %s", (LPSTR)lParam);
        SetDlgItemText(hDlg, IDM_RENAME_TEXT, lpumb->szBuffer);
        wsprintf(lpumb->szBuffer, "%s", (LPSTR)lParam);
        SetDlgItemText(hDlg, IDM_NEW_NAME_TEXT, lpumb->szBuffer);
        return TRUE;

    case WM_SETFOCUS:
        SetFocus(GetDlgItem(hDlg, IDM_NEW_NAME_TEXT));
        return TRUE;

    case WM_COMMAND:
        switch (wParam)
        {
        case IDM_RENAME_RENAME:
            GetDlgItemText(hDlg, IDM_NEW_NAME_TEXT, lpsz, 80);
        case IDM_RENAME_CANCEL:
            EndDialog(hDlg, wParam);
            break;
        case IDM_RENAME_HELP:
            WinHelp(hDlg,szHelpFileName,HELP_CONTEXT, (DWORD)(HELPID_OVERWRITE));
        }
        return TRUE;
    }
    return FALSE;
}

