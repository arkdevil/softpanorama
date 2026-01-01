:FREEWIN 1,2,3,4,5,6,7,8,9,0

:COM  '          ПРИМЕР   КНИГИ

:TEXT
  N0=0.txt
  N1=1.txt
  N2=2.txt
  N3=3.txt
  N4=4.txt
  N5=5.txt
  N6=6.txt
:START
  Load N0
'  window 2
'  load N1
'  window 1
:LABEL N0,n2
   window 2
   top
   load N2
:LABEL N0,n3
   window 2
   top
   load N3
:LABEL N0,n4
   window 2
   top
   load N4
:LABEL N0,n5
   window 2
   top
   load N5
:LABEL N0,n6
   window 2
   load N6
:LABEL N0,n1
   window 2
   top
   load N1

:LABEL N1,n2
   window 2
   top
   load N2
:LABEL N2,n1
   window 2
   top
   load N1
:LABEL N2,n3
   window 2
   top
   load N3

:LABEL N3,n2
   window 2
   top
   load N2
:LABEL N3,n4
   window 2
   top
   load N4

:LABEL N4,n3
   window 2
   top
   load N3
:LABEL N4,n5
   window 2
   top
   load N5

:LABEL N5,n4
   window 2
   top
   load N4
:LABEL N5,n6
   window 2
   top
   load N6

:LABEL N6,n5
   window 2
   top
   load N5
