:freewin 1,2,3,4,5,6,7,8,9,0

:COM '  И Н Т Е Г Р А Т О Р   П Р О Г Р А М М

:TEXT
  !ЛЕКСОКОН = lex
  !WORD5 = word
  !ACAD10 = acad
  !НОРТОН = nc
  !PASCAL = turbo
  DOC=my.scr
  PRG=inter.prg

:START
 setup
 load DOC
 window 2
 load PRG
 window 1
' SetUp
' ------------------------------------------------------------
'             Блок настойки на запуск программ
' ------------------------------------------------------------
:label DOC,ACAD
' Запуск АКАДА
 execi acad

:label DOC,NC
' Нортон коммандер
 execi nc

:label DOC,LEX
' Лексикон
 execi lex

:label DOC,WORD
' ВОРД 5
 execi word

:label DOC,TURBO
 execi turbo
' ------------------------------------------------------------

:label DOC,ТРАНСЛЯЦИЯ
 execi ..\ttb inter.prg
