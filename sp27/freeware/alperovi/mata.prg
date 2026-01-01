*:*********************************************************************
*:
*:        Program: MATA.PRG
*:
*:         System: a
*:         Author: aa
*:      Copyright (c) 1989, aaa
*:  Last modified: 10/12/89      0:34
*:
*:  Procs & Fncts: ECR
*:               : LINE
*:               : RAMKA
*:
*:      Called by: MAT.PRG                       
*:
*:          Calls: SPACE()        (function  in ?)
*:               : ECR            (procedure in MATA.PRG)
*:               : LINE           (procedure in MATA.PRG)
*:               : INKEY()        (function  in ?)
*:               : RECNO()        (function  in ?)
*:
*:      Documented 10/16/89 at 01:40               FoxDoc  version 1.0
*:*********************************************************************
*MATA
* FOXBASE: Программа выдачи каталога ФЛОППИ-ДИСКОВ
*
* Файл  MAT.dbf должен иметь индексный файл IMAT.idx
* Движение по блоку  UP,DOWN,LEFT,RIGHT
* Смена блока        pgUP,pgDN
* Переход в редактор Entry
* Пополнение         F9
* Завершение         ^END
* Прерывание         ESC
*
on escape cancel
* public flag
set delete off
flag = 0        && Признак окончания операции MATB
iii = 0
up = 5
down = 24
left = 19
right = 4
pgup = 18
pgdn = 3
esc = 27
car_ret = 13
f9  = -8
f10 = -9
ctrl_end = 23
home = 1
end = 6
key = 0
ni = 18       && Число строк
nj = 6        && Число столбцов
mmax = ni*nj
mblock = 60   && Число блоков
old = 1
new = 1
dis = 13      && Расстояное между началами столбцов
iblock = 1
firstz= 1
max = 1
store space(dis-1) to oldst

set print off
set proc to mata
dimension x(mmax)        && Текущие имена (блока)
dimension block(mblock)  && Hачальные имена в блоках
store space(11) to x
store space(11) to block
do ecr

do while .t.
   
   set color to w/n
   ind = old
   do line
   set color to n/w
   ind = new
   do line
   store x(new) to str
   find &str.
   set color to w/n, n/w
   @ 21,02 get name
   @ 21,57 get box
   @ 21,69 get disket_f
   @ 21,76 get disketn
   clear gets
   old = new
   set color to w/n
   
   key = inkey()
   do while key = 0
      key = inkey()
   enddo
   *
   do case
   case key = up
      new = iif(old=1,max,old-1)
   case key = down
      new = iif(old=max,1,old+1)
   case key = left
      if old-ni < 1
         new = iif(old=1,max,old-1)
      else
         new = old - ni
      endif
   case key = right
      if old+ni > max
         new = iif(old=max,1,old+1)
      else
         new = old + ni
      endif
   case key = pgup .and. iblock > 1
      iblock = iblock - 1
      new = 1
      old = 1
      do ecr
   case key = pgdn .and.iii=1 &&.not.eof()
      if iblock < mblock
         iblock = iblock + 1
      else
         accept 'переполнение массива блоков' to  str
      endif
      old = 1
      new = 1
      do ecr
   case  key = car_ret  &&car_ret
      edit recno()
      do ecr
   case key = f9
      append
      do ecr
   case key = ctrl_end
      set proc to
      return
   endcase
enddo

*********************************************************
*   Отображение квадратика
*!*********************************************************************
*!
*!      Procedure: LINE
*!
*!      Called by: MATA.PRG                      
*!               : ECR            (procedure in MATA.PRG)
*!
*!          Calls: TRIM()         (function  in ?)
*!               : SUBSTR()       (function  in ?)
*!
*!*********************************************************************
proc line
j=0
k=ind
do while k>0
   k=k-ni
   j=j+1
enddo
i=ni+k+1
j=1+(j-1)*dis
store trim(substr(x(ind),1,8))+'.'+substr(x(ind),9) to str
store substr(str+'         ',1,dis-1) to str
@ i,j say str
return
********************************************************
*   Загрузка и отображение блока
*!*********************************************************************
*!
*!      Procedure: ECR
*!
*!      Called by: MATA.PRG                      
*!
*!          Calls: RAMKA          (procedure in MATA.PRG)
*!               : .NOT.FOUND()   (function  in ?)
*!               : SPACE()        (function  in ?)
*!               : .NOT.EOF()     (function  in ?)
*!               : LINE           (procedure in MATA.PRG)
*!
*!*********************************************************************
proc ecr
clear
do ramka
@24,2 say "Смена кадра:PgUP,PgDN, Редактирование:ENTRY, Н
Пополнение:F9, Выход:^End"
set color to w/n
if firstz= 1
   firstz= 0
   goto top
   store cod+ext to block(1)
else
   store block(iblock) to str
   find &str.
   if .not.found()
      goto top
      iblock = 1
      block(iblock) = cod + ext
      store space(11) to oldst
   endif
endif
l = 0
do while .not.eof() .and. l < mmax
   if cod+ext<>oldst
      l = l+1
      store cod+ext to x(l)
      store cod+ext to oldst
      ind = l
      do line
   endif
   skip
enddo
max = l
if .not.eof()
   block(iblock + 1) = cod + ext
   iii = 1
else
   iii = 0
endif
return
************************************************
*!*********************************************************************
*!
*!      Procedure: RAMKA
*!
*!      Called by: ECR            (procedure in MATA.PRG)
*!
*!          Calls: SPACE()        (function  in ?)
*!               : ДИСК()         (function  in ?)
*!
*!*********************************************************************
proc ramka
set color to w/n
@ 01,00 say "╔════════════╤════════════╤════════════╤════════════╤════════════╤═════════════╗"
i=1
do while i<=ni+1
   i=i+1
   @ i,00 say "║            │            │            │            │            │             ║"
enddo
@ 20,00 say "╠════════════╧════════════╧════════════╧════════════╧════════════╧═════════════╣"
@ 21,00 say "║"+space(50)+"КОРОБ:    ДИСК(1):    ИЗ:   ║"
@ 22,00 say "╙──────────────────────────────────────────────────────────────────────────────╜"
return
*: EOF: MATA.PRG
