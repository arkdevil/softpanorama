@ECHO off
REM ===================================================================
REM
REM Shell out to a new copy of COMMAND.COM to increase environment size
REM
REM ===================================================================

REM
REM Determine the bytes free in the current environment.  If there are not
REM 300 bytes free, shell out to increase the size of the environment.
REM

STRINGS efree = ENVFREE
STRINGS SUB 300, %EFREE% > NUL
IF ERRORLEVEL 1 GOTO main


ECHO Bytes free in current environment:
STRINGS ENVFREE

REM
REM Determine the size of the necessary environment by adding the
REM required bytes to the current environment size.
REM

STRINGS esize = ENVSIZE
STRINGS esize = ADD %ESIZE%, 300

REM
REM Shell out using the COMSPEC variable.  The %0 parameter is the name
REM of the batch file being executed.
REM

%COMSPEC% /e:%ESIZE% /c %0
GOTO end

REM
REM This is the main body of the batch file.  Since this is only an
REM example, the only work done here is to print the number of bytes free
REM in the shelled environment.
REM

:MAIN
ECHO.
ECHO Bytes free in shelled environment
STRINGS ENVFREE

:END
SET EFREE=
SET ESIZE=
