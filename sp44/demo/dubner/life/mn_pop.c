/**
*  Модуль, поддерживающий работу с так называемым pop-меню.
*
* Версия	3.5	(C)Copyright InfoScope Inc. 1991
*
**/

#include <ctype.h>

#include "mn_pop.h"

/**
*
* Имя	mn_makePop	-- Начать работу с pop-меню
*
* Обращение     pmenu = mn_makePop(pdef, pupper_left);
*
* Параметры:    MN_POP 	     *pmenu	Возвращаемый указатель на
*					созданную структуру или
*					NULL, если не хватило памяти.
*		MN_POP_DEF   *pdef	Указатель на структуру,
*					описывающую pop-меню.
*		LOC 	  *pupper_left	Указатель на структуру,
*					задающую положение ФО на экране.
*
* Описание	Функция создает в памяти все необходимые структуры.
*		Если для какой-нибудь из них не хватает памяти, вся
*		ранее pазмещенная память освобождается и вызывается
*		системная функция wnd_Err с параметром MN_OUT_OF_MEMORY.
*
* Возвращает	pmenu	Указатель на созданную структуру или
*			NULL, если не хватило памяти.
*
* Вызывает следующие функции системы:
*
* Версия	3.5	(C)Copyright InfoScope Inc. 1991
*
**/

ENTRY MN_POP_PTR mn_makePop(MN_POP_DEF *pdef, LOC *pupper_left)
{
   MN_POP_PTR	pmenu;
   LOC        	where={0,0};

   if((pmenu=utl_alloc(MN_POP)) == NULL) {      /* Нет памяти для меню  */
      (*mn_Err)(MN_OUT_OF_MEMORY);
      return NULL;
   }
   if((mn_SetInPop(pmenu)=mn_MakeSet()) == NULL) {/* Нет памяти		*/
      utl_free(pmenu);
      (*mn_Err)(MN_OUT_OF_MEMORY);
      return NULL;
   }
		/* Создадим окно, в котором будем показывать меню	*/
   if(pupper_left != NULL)
      where = *pupper_left;
   if((mn_HoleInPop(pmenu)=mn_CreateHole(&(pdef->hole),&where)) == NULL) {
   						/* Нет памяти для окна	*/
      utl_free(mn_SetInPop(pmenu));
      utl_free(pmenu);
      (*mn_Err)(MN_OUT_OF_MEMORY);
      return NULL;
   }
				   /* Все в порядке - установим поля	*/
   pmenu->last_key  = 0;
   pmenu->current   = pdef->current;
   pmenu->protected = pdef->protected;
   pmenu->selected  = pdef->selected;
   pmenu->pick_out  = pdef->pick_out;

   return pmenu;				/* Успех	*/

}/*mn_makePop*/

/**
*
* Имя	disposePopField --	Освободить память пункта pop-меню
*
* Обращение	disposePopField(pitem);
*
* Параметры:	MN_ITEM_PTR pitem	Указатель на освобождаемый пункт.
*
* Описание  	Если соответствующие указатели не равны NULL, память,
*		на которую они указывают, освобождается.
*
* Возвращает	void	Возвращаемого значения нет.
*
* Вызывает следующие функции системы:
*
* Версия	3.5	(C)Copyright InfoScope Inc. 1991
*
**/

ENTRY void disposePopField(MN_ITEM_PTR pitem)
{
   if(mn_PopFields(pitem)) {
       if(mn_PopItemName(pitem))
          utl_free(mn_PopItemName(pitem));
       if(mn_PopItemKeys(pitem))
          utl_free(mn_PopItemKeys(pitem));
       if(pitem->link)
          utl_free(pitem->link);
   }
}/*disposePopField*/

/**
*
* Имя	mn_disposePopItem	-- Уничтожить пункт pop-меню
*
* Обращение	result = mn_disposePopItem(pmenu,ident);
*
* Параметры:    byte 	     result	Результат равен 1, если
*					все в порядке, иначе 0.
*		MN_POP_PTR pmenu	Меню, которому принадлежит
*					удаляемый пункт.
*		unsigned     ident	Идентификатор удаляемого пункта.
*
* Описание	Вызовом функции ядра mn_DisposeItem(), которой передается
*		адрес точки входа в disposePopField(), освобождается
*		пункт с заданным идентификатором.
*
* Возвращает	result	1, если удаление прошло, 0 в случае ошибки.
*
* Вызывает следующие функции системы:
*
* Версия    3.5    (C)Copyright InfoScope Inc. 1991
*       mn_DisposeItem(), disposePopField(),
*
**/

ENTRY byte mn_disposePopItem(MN_POP_PTR pmenu,unsigned ident)
{
   return mn_DisposeItem(mn_SetInPop(pmenu),ident,disposePopField);
}/*mn_disposePopItem*/

/**
*
* Имя	mn_disposePop	-- Уничтожить pop-меню
*
* Обращение	mn_disposePop(MN_POP_PTR pmenu);
*
* Параметры:	MN_POP_PTR pmenu
*
* Описание	Вызовом функции ядра mn_DisposeSet(), которой передается
*		адрес точки входа в disposePopField(), последовательно
*		освобождаются оба набора пунктов.
*		После этого освобождается память, отведенная под ФО и
*		саму структуру меню.
*
* Возвращает	void	Возвращаемого значения нет.
*
* Вызывает следующие функции системы:
*       mn_DisposeSet(), mn_disposePopField(),
*       mn_DisposeHole(), utl_free()
*
* Версия    3.5    (C)Copyright InfoScope Inc. 1991
*
**/

ENTRY void mn_disposePop(MN_POP_PTR pmenu)
{
   if(pmenu != NULL) {
       mn_DisposeSet(mn_SetInPop(pmenu),NULL,disposePopField);
       mn_DisposeHole(mn_HoleInPop(pmenu));      /* Теперь уберем окно           */
       utl_free(pmenu);			/* и отдадим память		*/
   }
}/*mn_disposePop*/


/**
*
* Имя   mn_addPopItem -- Добавить пункт и установить его поля
*
* Обращение     result = mn_addPopItem(pmenu, ident, pdef);
*
* Параметры:	int result	  1, если все в порядке,
*				  0 в противном случае
*               MN_POP_PTR pmenu   Указатель на pop-меню
*		unsigned ident	  Идентификатор пункта.
*		MN_POP_ITEM_DEF *pdef  Указатель на структуру, содержащую
*				  описание пункта.
*
* Описание      Если б-пункта с заданным идентификатором нет в меню,
*               функция добавляет его в меню. После этого она устанавливает
*               поля пункта, запрашивая необходимую память.
*               Для указания в строке keys кодов несимвольных клавиш
*               используйте символ '\xFF', за которым следует скен-код.
*               Например, "\xFF\x3B" означает, что задана клавиша F1.
*
*               Если памяти не хватает, функция уничтожает пункт и
*		возвращает 0.
*		Информация, специфичная для pop-меню, "подвешивается"
*		к полю link базисного пункта меню.
*
* Возвращает	result	1, если все в порядке,
*			0 в противном случае
*
* Вызывает следующие функции системы:
*
* Версия    3.5    (C)Copyright InfoScope Inc. 1991
*
**/

ENTRY MN_ITEM *mn_addPopItem(MN_POP_PTR pmenu, unsigned ident,
			MN_POP_ITEM_DEF *pdef, int pickInName)
{
   MN_ITEM_PTR	pitem;
   char		*lB;
   int 		lR;

   if(!pmenu || ident == 0)
      return 0;

   pitem = mn_GetItemPtr(mn_SetInPop(pmenu), ident);
   if(!pitem) {				/* Если пункт еще не создан,	*/
      					/* то сначала создадим его. 	*/
      pitem = mn_AddItem(mn_SetInPop(pmenu),ident,0,0,0);
      if(!pitem)
         return NULL;                   /* Увы, создать не удалось!  	*/
   }

   if((pitem->link = utl_alloc(MN_POP_FIELD)) == NULL) {
      mn_DisposeItem(mn_SetInPop(pmenu),ident,NULL);
      return NULL;		/* Нет памяти для pop-информации!	*/
   }
   if((mn_PopItemName(pitem)=x_calloc(1,pdef->width+1)) == NULL) {
      utl_free(pitem->link);
      mn_DisposeItem(mn_SetInPop(pmenu),ident,NULL);
      return NULL;
   }
   mn_PopPickInName(pitem) = pickInName;
   if(pdef->name && *pdef->name) {	/* Позаботимся об имени пункта	*/
      if ((lB=strchr(pdef->name,'{')) != NULL) {     /* Выделил букву?	*/
         lR = (int)(lB-pdef->name);		     /* На каком месте?	*/
         if(*(lB+2) != '}') {	/* Нет закрывающей скобки - порушим все	*/
            utl_free(pitem->link);
            utl_free(mn_PopItemName(pitem));
            mn_DisposeItem(mn_SetInPop(pmenu),ident,NULL);
            return NULL;
         }
         		/* Теперь скопируем имя - по частям	*/
         strncpy(mn_PopItemName(pitem),pdef->name,min(pdef->width,lR));
         strncat(mn_PopItemName(pitem),lB+1,1);
         strncat(mn_PopItemName(pitem),lB+3,pdef->width-lR-1);
         mn_PopPickInName(pitem) = lR;
      }
      else
         strncpy(mn_PopItemName(pitem),pdef->name,pdef->width);
      *(mn_PopItemName(pitem)+pdef->width) = 0;	  /* На всякий пожарный	*/
   }
   if(pdef->keys && *pdef->keys) /* Теперь - о "навигационных" клавишах */
      if((mn_PopItemKeys(pitem) = utl_strdup(pdef->keys)) == NULL) {
         mn_DisposeItem(mn_SetInPop(pmenu),ident,disposePopField);
         return NULL;
      }
				/* Последний удар - положение и ширина	*/
   mn_ItemLoc(pitem) = pdef->loc;
   mn_SetItemWidth(pitem,pdef->width);

   return pitem;

}/*mn_addPopItem*/

/**
*
* Имя	mn_showPopItem	-- Показать пункт pop-меню в ФО
*
* Обращение     mn_showPopItem(pmenu, pitem);
*
* Параметры:    MN_POP_PTR pmenu	Указатель на структуру pop-меню.
*		MN_ITEM_PTR pitem	Указатель на требуемый пункт.
*
* Описание	Если ЛЕВАЯ граница пункта находится в ФО, выводится
*               имя пункта.
*
*
* Возвращает	void	Возвращаемого значения нет.
*
* Вызывает следующие функции системы:
*
* Версия	3.5	(C)Copyright InfoScope Inc. 1991
*
**/

ENTRY void mn_showPopItem(MN_POP_PTR pmenu, MN_ITEM_PTR pitem)
{
   LOC  loc;
   int  len,inHole;
   char *pn;
   int fore, back;

   inHole = mn_ItemVisible(mn_HoleInPop(pmenu),pitem);
   if(inHole) {
                                /* Сначала определим цвета fore и back  */
      fore = mn_itemIsProtected(pitem) ? pmenu->protected.fore :
      		mn_ItemIdent(mn_CurrentInSet(mn_SetInPop(pmenu))) ==
      						   mn_ItemIdent(pitem) ?
             pmenu->current.fore : -1;
      if(mn_itemIsSelected(pitem))	/* У выбранного приоритет!	*/
         fore = pmenu->selected.fore;
      back = mn_itemIsSelected(pitem) ? pmenu->selected.back :
             mn_itemIsProtected(pitem) ? pmenu->protected.back : -1;
      if(mn_ItemIdent(mn_CurrentInSet(mn_SetInPop(pmenu))) ==
      						mn_ItemIdent(pitem))
         back = pmenu->current.back;	/* Приоритет у текущего!	*/
			/* А теперь - собственно вывод	*/
      loc = mn_GetItemLocInHole(mn_HoleInPop(pmenu),pitem);
      len = strlen(pn = mn_PopItemName(pitem));
      if(len > mn_ItemWidth(pitem))
         len = mn_ItemWidth(pitem);
      len = min(len,inHole);
      if(len != 0)
         wnd_PutStr(mn_HolePane(mn_HoleInPop(pmenu)),&loc,pn,len,fore,back,0);

		/* Не нужно ли покрасить какую-нибудь букву?		*/
             	/* Узнаем странным способом, является ли пункт текущим! */
      if(back != pmenu->current.back)
         back = pmenu->pick_out.back;
      if(mn_PopPickInName(pitem) != -1)
         wnd_PutChar(mn_HolePane(mn_HoleInPop(pmenu)),
                     utl_GetLoc(loc.x + mn_PopPickInName(pitem), loc.y),
                         pmenu->pick_out.fore, back,
                         *(pn+mn_PopPickInName(pitem)),0);
   }
}/*mn_showPopItem*/

/**
*
* Имя	mn_displayPop	-- Показать pop-меню в ФО
*
* Обращение	result = mn_displayPop(pmenu);
*
* Параметры:    int result  1, если все в порядке,
*                           0, если что-то не так с pmenu.
*		MN_POP_PTR pmenu	Указатель структуры, содержащей
*                           информацию о pop-меню
*
* Описание      Проверив структуру, обращаемся к функции
*               mn_showPopItem() с каждым пунктом.
*
* Возвращает    result      1, если все в порядке,
*                           0, если что-то не так с pmenu.
*
* Вызывает следующие функции системы:
*      mn_FirstInSet(), mn_HoleOn(),
*        FOREACHmn_Item(), mn_showPopItem()
*
* Версия    3.5    (C)Copyright InfoScope Inc. 1991
*
**/

ENTRY int mn_displayPop(MN_POP_PTR pmenu)
{
   MN_ITEM_PTR pitem;

   if(!pmenu)
      return 0;

   if(mn_FirstInSet(mn_SetInPop(pmenu)) == NULL)
      return 0;			/* Ошибка: поля не установлены	*/

   mn_HoleOn(mn_HoleInPop(pmenu));

   FOREACHmn_Item(mn_SetInPop(pmenu),pitem) {
       mn_showPopItem(pmenu,pitem);
   }
   return 1;
}/*mn_displayPop*/


/**
*
* Имя   mn_navPopKey   -- Опознать свое нажатие
*
* Обращение pfound = mn_navPopKey(pset,key);
*
* Параметры:    MN_ITEM *pfound Адрес найденного пункта, если
*		 		клавиша - его,
*				NULL, если клавиша не опознана.
*               MN_ITEM_SET *pset   Адрес структуры, содержащей
*                            	информацию о наборе пунктов pop-меню
*               unsigned key    Код клавиши
*
* Описание      Переданный код клавиши сравнивается с заданными
*               специальными символами пунктов; при совпадении
*               указатель найденного пункта возвращается.
*
* Возвращает	pfound	Адрес найденного пункта, если
*		 	клавиша - его,
*			NULL, если клавиша не опознана.
*
* Вызывает следующие функции системы:
*        FOREACHmn_Item(), mn_itemIsProtected(), POP_ITEM_KEYS()
*
* Версия    3.5    (C)Copyright InfoScope Inc. 1991
*
**/

ENTRY MN_ITEM_PTR mn_navPopKey(MN_ITEM_SET *pset, unsigned key)
{
   MN_ITEM_PTR	pitem;
   char *pk,ch;
   int ext;

   FOREACHmn_Item(pset, pitem)
      if(!mn_itemIsProtected(pitem) &&
        (pk = mn_PopItemKeys(pitem)) != NULL)
          for(;*pk;pk++) {
             if((ext=(*pk == OxFF)) != 0)
                pk++;
             ch = (ext ? kbd_scan(key) : kbd_ascii(key));
             if(ch == *pk)
                return pitem;
          }

   return NULL;
}/*mn_navPopKey*/


