/*
*    Модуль, обеспечивающий выполнение шагов "Жизни"
*	с заданным промежутком времени между ними.
*
* Версия	1.5	(C)Copyright InfoScope Inc. 1992
*/

#include <display.h>
#include <kbd.h>

#include "lifescr.h"
#include "lifetxt.h"
#include "life.h"

int dinmsecs=2000;

#include <time.h>

/**
*
* Имя Animate -- Делает шаг каждые dinmsecs м/сек, пока не нажата клавиша
*
* Обращение	Animate();
*
* Описание	Делает шаг НЕ МЕНЕЕ, чем каждые dinmsec м/сек
*		до тех пор, пока пользователь не нажал клавишу.
*
* Возвращает    void	т.е. ничего
*
**/
ENTRY void Animate(void)
{
   double 	secs;
   time_t	startTime, currTime;

   secs = dinmsecs/1000;
   do {
      makeStep();
      startTime = time(NULL);
      OutStatistics(AnimateMsg);
      while(1) {
         currTime = time(NULL);
         if(kbd_Waiting() || (difftime(currTime,startTime) >= secs))
            break;
      }
   } while(!kbd_Waiting());
   OutStatistics("");

}/*Animate*/

#include <stdio.h>

#include <wnfrdef.h>
#include <kbdcodes.h>

WIN_DEF LIFE_IO1 = {
   {44,3},
   dsp_doAttr(DSP_BLUE,DSP_LIGHTGRAY),
   1,		/* Курсору да!		*/
   1,		/* Рамку в дамки!	*/

    {	/* Тип рамки: все линии двойные,			*/
    	/*	верхний и нижний заголовки центрированы		*/
    WN_UPDBL | WN_RDBL | WN_DWNDBL | WN_LDBL | WN_UPHC | WN_DWNHC,
    dsp_doAttr(DSP_WHITE,DSP_DARKGRAY),	/* Ее атрибуты	*/
    '#',
    NULL,		/* Верхний заголовок	*/
    dsp_doAttr(DSP_WHITE,DSP_DARKGRAY),	/* и его атрибуты	*/
    " ESC - выход без выбора ",
    dsp_doAttr(DSP_WHITE,DSP_DARKGRAY),
    NULL,
    dsp_doAttr(DSP_WHITE,DSP_DARKGRAY),
    NULL,
    dsp_doAttr(DSP_WHITE,DSP_DARKGRAY)
    }
};
LOC LIFE_IOH1 = {1,6};

/**
*
* Имя	askTime -- Спросить у пользователя про время
*
* Обращение	askTime();
*
* Описание	Выводит окно, в которое выведено текущее
*		время ожидания между последовательными шагами
*		при "оживляже".
*		Если пользователь нажал ESC, ничего не меняется.
*		В противном случае заданное число переводится
*		в числовой вид и становится текущим значением
*		времени ожидания.
*
* Возвращает	Ничего - функция типа void.
*
**/
ENTRY void askTime(void)
{
   WINDOW *wnd;
   LOC edpos={2,1};
   word edkey;
   char 	secs[25];
   float	t=dinmsecs/1000.0;

   LIFE_IO1.border.ttl = "Время между позициями в сек.";

   wnd = wnd_Open (&LIFE_IO1, &LIFE_IOH1, 0, 0);
   sprintf(secs,"%.1f",t);
   wnd_LinEd (wnd, &edpos, 40, DSP_WHITE, DSP_BLACK, 0, secs, 25, &edkey);
   wnd_Close (wnd);

   if(edkey != KBD_NORMAL(ESC))
      dinmsecs = atof(secs)*1000.0+1;

}/*askTime*/
