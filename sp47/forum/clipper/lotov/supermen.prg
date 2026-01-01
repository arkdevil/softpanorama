*\(*)/*\(*)/*\(*)/*\(*)/*\*   САМОНАСТРАИВАЕМЫЙ      ОШИБКИ    ПРИ   ЗАДАНИИ
*   PROCEDURE SUPERMEN  &&*   ГЕНЕРАТОР    МЕНЮ            ПАРАМЕТРОВ
*\(*)/*\(*)/*\(*)/*\(*)/*\*   ТРЕХ        ВИДОВ      ИСПРАВЛЯЕТ ПО УМОЛЧАНИЮ
*
* Выбор - стрелками или по Первой букве !
*          1        2        3       4        5
 PARAMETER Me_ROW0p,Me_COL0p,Me_VXOD,Me_OTVET,Me_PARAMp
* Не   исправляет   только   параметры  1  и  2,
* в силу чего  возможен  выход за пределы экрана
* верхнего меню и последних строк нижних подменю
*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*
* 1,2 - АДРЕС ЛЕВОГО ВЕРХНЕГО УГЛА МЕНЮ
*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*
*   3 - ИМЯ МАССИВА С ПОРЦИЯМИ СТРОК ПОДМЕНЮ ВИДА:
* "0 ЗАГОЛОВОК 1-го ПОДМЕНЮ"    Структура строки: Цифра Пробел   Сообщение
* "0 ЗАГОЛОВОК 2-го ПОДМЕНЮ"                            или
* "0*ЗАГОЛОВОК 3-го ПОДМЕНЮ"                            Звездочка (коментарий)
* "1    СТРОКА 1-го ПОДМЕНЮ"
* "2    СТРОКА 2-го ПОДМЕНЮ"
* "1    СТРОКА 3-го ПОДМЕНЮ"
* "1    СТРОКА 3-го ПОДМЕНЮ
*  ... ... ... ... ... ...
*  " СТРОКА БЕЗ НОМЕРА " - КОНЕЦ МАССИВА (Обязательно !)     Первая   строка
*  Этот первый вариант можно схематически записать как       нижнего    меню
*    "000111222333 "  - меню из трех подменю.                1-3 символа, то
*  Из первого варианта легко получаются второй и третий:     нижнее     меню
*    "011111111111 "  - меню из одного меню и                не открывается!
*    "000000000000 "  - меню в  одну строку.
*  Масив может быть заменен строковой переменной, строки разделяются ";"
*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*
*  4 - ПРИ ВХОДЕ, ПОСТОЯННО ВО ВРЕМЯ РАБОТЫ (это пригодится для организации
*            Help) И НА ВЫХОДЕ ЕСТЬ ТРЕХЗНАЧНЫЙ НОМЕР "ABC" ВЫБРАННОГО МЕНЮ
*            ИЛИ НОЛЬ ПРИ НАЖАТИИ "Esc":
*            "A"  - НОМЕР ВЕРХНЕГО ПОДМЕНЮ
*            "BC" - НОМЕР СТРОКИ НИЖНЕГО ПОДМЕНЮ                F1
*  ( Несмотря на то, что INKEY(0) не позволяет работать SET KEY 28 TO,
*    SET KEY работает, благодаря хитрому алгоритму; ищи *! . Правда другие
*    функциональные клавиши не работают, а самое СТРАШНОЕ, что в программе HELP
*    необходимо еще послать символ: KEYBOARD(CHR(13)), можете выбросить хитрый
*    алгоритм, но тогда не вызовете свой HELP. В HELP используйте
*    RESTSCREEN(Me_ROWT,Me_COLT,Me_ROWT+1,Me_COLT+1,Me_1S), чтобы воостановить
*    символ, затертый от GET [ приходится сохранять квадрат из четырех
*    символов, так как один символ не сохраняется ! ] )
*
*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*
*  5 - НАСТРОЕЧНАЯ ТАБЛИЦА ИЗ 11 СИМВОЛОВ, ЕСЛИ ПУСТАЯ СТРОКА, ТО ПАРАМЕТРЫ
* No.. БЕРУТСЯ ПО УМОЛЧАНИЮ: "No........"="11111279011"
*  1 = 0,1,2   - 0- НЕ ВООСТАНАВЛИВАТЬ ЭКРАН, 2- ВООСТАНАВЛИВАТЬ, 1- ВЕРХНЕЕ
*   2 = 0      - НЕ РИСОВАТЬ ТЕНИ                                    МЕНЮ
*    3 = 0,1,2 - БЕЗ РАМКИ, С ОДИНАРНОЙ ИЛИ ДВОЙНОЙ РАМКОЙ           ОСТАВИТЬ
*     4 = 0    - НЕ ЦЕНТРОВАТЬ СТРОКИ НИЖНЕГО МЕНЮ
*      5 =0,1  - РАССТОЯНИЕ МЕЖДУ СТРОКАМИ НИЖНЕГО МЕНЮ
*       6      - НА СКОЛЬКО СТРОК СДВИНУТЬ НИЖНЕЕ МЕНЮ ВНИЗ (0-9)
*        78    - НОМЕР ЕЩЕ ДОСТУПНОЙ ПРАВОЙ КОЛОНКИ ЭКРАНА
*          901 - ДЛИНА ИСПОЛЬЗУЕМЫХ МАССИВОВ (равна длине наибольшего меню+1)
*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*
* Внешняя переменная MENUC > 0 - то функция настройки цветов C() вызывает
* номер цвета, как MENUC+1,2,3,4, а иначе база равна 50. При выходе MENUC=0.
*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*
* Для ПЕРЕВОДА В FoxBase:
*     Me_VXOD(     -> &Me_VXOD[  и передавать "имя" массива, как симв. перем.
*     DECLARE      -> DIMENSION
*     Массив[...]  -> Массив(...)
*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*\(*)/*
  Me_COLOR =""
* Me_COLOR1="R+/B"
* Me_COLOR2="B+/W"
* Me_COLOR3="W+/RB"
* Me_COLOR4="B+/W"
* Me_COLOR5="B+/BG"
* Me_COLOR6="W/N+"
IF  TYPE("MENUC") # "N"
   PUBLIC MENUC
          MENUC=0
ENDIF
IF MENUC=0
  Me_COLOR1=C(51)      &&   ВЫДЕЛЕННАЯ СТРОКА ВЕРХНЕГО МЕНЮ
  Me_COLOR2=C(53)      && НЕВЫДЕЛЕННАЯ СТРОКА ВЕРХНЕГО МЕНЮ
  Me_COLOR3=C(54)      &&   ВЫДЕЛЕННАЯ СТРОКА НИЖНЕГО  МЕНЮ
  Me_COLOR4=Me_COLOR2  && НЕВЫДЕЛЕННАЯ СТРОКА НИЖНЕГО  МЕНЮ
  Me_COLOR5=C(52)      && РАМКА И ФОН ОКОН МЕНЮ
  Me_COLOR6="W/N+"     && ЦВЕТ ТЕНИ
  Me_COLOR7=C(55)      && ВЫДЕЛЕННАЯ БУКВА ДЛЯ ПОИСКА
ELSE
  Me_COLOR1=C(MENUC+1)
  Me_COLOR2=C(MENUC+3)
  Me_COLOR3=C(MENUC+4)
  Me_COLOR4=Me_COLOR2
  Me_COLOR5=C(MENUC+2)
  Me_COLOR6="W/N+"
  Me_COLOR7=C(MENUC+5)
ENDIF
* ? "1   ",Me_COLOR1,"2   ",Me_COLOR2,"3   ",Me_COLOR3,"4   ",Me_COLOR4,"5  ",Me_COLOR5,"7  ",Me_COLOR7
Me_1b=""    && Первые буквы    меню для выбора
Me_2b=""    && Первые буквы подменю для выбора
Me_at=0     && строчными буквами - алгоритм выбора по Первой букве
Me_rest=.t. && Воостанавливать экран после выбора меню по первой букве
  Me_ROWT=0
  Me_COLT=0
  Me_SOOT=""
  Me_COLORT=Me_COLOR5
  SET CURSOR OFF
  Me_PARAM=""   && Только для Clipper:
  IF PCOUNT() > 4 && ЧИСЛО ПЕРЕДАННЫХ ПАРАМЕТРОВ ПРОГРАММЕ
     Me_PARAM=Me_PARAMp
  ENDIF
*
*Me_PARAM=TRIM(SUBSTR(Me_PARAMp,1,11))
 Me_PARAM=TRIM(SUBSTR(Me_PARAM ,1,11))
Me_PARAM=Me_PARAM+SUBSTR("11111279011 ",LEN(Me_PARAM)+1)
   Me_SAVESCR= 2         && СОХРАНЯТЬ ЭКРАН
   Me_TENI   =.T.        && РИСОВАТЬ ТЕНИ
   Me_RAMKA  = 1         && РИСОВАТЬ РАМКУ
   Me_CENTR  =.T.        && ЦЕНТРИРОВАТЬ СТРОКИ В МЕНЮ
   Me_CHAG   = 2         && ШАГ МЕЖДУ СТРОКАМИ НИЖНЕГО МЕНЮ
   Me_SDVIG  = 2         && СДВИГ НИЖНЕГО МЕНЮ
   Me_COLR   = 79        && ПРАВАЯ ГРАНИЦА
   Me_IDLS   = "11"      && ДЛИНА МАССИВОВ
Me_SAVESCR=VAL(SUBSTR(Me_PARAM,1,1))
IF VAL(SUBSTR(Me_PARAM,2,1))=0
   Me_TENI   =.F.
ENDIF
Me_RAMKA=VAL(SUBSTR(Me_PARAM,3,1))
IF VAL(SUBSTR(Me_PARAM,4,1))=0
   Me_CENTR  =.F.
ENDIF
Me_CHAG =VAL(SUBSTR(Me_PARAM,5,1))
Me_CHAG=Me_CHAG+1
IF Me_CHAG > 2
   Me_CHAG = 2
ENDIF
Me_SDVIG=VAL(SUBSTR(Me_PARAM,6,1))
Me_NULN1=VAL(SUBSTR(Me_PARAM,7,2))
IF Me_NULN1 > 2
   Me_COLR = MIN(Me_NULN1,79)
ENDIF
   Me_COLR = Me_COLR-2
Me_STR=SUBSTR(Me_PARAM,9,3)
IF Me_STR   > " 11"
   Me_IDLS  = Me_STR
ENDIF
Me_KEYS=" 24  4  5 19 13 27" && ВОСПРИНИМАЕМЫЕ КЛАВИШИ
Me_ROW0    = Me_ROW0p
*******************************
*IF Me_ROW0 < 1
*   Me_ROW0 = 1
*ENDIF
Me_COL0    = Me_COL0p
IF Me_COL0 < 2
   Me_COL0 = 2
ENDIF
Me_INKEY=0
Me_KOL=0    && ЧИСЛО ПOДМЕНЮ
* Me_MAS01  -  АДРЕСА СТРОК   ВЕРХНЕГО МЕНЮ
* Me_MAS02  -  АДРЕСА КОЛОНОК ВЕРХНЕГО МЕНЮ
* Me_MAS1   -  АДРЕСА ЛЕВЫХ  ВЕРХНИХ УГЛОВ
* Me_MAS2   -         ПОРЦИЙ ПОДМЕНЮ
* Me_ADR    -  АДРЕСА ПОРЦИЙ ПОДМЕНЮ
* Me_OPEN   -  ОТКРЫВАТЬ ПОДМЕНЮ ?
* Me_LENMEN -  ШИРИНА КАЖДОГО ПОДМЕНЮ
*DIMENSION Me_MAS01(&Me_IDLS),Me_MAS02(&Me_IDLS),Me_MAS1(&Me_IDLS),;
*          Me_MAS2(&Me_IDLS),Me_ADR(&Me_IDLS),Me_OPEN(&Me_IDLS),Me_LENMEN(&Me_IDLS)
 Me_IDLS=VAL(Me_IDLS)
 DECLARE   Me_MAS01[Me_IDLS],Me_MAS02[Me_IDLS],Me_MAS1[Me_IDLS],Me_MAS2[Me_IDLS],;
           Me_ADR[Me_IDLS],Me_OPEN[Me_IDLS],Me_LENMEN[Me_IDLS]
 AFILL(Me_OPEN,.F.) && Clipper
Me_MASSIV="Me_VXOD"
IF TYPE("Me_VXOD")="C"    && ПЕРЕВОД СТРОКИ В МАССИВ
  Me_MASSIV="Me_VXOD1"
  Me_NUL2=Me_IDLS*2+1
  DECLARE Me_VXOD1[Me_NUL2]
  Me_VXOD1[Me_NUL2]=""
  Me_NULS=Me_VXOD+";;"
  Me_NUL1=1
  DO WHILE .NOT. EMPTY(Me_NULS) .AND. Me_NUL1 < Me_NUL2
     Me_NSTR=AT(";",Me_NULS)
     Me_VXOD1[Me_NUL1]=SUBSTR(Me_NULS,1,Me_NSTR-1)
     Me_NULS           =SUBSTR(Me_NULS,  Me_NSTR+1)
     Me_NUL1=Me_NUL1+1
  ENDDO
ENDIF
*SET STATUS OFF
*SET SCOREBOARD OFF
* SET COLOR TO &Me_COLOR5 && ОСНОВНОЙ ФОН
* CLEAR
*     ЗАПОЛНЕНИЕ МАССИВОВ И ВЫДАЧА ВЕРХНЕЙ СТРОКИ МЕНЮ
Me_ROW1=Me_ROW0+3+Me_SDVIG  && НАЧАЛЬНАЯ СТРОКА ДЛЯ ПОДМЕНЮ
Me_COL1=Me_COL0
Me_NSTR=1
Me_EOF=.T.
Me_RIGHT=Me_COL1
SAVE SCREEN  && 01
Me_OPENSUP=.F.                             && МЕНЮ НЕ ОТКРЫВАТЬ
DO WHILE .T.                               && ВЕРХНЕЕ МЕНЮ
  Me_STR =&Me_MASSIV[Me_NSTR]
  Me_LEN =LEN(Me_STR)
  Me_LENW=Me_LEN
  IF Me_LEN <= 3
     Me_STR = SUBSTR(Me_STR+"  ",1,3)
     &Me_MASSIV[Me_NSTR]=Me_STR
     Me_LEN = LEN(Me_STR)
  ENDIF
  Me_NNN =ABS(ASC(Me_STR)-48) && 0123456789
  IF Me_EOF .AND. Me_NNN # 0
     Me_NNN=0
     Me_STR='0 Меню должно начинаться с "0" !'
     Me_LEN=LEN(Me_STR)
     &Me_MASSIV[Me_NSTR  ]=Me_STR
     &Me_MASSIV[Me_NSTR+1]=""
  ENDIF
  if substr(Me_str,2,1) # "*"
     Me_1b=Me_1b+substr(Me_str,3,1)
  else
     Me_1b=Me_1b+" "
  endif
  IF Me_NNN = 0
     IF SUBSTR(Me_STR,2,1) # "*"
        Me_OPENSUP=.T.
     ENDIF
     Me_KOL =Me_KOL +1
     IF Me_COL1+Me_LEN   > Me_COLR
        Me_COL1=Me_COL0
        Me_ROW0=Me_ROW0+2
        Me_ROW1=Me_ROW1+2
     ENDIF
     Me_MAS1 [ Me_KOL ]   = Me_ROW1
     Me_MAS01[ Me_KOL ]   = Me_ROW0
     Me_MAS02[ Me_KOL ]   = Me_COL1
     Me_COL1 = Me_COL1    + Me_LEN - 1
     Me_RIGHT=MAX(Me_RIGHT,Me_COL1)
  ENDIF
  IF Me_NNN # 0 .OR. Me_KOL+1 >= Me_IDLS
     Me_MAS1 [ Me_KOL+1 ] = Me_ROW1
     Me_MAS01[ Me_KOL+1 ] = Me_ROW0
     Me_MAS02[ Me_KOL+1 ] = Me_COL1
     EXIT
  ENDIF
  Me_NSTR=Me_NSTR+1
  Me_EOF=.F.
ENDDO
do perekod with Me_1b,sysb && строчные -> в ПРОПИСНЫЕ
IF .NOT. Me_OPENSUP
   Me_OTVET=0
ENDIF
Me_NMENU =INT(Me_OTVET/100)
IF Me_NMENU = 0  && НОМЕР ПОДМЕНЮ
   Me_NMENU = 1
ENDIF
Me_NNMENU=MOD(Me_OTVET,100)
IF Me_NNMENU = 0
   Me_NNMENU = 1 && НОМЕР СТРОКИ В МЕНЮ
ENDIF
*                                    РАМКА ДЛЯ ВЕРХНЕГО МЕНЮ:
  Me_SDVIG=0
  Me_NULN1=MAX(Me_MAS01[ 1 ]-1,0)
  Me_NULN2=Me_MAS01[Me_KOL]+1
  Me_HAD  =Me_MAS01[Me_KOL]+2
  IF Me_NULN1=0 .AND. Me_NULN2=1
     Me_SDVIG=-1
     Me_NULN2=0
     Me_HAD  =1    && ДЛЯ СДВИГА ТЕНИ ВНИЗ ВЕРХНЕГО МЕНЮ
  ENDIF
  SET COLOR TO &Me_COLOR5
    @ Me_NULN1,Me_MAS02[1]-2 CLEAR TO Me_NULN2,Me_RIGHT
  IF Me_RAMKA=1
    @ Me_MAS01[ 1 ]-1,Me_MAS02[1]-2       TO Me_MAS01[Me_KOL]+1,Me_RIGHT
  ENDIF
  IF Me_RAMKA > 1
    @ Me_MAS01[ 1 ]-1,Me_MAS02[1]-2       TO Me_MAS01[Me_KOL]+1,Me_RIGHT DOUBLE
  ENDIF
  IF Me_TENI
    SET COLOR TO &Me_COLOR6
    @ Me_MAS01[ 1 ]  ,Me_RIGHT+1 CLEAR TO Me_HAD,Me_RIGHT+2 && ТЕНЬ
                Me_COLSHAD=Me_MAS02[1]
    @ Me_HAD,Me_COLSHAD          CLEAR TO Me_HAD,Me_RIGHT+2 && ТЕНЬ
  ENDIF
Me_NULN1=1
DO WHILE Me_NULN1 <= Me_KOL      &&  ВЫДАЧА СТРОК ВЕРХНЕГО МЕНЮ
   SET COLOR TO &Me_COLOR2 && СТРОКА ВЕРХНЕГО МЕНЮ
   Me_NULS=SUBSTR(&Me_MASSIV[Me_NULN1],3)
   @ Me_MAS01[Me_NULN1],Me_MAS02[Me_NULN1] SAY Me_NULS
   SET COLOR TO &Me_COLOR7
   @ Me_MAS01[Me_NULN1],Me_MAS02[Me_NULN1] SAY SUBSTR(Me_NULS,1,1)
   Me_NULN1=Me_NULN1+1
ENDDO
IF Me_COLR < Me_RIGHT
   Me_COLR = Me_RIGHT
ENDIF
Me_NSTR1 =1
Me_KOL1  =0
Me_LENMAX=Me_LEN                  && ШИРИНА ПОДМЕНЮ
*  ЕСТЬ ЛИ ПОДМЕНЮ ВООБЩЕ ?
         Me_EOFW=.T.
IF   ABS (ASC( &Me_MASSIV[Me_NSTR] )-48) > 9
         Me_EOFW=.F.
ENDIF
Me_NSTRW =Me_NSTR
Me_NNN1  =Me_NNN
         Me_EOF = Me_EOFW         && НИЖНЕЕ МЕНЮ
DO WHILE Me_EOFW                  && СКАНИРОВАНИЕ НИЖНЕГО ПОДМЕНЮ
   IF Me_NNN1  # Me_NNN           && 1-ЫЙ СИМВОЛ ПОДМЕНЮ
      Me_KOL1  = Me_KOL1 + 1      && СКОЛЬКО СЧИТАНО ПОДМЕНЮ
      IF Me_KOL1 > Me_KOL
         EXIT
      ENDIF
*                                    ОТКРЫВАТЬ ПОДМЕНЮ ?
      IF Me_LENW <= 3
         Me_OPEN1=.F.
      ELSE
         Me_OPEN1=.T.
      ENDIF
         Me_OPEN   [Me_KOL1]=Me_OPEN1
      Me_NNN1  = Me_NNN
      Me_ADR[Me_NSTR1]=Me_NSTRW && АДРЕС N-ОЙ ПОРЦИИ ПОДМЕНЮ
                       Me_NSTRW=Me_NSTR
*     РАЗМЕСТИТЬ ПОДМЕНЮ ПО ЦЕНТРУ ЗАГОЛОВКА
      Me_NUL1=Me_MAS02[Me_NSTR1]
      Me_NUL2=Me_MAS02[Me_NSTR1+1]
      IF Me_NUL2 <= Me_NUL1
         Me_NUL2 = Me_RIGHT  +01
      ENDIF
      Me_NUL2=Me_NUL1+INT( (Me_NUL2-Me_NUL1-Me_LENMAX)/2 )
*
      IF Me_NUL2 + Me_LENMAX > Me_COLR
         Me_NUL2 = Me_COLR   - Me_LENMAX + 01
      ENDIF
      IF Me_NUL2 < 2            && ЗАЩИТА ОТ ВЫХОДА ЗА ПРЕДЕЛЫ ЭКРАНА
         Me_NUL2 = 2
      ENDIF
      Me_MAS1[Me_NSTR1]=Me_ROW1
      Me_MAS2[Me_NSTR1]=Me_NUL2
      Me_LENMEN[Me_NSTR1]=Me_LENMAX
                          Me_LENMAX=0
                          Me_LENW  =Me_LEN
              Me_NSTR1 =Me_NSTR1+1
   ENDIF
   IF .NOT. Me_EOF .OR. Me_NSTR1 >= Me_IDLS && ВЫХОД НА СЛЕДУЮЩЕМ ЦИКЛЕ
      EXIT
   ENDIF
   Me_NSTR=Me_NSTR+1
   Me_STR =&Me_MASSIV[Me_NSTR]
   Me_NNN =ABS(ASC(Me_STR)-48) && 0123456789
   Me_LENMAX=MAX(Me_LENMAX,Me_LEN)
   Me_LEN =LEN(Me_STR)-1
   IF Me_LEN <= 2
      Me_STR = SUBSTR(Me_STR+"  ",1,3)
      &Me_MASSIV[Me_NSTR]=Me_STR
      Me_LEN = LEN(Me_STR)
   ENDIF
   IF Me_NNN >  9
      Me_EOF = .F.            && ВЫЙТИ НА СЛЕДУЮЩЕМ ЦИКЛЕ
   ENDIF
ENDDO
* Me_STR - ПОСЛЕДНЯЯ СТРОКА:
         Me_EOF = Me_EOFW
*                           ЗАЩИТА:
*IF Me_EOF
*  IF Me_KOL1  < Me_NMENU && ЗАЩИТА ОТ ЗАШКАЛИВАНИЯ ПО ЧИСЛУ ПОДМЕНЮ
*     Me_NMENU = Me_KOL1
*  ENDIF
* IF Me_KOL1  < Me_KOL   && ВЕРХНЕЕ МЕНЮ ДОЛЖНО БЫТЬ НЕ БОЛЬШЕ, ЧЕМ
*    Me_KOL   = Me_KOL1  && ЧИСЛО НИЖНИХ ПОДМЕНЮ
* ENDIF
*ENDIF
IF Me_KOL   < Me_NMENU   && ЗАДАННЫЙ НОМЕР ПОДМЕНЮ НЕ БЫЛ БЫ БОЛЬШЕ, ЧЕМ
   Me_NMENU = Me_KOL     && ВЕРХНИХ МЕНЮ
ENDIF
Me_ADR[Me_NSTR1]=Me_NSTR
*                    ЦИКЛ  МЕНЮ
IF Me_OPENSUP
   Me_VID=.F. && НЕТ НИЧЕГО, ЧТО МОЖНО ВЫДЕЛИТЬ
   Me_PLUS=1
   Me_NMENU=Me_NMENU-1
*  ЦИКЛ ВЫБОРА ОЧЕРЕДНОЙ АЛЬТЕРНАТИВЫ В ВЕРХНЕМ МЕНЮ
   DO WHILE .NOT. Me_VID
      Me_NMENU = Me_NMENU + Me_PLUS
      IF Me_NMENU > Me_KOL             && ВОЗВРАТ К 1-МУ ПОДМЕНЮ
         Me_NMENU = 1                  && НОМЕР ПОДМЕНЮ В МЕНЮ
      ENDIF
      IF   Me_NMENU = 0
           Me_NMENU = Me_KOL           && НОМЕР ПОДМЕНЮ В МЕНЮ
      ENDIF
      IF SUBSTR(&Me_MASSIV[Me_NMENU],2,1) # "*" && КОММЕНТАРИЙ
         Me_VID=.T.
      ENDIF
   ENDDO
   SET COLOR TO &Me_COLOR1 && ВЫДЕЛЕННАЯ СТРОКА ВЕРХНЕГО МЕНЮ
   Me_COLORT=Me_COLOR1
   Me_ROWT=Me_MAS01[Me_NMENU]
   Me_COLT=Me_MAS02[Me_NMENU]
   Me_SOOT=SUBSTR(&Me_MASSIV[Me_NMENU],3)
   @ Me_ROWT,Me_COLT SAY Me_SOOT
ENDIF
   Me_MIN = 0
   Me_MAX = 0
   Me_ROW = 0
   Me_COL = 0
   IF Me_EOFW .AND. Me_KOL > 1        && ЕСТЬ ПОДМЕНЮ
      Me_EOF =.F.
   ENDIF
 Me_OPEN1=.T.
*
*
           Me_CYCL  = .T.             && ЧТОБЫ ПРИ ВЫБОРЕ ВЫЙТИ ИЗ ЦИКЛА
 DO WHILE  Me_CYCL          && ГЛАВНЫЙ ЦИКЛ: ВЛЕВО/ВПРАВО ПО ВЕРХНЕМУ МЕНЮ
 SAVE SCREEN TO Me_SCREEN   && 02
 IF Me_EOF .AND. Me_OPEN1
   Me_MIN  = Me_ADR[Me_NMENU]         && ДИАПАЗОН СТРОК СО СТРОКАМИ ПОДМЕНЮ
   Me_MAX  = Me_ADR[Me_NMENU+1]-1
   Me_ROW  =Me_MAS1[Me_NMENU]+Me_SDVIG && ЛЕВЫЙ ВЕРХНИЙ УГОЛ
   Me_COL  =Me_MAS2[Me_NMENU]
   Me_NSTR=Me_MIN
   Me_LENMIN=Me_LENMEN[Me_NMENU]-1
   SET COLOR TO &Me_COLOR5
   Me_NULN1=Me_ROW+(Me_MAX-Me_NSTR)*Me_CHAG+1
   Me_PRAVO=Me_COL+Me_LENMIN+1
     @ Me_ROW-1,Me_COL-2 CLEAR TO Me_NULN1  ,Me_PRAVO
   IF Me_RAMKA > 0
     IF Me_RAMKA=1
       @ Me_ROW-1,Me_COL-2       TO Me_NULN1  ,Me_PRAVO && РАМКА ПОДМЕНЮ
       Me_NULS="─"
       Me_NULS1="├"
       Me_NULS2="┤"
     ENDIF
     IF Me_RAMKA > 1
       @ Me_ROW-1,Me_COL-2       TO Me_NULN1  ,Me_PRAVO DOUBLE
       Me_NULS="═"
       Me_NULS1="╠"
       Me_NULS2="╣"
     ENDIF
*                                         ЛИНИИ МЕЖДУ АЛЬТЕРНАТИВАМИ ПОДМЕНЮ
     Me_FOR=Me_ROW+1
     DO WHILE Me_FOR < Me_NULN1 .AND. Me_CHAG > 1
       @ Me_FOR,Me_COL-2 SAY Me_NULS1
       @ Me_FOR,Me_PRAVO SAY Me_NULS2
       @ Me_FOR,Me_COL-1 SAY REPLICATE(Me_NULS,Me_PRAVO-Me_COL+1)
       Me_FOR=Me_FOR+2
     ENDDO
   ENDIF
        Me_OPENALT = .F.
        Me_ROW1=Me_ROW -Me_CHAG
   Me_2b=""
   DO WHILE Me_NSTR <= Me_MAX          &&  ВЫДАЧА СТРОК ПОДМЕНЮ
     Me_ROW1=Me_ROW1+Me_CHAG
     Me_NULS=&Me_MASSIV[Me_NSTR]
     IF SUBSTR(Me_NULS,2,1) # "*"
        Me_OPENALT = .T.
        Me_2b=Me_2b+substr(Me_nuls,3,1)
     else
        Me_2b=Me_2b+" "
     ENDIF
     Me_NULS=SUBSTR(Me_NULS,3,Me_LENMIN)
     Me_NUL1=Me_COL
     IF Me_CENTR
        Me_NUL1=Me_COL+(Me_PRAVO-Me_COL-LEN(Me_NULS)-1)/2
     ENDIF
     SET COLOR TO &Me_COLOR4             && НЕВЫДЕЛЕННЫЕ СТРОК ПОДМЕНЮ
     @ Me_ROW1,Me_NUL1 SAY Me_NULS
     SET COLOR TO &Me_COLOR7
     @ Me_ROW1,Me_NUL1 SAY SUBSTR(Me_NULS,1,1)
     Me_NSTR = Me_NSTR + 1
   ENDDO
   do perekod with Me_2b,sysb && строчные -> в ПРОПИСНЫЕ
   Me_ROW2=Me_ROW1 && ПОСЛЕДНЯЯ СТРОКА ПОДМЕНЮ
   IF Me_TENI
     SET COLOR TO &Me_COLOR6
     @ Me_ROW   ,Me_COL+Me_LENMIN+2 CLEAR TO Me_ROW2+2,Me_COL+Me_LENMIN+3 && ТЕНЬ
     @ Me_ROW2+2,Me_COL             CLEAR TO Me_ROW2+2,Me_COL+Me_LENMIN+3 && ТЕНЬ
     SET COLOR TO &Me_COLOR1
   ENDIF
*
      Me_NUL1   = Me_MAX - Me_MIN + 1
   IF Me_NUL1   < Me_NNMENU
      Me_NNMENU = Me_NUL1
   ENDIF
   Me_NSTR=Me_MIN+Me_NNMENU-1
   Me_ROW1=Me_ROW+Me_NNMENU*Me_CHAG-Me_CHAG
   Me_COL1=Me_COL
   IF Me_OPENALT
        Me_VID=.F. && НЕТ НИЧЕГО, ЧТО МОЖНО ВЫДЕЛИТЬ
        Me_PLUS=1
        Me_NSTR=Me_NSTR-1  && ПОДГОТОВКА ПЕРЕД НАЧАЛОМ ЦИКЛА
        Me_ROW1  = Me_ROW1  -Me_PLUS*Me_CHAG
        Me_NNMENU= Me_NNMENU-Me_PLUS
*       ЦИКЛ ВЫБОРА ОЧЕРЕДНОЙ АЛЬТЕРНАТИВЫ В ВЕРХНЕМ МЕНЮ
        DO WHILE .NOT. Me_VID
              Me_NSTR  = Me_NSTR  +Me_PLUS
              Me_ROW1  = Me_ROW1  +Me_PLUS*Me_CHAG
              Me_NNMENU= Me_NNMENU+Me_PLUS
           IF Me_NSTR  > Me_MAX
              Me_NSTR  = Me_MIN         && НА НАЧАЛО
              Me_ROW1  = Me_ROW
              Me_NNMENU=1
           ENDIF
           IF Me_NSTR  < Me_MIN
              Me_NSTR  = Me_MAX        && В КОНЕЦ
              Me_ROW1  = Me_ROW2
              Me_NNMENU=Me_MAX-Me_MIN+1
           ENDIF
           IF SUBSTR(&Me_MASSIV[Me_NSTR],2,1) # "*" && КОММЕНТАРИЙ
              Me_VID=.T.
           ENDIF
        ENDDO
        SET COLOR TO &Me_COLOR3   && ВЫДАЧА ПЕРВОЙ ВЫДЕЛЕННОЙ СТРОКИ ПОДМЕНЮ
        Me_COLORT=Me_COLOR3
        Me_ROWT=Me_ROW1
        Me_COLT=Me_COL1
        Me_SOOT=SUBSTR(&Me_MASSIV[Me_NSTR],3,Me_LENMIN)
        IF Me_CENTR
           Me_COLT=Me_COLT+(Me_PRAVO-Me_COLT-LEN(Me_SOOT)-1)/2
        ENDIF
        @ Me_ROWT,Me_COLT SAY Me_SOOT
   ENDIF
*
   Me_INKEY=0
*                  ВВЕРХ / ВНИЗ ПО ПОДМЕНЮ
*                  НЕ СТРЕЛКИ ВЛЕВО ВПРАВО
   DO WHILE Me_INKEY  # 19 .AND. Me_INKEY  # 4 .AND. Me_EOF .AND. Me_OPEN1
          IF Me_OPENALT
            Me_OTVET = Me_NMENU*100+Me_NNMENU
          ELSE
            IF Me_OPENSUP
              Me_OTVET = Me_NMENU*100
            ENDIF
          ENDIF
*!* ХИТРЫЙ АЛГОРИТМ, ЧТОБЫ ЗАСТАВИТЬ ПРОГРАММУ РЕАГИРОВАТЬ НА SET KEY 28 TO:
            Me_INKEY=INKEY(0)                    && ЗАПРОС В НИЖНИХ ПОДМЕНЮ
            IF .NOT. STR(Me_INKEY,3) $ Me_KEYS .AND. Me_INKEY > 0 .AND. Me_INKEY < 32
                Me_NULS =" "
                KEYBOARD(CHR(Me_INKEY)+CHR(13))
                Me_1S=SAVESCREEN(Me_ROWT,Me_COLT,Me_ROWT+1,Me_COLT+1)
                @ Me_ROWT,Me_COLT GET Me_NULS
                READ
                SET COLOR TO &Me_COLORT
                @ Me_ROWT,Me_COLT SAY Me_SOOT
            ENDIF
            Me_at=at(perekod(chr(Me_inkey),sysb),Me_2b)
            Me_rest=.t.
            if Me_at > 0 .and. Me_inkey > 32
               if Me_nnmenu # Me_at
*                                                СНЯТИЕ ВЫДЕЛЕНИЯ СО СТРОКИ
                  SET COLOR TO &Me_COLOR4 &&                  НИЖНЕГО МЕНЮ
                  @ Me_ROWT,Me_COLT SAY Me_SOOT
                  SET COLOR TO &Me_COLOR7
                  @ Me_ROWT,Me_COLT SAY SUBSTR(Me_SOOT,1,1)
                  if Me_savescr # 1
                     Me_rest=.f.
                  endif
               endif
               Me_nul1=Me_at-Me_nnmenu      && длина перепада
               Me_nstr=Me_nstr+Me_nul1
               Me_nnmenu=Me_at
               Me_inkey=13
                  SET COLOR TO &Me_COLOR3   && ВЫДАЧА ВЫДЕЛЕННОЙ СТРОКИ ПОДМЕНЮ
                  Me_COLORT=Me_COLOR3
                  Me_ROWT=Me_ROW1 + Me_nul1*Me_CHAG
                  Me_COLT=Me_COL1
                  Me_SOOT=SUBSTR(&Me_MASSIV[Me_NSTR],3,Me_LENMIN)
                  IF Me_CENTR
                     Me_COLT=Me_COLT+(Me_PRAVO-Me_COLT-LEN(Me_SOOT)-1)/2
                  ENDIF
                  @ Me_ROWT,Me_COLT SAY Me_SOOT
            endif
*!*
      IF Me_INKEY = 27                      && ВЫХОД ПО Esc
            Me_OTVET = 0
            Me_CYCL=.F.
            EXIT
      ENDIF
      IF Me_INKEY = 13 .AND. Me_OPENALT     && ВЫБОР
         Me_OTVET = Me_NMENU*100+Me_NNMENU
         Me_CYCL=.F.
         EXIT
      ENDIF
      IF (Me_INKEY = 24 .OR. Me_INKEY = 5) .AND. Me_OPENALT && СТРЕЛКИ ВВЕРХ ВНИЗ
            SET COLOR TO &Me_COLOR4 && СНЯТИЕ ВЫДЕЛЕНИЯ СО СТРОКИ
            Me_COLORT=Me_COLOR4
            Me_ROWT=Me_ROW1
            Me_COLT=Me_COL1
            Me_SOOT=SUBSTR(&Me_MASSIV[Me_NSTR],3,Me_LENMIN)
            IF Me_CENTR
               Me_COLT=Me_COLT+(Me_PRAVO-Me_COLT-LEN(Me_SOOT)-1)/2
            ENDIF
            @ Me_ROWT,Me_COLT SAY Me_SOOT
            SET COLOR TO &Me_COLOR7
            @ Me_ROWT,Me_COLT SAY SUBSTR(Me_SOOT,1,1)
        Me_PLUS=1
        IF  Me_INKEY = 5                    && СТРЕЛКА ВВЕРХ
            Me_PLUS  =-1
        ENDIF
*       ЦИКЛ ВЫБОРА ОЧЕРЕДНОЙ АЛЬТЕРНАТИВЫ В НИЖНЕМ МЕНЮ
        Me_NNMENUW=Me_NNMENU
        Me_VID=.F. && НЕТ НИЧЕГО, ЧТО МОЖНО ВЫДЕЛИТЬ
        DO WHILE .NOT. Me_VID
           Me_NSTR   =Me_NSTR  +Me_PLUS
           Me_ROW1   =Me_ROW1  +Me_PLUS*Me_CHAG
           Me_NNMENU =Me_NNMENU+Me_PLUS
           IF Me_NNMENUW=Me_NNMENU
              Me_VID =.T.
              EXIT
           ENDIF
           IF Me_NSTR  > Me_MAX
              Me_NSTR  = Me_MIN         && НА НАЧАЛО
              Me_ROW1  = Me_ROW
              Me_NNMENU=1
           ENDIF
           IF Me_NSTR  < Me_MIN
              Me_NSTR  = Me_MAX         && В КОНЕЦ
              Me_ROW1  = Me_ROW2
              Me_NNMENU=Me_MAX-Me_MIN+1
           ENDIF
           IF SUBSTR(&Me_MASSIV[Me_NSTR],2,1) # "*" && КОММЕНТАРИЙ
              Me_VID=.T.
           ENDIF
        ENDDO
*                                 ВЫДЕЛЕНИЕ ОЧЕРЕДНОЙ СТРОКИ
            SET COLOR TO &Me_COLOR3 && ВЫДЕЛЕННАЯ СТРОКА ПОДМЕНЮ
            Me_COLORT=Me_COLOR3
            Me_ROWT=Me_ROW1
            Me_COLT=Me_COL1
            Me_SOOT=SUBSTR(&Me_MASSIV[Me_NSTR],3,Me_LENMIN)
            IF Me_CENTR
               Me_COLT=Me_COLT+(Me_PRAVO-Me_COLT-LEN(Me_SOOT)-1)/2
            ENDIF
            @ Me_ROWT,Me_COLT SAY Me_SOOT
      ENDIF      && ENDIF СТРЕЛКИ ВВЕРХ ВНИЗ
   ENDDO         && ОЧИЩЕНИЕ ОКНА С ТЕКУЩИМ ПОДМЕНЮ
   IF Me_CYCL
      SET COLOR TO &Me_COLOR5
      @ Me_ROW-1 ,Me_COL-2     CLEAR TO Me_ROW2+2,Me_COL+Me_LENMIN+4
      IF Me_EOF .AND. Me_OPEN1 .AND. Me_TENI
         SET COLOR TO &Me_COLOR6 && КУСОЧЕК НИЖНЕЙ ПОЛОВИНЫ ТЕНИ
         @ Me_HAD,Me_COLSHAD  CLEAR TO Me_HAD,Me_RIGHT+2 && ТЕНЬ
      ENDIF
   ENDIF
ELSE
    IF Me_OPENSUP
      Me_OTVET = Me_NMENU*100
    ENDIF
*                                    ЗАПРОС В ВЕРХНЕМ МЕНЮ
*!* ХИТРЫЙ АЛГОРИТМ, ЧТОБЫ ЗАСТАВИТЬ ПРОГРАММУ РЕАГИРОВАТЬ НА SET KEY ... TO:
            Me_INKEY=INKEY(0)
            IF .NOT. STR(Me_INKEY,3) $ Me_KEYS .AND. Me_INKEY > 0 .AND. Me_INKEY < 32
                Me_NULS =" "
                KEYBOARD(CHR(Me_INKEY)+CHR(13))
                Me_1S=SAVESCREEN(Me_ROWT,Me_COLT,Me_ROWT+1,Me_COLT+1)
                @ Me_ROWT,Me_COLT GET Me_NULS
                READ
                @ Me_ROWT,Me_COLT SAY Me_SOOT
            ENDIF
            Me_at=at(perekod(chr(Me_inkey),sysb),Me_1b)
            Me_rest=.t.
            if Me_at > 0 .and. Me_inkey > 32
               if Me_nmenu # Me_at
*                                                СНЯТИЕ ВЫДЕЛЕНИЯ СО СТРОКИ
                  SET COLOR TO &Me_COLOR2 &&                  ВЕРХНЕГО МЕНЮ
                  Me_NULS=SUBSTR(&Me_MASSIV[Me_NMENU],3)
                  @ Me_MAS01[Me_NMENU],Me_MAS02[Me_NMENU] SAY Me_NULS
                  SET COLOR TO &Me_COLOR7
                  @ Me_MAS01[Me_NMENU],Me_MAS02[Me_NMENU] SAY SUBSTR(Me_NULS,1,1)
                  Me_rest=.f.
               endif
               Me_nmenu=Me_at
               Me_inkey=13
            endif
*!*
   IF Me_INKEY =13
      IF Me_EOFW .AND. Me_OPEN[Me_NMENU]        && ОТКРЫВАТЬ ПОДМЕНЮ ?
         Me_EOF = .T.
      ELSE
         IF Me_OPENSUP
            Me_OTVET = Me_NMENU*100
            Me_CYCL=.F.
            EXIT
         ENDIF
      ENDIF
   ENDIF
ENDIF  && КОНЕЦ IF Me_EOF
IF (Me_SAVESCR=1 .OR. (Me_INKEY # 13 .AND. Me_INKEY # 27)) .and. Me_rest
   RESTORE SCREEN FROM Me_SCREEN   && 02
ENDIF
Me_rest=.t.
   IF Me_INKEY = 27                      && ВЫХОД ПО Esc
         Me_OTVET = 0
         Me_CYCL=.F.
         EXIT
   ENDIF
  IF Me_OPENSUP && ЕСТЬ АЛЬТЕРНАТИВЫ В ВЕРХНЕМ МЕНЮ
   Me_VID=.T.
*                                              СТРЕЛКИ ВЛЕВО ВПРАВО
   IF  Me_INKEY = 19 .OR. Me_INKEY = 4 .OR. Me_INKEY = 24 .OR. Me_INKEY = 5
*                                                СНЯТИЕ ВЫДЕЛЕНИЯ СО СТРОКИ
            SET COLOR TO &Me_COLOR2 &&                  ВЕРХНЕГО МЕНЮ
            Me_NULS=SUBSTR(&Me_MASSIV[Me_NMENU],3)
            @ Me_MAS01[Me_NMENU],Me_MAS02[Me_NMENU] SAY Me_NULS
            SET COLOR TO &Me_COLOR7
            @ Me_MAS01[Me_NMENU],Me_MAS02[Me_NMENU] SAY SUBSTR(Me_NULS,1,1)
     Me_VID=.F. && НЕТ НИЧЕГО, ЧТО МОЖНО ВЫДЕЛИТЬ
     Me_PLUS=1
     IF Me_INKEY = 19 .OR. Me_INKEY = 5  && СТРЕЛКА ВЛЕВО
        Me_PLUS  = -1
     ENDIF
*    ЦИКЛ ВЫБОРА ОЧЕРЕДНОЙ АЛЬТЕРНАТИВЫ В ВЕРХНЕМ МЕНЮ
     Me_NMENUW=Me_NMENU
     DO WHILE .NOT. Me_VID
        Me_NMENU = Me_NMENU + Me_PLUS
        IF Me_NMENU > Me_KOL             && ВОЗВРАТ К 1-МУ ПОДМЕНЮ
           Me_NMENU = 1                  && НОМЕР ПОДМЕНЮ В МЕНЮ
        ENDIF
        IF   Me_NMENU = 0
             Me_NMENU = Me_KOL           && НОМЕР ПОДМЕНЮ В МЕНЮ
        ENDIF
        IF Me_NMENU=Me_NMENUW
           Me_VID  =.T.
           EXIT
        ENDIF
        IF SUBSTR(&Me_MASSIV[Me_NMENU],2,1) # "*" && КОММЕНТАРИЙ
           Me_VID=.T.
        ENDIF
     ENDDO
   ENDIF
     Me_OPEN1=Me_OPEN[Me_NMENU]
*
       SET COLOR TO &Me_COLOR1 && ВЫДЕЛЕННАЯ СТРОКА ВЕРХНЕГО МЕНЮ
       Me_COLORT=Me_COLOR1
       Me_ROWT=Me_MAS01[Me_NMENU]
       Me_COLT=Me_MAS02[Me_NMENU]
       Me_SOOT=SUBSTR(&Me_MASSIV[Me_NMENU],3)
       @ Me_ROWT,Me_COLT SAY Me_SOOT
*
  ENDIF && IF Me_OPENSUP
 ENDDO
SET COLOR TO &Me_COLOR5
IF Me_SAVESCR >= 2
   RESTORE SCREEN && 01
ENDIF
SET CURSOR ON
MENUC=0
* ЕДИНСТВЕННЫЙ ВЫХОД ИЗ ПРОГРАММЫ НАХОДИТСЯ ЗА ЭТОЙ СТРОКОЙ !
  RETURN
