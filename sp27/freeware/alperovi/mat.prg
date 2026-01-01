*MAT
* FOXBASE: Программа выдачи каталога ФЛОППИ-ДИСКОВ
* головной модуль
 set status off
 on escape cancel
* set escape off
     
DO WHILE .T.
  close all
  use mat
  if .not.FILE('imat.idx')
     index  to imat on cod+ext
  endif
  use mat index imat

 set procedure to matidr1
 do matidr1
 set proc to
SET COLOR TO W/N

@ 16,22 say    "┌────────────────────────────┐"
@ 17,22 prompt "│  Просмотр и корректировка  │"
@ 18,22 prompt "│       Выдача отчета        │"
@ 19,22 prompt "│           Конец            │"
@ 20,22 say    "└────────────────────────────┘"
     
set message to 24
menu to choice
*
   do case
     case choice = 1
      do mata
     case choice = 2
      do mati
     otherwise
      return
    endcase
*
ENDDO
