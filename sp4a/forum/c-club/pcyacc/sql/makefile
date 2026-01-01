
YFLAG=
CFLAG=-c
OBJ=main.obj lex.obj sql.obj

.c.obj:
	tcc $(CFLAG) $*.c

.h.obj:
	tcc $(CFLAG) $*.c

sql.exe: $(OBJ)
	tcc -esql.exe $(OBJ)

sql.c: sql.y
	pcyacc $(YFLAG) sql.y



