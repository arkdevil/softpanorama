/*--------------------------------------------------*
* Файл    MATR.CPP                                  *
* автор : Ушаров В.В.                               *
* Программа для теста по введенному тексту          *
* Дата  :    09.1992                                *
----------------------------------------------------*/
#include <stdio.h>
#include <dir.h>
#include <dos.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <io.h>

#include <ui_win.hpp>
#include "matr.hpp"

#include "textfile.hpp"  // tools for file
#include "ctr_prn.hpp"   // tools for printer
void Melody()
{
//for (int i=500; i > 100 ; i -= 100) {
   sound(200);
   delay(50);
   nosound();
/*   sound(100);
   delay(100);
   sound(i);
   delay(100);
   nosound();
   }
   */
return;
}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
TEST::TEST(char *_input[],int _MaxInput,
			char *_output[],int _MaxOutput,
					char *_filename,char *_header)  :
	UIW_WINDOW(6, 8, 58, 14, WOF_NO_FLAGS, WOAF_NO_FLAGS ,
#ifdef HELP_TEST_N
		     HELP_TEST)
#else
		     NO_HELP_CONTEXT)
#endif
{
numer=0;
current=0;
flag=0;
textBuffer[0]='\0';
strcpy(textBuffer,_input[current]);
int i;
MaxOutput=_MaxOutput;
MaxInput=_MaxInput;
header=new char[strlen(_header)+1];
	*header='\0';
	strcpy(header,_header);
//initialization of base
for (i=0 ; i < MaxInput ; i++) {
	input[i][0]='\0';
		strcpy(input[i],_input[i]);
}
for (i=0 ; i < MaxOutput ; i++)  {
	output[i][0]='\0';
	strcpy(output[i],_output[i]);
}
filename[0]='\0';
strcpy(filename,_filename);
     *this
		+ new UIW_BORDER
//                + UIW_SYSTEM_BUTTON
		+ new UIW_TITLE(header, WOF_JUSTIFY_CENTER);

	// Create the window menu.
//members
	UIW_PULL_DOWN_MENU *menu =
		new UIW_PULL_DOWN_MENU(0, WOF_NO_FLAGS, WOAF_NO_FLAGS);
       //	*menu
/*
	       +  new UIW_PULL_DOWN_ITEM("  П~одсказка ", MNIF_NO_FLAGS ,
			TEST::Help);
*/
extern void ExitButton(void *object, UI_EVENT &event);
extern void WasSelected(void *data, UI_EVENT &event);
	UIW_PULL_DOWN_ITEM *item111 =
		new UIW_PULL_DOWN_ITEM("      ~Выход    ", MNIF_NO_FLAGS );
	// Determine the Exit items.
	item111->Add(new UIW_POP_UP_ITEM ("        ~ДА    ", MNIF_NO_FLAGS, BTF_NO_TOGGLE,
	WOF_NO_FLAGS, ExitButton));
	item111->Add(new UIW_POP_UP_ITEM ("        ~НЕТ   ", MNIF_NO_FLAGS, BTF_NO_TOGGLE,
	WOF_NO_FLAGS,WasSelected));
		*menu+item111;
	*this+menu;
	text   = new UIW_TEXT ( 2  , 1  , 50 , 5 ,textBuffer, 2000 ,TXF_NO_FLAGS, WOF_NO_ALLOCATE_DATA | WOF_BORDER| WOF_AUTO_CLEAR );
	char otto[40];
	*otto='\0';
	sprintf(otto,"Разработка :%c%c%c%c%c%c В.В. 1992 (c)",147,232,160,224,174,162);
	message= new UIW_PROMPT(40,0,"        ");
	*this
		+ new UIW_SCROLL_BAR(52, 1, 1, 5)
		+	text
		+ message
		+ new UIW_PROMPT(1,0,otto)
		+ new UIW_BUTTON(10, 7, 15, "~Да", BTF_NO_TOGGLE | BTF_AUTO_SIZE ,
			WOF_BORDER | WOF_JUSTIFY_CENTER, TEST::TST_OkRecord)

		+ new UIW_BUTTON(28, 7, 15 , "~Нет", BTF_NO_TOGGLE| BTF_AUTO_SIZE ,
			WOF_BORDER | WOF_JUSTIFY_CENTER, TEST::TST_Canceal)

		+ new UIW_BUTTON(10, 9, 15, "~Печать", BTF_NO_TOGGLE| BTF_AUTO_SIZE ,
			WOF_BORDER | WOF_JUSTIFY_CENTER, TEST::TST_PrintButton)

		+ new UIW_BUTTON(28, 9, 15, "~ASCII-фаил", BTF_NO_TOGGLE| BTF_AUTO_SIZE ,
			WOF_BORDER | WOF_JUSTIFY_CENTER, TEST::TST_AsciiFile);

}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
void TEST::Work(int res)
{
if (res == HAVE_IT) numer++;
if (current < (MaxInput-1)) {

	current++;
	text->DataSet(input[current],2000);
		  }
else   //exceed
	{
	flag = TO_PRN;
		if (numer > 7 )
			text->DataSet(output[2],2000);//current=2;
		else if ( ( numer >= 1) && ( numer <= 7))
			text->DataSet(output[1],2000);//current=1;
		else if (numer <= 1 )
			text->DataSet(output[0],2000);//current=0;

	}
}
//member function
#pragma argsused
 void TEST::TST_OkRecord(void *data, UI_EVENT &event)
{
		UIW_BUTTON *item = (UIW_BUTTON *)data;
		((TEST *)item->parent)->OkRecord(item);

}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
//member function
#pragma argsused
void TEST::OkRecord(UIW_BUTTON *button)
{
	if (flag == TO_PRN) {
//		Melody();
		current=numer=-1;
		flag=0;
		return;
	}
	Work(HAVE_IT);
	button->woStatus &= ~WOS_CURRENT;
	button->parent->woStatus &= ~WOS_CURRENT;
}
#pragma argsused
 void TEST::TST_Canceal(void *data, UI_EVENT &event)
{
		UIW_BUTTON *item = (UIW_BUTTON *)data;
		((TEST *)item->parent)->Canceal(item);

}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
//member function
#pragma argsused
void TEST::Canceal(UIW_BUTTON *button)
{
	if (flag == TO_PRN) return;

	Work(HAVE_NOT);
	button->woStatus &= ~WOS_CURRENT;
	button->parent->woStatus &= ~WOS_CURRENT;
}

//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
#pragma argsused
void TEST::TST_PrintButton(void *data, UI_EVENT &event)
{
		UIW_BUTTON *item = (UIW_BUTTON *)data;
                ((TEST *)item->parent)->PrintButton(item);

}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
void TEST::PrintButton(UIW_BUTTON *button)
{
	button->woStatus &= ~WOS_CURRENT;
	button->parent->woStatus &= ~WOS_CURRENT;
//printf("\r numer =%d",flag);
//check for denied
	if (flag != TO_PRN) return;

	CONTROL_PRN *mem=new CONTROL_PRN(header,0);
	windowManager->Add(mem);
	mem->PutPrn((char *)text->DataGet(),PRN_STRING);
	//current=0;

		return;
}

//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
#pragma argsused
void TEST::TST_AsciiFile(void *data, UI_EVENT &event)
{
		UIW_BUTTON *item = (UIW_BUTTON *)data;
		((TEST *)item->parent)->AsciiFile(item);
}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
void TEST::AsciiFile(UIW_BUTTON *button)
{

//check for denied
	if (flag != TO_PRN) return;
char txt[20];
txt[0]='\0';
sprintf(txt,"FILE : %s",filename);
message->DataSet(txt);

TextFile my(filename,"at");
if (my.GetStatus() != Open)
	{
	_errorSystem->ReportError(windowManager,0xFFFF,"\nMistakes in Open ! ");
		return;
	}
		if ( my.PutLine((char *)text->DataGet()) == EOF)
	{
	_errorSystem->ReportError(windowManager,0xFFFF,"\nMistakes in Write ! ");
		return;
	}

my.Close();


	button->woStatus &= ~WOS_CURRENT;
	button->parent->woStatus &= ~WOS_CURRENT;

		return;

}


//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
#pragma argsused
void TEST::Help(void *item, UI_EVENT &event)
{
/*
      if (_helpSystem)
      _helpSystem->DisplayHelp(((UIW_POP_UP_ITEM *)item)->windowManager,HELP_BEAR );
*/
}
