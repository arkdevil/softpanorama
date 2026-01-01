.AUTODEPEND
.NOSWAP
.SILENT

NAME		= SETDATE

.PATH.h 	= ..\TCINC
.PATH.obj	= ..
.PATH.map	= ..
.PATH.lib	= ..\TCLIB
.PATH.exe	= ..

#DEBUG_L = /v /d /s
#DEBUG_C = -M -v -y

ASM	= nxtevar.asm envpkg.asm
ASW	= /ml /m5 /n /w2 /z /q /t
AOBJS	= nxtevar.obj envpkg.obj

H	= .\$(NAME).h
C	= $(NAME).c
CSW	= -1  -S- -B- -C -G -I$(.PATH.h);..\H; -K -L\DEV\C\TCLIB -N- -O -X -Z -a -b -c -d -k- -ms -n\DEV\C -r -u -w
COBJS	= $(NAME).obj

LSW	= /3 /m /s /ye
$(NAME).exe: $(COBJS) $(AOBJS) $(NAME).lnk
	tlink $(DEBUG_L) $(LSW) @$(NAME).lnk

.c.obj:
	echo Kompilerar $<
	tcc $(CSW) $(DEBUG_C) $< >e

.asm.obj:
	echo Assemblerar $<
	tasm $(ASW) $<, $(.PATH.obj)\$& >e

$(COBJS): $(C)

$(AOBJS): $(ASM)
