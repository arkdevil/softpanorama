#ifndef MN_POPUP_H			/* To prevent redefinition	*/

#define  LOCAL		static
#define  ENTRY		extern

#include "mn_pop.h"

typedef struct {        /* Структура, задающая определение popup-пункта */
   word  ident;         /* Идентификатор       */
   char *name;          /* Имя пункта          */
   char *keys;          /* Выбирающие клавиши  */
} MN_POPUP_ITEM_DEF;

                                /* Сделать popup-меню по описанию       */
                                /* его pop-части и совокупности         */
                                /* описаний пунктов.                    */
MN_POP *mn_makePopUp(MN_POP_DEF *popDef, MN_POPUP_ITEM_DEF *iDefs);
                                /* Вывести на экран popup-меню.         */
int mn_displayPopUp(MN_POP_PTR pmenu, LOC *loc);
                                /* Пример опрашивающей функции.         */
int mn_askPopUp(MN_POP_PTR pmenu);
				/* Еще пример опрашивающей функции.	*/
MN_ITEM_PTR mn_askGrid(MN_POP_PTR pmenu,int xGrid);

#define MN_POPUP_H			/* Prevents redefinition	*/

#endif					/* Ends "#ifndef MN_POPUP_H"	*/

