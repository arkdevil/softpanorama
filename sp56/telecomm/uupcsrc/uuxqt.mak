.AUTODEPEND

.PATH.obj = UUCICO

#		*Translator Definitions*
CC = bcc +UUXQT.CFG
TASM = TASM
TLINK = tlink


#		*Implicit Rules*
.c.obj:
  $(CC) -c {$< }

.cpp.obj:
  $(CC) -c {$< }

#		*List Macros*


EXE_dependencies =  \
  uuxqt.obj \
  arbmath.obj \
  arpadate.obj \
  dater.obj \
  expath.obj \
  fakeport.obj \
  getopt.obj \
  hlib.obj \
  hostable.obj \
  import.obj \
  koi8.obj \
  lib.obj \
  ndir.obj \
  pushpop.obj \
  readdir.obj \
  screen.obj \
  ssleep.obj \
  timestmp.obj \
  tzset.obj \
  usertabl.obj

#		*Explicit Rules*
uucico\uuxqt.exe: uuxqt.cfg $(EXE_dependencies)
  $(TLINK) /v/x/c/P-/L\BCC\LIB @&&|
c0l.obj+
uucico\uuxqt.obj+
uucico\arbmath.obj+
uucico\arpadate.obj+
uucico\dater.obj+
uucico\expath.obj+
uucico\fakeport.obj+
uucico\getopt.obj+
uucico\hlib.obj+
uucico\hostable.obj+
uucico\import.obj+
uucico\koi8.obj+
uucico\lib.obj+
uucico\ndir.obj+
uucico\pushpop.obj+
uucico\readdir.obj+
uucico\screen.obj+
uucico\ssleep.obj+
uucico\timestmp.obj+
uucico\tzset.obj+
uucico\usertabl.obj
uucico\uuxqt
		# no map file
cl.lib
|


#		*Individual File Dependencies*
uuxqt.obj: util\uuxqt.c 
	$(CC) -c util\uuxqt.c

arbmath.obj: lib\arbmath.c 
	$(CC) -c lib\arbmath.c

arpadate.obj: lib\arpadate.c 
	$(CC) -c lib\arpadate.c

dater.obj: lib\dater.c 
	$(CC) -c lib\dater.c

expath.obj: lib\expath.c 
	$(CC) -c lib\expath.c

fakeport.obj: lib\fakeport.c 
	$(CC) -c lib\fakeport.c

getopt.obj: lib\getopt.c 
	$(CC) -c lib\getopt.c

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

ndir.obj: lib\ndir.c 
	$(CC) -c lib\ndir.c

pushpop.obj: lib\pushpop.c 
	$(CC) -c lib\pushpop.c

readdir.obj: lib\readdir.c 
	$(CC) -c lib\readdir.c

screen.obj: uucico\screen.c 
	$(CC) -c uucico\screen.c

ssleep.obj: lib\ssleep.c 
	$(CC) -c lib\ssleep.c

timestmp.obj: lib\timestmp.c 
	$(CC) -c lib\timestmp.c

tzset.obj: lib\tzset.c 
	$(CC) -c lib\tzset.c

usertabl.obj: lib\usertabl.c 
	$(CC) -c lib\usertabl.c

#		*Compiler Configuration File*
uuxqt.cfg: uuxqt.mak
  copy &&|
-ml
-f-
-N
-v
-O
-k-
-wamb
-wamp
-wpro
-wdef
-wsig
-wnod
-w-sus
-wstv
-wucp
-wuse
-nUUCICO
-I\BCC\INCLUDE;LIB;\CT6\INCLUDE
-L\BCC\LIB
-P-.C
| uuxqt.cfg


