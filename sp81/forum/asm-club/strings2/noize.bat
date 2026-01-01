@ECHO OFF
REM ------------------------------------------------------------
REM NOIZE.BAT - by Neil Rubenking
REM
REM Enter a frequency as its command line parameter and it
REM starts a note of that frequency.  Enter NO parameter and it
REM shuts the speaker up.
REM ------------------------------------------------------------
IF '%1'=='' GOTO Stop
STRINGS inv=DIV 1193180,%1
STRINGS inv=CONVERT %inv%,16
STRINGS inv=RIGHT 0000%inv%,4
STRINGS Hi=LEFT %inv%,2
STRINGS Lo=RIGHT %inv%,2
STRINGS /b16 OUT 43,B6
STRINGS /b16 OUT 42,%lo%
STRINGS /b16 OUT 42,%hi%
STRINGS /b16 AL=IN 61
STRINGS /b16 AL=OR %AL%,3
STRINGS /b16 OUT 61,%AL%
GOTO End
:Stop
STRINGS /b16 AL=IN 61
STRINGS /b16 AL=AND %AL%,FC
STRINGS /b16 OUT 61,%AL%
:End
SET al=
SET inv=
SET hi=
SET lo=

@ECHO OFF
REM ------------------------------------------------------------
REM MARY.BAT - by Neil Rubenking
REM
REM Plays a familar tune
REM ------------------------------------------------------------
STRINGS /I /Q
CALL NOIZE 330
CALL NOIZE 294
CALL NOIZE 262
CALL NOIZE 294
CALL NOIZE 330
CALL NOIZE 330
CALL NOIZE 330
CALL NOIZE 330
CALL NOIZE 294
CALL NOIZE 294
CALL NOIZE 294
CALL NOIZE 294
CALL NOIZE 330
CALL NOIZE 392
CALL NOIZE 392
CALL NOIZE 392
CALL NOIZE
STRINGS /U /Q
