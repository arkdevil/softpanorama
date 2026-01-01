
YFLAG=-D
CFLAG=-c
OBJ=main.obj lex.obj ht.obj


ht.exe: $(OBJ)
	cl -Feht $(OBJ)

ht.c:   ht.y
	pcyacc $(YFLAG) ht.y

lex.c:  ht.h

.c.obj:
	cl $(CFLAG) $*.c


