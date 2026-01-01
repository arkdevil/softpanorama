/*--------------------------------------------------*
* Файл SENS.CPP                                     *
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
#include "sens.hpp"

#include "textfile.hpp"  // tools for file
#include "ctr_prn.hpp"   // tools for printer

//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
SENS::SENS(char *_input[],int _MaxInput,
			char *_output[],int _MaxOutput,
					char *_header ,
						char *prompt1,
							char *prompt2,
								char *prompt3 ,
					char *_filename)  :
	UIW_WINDOW(6, 8, 68, -3, WOF_NO_FLAGS, WOAF_NO_FLAGS ,
		     NO_HELP_CONTEXT)
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
		+ new UIW_TITLE(header, WOF_JUSTIFY_CENTER);

	// Create the window menu.
//members
	UIW_PULL_DOWN_MENU *menu =
		new UIW_PULL_DOWN_MENU(0, WOF_NO_FLAGS, WOAF_NO_FLAGS);
extern void ExitButton(void *object, UI_EVENT &event);
extern void WasSelected(void *data, UI_EVENT &event);
       //	*menu
	UIW_PULL_DOWN_ITEM *item111 =
		new UIW_PULL_DOWN_ITEM("      ~Выход    ", MNIF_NO_FLAGS );
	// Determine the Exit items.
	item111->Add(new UIW_POP_UP_ITEM ("        ~ДА    ", MNIF_NO_FLAGS, BTF_NO_TOGGLE,
	WOF_NO_FLAGS, ExitButton));
	item111->Add(new UIW_POP_UP_ITEM ("        ~НЕТ   ", MNIF_NO_FLAGS, BTF_NO_TOGGLE,
	WOF_NO_FLAGS,WasSelected));
		*menu+item111;
	*this+menu;
	text   = new UIW_TEXT ( 2  , 4  , 60 , 8 ,textBuffer, 2000 ,TXF_NO_FLAGS, WOF_NO_ALLOCATE_DATA | WOF_BORDER| WOF_AUTO_CLEAR );
	message= new UIW_PROMPT(40,0,"        ");
	autor= new UIW_PROMPT(1,0,"        ");
	*this
		+ new UIW_SCROLL_BAR(62, 4, 1, 8)
		+	text
		+ message
		+ autor
		+ new UIW_PROMPT(1,1,prompt1)
		+ new UIW_PROMPT(1,2,prompt2)
		+ new UIW_PROMPT(1,3,prompt3)

		+ new UIW_BUTTON(10, 14, 10, "(~а)", BTF_NO_TOGGLE | BTF_AUTO_SIZE ,
			WOF_BORDER | WOF_JUSTIFY_CENTER, SENS::SNS_Button)

		+ new UIW_BUTTON(25, 14, 10, "(~б)", BTF_NO_TOGGLE | BTF_AUTO_SIZE ,
			WOF_BORDER | WOF_JUSTIFY_CENTER, SENS::SNS_Button)

		+ new UIW_BUTTON(40, 14, 10, "(~в)", BTF_NO_TOGGLE | BTF_AUTO_SIZE ,
			WOF_BORDER | WOF_JUSTIFY_CENTER, SENS::SNS_Button)

		+ new UIW_BUTTON(10, 16, 15, "~Печать", BTF_NO_TOGGLE| BTF_AUTO_SIZE ,
			WOF_BORDER | WOF_JUSTIFY_CENTER, SENS::SNS_PrintButton)

		+ new UIW_BUTTON(35, 16, 15, "~ASCII-фаил", BTF_NO_TOGGLE| BTF_AUTO_SIZE ,
			WOF_BORDER | WOF_JUSTIFY_CENTER, SENS::SNS_AsciiFile);

}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
void SENS::Work(int res )
{
//very simple 
//without any comments
switch(res) {
	case A_BUTTON:
		switch(current) {
			case 0: numer +=0; break;
			case 1: numer +=6; break;
			case 2: numer +=0; break;
			case 3: numer +=6; break;
			case 4: numer +=4; break;
			case 5: numer +=0; break;
			}
	break;
	case B_BUTTON:
		switch(current) {
			case 0: numer +=3; break;
			case 1: numer +=4; break;
			case 2: numer +=0; break;
			case 3: numer +=3; break;
			case 4: numer +=6; break;
			case 5: numer +=6; break;
			 }
	break;
	case C_BUTTON:
		switch(current) {
			case 0: numer +=6; break;
			case 1: numer +=0; break;
			case 2: numer +=3; break;
			case 3: numer +=0; break;
			case 4: numer +=3; break;
			case 5: numer +=4; break;
			}
	break;
       }
if (current < (MaxInput-1)) {
	current++;
	text->DataSet(input[current],2000);
		  }
else   
//exceed 
        {
	flag = TO_PRN;
                if ( (numer >= 0  ) && (numer <= 11) )
                        text->DataSet(output[A_BUTTON],2000);//current=2;
                else if ( ( numer >= 12) && ( numer <= 22))
                        text->DataSet(output[B_BUTTON],2000);//current=1;
                else if ( ( numer >= 23) && ( numer <= 36))
                        text->DataSet(output[C_BUTTON],2000);//current=0;

	}
}
//member function
#pragma argsused
 void SENS::SNS_Button(void *data, UI_EVENT &event)
{
		UIW_BUTTON *item = (UIW_BUTTON *)data;
		((SENS *)item->parent)->All_Button(item);
}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
//member function
void SENS::All_Button(UIW_BUTTON *button)
{
char all[10];
all[0]='\0';
strcpy(all,(char *)button->DataGet());
	if (flag == TO_PRN) {
		current=numer=-1;
		flag=0;
		return;
	}
switch((unsigned char)all[2]) {
	case 160:
                //letter A
		Work(A_BUTTON);
	break;
	case 161:
                //letter Б
		Work(B_BUTTON);
	break;
	case 162:
                //letter В
                Work(C_BUTTON);
        break;
        }
	button->woStatus &= ~WOS_CURRENT;
	button->parent->woStatus &= ~WOS_CURRENT;
}

//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
#pragma argsused
void SENS::SNS_PrintButton(void *data, UI_EVENT &event)
{
		UIW_BUTTON *item = (UIW_BUTTON *)data;
                ((SENS *)item->parent)->PrintButton(item);
}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
void SENS::PrintButton(UIW_BUTTON *button)
{
	button->woStatus &= ~WOS_CURRENT;
	button->parent->woStatus &= ~WOS_CURRENT;
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
void SENS::SNS_AsciiFile(void *data, UI_EVENT &event)
{
		UIW_BUTTON *item = (UIW_BUTTON *)data;
                ((SENS *)item->parent)->AsciiFile(item);
}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
void SENS::AsciiFile(UIW_BUTTON *button)
{

//check for denied
	if (flag != TO_PRN) return;
char txt[20];
txt[0]='\0';
sprintf(txt,"FILE : %s",filename);
message->DataSet(txt);
	char otto[40];
	*otto='\0';
// just only for fun
// write of my name in letters
        sprintf(otto,"Разработка :%c%c%c%c%c%c В.В. 1992 (c)",147,232,160,224,174,162);
autor->DataSet(otto);

TextFile my(filename,"wt");
if (my.GetStatus() != Open)
	{
        _errorSystem->ReportError(windowManager,0xFFFF,"\nError in Open file %s! ",filename);
		return;
	}
		if ( my.PutLine((char *)text->DataGet()) == EOF)
	{
        _errorSystem->ReportError(windowManager,0xFFFF,"\nError in Write to file %s! ",filename);
		return;
	}

my.Close();


	button->woStatus &= ~WOS_CURRENT;
	button->parent->woStatus &= ~WOS_CURRENT;

		return;

}


//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
