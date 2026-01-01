@echo off
REM ===================================================================
REM Loop 10 times using STRINGS to increment a loop variable.
REM ===================================================================

SET count=1
:LABEL1
ECHO %COUNT%
STRINGS count = ADD %COUNT%, 1
IF NOT .%COUNT%==.10 GOTO LABEL1
SET count=
