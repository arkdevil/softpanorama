/**
* Модуль обеспечивает запись текущей позиции в файл и
*	чтение позиции из файла.
*
* Версия	1.5	(C)Copyright InfoScope Inc. 1992
*
**/


#include <dir.h>
#include <stdio.h>
#include <conio.h>

#include <display.h>
#include <kbdcodes.h>
#include <wnfrdef.h>

#include "life_io.h"
#include "lifescr.h"
#include "life.h"
#include "lifetxt.h"
#include "filemenu.h"

LOCAL void saveToFile (FILE *outF);
LOCAL void makeBak (char *name);

FILE *wFile;

WIN_DEF LIFE_IO0 = {
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

LOC LIFE_IOH0 = {1,6};

/**
*
* Имя readFile -- Чтение конфигурации из файла
*
* Обращение	result = readFile(filename);
*
*		int result	1, если все в порядке,
*				0, если файл не удалось открыть.
*		char *filename  Имя файла.
*
* Описание	Конфигурация задается в текстовом виде
*		последовательностью строк, каждая из которых
*		содержит пару: x- и y-координату точки на
*		плоскости. Конечно, координаты могут быть как
*		положительными, так и отрицательными.
*
*		В результате работы функции будет построен список
*		с головой в mainList, содержащий координаты точек из
*		файла.
*
*		Если при добавлении очередной точки в список не хватило
*		памяти, функция вызывает finMessage с сообщением noMemoryMsg.
*		Ожидается, что после этого выполнение программы прекратится
*		с кодом возврата -1.
*
*		Во время чтения данных вычисляется центр тяжести
*		позиции. Значения meanX и meanY преобразуются в
*		координаты центра тяжести делением на кол-во точек.
*		Потом центр тяжести становится центром плоскости (ScrX,ScrY)
*		и центром экрана.
*
*	Прим.	Сохраняемые ScrOldX и ScrOldY используются в функции ReDraw
*		для того, чтобы стереть с экрана текущую позицию.
*
* Возвращает	result	1, если все в порядке,
*			0, если файл не удалось открыть.
*
**/

ENTRY int readFile(char *name)
{
   char str[80];
   long x, y, i;
   long meanX=0, meanY=0;

   if((wFile = fopen(name,"rt")) == NULL)
      return 0;

   wipeLand();
   meanX = meanY = i = 0;
   while (fgets (str, 80, wFile)) {
      sscanf (str, "%ld %ld", &x, &y);
      if(!addCell (x, y, &mainList))
         finMessage(noMemoryMsg);
      meanX += x;
      meanY += y;
      i++;
   }

   if(i) {
      meanX /= i;
      meanY /= i;
   }
   scrX = pc_GetScreenCols () / 2;
   scrX -= meanX;
   scrOldX = scrX;
   scrY = pc_GetScreenRows () / 2;
   scrY -= meanY;
   scrOldY = scrY;
   return 1;
}/*readFile*/

/**
*
* Имя askFileName	-- Запрашивает у пользователя имя файла
*
* Обращение	ret = askFileName(char *name,int save)
*
*		int ret		Возвращает: 1, если все благополучно
*				0, если пользователь нажал на <ESC>
*		char *name	Имя файла. Если строка непуста при
*				входе, пользователь редактирует ее.
*				В противном случае, пользователь
*				вводит имя файла с самого начала.
*				Если пользователь нажал <ESC>, то
*				при выходе строка name пуста (таково
*				свойство функции wnd_LinEd).
*		int save	Управляет верхним заголовком окна:
*				1 - в заголовке "Enter file name to save to",
*				0 - в заголовке "Enter file name to load from".
*
* Описание	Создаем окно, выводим, редактируем, возвращаем.
*
* Возвращает	ret		Возвращает: 1, если все благополучно
*				0, если пользователь нажал на <ESC>
*
**/
LOCAL int askFileName(char *name,int save)
{
   WINDOW *wnd;
   LOC edpos={2,1};
   word edkey;

   LIFE_IO0.border.ttl = save ? stitle : ltitle;
   wnd = wnd_Open (&LIFE_IO0, &LIFE_IOH0, 0, 0);
   wnd_LinEd (wnd, &edpos, 40, DSP_WHITE, DSP_BLACK, 0, name, MAXPATH, &edkey);
   wnd_Close (wnd);

   return edkey == KBD_NORMAL(ESC) ? 0 : 1;

}/*askFileName*/

/**
*
* Имя Save -- Записывает конфигурацию в файл
*
* Обращение	result = Save();
*		int result	1, если все в порядке,
*				0, если не удалось открыть файл.
*
* Описание	Создает окно, запрашивает у пользователя имя файла.
*		Пытается проинтерпретировать ответ:
*		если встречает групповые символы, т.е. '*' и '?',
*		   создает меню для запроса имени файла,
*		если отсутствует имя файла, добавляет '*' и также
*		   создает меню для запроса файла.
*		Если файл с заданным именем уже есть, меняет
*		 расширение его имени на bak.
*
* Возвращает    result	1, если все в порядке,
*			0, если не удалось открыть файл.
*
**/
ENTRY int Save (void)
{
   FILE *outF;
   static char name[MAXPATH]="*.pos";
   char sname[MAXPATH], normname [MAXPATH];
   int  res, choice;
   char _name[MAXPATH],*_n,*cur;

   strcpy(sname,name);
   OutStatistics("asking");
   if (!askFileName(sname,1)) {
      OutStatistics("");
      return 1;
   }

   OutStatistics("");
   strcpy(name,sname);

   strrev(name);
   for(choice=0,_n=_name,cur=name;*cur && !choice;) {
      *_n = *cur++;
      if(*_n++ == '.' &&
      		(choice=(*cur == '\\' || *cur == '/' || !*cur)) != 0)
        *_n++ = '*';
   }
   while((*_n++=*cur++)!=0);
   strrev(_name);
   strcpy(name,_name);
   if (strpbrk(name, "*?"))
      getFileName(name,sname);
   strcpy(name,sname);

   utl_fname (name, normname, &res);
   makeBak (name);

   if ((outF = fopen (name, "wt")) == NULL)
      return 0;

   OutStatistics("writing");
   saveToFile(outF);
   OutStatistics("");

   return 1;

}/*Save*/

/**
*
* Имя Load -- Читает конфигурацию из фаила
*
* Обращение	res = Load();
*
*               int res         0, если файл не удалось прочитать
*					(по любой причине),
*                               1, если с файлом все в порядке,
*			       -1, если в ответ на запрос имени файла
*                                       пользователь нажал ESC.
*
* Описание	Создает окно, запрашивает у пользователя имя файла.
*		Пытается проинтерпретировать ответ:
*		если встречает групповые символы, т.е. '*' и '?',
*		   создает меню для запроса имени файла,
*		если отсутствует имя файла, добавляет '*' и также
*		   создает меню для запроса файла.
*
* Возвращает    res         0, если файл не удалось прочитать
*                                       (по любой причине),
*                           1, если с файлом все в порядке,
*                          -1, если в ответ на запрос имени файла
*                                       пользователь нажал ESC.
*
**/
ENTRY int Load (void)
{
   static char name[MAXPATH]="*.pos";
   char lname[MAXPATH], normname [MAXPATH];
   int res, choice;
   char _name[MAXPATH],*_n,*cur;


   strcpy(lname,name);
   OutStatistics("asking");
   if (!askFileName(lname,0)) {
      OutStatistics("");
      return -1;
   }

   OutStatistics("");
   strcpy(name,lname);

   strrev(name);
   for(choice=0,_n=_name,cur=name;*cur && !choice;) {
      *_n = *cur++;
      if(*_n++ == '.' &&
      		(choice=(*cur == '\\' || *cur == '/' || !*cur)) != 0)
        *_n++ = '*';
   }
   while((*_n++=*cur++)!=0);
   strrev(_name);
   strcpy(name,_name);
   if (strpbrk(name, "*?"))
      getFileName(name,lname);
   else
      strcpy(lname,name);

   utl_fname (lname, normname, &res);
   OutStatistics("reading");
   if (!readFile(lname))
      return 0;

   stepNo = 0;
   OutStatistics("");
   return 1;
}/*Load*/

/**
*
* Имя makeBak -- Делает запасную копию файла
*
* Обращение	makeBak(name);
*
*		char *name	Имя входного файла
*
* Описание	Переименовывает файл с заданным именем в файл с
*		тем же именем и расширением ".bak".
*
* NB		О неудаче не сообщает!!!
*
* Возвращает	void	т.е. ничего.
*
**/
LOCAL void makeBak (char *name)
{
   char normname [MAXPATH], dr [MAXDRIVE], dir [MAXDIR],
            fname [MAXFILE], ext [MAXEXT], bakname [MAXPATH];
   int res;

   OutStatistics("making bat");
   utl_fname (name, normname, &res);

   if(FileExists(normname)) {
      fnsplit (normname, dr, dir, fname, ext);
      fnmerge (bakname, dr, dir, fname, ".bak");
      if(FileExists(bakname))
        remove(bakname);
      rename (normname, bakname);
   }
   strcpy(name,normname);
   OutStatistics("");
}/*makeBak*/

/**
*
* Имя saveToFile -- Записывает конфигурацию в файл
*
* Обращение	saveToFile(file);
*
*		FILE *file	Открытый(!) файл в который должна
*				быть записана позиция.
*
* Описание	По одной записывает точки в файл.
*
* Возвращает	void	т.е. ничего.
*
**/
LOCAL void saveToFile (FILE *outF)
{
   CELL *c;

   for (c = mainList; c; c = c->next)
      fprintf (outF, "%ld %ld\n", c->loc.x, c->loc.y);

   fclose (outF);

}/*saveToFile*/

/**
*
* Имя finMessage -- Вывести сообщение и "вывалиться"
*
* Обращение	finMessage(fmt,arg1,...);
*
* Описание   	Функция выводит аргументы в соответствии с заданным
*		форматом на стандартный вывод, после чего выполнение
*		программы останавливается с кодом возврата -1.
*
* Возвращает	void, то есть ничего.
*
**/

ENTRY void finMessage(char *fmt,...)
{
   va_list argptr;

   va_start(argptr,fmt);

   vprintf(fmt,argptr);
   exit(-1);
}/*finMessage*/

