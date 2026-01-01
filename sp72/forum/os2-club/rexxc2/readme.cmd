@ECHO OFF
SETLOCAL
CLS
ECHO.       ┌────────────────────────────────────────────────────────────────┐
ECHO.       │          REXXCC v2.00 (c) Bernd Schemmer 1994                  │
ECHO.       │                  FileList for REXXCC                           │
ECHO.       └────────────────────────────────────────────────────────────────┘
ECHO.
ECHO.              INSTALL.CMD - install program for REXXCC
ECHO.              README.CMD  - this file
ECHO.              REXXCC.CMD  - the REXX "compiler"
ECHO.              REXXCCW.CMD - the WPS front end for REXXCC
ECHO.
ECHO.   Press any key to view the documentation for REXXCC or CTRL-C to abort ...
PAUSE >NUL

REM *** use list if 4OS2 is the command shell
if NOT "%_4ver%" == "" ALIAS more=list/s
call rexxcc /?
if NOT "%_4ver%" == "" UNALIAS more
CLS
ECHO.
ECHO.       ┌────────────────────────────────────────────────────────────────┐
ECHO.       │ To view the description for REXXCC again you can view the file │
ECHO.       │            REXXCC.CMD with any fileviewer.                     │
ECHO.       └────────────────────────────────────────────────────────────────┘
ECHO.
ECHO.                       Use INSTALL.CMD to install REXXCC.
ECHO.
ECHO.                               Press any key ...
PAUSE >NUL
ENDLOCAL

