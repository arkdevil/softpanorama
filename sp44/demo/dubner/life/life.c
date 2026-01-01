/**
*  Модуль, содержащий основные для "Жизни" функции:
*	они обеспечивают переход от позиции к позиции.
*
* Версия	1.5	(C)Copyright InfoScope Inc. 1992
*
**/

#include <stdio.h>

#include <display.h>
#include <xm.h>

#include "life.h"
#include "lifetxt.h"
#include "lifescr.h"
#include "life_io.h"

CELL *mainList;

LOCAL int vicinity [5] [5];
big	stepNo;

LOCAL void makeVicinity (CELL *center);
	/* Для точки с центром в center строит окрестность радиуса 3.	*/
	/* Рассматриваются точки из списка с головой в mainList. 	*/

LOCAL int checkCreation (int x, int y);
	/* Рассматривая окрестность точки (x,y) в Vicinity,        	*/
	/* решает, нужно ли создавать на плоскости точку           	*/
	/* с соответствующими координатами.                        	*/
	/* Возвращает 1, если нужно, 0 в противном случае.         	*/
LOCAL void glueList(CELL *list);
	/* Присоединить к списку, начинающемуся в list,           	*/
	/* список, начинающийся в mainList.                        	*/
	/* NB      Список "начинается" в p,                        	*/
	/*         если в p хранится адрес его первого элемента.   	*/

/**
*
* Имя findCell	-- Ищет элемент с координатами (x, y) в списке mainList
*
* Обращение	this = findCell (x, y);
*
*		CELL *this	найденный элемент списка mainList
*		long x		координаты искомого элемента по горизонтали
*		long y		и вертикали
*
* Описание	Ищет злемент списка начинающегося в mainList
*		с координатами (x, y) и возвращает указатель
*		на него или NULL.
*
* Возвращает	this	Указатель на найденный элемент или
*			NULL если элемент не найден
*
**/
ENTRY CELL *findCell (long x, long y)
{
   CELL *c;

   for (c = mainList;
        (c) && ((c->loc.x != x) || (c->loc.y != y));
        c = c->next);

   return c;

}/*findCell*/


/**
*
* Имя	addCell     -- Добавить точку с заданными координатами к списку
*
* Обращение	result = addCell(x,y,phead);
*
*		int result	1, если все в порядке,
*			       -1, если точка уже есть в списке,
*				0, если не хватило памяти.
*		int x,y		Координаты точки.
*		CELL **phead	Адрес переменной, содержащей
*				адрес начала списка.
*
* Описание	Проходом по элементам списка проверяем, что заданная
*		точка отсутствует в списке.
*		Если все в порядке, запрашиваем память для нового
*		элемента в списке и делаем его первым элементом.
*
* Возвращает	result	1, если все в порядке,
*		       -1, если точка уже есть в списке,
*			0, если не хватило памяти.
*
**/
ENTRY int  addCell (long x, long y, CELL **head)
{
   CELL *current;

   for (current = *head; current != NULL; current = current->next)
      if(current->loc.x == x && current->loc.y == y)
         return -1;       		/* Точка уже есть в списке.	*/

   if ((current = x_calloc (sizeof (CELL), 1)) == NULL)
      return 0;				/* Увы, не хватает памяти.	*/

   current->next = *head;		/* Добавляем в голову списка.	*/
   *head = current;
   current->loc.x = x;
   current->loc.y = y;

#ifdef XM_USED
   x_checkMem();
#endif

   return 1;				/* Победа!!!	*/

}/*addCell*/

/**
*
* Имя listLen	-- Возвращает длину списка, начинающегося в mainList
*
* Обращение	len = listLen (void);
*
*		big len		возвращаемая длинна
*
* Описание	Возвращает длинну списка начинающегося в mainList,
*		т.е. кол-во элементов в нем.
*
* Возвращает	len	Кол-во элементов в списке
*
**/
ENTRY big listLen (void)
{
   CELL *cur;
   big n;

   for (n=0,cur = mainList; cur; cur = cur->next, n++);
   return n;
}/*listLen*/

/**
*
* Имя makeVicinity	-- Создает окрестность данной точки радиусом 2
*
* Обращение	makeVicinity (center);
*
*		CELL *center	центр окрестности
*
* Описание	Массивом vicinity мы представляем окрестность радиуса 2
*		(т.е. квадрат 5x5) с центром в одной из "живых" клеток.
*		В массив vicinity ставится 1 в те места, которым
*		на исходной плоскости, представляемой списком
*		mainList, соответствует "живая" точка.
*		Использование окрестности - см. в функции makeStep.
*
* Возвращает	void	т.е. ничего.
*
**/
LOCAL void makeVicinity (CELL *center)
{
   CELL *current;
   int i, j;

   for (i = 0; i < 5; i++)              /* Обнулим массив vicinity      */
      for (j = 0; j < 5; j++)
         vicinity [i] [j] = 0;

                      /* А теперь расставим 1 там, где есть точки       */
   for (current = mainList; current != NULL; current = current->next) {
      if ((labs (center->loc.x - current->loc.x) <= 2) &&
             (labs (center->loc.y - current->loc.y) <= 2))
         vicinity [(int) (current->loc.x + 2 - center->loc.x)]
                  [(int) (current->loc.y + 2 - center->loc.y)] = 1;
   }
}/*makeVicinity*/

/**
*
* Имя makeStep	-- Делает шаг по законам "Жизни" Конвея
*
* Обращение	makeStep ();
*
*		Параметров нет
*
* Описание	Преобразует позицию на плоскости по законам игры
*		"Жизнь" Конвея:
*			1. Если у пустой клетки 3 живых соседа (соседней
*		клеткой называется такая клетка которая касается данной
*		хотя бы одним углом) в текущем поколении, то в этой клетке
*		зародится новая жизнь в следующем поколении.
*			2. Если у живой клетки больше трех живых соседей
*		в данном поколении, в следующем она умрет от перенаселения.
*			3. Если меньше двух, то она умрет от одиночества.
*		В иных случаях состояние клетки не меняется.
*
* Возвращает	void	т.е. ничего.
*
**/
ENTRY void makeStep (void)
{
   CELL *current, *newHead=NULL;
   int k,x,y;

   OutStatistics(ThinkingMsg);
   for (current = mainList; current != NULL; current = current->next) {
      makeVicinity (current);
      k = 0;
      for (x = 1; x < 4; x++)		/* Подсчитаем количество	*/
         for (y = 1; y < 4; y++)	/* соседей точки, находящейся	*/
            if (vicinity [x] [y])	/* в центре квадрата vicinity.	*/
               k++;
      if (k != 3 && k != 4)		/* См. правила 2 и 3.		*/
         current->mode = DELETE;     	/* Пометим точку на удаление    */

      for (x = 1; x < 4; x++)           /* Проход по точкам vicinity,	*/
         for (y = 1; y < 4; y++) {	/* прилежащим к ее центру.	*/
            if (vicinity [x] [y] == 0){    /* Если нет точки, проверим, */
               if (checkCreation (x, y)){  /* не нужно ли породить.   	*/
                  if(addCell (current->loc.x - 2 + x,
                             current->loc.y - 2 + y, &newHead) == 0)
                     finMessage("Не хватило памяти для очередной точки");
              }
           }
	 }
                  			/* Заметим, что центральная	*/
                                        /* всегда есть, поэтому она 	*/
                                        /* не проверяется.		*/
   }

   clearLand();			/* Выбросим из списка умершие точки.	*/

   if(newHead)			/* Если родились новые точки,		*/
      glueList(newHead);	/* перекинем их в основной список.	*/

   stepNo++;
   OutStatistics("");		/* Чтобы появились новые значения	*/
   				/* номера шага и кол-ва точек.		*/
}/*makeStep*/

/**
*
* Имя clearLand	-- Удаляет точки помеченные на удаление
*
* Обращение	clearLand();
*
* Описание	Удаляет из списка mainList все точки, у которых
*		поле mode равно DELETE, при этом, убирая их с экрана.
*
* Возвращает	void	т.е. ничего.
*
**/
ENTRY void clearLand(void)
{
   CELL *current=mainList,**Next=&mainList;

   while (current != NULL) {
      if((current)->mode == DELETE) {
         *Next = current->next;
         hideCell(current);
         x_free(current);
         current = *Next;
      }
      else {
         Next = &(current->next);
         current = current->next;
      }
   }
}/*clearLand*/

/**
*
* Имя wipeLand -- Удалить все точки
*
* Обращение	wipeLand();
*
* Описание	Пройдясь по точкам, пометим каждую из них на удаление.
*		После этого вызовем clearLand.
*
* Возвращает	void	т.е. ничего.
*
**/
ENTRY void wipeLand(void)
{
   CELL *current;

   for (current=mainList;current != NULL;current=current->next)
      current->mode = DELETE;
   clearLand();
}/*wipeLand*/

/**
*
* Имя	glueList -- Расширить основной список данным
*
* Обращение	glueList(list);
*
*		CELL *list	Добавляемый список клеток.
*
* Описание	Найдя последний элемент заданного списка клеток,
*		прицепляем к нему основной список
*		(его голова - в переменной mainList).
*		При поиске происходит (пере)вывод позиции.
*
*	NB	При поиске последнего элемента основываемся на том,
*		что список list НЕПУСТ.
*
* Возвращает	Ничего - функция типа void.
*
**/
LOCAL void glueList(CELL *list)
{
   CELL *l;

   for(l = list;l->next;l=l->next)	/* Найдем конец списка list и	*/
      showCell(l);
   l->next = mainList;		/* ...прицепим к нему список mainList	*/
   showCell(l);			/* Покажем и последнюю точку тоже.	*/

   mainList = list;			/* Объявим новый список рабочим	*/

}/*glueList*/

/**
*
* Имя	checkCreation -- Проверка точки окрестности
*
* Обращение	create = checkCreation (x, y);
*
*		int create	1 - нужно создать новую точку,
*				0 - НЕ нужно.
*		int x, y	Координаты точке внутри окрестности.
*
* Описание	Рассматривается окрестность радиуса 1 с центром в (x,y)
*		внутри основной окрестности. Считаем количество
*		ненулевых точек внутри рассматриваемой окрестности.
*		Если оно равно 3, возвращаем 1, иначе - 0.
*
* Возвращает	create	1 - нужно создать новую точку,
*			0 - НЕ нужно.
*
**/
LOCAL int checkCreation (int x, int y)
{
   int k, i, j;

   k = 0;
   for (i = 1; i < 4; i++)
      for (j = 1; j < 4; j++)
         if (vicinity [x - 2 + i] [y - 2 + j])
            k++;

   return (k == 3);

}/*checkCreation*/
