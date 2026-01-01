.AUTODEPEND

.PATH.obj = UUCICO

#		*Translator Definitions*
CC = bcc +UUCICO.CFG
TASM = TASM
TLINK = tlink


#		*Implicit Rules*
.c.obj:
  $(CC) -c {$< }

.cpp.obj:
  $(CC) -c {$< }

#		*List Macros*


EXE_dependencies =  \
  uucico.obj \
  arbmath.obj \
  arpadate.obj \
  checktim.obj \
  dater.obj \
  dcp.obj \
  dcpgpkt.obj \
  dcplib.obj \
  dcpstats.obj \
  dcpsys.obj \
  dcpxfer.obj \
  expath.obj \
  fossil.obj \
  getopt.obj \
  hlib.obj \
  hostable.obj \
  hostatus.obj \
  import.obj \
  lib.obj \
  modem.obj \
  mx5.obj \
  ndir.obj \
  pushpop.obj \
  screen.obj \
  script.obj \
  ssleep.obj \
  timestmp.obj \
  tzset.obj \
  ulib.obj \
  usertabl.obj \
  commfifo.obj

#		*Explicit Rules*
uucico\uucico.exe: uucico.cfg $(EXE_dependencies)
  $(TLINK) /v/x/c/P-/L\BCC\LIB @&&|
c0l.obj+
uucico\uucico.obj+
uucico\arbmath.obj+
uucico\arpadate.obj+
uucico\checktim.obj+
uucico\dater.obj+
uucico\dcp.obj+
uucico\dcpgpkt.obj+
uucico\dcplib.obj+
uucico\dcpstats.obj+
uucico\dcpsys.obj+
uucico\dcpxfer.obj+
uucico\expath.obj+
uucico\fossil.obj+
uucico\getopt.obj+
uucico\hlib.obj+
uucico\hostable.obj+
uucico\hostatus.obj+
uucico\import.obj+
uucico\lib.obj+
uucico\modem.obj+
uucico\mx5.obj+
uucico\ndir.obj+
uucico\pushpop.obj+
uucico\screen.obj+
uucico\script.obj+
uucico\ssleep.obj+
uucico\timestmp.obj+
uucico\tzset.obj+
uucico\ulib.obj+
uucico\usertabl.obj+
uucico\commfifo.obj
uucico\uucico
		# no map file
cl.lib
|


#		*Individual File Dependencies*
uucico.obj: uucico\uucico.c 
	$(CC) -c uucico\uucico.c

arbmath.obj: lib\arbmath.c 
	$(CC) -c lib\arbmath.c

arpadate.obj: lib\arpadate.c 
	$(CC) -c lib\arpadate.c

checktim.obj: uucico\checktim.c 
	$(CC) -c uucico\checktim.c

dater.obj: lib\dater.c 
	$(CC) -c lib\dater.c

dcp.obj: uucico\dcp.c 
	$(CC) -c uucico\dcp.c

dcpgpkt.obj: uucico\dcpgpkt.c 
	$(CC) -c uucico\dcpgpkt.c

dcplib.obj: uucico\dcplib.c 
	$(CC) -c uucico\dcplib.c

dcpstats.obj: uucico\dcpstats.c 
	$(CC) -c uucico\dcpstats.c

dcpsys.obj: uucico\dcpsys.c 
	$(CC) -c uucico\dcpsys.c

dcpxfer.obj: uucico\dcpxfer.c 
	$(CC) -c uucico\dcpxfer.c

expath.obj: lib\expath.c 
	$(CC) -c lib\expath.c

fossil.obj: uucico\fossil.c 
	$(CC) -c uucico\fossil.c

getopt.obj: lib\getopt.c 
	$(CC) -c lib\getopt.c

hlib.obj: lib\hlib.c 
	$(CC) -c lib\hlib.c

hostable.obj: lib\hostable.c 
	$(CC) -c lib\hostable.c

hostatus.obj: lib\hostatus.c 
	$(CC) -c lib\hostatus.c

import.obj: lib\import.c 
	$(CC) -c lib\import.c

lib.obj: lib\lib.c 
	$(CC) -c lib\lib.c

modem.obj: uucico\modem.c 
	$(CC) -c uucico\modem.c

mx5.obj: uucico\mx5.c 
	$(CC) -c uucico\mx5.c

ndir.obj: lib\ndir.c 
	$(CC) -c lib\ndir.c

pushpop.obj: lib\pushpop.c 
	$(CC) -c lib\pushpop.c

screen.obj: uucico\screen.c 
	$(CC) -c uucico\screen.c

script.obj: uucico\script.c 
	$(CC) -c uucico\script.c

ssleep.obj: lib\ssleep.c 
	$(CC) -c lib\ssleep.c

timestmp.obj: lib\timestmp.c 
	$(CC) -c lib\timestmp.c

tzset.obj: lib\tzset.c 
	$(CC) -c lib\tzset.c

ulib.obj: uucico\ulib.c 
	$(CC) -c uucico\ulib.c

usertabl.obj: lib\usertabl.c 
	$(CC) -c lib\usertabl.c

commfifo.obj: uucico\commfifo.asm 
	$(TASM) /MX /ZI /O UUCICO\COMMFIFO.ASM,UUCICO\COMMFIFO.OBJ

#		*Compiler Configuration File*
uucico.cfg: uucico.mak
  copy &&|
-ml
-f-
-ff-
-N
-v
-O
-k-
-h
-wpin
-wamb
-wamp
-wasm
-wpro
-wdef
-w-sus
-wstv
-wuse
-nUUCICO
-I\BCC\INCLUDE;LIB;UUCICO
-L\BCC\LIB
-P-.C
-Ff
| uucico.cfg


