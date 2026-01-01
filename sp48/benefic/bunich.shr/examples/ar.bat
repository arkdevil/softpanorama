@echo off
Rem -- Интеллектуальная работа с архиватором ARJ
Rem -- Вызов:   AR функция архив аргументы

Rem call c:\bat\setarj
  mb W=File(Fname /d/,%2)
  if "%W%"=="A:" goto :Floppy
  if "%W%"=="B:" goto :Floppy
:HardDisk
  arj %1 %2 %3 %4 %5 %6 %7 %8 %9
  goto :Finish
:Floppy
  mb W=FILE(FindPfx %2)
  if "%W%"=="" goto :HardDisk
  mb W=FILE(FSize %W%)
  mb W=CompNum(%W%,200000)
  if %W%==L goto :RAMDisk
  arj -wC:\W %1 %2 %3 %4 %5 %6 %7 %8 %9
  goto :Finish
:RAMDisk
  arj -wD: %1 %2 %3 %4 %5 %6 %7 %8 %9
:Finish
  Set ARJ_SW=
  Set W=