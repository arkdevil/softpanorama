
YFLAG=
CFLAG=-c
OBJ=main.obj lex.obj ansic.obj

.c.obj:
	cl $(CFLAG) $*.c

.h.obj:
	cl $(CFLAG) $*.c

acc.exe: $(OBJ)
	 cl -Feacc $(OBJ)

ansic.c: ansic.y
	 pcyacc $(YFLAG) ansic.y



