/* Файл UTILIT1.C */
/* Автор А.Синев, Copyright (C) 1990,1991 */
/* Turbo C 2.0, Turbo C++ 1.0 */

#include <string.h>
#include <conio.h>
#include <alloc.h>

#include "makeprt.h"

/********** Получить полное имя файла **********/
/* Функция заполняет буфер *pathname строкой
   полного имени файла, составляемой из пути
   поиска (определяемого по заданной модели
   *pattern) и имени файла *ff_name (найденного,
   например, при помощи функции findnext()).
   Размер буфера должен быть достаточным для
   размещения в нем возвращаемой строки. */

void get_pathname(char *pattern,char *ff_name,
                               char *pathname)
{
 /* указатель на последний символ '\\' в строке
    модели поиска */
 char *last_bslash;

 /* скопировать модель поиска в выходную строку */
 strcpy(pathname,pattern);

 if ((last_bslash=strrchr(pathname,'\\')) != NULL)
   last_bslash[1] = 0;
 else
   *pathname = 0;
 /* присоединить имя файла к пути поиска */
 strcat(pathname,ff_name);
} /* get_pathname() */

/********* Функция сжатия имени файла *********/
/* Функция сжимает имя файла до максимальной
   длины 19 байт + 1 байт (0), добавляя при этом
   необходимое расширение *def_ext (если таковое
   отсутствовало в переданном имени), и заполняет
   строку *shrunkname полученным текстом. В итоге
   строка приобретает вид C:\...\FILENAME.EXT
   (в зависимости от переданного имени).
   Параметры:
   *shrunkname - указатель на буфер для заполнения
                 (размер буфера - 20 байт)
   *pathname - указатель на первоначальное имя
               файла
   *def_ext - указатель на строку присоединяемого
              расширения (вида ".EXT"), либо на
              нулевую строку */

void shrink_fname(char *shrunkname,
             char *pathname,const char *def_ext)
{
 /* указатели на первый и последний символ '\\'
    в переданной строке */
 char *firstbs,*lastbs;
 /* указатель на последний символ ':' */
 char *lastcolon;
 /* указатель на первый символ '.'
    непосредственно в имени файла */
 char *firstpoint;
 /* указатель на текущий символ в переданной
    строке */
 char *charptr;
 /* текущий символ в заполняемой строке */
 int currentchar;
 /* длины имени файла и расширения */
 char name_length, ext_length;
 register int i;  /* счетчик */

 charptr = pathname;
 currentchar = 0;

 if ((lastcolon=strrchr(charptr,':')) != NULL) {
   if (lastcolon > pathname) {
     shrunkname[0] = lastcolon[-1];
     shrunkname[1] = lastcolon[0];
     currentchar = 2;
     charptr = lastcolon + 1;
   }
 }
 if ((lastbs = strrchr(charptr,'\\')) != NULL) {
   firstbs = strchr(charptr,'\\');
   if (lastbs != firstbs)
     shrunkname[currentchar++] = '\\';
   if (lastbs != charptr) {
     shrunkname[currentchar++] = '.';
     shrunkname[currentchar++] = '.';
     shrunkname[currentchar++] = '.';
   }
   shrunkname[currentchar++] = '\\';
   charptr = lastbs + 1;
 }
 if ((firstpoint=strchr(charptr,'.')) != NULL) {
   name_length = firstpoint - charptr;
   if (name_length > 8)
       name_length = 8;
   for (i=0; i<name_length;
        shrunkname[currentchar++]=charptr[i++]);
   shrunkname[currentchar++] = '.';
   charptr = firstpoint + 1;
   if ((ext_length=strlen(charptr)) > 3)
     ext_length = 3;
   for (i=0; i<ext_length;
        shrunkname[currentchar++]=charptr[i++]);
   shrunkname[currentchar] = 0;
 } else {
   if ((name_length=strlen(charptr)) > 8)
     name_length = 8;
   for (i=0; i<name_length;
        shrunkname[currentchar++]=charptr[i++]);
   shrunkname[currentchar] = 0;
   strcat(pathname,def_ext);
   strcat(shrunkname,def_ext);
 }
} /* shrink_fname() */


#define WildcardLeft 26    /* левая и правая */
#define WildcardRight 54   /* координаты окна */
/* строка текста предупреждения (29x5) */
#define WildcardText "\
┌───────────────────────────┐\
│  You can't use wildcards  │\
│  in the output file name. │\
│         Press ESC.        │\
└───────────────────────────┘"

/**** Функция выдачи окна с предупреждением ****/
/* о наличии символов *,? в модели имени файла */
/* start_row - номер строки экрана,
         соответствующей верхней рамке окна */

void wildcard_mes(int start_row)
{
 char *wildcardbuff;      /* буфер экрана */
 int bottom_row;    /* нижняя координата окна */
 char attr = WHITE + (RED<<4); /*атрибуты окна*/

 /* зарезервировать буфер */
 if ((wildcardbuff = malloc((29+2)*(5+1)*2)) ==
                                           NULL)
   return;
 /* если монохромный режим, то сменить атрибуты */
 if (get_video_mode() == MONO)
   attr = LIGHTGRAY;
 /* вычислить нижнюю координату окна */
 bottom_row = start_row + 4;
 /* построить окно */
 make_window(WildcardLeft,
      start_row,WildcardRight,bottom_row,
      WildcardText,wildcardbuff,attr,0,0,0,0);
 /* ждать нажатия клавиши ESCAPE */
 while (getkey() != ESCAPE);
 /* восстановить экран под окном */
 restore_text(WildcardLeft,start_row,
     WildcardRight+2,bottom_row+1,wildcardbuff);
} /* wildcard_mes() */

/* Конец файла UTILIT1.C */
