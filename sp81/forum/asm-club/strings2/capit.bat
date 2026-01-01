@ECHO off
REM ===================================================================
REM
REM Use strings to capitalize the opcodes in an ASM file.
REM
REM ===================================================================

REM
REM Use the previous example file PARSE to parse the filename.
REM

CALL PARSE %1 ASM

IF .%fname%==. GOTO end

STRINGS fileout = FILENAME %FNAME%
SET fileout=%FILEOUT%.OUT

SET lnum=1

REM
REM Read the line to the variable 'LINE'.  If no more lines are in the
REM file, STRINGS will return a nonzero return code.  Pipe the output
REM to the NUL driver to avoid the 'Line not found' error message.
REM
:LABEL1

SET line=
SET part1=
SET part2=

STRINGS line = READ %FNAME%, %LNUM% > NUL
IF ERRORLEVEL 1 GOTO end

REM
REM Find the offset of the ; character in the line.  Don't capitalize
REM characters after the ; since they are part of the comment.
REM

STRINGS /p~ offset = FIND ~~%LINE%~ ;
IF .%OFFSET%==.0 SET offset=128

STRINGS /p~ part1 = LEFT ~~%LINE%~ %OFFSET%

STRINGS offset = ADD %OFFSET%, 1

STRINGS /p~ part2 = MID ~~%LINE%~ %OFFSET%~ 128

STRINGS /p~ part1 = UPPER ~~%PART1%

REM
REM Write the line to the file.  Change the parse character to ~ since
REM the line may contain a comma.  Use double parse characters ~~ to
REM force STRINGS to respect any leading spaces in the parameters.
REM

STRINGS /p~ WRITE %FILEOUT%~ ~~%PART1%%PART2% >NUL

STRINGS lnum = ADD %LNUM%, 1

GOTO label1

:END
SET var=
SET fname=
SET fileout=
SET lnum=
SET offset=
SET line=
SET part1=
SET part2=
