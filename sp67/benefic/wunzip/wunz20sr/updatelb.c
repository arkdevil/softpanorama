#include "wizunzip.h"
#include "unzip.h"     

/* updatelb.c module of WizUnzip.
 * Author: Robert A. Heath
 * I, Robert Heath, place this source code module in the public domain.
 */

/* Update Buttons is called when an event possibly modifies the 
 * number of selected items in the listbox. 
 * The function reads the number of selected items. 
 * A non-zero value enables relevant buttons and menu items.
 * A zero value disables them.
 */
void
UpdateButtons(HWND hWnd)
{
    BOOL fButtonState;

    if (lpumb->szFileName[0] &&
        SendMessage(hWndList, LB_GETSELCOUNT, 0, 0L)) /* anything selected ? */
    {
        fButtonState = TRUE;
    }
    else
    {
        fButtonState = FALSE;
    }
    EnableWindow(hExtract, fButtonState);
    EnableWindow(hDisplay, fButtonState);
    EnableWindow(hTest, fButtonState);
    EnableWindow(hShowComment, (BOOL)(lpumb->szFileName[0] && cchComment ? TRUE : FALSE));
}

/* Update List Box attempts to fill the list box on the parent
 * window with the next "cListBoxLines" of personal data from the 
 * current position in the file.
 * UpdateListBox() assumes that the a record has been read in when called.
 * The cZippedFiles variable indicates whether or not a record exists.
 * The bForward parameter controls whether updating precedes forward
 * or reverse.
 */
void
UpdateListBox(HWND hWnd)
{
    SendMessage(hWndList, LB_RESETCONTENT, 0, 0L);
    InvalidateRect( hWndList, NULL, TRUE );
    UpdateWindow( hWndList );
    cZippedFiles = 0;

    if (lpumb->szFileName[0])       /* file selected? */
    {
        /* if so -- stuff list box              */
        SendMessage(hWndList, WM_SETREDRAW, FALSE, 0L);
        if (FSetUpToProcessZipFile(0, 0, 
                (int)(!uf.fFormatLong ? 1 : 2), 1, 0, 0, 0, 0,
                            0, lpumb->szFileName, NULL))
        {
            process_zipfile();
        }
        else
        {
            MessageBox(hWndMain, szNoMemory, NULL, 
                        MB_OK|MB_ICONEXCLAMATION);
        }
        
        TakeDownFromProcessZipFile();
#ifndef NEED_EARLY_REDRAW
        SendMessage(hWndList, WM_SETREDRAW, TRUE, 0L);
        InvalidateRect(hWndList, NULL, TRUE);   /* force redraw         */
#endif
        cZippedFiles = (WORD)SendMessage(hWndList, LB_GETCOUNT, 0, 0L);
        assert((int)cZippedFiles != LB_ERR);
        if (cZippedFiles)   /* if anything went into listbox set to top */
        {
#ifdef NEED_EARLY_REDRAW
            UpdateWindow(hWndList); /* paint now!                   */
#endif
            SendMessage(hWndList, LB_SETTOPINDEX, 0, 0L);
        }
#ifdef NEED_EARLY_REDRAW
        else /* no files were unarchived!                           */
        {
            /* Add dummy message to initialize list box then clear it
             * to prevent strange problem where later calls to 
             * UpdateListBox() do not result in displaying of all contents.
             */
            SendMessage(hWndList, LB_ADDSTRING, 0, (LONG)(LPSTR)" ");
            UpdateWindow(hWndList); /* paint now!                   */
        }
#endif
    }
#ifdef NEED_EARLY_REDRAW
    else
    {
        /* Add dummy message to initialize list box then clear it
         * to prevent strange problem where later calls to 
         * UpdateListBox() do not result in displaying of all contents.
         */
        SendMessage(hWndList, LB_ADDSTRING, 0, (LONG)(LPSTR)" ");
        UpdateWindow(hWndList); /* paint now!                   */
    }
#endif

}
