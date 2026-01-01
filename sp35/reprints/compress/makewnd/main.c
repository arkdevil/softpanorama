/* Файл MAIN.C */
/* Автор А.Синев, Copyright (C) 1990,1991 */
/* Turbo C 2.0, Turbo C++ 1.0 */

#define MAIN

#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <dir.h>
#include <dos.h>
#include <string.h>
#include <setjmp.h>

#include "makeprt.h"

/**********************************************/
void main(void)
{
 /* состояние курсора в окне: 0 - курсора нет */
 int bar_status = 0;
 /* коды дополнительных функциональных клавиш,
    отсутствующих в окне меню */
 int specialkey;
 /* полные имена файлов */
 char pathname[StrBuffSize+4], *pthname;
 char shrunkname[20]; /* сокращенное имя файла */
 /* аргумент функции findfirst() */
 struct ffblk ffblk;
 /* значения, возвращаемые функциями
    setjmp() и longjmp() */
 int value;
 /* промежуточная переменная */
 int clrpattern = 0;

 /* установить альтернативную программу обработки
    прерывания 0x23  (Ctrl-Break handler) */
 ctrlbrk(break_control);

 /* временно отключить прерывание 0x1B
    (Ctrl-Break) */
 OldBreakVector = break_off();

 /* прочитать текущий режим дисплея и форму
    курсора */
 VideoMode = get_video_mode();
 CursorShape = get_cursor_size();

 /* если дисплей в монохромном режиме - поменять
    значения атрибутов, иначе переключить бит
    мигания/интенсивности */
 if (VideoMode == MONO) {
   MenuBoxAttr = DialBoxAttr =
   NumbBarAttr = LIGHTGRAY + (BLACK<<4);
   HotAttr = LIGHTBLUE + (BLACK<<4);
   BarAttr = BLACK + (LIGHTGRAY<<4);
   ShadowAttr = BLACK<<4;
 } else
   toggle_intensity_blinking(INTENSITY);

 /* временно спрятать курсор */
 set_cursor_size(NoCursor);

 /* заполнить атрибутами массивы курсоров */
 memset(MenuBar,BarAttr,MenuBarWidth);
 memset(DialBar,BarAttr,
      DialBoxRight-DialBoxLeft-2);
 memset(NumbBar,NumbBarAttr,NumbBuffSize-1);

 /* начальный режим открытия выходного файла */
 OpenMode = WriteMode;

 Choice = 1;     /* начальное значение выбора */
 menu_on();      /* включить окно меню */

 while (1) {     /* бесконечный цикл */
  /* получить значение выбора и производить
     соответствующую обработку */
  switch (Choice = get_choice(MenuBoxTop+1,
      MenuBoxBottom-1,MenuBoxLeft+1,MenuBarWidth,
      Choice,MenuBar,MenuBarBuffer,NN_AltKeys,
      AltKeys,bar_status)) {
   /* редактировать имя входного файла */
   case 1:
     bar_status = 1;      /* курсор меню есть */
     /* построить диалоговое окно */
     dialbox_on();
     /* скопировать модель имени файла */
     if (! *InFileName) {
       strcpy(InFileName,InFNamePattern);
       clrpattern = 1;
     }
     /* редактировать имя входного файла */
     if (!edit_fname(InFileName)) {
       /* восстановить экран под диалоговым
          окном */
       dialbox_off();
       if (clrpattern)
         *InFileName = 0;
       clrpattern = 0;
       break;
     }
     clrpattern = 0;
     /* сократить имя входного файла для выдачи
        на экран */
     if (*InFileName)
       shrink_fname(shrunkname,InFileName,
                               InFExtPattern);
     else
       *shrunkname = 0;
     /* восстановить экран под диалоговым окном */
     dialbox_off();
     /* очистить место в окне для имени файла */
     clear_nchars(MenuBoxTop+Choice,StrLeftCol,
                                    StrLength);
     /* выдать на экран имя входного файла */
     put_string(MenuBoxTop+Choice,StrLeftCol,
                                   shrunkname);
     break;
   /* редактировать имя выходного файла */
   case 2:
     bar_status = 1;
     /* скопировать модель имени файла */
     if (! *OutFileName)
       strcpy(OutFileName,OutFNamePattern);
     /* построить диалоговое окно */
     dialbox_on();
     /* редактировать имя выходного файла */
     if (!edit_fname(OutFileName)) {
       /* восстановить экран под окном */
       dialbox_off();
       break;
     }
     /* сократить имя выходного файла для выдачи
        на экран */
     if (*OutFileName)
       shrink_fname(shrunkname,OutFileName,
                                OutFExtPattern);
     else
       *shrunkname = 0;
     /* если в имени файла есть символы *,?
        выдать предупреждение */
     if (strchr(OutFileName,'*') != NULL ||
              strchr(OutFileName,'?') != NULL) {
       wildcard_mes(MenuBoxTop+Choice+1);
       *OutFileName = *shrunkname = 0;
     }
     /* если файл с указанным именем уже имеется
        на диске */
     if (!findfirst(OutFileName,&ffblk,
                                   FF_Attrib)) {
       /* получить полное имя файла */
       get_pathname(OutFileName,ffblk.ff_name,
                                      pathname);
       pthname = searchpath(pathname);
       /* выдать предупреждение и получить
          режим открытия файла */
       switch (fexists_mes(MenuBoxTop+Choice+1,
                                     pthname)) {
        case 0: OpenMode = WriteMode;
          break;
        case 1: OpenMode = AppendMode;
          break;
        default: OpenMode = WriteMode;
          *OutFileName = *shrunkname = 0;
       }
     }
     /* восстановить экран под окном */
     dialbox_off();
     /* очистить место в окне для имени файла */
     clear_nchars(MenuBoxTop+Choice,StrLeftCol,
                                     StrLength);
     /* выдать на экран имя выходного файла */
     put_string(MenuBoxTop+Choice,StrLeftCol,
                                    shrunkname);
     break;
   /* редактировать число строк на страницу
      выходного файла */
   case 3:
     bar_status = 1;
     edit_number(&LinesPerPage);
     break;
   /* редактировать ширину полей для нечетных
      страниц */
   case 4:
     bar_status = 1;
     edit_number(&OddMargin);
     break;
   /* редактировать ширину полей для четных
      страниц */
   case 5:
     bar_status = 1;
     edit_number(&EvenMargin);
     break;
   /* переключить ключ выдачи номеров страниц */
   case 6:
     bar_status = 1;
     toggle_switch(&PgNumb_sw);
     break;
   /* переключить ключ выдачи текста на экран */
   case 7:
     bar_status = 1;
     toggle_switch(&Screen_sw);
     break;
   /* обрабатывать текст */
   case 8:
     menu_off();        /* погасить окно меню */
     /* восстановить курсор */
     set_cursor_size(CursorShape);
     /* восстановить вектор прерывания 0x1B */
     break_on(OldBreakVector);
     /* установить адрес перехода для возврата
        из функции обработки прерывания 0x23
        (Ctrl-Break handler) */
     value = setjmp(Jumper);
     if (!value)
       process();       /* обрабатывать текст */
     /* отключить обработку прерывания 0x1B */
     OldBreakVector = break_off();
     /* отменить курсор */
     set_cursor_size(NoCursor); 
     menu_on();         /* включить окно меню */
     bar_status = 0;    /* курсора меню нет */
     break;
   /* обработка дополнительных функциональных
      клавиш, отсутствующих в окне меню */
   default:
     /* получить код дополнительной клавиши */
     specialkey = Choice & SpecialKeyMask;
     /* получить значение текущего выбора */
     Choice >>= 9;
     switch (specialkey) {
      case ESCAPE:   /* нажата клавиша ESCAPE */
        menu_off();     /* погасить окно меню */
        /* восстановить бит
           мигания/интенсивности */
        if (VideoMode != MONO)
          toggle_intensity_blinking(BLINKING);
        /* восстановить курсор */
        set_cursor_size(CursorShape);
        /* восстановить вектор прерывания
           0x1B (Ctrl-Break) */
        break_on(OldBreakVector);
        return;      /* выход из программы */
      /* нажата клавиша Ctrl-O */
      case CTRL_O:
        menu_off();  /* погасить окно меню */
        getkey();    /* ждать нажатия клавиши */
        menu_on();   /* включить окно меню */
        bar_status = 0;  /* курсора меню нет */
     }
  }
 }
} /* main */

/******** Функция включения окна меню *********/
void menu_on(void)
{
 /* построить окно на экране */
 make_window(MenuBoxLeft,MenuBoxTop,
       MenuBoxRight,MenuBoxBottom,MenuText,
       MenuBuffer,MenuBoxAttr,ShadowAttr,
       NN_HotChars,HotCharNumbers,HotAttr);
} /* menu_on() */

/******** Функция выключения окна меню ********/
void menu_off(void)
{
 /* сохранить текст окна меню (без атрибутов) */
 get_window_text(MenuBoxLeft,MenuBoxTop,
          MenuBoxRight,MenuBoxBottom,MenuText);
 /* восстановить экран из буфера */
 restore_text(MenuBoxLeft,MenuBoxTop,
     MenuBoxRight+2,MenuBoxBottom+1,MenuBuffer);
} /* menu_off() */

/***** Функция включения диалогового окна *****/
void dialbox_on(void)
{
 /* построить окно */
 make_window(DialBoxLeft,(MenuBoxTop+Choice+1),
            DialBoxRight,(MenuBoxTop+Choice+3),
            DialBoxText,DialBoxBuffer,
            DialBoxAttr,0,0,0,0);
} /* dialbox_on() */

/***** Функция выключения диалогового окна ****/
void dialbox_off(void)
{
 /* восстановить экран из буфера */
 restore_text(DialBoxLeft,(MenuBoxTop+Choice+1),
         DialBoxRight+2,(MenuBoxTop+Choice+3)+1,
                                 DialBoxBuffer);
} /* dialbox_off() */

/***** Функция редактирования имени файла *****/
int edit_fname(char *fname)
{
 /* редактировать строку */
 return (edit_string((MenuBoxTop+Choice+1)+1,
      DialBoxLeft+1,DialBoxRight-1,CursorShape,
      StrBuffSize,fname,DialBar,DialBarBuffer));
} /* edit_fname() */

/***** Функция редактирования целого числа ****/
void edit_number(int *number)
{
 char buffer[NumbBuffSize];   /* буфер строки */
 int numberlength;            /* длина строки */

 /* преобразовать число в строку и вычислить
    ее длину */
 itoa(*number,buffer,Radix);
 numberlength = strlen(buffer);
 /* очистить место в окне под строку */
 clear_nchars(MenuBoxTop+Choice,StrLeftCol,
                                NumbBuffSize);
 /* редактировать строку */
 edit_string(MenuBoxTop+Choice,StrLeftCol-1,
      StrLeftCol+4,CursorShape,NumbBuffSize,
      buffer,NumbBar,NumbBarBuff);

 /* число не может быть отрицательным */
 if ((*number = atoi(buffer)) < 0)
   *number = 0;
 /* снова преобразовать целое в строку; это
    необходимо для исключения ошибки ввода
    неправильной строки */
 itoa(*number,buffer,Radix);
 /* очистить место в окне для строки */
 clear_nchars(MenuBoxTop+Choice,StrLeftCol,
                                NumbBuffSize);
 /* вывести строку на экран */
 put_string(MenuBoxTop+Choice,StrLeftCol,buffer);
 /* восстановить атрибуты строки на экране */
 make_hbar(MenuBoxTop+Choice,StrLeftCol,
           numberlength,NumbBarBuff,
           (unsigned char *)buffer);
} /* edit_number() */

/********* Функция переключения опции *********/
void toggle_switch(int *sw)
{
 /* указатель на строку индикации */
 char *swstrptr;

 if (*sw) {
   *sw = 0;
   swstrptr = OffString;
 } else {
   *sw = 1;
   swstrptr = OnString;
 }
 /* вывести строку индикации на экран */
 put_string(MenuBoxTop+Choice,StrLeftCol,
                                  swstrptr);
} /* toggle_switch() */

/***** Функция обработки прерывания 0x23 ******/
/*********** (Ctrl-Break handler) *************/
int break_control(void)
{
 fputs("User Break ...\n",stdout);
 /* закрыть все открытые потоки */
 if ((fcloseall()) != EOF)
   /* перейти на адрес возврата, установленый
      в структуре *Jumper функцией setjmp () */
   longjmp(Jumper,1);
 /* если ошибка, то выход из программы */
 perror("\nError");
 /* восстановить бит мигания/интенсивности */
 if (VideoMode != MONO)
   toggle_intensity_blinking(BLINKING);
 return ABORT;       /* выход из программы */
} /* break_control() */

/****** Функция разбивки текстовых файлов *****/
/****** на страницы с добавлением полей *******/
void process(void)
{
 FILE *infile, *outfile;
 int ofstat = 0; /* состояние выходного файла */
 /* количество строк во входном файле */
 unsigned int nn_lines;
 int nn_pages;          /* количество страниц */
 /* указатель на структуру описания файла */
 struct ffblk ffblk;
 /* прочитанный символ, счетчики, поля */
 int ch, i, j, k, margin;
 /* имена найденных файлов */
 char *pathname, inff_name[StrBuffSize+4];

 /* открыть выходной поток */
 if (*OutFileName) {
   if ((outfile=fopen(OutFileName,OpenMode)) !=
                                           NULL)
     ofstat = 1;
   else {
     printf("\nCan't open output file %s",
                                   OutFileName);
     perror("");
   }
 }
 if (!ofstat)
   fputs("\nNo output file!",stdout);

 /* искать входной файл, соответствующий заданной
    модели имени */
 if (!findfirst(InFileName,&ffblk,FF_Attrib)) {
   /* если выходной файл открыт в режиме "at",
      то начать новую страницу */
   if (ofstat && *OpenMode=='a')
     fputs("\n\f\n",outfile);

/* метка перехода, если найден следующий файл,
   соответствующий заданной модели */
next_file:
   /* получить полное имя найденного файла */
   get_pathname(InFileName,ffblk.ff_name,
                               inff_name);
   pathname = searchpath(inff_name);

   /* открыть входной поток */
   if ((infile = fopen(pathname,"rt")) != NULL) {
     printf("\n\nReading from file: %s ...",
                                    pathname);
     nn_lines = nn_pages = 0; /* нач. значения */
     /* если установлен счетчик страниц */
     if (PgNumb_sw) {
       fputs("\nAnalysing ...",stdout);
       do {
         if ((ch = fgetc(infile)) == '\n')
           nn_lines++; /* считать число строк */
       } while (ch != EOF);
       nn_pages = LinesPerPage ?
          (nn_lines + 1) / LinesPerPage + 1 : 1;
       printf(NN_LinesStr,pathname,nn_lines+1);
       printf(NN_PagesStr,nn_pages,LinesPerPage);
       rewind(infile);
     } else
       nn_pages = 0x7FFF;

     /* перевести строку, если разрешен вывод на
        экран */
     if (Screen_sw)
       fputs("\n\n",stdout);

     for (i=0; i<nn_pages; i++) {
       /* определить размер полей для текущей
          страницы */
       margin = i & 0x0001 ?
                EvenMargin : OddMargin;
       /* если не первая страница, то вывести
          символ перевода формата */
       if (i) {
         if (ofstat)
           fputs("\f\n",outfile);
         if (Screen_sw)
           fputs("\f\n",stdout);
       }
       /* вывести номер страницы */
       if (PgNumb_sw) {
         if (ofstat) {
           fprintf(outfile,"%*s",margin,"");
           fprintf(outfile,HeadString,pathname,
                                  i+1,nn_pages);
           fprintf(outfile,"%*s",margin,"");
           for (k=0; k<65; k++)
             fputc('-',outfile);
           fputc('\n',outfile);
         }
         if (Screen_sw) {
           fprintf(stdout,"%*s",margin,"");
           fprintf(stdout,HeadString,pathname,
                                  i+1,nn_pages);
           fprintf(stdout,"%*s",margin,"");
           for (k=0; k<65; k++)
             fputc('-',stdout);
           fputc('\n',stdout);
         }
       }
       /* выводить текст */
       for (j=0; j<LinesPerPage; j++) {
         /* вставить поля */
         if (ofstat)
           fprintf(outfile,"%*s",margin,"");
         if (Screen_sw)
           fprintf(stdout,"%*s",margin,"");
         /* выводить строку */
         do {
           /* если конец файла, то закрыть
              текущий входной поток и искать
              следующий файл, соответствующий
              заданной модели имени */
           if ((ch = fgetc(infile)) == EOF) {
             fclose(infile);
             if (!findnext(&ffblk)) {
               /* если файл найден, то
                  перевести формат и вернуться
                  в начало цикла */
               if (ofstat)
                 fputs("\n\f\n",outfile);
               if (Screen_sw)
                 fputs("\n\f\n",stdout);
               goto next_file;
             } else       /* иначе возврат */
               goto quit;
           }
           /* вывести прочитанный символ */
           if (ofstat)
             fputc(ch,outfile);
           if (Screen_sw)
             fputc(ch,stdout);
         } while (ch != '\n');
       }
     }
   } else {
     /* если ошибка открытия входного потока */
     printf("\nCan't open input file %s",
                                    pathname);
     perror("");
   }
 } else        /* если входной файл не найден */
   printf("\nThe file %s not found.",InFileName);
quit:
 if (ofstat)   /* закрыть выходной поток */
   fclose(outfile);
} /* process() */

/* Конец файла MAIN.C */
