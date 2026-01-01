#include "wizunzip.h"

/* sizewndw.c module of WizUnZip.
 * Author: Robert A. Heath
 * I, Robert Heath, place this source code module in the public domain.
 */

#define MIN_LISTBOX_LINES 2

/* Call this when the window size changes or needs to change. */
void SizeWindow(HWND hWnd, BOOL bOKtoMovehWnd)
{
    WORD wMinClientWidth;       /* minimum client width     */
    WORD wButtonWidth;
    int nListBoxHeight;         /* height of listbox in pix         */
    WORD wVariableHeight;       /* no. variable pixels on client    */
    WORD wVariableLines;            /* no. variable lines on client window */
    WORD wMessageBoxHeight;     /* message box height in pixels     */
    int nButtonsYpos;
    WORD wClientWidth, wClientHeight;       /* size of client area  */
    RECT rectT;             /* full window rectangle structure          */
    int nCxBorder;
    int nCyBorder;
    int nCxVscroll; /* vertical scroll width */
    int nCyHscroll; /* vertical scroll width */
    int nCyCaption; /* caption height       */

    GetClientRect(hWnd, &rectT);
    wClientWidth = rectT.right-rectT.left+1; /* x size of client area */
    wClientHeight = rectT.bottom-rectT.top+1; /* y size of client area */
	if (wWindowSelection == IDM_MAX_STATUS)
    {
        /* position the status window to fill entire client window   */
        MoveWindow(hWndStatus, 0, 0, wClientWidth, wClientHeight, TRUE);
        cLinesMessageWin = wClientHeight / dyChar ;
        return;
    }

    nCxBorder = GetSystemMetrics(SM_CXBORDER);
    nCyBorder = GetSystemMetrics(SM_CYBORDER);
    nCxVscroll = GetSystemMetrics(SM_CXVSCROLL);
    nCyHscroll = GetSystemMetrics(SM_CYHSCROLL);
    nCyCaption = GetSystemMetrics(SM_CYCAPTION);

    if (wClientHeight < (WORD)(11*dyChar))
        wClientHeight = 11*dyChar;

    /* List Box gets roughly 1/2 of lines left over on client
     * window after subtracting fixed overhead for borders,
     * horizontal scroll bar,
     * button margin spacing, header, and trailer lines.
     * unless the status window is minimized
     */
    wVariableHeight =  wClientHeight - (2 * nCyBorder) - (6 * dyChar);
	if (wWindowSelection != IDM_MAX_LISTBOX)
        wVariableHeight -= nCyHscroll + nCyCaption + (2*nCyBorder) + dyChar;
    wVariableLines = wVariableHeight / dyChar;
    cListBoxLines =  (wWindowSelection == IDM_MAX_LISTBOX) ? 
					wVariableLines : wVariableLines / 2 ; 

    if (cListBoxLines < MIN_LISTBOX_LINES)
        cListBoxLines = MIN_LISTBOX_LINES;

    cLinesMessageWin = wVariableLines - cListBoxLines; /* vis. msg. wnd lines */

    wMinClientWidth = 
       (!uf.fFormatLong ? MIN_SHORT_FORMAT_CHARS : MIN_LONG_FORMAT_CHARS) * dxChar +
                      nCxVscroll + 2 * nCxBorder;

    /* if we moved the hWnd from WM_SIZE, we'd probably get into
     * a nasty, tight loop since this generates a WM_SIZE.
     */
    if (bOKtoMovehWnd && (wClientWidth < wMinClientWidth))
    {
        wClientWidth = wMinClientWidth;
        GetWindowRect(hWnd, &rectT);
        MoveWindow(hWnd, rectT.left, rectT.top,
                    wClientWidth + (2*GetSystemMetrics(SM_CXFRAME)), wClientHeight,
                    TRUE);
    }

    /* divide buttons up into 4 equal zones each button separated by
     * a 1-character buffer.
     */
    wButtonWidth = max( ((wClientWidth - 5 * dxChar)/4), 60 );

    nListBoxHeight = (cListBoxLines * dyChar) + (2 * nCyBorder);
    MoveWindow(hWndList,        
            0, dyChar,
            wClientWidth,nListBoxHeight,
            TRUE);

    nButtonsYpos = (cListBoxLines+3) * dyChar+ (dyChar/2) + (2 * nCyBorder);

    /* position the 4 buttons */
    MoveWindow(hExtract, 
            dxChar,nButtonsYpos,
            wButtonWidth, 2 * dyChar,
            TRUE);

    MoveWindow(hDisplay,
            wButtonWidth+ (2 * dxChar), nButtonsYpos,
            wButtonWidth, (2 * dyChar),
            TRUE);

    MoveWindow(hTest,
            2*(wButtonWidth+dxChar)+dxChar, nButtonsYpos,
            wButtonWidth, (2 * dyChar),
            TRUE);

    MoveWindow(hShowComment,
            3*(wButtonWidth+dxChar)+dxChar, nButtonsYpos,
            wButtonWidth, (2 * dyChar),
            TRUE);


    /* Position the status (Message) window.
     * The Message windows is positioned relative to the bottom
     * of the client area rather than relative to the top of the client.
     */
    wMessageBoxHeight = wVariableHeight - nListBoxHeight + 
                        2 * nCyBorder + 
                        nCyHscroll + nCyCaption ;

    MoveWindow(hWndStatus, 
            0, wClientHeight - wMessageBoxHeight,
            wClientWidth, wMessageBoxHeight,
            TRUE);

}
