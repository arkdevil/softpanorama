/*
	BarClock(tm) v2.4

	Copyright (c) 1993  Patrick Breen
	All rights reserved.

	How to reach me:

		Patrick Breen
		PO Box 523
		Medford, MA 02155

		Phone	(617) 396-2673
		Fax		(617) 396-5761

		Internet:		pbreen@world.std.com
		CompuServe: 	70312,743
		AmericaOnline:	PBreen
*/

#include "bcddelib.h"

LRESULT CALLBACK WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);

HINSTANCE hAppInstance;		// Application instance

int PASCAL WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
				LPSTR lpCmd, int nCmdShow)
{
	WNDCLASS wndClass;
	HWND hWnd;
	DWORD style;
	MSG msg;

	// We can only have one instance running
	if (hPrevInstance != (HINSTANCE) 0)
		return (0);

	// Set the global and resource instance
	hAppInstance = hInstance;

	// Define the bar window class
	wndClass.style 	   = 0;
	wndClass.cbClsExtra	   = 0;
	wndClass.cbWndExtra    = 0;
	wndClass.hIcon 	   = NULL;
	wndClass.hCursor 	   = LoadCursor(0, IDC_ARROW);
	wndClass.lpszMenuName  = NULL;
	wndClass.lpfnWndProc   = WndProc;
	wndClass.hInstance     = hInstance;
	wndClass.hbrBackground = (HBRUSH) (COLOR_BACKGROUND + 1);
	wndClass.lpszClassName = "TestApp";

	// Register the window class
	if (RegisterClass(&wndClass)) {

		// Setup the window style
		style = WS_POPUP | WS_BORDER | WS_CAPTION | WS_THICKFRAME | WS_VISIBLE | WS_SYSMENU;

		// Create the bar window
		hWnd = CreateWindow("TestApp", "TestApp", style,
						0, 0, 100, 50,
						NULL, LoadMenu(hInstance, MAKEINTRESOURCE(100)),
						hInstance, NULL);

		// If we could create the app window
		if (hWnd) {

          	BCDdeLibInit();

			// Start the message loop
			while (GetMessage(&msg, (HWND) 0, 0, 0)) {
				TranslateMessage(&msg);
				DispatchMessage(&msg);
			}

			BCDdeLibFree();
		}

		// All done with the class
		UnregisterClass("TestApp", hInstance);
	}

	// Return something
	return (msg.wParam);
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	char hostBuf[128];

	switch (msg) {

		case WM_COMMAND:
			// If this is a command
			// (either from the menu or one
			//  that we sent to ourselves)
			if (HIWORD(lParam) == 0) {

				// Switch on menu ID
				switch (wParam) {

					case 100:
						BCDdeMessage("This is a DDE message!", 0);
						break;

					case 101:
						BCDdeCalendar(1995, 5, 8);
						break;

					case 102:
						BCDdePlayWave("tada.wav");
						break;

					case 103:
						BCDdeRunApp("notepad.exe");
						break;

					case 110:
						BCDdeTimerAdd("Test Timer",
								    eTmrCountUp,
								    5, 50,
								    eIncMinute,
								    0);
						break;

					case 111:
						BCDdeTimerDelete("Test Timer");
						break;

					case 112:
						BCDdeTimerStart("Test Timer");
						break;

					case 113:
						BCDdeTimerStop("Test Timer");
						break;

					case 120:
						BCDdeAlarmAdd("Test Alarm",
								    1995, 5, 8,
								    12, 0,
								    eRepeatHour);
						break;

					case 121:
						BCDdeAlarmDelete("Test Alarm");
						break;

					case 140:
						if (BCDdeQueryHost(hWnd, hostBuf, sizeof(hostBuf)) == BCDDE_NOERROR) {
							BCDdeSetHost(hostBuf);
						}
						break;

					case 141:
						BCDdeClearHost();
						break;

					case 200:
						PostQuitMessage(0);
						return 0;
				}

				return 0;
			}
			break;

		case WM_DESTROY:
			// And we are out of here!
			PostQuitMessage(0);
			return 0;
	}

	// Call DefProc
	return DefWindowProc(hWnd, msg, wParam, lParam);
}

