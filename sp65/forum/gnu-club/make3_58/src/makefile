## Copyright (C) 1988, 1989 Free Software Foundation, Inc.
# This file is part of GNU Make.
# 
# GNU Make is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 1, or (at your option)
# any later version.
#
# GNU Make is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with GNU Make; see the file COPYING.  If not, write to
# the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

# MS-DOS port (c) 1990 by Thorsten Ohl <ohl@gnu.ai.mit.edu>
#
# To this port, the same copying conditions apply as to the
# original release.
#
# IMPORTANT:
# This file is not identical to the original GNU release!
# You should have received this code as patch to the official
# GNU release.
#
# MORE IMPORTANT:
# This port comes with ABSOLUTELY NO WARRANTY.
#
# $Header: e:/gnu/make/RCS/makefile.'v 3.58.0.9 90/07/23 23:17:36 tho Exp $

#
#	Makefile for GNU Make
#

VPATH	= d:/usr/lib;d:/usr/include
BINDIR	= c:/bin

#BUILD = debug
BUILD = production

ifeq ($(BUILD),debug)

defines = -DUSG -DNO_LDAV -DNO_FLOAT -DSTDC_HEADERS -DSMART_SHELL -DUSE_XMS

CFLAGS	= $(defines) -FPa -AL -Od -Zi -W4
CRIPPLED_CFLAGS = $(CFLAGS)
LDFLAGS = /st:0x8000/map/noe/co

else

CFLAGS	= $(defines) -FPa -AL -Ox -W4
CRIPPLED_CFLAGS = $(defines) -FPa -AL -Od -W4
LDFLAGS = /st:0x8000/map/noe/e

endif
  
# MS-DOS specific files (not in the GNU distribution)
DOSOBJ	= msd_dir.obj _cwild.obj zipscan.obj
DOSSRC	= msd_dir.c _cwild.c zipscan.c
DOSINC	= msd_dir.h
SWAPLIB	= swaplibl.lib
SWAPOBJ	= swap.obj
SWAPSRC	= swap.c
SWAPINC	= swaplib.h

# If you don't want archive support, comment these out.
ARCHIVES = ar.obj zipscan.obj
ARCHIVES_SRC = ar.c zipscan.c

objs  = $(swapobj) glob.obj commands.obj job.obj dir.obj file.obj load.obj \
        misc.obj main.obj read.obj remake.obj remote.obj rule.obj \
        implicit.obj default.obj variable.obj expand.obj function.obj \
        vpath.obj $(ARCHIVES) $(extras)
srcs  = $(swapsrc) glob.c commands.c job.c dir.c file.c load.c misc.c \
        main.c read.c remake.c remote.c rule.c implicit.c default.c \
        variable.c expand.c function.c vpath.c version.c $(ARCHIVES_SRC)
incs  =	commands.h dep.h file.h job.h make.h rule.h variable.h msd_dir.h

DISTSRC	= $(DISTOBJ:.obj=.c) remote-s.c version.c
DISTINC	= commands.h dep.h file.h job.h make.h rule.h variable.h

# Preserve the ordering of object files!
# swap spawn ...
OBJS	= $(SWAPOBJ) $(DISTOBJ) $(AROBJ) $(DOSOBJ)
SRCS	= $(DISTSRC) $(ARSRC) $(DOSSRC)
INCS	= $(DISTINC) $(ARINC) $(DOSINC)

# Files for backup and patches:
RCSFILES= $(patsubst %, RCS/%'v, $(SRCS) $(INCS)) RCS/makefile.'v
MISC	= projects ChangeLog makepat mkpatch readme.dos make.dos
DISTFILES = $(patsubst %, dist/%, $(DISTSRC) $(ARSRC) $(DISTINC) $(ARINC))
DOSFILES = $(patsubst %, dos/%, $(SRCS) $(INCS) makefile)

DISK = b:
ZIPFILE	= gnumake.zip

all: gnumake.exe

gnumake.exe: $(objs) version.c
	$(CC) $(CFLAGS) -c version.c
	$(LINK) $(LDFLAGS) $(OBJS) version setargv,$@,gnumake.map,$(SWAPLIB),

# Well, here optimization is dangerous... (inline assembler etc.)
swap.obj: swap.c
	$(CC) $(CRIPPLED_CFLAGS) -c $<

# MSC 6.0 bombs with `-Ox'
main.obj : main.c make.h commands.h dep.h file.h variable.h job.h $(SWAPINC)
	$(CC) $(CRIPPLED_CFLAGS) -c $<

# debugging
swap.exe: swap.c spawn.c
	$(CC) $(CRIPPLED_CFLAGS) -DTEST -Zi -Fe$@ swap.c spawn.c
	rm -f swap.obj spawn.obj

tags: $(srcs) $(srcs2) $(srcs3) $(incs)
	etags  *.c *.h

install: $(BINDIR)/make.exe

$(BINDIR)/make.exe:gnumake.exe
	$(INSTALL) $< $@

clean:
	rm -f *.obj *.map tags errs
	rcsclean *.c *.h makefile

zip: $(ZIPFILE)

disk: $(DISK)/$(ZIPFILE)

$(ZIPFILE): $(RCSFILES) $(MISC)
	pkzip -frp $@

$(DISK)/$(ZIPFILE): $(ZIPFILE)
	cp $< $@
	pkunzip -t $@ | grep -vw OK

# Dependencies:

ar.obj: make.h file.h
commands.obj: make.h dep.h commands.h file.h variable.h job.h
default.obj: make.h rule.h dep.h file.h commands.h variable.h
dir.obj: make.h msd_dir.h
expand.obj: make.h commands.h file.h variable.h
file.obj: make.h commands.h dep.h file.h variable.h
function.obj: make.h variable.h dep.h commands.h job.h $(SWAPINC)
glob.obj: msd_dir.h
implicit.obj: make.h rule.h dep.h file.h
job.obj: make.h commands.h job.h file.h variable.h $(SWAPINC)
load.obj: make.h commands.h job.h
misc.obj: make.h dep.h
msd_dir.obj: msd_dir.h
read.obj: make.h commands.h dep.h file.h variable.h
remake.obj: make.h commands.h job.h dep.h file.h
remote.obj: remote-s.c make.h commands.h
rule.obj: make.h commands.h dep.h file.h variable.h rule.h
variable.obj: make.h commands.h variable.h dep.h file.h
vpath.obj: make.h file.h variable.h




