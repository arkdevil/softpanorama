rem----------------------------------------------------
rem CHECKEX.BAT - Scans the path for a program name.
rem----------------------------------------------------
@echo off
SET index=1
if exist %1.com echo %1.com
if exist %1.exe echo %1.exe
if exist %1.bat echo %1.bat
:loop
   STRINGS pdir = PARSE %path%, %index%,;
   IF . == .%pdir% GOTO exit
   if exist %pdir%\%1.com echo %pdir%\%1.com
   if exist %pdir%\%1.exe echo %pdir%\%1.exe
   if exist %pdir%\%1.bat echo %pdir%\%1.bat
   STRINGS index = ADD %index%, 1
GOTO loop
:exit
SET index=
SET pdir=
