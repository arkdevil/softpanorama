#
# Makefile for GNU make
#
# libkb -- a free, advanced and portable low-level keyboard library
# Copyright (C) 1995, 1996 Markus Franz Xaver Johannes Oberhumer
# For conditions of distribution and use, see copyright notice in kb.h 
#


# /***********************************************************************
# // Configuration
# ************************************************************************/

O := .o#			# object extension
A := .a#			# library extension
E := .out#			# executable extension

UNAME_M    := $(shell uname -m)


# /***********************************************************************
# // Compiler and linker flags
# ************************************************************************/

CC            := gcc
## CFLAGS        += -v			# be verbose
CFLAGS        += -Wall -W -pedantic	# all warnings on
CFLAGS        += -O2 			# optimize 
ifeq ($(UNAME_M),i486)
CFLAGS        += -m486 			# optimize for 486
endif

### debugging
ifeq (1,2)
CFLAGS        += -g 			# include debug information
else
CFLAGS        += -fomit-frame-pointer 	# optimize (no debugging possible)
LDFLAGS       += -s			# strip executable
endif

### bounds checking
ifeq (1,2)
CFLAGS        += -fbounds-checking
LDFLAGS       += -fbounds-checking
endif


CFLAGS        := $(strip $(CFLAGS))
LDFLAGS       := $(strip $(LDFLAGS))
LDLIBS        := $(strip $(LDLIBS))


# /***********************************************************************
# // main targets
# ************************************************************************/

.PHONY: default all

default: all

all: vt$E

vt$E: vt$O 
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@


clean:
	-$(RM) *.o *.out 

realclean: clean


