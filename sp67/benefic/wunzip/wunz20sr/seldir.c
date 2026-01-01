#include <string.h>
#include <io.h>
#include <stdio.h>
#include "wizunzip.h"
#include "helpids.h"
#include "seldir.h"



BOOL FAR PASCAL SelectDirProc(HWND hDlg, WORD wMessage, WORD wParam, LONG lParam)
{
    static OPENFILENAME __far *lpofn = 0;
    static WORD wClose;

    switch (wMessage)
    {
    case WM_DESTROY:
        if (lpofn && lpofn->lpstrFile && (wClose == IDOK))
        {
            LPSTR lpszSeparator;
			DWORD dwResult;		/* result of Save As Default button query */

            /* strip off filename to make directory name    */
            for (lpszSeparator = lpofn->lpstrFile+lstrlen(lpofn->lpstrFile);
                lpszSeparator > lpofn->lpstrFile;
                --lpszSeparator)
            {
				/* Just backed up to root directory ?
				 */
				if (lpszSeparator > (lpofn->lpstrFile+2) &&
					lpszSeparator[-1] == '\\' &&
					lpszSeparator[-2] == ':')
				{
                    *lpszSeparator = '\0';	/* leave the root dir's '\\' */
                    break;
				}
                if ((*lpszSeparator) == '\\')
                {
                    *lpszSeparator = '\0';
                    break;
                }
            }
			/* get state of Save As Default checkbox */
			dwResult = SendDlgItemMessage(hDlg , IDM_SAVE_AS_DEFAULT, BM_GETSTATE, 0, 0);
			if (dwResult & 1)	/* if checked */
			{
				/* save as future default */
				WritePrivateProfileString(szAppName, szDefaultUnzipToDir, 
                                lpofn->lpstrFile, szWizUnzipIniFile);
 
			}
        }
        break;
    case WM_COMMAND:
        // When the user presses the OK button, stick text
        // into the filename edit ctrl to fool the commdlg
        // into thinking a file has been chosen.
        // We're just interested in the path, so any file
        // name will do - so long as it doesn't match
        // a directory name, we're fine

        if (wParam == IDOK)
        {
            SetDlgItemText(hDlg, edt1, "johnny\376\376.\375\374\373");
            wClose = wParam;
        }
        else if (wParam == IDCANCEL)
        {
            wClose = wParam;
        }
        break;
    case WM_INITDIALOG:
        {
            RECT    rT1, rT2;
            short   nWidth, nHeight;

            lpofn = (OPENFILENAME __far *)lParam;
            CenterDialog(GetParent(hDlg), hDlg); /* center on parent */

            wClose = 0;

            // Disable the filename edit ctrl
            //  and the file type label
            //  and the file type combo box
            EnableWindow(GetDlgItem(hDlg, edt1), FALSE);
            EnableWindow(GetDlgItem(hDlg, stc2), FALSE);
            EnableWindow(GetDlgItem(hDlg, cmb1), FALSE);

            GetWindowRect(GetDlgItem(hDlg, cmb2), &rT1);

            // Hide the file type label & combo box
            ShowWindow(GetDlgItem(hDlg, stc2), SW_HIDE);
            ShowWindow(GetDlgItem(hDlg, cmb1), SW_HIDE);

            // Extend the rectangle of the list of files
            // in the current directory so that it's flush
            // with the bottom of the Drives combo box
            GetWindowRect(GetDlgItem(hDlg, lst1), &rT2);
            nWidth = rT2.right - rT2.left;
            nHeight = rT1.bottom - rT2.top;
            ScreenToClient(hDlg, (LPPOINT)&rT2);
            MoveWindow(GetDlgItem(hDlg, lst1),
                        rT2.left, rT2.top,
                        nWidth,
                        nHeight,
                        TRUE);          
        }
    default:
        break;
    }

    /* message not handled */
    return 0;
}
