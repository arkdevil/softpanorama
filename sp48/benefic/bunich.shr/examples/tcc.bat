 @echo off
  mb N=File(Fname /dpn/,%1)
  Set path=%PATH%;c:\asm
  if not %2.==. goto :Debug
:EXE
  c:\tc\bcc.exe %3 %4 %5 %6 %7 %1
  goto :Del
:Debug
  if not %2.==d. goto :COM
  c:\tc\bcc.exe -v -O- -K- -Z- %3 %4 %5 %6 %7 %1
  goto :Del
:COM
  if not %2.==c. goto :Error
  c:\tc\bcc.exe -mt -lt %3 %4 %5 %6 %7 %1
  goto :Del
:Error
  if %2.==e. goto :EXE_run
  echo Неверен второй параметр; укажите:  TCC имя [c │ d │ e]
:Del
  if exist %N%.obj  del %N%.obj
  set N=
