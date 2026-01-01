@echo off
if "%DATE%" == "YYMMDD" goto ERR_NODATE
if "%DATE%" == "" goto ERR_NODATE
:MAIN
shift
if "%0" == "" goto END
if exist rev\%DATE%\NUL goto L1
if not exist rev\NUL md rev
if not exist rev\%DATE%\NUL ncd md rev\%DATE%
if not exist rev\%DATE%\NUL goto ERR_CD
:L1
sqz u rev\%DATE%\%0 /sp1da%DATE% /x@\bat\u.skp %0\*.*
if errorlevel 1 goto ERR_SQZ
if not exist rev\%DATE%\%0.sqz goto MAIN
sqz t rev\%DATE%\%0
if errorlevel 1 goto ERR_CRC
goto MAIN
:ERR_NODATE
echo Environ DATE är ej satt till något datum!
goto END
:ERR_CD
echo Kunde inte skapa rev\%DATE%\
goto END
:ERR_SQZ
echo ERROR from SQZ while packing %0
goto END
:ERR_CRC
echo Error in rev\%DATE%\%0.sqz
:END
