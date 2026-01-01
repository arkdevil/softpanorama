*:*********************************************************************
*:
*:        Program: CATP.PRG
*:
*:         System: КАТАЛОГ ДИСКЕТ
*:         Author:  Альперович Л З, Пузанкевич П.И.
*:      Copyright (c) 1991, г. Твеpь
*:  Last modified: 04/09/91     16:17
*:
*:  Procs & Fncts: ECR
*:               : LINE
*:               : RAMKA
*:
*:      Called by: CAT.PRG        
*:               : CATK.PRG       
*:
*:          Calls: ECR              (procedure in CATP.PRG)
*:               : LINE             (procedure in CATP.PRG)
*:
*:           Uses: SYSTEMS.DBF    
*:               : DISKI.DBF      
*:
*:        Indexes: ISYSTEMS.NDX
*:               : IDISKI.NDX
*:
*:     Documented: 04/09/91 at 16:20               FoxDoc version 1.0
*:*********************************************************************
*CATP - Поиски корректировка записей файлов DISKI и SYSTEMS
* Файл  systems.dbf должен иметь индексный файл Isystems.idx
* Движение по блоку  UP,DOWN,LEFT,RIGHT
* Смена блока        pgUP,pgDN
* Переход в редактор Entry
* Завершение         ^END
* Прерывание         ESC
* BROWSE             F7
* Удаление помеч зап F8
* Пополнение         F9   (APPEND)
* Инф о диске        F10  (при q1=.t.)
* Q1=.T.  работа с файлом SYSTEMS (обл 1)
* Q1=.F.  работа с файлом DISKI   (обл 2)

ON ESCAPE RETURN

SET DELETE OFF
flag = 0        && Признак окончания операции MATB
iii = 0
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
home = 1
END = 6
KEY = 0
ni = 18       && Число строк
nj = 6        && Число столбцов
mmax = ni*nj
mblock = 60   && Число блоков
old = 1
new = 1
dis = 13      && Расстояное между началами столбцов
iblock = 1
firstz= 1
MAX = 1
STORE SPACE(dis-1) TO oldst

SET PROC TO catp
DIMENSION X(mmax)        && Текущие имена (блока)
DIMENSION block(mblock)  && Hачальные имена в блоках
STORE SPACE(11) TO X
STORE SPACE(11) TO block
IF q1
   SELECT 1          && работа с SYSTEMS
ELSE
   SELECT 2          && работа с DISKI
ENDIF
SET FILTER TO &flt
GO TOP
DO ecr

DO WHILE .T.
   
   SET COLOR TO W/B
   ind = old
   DO Line
   SET COLOR TO B/W
   ind = new
   DO Line
   STORE X(new) TO STR
   *   find &str.
   IF .NOT.q1
      STR=SUBSTR(SPACE(8)+STR,LEN(SPACE(8)+TRIM(STR))-7,8)
   ENDIF
   SEEK STR
   IF .NOT. FOUND()
      @ 11,30 TO 13,50 DOUBLE
      SET COLOR TO W*/R
      @ 12,31 SAY [ Записи не найдены!]
      *      suspend
      KEY=INKEY(1)
      SET FILTER TO
      RETURN
   ENDIF
   SET COLOR TO W/B, B/W
   IF q1
      @ 21,02 GET system
      @ 21,48 GET VERS
      @ 21,62 GET DISK
      @ 21,76 GET kol
   ELSE
      @ 21,02 GET system
      @ 21,43 GET vladelec
      @ 21,66 GET FORMAT
      @ 21,77 GET BOX
   ENDIF
   CLEAR GETS
   old = new
   SET COLOR TO W/B
   SAVE SCREEN TO ekr1
   KEY = INKEY()
   DO WHILE KEY = 0
      KEY = INKEY()
   ENDDO
   *
   DO CASE
   CASE KEY = up
      new = IIF(old=1,MAX,old-1)
   CASE KEY = down
      new = IIF(old=MAX,1,old+1)
   CASE KEY = LEFT
      IF old-ni < 1
         new = IIF(old=1,MAX,old-1)
      ELSE
         new = old - ni
      ENDIF
   CASE KEY = RIGHT
      IF old+ni > MAX
         new = IIF(old=MAX,1,old+1)
      ELSE
         new = old + ni
      ENDIF
   CASE KEY = pgup .AND. iblock > 1
      iblock = iblock - 1
      new = 1
      old = 1
      DO ecr
   CASE KEY = pgdn .AND.iii=1 &&.not.eof()
      IF iblock < mblock
         iblock = iblock + 1
      ELSE
         ACCEPT 'переполнение массива блоков' TO  STR
      ENDIF
      old = 1
      new = 1
      DO ecr
   CASE  KEY = car_ret  &&car_ret
      EDIT RECNO()
      *      do ecr
      RESTORE SCREEN FROM ekr1
   CASE KEY = f9
      APPEND
      *      do ecr
      RESTORE SCREEN FROM ekr1
   CASE KEY = f7
      BROWSE
      *      do ecr
      RESTORE SCREEN FROM ekr1
   CASE KEY = f8
      USE
      IF q1
         USE systems INDEX isystems
      ELSE
         USE diski INDEX idiski
      ENDIF
      @ 23,0
      @ 23,0 SAY ' '
      IF LUPDATE()=DATE()
         ?? 'Помеченные записи удаляются из БД'
         PACK
         STORE 1 TO old,new,iblock,MAX,firstz
         STORE SPACE(12) TO oldst
         GO TOP
         DO ecr
      ELSE
         ?? 'Записи  не помечались на удаление. PACK не выполняется'
         qq=INKEY(0.8)
         RESTORE SCREEN FROM ekr1
      ENDIF
      *      do ecr
   CASE KEY = f10 .AND. q1
      SET RELATION TO SUBSTR(SPACE(8)+DISK,LEN(SPACE(8)+TRIM(DISK))-7,8) INTO B
      @ 24,1 GET b->system
      @ 24,41 SAY ' 'GET b->vladelec
      @ 24,57 SAY ' Формат' GET b->format
      @ 24,69 SAY ' Коробка' GET b->box
      CLEAR GETS
      SET RELATION TO
      KEY=INKEY(2)
      *      browse nomenu noappend nomodify
      RESTORE SCREEN FROM ekr1
   CASE KEY = ctrl_end
      SET PROC TO
      SET FILTER TO
      RETURN
   ENDCASE
ENDDO

*********************************************************
*   Отображение квадратика
*!*********************************************************************
*!
*!      Procedure: LINE
*!
*!      Called by: CATP.PRG       
*!               : ECR              (procedure in CATP.PRG)
*!
*!*********************************************************************
PROC Line
J=0
k=ind
DO WHILE k>0
   k=k-ni
   J=J+1
ENDDO
I=ni+k+1
J=1+(J-1)*dis
STORE TRIM(SUBSTR(X(ind),1,8)) TO STR
IF q1
   STORE STR+'.'+SUBSTR(X(ind),9) TO STR
ENDIF
STORE SUBSTR(STR+'          ',1,dis-1) TO STR
@ I,J SAY STR
RETURN
********************************************************
*   Загрузка и отображение блока
*!*********************************************************************
*!
*!      Procedure: ECR
*!
*!      Called by: CATP.PRG       
*!
*!          Calls: RAMKA            (procedure in CATP.PRG)
*!               : LINE             (procedure in CATP.PRG)
*!
*!*********************************************************************
PROC ecr
CLEAR
DO ramka
SET COLOR TO W+/N
@ 23,2 SAY "Выбор:"+CHR(27)+CHR(24)+CHR(25)+CHR(26)+", Смена кадра:PgUP/PgDN,"+;
   " Редактир:ENTRY, Пополн:F9,  Выход:Ctrl-End"
@ 24,20 SAY "Удаление зап:F8,  BROWSE:F7"
IF q1
   @ 24,47 SAY [,  Инф о дискете:F10]
   IF z#maxk
      @ 0,15 SAY [ Каталог систем, программ, файлов ]
      @ 0,51 SAY [(]+TRIM(kk(z))+")"
   ELSE
      @ 0,20 SAY [ Каталог систем, программ, файлов ]
   ENDIF
ELSE
   @ 0,30 SAY [Каталог дискеток]
ENDIF
SET COLOR TO W/B
IF firstz= 1
   firstz= 0
   GOTO TOP
   IF q1
      STORE cod+ext TO block(1)
   ELSE
      STORE DISK TO block(1)
   ENDIF
   
ELSE
   STORE block(iblock) TO STR
   IF .NOT.q1
      STR=SUBSTR(SPACE(8)+STR,LEN(SPACE(8)+TRIM(STR))-7,8)
   ENDIF
   *   find &str.
   SEEK STR
   IF .NOT.FOUND()
      GOTO TOP
      iblock = 1
      IF q1
         STORE cod+ext TO block(iblock)
      ELSE
         STORE DISK TO block(iblock)
      ENDIF
      STORE SPACE(11) TO oldst
   ENDIF
ENDIF
l = 0
SET EXACT ON
DO WHILE .NOT.EOF() .AND. l < mmax
   IF q1
      STORE cod+ext TO nm
   ELSE
      STORE DISK TO nm
   ENDIF
   IF nm<>oldst
      l = l+1
      STORE nm TO X(l)
      STORE nm TO oldst
      ind = l
      DO Line
   ENDIF
   SKIP
ENDDO
SET EXACT OFF
MAX = l
IF .NOT.EOF()
   block(iblock + 1) = nm
   iii = 1
ELSE
   iii = 0
ENDIF
RETURN
************************************************
*!*********************************************************************
*!
*!      Procedure: RAMKA
*!
*!      Called by: ECR              (procedure in CATP.PRG)
*!
*!*********************************************************************
PROC ramka
SET COLOR TO W/N
@ 01,00 SAY "╔════════════╤════════════╤════════════╤════════════╤════════════╤═════════════╗"
I=1
DO WHILE I<=ni+1
   I=I+1
   @ I,00 SAY "║            │            │            │            │            │             ║"
ENDDO
@ 20,00 SAY "╠════════════╧════════════╧════════════╧════════════╧════════════╧═════════════╣"
IF q1
   @ 21,00 SAY "║"+SPACE(42)+"Верс:      ДИСК(1):         ИЗ:     ║"
ELSE
   @ 21,00 SAY "║"+SPACE(58)+"Формат:     Короб:  ║"
ENDIF
@ 22,00 SAY "╙──────────────────────────────────────────────────────────────────────────────╜"
RETURN
*: EOF: CATP.PRG
