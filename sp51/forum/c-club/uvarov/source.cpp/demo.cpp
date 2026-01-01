//	DEMO.CPP - This file contains the main program loop.
//	COPYRIGHT (C) 1991.  All Rights Reserved.
//	Zinc Software Incorporated.  Pleasant Grove, Utah  USA

#include <ui_win.hpp>
#include "demo.hpp"
/*--------------------------------------------------*
* доработка  : Ушаров В.В.                          *
* Дата  :    09.1992                                *
----------------------------------------------------*/
#include <dos.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys\stat.h>
#include <time.h>
#include <io.h>
#include <stdio.h>
#include <string.h>

// Button validate procedure for 'Esc=Exit' button.
#pragma argsused
void ExitButton(void *object, UI_EVENT &event)
{
	((UI_WINDOW_OBJECT *)object)->woStatus &= ~WOS_CURRENT;
	// Put a delete level message on the event queue to exit the program.
	event.type = S_DELETE;
	((UI_WINDOW_OBJECT *)object)->eventManager->Put(event);
}

//-------------------->>>>>>>>>>>><<<<<<<<<<<<<<-----------------------\\

void WasSelected(void *data, UI_EVENT &event)
{
	 UIW_POP_UP_ITEM *item=(UIW_POP_UP_ITEM *)data;
	item->woStatus &= ~WOS_CURRENT;
	//((UIW_POP_UP_ITEM *)data)->woStatus &= ~WOS_SELECTED;
	event.type=S_CLOSE_TEMPORARY; //ONTINUE;
//event.type = S_REDISPLAY;
	item->eventManager->Put(event);

}
//-------------------->>>>>>>>>>>><<<<<<<<<<<<<<-----------------------\\
//-------------------->>>>>>>>>>>><<<<<<<<<<<<<<-----------------------\\
int FatalExec(char *msg)
{
int i=0;
time_t t;  //current time
char message[150];
int handle;  //file descriptor
/* Emits a 7-Hz tone for 10 seconds.
   Your PC may not be able to emit a 7-Hz tone. */
t=time(NULL);
sprintf(message," Error -> < %s > recieved %s \n",msg,ctime(&t));
if ( (handle = open("Error.msg", O_CREAT | O_RDWR | O_APPEND, S_IREAD | S_IWRITE)) != EOF)
{
	write(handle,message,strlen(message));
close(handle);
}
for (i=0; i<20; i++)
	{
	sound( 5000 - i*100);
	delay(i);
	nosound();
	}
abort();
//exit(1);
return 1;
}
//-------------------->>>>>>>>>>>><<<<<<<<<<<<<<-----------------------\\



void cdecl FreeStoreException(void)
{
	// The program failed on all attempts to get memory.
	//	printf("nDEMO: Out of memory!\n");
FatalExec("\n Недостаточно памяти для нормального функционирования программы ");
//	abort();
}
//should be inserted into main()
UI_DISPLAY *_display;
UI_EVENT_MANAGER *_eventManager;
DEMO_WINDOW_MANAGER *_windowManager;


main()
{
	// Initialize the display, trying for graphics first.
	//UI_DISPLAY *
	_display = new UI_DOS_BGI_DISPLAY;
	if (!_display->installed)
	{
		delete _display;
		_display = new UI_DOS_TEXT_DISPLAY;
	}

	// Initialize the event manager and add three devices to it.
	//UI_EVENT_MANAGER *
	_eventManager=new UI_EVENT_MANAGER(100, _display);
	*_eventManager
		+ new UI_BIOS_KEYBOARD
		+ new UI_MS_MOUSE
		+ new UI_CURSOR;

	// Reset the free store exception handler.
	extern void (*_new_handler)();
	_new_handler  = FreeStoreException;


	// Initialize the demo window manager and add the control window.
	//DEMO_WINDOW_MANAGER *
	_windowManager=new DEMO_WINDOW_MANAGER(_display, _eventManager);
	*_windowManager
		+ new CONTROL_WINDOW;

	// Initialize the help and error systems.
	_errorSystem = new UI_ERROR_WINDOW_SYSTEM;

	// Wait for user response.
	int ccode;
	do
	{
		// Get input from the user.
		UI_EVENT event;
		_eventManager->Get(event, Q_NORMAL);

		// Check for a screen reset message.
		if (event.type == S_RESET_DISPLAY)
		{
			event.data = NULL;
			_windowManager->Event(event);			// Tell the managers we are
			_eventManager->Event(event);			// changing the display.
			delete _display;
			if (event.rawCode == TDM_NONE)
				_display = new UI_DOS_BGI_DISPLAY;
			else
				_display = new UI_DOS_TEXT_DISPLAY(event.rawCode);
			if (!_display->installed)
			{
				delete _display;
				_display = new UI_DOS_TEXT_DISPLAY;
			}
			event.data = _display;
			_eventManager->Event(event);			// Tell the managers we
			ccode = _windowManager->Event(event);	// changed the display.
		}
		else
			ccode = _windowManager->Event(event);
	} while (ccode != L_EXIT);

	// Clean up.
	delete _errorSystem;
	delete _display;
	delete _windowManager;
	delete _eventManager;
//	windowManager.DEMO_WINDOW_MANAGER::~DEMO_WINDOW_MANAGER();
//	eventManager.UI_EVENT_MANAGER::~UI_EVENT_MANAGER();

	return (0);
}

