//	CLOCK.CPP - Example of a derived device.
//	COPYRIGHT (C) 1991.  All Rights Reserved.
//	Zinc Software Incorporated.  Pleasant Grove, Utah  USA

#include <ui_win.hpp>
#include "demo.hpp"
#include <graphics.h>

// Define the clock event type. 
const int E_CLOCK = 10000;

class CLOCK : public UI_DEVICE, public UIW_WINDOW
{
public:
	UI_DEVICE *device;
	UIW_WINDOW *window;

	CLOCK(int left, int top);
	~CLOCK(void) {}

private:
	UI_TIME time;
	UIW_TIME *timeField;

	int Event(const UI_EVENT &event);
	void Poll(void);
};

#pragma argsused
CLOCK::CLOCK(int left, int top):
	UI_DEVICE(E_CLOCK, D_ON),
	UIW_WINDOW(left, top, 12, 3, WOF_NO_FLAGS, WOAF_NO_SIZE | WOAF_NO_DESTROY)
{
	// Setup the time.
	timeField = new UIW_TIME(1, 0, 8, &time, "",
		TMF_SECONDS | TMF_COLON_SEPARATOR | TMF_TWENTY_FOUR_HOUR | TMF_ZERO_FILL,
		WOF_JUSTIFY_CENTER | WOF_NON_SELECTABLE | WOF_NO_ALLOCATE_DATA);

	// Set this object pointer to the window pointer and add objects.
	window = this;
	*window
		+ new UIW_BORDER
		+ new UIW_TITLE("Clock")
		+ timeField;

	// Set this object pointer to the device pointer.
	device = this;
}

int CLOCK::Event(const UI_EVENT &event)
{
	int returnValue;

	// Switch on the event type.
	switch (event.type)
	{
	case E_DEVICE:
	case E_CLOCK:
		// Turn the clock on or off.
		switch (event.rawCode)
		{
		case D_OFF:
		case D_ON:
			state = event.rawCode;
			enabled = (event.rawCode == D_OFF) ? FALSE : TRUE;
			break;
		}
		returnValue = state;
		break;

	default:
		// Process window messages.
		returnValue = UIW_WINDOW::Event(event);
	}

	return(returnValue);
}

#pragma argsused
void CLOCK::Poll(void)
{
	// Check to see if the clock is on.
	if (!enabled)
		return;

	UI_TIME newTime;
	int hour, minute, second;
	int oldHour, oldMinute, oldSecond;

	// Check to see if the time has changed.
	newTime.Export(&hour, &minute, &second);
	time.Export(&oldHour, &oldMinute, &oldSecond);

	if (oldSecond != second || oldMinute != minute)
	{
		time.Import();
		timeField->DataSet(&time);
	}
}

UI_WINDOW_OBJECT *CONTROL_WINDOW::Window_Clock_Digit(void)
{
	// Add the clock to the window and event managers.
	CLOCK *clock = new CLOCK(0, 0);
//	*windowManager + clock->window;
	*eventManager + clock->device;

	// Return the window pointer.
	return (clock->window);
}
