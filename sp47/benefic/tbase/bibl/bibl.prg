:FREEWIN 1,2,3,4,5,6,7,8,9

:COM '             К А Р Т О Т Е К А

:TEXT
  !ПОИСК=..\tbf bibl
  *ПРОСМОТР=tbfind

  Картотека=BIBL.txt
  Рефераты=REF.txt
  ДопМеню=Dop.txt
  ПОИСК=tbfind.scr

:START
  Setup
  Load Картотека
  window 2
  load Рефераты
  window 0
  load ДопМеню
  window 1
'  setup

:LABEL Картотека,R*
   window 2
   load Рефераты
   top
   golab

:LABEL ДопМеню,ПОИСК
'   window 0
   execi ..\tbf BIBL

:LABEL ДопМеню,ПРОСМОТР
   use tbfind

:LABEL ДопМеню,SETUP
   setup
   Back

:LABEL Картотека,ALT-0
   window 0
