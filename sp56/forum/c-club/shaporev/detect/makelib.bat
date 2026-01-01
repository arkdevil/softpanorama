@echo off
if "%1" == "n" goto MAKENEAR:
if "%1" == "N" goto MAKENEAR:
if "%1" == "f" goto MAKE_FAR:
if "%1" == "F" goto MAKE_FAR:
echo Bad program type "%1"
exit

:MAKENEAR
if exist *.obj del *.obj
tasm /ml /d__NEAR__ *.asm
goto BUILD:

:MAKE_FAR
if exist *.obj del *.obj
tasm /ml *.asm

:BUILD
if errorlevel 1 exit
if exist detect%1.ctl del detect%1.ctl
if exist detect%1.lib del detect%1.lib

rem for %%f in (*.obj) do tlib detect%1.lib /c +%%f
rem tlib detect%1.lib /c ,detect%1.ctl
tlib detect%1.lib /c @detect.ind

if exist *.obj del *.obj
if exist *.bak del *.bak
