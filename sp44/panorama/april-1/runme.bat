@echo off
echo This batch file compiles supplied message base (via mkmb.exe)
echo  and then tests it using cookie.com,
echo  displaying randomly choosen messages.
echo.
echo Press any key to run, ^C to abort.
echo.
pause >nul
if exist cookie.mb goto Run
mkmb -c funtalk.721 cookie.mb
if errorlevel 1 goto Abort
:Run
for %%i in (*.*) do cookie cookie.mb
goto Exit
:Abort
echo Sonething wrong! Can't continue.
:Exit

