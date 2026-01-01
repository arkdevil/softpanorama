/* **********************************************************************

ФАЙЛ: CLIP1.S
НАЗНАЧЕНИЕ: Исходный файл макросов системы поддержки программирования
            на языке CLIPPER в среде редактора Multi-Edit 
            CLIPPER-MACRO 2.1
АВТОР: Георгий ЖЕРДЕВ, 672005. г.Чита-5, ул.Рахова, 98, кв.49
ДАТА: 24.06.93
ПРИМЕЧАНИЯ: Требуемая версия Multi-Edit - 6.x. Компилировать с помощью
            CMAC.EXE версии 6.x.

************************************************************************* */

macro_file CLIP1;

/*    Макросы:
      WORD_HELP   Вызывает на экран запрашиваемый раздел template CLIPPER.HLP
      SAYBOX      Макрос вывода команды @ ... BOX ...
         BOX      ────┐
         BOXNIL       │
         BOXA         │
         BOXB         │
         BOXC         ├─ Макросы, вызываемые из SAYBOX
         BOXD         │
         BOXE         │
         BOXF         │
         BOXG         │
         BOXH         │
         BOXI     ────┘
      TITLE             Построение заголовка процедуры/функции
      CLIP_FILE_TITLE   Построение заголовка *.PRG-файла
      FUNCTION          Вывод конструкции FUNCTION () - RETURN ()
      PROCEDURE         Вывод конструкции PROCEDURE () - RETURN
      TEXTENDTEXT       Вывод конструкции TEXT - ENDTEXT
      BEGINENDBEGIN     Вывод конструкции BEGIN SEQUENCE - END SEQUENCE
      ALLSETS           Вывод команды SET ... с выбором конкретной установки
                        из меню
      CL_LOAD           Макрос загрузки файла по шаблону. Вызывается из
                        CLIPPER^CLIP_LOAD
      F_CHOICE          Макрос поиска файлов по шаблону и вывода списка
                        для выбора. Вызывается ряда макросов, требующих
                        загрузки файла (CLIP1^CL_LOAD и CLIP2^CLIP_RMAKE)
      SETFUNC           Макрос вывода функции SET() с выбором конкретной
                        установки из меню
            CL_SF       Макрос, вызываемый из SETFUNC
      CLIP_USERWORK     Макрос работы со словарем пользовательских функций.
                        Также вызывается из макросов CLIP_USERFUNC,
                        CLIP_USERNEW и CLIP_NEWWORD
            CHFILE      Макрос, вызываемый из CLIP_USERWORK
      CLIP_USERFUNC     Макрос вывода макроподстановок, определенных
                        в словаре пользовательских функций
      CLIP_USERNEW      Макрос смены словаря пользовательских функций или
                        присвоения его новой клавише
      CLIP_NEWWORD      Добавление нового определения в словарь
                        пользовательских функций
*/


macro WORD_HELP FROM EDIT trans {   /* Вызывает на экран запрашиваемый раздел
                                       template CLIPPER.HLP. Для вызова этого
                                       макроса необходимо ввести в текст
                                       вопросительный знак (или </> - т.е.
                                       та же клавиша в нижнем регистре и нажать
                                       клавишу, связанную с одним из макросов
                                       Template: CLIP_COMMANDS, CLIP_FUNCTIONS,
                                       CLIP_DBFUNC или CLIP_CLASSES.
                                       Параметры, передаваемые из указанных
                                       макросов в данный:
                                       /S= то, что Вы написали на экране,
                                       /WHERE= макрос-источник, вызвавший
                                               WORD_HELP */
  str WWORD,WHERE,LOC;
  int P;
  WWORD = PARSE_STR('/S=',MPARM_STR);     /* Считанная с экрана аббревиатура */
  WHERE = PARSE_STR('/WHERE=',MPARM_STR); /* Макрос-источник */
  P = XPOS('?',WWORD,1);                  /* Перепроверяем аббревиатуру
                                             на наличие вопросительного знака */
  if(  (P > 0)  ) {
      WWORD = STR_DEL(WWORD, P, 1);       /* ...и удаляем его. */
  };
  WWORD = COPY(WWORD,1,1);
  if(  (WHERE == 'COM')  ) {              /* Формируем строку поиска в
                                             CLIPPER.HLP */
    LOC = 'KEYSCOM';
  } else {
    if(  (WHERE == 'FUNC')  ) {
        LOC = 'KEYSFUNC';
    } else {
        if(  (WHERE == 'CLASS')  ) {
            LOC = 'KEYSCLASS';
        } else {
            LOC = 'KEYSDBF';
        };
    };
  };
  if( svl(loc) == 0 ) {
    beep;
  } else {
      rm('mehelp /F=CLIPPER/TO=1/LK=' + loc);   /* Вызываем CLIPPER.HLP
                                                   на экран */
  }
}


macro SAYBOX FROM EDIT trans {   /* Макрос вывода команды @ ... BOX ...
                                    Позволяет выбрать из меню тип рамки */
    TEXT('@  ');                 /* Начало вывода */
    RM('CLIP1^BOX');             /* Вызов макроса меню типов рамки */
    FIRST_WORD;                  /* Установка конечной позиции курсора */
    RIGHT;
    RIGHT;
};


macro BOX FROM EDIT trans {      /* Макрос меню типов рамки */
    PUT_BOX(1,2,79,7,0,M_T_COLOR,' Выберите тип рамки: ',TRUE);
    WRITE('   без    ┌───┐  ╔═══╗  ╒═══╕  ╓───╖  ┌───┐  ╒═══╕  ╓───┐  ┌───╖  ╓───╖',2,3,0,M_T_COLOR);
    WRITE('    0     │ 1 │  ║ 2 ║  │ 3 │  ║ 4 ║  │ 5 │  │ 6 │  ║ 7 │  │ 8 ║  ║ 9 ║',2,4,0,M_T_COLOR);
    WRITE('  рамки   └───┘  ╚═══╝  ╘═══╛  ╙───╜  ╘═══╛  └───┘  ╚═══╛  ╘═══╝  ╚═══╝',2,5,0,M_T_COLOR);
    READ_KEY;
    KILL_BOX;
            /* В зависимости от выбранного типа рамки
               вызываем соответствующий макрос для его вывода */
    if(  (KEY1 == 48)  ) {
        RM('CLIP1^BOXNIL');
    };
    if(  (KEY1 == 49)  ) {
        RM('CLIP1^BOXA');
    };
    if(  (KEY1 == 50)  ) {
        RM('CLIP1^BOXB');
    };
    if(  (KEY1 == 51)  ) {
        RM('CLIP1^BOXC');
    };
    if(  (KEY1 == 52)  ) {
        RM('CLIP1^BOXD');
    };
    if(  (KEY1 == 53)  ) {
        RM('CLIP1^BOXE');
    };
    if(  (KEY1 == 54)  ) {
        RM('CLIP1^BOXF');
    };
    if(  (KEY1 == 55)  ) {
        RM('CLIP1^BOXG');
    };
    if(  (KEY1 == 56)  ) {
        RM('CLIP1^BOXH');
    };
    if(  (KEY1 == 57)  ) {
        RM('CLIP1^BOXI');
    };
};


      /* Набор макросов для вывода разных типов рамок.
         (Весь этот раздел вывода рамок писался еще во времена
         MultiEdit 4.0, когда не было понятия процедур;
         перегружать основной текст макроса не хотелось,
         позтому и получилась такая многоэтажная макро-структура).
         В следующей версии CLIPPER-MACRO такого уже не будет. */

macro BOXNIL FROM EDIT trans {
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('BOX "         "');
    } else {
        TEXT('Box "         "');
    };
};

macro BOXA FROM EDIT trans {
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('BOX "┌─┐│┘─└│ "');
    } else {
        TEXT('Box "┌─┐│┘─└│ "');
    };
};

macro BOXB FROM EDIT trans {
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('BOX "╔═╗║╝═╚║ "');
    } else {
        TEXT('Box "╔═╗║╝═╚║ "');
    };
};

macro BOXC FROM EDIT trans {
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('BOX "╒═╕│╛═╘│ "');
    } else {
        TEXT('Box "╒═╕│╛═╘│ "');
    };
};

macro BOXD FROM EDIT trans {
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('BOX "╓─╖║╜─╙║ "');
    } else {
        TEXT('Box "╓─╖║╜─╙║ "');
    };
};

macro BOXE FROM EDIT trans {
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('BOX "┌─┐│╛═╘│ "');
    } else {
        TEXT('Box "┌─┐│╛═╘│ "');
    };
};

macro BOXF FROM EDIT trans {
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('BOX "╒═╕│┘─└│ "');
    } else {
        TEXT('Box "╒═╕│┘─└│ "');
    };
};

macro BOXG FROM EDIT trans {
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('BOX "╓─┐│╛═╚║ "');
    } else {
        TEXT('Box "╓─┐│╛═╚║ "');
    };
};

macro BOXH FROM EDIT trans {
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('BOX "┌─╖║╝═╘│ "');
    } else {
        TEXT('Box "┌─╖║╝═╘│ "');
    };
};

macro BOXI FROM EDIT trans {
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('BOX "╓─╖║╝═╚║ "');
    } else {
        TEXT('Box "╓─╖║╝═╚║ "');
    };
};


macro TITLE from edit trans {    /* Построение заголовка процедуры/функции.
                                    Данный макрос вызывается из
                                    CLIPPER^CLIP_COMMANDS при вводе
                                    аббревиатуры <ppp> для вывода
                                    титула процедуры или <fff> - функции */
    str comment_char;
    int initpos,no_empty = 0,i,w_a = window_attr,refr = refresh;
    w_a = window_attr;     /* "Прячем" окно на время работы, чтобы
                              не дергалось */
    refresh = FALSE;
    window_attr = 64;
    if(  (LENGTH(GET_LINE) > 0)  ) {   /* Если текущая строка не пустая,
                                          поднимаемся строкой выше */
        no_empty = 1;
        initpos = c_col;
        GOTO_COL(1);
        SET_INDENT_LEVEL;
        cr;
        up;
    } else {
        GOTO_COL(1);
        SET_INDENT_LEVEL;
      };
         /* Далее устанавливаем тип символа комментария в зависимости
            от используемой версии CLIPPER. Версия CLIPPER хранится
            в глобальной переменной 'clip_version', куда заносится
            в макросе CLIPPER^ON при запуске системы. В макрос же
            CLIPPER^ON информация о версии попадает через параметр
            /V=... */
    if(  (xpos('5',global_str('clip_version'),1) > 0)  ) {
        Text('/');      /* Версия 5.x: достаточно в начале титула
                           поставить слэш / и далее обходиться
                           без символов комментария */
        comment_char = ' ';
    } else {
        comment_char = '* ';  /* Более ранние версии */
    };
    Text('*****************************************************************');
    cr;
    Text(comment_char + char(12));  /* Символ перевода страницы
                                       для быстрого листания по функциям */
    cr;
    Text(comment_char + parse_str('/P=',mparm_str) + ': '); /* Что именно
                                       мы комментируем,- процедуру или
                                       функцию,- указывается в параметре
                                       макроса /P= */
    cr;
         /* Информация об авторе редактируемого файла хранится
            в глобальной переменной 'clip_user', куда заносится
            в макросе CLIPPER^ON при запуске системы. В макрос же
            CLIPPER^ON информация об авторе попадает через параметр
            /USR=... */
    Text(comment_char + 'АВТОР..............' + global_str('clip_user'));
    cr;
         /* Текущая дата */
    Text(comment_char + 'ДАТА...............' + Date + ' * ' + time);
    cr;
    Text(comment_char + 'НАЗНАЧЕНИЕ.........');
    mark_pos;  /* Сюда мы вернемся перед завершением макроса */
    cr;
    Text(comment_char + 'ПАРАМЕТРЫ..........');
    if ( xpos('PROCEDURE',caps(parse_str('/P=',mparm_str)),1) == 0) {
      cr;
      Text(comment_char + 'ВОЗВР. ЗНАЧЕНИЕ....');  /* Только для функций */
    }
    cr;
    Text(comment_char + 'ПРИМЕЧАНИЯ.........');
    cr;
    Text('******************* Clipper-Macro 6.x/2.1 *******************');
    if(  (xpos('5',global_str('clip_version'),1) > 0)  ) {
        Text('/');      /* Завершаем комментарий в CLIPPER 5.x */
    };
    cr;
    if(  (no_empty )  ) {
      down;
      goto_col(initpos);
    } else cr;
    RM('CLIP1^' + parse_str('/P=',mparm_str));  /* Далее вызываем,
                     в зависимости от того, что мы комментировали,
                     либо макрос FUNCTION, либо PROCEDURE */
    goto_mark;
    up;
    up;
    up;           /* Устанавливаем курсор в месте наименования функции */
    refresh = refr;     /* Восстанавливаем аттрибут окна */
    window_attr = w_a;
    update_window;
};



            /* Построение заголовка *.PRG-файла */

macro CLIP_FILE_TITLE from edit trans {
    if(  (GET_EXTENSION(FILE_NAME) != 'PRG')  ) {  /* Работаем только для
                                                      *.PRG-файлов! */
      goto q;
    };
    str buf,s,comment_char,type,vers,user;
    int reg,case,n,n1;
    reg = reg_exp_stat;    /* Установки режима поиска */
    case = ignore_case;
    reg_exp_stat = 1;
    ignore_case = 1;
    buf = '';
    make_message('Строим титульную страницу...');
    working;
         /* Информация об авторе редактируемого файла может быть
            передана в макрос непосредственно через параметр
            /USER=...; в противном случае она ищется
            в глобальной переменной 'clip_user', куда заносится
            в макросе CLIPPER^ON при запуске системы. В макрос же
            CLIPPER^ON информация об авторе попадает через параметр
            /USR=... */
    user = parse_str('/USER=',mparm_str);
    if (user == '') user = global_str('clip_user');
         /* Информация о версии CLIPPER также может быть передана
            прямо в макрос в параметре /VERSION=...; иначе она ищется
            в глобальной переменной 'clip_version', куда заносится
            в макросе CLIPPER^ON при запуске системы. В макрос же
            CLIPPER^ON информация о версии попадает через параметр
            /V=... */
    vers = parse_str('/VERSION=',mparm_str);
    if (vers == '') vers = global_str('clip_version');
    tof;
         /* Макрос выполняется в два прохода.
            В первый проход собирается список всех функций файла: */
    while(  (SEARCH_FWD('{{%{ *}STATIC}||{%{ *}STAT}||{%}}{ *}FUNC{?*}$',0))  ) {
        first_word;                    /* Нашли очередную... */
        type = '';
        s = get_word('(');             /* Считываем название */
        n = xpos('FUNC',caps(s),1);
        n1 = xpos('STAT',caps(s),1);   /* Если это STATIC FUNCTION */
        if(  (n1 > 0) & (n1 < n)  ) {
            type = '(static) ';
        };
        n = xpos(' ',s,n);             /* Добавляем информацию в строку-список */
        buf = buf + type + remove_space(copy(s,n+1,(svl(s) - n))) + '|127' ;
        down;                          /* ...и движемся дальше */
    };
    tof;
    GOTO_COL(1);                       /* А теперь начинаем вывод... */
    SET_INDENT_LEVEL;
    cr;
    up;
    if(  (xpos('5',Vers,1) > 0)  ) {   /* Для начала определяем символ
                                          комментария в зависимости от
                                          версии CLIPPER */
        Text('/');                     /* Это - для CLIPPER 5.x */
        comment_char = ' ';
    } else {
        comment_char = '* ';           /* А это - для более ранних версий */
    };
    Text('*****************************************************************');
    cr;     /* Имя редактируемого файла */
    Text(comment_char + 'ФАЙЛ..............' + truncate_path(file_name));
    cr;
    Text(comment_char + 'АВТОР.............' + USER);
    cr;     /* Текущая дата */
    Text(comment_char + 'ДОКУМЕНТИРОВАН....' + Date + ' * ' + time);
    cr;
    Text(comment_char + 'ЯЗЫК..............CLIPPER ' + Vers);
    cr;
    Text(comment_char + 'НАЗНАЧЕНИЕ........');
    mark_pos;  /* Сюда мы вернемся перед завершением макроса */
    cr;
    Text(comment_char + 'ПРИМЕЧАНИЯ........');
    cr;
    Text(comment_char);
    cr;
    if(  (svl(buf) > 0)  ) {     /* Далее перечисляем все обнаруженные функции */
        Text(comment_char + 'ФУНКЦИИ: ');
        cr;
        n = xpos('|127',buf,1);
        while(  (n > 0)  ) {
            s = copy(buf,1,(n - 1));
            if (xpos('(static)',s,1)) Text(comment_char + s);
            else Text(comment_char + '         ' + s);
            cr;
            buf = copy(buf, (n + 1), (svl(buf) - n));
            n = xpos('|127',buf,1);
        };
    };
    mark_pos;     /* Отсюда начнем вывод имен процедур */
    buf = '';
                  /* Теперь - совершенно аналогичный сбор информации
                     об описанных в файле процедурах */
    while(  (Search_FWD('{{%{ *}static}||{%{ *}stat}||{%}}{ *}proc{?*}',0))  ) {
        first_word;
        type = '';
        s = get_word('(');
        n = xpos('PROC',caps(s),1);
        n1 = xpos('STAT',caps(s),1);
        if(  (n1 > 0) & (n1 < n)  ) {
            type = '(static) ';
        };
        n = xpos(' ',s,n);
        buf = buf + type + remove_space(copy(s,n+1,(svl(s) - n))) + '|127' ;
        down;
    };
    goto_mark;
                  /* И совершенно аналогичный вывод их в титуле
                     вслед за функциями */
    if(  (svl(buf) > 0)  ) {
        Text(comment_char);
        cr;
        Text(comment_char + 'ПРОЦЕДУРЫ: ');
        cr;
        n = xpos('|127',buf,1);
        while(  (n > 0)  ) {
            s = copy(buf,1,(n - 1));
            if (xpos('(static)',s,1)) Text(comment_char + '  ' + s);
            else Text(comment_char + '           ' + s);
            cr;
            buf = copy(buf, (n + 1), (svl(buf) - n));
            n = xpos('|127',buf,1);
        };
    };
    Text('******************* Clipper-Macro 6.x/2.1 *******************');
    if(  (xpos('5',Vers,1) > 0)  ) {
        Text('/');   /* Завершаем комментарий в CLIPPER 5.x */
    };
    cr;
    redraw;
    goto_mark;       /* Устанавливаем курсор у пункта <НАЗНАЧЕНИЕ> */
    make_message('Готово! Вносите недостающие сведения!');
    reg_exp_stat = reg;    /* Восстанавливаем установки поиска */
    ignore_case = case;
    q:
};


         /* Вывод конструкции FUNCTION () - RETURN () */

macro FUNCTION FROM EDIT trans {
    str cw;
    if (get_line != '') {         /* Если строка не пустая... */
      first_word;
      cw = caps(get_word(' '));   /* Считываем первое слово */
      if ((cw == 'STATIC') OR (cw == 'STAT')) right;  /* Если это слово
                                     STATIC - очевидно, подразумевается
                                     статическая функция. В таком случае
                                     мы просто перемещаемся вправо */
      else {                      /* В противном случае мы спускаемся
                                   * на строку ниже */
         eol;
         cr;
         goto_col(1);
         }
      }
                                  /* Ну, а дальше - стандартный вывод
                                   * конструкции, аналогичный макросам
                                   * CLIP_COMMANSx, описанным в CLIPPER.S */
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('FUNCTION ()');
        CR;
        GOTO_COL(1);
        TEXT('RETURN ()');
    } else {
        TEXT('Function ()');
        CR;
        GOTO_COL(1);
        TEXT('Return ()');
    };
    UP;
    FIRST_WORD;
    while(  (CUR_CHAR != '(')  ) {
        RIGHT;
    };
};


         /* Абсолютно аналогичный предыдущему макрос
          * вывода конструкции PROCEDURE () - RETURN */

macro PROCEDURE FROM EDIT trans {
    str cw;
    if (get_line != '') {
      first_word;
      cw = caps(get_word(' '));
      if ((cw == 'STATIC') OR (cw == 'STAT')) right;
      else {
         eol;
         cr;
         goto_col(1);
         }
      }
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('PROCEDURE ()');
        CR;
        GOTO_COL(1);
        TEXT('RETURN');
    } else {
        TEXT('Procedure ()');
        CR;
        GOTO_COL(1);
        TEXT('Return');
    };
    UP;
    FIRST_WORD;
    while(  (CUR_CHAR != '(')  ) {
        RIGHT;
    };
};


            /* Стандартный макрос вывода
            * конструкции TEXT - ENDTEXT, аналогичный макросам
            * TEXT_COMMANDSx, описанным в CLIPPER.S */

macro TEXTENDTEXT FROM EDIT trans {
    if(  (LENGTH(GET_LINE) > 0)  ) {
        RM('CLIPPER^CLI_IND');
    };
    int prev_pos = c_col;
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('TEXT '+CAPS(PARSE_STR('/S=',MPARM_STR)));
        CR;
        goto_col(prev_pos);
        TEXT('ENDTEXT');
    } else {
        TEXT('Text '+PARSE_STR('/S=',MPARM_STR));
        CR;
        goto_col(prev_pos);
        TEXT('EndText');
    };
    UP;
    EOL;
};


            /* Стандартный макрос вывода
            * конструкции BEGIN SEQUENCE - END SEQUENCE, аналогичный макросам
            * TEXT_COMMANDSx, описанным в CLIPPER.S */

macro BEGINENDBEGIN FROM EDIT trans {
    if(  (LENGTH(GET_LINE) > 0)  ) {
        RM('CLIPPER^CLI_IND');
    };
    int prev_pos = c_col;
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('BEGIN SEQUENCE');
        CR;
        goto_col(prev_pos);
        TEXT('END SEQUENCE');
    } else {
        TEXT('Begin Sequence');
        CR;
        goto_col(prev_pos);
        TEXT('End Sequence');
    };
    UP;
    EOL;
    RM('CLIPPER^CLI_IND');
};


            /* Вывод команды SET ... с выбором конкретной установки
             * из меню                                               */

macro ALLSETS FROM EDIT trans {
  LOOP:     /* Выдаем на экран меню и далее вызываем макрос
             * CLIPPER^TEXT_COMMANDS0 для вывода соответствующей
             * строки в зависимости от сделанного выбора  */
  RM ('USERIN^XMENU /X=57/Y=4/B=1/T=1/L=1.Выберите:/M=1.Все()2.След.лист()Alternate to()alteRnate on/off()Bell()Century()cOlor()coNfirm()conSole()cUrsor()Date()dEcimals()deFault()deLeted()delImiters to()deliMiters on/off()deVice()epocH()escaPe()exacT()') ;
  if(  (RETURN_INT < 1)  ) {
    GOTO FINISH;
  };
  if(  (RETURN_INT == 1)  ) {    /* Обратите внимание: первый пункт меню -
                                  * вывести сразу все SET-команды. Очень
                                  * удобно для установки среды исполнения
                                  * программы в начале программного файла.
                                  * Получив весь список, Вы далее можете
                                  * удалить лишнее и не упустить ничего
                                  * из необходимого. */
      MARK_POS;
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Alternate To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Bell O');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Century O');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Color To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Confirm O');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Console O');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Cursor O');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Date ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Decimals To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Default To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Deleted O');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Delimiters To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Device To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Epoch To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Escape O');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Exact O');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Exclusive O');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Filter To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Fixed O');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Format To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Function To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Index To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Intensity O');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Key To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Margin To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Message To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Order To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Path To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Printer To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Procedure To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Relation ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Scoreboard O');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set SoftSeek O');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Typeahead To ');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Unique O');
      RM('CLIPPER^TEXT_COMMANDS0 /S=Set Wrap O');
      GOTO_MARK;
      EOL;
      GOTO FINISH;
  };
  if(  (RETURN_INT == 2)  ) {    /* Второй пункт меню - показать вторую
                                  * страницу. Этих SET-команд так много,
                                  * что за раз они на экран не входят. Делать
                                  * прокрутку не совсем удобно. Удобнее сразу
                                  * вызвать вторую страницу, если знаешь,
                                  * что на первой искомое отсутствует. */
    RM ('USERIN^XMENU /X=57/Y=4/B=1/T=1/L=2.Выберите:/M=1.лист1()Exclusive()Filter()fIxed()fOrmat()fUnction()iNdex()inTensit()Key()Margin()messaGe()message...Center()oRder()patH()Printer()proceDure()reLation()scoreBoard()Softseek()tYpeahead()uniQue()Wrap()') ;
               /* Сначала оценим возврат их XMENU второй страницы.
                * Этот макрос писался еще тогда, когда язык MultiEdit
                * был очень беден в отношении конструкций управления
                * процессом,- пришлось поступить подобным образом.
                * Поскольку это нормально работает и в 6-м ME,
                * переделывать не стал. */
    if(  (RETURN_INT < 2)  ) {
      GOTO LOOP;
    };
    if(  (RETURN_INT == 2)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set ExcPsive O');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 3)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Filter To ');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 4)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Fixed O');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 5)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Format To ');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 6)  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Set Function  To ');
      LEFT;
      LEFT;
      LEFT;
      LEFT;
      GOTO FINISH;
    };
    if(  (RETURN_INT == 7)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Index To ');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 8)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Intensity O');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 9)  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Set Key To ');
      LEFT;
      LEFT;
      LEFT;
      LEFT;
      GOTO FINISH;
    };
    if(  (RETURN_INT == 10)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Margin To ');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 11)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Message To ');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 12)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Message To  Center');
      LEFT;
      LEFT;
      LEFT;
      LEFT;
      LEFT;
      LEFT;
      LEFT;
      GOTO FINISH;
    };
    if(  (RETURN_INT == 13)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Order To ');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 14)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Path To ');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 15)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Printer To ');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 16)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Procedure To ');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 17)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Relation ');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 18)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Scoreboard O');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 19)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set SoftSeek O');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 20)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Typeahead To ');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 21)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Unique O');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 22)  ) {
          RM('CLIPPER^TEXT_COMMANDS1 /S=Set Wrap O');
      GOTO FINISH;
    };
  };
         /* А вот только теперь переходим к оценке
          * возврата из XMENU первой страницы! */

  if(  (RETURN_INT == 3)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Alternate To ');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 4)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Alternate O');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 5)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Bell O');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 6)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Century O');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 7)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Color To ');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 8)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Confirm O');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 9)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Console O');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 10)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Cursor O');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 11)  ) {      /* Если Вы заказали SET DATE, уточним,
                                     * какой именно формат Вам желателен
                                     * и избавим Вас от необходимости писать
                                     * это от руки */
    RM('CLIPPER^TEXT_COMMANDS1 /S=Set Date ');
    RM ('USERIN^XMENU /X=57/Y=4/B=1/T=1/S=5/L=Формат даты:/M=American-мм/дд/гг()anSi-    гг.мм.дд()British- дд/мм/гг()French-  дд/мм/гг()German-  дд.мм.гг()Italian- дд-мм-гг()Japan-   гг/мм/дд()Usa-     мм-дд-гг()');
    if(  (RETURN_INT == 1)  ) {
          RM('CLIPPER^TEXT_COMMANDS3 /S=American');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 2)  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=ANSI');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 3)  ) {
          RM('CLIPPER^TEXT_COMMANDS3 /S=British');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 4)  ) {
          RM('CLIPPER^TEXT_COMMANDS3 /S=French');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 5)  ) {
          RM('CLIPPER^TEXT_COMMANDS3 /S=German');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 6)  ) {
          RM('CLIPPER^TEXT_COMMANDS3 /S=Italian');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 7)  ) {
          RM('CLIPPER^TEXT_COMMANDS3 /S=Japan');
      GOTO FINISH;
    };
    if(  (RETURN_INT == 8)  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=USA');
      GOTO FINISH;
    };
  };
  if(  (RETURN_INT == 12)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Decimals To ');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 13)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Default To ');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 14)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Deleted O');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 15)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Delimiters To ');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 16)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Delimiters O');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 17)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Device To ');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 18)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Epoch To ');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 19)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Escape O');
    GOTO FINISH;
  };
  if(  (RETURN_INT == 20)  ) {
        RM('CLIPPER^TEXT_COMMANDS1 /S=Set Exact O');
    GOTO FINISH;
  };
  FINISH:      /* Вот и все... */
};


         /* Макрос загрузки файла по шаблону. Вызывается из
          * CLIPPER^CLIP_LOAD. Писался еще во времена 4-й версии ME,
          * когда имя файла для загрузки приходилось набирать вручную,
          * либо каждый раз для этого выходить в Dir Shell.
          * Сейчас процесс выбора файла существенно упростился, но
          * я сохранил этот макрос. В нем есть свои прелести:
          * он достаточно быстро работает, выводит на экран только
          * файлы по заданному шаблону, позволяет грузить файл как
          * в текущее, так и в новое окно, и, наконец, запоминает
          * каталог поиска файлов */

macro CL_LOAD FROM EDIT trans {
    str MASK,FNAME;
    MASK = PARSE_STR('/MASK=',MPARM_STR);    /* Шаблон файлов */
    if(  (SVL(MASK) == 0)  ) {
      MASK = '*.*';
    };
    CYCLE:
    PUSH_LABELS;
    FLABEL('НовКат',2,255);
    FLABEL('НовОкн',9,255);
    RM('CLIP1^F_CHOICE /WHAT=1/MASK='+MASK);    /* Собственно выбор и вывод
                     * меню файлов производятся в другом макросе - F_CHOICE.
                     * Сделано это, чтобы избежать дублирования, так как
                     * аналогичные действия потребуются и при выборе
                     * *.RMK-файла в макросе CLIP2^CLIP_RMAKE */
    POP_LABELS;
    if(  (LENGTH(RETURN_STR) == 0)  ) {
        return_int = 0;
        GOTO QUIT;
    };
    FNAME = RETURN_STR;
    if(  (RETURN_INT == 1)  ) {     /* Загрузить файл в новое окно */
        CREATE_WINDOW;
        if(  (ERROR_LEVEL)  ) {
            RM('MEERROR');
            return_int = 0;
            GOTO QUIT;
        };
        LOAD_FILE(REMOVE_SPACE(FNAME));
        if(  (ERROR_LEVEL)  ) {
            RM('MEERROR');
            return_int = 0;
            GOTO QUIT;
        };
        MAKE_MESSAGE('Файл '+REMOVE_SPACE(FNAME)+' загружен в новое окно');
        return_int = 1;
        GOTO QUIT;
    };
    if(  (FILE_CHANGED)  ) {        /* ИНАЧЕ - загрузить файл в текущее окно.
                                     * Разумеется, сначала проверяем ранее
                                     * редактировавшийся в данном окне файл
                                     * на предмет не записанных изменений */
        BEEP;
        RM('USERIN^VERIFY /C=1/L=4/H=ME.HLP^FL/T=ЗАПИСАТЬ?/BL=Изменения в текущем файле '+TRUNCATE_PATH(FILE_NAME)+' не записаны !');
        if(  (RETURN_INT)  ) {
            SAVE_FILE;
            if(  (ERROR_LEVEL)  ) {
              RM('MEERROR');
              MASK = GET_PATH(FNAME)+TRUNCATE_PATH(MASK);
              GOTO CYCLE;
            };
            MAKE_MESSAGE('Файл '+TRUNCATE_PATH(FILE_NAME)+' записан');
        };
    };
    LOAD_FILE(FNAME);
    if(  (ERROR_LEVEL)  ) {
      RM('MEERROR');
      MASK = GET_PATH(FNAME)+TRUNCATE_PATH(MASK);
      GOTO CYCLE;
    };
    MAKE_MESSAGE('Файл '+FNAME+' загружен');
    return_int = 1;
    QUIT:
};


         /* Макрос поиска файлов по шаблону и вывода списка
          * для выбора. Вызывается ряда макросов, требующих
          * загрузки файла (CLIP1^CL_LOAD и CLIP2^CLIP_RMAKE).
          * Получает параметры:
          * WHAT= откуда макрос вызван:
          *       1 - из CLIP1^CL_LOAD
          *       3 - из CLIP2^CLIP_RMAKE
          *              (раньше были и другие макросы,
          *               обращавшиеся к этому)
          * MASK= шаблон поиска */

macro F_CHOICE FROM EDIT trans {
    str MASK,FNAME,ALLFILE[2048],ext;
    int ROW,NUM,COL,MAXROW,MAXNUM,RR,RR1,CURROW,NEWWIND,OLDWIND;
    OLDWIND = CUR_WINDOW;
    NEWWIND = 0;

            /* Если вызов из CLIP1^CL_LOAD */

    if(  (PARSE_INT('/WHAT=',MPARM_STR) == 1)  ) {
        ext = PARSE_STR('/MASK=',MPARM_STR);
        if(  (SVL(ext) == 0)  ) {
            ext = '*.*';
        } else {
            ext = truncate_path(ext);
        };
    };
            /* ИНАЧЕ - если вызов из CLIP2^CLIP_RMAKE, мы будем
             * искать *.RMK - файлы только в текущем каталоге,
             * поэтому дальнейшие операции по определению каталога
             * умолчания и пр. мы опускаем */
    if(  (xpos('*.RMK',parse_str('/MASK=', mparm_str),1) > 0) & (parse_int('/WHAT=', mparm_str) == 3)  ) {
      MASK = PARSE_STR('/MASK=',MPARM_STR);
      GOTO LOOP;
    };
         /* Таким образом, вплоть до метки LOOP мы работаем только
          * по обслуживанию макроса CLIP1^CL_LOAD */
    MASK = PARSE_STR('/MASK=',MPARM_STR);
    if(  (LENGTH(GET_PATH(MASK)) == 0)  ) {
               /* Если макрос уже вызывался, должна существовать
                * глобальная переменная clip_path, хранящая
                * каталог прошлого сеанса */
        if(  (LENGTH(GLOBAL_STR('CLIP_PATH')) > 0)  ) {
               MASK = GLOBAL_STR('CLIP_PATH')+MASK;
               GOTO LOOP;
        } else {        /* Если же макрос вызван впервые, запросим каталог */
               GOTO QUERY;
        };
        if(  (GLOBAL_INT('CLIP_FLMENU') == 0)  ) {
            SET_GLOBAL_INT('CLIP_FLMENU',1);    /* Выбор по умолчанию */
        };
        QUERY:          /* Запрос каталога */
        RM ('USERIN^XMENU /X=1/Y=3/B=1/T=0/S='+STR(GLOBAL_INT('CLIP_FLMENU'))+'/L=* Каталог? */M= 1. Текущий (CLIPPER^DOP) 2. Умолчания (CLIPPER^DOP) 3. Другой (CLIPPER^DOP) 4. Multi-Edit (CLIPPER^DOP)') ;
        if(  (RETURN_INT == 0)  ) {       /* Нажали ESC */
            RETURN_STR = '';
            GOTO QUIT;
        };
        SET_GLOBAL_INT('CLIP_FLMENU',RETURN_INT);  /* Значение выбора
                                                    * по умолчанию на будущее */
        if(  (RETURN_INT == 2)  ) {    /* Затребован каталог умолчания для
                                        * файлов с данным расширением.
                        * Ищем ME-переменную с установками для файлов
                        * с данным расширением */
            if(  (LENGTH(GLOBAL_STR('.'+GET_EXTENSION(MASK))) > 0)  ) {
                FNAME = PARSE_STR('|127DIR=',GLOBAL_STR('.'+GET_EXTENSION(MASK)));

                if(  (XPOS('\',FNAME,1) != SVL(FNAME))  ) {
                    FNAME = FNAME+'\';
                };
                MASK = REMOVE_SPACE(FNAME)+MASK;
                if(  (PARSE_INT('/WHAT=',MPARM_STR) == 1)  ) {
                    SET_GLOBAL_STR('CLIP_PATH',FNAME);
                };
            } else {    /* А такой переменной-то и нет! */
                        /* Попросим написать каталог... */
                BEEP;
                MAKE_MESSAGE('Определение каталога умолчания не обнаружено !');
                set_global_str('clip_istr_1',mask);
                set_global_str('clip_iparm_1','/H=CLIPPER^DOP%CLIP_LOAD/TP=0/W=40/ML=100');
                RM('USERIN^DATA_IN /#=1/PRE=clip_/T=ОБОЗНАЧЬТЕ ДРУГОЙ КАТАЛОГ (Выход - <ESC>)');
                MAKE_MESSAGE('');
                if(  ( RETURN_INT < 1 )  ) {
                    RETURN_STR = '';
                    GOTO quit;
                };
                MASK = REMOVE_SPACE(global_str('clip_istr_1'));
                if(  (xpos('\',mask,1) < svl(mask))  ) {
                    if(  (xpos(ext,mask,1) == 0)  ) {
                        mask = mask + '\' + ext;
                    };
                };
            };
        };
        if(  (RETURN_INT == 3)  ) {    /* ИНАЧЕ - Затребован каталог
                                        *  и не текущий, и не умолчания */
                                       /*  А какой? */
            set_global_str('clip_istr_1',mask);
            set_global_str('clip_iparm_1','/H=CLIPPER^DOP%CLIP_LOAD/TP=0/W=40/ML=100');
            RM('USERIN^DATA_IN /#=1/PRE=clip_/T=ОБОЗНАЧЬТЕ ДРУГОЙ КАТАЛОГ (Выход - <ESC>)');
            if(  ( RETURN_INT < 1 )  ) {
                RETURN_STR = '';
                GOTO quit;
            };
            MASK = REMOVE_SPACE(global_str('clip_istr_1'));
        };
        if(  (xpos('\',mask,1) < svl(mask))  ) {
            if(  (xpos(ext,mask,1) == 0)  ) {
                mask = mask + '\' + ext;
            };
        };
        if(  (RETURN_INT == 4)  ) {
            MASK = ME_PATH + MASK;
        };
        SET_GLOBAL_STR('CLIP_PATH',GET_PATH(MASK));   /* Устанавливаем
                         * глобальную переменную для следующих вызовов
                         * этого макроса */
    };

LOOP:                    /* Петля поиска требуемых файлов и сбора их имен
                          * в строку меню */
    if(  (FIRST_FILE(MASK) == 0)  ) {
      NUM = 1;
      ALLFILE = LAST_FILE_NAME;   /* Имя первого найденного файла */
      Pad_str(ALLFILE,12,' ');
    } else {   /* Файлов согласно шаблону не оказалось */
      BEEP;
      MAKE_MESSAGE('В данном каталоге файлов '+TRUNCATE_PATH(MASK)+' НЕТ !');

NO_FILES:                         /* Запрос другого каталога */
      set_global_str('clip_istr_1',mask);
      set_global_str('clip_iparm_1','/H=CLIPPER^DOP%CLIP_LOAD/TP=0/W=40/ML=100');
      RM('USERIN^DATA_IN /#=1/PRE=clip_/T=ОБОЗНАЧЬТЕ ДРУГОЙ КАТАЛОГ (Выход - <ESC>)');
      MAKE_MESSAGE('');
      if(  ( RETURN_INT < 1 )  ) {
           RETURN_STR = '';
           GOTO QUIT;
      };
      MASK = REMOVE_SPACE(global_str('clip_istr_1'));
    if(  (xpos('\',mask,1) < svl(mask))  ) {
        if(  (xpos(ext,mask,1) == 0)  ) {
            mask = mask + '\' + ext;
        };
    };
      if(  (PARSE_INT('/WHAT=',MPARM_STR) == 1)  ) {
          SET_GLOBAL_STR('CLIP_PATH',GET_PATH(MASK));
      };
      GOTO LOOP;                  /* Возврат к петле поиска */
    };
    while(  NEXT_FILE == 0   ) {  /* Если же файлы есть, продолжаем
                                   * их собирать */
      NUM ++;
      FNAME = LAST_FILE_NAME;     /* Имя очередного файла */
      Pad_str(FNAME,12,' ');
      ALLFILE = ALLFILE + FNAME;
    };
    MAXNUM = NUM;                 /* Общее количество найденных файлов */
    ROW = 3;                      /* Расчет координат для самодельного
                                   * меню, которое последует далее */
    RR = ROW + MAXNUM + 2;
    if(  (RR > 24)  ) {
        MAXROW = 24;
    } else {
        MAXROW = RR;
    };
    COL = 64;
    if(  (PARSE_INT('/WHAT=',MPARM_STR) == 1)  ) {
        PUT_BOX(28,3,65,10,0,H_T_COLOR,'',TRUE);
        WRITE('<ENTER> - Загрузить в текущ. окно',29,4,0,H_T_COLOR);
        WRITE('<F9>    - Загрузить в новое окно',29,5,0,H_T_COLOR);
        WRITE('<F2>    - Изменить каталог',29,6,0,H_T_COLOR);
        WRITE('<ESC>   - Отказаться от выполнения',29,8,0,H_T_COLOR);
    };
         /* Дальше пошло самодельное меню файлов */

    PUT_BOX(COL,ROW,COL+15,MAXROW,0,M_T_COLOR,' Ваш выбор: ',TRUE);
    MAXROW = MAXROW - 2;
    ROW = ROW + 1;
    CURROW = ROW;
    COL = COL+1;
    NUM = 1;
    while(  (CURROW <= MAXROW)  ) {
        FNAME = COPY(ALLFILE,(NUM * 12 - 11),12);
        WRITE(FNAME,COL,CURROW,0,M_T_COLOR);
        NUM = NUM + 1;
        CURROW = CURROW + 1;
    };
    CURROW = ROW;
    NUM = 1;
    FNAME = COPY(ALLFILE,1,12);
    WRITE(FNAME,COL,CURROW,0,M_H_COLOR);
    READ_KEY;
    ERROR_LEVEL = 0;
    windloop:
    while(  (KEY2 != 28)  ) {    /* Пока не ENTER */
        if(  (KEY2 == 67)  ) {   /* F9 - Загрузить в новое окно */
            if(  (PARSE_INT('/WHAT=',MPARM_STR) == 1)  ) {
                RETURN_INT = 1;
                MASK = COPY(MASK,1,XPOS('*.',MASK,1)-1);
                RETURN_STR = REMOVE_SPACE(MASK+FNAME);
                KILL_BOX;
                KILL_BOX;
                GOTO QUIT;
            };
        };
        if(  (KEY2 == 60)  ) {   /* F2 - Затребован другой каталог */
          KILL_BOX;
          KILL_BOX;
          GOTO NO_FILES;
        };
        WRITE(FNAME,COL,CURROW,0,M_T_COLOR);

               /* Обработка клавиш перемещения курсора */

        if(  (KEY2 == 72)  ) {
            if(  (NUM == 1)  ) {
                BEEP;
            } else {
                NUM = NUM - 1;
                if(  (CURROW == ROW)  ) {
                        SCROLL_BOX_DN(COL,ROW,COL+11,MAXROW,M_T_COLOR);
                } else {
                    CURROW = CURROW - 1;
                };
            };
        } else {
            if(  (KEY2 == 80)  ) {
                if(  (NUM == MAXNUM)  ) {
                    BEEP;
                } else {
                    NUM = NUM + 1;
                    if(  (CURROW == MAXROW)  ) {
                        SCROLL_BOX_UP(COL,ROW,COL+11,MAXROW,M_T_COLOR);
                    } else {
                        CURROW = CURROW+1;
                    };
                };
            } else {
                if(  (KEY2 == 81)  ) {
                    if(  (NUM == MAXNUM)  ) {
                        BEEP;
                        GOTO FINISH;
                    };
                    if(  (CURROW < MAXROW)  ) {
                        NUM = NUM + (MAXROW - CURROW);
                        CURROW = MAXROW;
                    } else {
                        RR1 = 0;
                        RR = MAXROW - ROW + 1;
                        while(  (RR1 < RR)  ) {
                            NUM = NUM + 1;
                            if(  (NUM < MAXNUM)  ) {
                                SCROLL_BOX_UP(COL,ROW,COL+11,MAXROW,M_T_COLOR);
                                FNAME = COPY(ALLFILE,(NUM * 12 - 11),12);
                                WRITE(FNAME,COL,CURROW,0,M_T_COLOR);
                            } else {
                                SCROLL_BOX_UP(COL,ROW,COL+11,MAXROW,M_T_COLOR);
                                GOTO FINISH;
                            };
                        };
                        FINISH:
                    };
                } else {
                    if(  (KEY2 == 73)  ) {
                        if(  (NUM == 1)  ) {
                            BEEP;
                            GOTO FINISH1;
                        };
                        if(  (CURROW > ROW)  ) {
                            NUM = NUM - (CURROW - ROW);
                            CURROW = ROW;
                        } else {
                            RR1 = 0;
                            RR = MAXROW - ROW + 1;
                            while(  (RR1 < RR)  ) {
                                NUM = NUM - 1;
                                if(  (NUM > 1)  ) {
                                    SCROLL_BOX_DN(COL,ROW,COL+11,MAXROW,M_T_COLOR);
                                    FNAME = COPY(ALLFILE,(NUM * 12 - 11),12);
                                    WRITE(FNAME,COL,CURROW,0,M_T_COLOR);
                                } else {
                                    SCROLL_BOX_DN(COL,ROW,COL+11,MAXROW,M_T_COLOR);
                                    GOTO FINISH1;
                                };
                            };
                            FINISH1:
                        };
                    } else {
                        if(  (KEY2 == 1)  ) {
                            RETURN_STR = '';
                            KILL_BOX;
                            KILL_BOX;
                            GOTO QUIT;
                        } else {
                            BEEP;
                        };
                    };
                };
            };
        };
        FNAME = COPY(ALLFILE,(NUM * 12 - 11),12);
        WRITE(FNAME,COL,CURROW,0,M_H_COLOR);
        WINDEXIT:
        READ_KEY;
    };
    RETURN_INT = 0;
    MASK = COPY(MASK,1,XPOS('*.',MASK,1)-1);    /* Возвращаем имя выбранного
                                                 * файла */
    RETURN_STR = REMOVE_SPACE(MASK+FNAME);
    KILL_BOX;
    KILL_BOX;
    if(  (NEWWIND == 1)  ) {
        DELETE_WINDOW;
        SWITCH_WINDOW(OLDWIND);
    };
    QUIT:
    REFRESH = 1;
};


            /* Вывод функции SET() с выбором конкретной установки
             * из меню                                          */

macro SETFUNC FROM EDIT trans {
    RM('CLIPPER^TEXT_COMMANDS5 /S=Set()');
    str STR_1,STR_2 ;
    STR_1 = '2.След.лист()ALTERNATE()ALTFILE()BELL()CANCEL()COLOR()CONFIRM()CONSOLE()CURSOR()DATEFORMAT()DEBUG()DECIMALS()DEFAULT()DELETED()DELIMITERS()DELIMCHARS()DEVICE()EPOCH()ESCAPE()EXACT()';
    STR_2 = '1.Лист1()EXCLUSIVE()EXIT()EXTRA()EXTRAFILE()FIXED()INSERT()INTENSITY()MARGIN()MCENTER()MESSAGE()PATH()PRINTER()PRINTFILE()SCOREBOARD()SCROLLBREAK()SOFTSEEK()TYPEAHEAD()UNIQUE()WRAP()' ;
P1:      /* Первая страница меню */
    RM('USERIN^XMENU /S=1/L= Установки Set /X=62/Y=4/B=1/T=1/M='+STR_1);
    if(  (RETURN_INT == 0)  ) {
        GOTO F;
    };
    if(  (RETURN_INT == 1)  ) {
        GOTO P2;
    };
    RM('CL_SF /T=1/N='+STR(RETURN_INT-1));
P2:      /* Вторая страница меню */
    RM('USERIN^XMENU /S=1/L= Установки Set /X=62/Y=4/B=1/T=1/M='+STR_2);
    if(  (RETURN_INT == 0)  ) {
        GOTO F;
    };
    if(  (RETURN_INT == 1)  ) {
        GOTO P1;
    };
    RM('CL_SF /T=2/N='+STR(RETURN_INT-1));   /* После выбора определенной
                                              * установки вызываем макрос
                                              * ввода ее в текст */
    F:
};


         /* Макрос ввода в текст установки Set(). Вызывается
          * из CLIP1^SETFUNC */

macro cl_sf FROM EDIT trans {
    str S,N;
    if(  (GLOBAL_INT('CLIP_SET_CH') == 0)  ) {     /* В этой переменной
                                                    * хранится установка
                                                    * умолчания:
                                                    * вводить в текст числовое
                                                    * представление установки
                                                    * или ее макроопределение
                                                    * из Set.Ch */
        SET_GLOBAL_INT('CLIP_SET_CH',1);     /* По умолчанию -
                                              * макроопределение */
    };
    N = REMOVE_SPACE(PARSE_STR('/N=',MPARM_STR));  /* Имя установки */
    RM('USERIN^XMENU /X=2/Y=4/B=1/T=0/S='+STR(GLOBAL_INT('CLIP_SET_CH'))+'/L=* ВВЕСТИ /M=1. Макроопределение (CLIPPER^KEYSFUNC%SET)2. Цифровое значение (CLIPPER^KEYSFUNC%SET)');
    if(  (RETURN_INT == 0)  ) {
        GOTO FINISH;
    };
    SET_GLOBAL_INT('CLIP_SET_CH',RETURN_INT);   /* Устанавливаем новое
                                                 * значение умолчания */
    if(  (RETURN_INT == 1)  ) {        /* Вводить макроподстановку */
        if(  (PARSE_INT('/T=',MPARM_STR) == 1)  ) {   /* И пошли вводить ... */
            if(  (N == '1')  ) {    /* Первая страница меню */
            S = 'ALTERNATE';
            GOTO FF;
             };


            if(  (N == '2')  ) {
            S = 'ALTFILE';
            GOTO FF;
             };


            if(  (N == '3')  ) {
            S = 'BELL';
            GOTO FF;
             };


            if(  (N == '4')  ) {
            S = 'CANCEL';
            GOTO FF;
             };


            if(  (N == '5')  ) {
            S = 'COLOR';
            GOTO FF;
             };


            if(  (N == '6')  ) {
            S = 'CONFIRM';
            GOTO FF;
             };


            if(  (N == '7')  ) {
            S = 'CONSOLE';
            GOTO FF;
             };


            if(  (N == '8')  ) {
            S = 'CURSOR';
            GOTO FF;
             };


            if(  (N == '9')  ) {
            S = 'DATEFORMAT';
            GOTO FF;
             };


            if(  (N == '10')  ) {
            S = 'DEBUG';
            GOTO FF;
             };


            if(  (N == '11')  ) {
            S = 'DECIMALS';
            GOTO FF;
             };


            if(  (N == '12')  ) {
            S = 'DEFAULT';
            GOTO FF;
             };


            if(  (N == '13')  ) {
            S = 'DELETED';
            GOTO FF;
             };


            if(  (N == '14')  ) {
            S = 'DELIMITERS';
            GOTO FF;
             };


            if(  (N == '15')  ) {
            S = 'DELIMCHARS';
            GOTO FF;
             };


            if(  (N == '16')  ) {
            S = 'DEVICE';
            GOTO FF;
             };


            if(  (N == '17')  ) {
            S = 'EPOCH';
            GOTO FF;
             };


            if(  (N == '18')  ) {
            S = 'ESCAPE';
            GOTO FF;
             };


            if(  (N == '19')  ) {
            S = 'EXACT';
            GOTO FF;
             };

        } else {        /* Вторая страница меню */

            if(  (N == '1')  ) {
            S = 'EXCLUSIVE';
            GOTO FF;
             };


            if(  (N == '2')  ) {
            S = 'EXIT';
            GOTO FF;
             };


            if(  (N == '3')  ) {
            S = 'EXTRA';
            GOTO FF;
             };


            if(  (N == '4')  ) {
            S = 'EXTRAFILE';
            GOTO FF;
             };


            if(  (N == '5')  ) {
            S = 'FIXED';
            GOTO FF;
             };


            if(  (N == '6')  ) {
            S = 'INSERT';
            GOTO FF;
             };


            if(  (N == '7')  ) {
            S = 'INTENSITY';
            GOTO FF;
             };


            if(  (N == '8')  ) {
            S = 'MARGIN';
            GOTO FF;
             };


            if(  (N == '9')  ) {
            S = 'MCENTER';
            GOTO FF;
             };


            if(  (N == '10')  ) {
            S = 'MESSAGE';
            GOTO FF;
             };


            if(  (N == '11')  ) {
            S = 'PATH';
            GOTO FF;
             };


            if(  (N == '12')  ) {
            S = 'PRINTER';
            GOTO FF;
             };


            if(  (N == '13')  ) {
            S = 'PRINTFILE';
            GOTO FF;
             };


            if(  (N == '14')  ) {
            S = 'SCOREBOARD';
            GOTO FF;
             };


            if(  (N == '15')  ) {
            S = 'SCROLLBREAK';
            GOTO FF;
             };


            if(  (N == '16')  ) {
            S = 'SOFTSEEK';
            GOTO FF;
             };


            if(  (N == '17')  ) {
            S = 'TYPEAHEAD';
            GOTO FF;
             };


            if(  (N == '18')  ) {
            S = 'UNIQUE';
            GOTO FF;
             };


            if(  (N == '19')  ) {
            S = 'WRAP';
            GOTO FF;
             };


        };
        FF:
        S = '_SET_'+S+',';
    } else {            /* Заказанное числовое представление установки */
        if(  (PARSE_INT('/T=',MPARM_STR) == 1)  ) {   /* Первая страница меню */

            if(  (N == '1')  ) {
            S = '18,';
            GOTO FF1;
             };


            if(  (N == '2')  ) {
            S = '19,';
            GOTO FF1;
             };


            if(  (N == '3')  ) {
            S = '26,';
            GOTO FF1;
             };


            if(  (N == '4')  ) {
            S = '12,';
            GOTO FF1;
             };


            if(  (N == '5')  ) {
            S = '15,';
            GOTO FF1;
             };


            if(  (N == '6')  ) {
            S = '27,';
            GOTO FF1;
             };


            if(  (N == '7')  ) {
            S = '17,';
            GOTO FF1;
             };


            if(  (N == '8')  ) {
            S = '16,';
            GOTO FF1;
             };


            if(  (N == '9')  ) {
            S = '4,';
            GOTO FF1;
             };


            if(  (N == '10')  ) {
            S = '13,';
            GOTO FF1;
             };


            if(  (N == '11')  ) {
            S = ' 3,';
            GOTO FF1;
             };


            if(  (N == '12')  ) {
            S = ' 7,';
            GOTO FF1;
             };


            if(  (N == '13')  ) {
            S = '11,';
            GOTO FF1;
             };


            if(  (N == '14')  ) {
            S = '33,';
            GOTO FF1;
             };


            if(  (N == '15')  ) {
            S = '34,';
            GOTO FF1;
             };


            if(  (N == '16')  ) {
            S = '20,';
            GOTO FF1;
             };


            if(  (N == '17')  ) {
            S = ' 5,';
            GOTO FF1;
             };


            if(  (N == '18')  ) {
            S = '28,';
            GOTO FF1;
             };


            if(  (N == '19')  ) {
            S = ' 1,';
            GOTO FF1;
             };

        } else {                                      /* Вторая страница меню */
            if(  (N == '1')  ) {
            S = ' 8,';
            GOTO FF1;
             };


            if(  (N == '2')  ) {
            S = '30,';
            GOTO FF1;
             };


            if(  (N == '3')  ) {
            S = '21,';
            GOTO FF1;
             };


            if(  (N == '4')  ) {
            S = '22,';
            GOTO FF1;
             };


            if(  (N == '5')  ) {
            S = ' 2,';
            GOTO FF1;
             };


            if(  (N == '6')  ) {
            S = '29,';
            GOTO FF1;
             };


            if(  (N == '7')  ) {
            S = '31,';
            GOTO FF1;
             };


            if(  (N == '8')  ) {
            S = '25,';
            GOTO FF1;
             };


            if(  (N == '9')  ) {
            S = '37,';
            GOTO FF1;
             };


            if(  (N == '10')  ) {
            S = '36,';
            GOTO FF1;
             };


            if(  (N == '11')  ) {
            S = ' 6,';
            GOTO FF1;
             };


            if(  (N == '12')  ) {
            S = '23,';
            GOTO FF1;
             };


            if(  (N == '13')  ) {
            S = '24,';
            GOTO FF1;
             };


            if(  (N == '14')  ) {
            S = '32,';
            GOTO FF1;
             };


            if(  (N == '15')  ) {
            S = '38,';
            GOTO FF1;
             };


            if(  (N == '16')  ) {
            S = ' 9,';
            GOTO FF1;
             };


            if(  (N == '17')  ) {
            S = '14,';
            GOTO FF1;
             };


            if(  (N == '18')  ) {
            S = '10,';
            GOTO FF1;
             };


            if(  (N == '19')  ) {
            S = '35,';
            GOTO FF1;
             };

        };

    };
    FF1:             /* Ну, а теперь непосредственный ввод в текст */
    RM('CLIPPER^TEXT_COMMANDS3 /S='+S);
    FINISH:
};


         /* Макрос работы со словарем пользовательских функций */

macro clip_userwork from edit trans {
  str dict, txt;
  int fileptr, dos_err, amount;
  dict = ME_PATH + 'clip_uf.db';    /* Файл-список пользовательских словарей
                                     * должен располагаться в каталоге
                                     * Multi-Edit (к слову, в следующей
                                     * версии я собираюсь выделить все
                                     * файлы CLIPPER-MACRO в отдельный
                                     * каталог \CLIP; их становится
                                     * слишком много */
  if( not(file_exists( dict ))) {   /* Если такой файл отсутствует,
                                     * мы предлагаем создать его
                                     * и создаем... */
    beep;
    rm('userin^verify /H=CLIPPER^USER%CLIP_USERWORK/T=Создать новый файл-список CLIP_UF.DB?/S=0/BL=Не найден список пользовательских словарей!');
    if( return_int ) {
      dos_err = s_create_file( dict, fileptr );
      if( dos_err != 0 ) {
        rm('meerror^messagebox /T=ВНИМАНИЕ!/M=Файл создать невозможно! Ошибка DOS: ' + Str(dos_err) + '/B=3');
        goto fin;
      }
      txt = '/T=Маршрут + имя файла-словаря:/L=1/C=1/W=49/ML=130/H=CLIPPER^USER%CLIP_USERWORK/DBF=NAME' +
            Char(13) + '/T=Комментарий:/L=2/C=1/W=25/ML=25/H=CLIPPER^USER%CLIP_USERWORK/DBF=COMM' +
            Char(13) + '****START****' + Char(13);
      dos_err = s_write_bytes( txt, fileptr, amount );
      if( (dos_err != 0) | (svl(txt) != amount) ) {
        beep;
        rm('meerror^messagebox /T=ВНИМАНИЕ!  /M=Ошибка создания файла (ошибка DOS: ' + Str(dos_err) + ')');
        dos_err = s_close_file( fileptr );
        del_file( dict );
        goto fin;
      }
      dos_err = s_close_file( fileptr );
    } else {
      goto fin;
    }
  }                  /* Далее прелагаем выбрать из списка файл-словарь
                      * пользовательских функций. Макрос CLIP1^CHFILE,
                      * передаваемый в USERIN^DB, создает новый
                      * файл, если пользователь определяет новый,
                      * не существовавший ранее словарь */
  txt = '/H=CLIPPER^USER%CLIP_USERWORK';
  rm('userin^db /X=2/Y=3/F=' + dict + '/LT=Выберите словарь/DT=Файл пользовательских функций/LO=1/GLO=clip_usch/NC=1/SPR=1/ABT=Choose/CBT=Cancel/NDF=0' + txt + '/MACRO=CLIP1^CHFILE');
  check_key;         /* Определить отказ от работы (ESC или F10) */
  if( (key1 == 0) && (key2 == 68) ) {
      GOTO FIN;
  };
  if( (key1 == 27) && (key2 == 1) ) {
      GOTO FIN;
  };
                     /* Выделяем имя файла-словаря */
  dict = parse_str('|127NAME=',global_str('clip_usch'));
  if( svl(dict) == 0 ) {
      GOTO FIN;
  };
  if( length(get_extension(dict)) == 0 ) {
      dict = remove_space(dict) + '.UF';
  };
  if( file_exists( dict ) == 0) {
    rm('meerror^messagebox /T=ВНИМАНИЕ!/M=Файл ' + dict + ' не найден!/B=3');
    goto fin;
  }
  if( length( parse_str( '/FROM=', mparm_str ) ) > 0 ) {    /* Макрос был
                                        * вызван из CLIP_USERFUNC, CLIP_NEWWORD
                                        * или CLIP_USERNEW, необходимо
                                        * просто вернуть имя выбранного
                                        * словаря */
    return_str = dict;
    return_int = 1;
    goto allfin;
  }
  if(length(get_path(dict)) == 0) {
    dict = fexpand(dict);
  }
         /* Снова вызываем USERIN^DB для работы с выбранным файлом-словарем */
  rm('userin^db /X=2/Y=3/F=' + dict + '/LT=' + truncate_path(dict) + '/DT=Определения функции/LO=1/GLO=clip_usch/NDF=0/SRP=1/H=CLIPPER^USER%CLIP_USERWORK');
  fin:
  return_int = 0;
  allfin:
}


                     /* Макрос CLIP1^CHFILE,
                      * вызываемый из CLIP1^CLIP_USERWORK, создает новый
                      * файл, если пользователь определяет новый,
                      * не существовавший ранее словарь */

macro CHFILE trans {
  str dict, txt;
  int fileptr, dos_err, amount;
  if( parse_int('/P=', mparm_str) ) {     /* USERIN^DB вызвал макрос при
                                           * выходе из окна редактирования
                                           * данных */
                  /* Выделяем редактировавшееся имя файла-словаря */
    dict = parse_str('|127NAME=', global_str('clip_usch'));
    if( svl(dict) == 0 ) {
      goto fin;
    }
    if( length(get_extension(dict)) == 0 ) {
        dict = remove_space(dict) + '.UF';
    };
    if( not(file_exists( dict ))) {    /* Файл отсутствует, надо создать */
        make_message('Создаем файл ' + dict);
        dos_err = s_create_file( dict, fileptr );
        if( dos_err != 0 ) {
          rm('meerror^messagebox /T=ВНИМАНИЕ!/M=Файл' + truncate_path(dict) + ' создать невозможно! Ошибка DOS: ' + Str(dos_err) + '/B=3');
          goto fin;
        }
        txt = '@DISPLAY_STRING=TEXT=23KEY=5' + char(13);
        dos_err = s_write_bytes( txt, fileptr, amount );
        if( (dos_err != 0) | (svl(txt) != amount) ) {
          goto d_err;
        }
        txt = '/C=1/L=1/W=5/H=CLIPPER^USER%* Ключ/T=Ключ:      /DBF=KEY' + char(13);
        dos_err = s_write_bytes( txt, fileptr, amount );
        if( (dos_err != 0) | (svl(txt) != amount) ) {
          goto d_err;
        }
        txt = '/C=1/L=2/W=20/H=CLIPPER^USER%* Строка/T=Строка:    /DBF=TEXT' + char(13);
        dos_err = s_write_bytes( txt, fileptr, amount );
        if( (dos_err != 0) | (svl(txt) != amount) ) {
          goto d_err;
        }
        txt = '/C=1/L=3/W=1/H=CLIPPER^USER%* Тип/T=Тип (0-5): /TP=1/MIN=0/MAX=5/DBF=TYPE' + char(13);
        dos_err = s_write_bytes( txt, fileptr, amount );
        if( (dos_err != 0) | (svl(txt) != amount) ) {
          goto d_err;
        }
        txt = '****START****' + char(13);
        dos_err = s_write_bytes( txt, fileptr, amount );
        if( (dos_err != 0) | (svl(txt) != amount) ) {
          goto d_err;
        }
        dos_err = s_close_file( fileptr );
        goto fin;
    }
  }
  goto fin;
  d_err:
    beep;
    rm('meerror^messagebox /T=ВНИМАНИЕ! /M=Ошибка создания файла' + truncate_path(dict) + ' (ошибка DOS: ' + Str(dos_err) + ')');
    dos_err = s_close_file( fileptr );
    del_file( dict );
  fin:
}



                        /* Макрос вывода макроподстановок, определенных
                         * в словаре пользовательских функций.
                         * Получает один параметр /LIB - имя
                         * файла-словаря функций */

macro clip_userfunc from edit trans {
    int REZ, NN, NN1;
    str WWORD, WRD, compyte, lib;
    REZ = INSERT_MODE;
    INSERT_MODE = TRUE;
    lib = parse_str('/LIB=', mparm_str);    /* Имя файла-словаря */
    if(  (svl(lib) == 0)  ) {
        beep;
        make_message('Словарь пользовательских функций не указан!');
        rm('clip_userwork /FROM=UF');        /* Если файл не указан
                                     * (может произойти такая накладка
                                     * при невнимательном ручном определении
                                     * макроса в CLIPMAP), предлагаем выбрать
                                     * словарь из списка, для чего вызываем
                                     * макрос CLIP_USERWORK. Параметр /FROM
                                     * указывает, что макрос вызван именно
                                              * отсюда */
        if(  (return_int == 0)  ) {    /* Словарь выбран не был */
            GOTO FIN;
        };
        lib = return_str;              /* Иначе - имя словаря в RETURN_STR */
    };
    if( length(get_extension(lib)) == 0 ) {
        lib = remove_space(lib) + '.UF';
    };
    if(length(get_path(lib)) == 0) {
      lib = fexpand(lib);
    }
    PUSH_UNDO;
    WORD_LEFT;
    WRD = GET_WORD(' !#$&.,{}[]=-+<>/\*:;%^()"'+char(39));  /* Считываем
                                                * введенную аббревиатуру */
    WORD_LEFT;
    RM('DELWORD');                              /* ... и удаляем ее */
    WWORD = CAPS(WRD);                          /* Если аббревиатура была
                                                 * введена в верхнем регистре,
                                                 * вывод макроподстановки
                                                 * также будет в верхнем
                                                 * регистре */
    if(  (WWORD == WRD)  ) {
        SET_GLOBAL_INT('CLIP_CAPS',TRUE);
    } else {
        SET_GLOBAL_INT('CLIP_CAPS',FALSE);
    };
    if(  (XPOS('?',WWORD,1) > 0)  ) {     /* Если задать в аббревиатуре
                                           * знак вопроса, на экран будет
                                           * выведено содержимое всего
                                           * словаря (метка SEE) */
SEE:
        rm('userin^db /X=2/Y=3/F=' + lib + '/LT=' + truncate_path( lib ) + '/DT=Определения функции/LO=1/GLO=clip_usch/NC=1/NDF=1/SRP=1/ABT=Choose/CBT=Cancel/H=CLIPPER^USER%CLIP_USERWORK');
        check_key;             /* Определить отказ от работы (ESC или F10) */
        if( (key1 == 0) && (key2 == 68) ) {
            pop_undo;
            undo;
            GOTO FIN;
        };
        if( (key1 == 27) && (key2 == 1) ) {
            pop_undo;
            undo;
            GOTO FIN;
        };                     /* Выделяем выбранную макроподстановку */
        wword = parse_str('|127TEXT=',global_str('clip_usch'));
        goto more;
    } else {                   /* Стандартный режим: ищем запись в словаре
                                * по аббревиатуре */
        rm('mesys^get_db_record /F=' + lib + '/NDF=1/FV=' + wword + '/GLO=clip_usch/DBF=KEY');
        if ( return_int != 1) {     /* Если не нашли, возвращаемся
                                     * к метке SEE для вывода на экран
                                     * содержимого всего словаря */
            beep;
            make_message('Вхождение не обнаружено! Уточните:');
            goto SEE;
        };
                                    /* Выделяем найденную макроподстановку */
        wword = parse_str('|127TEXT=',global_str('clip_usch'));
    };
MORE:                               /* Тип макроподстановки: от этого
                                     * будет зависеть, какой макрос
                                     * из серии CLIPPER^TEXT_COMMANDSx
                                     * вызвать для вывода в текст */
    compyte = parse_str('|127TYPE=',global_str('clip_usch'));
    if(  (length(remove_space(compyte)) > 0)  ) {
                                    /* И вызываем соответствующий
                                     * CLIPPER^TEXT_COMMANDSx */
      RM('CLIPPER^TEXT_COMMANDS' + compyte + ' /S=' + WWORD);
    };
pop_undo;
FIN:
insert_mode = rez;
};


               /* Макрос смены словаря пользовательских функций или
                  присвоения его новой клавише */

macro clip_usernew from edit trans {
    str dict;
    rm('clip_userwork /FROM=UF');   /* Предлагаем выбрать
                                     * словарь из списка, для чего вызываем
                                     * макрос CLIP_USERWORK. Параметр /FROM
                                     * указывает, что макрос вызван именно
                                              * отсюда */
    if(  (return_int == 0)  ) {     /* Отказ от выбора */
        GOTO FIN;
    };
    dict = return_str;              /* Иначе - имя словаря в RETURN_STR */
    RM('KEYMAC^KEYMAC_K_PROMPT /T=Какой клавише назначить словарь?');
    check_key;
    if( (key1 == 27) && (key2 == 1) ) {  /* ESCAPE - отказ от назначения */
        GOTO FIN;
    };
                                         /* В RETURN_INT - код выбранной
                                          * клавиши, возвращенный из
                                          * KEYMAC^KEYMAC_K_PROMPT */
    macro_to_key( return_int, 'CLIP1^CLIP_USERFUNC /LIB=' + dict, EDIT);
                           /* Вызываем SETUP^MAKEKEY для получения
                            * текстового представления выбранной
                            * клавиши */
    RM('SETUP^MAKEKEY /K1='+Str(key1)+'/K2='+Str(key2));
    make_message(return_str + ' ' + truncate_path(dict));
FIN:
};


                  /* Добавление нового определения в словарь
                   * пользовательских функций */

macro CLIP_NEWWORD from edit trans {
   str w,delims = ' !$&*|124.,{}[]<>/\*:;%^"=-+'+char(39),
       old_del = word_delimits,dict_file;
   int w_id = window_id,i_case = ignore_case,is = 0;
   ignore_case = TRUE;
   word_delimits = delims;
   word_left;
   while ( xpos(cur_char,delims,1) ) right;
   w = get_word(delims);      /* Считываем текущее слово */
   refresh = FALSE;
   word_delimits = old_del;
   rm('clip_userwork /FROM=UF');   /* Предлагаем выбрать
                                    * словарь из списка, для чего вызываем
                                    * макрос CLIP_USERWORK. Параметр /FROM
                                    * указывает, что макрос вызван именно
                                             * отсюда */
   if(  (return_int == 0)  ) {     /* Отказ от выбора */
      GOTO FIN;
   };
   dict_file = return_str;         /* Иначе - имя словаря в RETURN_STR */
   if (get_extension(dict_file) == '') dict_file = dict_file + '.UF';
   if (get_path(dict_file) == '') dict_file = dir_path + '\' + dict_file;
                   /* Проверяем, не загружен ли уже словарь в редактор */
   if ( not(switch_file(dict_file)) ) {
                   /* И если нет,- загружаем */
      create_window;
      if (error_level) {
         rm('meerror^messagebox /B=3/T=ВНИМАНИЕ!/M=Невозможно создать окно для ' +
            truncate_path(dict_file) + '!');
         error_level = 0;
         goto fin;
      }
      window_attr = 64;    /* Скрытое окно */
      load_file(dict_file);
      if (error_level) {
         rm('meerror^messagebox /B=3/T=ОШИБКА!/M=Невозможно загрузить файл ' +
            truncate_path(dict_file) + '!');
         delete_window;
         error_level = 0;
         goto fin;
      }
   }
   tof;           /* Проверяем: может быть определяемая макроподстановка
                   * уже есть в словаре? */
   if (search_fwd(char(127)+'TEXT='+w,0)) {
                  /* Если и вправду есть: */
      rm('userin^verify /BL=Данное определение уже есть в словаре!/T=Вы собираетесь его переопределить?');
      if ( return_int ) is = TRUE;
      else goto fin;
   }
                  /* Формируем строки параметров для USERIN^DATA_IN */
   set_global_str('clip_nwiparm_1','/C=1/L=1/W=5/H=CLIPPER^USER%* Ключ/T=Ключ:      ');
   if (is) set_global_str('clip_nwistr_1',parse_str(char(127)+'KEY=',get_line));
   set_global_str('clip_nwiparm_2','/C=1/L=2/W=20/H=CLIPPER^USER%* Строка/T=Строка:    ');
   set_global_str('clip_nwistr_2',w);
   set_global_str('clip_nwiparm_3','/C=1/L=3/W=1/H=CLIPPER^USER%* Тип/T=Тип (0-5): /TP=1/MIN=0/MAX=5');
   if (is) set_global_int('clip_nwiint_3',parse_int(char(127)+'TYPE=',get_line));
                  /* И вызываем USERIN^DATA_IN для определения остальных
                   * параметров макроподстановки */
   rm('userin^data_in /#=3/PRE=clip_nw/T=Определите параметры');
   if ( return_int ) {
      if ( is ) del_line;     /* Если эта макроподстановка уже была
                               * в словаре, удаляем прежнюю строку */
      eof;                    /* И вводим в конец файла новую строку параметров
                               * макроподстановки в формате DB */
      eol;
      if (c_col > 1) cr;
      text(char(127)+'KEY='+global_str('clip_nwistr_1')+
           char(127)+'TEXT='+global_str('clip_nwistr_2')+
           char(127)+'TYPE='+str(global_int('clip_nwiint_3')));
      cr;
      make_message('Определение "' + global_str('clip_nwistr_2') + '" добавлено в словарь ' + truncate_path(dict_file));
   }
FIN:
   set_global_str('clip_nwistr_1','');      /* Очищаем использовавшиеся
                                             * глобальные строки */
   set_global_str('clip_nwistr_2','');
   set_global_int('clip_nwiint_3',0);
   switch_win_id(w_id);
   ignore_case = i_case;
   refresh = TRUE;
}

/* ****************************************************************** */

/* И ВСЕ ?!
      ВСЕ !
         ВСЕ !!!

            Георгий Жердев
            24.06.93
 */

