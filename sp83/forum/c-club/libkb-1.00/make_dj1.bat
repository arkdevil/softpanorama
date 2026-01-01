@echo off

rem /* make_dj1.bat -- simple make driver for djgpp v1
rem  * Copyright (C) 1996 Markus F.X.J. Oberhumer
rem  * For conditions of distribution and use, see copyright notice in kb.h 
rem  */

md _djgpp
copy include\*.* _djgpp
copy src\*.* _djgpp
copy samples\*.* _djgpp
copy config\dos\*.* _djgpp
cd _djgpp
make -f makefile.dj1
