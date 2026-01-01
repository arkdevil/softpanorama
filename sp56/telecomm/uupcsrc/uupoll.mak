.AUTODEPEND

.PATH.obj = OBJ

#		*Translator Definitions*
CC = bcc +UUPOLL.CFG
TASM = TASM
TLINK = tlink


#		*Implicit Rules*
.c.obj:
  $(CC) -c {$< }

.cpp.obj:
  $(CC) -c {$< }

#		*List Macros*


EXE_dependencies =  \
  uupoll.obj \
  arpadate.obj \
  dater.obj \
  fakeport.obj \
  fakescr.obj \
  getopt.obj \
  hlib.obj \
  hostable.obj \
  lib.obj \
  ndir.obj \
  ssleep.obj \
  timestmp.obj \
  tzset.obj

#		*Explicit Rules*
obj\uupoll.exe: uupoll.cfg $(EXE_dependencies)
  $(TLINK) /v/x/c/P-/L\BCC\LIB @&&|
c0s.obj+
obj\uupoll.obj+
obj\arpadate.obj+
obj\dater.obj+
obj\fakeport.obj+
obj\fakescr.obj+
obj\getopt.obj+
obj\hlib.obj+
obj\hostable.obj+
obj\lib.obj+
obj\ndir.obj+
obj\ssleep.obj+
obj\timestmp.obj+
obj\tzset.obj
obj\uupoll
		# no map file
cs.lib
|


#		*Individual File Dependencies*
uupoll.obj: util\uupoll.c 
	$(CC) -c util\uupoll.c

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

hlib.obj: lib\hlib.c 
	$(CC) -c lib\hlib.c

hostable.obj: lib\hostable.c 
	$(CC) -c lib\hostable.c

lib.obj: lib\lib.c 
	$(CC) -c lib\lib.c

ndir.obj: lib\ndir.c 
	$(CC) -c lib\ndir.c

ssleep.obj: lib\ssleep.c 
	$(CC) -c lib\ssleep.c

timestmp.obj: lib\timestmp.c 
	$(CC) -c lib\timestmp.c

tzset.obj: lib\tzset.c 
	$(CC) -c lib\tzset.c

#		*Compiler Configuration File*
uupoll.cfg: uupoll.mak
  copy &&|
-f-
-j10
-g10
-N
-v
-O
-k-
-wpin
-wamb
-wamp
-wpro
-wdef
-wnod
-w-sus
-wstv
-wucp
-wuse
-nOBJ
-I\BCC\INCLUDE;LIB
-L\BCC\LIB
-P-.C
| uupoll.cfg


