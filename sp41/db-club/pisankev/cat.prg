*:*********************************************************************
*:
*:        Program: CAT.PRG
*:
*:         System: КАТАЛОГ ДИСКЕТ
*:         Author: Пузанкевич П.И., Альперович Л.З.
*:      Copyright (c) 1991, г. Твеpь
*:  Last modified: 04/09/91     16:01
*:
*:          Calls: ZAST.PRG
*:               : CATP.PRG
*:               : CATK.PRG
*:               : CATO.PRG
*:               : CATD.PRG
*:
*:           Uses: KLASS.DBF      
*:               : DISKI.DBF      
*:               : SYSTEMS.DBF    
*:
*:        Indexes: IDISKI.NDX
*:               : ISYSTEMS.NDX
*:
*:     Documented: 04/09/91 at 16:20               FoxDoc version 1.0
*:*********************************************************************
* CAT  - Программа выдачи каталога дискет, головной модуль
SET STATUS OFF
ON ESCAPE RETURN
SET SCORE OFF
SET TALK OFF
SET SAFETY OFF
maxk=48
DO zast
SET MESSAGE TO 24
SELE 3
USE klass
DIMENSION kk(maxk)
STORE SPACE(25) TO kk
I=1
DO WHILE I<maxk .AND..NOT. EOF()
   kk(I)=class
   I=I+1
   SKIP
ENDDO
USE
SELECT 2
USE diski
IF .NOT.FILE('idiski.idx')
   INDEX  TO idiski ON SUBSTR(SPACE(8)+DISK,LEN(SPACE(8)+TRIM(DISK))-7,8)
ENDIF
USE diski INDEX idiski
SELECT 1
USE systems
IF .NOT.FILE('isystems.idx')
   INDEX  TO isystems ON cod+ext
ENDIF
USE systems INDEX isystems
DO WHILE .T.
   DO zast
   SET COLOR TO W/N
   @ 15,23,20,52 BOX '▒'
   SET COLOR TO W+/B,GR+/BG
   @ 16,22 TO 21,51 DOUBLE
   @ 17,23 PROMPT "  Просмотр и корректировка  "
   @ 18,23 PROMPT "        Выдача отчета       "
   @ 19,23 PROMPT "  Снятие данных с дискеты   "
   @ 20,23 PROMPT "           Конец            "
   
   MENU TO choice
   *
   DO CASE
   CASE choice = 1
      DO WHILE .T.
         z=maxk
         flt=''
         DO zast
         SET COLOR TO N/W
         @ 15,23,20,52 BOX '▒'
         SET COLOR TO R+/N
         @ 16,22 TO 21,51 DOUBLE
         @ 16,24 SAY " Просмотр и корректировка "
         SET COLOR TO W+/B,GR+/BG
         @ 17,23 PROMPT " Каталога дискет            "
         @ 18,23 PROMPT " Каталога систем, программ  "
         @ 19,23 PROMPT " По классификатору программ "
         @ 20,23 PROMPT "   Возврат в главное меню   "
         MENU TO choice
         DO CASE
         CASE choice=1
            q1=.F.
            DO catp
         CASE choice=2
            q1=.T.
            DO catp
         CASE choice=3
            DO catk
         CASE choice=4
            EXIT
         ENDCASE
      ENDDO
   CASE choice = 2
      DO cato
   CASE choice = 3
      DO catd
   OTHERWISE
      CLOSE ALL
      QUIT
   ENDCASE
   *
ENDDO
*: EOF: CAT.PRG
