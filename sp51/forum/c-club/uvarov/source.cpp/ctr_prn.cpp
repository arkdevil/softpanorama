/*--------------------------------------------------*
* Файл CTR_PRN.CPP                                  *
* автор : Ушаров В.В.                               *
* Дата  :    09.1992                                *
* Организация работы с принтером                    *
----------------------------------------------------*/
#include <ui_win.hpp>
#include <stdio.h>
#include <string.h>
#include <graphics.h>
#include <dos.h>
#include <process.h>
#include <errno.h>
#include <dir.h>

#include "ctr_prn.hpp"
int CheckPrn=0;

//------------------------------------------------------------//
CONTROL_PRN::CONTROL_PRN(char *name,int _portnum,int _mask ) :
	UIW_WINDOW(10, 1, 45, 10, WOF_NO_FLAGS, WOAF_TEMPORARY , NO_HELP_CONTEXT) ,
	PRINTER (_portnum,_mask)

{
flag=0;
before=0;
after=0;
     *this
		+ new UIW_BORDER
		+ new UIW_TITLE(name, WOF_JUSTIFY_CENTER);

	*this
	  + new   UIW_BUTTON(16, 6, 14, "~Отменить" ,BTF_NO_TOGGLE| BTF_AUTO_SIZE ,
			WOF_BORDER | WOF_JUSTIFY_CENTER, CONTROL_PRN::GR_Canceal);
	windowText= new UIW_TEXT(1, 1, 40, 4,
			"              ",
			128, TXF_NO_FLAGS, WOF_VIEW_ONLY | WOF_NON_SELECTABLE | WOF_BORDER);
	*this + windowText;
}
//------------------------------------------------------------//
#pragma argsused
void CONTROL_PRN::GR_Canceal(void *data, UI_EVENT &event)
{
	      UIW_BUTTON *item = (UIW_BUTTON *)data;
	      ((CONTROL_PRN *)item->parent)->Canceal(item);

}
//------------------------------------------------------------//
void CONTROL_PRN::Canceal(UIW_BUTTON *button)
{
//convert means to edsire values
UI_EVENT event;
	// Make the current field non current and update the matrices.
	button->woStatus &= ~WOS_CURRENT;
	button->parent->woStatus &= ~WOS_CURRENT;
	// Put a delete level message on the event queue to exit the program.
	event.type = S_DELETE;
	button->eventManager->Put(event);
}
//------------------------------------------------------------//
void CONTROL_PRN::Show(char *str)
{
	windowText->DataSet(str,120);
}
//------------------------------------------------------------//
//check & go on
#pragma argsused
int CONTROL_PRN::PutPrn(void *data , int name)
{
int sts;
int tck=0;

//UI_EVENT event;
//int ccode;
	do {
		//for sound beware
		if (tck > 15000 ) {
			for (int i=200;i <350; i+=50) {
				sound(i); delay(i);nosound();
			}
			tck=0;
			}
		tck++;
		sts = DesireAction(); // == PRN_WAIT
		if (sts == PRN_CANCEAL)
			return (-1);
		if (sts == PRN_CONTINUE)
			break;
		if (before == TURN_ON) after =TURN_ON;

		} while (sts == PRN_WAIT);
if (after == TURN_ON) {
after =0;

//load font
// may be do it later

Show("\nВы забыли загрузить фонт");
//delay(2000);
}
	Put(data,name);
//just an any case
return 0;
}
#pragma argsused
void CONTROL_PRN::LoadFont(char *arg)
{
//Don't care about.
//
}

