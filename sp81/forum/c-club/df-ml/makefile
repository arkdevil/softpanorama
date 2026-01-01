LD=rundos c
LFLAGS=-tg
CC=rundos cc 
CFLAGS=-I. # -I/aztec4.1d/include
AS=rundos as

INCLUDE=


OBJS=	intr24.o dosintr.o df.o getlol.o getopt.o

df.exe: $(OBJS)
	$(LD) $(LFLAGS) -o $@ $^ 

%.o:	%.c
	$(CC) $(CFLAGS) -o $@ $<

%.o:	%.asm
	$(AS) -o $@ $<

df.o:	lstolist.h
intr24.o: intr24.asm
getlol.o:	lstolist.h

dist:
	-rm *.o *.dbg *.sym

clean:	dist
	-rm df.exe
