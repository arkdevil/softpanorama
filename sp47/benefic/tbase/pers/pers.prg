:freewin 1,2,3,4,5,6,7,8,9,0

:COM   '     П О Р У Ч Е Н И Я

:TEXT
  КТО=pers1.SCR
  ЧТО=pers2.SCR
:START
   setup
   LOAD КТО
   window 2
   load ЧТО
   window 1
'   setup
:label КТО,*
  window 2
   top
   golab

