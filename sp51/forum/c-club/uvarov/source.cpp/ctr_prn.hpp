#include <ui_win.hpp>

#ifndef __PRINTER_HPP
#include "printer.hpp"
#endif

#ifndef __CONTROL_PRN_HPP__
#define __CONTROL_PRN_HPP__


class CONTROL_PRN : public UIW_WINDOW , public PRINTER {
	char *check;
public:
	int flag;

	CONTROL_PRN(char *name,int _mask = 0 ,int _portnum=0);

static void CONTROL_PRN::GR_Canceal(void *data, UI_EVENT &event);
	void Canceal(UIW_BUTTON *button);
	int PutPrn(void *data , int name=PRN_STRING); //translate and check
	void LoadFont(char *arg);
	UIW_TEXT *windowText;
	void Show(char *str);

///------------------<<<<<<<<<<<>>>>>>>>>>>>>---------------------\\
		UIW_BUTTON  *CancealButton;
};

#endif
