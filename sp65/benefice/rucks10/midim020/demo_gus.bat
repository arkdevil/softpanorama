@echo off
if !%1==! goto noparms
if %1==512 goto g512
REM For GUS devices (port/DMA/IRQln/patch info read from ULTRASND= & ULTRADIR=
REM See README.GUS for more
:g256
mm020 mm020.mid /d5 /q1 /x24
goto exit
:g512
mm020 mm020.mid /d5 /x24
goto exit
:noparms
echo GRAM size required:
echo    demo_gus 256    (for 256K GUS)
echo    demo_gus 512    (for 512K+)
:exit
echo.


