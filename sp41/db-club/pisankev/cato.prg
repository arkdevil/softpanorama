*:*********************************************************************
*:
*:        Program: CATO.PRG
*:
*:         System: КАТАЛОГ ДИСКЕТ
*:         Author: Альпеpович Л З, Пузанкевич П.И.
*:      Copyright (c) 1991, г. Твеpь
*:  Last modified: 04/09/91     16:15
*:
*:      Called by: CAT.PRG        
*:
*:          Calls: ZAST.PRG
*:
*:           Uses: KLASS.DBF      
*:               : DISKI.DBF      
*:               : SYSTEMS.DBF    
*:
*:        Indexes: ITMP.IDX
*:               : ITMP.NDX
*:               : IDISKI.NDX
*:               : ISYSTEMS.NDX
*:
*:   Report Forms: &OTH
*:
*:     Documented: 04/09/91 at 16:20               FoxDoc version 1.0
*:*********************************************************************
*CATO  - выдача отчета
SET SAFETY OFF
ON ESCAPE RETURN
SAVE SCREEN TO ekr2
DIMENSION ks(6)
STORE ' ' TO ks
ks(3)='i'
ks(4)='d'
ks(5)='n'

c1=1
DO WHILE .T.
   RESTORE SCREEN FROM ekr2
   ss=' '
   SET PRINT OFF
   SET FILTER TO
   SET COLOR TO N/W
   @ 15,23,20,52 BOX '▒'
   SET COLOR TO R+/N
   @ 16,22 TO 21,51 DOUBLE
   @ 16,30 SAY " Выдача отчета "
   SET COLOR TO W+/B,GR+/BG
   @ 17,23 PROMPT "      По  дискетам          "
   @ 18,23 PROMPT "   По системам, программам  "
   @ 19,23 PROMPT "   По классификатору        "
   @ 20,23 PROMPT "   Возврат в главное меню   "
   MENU TO c1
   DO CASE
   CASE c1=4
      EXIT
   CASE c1=3
      SELE 3
      USE klass
      STORE "klass" TO oth
   OTHERWISE
      IF c1=1
         SELECT 2
         USE DISKI INDEX IDISKI
      ELSE
         SELECT 1
         USE SYSTEMS INDEX ISYSTEMS
      ENDIF
      DELETE FILE itmp.idx
      k=1
      prff=''
      SET COLOR TO W+/B,N/W
      @ 14,10 CLEAR TO 22,70
      @ 14,10 TO 22,70 DOUBLE
      DO WHILE LEN(prff)<5
         @ 15,11 SAY "Задайте код сортировки пpоизвольной комбинацией букв:" GET prff
         IF c1=1
            @ 16,25 SAY "f - формат дискетки                "
            @ 17,25 SAY "b - номер коробки                  "
            @ 18,25 SAY "i - владелец дискетки              "
            ks(1)='f'
            ks(2)="b"
         ELSE
            @ 16,25 SAY "c - код программного продукта      "
            @ 17,25 SAY "k - класс                          "
            @ 18,25 SAY "i - источник                       "
            ks(1)='c'
            ks(2)="k"
         ENDIF
         @ 19,25 SAY "d - номер дискетки                 "
         @ 20,25 SAY "n - назначение                     "
         @ 21,25 SAY "  - конец задания ключа сортировки "
         CLEAR GETS
         I=1
         DO WHILE I<7
            @ 15+I,25 PROMPT ks(I)
            I=I+1
         ENDDO
         MENU TO k
         IF k=6
            EXIT
         ENDIF
         prff=prff+ks(k)
      ENDDO   && задания сортировичн ключа
*      @ 15,64  GET prff
      CLEAR GETS
      I=LEN(TRIM(prff))
      IF I>0
         k=1
         STORE ' ' TO mm
         STORE ' ' TO ssss
         *        сортировка в любом наборе полей
         DO WHILE k<=I
            STORE SUBSTR(prff,k,1) TO prf
            DO CASE
            CASE prf='c'.AND. c1=2
               STORE 'cod' TO nn
               STORE 'ИМЕHАМ ФАЙЛОВ' TO ssss
            CASE prf='d'
               STORE 'substr(space(8)+disk,len(space(8)+trim(disk))-7,8)' TO nn
               STORE 'ДИСКЕТАМ' TO ssss
            CASE prf='b'.AND. c1=1
               STORE 'tran(box,"99")' TO nn
               STORE 'КОРОБКАМ' TO ssss
            CASE prf='i'
               IF c1=2
                  STORE 'source' TO nn
                  STORE 'ИСТОЧHИКУ' TO ssss
               ELSE
                  STORE 'vladelec' TO nn
                  STORE 'ВЛАДЕЛЬЦАМ' TO ssss
               ENDIF
            CASE prf='n'
               STORE 'system' TO nn
               STORE 'HАЗHАЧЕHИЮ' TO ssss
            CASE prf='k'.AND. c1=2
               STORE 'tran(kl,"99")' TO nn
               STORE 'КЛАССУ' TO ssss
            CASE prf='f'.AND. c1=1
               STORE 'format' TO nn
               STORE 'ФОРМАТУ ДИСКЕТ' TO ssss
            OTHERWISE
               WAIT 'Ошибка в ключе сортировки'
               EXIT
            ENDCASE
            k=k+1
            STORE mm+nn+'+' TO mm
            STORE ss+' '+ssss TO ss
         ENDDO    &&k
         *
         STORE SUBSTR(mm,1,LEN(mm)-1) TO mm
         @ 23,10 SAY [Сортировка по]+ss
         SET COLOR TO W*/B
         @ 24,35 SAY 'ЖДИТЕ'
         IF c1=1
            SELECT 2
         ELSE
            SELECT 1
         ENDIF
         INDEX  TO itmp ON &mm
         SET COLOR TO W/B
         @ 23,0 CLEAR
         SET INDEX TO itmp
      ENDIF             &&len(pprf)>0
      STORE SPACE(60) TO ppff
      SET COLOR TO W/N,N/W
      @ 23,2 SAY "Задайте фильтр:" GET ppff
      READ
      IF LEN(TRIM(ppff))>0
         SET FILTER TO &ppff.
         GO TOP
      ENDIF
   ENDCASE      &&    c1 конец подготовки и выбора файла БД для отчета
   *
   ON ERROR  I=1
   I=1
   c2=1
   DO WHILE I=1
      I=0
      RESTORE SCREEN FROM ekr2
      SET COLOR TO W/N
      @ 15,23,20,52 BOX ' '
      SET COLOR TO W+/B,GR+/BG
      @ 16,22 TO 21,51 DOUBLE
      @ 16,34 SAY [ Вывод ]
      @ 17,23 PROMPT "       Ha принтер           "  MESSAGE;
         " "
      @ 18,23 PROMPT "     В текстовoй файл       " MESSAGE;
         [          Файл можно просмотреть на экране или распечатать]
      @ 19,23 PROMPT "           Выход            " MESSAGE;
         "                   Выход в меню выбора типов отчетов   "
      @ 20,23    SAY "                            "
      MENU TO c2
      c22=1
      IF c2#3
         IF c1#3
            SET COLOR TO W/N
            @ 15,23,20,52 BOX ' '
            SET COLOR TO W+/B,GR+/BG
            @ 16,22 TO 21,51 DOUBLE
            @ 16,30 SAY [ Формат отчета ]
            @ 17,23 SAY    "                            "
            @ 18,23 PROMPT "          Краткий           " MESSAGE;
               [         Ширина 80 позиций, занимает мало памяти, печатается быстро ]
            @ 19,23 PROMPT "          Полный            " MESSAGE;
               [Выдача всех полей, в т.ч. МЕМО(135 поз).По 1000 зап форм-ся отчет дл более 1М]
            @ 20,23 SAY    "                            "
            MENU TO c22
            DO CASE
            CASE c22 = 1
               IF c1 = 1
                  STORE "d" TO oth
               ELSE
                  STORE "s" TO oth
               ENDIF
            CASE c22 = 2
               IF c1 = 1
                  STORE "dm" TO oth
               ELSE
                  STORE "sm" TO oth
               ENDIF
            ENDCASE
         ENDIF      &&c1#3    конец уточнения имени отчета
         DO CASE
         CASE c2 = 1
            SET PRINT ON
            IF c22=2
               ?? CHR(15)
            ENDIF
            ? " Отсортировано по",ss
            ?
            *      keyboard  oth
            REPORT FORM &oth PLAIN TO PRINT
            rec=RECCOUNT()
            ? 'Число записей в базе ', rec
            ?
            ?? CHR(18)
         CASE c2 = 2
            SET COLOR TO W/N,GR+/N
            STORE 'ot.txt                          ' TO pr
            @ 23,17 SAY "Имя файла :" GET pr
            READ
            pr=TRIM(pr)
            @ 23,0 CLEAR
            ? ss
            ?
            *     keyboard  oth
            on error
            *SET SAFETY ON
            REPORT FORM &oth TO FILE &pr
            *SET SAFETY off
            DO zast
            k=1
            SET COLOR TO W+/B,GR+/BG
            @ 15,5 SAY 'Хотите сейчас просмотреть файл '+'&pr?'
            @ 14,59,17,63 BOX
            @ 15,60 PROMPT "Да "
            @ 16,60 PROMPT "Heт"
            MENU TO k
            IF k=1
               ! VIEW &pr
            ENDIF
         ENDCASE
         IF I=1
            ACCEPT  'ОШИБКА ' TO str1
            KEY=INKEY(1)
            LOOP
         ENDIF
      ENDIF                            &&c2#3  kohec vydachi otcheta
      DO CASE
      CASE c1=1
         SELECT 2
         USE diski INDEX idiski
      CASE c1=2
         SELECT 1
         USE systems INDEX isystems
      ENDCASE
      DELETE  FILE itmp.idx
   ENDDO    &&i  кон цикла выбора назначен отчета
   ON ERROR
ENDDO
RETURN
**************************************
*: EOF: CATO.PRG
