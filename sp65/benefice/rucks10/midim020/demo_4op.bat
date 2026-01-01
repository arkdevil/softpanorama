@echo off
if !%1==! goto noparms
REM For OPL3 devices (SB-Pro, SB-16, PAS-16, etc.)
REM See README.OPL for more
REM Allocates max 4op voices
mm020 mm020.mid /b%1 /d3 /m6
goto exit
:noparms
echo Baseport required (for OPL3 devices):
echo    demo_4op 220    (for SB-Pro/SB-16s: 2x0)
echo    demo_4op 388    (for PAS-16)
:exit
echo.


