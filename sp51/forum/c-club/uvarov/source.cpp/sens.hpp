/*--------------------------------------------------*
* Файл SENS.HPP                                     *
* автор : Ушаров В.В.                               *
* Программа для теста по введенному тексту          *
* Дата  :    09.1992                                *
----------------------------------------------------*/
#ifndef ____SENS_HPP__
#define ____SENS_HPP__
#include <ui_win.hpp>
#include "matr.hpp"

const int A_BUTTON = 0;
const int B_BUTTON = 1;
const int C_BUTTON = 2;

class SENS : public UIW_WINDOW {
public:
int numer;
int current;
 ///-----------------------------------------------///
char textBuffer[2000];
char input[20][1000];
int MaxInput;
char output[10][1000];
int MaxOutput;
char filename[13];
char *header;
 ///-----------------------------------------------///
int flag;
	SENS (char *_input[],int _MaxInput,
			char *_output[],int _MaxOutput,
				char *_header="Трансцендент",
			char *prompt1="      ",
				char *prompt2="      ",
					 char *prompt3="      " ,
					char *_filename="sens.doc"
);
//        SENS(void);

//members
//member function
	~SENS() {}
	UIW_TEXT *text;
	UIW_PROMPT *message;
	UIW_PROMPT *autor;
virtual void Work(int res);
static void SENS::SNS_Button(void *data, UI_EVENT &event);
	void All_Button(UIW_BUTTON *button);

static void SENS::SNS_PrintButton(void *data, UI_EVENT &event);
	void PrintButton(UIW_BUTTON *button);

static void SENS::SNS_AsciiFile(void *data, UI_EVENT &event);
	void AsciiFile(UIW_BUTTON *button);

static void SENS::Help(void *item, UI_EVENT &event);
};

const int WHITE_CIRCLE = 0;
const int POINT_CIRCLE = 1;
const int FULL_CIRCLE  = 2;

class AFTER_VOCANCY : public SENS {
public:
int rezult[3];
//int rezult_
	AFTER_VOCANCY (char *_input[],int _MaxInput,
			char *_output[],int _MaxOutput,
				char *_header="После отпуска",
			char *prompt1="      ",
				char *prompt2="      ",
					 char *prompt3="      " ,
					char *_filename="after.voc");
void Work(int res);
};

#endif
