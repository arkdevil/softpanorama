/* **********************************************************************

ФАЙЛ: CLIP2.S
НАЗНАЧЕНИЕ: Исходный файл макросов системы поддержки программирования
            на языке CLIPPER в среде редактора Multi-Edit 
            CLIPPER-MACRO 2.1
АВТОР: Георгий ЖЕРДЕВ, 672005. г.Чита-5, ул.Рахова, 98, кв.49
ДАТА: 27.06.93
ПРИМЕЧАНИЯ: Требуемая версия Multi-Edit - 6.x. Компилировать с помощью
            CMAC.EXE версии 6.x.

************************************************************************* */

macro_file CLIP2;

/*
   Макросы:
   CL_BR_CONTROL        Контроль на парность скобок / кавычек в строке;
                        также вызывается из CLIP2^CL_OP_CONTROL
   CL_OP_CONTROL        Полный контроль структуры / всего файла
   CL_PROCFILE_OPEN     Открытие файла-функции
   CLIP_BATCOMPILE      Компиляция с использованием *.bat-файла
   ALLSAVE              Запись всех редактируемых файлов. Вызывается из
                        CLIP2^CLIP_BATCOMPILE и CLIP2^CLIP_RMAKE
   CLIP_RMAKE           Компиляция с использованием *.rmk-файла
   CLIP_CHMAKE          Смена *.rmk-файла, используемого по умолчанию
                        в макросе CLIP2^CLIP_RMAKE
   CLIP_FIND            Поиск противоположного конца текущей структуры
      CL_FWD            Вызывается из CLIP2^CLIP_FIND. Поиск конца
                        текущей структуры
      CL_BWD            Вызывается из CLIP2^CLIP_FIND. Поиск начала
                        текущей структуры

 */


                     /* Контроль на парность скобок / кавычек в строке;
                      * также вызывается из CLIP2^CL_OP_CONTROL */

macro cl_br_control from edit trans {
    int num = 0,numq = 0,numf = 0,nums = 0,numd = 0,reg_exp = reg_exp_stat;
    str ch,em,
        prov = '()[]{};"' + char(39);  /* Проверяемые разделители */
    reg_exp_stat = FALSE;
    mark_pos;
    LOOP:                              /* Основная петля проверки */
    first_word;
    while(  not(at_eol)  ) {
        ch = cur_char;                 /* Считываем текущий символ */
                                       /* Поскольку, в отличие от скобок,
                            * правая-левая кавычки никак не различаются
                            * между собой, приходится держать флаги нахождения
                            * внутри текстовой строки, ограниченной либо
                            * двойными, либо одинарными кавычками. Пока мы
                            * внутри текстовой строки (один из флагов поднят),
                            * проверка парности разделителей не
                            * осуществляется */
        if ((( nums ) AND (ch != char(39))) OR ( ( numd ) AND (ch != '"' ))) {
            goto next;
        }
        if(  not(xpos(ch,prov,1))  ) {    /* Текущий символ не относится
                                           * к числу контролируемых
                                           * разделителей */
            if ( ch == '&' ) {            /* & - Это может быть начало
                                           * комментария */
               right;                     /* Вправо, чтобы уточнить */
               if ( cur_char == '&' ) {   /* && - это точно комментарий */
                  break;                  /* Больше здесь делать нечего */
               }
               left;
            } else if ( ch =='/' ) {      /* "/" - И это может быть началом
                                           * комментария */
               right;
               if (cur_char == '*') {     /* "/*" - Этот комментарий
                                           * может занимать только часть
                                           * строки, поэтому следует найти
                                           * его конец */
                  if (not(search_fwd('*/',0))) {     /* Если не нашли... */
                     em = 'Незакрытый комментарий /* ... */ !';
                     goto errm1;
                     }
                  mark_pos;               /* Нашли. Уточняем: продолжается ли
                                           * строка и после комментария */
                  eol;
                  do { left; } while (cur_char == ' ');
                  if (cur_char == ';') {  /* Продолжается */
                     goto_mark;
                     right;
                     right;
                     } else {             /* Не продолжается */
                        pop_mark;
                        break;
                        }
               } else if (cur_char == '/') break;  /* Если же это
                                       * однострочный комментарий "//" в
                                       * конце строки, нам здесь делать
                                       * больше нечего  */
               left;
            }
            goto next;
        };
        if(  (ch == ';')  ) {         /* Перенос на следующую строку!
                                       * (Возможно. А возможно и наоборот:
                                       * несколько командных строк
                                       * расположены в одной через точку
                                       * с запятой. Следует уточнить...) */
            mark_pos;
            do {
               right;
               if (at_eol) break;     /* Конец строки. Спускаемся ниже */
               if ( cur_char != ' ' ) {    /* Не конец строки. Продолжим
                                            * чтение */
                  goto_mark;
                  goto next;
               }
            } while ( TRUE ) ;
            pop_mark;
            down;
            goto loop;                /* Спустившись на строку, возвращаемся
                                       * в основной цикл проверки */
        };          /* ... С возможными комментариями покончено.
                     * Теперь проверяем на вероятные разделители
                     * из числа контролируемых. В случае, если
                     * попался какой-то из них, увеличиваем (если
                     * это открывающий символ) или уменьшаем (если
                     * закрывающий) соответствующий счетчик */
        if(  (ch == '(')  ) {
            num ++;
        } else {
            if(  (ch == ')')  ) {
                num --;
            };
        };
        if(  (ch == '[')  ) {
            numq ++;
        } else {
            if(  (ch == ']')  ) {
                numq --;
            };
        };
        if(  (ch == '{')  ) {
            numf ++;
        } else {
            if(  (ch == '}')  ) {
                numf --;
            };
        };
        if((ch == '"')) { numd = not(numd); }   /* Устанавливаем-снимаем флаг
                                                 * начала текстовой строки,
                                                 * ограниченной либо двойными,
                                                 * либо одинарными кавычками */
        if((ch == char(39))) { nums = not(nums); }
                        /* Если хоть один из счетчиков стал отрицательным,-
                         * БАЛАНС НАРУШЕН ! Формируем строку об ошибке и
                         * переходим к ее выводу */
        if(  (num < 0)  ) {
            em = 'Строка '+str(c_line)+', столбец '+str(c_col)+' : '+'Лишняя <)> !';
            goto errm1;
        } else {
            if(  (numq < 0)  ) {
                em = 'Строка '+str(c_line)+', столбец '+str(c_col)+' : ' +'Лишняя <]> !';
                goto errm1;
            } else {
                if(  (numf < 0)  ) {
                    em = 'Строка '+str(c_line)+', столбец '+str(c_col)+' : '+ 'Лишняя <}> !';
                    goto errm1;
                };
            };
        };
        NEXT:
        right;
    };
            /* Все. Строка завершилась. Подводим окончательный итог */

    if(  (numd)  ) {       /* Мы так и остались внутри текстовой строки!
                            * Нет пары для двойной кавычки! */
        em = 'Не хватает до пары двойной кавычки <"> !';
        goto errm1;
    };
    if(  (nums)  ) {       /* Аналогично: нет пары для одинарной кавычки! */
        em = 'Не хватает до пары одинарной кавычки <' + char(39) + '> !';
        goto errm1;
    };
    if(  (num)  ) {        /* И так далее для каждого из разделителей.
                            * Если хоть один из счетчиков не равен нулю -
                            * нарушен баланс! */
        em = 'Не достает '+str(num)+' закрывающих скобок <)> !';
        goto errm1;
    };
    if(  (numq)  ) {
        em = 'Не достает '+str(numq)+' закрывающих скобок <]> !';
        goto errm1;
    };
    if(  (numf)  ) {
        em = 'Не достает '+str(numf)+' закрывающих скобок <}> !';
        goto errm1;
    };
    if(  (parse_int('/TYPE=',mparm_str) != 1)  ) {
        make_message('Все в порядке !');
    };
    return_int = 1;
    goto FIN;

    ERRM1:        /* Вывод сообщения об ошибке */
      beep;
      make_message(em);
      return_int = 0;

    FIN:
      reg_exp_stat = reg_exp;
      goto_mark;
};


                  /* Полный контроль структуры / всего файла */

macro cl_op_control from edit trans {
    str count,begs,ends,interns,cur,prov,em,ss;
    int p,p1,VarAll,VarSec,i;
    VarAll = 0;            /* Флаг "проверять все" */
    VarSec = 0;            /* Флаг "проверять текущий цикл" */
    begs = '.BEGIN.IF   .DO CASE.FOR .TEXT   .DO WHILE.';   /* Слова для
                                                             * проверки */
    ENDS = '.END  .ENDIF.ENDCASE.NEXT.ENDTEXT.ENDDO.';
    INTERNS = '.CASE.ELSE.OTHERWISE.ELSEIF.LOOP.EXIT.RECOVER.';
    count = '';            /* Строка-стек текущих циклов */
    refresh = FALSE;
    if(  (length(global_str('clip_match')) != 0)  ) {    /* Если строка
                                      * CLIP_MATCH не пустая, - значит,
                                      * проверка уже производилась и
                                      * может быть продолжена дальше */
        VarSec = 1;                  /* Устанавливаем флаг и считываем
                                      * строку-стек от прошлого сеанса */
        count = global_str('clip_match');
    };
   if(  (VarSec)  ) {
      RM ('USERIN^XMENU /X=57/Y=4/B=1/T=1/L=* Контроль циклов */M=1.Продолжить()2.Текущий цикл()3.Весь файл()') ;
      if(  (RETURN_INT < 1)  ) {
            GOTO FIN;
      };
      if((return_int != 1)) {
            VarSec = 0;
            count = '';
      } else if((return_int == 3)) {      /* Почему else if ?!!! */
            VarAll = 1;
            tof;
      };
   } else {
      RM ('USERIN^XMENU /X=57/Y=4/B=1/T=1/L=* Контроль циклов */M=1.Текущий цикл()2.Весь файл()') ;
      if(  (RETURN_INT < 1)  ) {
            GOTO FIN;
      } else if(  (return_int == 2)  ) {
            VarAll = 1;
            tof;
      };
   };
    working;
    make_message('Минутку! Проверяем...');
    push_undo;
    while ((get_line == '') AND (not(at_eof))) down;
    first_word;
    while(  (not(at_eof))  ) {
         if (cur_char == '/') {
            right;
            if (cur_char != '*') goto NEXT_LINE;
            if (not(search_fwd('*/',0))) {
               beep;
               make_message('Незакрытый комментарий /* ... */ !');
               set_global_str('clip_match',count);
               GOTO FIN;
            }
            right;
            word_right;
         }
        put_line_num(c_line);
         mark_pos;
         RM('clip2^cl_br_control /TYPE=1');
         if(  (not(return_int))  ) {
               set_global_str('clip_match',count);
               GOTO FIN;
         };
         goto_mark;
        cur = '.' + caps(get_word(' '));
        if(  (cur == '.TEXT')  ) {
            while(  (cur != 'ENDTEXT')  ) {
                down;
                first_word;
                cur = caps(get_word(' '));
            };
            goto NEXT_LINE;
        };
        if(  (cur == '.DO')  ) {
            word_right;
            cur = cur + ' ' + caps(get_word(' '));
        };
        p = xpos(cur,begs,1);
        if(  (p > 0)  ) {
            count = count + cur;
        } else {
            p = xpos(cur,ends,1);
            if(  p  ) {
                prov = copy(begs, p , (xpos('.',begs,p + 1) - p ));
                p1 = 0;
                do {
                    p1 = xpos('.',count,p1+1);
                    if(  p1  ) p = p1;
                } while(p1);
                ss = copy(count,p,svl(count)-p+1);
                if(  (remove_space(ss) == remove_space(prov))  ) {
                    count = copy(count,1,p-1);
                } else {
                    em = 'Конец структуры '+copy(cur,2,svl(cur)-1)+' не следует за '+remove_space(copy(prov,2,svl(prov)-1))+' !';
                    goto err;
                };
            } else {
                p = xpos(cur,interns,1);
                if(  (p)  ) {
                    if(  (p == 28) | (p == 33)  ) {
                        if( VarAll ) {
                            if(  (xpos('DO WHILE',count,1) == 0) & (xpos('FOR',count,1) == 0)  ) {
                                em = copy(cur,2,svl(cur)-1)+' не находится внутри цикла DO WHILE - ENDDO или FOR - NEXT !';
                                goto err;
                            };
                        };
                        goto NEXT_LINE;
                    } else if(  (p == 1) | (p == 11)  ) prov = '.DO CASE';
                      else if(  (p == 6) | (p == 21)  ) prov = '.IF';
                      else if(p == 38) prov = '.BEGIN';
                      else goto ff;
                    p1 = 0;
                    do {
                        p1 = xpos('.',count,p1+1);
                        if((p1)) p = p1;
                    } while(p1);
                    ss = remove_space(copy(count,p,svl(count)-p+1));
                    if(  (ss != prov)  ) {
                        em = cur + ' не следует за '+prov+' !';
                        goto err;
                    };
                };
                ff:
            };
        };
        if( not(VarAll) ) {
            if(  (svl(count) == 0)  ) {
                make_message('Все в порядке !');
                set_global_str('clip_match','');
                GOTO FIN;
            };
        };
        if(  VarSec  ) {
            VarSec = 0;
        };
        NEXT_LINE:
        p = 1;
        while(not(at_eof)) {
            p = xpos('/*',get_line,p);
            if (p) {
               p1 = c_line;
               goto_col(p + 1);
               if (search_fwd( '*/',0)) {
                  if (p1 == c_line) {
                     p = c_col;
                     continue;
                  } else break;
               }  else {
                  beep;
                  make_message('Незакрытый комментарий /* ... */ !');
                  set_global_str('clip_match',count);
                  GOTO FIN;
               }
            }
            eol;
            left;
            if(  (cur_char == ';')  ) down;
            else break;
        };
        down;
        while ((get_line == '') AND (not(at_eof))) down;
        first_word;
    };
    make_message('Все в порядке !');
    set_global_str('clip_match','');
    GOTO FIN;
    err:
      beep;
      make_message(em);
      set_global_str('clip_match','');
    FIN:
      refresh = TRUE;
      redraw;
      pop_undo;
};


                  /* Поиск противоположного конца текущей структуры
                   * IF - ENDIF
                   * DO CASE - ENDCASE
                   * DO WHILE - ENDDO
                   * FOR - NEXT
                   * BEGIN SEQUENCE - END SEQUENCE
                   * TEXT - ENDTEXT,
                   *    а также функции или процедуры */

macro CLIP_FIND from edit trans {
   str begs = '.PROCEDURE.FUNCTION.PROC.FUNC.DO WHILE.DO CASE.IF.BEGIN.TEXT.FOR.',
       ends = '.RETURN.ENDDO.ENDCASE.ENDIF.NEXT.END.ENDTEXT.',
       begword;
   push_undo;
   mark_pos;      /* Начальную позицию помещаем в стек, чтобы при желании
                   * пользователь мог быстро вернуться обратно */
   first_word;
   begword = '.' + caps(get_word(' '));   /* Считываем первое слово
                                           * начальной строки */
   if ( (begword == '.STATIC') OR (begword == '.STAT') ) {   /* Это может
                                                      * быть STATIC FUNCTION
                                                      * или PROCEDURE */
      word_right;
      begword = '.' + caps(get_word(' '));            /* В таком случае
                                                       * считываем второе
                                                       * слово */
   } else if (begword == '.END') {                    /* Если END,-
                                                       * проверяем: является ли
                                                       * это END SEQUENCE */
      word_right;
      if ( caps(get_word(' ')) != 'SEQUENCE' ) {
         rm('meerror^messagebox /B=3/T=ИЗВИНИТЕ/M=Мы не обрабатываем неполные завершения "END"');
         goto_mark;
         goto fin;
      }
   } else if ( begword == '.DO' ) {      /* Первое слово - DO. Может быть
                                          * началом как DO WHILE, так и
                                          * DO CASE */
      word_right;
      begword = begword + ' ' + caps(get_word(' '));
   }
   begword = begword + '.';
   if ( xpos(begword,begs,1) ) {     /* Ну, а теперь проверяем:
                                      * если мы находимся вначале какой-либо
                                      * структуры,- ищем вперед... */
      rm('CL_FWD /W=' + begword);
   }  else if ( ( xpos(begword,ends,1) ) ) {    /* ИНАЧЕ - ищем назад... */
      rm('CL_BWD /W=' + begword);
   }  else {                         /* Иначе - вообще не ищем */
         rm('meerror^messagebox /B=3/T=ИСКАТЬ НЕЧЕГО!/M=Установите курсор на начало/конец структуры!');
         goto_mark;
         goto fin;
   }
FIN:
   pop_undo;
}


                         /* Вызывается из CLIP2^CLIP_FIND. Поиск конца
                          * текущей структуры. Получает параметр /W с
                          * первым словом начальной строки,- т.е.
                          * началом структуры */

macro CL_FWD {
   str begword,endword,curword,errmess = '';
   int counter = 0,do_struct = 0,proc = 0,
       reg_exp = reg_exp_stat,n,n1,line;
   begword = parse_str('/W=',mparm_str);   /* Считываем начальное слово
                                            * из переданного параметра */
   If (begword == '.DO WHILE.') {          /* Оцениваем его и подбираем
                                            * слово, которым должна окончиться
                                            * структура */
      do_struct = 1;
      endword = '.ENDDO.';
   } else if (begword == '.DO CASE.') {
      do_struct = 1;
      endword = '.ENDCASE.';
   } else if (begword == '.IF.') endword = '.ENDIF.';
      else if (begword == '.BEGIN.') endword = '.END.';
      else if (begword == '.TEXT.') endword = '.ENDTEXT.';
      else if (begword == '.FOR.') endword = '.NEXT.';
      else if (( begword == '.PROCEDURE.') OR (begword == '.FUNCTION.')
            OR ( begword == '.PROC.') OR ( begword == '.FUNC.')) {
      proc = 1;            /* Если мы ищем конец процедуры / функции,-
                            * будем просто искать до следующего слова
                            * PROCEDURE / FUNCTION или конца файла */
      counter = 2;
   }
   make_message('Прежняя позиция в файле помещена в стек');
   working;                      /* Начинаем... */
   reg_exp_stat = FALSE;
   refresh = FALSE;
   do {                           /* Основной цикл прохода по строкам */
      first_word;                 /* Всегда считываем первое слово в строке */
      n = xpos('/*',get_line,1);  /* Если на строке начинается многострочный
                                   * комментарий */
      if (n) {
         if ( n == c_col ) {      /* Комментарий начинается с начала строки */
            right;
            if ( not(search_fwd('*/',0)) ) {    /* Ищем конец комментария */
               errmess = 'Незакрытый комментарий!';
               goto ERR;
            }
            line = c_line;
            right;
            word_right;
            if (c_line != line) {         /* Если за комментарием на данной
                                           * строке ничего больше нет,
                                           * переходим на строку ниже
                                           * и возвращаемся к началу цикла */
               continue;
            } else if ( at_eol ) {
               down;
               continue;
            }
         }
      } else {            /* Нет ли на текущей строке конца комментария? */
         n1 = xpos('*/',get_line,1);     /* Есть... */
         if ( n1 ) {
            goto_col(n1+1);
            right;
            word_right;
            if (c_line != line) {      /* Если за комментарием на данной
                                        * строке ничего больше нет,
                                        * переходим на строку ниже
                                        * и возвращаемся к началу цикла */
               continue;
            } else if ( at_eol ) {
               down;
               continue;
            }
         }
      }
      mark_pos;
      curword = caps(get_word(' '));      /* Считываем первое
                                           * не закомментированное слово
                                           * в строке */
      if ( xpos('.' + curword + '.','.STATIC.STAT.PROCEDURE.PROC.FUNCTION.FUNC.',1)  ) {
         if ( not(proc) )  {              /* Началась новая процедура /
                                           * функция, а цикл так и не
                                           * завершен */
            pop_mark;
            goto ERR;
         }
         pop_mark;
                           /* Если STATIC, читаем второе слово */
         if ((curword == 'STAT') OR (curword == 'STATIC')) word_right;
         else word_left;
      } else goto_mark;
      curword = '.' + caps(get_word(' '));
      if ((do_struct) AND (curword == '.DO')) {   /* Если DO, читаем
                                                   * второе слово */
         word_right;
         curword = curword + ' ' + caps(get_word(' ')) + '.';
      } else curword = curword + '.';
      if ( proc AND ((curword == '.PROCEDURE.') OR
                     (curword == '.PROC.') OR
                     (curword == '.FUNCTION.') OR
                     (curword == '.FUNC.'))) {
         counter--;
         if (not(counter)) up;   /* Нашли следующую процедуру / функцию,-
                                  * и, таким образом, конец текущей */
      }  else {
         if ( curword == begword ) counter ++;      /* Начало еще одной
                                                     * вложенной структуры */
         else if ( curword == endword ) counter --; /* Конец одной из
                                                     * структур */
      }
      if ( n > 1 ) {          /* В текущей строке начинается
                               * комментарий */
         goto_col(n);
         line = c_line;
         right;               /* Ищем конец комментария */
         if ( not(search_fwd('*/',0)) ) {
            errmess = 'Незакрытый комментарий!';
            goto ERR;
         }
         if (line == c_line) {     /* Комментарий завершается в той же строке.
                                    * Спускаемся на строку ниже для продолжения
                                    * работы */
            down;
            if ( at_eof ) {        /* Конец файла! Если мы отслеживали
                                    * процедуру / функцию,- то все в порядке,
                                    * в противном случае это ошибка! */
               if (proc) goto REST;
               else goto ERR;
            }
         }
      } else {                      /* Спускаемся на строку ниже для продолжения
                                    * работы */
         down;
         if ( at_eof ) {            /* Конец файла! Если мы отслеживали
                                     * процедуру / функцию,- то все в порядке,
                                     * в противном случае это ошибка! */
            if (proc) goto REST;
            else goto ERR;
         }
      }
   } while (counter);               /* Условие продолжения поиска:
                                     * пока счетчик начала/конца структуры
                                     * не нулевой */
   up;                              /* ВСЕ В ПОРЯДКЕ:
                                     * окончание найдено! */
   first_word;
   goto rest;
ERR:
   if (svl(errmess) == 0) errmess = 'Искомая позиция не найдена!';
   rm('meerror^messagebox /B=3/T=ВНИМАНИЕ!/M=' + errmess);
REST:
   working;
   reg_exp_stat = reg_exp;
   refresh = TRUE;
   redraw;
FIN:

}


                  /* Вызывается из CLIP2^CLIP_FIND. Поиск начала
                   * текущей структуры. Получает параметр /W с
                   * первым словом начальной строки,- т.е.
                   * началом структуры */

macro CL_BWD {
   str begword,endword,curword,errmess = '';
   int counter = 0,do_struct = 0,proc = 0,
       reg_exp = reg_exp_stat,n,n1,line;
   begword = parse_str('/W=',mparm_str);     /* Считываем начальное слово
                                              * из переданного параметра */
   if ( begword == '.ENDDO.' ) {             /* Оцениваем его и подбираем
                                              * слово, которым должна окончиться
                                              * структура */
      do_struct = 1;
      endword = '.DO WHILE.';
   } else if ( begword == '.ENDCASE.' ) {
      do_struct = 1;
      endword = '.DO CASE.';
   } else if (begword == '.ENDIF.') endword = '.IF.';
      else if (begword == '.NEXT.') endword = '.FOR.';
      else if (begword == '.END.') endword = '.BEGIN.';
      else if (begword == '.ENDTEXT.') endword = '.TEXT.';
      else if (begword == '.RETURN.') proc = 1;     /* Если мы ищем начало
                            * процедуры / функции,- будем просто искать до
                            * ближайшего слова PROCEDURE / FUNCTION вверх
                            * или до начала файла */
   make_message('Прежняя позиция в файле помещена в стек');
   working;                       /* Начинаем... */
   reg_exp_stat = FALSE;
   refresh = FALSE;
   do {                           /* Основной цикл прохода по строкам */
      first_word;                 /* Всегда считываем первое слово в строке */
      n = xpos('*/',get_line,1);  /* Если на строке завершается многострочный
                                   * комментарий */
      n1 = xpos('/*',get_line,1); /* Если на строке начинается многострочный
                                   * комментарий */
      if (n1 == c_col) {          /* Комментарий начинается с начала строки */
         if (not(n)) {            /* Если конца комментария на текущей
                                   * строке при этом нет,- следвательно,
                                   * вся строка закомментирована; делать нам
                                   * здесь нечего. Поднимаемся на
                                   * строку выше для продолжения работы */
            up;
            continue;
         } else {                 /* В противном случае переходим к первому
                                   * слову после конца комментария */
            goto_col(n+1);
            word_right;
         }
      } else if ( n AND (( n1 > n) OR (n1 == 0)) ) {    /* Другой вариант:
                                   * конец комментария есть, а начало либо
                                   * отсутствует, либо находится за концом,
                                   * т.е. является началом другого
                                   * комментария */
         eol;
         left;
         if ( cur_char == '/') {
            left;
            if ( cur_char == '*' ) {   /* В конце строки и этот, второй,
                                        * комментарий все-таки тоже
                                        * завершается. Еще раз уточняем,
                                        * где этот комментарий начался */
               line = c_line;
               if ( not(search_bwd('/*',0)) ) {
                  errmess = 'Незакрытый комментарий!';
                  goto ERR;
               }
               if (line != c_line) continue;    /* В процессе уточнения
                                                 * оказались на другой строке.
                                                 * Возвращаемся к началу цикла
                                                 * для продолжения работы */
               line = c_line;
               word_left;
               if (c_line != line) {            /* Начало комментария оказалось
                                                 * с начала строки. То же
                                                 * самое... */
                  continue;
               } else if (c_col == xpos('/*',get_line,1)) {
                  up;
                  continue;
               } else first_word;   /* В противном случае переходим, как
                                     * обычно, к первому слову в строке,-
                                     * судя по всему, оно не закомментировано */
            } else {                /* Во всех остальных случаях переходим
                                     * к первому слову после комментария */
               goto_col(n+1);
               word_right;
            }
         } else {
            goto_col(n+1);
            word_right;
         }
      } else first_word;
      mark_pos;
      curword = caps(get_word(' '));   /* Считываем первое
                                        * не закомментированное слово
                                        * в строке */
      if ( xpos('.' + curword + '.','.STATIC.STAT.PROCEDURE.PROC.FUNCTION.FUNC.',1)  ) {
         if ( not(proc) )  {           /* Добрались до начала текущей
                                        * процедуры / функции, а цикл так и не
                                        * завершен */
            pop_mark;
            goto ERR;
         }
         pop_mark;
                                       /* Если STATIC, читаем второе слово */
         if ((curword == 'STAT') OR (curword == 'STATIC')) word_right;
         else word_left;
      } else goto_mark;
      curword = '.' + caps(get_word(' '));
      if ((do_struct) AND (curword == '.DO')) {    /* Если DO, читаем
                                                    * второе слово */
         word_right;
         curword = curword + ' ' + caps(get_word(' ')) + '.';
      } else curword = curword + '.';
      if ( proc AND ((curword == '.PROCEDURE.') OR
                     (curword == '.PROC.') OR
                     (curword == '.FUNCTION.') OR
                     (curword == '.FUNC.'))) {
         counter --;             /* Нашли начало процедуры / функции */
      }  else {
         if ( curword == begword ) counter ++;       /* Конец одной из
                                                      * структур */
         else if ( curword == endword ) counter --;  /* Начало еще одной
                                                      * вложенной структуры */
      }
      if ( n > 1 ) {             /* В текущей строке завершался какой-то
                                  * комментарий */
         goto_col(n);
         line = c_line;
         right;                  /* Ищем его начало... */
         if ( not(search_bwd('/*',0)) ) {
            errmess = 'Незакрытый комментарий!';
            goto ERR;
         }
         if (line == c_line) {    /* Комментарий начался в той же строке.
                                   * Поднимаемся на строку выше для продолжения
                                   * работы */
            if ( c_line == 1 ) goto ERR;  /* Начало файла! Если мы отслеживали
                                   * процедуру / функцию,- то все в порядке,
                                   * в противном случае это ошибка! */
            up;                   /* Поднимаемся на строку выше для продолжения
                                   * работы */
         }
      } else {
         if ( c_line == 1 ) goto ERR;     /* То же самое... */
         up;                      /* Поднимаемся на строку выше для продолжения
                                   * работы */
      }
   } while (counter);             /* Условие продолжения поиска:
                                   * пока счетчик начала/конца структуры
                                   * не нулевой */
   down;                          /* ВСЕ В ПОРЯДКЕ:
                                   * окончание найдено! */
   first_word;
   goto rest;
ERR:
   if (svl(errmess) == 0) errmess = 'Искомая позиция не найдена!';
   rm('meerror^messagebox /B=3/T=ВНИМАНИЕ!/M=' + errmess);
REST:
   working;
   reg_exp_stat = reg_exp;
   refresh = TRUE;
   redraw;
FIN:

}


                  /* Открытие файла-функции. Есть любители хранить
                   * каждую функцию в отдельном файле: скажем,
                   * функцию Func1() в func1.prg, а Func2() в func2.prg.
                   * Я как-то столкнулся с этим, разбирая исходники
                   * чужой огромной программы, состоящей из полутора
                   * сотен таких файлов. Тогда и написал этот макрос. */

macro CL_PROCFILE_OPEN from edit trans {
    str file,pds;
    int n,curw,cnt;
    curw = cur_window;
    WORD_LEFT;       /* Считываем слово по курсором */
    file = CAPS(GET_WORD(' !<>/\*:;%^"@#$&*().,{}[]=-+'+char(39)))+'.PRG';
    n = 1;
    while(  (n <= window_count)  ) {     /* Проверяем: не загружен ли уже
                                          * искомый файл */
        switch_window(n);
        if(  (caps(truncate_path(file_name)) == truncate_path(file))  ) {
            GOTO FIN;
        };
        n = n+1;
    };
    cnt = 1;
    loop:                                 /* Петля поиска файла */
    if(  (FIRST_FILE(file) == 0)  ) {     /* Файл найден */
        if ( cnt != 1 ) SET_GLOBAL_STR('CLIP_PATH',file);  /* Устанавливаем
                                           * в строке каталог поиска файлов
                                           * по умолчанию */
        goto newwind;                     /* Переходим к загрузке файла */
    } else {
        if(  (cnt == 1)  ) {              /* ФАЙЛ НЕ НАЙДЕН!
                                           * Для первого раза проверим
                                           * каталог умолчания в глобальной
                                           * переменной и повторим поиск
                                           * в этом каталоге */
            if(  (length(global_str('CLIP_PATH')) > 0)  ) {
                file = global_str('CLIP_PATH')+truncate_path(file);
                cnt = 2;                  /* Изменяем счетчик, чтобы не
                                           * повторять эту процедуру
                                           * вторично */
                goto loop;
            };
            cnt = 2;
        };
        if(  (cnt == 2)  ) {         /* Во второй раз проверим
                                      * MultiEdit-строку конфигурации
                                      * (EXTENSION SETUP) - поищем
                                      * каталог умолчания для *.prg там */
            if(  (length(global_str('.PRG')) > 0)  ) {
                pds = remove_space(PARSE_STR('|127DIR=',GLOBAL_STR('.PRG')));

                if(  (svl(pds) > 0)  ) {
                    if(  (xpos('\',pds,1) == svl(pds))  ) {
                        file = pds+truncate_path(file);
                    } else {
                        file = pds+'\'+truncate_path(file);
                    };
                    cnt = 3;
                    goto loop;
                };
            };
            cnt = 3;
        };
        BEEP;             /* В третий раз и во все
                           * последующие будем запрашивать
                           * каталог поиска, пока не найдем
                           * файл или пока пользователю не
                           * надоест */
        MAKE_MESSAGE('В данном каталоге файлa '+TRUNCATE_PATH(file)+' НЕТ !');
        set_global_str('clip_istr_1',file);
        set_global_str('clip_iparm_1','/H=CLIPPER.HLP^DOP%CL_PROCFILE_OPEN/TP=0/W=40/ML=100');
        RM('USERIN^DATA_IN /#=1/PRE=clip_/T=ОБОЗНАЧЬТЕ ДРУГОЙ КАТАЛОГ (Выход - <ESC>)');
        MAKE_MESSAGE('');
        if(  ( RETURN_INT < 1 )  ) {
            RETURN_STR = '';
            switch_window(curw);
            GOTO FIN;
        };
        if(  (xpos(truncate_path(file),global_str('clip_istr_1'),1) > 0)  ) {
            file = REMOVE_SPACE(global_str('clip_istr_1'));
        } else {
            if(  (xpos('\',global_str('clip_istr_1'),1) == length(remove_space(global_str('clip_istr_1'))))  ) {
                file = remove_space(global_str('clip_istr_1'))+truncate_path(file);
            } else {
                file = remove_space(global_str('clip_istr_1'))+'\'+truncate_path(file);
            };
        };
        goto loop;
    };
    newwind:         /* Файл все же найден.
                      * Создаем окно и загружаем */
    create_window;
    if(  (ERROR_LEVEL)  ) {
        RM('MEERROR');
        return_int = 0;
        GOTO FIN;
    };
    load_file(file);
    if(  (ERROR_LEVEL)  ) {
        RM('MEERROR');
        return_int = 0;
    };
    FIN:
};



         /* Компиляция с использованием *.bat-файла.
          * Имя *.bat-файла передается в параметре /BAT.
          * В параметре /PAR передаются параметры для bat-файла.
          * Кроме того, если имеется параметр /SF=1,
          * bat-файлу будет передано имя редактируемого
          * в текущем окне файла без расширения */

macro CLIP_BATCOMPILE from edit trans {
    int n,cw,reg_exp = reg_exp_stat,i_case = ignore_case,no_err = FALSE;
    str bat,pars = '';
    bat = parse_str('/BAT=',mparm_str);   /* Считываем имя bat-файла */
    if (parse_int('/SF=',mparm_str) ) {   /* Передать bat-файлу имя
                                           * редактируемого в текущем
                                           * окне файла */
      bat = bat + ' ' + truncate_extension(file_name);
    }
    if(  (svl(bat) == 0)  ) {
        goto e;
    };
    cw = cur_window;
    refresh = FALSE;
    n = xpos('/PAR=',mparm_str,1);        /* Параметры для bat-файла */
    if ( n ) {
        pars = ' ' + copy(mparm_str,n + 5,200);
    }
    rm('allsave');                        /* Макрос записи всех редактируемых
                                           * файлов */
    if(  (return_int == 0)  ) {
        goto e;                           /* Какая-то ошибка при записи... */
    };
    del_file('meerr.tmp');                /* Удаляем MEERR.TMP с диска */
    Set_Global_Str('LAST_COMP','CLIPPER 5');   /* Устанавливаем глобальную
                                                * ME-переменную для правильной
                                                * последующей обработки в
                                                * LANGUAGE^CMPERROR */
    return_str = bat + pars;              /* И выполняем *.bat-файл */
    rm('meutil1^exec /CMD=1/MEM=0/SWAP=0/SCREEN=3/CMDLN=1/T=' + bat + pars);
    if(  (file_exists('meerr.tmp'))  ) {       /* В процессе выполнения
                                                * создан файл MEERR.TMP... */
                                               /* Загружаем его... */
        if ( !Switch_Win_Id(global_int('clip_erwind')) ) create_window;
        load_file('meerr.tmp');
        reg_exp_stat = TRUE;
        ignore_case = TRUE;                    /* И ищем: есть ли сообщения
                                                * об ошибках */
        if (not(search_fwd('{:||) +}{fatal}||{error}||{warning}',0))) {
         delete_window;                        /* Ошибок нет! */
         no_err = TRUE;
        } else tof;
        reg_exp_stat = reg_exp;
        ignore_case = i_case;
    };
    switch_window(cw);
    set_global_int('clip_erwind',0);
    refresh = TRUE;
    if (not(no_err)) rm('language^cmperror');  /* Ошибки есть! */
    else make_message('No error!');
    e:
    refresh = TRUE;
};


               /* Запись всех редактируемых файлов. Вызывается из
                * CLIP2^CLIP_BATCOMPILE и CLIP2^CLIP_RMAKE.
                * Возврат: 0 в RETURN_INT при ошибке,
                *          1 при отсутствие ошибок */

macro ALLSAVE {
    int counter,cw;
    counter = 0;
    make_message('Записываем файлы...');
    cw = cur_window;
    while(  (counter < Window_Count )  ) {      /* Проход по всем окнам */
        counter = counter + 1;
        Switch_Window (counter) ;
        if(  (truncate_path(file_name) == 'MEERR.TMP')  ) {
            erase_window;                      /* Если встретим MEERR.TMP,
                                                * удаляем */
            set_global_int('clip_erwind',window_id);  /* Запоминаем ID окна
                                                         для повторного
                                                         использования */
        };
        if(  ((File_Changed  != 0) & (Caps (File_Name )  != '?NO-FILE?'))  ) {
            Save_File ;                         /* Модифицированные файлы
                                                 * записываем */
            if(  (Error_Level  != 0)  ) {
            Refresh = 1;
            Redraw ;
            Make_Message ('Некорректное имя файла или ошибка записи файла!') ;
            Rm ('MEERROR^Beeps /C=1') ;
            return_int = 0;
            GoTo FIN ;
            } ;
        } ;
    } ;
    return_int = 1;
    make_message('');
    FIN:
    switch_window(cw);
}


            /* Компиляция с использованием *.rmk-файла.
             * В параметре /PATH может быть передан каталог
             * для поиска *.rmk-файлов. При первом вызове
             * устанавливает в глобальной переменной CLIP_RMAKE
             * имя используемого *.rmk-файла, при последующих
             * вызовах использует это имя. Для смены имени
             * используемого файла следует вызвать макрос
             * CLIP2^CLIP_CHMAKE */

macro CLIP_RMAKE from edit trans {
    int n,cw,reg_exp = reg_exp_stat,i_case = ignore_case,no_err = FALSE;
    str path;
    path = caps(parse_str('/PATH=',mparm_str));    /* Если есть, считываем
                                                    * каталог для поиска
                                                    * *.rmk-файлов */
    if(  (svl(path) > 0)  ) {
      n = svl(path);
      if(  (copy(path,n,1) != '\')  ) {
         if(  (xpos('*.RMK',path,1) == 0)  ) {
            path = path + '\*.RMK';
         };
      } else {
         path = path + '*.RMK';
      }; /* if */
    } else {
      path = '*.RMK';
    };
    if (( global_str('clip_rmake') == '' )
          OR (caps(get_path(path)) != get_path(global_str('clip_rmake')))) {
                             /* Переменная CLIP_RMAKE пуста,- следовательно,
                              * это первый вызов макроса.
                              * Второй вариант:
                              * макрос вызван с параметром /PATH,
                              * не соответствующим ранее использовавшемуся
                              * каталогу */
      rm('clip2^clip_chmake /PATH=' + path);  /* Макрос запроса имени
                                               * RMK-файла */
      if(  (return_str == '')  ) {
         goto e;
      };
      path = get_path(path) + remove_space(return_str);
    } else path = global_str('clip_rmake'); /* Если же CLIP_RMAKE не пуста,
                                             * считываем имя файла */
    cw = cur_window;
    refresh = FALSE;
    rm('allsave');                          /* Макрос записи всех
                                             * редактируемых файлов */
    if(  (return_int == 0)  ) {
        goto e;                             /* Какая-то ошибка при записи... */
    del_file('meerr.tmp');                  /* Удаляем MEERR.TMP с диска */
    };
    Set_Global_Str('LAST_COMP','CLIPPER 5');  /* Устанавливаем глобальную
                                               * ME-переменную для правильной
                                               * последующей обработки в
                                               * LANGUAGE^CMPERROR */
    return_str = 'rmake ' + path;             /* Формируем командную
                                               * строку */
                                              /* И выполняем ее */
    rm('meutil1^exec /CMD=1/MEM=0/SWAP=0/SCREEN=3/CMDLN=1/RED=meerr.tmp/T='+path);
    if(  (file_exists('meerr.tmp'))  ) {    /* В процессе выполнения
                                             * создан файл MEERR.TMP... */
        if ( !Switch_Win_Id(global_int('clip_erwind')) ) create_window;
        load_file('meerr.tmp');             /* Загружаем его... */
        reg_exp_stat = TRUE;
        ignore_case = TRUE;                 /* И ищем: есть ли сообщения
                                             * об ошибках */
        if (not(search_fwd('{:||) +}{fatal}||{error}||{warning}',0))) {
         delete_window;                     /* Ошибок нет! */
         no_err = TRUE;
        } else tof;
        reg_exp_stat = reg_exp;
        ignore_case = i_case;
    };
    switch_window(cw);
    set_global_int('clip_erwind',0);
    refresh = TRUE;
    if (not(no_err)) rm('language^cmperror');   /* Ошибки есть! */
    else make_message('No error!');
    e:
    refresh = TRUE;
};


               /* Смена *.rmk-файла, используемого по умолчанию
                * в макросе CLIP2^CLIP_RMAKE.
                * В параметре /PATH может быть передан каталог
                * для поиска *.rmk-файлов. */

macro clip_chmake from edit trans {
    int n;
    str path;
    path = caps(parse_str('/PATH=',mparm_str));    /* Если есть, считываем
                                                    * каталог для поиска
                                                    * *.rmk-файлов */
    if(svl(path)) {
      n = svl(path);
      if(  (copy(path,n,1) != '\')  ) {
         if(  (xpos('*.RMK',path,1) == 0)  ) {
            path = path + '\*.RMK';
         };
      } else {
         path = path + '*.RMK';
      };
    } else {
      path = '*.RMK';
    };
   rm('clip1^f_choice /WHAT=3 /MASK=' + path);    /* Вызываем макрос поиска
                                                   * и вывода в меню файлов
                                                   * по шаблону */
   if(  (return_str == '')  ) {
      goto e;
   };
   path = get_path(path) + remove_space(return_str);
   set_global_str('clip_rmake',caps(path));   /* Пишем в глобальную
                                               * переменную CLIP_RMAKE
                                               * имя файла для использования
                                               * при последующих вызовах */
   e:
}
/* ****************************************************************** */

/* И ВСЕ ?!
      ВСЕ !
         ВСЕ !!!

            Георгий Жердев
            27.06.93
 */

