/**
*  Модуль, осуществляющий проход по меню.
*	Для работы необходимы базовые менюшные средства.
*
* Версия	3.5	(C)Copyright InfoScope Inc. 1991
*
**/


#include <mn_core.h>
#include <mn_find.h>
#include <kbdcodes.h>

/**
*
* Имя   mn_traverseLineStyle  -- Проход по "линейчатому" меню
*
* Обращение pitem = mn_traverseGridStyle(pset, key);
*
* Параметры: MN_ITEM_PTR pitem	     Адрес найденного пункта или
*				     NULL, если key не удалось
*				     интерпретировать
*            MN_ITEM_SET *set        Адрес набора пунктов
*            unsigned    key         Клавиатурный код клавиши
*
* Описание   	Функция пытается интерпретировать клавиатурный код нажатой
*	 	клавиши и, если ей это удается, определяет очередной
*		активный пункт, идентификтор которого и возвращает.
*		В противном случае функция возвращает 0.
*
*     NB	Такая работа функции предполагает, что 0 не может быть
*		идентификатором пункта!
*
* Возвращает	ident	     Идентификатор найденного пункта
*			     или 0, если key не удалось интерпретировать.
*
* Вызывает следующие функции системы:
*    KBD_...(), mn_navFind...(),
*
* Версия	3.5	(C)Copyright InfoScope Inc. 1991
*
**/
ENTRY MN_ITEM_PTR mn_traverseLineStyle(MN_ITEM_SET *pset, unsigned key)
{
   MN_ITEM_PTR	pitem=NULL;
   LOC		*ploc=&mn_ItemLoc(mn_CurrentInSet(pset));

   switch(key) {
       case KBD_NORMAL(UP) :
          pitem = mn_navFindAbove(pset,ploc);
          if(pitem == NULL)
              pitem = mn_navFindLowest(pset,ploc);
          break;
       case KBD_NORMAL(DOWN) :
          pitem = mn_navFindUnder(pset,ploc);
          if(pitem == NULL)
              pitem = mn_navFindHighest(pset,ploc);
          break;
       case KBD_NORMAL(LEFT) :
          pitem = mn_navFindLeft(pset,ploc);
          if(pitem == NULL)
              pitem = mn_navFindRightest(pset,ploc);
          break;
       case KBD_NORMAL(RIGHT) :
          pitem = mn_navFindRight(pset,ploc);
          if(pitem == NULL)
              pitem = mn_navFindLeftest(pset,ploc);
          break;
       case KBD_NORMAL(HOME) :
          pitem = mn_FirstInSet(pset);
          break;
       case KBD_NORMAL(END) :
          pitem = mn_GetLastItem(pset);
          break;
   }/*switch*/

   return pitem;

}/*mn_traverseLineStyle*/

/**
*
* Имя   mn_traverseGridStyle  -- Проход по меню в стиле Grid
*
* Обращение pitem = mn_traverseGridStyle(pset, key);
*
* Параметры: MN_ITEM_PTR pitem	     Адрес найденного пункта
*				     или NULL, если key не удалось
*				     интерпретировать
*            MN_ITEM_SET *set        Адрес набора пунктов
*            unsigned    key         Клавиатурный код клавиши
*
* Описание   	Функция пытается интерпретировать клавиатурный код нажатой
*	 	клавиши и, если ей это удается, определяет очередной
*		активный пункт, идентификтор которого и возвращает.
*		В противном случае функция возвращает 0.
*
*     NB	Такая работа функции предполагает, что 0 не может быть
*		идентификатором пункта.
*
* Возвращает	ident	     Идентификатор найденного пункта
*				     или 0, если key не удалось
*				     интерпретировать.
*
* Вызывает следующие функции системы:
*    mn_navPopKey(), KBD_...(), mn_navFind...(),
*
* Версия	3.5	(C)Copyright InfoScope Inc. 1991
*
**/
ENTRY MN_ITEM_PTR mn_traverseGridStyle(MN_ITEM_SET *pset, unsigned key)
{
   MN_ITEM_PTR	pitem=NULL;
   LOC		*ploc=&mn_ItemLoc(mn_CurrentInSet(pset));

   switch(key) {
       case KBD_NORMAL(UP) :
          pitem = mn_navFindAbove(pset,ploc);
          break;
       case KBD_NORMAL(DOWN) :
          pitem = mn_navFindUnder(pset,ploc);
          break;
       case KBD_NORMAL(LEFT) :
          pitem = mn_navFindLeft(pset,ploc);
          if(pitem == NULL)
              pitem = mn_GetPrevItemPtr(pset,mn_CurrentInSet(pset));
          break;
       case KBD_NORMAL(RIGHT) :
          pitem = mn_navFindRight(pset,ploc);
          if(pitem == NULL)
              pitem = mn_GetNextItemPtr(mn_CurrentInSet(pset));
          break;
       case KBD_NORMAL(HOME) :
          pitem = mn_FirstInSet(pset);
          break;
       case KBD_NORMAL(END) :
          pitem = mn_GetLastItem(pset);
          break;
   }/*switch*/

   return pitem;

}/*mn_traverseGridStyle*/

