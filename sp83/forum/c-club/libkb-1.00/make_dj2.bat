@echo off

rem /* make_dj2.bat -- make driver for djgpp v2
rem  * Copyright (C) 1996 Markus F.X.J. Oberhumer
rem  * For conditions of distribution and use, see copyright notice in kb.h 
rem  */

make -f config\dos\makefile.dj2 target=djgpp2

rem use this if you have MikMod installed (libmik.a)
rem make -f config\dos\makefile.dj2 target=djgpp2_mik

rem use this if you have Allegro installed (liballeg.a)
rem make -f config\dos\makefile.dj2 target=djgpp2_allegro

rem use this if you have sb_lib installed (libsb.a)
rem make -f config\dos\makefile.dj2 target=djgpp2_sb
