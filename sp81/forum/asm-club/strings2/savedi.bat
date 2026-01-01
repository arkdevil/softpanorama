@ECHO off
REM ===================================================================
REM
REM Use strings to save the current disk and directory.
REM
REM ===================================================================


REM
REM Pipe the current drive and directory into a env var using the ASK
REM command.
REM

CD | STRINGS olddir = ask > NUL

REM
REM Change to the root directory of the C: drive to leave where we were.
REM

C:
CD \
ECHO on
DIR autoexec.bat
@ECHO off

REM
REM Use the LEFT command to separate the drive letter from the directory
REM string, then change to the proper disk.
REM

STRINGS drive = LEFT %OLDDIR%, 2
%DRIVE%

REM
REM Use the MID command to return the directory string without the drive
REM letter. Change to the proper directory using the CD command.
REM

CD %OLDDIR%

SET drive=
SET olddir=
