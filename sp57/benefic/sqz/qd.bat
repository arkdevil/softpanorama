@echo off
:MAIN
shift
if "%0" == "" goto END
sqz u %0 /sp1z0q0 %0\*.*
if errorlevel 1 goto ERROR
sqz t %0 /z01
if errorlevel 1 goto ERROR
:L_REMOVE
ncd RMTREE /BATCH %0
if errorlevel 1 goto ERROR
goto MAIN
:ERROR
echo ERROR from SQZ while packing %0
:END
