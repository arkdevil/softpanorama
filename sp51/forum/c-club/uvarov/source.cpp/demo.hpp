//	DEMO.HPP - This file contains the demo control and class definitions.
//	COPYRIGHT (C) 1990.  All Rights Reserved.
//	Zinc Software Incorporated.  Pleasant Grove, Utah  USA

#ifndef DEMO_DISPLAY_HEADER
#define DEMO_DISPLAY_HEADER
// Display options.
const int DEMO_DISPLAY			= 10000;	// Special number.
const int DEMO_25x40_MODE		= 10001;
const int DEMO_25x80_MODE		= 10002;
const int DEMO_43x80_MODE		= 10003;
const int DEMO_GRAPHICS_MODE	= 10004;

// Window options.
const int DEMO_WINDOW			= 10100;	// Special number.

const int DEMO_GENERIC_WINDOW   = 10101;
const int DEMO_DATE_WINDOW		= 10102;
const int DEMO_TIME_WINDOW		= 10103;
const int DEMO_FORTUNE_WINDOW           = 10203;
const int DEMO_SENS_WINDOW              = 10223;
const int DEMO_VOCANCY_WINDOW              = 10226;

const int DEMO_NUMBER_WINDOW    = 10104;
const int DEMO_STRING_WINDOW	= 10105;
const int DEMO_TEXT_WINDOW		= 10106;
const int DEMO_MENU_WINDOW		= 10107;
const int DEMO_MATRIX_WINDOW	= 10108;
const int DEMO_ICON_WINDOW		= 10109;

// Event options.
const int DEMO_EVENT			= 10200;	// Special number.
const int DEMO_EVENT_MONITOR	= 10201;

//utility options
const int DEMO_CLOCK_DIGIT	= 10250;
const int DEMO_CLOCK_ANALOG	= 10255;
const int DEMO_BIORYTHM		= 10260;
const int DEMO_CALC		= 10265;


// Help options.
const int DEMO_HELP				= 10300;	// Special number.
const int DEMO_HELP_INDEX		= 10301;
const int DEMO_HELP_KEYBOARD	= 10302;
const int DEMO_HELP_MOUSE		= 10303;
const int DEMO_HELP_COMMANDS	= 10304;
const int DEMO_HELP_PROCEDURES	= 10305;
const int DEMO_HELP_OBJECTS		= 10306;
const int DEMO_HELP_HELP		= 10307;
const int DEMO_HELP_DEMO		= 10308;

class DEMO_WINDOW_MANAGER : public UI_WINDOW_MANAGER
{
public:
	DEMO_WINDOW_MANAGER(UI_DISPLAY *display, UI_EVENT_MANAGER *eventManager) :
		UI_WINDOW_MANAGER(display, eventManager, DEMO_WINDOW_MANAGER::ExitFunction) { }
	virtual int Event(const UI_EVENT &event);

private:
	static int ExitFunction(UI_DISPLAY *display,
		UI_EVENT_MANAGER *eventManager, UI_WINDOW_MANAGER *windowManager);
};

class CONTROL_WINDOW : public UIW_WINDOW
{
public:
	CONTROL_WINDOW(void);
	virtual int Event(const UI_EVENT &event);

protected:
	static void Message(void *item, UI_EVENT &event);

	void Option_Display(int item);
	void Option_Utility(int item);
	void Option_Window(int item);

	UI_WINDOW_OBJECT *Window_Generic(void);
	UI_WINDOW_OBJECT *Window_Date(void);
	UI_WINDOW_OBJECT *Window_Time(void);
        UI_WINDOW_OBJECT *Window_Sens(void);
        UI_WINDOW_OBJECT *Window_Fortune(void);
	UI_WINDOW_OBJECT *Window_Vocancy(void);

	UI_WINDOW_OBJECT *Window_Clock_Digit(void);
	UI_WINDOW_OBJECT *Window_Clock_Analog(void);
	UI_WINDOW_OBJECT *Window_Biorythm(void);
	UI_WINDOW_OBJECT *Window_Calculator(void);

private:
	int placed;
};

#endif
