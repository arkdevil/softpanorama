#pragma inline
#include <alloc.h>
#include <string.h>
#include "edstr.h"
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
   Функция возвращает строку */

char *edit_string(int row,int start_col,
		  int end_col,int cursorshape,int buffersize,
		  char *originalstring,unsigned char *sourceattr,
		  unsigned char *destattr){
 int ch;
 /* начальная и конечная координаты строки на экране, ширина окна */
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
  case TAB:       /* нажата клавиша TAB */
    goto E_nter;
  case ESCAPE:       /* нажата клавиша ESCAPE */
    free(buffer);
 /* восстановить параметры курсора */
    set_cursor_position_size(cursorparms);
    return(NULL);    /* перейти на возврат вернуть NULL*/
  case ENTER:        /* нажата клавиша ENTER */
    /* преобразовать отредактированную строку в
       верхний регистр и скопировать ее в
       первоначальный буфер */
E_nter:
    strcpy(originalstring,buffer);
 /* вывести преобразованную строку на экран */
    asm call near ptr updateleft
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
 free(buffer);
 /* восстановить параметры курсора */
 set_cursor_position_size(cursorparms);
 return(originalstring);
 /* Процедуры встроенного ассемблера
    процедура восстановления атрибутов
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
}
