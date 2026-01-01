/**
*  Модуль предъявления позиции и информации о ней на экран.
*
* Версия	1.5	(C)Copyright InfoScope Inc. 1992
*
**/

#include <stdio.h>

#include <display.h>

#include "life.h"
#include "lifescr.h"

WIN_DEF DEF_STATISTICS = {
   {80,1},
   dsp_doAttr(DSP_LIGHTGRAY,DSP_BLACK),
   0,
   0
};

LOC WHERE_STATISTICS = {1,25};

long scrX, scrY;
long scrOldX, scrOldY;
WINDOW *statistics_wnd;

LOCAL void clsPage (char ch, byte attr);
LOCAL void putChar (char ch, byte attr, int x, int y);

/**
*
* Имя putChar	-- Выводит символ в заданное место экрана заданными цветами
*
* Обращение	putChar(ch, attr, x, y);
*
*		char ch		выводимый символ
*		byte attr	цвета в формате байта
*		int x		координаты на экране по горизонтали
*		int y		и вертикали
*
* Описание	Выводит символ ch с атрибутами attr в точку на экране
*		с координатами (x, y).
*
* Возвращает	void	т.е. ничего.
*
**/
LOCAL void putChar(char ch, byte attr, int x, int y)
{
   scr_PutChar(utl_GetLoc(x,y),dsp_getFore(attr),dsp_getBack(attr),ch,0);
}/*putChar*/

/**
*
* Имя clsPage	-- Чистит экран заданным символом
*
* Обращение	clsPage(ch, attr);
*
*		char ch		символ
*		byte attr	аттрибуты
*
* Описание	Заполняет страницу символом ch с цветами attr.
*
* Возвращает	void	т.е. ничего.
*
**/
LOCAL void clsPage(char ch, byte attr)
{
   int x,y;

   for(x=1;x<=dsp_ScreenCols();x++)
      for(y=1;y<=dsp_ScreenRows();y++)
         putChar(ch,attr,x,y);
}/*clsPage*/

/**
*
* Имя drawLand	-- Рисует заново конфигурацию
*
* Обращение	drawLand();
*
* Описание	Рисует заново конфигурацию точек, попадающих внутрь
*		области видимости.
*
* Возвращает	void	т.е. ничего.
*
**/
ENTRY void drawLand(void)
{
   CELL *current;

   clsPage (EMPTY_SYM, EMPTY_ATTR);
   for (current = mainList; current != NULL; current = current->next) {
      showCell (current);
   }
}/*drawLand*/

/**
*
* Имя ReDraw	-- Перерисовывает конфигурацию
*
* Обращение	ReDraw();
*
* Описание	Прячет все точки, попавшие на экран, в соответствии
*		со старыми относительными координатами экрана на
*		плоскости (ScrOldX, ScrOldY), а потом выводит их
*		с новыми относительными координатами (ScrX, ScrY).
*
* Возвращает	void	т.е. ничего.
*
**/
ENTRY void ReDraw (void)
{
   long newx, newy;
   CELL *current;

   newx = scrX;
   newy = scrY;
   scrX = scrOldX;
   scrY = scrOldY;
   for (current = mainList; current != NULL; current = current->next) {
      hideCell (current);
   }
   scrX = newx;
   scrY = newy;
   for (current = mainList; current != NULL; current = current->next) {
      showCell (current);
   }
   scrOldX = scrX;
   scrOldY = scrY;
}/*ReDraw*/

/**
*
* Имя hideCell	-- Прячет точку, если она видима
*
* Обращение	hideCell(cell);
*
*		CELL *cell	Прячюемая точка
*
* Описание	Если точка cell находится в области видимости,
*		выводит в точку с соответствующими относительными
*		координатами экрана "фоновый" символ EMPTY_SYM
*		цветом EMPTY_ATTR, в противном случае ничего не делает.
*
* Примечание	Относителиные координаты вычисляется сложением
*		относительных координат экрана на плоскости с
*		координатами точки:
*
*		    (cell->loc.x + ScrX, cell->loc.y + ScrY).
*
* Возвращает	void	т.е. ничего.
*
**/
void hideCell (CELL *cell)
{
   if ((cell->loc.x + scrX >= 1) && (cell->loc.x + scrX <= dsp_ScreenCols ()) &&
        (cell->loc.y + scrY >= 1) && (cell->loc.y + scrY <= dsp_ScreenRows ()))
      putChar (EMPTY_SYM, EMPTY_ATTR, (int) (cell->loc.x + scrX), (int) (cell->loc.y + scrY));
}/*hideCell*/

/**
*
* Имя showCell	-- Показывает точку, если она видима
*
* Обращение	showCell(cell);
*
*		CELL *cell	Прячюемая точка
*
* Описание	Если точка cell находится в области видимости,
*		выводит в точку с соответствующими относительными
*		координатами экрана "активный" символ CELL_SYM
*		цветом CELL_ATTR, в противном случае ничего не делает.
*
* Примечание	Описание относителиных координат см. в hideCell.
*
* Возвращает	void	т.е. ничего.
*
**/
void showCell (CELL *cell)
{
   if ((cell->loc.x + scrX >= 1) && (cell->loc.x + scrX <= dsp_ScreenCols ()) &&
        (cell->loc.y + scrY >= 1) && (cell->loc.y + scrY <= dsp_ScreenRows ()))
      putChar (CELL_SYM, CELL_ATTR, (int) (cell->loc.x + scrX), (int) (cell->loc.y + scrY));
}/*showCell*/

void OutStatistics(char *mode)
{
   char str[80];
   		/* Рапортуем о результатах.	*/
   wnd_SetPos (statistics_wnd, 1, 1);
   sprintf (str, "Шаг: %6ld Точек: %6ld", stepNo, listLen ());
   wnd_PutStr (statistics_wnd, utl_GetLoc(1,1), str, 0, DSP_LIGHTGRAY, DSP_BLACK, 0);
   wnd_PutStr (statistics_wnd, utl_GetLoc(dsp_ScreenCols() - 26,1),
         "                        ", 0, DSP_LIGHTGRAY, DSP_BLACK, 0);
   wnd_PutStr (statistics_wnd, utl_GetLoc(dsp_ScreenCols() - strlen(mode) - 2,1),
   		mode, 0, DSP_LIGHTGRAY, DSP_BLACK, 0);
}/*OutStatistics*/

void StartStatisticsOut(void)
{
   WHERE_STATISTICS.y = dsp_ScreenRows();
   statistics_wnd = wnd_Open (&DEF_STATISTICS, &WHERE_STATISTICS,
               pc_GetVideoPage(), 0);
}/*StartStatisticsOut*/

void HideStatisticsWnd(void)
{
   wnd_Hide(statistics_wnd);
}/*HideStatisticsWnd*/

void ShowStatisticsWnd(void)
{
   wnd_UnHide(statistics_wnd);
}/*HideStatisticsWnd*/
