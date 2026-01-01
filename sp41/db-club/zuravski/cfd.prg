SET PROC TO CFD
DO MAT
************************************************************
*                         R2                               *
************************************************************

PROCEDURE R2
*:*********************************************************************
*:
*:        Program: R2.PRG
*:
*:         System: CatFd
*:         Author: Alperovitch L.Z. & Suravsky Yaroslaw Wla
*:      Copyright (c) 1991, A&S + SoftPanorama
*:  Last modified: 01/30/91     13:01
*:
*:      Called by: MATI.PRG       
*:
*:     Documented: 01/30/91 at 13:06               FoxDoc version 1.0
*:*********************************************************************
* Отчет "файлы-коробка-дискетта"
GO TOP
IF EOF()
   CLEAR
   @ 15,30 SAY 'БД пуста !!!'
   ? CHR(7)+CHR(7)
   RETURN
ENDIF
SET PRINT TO cfd.txt
SET PRINT ON
SET CONS OFF
? REPL('-',70)
? '   Fname  ext  Длина,байт   Тип ОС   Вид копии Коробка N Дискетта N'
? '   Аннотация'
? REPL('-',70)
z=0
DO WHILE .NOT. EOF()
   ? cod,ext,' ',lenf,' ',tipevm,' ',tipcopy,BOX,disketn
   IF LEN(TRIM(name1)) # 0
      ? TRIM(name1)
   ENDIF
   IF LEN(TRIM(name2)) # 0
      ? TRIM(name2)
   ENDIF
   z=z+1
   sz=LTRIM(STR(z))
   IF RIGHT(sz,1)='0'
      SET PRIN OFF
      @ 24,46 SAY z PICT '9999'
      SET PRIN ON
   ENDIF
   SKIP
ENDDO
? repl('-',70)
SET PRINT TO
SET PRINT OFF
*: EOF: R2.PRG


************************************************************
*                         R1                               *
************************************************************

PROCEDURE R1
*:*********************************************************************
*:
*:        Program: R1.PRG
*:
*:         System: CatFd
*:         Author: Alperovitch L.Z. & Suravsky Yaroslaw Wla
*:      Copyright (c) 1991, A&S + SoftPanorama
*:  Last modified: 01/30/91     13:01
*:
*:      Called by: MATI.PRG       
*:
*:     Documented: 01/30/91 at 13:06               FoxDoc version 1.0
*:*********************************************************************
* Отчет "коробка-дискетта-файлы"
GO TOP
IF EOF()
   CLEAR
   @ 15,30 SAY 'БД пуста !!!'
   ? CHR(7)+CHR(7)
   RETURN
ENDIF
old_b=BOX
old_d=disketn
SET PRINT TO cfd.txt
SET PRINT ON
SET CONS OFF
? '             Коробка N',BOX
? '        Дискетта N',disketn,' типа ',tipd,' объем ',dens,' Kб'
? '   Fname  ext  Длина,байт   Тип ОС   Вид копии'
? '   Аннотация'
? REPL('-',70)
z=0
DO WHILE .NOT. EOF()
   IF BOX # old_b
      ? REPL('-',70)
      ? '             Коробка N',BOX
      ? '        Дискетта N',disketn,' типа ',tipd,' объем ',dens,' Kб'
      ? '   Fname  ext  Длина,байт   Тип ОС   Вид копии'
      ? '   Аннотация'
      ? REPL('-',70)
      old_b=BOX
      old_d=disketn
   ELSE
      IF disketn # old_d
         ? REPL('-',70)
         ? '        Дискетта N',disketn,' типа ',tipd,' объем ',dens,' Kб'
         ? '   Fname  ext  Длина,байт   Тип ОС   Вид копии'
         ? '   Аннотация'
         ? REPL('-',70)
         old_d=disketn
      ENDIF
   ENDIF
   ? cod,ext,' ',lenf,' ',tipevm,' ',tipcopy
   IF LEN(TRIM(name1)) # 0
      ? TRIM(name1)
   ENDIF
   IF LEN(TRIM(name2)) # 0
      ? TRIM(name2)
   ENDIF
   z=z+1
   sz=LTRIM(STR(z))
   IF RIGHT(sz,1)='0'
      SET PRIN OFF
      @ 24,46 SAY z PICT '9999'
      SET PRIN ON
   ENDIF
   SKIP
ENDDO
? repl('-',70)
SET PRINT TO
SET PRINT OFF
*: EOF: R1.PRG


************************************************************
*                         SETSW                            *
************************************************************

PROCEDURE SETSW
*:*********************************************************************
*:
*:        Program: SETSW.PRG
*:
*:         System: CatFd
*:         Author: Alperovitch L.Z. & Suravsky Yaroslaw Wla
*:      Copyright (c) 1991, A&S + SoftPanorama
*:  Last modified: 01/02/91     17:00
*:
*:      Called by: MAT.PRG        
*:               : P1.PRG         
*:               : DELA.PRG       
*:
*:     Documented: 01/30/91 at 13:06               FoxDoc version 1.0
*:*********************************************************************
* SETSW.PRG
SET STEP OFF
SET ECHO OFF
SET DATE       BRITISH
SET TALK       OFF
SET BELL       OFF
SET STATUS     OFF
SET ESCAPE     OFF
SET DELETED    ON
SET CONFIRM    ON
SET SCOREBOARD OFF
SET STEP OFF
SET ECHO OFF
SET PRINT OFF
SET DEVICE TO SCREEN
* on error do errhand with error(),sys(16)
* on key=315 do helptxt with hlptxtn
ON ESCAPE RETURN
SET PRINT TO


************************************************************
*                         MATI                             *
************************************************************

PROCEDURE MATI
*:*********************************************************************
*:
*:        Program: MATI.PRG
*:
*:         System: CatFd
*:         Author: Alperovitch L.Z. & Suravsky Yaroslaw Wla
*:      Copyright (c) 1991, A&S + SoftPanorama
*:  Last modified: 01/30/91     13:00
*:
*:      Called by: MAT.PRG        
*:
*:          Calls: MATIDR1.PRG
*:               : R1.PRG
*:               : R2.PRG
*:
*:     Documented: 01/30/91 at 13:06               FoxDoc version 1.0
*:*********************************************************************
* MATI
* FOXBASE: Программа выдачи каталога ФЛОППИ-ДИСКОВ
*
DO WHILE .T.
   CLEAR
   DO matidr1
   @ 15,10 SAY  "Вариант отчетa или Esc"
   @ 16,9 TO 19,32
   @ 17,10 PROM "Коробка-дискетта-файлы"
   @ 18,10 PROM "Файл-коробки-дискетты "
   *
   MENU TO rx
   DO CASE
   CASE rx=0
      RETURN
   CASE rx=1
      SET COLOR TO W+*/B
      @ 24,20 SAY 'Минуточку, готовлю отчет '
      SET COLOR TO W+/B
      SET ORDER TO 2
      DO r1
   CASE rx=2
      SET COLOR TO W+*/B
      @ 24,20 SAY 'Минуточку, готовлю отчет '
      SET COLOR TO W+/B
      SET ORDER TO 1
      DO r2
   ENDCASE
   @ 24,20
   ! prpage cfd.txt v
   ! del cfd.txt
ENDDO
*: EOF: MATI.PRG


************************************************************
*                         MAT                              *
************************************************************

PROCEDURE MAT
* Программа выдачи каталога ФЛОППИ-ДИСКОВ
* MAT - головной модуль
DO setsw
SET COLOR TO W+/B,GR+/N
*
DO WHILE .T.
   CLOSE ALL
   USE mat
   IF .NOT.FILE('matfbd.idx')
      INDEX  TO matfbd ON cod+ext+STR(BOX*100+disketn,4)
   ENDIF
   IF .NOT.FILE('matbdf.idx')
      INDEX  TO matbdf ON STR(BOX*100+disketn,4)+cod+ext
   ENDIF
   USE mat INDEX matfbd,matbdf
   *
   DO matidr1 && Заставка
   @ 16,22 SAY    "┌────────────────────────────┐"
   @ 17,22 PROMPT "│       Hовая коробка        │"
   @ 18,22 PROMPT "│  Просмотр и корректировка  │"
   @ 19,22 PROMPT "│          Отчеты            │"
   @ 20,22 PROMPT "│       (Esc)   Конец        │"
   @ 21,22 SAY    "└────────────────────────────┘"
   SET MESSAGE TO 24
   choice=2
   MENU TO choice
   *
   DO CASE
   CASE choice = 1
      DO p1
   CASE choice = 2
      DO dela
   CASE choice = 3
      DO mati
   OTHERWISE
      close all
      ! del mat?????.idx>nul 
      QUIT
   ENDCASE
   *
ENDDO
*: EOF: MAT.PRG


************************************************************
*                         P1                               *
************************************************************

PROCEDURE P1
*:*********************************************************************
*:
*:        Program: P1.PRG
*:
*:         System: CatFd
*:         Author: Alperovitch L.Z. & Suravsky Yaroslaw Wla
*:      Copyright (c) 1991, A&S + SoftPanorama
*:  Last modified: 01/30/91     12:05
*:
*:      Called by: MAT.PRG        
*:
*:          Calls: SETSW.PRG
*:               : SIGNFD.PRG
*:
*:           Uses: DIRTXT.DBF     
*:
*:     Documented: 01/30/91 at 13:06               FoxDoc version 1.0
*:*********************************************************************
* Hовая коробка
DO setsw
SET COLOR TO W+/B
*
rdisketn=10
rtipd='ГМД-130'
rdens=800
rtipevm='MSDOS'
SET COLOR TO ,GR+/N
*
SET ORDER TO 2 && use mat index matbdf - коробка,дискетта,файл
rbox=1
GO BOTT
IF .NOT. EOF()
   rbox=BOX+1
ENDIF
fl_del=0
DO WHILE .T.
   CLEAR
   @  3,27 SAY "Каталог дискетт: новая коробка !"
   @  5, 0 SAY "Коробка N "
   @  5,14 SAY "Содержит дискетт "
   @  7, 0 SAY "Тип дискетт "
   @  9, 0 SAY "Объем Kb "
   @ 11, 0 SAY "Тип ОС "
   @ 11,15 SAY "<--- : MSDOS / RT11(для ДВК-3) / ..."
   @  5,10 GET rbox        PICTURE "999"
   @  5,32 GET rdisketn    PICTURE "99" RANGE 1,10
   @  7,13 GET rtipd
   @  9,10 GET rdens       PICTURE "9999"
   @ 11, 7 GET rtipevm
   @ 15,20 SAY 'Esc-выход;'
   READ
   IF READKEY()=12 .OR. READKEY()=268
      EXIT
   ENDIF
   SEEK ltrim(str(rbox))
   IF FOUND().and.rbox=box
      @ 5,40 SAY '<-- Коробка N '+STR(rbox,3)+' уже зарегистрирована !' 
      ? chr(7)
      LOOP
   ENDIF
   *
   CLEAR
   SET COLOR TO W+/B
   @  3,27
   @  3,27 SAY "Каталог дискетт:"
   @  5, 0 SAY 'Коробка N Дискетта N Файл N '
   @  7, 0 SAY "Filename"
   @  7, 9 SAY "Ext"
   @  7,15 SAY ' Длина '
   @  9, 0 SAY "Аннотация"
   SET COLOR TO BG+/R+
   @ 12,0  SAY REPL(CHR(4),60)
   SET COLOR TO W+/B,GR+/N
   @ 13, 0 SAY "Тип дискетты"
   @ 15, 0 SAY "Объем Kb "
   @ 17, 0 SAY "Тип ОС"
   @ 20, 9 SAY "Esc - переход к след.дискете; PgDown/выход за край - след.файл"
   *
   I=1
   DO WHILE I<=rdisketn
      DO signfd && Заполнение сигнатуры дискетты
      I=I+1
   ENDDO
   rbox=rbox+1
ENDDO
IF fl_del=1
   PACK
   REIN
ENDIF
CLOSE DATA
IF FILE('DIRTXT.DBF')
   SET SAFE OFF
   DELE FILE dirtxt.dbf
   DELE FILE dir.txt
ENDIF
*: EOF: P1.PRG


************************************************************
*                         DELA                             *
************************************************************

PROCEDURE DELA
*:*********************************************************************
*:
*:        Program: DELA.PRG
*:
*:         System: CatFd
*:         Author: Alperovitch L.Z. & Suravsky Yaroslaw Wla
*:      Copyright (c) 1991, A&S + SoftPanorama
*:  Last modified: 01/30/91     12:43
*:
*:      Called by: MAT.PRG        
*:
*:          Calls: SETSW.PRG
*:               : MATIDR1.PRG
*:               : RPAGE.PRG
*:               : RAMKA.PRG
*:               : SHPAGE.PRG
*:               : IN_KEY.PRG
*:
*:     Documented: 01/30/91 at 13:06               FoxDoc version 1.0
*:*********************************************************************
*
* Hавигация по БД "Каталог дискетт"
*
* Индексный файл - matf : cod+ext
*
DO setsw     && Set switches
CLEAR
SET COLOR TO W+/B,GR+/N
*
DO matidr1
*
@ 14,20 SAY  '    Задайте порядок выдачи         '
@ 15,19 TO 18,55
@ 16,20 PROM 'по имени файла,N коробки,N дискетты'
@ 17,20 PROM 'по N коробки,N дискетты,имени файла'
MENU TO m1
IF m1=0
   RETURN
ENDIF
*
SET ORDER TO m1
*
GO TOP
IF .NOT. EOF()
   rn1st=RECNO() && Читать фрагмент файла(блок) в память,начиная с ...
ENDIF
*         Блок - в него читаем Сod+ext+recno() - для навигации по БД
rx=5
ry=14
DIME page(rx*ry)
*
RECC=0        && Количество записей,загруженных в блок
*
fl_del=0      && Флаг слежения за удалениями
*
x1=0          && Nn стр./столбцов
y1=0
dcol=15       && Расстояние между столбцами
ip=1          && Указатель в блоке,куда поставить курсор
H=CHR(24)+CHR(25)+CHR(26)+CHR(27)
H=H+'/Enter-редакт/Ins-вставка/Del-удал/Esc-вых./PgUp/Down-cтр.назад/вперед'
*
DO WHILE .T.  && Главный цикл
   SET ORDER TO m1	
   DO rpage   && Прочесть блок в память
   DO ramka   && Разметка экрана
   DO shpage  && Показать блок
   in_key=0
   DO in_key  && Работа с блоком - ожидание и анализ кнопки
   IF in_key=27
      exit
   ENDIF
ENDDO
*
IF fl_del = 1
   PACK
ENDIF
CLOSE DATA
*: EOF: DELA.PRG


************************************************************
*                         IN_KEY                           *
************************************************************

PROCEDURE IN_KEY
*:*********************************************************************
*:
*:        Program: IN_KEY.PRG
*:
*:         System: CatFd
*:         Author: Alperovitch L.Z. & Suravsky Yaroslaw Wla
*:      Copyright (c) 1991, A&S + SoftPanorama
*:  Last modified: 01/30/91     12:06
*:
*:      Called by: DELA.PRG       
*:
*:          Calls: ITOXY.PRG
*:
*:     Documented: 01/30/91 at 13:06               FoxDoc version 1.0
*:*********************************************************************
*
I=ip          && Куда поставить курсор
DO itoxy      && Пересчет i в координаты
DIME recr(11) && Запись БД
*
DO WHILE .T.
   SET COLOR TO GR+/N
   SET ORDER TO m1
   @ y1+1,x1*dcol+1 SAY LEFT(page(I),8)+'.'+SUBSTR(page(I),9,3)
   SET COLOR TO W+/B
   lens=LEN(page(I))-11
   rn=VAL(SUBSTR(page(I),12,lens))
   GO rn
   @ 17,1  SAY 'Коробка'      GET BOX PICT '999'
   @ 17,13 SAY 'Дискетта N'   GET disketn PICT '99'
   @ 17,27 SAY 'типa'         GET tipd
   @ 17,43 SAY 'Объем'        GET dens PICT '9999'
   @ 17,54 SAY 'OC'           GET tipevm
   @ 18,1  SAY 'Fname'        GET cod
   @ 18,16 SAY 'Ext'          GET ext
   @ 18,25 SAY 'Длина '       GET lenf
   @ 18,47 SAY 'Тип копии'    GET tipcopy
   @ 19,20 SAY 'Аннотация'
   @ 20,1  GET name1
   @ 21,1  GET name2
   @ 22,01 SAY H
   CLEAR GETS
   Cursor=SYS(2002)
   in_key=INKEY(0)
   DO CASE
   CASE in_key=27
      EXIT
   CASE in_key=24 && Вниз
      @ y1+1,x1*dcol+1 SAY LEFT(page(I),8)+'.'+SUBSTR(page(I),9,3)
      *        Снять активную окраску с прямоугольника
      I=I+1
      IF I>RECC  && C последней - на первую
         I=1
      ENDIF
      DO itoxy   && Пересчет i в координаты
   CASE in_key=5 && Вверх
      @ y1+1,x1*dcol+1 SAY LEFT(page(I),8)+'.'+SUBSTR(page(I),9,3)
      I=I-1
      IF I=0     && C первой - на последнюю
         I=RECC
      ENDIF
      DO itoxy
   CASE in_key=19 && Влево
      @ y1+1,x1*dcol+1 SAY LEFT(page(I),8)+'.'+SUBSTR(page(I),9,3)
      IF I>ry
         I=I-ry
      ELSE     && Cлева ничего нет - прыгаем на правый край
         IF I=1
            I=RECC
         ELSE
            I = INT(RECC/ry-0.01)*ry+y1-1
            IF I>RECC
               I=RECC
            ENDIF
         ENDIF
      ENDIF
      DO itoxy
   CASE in_key=4 && Вправо
      @ y1+1,x1*dcol+1 SAY LEFT(page(I),8)+'.'+SUBSTR(page(I),9,3)
      IF I=RECC
         I=1
      ELSE  && Cправа ничего нет - прыгаем на левый край
         I=I+ry
         IF I>RECC
            I = y1+1
         ENDIF
      ENDIF
      DO itoxy
   CASE in_key=3 && PgDown
      lens=LEN(page(RECC))-11
      rn=VAL(SUBSTR(page(RECC),12,lens))
      GO rn
      ip=1
      SKIP
      IF EOF()
         GO TOP
      ENDIF
      rn1st=RECNO()
      EXIT
   CASE in_key=18 && PgUp
      lens=LEN(page(1))-11
      rn=VAL(SUBSTR(page(1),12,lens))
      GO rn      && перейти к началу блока
      ip=1
      back=rx*ry && Вернуться на блок назад
      DO WHILE .NOT. BOF() .AND. back > 0
         SKIP -1
         back=back-1
      ENDDO
      rn1st=RECNO()
      EXIT
      * -------------------------------------------------------------------------
      *    Действия над записями: удаление
      * -------------------------------------------------------------------------
   CASE in_key=7 && Del
      SET COLOR TO GR+/R*
      @ y1+1,x1*dcol+1 SAY LEFT(page(I),8)+'.'+SUBSTR(page(I),9,3)
      @ 24,20 SAY 'Удалять (Enter/Esc)'
      in_key=INKEY(0)
      SET COLOR TO W+/B
      @ 24,20
      IF in_key=13
         lens=LEN(page(I))-11
         rn=VAL(SUBSTR(page(I),12,lens))
         GO rn
         DELETE
         fl_del=1
         RECC=RECC-1
         IF RECC=0
            rn1st=0
         ELSE
            i1=IIF(I=1,2,1)
            lens=LEN(page(i1))-11
            rn1st=VAL(SUBSTR(page(i1),12,lens))
            ip=IIF(I=1,1,I-1)
         ENDIF
         EXIT
      ENDIF
      @ y1+1,x1*dcol+1 SAY LEFT(page(I),8)+'.'+SUBSTR(page(I),9,3)
      *  Вставка
   CASE in_key=22 && Ins
      fl_ex=0
      @ y1+1,x1*dcol+1 SAY LEFT(page(I),8)+'.'+SUBSTR(page(I),9,3)
      SET COLOR TO GR+/R*
      @ 24,20 SAY 'Вставлять ?(Enter/Esc)'
      in_key=INKEY(0)
      SET COLOR TO W+/B
      @ 24,20
      IF in_key=13
         SCATTER TO recr
         Cursor=SYS(2002,1)
         DO WHILE .T.
            SET ORDER TO m1
            @ 17,1  SAY 'Коробка'      GET recr(6) PICT '999'
            @ 17,13 SAY 'Дискетта N'   GET recr(7) PICT '99'
            @ 17,27 SAY 'типa'         GET recr(8)
            @ 17,43 SAY 'Объем'        GET recr(9) PICT '9999'
            @ 17,54 SAY 'OC'           GET recr(10)
            @ 18,1  SAY 'Fname'        GET recr(1)
            @ 18,16 SAY 'Ext'          GET recr(2)
            @ 18,25 SAY 'Длина '       GET recr(5)
            @ 18,47 SAY 'Тип копии'    GET recr(11)
            @ 19,20 SAY 'Аннотация'
            @ 20,1  GET recr(3)
            @ 21,1  GET recr(4)
            READ
            IF READKEY()=12 .OR. READKEY()=268
               EXIT
            ENDIF
            SET ORDER TO 2 && matbdf - Коробка,дискетта,файл
            SEEK LTRIM(STR(recr(6)*100+recr(7)))+recr(1)+recr(2)
            IF FOUND()
               @ 24,2 SAY 'Такой файл на этой дискетте уже есть !'
               ! beep /r2
               @ 24,2
               LOOP
            ENDIF
            fl_ex=1
            INSERT Blank
            GATHER FROM recr
            ip=1           && Выдать,начиная со вставленного
            rn1st=RECNO()
            SET ORDER TO m1
            EXIT
         ENDDO
      ENDIF
      IF fl_ex=1
         EXIT
      ENDIF
      *  Редактирование - Enter
   CASE in_key=13 && Ins
      fl_ex=0
      SET COLOR TO GR+/R*
      @ y1+1,x1*dcol+1 SAY LEFT(page(I),8)+'.'+SUBSTR(page(I),9,3)
      SET COLOR TO W+/B
      SCATTER TO recr
      tempbdf=LTRIM(STR(BOX*100+disketn))+cod+ext
      Cursor=SYS(2002,1)
      DO WHILE .T.
         SET ORDER TO m1
         @ 17,1  SAY 'Коробка'      GET recr(6) PICT '999'
         @ 17,13 SAY 'Дискетта N'   GET recr(7) PICT '99'
         @ 17,27 SAY 'типa'         GET recr(8)
         @ 17,43 SAY 'Объем'        GET recr(9) PICT '9999'
         @ 17,54 SAY 'OC'           GET recr(10)
         @ 18,1  SAY 'Fname'        GET recr(1)
         @ 18,16 SAY 'Ext'          GET recr(2)
         @ 18,25 SAY 'Длина '       GET recr(5)
         @ 18,47 SAY 'Тип копии'    GET recr(11)
         @ 19,20 SAY 'Аннотация'
         @ 20,1  GET recr(3)
         @ 21,1  GET recr(4)
         @ 24,20 SAY 'Редактируйте ...'
         READ
         IF READKEY()=12 .OR. READKEY()=268
            EXIT
         ENDIF
         SET ORDER TO 2 && matbdf - Коробка,дискетта,файл
         tempkey=LTRIM(STR(recr(6)*100+recr(7)))+recr(1)+recr(2)
         IF tempbdf # tempkey
            SEEK tempkey
            IF FOUND()
               @ 24,2 SAY 'Такой файл на этой дискетте уже есть !'
               ! beep /r2
               LOOP
            ENDIF
         ENDIF
         GO rn
         GATHER FROM recr
         IF tempbdf # tempkey
            fl_ex=1
            ip=1           && Выдать,начиная с отредактированного
            rn1st=RECNO()
         ENDIF
         SET ORDER TO m1
         EXIT
      ENDDO
      @ 24,20
      IF fl_ex=1
         EXIT
      ENDIF
   ENDCASE
ENDDO
Cursor=SYS(2002,1)
*
*: EOF: IN_KEY.PRG


************************************************************
*                         ITOXY                            *
************************************************************

PROCEDURE ITOXY
*:*********************************************************************
*:
*:        Program: ITOXY.PRG
*:
*:         System: CatFd
*:         Author: Alperovitch L.Z. & Suravsky Yaroslaw Wla
*:      Copyright (c) 1991, A&S + SoftPanorama
*:  Last modified: 01/30/91     11:50
*:
*:      Called by: SHPAGE.PRG     
*:               : IN_KEY.PRG     
*:
*:     Documented: 01/30/91 at 13:06               FoxDoc version 1.0
*:*********************************************************************
x1 = INT (I/ry-0.01)
y1 = I - ry*x1
*: EOF: ITOXY.PRG


************************************************************
*                         MATIDR1                          *
************************************************************

PROCEDURE MATIDR1
*:*********************************************************************
*:
*:        Program: MATIDR1.PRG
*:
*:         System: CatFd
*:         Author: Alperovitch L.Z. & Suravsky Yaroslaw Wla
*:      Copyright (c) 1991, A&S + SoftPanorama
*:  Last modified: 01/30/91      8:31
*:
*:      Called by: MAT.PRG        
*:               : DELA.PRG       
*:               : MATI.PRG       
*:
*:     Documented: 01/30/91 at 13:06               FoxDoc version 1.0
*:*********************************************************************
CLEAR
@ 01,06 SAY "██    ████    ██████  ███████  ██████     ██████   ██████   ██████"
@ 02,06 SAY "██    █  █    █    █  █  █  █  █    █     █    █   █    █   █    █"
@ 03,06 SAY "██ ████       █    █     █     █    █     █    █   █    █   █"
@ 04,06 SAY "█████         ██████     █     ██████     █    █   █    █   █"
@ 05,06 SAY "██ ████       █    █     █     █    █     █    █   █    █   █"
@ 06,06 SAY "██    █ ████  █    █     █     █    █     █    █   █    █   █"
@ 07,06 SAY "██    █    █  █    █     █     █    █  ████    ██  ██████   █"
@ 08,12 SAY "██████"
@ 10,14  SAY "╔═══╗  ║  ╔╗ ╔══╗ ║ ╔═  ╔══╗ ╔═╦═╗ ╔═══╗ ║ ╔═"
@ 11,14  SAY "║   ║  ║ ╔╝║ ║    ╠═╩╗  ╠═     ║   ║   ║ ║═╩╗"
@ 12,14  SAY "║   ║  ║╔╝ ║ ║    ║  ║  ║      ║   ║   ║ ║  ║"
@ 13,13 SAY "╔╩═══╩╗ ╚╝    ╚═══    ╚═ ╚══╝       ╚═══╝    ╚═"
@ 22,13 SAY "COPYRIGHT(C) - Alperovitch L.Z. & Suravsky Yaroslaw Wladim.-1990,91"
*: EOF: MATIDR1.PRG


************************************************************
*                         RAMKA                            *
************************************************************

PROCEDURE RAMKA
*:*********************************************************************
*:
*:        Program: RAMKA.PRG
*:
*:         System: CatFd
*:         Author: Alperovitch L.Z. & Suravsky Yaroslaw Wla
*:      Copyright (c) 1991, A&S + SoftPanorama
*:  Last modified: 01/29/91     18:33
*:
*:      Called by: DELA.PRG       
*:
*:     Documented: 01/30/91 at 13:06               FoxDoc version 1.0
*:*********************************************************************
CLEAR
*
@ 01, 00 SAY "╔══════════════╤══════════════╤══════════════╤══════════════╤══════════════╗"
I=1
DO WHILE I<ry+1
   I=I+1
   @ I, 00 SAY "║              │              │              │              │              ║"
ENDDO
@ I+1,00 SAY "╠══════════════╧══════════════╧══════════════╧══════════════╧══════════════╣"
@ I+2,00 SAY "║                                                                          ║"
@ I+3,00 SAY "║                                                                          ║"
@ I+4,00 SAY "║                                                                          ║"
@ I+5,00 SAY "║                                                                          ║"
@ I+6,00 SAY "║                                                                          ║"
@ I+7,00 SAY "║                                                                          ║"
@ I+8,00 SAY "╙──────────────────────────────────────────────────────────────────────────╜"

*: EOF: RAMKA.PRG


************************************************************
*                         RPAGE                            *
************************************************************

PROCEDURE RPAGE
*:*********************************************************************
*:
*:        Program: RPAGE.PRG
*:
*:         System: CatFd
*:         Author: Alperovitch L.Z. & Suravsky Yaroslaw Wla
*:      Copyright (c) 1991, A&S + SoftPanorama
*:  Last modified: 01/30/91      9:08
*:
*:      Called by: DELA.PRG       
*:
*:     Documented: 01/30/91 at 13:06               FoxDoc version 1.0
*:*********************************************************************
*    rpage   && 1 - Прочесть блок в память
GO TOP
IF .NOT. EOF()
   GO rn1st   &&  ачиная с ...
ENDIF
*
RECC=1  && Количество записей,загруженных в память
*
DO WHILE .NOT. EOF() .AND. RECC<=rx*ry
   page (RECC) = cod+ext+LTRIM(STR(RECNO()))
   SKIP
   RECC=RECC+1
ENDDO
RECC=RECC-1
*
IF RECC = 0
   @ 10,15,12,62 BOX
   @ 11,16 SAY 'БД пуста - зарегистрируйте 1-ю новую коробку !'
   ? REPL(CHR(7),5)
   close all
   ! del mat?????.idx>nul
   quit 
ENDIF
*: EOF: RPAGE.PRG


************************************************************
*                         SHPAGE                           *
************************************************************

PROCEDURE SHPAGE
*:*********************************************************************
*:
*:        Program: SHPAGE.PRG
*:
*:         System: CatFd
*:         Author: Alperovitch L.Z. & Suravsky Yaroslaw Wla
*:      Copyright (c) 1991, A&S + SoftPanorama
*:  Last modified: 01/30/91      8:36
*:
*:      Called by: DELA.PRG       
*:
*:          Calls: ITOXY.PRG
*:
*:     Documented: 01/30/91 at 13:06               FoxDoc version 1.0
*:*********************************************************************
* Показать блок
I=1            && N ячейки в блоке
dcol=15        && Расстояние между столбцами
*
DO WHILE I <= RECC
   DO itoxy && Пересчет i в координаты x,y
   @ y1+1,x1*dcol+1 SAY LEFT(page(I),8)+'.'+SUBSTR(page(I),9,3)
   I=I+1
ENDDO
*: EOF: SHPAGE.PRG


************************************************************
*                         SIGNFD                           *
************************************************************

PROCEDURE SIGNFD
*         Заполнение   сигнатуры   дискетты
DO WHILE .T. && Установка режима заполнения БД сведениями о файлах дискетты
   m=2
   kvofiles=0
   rtipcopy='COPY    '
   @  6, 6 GET rbox        PICTURE "999"
   @  6,10 GET I           PICTURE "99"
   @  6,13 SAY ' из ' GET rdisketn PICT '99'
   @  6,21
   @  7,25
   @  8, 0
   @ 10, 0
   @ 11, 0
   @ 13,13 GET rtipd
   @ 15,10 GET rdens       PICTURE "9999"
   @ 17, 7 GET rtipevm
   CLEAR GETS
   SET COLOR TO ,2+*/209
   @ 5,35 SAY  'Как будем заполнять поля Filename Ext Длина ?'
   @ 6,35 PROM '1       - вручную; Esc - выход'
   @ 7,35 PROM '2/Enter - по XDIR (только для МSDOS COPY !)'
   MENU TO m
   SET COLOR TO W+/B,GR+/N
   DO CASE
   CASE m=0
      RETURN 
   CASE m=2
      @ 6,35
      @ 7,35 SAY '        - по XDIR (только для МSDOS COPY !)'
      SET COLOR TO 2+*/209,GR+*/N
      drv='A'
      @ 23,20 SAY 'Уст.дискетту в (ABEFGH)' GET drv ;
         VALID AT(drv,'ABEFGHabefgh')#0
      READ
      @ 23,20 SAY 'Читаю каталог командой XDIR ...           '
      ! xdir &drv:>dir.txt
      @ 23,20
      @ 23,20 SAY 'Дискетта прочтена ...'
      ? CHR(7)
      @ 23,20 say 'Можете вынуть дискетту ...                            '
      ? chr(7)
      @ 23,20
      set color to w+/b,gr+/n
      SELE 2
      SET SAFE OFF
      IF FILE('dirtxt.dbf')
         USE dirtxt
         ZAP
      ELSE
         SAVE SCREEN TO scrt
         SET COLO TO N/N,N/N,N
         KEYBOARD 'TXT'+CHR(13)+'C80'+CHR(13)+CHR(13)+CHR(13)+'N'
         CREA DIRTXT
         CLEA TYPE
         SET COLO TO W+/B,GR+/N
         REST SCREEN FROM scrt
      ENDIF
      APPE FROM dir.txt TYPE SDF
      DELE && удалили последнюю строку каталога,она нам не нужна
      GO TOP
      PACK
      dele file dir.txt
      kvofiles=RECCOUNT()
      IF kvofiles=0
         @ 7,25
         SET COLO TO GR+*/N
         @ 7,25 SAY 'ЭTA ДИСКЕТТА ПУСТА !!!'
         SET COLO TO W+/B,GR+/N
         ? REPL(CHR(7),5)
         LOOP
      ENDIF
   CASE m=1
      @ 6,35 SAY '        - вручную'
      @ 7,25
      CLEAR GETS
      @ 7,25 SAY 'Вид копии:СОРУ/LONGCOPY/BACKUP/PCBACKUP/FASTBACK/...'
      @ 8,25 GET rtipcopy
      READ
      @ 8,25
      @ 7,25
      @ 7,25 SAY 'Вид копии' GET rtipcopy
   ENDCASE
   EXIT
ENDDO
SELE 1
SET COLO TO W+/B,GR+/N
J=1
DO WHILE .T. && Hа одной дискете м.быть несколько файлов
   @  6,21 GET J PICT '99'
   IF m=2
      @  6,23 SAY 'из' GET kvofiles PICT '99'
   ENDIF
   CLEAR GETS
   *
   INSERT Blank
   REPL BOX     WITH rbox
   REPL disketn WITH I
   REPL tipd    WITH rtipd
   REPL dens    WITH rdens
   REPL tipevm  WITH rtipevm
   REPL tipcopy WITH rtipcopy
   *
   IF m=2
      SELE 2
      GO J
      RTXT=FIELD(1)
      rtxt=&RTXT
      SELE 1
      ptr=AT('.',SUBSTR(rtxt,41,9))
      IF ptr=0
         REPL cod  WITH SUBSTR(rtxt,41,8)
      ELSE
         REPL cod  WITH SUBSTR(rtxt,41,ptr-1)
         REPL ext  WITH SUBSTR(rtxt,41+ptr,3)
      ENDIF
      IF LEFT(rtxt,9) = 'DIRECTORY'
         REPL name1 WITH 'DIR'
      ELSE
         REPL lenf  WITH SUBSTR(rtxt,9,10)
         REPL name1 WITH LEFT(rtxt,6)
      ENDIF
   ENDIF
   @  8, 0 GET cod
   @  8, 9 GET ext
   @  8,15 GET lenf
   IF m=2
      CLEAR GETS
   ENDIF
   *
   @ 10, 0 GET name1
   @ 11, 0 GET name2
   READ
   IF READKEY()=12 .OR. READKEY()=268
      fl_del=1
      DELETE
      EXIT
   ENDIF
   J=J+1
   IF m=2 .AND. J>kvofiles
      EXIT
   ENDIF
ENDDO
*: EOF: SIGNFD.PRG
