@echo off
REM В СТРОКЕ EXTERNAL_EDITOR ЗАПИСАТЬ:
REM NCEDIT !:!\!.! !: !\
ext %1 .txt .cal .pas .doc .c .wk? .exe
if errorlevel = 7 goto exe
if errorlevel = 6 goto wk
if errorlevel = 5 goto c
if errorlevel = 4 goto doc
if errorlevel = 3 goto pas
if errorlevel = 2 goto cal
if errorlevel = 1 goto txt
:other
edit %1
goto end
:txt
c:\lexicon\lex %1
goto end
:cal
:call в след. строке можно не писать - все равно end
ncext c: \supercal sc4 %1 %2 %3
goto end
:pas
d:\tp\turbo %1
goto end
:doc
d:\word5\word %1
goto end
:c
d:\tc\tc %1
goto end
:wk
d:\quattro\q %1
goto end
:exe
vihe %1
:end
