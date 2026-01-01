* * * * * * * * * * * * * * * * * * * * * * * * ВЫДАЧА И ПРИЕМ
             FUNCTION  SOOB                   *   (ВОЗМОЖНО)
* * * * * * * * * * * * * * * * * * * * * * * *     ОТВЕТА
*
* MENUPAUSA = ЗАДЕРЖКА ПРИ ВЫДАЧЕ СООБЩЕНИЯ С СОХРАНЕНИЕМ ЭКРАНА
* MENUCENTR = .T. - ЦЕНТРОВАТЬ СТРОКИ
* MENUC     = НОМЕР ПАЛИТРЫ ДЛЯ ФУНКЦИИ C(где nn=MENUC+1,2,3)
* ПОСЛЕ ВЫЗОВА MENUPAUSA=0, MENUCENTR=.F.,  SYSMENU= ВЫБРАННОЙ АЛЬТЕРНАТИВЕ,
*              MENUC    =0 - ПО УМОЛЧАНИЮ
* НАЧАЛЬНЫЕ ЗНАЧЕНИЯ И ШАБЛОН МОГУТ БЫТЬ МАССИВАМИ,
* ДЛЯ КАЖДОГО ВВОДА - ОДИН "#" !!!

* ВВЕДЕН ШАБЛОН - "@Л" - НА КОТОРЫЙ НАДО ОТВЕЧАТЬ Да или Нет

* ЗАПРОС НАЧИНАЕТСЯ С ПОЗИЦИИ С "#" в Сообщении ( 3-ий паpаметp )

* ТЕНЬ СМОТРИТ ВЛЕВО-BНИЗ или в свободную стоpону

* ЕСЛИ ОТВЕТ НЕ ЗАПРАШИВАЕТСЯ, А ВООСТАНОВЛЕНИЕ ЭКРАНА .Т. УКАЗАНО,
* ТО ВЫДАЕТСЯ ПАУЗА ДО НАЖАТИЯ КЛАВИШИ

* Если ПЕРВЫМ СИМВОЛОМ В СТРОКЕ СТОИТ "@", ТО ЭТО МЕНЮ,ПРИЧЕМ
* ВОЗВРАЩАЕМЫЙ НОМЕР СОВПАДАЕТ С НОМЕРОМ СТРОКИ МЕНЮ, ЛИБО БЕРЕТСЯ ИЗ НАЧ.
* ЗНАЧЕНИЯ, ЕСЛИ ОНО ЕСТЬ ВООБЩЕ ( ВИДА "NN NN NN ..." )

* Если ПЕРВЫМ СИМВОЛОМ В СТРОКЕ СТОИТ "-", (минус) ТО ЭТО РАЗДЕЛИТЕЛЬ "├──┤",
*      ЯСНО, ЧТО ОН ДОЛЖЕН БЫТЬ В СЕРЕДИНЕ.                   CHR(195,196,180)

* Если В НАЧАЛЕ СИМВОЛЬНОГО ПОЛЯ СТОИТ "^"(птичка), ТО "^" УДАЛЯЕТСЯ И
*      РАМКА НЕ ЧЕРТИТСЯ ! ПТИЧКА СО ВТОРОЙ ПОЗИЦИИ - УБРАТЬ ТЕНЬ !

PARAMETER So_1p,So_2p,So_SOOB,So_NACHp,So_PICTp,So_Tp && - ВООСТ. ЛИ ЭКРАН
* 1 и 2 - Кооpдинаты веpхнего левого угла. 2 м.б. типа "C",тогда центpиpовать
*     3 - Сообщение/запpос или Меню
*     4 - Нач. значение для запpоса / Числа, возвpащаемое Меню пpи выбоpе
*     5 - Шаблон для запpоса ( введен шаблон @Л )
*     6 - .F. - Экpан не воостанавливать
* НЕ БУДЕТ ОШИБКИ, ЕСЛИ ВЫ ЗАДАДИТЕ ДАЖЕ ОДИН ПАРАМЕТР ИЗ ШЕСТИ
So_CVETOLD=SETCOLOR()
SET WRAP ON
So_KOL=PCOUNT() && ЧИСЛО ПЕРЕДАННЫХ ПАРАМЕТРОВ
So_CVET=0 && НЕ БЫЛО СДВИГА ЦВЕТА
So_1=SYSROW
IF So_KOL > 0
   So_1=So_1p
ENDIF
* ЦЕНТРИРОВАТЬ ?
So_CENTR=.F.
IF So_KOL > 1
    IF TYPE("So_2p") <> "N"
       So_2=2
       So_CENTR=.T.
    ELSE
       So_2=So_2p
    ENDIF
ELSE
   So_2=SYSCOL
ENDIF
*
   DO WHILE .T. && Завеpшение цикла до завеpшения Д Е Й С Т В А
    IF MENUC > 0
       So_C1 =MENUC+1
       So_C2 =MENUC+2
       So_C4 =MENUC+3
       So_C5 =MENUC+3
    ELSE                && ПО УМОЛЧАНИЮ
       So_C1 =51
       So_C2 =52
       So_C4 =93
       So_C5 =53
       IF "#" $ So_SOOB && ВВОД
          So_C2=92
       ELSE
          IF .NOT. "@" $ So_SOOB && И НЕТ МЕНЮ, ЗНАЧИТ ПРОСТО СООБЩЕНИЕ
             So_C1=31
             So_C2=32
          ENDIF
       ENDIF
    ENDIF
       So_C1s=C(So_C1)     &&   СООБЩЕНИЕ
       So_C2s=C(So_C2)     &&   РАМКА
       So_C3s="W/N+"       &&   ТЕНЬ
       So_C4s=C(So_C4)     &&   ВВОД
       So_C5s=C(So_C5)     &&   АльТЕРНАТИВА
*
      So_INDEXM=1 && ИНДЕКС ДЛЯ МОЖЕТ БЫТЬ СУЩ. МАССИВОВ So_NACHp, So_PICTp
IF So_KOL < 3      && ОЧИСТКА ЭКРАНА, если есть только кооpдинаты
   C(10)
   IF So_KOL=0
       @ 0   ,0    CLEAR
   ELSEIF So_KOL=1
       @ So_1,0    CLEAR
   ELSE
       @ So_1,So_2 CLEAR
   ENDIF
   RETURN .T.
ENDIF
So_NACH=""
So_PRMAS=.F. && So_NACHp, So_PICTp НЕ МАССИВЫ !
IF So_KOL > 3
   IF TYPE("So_NACHp")="A"
      So_PRMAS=.T.
   ELSE
      So_NACH=So_NACHp
   ENDIF
ENDIF
So_PICT=""
IF So_KOL > 4 .AND. .NOT. So_PRMAS
    So_PICT=So_PICTp
ENDIF
*
So_TT=.T. && ОБ ЯВНОМ УКАЗАНИИ ВООСТАНОВЛЕНИИ ЭКРАНА
So_T=.F.
IF So_KOL > 5
   So_T=So_Tp
   So_TT=So_Tp
ENDIF
So_PR=.F. && НЕТ ЗАПРОСА
So_MEN=.F. && НЕТ МЕНЮ @ в 1-ой позиции
So_MENU=.F. && ВООБЩЕ НЕТ МЕНЮ
DECLARE MMM[25]
So_KOL1=0
So_SOOB1=So_SOOB
So_TEN=.T. && РИСОВАТЬ ТЕНЬ
So_TENPLUS=2
IF SUBSTR(So_SOOB,2,1)="^"
   So_TEN=.F.
   So_TENPLUS=0 && ДЛЯ НЕ ЗАШКАЛИВАНИЯ
   IF So_SOOB=" "
      So_SOOB1=SUBSTR(So_SOOB,3)
   ELSE
      So_SOOB1=STUFF(So_SOOB,2,1,"")
   ENDIF
ENDIF
So_RAMKA=.T. && РИСОВАТЬ РАМКУ
IF So_SOOB1="^"
   So_RAMKA=.F.
   So_SOOB1=SUBSTR(So_SOOB1,2)
ENDIF
So_IND=0
So_MAX=0
So_REZ=""
DO WHILE .NOT. EMPTY(So_SOOB1)
   DO TEETH WITH So_SOOB1,So_REZ
*
   So_REZ=       (So_REZ)
   So_MAX=MAX(So_MAX,LEN(So_REZ))
   So_IND=So_IND+1
   MMM[So_IND]=So_REZ
ENDDO
So_MAX=So_MAX+2
IF So_CENTR && ЦЕНТРИРОВАНИЕ
   So_2=INT(40-So_MAX/2)
ENDIF
IF .NOT. So_RAMKA && НЕТ РАМКИ - СДВИГ НА ТОЛЩИНУ РАМКИ.
   So_1=So_1-1
   So_2=So_2-1
ENDIF
*                                   ЗАЩИТА ОТ ЗАШКАЛИВАНИЯ
  IF So_1 < 0
     So_1 = 0
  ENDIF
  IF So_2 < 0
     So_2 = 0
  ENDIF
So_1k=So_1+So_IND
So_2k=So_2+So_MAX
So_TENPLUS=25-So_TENPLUS &&24
  IF So_1K >  So_TENPLUS
     So_1K =  So_TENPLUS
     So_1  =  So_TENPLUS-So_IND
  ENDIF
  IF So_2K > 77
     So_2K = 77
     So_2  = 77-So_MAX
  ENDIF
So_=SAVESCREEN(So_1-3,So_2-3,So_1k+2,So_2k+4)
IF So_TEN && ЕСЛИ ТЕНИ В ПОЛДЕНЬ РАЗРЕШЕНЫ ПРИКАЗОМ ГЛАВНОГО ВРАЧА
 SET COLOR TO (So_C3s)
*                            ТАК КУДА ЖЕ СМОТРИТ МОЯ ТЕНЬ ?
        So_MSN=1
        IF So_1k>22
           So_MSN=-1
           IF So_1<2
              So_MSN=0
           ENDIF
        ENDIF                 &&   ВЛЕВО <-ТЕНЬ-> ВПРАВО
        So_MKN=2              &&   So_MKN=-2      So_MKN=2
        IF So_2k>76           &&   IF So_2<2      IF So_2k>76
           So_MKN=-2          &&      So_MKN= 2      So_MKN=-2
           IF So_2<2          &&      IF So_2k>76    IF So_2<2
              So_MKN=0        &&         So_MKN=0       So_MKN=0
           ENDIF              &&      ENDIF          ENDIF
        ENDIF                 &&   ENDIF          ENDIF
  IF  So_RAMKA
    @ So_1+So_MSN  ,So_2+So_MKN   CLEAR TO So_1k+1+So_MSN,So_2k+1+So_MKN   && TEНЬ
  ELSE
    @ So_1+1+So_MSN,So_2+1+So_MKN CLEAR TO So_1k+So_MSN,So_2k+So_MKN   && TEНЬ
  ENDIF
ENDIF
 SET COLOR TO (So_C2s)
IF So_RAMKA
   @ So_1,So_2       TO So_1k+1,So_2k+1 && РАМКА
ENDIF
* SET COLOR TO (So_C1s)
@ So_1+1,So_2+1 CLEAR TO So_1k  ,So_2k   && ОКНО
So_11=So_1
So_22=So_2+1
So_22W=So_22
SET CURSOR OFF
So_SOOB1=REPLICATE(CHR(196),So_MAX)
FOR So_INDEX=1 TO So_IND
    So_REZ=MMM[So_INDEX]
    So_11INDEX=So_11+So_INDEX
    IF So_REZ="@"                      && МЕНЮ
       So_MEN=.T.
       So_MENU=.T.
       So_REZ=SUBSTR(So_REZ,2)
       SET COLOR TO (So_C5s)
    ELSEIF So_REZ="-" && МИНУС         && РАМКА
      IF So_RAMKA
        So_REZ=CHR(195)+So_SOOB1+CHR(180)
      ELSE &&     ПРОБЕЛ - 032
        So_REZ=" "+So_SOOB1+" "
      ENDIF
        So_22=So_22-1
          SET COLOR TO (So_C2s)
    ELSE
    SET COLOR TO (So_C1s)
    ENDIF
    So_LEN=LEN(So_REZ)
    IF MENUCENTR
       So_RAZ=INT((So_MAX-So_LEN)/2)+1
    ELSE
       So_RAZ=1
    ENDIF
    So_SPACE=SPACE(So_MAX)
    So_REZ=STUFF(So_SPACE,So_RAZ,So_LEN,So_REZ)
    IF So_MEN
       So_MEN=.F.
       @ So_11INDEX,So_22 PROMPT So_REZ   && МЕНЮ
    ELSE
       @ So_11INDEX,So_22 SAY So_REZ      && СООБЩЕНИЕ
    ENDIF
    So_AT=AT("#",So_REZ)
    IF So_AT > 0
       SET COLOR TO (So_C4s)
       IF So_PRMAS
* ОБРАБОТКА ЕЩЕ ВВОДА
          DO WHILE So_AT > 0
             So_REZ=STUFF(So_REZ,So_AT,1," ")
             @ So_11INDEX,So_22+So_AT-1 GET So_NACHp[So_INDEXM] PICTURE So_PICTp[So_INDEXM]
             So_INDEXM=So_INDEXM+1
             So_AT=AT("#",So_REZ)
          ENDDO
       ELSE
          @ So_11INDEX,So_22+So_AT-1 GET So_NACH PICTURE So_PICT
       ENDIF
       So_PR=.T.
    ENDIF
    So_22 =So_22W
          SET COLOR TO (So_C1s)
NEXT
*
EXIT
ENDDO
*
IF So_PR
   SET CURSOR ON
   SET COLOR TO (So_C4s)
   READ
   SET CURSOR OFF
   C(10) && Воостановление цвета
   IF So_T .OR. So_KOL < 6
      So_T=.T.
   ELSE
      So_T=.F.
   ENDIF
   So_PR=So_NACH

ELSEIF So_MENU && ЕСЛИ БЫЛО МЕНЮ
   SET COLOR TO (So_C5s)
   MENU TO So_PR
   IF .NOT. So_TT
       SYSMENU=So_PR
    ENDIF
    IF So_T .OR. So_KOL < 6
       So_T=.T.
    ELSE
       So_T=.F.
    ENDIF
    IF .NOT. EMPTY(So_NACH)
      So_PR=VAL(SUBSTR(So_NACH,So_PR*3-2,2)) && ВЫБОР ЗАДАННОГО ОТBЕТА NN !
    ENDIF
ELSEIF So_PICT="@Л"
So_PR=.F.
*  So_REZ=CHR(13)+"DdДдNnНн"+CHR(27)
   So_REZ=CHR(13)+"LlДдYyНн"+CHR(27)
   So_SPACE="?"
   DO WHILE .NOT. So_SPACE $ So_REZ
        So_SPACE=CHR(INKEY(0))
   ENDDO
   IF So_SPACE $ SUBSTR(So_REZ,1,5)
      So_PR=.T.
   ENDIF
ELSE
   IF So_T
     INKEY(MENUPAUSA)
           MENUPAUSA=0
   ENDIF
ENDIF
   IF So_T
      RESTSCREEN(So_1-3,So_2-3,So_1k+2,So_2k+4,So_)
   ENDIF
C(10)
SET CURSOR ON
MENUCENTR=.T.
MENUC    = 0
SETCOLOR(So_CVETOLD)
RETURN So_PR
* *  * * * * * * * * * * * * * * * * * * * * * * ПОЛУЧЕHИЕ ПОЛЕЙ ИЗ "STROKA"
           PROCEDURE  TEETH                    * разделенных символом
* *  * * * * * * * * * * * * * * * * * * * * * * из 4-го параметра
*
PARAMETER Te_STROKA,Te_REZULTp,Te_IDLp,Te_RAZDp,Te_INDp
* 1- ОСТАТОК, 2- РЕЗУЛЬТАТ, 3- ДЛИHА ОСТАТКА, 4- СПИСОК РАЗДЕЛИТЕЛЕЙ,
* (по умолчанию в разделителях нет пробела, только ";" !!!!! )
* 5- HОМЕР HАЙДЕHHОГО РАЗДЕЛИТЕЛЯ ИЛИ HОЛЬ, ЕСЛИ HЕ HАЙДЕH.
* ДОСТАТОЧНО ЗАДАТЬ ДВА ПАРАМЕТРА
*PRIVATE ALL LIKE Te_*
Te_KOL=PCOUNT()
Te_REZULT=""
Te_IDL=0
Te_RAZD=";"
IF Te_KOL > 3
   Te_RAZD=Te_RAZDp
   IF " " $ Te_RAZD
*              БЕЗ ЭТОЙ СТРОКИ НЕ БУДЕТ РАБОТАТЬ РАЗДЕЛИТЕЛЬ ПРОБЕЛ,
*              ТАК КАК ЗА 1 РАЗДЕЛИТЕЛЬ ИДЕТ МНОГО ПРОБЕЛОВ
      Te_STROKA=LTRIM(Te_STROKA) && 06/17/92 09:06am
   ENDIF
ENDIF
Te_IND=0
IF .NOT. RIGHT(Te_STROKA,1) $ Te_RAZD
     Te_STROKA=Te_STROKA+LEFT(Te_RAZD,1)
ENDIF
Te_AT=0
Te_IND=1
Te_LEN=LEN(Te_RAZD)
DO WHILE Te_IND <= Te_LEN .AND. Te_AT=0
  Te_AT=AT( SUBSTR(Te_RAZD,Te_IND,1) ,Te_STROKA)
  Te_IND=Te_IND+1
ENDDO
IF Te_AT =0
   Te_IND=0
ENDIF
Te_REZULT=SUBSTR(Te_STROKA,1,Te_AT-1)
IF LEN(Te_STROKA) > Te_AT
   Te_STROKA=SUBSTR(Te_STROKA,Te_AT+1)
ELSE
   Te_STROKA=""
ENDIF
Te_IDL=LEN(Te_STROKA)
IF Te_KOL > 4
   Te_INDp=Te_IND
ENDIF
IF Te_KOL > 2
   Te_IDLp=Te_IDL
ENDIF
IF Te_KOL > 1
   Te_REZULTp=Te_REZULT
ENDIF
RETURN
* * * * * * * * * * * * * * * * * * * * * * * * НАЧАЛЬНАЯ ИНИЦИАЛИЗАЦИЯ
            PROCEDURE  RUNINGER               * ПЕРЕМЕННЫХ ПРИ ЗАПУСКЕ
* * * * * * * * * * * * * * * * * * * * * * * * ПРОГРАММЫ !
*
PARAMETER RunIMFp
PUBLIC SYSROW,SYSCOL,SYSMENU,SYSCOLORC,MENUPAUSA,MENUCENTR,MENUC,SYSB,SYSM
* ПЕРЕКОДИРОВКА из стpочных в ПРОПИСНЫЕ
* PEREKOD(Stroka,SYSB), Stroka тоже пеpекодиpуется !!
 SYSB=SPACE(33)+"!"+CHR(34)+"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`ABCDEFGHIJKLMNOPQRSTUVWXYZ{|}~ АБВГДЕЖЗИЙКЛМ"+CHR(141)+"ОПРСТУФХЦЧШЩ'ЫЬЭЮЯАБВГДЕЖЗИЙКЛМ"+CHR(141)+"ОП"+space(48)+"РСТУФХЦЧШЩ'ЫЬЭЮЯ"
 SYSM=SPACE(33)+"!"+CHR(34)+"#$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ абвгдежзийклмнопрстуфхцчшщ'ыьэюяабвгдежзийклмноп"+space(48)+"рстуфхцчшщ'ыьэюя"
SET DATE BRITISH && ДД/ММ/ГГ
SET STATUS OFF
SET SCOREBOARD OFF
SET EXACT OFF && СРАВНЕНИЕ СТРОК: "AAA"="A"=.T.
SET WRAP ON
SET DELETED ON
SET ESCAPE ON
* ВСЕ ЭТИ ПАРАМЕТРЫ ВООСТАНАВЛИВАЮТСЯ КАК 1,0,0, КАК ЗАШИТО В ПРОГРАММАХ !
MENUINDEX=1   && ОТНОСИТЕЛЬНОЕ РАСПОЛОЖЕНИЕ
MENUOTNOS=0   && КУРСОРА В SOOB1 ( ACHOICE() )
MENUPAUSA=0   && INKEY(MENUPAUSA) но уже в SOOB()
MENUCENTR=.T. && ЦЕНТРОВАТЬ СТРОКУ В МЕНЮ
MENUC    =0   && НЕТ ВЫБОРА ПАЛИТРЫ ДЛЯ C()
SYSCOLORC=CHR(55)+CHR(39)+CHR(39)+CHR(39)+CHR(39)+CHR(97)+CHR(225)+CHR(39)+;
 CHR(39)+CHR(39)+CHR(243)+CHR(115)+CHR(39)+CHR(39)+CHR(39)+CHR(246)+;
 CHR(148)+CHR(39)+CHR(39)+CHR(39)+CHR(145)+CHR(51)+CHR(55)+CHR(245)+;
 CHR(215)+CHR(35)+CHR(39)+CHR(208)+CHR(39)+CHR(39)+CHR(209)+CHR(241)+;
 CHR(144)+CHR(212)+CHR(39)+CHR(213)+CHR(117)+CHR(39)+CHR(39)+CHR(39)+;
 CHR(39)+CHR(35)+CHR(213)+CHR(97)+CHR(55)+CHR(39)
 NULS="COLOR.CLR"
IF FILE(NULS)
   RESTORE FROM (NULS) ADDITIVE
   SYSCOLORC=COLOR01
ENDIF
C(10)
*
SYSCOL=20          && КООРДИНАТЫ
SYSROW=12          && КУРСОРА ПО УМОЛЧАНИЮ ДЛЯ SOOB.PRG
SYSMENU=0          && ОТВЕТ МЕНЮ НЕ МОДИФИЦИРОВАННЫЙ СПИСКОМ В ПОЛЕ НАЧ ЗНАЧ
SETCANCEL(.T.)
RETURN
