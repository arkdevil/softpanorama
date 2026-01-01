//	CONTROL.CPP - This file contains the main control functions.
//	COPYRIGHT (C) 1991.  All Rights Reserved.
//	Zinc Software Incorporated.  Pleasant Grove, Utah  USA

/*--------------------------------------------------*
* доработка  : Ушаров В.В.                          *
* Дата  :    09.1992                                *
----------------------------------------------------*/
#define USE_RAW_KEYS	// For accelarator key definitions.
#include <ui_win.hpp>
#include "demo.hpp"

DEMO_WINDOW_MANAGER::Event(const UI_EVENT &event)
{
	// Get the main-level return code.
	int ccode = UI_WINDOW_MANAGER::Event(event);

	// Check for event monitor windows.
	for (UI_WINDOW_OBJECT *object = First(); object; object = object->Next())
		if (object->userFlags == DEMO_EVENT_MONITOR)
		{
			UI_EVENT tEvent;
			tEvent.type = ccode;
			tEvent.rawCode = 0xFFFF;
			tEvent.data = &event;
			object->Event(tEvent);
		}

	// Return the control code.
	return (ccode);
}

CONTROL_WINDOW::CONTROL_WINDOW(void) :
	UIW_WINDOW(0, 0, 52, 13, WOF_NO_FLAGS, WOAF_LOCKED),
	placed(FALSE)
{
	UI_ITEM control[] =			// Control menu items.
	{
		{ S_CLEAR,				CONTROL_WINDOW::Message,	"~Очистить     Shift+F5" },
		{ S_REDISPLAY,			CONTROL_WINDOW::Message,	"О~бновить    Shift+F6" },
		{ S_CASCADE,			CONTROL_WINDOW::Message,	"~Каскад    Shift+F7" },
		{ 0, 					0, 							"" }, // item separator
		{ L_EXIT_FUNCTION,		CONTROL_WINDOW::Message,	"~Выход       Alt+F4" },
		{ 0, 					0, 							0 } // end of array
	};
	UI_ITEM display[] =			// Display menu items.
	{
		{ DEMO_25x40_MODE,		CONTROL_WINDOW::Message,	"~1-25x40 текстовой режим" },
		{ DEMO_25x80_MODE,		CONTROL_WINDOW::Message,	"~2-25x80 текстовой режим" },
		{ DEMO_43x80_MODE,		CONTROL_WINDOW::Message,	"~3-(43/50)x80 текстовой режим" },
		{ DEMO_GRAPHICS_MODE,	CONTROL_WINDOW::Message,	"~4-графический режим" },
		{ 0, 					0, 							0 } // end of array
	};
	UI_ITEM window[] =			// Window menu items.
	{
        { DEMO_GENERIC_WINDOW,  CONTROL_WINDOW::Message,   "~1- О горячности  " },
        { DEMO_DATE_WINDOW,     CONTROL_WINDOW::Message,   "~2- О переедании  " },
        { DEMO_TIME_WINDOW,     CONTROL_WINDOW::Message,   "~3- О cкуке       " },
        { DEMO_FORTUNE_WINDOW,     CONTROL_WINDOW::Message,"~4- О экзамене   " },
        { DEMO_SENS_WINDOW,     CONTROL_WINDOW::Message,   "~5- Трансцендентные способности" },
        { DEMO_VOCANCY_WINDOW,     CONTROL_WINDOW::Message,"~6- Что ждет Вас после отпуска ?" },
		{ 0, 					0, 							0 } // end of array
	};
	UI_ITEM utility[] =			// Window menu items.
	{
		{ DEMO_CLOCK_DIGIT,		CONTROL_WINDOW::Message,	"~1- Цифровые часы" },
		{ DEMO_BIORYTHM,		CONTROL_WINDOW::Message,	"~3- Биоритмы" },
		{ DEMO_CALC,			CONTROL_WINDOW::Message,	"~4- Калкулятор" },
		{ 0, 					0, 							0 } // end of array
	};

	// Attach the sub-window objects to the control window.
	*this
		+ new UIW_BORDER
		+ new UIW_MAXIMIZE_BUTTON
		+ new UIW_MINIMIZE_BUTTON
		+ UIW_SYSTEM_BUTTON::Generic()
		+ new UIW_TITLE("Управляющая панель")
		+ &(*new UIW_PULL_DOWN_MENU(0, WOF_NO_FLAGS, WOAF_NO_FLAGS)
			+ new UIW_PULL_DOWN_ITEM(" ~Управление ", MNF_NO_FLAGS, control)
			+ new UIW_PULL_DOWN_ITEM(" ~Монитор ", MNF_NO_FLAGS, display)
                        + new UIW_PULL_DOWN_ITEM(" ~Развлечения ", MNF_NO_FLAGS, window)
			+ new UIW_PULL_DOWN_ITEM("  ~Утилиты    ", MNF_NO_FLAGS, utility));
}

int CONTROL_WINDOW::Event(const UI_EVENT &event)
{
	// Check for an accelerator key.
	int ccode = event.type;
	if (ccode == S_CREATE && !placed)
	{
		// Center the window on the screen.
		display->RegionConvert(true, &woStatus, WOS_GRAPHICS);
		int width = true.right - true.left + 1;
		int height = true.bottom - true.top + 1;
		true.left = (display->columns - width) / 2;
		true.top = (display->lines - height) / 2;
		true.right = true.left + width - 1;
		true.bottom = true.top + height - 1;
		relative = true;
		placed = TRUE;
	}
	if (ccode == E_KEY)
	{
		// Define the set of accelerator keys.
		static struct ACCELERATOR_PAIR
		{
			USHORT rawCode;
			int logicalType;
		} acceleratorTable[] =
		{
			{ SHIFT_F5,		S_CLEAR },
			{ SHIFT_F6,		S_REDISPLAY },
			{ SHIFT_F7,		S_CASCADE },
			{ ALT_F4,		L_EXIT_FUNCTION },
			{ 0, 0 } 		// End of array.
		};

		for (int i = 0; acceleratorTable[i].rawCode; i++)
			if (event.rawCode == acceleratorTable[i].rawCode)
			{
				UI_EVENT tEvent = event;
				tEvent.type = acceleratorTable[i].logicalType;
				eventManager->Put(tEvent);	// Put the accelarator key
				return (ccode);				// into the system.
			}
	}

	// Process the event according to its type.
	if (ccode >= DEMO_HELP)
;	       //	Option_Help(event.type);			// Help option.
	else if (ccode >= DEMO_CLOCK_DIGIT)
		Option_Utility(event.type);			// Event option.
	else if (ccode >= DEMO_WINDOW)
		Option_Window(event.type);			// Window option.
	else if (ccode >= DEMO_DISPLAY)
		Option_Display(event.type);			// Window option.
	else
		ccode = UIW_WINDOW::Event(event);	// Unknown event.

	// Return the control code.
	return (ccode);
}

void CONTROL_WINDOW::Message(void *data, UI_EVENT &event)
{
	// Remove the temporary pull-down menu.
	UIW_BUTTON *item = (UIW_BUTTON *)data;
	event.type = S_CLOSE_TEMPORARY;
	item->eventManager->Put(event);

	// Put the message in the event queue so the control window
	// can handle it at a higher level.
	event.type = item->value;
	item->eventManager->Put(event);
}

#pragma argsused
int DEMO_WINDOW_MANAGER::ExitFunction(UI_DISPLAY *display,
	UI_EVENT_MANAGER *eventManager, UI_WINDOW_MANAGER *windowManager)
{
	// Determine the exit window coordinates.
	int width = 32;
	int height = 10;
	int left = (display->columns / display->cellWidth - width) / 2;
	int top = (display->lines / display->cellHeight - height) / 2;


	// Create and attach the exit confirmation window.
	UIW_WINDOW *window = new UIW_WINDOW(left, top, width, height,
		WOF_NO_FLAGS, WOAF_MODAL | WOAF_NO_SIZE | WOAF_NO_MOVE);
	*window
		+ new UIW_BORDER
		+ new UIW_SYSTEM_BUTTON
		+ new UIW_TITLE("Выход из программы")
		+ new UIW_PROMPT(6, 2, "Закончить развлекаться")
//		+ new UIW_PROMPT(6, 3, " данных. ")
		+ new UIW_BUTTON(4, 6, 10, "~Да", BTF_NO_TOGGLE | BTF_AUTO_SIZE,
			WOF_BORDER | WOF_JUSTIFY_CENTER, CONTROL_WINDOW::Message, L_EXIT)
		+ new UIW_BUTTON(16, 6, 10, "~Нет", BTF_NO_TOGGLE | BTF_AUTO_SIZE,
			WOF_BORDER | WOF_JUSTIFY_CENTER, CONTROL_WINDOW::Message, S_DELETE);
	*windowManager
		+ window;

	// Return the control code.
	return (S_CONTINUE);
}
