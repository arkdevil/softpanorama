
OBJ=main.obj db4.obj lex.obj
CFLAG=-c
YFLAG=-D
LFLAG=-Fedb4

db4.exe:  $(OBJ)
	  cl $(LFLAG) $(OBJ)

main.obj: main.c
	  cl $(CFLAG) main.c

db4.obj:  db4.c const.h
	  cl $(CFLAG) db4.c

db4.c:    db4.y
	  pcyacc $(YFLAG) db4.y

lex.obj:  lex.c const.h	db4.h
	  cl $(CFLAG) lex.c


