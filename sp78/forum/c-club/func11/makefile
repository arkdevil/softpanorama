CC = gcc
CFLAGS = #-g
OFLAGS = -O2
LDFLAGS = -lm
IDIRS =
LDIRS =

testfunc :testfunc.o funcion.o
	$(CC) $(OFLAGS) -o testfunc testfunc.o funcion.o $(LDIRS) $(LDFLAGS)
	coff2exe -s /c/djgpp/bin/go32.exe testfunc
	-del testfunc.
	-dir testfunc.*

testfunc.o:testfunc.c
	$(CC) $(OFLAGS) -c testfunc.c $(CFLAGS) $(IDIRS)

funcion.o:funcion.c
	$(CC) $(OFLAGS) -c funcion.c $(CFLAGS) $(IDIRS)
