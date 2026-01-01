@echo off

REM  COMPLIMENTS TO FRANK DIACHEYSN FOR MODIFYING THIS FILE TO WORK WITH
REM  ZIP AND ARJ FORMATS

REM  SUPPORT.BAT
REM  Packs archive files SWAGX-Y using current .SWG files,
REM  Support sites DO NOT have to download the ENTIRE SWAG files package
REM  with each release.  All that is necessary is to download SWAGYYMM.ZIP
REM  OR ALLSWAGS.ZIP.  SWAGYYMM.ZIP can be used to update the current copy
REM  of ALLSWAGS.ZIP that the support site has.  Once this is done, the
REM  smaller support archives can be created with this batch file.

REM  This makes it easy for Support sites to download ONLY the SWAG update
REM  or the ALLSWAGS.ZIP and create the five supporting archives.
REM
REM  There are TWO varibles needed with this batch file.
REM  %1 is the directory location of your SWAG ZIP files.
REM  %2 is the directory location of your *.SWG files.
REM  %3 [ARJ] is optional and makes support.bat use ARJ instead of PkZip
REM  therefore, call this for DOS : support [swagzips] [swagfiles] [ARJ]

IF "%1" == "" GOTO SYNTAX
IF "%2" == "" GOTO SYNTAX
IF "%3" == "ARJ" GOTO ARJ
IF "%3" == "arj" GOTO ARJ

IF EXIST %1\file_id.diz COPY %1\file_id.diz %1\support.diz
REM  Create SWAG.ZIP
IF EXIST %1\swag.zip DEL %1\swag.zip
COPY swag.diz file_id.diz
PKZIP -ex %1\swag.zip %2\reader.exe %2\bbs.txt %2\swag.txt %2\reader.doc %2\file_id.diz

REM  Create SWAGA-C.ZIP
IF EXIST %1\swaga-c.zip DEL %1\swaga-c.zip
COPY swaga-c.diz file_id.diz
PKZIP -ex %1\swaga-c.zip %2\a*.swg %2\b*.swg %2\c*.swg %2\file_id.diz

REM  Create SWAGD-F.ZIP
IF EXIST %1\swagd-f.zip DEL %1\swagd-f.zip
COPY swagd-f.diz file_id.diz
PKZIP -ex %1\swagd-f.zip %2\d*.swg %2\e*.swg %2\f*.swg %2\file_id.diz

REM  Create SWAGG-M.ZIP
IF EXIST %1\swagg-m.zip DEL %1\swagg-m.zip
COPY swagg-m.diz file_id.diz
PKZIP -ex %1\swagg-m.zip %2\g*.swg %2\h*.swg %2\i*.swg %2\file_id.diz -x%2\grepswag.*
PKZIP -ex %1\swagg-m.zip %2\j.swg %2\k*.swg %2\l*.swg %2\m*.swg -x%2\grepswag.*

REM  Create SWAGN-R.ZIP
IF EXIST %1\swagn-r.zip DEL %1\swagn-r.zip
COPY swagn-r.diz file_id.diz
PKZIP -ex %1\swagn-r.zip %2\n*.swg %2\o*.swg %2\p*.swg %2\q*.swg %2\r*.swg %2\file_id.diz

REM  Create SWAGS-Z.ZIP
IF EXIST %1\swags-z.zip DEL %1\swags-z.zip
COPY swags-z.diz file_id.diz
PKZIP -ex %1\swags-z.zip %2\s*.swg %2\t*.swg %2\u*.swg %2\v*.swg %2\w*.swg
PKZIP -ex %1\swags-z.zip %2\x*.swg %2\y*.swg %2\z*.swg %2\file_id.diz

GOTO END

:ARJ

IF EXIST %1\file_id.diz COPY %1\file_id.diz %1\support.diz
REM  Create SWAG.ARJ
IF EXIST %1\swag.arj DEL %1\swag.arj
COPY swag.diz file_id.diz
arj a %1\swag.arj %2\reader.exe %2\bbs.txt %2\swag.txt %2\reader.doc %2\file_id.diz

REM  Create SWAGA-C.arj
IF EXIST %1\swaga-c.arj DEL %1\swaga-c.arj
COPY swaga-c.diz file_id.diz
arj a %1\swaga-c.arj %2\a*.swg %2\b*.swg %2\c*.swg %2\file_id.diz

REM  Create SWAGD-F.arj
IF EXIST %1\swagd-f.arj DEL %1\swagd-f.arj
COPY swagd-f.diz file_id.diz
arj a %1\swagd-f.arj %2\d*.swg %2\e*.swg %2\f*.swg %2\file_id.diz

REM  Create SWAGG-M.arj
IF EXIST %1\swagg-m.arj DEL %1\swagg-m.arj
COPY swagg-m.diz file_id.diz
arj a %1\swagg-m.arj %2\g*.swg %2\h*.swg %2\i*.swg %2\file_id.diz -x%2\grepswag.*
arj a %1\swagg-m.arj %2\j.swg %2\k*.swg %2\l*.swg %2\m*.swg -x%2\grepswag.*

REM  Create SWAGN-R.arj
IF EXIST %1\swagn-r.arj DEL %1\swagn-r.arj
COPY swagn-r.diz file_id.diz
arj a %1\swagn-r.arj %2\n*.swg %2\o*.swg %2\p*.swg %2\q*.swg %2\r*.swg %2\file_id.diz

REM  Create SWAGS-Z.arj
IF EXIST %1\swags-z.arj DEL %1\swags-z.arj
COPY swags-z.diz file_id.diz
arj a %1\swags-z.arj %2\s*.swg %2\t*.swg %2\u*.swg %2\v*.swg %2\w*.swg
arj a %1\swags-z.arj %2\x*.swg %2\y*.swg %2\z*.swg %2\file_id.diz

GOTO END

:SYNTAX
ECHO SUPPORT.BAT Create SWAG Support ZIPS from *.SWG Files
ECHO Third parameter "[ARJ]" is optional and creates ARJs instead of ZIPs
ECHO SYNTAX: SUPPORT [swagZIPpath] [swagFILESpath] [ARJ]

ECHO   e.g. "SUPPORT \swag\zips \swag\files"

:END

IF EXIST %1\file_id.diz DEL %1\file_id.diz
IF EXIST %1\support.diz REN %1\support.diz %1\file_id.diz
