# $Id: Makefile,v 5.8 1990/12/13 06:54:06 eggert Exp $
# Copyright (C) 1982, 1988, 1989 Walter Tichy
#   Copyright 1990 by Paul Eggert
#   Distributed under license by the Free Software Foundation, Inc.
#
# This file is part of RCS.
#
# RCS is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 1, or (at your option)
# any later version.
#
# RCS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with RCS; see the file COPYING.  If not, write to
# the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
#
# MAKEFILE adapted for MSDOS and Borland C++
# Stu Phillips, August 1991

.AUTODEPEND

# Tool definitions

CC = bcc +BCC.CFG
AS = tasm
LD = tlink
MODEL = -ms

# Paths for RCS files

.PATH.c%v = ./rcs
.PATH.h%v = ./rcs

# Rules to create files from RCS database

.c%v.c:
	co {$&.c }

.h%v.h:
	co {$&.h }

.c.obj:
	$(CC) -c {$&.c }


# binary commands
RCSCOMMANDS   =   ci.exe ident.exe rcs.exe rcsdiff.exe rcsmerge.exe \
			      rlog.exe co.exe

all : bcc.cfg $(RCSCOMMANDS) rcs.lib 

RCSLIB = rcslex.obj rcssyn.obj rcsgen.obj rcsedit.obj rcskeys.obj \
		 rcsmap.obj rcsrev.obj rcsutil.obj rcsfnms.obj partime.obj \
		 maketime.obj rcskeep.obj rcsfcmp.obj getcwd.obj unlink.obj

rcs.lib: bcc.cfg $(RCSLIB)
	rm -f rcs.lib
	tlib /c rcs.lib @rcs.tl

ci.exe : bcc.cfg ci.obj rcs.lib
	$(CC) -eci ci.obj rcs.lib

co.exe : bcc.cfg co.obj rcs.lib
	$(CC) -eco co.obj rcs.lib

ident.exe : bcc.cfg ident.obj rcs.lib
	$(CC) -eident ident.obj rcs.lib

rlog.exe : bcc.cfg rlog.obj rcs.lib
	$(CC) -erlog rlog.obj rcs.lib

rcs.exe : bcc.cfg rcs.obj rcs.lib
	$(CC) -ercs rcs.obj rcs.lib
	
rcsdiff.exe : bcc.cfg rcsdiff.obj rcs.lib 
	$(CC) -ercsdiff rcsdiff.obj rcs.lib

rcsmerge.exe : bcc.cfg rcsmerge.obj rcs.lib
	$(CC) -ercsmerge rcsmerge.obj rcs.lib

SOURCE=	ci.c co.c ident.c maketime.c partime.c rcs.c \
	rcsdiff.c rcsedit.c rcsfcmp.c rcsfnms.c rcsgen.c \
	rcskeep.c rcskeys.c rcslex.c rcsmap.c rcsmerge.c rcsrev.c rcssyn.c \
	rcsutil.c rlog.c getcwd.c unlink.c
OBJECT=	ci.obj co.obj ident.obj maketime.obj partime.obj rcs.obj \
	rcsdiff.obj rcsedit.obj rcsfcmp.obj rcsfnms.obj rcsgen.obj \
	rcskeep.obj rcskeys.obj rcslex.obj rcsmap.obj rcsmerge.obj rcsrev.obj \
    rcssyn.obj rcsutil.obj rlog.obj getcwd.c unlink.c

$(OBJECT) : bcc.cfg conf.h rcsbase.h

#		*Compiler Configuration File*
bcc.cfg: makefile
  cp &&|
-ms
-O
-Z
-f-
-v
-y
-ID:\BORLANDC\INCLUDE
-LD:\BORLANDC\LIB
-P.C
| bcc.cfg
