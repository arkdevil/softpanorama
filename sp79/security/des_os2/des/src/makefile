CFLAGS=-g -O -DLITTLE_ENDIAN -DIBMPC -Zexe
# radlogin has been taken out for OS/2; no multiuser-system!
all: descalc descycle descert certify benchmark des uuencode uudecode

des: main.o des.o getpass.o misc.o
	gcc $(CFLAGS) -o des main.o des.o getpass.o misc.o

benchmark: benchmark.o des.o
	gcc $(CFLAGS) -o benchmark benchmark.o des.o

radlogin: radlogin.o des.o
	gcc $(CFLAGS) -o radlogin radlogin.o des.o

descert: descert.o des.o
	gcc $(CFLAGS) -o descert descert.o des.o

descalc: descalc.o des.o
	gcc $(CFLAGS) -o descalc descalc.o des.o

descycle: descycle.o des.o
	gcc $(CFLAGS) -o descycle descycle.o des.o

certify: descert testdata
	descert < testdata
	touch certify

radlogin.o: radlogin.c
	gcc $(CFLAGS) -c -O -DUTMP_FILE=\"/etc/utmp\" radlogin.c

uuencode: uuencode.o
	gcc $(CFLAGS) -o uuencode uuencode.o

uudecode: uudecode.o
	gcc $(CFLAGS) -o uudecode uudecode.o

.c.o:
	gcc $(CFLAGS) -c $<

clean:
	-del descalc descycle descert certify radlogin benchmark des *.o 2>nul:
	-del uuencode uudecode *.exe *~ 2>nul:
