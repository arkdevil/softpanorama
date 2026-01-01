/* **********************************************************************

ФАЙЛ: CLIPPER.S
НАЗНАЧЕНИЕ: Исходный файл макросов системы поддержки программирования
            на языке CLIPPER в среде редактора Multi-Edit 
            CLIPPER-MACRO 2.1
АВТОР: Георгий ЖЕРДЕВ, 672005. г.Чита-5, ул.Рахова, 98, кв.49
ДАТА: 20.06.93
ПРИМЕЧАНИЯ: Требуемая версия Multi-Edit - 6.x. Компилировать с помощью
            CMAC.EXE версии 6.x.

************************************************************************* */


macro_file CLIPPER;

/*    Макросы:
      ON              Инициализация системы при загрузке *.prg-файла
      OFF             Выгрузка системы; восстановление первоначальных
                      назначений макро-клавиш
      CLIMTCH         Макрос проверки завершения циклов
      CLI_IND         Макрос обработки автоотступа при переходе на новую строку
      CLIP_COMMANDS   Ввод макроподстановок стандартных CLIPPER-функций
      CLIP_FUNCTIONS  Ввод макроподстановок стандартных CLIPPER-команд
      CLIP_DBFUNC     Ввод макроподстановок CLIPPER-функций обработки
                      баз данных (DB????????())
      CLIP_CLASSES    Ввод макроподстановок имен методов и переменных
                      CLIPPER-классов
      FORNEXT         Макрос ввода структуры FOR-NEXT
      DOWHILE         Макрос ввода структуры DO-WHILE
      DOCASE          Макрос ввода структуры DO CASE - CASE - ENDCASE
      IFENDIF         Макрос ввода структуры IF-ENDIF
      IFELSEENDIF     Макрос ввода структуры IF-ELSE-ENDIF
      CASE            Макрос ввода оператора CASE
      OTHERWISE       Макрос ввода оператора OTHERWISE
      ELSE            Макрос ввода оператора ELSE
      ELSEIF          Макрос ввода оператора ELSEIF
      RECOVER         Макрос ввода оператора RECOVER
      RECOVER_U       Макрос ввода оператора RECOVER USING
      TEXT_COMMANDS0  Макрос ввода макроподстановки типа 0
                      (см. CLIPPER.HLP-Пользовательские функции-Типы вывода
                      мнемонических имен)
      TEXT_COMMANDS1  Макрос ввода макроподстановки типа 1 (см. там же)
      TEXT_COMMANDS2  Макрос ввода макроподстановки типа 2 (см. там же)
      TEXT_COMMANDS3  Макрос ввода макроподстановки типа 3 (см. там же)
      TEXT_COMMANDS4  Макрос ввода макроподстановки типа 4 (см. там же)
      TEXT_COMMANDS5  Макрос ввода макроподстановки типа 5 (см. там же)
      CLIP_TWOBRANCH  Макрос ввода парных круглых скобок ()
      CLIP_TWOSQUOTES Макрос ввода парных одинарных кавычек
      CLIP_TWODQUOTES Макрос ввода парных двойных кавычек
      CLIP_TWOBRACKET Макрос ввода парных квадратных скобок []
      CLIP_TWOCURL    Макрос ввода парных фигурных скобок {}
      CLIP_SBRANCH    Макрос ввода одиночных открывающих круглых скобок (
      CLIP_SSQUOTES   Макрос ввода одиночных одинарных кавычек
      CLIP_SDQUOTES   Макрос ввода одиночных двойных кавычек
      CLIP_SBRACKET   Макрос ввода одиночных открывающих  квадратных скобок [
      CLIP_SCURL      Макрос ввода одиночных открывающих  фигурных скобок {
      SHCALA          Вывод на экран разметки столбцов
      CLIP_LOAD       Макрос загрузки файлов по шаблону
      CLIP_MACROLIST  Макрос пользовательского меню
*/


macro CLIMTCH FROM EDIT trans {     /* Макрос проверки завершения циклов.
                                       Осуществляет перевызов макроса
                                       полной проверки цикла/файла
                                       из CLIP2.MAC */
    rm('clip2^cl_op_control');
};


macro ON from edit trans {   /* Инициализация системы при загрузке. Указывается
                                в качестве "Post-load macro" при установке
                                EXTENSION SETUP для файлов с определенным
                                расширением */

  if ( parse_int('/SC=',mparm_str) ) {       /* /SC=1 - Установить макросы
                                                вывода парных скобок/кавычек
                                                и альтернативного вывода
                                                одиночных скобок/кавычек */

      /* Макрос ввода парных скобок/кавычек */

      key_to_window(<(>,'CLIPPER^CLIP_TWOBRANCH');
      key_to_window(<'>,'CLIPPER^CLIP_TWOSQUOTES');
      key_to_window(<">,'CLIPPER^CLIP_TWODQUOTES');
      key_to_window(<[>,'CLIPPER^CLIP_TWOBRACKET');
      key_to_window(<{>,'CLIPPER^CLIP_TWOCURL');

      /* Макрос ввода одиночных открывающих скобок/кавычек */

      key_to_window(<ALT9>,'CLIPPER^CLIP_SBRANCH');
      key_to_window(<ALTSHFT9>,'CLIPPER^CLIP_SBRANCH');
      key_to_window(<ALT'>,'CLIPPER^CLIP_SSQUOTES');
      key_to_window(<ALTSHFT'>,'CLIPPER^CLIP_SDQUOTES');
      key_to_window(<ALT[>,'CLIPPER^CLIP_SBRACKET');
      key_to_window(<ALTSHFT[>,'CLIPPER^CLIP_SCURL');
  }
  if(  (GLOBAL_INT('CLIP_STAY') == 0)  ) {   /* Первый вызов системы в текущем
                                                сеансе работы в ME. Устанавливаем
                                                остальные необходимые параметры */
    Set_global_str('clip_version',parse_str('/V=',mparm_str));
    Set_global_str('clip_user',parse_str('/USR=',mparm_str));
    SET_GLOBAL_STR('OLD_CL_WORDDEL',WORD_DELIMITS);
    SET_GLOBAL_INT('!DBASE_DIALECT',1);
    WORD_DELIMITS = ' :<>!#|124$&*().,{}[]=-+';
    Set_Global_Str('@KEYMAP_NAME@','KN=CLIPMAPFN=CLIPMAP');  /* Переопределяем
                                                                  keymap */
    RM('CLIPMAP');
    SET_GLOBAL_INT('CLIP_STAY',1);     /* Помечаем, что система уже установлена */
    MAKE_MESSAGE('Установлена CLIPPER-MACRO 5.x/6.x/2.1. HELP - для справок');
  } else {
    MAKE_MESSAGE('CLIPPER-MACRO 5.x/6.x/2.1 уже установлена. HELP - для справок');
  };
};


macro OFF from edit trans {    /* Выгрузка системы; восстановление
                                  первоначальных назначений макро-клавиш.
                                  Данный макрос (наряду с макросом
                                  CLIPPER^ON) может быть назначен какой-либо
                                  клавише для оперативного переключения между
                                  двумя keymap -
                                  системы CLIPPER-MACRO и стандартным */

  if(  (GLOBAL_INT('CLIP_STAY') == 0)  ) {      /* А система и не загружена! */
    MAKE_MESSAGE('CLIPPER-MACRO 5.x/6.x/2.1 не установлена.');
    GOTO FINISH;
  };
  SET_GLOBAL_INT('CLIP_STAY',0);    /* Снимаем флаг установки системы */
  WORD_DELIMITS = GLOBAL_STR('OLD_CL_WORDDEL');
    Set_Global_Str('@KEYMAP_NAME@','KN=MYKEYMAPFN=KEYMAP');
    RM('KEYMAP');
    if(  ERROR_LEVEL != 0  ) {
    RM('KEYMAP');
    };
  MAKE_MESSAGE('CLIPPER-MACRO 5.x/6.x/2.1 выгружена.');
    FINISH:
};


macro CLIP_COMMANDS FROM EDIT {     /* Ввод макроподстановок стандартных
                                       CLIPPER-функций */
    PUSH_UNDO;
    int Ins_mode,NN;
    Ins_mode = INSERT_MODE;
    INSERT_MODE = TRUE;
    WORD_LEFT;
    str CAPSWord,InputWord;
            /* Читаем введенное слово-аббревиатуру... */
    InputWord = GET_WORD(' !$&*|124().,{}[]<>/\*:;%^()"=-+'+char(39));
    WORD_LEFT;
    RM('DELWORD');   /* ...и удаляем его */
    CAPSWord = CAPS(InputWord);     /* Переводим в верхний регистр и смотрим: */
    if(  (CAPSWord == InputWord)  ) {     /* Ввод осуществлялся в верхнем регистре */
        SET_GLOBAL_INT('CLIP_CAPS',TRUE);
    } else {
        SET_GLOBAL_INT('CLIP_CAPS',FALSE); /* Ввод осуществлялся в нижнем регистре */
    };
    NN = XPOS('2',CAPSWord,1);   /* Проверяем и заменяем "2" на "@" */
    if(  (NN > 0)  ) {
        CAPSWord = STR_DEL(CAPSWord,NN,1);
        CAPSWord = STR_INS('@',CAPSWord,NN);
    };
    NN = XPOS('3',CAPSWord,1);   /* Проверяем и заменяем "3" на "#" */
    if(  (NN > 0)  ) {
        CAPSWord = STR_DEL(CAPSWord,NN,1);
        CAPSWord = STR_INS('#',CAPSWord,NN);
    };
    if(  (CAPSWord == '@?') | (CAPSWord == '@/')  ) {    /* Имел место запрос
                                                            всех @-команд */
        CAPSWord = '@';
        BACK_SPACE;
    };
    if(  (XPOS('?',CAPSWord,1) > 0)  ) {        /* Если во вводе знак ? -
                                                   перенаправляем в макрос
                                                   подсказки сокращений */
        RM('CLIP1^WORD_HELP /WHERE=COM/S='+CAPSWord);
        GOTO FINISH;
    };

             /* Список для выбора @-команд. После выбора
                подставляем в CAPSWord соответствующую
                аббревиатуру для дальнейшей обработки */

    if(  (CAPSWord == '@')  ) {
        RM ('USERIN^XMENU /X=57/Y=4/B=1/T=1/L=Что именно?/M=@...Say()@ Row(()+...say()@...Get()@...sAy...get()@...Prompt()@...prompt...Message()@...Clear to()@...Box()@...To...()@...to...Double()') ;
        if(  RETURN_INT < 1  ) {
            GOTO FINISH;
        };
        if(  RETURN_INT == 1  ) {
            CAPSWord = CAPSWord + 'S';
        };
        if(  RETURN_INT == 2  ) {
            CAPSWord = CAPSWord + 'R';
        };
        if(  RETURN_INT == 3  ) {
            CAPSWord = CAPSWord + 'G';
        };
        if(  RETURN_INT == 4  ) {
            CAPSWord = CAPSWord + 'SG';
        };
        if(  RETURN_INT == 5  ) {
            CAPSWord = CAPSWord + 'P';
        };
        if(  RETURN_INT == 6  ) {
            CAPSWord = CAPSWord + 'PM';
        };
        if(  RETURN_INT == 7  ) {
            CAPSWord = CAPSWord + 'C';
        };
        if(  RETURN_INT == 8  ) {
            CAPSWord = CAPSWord + 'B';
        };
        if(  RETURN_INT == 9  ) {
            CAPSWord = CAPSWord + 'T';
        };
        if(  RETURN_INT == 10  ) {
            CAPSWord = CAPSWord + 'TD';
        };
    };

      /* А ДАЛЬШЕ - очень длинный и нудный перебор всех возможных вариантов
         сокращений с вызовом соответствующих макросов */

    if(  (CAPSWord == 'F')  ) {
        RM('CLIPPER^FORNEXT');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'TTF')  ) {
        RM('CLIP1^TEXTENDTEXT /S=To File ');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'TTP')  ) {
        RM('CLIP1^TEXTENDTEXT /S=To Print');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'TT')  ) {
        RM('CLIP1^TEXTENDTEXT');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'BEG') | (CAPSWord == 'BS')  ) {
        RM('CLIP1^BEGINENDBEGIN');
        GOTO FINISH;
    };


    if(  (CAPSWord == 'I')  ) {
        RM('CLIPPER^IFENDIF');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'IE')  ) {
        RM('CLIPPER^IFELSEENDIF');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'DW')  ) {
        RM('CLIPPER^DOWHILE');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'DC')  ) {
        RM('CLIPPER^DOCASE');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'C')  ) {
        RM('CLIPPER^CASE');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'O')  ) {
        RM('CLIPPER^OTHERWISE');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'EL')  ) {
        RM('CLIPPER^ELSE');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'EI')  ) {
        RM('CLIPPER^ELSEIF');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'FF')  ) {
        RM('CLIP1^FUNCTION');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'FFF')  ) {
        RM('CLIP1^TITLE /P=FUNCTION');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'PP')  ) {
        RM('CLIP1^PROCEDURE');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'PPP')  ) {
        RM('CLIP1^TITLE /P=PROCEDURE');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'S') | (CAPSWord == 'SET')  ) {
        RM('CLIP1^ALLSETS');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'B')  ) {
        RM('CLIP1^BOX');
        CR;
        GOTO FINISH;
    };

    if(  (CAPSWord == '@B') | (CAPSWord == '2B')  ) {
        RM('CLIP1^saybox');
        GOTO FINISH;
    };

    if(  (CAPSWord == 'AD') | (CAPSWord == 'ADD')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Additive');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CP') | (CAPSWord == 'COP')  ) {
      RM ('USERIN^XMENU /X=47/Y=4/B=1/T=1/L=COPY-Что именно?/M=Copy...to(CLIPPER^CLIPTE%COPY)copy File...to(CLIPPER^CLIPTE%COPY)copy Structure to(CLIPPER^CLIPTE%COPY)copy to...structure Extended(CLIPPER^CLIPTE%COPY)Index(CLIPPER^CLIPTE%COPY)') ;
      if(  RETURN_INT < 1  ) {
         GOTO FINISH;
      };
      if(  RETURN_INT == 1  ) {
         RM('CLIPPER^TEXT_COMMANDS3 /S=Copy To ');
         GOTO FINISH;
      };
      if(  RETURN_INT == 2  ) {
         RM('CLIPPER^TEXT_COMMANDS3 /S=Copy File  To ');
         LEFT;
         LEFT;
         LEFT;
         LEFT;
         GOTO FINISH;
      };
      if(  RETURN_INT == 3  ) {
         RM('CLIPPER^TEXT_COMMANDS3 /S=Copy Structure To ');
         GOTO FINISH;
      };
      if(  RETURN_INT == 4  ) {
         RM('CLIPPER^TEXT_COMMANDS2 /S=Copy To  Structure Extended ');
         RIGHT;
         WORD_RIGHT;
         LEFT;
         GOTO FINISH;
      };
    };

    if(  (CAPSWord == '#C') | (CAPSWord == '#COM')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=#Command ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '#T') | (CAPSWord == '#TR')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=#Translate ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '#XC') | (CAPSWord == '#XCOM')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=#xCommand ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '#XT') | (CAPSWord == '#XTR')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=#xTranslate ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '#D')  | (CAPSWord == '#DEF')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=#Define ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '#E') | (CAPSWord == '#ER') | (CAPSWord == '#ERR')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=#Error ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '#I') | (CAPSWord == '#ID')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=#IfDef ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '#IND')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=#IfNDef ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '#IN') | (CAPSWord == '#INC')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=#Include ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '#U') | (CAPSWord == '#UN') | (CAPSWord == '#UD')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=#Undef ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'G')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Go ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'GT')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Go Top');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'BK')  ) {
      RM('CLIPPER^TEXT_COMMANDS0 /S=Break');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'GB')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Go Bottom');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'EJ')  ) {
      RM('CLIPPER^TEXT_COMMANDS0 /S=Eject');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'COM')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Commit');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'P')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Pack');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CLR')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Color ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'Q')  ) {
      RM('CLIPPER^TEXT_COMMANDS0 /S=Quit');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CA')  ) {
      RM('CLIPPER^TEXT_COMMANDS0 /S=Clear All');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CL') | (CAPSWord == 'CLO')  ) {
      RM ('USERIN^XMENU /X=57/Y=4/B=1/T=1/L=CLOSE-Что именно?/M=All(CLIPPER^CLIPTE%CLOSE)aLternate(CLIPPER^CLIPTE%CLOSE)Databases(CLIPPER^CLIPTE%CLOSE)Format(CLIPPER^CLIPTE%CLOSE)Index(CLIPPER^CLIPTE%CLOSE)') ;
      if(  RETURN_INT < 1  ) {
         GOTO FINISH;
      };
      if(  RETURN_INT == 1  ) {
         RM('CLIPPER^TEXT_COMMANDS0 /S=Close All');
         GOTO FINISH;
      };
      if(  RETURN_INT == 2  ) {
         RM('CLIPPER^TEXT_COMMANDS0 /S=Close Alternate');
         GOTO FINISH;
      };
      if(  RETURN_INT == 3  ) {
         RM('CLIPPER^TEXT_COMMANDS0 /S=Close Databases');
         GOTO FINISH;
      };
      if(  RETURN_INT == 4  ) {
         RM('CLIPPER^TEXT_COMMANDS0 /S=Close Format');
         GOTO FINISH;
      };
      if(  RETURN_INT == 5  ) {
         RM('CLIPPER^TEXT_COMMANDS0 /S=Close Index');
         GOTO FINISH;
      };
    };

    if(  (CAPSWord == 'CLALL') | (CAPSWord == 'CLA')  ) {
         RM('CLIPPER^TEXT_COMMANDS0 /S=Close All');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CLALT')  ) {
         RM('CLIPPER^TEXT_COMMANDS0 /S=Close Alternate');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CLD') | (CAPSWord == 'CLB')  ) {
         RM('CLIPPER^TEXT_COMMANDS0 /S=Close Databases');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CLF')  ) {
         RM('CLIPPER^TEXT_COMMANDS0 /S=Close Format');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CLI') | (CAPSWord == 'CLIN')  ) {
         RM('CLIPPER^TEXT_COMMANDS0 /S=Close Index');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CN') | (CAPSWord == 'CON')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Continue');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'L')  ) {
      RM('CLIPPER^TEXT_COMMANDS0 /S=Loop');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RSS')  ) {
      RM('CLIPPER^TEXT_COMMANDS0 /S=Restore Screen');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SS')  ) {
      RM('CLIPPER^TEXT_COMMANDS0 /S=Save Screen');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'AB')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Append Blank');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CG')  ) {
      RM('CLIPPER^TEXT_COMMANDS0 /S=Clear Gets');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CM')  ) {
      RM('CLIPPER^TEXT_COMMANDS0 /S=Clear Memory');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CS')  ) {
      RM('CLIPPER^TEXT_COMMANDS0 /S=Clear Screen');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CT')  ) {
      RM('CLIPPER^TEXT_COMMANDS0 /S=Clear Typeahead');
      GOTO FINISH;
    };


    if(  (CAPSWord == 'PR') | (CAPSWord == 'PRIV')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Private ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'PB') | (CAPSWord == 'PUB')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Public ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FI')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Find ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'EXT')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=External ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ER')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Erase ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CPS') | (CAPSWord == 'CPST')  ) {
         RM('CLIPPER^TEXT_COMMANDS3 /S=Copy Structure To ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CPF') | (CAPSWord == 'CPFT')  ) {
         RM('CLIPPER^TEXT_COMMANDS1 /S=Copy File  To ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CPT')  ) {
         RM('CLIPPER^TEXT_COMMANDS3 /S=Copy To ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CR')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Create ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'D') | (CAPSWord == 'DEL')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Delete ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DF') | (CAPSWord == 'DELF')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Delete File ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DS') | (CAPSWord == 'DISP')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Display ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'LF') | (CAPSWord == 'LAB')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Label From ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'LC')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Local ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'M') | (CAPSWord == 'MT')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Menu To ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'K')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Keyboard ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'PIC')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Picture ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RSSF') | (CAPSWord == 'RSF')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Restore Screen From ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SL') | (CAPSWord == 'SEL')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Select ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'MEM') | (CAPSWord == 'MV')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Memvar ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'E')  ) {
      RM('CLIPPER^TEXT_COMMANDS0 /S=Exit ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SCL') | (CAPSWord == 'SCOL')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Set Color To ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SF') | (CAPSWord == 'SFT')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Set Function  To ');
      LEFT;
      LEFT;
      LEFT;
      LEFT;
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SKT')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Set Key To ');
      LEFT;
      LEFT;
      LEFT;
      LEFT;
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RO')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=ReadOnly ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SST')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Save Screen To ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'V') | (CAPSWord == 'VAL')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Valid ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'U')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Use ');
      GOTO FINISH;
    };


    if(  (CAPSWord == 'LOC')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Locate  For ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'J')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Join With  To  For ');
      RIGHT;
      WORD_RIGHT;
      LEFT;
      GOTO FINISH;
    };

    if(  (CAPSWord == 'IN') | (CAPSWord == 'INP')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Input '' To ');
      RIGHT;
      GOTO FINISH;
    };

    if(  (CAPSWord == 'IND')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Index On  To ');
      RIGHT;
      WORD_RIGHT;
      LEFT;
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CRF')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Create From ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CPSE') | (CAPSWord == 'CPE')  ) {
         RM('CLIPPER^TEXT_COMMANDS2 /S=Copy To  Structure Extended ');
         RIGHT;
         WORD_RIGHT;
         LEFT;
         GOTO FINISH;
    };

    if(  (CAPSWord == 'DSP') | (CAPSWord == 'DISPP')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Display  To Print');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DSF') | (CAPSWord == 'DISPF')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Display  To File ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'A')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Accept '' To ');
      RIGHT;
      GOTO FINISH;
    };

    if(  (CAPSWord == '@C') | (CAPSWord == '2C')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=@  Clear To ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '@G') | (CAPSWord == '2G')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=@  Get ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '@P') | (CAPSWord == '2P')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=@  Prompt ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '@PM') | (CAPSWord == '2PM')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=@  Prompt  Message ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '@S') | (CAPSWord == '2S')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=@  Say ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '@SG') | (CAPSWord == '2SG')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=@  Say  Get ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '@R') | (CAPSWord == '2R')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=@ Row()+1,  Say ');
      RIGHT;
      WORD_RIGHT;
      LEFT;
      GOTO FINISH;
    };

    if(  (CAPSWord == '@T') | (CAPSWord == '2T')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=@  To ');
      GOTO FINISH;
    };

    if(  (CAPSWord == '@TD') | (CAPSWord == '2TD')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=@  To  Double');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'UU')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Use  Index  Alias  New Via ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'AF')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Append From ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'AV')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Average  To ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'W')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=While ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RD')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Random ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DEF')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Default ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'EXC') | (CAPSWord == 'EP')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Except ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'LK')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Like ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'AL')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Alias ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FL') | (CAPSWord == 'FLD') | (CAPSWord == 'FLDS')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Fields ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ALT')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Alternate ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DB')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Databases ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FOR')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Format ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'EX')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Exclusive ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'R')  ) {
      RM('CLIPPER^TEXT_COMMANDS0 /S=Read');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'REC') | (CAPSWord == 'RR')  ) {
      RM('CLIPPER^RECOVER');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RU')  ) {
      RM('CLIPPER^RECOVER_U');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RC') | (CAPSWord == 'RL') ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Recall ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RI')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=ReIndex');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RN') | (CAPSWord == 'REN')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Rename  To ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RP') | (CAPSWord == 'REP')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Replace  With ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RF')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Report Form ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ST')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Save To ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SK')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Skip ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SE')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Seek ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SO') | (CAPSWord == 'SR') | (CAPSWord == 'SRT')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Sort  On  To ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'T')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Total On  To ');
      RIGHT;
      WORD_RIGHT;
      LEFT;
      GOTO FINISH;
    };

    if(  (CAPSWord == 'UL')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Unlock ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'UD')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Update On  From  Replace  With ');
      RIGHT;
      WORD_RIGHT;
      LEFT;
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RS')  ) {
      RM('CLIPPER^TEXT_COMMANDS0 /S=Read Save');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RL') | (CAPSWord == 'REL')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Release ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RES')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Restore From ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RESA')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Restore From  Additive');
      RIGHT;
      WORD_RIGHT;
      LEFT;
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RT') | (CAPSWord == 'RET')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Return ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SH') | (CAPSWord == 'SHA')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Shared ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'STAT')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=Static ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SUM')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Sum  To ');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'TP')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Type  To Print');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'TF')  ) {
      RM('CLIPPER^TEXT_COMMANDS2 /S=Type  To File ');
      GOTO FINISH;
    };

    TEXT(InputWord);       /* НИЧЕГО НЕ НАШЛИ !!! */
    BEEP;
    make_message('Вхождение не обнаружено');
    FINISH:
    POP_UNDO;
    INSERT_MODE = Ins_mode;
};



macro CLIP_FUNCTIONS FROM EDIT {    /* Ввод макроподстановок стандартных
                                       CLIPPER-команд. По структуре
                                       абсолютно аналогичен CLIP_COMMANDS */
    PUSH_UNDO;
    int Ins_mode;
    Ins_mode = INSERT_MODE;
    INSERT_MODE = TRUE;
    WORD_LEFT;
    str CAPSWord,InputWord;
    InputWord = GET_WORD(' !#|124$&*().,{}[]=-+<>/\*:;%^()"'+char(39));
    WORD_LEFT;
    RM('DELWORD');
    CAPSWord = CAPS(InputWord);
    if(  (CAPSWord == InputWord)  ) {
        SET_GLOBAL_INT('CLIP_CAPS',TRUE);
    } else {
        SET_GLOBAL_INT('CLIP_CAPS',FALSE);
    };
    if(  (XPOS('?',CAPSWord,1) > 0)  ) {
        RM('CLIP1^WORD_HELP /WHERE=FUNC/S='+CAPSWord);
        GOTO FINISH;
    };

    if(  (CAPSWord == 'A') | (CAPSWord == 'ACH')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=AChoice()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'AC') | (CAPSWord == 'ACL')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=AClone()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ACO')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=ACopy()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'AD') | (CAPSWord == 'ADE')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=ADel()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'AE') | (CAPSWord == 'AV')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=AEval()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'AFD') | (CAPSWord == 'AFS') | (CAPSWord == 'AFL')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=AFields()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'AF')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=AFill()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'AL')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Alias()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ALE') | (CAPSWord == 'ALR')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Alert()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'AT') | (CAPSWord == 'ATR')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=AllTrim()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'AR') | (CAPSWord == 'ARR')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Array()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ASC')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=AScan()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'AS') | (CAPSWord == 'ASZ')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=ASize()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ASR') | (CAPSWord == 'ASO')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=ASort()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ATL') | (CAPSWord == 'ATA')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Atail()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'BI')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Bin2I()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'BL')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Bin2L()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'BW')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Bin2W()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'B')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=BoF()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'BK')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Break()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'BR')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Browse()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CD')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=CDoW()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CH')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Chr()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CM')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=CMonth()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'C')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Col()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CT')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=CToD()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CUR') | (CAPSWord == 'CRD') | (CAPSWord == 'CURD')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=CurDir()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DA') | (CAPSWord == 'DT')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Date()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'D')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Day()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DL') | (CAPSWord == 'DEL')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Deleted()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DSC') | (CAPSWord == 'DESC') | (CAPSWord == 'DES')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Descend()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DP') | (CAPSWord == 'DEVP') | (CAPSWord == 'DVP')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DevPos()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DEV')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DevOut()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DIB') | (CAPSWord == 'DBEG')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DispBegin()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DB')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DispBox()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DIE') | (CAPSWord == 'DEND')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DispEnd()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DIO') | (CAPSWord == 'DO')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DispOut()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DIR')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Directory()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DSK') | (CAPSWord == 'DISK')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DiskSpace()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DOS') | (CAPSWord == 'DOSER')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DOSError()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DTC')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DToC()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'DTS')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DToS()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'E')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=EoF()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'EM') | (CAPSWord == 'EMP')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Empty()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'EB') | (CAPSWord == 'ERB')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=ErrorBlock()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'EL') | (CAPSWord == 'ERL')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=ErrorLevel()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'EV')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Eval()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FCL')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FClose()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FCN') | (CAPSWord == 'FCNT')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=FCount()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FCR')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FCreate()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FB') | (CAPSWord == 'FIB')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FieldBlock()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FWB') | (CAPSWord == 'FIWB')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FieldWBlock()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FE') | (CAPSWord == 'FERS')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FErase()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FER') | (CAPSWord == 'FRR') | (CAPSWord == 'FERR')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=FError()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FLD')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Field()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FNM') | (CAPSWord == 'FLDN')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FieldName()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FG') | (CAPSWord == 'FIG')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FieldGet()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FPS') | (CAPSWord == 'FIPS') | (CAPSWord == 'FPOS')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FieldPos()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FP') | (CAPSWord == 'FPT') | (CAPSWord == 'FPUT') | (CAPSWord == 'FIP')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FieldPut()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FL')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=FLock()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FO') | (CAPSWord == 'FOP')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FOpen()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FN') | (CAPSWord == 'FND')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Found()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FR') | (CAPSWord == 'FRD')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FRead()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FRS') | (CAPSWord == 'FRDS')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FReadStr()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FRN')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FRename()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FS') | (CAPSWord == 'FSK')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FSeek()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'FW') | (CAPSWord == 'FWR')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=FWrite()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'G') | (CAPSWord == 'GE')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=GetEnv()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'GA')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=GetActive()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'GAP')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=GetApplyKey()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'GDS') | (CAPSWord == 'GDSK')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=GetDoSetKey()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'GPOSTV') | (CAPSWord == 'GPOST') | (CAPSWord == 'POSTV')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=GetPostValidate()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'GPREV') | (CAPSWord == 'GPRE') | (CAPSWord == 'PREV')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=GetPreValidate()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'GR') | (CAPSWord == 'GETR')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=GetReader()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'H') | (CAPSWord == 'HRD')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=HardCR()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'HD') | (CAPSWord == 'HEAD')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Header()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'I')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=If()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'INE') | (CAPSWord == 'INEX') | (CAPSWord == 'INX')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=IndexExt()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'INK')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=IndexKey()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'INO') | (CAPSWord == 'INOR') | (CAPSWord == 'INORD')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=IndexOrd()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'IN') | (CAPSWord == 'IK')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Inkey()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'IA') | (CAPSWord == 'ISA')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=IsAlpha()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'IC') | (CAPSWord == 'ISC')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=IsColor()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ID') | (CAPSWord == 'ISD')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=IsDigit()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'IL') | (CAPSWord == 'ISL')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=IsLower()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'IP') | (CAPSWord == 'ISP')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=IsPrinter()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'IU') | (CAPSWord == 'ISU')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=IsUpper()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'IB')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=I2Bin()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'LK')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=LastKey()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'LR')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=LastRec()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'L') | (CAPSWord == 'LF')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Left()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'LN')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Len()');
      GOTO FINISH;
    };


    if(  (CAPSWord == 'LW') | (CAPSWord == 'LOW')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Lower()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'LT')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=LTrim()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'LD') | (CAPSWord == 'LUP')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=LUpDate()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'LB')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=L2Bin()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'MX')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Max()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'MC') | (CAPSWord == 'MCOL')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=MaxCol()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'MR') | (CAPSWord == 'MROW')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=MaxRow()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ME')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=MemoEdit()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'MN')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Min()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ML')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=MemoLine()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'MRD') | (CAPSWord == 'MREAD')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=MemoRead()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'MEM')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Memory()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'MT')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=MemoTran()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'MW') | (CAPSWord == 'MWRIT')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=MemoWrit()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'MB') | (CAPSWord == 'MVB')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=MemvarBlock()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'MLC')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=MLCount()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'MLCTP') | (CAPSWord == 'MLCT') | (CAPSWord == 'MLT')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=MLCToPos()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'MPTL') | (CAPSWord == 'MPT') | (CAPSWord == 'MPTLC')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=MPosToLC()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'MP') | (CAPSWord == 'MLP')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=MLPos()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'M')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Month()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'NE')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=NetErr()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'NN')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=NetName()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'NK')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=NextKey()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'NS')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=NoSnow()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'OE') | (CAPSWord == 'OUTE')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=OutErr()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'OS') | (CAPSWord == 'OUTS')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=OutStD()');
      GOTO FINISH;
    };


    if(  (CAPSWord == 'P')  ) {
      RM ('USERIN^XMENU /X=57/Y=4/B=1/T=1/L= PAD - ? /M= padR (CLIPPER^CLIPTE%PAD) padL (CLIPPER^CLIPTE%PAD) padC (CLIPPER^CLIPTE%PAD)') ;
      if(  (RETURN_INT == 1)  ) {
        RM('CLIPPER^TEXT_COMMANDS5 /S=PadR()');
      };
      if(  (RETURN_INT == 2)  ) {
        RM('CLIPPER^TEXT_COMMANDS5 /S=PadL()');
      };
      if(  (RETURN_INT == 3)  ) {
        RM('CLIPPER^TEXT_COMMANDS5 /S=PadC()');
      };
      GOTO FINISH;
    };

    if(  (CAPSWord == 'PC')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=PCol()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'PCN') | (CAPSWord == 'PCNT')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=PCount()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'PL')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=ProcLine()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'PN')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=ProcName()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'PR')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=PRow()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'Q')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=QOut()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'QQ')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=QQOut()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RE')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=ReadExit()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RI')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=ReadInsert()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RK')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=ReadKey()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RM')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=ReadModal()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RV')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=ReadVar()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RC') | (CAPSWord == 'RECC')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=RecCount()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RN') | (CAPSWord == 'RECN')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=RecNo()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RECS') | (CAPSWord == 'RSZ')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=RecSize()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'REP') | (CAPSWord == 'RP') | (CAPSWord == 'RPL')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Replicate()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RS')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=RestScreen()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'R')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Right()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RL')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=RLock()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ROU') | (CAPSWord == 'RND')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Round()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RT')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=RTrim()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SS')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=SaveScreen()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SCR') | (CAPSWord == 'SL')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Scroll()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SEC')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Seconds()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SEL')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Select()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'S')  ) {
      RM('CLIP1^SETFUNC');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SB')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=SetBlink()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SC') | (CAPSWord == 'SCAN')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=SetCancel()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SCL') | (CAPSWord == 'SCOL')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=SetColor()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SCUR')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=SetCursor()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SK') | (CAPSWord == 'SKEY')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=SetKey()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SM')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=SetMode()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SP') | (CAPSWord == 'SPOS')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=SetPos()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SPR') | (CAPSWord == 'SPRC')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=SetPRC()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SND')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Soundex()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SPC') | (CAPSWord == 'SPA')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Space()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SQ')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Sqrt()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ST')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=StrTran()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'STU') | (CAPSWord == 'STF')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Stuff()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SUB')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Substr()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'TM') | (CAPSWord == 'TIM')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Time()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'TN') | (CAPSWord == 'TON')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Tone()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'TR') | (CAPSWord == 'TRANS')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Transform()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'T') | (CAPSWord == 'TP')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Type()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'UD') | (CAPSWord == 'UPD')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Updated()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'U') | (CAPSWord == 'UP')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Upper()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'US')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Used()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'V')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Val()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'VT') | (CAPSWord == 'VTP')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=ValType()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'VR') | (CAPSWord == 'VER')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=Version()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'W')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Word()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'Y')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=Year()');
      GOTO FINISH;
    };

    TEXT(InputWord);
    BEEP;
    make_message('Вхождение не обнаружено');
    FINISH:
    POP_UNDO;
    INSERT_MODE = Ins_mode;
};



macro CLIP_DBFUNC FROM EDIT {    /* Ввод макроподстановок CLIPPER-функций
                                    обработки баз данных (DB????????()).
                                    По структуре абсолютно аналогичен
                                    CLIP_COMMANDS */
    PUSH_UNDO;
    int Ins_mode;
    Ins_mode = INSERT_MODE;
    INSERT_MODE = TRUE;
    WORD_LEFT;
    str CAPSWord,InputWord;
    InputWord = GET_WORD(' !#|124$&*().,{}[]=-+<>/\*:;%^()"'+char(39));
    WORD_LEFT;
    RM('DELWORD');
    CAPSWord = CAPS(InputWord);
    if(  (CAPSWord == InputWord)  ) {
        SET_GLOBAL_INT('CLIP_CAPS',TRUE);
    } else {
        SET_GLOBAL_INT('CLIP_CAPS',FALSE);
    };
    if(  (XPOS('?',CAPSWord,1) > 0)  ) {
        RM('CLIP1^WORD_HELP /WHERE=DB/S='+CAPSWord);
        GOTO FINISH;
    };

    if(  (CAPSWord == 'A') | (CAPSWord == 'AP') | (CAPSWord == 'APP')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBAppend()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CF') | (CAPSWord == 'CLF')   ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBClearFilter()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CI') | (CAPSWord == 'CLI')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBClearIndex()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CR') | (CAPSWord == 'CLR')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBClearRelation()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CAL') | (CAPSWord == 'CLA')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=DBCloseAll()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'CL') | (CAPSWord == 'CAR') | (CAPSWord == 'CA') | (CAPSWord == 'CLO')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBCloseArea()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'C') | (CAPSWord == 'COM') | (CAPSWord == 'COMM')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBCommit()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'COMA')  ) {
      RM('CLIPPER^TEXT_COMMANDS1 /S=DBCommitAll()');
      GOTO FINISH;
    };

    if(   (CAPSWord == 'CREA') | (CAPSWord == 'CR')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBCreate()');
      GOTO FINISH;
    };

    if(   (CAPSWord == 'CRI')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBCreateIndex()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'D')| (CAPSWord == 'DEL')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBDelete()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ED')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBEdit()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'E') | (CAPSWord == 'EV')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBEval()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'F') | (CAPSWord == 'FIL') | (CAPSWord == 'FILT')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBFilter()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'GB') | (CAPSWord == 'BOT') | (CAPSWord == 'GBOT')   ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBGoBottom()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'G') | (CAPSWord == 'TO') | (CAPSWord == 'GTO') | (CAPSWord == 'T')   ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBGoTo()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'GT') | (CAPSWord == 'TOP') | (CAPSWord == 'GTOP')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBGoTop()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'REC') | (CAPSWord == 'R') | (CAPSWord == 'RC')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBRecall()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RI') | (CAPSWord == 'REI') | (CAPSWord == 'REIND') | (CAPSWord == 'RIND')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBReindex()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'REL') | (CAPSWord == 'RL')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBRelation()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SE')   ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBSeek()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SEL') | (CAPSWord == 'SL') | (CAPSWord == 'S')   ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBSelectArea()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'RSEL') | (CAPSWord == 'RSL')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBRSelect()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SETF') | (CAPSWord == 'SF') | (CAPSWord == 'SFILT')   ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBSetFilter()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SETI') | (CAPSWord == 'SI') | (CAPSWord == 'SIND')   ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBSetIndex()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SETO') | (CAPSWord == 'SO') | (CAPSWord == 'SORD')   ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBSetOrder()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SETR') | (CAPSWord == 'SR') | (CAPSWord == 'SREL')   ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBSetRelation()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'SK')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBSkip()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'ST') | (CAPSWord == 'STR') | (CAPSWord == 'STRU')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBStruct()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'UNL') | (CAPSWord == 'UL')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBUnLock()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'UNLA') | (CAPSWord == 'ULA')  ) {
      RM('CLIPPER^TEXT_COMMANDS3 /S=DBUnLockAll()');
      GOTO FINISH;
    };

    if(  (CAPSWord == 'U') | (CAPSWord == 'UA') | (CAPSWord == 'USA')  ) {
      RM('CLIPPER^TEXT_COMMANDS5 /S=DBUseArea()');
      GOTO FINISH;
    };


    TEXT(InputWord);
    BEEP;
    make_message('Вхождение не обнаружено');
    FINISH:
    POP_UNDO;
    INSERT_MODE = Ins_mode;
};


macro CLIP_classes FROM EDIT {      /* Ввод макроподстановок имен методов
                                       и переменных CLIPPER-классов.
                                       По структуре абсолютно аналогичен
                                       CLIP_COMMANDS */
    PUSH_UNDO;
    int Ins_mode;
    Ins_mode = INSERT_MODE;
    INSERT_MODE = TRUE;
    WORD_LEFT;
    str CAPSWord,InputWord;
    InputWord = GET_WORD(' !#|124$&*().,{}[]=-+<>/\*:;%^()"'+char(39));
    WORD_LEFT;
    RM('DELWORD');
    CAPSWord = CAPS(InputWord);
    if(  (CAPSWord == InputWord)  ) {
        SET_GLOBAL_INT('CLIP_CAPS',TRUE);
    } else {
        SET_GLOBAL_INT('CLIP_CAPS',FALSE);
    };
    if(  (XPOS('?',CAPSWord,1) > 0)  ) {
        RM('CLIP1^WORD_HELP /WHERE=CLASS/S='+CAPSWord);
        GOTO FINISH;
    };

if(  (CAPSWord == 'AC') | (CAPSWord == 'ADC')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=AddColumn()');
GOTO FINISH;
};
if(  (CAPSWord == 'A')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Args');
GOTO FINISH;
};
if(  (CAPSWord == 'AS') | (CAPSWord == 'ASS')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Assign()');
GOTO FINISH;
};
if(  (CAPSWord == 'AL') | (CAPSWord == 'AU')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=AutoLite');
GOTO FINISH;
};
if(  (CAPSWord == 'BS')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=BackSpace()');
GOTO FINISH;
};
if(  (CAPSWord == 'BD')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=BadDate');
GOTO FINISH;
};
if(  (CAPSWord == 'B') | (CAPSWord == 'BL')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Block');
GOTO FINISH;
};
if(  (CAPSWord == 'BU') | (CAPSWord == 'BUF')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Buffer');
GOTO FINISH;
};
if(  (CAPSWord == 'CD') | (CAPSWord == 'CAND')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=CanDefault');
GOTO FINISH;
};
if(  (CAPSWord == 'CR') | (CAPSWord == 'CANR')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=CanRetry');
GOTO FINISH;
};
if(  (CAPSWord == 'CS') | (CAPSWord == 'CANS')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=CanSubstitute');
GOTO FINISH;
};
if(  (CAPSWord == 'CA') | (CAPSWord == 'CAR')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Cargo');
GOTO FINISH;
};
if(  (CAPSWord == 'CH')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Changed');
GOTO FINISH;
};
if(  (CAPSWord == 'C')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Col');
GOTO FINISH;
};
if(  (CAPSWord == 'CC') | (CAPSWord == 'COLC')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=ColCount');
GOTO FINISH;
};
if(  (CAPSWord == 'CB') | (CAPSWord == 'CLB')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=ColorBlock');
GOTO FINISH;
};
if(  (CAPSWord == 'CLD') | (CAPSWord == 'CDIS') | (CAPSWord == 'CDISP') | (CAPSWord == 'CDS')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=ColorDisp()');
GOTO FINISH;
};
if(  (CAPSWord == 'CLR') | (CAPSWord == 'CREC')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=ColorRect()');
GOTO FINISH;
};
if(  (CAPSWord == 'CLS') | (CAPSWord == 'CSPEC')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=ColorSpec');
GOTO FINISH;
};
if(  (CAPSWord == 'CP')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=ColPos');
GOTO FINISH;
};
if(  (CAPSWord == 'COLS') | (CAPSWord == 'CSP') | (CAPSWord == 'CSEP')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=ColSep');
GOTO FINISH;
};
if(  (CAPSWord == 'CW') | (CAPSWord == 'COLW')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=ColWidth()');
GOTO FINISH;
};
if(  (CAPSWord == 'CON') | (CAPSWord == 'CONF') | (CAPSWord == 'CNF')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Configure()');
GOTO FINISH;
};
if(  (CAPSWord == 'DP') | (CAPSWord == 'DECP') | (CAPSWord == 'DPOS')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=DecPos');
GOTO FINISH;
};
if(  (CAPSWord == 'DC') | (CAPSWord == 'DEFC') | (CAPSWord == 'DCOL') | (CAPSWord == 'DCLR')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=DefColor');
GOTO FINISH;
};
if(  (CAPSWord == 'DH') | (CAPSWord == 'DHIL')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=DeHilite()');
GOTO FINISH;
};
if(  (CAPSWord == 'DELC')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=DelColumn()');
GOTO FINISH;
};
if(  (CAPSWord == 'DELL') | (CAPSWord == 'DEL') | (CAPSWord == 'DL')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=DelLeft()');
GOTO FINISH;
};
if(  (CAPSWord == 'DELR') | (CAPSWord == 'DR')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=DelRight()');
GOTO FINISH;
};
if(  (CAPSWord == 'DWL') | (CAPSWord == 'DELWL')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=DelWordLeft()');
GOTO FINISH;
};
if(  (CAPSWord == 'DWR') | (CAPSWord == 'DELWR')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=DelWordRight()');
GOTO FINISH;
};
if(  (CAPSWord == 'DES') | (CAPSWord == 'DESCR') | (CAPSWord == 'DS')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Description');
GOTO FINISH;
};
if(  (CAPSWord == 'DISP') | (CAPSWord == 'DSP')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Display()');
GOTO FINISH;
};
if(  (CAPSWord == 'D') | (CAPSWord == 'DN')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Down()');
GOTO FINISH;
};
if(  (CAPSWord == 'E')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=End()');
GOTO FINISH;
};
if(  (CAPSWord == 'ERN') | (CAPSWord == 'EN')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=ErrorNew()');
GOTO FINISH;
};
if(  (CAPSWord == 'ES') | (CAPSWord == 'EXS')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=ExitState');
GOTO FINISH;
};
if(  (CAPSWord == 'FN') | (CAPSWord == 'FLN')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Filename');
GOTO FINISH;
};
if(  (CAPSWord == 'F') | (CAPSWord == 'FT') | (CAPSWord == 'FOOT')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Footing');
GOTO FINISH;
};
if(  (CAPSWord == 'FS') | (CAPSWord == 'FSEP')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=FootSep');
GOTO FINISH;
};
if(  (CAPSWord == 'FR') | (CAPSWord == 'FRZ')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Freeze');
GOTO FINISH;
};
if(  (CAPSWord == 'GENC')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=GenCode');
GOTO FINISH;
};
if(  (CAPSWord == 'GC') | (CAPSWord == 'GETC')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=GetColumn()');
GOTO FINISH;
};
if(  (CAPSWord == 'GN') | (CAPSWord == 'GETN')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=GetNew()');
GOTO FINISH;
};
if(  (CAPSWord == 'GB') | (CAPSWord == 'GOB')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=GoBottom()');
GOTO FINISH;
};
if(  (CAPSWord == 'GBB')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=GoBottomBlock');
GOTO FINISH;
};
if(  (CAPSWord == 'GT') | (CAPSWord == 'GOT')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=GoTop()');
GOTO FINISH;
};
if(  (CAPSWord == 'GTB')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=GoTopBlock');
GOTO FINISH;
};
if(  (CAPSWord == 'HF') | (CAPSWord == 'HASF') | (CAPSWord == 'HFOC')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=HasFocus');
GOTO FINISH;
};
if(  (CAPSWord == 'HD') | (CAPSWord == 'HEAD')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Heading');
GOTO FINISH;
};
if(  (CAPSWord == 'HS') | (CAPSWord == 'HSEP')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=HeadSep');
GOTO FINISH;
};
if(  (CAPSWord == 'HIL')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Hilite()');
GOTO FINISH;
};
if(  (CAPSWord == 'HB') | (CAPSWord == 'HITB')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=HitBottom');
GOTO FINISH;
};
if(  (CAPSWord == 'HT') | (CAPSWord == 'HITT')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=HitTop');
GOTO FINISH;
};
if(  (CAPSWord == 'H') | (CAPSWord == 'HM')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Home()');
GOTO FINISH;
};
if(  (CAPSWord == 'IC') | (CAPSWord == 'ICOL') | (CAPSWord == 'INSC')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=InsColumn()');
GOTO FINISH;
};
if(  (CAPSWord == 'I') | (CAPSWord == 'INS')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=Insert()');
GOTO FINISH;
};
if(  (CAPSWord == 'ID')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Invalidate()');
GOTO FINISH;
};
if(  (CAPSWord == 'KF') | (CAPSWord == 'KILLF') | (CAPSWord == 'KFOC')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=KillFocus()');
GOTO FINISH;
};
if(  (CAPSWord == 'L') | (CAPSWord == 'LF')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Left()');
GOTO FINISH;
};
if(  (CAPSWord == 'LV') | (CAPSWord == 'LVIS') | (CAPSWord == 'LEFTV')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=LeftVisible');
GOTO FINISH;
};
if(  (CAPSWord == 'N') | (CAPSWord == 'NM')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Name');
GOTO FINISH;
};
if(  (CAPSWord == 'NB') | (CAPSWord == 'NBOT')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=nBottom');
GOTO FINISH;
};
if(  (CAPSWord == 'NL')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=nLeft');
GOTO FINISH;
};
if(  (CAPSWord == 'NR') | (CAPSWord == 'NRI')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=nRight');
GOTO FINISH;
};
if(  (CAPSWord == 'NT')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=nTop');
GOTO FINISH;
};
if(  (CAPSWord == 'OP') | (CAPSWord == 'OPER') | (CAPSWord == 'O')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Operation');
GOTO FINISH;
};
if(  (CAPSWord == 'OR') | (CAPSWord == 'ORIG')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Original');
GOTO FINISH;
};
if(  (CAPSWord == 'OS') | (CAPSWord == 'OSC') | (CAPSWord == 'OC')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=OSCode');
GOTO FINISH;
};
if(  (CAPSWord == 'OST') | (CAPSWord == 'OVS') | (CAPSWord == 'OVERS')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=OverStrike()');
GOTO FINISH;
};
if(  (CAPSWord == 'PD') | (CAPSWord == 'PGD') | (CAPSWord == 'PDN') | (CAPSWord == 'PGDN')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=PageDown()');
GOTO FINISH;
};
if(  (CAPSWord == 'PU') | (CAPSWord == 'PGU') | (CAPSWord == 'PUP') | (CAPSWord == 'PGUP')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=PageUp()');
GOTO FINISH;
};
if(  (CAPSWord == 'PE') | (CAPSWord == 'PANE')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=PanEnd()');
GOTO FINISH;
};
if(  (CAPSWord == 'PH') | (CAPSWord == 'PANH')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=PanHome()');
GOTO FINISH;
};
if(  (CAPSWord == 'PL') | (CAPSWord == 'PANL')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=PanLeft()');
GOTO FINISH;
};
if(  (CAPSWord == 'PR') | (CAPSWord == 'PANR')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=PanRight()');
GOTO FINISH;
};
if(  (CAPSWord == 'PC') | (CAPSWord == 'PIC') | (CAPSWord == 'PICT')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Picture');
GOTO FINISH;
};
if(  (CAPSWord == 'P')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Pos');
GOTO FINISH;
};
if(  (CAPSWord == 'POSTB') | (CAPSWord == 'POB')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=PostBlock');
GOTO FINISH;
};
if(  (CAPSWord == 'PREB') | (CAPSWord == 'PRB')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=PreBlock');
GOTO FINISH;
};
if(  (CAPSWord == 'RD') | (CAPSWord == 'RDR') | (CAPSWord == 'RE')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Reader');
GOTO FINISH;
};
if(  (CAPSWord == 'RA') | (CAPSWord == 'REFA') | (CAPSWord == 'RALL')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=RefreshAll()');
GOTO FINISH;
};
if(  (CAPSWord == 'RC') | (CAPSWord == 'REFC') | (CAPSWord == 'RCUR') | (CAPSWord == 'RCURR')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=RefreshCurrent()');
GOTO FINISH;
};
if(  (CAPSWord == 'RJ') | (CAPSWord == 'REJ')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Rejected');
GOTO FINISH;
};
if(  (CAPSWord == 'RES') | (CAPSWord == 'RST')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Reset()');
GOTO FINISH;
};
if(  (CAPSWord == 'RI') | (CAPSWord == 'RT')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Right()');
GOTO FINISH;
};
if(  (CAPSWord == 'RV') | (CAPSWord == 'RVIS') | (CAPSWord == 'RTVIS') | (CAPSWord == 'RTV')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=RightVisible');
GOTO FINISH;
};
if(  (CAPSWord == 'R')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Row');
GOTO FINISH;
};
if(  (CAPSWord == 'ROWC') | (CAPSWord == 'RCNT') | (CAPSWord == 'RCN')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=RowCount');
GOTO FINISH;
};
if(  (CAPSWord == 'RP') | (CAPSWord == 'ROWP') | (CAPSWord == 'RPOS')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=RowPos');
GOTO FINISH;
};
if(  (CAPSWord == 'SEV') | (CAPSWord == 'SEVER')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Severity');
GOTO FINISH;
};
if(  (CAPSWord == 'SC') | (CAPSWord == 'SETC') | (CAPSWord == 'SCOL')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=SetColumn()');
GOTO FINISH;
};
if(  (CAPSWord == 'SF') | (CAPSWord == 'SETF') | (CAPSWord == 'SFOC')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=SetFocus()');
GOTO FINISH;
};
if(  (CAPSWord == 'SB') | (CAPSWord == 'SKIPB') | (CAPSWord == 'SKB')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=SkipBlock');
GOTO FINISH;
};
if(  (CAPSWord == 'STAB') | (CAPSWord == 'STABIL')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Stabilize()');
GOTO FINISH;
};
if(  (CAPSWord == 'ST') | (CAPSWord == 'STABL')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Stable');
GOTO FINISH;
};
if(  (CAPSWord == 'SUBC') | (CAPSWord == 'SCOD')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=SubCode');
GOTO FINISH;
};
if(  (CAPSWord == 'SUBS') | (CAPSWord == 'SSCR') | (CAPSWord == 'SSCRIPT')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Subscript');
GOTO FINISH;
};
if(  (CAPSWord == 'SS') | (CAPSWord == 'SUBSYS') | (CAPSWord == 'SSYS')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=SubSystem');
GOTO FINISH;
};
if(  (CAPSWord == 'TBC') | (CAPSWord == 'TBCOL') | (CAPSWord == 'TBCN')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=TBColumnNew()');
GOTO FINISH;
};
if(  (CAPSWord == 'TBN') | (CAPSWord == 'TBR') | (CAPSWord == 'TBRN')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=TBrowseNew()');
GOTO FINISH;
};
if(  (CAPSWord == 'TBRDB') | (CAPSWord == 'TBDB') | (CAPSWord == 'TDB')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=TBrowseDB()');
GOTO FINISH;
};
if(  (CAPSWord == 'TDC') | (CAPSWord == 'TOD') | (CAPSWord == 'TODP')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=ToDecPos()');
GOTO FINISH;
};
if(  (CAPSWord == 'TR') | (CAPSWord == 'TRS') | (CAPSWord == 'TRI')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Tries');
GOTO FINISH;
};
if(  (CAPSWord == 'T') | (CAPSWord == 'TYP')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Type');
GOTO FINISH;
};
if(  (CAPSWord == 'TO')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=TypeOut');
GOTO FINISH;
};
if(  (CAPSWord == 'UN')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Undo()');
GOTO FINISH;
};
if(  (CAPSWord == 'U')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Up()');
GOTO FINISH;
};
if(  (CAPSWord == 'UB') | (CAPSWord == 'UBUF')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=UpdateBuffer()');
GOTO FINISH;
};
if(  (CAPSWord == 'VG') | (CAPSWord == 'VARG')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=VarGet()');
GOTO FINISH;
};
if(  (CAPSWord == 'VP') | (CAPSWord == 'VARP')  ) {
   RM('CLIPPER^TEXT_COMMANDS5 /S=VarPut()');
GOTO FINISH;
};
if(  (CAPSWord == 'W') | (CAPSWord == 'WI') | (CAPSWord == 'WIG')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=Width');
GOTO FINISH;
};
if(  (CAPSWord == 'WL')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=WordLeft()');
GOTO FINISH;
};
if(  (CAPSWord == 'WR')  ) {
   RM('CLIPPER^TEXT_COMMANDS3 /S=WordRight()');
GOTO FINISH;
};


    TEXT(InputWord);
    BEEP;
    make_message('Вхождение не обнаружено');
    FINISH:
    POP_UNDO;
    INSERT_MODE = Ins_mode;
};



macro CLI_IND FROM EDIT {     /* Макрос обработки автоотступа при переходе
                                 на новую строку. */

    str InputWord,line = get_line;
    int WHERE,FRST = 0,empt = 0,w_a,refr,comment = 0;
    WHERE = C_COL;         /* Запомнили координату */
    if (line == '') {      /* ENTER нажата в пустой строке */
      empt = 1;
      mark_pos;
      w_a = window_attr;
      refr = refresh;
      refresh = FALSE;
      window_attr = 64;    /* "Прячем" на время окно, чтобы оно не
                              дергалось при блужданиях по строкам */
      do {                      /* Ищем вверх первую не пустую строку */
         if (c_line == 1) break;
         up;
      } while (get_line == '');
    } else {      /* ИНАЧЕ: если строка не пустая */
      frst = xpos('/*',line,1);     /* Не внутри ли мы комментария? */
      if ( frst ) {                 /* Начало комментария нашли, а конец? */
         eol;
         left;
         InputWord = cur_char;
         left;
         InputWord = cur_char + InputWord;
         if ((InputWord == '*/') AND (c_col < where)) frst = 0;  /* Нашли и
                                                конец комментария, но ENTER
                                                была нажата за его концом,
                                                так что это не считается */
         else {      /* ИНАЧЕ: мы внутри комментария. В таком случае
                        отступ установим на уровне начала комментария
                        в предыдущей строке - для пущей красоты */
            comment = 1;
            goto_col(frst);
         }
      }
    }
    if (not(frst)) {    /* Ну, а если мы все же не внутри комментария... */
      FIRST_WORD;
      FRST = C_COL;
      }
    set_indent_level;
            /* Считываем первое слово в строке */
    InputWord = ',' + REMOVE_SPACE(GET_WORD(' !@|124$&.,{}[]=-+<>/\*:;%^()"'+char(39))) + ',';
    if (empt) {
      goto_mark;
      refresh = refr;
      window_attr = w_a;   /* Восстанавливаем экран */
      update_window;
      }
    GOTO_COL(WHERE);       /* Возвращаемся к исходной позиции и, наконец,
                              осуществляем "возврат каретки" */
    CR;
    if(  (WHERE <= FRST)  ) {   /* Если курсор в момент нажатия ENTER
                                   находился левее первого слова в текущей
                                   строке, не будем ничего никуда двигать */
        GOTO FINISH;
    };
         /* Сначала, чтобы не тратить зря время, проверяем первое слово
            строки на НЕ ПРИНАДЛЕЖНОСТЬ к списку ключевых слов */

    if( (XPOS(CAPS(InputWord),',BEGIN,TEXT,IF,FOR,DO,FUNCTION,PROCEDURE,CASE,OTHERWISE,ELSEIF,ELSE,WHILE,RECOVER,STATIC,#IFDEF,#IFNDEF,#ELSE,',1) == 0) ) {
        GOTO_COL(FRST);    /* И если это слово нейтральное, завершаем работу */
        GOTO FINISH;
    } else {
            /* В ПРОТИВНОМ СЛУЧАЕ: отступ на один TAB вправо */
        tab_right;
    };
    FINISH:
};


   /* Далее - целый ряд очень простых макросов ввода в текст подстановок
      CLIPPER-структур - без комментариев */

macro FORNEXT FROM EDIT TRANS {
    if(  (LENGTH(GET_LINE) > 0)  ) {
        RM('CLIPPER^CLI_IND');
    };
    int prev_pos = c_col;
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('FOR := TO ');
        CR;
        goto_col(prev_pos);
        TEXT('NEXT');
    } else {
        TEXT('For := To ');
        CR;
        goto_col(prev_pos);
        TEXT('Next');
    };
    UP;
};


macro DOWHILE FROM EDIT TRANS {
    if(  (LENGTH(GET_LINE) > 0)  ) {
        RM('CLIPPER^CLI_IND');
    };
    int prev_pos = c_col;
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('DO WHILE ');
        CR;
        goto_col(prev_pos);
        TEXT('ENDDO');
    } else {
        TEXT('Do While ');
        CR;
        goto_col(prev_pos);
        TEXT('EndDo');
    };
  UP;
  RIGHT;
  RIGHT;
  RIGHT;
  RIGHT;
};


macro DOCASE FROM EDIT TRANS {
    if(  (LENGTH(GET_LINE) > 0)  ) {
        RM('CLIPPER^CLI_IND');
    };
    int prev_pos = prev_pos = c_col;
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('DO CASE');
        CR;
        up;
        first_word;
        down;
        tab_right;
        TEXT('CASE ');
        CR;
        up;
        first_word;
        down;
        TEXT('CASE ');
        CR;
        goto_col(prev_pos);
        TEXT('ENDCASE');
    } else {
        TEXT('Do Case');
        CR;
        up;
        first_word;
        down;
        tab_right;
        TEXT('Case ');
        CR;
        up;
        first_word;
        down;
        TEXT('Case ');
        CR;
        goto_col(prev_pos);
        TEXT('EndCase');
    };
    UP;
    UP;
    EOL;
};


macro IFENDIF FROM EDIT TRANS {
    if(  (LENGTH(GET_LINE) > 0)  ) {
        RM('CLIPPER^CLI_IND');
    };
    int prev_pos = c_col;
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('IF ');
        CR;
        goto_col(prev_pos);
        TEXT('ENDIF');
    } else {
        TEXT('If ');
        CR;
        goto_col(prev_pos);
        TEXT('EndIf');
    };
    UP;
    EOL;
};


macro IFELSEENDIF FROM EDIT TRANS {
    if(  (LENGTH(GET_LINE) > 0)  ) {
        RM('CLIPPER^CLI_IND');
    };
    int prev_pos = c_col;
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('IF ');
        CR;
        goto_col(prev_pos);
        set_indent_level;
        TEXT('ELSE');
        CR;
        TEXT('ENDIF');
    } else {
        TEXT('If ');
        CR;
        goto_col(prev_pos);
        set_indent_level;
        TEXT('Else');
        CR;
        TEXT('EndIf');
    };
    UP;
    UP;
    EOL;
};

   /* Теперь еще ряд макросов - тоже ввод макроподстановок операторов типа
      CASE, ELSE и пр., - но посложнее, так как прежде, чем ввести оператор,
      мы отслеживаем: а находимся ли мы внутри соответствующей структуры.
      Все эти макросы однотипны, поэтому комментарии пишу только для
      первого */

macro CASE FROM EDIT TRANS {
    int w_a,prev_r,end = 0,refr = refresh,_pos,_beg = 0,_if = 0,_for = 0,_while = 0;
    str FW,prov1 = '.DO.ENDCASE.STATIC.PROCEDURE.FUNCTION.STAT.PROC.FUNC.BEGIN.IF.FOR.END.ENDIF.NEXT.ENDDO.',
           prov2 = '.STATIC.PROCEDURE.FUNCTION.STAT.PROC.FUNC.',
           prov3 = '.BEGIN.IF.FOR.END.ENDIF.NEXT.ENDDO.';
    mark_pos;     /* prov1 - все ключевые слова, на которые мы будем
                             обращать внимание при контроле;
                     prov2 и prov3 - они же, но разбитые на подгруппы
                             начала структур (prov2) и конца (prov3);
                     end, _beg, _if, _for, _while - счетчики для
                             соответствующих структур */
    if(  (GET_LINE != '')  ) {    /* Производим "возврат каретки" */
        CR;
    };
    mark_pos;                     /* Запоминаем позицию */
    w_a = window_attr;
    refresh = FALSE;
    window_attr = 64;             /* Прячем на время окно, чтобы не
                                     мельтешило */
    SEARCH_LOOP:                  /* Основная петля поиска вперед, пока
                                     не найдем начала текущей структуры
                                     DO CASE. */
    do
    { up;                         /* Строка вверх */
      first_word;
      if ( c_line == 1 ) call SEARCH_ERROR;     /* Дошли до начала файла,
                                                   но не до начала
                                                   DO CASE ! */
      fw = '.' + caps(get_word(' ')) + '.';     /* Считываем первое слово
                                                   в строке */
      If (xpos(fw,prov1,1) == 0) {              /* Слово индифферентное,
                                                   можно продолжать */
         continue;
      }  else {                                 /* ИНАЧЕ... */
         if (fw == '.ENDCASE.') end ++;         /* Сначала проверяем на
                                                   ENDCASE,- если да,
                                                   увеличиваем счетчик
                                                   для DO CASE - ENDCASE
                                                   (очевидно, напоролись
                                                   на вложенную структуру) */
         Else if (xpos(fw,prov2,1)) {           /* ВНИМАНИЕ! Мы нашли начало
                                                   какой-то новой структуры,
                                                   не дойдя до начала текущего
                                                   DO CASE ! Такого просто
                                                   не может быть! */
            call search_error;
            break;
         }
         Else if (xpos(fw,prov3,1)) {           /* Ну, а если это конец
                                                   какой-либо из структур
                                                   (очевидно, вложенной),
                                                   необходимо изменить
                                                   соответствующий счетчик */
            call STRUCT_CNT;
            break;
         }
      }
    } while ( fw != '.DO.' );       /* Основное условие поиска:
                                       пока нам не встретится какое-либо DO */
    if (fw == '.DO.') {             /* Если же оно все же встретилось,
                                       уточним, что это: DO CASE или
                                       DO WHILE ? */
      word_right;
      fw = caps(get_word(' '));
      if (fw != 'CASE') {
            if (fw == 'WHILE') {
               fw = '.DO.';         /* Если DO WHILE, обновим соответствующий
                                       счетчик и продолжим поиск */
               call STRUCT_CNT;
            }
            goto SEARCH_LOOP;
      }
      if (end) {                    /* Если DO CASE, но это DO CASE вложенной
                                       структуры (счетчик end не пуст),
                                       обновим счетчик и продолжим поиск */
         end --;
         goto SEARCH_LOOP;
      }
    }
    first_word;                     /* Мы, наконец, дошли до конца.
                                       Засекаем позицию первого слова
                                       (т.е. "DO"), возвращаемся на свое
                                       место и соответсвующим образом
                                       корректируем нашу текущую позицию
                                       в строке... */
    _pos = c_col;
    goto_mark;
    pop_mark;
    goto_col(_pos);
    refresh = refr;
    window_attr = w_a;              /* ...открываем "спрятанный" экран... */
    update_window;
    tab_right;
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {    /* ... и наконец-то вводим
                                              желанное слово! */
        TEXT('CASE ');
    } else {
        TEXT('Case ');
    };
    goto fin;

    SEARCH_ERROR:          /* Сообщение об ошибке */
    beep;
    rm('meerror^verify /T=Вы уверены, что Вы правы?!/H=CLIPPER^CLIPSI/S=1/BL=Нет начала структуры DO CASE !');
    if (return_int) ret;
    goto_mark;
    del_line;
    goto_mark;
    refresh = refr;
    window_attr = w_a;
    update_window;
    goto FIN;

    STRUCT_CNT:            /* Отслеживание количества вложенных структур */
    if (fw == '.END.') {                /* Конец SEQUENCE */
      _beg --;
      goto SEARCH_LOOP;
    } else if (fw == '.ENDIF.') {       /* Конец IF-ENDIF */
      _if --;
      goto SEARCH_LOOP;
    } else if (fw == '.ENDDO.') {       /* Конец DO WHILE-ENDDO */
      _while --;
      goto SEARCH_LOOP;
    } else if (fw == '.NEXT.') {        /* Конец FOR-NEXT */
      _for --;
      goto SEARCH_LOOP;
    } else if (fw == '.BEGIN.') {       /* Начало SEQUENCE */
      _beg ++;
      if (_beg < 1) goto SEARCH_LOOP;
      fw = 'SEQUENCE';
    } else if (fw == '.IF.') {          /* Начало IF-ENDIF */
      _if ++;
      if (_if < 1) goto SEARCH_LOOP;
      fw = 'IF - ENDIF';
    } else if (fw == '.DO.') {          /* Начало DO WHILE-ENDDO */
      _while ++;
      if (_while < 1) goto SEARCH_LOOP;
      fw = 'DO WHILE - ENDDO';
    } else {                            /* Начало FOR-NEXT */
      _for ++;
      if (_for < 1) goto SEARCH_LOOP;
      fw = 'FOR - NEXT';
    }
    beep;      /* Если мы добрались сюда,- значит нарушен баланс
                  какой-то из структур! */
    rm('meerror^verify /T=Вы уверены, что Вы правы?!/H=CLIPPER^CLIPSI/S=1/BL=Вы находитесь внутри структуры ' + fw + ' !');
    if (return_int) ret;
    goto_mark;
    del_line;
    goto_mark;
    refresh = refr;
    window_attr = w_a;
    update_window;
    goto FIN;

    FIN:
};


macro OTHERWISE FROM EDIT TRANS {
    int w_a,prev_r,end = 0,refr = refresh,_pos,_beg = 0,_if = 0,_for = 0,_while = 0;
    str FW,prov1 = '.DO.ENDCASE.STATIC.PROCEDURE.FUNCTION.STAT.PROC.FUNC.BEGIN.IF.FOR.END.ENDIF.NEXT.ENDDO.',
           prov2 = '.STATIC.PROCEDURE.FUNCTION.STAT.PROC.FUNC.',
           prov3 = '.BEGIN.IF.FOR.END.ENDIF.NEXT.ENDDO.';
    mark_pos;
    if(  (GET_LINE != '')  ) {
        CR;
    };
    mark_pos;
    w_a = window_attr;
    refresh = FALSE;
    window_attr = 64;
    SEARCH_LOOP:
    do
    { up;
      first_word;
      if ( c_line == 1 ) call SEARCH_ERROR;
      fw = '.' + caps(get_word(' ')) + '.';
      If (xpos(fw,prov1,1) == 0) {
         continue;
      }  else {
         if (fw == '.ENDCASE.') end ++;
         Else if (xpos(fw,prov2,1)) {
            call search_error;
            break;
         }
         Else if (xpos(fw,prov3,1)) {
            call STRUCT_CNT;
            break;
         }
      }
    } while ( fw != '.DO.' );
    if (fw == '.DO.') {
      word_right;
      fw = caps(get_word(' '));
      if (fw != 'CASE') {
            if (fw == 'WHILE') {
               fw = '.DO.';
               call STRUCT_CNT;
            }
            goto SEARCH_LOOP;
      }
      if (end) {
         end --;
         goto SEARCH_LOOP;
      }
    }
    first_word;
    _pos = c_col;
    goto_mark;
    pop_mark;
    goto_col(_pos);
    refresh = refr;
    window_attr = w_a;
    update_window;
    tab_right;
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('OTHERWISE');
    } else {
        TEXT('OtherWise');
    };
    RM('CLIPPER^CLI_IND');
    goto fin;

    SEARCH_ERROR:
    beep;
    rm('meerror^verify /T=Вы уверены, что Вы правы?!/H=CLIPPER^CLIPSI/S=1/BL=Нет начала структуры DO CASE !');
    if (return_int) ret;
    goto_mark;
    del_line;
    goto_mark;
    refresh = refr;
    window_attr = w_a;
    update_window;
    goto FIN;

    STRUCT_CNT:
    if (fw == '.END.') {
      _beg --;
      goto SEARCH_LOOP;
    } else if (fw == '.ENDIF.') {
      _if --;
      goto SEARCH_LOOP;
    } else if (fw == '.ENDDO.') {
      _while --;
      goto SEARCH_LOOP;
    } else if (fw == '.NEXT.') {
      _for --;
      goto SEARCH_LOOP;
    } else if (fw == '.BEGIN.') {
      _beg ++;
      if (_beg < 1) goto SEARCH_LOOP;
      fw = 'SEQUENCE';
    } else if (fw == '.IF.') {
      _if ++;
      if (_if < 1) goto SEARCH_LOOP;
      fw = 'IF - ENDIF';
    } else if (fw == '.DO.') {
      _while ++;
      if (_while < 1) goto SEARCH_LOOP;
      fw = 'DO WHILE - ENDDO';
    } else {                           /* (fw == '.FOR.') */
      _for ++;
      if (_for < 1) goto SEARCH_LOOP;
      fw = 'FOR - NEXT';
    }
    beep;
    rm('meerror^verify /T=Вы уверены, что Вы правы?!/H=CLIPPER^CLIPSI/S=1/BL=Вы находитесь внутри структуры ' + fw + ' !');
    if (return_int) ret;
    goto_mark;
    del_line;
    goto_mark;
    refresh = refr;
    window_attr = w_a;
    update_window;
    goto FIN;

    FIN:
};


macro ELSE FROM EDIT TRANS {
    int w_a,prev_r,end = 0,refr = refresh,_pos,_beg = 0,_case = 0,_for = 0,_while = 0;
    str FW,prov1 = '.ENDIF.STATIC.PROCEDURE.FUNCTION.STAT.PROC.FUNC.BEGIN.IF.FOR.DO.END.ENDDO.NEXT.ENDCASE.',
           prov2 = '.STATIC.PROCEDURE.FUNCTION.STAT.PROC.FUNC.',
           prov3 = '.BEGIN.DO.FOR.ENDDO.NEXT.ENDCASE.END.';
    mark_pos;
    if(  (GET_LINE != '')  ) {
        CR;
    };
    mark_pos;
    w_a = window_attr;
    refresh = FALSE;
    window_attr = 64;
    SEARCH_LOOP:
    do
    { up;
      first_word;
      if ( c_line == 1 ) call SEARCH_ERROR;
      fw = '.' + caps(get_word(' ')) + '.';
      If (xpos(fw,prov1,1) == 0) {
         continue;
      }  else {
         if (fw == '.ENDIF.') end ++;
         Else if (xpos(fw,prov2,1)) {
            call search_error;
            break;
         }
         Else if (xpos(fw,prov3,1)) {
            call STRUCT_CNT;
            break;
         }
      }
    } while ( fw != '.IF.' );
      if (end) {
         end --;
         goto SEARCH_LOOP;
      }
    first_word;
    _pos = c_col;
    goto_mark;
    pop_mark;
    goto_col(_pos);
    refresh = refr;
    window_attr = w_a;
    update_window;
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('ELSE');
    } else {
        TEXT('Else');
    };
    RM('CLIPPER^CLI_IND');
    goto fin;

    SEARCH_ERROR:
    beep;
    rm('meerror^verify /T=Вы уверены, что Вы правы?!/H=CLIPPER^CLIPSI/S=1/BL=Нет начала структуры IF !');
    if (return_int) ret;
    goto_mark;
    del_line;
    goto_mark;
    refresh = refr;
    window_attr = w_a;
    update_window;
    goto FIN;

    STRUCT_CNT:
    if (fw == '.END.') {
      _beg --;
      goto SEARCH_LOOP;
    } else if (fw == '.ENDCASE.') {
      _case --;
      goto SEARCH_LOOP;
    } else if (fw == '.ENDDO.') {
      _while --;
      goto SEARCH_LOOP;
    } else if (fw == '.NEXT.') {
      _for --;
      goto SEARCH_LOOP;
    } else if (fw == '.BEGIN.') {
      _beg ++;
      if (_beg < 1) goto SEARCH_LOOP;
      fw = 'SEQUENCE';
    } else if (fw == '.DO.') {
      word_right;
      fw = caps(get_word(' '));
      if (fw == 'WHILE') {
         _while ++;
         if (_while < 1) goto SEARCH_LOOP;
         fw = 'DO WHILE - ENDDO';
      }
      else if (fw == 'CASE') {
         _case ++;
         if (_case < 1) goto SEARCH_LOOP;
         fw = 'DO CASE - ENDCASE';
      } else goto SEARCH_LOOP;
    } else {                           /* (fw == '.FOR.') */
      _for ++;
      if (_for < 1) goto SEARCH_LOOP;
      fw = 'FOR - NEXT';
    }
    beep;
    rm('meerror^verify /T=Вы уверены, что Вы правы?!/H=CLIPPER^CLIPSI/S=1/BL=Вы находитесь внутри структуры ' + fw + ' !');
    if (return_int) ret;
    goto_mark;
    del_line;
    goto_mark;
    refresh = refr;
    window_attr = w_a;
    update_window;
    goto FIN;

    FIN:
};


macro ELSEIF FROM EDIT TRANS {
    int w_a,prev_r,end = 0,refr = refresh,_pos,_beg = 0,_case = 0,_for = 0,_while = 0;
    str FW,prov1 = '.ENDIF.STATIC.PROCEDURE.FUNCTION.STAT.PROC.FUNC.BEGIN.IF.FOR.DO.END.ENDDO.NEXT.ENDCASE.',
           prov2 = '.STATIC.PROCEDURE.FUNCTION.STAT.PROC.FUNC.',
           prov3 = '.BEGIN.DO.FOR.ENDDO.NEXT.ENDCASE.';
    mark_pos;
    if(  (GET_LINE != '')  ) {
        CR;
    };
    mark_pos;
    w_a = window_attr;
    refresh = FALSE;
    window_attr = 64;
    SEARCH_LOOP:
    do
    { up;
      first_word;
      if ( c_line == 1 ) call SEARCH_ERROR;
      fw = '.' + caps(get_word(' ')) + '.';
      If (xpos(fw,prov1,1) == 0) {
         continue;
      }  else {
         if (fw == '.ENDIF.') end ++;
         Else if (xpos(fw,prov2,1)) {
            call search_error;
            break;
         }
         Else if (xpos(fw,prov3,1)) {
            call STRUCT_CNT;
            break;
         }
      }
    } while ( fw != '.IF.' );
      if (end) {
         end --;
         goto SEARCH_LOOP;
      }
    first_word;
    _pos = c_col;
    goto_mark;
    pop_mark;
    goto_col(_pos);
    refresh = refr;
    window_attr = w_a;
    update_window;
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('ELSEIF ');
    } else {
        TEXT('ElseIf ');
    };
    goto fin;

    SEARCH_ERROR:
    beep;
    rm('meerror^verify /T=Вы уверены, что Вы правы?!/H=CLIPPER^CLIPSI/S=1/BL=Нет начала структуры IF !');
    if (return_int) ret;
    goto_mark;
    del_line;
    goto_mark;
    refresh = refr;
    window_attr = w_a;
    update_window;
    goto FIN;

    STRUCT_CNT:
    if (fw == '.END.') {
      _beg --;
      goto SEARCH_LOOP;
    } else if (fw == '.ENDCASE.') {
      _case --;
      goto SEARCH_LOOP;
    } else if (fw == '.ENDDO.') {
      _while --;
      goto SEARCH_LOOP;
    } else if (fw == '.NEXT.') {
      _for --;
      goto SEARCH_LOOP;
    } else if (fw == '.BEGIN.') {
      _beg ++;
      if (_beg < 1) goto SEARCH_LOOP;
      fw = 'SEQUENCE';
    } else if (fw == '.DO.') {
      word_right;
      fw = caps(get_word(' '));
      if (fw == 'WHILE') {
         _while ++;
         if (_while < 1) goto SEARCH_LOOP;
         fw = 'DO WHILE - ENDDO';
      }
      else if (fw == 'CASE') {
         _case ++;
         if (_case < 1) goto SEARCH_LOOP;
         fw = 'DO CASE - ENDCASE';
      } else goto SEARCH_LOOP;
    } else {                           /* (fw == '.FOR.') */
      _for ++;
      if (_for < 1) goto SEARCH_LOOP;
      fw = 'FOR - NEXT';
    }
    beep;
    rm('meerror^verify /T=Вы уверены, что Вы правы?!/H=CLIPPER^CLIPSI/S=1/BL=Вы находитесь внутри структуры ' + fw + ' !');
    if (return_int) ret;
    goto_mark;
    del_line;
    goto_mark;
    refresh = refr;
    window_attr = w_a;
    update_window;
    goto FIN;

    FIN:
};



macro RECOVER FROM EDIT TRANS {
    int w_a,prev_r,end = 0,refr = refresh,_pos,_if = 0,_case = 0,_for = 0,_while = 0;
    str FW,prov1 = '.END.STATIC.PROCEDURE.FUNCTION.STAT.PROC.FUNC.BEGIN.IF.FOR.DO.ENDIF.ENDDO.NEXT.ENDCASE.',
           prov2 = '.STATIC.PROCEDURE.FUNCTION.STAT.PROC.FUNC.',
           prov3 = '.IF.DO.FOR.ENDDO.NEXT.ENDCASE.ENDIF.';
    mark_pos;
    if(  (GET_LINE != '')  ) {
        CR;
    };
    mark_pos;
    w_a = window_attr;
    refresh = FALSE;
    window_attr = 64;
    SEARCH_LOOP:
    do
    { up;
      first_word;
      if ( c_line == 1 ) call SEARCH_ERROR;
      fw = '.' + caps(get_word(' ')) + '.';
      If (xpos(fw,prov1,1) == 0) {
         continue;
      }  else {
         if (fw == '.END.') end ++;
         Else if (xpos(fw,prov2,1)) {
            call search_error;
            break;
         }
         Else if (xpos(fw,prov3,1)) {
            call STRUCT_CNT;
            break;
         }
      }
    } while ( fw != '.BEGIN.' );
    word_right;
    if (xpos(caps(get_word(' ')),'SEQUENCE',1) == 0) goto SEARCH_LOOP;
      if (end) {
         end --;
         goto SEARCH_LOOP;
      }
    first_word;
    _pos = c_col;
    goto_mark;
    pop_mark;
    goto_col(_pos);
    refresh = refr;
    window_attr = w_a;
    update_window;
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('RECOVER ');
    } else {
        TEXT('Recover ');
    };
    RM('CLIPPER^CLI_IND');
    goto fin;

    SEARCH_ERROR:
    beep;
    rm('meerror^verify /T=Вы уверены, что Вы правы?!/H=CLIPPER^CLIPSI/S=1/BL=Нет начала структуры SEQUENCE !');
    if (return_int) ret;
    goto_mark;
    del_line;
    goto_mark;
    refresh = refr;
    window_attr = w_a;
    update_window;
    goto FIN;

    STRUCT_CNT:
    if (fw == '.ENDIF.') {
      _if --;
      goto SEARCH_LOOP;
    } else if (fw == '.ENDCASE.') {
      _case --;
      goto SEARCH_LOOP;
    } else if (fw == '.ENDDO.') {
      _while --;
      goto SEARCH_LOOP;
    } else if (fw == '.NEXT.') {
      _for --;
      goto SEARCH_LOOP;
    } else if (fw == '.IF.') {
      _if ++;
      if (_if < 1) goto SEARCH_LOOP;
      fw = 'IF - ENDIF';
    } else if (fw == '.DO.') {
      word_right;
      fw = caps(get_word(' '));
      if (fw == 'WHILE') {
         _while ++;
         if (_while < 1) goto SEARCH_LOOP;
         fw = 'DO WHILE - ENDDO';
      }
      else if (fw == 'CASE') {
         _case ++;
         if (_case < 1) goto SEARCH_LOOP;
         fw = 'DO CASE - ENDCASE';
      } else goto SEARCH_LOOP;
    } else {                           /* (fw == '.FOR.') */
      _for ++;
      if (_for < 1) goto SEARCH_LOOP;
      fw = 'FOR - NEXT';
    }
    beep;
    rm('meerror^verify /T=Вы уверены, что Вы правы?!/H=CLIPPER^CLIPSI/S=1/BL=Вы находитесь внутри структуры ' + fw + ' !');
    if (return_int) ret;
    goto_mark;
    del_line;
    goto_mark;
    refresh = refr;
    window_attr = w_a;
    update_window;
    goto FIN;

    FIN:
};


macro RECOVER_U FROM EDIT TRANS {
    int w_a,prev_r,end = 0,refr = refresh,_pos,_if = 0,_case = 0,_for = 0,_while = 0;
    str FW,prov1 = '.END.STATIC.PROCEDURE.FUNCTION.STAT.PROC.FUNC.BEGIN.IF.FOR.DO.ENDIF.ENDDO.NEXT.ENDCASE.',
           prov2 = '.STATIC.PROCEDURE.FUNCTION.STAT.PROC.FUNC.',
           prov3 = '.IF.DO.FOR.ENDDO.NEXT.ENDCASE.ENDIF.';
    mark_pos;
    if(  (GET_LINE != '')  ) {
        CR;
    };
    mark_pos;
    w_a = window_attr;
    refresh = FALSE;
    window_attr = 64;
    SEARCH_LOOP:
    do
    { up;
      first_word;
      if ( c_line == 1 ) call SEARCH_ERROR;
      fw = '.' + caps(get_word(' ')) + '.';
      If (xpos(fw,prov1,1) == 0) {
         continue;
      }  else {
         if (fw == '.END.') end ++;
         Else if (xpos(fw,prov2,1)) {
            call search_error;
            break;
         }
         Else if (xpos(fw,prov3,1)) {
            call STRUCT_CNT;
            break;
         }
      }
    } while ( fw != '.BEGIN.' );
    word_right;
    if (xpos(caps(get_word(' ')),'SEQUENCE',1) == 0) goto SEARCH_LOOP;
      if (end) {
         end --;
         goto SEARCH_LOOP;
      }
    first_word;
    _pos = c_col;
    goto_mark;
    pop_mark;
    goto_col(_pos);
    refresh = refr;
    window_attr = w_a;
    update_window;
    if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
        TEXT('RECOVER USING ');
    } else {
        TEXT('Recover Using ');
    };
    goto fin;

    SEARCH_ERROR:
    beep;
    rm('meerror^verify /T=Вы уверены, что Вы правы?!/H=CLIPPER^CLIPSI/S=1/BL=Нет начала структуры SEQUENCE !');
    if (return_int) ret;
    goto_mark;
    del_line;
    goto_mark;
    refresh = refr;
    window_attr = w_a;
    update_window;
    goto FIN;

    STRUCT_CNT:
    if (fw == '.ENDIF.') {
      _if --;
      goto SEARCH_LOOP;
    } else if (fw == '.ENDCASE.') {
      _case --;
      goto SEARCH_LOOP;
    } else if (fw == '.ENDDO.') {
      _while --;
      goto SEARCH_LOOP;
    } else if (fw == '.NEXT.') {
      _for --;
      goto SEARCH_LOOP;
    } else if (fw == '.IF.') {
      _if ++;
      if (_if < 1) goto SEARCH_LOOP;
      fw = 'IF - ENDIF';
    } else if (fw == '.DO.') {
      word_right;
      fw = caps(get_word(' '));
      if (fw == 'WHILE') {
         _while ++;
         if (_while < 1) goto SEARCH_LOOP;
         fw = 'DO WHILE - ENDDO';
      }
      else if (fw == 'CASE') {
         _case ++;
         if (_case < 1) goto SEARCH_LOOP;
         fw = 'DO CASE - ENDCASE';
      } else goto SEARCH_LOOP;
    } else {                           /* (fw == '.FOR.') */
      _for ++;
      if (_for < 1) goto SEARCH_LOOP;
      fw = 'FOR - NEXT';
    }
    beep;
    rm('meerror^verify /T=Вы уверены, что Вы правы?!/H=CLIPPER^CLIPSI/S=1/BL=Вы находитесь внутри структуры ' + fw + ' !');
    if (return_int) ret;
    goto_mark;
    del_line;
    goto_mark;
    refresh = refr;
    window_attr = w_a;
    update_window;
    goto FIN;

    FIN:
};



   /* Следующий набор простеньких макросов,- они непосредственно
      выводят в текст макроподстановки, заданные в CLIP_COMMANDS,
      CLIP_FUNCTIONS, CLIP_DBFUNC или CLIP_CLASSES, форматируя
      вывод соотвествующим образом (согласно описанию в CLIPPER.HLP-
      Пользовательские функции-Типы вывода мнемонических имен) */

macro TEXT_COMMANDS0 FROM EDIT TRANS {
  if(  (LENGTH(GET_LINE) > 0)  ) {
    RM('CLIPPER^CLI_IND');
  };
  if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
    TEXT(CAPS(PARSE_STR('/S=',MPARM_STR)));
  } else {
    TEXT(PARSE_STR('/S=',MPARM_STR));
  };
  DOWN;
  if(  (LENGTH(GET_LINE) > 0)  ) {
    UP;
  } else {
    UP;
    CR;
  };
};


macro TEXT_COMMANDS1 FROM EDIT TRANS {
  if(  (LENGTH(GET_LINE) > 0)  ) {
    RM('CLIPPER^CLI_IND');
  };
  if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
    TEXT(CAPS(PARSE_STR('/S=',MPARM_STR)));
  } else {
    TEXT(PARSE_STR('/S=',MPARM_STR));
  };
};


macro TEXT_COMMANDS2 FROM EDIT TRANS {
  if(  (LENGTH(GET_LINE) > 0)  ) {
    RM('CLIPPER^CLI_IND');
  };
  if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
    TEXT(CAPS(PARSE_STR('/S=',MPARM_STR)));
  } else {
    TEXT(PARSE_STR('/S=',MPARM_STR));
  };
  FIRST_WORD;
  WORD_RIGHT;
  LEFT;
};


macro TEXT_COMMANDS3 FROM EDIT TRANS {
  if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
    TEXT(CAPS(PARSE_STR('/S=',MPARM_STR)));
  } else {
    TEXT(PARSE_STR('/S=',MPARM_STR));
  };
};


macro TEXT_COMMANDS4 FROM EDIT TRANS {
  if(  (LENGTH(GET_LINE) > 0)  ) {
    RM('CLIPPER^CLI_IND');
  };
  if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
    TEXT(CAPS(PARSE_STR('/S=',MPARM_STR)));
  } else {
    TEXT(PARSE_STR('/S=',MPARM_STR));
  };
  LEFT;
};


macro TEXT_COMMANDS5 FROM EDIT TRANS {
  if(  (GLOBAL_INT('CLIP_CAPS'))  ) {
    TEXT(CAPS(PARSE_STR('/S=',MPARM_STR)));
  } else {
    TEXT(PARSE_STR('/S=',MPARM_STR));
  };
  LEFT;
};




   /* Совсем мелочевка - десяток макросов вывода в текст при нажатии
      одной клавиши либо сразу пары скобок/кавычек (открывающей-закрывающей),
      либо прямо наоборот - только одной скобки/кавычки. См. CLIPPER.HLP. */

macro CLIP_TWOBRANCH FROM EDIT TRANS {
    TEXT('()');
    left;
};

macro CLIP_TWOSQUOTES FROM EDIT TRANS {
    str Q;
    Q = char(39);
    TEXT(Q + Q);
    left;
};

macro CLIP_TWODQUOTES FROM EDIT TRANS {
    str Q;
    Q = '|34';
    TEXT(Q + Q);
    left;
};

macro CLIP_TWOBRACKET FROM EDIT TRANS {
    TEXT('[]');
    left;
};

macro CLIP_TWOCURL FROM EDIT TRANS {
    TEXT('{}');
    left;
};

macro CLIP_SBRANCH FROM EDIT TRANS {
   TEXT('(');
};

macro CLIP_SSQUOTES FROM EDIT TRANS {
   TEXT(char(39));
};

macro CLIP_SDQUOTES FROM EDIT TRANS {
   str Q;
   Q = '|34';
   TEXT(Q);
};

macro CLIP_SBRACKET FROM EDIT TRANS {
   TEXT('[');
};

macro CLIP_SCURL FROM EDIT TRANS {
   TEXT('{');
};



   /* Один из самых первых макросов системы. Сохраняю его только потому,
      что он и впрямь иногда удобен: нумерует на экране 80 столбцов,
      по отношению к которым можно прикинуть экранный вывод Вашей
      программы. Цифры вводятся прямо в текст!- но, попользовавшись,
      их совершенно недолго и удалить.
      В будущих версиях я все же возьмусь за этот макрос и доведу
      его до более пристойного вида. Собственный Ruler ME меня
      совершенно не устраивает */

macro SHCALA FROM EDIT trans {
    int I;
    I = INSERT_MODE;
    INSERT_MODE = TRUE;
    push_undo;
    CR;
    goto_col(1);
    CR;
    goto_col(1);
    TEXT('01234567890123456789012345678901234567890123456789012345678901234567890123456789');
    goto_col(1);
    UP;
    TEXT('          1         2         3         4         5         6         7');
    DOWN;
    EOL;
    CR;
    goto_col(1);
    pop_undo;
    INSERT_MODE = I;
};



   /* Загрузка файлов по шаблону - просто перевызывает соответствующий
      макрос из CLIP1.MAC */

macro CLIP_LOAD FROM EDIT TRANS {
    RM('CLIP1^CL_LOAD /MASK='+PARSE_STR('/MASK=',MPARM_STR));
};


   /* Макрос вызова на экран пользовательского меню системы.
      Благодаря ему, Вы можете одновременно иметь 2 пользовательских
      меню - "общего пользования" и "избирательно CLIPPER-системное" */

macro CLIP_MACROLIST FROM EDIT TRANS {
   int ch_type,rest_DOS,swp,usecmd,i,st_row,swp_mem;
   str str1,str2;
   Refresh = 0;
      /* Пользовательское меню хранится в файле CLIPF.DB в ME_PATH */
   Rm ('USERIN^DB /ABT=Go/F=CLIPF.DB/LT=Пользовательское меню/LO=2/H=ME^USER/GLO=@USER@') ;
   if(  (Return_Int  == 1)  ) {
            /* Выделяем из строки возврата все необходимые параметры */
      Return_Str = Parse_Str ('|127CMD=' , Global_Str ('@USER@') ) ;
      Rm ('XlateCmdLine /F=' + File_Name ) ;
      ch_type = Parse_Int ('|127TYPE=' , Global_Str ('@USER@') ) ;
      if(  (ch_type < 2)  ) {              /* Макрос */
         Rm (Return_Str ) ;
      } else {
         if(  (ch_type == 2)  ) {          /* Программа */
            st_row = Status_Row ;
            Status_Row = 0;
            swp_mem = (Parse_Int ('|127SWAP_MEM=' , Global_Str ('@USER@') )  * 1024/* 0400 */) / 16/* 10 */;
            swp = Parse_Int ('|127SWAP=' , Global_Str ('@USER@') ) ;
            if(  (swp > 4)  ) {
               swp = 0;
            } ;
            rest_DOS = Parse_Int ('|127REST=' , Global_Str ('@USER@') )  < 2;
            usecmd = Parse_Int ('|127USECMD=' , Global_Str ('@USER@') )  < 2;
            if(  (Parse_Str ('|127DIR=' , Global_Str ('@USER@') )  != '')  ) {
               str2 = Fexpand ('') ;
               if(  ((Svl(str2) > 3) & (Copy (str2 , Svl(str2) , 1)  == '\'))  ) {
                  str2 = Str_Del (str2 , Svl(str2) , 1) ;
               } ;
               Change_Dir (Parse_Str ('|127DIR=' , Global_Str ('@USER@') ) ) ;
            } ;
            Rm ('MEUTIL1^EXEC /SWAP=' + Str (swp)  + '/MEM=' + Str (swp_mem)  + '/CMD=' + Str (usecmd)  + '/SCREEN=' + Str (rest_DOS) ) ;
            if(  (Parse_Str ('|127DIR=' , Global_Str ('@USER@') )  != '')  ) {
               Change_Dir (str2) ;
            } ;
            Status_Row = st_row;
            New_Screen ;
         } else {                          /* HELP-файл */
            if(  (ch_type == 3)  ) {
               i = Xpos ('^' , Return_Str  , 1) ;
               if(  (i == 0)  ) {
                  i = Length (Return_Str ) ;
               } ;
               str1 = Copy (Return_Str  , 1 , i - 1) ;
               Return_Str = Copy (Return_Str  , i + 1 , 254) ;
               Update_Status_Line ;
               Rm ('MEHELP /F=' + str1 + '/LK=' + Return_Str ) ;
            } else {
               if(  (ch_type == 4)  ) {    /* Загрузить текстовый файл */
                  if(  (Switch_File (Caps (Return_Str ) ) )  ) {
                     Make_Message (Truncate_Path (Return_Str )  + ' уже загружен.') ;
                  } else {
                     Rm ('LDFILES /LC=1') ;
                  } ;
               } ;
            } ;
         } ;
      } ;
   } ;
} ;

/* ****************************************************************** */

/* И ВСЕ ?!
      ВСЕ !
         ВСЕ !!!

            Георгий Жердев
            20.06.93
 */

