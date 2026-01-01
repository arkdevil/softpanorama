@echo off
tasm /m5 %1.asm, %1.obj > meerr.tmp
if not errorlevel 1 tlink /x %1, %1 >> meerr.tmp
if exist %1.exe exe2bin %1.exe %1.bin > nul
if exist %1.exe del %1.exe
if exist %1.obj del %1.obj
