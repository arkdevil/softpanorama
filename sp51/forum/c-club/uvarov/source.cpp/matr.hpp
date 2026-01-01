/*--------------------------------------------------*
* Файл MATR.CPP                                     *
* автор : Ушаров В.В.                               *
* Программа для теста по введенному тексту          *
* Дата  :    09.1992                                *
----------------------------------------------------*/

#ifndef ____TEST_HPP__
#define ____TEST_HPP__
#include <ui_win.hpp>

const int TO_PRN   = 0x200;
const int HAVE_IT  = 0x1;
const int HAVE_NOT = 0;

class TEST : public UIW_WINDOW {
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
	TEST (char *_input[],int _MaxInput,
			char *_output[],int _MaxOutput,
					char *_filename="test.doc",
						char *_header="Познай себя");
//        TEST(void);

//members
//member function
	~TEST() {}
	UIW_TEXT *text;
	UIW_PROMPT *message;
virtual void Work(int res);
static void TEST::TST_OkRecord(void *data, UI_EVENT &event);
	void OkRecord(UIW_BUTTON *button);

static void TEST::TST_PrintButton(void *data, UI_EVENT &event);
	void PrintButton(UIW_BUTTON *button);

static void TEST::TST_AsciiFile(void *data, UI_EVENT &event);
	void AsciiFile(UIW_BUTTON *button);

static void TEST::TST_Canceal(void *data, UI_EVENT &event);
	void Canceal(UIW_BUTTON *button);

static void TEST::Help(void *item, UI_EVENT &event);
};

class TASK1 : public TEST {
public:
        TASK1(char *_input[],int _MaxInput,
			char *_output[],int _MaxOutput,
                                        char *_filename="task_1.doc",
                                                char *_header="Познай себя");
void Work(int res);
};

class TASK3 : public TEST {
public:
int answer[11];
        TASK3(char *_input[],int _MaxInput,
			char *_output[],int _MaxOutput,
                                        char *_filename="task_3.doc",
                                                char *_header="Познай себя");
void Work(int res);
};

#endif
