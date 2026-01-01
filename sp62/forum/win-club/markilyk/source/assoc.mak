.AUTODEPEND

BIN = C:\BC\BIN
CC = $(BIN)\bcc +ASSOC.CFG
TASM = $(BIN)\tasm
TLIB = $(BIN)\tlib
TLINK = $(BIN)\tlink
LIBDIR = C:\BC\LIB
INCLUDEDIR = C:\BC\INCLUDE
LIBS = cws import


.c.obj:
  $(CC) -c {$< } >assoc.lst

.asm.obj:
  $(TASM) -w2 {$< }  


EXE_dependencies =  \
 assoc.obj \
 assoc.def

assoc.exe: assoc.cfg $(EXE_dependencies) clnstub.exe
  $(TLINK) /x/c/P-/Twe/L$(LIBDIR) @&&|
c0ws.obj+
assoc.obj
assoc
		
+
$(LIBS)
assoc.def
|
  RC  assoc.exe


assoc.obj: assoc.cfg assoc.c 

clnstub.exe: clnstub.obj
  $(TLINK) /x/c/Tde clnstub.obj

assoc.cfg: assoc.mak
  copy &&|
-2
-f-
-ff-
-G
-O
-Og
-Oe
-Om
-Ov
-Ol
-Ob
-Op
-Oi
-Z
-k-
-d
-WE
-vi-
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
-weas
-wpre
-I$(INCLUDEDIR)
-L$(LIBDIR)
| assoc.cfg


