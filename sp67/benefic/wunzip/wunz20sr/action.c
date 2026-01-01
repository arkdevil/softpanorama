#include "wizunzip.h"
#include "unzip.h"     

/* Action.c module of WizUnZip.
 * Author: Robert A. Heath, 1993
 * I, Robert Heath, place this source code module in the public domain.
 */
char __based(__segname("STRINGS_TEXT")) szNoMemory[] = 
            "Insufficient memory for this operation!";

char __based(__segname("STRINGS_TEXT")) szCantChDir[] = 
			"Can't change directory to %s!";


/* Get Selection Count returns a count of the selected 
 * list box items. If the count is  greater than zero, it also returns
 * a pointer to a locked list in local memory of the item nos.
 * and their local memory handle.
 * A value of -1 indicates an error.
 */
int CLBItemsGet(HWND hListBox, int __far * __far *ppnSelItems, HANDLE *phnd)
{
    int cSelLBItems = (int)SendMessage(hListBox, LB_GETSELCOUNT, 0, 0L);

    if ( !phnd )
        return -1;

    *phnd = 0;
    if (cSelLBItems)
    {
        *phnd = GlobalAlloc(GMEM_FIXED, cSelLBItems * sizeof(int));
        if ( !*phnd )
            return -1;

        *ppnSelItems = (int __far *)GlobalLock( *phnd );
        if ( !*ppnSelItems )
        {
            GlobalFree( *phnd );
            *phnd = 0;
            return -1;
        }

        if (SendMessage(hWndList, LB_GETSELITEMS, cSelLBItems, (LONG)*ppnSelItems) != cSelLBItems)
        {
            GlobalUnlock(*phnd);
            GlobalFree(*phnd);
            *phnd = 0;
            return -1;
        }
    }
    return cSelLBItems;
}

/* Re-select listbox contents from given list. The pnSelItems is a
 * list containing the indices of those items selected in the listbox.
 * This list was probably created by GetLBSelCount() above.
 */
void ReselectLB(HWND hListBox, int cSelLBItems, int __far *pnSelItems)
{
    int i;

    
    for (i = 0; i < cSelLBItems; ++i)
    {
        SendMessage(hListBox, LB_SETSEL, TRUE, MAKELPARAM(pnSelItems[i],0));
    }
}


#define cchFilesMax 1024

/* Action is called on double-clicking, or selecting one of the 3
 * main action buttons. The action code is the action
 * relative to the listbox or the button ID.
 */
void Action(HWND hWnd, WORD wActionCode)
{
    HANDLE  hMem = 0;
    int i;
    int iSelection;
    int cch;
    int cchCur;
    int cchTotal;
    int __far *pnSelItems;  /* pointer to list of selected items */
    HANDLE  hnd = 0;
    int cSelLBItems = CLBItemsGet(hWndList, &pnSelItems, &hnd);
    int argc;
    LPSTR   lpszT;
    char **pszIndex;
    char *sz;
    WORD wIndex = !uf.fFormatLong ? SHORT_FORM_FNAME_INX
                            : LONG_FORM_FNAME_INX;

	gfCancelDisplay = FALSE;	/* clear any previous cancel */
    /* if no items were selected */
    if (cSelLBItems < 1)
        return;

    /* Note: this global value can be overriden in replace.c */
    uf.fDoAll = (uf.fOverwrite) ? 1 : 0;

    SetCapture(hWnd);
    hSaveCursor = SetCursor(hHourGlass);
    ShowCursor(TRUE);

#if 1
    /* If all the files are selected pass in no filenames */
    /* since unzipping all files is the default */
    hMem = GlobalAlloc( GPTR, 4096 );
    if ( !hMem )
        goto done;
    lpszT = (LPSTR)GlobalLock( hMem );
    if ( !lpszT )
    {
        GlobalFree( hMem );
        goto done;
    }

    argc = ((WORD)cSelLBItems == cZippedFiles) ? 0 : 1;
    iSelection = 0;

    do
    {
        char rgszFiles[cchFilesMax];

        if (argc)
        {
            cchCur = 0;
            pszIndex = (char **)rgszFiles;
            cch = (sizeof(char *) * ((cSelLBItems > (cchFilesMax/16)-1 ) ? (cchFilesMax/16) : cSelLBItems+1));
            cchTotal = (cchFilesMax-1) - cch;
            sz = rgszFiles + cch;
            
            for (i=0; ((i+iSelection)<cSelLBItems) && (i<(cchFilesMax/16)-1); ++i)
            {
                cch = (int)SendMessage(hWndList, LB_GETTEXTLEN, pnSelItems[i+iSelection], 0L);
                if (cch != LB_ERR)
                {
                    if ((cchCur+cch+1-wIndex) > cchTotal)
                        break;
                    cch = (int)SendMessage(hWndList, LB_GETTEXT, pnSelItems[i+iSelection], (LONG)lpszT);
                    if ((cch != LB_ERR) && (cch>wIndex))
                    {
                        lstrcpy(sz, lpszT+wIndex);
                        pszIndex[i] = sz;
                        cchCur += (cch + 1 - wIndex);
                        sz += (cch + 1 - wIndex);
                    }
                    else
                    {
                        break;
                    }
                }
                else
                {
                    MessageBeep(1);
                    goto done;
                }
            }
            if (i == 0)
                goto done;
            argc = i;

            pszIndex[i] = 0;
            iSelection += i;
        }
        else
        {
            iSelection = cSelLBItems;
        }

        switch (wActionCode)
        {
        case 0:         /* extract */
            if (FSetUpToProcessZipFile(0, 0, 0, 1, 0, 
                            (int)(uf.fRecreateDirs ? 1 : 0), 
                            uf.fDoAll, (int)(uf.fTranslate ? 1 : 0),
                                argc, lpumb->szFileName, (char **)rgszFiles))
            {
			int DlgDirListOK = 1; /* non-zero when DlgDirList() succeeds */

				/* If extracting to different directory from archive dir.,
				 * temporarily go to "unzip to" directory.
				 */ 
				if (!uf.fUnzipToZipDir && lpumb->szUnzipToDirName[0])
				{
					lstrcpy(lpumb->szBuffer, lpumb->szUnzipToDirName); /* OK to clobber szBuffer! */
					DlgDirListOK = DlgDirList(hWnd, lpumb->szBuffer, 0, 0, 0);
				}
				if (!DlgDirListOK)	/* if DlgDirList failed  */
				{
					wsprintf(lpumb->szBuffer, szCantChDir, lpumb->szUnzipToDirName);
					MessageBox(hWndMain, lpumb->szBuffer, NULL, MB_OK | MB_ICONEXCLAMATION);
				}
				else
				{
                	process_zipfile();	/* extract the file(s)			*/
					/* Then return to archive dir. after extraction.
					 * (szDirName is always defined if archive file defined)
					 */
					if (!uf.fUnzipToZipDir && lpumb->szUnzipToDirName[0])
					{
						lstrcpy(lpumb->szBuffer, lpumb->szDirName); /* OK to clobber szBuffer! */
						if (!DlgDirList(hWnd, lpumb->szBuffer, 0, 0, 0)) /* cd back */
						{
							wsprintf(lpumb->szBuffer, szCantChDir, lpumb->szDirName);
							MessageBox(hWndMain, lpumb->szBuffer, NULL, MB_OK | MB_ICONEXCLAMATION);

						}
					}
				}
            }
            else
            {
                MessageBox(hWndMain, szNoMemory, NULL, MB_OK | MB_ICONEXCLAMATION);
            }
            TakeDownFromProcessZipFile();
            break;
        case 1:     /* display to message window */
            bRealTimeMsgUpdate = FALSE;
            if (FSetUpToProcessZipFile(1, 0, 0, 1, 0,  0, 0, 0,
                                argc, lpumb->szFileName, (char **)rgszFiles))
            {
                process_zipfile();
            }
            else
            {
                MessageBox(hWndMain, szNoMemory, NULL, MB_OK | MB_ICONEXCLAMATION);
            }

            TakeDownFromProcessZipFile();
            bRealTimeMsgUpdate = TRUE;
			if (uf.fAutoClearStatus)	/* if automatically clearing status, leave user at top */
				SetStatusTopWndPos();
	
			else	/* traditional behavior leaves user at bottom of window */
            	UpdateMsgWndPos();

			/* Following extraction to status window, user will want
			 * to scroll around, so leave him/her on Status window.
			 */
        	if (wWindowSelection != IDM_MAX_LISTBOX)
        		PostMessage(hWnd, WM_COMMAND, IDM_SETFOCUS_ON_STATUS, 0L);

            break;
        case 2:     /* test */
            if (FSetUpToProcessZipFile(0, 1, 0, 1, 0,  0, 0, 0,
                                argc, lpumb->szFileName, (char **)rgszFiles))
            {
                process_zipfile();
            }
            else 
            {
                MessageBox(hWndMain, szNoMemory, NULL, MB_OK | MB_ICONEXCLAMATION);
            }

            TakeDownFromProcessZipFile();
            break;
        }
    } while (iSelection < cSelLBItems);
    

    /* march through list box checking what's selected
     * and what is not.
     */
#else
    for (i = 0; i < cSelLBItems ; ++i)
    {
        int nLength;
        char szBuffer[256];

        /* extract item from list box...        */
        if ((nLength = (int)SendMessage(hWndList, LB_GETTEXT, 
                            pnSelItems[i], (LONG)(LPSTR)szBuffer)) > 0)
        {
            /* index of filename in buffer */
            WORD wIndex = !uf.fFormat ? SHORT_FORM_FNAME_INX
                                    : LONG_FORM_FNAME_INX;

            PSTR pfn = &szBuffer[wIndex]; /* points to filename */
            /* fake arg list for process_zipfile() */
            static char *FileNameVector[] = { "", "" }; 
        
            WinAssert(nLength < (256-1));
            /* pass desired filename */
            FileNameVector[0] = pfn;
            switch (wActionCode)
            {
            case 0:         /* extract */
                if (FSetUpToProcessZipFile(0, 0, 0, 1, 0, 
                                (int)(uf.fRecreateDirs ? 1 : 0), 
                                uf.fDoAll, (int)(uf.fTranslate ? 1 : 0),
                                    1, lpumb->szFileName, FileNameVector))
                {
                    process_zipfile();
                }
                else
                {
                    MessageBox(hWndMain, szNoMemory, NULL, 
                                MB_OK|MB_ICONEXCLAMATION);
                }
                TakeDownFromProcessZipFile();
                break;
            case 1:     /* display to message window */
                bRealTimeMsgUpdate = FALSE;
                if (FSetUpToProcessZipFile(1, 0, 0, 1, 0,  0, 0, 0,
                                    1, lpumb->szFileName, FileNameVector))
                {
                    process_zipfile();
                }
                else
                {
                    MessageBox(hWndMain, szNoMemory, NULL, 
                                MB_OK|MB_ICONEXCLAMATION);
                }
                
                TakeDownFromProcessZipFile();
                bRealTimeMsgUpdate = TRUE;
                UpdateMsgWndPos();
                break;
            case 2:     /* test */
                if (FSetUpToProcessZipFile(0, 1, 0, 1, 0,  0, 0, 0,
                                    1, lpumb->szFileName, FileNameVector))
                {
                    process_zipfile();
                }
                else 
                {
                    MessageBox(hWndMain, szNoMemory, NULL, 
                                MB_OK|MB_ICONEXCLAMATION);
                }
                
                TakeDownFromProcessZipFile();
                break;
            }
        }
    }
#endif

done:

    if ( hMem )
    {
        GlobalUnlock( hMem );
        GlobalFree( hMem );
    }
    GlobalUnlock(hnd);
    GlobalFree(hnd);


    ShowCursor(FALSE);
    SetCursor(hSaveCursor);
    ReleaseCapture();
	SoundAfter();		/* play sound afterward if requested */
    if (!uf.fIconSwitched)  /* if haven't already, switch icons */
    {
        HANDLE hIcon;

        hIcon = LoadIcon(hInst,"UNZIPPED"); /* load final icon   */
        assert(hIcon);
        SetClassWord(hWndMain, GCW_HICON, hIcon);
        uf.fIconSwitched = TRUE;    /* flag that we've switched it  */
    }
}

/* Display the archive comment using the Info-ZIP engine. */
void DisplayComment(HWND hWnd)
{

    SetCapture(hWnd);
    hSaveCursor = SetCursor(hHourGlass);
    ShowCursor(TRUE);
    bRealTimeMsgUpdate = FALSE;
	gfCancelDisplay = FALSE;	/* clear any previous cancel */

    if (FSetUpToProcessZipFile(0, 0, 0, 1, 1, 0, 0, 0,
                        0, lpumb->szFileName, NULL))
    {
        process_zipfile();
    }
    else 
    {
        MessageBox(hWndMain, szNoMemory, NULL, MB_OK | MB_ICONEXCLAMATION); 
    }
    
    TakeDownFromProcessZipFile();
    ShowCursor(FALSE);
    SetCursor(hSaveCursor);
    bRealTimeMsgUpdate = TRUE;
    UpdateMsgWndPos();
    ReleaseCapture();
    SoundAfter();		/* play sound during if requested			*/
}
