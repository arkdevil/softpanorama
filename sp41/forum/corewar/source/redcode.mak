.AUTODEPEND

#		*Translator Definitions*
CC = bcc +REDCODE.CFG
TASM = TASM
TLINK = tlink


#		*Implicit Rules*
.c.obj:
  $(CC) -c {$< }

.cpp.obj:
  $(CC) -c {$< }

#		*List Macros*


EXE_dependencies =  \
  stub.obj \
  redcode.obj

#		*Explicit Rules*
redcode.exe: redcode.cfg $(EXE_dependencies)
  $(TLINK) /v/x/c/d/P-/LC:\BC\LIB @&&|
c0t.obj+
stub.obj+
redcode.obj
redcode
		# no map file
cs.lib
|


#		*Individual File Dependencies*
stub.obj: stub.asm 
	$(TASM) /MX /ZI /O STUB.ASM,STUB.OBJ

redcode.obj: redcode.c 

#		*Compiler Configuration File*
redcode.cfg: redcode.mak
  copy &&|
-mt
-f-
-C
-v
-y
-O
-Z
-k-
-d
-H=REDCODE.SYM
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
| redcode.cfg


