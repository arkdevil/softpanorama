@echo off

rem /* make_wcc.bat -- simple make driver for Watcom C
rem  * Copyright (C) 1996 Markus F.X.J. Oberhumer
rem  * For conditions of distribution and use, see copyright notice in kb.h 
rem  */

md _wcc
copy include\*.* _wcc
copy src\*.* _wcc
copy samples\*.* _wcc
copy config\dos\*.* _wcc
cd _wcc
wmake -f makefile.wcc
