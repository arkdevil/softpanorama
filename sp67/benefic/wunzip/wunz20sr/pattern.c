#include "pattern.h"
#include "wizunzip.h"
#include "unzip.h"
#include "helpids.h"

char __based(__segname("STRINGS_TEXT")) szNoMatch[] = 
            "No entry matches the pattern!";

/****************************************************************************

    FUNCTION: PatternSelectProc(HWND, unsigned, WORD, LONG)

    PURPOSE:  Processes messages for "Select Files by Pattern" dialog box

    MESSAGES:

    WM_INITDIALOG - initialize dialog box
    WM_COMMAND    - Input received

****************************************************************************/

BOOL FAR PASCAL
PatternSelectProc(HWND hwndDlg, WORD wMessage, WORD wParam, LONG lParam)
{
static HWND hSelect, hDeselect, hPattern;
PSTR psLBEntry = NULL;  /* list box entry */
PSTR psPatternBuf = NULL;	/* pattern collection	*/
DWORD cListItems;	/* no. items in listbox	*/
WORD Fname_Inx;		/* index into LB entry	*/
BOOL fSelect;		/* we're selecting if TRUE */
int nPatternLength;	/* length of data in pattern edit window */


	switch (wMessage) {
	case WM_INITDIALOG:
		hSelect = GetDlgItem(hwndDlg, IDOK);
		hDeselect = GetDlgItem(hwndDlg, IDM_PATTERN_DESELECT);
        hPattern = GetDlgItem(hwndDlg, IDM_PATTERN_PATTERN);
		CenterDialog(GetParent(hwndDlg), hwndDlg);
		return TRUE;
		break;
	case WM_COMMAND:
		switch (wParam) {
        case IDM_PATTERN_PATTERN:
            if (HIWORD(lParam) == EN_CHANGE)
			{
			
			nPatternLength = GetWindowTextLength(hPattern);
			/* Enable or disable buttons depending on fullness of
			 * "Suffix" box.
			 */
				if (nPatternLength >= 0 && nPatternLength <= 1)
				{
				BOOL fButtonState = (nPatternLength > 0) ; 

					EnableWindow(hSelect, fButtonState);
					EnableWindow(hDeselect, fButtonState);

				}
			}
            break;
		case IDOK: /* Select items using pattern */
		case IDM_PATTERN_DESELECT:
			fSelect = (BOOL)(wParam == IDOK);
			/* Be sure that listbox contains at least 1 item,
			 * that a pattern exists (is non-null), and
			 * that we can buffer them.
			 */
			if ((cListItems = SendMessage(hWndList, LB_GETCOUNT, 0, 0L)) != LB_ERR &&
			     cListItems >= 1 &&
				(nPatternLength = GetWindowTextLength(hPattern)) >= 1 &&
				(psPatternBuf =	/* get a buffer	for the file name					*/
              (PSTR)LocalAlloc(LMEM_FIXED, nPatternLength+1)) != NULL &&
			  (psLBEntry =	/* get a buffer	for the file name					*/
              (PSTR)LocalAlloc(LMEM_FIXED, FILNAMSIZ+LONG_FORM_FNAME_INX)) != NULL &&
				GetWindowText(hPattern, psPatternBuf, nPatternLength+1) > 0)
			{
			DWORD cItemsSelected = 0; /* no. "hits" during pattern search	*/
			UINT uLBInx;
			PSTR psPattern;	/* points to any one pattern in buffer		*/
			static char DELIMS[] = " \t,"; /* delimiters, mostly whitespace */

				_strlwr(psPatternBuf);	/* convert pattern to lower case	*/
 				Fname_Inx = (UINT)(uf.fFormatLong ? LONG_FORM_FNAME_INX : SHORT_FORM_FNAME_INX);
				/* march through list of patterns in edit field				*/
				for (psPattern = strtok(psPatternBuf, DELIMS);
					 psPattern != NULL; psPattern = strtok(NULL, DELIMS))
				{
					 
					/* March thru listbox matching the complete path with every entry.
					 * Note: unzip's match() function probably won't work for national
					 * characters above the ASCII range.
					 */
					for (uLBInx = 0; uLBInx < cListItems; uLBInx++)
					{
						/* Retrieve listbox entry								*/
					 	if (SendMessage(hWndList, LB_GETTEXT, uLBInx, (LPARAM)((LPSTR)psLBEntry)) >
							(LRESULT)Fname_Inx)
						{
							_strlwr(&psLBEntry[Fname_Inx]); /* convert filename to lower case */
							/* Use UnZip's match() function						*/
							if (match(&psLBEntry[Fname_Inx], psPattern))
							{
								SendMessage(hWndList, LB_SETSEL, (WPARAM)fSelect, 
											MAKELPARAM(uLBInx,0));
								cItemsSelected++;
							}
						}
					}
				}
				if (!cItemsSelected)	/* If no pattern match					*/
				{
					MessageBox(hwndDlg, szNoMatch, szAppName, MB_OK | MB_ICONASTERISK);
				}
				else /* one or more items were selected */
				{
					UpdateButtons(hWndMain); /* turn main push buttons on or off */
				}
			}
			if (psLBEntry)
				LocalFree((HLOCAL)psLBEntry);

			if (psPatternBuf)
				LocalFree((HLOCAL)psPatternBuf);
			break;
		case IDCANCEL:
			PostMessage(hwndDlg, WM_CLOSE, 0, 0L);
			break;
		case IDM_PATTERN_HELP:
            WinHelp(hwndDlg,szHelpFileName,HELP_CONTEXT, (DWORD)(HELPID_SELECT_BY_PATTERN));
			break;
		}
		return TRUE;
		break;
	case WM_CLOSE:
		DestroyWindow(hwndDlg);
		hPatternSelectDlg = 0; /* flag dialog inactive	*/
		return TRUE;
	}
	return FALSE;
}

