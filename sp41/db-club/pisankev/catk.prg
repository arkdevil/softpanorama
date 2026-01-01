*:*********************************************************************
*:
*:        Program: CATK.PRG
*:
*:         System: КАТАЛОГ ДИСКЕТ
*:         Author: Пузанкевич П.И.
*:      Copyright (c) 1991, г. Твеpь
*:  Last modified: 12/12/90     16:59
*:
*:      Called by: CAT.PRG        
*:
*:          Calls: ZAST.PRG
*:               : CATP.PRG
*:
*:     Documented: 04/09/91 at 16:20               FoxDoc version 1.0
*:*********************************************************************
*CATK   поиск и корректировка по классификатору
* Движение по класc-у   UP,DOWN,LEFT,RIGHT
* Смена записи          pgUP,pgDN
* Сохранен класc. кода  Entry
* Завершение            ^END
* Прерывание            ESC
* Q2=2  изменение в БД SYSTEMS классиф. кода текущей записи
* Q2=1  поиск в БД SYSTEMS записей по классификатору
up = 5
down = 24
LEFT = 19
RIGHT = 4
pgup = 18
pgdn = 3
esc = 27
car_ret = 13
f7  = -6
f8  = -7
f9  = -8
f10 = -9
ctrl_end = 23
KEY = 0
q2=1
SELECT 1
DO WHILE .T.
   DO zast
   SET COLOR TO W/N
   @ 15,15,19,66 BOX '▒'
   SET COLOR TO W+/B,GR+/BG
   @ 16,14 TO 20,65 DOUBLE
   @ 17,15 PROMPT "   Поиск по классификатору в каталоге систем      "
   @ 18,15 PROMPT "   Корректировка классификационного кода записей  "
   @ 19,15 PROMPT "           Возврат в предыдущее меню              "
   MENU TO q2
   IF q2=3
      EXIT
   ENDIF
   SET COLOR TO
   CLEAR
   SET COLOR TO R+/N
   @ 1,1,21,79 BOX '▒'
   SET COLOR TO
   @ 20,1 CLEAR TO 21,77
   @ 2,0 TO 22,78 DOUBLE
   @ 3,26 TO 18,26
   @ 3,52 TO 18,52
   @ 19,1 TO 19,77
   SET COLOR TO W/B
   k=0
   DO WHILE k<3
      I=1
      J=k*26+1
      DO WHILE I<17
         z=I+k*16
         @ I+2,J SAY kk(z)
         I=I+1
      ENDDO
      k=k+1
   ENDDO
   SET COLOR TO W+/B
   @ 23,1 SAY [Выбор классиф. кода: ]+CHR(27)+CHR(24)+CHR(25)+CHR(26)
   @ 24,35 SAY [Выход: Ctrl-End]
   IF q2=2
      @ 0,12 SAY [Корректировка классификационных кодов записей БД SYSTEMS]
      @ 20,56 SAY [Версия:]
      @ 21,2 SAY [Диск(1):         из:   Длина:          Класс:]
      @ 23,27 SAY [Cлед/Пред зап: PgDn/PgUp  Замена кл. кода в БД: Enter]
   ELSE
      @ 0,15 SAY [Просмотр записей БД SYSTEMS по классификатору]
      @ 21,2 SAY [                                       Класс:]
      @ 23,27 SAY [       Поиск систем по классификационному коду: Enter]
   ENDIF
   io=1
   in=1
   ko=0
   kn=0
   DO WHILE .T.
      SET COLOR TO W/B
      @ io+2,ko*26+1 SAY kk(io+ko*16)
      SET COLOR TO GR+/BG
      z=in+kn*16
      @ in+2,kn*26+1 SAY kk(z)
      SET COLOR TO W/B,GR+/BG
      IF q2=2
         @ 20,2 GET cod
         @ 20,11 GET ext
         @ 20,15 GET system
         @ 20,63 GET VERS
         @ 20,69 GET date_in
         @ 21,10 GET DISK
         @ 21,22 GET kol PICTURE "99"
         @ 21,31 GET size PICTURE '99999999'
         @ 21,47 GET kl PICTURE '99'
         IF kl=0
            @ 21,51 GET kk(48)
         ELSE
            @ 21,51 GET kk(kl)
         ENDIF
      ELSE
         IF z=48
            @ 21,41 SAY [Класс: 0]
            @ 21,51 GET kk(48)
         ELSE
            @ 21,47 GET z PICTURE '99'
            @ 21,51 GET kk(z)
         ENDIF
      ENDIF    Q2=2
      CLEAR GETS
      io=in
      ko=kn
      SET COLOR TO W/B
      
      KEY = INKEY()
      DO WHILE KEY = 0
         KEY = INKEY()
      ENDDO
      *
      DO CASE
      CASE KEY = up
         in = IIF(io=1,16,io-1)
      CASE KEY = down
         in = IIF(io=16,1,io+1)
      CASE KEY = LEFT
         kn = IIF(ko=0,0,ko-1)
      CASE KEY = RIGHT
         kn= IIF(ko=2,2,ko+1)
      CASE KEY = pgup .AND. q2=2
         SKIP -1
         IF BOF()
            GO TOP
         ENDIF
      CASE KEY = pgdn .AND.q2=2
         SKIP 1
         IF EOF()
            GO BOTTOM
         ENDIF
      CASE  KEY = car_ret  &&car_ret
         IF q2=2
            IF z=maxk
               REPLACE kl WITH 0
            ELSE
               REPLACE kl WITH z
            ENDIF
         ELSE
            IF z=maxk
               flt=''
            ELSE
               flt='KL=Z'
            ENDIF
            SAVE SCREEN TO ekr2
            q1=.T.
            DO catp
            RESTORE SCREEN FROM ekr2
         ENDIF
      CASE KEY = ctrl_end
         EXIT
      ENDCASE
   ENDDO
ENDDO
RETURN
*: EOF: CATK.PRG
