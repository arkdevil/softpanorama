#ifndef MN_POP_H			/* To prevent redefinition	*/

#define MN_POP_H                        /* Prevents redefinition        */

#include <mn_core.h>
#include <mn_find.h>
#include <wnfrdef.h>
#include <kbd.h>
#include <kbdcodes.h>

/************************************************************************/
/*               Хедер - файл для меню типа pop                         */
/************************************************************************/

/*----------------------------------------------------------------------*/
/*                      Описания структур данных                        */
/*----------------------------------------------------------------------*/

typedef struct {            /*     Структура для описания pop-меню      */
                  /*     Цветовые атрибуты пунктов            */
   MN_COLORS  current,          /* текущий                              */
              selected,         /* выбранный                            */
              protected,        /* защищенный                           */
              pick_out;         /* ключевые символы                     */
   WIN_DEF    hole;             /* Описание окна                        */
} MN_POP_DEF;

typedef struct {
   LOC          loc;            /* Начальная позиция текста в ВО        */
   int          width;          /* Ширина поля вывода имени пункта      */
   char         *name;          /* Текст, идентифицирующий пункт        */
   char         *keys;          /* Клавиши, выбирающие данный пункт     */
} MN_POP_ITEM_DEF;

typedef struct {                /* На эту структуру указывает           */
                                /* поле link б-пункта                   */
   char 	*name;          /* Текст, идентифицирующий пункт        */
   int		pickInName;	/* Номер выбирающей буквы или -1.	*/
   char 	*keys;          /* Клавиши, выбирающие данный пункт     */
   void 	*link;          /* свободный указатель                  */
} MN_POP_FIELD, *MN_POP_FIELD_PTR;

                                        /*------------------------------*/
                                        /* Указатель на дополнительное  */
                                        /* поле данных pop-пункта       */
#define mn_PopFields(pitem)	((MN_POP_FIELD_PTR)((pitem)->link))
                                        /*------------------------------*/
                                        /* Имя pop-пункта               */
#define mn_PopItemName(pitem)	(mn_PopFields(pitem)->name)
                                        /*------------------------------*/
                                        /* Номер выбирающей буквы	*/
#define mn_PopPickInName(pitem)	(mn_PopFields(pitem)->pickInName)
                                        /*------------------------------*/
                                        /* Строка спец. символов        */
                                        /* pop-пункта                   */
#define mn_PopItemKeys(pitem)	(mn_PopFields(pitem)->keys)


typedef struct {                /* Рабочая структура pop-меню           */
   MN_ITEM_SET  *set;               /* Список пунктов                   */
   MN_HOLE      *hole;          /* Физическое окно                      */
                            /*     Цветовые атрибуты пунктов            */
   MN_COLORS    current,             /* текущий                         */
                protected,           /* защищенный                      */
                selected,            /* выбранный                       */
                pick_out;            /* ключевые символы                */
   int          last_key;            /* Рабочее поле, используемое при  */
                                     /* навигации                       */
} MN_POP, *MN_POP_PTR;


/*----------------------------------------------------------------------*/
/*                  Прототипы пользовательских функций                  */
/*----------------------------------------------------------------------*/
                                        /* Создать pop-меню             */
MN_POP_PTR _Cdecl mn_makePop(MN_POP_DEF *pdef, LOC *pupper_left);
                                        /*------------------------------*/
                                        /* Уничтожить pop-меню          */
void  _Cdecl    mn_disposePop(MN_POP_PTR pmenu);
                                        /*------------------------------*/
void disposePopField(MN_ITEM_PTR pitem);
                                        /* Уничтожить пункт pop-меню    */
byte  _Cdecl    mn_disposePopItem(MN_POP_PTR pmenu,unsigned ident);
                                        /*------------------------------*/
                                        /* Добавить пункт и заполнить   */
                                        /* значениями его поля          */
MN_ITEM_PTR _Cdecl mn_addPopItem(MN_POP_PTR pmenu, unsigned ident,
				 MN_POP_ITEM_DEF *pdef, int pickInName);
                                        /*------------------------------*/
					/* Указатель на ФО в pop-меню	*/
#define mn_HoleInPop(pmenu)	((pmenu)->hole)
                                        /*------------------------------*/
                                        /* Указатель на набор пунктов	*/
                                        /* в pop-меню.			*/
#define mn_SetInPop(pmenu)	((pmenu)->set)
                                        /*------------------------------*/
                                        /* Показать pop-пункт в окне    */
void  _Cdecl    mn_showPopItem(MN_POP_PTR pmenu,MN_ITEM_PTR pitem);
                                        /*------------------------------*/
                                        /* Показать pop-меню в ФО       */
int   _Cdecl    mn_displayPop(MN_POP_PTR pmenu);
                                        /*------------------------------*/
                                        /* Опознать свое нажатие        */
MN_ITEM_PTR _Cdecl mn_navPopKey(MN_ITEM_SET *pset, unsigned scan);
                                        /*------------------------------*/
                                     	/* Горизонтально-вертикальный   */
                                     	/* навигатор                    */
MN_ITEM_PTR _Cdecl mn_traverseGridStyle(MN_ITEM_SET *pset, unsigned key);
                                     	/*------------------------------*/

#endif                                  /* Ends "#ifndef MN_POP_H"      */
