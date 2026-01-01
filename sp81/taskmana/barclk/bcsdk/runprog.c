/*
	BarClock(tm)

	Keyword Extension Sample

	Copyright (c) 1994  Patrick Breen
	All rights reserved.

	Contact Information:

		Atomic Dog Software
		PO Box 523
		Medford, MA 02155

		Phone (617) 396-2673
		Fax   (617) 396-5761

		Internet:			pbreen@world.std.com
		CompuServe: 		70312,743
		America Online: 	PBreen
*/

#include "bchook.h"
#include <shellapi.h>
#include <commdlg.h>

BOOL CALLBACK RunProgram(HWND hwndDlg, UINT msg, WPARAM wParam, LPARAM lParam);

// Handle to the DLL instance from Libinit.asm
HANDLE LIBINST;

void cdecl _cexit(void)
{
}

// Standard library initialization
int FAR PASCAL LibMain(HINSTANCE hInstance, WORD a, WORD b, LPSTR c)
{
	LIBINST = hInstance;
	return 1;
}

// Standard library exit
int FAR PASCAL WEP(int a)
{
	return TRUE;
}

// Standard version number return
DWORD FAR _export BCHookVersion(DWORD FAR *pSig)
{
	(*pSig) = 0x01534441L;		// 'ADS' (in reverse) x1
	return HOOKVERSION;
}

// Return the number of buttons we support
BYTE FAR _export BCBtnCount(void)
{
	// We support 1 buttons
	return 1;
}

// Return the label for the button
void FAR _export BCBtnLabel(BYTE btnId, LPSTR pLabelBuf)
{
	// Copy appropriate label into buffer
	if (btnId == 0) lstrcpy(pLabelBuf, "Run Program");
	return;
}

// Handle a button click
void FAR _export BCBtnClick(BYTE btnId, BOOL bLeft)
{
	// Display a dialog
	DialogBox(LIBINST, MAKEINTRESOURCE(400), (HWND) 0, RunProgram);
	return;
}

static BOOL NEAR GetFile(HWND hwnd, short id)
{
	char file[256];
	OPENFILENAME ofn;

	file[0] = 0;

	// Initialize the OFN struct
	ofn.lStructSize = sizeof(OPENFILENAME);
	ofn.hwndOwner = hwnd;
	ofn.lpstrFilter = "Programs\0*.exe *.com *.bat *.pif *.wbt\0";
	ofn.nFilterIndex = 1;
	ofn.lpstrCustomFilter = NULL;
	ofn.nMaxCustFilter = 0;
	ofn.lpstrFileTitle = NULL;
	ofn.nMaxFileTitle = 0;
	ofn.lpstrTitle = NULL;
	ofn.lpstrFile= file;
	ofn.nMaxFile = sizeof(file);
	ofn.lpstrInitialDir = NULL;
	ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | OFN_HIDEREADONLY;
	ofn.lpstrDefExt = "exe";
	ofn.lpfnHook = NULL;
	ofn.lpTemplateName = NULL;

	// Open the dialog
	if (GetOpenFileName(&ofn)) {

		// The user confirmed, set the item text
		SetDlgItemText(hwnd, id, file);
		return TRUE;
	}

	return FALSE;
}


BOOL CALLBACK RunProgram(HWND hwndDlg, UINT msg, WPARAM wParam, LPARAM lParam)
{
	char prog[300];
	char dir[256];
	char tag[8];
	char save = 0;
	LPSTR pArg;
	BOOL bMin;
	short i;

	// Handle init dialog
	if (msg == WM_INITDIALOG) {

		// Refresh combo box
		for (i = 0; i < 20; i++) {

			// Get the next command
			wsprintf(tag, "Cmd%d", i);
			if (GetPrivateProfileString("RunProg", tag, "", prog, sizeof(prog), "BARCLOCK.INI") == 0)
				break;

			SendDlgItemMessage(hwndDlg, 100, CB_ADDSTRING, 0, (LPARAM) prog);
		}

		// Default to last command
		SendDlgItemMessage(hwndDlg, 100, CB_SETCURSEL, 0, 0);

	// If confirmed
	} else if (msg == WM_COMMAND) {

		switch (wParam) {

			case 103:
				// Check for browse command
				GetFile(hwndDlg, 100);
				return TRUE;

			case IDOK:
				// Get dialog info
				GetDlgItemText(hwndDlg, 100, prog, sizeof(prog));
				GetDlgItemText(hwndDlg, 101, dir, sizeof(dir));
				bMin = IsDlgButtonChecked(hwndDlg, 102);

				// Now, run forward from the start looking
				// for a space - we want to use ShellExecute
				// so we need to seperate the .EXE from any
				// arguments that have been provided
				pArg = prog;
				while (*pArg && *pArg != ' ') pArg++;

				// We found a space, terminate
				// app string and step past space
				if (*pArg == ' ') {
					save = *pArg;
					*pArg++ = 0;
				}

				// Run the application
				if (ShellExecute(0, NULL, prog, pArg, dir, (bMin)? SW_SHOWMINIMIZED:SW_SHOWNORMAL) <= (HINSTANCE) 32) {
					MessageBox(hwndDlg, "Could not run program.", "Error!", MB_OK);
					return TRUE;
				}

				// Restore blasted char
				if (save) pArg[-1] = save;

				// If command is not identical - reorder history
				if ((GetPrivateProfileString("RunProg", "Cmd0", "", dir, sizeof(dir), "BARCLOCK.INI") == 0) ||
				    (lstrcmpi(prog, dir) != 0)) {

					// Update command history
					for (i = 19; i >= 0; i--) {

						// If command exists
						wsprintf(tag, "Cmd%d", i);
						if (GetPrivateProfileString("RunProg", tag, "", dir, sizeof(dir), "BARCLOCK.INI") > 0) {

							// Move to the next slot
							wsprintf(tag, "Cmd%d", i + 1);
							WritePrivateProfileString("RunProg", tag, dir, "BARCLOCK.INI");
						}
					}

					// Put the latest in the first slot
					WritePrivateProfileString("RunProg", "Cmd0", prog, "BARCLOCK.INI");
				}

			case IDCANCEL:
				// Any command message causes this
				// dialog to go awaw
				EndDialog(hwndDlg, wParam);
				return TRUE;
		}
	}

	return (msg == WM_INITDIALOG);
}

