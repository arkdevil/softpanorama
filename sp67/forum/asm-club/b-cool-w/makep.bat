@echo off
echo makeP - CPU Identifier/Pas Builder  Version 1.00 (c) 1994 by B-coolWare.
echo:
echo *** I M P O R T A N T ***
echo Do not forget to set appropriate memory model in CPU_HL.ASM and CPUSPEED.ASM
echo or compiled code won't work properly and may hang your PC!
pause
echo:
yesno Do you want to compile the CPU Identifier
if errorlevel 1 goto compile
goto P5Info
:compile
echo Building CPU Identifier/Pas...
tasm /t/m cpu_hl, cpu_tp
tasm /t/m cpuspeed, speed_tp
tpc /m cpu
REM bpc -cd -m cpu
rem		^-- unREM this if you're BP 7 user
echo:
:P5Info
yesno Do you want to compile P5Info program
if errorlevel 1 goto mkP5
goto Done
:mkP5
echo Building P5Info/Pas...
tasm /t/m p5info
tpc p5info
REM bpc -cd p5info
rem		^-- unREM this if you're BP 7 user
:Done
if exist *.obj del *.obj >nul
echo makeP done.
