@echo off
: ****** Трансляция CLARION из MULTI-EDIT 23.12.91-21:24   *******
IF EXIST MEERR.TMP ERASE MEERR.TMP >NUL
IF EXIST %2*.ERR  ERASE %2*.ERR >NUL
:*          без листинга ******************
ccmp %1.cla NO /b
IF NOT EXIST %2*.ERR GOTO EXIT
FOR %%F IN (%2*.ERR) DO TYPE %%F >> MEERR.TMP
:EXIT
