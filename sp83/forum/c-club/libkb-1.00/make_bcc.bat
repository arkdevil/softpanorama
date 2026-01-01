@echo off

rem /* make_bcc.bat -- simple make driver for Borland C 3.1/4.0
rem  * Copyright (C) 1996 Markus F.X.J. Oberhumer
rem  * For conditions of distribution and use, see copyright notice in kb.h 
rem  */

md _bcc
copy include\*.* _bcc
copy src\*.* _bcc
copy samples\*.* _bcc
copy config\dos\*.* _bcc
cd _bcc
make -f makefile.bcc

rem copy kbtst.exe ..\bin\kbtstdos.exe
