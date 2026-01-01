#
# Makefile for Linux a.out shared library
#
# libkb -- a free, advanced and portable low-level keyboard library
# Copyright (C) 1995, 1996 Markus Franz Xaver Johannes Oberhumer
# For conditions of distribution and use, see copyright notice in kb.h 
#


#
# Build libkb shared image.
# Required: dlltools >= 2.16
#

#
# Adress space reserved for the library.
#
JUMP_BASE  = 0x73b00000
JUMP_SIZE  = 0x400
JUMP_GOT   = 0x400


#
# Your X11 directory setup
#
## SHARED_LIBPATH  += -L/usr/X11R6/lib
## SHARED_REQ_LIBS += -lXt -lX11



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
# //    $(SHARED_LIB) $(JUMP_DIR)
# //    shared_stage1  shared_stage2
# //
# ************************************************************************/

.PHONY: shared_lib shared_lib_clean shared_lib_install
.PHONY: shared_stage1 shared_stage2

SHARED_LIB = $(JUMP_SA)

SHARED_OBJS = $(SRCS:%.c=%.so)

SHARED_CFLAGS += -B/usr/dll/jump/

%.so : %.c
	$(COMPILE.c) $(SHARED_CFLAGS) $< $(OUTPUT_OPTION)


SHARED_LIBGCC =`gcc --print-libgcc-file-name`
SHARED_REV=$(major_shared).$(minor_shared)

JUMP_DIR=./jump
JUMP_LIB=lib$(lib_name)
JUMP_AR=lib$(lib_name).a~
JUMP_SA=lib$(lib_name).sa
JUMP_SO=lib$(lib_name).so.$(SHARED_REV)

export JUMP_DIR JUMP_LIB




$(JUMP_AR): $(SHARED_OBJS)
	$(RM) $(JUMP_AR)
	(cd .; ar cq  $(JUMP_AR) $(SHARED_OBJS)) || exit 1
	ranlib $(JUMP_AR)

$(JUMP_DIR):
	mkdir $(JUMP_DIR)

$(JUMP_DIR)/jump.log:
	@echo "#"
	@echo "# Stage 1: Collect global vars and exported functions."
	@echo "#"
	if [ ! -d $(JUMP_DIR) ]; then mkdir $(JUMP_DIR); fi
	@if [ -s $(JUMP_DIR)/jump.log ]; then echo "Error: Leftover globals for shared lib"; exit 1; fi
	$(RM) $(JUMP_AR)
	$(MAKE) $(JUMP_AR)
	touch $@


./mk_JUMP_SO_0: $(JUMP_DIR)/jump.log
	$(RM) $(SHARED_OBJS)
	$(RM) $(JUMP_AR)
	getfuncs
	getvars
	touch $@

./mk_JUMP_SO_1: ./mk_JUMP_SO_0
	@echo "#"
	@echo "# Stage 2: Build shared image."
	@echo "#"
	$(MAKE) $(JUMP_AR)
	getsize > $(JUMP_DIR)/j.v
	mv $(JUMP_DIR)/j.v $(JUMP_DIR)/jump.vars
	touch $@

$(JUMP_SO): ./mk_JUMP_SO_1 $(JUMP_AR)
	-mkimage -f -l $(JUMP_LIB) -v $(SHARED_REV) -a $(JUMP_BASE) -j $(JUMP_SIZE) -g $(JUMP_GOT) -- $(JUMP_AR) $(SHARED_LIBPATH) $(SHARED_REQ_LIBS) -lc $(SHARED_LIBGCC) -lc -dll-verbose 


$(JUMP_SA): $(JUMP_SO)
	mkstubs -f -l $(JUMP_LIB) -v $(SHARED_REV) -a $(JUMP_BASE) -j $(JUMP_SIZE) -g $(JUMP_GOT) -- $(JUMP_LIB)
	verify-shlib -l $(JUMP_SO) $(JUMP_SA)


shared_lib: $(JUMP_DIR) $(SHARED_LIB)


shared_stage1: shared_lib_clean 
	$(MAKE) $(JUMP_DIR)/jump.log

shared_stage2: $(JUMP_SA)


shared_lib_clean:
	$(RM) $(JUMP_SO) $(JUMP_SA) $(JUMP_AR) $(SHARED_OBJS)
	$(RM) $(JUMP_DIR)/*
	$(RM) size.nm verify.out ./mk_JUMP_SO_0 ./mk_JUMP_SO_1



# /***********************************************************************
# // installation
# ************************************************************************/

shared_lib_install: $(JUMP_SA) $(JUMP_SO)
	$(INSTALL) $^ $(INSTALL_LIBDIR)/
	$(RM) $(INSTALL_LIBDIR)/lib$(lib_name).so.$(major_shared)
	ln -s $(INSTALL_LIBDIR)/$(JUMP_SO) $(INSTALL_LIBDIR)/lib$(lib_name).so.$(major_shared)


