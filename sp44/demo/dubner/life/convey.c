/**
*  Головной модуль - основной цикл и редактирование.
*
* Версия	1.5	(C)Copyright InfoScope Inc. 1992
*
**/

#include <stdio.h>
#include <stdlib.h>

#include <display.h>
#include <kbd.h>
#include <kbdcodes.h>
#include <utldef.h>

#include "life.h"
#include "lanit.h"
#include "lifehelp.h"
#include "lifescr.h"
#include "lifetxt.h"
#include "life_io.h"

LOCAL void Edit (void);

#ifdef XM_USED
LOCAL void MemWarns(unsigned int code, void *ptr);
#endif

void main(int argc, char *argv[])
{
   word key;
   int done=0,wasComp;

   if (argc == 2 && (*argv[1] == '?' || *argv[1] == 'h'))
      finMessage("%s",UsageMsg);

#ifdef XM_USED
   xm_setOwnWarn(MemWarns);
#endif

   if(argc == 2 && !readFile(argv[1]))
      finMessage("%s %s",badFileMsg,argv[1]);
   else
      if(argc == 1)
         kbd_PutKey(KBD_ALT(E),KBD_HEAD);

   pc_IntensityOn();
   if((wasComp=pc_CursorIsComp()) != 0)
      pc_CursorCompOff();
   dsp_Open(1);			/* Сохраним содержимое экрана.		*/
   scr_CursorOff();		/* Спрячем курсор.			*/
   StartStatisticsOut();
   StartLanit();
   StartHelp();

   drawLand ();
   OutStatistics(WaitingMsg);
   while (!done) {			/* Основной цикл "Жизни"	*/
      if(!lanit_hidden)
         ShowLanit();
      else
         HideLanit();
      key=kbd_In();
      switch (key) {
         case KBD_ALT(T) :
            askTime();				/* см. animate.c	*/
         case KBD_ALT (A) :
            Animate ();				/* см. animate.c	*/
            break;
         case KBD_ALT (W) :
            Save();                             /* см. lifeio.c		*/
            break;
         case KBD_ALT(X)  :
            done = 1;				/* Завершение работы	*/
            break;
         case KBD_ALT (L) :
            lanit_hidden = !lanit_hidden;	/* Работа с рекламным	*/
            OutStatistics(SecretMsg);		/* окном - в начале	*/
            break;
         case KBD_ALT (R) :
            Load();				/* см. lifeio.c		*/
            ReDraw ();                          /* см. lifescr.c	*/
            break;
         case KBD_ALT (E) :
            Edit();				/* см. ниже		*/
            break;
			/* UP, DOWN,LEFT, RIGHT, Home, End, PgUp, PgDn  */
                        /* осуществляют движение экрана по плоскости	*/
         case KBD_NORMAL (UP) :
            OutStatistics(MovingMsg);
            scrOldY = scrY;
            scrY--;
            ReDraw ();
            break;
         case KBD_NORMAL (DOWN) :
            OutStatistics(MovingMsg);
            scrOldY = scrY;
            scrY++;
            ReDraw ();
            break;
         case KBD_NORMAL (LEFT) :
            OutStatistics(MovingMsg);
            scrOldX = scrX;
            scrX--;
            ReDraw ();
            break;
         case KBD_NORMAL (RIGHT) :
            OutStatistics(MovingMsg);
            scrOldX = scrX;
            scrX++;
            ReDraw ();
            break;
         case KBD_NORMAL (HOME) :
            OutStatistics(MovingMsg);
            scrOldX = scrX;
            scrX--;
            scrOldY = scrY;
            scrY--;
            ReDraw ();
            break;
         case KBD_NORMAL (END) :
            OutStatistics(MovingMsg);
            scrOldX = scrX;
            scrX--;
            scrOldY = scrY;
            scrY++;
            ReDraw ();
            break;
         case KBD_NORMAL (PGUP) :
            OutStatistics(MovingMsg);
            scrOldX = scrX;
            scrX++;
            scrOldY = scrY;
            scrY--;
            ReDraw ();
            break;
         case KBD_NORMAL (PGDN) :
            OutStatistics(MovingMsg);
            scrOldX = scrX;
            scrX++;
            scrOldY = scrY;
            scrY++;
            ReDraw ();
            break;
		/* (UP, DOWN,LEFT, RIGHT, Home, End, PgUp, PgDn) + Shift */
                /* осуществляют движение рекламного окна по плоскости	 */
         case KBD_SHIFT (UP) :
            LanitMoveUp();
            break;
         case KBD_SHIFT (DOWN) :
            LanitMoveDown();
            break;
         case KBD_SHIFT (LEFT) :
            LanitMoveLeft();
            break;
         case KBD_SHIFT (RIGHT) :
            LanitMoveRight();
            break;
         case KBD_SHIFT (HOME) :
            LanitMoveUp();
            LanitMoveLeft();
            break;
         case KBD_SHIFT (END) :
            LanitMoveDown();
            LanitMoveLeft();
            break;
         case KBD_SHIFT (PGUP) :
            LanitMoveUp();
            LanitMoveRight();
            break;
         case KBD_SHIFT (PGDN) :
            LanitMoveDown();
            LanitMoveRight();
            break;
         case KBD_NORMAL (ESC) :		/* Ничего не делаем	*/
            break;
         default :			/* Все остальные клавиши -	*/
         				/*	шаг "Жизни"		*/
            OutStatistics(ThinkingMsg);
            makeStep ();
            break;
      }
      OutStatistics(WaitingMsg);
   }
   CloseHelp();
   dsp_Close(1);		/* Восстановим содержимое экрана.	*/
   pc_IntensityOff();
   if(wasComp)
      pc_CursorCompOn();

}/*main*/

/**
*
* Имя Edit -- Поредактируем
*
* Обращение	Edit();
*
* Описание	Редактирует поле клавишами:
*		  <СТРЕЛКИ> - подвинуть курсор по вертикали/горизонтали
*		  <HOME, END, PGUP, PGDN> - курсор по диагонали
*		  ПРОБЕЛ    - поставить/убрать точку
*                 ALT-C	    - почистить экран
*		В процессе работы могут быть изменены глобальные
*		переменные ScrX и ScrY, используемые функцией ReDraw
*		как координаты центра плоскости относительно центра экрана.
*
* Возвращает	void	т.е. ничего.
*
**/
LOCAL void Edit (void)
{
   CELL *c;
   int done = 0, x, y, changed = 0;
   word key;

   HideStatisticsWnd();
   HideLanit();
   scr_SetCursorSize(0,4);
   scr_CursorOn();
   x = dsp_ScreenCols () / 2;		/* Координаты центра экрана	*/
   y = dsp_ScreenRows () / 2;
   scr_SetCursorLoc (x, y);
   while(!done)
      switch (key = kbd_In ()) {
         case KBD_NORMAL(SPACE) :	/* Добавить/убрать точку	*/
            if ((c = findCell ((long) x - scrX, (long) y - scrY)) != NULL) {
               c->mode = DELETE;
               clearLand ();
            }
            else {
               if (!addCell ((long) x - scrX, (long) y - scrY, &mainList))
                  finMessage ("%s", noMemoryMsg);
               showCell (findCell ((long) x - scrX, (long) y - scrY));
            }
            changed = 1;
            scr_SetCursorLoc (x, y);
            break;
         case KBD_ALT(C)    :
            wipeLand();
            changed = 1;
            scr_SetCursorLoc (x, y);
            break;
         case KBD_NORMAL(UP)    :
            y--;
            if (y < 1) {		/* Вышли за пределы экрана?	*/
               scrY++;
               y++;
               ReDraw ();
            }
            scr_SetCursorLoc (x, y);
            break;
         case KBD_NORMAL(DOWN)  :
            y++;
            if (y > dsp_ScreenRows()) {	/* Вышли за пределы экрана?	*/
               scrY--;
               y--;
               ReDraw ();
            }
            scr_SetCursorLoc (x, y);
            break;
         case KBD_NORMAL(LEFT)  :
            x--;
            if (x < 1) {                /* Вышли за пределы экрана?	*/
               scrX++;
               x++;
               ReDraw ();
            }
            scr_SetCursorLoc (x, y);
            break;
         case KBD_NORMAL(RIGHT) :
            x++;
            if (x > dsp_ScreenCols()) { /* Вышли за пределы экрана?	*/
               scrX--;
               x--;
               ReDraw ();
            }
            scr_SetCursorLoc (x, y);
            break;
         			/* Здесь движение достигается трюком:	*/
                                /* в буфер клавиатуры кладем коды	*/
                                /* нужных клавиш - их потом 		*/
                                /* отрабатывает этот же цикл!		*/
         case KBD_NORMAL(HOME) :
            kbd_PutKey(KBD_NORMAL(UP), KBD_HEAD);
            kbd_PutKey(KBD_NORMAL(LEFT), KBD_HEAD);
            break;
         case KBD_NORMAL(END) :
            kbd_PutKey(KBD_NORMAL(DOWN), KBD_HEAD);
            kbd_PutKey(KBD_NORMAL(LEFT), KBD_HEAD);
            break;
         case KBD_NORMAL(PGUP) :
            kbd_PutKey(KBD_NORMAL(UP), KBD_HEAD);
            kbd_PutKey(KBD_NORMAL(RIGHT), KBD_HEAD);
            break;
         case KBD_NORMAL(PGDN) :
            kbd_PutKey(KBD_NORMAL(DOWN), KBD_HEAD);
            kbd_PutKey(KBD_NORMAL(RIGHT), KBD_HEAD);
            break;
         case KBD_NORMAL (ESC) :	/* Выход из редактирования	*/
            done = 1;
            break;
         case KBD_ALT (E) :		/* Еще один способ выхода	*/
            done = 1;
            changed = 0;
            break;
         default :			/* А это - выход с сохранением	*/
         				/* кода нажатой клавиши		*/
            kbd_PutKey(key,KBD_HEAD);
            done = 1;
            break;
      }
   scr_CursorOff();
   ShowStatisticsWnd();
   if (changed)
      stepNo = 0;
}/*Edit*/

#ifdef XM_USED
LOCAL void MemWarns(unsigned int code, void *ptr)
{
   if (code < 6)
      finMessage("Ошибка при работе с памятью: %s \n\r %p",xm_wngText[code],ptr);
}/*MemWarns*/
#endif
