@echo off
masm %1, %1; > meerr.tmp
if errorlevel 1 goto fin
link %1, %1; >> meerr.tmp
if exist %1.exe exe2bin %1.exe %1.bin > nul
if exist %1.exe del %1.exe
:fin
if exist %1.obj del %1.obj
