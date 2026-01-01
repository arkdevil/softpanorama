#include <windows.h>    /* required for all Windows applications */


/*
 -      CenterDialog
 -      
 *      Purpose:
 *              Moves the dialog specified by hwndDlg so that it is centered on
 *              the window specified by hwndParent. If hwndParent is null,
 *              hwndDlg gets centered on the screen.
 *      
 *              Should be called while processing the WM_INITDIALOG message
 *              from the dialog's DlgProc().
 *      
 *      Arguments:
 *              HWND    parent hwnd
 *              HWND    dialog's hwnd
 *      
 *      Returns:
 *              Nothing.
 *      
 */
void
CenterDialog(HWND hwndParent, HWND hwndDlg)
{
        RECT    rectDlg;
        RECT    rect;
        int             dx;
        int             dy;

        if (hwndParent == NULL)
        {
                rect.top = rect.left = 0;
                rect.right = GetSystemMetrics(SM_CXSCREEN);
                rect.bottom = GetSystemMetrics(SM_CYSCREEN);
        }
        else
        {
                GetWindowRect(hwndParent, &rect);
        }

        GetWindowRect(hwndDlg, &rectDlg);
        OffsetRect(&rectDlg, -rectDlg.left, -rectDlg.top);

        dx = (rect.left + (rect.right - rect.left -
                        rectDlg.right) / 2 + 4) & ~7;
        dy = rect.top + (rect.bottom - rect.top -
                        rectDlg.bottom) / 2;
        MoveWindow(hwndDlg, dx, dy, rectDlg.right, rectDlg.bottom, 0);
}


/****************************************************************************

    FUNCTION: About(HWND, unsigned, WORD, LONG)

    PURPOSE:  Processes messages for "About" dialog box

    MESSAGES:

    WM_INITDIALOG - initialize dialog box
    WM_COMMAND    - Input received

****************************************************************************/

BOOL FAR PASCAL
AboutProc(HWND hwndDlg, WORD wMessage, WORD wParam, LONG lParam)
{
    if ((wMessage == WM_CLOSE) || 
		(wMessage == WM_COMMAND && wParam == IDOK))
        EndDialog(hwndDlg, TRUE);

    if (wMessage == WM_INITDIALOG)
    {
            CenterDialog(GetParent(hwndDlg), hwndDlg);
    }
    return ((wMessage == WM_CLOSE) || (wMessage == WM_INITDIALOG) || (wMessage == WM_COMMAND))
            ? TRUE : FALSE;
}

