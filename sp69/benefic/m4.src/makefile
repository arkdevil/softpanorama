# makefile - GNUish MS-DOS m4
# Copyright (C) 1990 Free Software Foundation, Inc.
# Thorsten Ohl <ohl@gnu.ai.mit.edu>, 1990

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

# $Header: e:/gnu/m4/RCS/makefile 0.5.0.7 90/10/27 10:40:44 tho Exp $

# The name of the game
CMD	= m4.exe

# Where the gnulib lives
VPATH	= d:/usr/lib;d:/usr/include

# Where `make install' shall put the executable
BINDIR	= c:/bin

ZIPFILE	= m4
DISK	= b
INSTALL	= cp -f

# you will need the compact model for reasonably complicated macros:
MODEL	= C
LINT	= 3

VERSION	= 0.5
PACKETSIZE = 55

BUILD	= debug

# You shouldn't need to change anything below ...

ifeq ($(BUILD),debug)
CFLAGS	= -A$(MODEL) -Od -Zi -Za -qc -W$(LINT) -DUSG -DTRACE_MEMORY_USAGE
LDFLAGS = /co/st:0x8000/noe setargv
else
CFLAGS	= -A$(MODEL) -Ox -Ge -Za -W$(LINT) -DUSG
LDFLAGS = /e/st:0x8000/noe setargv
endif

HDRS	= m4.h
SRCS	= m4.c input.c output.c symtab.c builtin.c macro.c eval.c
OBJS	= m4.obj input.obj output.obj symtab.obj builtin.obj macro.obj eval.obj

LIBHDRS	= obstack.h version.h
LIBSRCS	= obstack.c vfprintf.c
LIBOBJS	= obstack.obj

ALLHDRS = ${HDRS} ${LIBHDRS}
ALLSRCS = ${SRCS} ${LIBSRCS}
ALLOBJS = ${OBJS} ${LIBOBJS} _cwild.obj

LOADLIBES = gnulib_$(MODEL)

RCSFILES= $(ALLHDRS) $(ALLSRCS) Makefile
MISC	= COPYING ChangeLog readme readme.gmd

.PHONY: all install zip disk clean veryclean dist

all: $(CMD)

$(CMD): $(ALLOBJS)

# This will be the default in the next make release:
%.exe: %.obj
	$(LINK) $(LDFLAGS) $^,$@,,$(LOADLIBES) $(LDLIBS),

m4.obj : m4.c m4.h obstack.h version.h 
input.obj : input.c m4.h obstack.h 
output.obj : output.c m4.h obstack.h 
symtab.obj : symtab.c m4.h obstack.h 
builtin.obj : builtin.c m4.h obstack.h 
macro.obj : macro.c m4.h obstack.h 
eval.obj : eval.c m4.h obstack.h 
obstack.obj : obstack.c obstack.h 

# utilities ...

install: $(BINDIR)/$(CMD)

$(BINDIR)/%: %
	$(INSTALL) $< $@

tags: $(ALLSRCS) $(ALLHDRS)
	etags -t *.c *.h

clean:
	$(RM) $(ALLOBJS) errs

veryclean: clean
	rcsclean $(RCSFILES)

include make.inc

dist: m4.01

m4.01: COPYING README README.gmd Makefile make.inc patches $(CMD)
	shar -Cb16 -F -an'GNUish MS-DOS m4' \
		-L$(PACKETSIZE) -o $(basename $@) $^

patches: $(ALLHDRS) $(ALLSRCS)
	rcsdiff -cw -r$(VERSION) *.[ch] > $@




