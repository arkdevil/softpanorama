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
#include <mmsystem.h>

static BOOL OpenCDDevice(BOOL);
static void CloseCDDevice(void);
static void PlayTrack(DWORD track);
static void PauseCD(void);
static void StopCD(void);
static void GoToTrack(BOOL bNext);
static void CDEject(void);
static void ErrorProc(DWORD);


// Handle to the DLL instance from Libinit.asm
HANDLE LIBINST;
WORD wGlobalDeviceID = 0;
HMENU hMenu;

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
	(*pSig) = 0x03534441L;		// 'ADS' (in reverse) x3
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
	MCI_STATUS_PARMS mcistatus;
	DWORD dwRes;
	DWORD track;

	// Copy appropriate label into buffer
	lstrcpy(pLabelBuf, "CD Controls");

	if (wGlobalDeviceID) {

     	// Get current track
		mcistatus.dwItem = MCI_STATUS_CURRENT_TRACK;
		dwRes = mciSendCommand(wGlobalDeviceID, MCI_STATUS, MCI_STATUS_ITEM,
						   (DWORD)(LPSTR)&mcistatus);
		track = (dwRes)? 0:mcistatus.dwReturn;

		// Get total tracks
		mcistatus.dwItem = MCI_STATUS_NUMBER_OF_TRACKS;
		dwRes = mciSendCommand(wGlobalDeviceID, MCI_STATUS, MCI_STATUS_ITEM,
						   (DWORD)(LPSTR)&mcistatus);

		// Tack on to label
		if (track && !dwRes) {
			wsprintf(pLabelBuf + lstrlen(pLabelBuf),
				    " - (Track %d of %d)",
				    (short) track,
				    (short) mcistatus.dwReturn);
		}
	}
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
		AppendMenu(hMenu, 0, 1, "Play");
		AppendMenu(hMenu, 0, 2, "Pause");
		AppendMenu(hMenu, 0, 3, "Stop");
		AppendMenu(hMenu, MF_SEPARATOR, 0, NULL);
		AppendMenu(hMenu, 0, 4, "Next Track");
		AppendMenu(hMenu, 0, 5, "Prev Track");
		AppendMenu(hMenu, MF_SEPARATOR, 0, NULL);
		AppendMenu(hMenu, 0, 6, "Eject");
	}

	return hMenu;
}

// Handle a button select
void FAR _export BCBtnClick(BYTE btnId, BOOL bLeft)
{
	// Toggle pause state
	PauseCD();
}

// Handle a menu selection
void FAR _export BCBtnMenuSelect(BYTE btnId, short itemId)
{
	// Clean up menu
	DestroyMenu(hMenu);
	hMenu = 0;

	switch (itemId) {

		case 1: PlayTrack(1); break;
		case 2: PauseCD(); break;
		case 3: StopCD(); break;
		case 4: GoToTrack(TRUE); break;
		case 5: GoToTrack(FALSE); break;
		case 6: CDEject(); break;
	}

	return;
}


/****************************************************************************

    FUNCTION  :  OpenCDDevice(HWND)

    PURPOSE   :  This function opens the device cdaudio and leaves it open.
		 The device could also be opened by assigning the string
		 "cdaudio" as follows.

		 mciopen.lpstrDeviceType="cdaudio"

		 Using this format you would only have to specify

		 MCI_OPEN_TYPE for dwflags.

    COMMENTS  :


    HISTORY   :

****************************************************************************/
static BOOL OpenCDDevice(BOOL bErr)
{
	MCI_OPEN_PARMS mciopen;
	DWORD dwRes;

	if (wGlobalDeviceID == 0) {

		mciopen.wDeviceID = 0;
		mciopen.lpstrDeviceType = (LPSTR)"cdaudio";

		dwRes = mciSendCommand(0, MCI_OPEN, MCI_OPEN_TYPE | MCI_OPEN_SHAREABLE,
						   (DWORD)(LPSTR)&mciopen);

		// If error
		if (dwRes) {

			// if we care
			if (bErr) {
				MessageBox(NULL, "Unable to open device.\n\nMake sure that an audio CD is loaded in your player!", "CD Error", MB_OK);
			}

		} else {
			wGlobalDeviceID = mciopen.wDeviceID;
		}
	}

	return (wGlobalDeviceID != 0);
}

/****************************************************************************

    FUNCTION  :  CloseCDDevice(HWND,WORD)

    PURPOSE   :  This function closes a currently open cdaudio	device.


    COMMENTS  :	 To conserve system resources you should always close a
		 device when you are not using it.

    HISTORY   :

****************************************************************************/
static void CloseCDDevice(void)
{
	// Close the global device
	ErrorProc(mciSendCommand(wGlobalDeviceID, MCI_CLOSE, 0, NULL));
	wGlobalDeviceID = 0;
	return;
}



/****************************************************************************

    FUNCTION  :  PlayCD(HWND,WORD)

    PURPOSE   :  This function takes a currently open device ID and starts
		 the CD playing.

    COMMENTS  :  The format is set to TMSF to make sure that the when I
		 specify the starting position it is a valid position.
		 I am starting the CD at the beginning each time the
		 user presses play.  This could be just as easily the
		 currently paused position or someother position on
		 the CD.


    HISTORY   :

****************************************************************************/
void PlayTrack(DWORD track)
{
	MCI_PLAY_PARMS mciplay;
	MCI_SET_PARMS mciset;
	DWORD dwRes = 0;

	if (OpenCDDevice(TRUE)) {

		//set time format to tmsf
		mciset.dwTimeFormat = MCI_FORMAT_TMSF;
		dwRes = mciSendCommand(wGlobalDeviceID, MCI_SET, MCI_SET_TIME_FORMAT,
						   (DWORD)(LPSTR)&mciset);

		if (!dwRes) {

			// play the CD.
			mciplay.dwFrom = MCI_MAKE_TMSF(track,0,0,0);
			dwRes = mciSendCommand(wGlobalDeviceID, MCI_PLAY, MCI_FROM,
							   (DWORD)(LPSTR)&mciplay);
		}
	}

	ErrorProc(dwRes);
	return;
}


/****************************************************************************

    FUNCTION  :  StopCD(HWND,WORD)

    PURPOSE   :  This function stops a currently playing CD device.


    COMMENTS  :

    HISTORY   :

****************************************************************************/
void StopCD(void)
{
	MCI_GENERIC_PARMS mcigeneric;

	if (OpenCDDevice(FALSE)) {

	   ErrorProc(mciSendCommand(wGlobalDeviceID, MCI_STOP, 0,
						   (DWORD)(LPSTR)&mcigeneric));

	   CloseCDDevice();
	}

     return;
}

/****************************************************************************

    FUNCTION  :  PauseCD(HWND,WORD)

    PURPOSE   :  This function pauses a currently playing CD device.


    COMMENTS  :  To implement pause you must first test to see whether the
		 CD is playing or stopped.  Yes it is stopped vs pause,
		 please note.  If the status is stopped you can restart the
		 CD from the currently paused position by playing.  If the
		 CD is playing then Pause the CD.

    HISTORY   :

****************************************************************************/
void PauseCD(void)
{
	MCI_GENERIC_PARMS mcigeneric;
	MCI_STATUS_PARMS mcistatus;
	MCI_PLAY_PARMS mciplay;
	DWORD dwRes = 0;

	if (OpenCDDevice(FALSE)) {

		mcistatus.dwItem = MCI_STATUS_MODE;
		dwRes = mciSendCommand(wGlobalDeviceID, MCI_STATUS, MCI_STATUS_ITEM,
						   (DWORD)(LPSTR)&mcistatus);

		if (!dwRes) {

			// If play, then pause
			if (mcistatus.dwReturn == MCI_MODE_PLAY) {
				dwRes = mciSendCommand(wGlobalDeviceID, MCI_PAUSE, 0,
								   (DWORD)(LPSTR)&mcigeneric);

				// Failure? then stop
				if (dwRes) {
					StopCD();
					dwRes = 0;
				}

			// Resume if paused
			} else if (mcistatus.dwReturn == MCI_MODE_PAUSE) {
				dwRes = mciSendCommand(wGlobalDeviceID, MCI_PLAY, 0,
								   (DWORD)(LPSTR)&mciplay);

			// Start from beginning
			} else {
				PlayTrack(1);
			}
		}
	}

	ErrorProc(dwRes);
	return;
}


/****************************************************************************

    FUNCTION  :  GoToNextTrack(HWND,WORD)

    PURPOSE   :  This function goes to the next track on the CD.


    COMMENTS  :  To implement GoToNextTrack you first need to find the
		 current position.  Then you need to find the total
		 number of tracks so that you can wrap when you get to
		 the end of the CD.  Then you increment the track value
		 by 1, if that number is greater than the number of tracks
		 reset to 1.  Pass this value to the SEEK command.

    HISTORY   :

****************************************************************************/
void GoToTrack(BOOL bNext)
{
	MCI_STATUS_PARMS mcistatus;
	DWORD dwTrack;
	DWORD dwRes = 0;

	if (OpenCDDevice(TRUE)) {

		mcistatus.dwItem = MCI_STATUS_CURRENT_TRACK;
		dwRes = mciSendCommand(wGlobalDeviceID, MCI_STATUS, MCI_STATUS_ITEM,
						   (DWORD)(LPSTR)&mcistatus);

		if (dwRes) {
			ErrorProc(dwRes);
			return;
		}

		dwTrack = mcistatus.dwReturn;
		mcistatus.dwItem = MCI_STATUS_NUMBER_OF_TRACKS;
		dwRes = mciSendCommand(wGlobalDeviceID, MCI_STATUS, MCI_STATUS_ITEM,
						   (DWORD)(LPSTR)&mcistatus);

		if (dwRes) {
			ErrorProc(dwRes);
			return;
		}

		// Next track
		if (bNext) {

			if ((dwTrack + 1) > mcistatus.dwReturn) {
				dwTrack = 1;
			} else {
				dwTrack++;
			}

		// Previous track
		} else {

			if (dwTrack == 1) {
				dwTrack = mcistatus.dwReturn;
			} else {
				dwTrack--;
			}
		}

		// Play the track
		PlayTrack(dwTrack);
	}

	ErrorProc(dwRes);
	return;
}

/****************************************************************************

    FUNCTION  :  CDEject(HWND,WORD)

    PURPOSE   :  This function Ejects the CD from the physical CD-ROM drive.


    COMMENTS  :

    HISTORY   :

****************************************************************************/
void CDEject(void)
{
	MCI_SET_PARMS mciset;

	if (OpenCDDevice(FALSE)) {

		ErrorProc(mciSendCommand(wGlobalDeviceID, MCI_SET, MCI_SET_DOOR_OPEN,
							(DWORD)(LPSTR)&mciset));
	}

	return;
}


/****************************************************************************

    FUNCTION  :  ErrorProc(WORD)

    PURPOSE   :  ErrorProc calls mciGetErrorString to display an error
		 message returned by MCI.

    COMMENTS  :

    HISTORY   :

****************************************************************************/
void ErrorProc(DWORD dwResult)
{
	char buf[128];

	if (dwResult) {

		if (!mciGetErrorString(dwResult, buf, sizeof(buf)))
			lstrcpy(buf, "Generic Error");

		MessageBox(NULL, buf, "ERROR", MB_OK);
	}

	return;
}
