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

// Handle to the DLL instance from Libinit.asm
HANDLE LIBINST;
HMENU hMenu;

BOOL CALLBACK QExitSetup(HWND hwndDlg, UINT msg, WPARAM wParam, LPARAM lParam);
static BOOL ConfirmExit(void);
static short ButtonAction(void);

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
	(*pSig) = 0x04534441L;		// 'ADS' (in reverse) x4
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
	lstrcpy(pLabelBuf, "Quick Exit");
}

// Return a menu that should be displayed
// when the specified button is clicked -
// this function is called just prior to
// display of the menu
HMENU FAR _export BCBtnMenu(BYTE btnId, BOOL bLeft)
{
	if (!bLeft) {

		// Create a popup menu (if a resource
		// menu is used, be sure to call the
		// function GetSubMenu to get the
		// proper popup menu handle to display
		//
		// e.g.
		//
		// hMenu = LoadMenu(hInstance, MAKEINTRESOURCE(id));
		// hPopup = GetSubMenu(hMenu, 0);

		// We will create our menu
		hMenu = CreatePopupMenu();

		// Add to the menu
		AppendMenu(hMenu, 0, 1, "Exit Windows");
		AppendMenu(hMenu, 0, 2, "Restart Windows");
		AppendMenu(hMenu, 0, 3, "Reboot");
		AppendMenu(hMenu, MF_SEPARATOR, 0, NULL);
		AppendMenu(hMenu, 0, 4, "Setup...");
	}

	return hMenu;
}

// Handle a button select
void FAR _export BCBtnClick(BYTE btnId, BOOL bLeft)
{
	// Default to exit windows
	BCBtnMenuSelect(btnId, 1 + ButtonAction());
}

// Handle a menu selection
void FAR _export BCBtnMenuSelect(BYTE btnId, short itemId)
{
	// Clean up menu
	DestroyMenu(hMenu);
	hMenu = 0;

	// Check for confirmation
	if ((itemId > 0) && (itemId < 4) && ConfirmExit()) {

		if (MessageBox((HWND) 0,
					(itemId == 1)? "OK to end Windows session?":
					(itemId == 2)? "OK to restart Windows?":
								"OK to reboot system?",
					"Quick Exit",
					MB_ICONSTOP | MB_YESNO) == IDNO)
			return;
	}

	switch (itemId) {

		case 1: ExitWindows(MAKELONG(0, 0), 0); break;
		case 2: ExitWindows(MAKELONG(EW_RESTARTWINDOWS, 0), 0); break;
		case 3: ExitWindows(MAKELONG(EW_REBOOTSYSTEM, 0), 0); break;
		case 4: DialogBox(LIBINST, MAKEINTRESOURCE(400), (HWND) 0, QExitSetup); break;
	}

	return;
}

static BOOL ConfirmExit(void)
{
	return GetPrivateProfileInt("QExit", "Confirm", 1, "BARCLOCK.INI");
}

static short ButtonAction(void)
{
	return GetPrivateProfileInt("QExit", "BtnAction", 1, "BARCLOCK.INI");
}

BOOL CALLBACK QExitSetup(HWND hwndDlg, UINT msg, WPARAM wParam, LPARAM lParam)
{
	// If confirmed
	if (msg == WM_INITDIALOG) {

		// Set the default values
		CheckDlgButton(hwndDlg, (ButtonAction())? 101:100, TRUE);
		CheckDlgButton(hwndDlg, 102, ConfirmExit());

	} else if (msg == WM_COMMAND) {

		switch (wParam) {

			case IDOK:
				// Update profile settings
				WritePrivateProfileString("QExit", "BtnAction",
									 (IsDlgButtonChecked(hwndDlg, 101))? "1":"0",
									 "BARCLOCK.INI");

				WritePrivateProfileString("QExit", "Confirm",
									 (IsDlgButtonChecked(hwndDlg, 102))? "1":"0",
									 "BARCLOCK.INI");


			case IDCANCEL:
				// Any command message causes this
				// dialog to go awaw
				EndDialog(hwndDlg, wParam);
				return TRUE;
		}
	}

	return (msg == WM_INITDIALOG);
}

