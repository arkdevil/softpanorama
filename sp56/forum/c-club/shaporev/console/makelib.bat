@echo off
if "%1" == "t" goto MAKETINY:
if "%1" == "T" goto MAKETINY:
if "%1" == "n" goto MAKENEAR:
if "%1" == "N" goto MAKENEAR:
if "%1" == "f" goto MAKE_FAR:
if "%1" == "F" goto MAKE_FAR:
echo Bad program type "%1"
exit

:MAKETINY
if exist *.obj del *.obj
tasm /ml /d__TINY__ *.asm
goto BUILD:

:MAKENEAR
if exist *.obj del *.obj
tasm /ml /d__NEAR__ *.asm
goto BUILD:

:MAKE_FAR
if exist *.obj del *.obj
tasm /ml *.asm

:BUILD
if errorlevel 1 exit
if exist console%1.ctl del console%1.ctl
if exist console%1.lib del console%1.lib

rem for %%f in (*.obj) do tlib console%1.lib /c +%%f
rem tlib console%1.lib /c ,console%1.ctl
tlib console%1.lib /c @console.ind

if exist *.obj del *.obj
if exist *.bak del *.bak
