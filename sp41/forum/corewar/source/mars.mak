.AUTODEPEND

#		*Translator Definitions*
CC = bcc +MARS.CFG
TASM = TASM
TLINK = tlink


#		*Implicit Rules*
.c.obj:
  $(CC) -c {$< }

.cpp.obj:
  $(CC) -c {$< }

#		*List Macros*


EXE_dependencies =  \
  mars.obj \
  stub.obj \
  cga.obj

#		*Explicit Rules*
mars.exe: mars.cfg $(EXE_dependencies)
  $(TLINK) /x/i/c/d/LC:\BC\LIB @&&|
c0c.obj+
mars.obj+
stub.obj+
cga.obj
mars
		# no map file
cc.lib+
graphics.lib
|


#		*Individual File Dependencies*
mars.obj: mars.cpp 

stub.obj: stub.asm 
	$(TASM) /MX /ZI /O STUB.ASM,STUB.OBJ

#		*Compiler Configuration File*
mars.cfg: mars.mak
  copy &&|
-mc
-f-
-C
-N
-v
-y
-G
-O
-Z
-d
-vi
-H=MARS.SYM
-wpin
-wamb
-wamp
-wasm
-wpro
-wcln
-wdef
-wsig
-wnod
-wstv
-wucp
-wuse
-IC:\BC\INCLUDE
-LC:\BC\LIB
-P-.C
| mars.cfg


