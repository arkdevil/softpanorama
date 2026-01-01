CFLAGs=

m4.exe:		m4.o eval.o gettoken.o
		c -g m4.o eval.o gettoken.o

m4.o:		m4.c m4.h
		c -c $(CFLAGS) m4.c

eval.o:		eval.c m4.h
		c -c $(CFLAGS) eval.c

gettoken.o:	gettoken.c m4.h
		c -c $(CFLAGS) gettoken.c

clean:
		del m4.exe
		del *.o
		del *.sym
		del *.bak
		del *.dbg
