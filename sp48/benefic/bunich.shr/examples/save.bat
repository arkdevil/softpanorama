@echo off
  if "%1"=="" goto :Error
  MB F=Upper("%1")
:ASK
  mb W=GetCh(/U/,"Укажи N (новое поколение %F%), M (модификация старого) или ESC (отказ): ")
  if "%W%"=="ESC" goto :Fin
  if "%W%"=="M" goto :Freshen
  if not "%W%"=="N" goto :ASK
  arj t a:%1-n
  if errorlevel 1 goto :Fin
  copy a:%1-n.arj a:%1-o.arj
  if errorlevel 1 goto :Fin
:Freshen
  call c:\bat\ar f a:%1-n
  goto :Fin
:Error
  echo Не задано имя ARJ-архива
:Fin
  set W=
  set F=
