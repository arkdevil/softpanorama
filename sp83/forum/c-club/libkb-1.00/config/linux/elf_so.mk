#
# Makefile for Linux ELF shared library 
#
# libkb -- a free, advanced and portable low-level keyboard library
# Copyright (C) 1995, 1996 Markus Franz Xaver Johannes Oberhumer
# For conditions of distribution and use, see copyright notice in kb.h 
#


# /***********************************************************************
# // imported vars:
# //    $(lib_name) $(major_shared) $(minor_shared)
# //    $(SRCS)
# //    $(INSTALL) $(INSTALL_LIBDIR)
# //
# // exported vars:
# //    $(SHARED_LIB) $(SHARED_OBJS) $(SHARED_CFLAGS)
# //
# // exported targets: 
# //    shared_lib  shared_lib_install  shared_lib_clean
# //    $(SHARED_LIB) 
# //
# ************************************************************************/

.PHONY: shared_lib shared_lib_install shared_lib_clean

SHARED_LIB = lib$(lib_name).so.$(major_shared).$(minor_shared)

SHARED_OBJS = $(SRCS:%.c=%.so)

SHARED_CFLAGS += -fPIC

%.so : %.c
	$(COMPILE.c) $(SHARED_CFLAGS) $< $(OUTPUT_OPTION)


$(SHARED_LIB): $(SHARED_OBJS)
	gcc -shared -Wl,-soname,lib$(lib_name).so.$(major_shared) -o $(SHARED_LIB) $(SHARED_OBJS)
	chmod a+x $(SHARED_LIB)
	$(RM) lib$(lib_name).so.$(major_shared)
	ln -s $(SHARED_LIB) lib$(lib_name).so.$(major_shared)
	$(RM) lib$(lib_name).so
	ln -s lib$(lib_name).so.$(major_shared) lib$(lib_name).so

shared_lib: $(SHARED_LIB)

shared_lib_clean:
	$(RM) $(SHARED_LIB) lib$(lib_name).so.$(major_shared) lib$(lib_name).so $(SHARED_OBJS)


# /***********************************************************************
# // installation
# ************************************************************************/

shared_lib_install: $(SHARED_LIB)
	$(INSTALL) $^ $(INSTALL_LIBDIR)/
	$(RM) $(INSTALL_LIBDIR)/lib$(lib_name).so.$(major_shared)
	ln -s $(INSTALL_LIBDIR)/$(SHARED_LIB) $(INSTALL_LIBDIR)/lib$(lib_name).so.$(major_shared)
	$(RM) $(INSTALL_LIBDIR)/lib$(lib_name).so
	ln -s $(INSTALL_LIBDIR)/lib$(lib_name).so.$(major_shared) $(INSTALL_LIBDIR)/lib$(lib_name).so

