# makefile for GNU fgrep (MS-DOS)
# Copyright (C) 1990 Free Software Foundation, Inc.

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

# MS-DOS specifics parts: Thorsten Ohl, <ohl@gnu.ai.mit.edu>

# $Header: e:/gnu/fgrep/RCS/makefile 1.1.0.6 90/09/24 00:38:02 tho Exp $
#

PROGRAM	= fgrep

# Where _cwild.c and the gnulib live:
VPATH	= d:/usr/lib;d:/usr/include

# Where the executable goes:
BINDIR	= c:/bin
INSTALL = cp -f

VERSION	= 1.1

# Backups:
DISK	= b:
ZIPFILE = $(PROGRAM).zip

# Configuration:

MODEL	= C
USE_OBSTACKS = yes

# In small model we can use the obstacks, but we can have
# no more than approx. 40 keywords.

ifeq ($(MODEL),S)
ifeq ($(USE_OBSTACKS),yes)
OBSTACK	= -DUSE_OBSTACKS
OBSTOBJ	= obstack.obj
OBSTINC	= obstack.h
else
OBSTACK	=
OBSTSRC	=
OBSTINC	=
endif
else
MODEL	= C
OBSTACK	=
OBSTSRC	=
OBSTINC	=
endif

CFLAGS	= -A$(MODEL) -Ox -Za -W4 -DSTDC_HEADERS -DSMART_SHELL $(OBSTACK)
LOADLIBES = gnulib_$(MODEL)
LDFLAGS	= /e/st:0x8000/noe/far/packcode setargv

OBJS	= fgrep.obj kwset.obj std.obj $(OBSTOBJ) _cwild.obj
SRCS	= fgrep.c kwset.c kwset.h obstack.c obstack.h std.c std.h unix.h

RCSFILES= $(SRCS) makefile
MISC	= readme changelo todo make.inc

.PHONEY: all zip disk clean veryclean install

all: fgrep.exe

fgrep.exe: $(OBJS)

# This is for old versions of make, where this rule wasn't default
%.exe: %.obj
	$(LINK) $(LDFLAGS) $^, $@, nul, $(LOADLIBES),

# Utilities

tags: $(SRCS)
	etags -t $^

install: $(BINDIR)/$(PROGRAM).exe

$(BINDIR)/%: %
	$(INSTALL) $< $@

clean:
	$(RM) *.obj *.tar patches *~ *.z

veryclean: clean
	$(RM) *.exe errs tags *.uue
	rcsclean *.c *.h makefile

fgrep.obj: kwset.h std.h unix.h
kwset.obj obstack.obj: $(OBSTINC)
std.obj: std.h unix.h

include make.inc

# Distribution

.PHONY: dist
dist: fgrep.uue

fgrep.tar: readme copying makefile make.inc patches fgrep.exe

patches: $(SRCS) $(addprefix RCS/,$(RCSFILES))
	rcsdiff -c -r$(VERSION) $(SRCS) > $@

.PHONY: test-dist
test-dist: $(PROGRAM).uue $(addprefix RCS/,$(RCSFILES))
	$(CO) -f -r$(VERSION) $(SRCS)
	sed /\.tar\.Z/s//.Z/ $(PROGRAM).uue | uudecode
	compress -d < $(PROGRAM).Z | tar -xOf -  patches | patch -s
	rcsdiff -q $(SRCS)

