//	WINDOW.CPP - This file contains the "Window" options.
//	COPYRIGHT (C) 1991.  All Rights Reserved.
//	Zinc Software Incorporated.  Pleasant Grove, Utah  USA

#include <ui_win.hpp>
#include "demo.hpp"
#include <graphics.h>
/*--------------------------------------------------*
* доработка  : Ушаров В.В.                          *
* Дата  :    09.1992                                *
----------------------------------------------------*/

void CONTROL_WINDOW::Option_Utility(int item)
{
	// Get the specified window.
	UI_WINDOW_OBJECT *object = NULL;
	if (item == DEMO_CLOCK_DIGIT)
		object = Window_Clock_Digit();
	else if (item == DEMO_BIORYTHM)
		object = Window_Biorythm();
	else if (item == DEMO_CALC)
		object = Window_Calculator();

	// Add the window object to the window manager.
	if (object)
		*windowManager + object;
}





