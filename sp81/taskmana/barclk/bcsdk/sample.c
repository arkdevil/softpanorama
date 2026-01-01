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
#include <string.h>

// Handle to the DLL instance from Libinit.asm
HANDLE LIBINST;

// Simple array of text strings we recognize
static char FAR *pKeys[] = { "patrick", "breen", "" };

static HMENU hMenu = 0;


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
	(*pSig) = 0x474F4441L;		// 'ADOG' (in reverse)
	return HOOKVERSION;
}

// We will recognize a two keywords [patrick] and
// [breen] - when the text "breen" comes in, we will
// pass back the unique identifier of 1 and
// for "patrick", we will pass back 2 - if neither
// matches, we pass back IDK_NONE
BYTE FAR _export IsKeyword(LPSTR pTxt, short FAR *pLen)
{
	char FAR *pKey;
	short len;
	BYTE id;

	// Loop over the keywords we understand
	for (id = 1, pKey = pKeys[0]; *pKey; pKey = pKeys[id++]) {

		// Get the length of the current key
		len = strlen(pKey);

		// If this one matches
		if (!strncmp(pTxt, pKey, len)) {

			// Set the length and return
			// a unique identifier for it
			*pLen = len;
			return id;
		}
	}

	// No match
	return IDK_NONE;
}

// We expand the keywords here - in this example we
// map [patrick] to output Breen and map [breen] to
// output Patrick.
short FAR _export ExpandKeyword(BYTE id, LPSTR pOutbuf)
{
	short len = 0;

	switch (id) {

		// Handle 'patrick'
		case 1:
			len = wsprintf(pOutbuf, "%s", "Breen");
			break;

		// Handle 'breen'
		case 2:
			len = wsprintf(pOutbuf, "%s", "Patrick");
			break;
	}

	// Return the number of bytes
	// added to the output buffer
	return len;
}

// Return the text that corresponds to the
// keywords that we recognize
short FAR _export KeywordText(BYTE id, LPSTR pOutbuf)
{
	// Copy the keyword text into the output
	// buffer and return the length - for this
	// sample, we only need to index into the
	// key array that is defined above
	return wsprintf(pOutbuf, "%s", pKeys[id - 1]);
}

// Return the number of buttons we support
BYTE FAR _export BCBtnCount(void)
{
	// We support 2 buttons
	return 2;
}

// Return the label for the button
void FAR _export BCBtnLabel(BYTE btnId, LPSTR pLabelBuf)
{
	// Copy appropriate label into buffer
	if (btnId == 0) lstrcpy(pLabelBuf, "This is a click button");
	if (btnId == 1) lstrcpy(pLabelBuf, "This is a menu button");
	return;
}


// Return a menu that should be displayed
// when the specified button is clicked -
// this function is called just prior to
// display of the menu
HMENU FAR _export BCBtnMenu(BYTE btnId)
{
	if (btnId == 1) {

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
		AppendMenu(hMenu, 0, 1, "Item 1");
		AppendMenu(hMenu, 0, 2, "Item 2");
		AppendMenu(hMenu, 0, 3, "Item 3");
	}

	return hMenu;
}


// Handle a button click
void FAR _export BCBtnClick(BYTE btnId)
{
	MessageBox((HWND) 0, "We were clicked!", "BarClock Hook", MB_OK);
	return;
}


// Handle a menu selection
void FAR _export BCBtnMenuSelect(BYTE btnId, short itemId)
{
	// If an item was selected
	if (itemId) {

		MessageBox((HWND) 0, "Menu item selected!", "BarClock Hook", MB_OK);
	}

	// Clean up menu
	DestroyMenu(hMenu);
	hMenu = 0;

	return;
}


