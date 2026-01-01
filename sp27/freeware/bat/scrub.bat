:--- SCRUB.BAT
:--- Frank Murphy
ECHO OFF
IF "%1"=="" GOTO SYNTAX
FOR %%d IN (A: B: a: b:) DO IF %1==%%d GOTO OK
ECHO SCRUB can only be used on a Floppy Disk
GOTO SYNTAX
:OK
ECHO | RECOVER %1 > NUL
DEL %1FILE*.* > NUL
GOTO END
:SYNTAX
ECHO Syntax ...  "SCRUB d:"
:END
