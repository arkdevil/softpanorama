@ECHO off
REM ===================================================================
REM
REM PARSE.BAT - A batch file that parses a filename.
REM
REM Entry: %1 is the filename entered by the user
REM  %2 is the default filename extension desired.
REM
REM Exit:  %FNAME% contains the parsed filename
REM
REM ===================================================================

SET fname=%1
SET fext=%2

IF .%1==. STRINGS fname = ASK Please enter the name of the file

STRINGS fname = FILENAME %fname%

IF .%2==. STRINGS fext = ASK Please enter the extension of the file

STRINGS fname = FILENAME %FNAME%

SET fname=%FNAME%.%FEXT%
IF EXIST %FNAME% GOTO END

ECHO The filename %FNAME% does not exist.
SET fname=
GOTO end

:END
SET fext=
