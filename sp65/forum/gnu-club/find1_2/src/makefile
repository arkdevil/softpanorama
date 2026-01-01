# Makefile for GNU find.
# Copyright (C) 1987, 1990 Free Software Foundation, Inc.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 1, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# $Header: e:/gnu/find/RCS/makefile 1.2.0.4 90/09/23 19:04:35 tho Exp $

# Use a Microsoft C 6.0 kludge ...
MSC	= 600

# Where to find utility program objects or sources
VPATH	= d:/usr/lib;d:/usr/include

# DEFS might contain:
# -DDEBUG		Print a trace tree.
# -DUSG			System V string headers and functions; ndir.h.
# -DDIRENT		If you have dirent.h.
# -DSYSNDIR		Old Xenix systems (selects sys/ndir.h).
# -DVPRINTF_MISSING	If you lack vprintf function (but have _doprnt).
# -DSTRSPN_MISSING	If you lack strspn function.
# -DMNTENT_MISSING	If you lack mntent.h (makes -fstype always false).
DEFS	= -DMNTENT_MISSING -DUSG -DSTDC_HEADERS

MODEL	= S

ifeq ($(BUILD),debug)
CFLAGS	= $(DEFS) -A$(MODEL) -Za -W4 -Od -Zi -DSMART_SHELL -DDEBUG
LDFLAGS	= /co/st:0x8000/far/packcode/noe setargv
else
CFLAGS	= $(DEFS) -A$(MODEL) -Za -W4 -Ox -DSMART_SHELL
LDFLAGS	= /e/st:0x8000/far/packcode/noe setargv
endif

# Directory in which to install 'find' and 'fastfind'.
BINDIR	= c:/bin

# Directory in which to install 'updatedb'
BATDIR	= c:/bat

# Directory in which to install programs to create fast-find database.
LIBDIR	= c:/scripts

# Data file for fast-find.
FCODES	= $(LIBDIR)/find.codes

INSTALL = cp -v
DISK	= b
ZIPFILE = find

# Files

INCS	= defs.h modechange.h
SRCS	= find.c parser.c tree.c pred.c util.c fstype.c listfile.c \
	  filemode.c modechange.c savedir.c version.c fastfind.c
OBJECTS	= find.obj parser.obj tree.obj pred.obj util.obj \
	  fstype.obj listfile.obj filemode.obj modechange.obj \
	  savedir.obj version.obj _cwild.obj

CMDS	= find.exe fastfind.exe lib/bigram.exe lib/code.exe
LOADLIBES = gnulib_$(MODEL)

VERSION = 1.2

RCSFILES= $(SRCS) $(INCS) makefile
MISC	= readme todo changelo copying \
	  $(addprefix lib/RCS/, makefile bigram.c code.c uniq-c \
				updatedb.sh updatedb.bat) \
	  $(addprefix RCS/, error.c glob.c regex.c regex.h)

# targets

.PHONY: all FORCE
all: $(CMDS)

lib/%.exe: FORCE
	$(MAKE) -wC lib LIBDIR=$(LIBDIR) BINDIR=$(BINDIR) FCODES=$(FCODES)

FORCE:

find.exe: $(OBJECTS)
fastfind.exe: fastfind.obj _cwild.obj

# This is for old versions of make, where this rule wasn't default
%.exe: %.obj
	$(LINK) $(LDFLAGS) $^, $@, nul, $(LOADLIBES),

ifeq ($(MSC),600)
CL:=$(CFLAGS)
fastfind.obj: fastfind.c
	CL -DFCODES=\\"$(FCODES)\\" -c $<
else
fastfind.obj: fastfind.c
	$(CC) $(CFLAGS) -DFCODES=\"$(FCODES)\" -c $<
endif

modechange.obj parser.obj: modechange.h
find.obj parser.obj tree.obj pred.obj utils.obj: defs.h

install: all lib/uniq-c lib/updatedb.bat
	$(INSTALL) $(CMDS) $(BINDIR)
	$(INSTALL) lib/uniq-c $(LIBDIR)
	$(INSTALL) lib/updatedb.bat $(BATDIR)

# Utilities

tags: $(SRCS)
	etags *.c

clean:
	$(RM) *.obj *.tar patches *.z *~
	-rcsclean lib/*.c

veryclean: clean
	$(RM) *.exe tags errs lib/*.exe *.uue
	rcsclean *.c *.h makefile

include make.inc

# Distribution

.PHONY: dist
dist: find.uue find-b.uue

find.tar: readme copying makefile make.inc patches lib/makefile
find-b.tar: readme copying lib/updatedb.bat lib/uniq-c $(CMDS)

patches: $(SRCS) $(INCS) lib/bigram.c lib/code.c \
	 $(RCSFILES) lib/RCS/bigram.c lib/RCS/code.c
	rcsdiff -c -r$(VERSION) *.c *.h lib/*.c > $@

.PHONY: test-dist
test-dist: find.uue $(RCSFILES) lib/RCS/bigram.c lib/RCS/code.c
	$(CO) -f -r$(VERSION) $(SRCS) $(INCS) lib/bigram.c lib/code.c
	sed /\.tar\.Z/s//.Z/ find.uue | uudecode
	compress -d < find.Z | tar -xOf -  patches | patch -s -p
	$(RM) find.Z
	rcsdiff -q *.c *.h lib/*.c

#
# Local Variables:
# mode:Text
# ChangeLog:ChangeLog
# compile-command:make
# End:

