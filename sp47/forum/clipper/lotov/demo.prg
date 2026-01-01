*\(*)/*\(*)/*\(*)/*\(*)/*\*
*   PROCEDURE DEMO      &&*  ТЕСТ/НАСТРОЙКА ЦВЕТОВ И МЕНЮ
*\(*)/*\(*)/*\(*)/*\(*)/*\*
*
SET PROCEDURE TO SSOOB
SET PROCEDURE TO CC
SET PROCEDURE TO RUBLIK
SET PROCEDURE TO KREST
HLPHLP=1
DO RUNINGER && НАЧАЛЬНАЯ ИНИЦИАЛИЗАЦИЯ СРЕДЫ
Te_FILE="DEMO.MEM"
Te_T=FILE(Te_FILE)
IF Te_T
  RESTORE FROM &Te_FILE ADDITIVE
ENDIF
IF .NOT. Te_T .OR. TYPE("Te_01GDE") = "U"
  Te_00SUMMA=123456789876543.21
  Te_01OTV =""
  Te_01ROW =99
  Te_01COLS='""'
  Te_01SOOB="Заголовок;-;@1 Альтернатива;-;@2 Альтернатива;-;@3 Альтернатива"
  Te_01NACH="          "
  Te_01PICT="@K XXXXXXX"
  Te_01SAVE=.T.
  Te_02ROW =00
  Te_02COL =20
  Te_02SOOB="0*Сумма прописью;0 Меню;0*Настройка;0 Выход;"+;
          "1*;2*Универсальное;2*Двухуровневое;1*Настройка;4 Выход;4 Еще Выход;4 А так же Выход"
  Te_02OTV =402
  Te_02TABL="10200479012"
*
  Te_01GDE=202
ENDIF
Te_GDE=Te_01GDE
Te_PARAM="11111279"
Te_SOOBG="0 Сумма прописью;0 Меню;0 Настройка;0 Выход;"+;
         "1 ;2 Универсальное;2 Двухуровневое;3 Настройка;4 "
MENUC=0
Te_61C=C(61) && Подвал
Te_63C=C(63) && Подвал
Te_10C=C(10) && Фон
Te_31C=C(31) && Cообщение
SET KEY 28 TO HELPDEMO
SET KEY  9 TO KREST && ПОЗИЦИОНИРОВАНИЕ ДЛЯ ОТЛАДКИ
                          DO WHILE .T.
SET CURSOR OFF
SET COLOR TO (Te_10C)
FON(.T.)
SET COLOR TO (Te_61C)
@ 24,22 SAY " Tab - ПОЗИЦИОНИРОВАНИЕ ДЛЯ ОТЛАДКИ"
SET COLOR TO (Te_63C)
@ 24,23 SAY "Tab"
SOOB(1,"Ц","ДЕМОНСТРАЦИЯ;-;НАСТРОЙКА")
Te_GDE=Te_01GDE
DO SUPERMEN WITH 12,22,Te_SOOBG,Te_01GDE,Te_PARAM
Te_GDE2=MOD(Te_01GDE,100)
Te_GDE1=Te_01GDE-Te_GDE2
DO CASE
   CASE Te_01GDE=100 && СУММА
SET CURSOR ON
KEYBOARD(CHR(13))
DO WHILE .T.
  Te_SUMMA=Te_00SUMMA
  Te_00SUMMA=SOOB(10,"","ЗАДАЙТЕ СУММУ;#                   ; 0.00 - Выход",Te_00SUMMA,"999999999999999.99",.F.)
  Te_SUMMAS=RUBL(Te_00SUMMA)
  Te_SUMMAS1="?"
  Te_SUMMAS2="?"
  ROW=17
  COL=09
  SET COLOR TO (Te_10C)
  FON(.F.)
*   ВЫДЕЛЕНИЕ СТРОКИ ДЛИНОЙ 60 СИМВОЛОВ ПО ПРОБЕЛУ:
  Te_FOR=0
  SET COLOR TO (Te_31C)
  DO WHILE LEN(TRIM(Te_SUMMAS)) > 0 && пока остаток строки не пуст
     DO PERENOS WITH Te_SUMMAS,60, .T., Te_SUMMAS1,Te_SUMMAS2
     @ ROW+ Te_FOR, COL SAY Te_SUMMAS1
     Te_SUMMAS=Te_SUMMAS2
     Te_FOR=Te_FOR+1
  ENDDO
  IF Te_00SUMMA=0
     Te_00SUMMA=Te_SUMMA
     IF Te_00SUMMA = 0
        Te_00SUMMA = 123456789876543.21
     ENDIF
      Te_NUL =INKEY(1)
      EXIT
  ENDIF
ENDDO
SET CURSOR OFF
   CASE Te_01GDE=201 && МЕНЮ УНИВЕРСАЛЬНОЕ
DO WHILE .T.
C(91)
CLEAR
@ 00,00 SAY '      ГЕНЕРАТОР СООБЩЕНИЙ, МЕНЮ ИЛИ ВВОДА В ПЕРЕМЕННУЮ (ИЛИ В МАССИВ)         '
@ 01,00 SAY '                                                                              '
@ 02,00 SAY '  MENUPAUSA = ## ЗАДЕРЖКА ПРИ ВЫДАЧЕ СООБЩЕНИЯ С СОХРАНЕНИЕМ ЭКРАНА           '
@ 03,00 SAY '  MENUCENTR = #   .T. - ЦЕНТРОВАТЬ СТРОКИ                                     '
@ 04,00 SAY '  MENUC     = ## НОМЕР ПАЛИТРЫ ДЛЯ ФУНКЦИИ C(где nn=MENUC+1,2,3)              '
@ 05,00 SAY '                                                                              '
@ 06,00 SAY '  ВВОД  НАЧИНАЕТСЯ С ПОЗИЦИИ С "#" в СТРОКЕ ( 3-ий паpаметp )                 '
@ 07,00 SAY '                                                                              '
@ 08,00 SAY '  Если ПЕРВЫМ СИМВОЛОМ В СТРОКЕ СТОИТ "@", ТО ЭТО МЕНЮ                        '
@ 09,00 SAY '                                                                              '
@ 10,00 SAY '  Если ПЕРВЫМ СИМВОЛОМ В СТРОКЕ СТОИТ "-", (минус) ТО ЭТО РАЗДЕЛИТЕЛЬ "├──┤", '
@ 11,00 SAY '                                                                              '
@ 12,00 SAY '  Если В НАЧАЛЕ СИМВОЛЬНОГО ПОЛЯ СТОИТ "^"(птичка), ТО "^" УДАЛЯЕТСЯ И        '
@ 13,00 SAY '       РАМКА НЕ ЧЕРТИТСЯ . ПТИЧКА СО ВТОРОЙ ПОЗИЦИИ - УБРАТЬ ТЕНЬ.            '
@ 14,00 SAY '                  1  2  3                                                     '
@ 15,00 SAY '           =SOOB( ## ## #                                                     '
@ 16,00 SAY '                                                                              '
@ 17,00 SAY ' 4              5                 6                                           '
@ 18,00 SAY ' #              #                 # )                                         '
@ 19,00 SAY '                                                                              '
@ 20,00 SAY ' 1 и 2 - Кооpдинаты веpхнего левого угла. (2 м.б. типа "C",тогда центpиpовать)'
@ 21,00 SAY '     3 - Символьная переменная СТРОК сообщения/меню/ввода через ";"           '
@ 22,00 SAY '     4 - Нач. значение для ввода (м. быть массив)                             '
@ 23,00 SAY '     5 - Шаблон для ввода (м. быть массив) ( введен шаблон @Л )               '
@ 24,00 SAY '     6 - .F. - Экpан не воостанавливать                                       '
Te_01SOOB=Te_01SOOB+SPACE(112-LEN(Te_01SOOB))
Te_01PICT=Te_01PICT+SPACE( 10-LEN(Te_01PICT))
C(93)
@ 02,14 GET MENUPAUSA PICTURE "99"
@ 03,14 GET MENUCENTR
@ 04,14 GET MENUC     PICTURE "99"
@ 15,01 SAY Te_01OTV
@ 15,18 GET Te_01ROW  PICTURE "99"
@ 15,21 GET Te_01COLS PICTURE "XX"
@ 15,24 GET Te_01SOOB
@ 18,01 GET Te_01NACH
@ 18,16 GET Te_01PICT
@ 18,34 GET Te_01SAVE
READ
Te_COL=VAL(Te_01COLS)
IF Te_COL=0
   Te_NULS=TRIM(LTRIM(Te_01COLS))
   IF Te_NULS # "0" .AND. Te_NULS # "00"
      Te_COL=Te_01COLS
   ENDIF
ENDIF
Te_01SOOB=TRIM(Te_01SOOB)
Te_AT1=AT("@",Te_01SOOB)
Te_AT2=AT("#",Te_01SOOB)
IF Te_AT1 > 0 .AND. Te_AT2 > 0
   IF Te_AT2 > 0
      Te_01SOOB=STUFF(Te_01SOOB,Te_AT2,1," ")
   ELSE
      Te_01SOOB=STUFF(Te_01SOOB,Te_AT1,1," ")
   ENDIF
ENDIF
Te_01PICT=TRIM(Te_01PICT)
SET COLOR TO (Te_10C)
FON(.F.)
Te_01OTV=SOOB(Te_01ROW,Te_COL,Te_01SOOB,Te_01NACH,Te_01PICT,Te_01SAVE)
SET COLOR TO (Te_61C)
@ 24,17 SAY "НАЖМИТЕ ЛЮБУЮ КЛАВИШУ, Esc - ВЫХОД"
SET COLOR TO (Te_63C)
@ 24,40 SAY "Esc"
Te_NUL=INKEY(0)
IF Te_NUL=27
   EXIT
ENDIF
ENDDO
   CASE Te_01GDE=202 && МЕНЮ ДВУХУРОВНЕВОЕ
HLPHLP=1
DO WHILE .T.
C(91)
CLEAR
@ 00,00 SAY '                     ГЕНЕРАТОР МЕНЮ ДВУХ УРОВНЕЙ                             '
@ 01,00 SAY '                                                                             '
@ 02,00 SAY '  MENUC   = ## НОМЕР ПАЛИТРЫ ДЛЯ ФУНКЦИИ C(где nn=MENUC+1,2,3)               '
@ 03,00 SAY '                                                                             '
@ 04,00 SAY '                   Строка  Колонка  Строка меню                              '
@ 05,00 SAY '  DO SUPERMEN WITH ##,     ##,      #                                        '
@ 06,00 SAY '                                                                             '
@ 07,00 SAY '                                                                             '
@ 08,00 SAY '                  Начальная                               Первая   строка    '
@ 09,00 SAY '                  позиция и                               нижнего    меню    '
@ 10,00 SAY '                  ответ        Настроечная таблица        1-3 символа, то    '
@ 11,00 SAY '                  ####,           ###########             нижнее     меню    '
@ 12,00 SAY '                   ABC            12345678901             не  открывается    '
@ 13,00 SAY '                                                                             '
@ 14,00 SAY '  "A"  - НОМЕР ВЕРХНЕГО МЕНЮ      1 0,1,2- ОТ НИЧЕГО ДО ПОЛНОГО ВООСТАНОВЛЕНИЯ'
@ 15,00 SAY '  "BC" - НОМЕР СТРОКИ НИЖНЕГО     2     0- НЕ РИСОВАТЬ ТЕНИ                  '
@ 16,00 SAY '               ПОДМЕНЮ            3 0,1,2- БЕЗ РАМКИ, С ОДИНАРНОЙ ИЛИ ДВОЙНОЙ'
@ 17,00 SAY '                                  4     0- НЕ ЦЕНТРОВАТЬ СТРОКИ НИЖНЕГО МЕНЮ '
@ 18,00 SAY '                                  5   0,1- ШАГ МЕЖДУ СТРОКАМИ НИЖНЕГО МЕНЮ   '
@ 19,00 SAY '                                  6      - СДВИНУТЬ НИЖНЕЕ МЕНЮ ВНИЗ (0-9)   '
@ 20,00 SAY '                                  78     - НОМЕР ЕЩЕ ДОСТУПНОЙ ПРАВОЙ КОЛОНКИ'
@ 21,00 SAY '                                  901    - ДЛИНА ИСПОЛЬЗУЕМЫХ МАССИВОВ       '
@ 22,00 SAY '                                           (равна длине наибольшего меню+1)  '
Te_02SOOB=Te_02SOOB+SPACE(132-LEN(Te_02SOOB))
C(93)
@ 02,12 GET MENUC     PICTURE "99"
@ 05,19 GET Te_02ROW  PICTURE "99"
@ 05,27 GET Te_02COL  PICTURE "99"
@ 05,36 GET Te_02SOOB
@ 11,18 GET Te_02OTV  PICTURE "9999"
@ 11,34 GET Te_02TABL
READ
Te_02SOOB=TRIM(Te_02SOOB)
SET COLOR TO (Te_10C)
FON(.F.)
@ 24,07 SAY "F1  ДЕМОНСТРАЦИЯ ПОМОЩИ      (Выбор стрелками или по первой букве)"
*SET KEY 28 TO HELPDEMO
DO SUPERMEN WITH Te_02ROW,Te_02COL,Te_02SOOB,Te_02OTV,Te_02TABL
*SET KEY 28 TO
SET COLOR TO (Te_61C)
@ 24,07 SAY "                НАЖМИТЕ ЛЮБУЮ КЛАВИШУ, Esc - ВЫХОД                "
SET COLOR TO (Te_63C)
@ 24,46 SAY "Esc"
Te_NUL=INKEY(0)
IF Te_NUL=27
   EXIT
ENDIF
ENDDO
   CASE Te_01GDE=301 && НАСТРОЙКА ЦВЕТОВ
DO COLORINS
Te_61C=C(61) && Подвал
Te_63C=C(63) && Подвал
Te_10C=C(10) && Фон
Te_31C=C(31) && Cообщение
SET KEY 28 TO HELPDEMO
   CASE Te_01GDE=400 .OR. Te_01GDE=000 && ВЫХОД
Te_01GDE=Te_GDE
SAVE TO &Te_FILE ALL LIKE Te_0*
@ 24,0 SAY ""
QUIT
ENDCASE
ENDDO
RETURN
*\(*)/*\(*)/*\(*)/*\(*)/*\*
   PROCEDURE HELPDEMO  && *  ДЛЯ ДЕМОНСТРАЦИИ ДВУХУРОВНЕГО МЕНЮ
*\(*)/*\(*)/*\(*)/*\(*)/*\*
PARAMETER Hlp_PRG, Hlp_NUMB, Hlp_VAR
IF  Hlp_PRG # "SUPERMEN"
     RETURN && ЧТОБЫ НА WAIT НЕ ВЫЙТИ И САМ СЕБЯ НЕ ВЫЗВАТЬ
ENDIF
set curs off
M->ROW=ROW() && КООРДИНАТЫ КУРСОРА НАДО ЖЕ КОНЕЧНО ЗАПОМНИТЬ
M->COL=COL()
Hlp_COLOR=SETCOLOR()
SAVE SCREEN TO Hlp_SCR
*CLEAR
DO CASE
   CASE HLPHLP=01
*       СЛЕДУЯ РЕКОМЕНДАЦИИ SUPERMEN
        RESTSCREEN(Me_ROWT,Me_COLT,Me_ROWT+1,Me_COLT+1,Me_1S)
        Hlp_ROW=25 - M->ROW
        Hlp_COL=80 - M->COL
        CLEAR TYPEAHEAD && ГАШЕНИЕ СИМВОЛОВ
        Hlp_NULS=STR(Me_OTVET,4)
        SOOB(Hlp_ROW,Hlp_COL,"ПОМОЩЬ;ТЕКУЩАЯ ПОЗИЦИЯ;В ПРОГРАММЕ;SUPERMEN;"+Hlp_NULS+";Нажмите любую клавишу ...")
        SET CURSOR OFF
        Hlp_NUL=INKEY(06)
        KEYBOARD(CHR(13))      && ЧТОБЫ ВЫЙТИ ИЗ READ в SUPERMEN
ENDCASE
 SETCOLOR(Hlp_COLOR)
* set curs on
@ M->ROW,M->COL SAY ""
 *CLEAR TYPEAHEAD
 RESTORE SCREEN FROM Hlp_SCR
 RELEASE ALL LIKE Hlp_*
 RETURN
* * * * * * * * * * * * * *         ОЧИСТКА ЭКРАНА
     FUNCTION  FON      &&*  FON(.T.) - Последовательность рамок
* * * * * * * * * * * * * *  FON(.F.) - Сетка
*                            FON()    - Очистка с рамкой по периметру
PARAMETER Fo_T
IF PCOUNT() = 0
   @ 1,1 CLEAR TO 23,78
   @ 0,0       TO 24,79 DOUBLE
ELSE
  IF Fo_T
    Fo_FOR=0
    DO WHILE Fo_FOR < 13
       @  Fo_FOR,Fo_FOR TO 24-Fo_FOR,79-Fo_FOR DOUBLE
          Fo_FOR=Fo_FOR+1
    ENDDO
  ELSE
    Fo_BOX=REPLICATE("┼",9)
    @ 0,0,24,79 BOX Fo_BOX
  ENDIF
ENDIF
RETURN .T.
