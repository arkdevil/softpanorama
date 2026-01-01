
YFLAG=-D
CFLAG=-c
OBJ=main.obj lex.obj pscript.obj

.c.obj:
	cl $(CFLAG) $*.c

.h.obj:
	cl $(CFLAG) $*.c

pscript.exe: $(OBJ)
	cl -Fepscript $(OBJ)

pscript.c: pscript.y
	pcyacc $(YFLAG) pscript.y



