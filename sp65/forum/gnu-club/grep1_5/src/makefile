# Makefile for GNU e?grep
# Copyright (C) 1988 Free Software Foundation, Inc.
# MS-DOS port (c) 1990 by Thorsten Ohl <ohl@gnu.ai.mit.edu>

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
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  */

# $Header: e:/gnu/grep/RCS/makefile 1.5.0.9 90/09/21 12:07:41 tho Exp $

# Where the executables go
BINDIR	= c:/bin

# Where the gnulib lives on your system
VPATH	= d:/usr/include;d:/usr/lib

# main entry points:
.PHONY: all regress install zip disk clean veryclean dist

DEFINES	= -DUSG -DSTDC_HEADERS -DSMART_SHELL

# Define MSC51, if your compiler is Microsoft C v5.1

ifeq ($(COMPILER),MSC51)
MODEL	= L
model	= l
CFLAGS	= -A$(MODEL) -Ox -W3 -Za $(DEFINES)
CRIPPLED_CFLAGS = -A$(MODEL) -Oilt -Gs -W3 -Za $(DEFINES)
else
MODEL	= C
model	= c
CFLAGS	= -A$(MODEL) -Ox -W4 -Za $(DEFINES)
CRIPPLED_CFLAGS = -A$(MODEL) -Ocit -Gs -W4 -Za $(DEFINES)
endif

LDFLAGS = /e/noe/far/packcode/st:0x8000 setargv
LOADLIBES = gnulib_$(model)

INSTALL = cp -v
DISK	= b:
ZIPFILE = grep.zip

# Files:

VERSION	= 1.5

# The common object modules:
OBJS = dfa.obj _cwild.obj

SRCS = grep.c dfa.c
INCS = dfa.h

CMDS	= egrep.exe grep.exe

RCSFILES= $(addprefix RCS/, $(SRCS) $(INCS) makefile)
MISC	= readme copying changelo

all: $(CMDS)

# Linking:

$(CMDS): $(OBJS)

# This is for old versions of make, where this rule wasn't default
%.exe: %.obj
	$(LINK) $(LDFLAGS) $^, $@, nul, $(LOADLIBES),

# Perform some tests

regress: egrep.exe
	cd tests
	regress
	cd ..

# Compilation:

egrep.obj: grep.c
	$(CC) $(CFLAGS) -DEGREP -Fo$@ -c $<

# --- MSC 5.1 generates incorrect code with relaxed alias checking `-Oa'
#     (this code fails some of the Spencer tests).
# --- MSC 6.0 generates incorrect code with `-Ol' and/or `-Oa'
#     (this code has memory leaks...).
dfa.obj: dfa.c dfa.h
	$(CC) $(CRIPPLED_CFLAGS) -c $<

dfa.obj egrep.obj grep.obj: dfa.h

# --- utils:

install: $(addprefix $(BINDIR)/, $(CMDS))

$(BINDIR)/%: %
	$(INSTALL) $< $@

zip: $(ZIPFILE)
disk: $(DISK)/$(ZIPFILE)

$(ZIPFILE): $(RCSFILES) $(MISC)
	pkzip -P -r- $@ $?

$(DISK)/$(ZIPFILE): $(ZIPFILE)
	cp $< $@
	pkunzip -t $@ | grep -vw OK

tags: $(SRCS) $(INCS)
	etags -t *.h *.c

clean:
	rm -f *.obj tests/tmp.bat tests/khadafy.out patches *.tar

veryclean: clean
	rm -f *.exe *.uue errs tags
	rcsclean *.c *.h makefile

dist: grep.uue grep-b.uue egrep-b.uue

%.uue: %.tar
	compress < $< | uuencode $<.Z > $@

%.tar:
	tar -cf $@ $^

grep.tar: readme copying makefile patches
grep-b.tar: readme copying grep.exe
egrep-b.tar: readme copying egrep.exe


patches: $(SRCS) $(INCS) $(RCSFILES)
	rcsdiff -c -r$(VERSION) *.[ch] > $@

.PHONY: test-dist
test-dist: grep.uue $(RCSFILES)
	$(CO) -f -r$(VERSION) $(SRCS) $(INCS)
	sed /\.tar\.Z/s//.Z/ grep.uue | uudecode
	compress -d < grep.Z | tar -xOf -  patches | patch -s
	rcsdiff -q $(SRCS) $(INCS)

.PHONY: cheat
cheat:
	$(INSTALL) $(addprefix $(BINDIR)/, $(CMDS)) .
