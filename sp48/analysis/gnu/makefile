# History:25,17

AFLAGS = /mx
CFLAGS = -ms -M

.c.obj:
	tcc $(CFLAGS) -DDEBUGGER=1 -DTOPLINEINFO=1 -DSOURCE_LIST -c $*
	mv $*.obj d$*.obj
	tcc $(CFLAGS) -DDEBUGGER=0 -DTOPLINEINFO=0 -c $*

.asm.obj:
	tasm $(AFLAGS) /DDEBUGGER=1 /DTOPLINEINFO=1 $*;
	mv $*.obj d$*.obj
	tasm $(AFLAGS) /DDEBUGGER=0 /DTOPLINEINFO=0 $*;

OBJS =\
	control.obj\
	dalloc.obj\
	debug.obj\
	doutils.obj\
	exphdlr.obj\
	graphics.obj\
	grprot.obj\
	mono.obj\
	mswitch.obj\
	npx.obj\
	paging.obj\
	syms.obj\
	tables.obj\
	unassmbl.obj\
	utils.obj\
	valloc.obj\
	vga.obj\
	wild.obj\
	xms.obj

all : go32.exe stub.exe

stub.exe: stub.c
	tcc stub.c
	tdstrip stub

go32.exe : $(OBJS) go32.lnk makefile
	tlink /c /v /s /m @go32.lnk
	tlink /c /v /s /m @debug32.lnk


utest.exe : utest.obj unassmbl.obj
	tcc -v -M utest.obj unassmbl.obj

# DEPENDENCIES

debug.obj : build.h types.h gdt.h tss.h utils.h unassmbl.h syms.h paging.h npx.h mono.h

exphdlr.obj : build.h types.h gdt.h idt.h tss.h utils.h paging.h npx.h mono.h

control.obj : build.h types.h gdt.h idt.h tss.h valloc.h utils.h syms.h graphics.h mono.h

graphics.obj : build.h types.h paging.h graphics.h tss.h gdt.h

paging.obj : build.h types.h paging.h graphics.h tss.h gdt.h valloc.h dalloc.h utils.h aout.h mono.h

syms.obj : build.h types.h syms.h tss.h stab.h stab.def aout.h utils.h

unassmbl.obj : build.h types.h gdt.h idt.h tss.h utils.h unassmbl.h syms.h mono.h

utils.obj : build.h types.h tss.h gdt.h utils.h npx.h

valloc.obj : build.h types.h valloc.h xms.h mono.h

xms.obj : xms.h

dalloc.obj : build.h types.h valloc.h dalloc.h mono.h

mono.obj : mono.h

doutils.obj : build.inc segdefs.inc tss.inc gdt.inc idt.inc

mswitch.obj : build.inc segdefs.inc tss.inc gdt.inc idt.inc

tables.obj : build.inc segdefs.inc tss.inc gdt.inc idt.inc

vga.obj : segdefs.inc

grprot.obj : build.inc segdefs.inc tss.inc gdt.inc idt.inc

npx.obj : build.inc segdefs.inc tss.inc gdt.inc idt.inc
