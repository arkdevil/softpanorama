/***
*  Модуль обеспечивает диалог по поводу выбора файла.
*
*	Использованы функции, приведенные как пример
*	использования базисных "менюшных" средств.
*
* Версия	1.5	(C)Copyright InfoScope Inc. 1992
*
***/


#include "mn_pop.h"
/**
*
* Имя   mn_askGrid -- Опросить grid-меню
*
* Обращение pitem = mn_askGrid(pmenu,inLine);
*
* Параметры:    MN_ITEM_PTR   pitem    	Идентификатор выбранного пункта
*					или NULL, если нажат ESC.
*               GRID_MENU_PTR pmenu 	Указатель на рабочую структуру меню.
*		int	      inLine	Количество пунктов в строке меню.
*
* Описание  	Функция показывает меню, полностью осуществляет опрос
*           	пользователя, прячет ФО и возвращает идентификатор
*           	текущего пункта на момент, когда пользователь нажал
*               клавишу ENTER.
*
*
*
* Возвращает    ident         Идентификатор текущего пункта
*
* Версия	3.5	(C)Copyright InfoScope Inc. 1991
*
**/

ENTRY MN_ITEM_PTR mn_askGrid(MN_POP_PTR pmenu, int inLine)
{
    unsigned	scan,done=0,last_key=0;
    int		lines;
    MN_ITEM_PTR pitem,old;

    mn_displayPop(pmenu);           /* Показать меню                */

    while(!done) {
       if(last_key) {
          scan = last_key;
          last_key = 0;
       }
       else
          scan = kbd_In();

       if((pitem=mn_navPopKey(mn_SetInPop(pmenu),scan)) == NULL &&
           (pitem=mn_traverseGridStyle(mn_SetInPop(pmenu),scan)) == NULL)
          switch(scan) {
             case KBD_NORMAL(SPACE):    /* Пометить текущий пункт	*/
                pitem = mn_CurrentInSet(mn_SetInPop(pmenu));
                mn_itemChangeSelection(pitem);
                last_key = KBD_NORMAL(RIGHT);
                break;
             case KBD_NORMAL(ESC):
		pitem = NULL;
                done = 2;
                break;
             case KBD_NORMAL(ENTER):	/* Закончить работу	*/
                done = 1;
                break;
          }
       if(pitem != NULL) {
                         /* Покрасить "старый" текущий пункт		*/
          old = mn_CurrentInSet(mn_SetInPop(pmenu));
          mn_SetCurrent(mn_SetInPop(pmenu),pitem);
          mn_showPopItem(pmenu,old);
                        /* Установить и покрасить "новый" текущий пункт	*/
             if(pitem && !mn_ItemVisible(mn_HoleInPop(pmenu),pitem)) {
                switch(scan) {
                   case KBD_NORMAL(DOWN) :
                   case KBD_NORMAL(RIGHT) :
                      mn_MoveHole(mn_HoleInPop(pmenu),0,1);
                      break;
                   case KBD_NORMAL(UP) :
                   case KBD_NORMAL(LEFT) :
                      mn_MoveHole(mn_HoleInPop(pmenu),0,-1);
                      break;
                   case KBD_NORMAL(HOME) :
                      mn_SetHoleLoc(mn_HoleInPop(pmenu),0,0);
                      break;
                   case KBD_NORMAL(END) :
                      lines = mn_ItemsNumber(mn_SetInPop(pmenu));
                      lines /= inLine;
                      lines -= WND_PANE_HEIGHT(mn_HolePane(mn_HoleInPop(pmenu)));
                      mn_SetHoleLoc(mn_HoleInPop(pmenu),0,lines+1);
                      break;
                }
             mn_ClearHole(mn_HoleInPop(pmenu));
             mn_displayPop(pmenu);           /* Показать меню           */
             }
          else
             mn_showPopItem(pmenu,pitem);
        }
    }
    mn_HoleOff(mn_HoleInPop(pmenu));			/* Убрать ФО	*/
		/* В заключение - вернем идентификатор текущего пункта	*/
    return done == 1 ? mn_CurrentInSet(mn_SetInPop(pmenu)) : NULL;
}/*mn_askGrid*/
