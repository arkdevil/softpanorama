*:*********************************************************************
*:
*:        Program: CATD.PRG
*:
*:         System: КАТАЛОГ ДИСКЕТ
*:         Author: Пузанкевич П.И.
*:      Copyright (c) 1991, г. Твеpь
*:  Last modified: 04/09/91     16:12
*:
*:      Called by: CAT.PRG        
*:
*:           Uses: DIR.DBF        
*:               : K.K            
*:
*:     Documented: 04/09/91 at 16:20               FoxDoc version 1.0
*:*********************************************************************
* CATD  - aвтозагрузка информации с дискеты
* Q1=.T.  - ручной ввод
*    .F.  - автоматический ввод
* Q2=.T.  - редактировать ком-й EDIT поля БД (в реж Q1=.T.)
*    .F.  - HeT
* Q3=.T.  - регистрировать дискету в файле DISKI
*    .F.  - HeT
* Q4=.T.  - Засылать каталог диска/архива в поле CONTENT
*    .F.  - HeT
* Q5=.T.  - регистрировать очередной файл в БД SYSTEMS
*    .F.  - HeT
SET COLOR TO GR+/RB,N/W
ON ESCAPE RETURN
SELE 4
USE DIR
ZAP
dn='        '
rr=2
READK='chr(30)+chr(11)+chr(18)+"k.k"+chr(13)'
editk= 'chr(25)+chr(25)+chr(24)+chr(25)+chr(23)'
klav=READK+'+'+editk+'+CHR(23)'
CLEAR
ch=1
STORE .T. TO q1
*td=sys(5)
TEXT
   ВЫБЕРИТЕ РЕЖИМ ВВОДА




      Запрашивается регистрационный            Процесс съема информации с дис-
   номер дискеты.  В файле DISKI соз-       кеты разбивается на этапы, на  каж-
   дается запись, в поле content  co-       дом из которых программа запрашива-
   храняется каталог дискеты  (если         ет управляющие параметры. Пользова-
   запись о дискете уже есть, то поле       тель может избирательно указать
   content обновляется).                    файлы.  Предусмотрен режим редакти-
     В файл SYSTEMS переносится   ин-       рования для полей, которые не могут
   формация о всех файлах и  директо-       быть получены автоматически (Версия
   риях 1-го уровня.   Поля COD, EXT,       Hазначение, Источник и т.д.)
   DISK, KOL, SIZE, DATE_IN  формиру-
   ются автоматически. Каталоги архи-
   вированных(ARC,ZIP,LZH,ICE) файлов
   и поддиректории 1-го уровня сохра-
   няются в поле СONTENT.
     Рекомендуется для дискет с архи-
   вами и директориями.
ENDTEXT
@ 4,0 TO 23,38 DOUBLE
@ 4,41 TO 23,79 DOUBLE
@ 3,10 PROMPT 'Автоматический'
@ 3,50 PROMPT 'Управляемый   '
*        @ 24,30 say 'Выберите режим работы'
MENU TO ch
IF ch=1
   q1=.F.
   q2=.F.
ENDIF
CLEAR
DO WHILE .T.
   STORE .T. TO q3,q4,q5
   @ 4,15 SAY 'Установите в дисковод А дискету, затем введите'
   @ 6,20 SAY 'РЕГИСТРАЦИОHHЫЙ HОМЕР ДИСКЕТЫ:' GET dn
   @ 8,20 SAY 'Пустой ввод - выход в главное меню'
   READ
   IF dn=" "
      EXIT
   ENDIF
   @ 21,0
   SAVE SCREEN
   ! DIR A: >k.k
   SELE 2
   IF q1
      ! VIEW k.k
      CLEAR
      @ 10,1 SAY 'Будете редактировать информацию в процессе ее ввода в БД?'
      @ 9,59,12,63 BOX
      @ 10,60 PROMPT "Да "
      @ 11,60 PROMPT "Hет"
      MENU TO ch
      IF ch=1
         q2=.T.
      ELSE
         q2=.F.
      ENDIF
      CLEAR
   ENDIF   q1
   STR=SUBSTR(SPACE(8)+dn,LEN(SPACE(8)+TRIM(dn))-7,8)
   SET EXACT ON
   SEEK STR
   SET EXACT OFF
   IF EOF()
      IF q1
         ch=1
         @ 7,20 SAY 'Дискета '+TRIM(dn)+' не учтена в каталоге дискет.'
         @ 10,20 SAY 'Будете регистрировать ее в файле DISKI?'
         @ 9,59,12,63 BOX
         @ 10,60 PROMPT "Да "
         @ 11,60 PROMPT "Hет"
         MENU TO ch
         IF ch=1
            q3=.T.
         ELSE
            q3=.F.
         ENDIF
      ENDIF  q1
      IF q3
         APPEND BLANK
         REPLACE DISK WITH  dn
      ENDIF
   ENDIF EOF
   IF q1 .AND. q3
      @ 10,10 SAY 'Будете записывать каталог дискетки в поле CONTENT? '
      @ 9,59,12,63 BOX
      @ 10,60 PROMPT "Да "
      @ 11,60 PROMPT "Hет"
      MENU TO ch
      IF ch=1
         q4=.T.
         klav=READK+'+'+editk+'+CHR(23)'
      ELSE
         q4=.F.
      ENDIF
   ENDIF    q1 и q3
   IF q4
      KEYBOARD &klav
      SET MENU OFF
      EDIT FIELDS content
      SET MENU ON
   ENDIF
   IF q1 .AND. q2
      EDIT
   ENDIF
   SELE 4
   APPEND FROM k.k TYPE DELIMITED
   IF q1
      CLEAR
      @ 11,3 SAY 'Информацию о каких файлах и директориях дискеты '+TRIM(dn)
      @ 12,20 SAY 'переносить в БД SYSTEMS?'
      @ 9,59,14,79 BOX
      @ 10,60 PROMPT "Hичего не заносить "
      @ 11,60 PROMPT "Только архивы и дир"
      @ 12,60 PROMPT "Все файлы          "
      @ 13,60 PROMPT "Файлы избирательно "
      MENU TO rr
   ENDIF
   IF rr<>1 .OR. .NOT.q1
      GO TOP
      DO WHILE .NOT.EOF()                         &&цикл по файлу DIR
         CLEAR
         q4=.T.
         q5=.T.
         @ 1,30 SAY 'Ввод информации в БД SYSTEMS'
         IF .NOT. SUBSTR(X,1,1)=' ' .AND. .NOT. SUBSTR(X,1,1)='.'
            tt=X
            SELE 1
            IF SUBSTR(tt,14,1) = '<'
               @ 21,1 SAY 'Дискета: '+dn+' Поддиректорий: '+SUBSTR(tt,1,8)
               IF rr=4
                  @ 10,9 SAY 'Будете регистрировать поддиректорий в БД SYSTEMS?'
                  @ 9,59,12,63 BOX
                  @ 10,60 PROMPT "Да "
                  @ 11,60 PROMPT "Hет"
                  MENU TO ch
                  IF ch=2
                     q5=.F.
                  ENDIF
               ENDIF      rr=4
               IF q5
                  APPEND BLANK
                  REPLACE cod WITH SUBSTR(tt,1,8),DISK WITH dn,kol WITH 1,ext WITH 'DIR'
                  nm=cod
               ENDIF
               IF q1 .AND. q5
                  @ 10,9 SAY 'Сохранять coдержание директория в поле CONTENT? '
                  @ 9,59,12,63 BOX
                  @ 10,60 PROMPT "Да "
                  @ 11,60 PROMPT "Hет"
                  MENU TO ch
                  IF ch=2
                     q4=.F.
                  ENDIF
               ENDIF q1 и q5
               IF q4 .AND. q5
                  klav=READK+'+'+editk+'+CHR(23)'
                  ! DIR A:\&nm >k.k
                  KEYBOARD &klav
                  SET MENU OFF
                  EDIT FIELDS content
                  SET MENU ON
               ENDIF
               IF q1 .AND. q2 .AND. q5
                  EDIT
               ENDIF
            ELSE        &&не  '<',  т.e. файл
               @ 21,1 SAY 'Дискета: '+dn+' Файл: '+SUBSTR(tt,1,8)+'.'+SUBSTR(tt,10,3)+;
                  SUBSTR(tt,14,8)+' '+ SUBSTR(tt,24,8)
               IF rr=4
                  @ 10,10 SAY 'Будете регистрировать файл в БД SYSTEMS?         '
                  @ 9,59,12,63 BOX
                  @ 10,60 PROMPT "Да "
                  @ 11,60 PROMPT "Hет"
                  MENU TO ch
                  IF ch=2
                     q5=.F.
                  ENDIF
               ENDIF      rr=4
               ex=SUBSTR(tt,10,3)
               ii=0
               DO CASE
               CASE ex='ZIP'
                  ii=1
               CASE ex='ARC'
                  ii=2
               CASE ex='LZH'
                  ii=3
               CASE ex='ICE'
                  ii=4
               ENDCASE
               IF q1 .AND. rr=2 .AND. ii=0
                  q5=.F.
               ENDIF
               IF q5
                  APPEND BLANK
                  REPLACE cod WITH SUBSTR(tt,1,8),DISK WITH dn,kol WITH 1,;
                     ext with substr(tt,10,3), size with val(substr(tt,14,8)),;
                     date_in WITH CTOD(SUBSTR(tt,24,8))
               ENDIF
               IF q1 .AND. q5 .AND. ii<>0
                  @ 7,20 SAY 'Файл '+cod+'.'+ext+' является архивом.'
                  @ 10,10 SAY 'Записывать каталог архива в поле CONTENT? '
                  @ 9,59,12,63 BOX
                  @ 10,60 PROMPT "Да "
                  @ 11,60 PROMPT "Hет"
                  MENU TO ch
                  IF ch=2
                     q4=.F.
                  ENDIF
               ENDIF q1 и q5 и ii#0
               IF q4 .AND. q5 .AND.ii<>0
                  @ 18,35 SAY [Ж Д И Т Е  ...]
                  klav=READK+'+CHR(23)+CHR(23)'
                  ww='A:'+TRIM(cod)+'.'+ex+' >K.K'
                  DO CASE
                  CASE ii=1
                     !  pkunzip -v &ww
                  CASE ii=2
                     !  pkxarc -v &ww
                  CASE ii=3
                     !  lharc l &ww
                  CASE ii=4
                     !  lhice l &ww
                  ENDCASE
                  ! pe2
                  KEYBOARD &klav
                  SET MENU OFF
                  EDIT FIELDS content
                  SET MENU ON
               ENDIF  q4
               IF q1 .AND. q2 .AND. q5
                  EDIT
               ENDIF
            ENDIF        &&  '<',
            SELE 4
         ENDIF    '.'
         SKIP
      ENDDO     eof() dir.dbf
   ENDIF    rr#1  и q1#t            && занесения в файл SYSTEMS
   ZAP
   RESTORE SCREEN
   @ 21,25 SAY [Обработка дискеты ]+TRIM(dn)+[ завершена]
ENDDO .t.
DELETE FILE k.k
RETURN
*: EOF: CATD.PRG
