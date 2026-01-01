# Makefile for GNU DIFF, MS-DOS Version
# Copyright (C) 1988, 1989 Free Software Foundation, Inc.

# This file is part of GNU DIFF.

# GNU DIFF is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 1, or (at your option)
# any later version.
# 
# GNU DIFF is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with GNU DIFF; see the file COPYING.  If not, write to
# the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.  */

# $Header: e:/gnu/diff/RCS/makefile 1.15.0.1 91/03/12 18:14:26 tho Exp $

GNUVER	= 1.15

MSC	= 600
VPATH	= d:/usr/lib;d:/usr/include
INSTALL	= cp -f
BINDIR	= c:/bin
DISK	= b
ZIPFILE	= diff

OBJS	= analyze.obj context.obj ed.obj diff.obj ifdef.obj io.obj \
	  normal.obj util.obj dir.obj version.obj _cwild.obj

SRCS	= analyze.c context.c ed.c diff.c ifdef.c io.c normal.c util.c \
	  dir.c version.c diff3.c
INCS	= diff.h limits.h

RCSFILES = $(SRCS) $(INCS) makefile
MISC	= ChangeLog

MODEL	= L
CONFIG	= -DUSG -DHAVE_NDIR -DHAVE_DIRECT -DSMART_SHELL

# Don't use -Oi, since the intrinsic functions loose for huge arrays.

ifeq ($(MSC),510)
CFLAGS	= -A$(MODEL) -Oalt -Gs -Za -W4 $(CONFIG)
CRIPPLED_CFLAGS= -A$(MODEL) -Olt -Gs -Za -W4 $(CONFIG)
else  # not MSC 5.10
CFLAGS	= -A$(MODEL) -Oceglt -Gs -Za -W4 $(CONFIG)
endif # MSC 5.10
LDFLAGS = /e/noe/st:0x4000 setargv

LOADLIBES = gnulib_$(MODEL)

# make'm

all: diff.exe diff3.exe

diff.exe: $(OBJS)
diff3.exe: _cwild.obj

ifeq ($(MSC),510)
# This kludge is necessary because the MSC 5.1 compiler bombs with relaxed
# alias checking ...
analyze.obj: analyze.c
	$(CC) $(CRIPPLED_CFLAGS) $(CPPFLAGS) -c $<
endif # MSC 5.10

ifeq ($(MSC),600)
# This kludge is necessary because the MSC 6.0 compiler has a bug in the
# argument parsing from the environment ...
diff3.obj: diff3.c
	CL $(CFLAGS) -DDIFF_PROGRAM=\\"diff\\" -c $<
endif # MSC 6.00

$(OBJS): diff.h limits.h

# Utils

include make.inc

tags: $(SRCS) $(INCS)
	etags -t *.c *.h

clean:
	$(RM) *.obj

veryclean:
	$(RM) *.exe errs tags
	rcsclean -q *.[ch] makefile


dist: README.DOS Makefile patches diff.exe diff3.exe
	shar -BC -F -angnudiff -L60 -odiff $^

patches:
	$(MAKE) -t
	$(RM) *.exe *.obj
	rcsdiff -r$(GNUVER) -c *.[ch] > $@

