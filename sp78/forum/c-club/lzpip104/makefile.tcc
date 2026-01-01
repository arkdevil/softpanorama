CC	= tcc
CFLAGS	= -mc -G -O -Z -d -f- -w -v -y
AS	= tasm
AFLAGS	= /ml /w2 /dDYN_ALLOC

OBJZIP	= dzmain.obj lzerror.obj crc32.obj diszip.obj\
	zippipe.obj deflate.obj trees.obj bits.obj match.obj

OBJLZW	= doz.obj lzerror.obj compress.obj unlzw.obj

.c.obj:
	$(CC) $(CFLAGS) -c $<

.asm.obj:
	$(AS) $(AFLAGS) $<

all:	dogzip.exe	doz.exe

clean:
	command /c if exist *.bak del *.bak
	command /c if exist *.obj del *.obj
	command /c if exist *.exe del *.exe

doz.exe:	$(OBJLZW)
	$(CC) $(CFLAGS) -e$* $(OBJLZW)

dogzip.exe:	$(OBJZIP)
	command /c if exist doz.obj ren doz.obj doz.o
	$(CC) $(CFLAGS) -e$* b*.obj crc*.obj d*.obj l*.obj m*.obj t*.obj z*.obj
	command /c if exist doz.o ren doz.o doz.obj

lzerror.obj:	lzerror.c

doz.obj:	doz.c      modern.h lzpipe.h
compress.obj:	compress.c modern.h lzpipe.h lzwbits.h
unlzw.obj:	unlzw.c    modern.h lzpipe.h lzwbits.h

dzmain.obj:	dzmain.c   modern.h lzpipe.h
diszip.obj:	diszip.c   modern.h lzpipe.h stdinc.h zipdefs.h crc32.h
zippipe.obj:	zippipe.c  modern.h lzpipe.h zalloc.h zipdefs.h zipguts.h oscode.h crc32.h
deflate.obj:	deflate.c  modern.h lzpipe.h zalloc.h zipdefs.h zipguts.h
trees.obj:	trees.c    modern.h lzpipe.h zalloc.h zipdefs.h zipguts.h
bits.obj:	bits.c     modern.h lzpipe.h zalloc.h zipdefs.h zipguts.h stdinc.h
crc32.obj:	crc32.c    modern.h crc32.h
match.obj:	match.asm
