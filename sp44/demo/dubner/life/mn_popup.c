/**
*  Модуль, поддерживающий работу с так называемым popup-меню.
*	Для работоспособности необходимы не только базовые
*	менюшные средства, но и модуль для pop-меню.
*
* Версия	3.5	(C)Copyright InfoScope Inc. 1991
*
**/

#include "mn_popup.h"

/**
*
* Имя	mn_makePopUp  -- Приготовить PopUp-меню
*
* Обращение	pmenu = mn_makePopUp(popDef, iDefs);
*
* Параметры:    MN_POP *pmenu           Указатель на созданное меню
*					или NULL, если что-нибудь не так.
*		MN_POP_DEF *popDef	Структура, содержащая определение
*					pop-части создаваемого меню.
*		MN_POPUP_ITEM_DEF *iDefs	Массив, элементы которого
*					определяют пункты меню.
*
* Описание      Функция готовит для работы popup-меню по описанию
*               popDef его pop-части и массива iDefs, содержащего
*               описания пунктов. Предполагается, что массив заканчивается
*               "нулевым" пунктом, т.е. пунктом с элементами, установлен-
*               ными в 0/NULL.
*
* Примечание:   mn_makePlotus (см. mn_lotus.*) - это пример функции, в
*               которой кроме аналогичного массива нужно задавать еще
*               количество элементов в нем.
*
* Возвращает    pmenu           Указатель на созданное меню
*				или NULL, если что-нибудь не так.
*
* Вызывает следующие функции системы:
*
* Версия	3.5	(C)Copyright InfoScope Inc. 1991
*
**/

ENTRY MN_POP *mn_makePopUp(MN_POP_DEF *popDef, MN_POPUP_ITEM_DEF *iDefs)
{
   MN_POP		*pmenu;
   MN_POP_ITEM_DEF	itemDef;

   itemDef.loc.x = 1;
   itemDef.loc.y = 0;
   itemDef.width = popDef->hole.size.width;
   if((pmenu=mn_makePop(popDef,NULL)) != NULL)
      for(;iDefs->name;iDefs++) {
        itemDef.name = iDefs->name;
        itemDef.keys = iDefs->keys;
        itemDef.loc.y++;
        if(mn_addPopItem(pmenu,iDefs->ident,&itemDef,-1) == NULL) {
           mn_disposePop(pmenu);
           return NULL;
        }
      }
   return pmenu;
}/*mn_makePopUp*/

/**
*
* Имя	mn_displayPopUp -- Показать popup-меню на экране
*
* Обращение	ident = mn_displayPopUp(pmenu, loc);
*
* Параметры:    int         ident   Текущий пункт на момент нажатия ENTER.
*               MN_POP_PTR *pmenu   Меню, с которым нужно работать.
*               LOC        *loc     Положение ФО на экране или NULL.
*
* Описание      Выводит меню обращением к mn_displayPop.
*
* Возвращает    ident   Текущий пункт на момент нажатия ENTER.
*
* Вызывает следующие функции системы:
*
* Версия	3.00	(C)Copyright InfoScope Inc. 1991
*
**/

ENTRY int mn_displayPopUp(MN_POP_PTR pmenu, LOC *loc)
{
   if(!pmenu)
      return 0;

   if(loc != NULL)
      wnd_Move(mn_HolePane(mn_HoleInPop(pmenu)),loc);

   return mn_displayPop(pmenu);

}/*mn_displayPopUp*/

