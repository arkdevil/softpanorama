@echo off
echo mLib - TMIOSDGL(tm) Library Builder  Version 1.00 (c) 1994 by B-coolWare.
echo:
if .%1. == .. goto Help
if .%2. == .. goto Help
if %makeC%==ON goto Continue
echo *** I M P O R T A N T ***
echo Do not forget to set appropriate memory model in CPU_HL.ASM and CPUSPEED.ASM
echo or built library won't function properly!
pause
echo:
:Continue
echo Building C/C++ TMIOSDGL(tm) Library...
tasm /t/m/mx cpuspeed, speed_c
tasm /t/m/mx cpu_hl, cpu_c
bcc -m%2 -c -Ii:\borlandc\include cputype.c
REM tcc -m%2 -c -Id:\turboc\include cputype
rem				    	      ^-- unREM this if you're TC user
REM cl /A%2 /c /Ox /FPi /Id:\msc5\include cputype  
rem                                           ^-- unRem this if you're MSC user
if exist %1.lib del %1.lib
tlib %1 /C /0 +speed_c.obj +cpu_c.obj +cputype.obj
echo mLib done.
goto Quit
:Help
echo   usage: mlib libname t│s│c│m│l│h
:Quit
