/*
*	Функции, используемые для вывода окна рекламы.
* Версия	1.5	(C)Copyright InfoScope Inc. 1992
*
*/


#include <display.h>

#include "lanit.h"
#include "life_io.h"
#include "lifetxt.h"

int lanit_hidden = 0;

WIN_DEF LANIT0 = {
   {32,11},
   dsp_doAttr(DSP_BLACK,DSP_CYAN),
   0,
   1,
   {
    0xCCA,
    dsp_doAttr(DSP_LIGHTGRAY,DSP_DARKGRAY),
    '#',
    " СП Ланит ",
    dsp_doAttr(DSP_WHITE,DSP_DARKGRAY),
    " InfoScope Turbo C Tools ",
    dsp_doAttr(DSP_WHITE,DSP_DARKGRAY),
    NULL,
    dsp_doAttr(DSP_YELLOW,DSP_DARKGRAY),
    NULL,
    dsp_doAttr(DSP_YELLOW,DSP_DARKGRAY)
    }
};

LOC LANITH0 = {1,1};

const char *lanit_text[] =
  {
   " Программа, демонстрирующая\n\r"
   " игру \"Жизнь\" Конвея.\n\r"
   "\n\r"
   " Пользовательский интерфейс\n\r"
   " реализован на основе\n\r",
   " InfoScope Turbo C Tools.\n\r",
   " По вопросам поставки\n\r"
   " обращайтесь в ","СП Ланит.\n\r",
   " Тел. 261-43-62 или 331-54-27"
  };

WINDOW *lanit_wnd;

/**
*
* Имя StartLanit -- Открывает окно с рекламой
*
* Обращение	StartLanit();
*
* Описание	Открывает рекламное окно.
*		Выводит в него текст из массива lanit_text.
*
* Возвращает	void	т.е. ничего.
*
**/
void StartLanit(void)
{
   if ((lanit_wnd = wnd_Open (&LANIT0, &LANITH0, 0, lanit_hidden)) == NULL)
      finMessage(noMemoryMsg);
   wnd_WrtTxt(lanit_wnd, -1, -1, lanit_text[0]);
   wnd_WrtTxt(lanit_wnd, DSP_YELLOW, -1, lanit_text[1]);
   wnd_WrtTxt(lanit_wnd, -1, -1, lanit_text[2]);
   wnd_WrtTxt(lanit_wnd, DSP_YELLOW, -1, lanit_text[3]);
   wnd_WrtTxt(lanit_wnd, -1, -1, lanit_text[4]);
}/*StartLanit*/

/**
*
* Имя LanitMoveRight -- Сдвигает окно рекламы вправо
*
* Обращение	LanitMoveRight();
*
* Описание	Сдвигает окно рекламы вправо.
*
* Возвращает	void	т.е. ничего.
*
**/
void LanitMoveRight()
{
   LOC newloc;

   newloc.x = WND_LEFT_COL(lanit_wnd) + 1;
   newloc.y = WND_UPPER_ROW(lanit_wnd);
   wnd_Move(lanit_wnd, &newloc);
}/*LanitMoveUp*/

/**
*
* Имя LanitMoveLeft -- Сдвигает окно рекламы влево
*
* Обращение	LanitMoveLeft();
*
* Описание	Сдвигает окно рекламы влево.
*
* Возвращает	void	т.е. ничего.
*
**/
void LanitMoveLeft()
{
   LOC newloc;

   newloc.x = WND_LEFT_COL(lanit_wnd) - 1;
   newloc.y = WND_UPPER_ROW(lanit_wnd);
   wnd_Move(lanit_wnd, &newloc);
}/*LanitMoveUp*/

/**
*
* Имя LanitMoveUp -- Сдвигает окно рекламы вверх
*
* Обращение	LanitMoveUp();
*
* Описание	Сдвигает окно рекламы вверх.
*
* Возвращает	void	т.е. ничего.
*
**/
void LanitMoveUp()
{
   LOC newloc;

   newloc.x = WND_LEFT_COL(lanit_wnd);
   newloc.y = WND_UPPER_ROW(lanit_wnd) - 1;
   wnd_Move(lanit_wnd, &newloc);
}/*LanitMoveUp*/

/**
*
* Имя LanitMoveDown -- Сдвигает окно рекламы вниз
*
* Обращение	LanitMoveDown();
*
* Описание	Сдвигает окно рекламы вниз.
*
* Возвращает	void	т.е. ничего.
*
**/
void LanitMoveDown()
{
   LOC newloc;

   newloc.x = WND_LEFT_COL(lanit_wnd);
   newloc.y = WND_UPPER_ROW(lanit_wnd) + 1;
   wnd_Move(lanit_wnd, &newloc);
}/*LanitMoveUp*/
