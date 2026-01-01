@echo off
  mb W=ext(%1)
  if not %W%==LIB goto :FIN
  mb W=name(%1)
  cls
  liblist.exe %1
  list %W%.LLT
:ASK
  mb box 3,80 at 23 1
  mb put 24,1 "  Удалить %W%.LLT? Ответьте: Y или N     " Bright Red
  mb A=GetCh(/L/N/)
  if %A%.==n. goto :FIN
  if NOT %A%.==y. goto :ASK
  del %W%.LLT
:FIN
  set W=
  set A=
