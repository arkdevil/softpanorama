//	DISPLAY.CPP - This file contains the "Display" options.
//	COPYRIGHT (C) 1991.  All Rights Reserved.
//	Zinc Software Incorporated.  Pleasant Grove, Utah  USA

#include <ui_win.hpp>
#include "demo.hpp"

void CONTROL_WINDOW::Option_Display(int item)
{
	// Set up the default event.
	UI_EVENT event;
	event.type = S_RESET_DISPLAY;
	event.rawCode = TDM_NONE;

	// Decide on the new display type.
	if (item == DEMO_25x40_MODE)
		event.rawCode = TDM_25x40;
	else if (item == DEMO_25x80_MODE)
		event.rawCode = TDM_25x80;
	else if (item == DEMO_43x80_MODE)
		event.rawCode = TDM_43x80;

	// Send a message to reset the display.
	// (Code resides in main program loop).
	eventManager->Put(event);
}
