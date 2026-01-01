# Makefile for fileutils (MS-DOS)
# Copyright (C) 1986, 1988, 1989 Free Software Foundation, Inc.

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

# MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
# This port is also distributed under the terms of the
# GNU General Public License as published by the
# Free Software Foundation.

# Please note that this file is not identical to the
# original GNU release, you should have received this
# code as patch to the official release.

# $Header: e:/gnu/fileutil/RCS/makefile 1.4.0.3 90/09/19 13:27:14 tho Exp $

VPATH	= d:/usr/lib;d:/usr/include

INSTALL = cp -v
DISK	= b:
ZIPFILE = fileutil.zip

MODEL	= S
model	= s

# You'll need the gnulib, featuring:
# _cwild.c, error.c, getopt.c, getopt.h, getopt1.c, glob.c, gnulib.h,
# ndir.c, ndir.h, pwd.c, pwd.h, regex.c, regex.h, xmalloc.c, xrealloc.c

GNULIB	= gnulib_$(model)

DEFINES	= -DVPRINTF -DUTIMES_MISSING -DFCHMOD_MISSING -DSTDC_HEADERS \
	  -DINT_16_BITS -DUSG -DBLKSIZE=0x4000 -DSMART_SHELL

BUILD	= production

ifeq ($(BUILD),debug)
CFLAGS	= -A$(MODEL) -Za -Od -Zi -W4 $(DEFINES)
LDFLAGS	= /co/noe setargv
else
CFLAGS	= -A$(MODEL) -Za -Ox -W4 $(DEFINES)
LDFLAGS	= /e/noe/far/packcode setargv
endif

# for malloc()'ing programs
SSTACK	= /st:0x4000
# for alloca()'ing programs (incl. `auto' allocation)
BSTACK	= /st:0x8000

# Where to install the executables
BINDIR	= c:/bin

# Executable files in this directory

CMDS	= $(CMDS1) $(CMDS2) $(CMDS3) $(CMDS4) $(CMDS5)

# These are designed to give < 100k .tar.Z.uue files.

CMDS1	= cat.exe chmod.exe cmp.exe cp.exe
CMDS2	= cut.exe dir.exe dd.exe head.exe
CMDS3	= ls.exe mkdir.exe mv.exe paste.exe
CMDS4	= rm.exe rmdir.exe tac.exe
CMDS5	= tail.exe touch.exe vdir.exe

# Sources

SRCS	= argmatch.c backupfi.c cat.c chmod.c cmp.c cp-aux.c cp.c cut.c \
	  dd.c eaccess.c filebloc.c filemode.c getversi.c head.c ls.c \
	  mkdir.c modechan.c mv.c paste.c rm.c rmdir.c savedir.c tac.c \
	  tail.c touch.c getdate.y posixtim.y
INCS	= backupfi.h cp.h modechan.h system.h

UNUSED	= cp-hash.c dirlib.c du.c error.c getopt.c getopt.h getopt1.c \
	  globmat.c install.c ln.c mkfifo.c mktime.c mvdir.c regex.c regex.h

DOCS	= fileutil.pl
MPAGES	= gcat.1 gchmod.1 gcmp.1 gcp.1 gcut.1 gdd.1 gdu.1 ghead.1 \
	  ginstall.1 gln.1 gls.1 gmkdir.1 gmkfifo.1 gmv.1 gpaste.1 \
	  grm.1 grmdir.1 gtac.1 gtail.1 gtouch.1
MANDIR	= man
MANPAGES= $(addprefix $(MANDIR)/,$(MPAGES))

RCSFILES= $(addprefix RCS/, $(SRCS) $(INCS) $(DOCS) makefile readme) \
	  $(MANPAGES)
MISC	= changelo todo makepat mkpatch RCS/tar_-tv

TARFILES= makefile fileutil.pl patches
PATCHES	= fileutil
BINARIES= $(addprefix futil-b, 1 2 3 4 5)

# Version of fileutils release

VERSION = 1.4

# Targets

.PHONY: all install
all: $(CMDS)
install: $(addprefix $(BINDIR)/, $(CMDS))

$(BINDIR)/% : %
	$(INSTALL) $< $@

# Linking rules

%.exe: %.obj
	$(LINK) $(LDFLAGS) $(BSTACK) $^, $@, nul, $(GNULIB),

cmp.exe: cmp.obj _cwild.obj
	$(LINK) $(LDFLAGS) $(SSTACK) $^, $@, nul, $(GNULIB),

$(CMDS): _cwild.obj

chmod.exe: filemode.obj modechan.obj savedir.obj
cp.exe: argmatch.obj backupfi.obj cp-aux.obj eaccess.obj getversi.obj \
	savedir.obj # cp-hash.obj
dir.exe ls.exe vdir.exe: argmatch.obj filebloc.obj filemode.obj
mkdir.exe: modechan.obj
mv.exe: argmatch.obj backupfi.obj getversi.obj
rm.exe: eaccess.obj
touch.exe: argmatch.obj getdate.obj posixtim.obj

# Compilation rules

dir.obj: ls.c
	$(CC) $(CFLAGS) -DMULTI_COL -c -Fo$@ ls.c

vdir.obj: ls.c
	$(CC) $(CFLAGS) -DLONG_FORMAT -c -Fo$@ ls.c

$(SRCS:.c=.obj): system.h
chmod.obj mkdir.obj modechan.obj: modechan.h
backupfi.obj cp.obj getversi.obj mv.obj: backupfi.h
cp.obj cp-aux.obj cp-hash.obj : cp.h


# Documentation (requires Larry Wall's `perl').

.PHONY: docs info tex
docs: info tex
info: fileutil.inf
tex: fileutil.dvi

fileutil.dvi: fileutil.tex fileutil.pgs
	tex $<

fileutil.pgs: fileutil.pg
	texindex $^

fileutil.pg: fileutil.tex
	tex $<

fileutil.inf: fileutil.tex
	makeinfo $<

fileutil.tex: fileutil.pl $(MANPAGES)
	perl $< MANDIR=$(MANDIR) > $@

# Cleanup, Backup, Patches

.PHONY: clean veryclean
clean:
	rm -f *.obj *.map *~ *.tar *.cp *.fn *.ky *.pg *.pgs *.tp *.vr \
	      *.tex *.aux *.toc *.dvi *.log *.dlg

veryclean: clean
	rm -f *.uue *.exe *.inf errs tags
	rcsclean *.c *.h *.y *.pl makefile

.PHONY: zip disk
zip: $(ZIPFILE)
disk: $(DISK)/$(ZIPFILE)

$(ZIPFILE): $(RCSFILES) $(MISC)
	pkzip -r- -P $@ $?

$(DISK)/$(ZIPFILE): $(ZIPFILE)
	cp $< $@
	pkunzip -t $@ | grep -vw OK

tags: $(SRCS) $(INCS)
	etags -t *.h *.c


.PHONY: dist
dist: $(addsuffix .uue, $(PATCHES) $(BINARIES))

%.uue: %.tar
	compress < $< | uuencode $<.Z > $@

%.tar:
	tar -cf $@ $^

$(PATCHES).tar: readme copying $(TARFILES)
futil-b1.tar: readme copying $(CMDS1)
futil-b2.tar: readme copying $(CMDS2)
futil-b3.tar: readme copying $(CMDS3)
futil-b4.tar: readme copying $(CMDS4)
futil-b5.tar: readme copying $(CMDS5)

patches: $(SRCS) $(INCS) $(RCSFILES)
	rcsdiff -c -r$(VERSION) *.[chy] > $@

.PHONY: test-dist
test-dist: $(PATCHES).uue $(RCSFILES)
	$(CO) -f -r$(VERSION) $(SRCS) $(INCS)
	sed /\.tar\.Z/s//.Z/ $(PATCHES).uue | uudecode
	compress -d < $(PATCHES).Z | tar -xOf -  patches | patch -s
	rcsdiff -q $(SRCS) $(INCS)

.PHONY: cheat
cheat:
	$(INSTALL) $(addprefix $(BINDIR)/, $(CMDS)) .

