@echo off
if !%1==! goto noparms
REM For OPL3 devices (SB-Pro, SB-16, PAS-16, etc.)
REM See README.OPL for more
mm020 mm020.mid /b%1 /d3 /m0
goto exit
:noparms
echo Baseport required (for OPL3 devices):
echo    demo_2op 220    (for SB-Pro/SB-16s: 2x0)
echo    demo_2op 388    (for PAS-16)
:exit
echo.


