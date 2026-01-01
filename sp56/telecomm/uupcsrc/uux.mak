.AUTODEPEND

.PATH.obj = OBJ

#		*Translator Definitions*
CC = bcc +UUX.CFG
TASM = TASM
TLINK = tlink


#		*Implicit Rules*
.c.obj:
  $(CC) -c {$< }

.cpp.obj:
  $(CC) -c {$< }

#		*List Macros*


EXE_dependencies =  \
  uux.obj \
  arbmath.obj \
  arpadate.obj \
  dater.obj \
  expath.obj \
  fakescr.obj \
  fakeslep.obj \
  getopt.obj \
  getseq.obj \
  hlib.obj \
  hostable.obj \
  hostatus.obj \
  import.obj \
  lib.obj \
  ndir.obj \
  pushpop.obj \
  timestmp.obj \
  usertabl.obj \
  tzset.obj

#		*Explicit Rules*
obj\uux.exe: uux.cfg $(EXE_dependencies)
  $(TLINK) /v/x/c/P-/L\BCC\LIB @&&|
c0s.obj+
obj\uux.obj+
obj\arbmath.obj+
obj\arpadate.obj+
obj\dater.obj+
obj\expath.obj+
obj\fakescr.obj+
obj\fakeslep.obj+
obj\getopt.obj+
obj\getseq.obj+
obj\hlib.obj+
obj\hostable.obj+
obj\hostatus.obj+
obj\import.obj+
obj\lib.obj+
obj\ndir.obj+
obj\pushpop.obj+
obj\timestmp.obj+
obj\usertabl.obj+
obj\tzset.obj
obj\uux
		# no map file
cs.lib
|


#		*Individual File Dependencies*
uux.obj: util\uux.c 
	$(CC) -c util\uux.c

arbmath.obj: lib\arbmath.c 
	$(CC) -c lib\arbmath.c

arpadate.obj: lib\arpadate.c 
	$(CC) -c lib\arpadate.c

dater.obj: lib\dater.c 
	$(CC) -c lib\dater.c

expath.obj: lib\expath.c 
	$(CC) -c lib\expath.c

fakescr.obj: lib\fakescr.c 
	$(CC) -c lib\fakescr.c

fakeslep.obj: lib\fakeslep.c 
	$(CC) -c lib\fakeslep.c

getopt.obj: lib\getopt.c 
	$(CC) -c lib\getopt.c

getseq.obj: lib\getseq.c 
	$(CC) -c lib\getseq.c

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

ndir.obj: lib\ndir.c 
	$(CC) -c lib\ndir.c

pushpop.obj: lib\pushpop.c 
	$(CC) -c lib\pushpop.c

timestmp.obj: lib\timestmp.c 
	$(CC) -c lib\timestmp.c

usertabl.obj: lib\usertabl.c 
	$(CC) -c lib\usertabl.c

tzset.obj: lib\tzset.c 
	$(CC) -c lib\tzset.c

#		*Compiler Configuration File*
uux.cfg: uux.mak
  copy &&|
-f-
-N
-v
-O
-k-
-wpin
-wamb
-wamp
-wasm
-wpro
-wcln
-wdef
-wsig
-wnod
-w-sus
-wstv
-wucp
-wuse
-nOBJ
-I\BCC\INCLUDE;LIB
-L\BCC\LIB
-P-.C
| uux.cfg


