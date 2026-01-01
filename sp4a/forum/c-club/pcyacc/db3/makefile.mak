
# Borland Turbo C example build

OBJ=main.obj db3.obj lex.obj
CFLAG=-c -ms -I\include\b
YFLAG=-D
LFLAG=

db3.exe: $(OBJ)
	 tlink $(LFLAG) \lib\c0s $(OBJ),db3,,\lib\cs 

main.obj: main.c
	  tcc $(CFLAG) main.c

db3.obj:  db3.c const.h
	  tcc $(CFLAG) db3.c

db3.c:    db3.y
	  pcyacc $(YFLAG) db3.y

lex.obj:  lex.c const.h	db3.h
	  tcc $(CFLAG) lex.c


