/* Файл UTILIT3.C */
/* Автор А.Синев, Copyright (C) 1990,1991 */
/* Turbo C 2.0, Turbo C++ 1.0 */

#pragma inline

#include <alloc.h>
#include <string.h>

#include "makeprt.h"

/********** Получить значение выбора **********/
/********** в окне вертикального меню *********/
/* Функция возвращает значение выбора. Если была
   нажата специальная клавиша, возвращается также
   ее код в младших 9 битах (с 0 по 8), значение
   выбора при этом размещается с 9 по 15 биты.
   Параметры:
   first_row - первая строка меню на экране;
   last_row  - последняя строка меню на экране;
   start_col - первый столбец курсора меню на
               экране;
   bar_width - ширина курсора меню;
   curr_choice - текущее значение выбора;
   sourcebar - указатель на строку атрибутов
	      курсора, длиной bar_width;
   destinbar - указатель на буфер атрибутов
	      курсора, длиной bar_width;
   nn_altkeys - количество альтернативных клавиш,
              равное удвоенному количеству строк
              меню (для символов нижнего и
              верхнего регистров) плюс число
              специальных функциональных клавиш,
	      отсутствующих в окне меню;
   altkeys - указатель на массив кодов
	      альтернативных клавиш;
   bar_status - текущее состояние курсора меню:
      0 - курсора в окне нет, 1 - курсор есть */

int get_choice(int first_row,int last_row,
    int start_col,int bar_width,int curr_choice,
    unsigned char *sourcebar,
    unsigned char *destinbar,int nn_altkeys,
    int *altkeys,int bar_status)
{
 int row;         /* текущая строка */
 int ch;          /* код символа с клавиатуры */
 register int i;  /* счетчик */

 row = first_row + curr_choice - 1;
 if (bar_status)
   goto key_loop;

loop:
 /* построить курсор в окне меню */
 asm call near ptr makecursor
key_loop:
 /* прочитать символ с клавиатуры */
 switch(ch = getkey()) {
   /* если ENTER, то выход из цикла */
   case ENTER: goto quit;
   case UPKEY:              /* стрелка вверх */
     /* восстановить атрибуты под курсором */
     asm call near ptr restorecursor
     row--;
     break;
   case DOWNKEY:            /* стрелка вниз */
     /* восстановить атрибуты под курсором */
     asm call near ptr restorecursor
     row++;
     break;
   case PGUPKEY:            /* клавиша PgUp */
   case HOMEKEY:            /* клавиша Home */
   case LEFTKEY:            /* стрелка влево */
     asm call near ptr restorecursor
     row = first_row;
     break;
   case PGDNKEY:            /* клавиша PgDn */
   case ENDKEY:             /* клавиша End */
   case RIGHTKEY:           /* стрелка вправо */
     asm call near ptr restorecursor
     row = last_row;
     break;
   /* для остальных кодов проверять соответствие
      альтернативным клавишам */
   default:
     for (i=0; i<((last_row-first_row+1)<<1);
                                         i+=2) {
       if (ch == altkeys[i] ||
                           ch == altkeys[i+1]) {
         /* если соответствие найдено,
	    восстановить атрибуты под курсором */
         asm call near ptr restorecursor
	 row = first_row + (i >> 1);
         /* построить курсор в новом месте */
         asm call near ptr makecursor
	 goto quit;     /* переход на возврат */
       }
     }
     /* проверять соответствие кодам специальных
        клавиш, отсутствующих в окне меню */
     for (; i<nn_altkeys; i++) {
       /* если соответствие найдено, возвращается
          целая величина, в которой младшие 9 бит
          (с 0 по 8) отведены под код специальной
	  клавиши, а с 9 по 15 биты размещается
	  текущее значение выбора */
       if (ch == altkeys[i])
	 return (((row-first_row+1) << 9) |
	                            altkeys[i]);
     }
     /* если соответствие не найдено,
        возврат в цикл чтения с клавиатуры */
     goto key_loop;
 }
 /* если выбор за рамками окна - произвести
    коррекцию */
 if(row < first_row)
   row = last_row;
 else {
   if(row > last_row)
     row = first_row;
 }
 goto loop;    /* возврат в цикл */

quit:
 /* вернуть значение выбора */
 return (row - first_row + 1);

/*---------- Процедуры встроенного ассемблера */
 /* процедура построения курсора */
 asm makecursor proc near
 make_hbar(row,start_col,bar_width,sourcebar,
                                  destinbar);
 asm ret
 asm makecursor endp

 /* процедура восстановления атрибутов экрана
    под курсором */
 asm restorecursor proc near
 make_hbar(row,start_col,bar_width,destinbar,
                                  sourcebar);
 asm ret
 asm restorecursor endp

} /* get_choice() */


/**** Функция редактирования строки в окне ****/
/* Функция позволяет редактировать в окне
   заданного размера строку неограниченной длины,
   сдвигая ее влево и/или вправо и помечая выход
   строки за рамки окна. Функция возвращает
   отредактированную строку в том же буфере, в
   котором она была передана.
   Параметры:
   row       - номер строки окна на экране;
   start_col - левая координата окна на экране;
   end_col   - правая координата окна на экране;
   cursorshape - форма курсора;
   buffersize - размер буфера строки, байт;
   originalstring - указатель на редактируемую
		     строку;
   sourceattr - указатель на строку атрибутов
		 для закрашиваемой части окна;
   destattr - указатель на буфер атрибутов окна;
   Размеры массивов sourceattr[] и destattr[]
   должны быть равны (end_col - start_col - 2).
   Функция возвращает 0, если строка не редакти-
   ровалась (была нажата клавиша ESCAPE), либо
   1, если строка была отредактирована. */

int edit_string(int row,int start_col,
   int end_col,int cursorshape,int buffersize,
   char *originalstring,unsigned char *sourceattr,
   unsigned char *destattr)
{
 int ch;                     /* код символа */
 /* начальная и конечная координаты строки на
    экране, ширина окна */
 int startcolumn,endcolumn,width;
 /* индикаторы выхода строки за рамки окна */
 int beg_status,end_status;
 /* текущая длина строки, длина остатка строки
    справа от курсора */
 int length,rest;
 char *buffer;   /* буфер для редактирования */
 int entry;      /* номер вхождения в цикл */
 /* старые параметры курсора: x и y координаты
    и форма курсора */
 unsigned long cursorparms;
 int cursorpos_w;   /* позиция курсора в окне */
 /* указатель на позицию курсора в строке */
 char *cursorpos_s;
 int ret_status;    /* возвращаемое значение */

 /* зарезервировать буфер для редактирования
    строки размера buffersize */
 if ((buffer = malloc(buffersize)) == NULL)
   return 0;

 /* сохранить старые параметры курсора */
 cursorparms = get_cursor_position_size();

 /* вычислить промежуточные значения */
 startcolumn = start_col + 1;
 endcolumn = end_col - 1;
 width = end_col - startcolumn;
 /* максимальная длина строки */
 buffersize--;
 /* скопировать строку в буфер и получить ее
    длину, задать начальное значение остатка */
 length = string_copy(buffer,originalstring);
 rest = 0;

 /* начальное положение курсора в строке - в
    конце строки, нач.знач. правого индикатора */
 cursorpos_s = buffer + length;
 end_status = 0;

 /* определить положение курсора в окне и
    значение левого индикатора */
 if (length < width) {
   cursorpos_w = startcolumn+length;
   beg_status = 0;
 } else {
   cursorpos_w = endcolumn;
   beg_status = 1;
 }
 /* вывести строку на экран */
 asm call near ptr updateleft
 /* закрасить строку атрибутами *sourceattr для
    индикации нередактированной строки */
 if (length)
   make_hbar(row,startcolumn,cursorpos_w -
             startcolumn,sourceattr,destattr);
 /* установить курсор на нужную позицию */
 set_cursor_position(cursorpos_w,row);
 /* установить форму курсора */
 set_cursor_size(cursorshape);
 entry = 0;       /* нулевое вхождение в цикл */

key_loop:
 /* прочитать код с клавиатуры */
 switch(ch = getkey()) {
  case ESCAPE:       /* нажата клавиша ESCAPE */
    ret_status = 0;
    goto quit;       /* перейти на возврат */
  case ENTER:        /* нажата клавиша ENTER */
    ret_status = 1;
    /* преобразовать отредактированную строку в
       верхний регистр и скопировать ее в
       первоначальный буфер */
    strupr(buffer);
    strcpy(originalstring,buffer);
    goto quit;       /* перейти на возврат */
  case HOMEKEY:      /* нажата клавиша Home */
    /* если нулевое вхождение, то восстановить
       атрибуты экрана */
    if (!entry) {
      if (length)
        asm call near ptr restorebar;
      entry = 1;
    }
    if (rest != length) {
      cursorpos_w = startcolumn;
      cursorpos_s = buffer;
      rest = length;
      beg_status = 0;
      end_status = (rest <= width) ? 0 : 1;
      /* обновить строку вправо */
      asm call near ptr updateright
      break;
    } else
      goto key_loop;
  case PGUPKEY:      /* нажата клавиша PgUp */
    if (!entry) {
      if (length)
        asm call near ptr restorebar;
      entry = 1;
    }
    length = rest = string_copy(buffer,
                                originalstring);
    cursorpos_w = startcolumn;
    cursorpos_s = buffer;
    beg_status = 0;
    end_status = (length <= width) ? 0 : 1;
    clear_nchars(row,startcolumn,width);
    asm call near ptr updateright
    break;
  case LEFTKEY:      /* нажата стрелка влево */
    if (!entry) {
      if (length)
        asm call near ptr restorebar;
      entry = 1;
    }
    if (cursorpos_w > startcolumn) {
      cursorpos_w--;
      cursorpos_s--;
      rest++;
      break;
    } else {
      if (rest < length) {
	cursorpos_s--;
	rest++;
	beg_status = (rest == length) ? 0 : 1;
	end_status = (rest <= width) ? 0 : 1;
        asm call near ptr updateright
      }
      goto key_loop;
    }
  case ENDKEY:       /* нажата клавиша END */
    if (!entry) {
      if (length)
        asm call near ptr restorebar;
      entry = 1;
    }
    if (rest) {
      cursorpos_s = buffer + length;
      end_status = 0;
      rest = 0;
      if (length < width) {
	cursorpos_w = startcolumn + length;
	beg_status = 0;
      } else {
	cursorpos_w = endcolumn;
	beg_status = 1;
      }
      /* обновить строку влево */
      asm call near ptr updateleft
      break;
    } else
      goto key_loop;
  case RIGHTKEY:     /* нажата стрелка вправо */
    if (!entry) {
      if (length)
        asm call near ptr restorebar;
      entry = 1;
    }
    if (cursorpos_w < endcolumn) {
      if (rest) {
	cursorpos_w++;
	cursorpos_s++;
	rest--;
	break;
      }
      goto key_loop;
    } else {
      if (rest) {
	cursorpos_s++;
	rest--;
	beg_status=((length-rest)<width) ? 0 : 1;
	end_status = (rest<=1) ? 0 : 1;
        asm call near ptr updateleft
      }
      goto key_loop;
    }
  case DELKEY:       /* нажата клавиша DELETE */
    if (!entry) {
      if (length)
        asm call near ptr restorebar;
      entry = 1;
    }
    if (rest) {
      delete_char(cursorpos_s,rest);
      rest--;
      length--;
      if (rest < endcolumn-cursorpos_w) {
	end_status = 0;
	if (beg_status) {
	  cursorpos_w++;
	  beg_status = (length-rest <
	         cursorpos_w-start_col) ? 0 : 1;
          asm call near ptr updateleft
	  break;
	}
        asm call near ptr updateright
      } else {
	end_status = (rest <=
	           end_col-cursorpos_w) ? 0 : 1;
        asm call near ptr updateright
      }
    }
    goto key_loop;
  case BACKSPACE: /* нажата клавиша BACKSPACE */
    if (!entry) {
      if (length)
        asm call near ptr restorebar;
      entry = 1;
    }
    if (rest < length) {
      cursorpos_s--;
      delete_char(cursorpos_s,rest+1);
      length--;
      if (rest < end_col-cursorpos_w) {
	end_status = 0;
	if (beg_status) {
	  beg_status = (length-rest <
	         cursorpos_w-start_col) ? 0 : 1;
          asm call near ptr updateleft
	} else {
	  cursorpos_w--;
          asm call near ptr updateright
	  break;
	}
      } else {
	if (cursorpos_w > startcolumn) {
	  cursorpos_w--;
	  end_status = (rest <=
	           end_col-cursorpos_w) ? 0 : 1;
          asm call near ptr updateright
	  break;
	} else {
	  if (rest == length) {
	    beg_status = 0;
            asm call near ptr updateright
	  }
	}
      }
    }
    goto key_loop;

  default:           /* для остальных клавиш */
    /* если нажата "незаконная" клавиша, то
       возврат в цикл */
    if (ch<32 || ch>255)
      goto key_loop;
    if (!entry) {   /* если нулевое вхождение */
      if (length)
        asm call near ptr restorebar;
      *buffer = 0;
      length = rest = beg_status = end_status = 0;
      cursorpos_s = buffer;
      cursorpos_w = startcolumn;
      entry = 1;
      /* очистить строку на экране */
      clear_nchars(row,start_col,
                   end_col-start_col+1);
      set_cursor_position(startcolumn,row);
    }
    /* если буфер полон, вернуться в цикл */
    if (length >= buffersize)
      goto key_loop;
    /* вставить символ в строку */
    insert_char(cursorpos_s,rest,ch);
    length++;
    if (cursorpos_w < endcolumn) {
      end_status = (rest <
                   end_col-cursorpos_w) ? 0 : 1;
      asm call near ptr updateright
      cursorpos_s++;
      cursorpos_w++;
      break;
    }
    cursorpos_s++;
    beg_status = (length-rest <
                 cursorpos_w-start_col) ? 0 : 1;
    asm call near ptr updateleft
    goto key_loop;
 }
 /* установить курсор на нужную позицию */
 set_cursor_position(cursorpos_w,row);
 goto key_loop;

quit:
 free(buffer);       /* освободить буфер */
 /* восстановить параметры курсора */
 set_cursor_position_size(cursorparms);
 return ret_status;  /* возврат */

/*---------- Процедуры встроенного ассемблера */
 /* процедура восстановления атрибутов
    закрашенного бруска */
 asm restorebar proc near
 make_hbar(row,startcolumn,cursorpos_w -
        startcolumn,destattr,sourceattr);
 asm ret
 asm restorebar endp

 /* процедура обновления строки вправо */
 asm updateright proc near
 update_right(row,startcolumn,endcolumn,
	      beg_status,end_status,
	      cursorpos_w,cursorpos_s);
 asm ret
 asm updateright endp

 /* процедура обновления строки влево */
 asm updateleft proc near
 update_left(row,startcolumn,endcolumn,
             beg_status,end_status,
	     cursorpos_w,cursorpos_s);
 asm ret
 asm updateleft endp

} /* edit_string() */

/* Конец файла UTILIT3.C */
