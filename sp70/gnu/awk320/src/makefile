#       AWK - A Pattern Scanning and Processing Language
#
# Copyright (C) 1988, 1989, 1990 by Rob Duff
# All rights reserved
#

COBJ = awk.obj awkexec.obj awkpat.obj awkmath.obj awkdebug.obj \
       awkfile.obj awkcvt.obj awkgen.obj awkyacc.obj awklex.obj \
       awkfind.obj yylex.obj yymapc.obj yywrap.obj
AOBJ = awkutil.obj awkrand.obj setargv.obj awkfstr.obj awkatol.obj

CMODEL=s
AMODEL=SMALL
CC=tcc
CFLAGS=-m$(CMODEL) -v -O -Z -w#-rch
AS=tasm
AFLAGS=/D__$(AMODEL)__/ml/Zi/e
LD=link
LDFLAGS=#/v

CRT0=c:\tc\lib\c0$(CMODEL).obj
CLIB=c:\tc\lib\emu.lib+c:\tc\lib\math$(CMODEL).lib+c:\tc\lib\c$(CMODEL).lib

awk.exe: $(COBJ) $(AOBJ)
	$(LD) $(LDFLAGS)/m/v $(CRT0) $(COBJ) $(AOBJ),AWK,AWK,$(CLIB);

asm: $(AOBJ)
	rem

test.exe: test.obj awkfstr.obj
	$(LD) $(LDFLAGS)/M/V $(CRT0) test awkfstr,test,test,$(CLIB)

awkrand.obj:    awkrand.asm

awk.obj:        awk.c awk.h
awkpat.obj:     awkpat.c awk.h
awkgen.obj:     awkgen.c awk.h
awkcvt.obj:     awkcvt.c awk.h
awklex.obj:     awklex.c awk.h awkyacc.c
awkfile.obj:    awkfile.c awk.h
awkexec.obj:    awkexec.c awk.h
awkmath.obj:    awkmath.c awk.h
awkutil.obj:    awkutil.c awk.h
awkyacc.obj:    awkyacc.c awk.h
awkdebug.obj:   awkdebug.c awk.h

yylex.obj:      yylex.c yylex.h
yymapc.obj:     yymapc.c
yywrap.obj:     yywrap.c
yymain.obj:     yymain.c
yyerror.obj:    yyerror.c

awkfind.obj:    awkfind.c
awkfstr.obj:    awkfstr.asm
awkatol.obj:    awkatol.asm
setargv.obj:    setargv.asm

awkyacc.c:      awkyacc.y               # yacc uses \lib\yypars.c
	yacc    -f -o awkyacc.c -h awkyacc.h awkyacc.y
awklex.c:       awklex.l
	lex     -o awklex.c awklex.l

awk.arc:
	pkarc -u awk

awksrc.arc: awk.exe
	pkarc -oct -u awksrc *.h *.l *.y *.c awk*.asm *.dif *.prj makefile   

pcawk.arc:
	pkarc -oct -u pcawk awk.exe *.doc read.me demo\*.*

