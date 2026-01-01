.AUTODEPEND

.PATH.obj = OBJ

#		*Translator Definitions*
CC = bcc +RMAIL.CFG
TASM = TASM
TLINK = tlink


#		*Implicit Rules*
.c.obj:
  $(CC) -c {$< }

.cpp.obj:
  $(CC) -c {$< }

#		*List Macros*


EXE_dependencies =  \
  rmail.obj \
  address.obj \
  arbmath.obj \
  arpadate.obj \
  dater.obj \
  fakeport.obj \
  fakescr.obj \
  getopt.obj \
  getseq.obj \
  head.obj \
  hlib.obj \
  hostable.obj \
  import.obj \
  koi8.obj \
  lib.obj \
  lock.obj \
  ndir.obj \
  pcmail.obj \
  pushpop.obj \
  ssleep.obj \
  stat.obj \
  timestmp.obj \
  tzset.obj \
  usertabl.obj \
  volapyuk.obj

#		*Explicit Rules*
obj\rmail.exe: rmail.cfg $(EXE_dependencies)
  $(TLINK) /v/x/c/P-/L\BCC\LIB @&&|
c0s.obj+
obj\rmail.obj+
obj\address.obj+
obj\arbmath.obj+
obj\arpadate.obj+
obj\dater.obj+
obj\fakeport.obj+
obj\fakescr.obj+
obj\getopt.obj+
obj\getseq.obj+
obj\head.obj+
obj\hlib.obj+
obj\hostable.obj+
obj\import.obj+
obj\koi8.obj+
obj\lib.obj+
obj\lock.obj+
obj\ndir.obj+
obj\pcmail.obj+
obj\pushpop.obj+
obj\ssleep.obj+
obj\stat.obj+
obj\timestmp.obj+
obj\tzset.obj+
obj\usertabl.obj+
obj\volapyuk.obj
obj\rmail
		# no map file
cs.lib
|


#		*Individual File Dependencies*
rmail.obj: rmail\rmail.c 
	$(CC) -c rmail\rmail.c

address.obj: rmail\address.c 
	$(CC) -c rmail\address.c

arbmath.obj: lib\arbmath.c 
	$(CC) -c lib\arbmath.c

arpadate.obj: lib\arpadate.c 
	$(CC) -c lib\arpadate.c

dater.obj: lib\dater.c 
	$(CC) -c lib\dater.c

fakeport.obj: lib\fakeport.c 
	$(CC) -c lib\fakeport.c

fakescr.obj: lib\fakescr.c 
	$(CC) -c lib\fakescr.c

getopt.obj: lib\getopt.c 
	$(CC) -c lib\getopt.c

getseq.obj: lib\getseq.c 
	$(CC) -c lib\getseq.c

head.obj: rmail\head.c 
	$(CC) -c rmail\head.c

hlib.obj: lib\hlib.c 
	$(CC) -c lib\hlib.c

hostable.obj: lib\hostable.c 
	$(CC) -c lib\hostable.c

import.obj: lib\import.c 
	$(CC) -c lib\import.c

koi8.obj: rmail\koi8.c 
	$(CC) -c rmail\koi8.c

lib.obj: lib\lib.c 
	$(CC) -c lib\lib.c

lock.obj: rmail\lock.c 
	$(CC) -c rmail\lock.c

ndir.obj: lib\ndir.c 
	$(CC) -c lib\ndir.c

pcmail.obj: rmail\pcmail.c 
	$(CC) -c rmail\pcmail.c

pushpop.obj: lib\pushpop.c 
	$(CC) -c lib\pushpop.c

ssleep.obj: lib\ssleep.c 
	$(CC) -c lib\ssleep.c

stat.obj: rmail\stat.c 
	$(CC) -c rmail\stat.c

timestmp.obj: lib\timestmp.c 
	$(CC) -c lib\timestmp.c

tzset.obj: lib\tzset.c 
	$(CC) -c lib\tzset.c

usertabl.obj: lib\usertabl.c 
	$(CC) -c lib\usertabl.c

volapyuk.obj: rmail\volapyuk.c 
	$(CC) -c rmail\volapyuk.c

#		*Compiler Configuration File*
rmail.cfg: rmail.mak
  copy &&|
-f-
-N
-v
-O
-k-
-h
-wamb
-wamp
-wasm
-wpro
-wdef
-wstv
-wuse
-nOBJ
-I\BCC\INCLUDE;LIB;RMAIL
-L\BCC\LIB
-P-.C
-Ff
| rmail.cfg


