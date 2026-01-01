/*
	BarClock(tm)

	Keyword Extensions

	Copyright (c) 1994-1995  Patrick Breen
	All rights reserved.

	Atomic Dog Software
	PO Box 523
	Medford, MA 02155

	Phone (617) 396-2673
	Fax   (617) 396-5761
	BBS	 (617) 279-3561

	Internet:			pbreen@world.std.com
	CompuServe: 		70312,743
	America Online: 	PBreen

	FTP:	 ftp.std.com	/vendors/AtomicDog
	WWW:	 http://world.std.com/~pbreen
*/

#ifndef __BCHOOK_H_
#define __BCHOOK_H_

#define STRICT
#include <windows.h>

// CONSTANTS
#define HOOKVERSION   	0x00020000L	// Hook DLL Version
#define IDK_NONE		0			// Not a keyword

// Button
#define ID_BASEBUTTON	100


// DWORD BCHookVersion(DWORD FAR *pSignature);
//
//	Return the hook version constant.  This is used
// 	to check for compatibility if the hook DLL format
//	is ever modified.  The return value should always
//	be HOOKVERSION.  The signature should be set to
//	a unique signature value.  This should be a 4-byte
//	character string representing your company.  For
//	example, 'ADOG' for Atomic Dog Software.
DWORD FAR _export BCHookVersion(DWORD FAR *pSignature);


// BYTE IsKeyword(LPSTR, short FAR *);
//
// 	This routine is called to convert text within
// 	[ ] into keyword ids.  When the format string
// 	is parsed, each keyword will passed through
// 	this routine.  If the text represents a keyword
//	that this DLL supports, return a non-zero
//	identifier and set pLen to the length of the
//	keyword text.
BYTE FAR _export IsKeyword(LPSTR pTxt, short FAR *pLen);


// short ExpandKeyword(BYTE id, LPSTR pOutBuf);
//
// 	This routine is called when a string containing
//	a keyword identified by the above routine is
//	displayed.  The id returned by IsKeyword()
//	is passed in to this routine.  The output buffer
//	should be modified to contain the value that the
//	keyword represents and the number of bytes added
//	to the output buffer should be returned.
short FAR _export ExpandKeyword(BYTE id, LPSTR pOutbuf);


// short KeywordText(BYTE id, LPSTR pOutBuf);
//
// 	This routine is called to convert a keyword id
//	into it's textual representation.  The id returned
//	by IsKeyword() is passed in to this routine.
//	The output buffer should be modified to contain the
//	value that the keyword represents and the number of
//	bytes added to the output buffer should be returned.
short FAR _export KeywordText(BYTE id, LPSTR pOutbuf);


// BYTE BCBtnCount(void);
//
// 	Return the number of buttons supported by this DLL.
//	Each DLL can support up to 256 unique buttons (0 - 255).
//	The resource should contain a bitmap or icon for each
//	button.  The identifier for the resource should be the
//	button id (0 - 255) plus 100.  If a resource is not found
//	with the appropriate identifier, resource id 100 is used.
BYTE FAR _export BCBtnCount(void);


// void BCBtnLabel(short btnId, LPSTR pLabelBuf);
//
// 	This routine is called to get the text to
//	display in the tip text window (when the cursor
//	is over the button) and in the BarClock setup
//	dialog listing the available item types
void FAR _export BCBtnLabel(BYTE btnId, LPSTR pLabelBuf);


// void BCBtnMenu(short btnId, BOOL bLeftClick);
//
// 	This routine is called when the user clicks on
//	the button in the title bar.  This routine should
//	return a menu to drop in response to the click or
//	return 0 indicating that no menu should appear.
// 	If 0 is returned the BCBtnClick function is called.
HMENU FAR _export BCBtnMenu(BYTE btnId, BOOL bLeftClick);


// void BCBtnClick(short btnId, BOOL bLeftClick);
//
// 	This routine is called when the user clicks on a
//	button that has been added to the title bar.
void FAR _export BCBtnClick(BYTE btnId, BOOL bLeftClick);


// void BCBtnMenuSelect(short btnId, short itemId);
//
// 	This routine is called when the user selects a menu
//	item from a button that has been added to the title bar.
void FAR _export BCBtnMenuSelect(BYTE btnId, short itemId);



// Making BarClock load the .DLL
//
// Modify the BarClock .INI file by adding
// the following lines - the names of the
// .DLLs can be anything you choose so long as
// they each have the functions described
// above.
//
// [Hooks]
// File0=KEYWORD.DLL
// File1=BCADDON.DLL
// ...
//

#endif