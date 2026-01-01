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
  $(CC) -c {$< } >assocsrv.lst

.asm.obj:
  $(TASM) -w2 {$< }  

Link_Exclude =  assocsrv.res

Link_Include =  \
 assocsrv.obj \
 init.obj \
 handler.obj \
 callback.obj \
 utils.obj \
 assocsrv.def

assocsrv.exe: assocsrv.cfg $(Link_Include) $(Link_Exclude) srvstub.exe
  $(TLINK) /x/c/P-/Twe/L$(LIBDIR) @&&|
c0ws.obj+
assocsrv.obj+
init.obj+
handler.obj+
callback.obj+
utils.obj
assocsrv
		# no map file
+
$(LIBS)
assocsrv.def
|
  RC  assocsrv.res assocsrv.exe


assocsrv.obj: assocsrv.cfg assocsrv.c 

init.obj: assocsrv.cfg init.c 

handler.obj: assocsrv.cfg handler.c 

callback.obj: assocsrv.cfg callback.c 

utils.obj: assocsrv.cfg utils.c 

assocsrv.res: assocsrv.cfg assocsrv.rc 
	RC -R -I$(INCLUDEDIR) -FO assocsrv.res ASSOCSRV.RC

srvstub.exe: srvstub.obj
  $(TLINK) /x/c/Tde srvstub.obj

assocsrv.cfg: assocsrv.mak
  copy &&|
-2
-f-
-ff-
-C
-O
-Oe
-Ob
-Z
-k-
-d
-WE
-vi-
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
-w-stu
-w-use
-w-ucp
-weas
-wpre
-I$(INCLUDEDIR)
-L$(LIBDIR)
-P-.C
| assocsrv.cfg


