CC	= cc
CFLAGS	= -O -s

OBJZIP	= dzmain.o lzerror.o crc32.o diszip.o\
	zippipe.o deflate.o trees.o bits.o

OBJLZW	= doz.o lzerror.o compress.o unlzw.o

.c.o:
	$(CC) $(CFLAGS) -c $<

all:	dogzip	doz

clean:
	rm *.o *.b doz dogzip core

doz:	$(OBJLZW)
	$(CC) $(CFLAGS) -o $* $(OBJLZW)

dogzip:	$(OBJZIP)
	$(CC) $(CFLAGS) -o $* $(OBJZIP)

lzerror.o:	lzerror.c

doz.o:		doz.c      modern.h lzpipe.h
compress.o:	compress.c modern.h lzpipe.h lzwbits.h
unlzw.o:	unlzw.c    modern.h lzpipe.h lzwbits.h

dzmain.o:	dzmain.c   modern.h lzpipe.h
diszip.o:	diszip.c   modern.h lzpipe.h stdinc.h zipdefs.h crc32.h
zippipe.o:	zippipe.c  modern.h lzpipe.h zalloc.h zipdefs.h zipguts.h oscode.h crc32.h
deflate.o:	deflate.c  modern.h lzpipe.h zalloc.h zipdefs.h zipguts.h
trees.o:	trees.c    modern.h lzpipe.h zalloc.h zipdefs.h zipguts.h
bits.o:		bits.c     modern.h lzpipe.h zalloc.h zipdefs.h zipguts.h stdinc.h
crc32.o:	crc32.c    modern.h crc32.h
