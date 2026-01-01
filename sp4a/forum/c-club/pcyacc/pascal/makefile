
YFLAG=
CFLAG=-c -AS
OBJ=main.obj lex.obj pascal.obj

.c.obj:
        	cl $(CFLAG) $*.c

pascal.exe:     $(OBJ)

        	cl -Fbpascal -Fepascal -Lp $(OBJ)

pascal.c:       pascal.y

        	pcyacc $(YFLAG) pascal.y




