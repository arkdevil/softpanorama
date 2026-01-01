@echo off
echo makeA - CPU Identifier/Asm Builder  Version 1.00 (c) 1994 by B-coolWare.
echo:
yesno Do you want to compile CPU Identifier
if errorlevel 1 goto compile
goto Done
:compile
echo Building CPU Identifier/Asm...
tasm /t/m cpu
tlink /t/x cpu
if exist *.obj del cpu.obj >nul
:Done
echo makeA done.
