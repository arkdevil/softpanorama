* * * * * * * * * * * * * * *  СОЗДАНИЕ ТАБЛИЦЫ ЦВЕТОВ,
*                           *  ЗАПИСЫВАЕМУЮ В В ФАЙЛ.CLR, (типа .MEM)
*    PROCEDURE COLORINS   &&*  ПРИЧЕМ ИМЕНА В ФАЙЛЕ ДОБАВЛЯЮТСЯ
*                           *  АВТОМАТИЧЕСКИ: COLOR01,COLOR02,COLOR03 ...,
* * * * * * * * * * * * * * *  ЕСЛИ ИМЕНА В ФАЙЛЕ УЖЕ СУЩЕСТВУЮТ.
*
* В Клиппере 1987 года почему-то не работает установка цвета рамки...
* К сожалению, перевод на FoxBase затруднен использованием функций
* ACHOICE,ADIR,AINS,ADEL,AFILL,EMPTY,LASTKEY,ISPRINTER,SETCOLOR  и
* SET CURSOR TO, SET KEY ... TO, но полученные файлы *.CLR и функция
* установки цвета C(nn) уже могут быть использованы в FoxBase. Файлы можно
* использовать сразу а функцию С() придется чуть переделать, в ней самой есть
* подсказка, как это сделать.
* CLEAR
SET PROCEDURE TO CC
SET CURSOR OFF
SET KEY 28 TO HELPINS
HLPHLP=1
SET KEY -4 TO PRG_QUIT
IF TYPE("SYSCOLORC") # "C"
   PUBLIC SYSCOLORC
* ДЛИНА СТРОКИ НЕ МЕНЬШЕ 46 СИМВОЛОВ !
SYSCOLORC=CHR(55)+CHR(39)+CHR(39)+CHR(39)+CHR(39)+CHR(97)+CHR(225)+CHR(39)+;
 CHR(39)+CHR(39)+CHR(243)+CHR(115)+CHR(39)+CHR(39)+CHR(39)+CHR(246)+;
 CHR(148)+CHR(39)+CHR(39)+CHR(39)+CHR(145)+CHR(51)+CHR(55)+CHR(245)+;
 CHR(215)+CHR(35)+CHR(39)+CHR(208)+CHR(39)+CHR(39)+CHR(209)+CHR(241)+;
 CHR(144)+CHR(212)+CHR(39)+CHR(213)+CHR(117)+CHR(39)+CHR(39)+CHR(39)+;
 CHR(39)+CHR(35)+CHR(213)+CHR(97)+CHR(55)+CHR(39)
ENDIF
DECLARE Co_MENU[10],Co_MENU40[10],Co_MENU4[06],Co_MAS[40],Co_KAS[40]
Co_QUIT=.F.               && ЕЩЕ НЕ ВЫХОДИТЬ ИЗ ПРОГРАММЫ
* НОМЕРА ИЗОБРАЖЕНИЙ В NASTROY.PRG:
Co_NC1=" 11 15 21 22 25 31 32 35 41 42 45 51 52 53 54 55 61 63 65 71 72 73 74 75 81 82 85 92 93 94 95 "
Co_KOL=LEN(TRIM(Co_NC1))/3 && ЧИСЛО ВЫДАВАЕМЫХ ИЗОБРАЖЕНИЙ NASTROY.PRG
Co_MENU [01]="1 Фон           "
Co_MENU [02]="2 Заголовок     "
Co_MENU [03]="3 Сообщение     "
Co_MENU [04]="4 Сообщение No 2"
Co_MENU [05]="5 Меню          "
Co_MENU [06]="6 Подвал        "
Co_MENU [07]="7 Помощь        "
Co_MENU [08]="8 Предупреждение"
Co_MENU [09]="9 Ввод          "
*
* КАЖДАЯ СТРОКА 2-го МЕНЮ ИЗ 13 СИМВОЛОВ. ( ИНДЕКС_МАССИВА*10+1-я_ЦИФРА_МЕНЮ ) =
* РАВНО НОМЕРУ ОБРАЩЕНИЯ К ФУНКЦИИ C(nn). МОЖНО ЗАБИТЬ ПРОБЕЛАМИ ЛЮБОЕ МЕНЮ И
* ТОГДА ОНО НЕ БУДЕТ ОТОБРАЖАТЬСЯ.
* В КОНЦЕ СТРОКИ ДОЛЖЕН БЫТЬ ДОБАВЛЕН ОДИН ПРОБЕЛ.
*             "1            2            3            4           5             E"
Co_MENU40[01]="1 СООБЩЕНИЕ  2  рамка     3  невыделен 4  выделенный5  бордюр     "
Co_MENU40[02]="1 СООБЩЕНИЕ  2 РАМКА      3  невыделен 4  выделенный5  бордюр     "
Co_MENU40[03]="1 СООБЩЕНИЕ  2 РАМКА      3  невыделен 4  выделенный5  бордюр     "
Co_MENU40[04]="1 СООБЩЕНИЕ  2 РАМКА      3  невыделен 4  выделенный5  бордюр     "
Co_MENU40[05]="1 ЗАГОЛОВОК  2 РАМКА      3 НЕВЫДЕЛЕН  4 ВЫДЕЛЕННЫЙ 5 ПЕРВ.БУКВА  "
Co_MENU40[06]="1 СООБЩЕНИЕ  2  рамка     3 ВЫБРАННЫЙ  4  выделенный5  бордюр     "
Co_MENU40[07]="1 ТЕКСТ      2 РАМКА      3 ВЫБРАННЫЙ  4 ЗАГОЛОВОК  5  бордюр     "
Co_MENU40[08]="1 СООБЩЕНИЕ  2 РАМКА      3  невыделен 4  выделенный5  бордюр     "
Co_MENU40[09]="1  сообщение 2 РАМКА      3 ВЫБРАННЫЙ  4 НЕВЫБРАННЫЙ5  бордюр     "
Co_MENU4L=13
AFILL(Co_MAS, .F.)
AFILL(Co_KAS, .F.)
STROKAC1="N   N+  B   B+  G   G+  BG  BG+ R   R+  RB  RB+ GR  GR+ W   W+  "
STROKAC2="N   B   G   BG  R   RB  GR  W   N*  B*  G*  BG* R*  RB* GR* W*  "
*                    ЧИТАЕТ И ВЫБИРАЕТ 1 COLORxx В SYSCOLORC С ДИСКА
   Co_OTVTABN=1
   Co_OTVIMFN=1
   Co_OTV1   =1
   Co_OTV2   =1
Co_MASKA="*.CLR"
Co_KOLIMF=ADIR(Co_MASKA)
IF Co_KOLIMF > 0
  ADIR(Co_MASKA,Co_MAS)
  ASORT(Co_MAS,1,Co_KOLIMF)
  RELEASE ALL LIKE COLOR*
  NULS=Co_MAS[1]
  RESTORE FROM &NULS ADDITIVE
  IF TYPE("COLOR01") = "C"
     SYSCOLORC=COLOR01
  ENDIF
ENDIF
* ПЕРВОНОЧАЛЬНАЯ ВЫДАЧА ЭКРАНА
FOR Co_IND = 1 TO Co_KOL
    Co_A   = Co_IND*3-2
    Co_NN1 = VAL(SUBSTR(Co_NC1,Co_A))           && НОМЕР ИЗОБРАЖЕНИЯ
    Co_NN2 = INT(Co_NN1/10)*5+MOD(Co_NN1,10)-5  && АДРЕС БАЙТА СО ЦВЕТОМ
    Co_BYTE= SUBSTR(SYSCOLORC,Co_NN2,1)
    DO NASTROY WITH Co_NN1,Co_BYTE
NEXT
* * * * * * * * * * * * * * * * * * * * * * * *
                                  DO WHILE .T.
IF Co_KOLIMF > 0
*                            ЗАПРОС НА ЧТЕНИЕ ФАЙЛА
  C(52)
  @ 13,61 TO 23,78
  @ 14,62 CLEAR TO 22,77
  C(51)
  @ 14,63 SAY "Выберите  файл"
  @ 15,65 SAY "для чтения"
     C(53)
     IF Co_OTVIMFN=0
        Co_OTVIMFN=1
     ENDIF
     NULN=Co_OTVIMFN-1
     IF NULN > 0
        KEYBOARD(REPLICATE(CHR(24),NULN))
     ENDIF
     Co_OTVIMFN=ACHOICE(16,64,22,75,Co_MAS)
  IF Co_OTVIMFN > 0
     Co_OTVIMF  = Co_MAS[Co_OTVIMFN]
     RELEASE ALL LIKE COLOR*
     RESTORE FROM &Co_OTVIMF ADDITIVE
  *                         СКОЛЬКО COLORNN ?
     AFILL(Co_KAS,.F.)
     Co_COLORN=1
     Co_COLORS="COLOR01"
      NULS="'"+Co_COLORS+"'"
     DO WHILE TYPE(&NULS) = "C"
        Co_KAS[Co_COLORN]=Co_COLORS
        Co_COLORN=Co_COLORN+1
        Co_COLORS="COLOR"+SUBSTR(STR(Co_COLORN+100,3),2)
        NULS="'"+Co_COLORS+"'"
     ENDDO
  *                         ВЫБОР КОНКРЕТНОГО COLORNN
    C(52)
    @ 14,62 CLEAR TO 22,77
    C(51)
    @ 14,62 SAY "Выберите таблицу"
    @ 15,65 SAY    "для чтения"
    C(53)
     IF Co_OTVTABN=0
        Co_OTVTABN=1
     ENDIF
    NULN=Co_OTVTABN-1
     IF NULN > 0
        KEYBOARD(REPLICATE(CHR(24),NULN))
     ENDIF
    Co_OTVTABN=ACHOICE(16,64,22,75,Co_KAS)
    IF Co_OTVTABN > 0
       Co_OTVTAB  = Co_KAS[Co_OTVTABN]
       SYSCOLORC=&Co_OTVTAB
  *     ПЕРВОНОЧАЛЬНАЯ ВЫДАЧА ЭКРАНА
        FOR Co_IND = 1 TO Co_KOL
            Co_A   = Co_IND*3-2
            Co_NN1 = VAL(SUBSTR(Co_NC1,Co_A))          && НОМЕР ИЗОБРАЖЕНИЯ
            Co_NN2 = INT(Co_NN1/10)*5+MOD(Co_NN1,10)-5 && АДРЕС БАЙТА СО ЦВЕТОМ
            Co_BYTE= SUBSTR(SYSCOLORC,Co_NN2,1)
            DO NASTROY WITH Co_NN1,Co_BYTE
        NEXT
    ENDIF
  ENDIF
ENDIF
*
     IF Co_OTV1   =0
        Co_OTV1   =1
     ENDIF
    NULN=  Co_OTV1-1
     IF NULN > 0
        KEYBOARD(REPLICATE(CHR(24),NULN))
     ENDIF
   C(52)
   @ 13,61 TO 23,78
   C(53)
   Co_OTV1=ACHOICE(14,62,22,77,Co_MENU)
DO WHILE Co_OTV1 # 0
 DO WHILE Co_OTV2 # 0
*                                     ФОРМИРОВАНИЕ ВТОРОГО МЕНЮ
   Co_STR=Co_MENU40[Co_OTV1]+SPACE(Co_MENU4L)
   Co_LEN=0
   DO WHILE .NOT. EMPTY(Co_STR)
      Co_FORS= SUBSTR(Co_STR,1,Co_MENU4L)
      Co_STR = SUBSTR(Co_STR,Co_MENU4L+1)
      IF .NOT. EMPTY(Co_FORS)
        Co_LEN = Co_LEN+1
        Co_MENU4[Co_LEN]=Co_FORS
      ENDIF
   ENDDO
        Co_MENU4[Co_LEN+1]=.F.         && КОНЕЦ МАССИВА
        Co_OTV20=1
  IF Co_LEN > 0
     ROW=13
     COL=61
     C(52)
                   @ ROW,  COL TO ROW+1+Co_LEN,COL+1+Co_MENU4L
     C(53)
     IF Co_OTV2   =0
        Co_OTV2   =1
     ENDIF
    NULN=  Co_OTV2-1
     IF NULN > 0
        KEYBOARD(REPLICATE(CHR(24),NULN))
     ENDIF
     Co_OTV2=ACHOICE(ROW+1,COL+1, ROW  +Co_LEN,COL  +Co_MENU4L,Co_MENU4)
     IF Co_OTV2 = 0
        EXIT
     ENDIF
     Co_OTV20=VAL(Co_MENU4[Co_OTV2])    && ПЕРВАЯ ЦИФРА ПОДМЕНЮ
  ENDIF
*                                          И НАСТРОЙКА ИЗОБРАЖЕНИЯ
  Co_KAKOE=Co_OTV1*10+Co_OTV20
  Co_KAKOEC=STR(Co_KAKOE,3)
  Co_BYTEN =INT(Co_KAKOE/10)*5+MOD(Co_KAKOE,10)-5
  Co_BYTE  =SUBSTR(SYSCOLORC,Co_BYTEN,1)
  Co_BYTEW =Co_BYTE
  C(41)
  @ 19,61 SAY "┌───────┐┌─────┐"
  @ 20,61 SAY "│ ЦВЕТА └│фона│─┐"
  @ 21,61 SAY "│ символа└--┘ │"
  @ 22,61 SAY "│ EnterвыборEsc│"
  @ 23,61 SAY "└────────────────┘"
  C(42)
  @ 19,61 SAY "┌───────┐┌─────┐"
  @ 20,61 SAY "│"
  @ 20,69 SAY "└│"
  @ 20,73 SAY ""
  @ 20,76 SAY "│─┐"
  @ 21,61 SAY "│"
  @ 21,70 SAY "└--┘"
  @ 21,78 SAY "│"
  @ 22,61 SAY "│"
  @ 22,68 SAY ""
  @ 22,74 SAY ""
  @ 22,78 SAY "│"
  @ 23,61 SAY "└────────────────┘"
* ВЫДАЧА ПАЛИТРЫ:
  Co_KEY=0
  DO WHILE Co_KEY < 16
     Co_NULS=TRIM(SUBSTR(STROKAC1,Co_KEY*4+1,4))+"/N"
     SET COLOR TO (Co_NULS)
     @ 12,61+Co_KEY SAY "█"
     Co_KEY =Co_KEY+1
  ENDDO
  IF Co_KAKOE = 93
    SET CURSOR ON
  ENDIF
     DO NASTROY  WITH Co_KAKOE,Co_BYTE
  Co_QUIT=.F.               && ЕЩЕ НЕ ВЫХОДИТЬ ИЗ ПРОГРАММЫ
  Co_KEY=0
  DO INKEYCOL WITH Co_BYTE,Co_KEY
*                                         ЦИКЛ ВЫБОРА ЦВЕТА
  DO WHILE Co_KEY # 13 .AND. Co_KEY # 27
     DO NASTROY  WITH Co_KAKOE,Co_BYTE
     DO INKEYCOL WITH Co_BYTE,Co_KEY
  ENDDO
  SET CURSOR OFF
  IF Co_KEY = 13 && ВЫБОР
     SYSCOLORC=STUFF(SYSCOLORC,Co_BYTEN,1,Co_BYTE)
  ELSE
     DO NASTROY WITH Co_KAKOE,Co_BYTEW
  ENDIF
  IF Co_LEN=0
     EXIT
  ENDIF
 ENDDO
*
   C(52)
   @ 13,61 TO 23,78
     IF Co_OTV1   =0
        Co_OTV1   =1
     ENDIF
    NULN= Co_OTV1-1

     IF NULN > 0
        KEYBOARD(REPLICATE(CHR(24),NULN))
     ENDIF
   IF Co_OTV2=0
      Co_OTV2=1
   ENDIF
* ... ТЕНЬ:
   SET COLOR TO "W/N"
   @ 12,59 CLEAR TO  12,76
   C(53)
   Co_OTV1=ACHOICE(14,62,22,77,Co_MENU)
ENDDO                                  && КОНЕЦ ЦИКЛА НАСТРОЙКИ ЦВЕТОВ
IF Co_QUIT
   EXIT
ENDIF
* * * * * * * * * * * * * * * * * * * * * * * *
*                 ЗАПИСЬ НАСТРОЕННОЙ ТАБЛИЦЫ ЦВЕТОВ
C(52)
@ 13,61 TO 23,78
@ 14,62 CLEAR TO 22,77
C(51)
@ 14,63 SAY "Выберите  файл"
@ 15,65 SAY "для записи"
   C(53)
   AINS(Co_MAS,1)  && ДОБАВИМ В НАЧАЛО МАССИВА ЭЛЕМЕНТ
   Co_MAS[1] =" Новый файл "
     IF Co_OTVIMFN=0
        Co_OTVIMFN=1
     ENDIF
    NULN=Co_OTVIMFN
     IF NULN > 0
        KEYBOARD(REPLICATE(CHR(24),NULN))
     ENDIF
   Co_OTVIMFN=ACHOICE(16,64,22,75,Co_MAS)
IF Co_OTVIMFN > 0
   Co_OTVIMF  = Co_MAS[Co_OTVIMFN]
   IF Co_OTVIMFN=1
*                         ЗАПРОС ИМЕНИ ФАЙЛА
      C(93)

     Co_OTVIMF="        "
     @ 16,64 SAY Co_OTVIMF+".CLR"
     @ 16,64 GET Co_OTVIMF PICTURE "@Z !!!!!!!!"
     SET CURSOR ON
     READ
     SET CURSOR OFF
     C(11)
     IF .NOT. EMPTY(Co_OTVIMF) .AND. LASTKEY() # 27
         Co_OTVIMF=TRIM(Co_OTVIMF)+".CLR"
         Co_MAS[1]=Co_OTVIMF
         Co_KOLIMF=Co_KOLIMF+1
     ELSE
         ADEL(Co_MAS,1)
     ENDIF
   ELSE
         ADEL(Co_MAS,1)
   ENDIF
   IF .NOT. EMPTY(Co_OTVIMF) .AND. LASTKEY() # 27
*                             ВЫБОР COLORxx
       RELEASE ALL LIKE COLOR*
       IF FILE(Co_OTVIMF)
          RESTORE FROM &Co_OTVIMF ADDITIVE
       ENDIF
*                             СКОЛЬКО COLORNN ?
       AFILL(Co_KAS,.F.)
       Co_COLORN=1
       Co_COLORS="COLOR01"
       NULS="'"+Co_COLORS+"'"
       DO WHILE TYPE(&NULS) = "C"
          Co_KAS[Co_COLORN]=Co_COLORS
          Co_COLORN=Co_COLORN+1
          Co_COLORS="COLOR"+SUBSTR(STR(Co_COLORN+100,3),2)
          NULS="'"+Co_COLORS+"'"
       ENDDO
       Co_KAS[Co_COLORN]="COLOR"+SUBSTR(STR(Co_COLORN+100,3),2)
*                         ВЫБОР КОНКРЕТНОГО COLORNN
       C(52)
       @ 14,62 CLEAR TO 22,77
       C(51)
       @ 14,62 SAY "Выберите таблицу"
       @ 15,62 SAY "   для записи   "
       C(53)
     IF Co_OTVTABN=0
        Co_OTVTABN=1
     ENDIF
    NULN=Co_OTVTABN-1
     IF NULN > 0
        KEYBOARD(REPLICATE(CHR(24),NULN))
     ENDIF
       Co_OTVTABN=ACHOICE(16,64,22,75,Co_KAS)
       IF Co_OTVTABN = 0
          Co_KAS[Co_COLORN+1]=.F.
       ELSE
           Co_COLORN = Co_COLORN+1
*                          ЗАПИСЬ ТАБЛИЦЫ
           Co_COLORS = Co_KAS[Co_OTVTABN]
           &Co_COLORS= SYSCOLORC
           IF FILE (Co_OTVIMF)
              Co_BAKIMF=SUBSTR(Co_OTVIMF,1,AT(".",Co_OTVIMF))+"BAK"
              RENAME &Co_OTVIMF TO &Co_BAKIMF
           ENDIF
           SAVE TO &Co_OTVIMF ALL LIKE COLOR*
       ENDIF
   ENDIF
ELSE
  ADEL(Co_MAS,1)
ENDIF
Co_QUIT=.T.               && МОЖНО И ВЫЙТИ ИЗ ПРОГРАММЫ
ENDDO
*                ВЫВОД ТАБЛИЦЫ ДЛЯ ПЕРЕНОСА В ПРОГРАММУ  COLORINS
*  Co_OTVIMF="0-CLR-0.0-0"
*          IF FILE (Co_OTVIMF)
*             Co_BAKIMF=SUBSTR(Co_OTVIMF,1,AT(".",Co_OTVIMF))+"BAK"
*             RENAME &Co_OTVIMF TO &Co_BAKIMF
*          ENDIF
*  SET PRINT ON
*  SET PRINTER TO &Co_OTVIMF
*  SET CONSOLE OFF
*  ?? "SYSCOLORC="
*  Co_OTVIMF=")+"
*  Co_KOL=LEN(SYSCOLORC)
*  FOR IND=1 TO Co_KOL
*        IF IND=Co_KOL
*           Co_OTVIMF=")"
*        ENDIF
*        ?? "CHR("+LTRIM(STR(ASC(SUBSTR(SYSCOLORC,IND,1)),3))+Co_OTVIMF
*        IF MOD(IND,08)=0
*           ?? ";"
*           ? " "
*        ENDIF
*  NEXT
SET KEY 28 TO
RETURN
* * * * * * * * * * * * * * *
*                           *  ВЫДАЧА НА ДИСПЛЕЙ
     PROCEDURE NASTROY    &&*  НАСТРОЕЧНОГО СООБЩЕНИЯ В ЦВЕТЕ
*                           *
* * * * * * * * * * * * * * *
PARAMETER Na_N,Na_C  && Номер и Цвет в байте
*           КАКОЙ ПРИШЕЛ ЦВЕТ ?
Na_0=ASC(Na_C)
Na_1=INT(Na_0/16)
Na_2=Na_0-Na_1*16
*         0   1   2   3   4   5   6   7   8   9   10  11  12  13  14  15
STROKAC1="N   N+  B   B+  G   G+  BG  BG+ R   R+  RB  RB+ GR  GR+ W   W+  "
STROKAC2="N   B   G   BG  R   RB  GR  W   N*  B*  G*  BG* R*  RB* GR* W*  "
Na_COLOR1=TRIM(SUBSTR(STROKAC1,Na_1*4+1,4))
Na_COLOR2=TRIM(SUBSTR(STROKAC2,Na_2*4+1,4))
Na_COLOR =Na_COLOR1+"/"+Na_COLOR2
*  "Станд., Выд., Бордюр, Фон, Невыбранный"
*IF MOD(Na_N,10)=5  && Бордюр
*                                                        Na_0=SETCOLOR()+" "
*                                           Na_N1=AT(",",Na_0)
*                       Na_1 =SUBSTR(Na_0,1,Na_N1)
*     Na_0 =SUBSTR(Na_0,Na_N1+1)
*                              Na_N1=AT(",",Na_0)
*     Na_1 =Na_1+SUBSTR(Na_0,1,Na_N1)+Na_COLOR1
*           SET COLOR TO (Na_1)
*
*               RETURN
*ELSE
  SET COLOR TO (Na_COLOR)
  @ 20,62 SAY " ЦВЕТА "
  @ 21,62 SAY " символа"
*ENDIF
DO CASE
CASE Na_N = 11  && ФОН            1-Сооб.
@ 00,00 TO 24,79 DOUBLE
@ 00,00 SAY "1"
@ 00,16 SAY "П═Р═О═Г═Р═А═М═М═А═══Н═А═С═Т═Р═О═Й═К═И═══Ц═В═Е═Т═О═В"
*@ 13,61 TO 23,78
* ... ТЕНИ:
SET COLOR TO "W/N"
@ 09,04 CLEAR TO 09,16
@ 17,04 CLEAR TO  17,25
@ 04,32 CLEAR TO  04,46
@ 09,29 CLEAR TO  09,51
@ 17,33 CLEAR TO  17,48
@ 04,53 CLEAR TO  04,77
@ 09,59 CLEAR TO  09,77
@ 12,59 CLEAR TO  12,76
*
@ 02,15 CLEAR TO  08,16
@ 11,24 CLEAR TO  16,25
@ 02,45 CLEAR TO  03,46
@ 07,50 CLEAR TO  08,51
@ 11,47 CLEAR TO  16,48
@ 02,76 CLEAR TO  03,77
@ 07,76 CLEAR TO  08,77
@ 13,59 CLEAR TO  22,60
* ФОН
SET COLOR TO (Na_COLOR)
@ 01,15 CLEAR TO 01,17
@ 01,01 CLEAR TO 23,01
@ 17,02 CLEAR TO 17,03
@ 04,30 CLEAR TO 04,31
@ 01,45 CLEAR TO 01,46
@ 04,51 CLEAR TO 04,52
@ 01,76 CLEAR TO 01,77
@ 06,50 CLEAR TO 06,51
@ 06,76 CLEAR TO 06,77
@ 09,02 CLEAR TO 09,03
@ 09,27 CLEAR TO 09,28
@ 09,57 CLEAR TO 09,58
@ 10,24 CLEAR TO 10,25
@ 10,47 CLEAR TO 10,48
@ 12,77 CLEAR TO 12,78
@ 17,31 CLEAR TO 17,32
@ 23,59 CLEAR TO 23,60
@ 01,17 CLEAR TO 09,26
@ 01,27 CLEAR TO 05,29
@ 01,47 CLEAR TO 04,50
@ 01,78 CLEAR TO 11,78
@ 05,30 CLEAR TO 05,77
@ 10,26 CLEAR TO 17,30
@ 06,52 CLEAR TO 09,56
@ 10,49 CLEAR TO 11,78
@ 12,49 CLEAR TO 17,58
@ 18,02 CLEAR TO 22,58
@ 23,02 CLEAR TO 23,10
@ 19,00 SAY "╠════════╗"
@ 20,00 SAY "║░Смотри,║"
@ 21,00 SAY "║░░как░░░║"
@ 22,00 SAY "║выглядит║"
@ 23,00 SAY "║░░фон░!░║"
@ 24,00 SAY "╚════════╩"
CASE Na_N=21 && ЗАГОЛОВОК      1-Сооб.
 @ 02,32 SAY "2 ЗАГОЛОВОК"
CASE Na_N=22 && ЗАГОЛОВОК               2-Рамка
 @ 01,30 TO 03,44
 @ 02,31 SAY " "
 @ 02,43 SAY " "
CASE Na_N=31 && СООБЩЕНИЕ 1    1-Сооб.
 @ 07,29 SAY "3 C О О Б Щ Е Н И Е"
CASE Na_N=32 && СООБЩЕНИЕ 1             2-Рамка
 @ 06,27 TO 08,49
 @ 07,28 SAY " "
 @ 07,48 SAY " "
CASE Na_N=41 && СООБЩЕНИЕ 2    1-Сооб.
 @ 07,59 SAY "4 еще сообщение"
CASE Na_N=42 && СООБЩЕНИЕ 2             2-Рамка
 @ 07,58 SAY " "
 @ 07,74 SAY " "
 @ 06,57 TO 08,75
CASE Na_N=51 && МЕНЮ           1-Загол.
 @ 11,33 SAY "5  ЗАГОЛОВОК"
CASE Na_N=52 && МЕНЮ                    2-Рамка
 @ 10,31 TO 16,46
 @ 12,31 SAY "├"
 @ 12,32 TO 12,45
 @ 12,46 SAY "┤"
 @ 14,31 SAY "├"
 @ 14,32 TO 14,45
 @ 14,46 SAY "┤"
 @ 11,32 SAY " "
 @ 13,32 SAY " "
 @ 15,32 SAY " "
 @ 11,45 SAY " "
 @ 13,45 SAY " "
 @ 15,45 SAY " "
CASE Na_N=53 && МЕНЮ                             3-Невыделенный
 @ 15,34 SAY "  Меню  No2"
CASE Na_N=54 && МЕНЮ                                           4-Выбранный
 @ 13,33 SAY "5  Меню  No1"
CASE Na_N=55 && МЕНЮ                                                       5-Буква
 @ 15,33 SAY "5"
CASE Na_N=61 && ПОДВАЛ         1-Сооб.
 @ 23,11 SAY " Подвал 6: F1 - Помощь  F5 - Вред   Esc - Выход "
CASE Na_N=63 && ПОДВАЛ                           3-Выделенный
 @ 23,22 SAY "F1"
 @ 23,35 SAY "F5"
 @ 23,47 SAY "Esc"
CASE Na_N=71 && ПОМОЩЬ         1-Текст
 @ 04,03 SAY "Помогите не"
 @ 05,03 SAY "  кричите, "
 @ 06,03 SAY "F1 скорей  "
 @ 07,03 SAY "  нажмите !"
CASE Na_N=72 && ПОМОЩЬ                  2-Рамка
 @ 01,02 TO 08,14
 @ 03,02 SAY "├"
 @ 03,03 TO 03,13
 @ 03,14 SAY "┤"
 @ 02,03 SAY " "
 @ 02,13 SAY " "
CASE Na_N=73 && ПОМОЩЬ                           3-Выделенный
 @ 06,03 SAY "F1"
CASE Na_N=74 && ПОМОЩЬ                                         4-Заголовок
 @ 02,04 SAY "7 Помощь "
CASE Na_N=81 && ПРЕДУПРЕЖДЕНИЕ 1-Сооб.
 @ 11,04 SAY "8 Минздрав России "
 @ 12,05 SAY " ПРЕДУПРЕЖДАЕТ: "
 @ 13,03 SAY "Не программирование "
 @ 14,03 SAY "Не опасно для Вашего"
 @ 15,03 SAY "     здоровья !     "
CASE Na_N=82 && ПРЕДУПРЕЖДЕНИЕ          2-Рамка
 @ 10,02 TO 16,23
 @ 11,03 SAY " "
 @ 11,22 SAY " "
 @ 12,03 SAY "   "
 @ 12,20 SAY "   "
CASE Na_N=92 && ВВОД                    2-Рамка
 @ 01,51 SAY "┌───────┬───────────────┐"
 @ 02,51 SAY "│"
 @ 02,59 SAY "│"
 @ 02,75 SAY "│"
 @ 03,51 SAY "└───────┴───────────────┘"
 @ 02,60 SAY " "
 @ 02,74 SAY " "
CASE Na_N=93 && ВВОД                             3-Выделенный
 @ 02,52 SAY "9 Ввод "
 @ 02,52 SAY ""
CASE Na_N=94 && ВВОД                                           4-Невыбранный
 @ 02,61 SAY "Не выбранный "
*OTHERWISE
ENDCASE
RETURN
* * * * * * * * * * * * * * *
*                           *  ИЗМЕНЕНИЕ ЦВЕТА ПО НАЖАТОЙ КЛАВИШЕ
     PROCEDURE INKEYCOL   &&*  СТРЕЛКА ВВЕРХ/ВНИЗ, ВЛЕВО/ВПРАВО
*                           *
* * * * * * * * * * * * * * *
PARAMETER Ink_COLOR,Ink_KEY &&                                    5
* 1- БАЙТ ЦВЕТА: БУКВА/ФОН,  2- КОД НАЖАТОЙ КЛАВИШИ ПРИ ВЫХОДЕ (27,13, 19  4 )
*         1  4  7  10 13 16
Ink_KEYS=" 19  4 24  5 13 27"
*           КАКОЙ ПРИШЕЛ ЦВЕТ ?
Ink_0=ASC(Ink_COLOR)
Ink_1=INT(Ink_0/16)
Ink_2=Ink_0-Ink_1*16
*IF Ink_1=Ink_2
*   Ink_2=Ink_2-1
*   IF Ink_2 < 0
*      Ink_2 = 15
*   ENDIF
*ENDIF
Ink_KEY=0
Ink_AT=AT(STR(Ink_KEY,3),Ink_KEYS)
DO WHILE Ink_AT=0
   Ink_KEY=INKEY(0)
   IF Ink_KEY=28 .OR. Ink_KEY=-4
      IF Ink_KEY=28
         DO HELPINS WITH "",0,""
      ELSE
         DO PRG_QUIT
      ENDIF
   ENDIF
   Ink_AT=AT(STR(Ink_KEY,3),Ink_KEYS)
ENDDO
IF Ink_AT < 13
   IF Ink_AT < 7
      IF Ink_AT = 1
         Ink_1=Ink_1-1
         IF Ink_1 <  0
            Ink_1 = 15
         ENDIF
      ELSE
         Ink_1=Ink_1+1
         IF Ink_1 > 15
            Ink_1 =  0
         ENDIF
      ENDIF
   ELSE
      IF Ink_AT = 7
         Ink_2=Ink_2-1
         IF Ink_2 <  0
            Ink_2 = 15
         ENDIF
      ELSE
         Ink_2=Ink_2+1
         IF Ink_2 > 15
            Ink_2 =  0
         ENDIF
      ENDIF
   ENDIF
   Ink_COLOR=CHR(Ink_1*16+Ink_2)
ENDIF
RETURN

* * * * * * * * * * * * * * *
*                           *
     PROCEDURE HELPINS    &&* ПОМОЩЬ
*                           *
* * * * * * * * * * * * * * *
PARAMETER Hlp_PRG, Hlp_NUMB, Hlp_VAR
IF  Hlp_PRG="HELP"
     RETURN && ЧТОБЫ НА WAIT НЕ ВЫЙТИ И САМ СЕБЯ НЕ ВЫЗВАТЬ
ENDIF
M->ROW=ROW() && КООРДИНАТЫ КУРСОРА НАДО ЖЕ КОНЕЧНО ЗАПОМНИТЬ
M->COL=COL()
Hlp_COLOR=SETCOLOR()
save SCREEN to Hlp_SCR
set curs off
CLEAR
DO CASE
   CASE HLPHLP=01
   DECLARE Hlp_MAS[25]
C(71)
Hlp_MAS[01]="╔═════════════════ ПОДСКАЗКА ПО ПРОГРАММЕ НАСТРОЙКИ ЦВЕТОВ ════════════════════╗"
Hlp_MAS[02]='║     Программа настройки цветов записывает код цвета  "символ/фон"  элемента  ║'
Hlp_MAS[03]="║ изображения в один из байтов  символьной  переменной  SYSCOLORC,  длиной 37  ║"
Hlp_MAS[04]="║ байтов.  Для кодировки используются две  переменные:  STROKAC1  и  STROKAC2, ║"
Hlp_MAS[05]="║ содержащие таблицы цветов символов и фона.  После настройки таблица  цветов, ║"
Hlp_MAS[06]="║ SYSCOLORC, может записаться на диск в файл типа  *.MEM,  у  которого  будет  ║"
Hlp_MAS[07]="║ расширение .CLR, в переменную COLOR01, а если она уже в файле существует, то ║"
Hlp_MAS[08]="║ можно создать новую переменную COLOR02 и так далее.  Для установки необходи- ║"
Hlp_MAS[09]="║ мого цвета используется функция C(XY), где XY десятичное, двухзначное число  ║"
Hlp_MAS[10]="║ принимающее следующие значения:                                              ║"
Hlp_MAS[11]="╟──────────┬────────────────╥──────────────────────────────────────────────────╢"
Hlp_MAS[12]="║  адр. в  │       X        ║                        Y                         ║"
Hlp_MAS[13]="║ SYSCOLORC├────────────────╫────────┬───────┬────────────┬───────────────┬────╢"
Hlp_MAS[14]="║     1    │1 Фон           ║        │       │            │               │    ║"
Hlp_MAS[15]="║     6    │2 Заголовок     ║1 Сообщ.│2 Рамка│            │               │  Б ║"
Hlp_MAS[16]="║    11    │3 Сообщение     ║1 Сообщ.│2 Рамка│            │               │  о ║"
Hlp_MAS[17]="║    16    │4 Сообщение No 2║1 Сообщ.│2 Рамка│            │               │  р ║"
Hlp_MAS[18]="║    21    │5 Меню          ║1 Загол.│2 Рамка│3 Меню      │(4 Выделенный) │  д ║"
Hlp_MAS[19]="║    26    │6 Подвал        ║1 Сообщ.│       │3 Выделенный│               │  ю ║"
Hlp_MAS[20]="║    31    │7 Помощь        ║1 Текст │2 Рамка│3 Выделенный│ 4 Заголовок   │  р ║"
Hlp_MAS[21]="║    36    │8 Предупреждение║1 Сообщ.│2 Рамка│            │               │    ║"
Hlp_MAS[22]="║    41    │9 Ввод          ║        │2 Рамка│3 Ввод      │(4 Невыбранный)│    ║"
Hlp_MAS[23]="║    56    │Пробел          ║        │       │            │               │    ║"
Hlp_MAS[24]="║          При  каждом  обращении заменяется только один  основной  цвет  и    ║"
Hlp_MAS[25]="╚═F5 - Печать══ только при 53 и 93 заменяется два цвета, а при 10 - все три.═══╝"
FOR Hlp_FOR=1 TO 25
    @ Hlp_FOR-1,0 SAY Hlp_MAS[Hlp_FOR]
NEXT
C(72)    && РАМКА
@ 0,0 TO 24,79 DOUBLE
C(71)    && ОСНОВНОЙ
@ 24,15 SAY " только при 53 и 93 заменяется два цвета, а при 10 - все три."
C(74)    && ЗАГОЛОВОК
@ 00,18 SAY " ПОДСКАЗКА ПО ПРОГРАММЕ НАСТРОЙКИ ЦВЕТОВ "
@ 24,04 SAY " - Печать"
C(73)    && ВЫДЕЛЕННЫЙ
@ 08,36 SAY "XY"
@ 08,45 SAY "XY"
@ 11,19 SAY "X"
@ 11,53 SAY "Y"
@ 24,02 SAY "F5"
Hlp_FOR=INKEY(0)
IF Hlp_FOR=-4 && ПЕЧАТЬ
   IF ISPRINTER()
     SET PRINT ON
     SET CONSOLE OFF
     FOR Hlp_FOR=1 TO 25
         ? Hlp_MAS[Hlp_FOR]
     NEXT
         ? ""
     SET CONSOLE ON
     SET PRINT OFF
   ELSE
      C(81)
      @ 20,04 SAY "╔══════════╗"
      @ 21,04 SAY "║Принтер не║"
      @ 22,04 SAY "║  ГОТОВ   ║"
      @ 23,04 SAY "╚══════════╝"
      C(82)
      @ 20,04 TO 23,15 DOUBLE
      INKEY(5)
   ENDIF
ENDIF
ENDCASE
@ M->ROW,M->COL SAY ""
 *CLEAR TYPEAHEAD
 SETCOLOR(Hlp_COLOR)
 rest scre from Hlp_SCR
* set curs on
 RELEASE ALL LIKE Hlp_*
 RETURN

PROCEDURE PRG_QUIT
 QUIT
RETURN
