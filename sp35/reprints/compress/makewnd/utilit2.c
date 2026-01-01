/* Файл UTILIT2.C */
/* Автор А.Синев, Copyright (C) 1990,1991 */
/* Turbo C 2.0, Turbo C++ 1.0 */

#pragma inline

#include <string.h>
#include <conio.h>
#include <alloc.h>

#include "makeprt.h"

#define LeftUpper  '┌'
#define HorizBar   '─'
#define RightUpper '┐'
#define LeftLower  '└'
#define VertBar    '│'
#define RightLower '┘'
#define TheFile_Str "The file "
#define TheFile_StrLen 9
#define AlreadyExists_Str "already exists."
#define AlreadyExists_StrLen 15
#define Choice_Str " Overwrite   Append   Cancel "
#define Choice_StrLen 29
#define MaxLength  41
#define MaxPathNameLength 32
#define FirstChoiceWidth 11
#define SecondChoiceWidth 8
#define ThirdChoiceWidth 8
#define SecondChoiceOffset 12
#define ThirdChoiceOffset 21
#define ChoiceWidths "\x0b\x08\x08"  /* 11,8,8 */

/* │ The file C:\...\12345678.123\12345678.123 │
   123456789012345678901234567890123456789012345
   Максимальный размер окна = 45 x 5 (без тени)
*/
/****** Функция сообщения о существовании *****/
/********** указанного файла на диске *********/
/* Функция строит окно, горизонтальные размеры
   которого настраиваются под длину переданного
   имени файла и возвращает выбранный режим
   открытия файла:
   0 - Overwrite (перезаписать),
   1 - Append (добавить к концу),
   2 - Cancel (отмена).
   Параметры:
   start_row - номер строки экрана,соответствую-
               щей верхней рамке окна сообщения;
   *pathname - указатель на имя файла.
*/
int fexists_mes(int start_row, char *pathname)
{
 /* буферы текста и экрана */
 char *window_text, *window_buff;
 /* буфер сокращенного имени файла */
 char shrunkname[MaxPathNameLength];
 /* буферы курсора */
 unsigned char bar[FirstChoiceWidth];
 unsigned char bar_buff[FirstChoiceWidth];
 /* указатели на имя файла и текущий символ
    имени */
 char *fnptr, *currptr;
 /* длина переданного имени файла */
 int pnlength;
 int fnlength;    /* длина имени файла в окне */
 int currentchar; /* счетчик символов */
 /* ширина и координаты окна */
 int windowwidth, windowleft;
 int windowright, windowbottom;
 /* промежуточные переменные */
 int firststrlen, textlen;
 int leftmargin, rightmargin;
 int choice, choicerow, choiceleft[3];
 int hotkeys[3];
 /* атрибуты окна */
 char attr = WHITE + (RED<<4);
 /* атрибуты "горячих" клавиш */
 char hotattr = YELLOW + (RED<<4);
 register int i,j;            /* счетчики */

 /* зарезервировать буферы под текст окна и
    участок экрана под окном */
 if ((window_text = malloc(45*5)) == NULL)
   return 2;
 if ((window_buff = malloc((45+2)*(5+1)*2)) ==
                                         NULL) {
   free(window_text);
   return 2;
 }
 /* если монохромный режим, то сменить атрибуты */
 if (get_video_mode() == MONO) {
   attr = LIGHTGRAY;
   hotattr = LIGHTBLUE;
 }

 /* Сократить имя файла под максимальную ширину
    окна (если необходимо) */
 if ((pnlength=strlen(pathname)) <=
                            MaxPathNameLength) {
   fnptr=pathname;
   fnlength=pnlength;
 } else {
   currentchar=0;
   currptr=pathname;
   if (strrchr(currptr,':') == currptr+1) {
     shrunkname[currentchar++]=currptr[0];
     shrunkname[currentchar++]=currptr[1];
     currptr+=2;
   }
   if (strchr(currptr,'\\') == currptr)
     shrunkname[currentchar++]='\\';
   shrunkname[currentchar++]='.';
   shrunkname[currentchar++]='.';
   shrunkname[currentchar++]='.';
   for (i = MaxPathNameLength-1, j = pnlength-1;
               i >= currentchar;
               shrunkname[i--] = pathname[j--]);
   fnptr=shrunkname;
   fnlength=MaxPathNameLength;
 }
 /* длина первой строки, записываемой в окно */
 firststrlen = TheFile_StrLen + fnlength;
 /* ширина текста в окне */
 textlen = (firststrlen > Choice_StrLen) ?
            firststrlen + 2 : Choice_StrLen + 2;

 /* заполнить атрибутами массив курсора */
 memset(bar,LIGHTGRAY<<4,FirstChoiceWidth);

 /* заполнить первую строку окна */
 i=0;
 window_text[i++]=LeftUpper;
 memset(window_text+i,HorizBar,textlen);
 i += textlen;
 window_text[i++]=RightUpper;

 /* заполнить вторую строку окна */
 leftmargin = (textlen - firststrlen) >> 1;
 rightmargin = textlen - firststrlen - leftmargin;
 window_text[i++]=VertBar;
 memset(window_text+i,' ',leftmargin);
 i += leftmargin;
 memcpy(window_text+i,TheFile_Str,TheFile_StrLen);
 i += TheFile_StrLen;
 memcpy(window_text+i,fnptr,fnlength);
 i += fnlength;
 memset(window_text+i,' ',rightmargin);
 i += rightmargin;
 window_text[i++]=VertBar;

 /* заполнить третью строку окна */
 leftmargin = (textlen-AlreadyExists_StrLen)>>1;
 rightmargin = textlen - AlreadyExists_StrLen -
                                     leftmargin;
 window_text[i++]=VertBar;
 memset(window_text+i,' ',leftmargin);
 i += leftmargin;
 memcpy(window_text+i,AlreadyExists_Str,
                        AlreadyExists_StrLen);
 i += AlreadyExists_StrLen;
 memset(window_text+i,' ',rightmargin);
 i += rightmargin;
 window_text[i++]=VertBar;

 /* заполнить четвертую строку окна */
 choiceleft[0] = (textlen - Choice_StrLen) >> 1;
 rightmargin = textlen - Choice_StrLen -
                                  choiceleft[0];
 window_text[i++]=VertBar;
 memset(window_text+i,' ',choiceleft[0]);
 i += choiceleft[0];
 memcpy(window_text+i,Choice_Str,Choice_StrLen);
 i += Choice_StrLen;
 memset(window_text+i,' ',rightmargin);
 i += rightmargin;
 window_text[i++]=VertBar;

 /* заполнить пятую строку окна */
 window_text[i++]=LeftLower;
 memset(window_text+i,HorizBar,textlen);
 window_text[i+textlen]=RightLower;

 /* вычислить координаты окна на экране */
 windowwidth = textlen + 2;
 windowleft = (80 - windowwidth) >> 1;
 windowright = windowleft + windowwidth;
 windowleft++;
 windowbottom = start_row + 4;

 /* вычислить номера "горячих" символов в строке
    текста окна */
 hotkeys[0] = windowwidth*3 + choiceleft[0] + 3;
 hotkeys[1] = hotkeys[0] + SecondChoiceOffset;
 hotkeys[2] = hotkeys[0] + ThirdChoiceOffset;

 /* вычислить координаты курсора */
 choicerow = windowbottom - 1;
 choiceleft[0] += windowleft + 1;
 choiceleft[1]=choiceleft[0]+SecondChoiceOffset;
 choiceleft[2]=choiceleft[0]+ThirdChoiceOffset;

 /* построить окно */
 make_window(windowleft,start_row,windowright,
           windowbottom,window_text,window_buff,
           attr,0,3,hotkeys,hotattr);
 choice = 0;    /* начальное значение выбора */

loop:
 /* построить курсор */
 make_hbar(choicerow,choiceleft[choice],
             ChoiceWidths[choice],bar,bar_buff);
key_loop:
 /* прочитать код с клавиатуры */
 switch(getkey()) {
  case ENTER:
    break;
  case HOMEKEY:
    /* восстановить атрибуты под курсором (вызов
       процедуры встроенного ассемблера) */
    asm call near ptr restorecursor
    choice=0;
    goto loop;     /* возврат в цикл */
  case LEFTKEY:
    /* восстановить атрибуты под курсором */
    asm call near ptr restorecursor
    choice--;
    if (choice < 0)
      choice=2;
    goto loop;     /* возврат в цикл */
  case ENDKEY:
    asm call near ptr restorecursor
    choice=2;
    goto loop;
  case RIGHTKEY:
    asm call near ptr restorecursor
    choice++;
    if (choice > 2)
      choice=0;
    goto loop;
  case 'o':
  case 'O':
    choice = 0;
    break;
  case 'a':
  case 'A':
    choice = 1;
    break;
  case 'c':
  case 'C':
  case ESCAPE:
    choice = 2;
    break;
  default:             /* возврат в цикл */
    goto key_loop;     /* чтения с клавиатуры */
 }
 /* восстановить экран под окном */
 restore_text(windowleft,start_row,
      windowright+2,windowbottom+1,window_buff);
 free(window_text);    /* освободить буферы */
 free(window_buff);
 return choice;    /* вернуть значение выбора */

/*---------- Процедура встроенного ассемблера */
/* Восстановление атрибутов экрана под курсором */
 asm restorecursor proc near
 make_hbar(choicerow,choiceleft[choice],
           ChoiceWidths[choice],bar_buff,bar);
 asm  ret
 asm restorecursor endp

} /* fexists_mes() */

/* Конец файла UTILIT2.C */
