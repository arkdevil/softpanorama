#
# Makefile for GNU make
#
# libkb -- a free, advanced and portable low-level keyboard library
# Copyright (C) 1995, 1996 Markus Franz Xaver Johannes Oberhumer
# For conditions of distribution and use, see copyright notice in kb.h 
#


UNAME_S := $(strip $(shell uname -s))


ifneq ($(COMSPEC),)
shell_@=$(subst /,\\,$@)
else
shell_@=$@
endif


#
# Linux
#

ifeq ($(UNAME_S),Linux)

# TODO: autodetect an ELF compiler and select ELF target

ifneq ($(strip $(wildcard Makefile.lnx)),)
include Makefile.lnx
else
include makefile.lnx
endif
endif


#
# djgpp v2 (MSDOS)
#

ifeq ($(UNAME_S),)
ifneq ($(COMSPEC),)
ifneq ($(DJGPP),)
include config/dos/makefile.dj2
endif
endif
endif


