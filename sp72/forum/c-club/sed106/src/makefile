#  GNU SED, a batch stream editor.
#  Copyright (C) 1989, Free Software Foundation, Inc.
#  Thorsten Ohl, ohl@gnu.ai.mit.edu, 1990

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 1, or (at your option)
#  any later version.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  */

#  $Header: e:/gnu/sed/RCS/makefile 1.6.1.1 90/09/22 18:09:59 tho Exp $

# Entry points
.PHONY: all install clean veryclean zip disk

# Where _cwild.c and the gnulib live:
VPATH	= d:/usr/lib;d:/usr/include

# Where the executable goes:
BINDIR	= c:/bin
INSTALL = cp -f

PROGRAM = sed
VERSION	= 1.6

DISK	= b
ZIPFILE = sed

# compiler and linker

# The small model is sufficient for most (few lines) scripts, but
# the compact model is recommended for more complicated applications.
MODEL	= C

ifeq ($(BUILD),debug)
CFLAGS	= -A$(MODEL) -Za -DUSG -W4 -Od -Zi -DSTDC_HEADERS -DSMART_SHELL
LDFLAGS	= /co/noe/st:0x8000/far/packcode setargv
else
CFLAGS	= -A$(MODEL) -Za -DUSG -W4 -Ox -DSTDC_HEADERS -DSMART_SHELL
LDFLAGS	= /e/noe/st:0x8000/far/packcode setargv
endif

# files
OBJS	= sed.obj _cwild.obj
SRCS	= sed.c
LOADLIBES = gnulib_$(MODEL)

RCSFILES= $(SRCS) makefile
MISC	= ChangeLog README Todo make.inc

all: $(PROGRAM).exe

$(PROGRAM).exe: $(OBJS)

# This is for old versions of make, where this rule wasn't default
%.exe: %.obj
	$(LINK) $(LDFLAGS) $^, $@, nul, $(LOADLIBES),

# utils:

install: $(BINDIR)/$(PROGRAM).exe

$(BINDIR)/$(PROGRAM).exe: $(PROGRAM).exe
	$(INSTALL) $^ $@

clean:
	$(RM) *.obj *.tar patches *~

veryclean: clean
	$(RM) *.exe errs tags *.uue
	rcsclean *.c makefile

tags: $(SRCS)
	etags $^

dist: $(PROGRAM).uue

$(PROGRAM).tar: README makefile make.inc patches $(PROGRAM).exe

patches: $(SRCS)
	rcsdiff -c -r$(VERSION) $^ > $@

.PHONY: test-dist
test-dist: $(PROGRAM).uue $(addprefix RCS/, $(RCSFILES))
	$(CO) -f -r$(VERSION) $(SRCS)
	sed /\.tar\.Z/s//.Z/ $< | uudecode
	compress -d < $(PROGRAM).Z | tar -xOf - patches | patch -s
	$(RM) $(PROGRAM).Z
	rcsdiff -q $(SRCS)

include make.inc
