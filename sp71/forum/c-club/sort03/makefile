# Makefile for GNU sort
# Copyright 1989 (C) Free Software Foundation, Inc.

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

# MS-DOS port (c) 1990 by Thorsten Ohl, td12@ddagsi3.bitnet
# This port is also distributed under the terms of the
# GNU General Public License as published by the
# Free Software Foundation.

# $Header: e:/gnu/sort/RCS/makefile.'v 0.3.0.4 90/08/26 19:10:03 tho Rel $

# Interesting targets:
#
#	all (default, makes sort.exe)
#	docs (makes sort.dvi and sort.inf)
#	tags (creates tags)
#	install (put sort.exe into BINDIR)
#

PROGRAM	= sort

# Where to find library objects, includes, or sources
VPATH	= d:/usr/lib;d:/usr/include

# Where to put the executable
BINDIR	= c:/bin

INSTALL = cp -v
DISK	= b:
ZIPFILE = $(PROGRAM).zip

#BUILD	= debug
BUILD	= production

ifeq ($(BUILD),debug)
CFLAGS	= -AC -W4 -Od -Zi -Za -DSTDC_HEADERS -DUSG
LDFLAGS = /co/st:0x8000/noe
else
# Don't use -Oe (global register allocation):
# > sort.c(1106) : fatal error C1001: Internal Compiler Error  
# >                (compiler file '../grammar.c', line 140)   
# >                Contact Microsoft Product Support Services 
# We also refrain from removing the stackprobes for the momemt, until we
# figured out how deeply the program recurses...
CFLAGS	= -AC -W4 -Ocgilt -Za -DSTDC_HEADERS -DUSG
LDFLAGS = /e/st:0x8000/noe
endif

OBJS	= sort.obj
SRCS	= sort.c std.h
LIBS	= glob.obj msd_dir.obj _cwild.obj

RCSFILES= $(patsubst %, RCS/%'v, $(SRCS)) RCS/makefile.'v
MISC	= RCS/todo'v RCS/perf'v RCS/sort.t'v todo.dos changelo

DIST_FILES = readme sort.tex sort.inf makefile $(SRCS)

.PHONY: all
all: $(PROGRAM).exe

$(PROGRAM).exe: $(OBJS) $(LIBS)
	$(LINK) $(LDFLAGS) $^ setargv, $@;

sort.obj: std.h

.PHONY: install
install: $(PROGRAM).exe
	$(INSTALL) $(PROGRAM).exe $(BINDIR)

.PHONY: docs
docs: $(PROGRAM).inf $(PROGRAM).dvi

$(PROGRAM).inf: $(PROGRAM).tex
	makeinfo $<

$(PROGRAM).dvi: $(PROGRAM).tex
	tex $(PROGRAM)
	tex $(PROGRAM)
	rm $(PROGRAM).??

tags: $(SRCS)
	etags $^

.PHONY: clean
clean:
	rm -f *.exe *.obj *.aux *.toc *.log *.dvi *.dlg *.inf errs tags
	rm -r $(PROGRAM)
	rcsclean *.c *.h *.tex makefile

.PHONY: zip disk
zip: $(ZIPFILE)
disk: $(DISK)/$(ZIPFILE)

$(ZIPFILE): $(RCSFILES) $(MISC)
	pkzip -frp $@

$(DISK)/$(ZIPFILE): $(ZIPFILE)
	cp $< $@
	pkunzip -t $@ | grep -vw OK

.PHONY: dist tar-dist zip-dist
dist: tar-dist zip-dist

tar-dist: $(PROGRAM)-tar.uue
zip-dist: $(PROGRAM)-zip.uue

$(PROGRAM)-tar.uue: $(addprefix $(PROGRAM)/,$(DIST_FILES))
	flip -ub $(PROGRAM)/*.*
	tar -cf - $(PROGRAM) | compress | uuencode $(PROGRAM).tar.Z > $@

$(PROGRAM)-zip.uue:  $(addprefix $(PROGRAM)/,$(DIST_FILES))
	flip -mb $(PROGRAM)/*.*
	echo GNU $(PROGRAM) (pre-alpha) for MS-DOS \
		| pkzip -z $(PROGRAM)dist $(PROGRAM)/*.*
	uuencode $(PROGRAM)dist.zip $(PROGRAM).zip > $@

$(PROGRAM)/%: %
	cp $< $@

$(addprefix $(PROGRAM)/,$(DIST_FILES)): $(PROGRAM)

$(PROGRAM):
	mkdir $(PROGRAM)
