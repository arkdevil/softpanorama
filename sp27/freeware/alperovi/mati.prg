*MATI
* FOXBASE: Программа выдачи каталога ФЛОППИ-ДИСКОВ
*
on escape cancel
private choice
private choice1
*
set procedure to matidr1
set print off
store 'cbd  ' to prff
i=1
do while i=1
   i=0
   do matidr1
   @ 15,14 say "Задайте код сортировки:"
   @ 16,10 say "Пpоизвольной комбинацией букв:c,b,d,i,n,k"
   @ 17,16 say "c - код программного продукта"
   @ 18,16 say "b - номер коробки"
   @ 19,16 say "d - номер дискетки"
   @ 22,16 say "i - источник"
   @ 20,16 say "n - наименование продукта"
   @ 21,16 say "k - класс"
   *
   set color to w/n, n/w

   @ 15,38 get prff
   read
   k=1
   store ' ' to mm
   store ' ' to ss
   store ' ' to ssss
   *        сортировка в любом наборе полей
   do while k<=len(trim(prff))
      store substr(prff,k,1) to prf
      do case
      case prf='c'
         store 'cod' to nn
         store 'КОДУ' to ssss
      case prf='d'
         store 'tran(disket_f,"999")' to nn
         store 'ДИСКЕТАМ' to ssss
      case prf='b'
         store 'chr(box)' to nn
         store 'КОРОБКАМ' to ssss
      case prf='i'
         store 'source' to nn
         store 'ИСТОЧHИКУ' to ssss
      case prf='n'
         store 'name' to nn
         store 'HАИМЕHОВАHИЯМ' to ssss
      case prf='k'
         store 'class' to nn
         store 'КЛАССУ' to ssss
      otherwise
         i=1
      endcase
      k=k+1
      store mm+nn+'+' to mm
      store ss+' '+ssss to ss
   enddo
   *
enddo
*
store 'ОТСОРТИРОВАHО ПО '+ss to ss
store substr(mm,1,len(mm)-1) to mm
delete  file itmpmat.idx
@ 24,2 say 'ЖДИТЕ'
index  to itmpmat on &mm
@ 23,0 clear
*
use mat index itmpmat
*
on error  i=1
*
do matidr1
@ 15,14 say "Задайте фильтр:"
store space(32) to ppff
set color to w/n
@ 16,8 get ppff
read
if len(TRIM(ppff))>0
   set filter to &ppff.
*? ppff
*  wait
endif
*
i=1
do while i=1
   i=0
   do matidr1
   @ 15,08 say "ВЫВОД HА:   ┌───────────────┐"
   @ 16,20 prompt "│   Печать      │"
   @ 17,20 prompt "│   В файл      │"
   @ 18,20 prompt "│   Выход       │"
   @ 19,20 say "└───────────────┘"
   menu to choice
   if choice = 3
      set print off
      return
   endif
   *
   do matidr1
   @ 15,28 SAY "ФОРМАТ ОТЧЕТА:"
   @ 16,27 SAY "┌───────────────┐"
   @ 17,27 prompt  "│    ПОЛHЫЙ     │"
   @ 18,27 prompt  "│   КРАТКИЙ     │"
*  @ 19,27 prompt  "│ С ПОЛЯМИ MEMO │"
   @ 19,27 SAY "└───────────────┘"
   menu to choice1
 *
   do case
   case choice1 = 1
      store "rep2"+chr(13) to oth
   case choice1 = 2
      store "rep3"+chr(13) to oth
   case choice1 = 3
      store "rep4"+chr(13) to oth
do matidr1
@ 15,14 say "Задайте фильтр:"
store 'FF>0    ' to ppff
set color to w/n
@ 16,14 get ppff
read
if len(TRIM(ppff))>0
   set filter to &ppff.
endif
   endcase

   do case
    case choice = 1
      set print on
      ? ss
      ?
      keyboard  oth
      report plain to print
   case choice = 3
      set print off
      return
   otherwise
      do matidr1
      store space(12) to pr
      @ 20,14 say "Имя файла :"
      set color to w/n, n/w
      @ 20,26 get pr
      read
      @ 23,0 clear
      ? ss
      ?
      store trim(pr) to pr
      keyboard  oth
      report to file &pr
   endcase
   *
   if i=1
      accept  'ОШИБКА ' to str
   else
      ? 'Число записей в базе '
      store   reccount() to rec
      ??  rec
      ?
   endif
enddo
*
* расчет числа использованных дискеток
store replicate('0',254) to str
store replicate('0',254) to str1
k=0
goto top
do while .not.eof()
   i=disket_f
   if i < 257
      if substr(str,i,1) = '0'
         store stuff(str,i,1,'1') to strb
         k=k+1
      endif
      store strb to str
   else
      i=i-256
      if substr(str1,i,1) = '0'
         store stuff(str1,i,1,'1') to strb
         k=k+1
      endif
      store strb to str1
   endif
   skip
enddo
if pr='p'
   set print on
endif
?  'ЧИСЛО ДИСКЕТОК      '
?? k
?
set print off
wait
*******************************************************
return
