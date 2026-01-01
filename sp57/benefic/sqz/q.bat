@echo off
:MAIN
shift
if "%0" == "" goto END
sqz u %0 /sp1z01q0 %0\*.*
if errorlevel 1 goto ERROR
goto MAIN
:ERROR
echo ERROR from SQZ while packing %0
:END
