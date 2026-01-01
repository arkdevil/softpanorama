#ifndef UI_WIN_HPP
#include <ui_win.hpp>
#endif

//#include "brg.hpp"

#ifndef __GLOBAL_HPP
#define __GLOBAL_HPP

enum YEAR_MONTHS {
	JANUARY=1,
	FEBRUARY,
	MARTCH,
	APRIL,
	MAY,
	JUNE,
	JULY,
	AUGUST,
	SEPTEMBER,
	OCTOBER,
	NOVEMBER,
	DECEMBER };

extern void WasSelected(void *data, UI_EVENT &event);
extern void OkButton(void *object, UI_EVENT &event);
extern char *CheckSpace(char *str);
extern int CheckChar(char *str);
extern int CheckString(const char *str);
extern void Exit(void *data, UI_EVENT &event);
extern void ExitButton(void *object, UI_EVENT &event);
extern void Interrupt(void *data, UI_EVENT &event);
//extern GROUP *grp;
//extern PRIVACY_DATA *secure;
extern int FatalExec(char *msg);
extern int CheckForDigit(char *str);
extern char *GetMonth(YEAR_MONTHS year);
extern char *ConvLit(char *str,int size=8);
extern char *ReturnMonth(int _month);

#endif
