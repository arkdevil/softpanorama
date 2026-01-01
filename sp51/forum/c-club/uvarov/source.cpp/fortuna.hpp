
#ifndef ____FORTUNA_HPP__
#define ____FORTUNA_HPP__
#include <ui_win.hpp>
#include "matr.hpp"

class FORTUNA : public UIW_WINDOW {
public:

char input[20][1000];
int MaxInput;
char output[10][1000];
int MaxOutput;
int numer;
int legalNumer,illegalNumer;
int current;
 ///-----------------------------------------------///
char textBuffer[2000];
char filename[13];
char *header;
 ///-----------------------------------------------///
int flag;
        FORTUNA (char *_input[],int _MaxInput,
			char *_output[],int _MaxOutput,
                                char *_header="Желаю УДАЧИ",
                                        char *_filename="fortuna.doc");
//        FORTUNA(void);

//members
//member function
        ~FORTUNA() {}
	UIW_TEXT *text;
	UIW_PROMPT *message;
        UIW_PROMPT *autor;
	UIW_INTEGER *Numer;
virtual void Work(int res);

static void FORTUNA::FRN_OkNumer(void *data, UI_EVENT &event);
        void OkNumer(UIW_BUTTON *button);

static void FORTUNA::FRN_PrintButton(void *data, UI_EVENT &event);
	void PrintButton(UIW_BUTTON *button);

static void FORTUNA::FRN_AsciiFile(void *data, UI_EVENT &event);
	void AsciiFile(UIW_BUTTON *button);

static void FORTUNA::Help(void *item, UI_EVENT &event);
};

#endif
