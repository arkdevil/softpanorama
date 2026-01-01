#
# libkb -- a free, advanced and portable low-level keyboard library
# Copyright (C) 1995, 1996 Markus Franz Xaver Johannes Oberhumer
# For conditions of distribution and use, see copyright notice in kb.h 
#

#
# this file is included by Makefile, makefile.dj2 and Makefile.mfx
#

# /***********************************************************************
# // source, objects and executable files
# ************************************************************************/

SRCS = kbhandle.c kbmlock.c kbos.c kbsignal.c kbtables.c

OBJS = $(strip $(SRCS:.c=$O))


.PHONY: distexe

DISTEXE := bin/kbtstdos.exe bin/kbtstlnx.out

distexe: $(DISTEXE)


# /***********************************************************************
# // common useful targets
# ************************************************************************/

.PHONY: nm touch grep

nm: nm-$(C)

nm-DJG nm-EMX nm-LNX nm-lnx nm-: $(LIBKB)
	nm --extern-only $<


touch:
	-$(TOUCH) -c -t 072301001996.00 * */* */*/*
#	                MMDDhhmmCCYY.ss



UPPER_MAKE := Makefile Makefile.inc Makefile.lnx Makefile.mfx

UPPER_FILE := CHANGE.LOG COPYING.KB DESC.SDI FILE_ID.DIZ KB.DOC README.1ST


grep:
	-mfxgrep -lc   '\t' $(UPPER_FILE) include/kb.h
	-mfxgrep -lcrB '\r' 
	-mfxgrep -Lcri 'oberhumer' 


# /***********************************************************************
# // Dependencies and special rules
# ************************************************************************/

_kbtable.hh: mktables$E
	$< > $(shell_@)

kbhandle$O: kbhandle.c _handler.h _kblinux.h _kbmsdos.h 
kbtables$O: kbtables.c _kbtable.hh _kbname.hh
kbtst$O: kbtst.c myconio.h
tube$O: tube.c tube.h

