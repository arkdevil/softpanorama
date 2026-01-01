uuprep.exe: uuprep.o
	gcc -Wall -O2 -o uuprep.exe uuprep.o

uuprep.o: uuprep.c
	gcc -Wall -O2 -c uuprep.c
