#ifndef _GRAPH16_

#define _GRAPH16_

extern int BytesPerLine;

// Глобальные переменные для DisplayCharFont
extern void far *FontTable;
extern int FontSize;

#ifdef __cplusplus
 extern "C" {
#endif

// Рисование линии (два конца и цвет)
 void cdecl Line(int x1,int y1,int x2,int y2,int color);

// Эллипс (центр, две полуоси и цвет)
 void cdecl Ellipse(int x, int y, int xh, int yh, int color);

// Нарисовать символ (код символа, точка левого верхнего угла, 
//			цвет переднего плана, цвет фона)
//    Фонт берется из области прерменных BIOS
 void cdecl DisplayChar(int c, int x, int y, int fgd, int bkgd);

// Нарисовать символ своим фонтом (параметры те же)
//    Фонт берется из глобльных переменных:
//    высота буквы в пикселах - FontSize,
//    указатель на массив с фонтом - FontTable. Формат фонта обычный.
 void cdecl DisplayCharFont(int c, int x, int y, int fgd, int bkgd);

// Заполнить область до границы (внутренняя точка,
//            цвет заполнения, цвет границы)
 void cdecl FillRegion(int x, int y, int color, int border_color);

#ifdef __cplusplus
 }
#endif

#endif
