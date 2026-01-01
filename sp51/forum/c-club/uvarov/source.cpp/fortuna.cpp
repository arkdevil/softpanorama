/*--------------------------------------------------*
* Файл FORTUNA.CPP                                  *
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
#include "fortuna.hpp"
const int INFANT        = 3;
const int RATIONALIST  = 2;
const int ARMED_TRAIN   = 1;
const int FATALIST      = 0;
#include "textfile.hpp"  // tools for file
#include "ctr_prn.hpp"   // tools for printer
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
FORTUNA::FORTUNA(char *_input[],int _MaxInput,
			char *_output[],int _MaxOutput,
				char *_header,
					char *_filename)  :
	UIW_WINDOW(6, 8, 68, -3, WOF_NO_FLAGS, WOAF_NO_FLAGS ,
#ifdef HELP_FORTUNA_N
		     HELP_FORTUNA)
#else
		     NO_HELP_CONTEXT)
#endif
{
numer=0;
current=0;
legalNumer=0;
illegalNumer=0;
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
			FORTUNA::Help);
*/
extern void ExitButton(void *object, UI_EVENT &event);
extern void WasSelected(void *data, UI_EVENT &event);

        UIW_PULL_DOWN_ITEM *item111 =
		new UIW_PULL_DOWN_ITEM   ("      ~Выход    ", MNIF_NO_FLAGS );
	// Determine the Exit items.
	item111->Add(new UIW_POP_UP_ITEM ("        ~ДА     ", MNIF_NO_FLAGS, BTF_NO_TOGGLE,
	WOF_NO_FLAGS, ExitButton));
	item111->Add(new UIW_POP_UP_ITEM ("        ~НЕТ    ", MNIF_NO_FLAGS, BTF_NO_TOGGLE,
	WOF_NO_FLAGS,WasSelected));
		*menu+item111;
	*this+menu;
	text   = new UIW_TEXT ( 2  , 3  , 60 , 8 ,textBuffer, 2000 ,TXF_NO_FLAGS, WOF_NO_ALLOCATE_DATA | WOF_BORDER| WOF_AUTO_CLEAR );
	message= new UIW_PROMPT(40,0,"        ");
	autor= new UIW_PROMPT(1,0,"        ");
	Numer = new UIW_INTEGER ( 20, 12  , 5 ,&numer,"0..11",NMF_NO_FLAGS,WOF_BORDER | WOF_AUTO_CLEAR );
	*this
		+ new UIW_PROMPT(1 , 1 , "Если вы категорически не согласны - 0 , наоборот -10")
		+ new UIW_PROMPT(1 , 2 , "Если же частично - от 1 до 9 баллов ")
		+ new UIW_SCROLL_BAR(62, 3, 1, 8)
		+	text
		+ message
		+ new UIW_PROMPT(5,12,"Введите номер :")
		+ autor
		+ Numer
		+ new UIW_BUTTON(23, 14, 14, "~Ok", BTF_NO_TOGGLE | BTF_AUTO_SIZE ,
			WOF_BORDER | WOF_JUSTIFY_CENTER, FORTUNA::FRN_OkNumer)

		+ new UIW_BUTTON(10, 16, 15, "~Печать", BTF_NO_TOGGLE| BTF_AUTO_SIZE ,
			WOF_BORDER | WOF_JUSTIFY_CENTER, FORTUNA::FRN_PrintButton)

		+ new UIW_BUTTON(35, 16, 15, "~ASCII-фаил", BTF_NO_TOGGLE| BTF_AUTO_SIZE ,
			WOF_BORDER | WOF_JUSTIFY_CENTER, FORTUNA::FRN_AsciiFile);

}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
void FORTUNA::Work(int res)
{
switch(current) {
	case 1:case 3:case 5:case 7:case 9:
//printf("\rCase %d _>>leg",current);
		legalNumer += res;
	break;
	case 0: case 2: case 4: case 6: case 8:
//printf("\rCase %d _<<UNlegal",current);
		illegalNumer += res;
	break;
	}

if (current < (MaxInput-1)) {
	current++;
	text->DataSet(input[current],2000);
		  }
else   //exceed
	{
	flag = TO_PRN;
		if (
	(illegalNumer >= 0) && (illegalNumer <= 25) &&
	(legalNumer >= 0) && (legalNumer <= 25)
		   )
{
//	printf("%s","infant");
			text->DataSet(output[INFANT],2000);//current=2;
			}
	 else if (
	(illegalNumer >= 0) && (illegalNumer <= 25) &&
	(legalNumer >= 25)
		 )
	{
//	printf("%s","fatalist");
			text->DataSet(output[FATALIST],2000);//current=2;
			}
	 else if (
	(illegalNumer >= 25)  &&
	(legalNumer >= 0) && (legalNumer <= 25)
		 )
{
//	printf("%s","armed_train");
			text->DataSet(output[ARMED_TRAIN],2000);//current=2;
			}
	 else if (
	(illegalNumer >= 25)  &&
	(legalNumer >= 25)
		 )
{
//	printf("%s","rationalist");
			text->DataSet(output[RATIONALIST],2000);//current=2;
			}
	}
}
//member function
#pragma argsused
 void FORTUNA::FRN_OkNumer(void *data, UI_EVENT &event)
{
		UIW_BUTTON *item = (UIW_BUTTON *)data;
		((FORTUNA *)item->parent)->OkNumer(item);
//	privacy->OkRecord((UIW_BUTTON *)data);

}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
//member function
#pragma argsused
void FORTUNA::OkNumer(UIW_BUTTON *button)
{
	if (flag == TO_PRN) {
//		Melody();
		current=-1;
		flag=0;
		legalNumer=illegalNumer=0;
		return;
	}
numer=*( int *)Numer->DataGet();

	Work(numer);
	button->woStatus &= ~WOS_CURRENT;
	button->parent->woStatus &= ~WOS_CURRENT;
}

//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
#pragma argsused
void FORTUNA::FRN_PrintButton(void *data, UI_EVENT &event)
{
		UIW_BUTTON *item = (UIW_BUTTON *)data;
                ((FORTUNA *)item->parent)->PrintButton(item);
}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
void FORTUNA::PrintButton(UIW_BUTTON *button)
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
void FORTUNA::FRN_AsciiFile(void *data, UI_EVENT &event)
{
		UIW_BUTTON *item = (UIW_BUTTON *)data;
                ((FORTUNA *)item->parent)->AsciiFile(item);
}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
void FORTUNA::AsciiFile(UIW_BUTTON *button)
{

//check for denied
	if (flag != TO_PRN) return;
char txt[20];
txt[0]='\0';
sprintf(txt,"FILE : %s",filename);
message->DataSet(txt);
	char otto[40];
	*otto='\0';
	sprintf(otto,"Разработка :%c%c%c%c%c%c В.В. 1992 (c)",147,232,160,224,174,162);
autor->DataSet(otto);
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
void FORTUNA::Help(void *item, UI_EVENT &event)
{
/*
      if (_helpSystem)
      _helpSystem->DisplayHelp(((UIW_POP_UP_ITEM *)item)->windowManager,HELP_BEAR );
*/
}
