@echo off
echo makeC - CPU Identifier/C Builder  Version 1.00 (c) 1994 by B-coolWare.
echo:
echo *** I M P O R T A N T ***
echo Do not forget to set appropriate memory model in CPU_HL.ASM and CPUSPEED.ASM
echo files or this batch won't be successful!
pause
echo:
yesno Do you want to compile CPU Identifier
if errorlevel 1 goto compile
echo:
yesno Do you want to make TMIOSDGL library
if errorlevel 1 goto mklib
goto P5Info
:mklib
call mlib cputypel l
goto P5Info
:compile
echo Building CPU Identifier/C...
set makeC=ON
call mlib cputypel l
bcc -ml -c -Ii:\borlandc\include cpu.c
REM tcc -ml -c -Id:\turboc\include cpu
rem					      ^-- unREM this if you're TC user
REM cl /AL /c /Ox /FPi /Id:\msc5\include cpu
rem					      ^-- unREM this if you're MSC user

tlink /x/c/C /Li:\borlandc\lib c0l cpu, cpuc,,cl.lib mathl.lib emu.lib cputypel.lib
REM tlink /x/c/C /Ld:\turboc\lib c0l cpu, cpuc,,cl.lib mathl.lib emu.lib cputypel.lib
rem					      ^-- unREM this if you're TC user
REM tlink /x/c/C /Ld:\msc5\lib cpu, cpuc,,llibce.lib cputypel.lib
rem					      ^-- unREM this if you're MSC user
:P5Info
echo:
yesno Do you want to compile P5Info program
if errorlevel 1 goto mkP5
goto Done
:mkP5
echo *** I M P O R T A N T ***
echo Make sure you've set proper memory model in P5INFO.ASM or the program
echo won't be compiled properly!
pause
echo:
echo Building P5Info/C...
tasm /t/m/mx p5info, p5c
bcc -ml -c -Ii:\borlandc\include p5info.c
REM tcc -ml -c -Id:\turboc\include p5info
rem					      ^-- unREM this if you're TC user
REM cl /AL /c /Ox /FPi /Id:\msc5\include p5info
rem					      ^-- unREM this if you're MSC user
tlink /x/c/C/Li:\borlandc\lib c0l p5info p5c,p5info,,cl.lib
REM tlink /x/c/C/Ld:\turboc\lib c0l p5info p5c,p5info,,cl.lib
rem					      ^-- unREM this if you're TC user
REM tlink /x/c/C/Ld:\msc5\lib p5info p5c,p5info,,llibce.lib
rem					      ^-- unREM this if you're MSC user
:Done
if exist *.obj del *.obj >nul
echo makeC done.
set makeC=
