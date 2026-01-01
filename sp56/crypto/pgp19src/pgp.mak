.AUTODEPEND

#		*Translator Definitions*
CC = bcc +PGP.CFG
TASM = F:\TASM\TASM
TLINK = tlink


#		*Implicit Rules*
.c.obj:
  $(CC) -c {$< }

.cpp.obj:
  $(CC) -c {$< }

#		*List Macros*


EXE_dependencies =  \
  pgp.obj \
  basslib.obj \
  basslib2.obj \
  keygen.obj \
  lfsr.obj \
  lzh.obj \
  md4.obj \
  memmgr.obj \
  random.obj \
  rsaio.obj \
  rsalib.obj \
  fprims.obj

#		*Explicit Rules*
pgp.exe: pgp.cfg $(EXE_dependencies)
  $(TLINK) /v/x/c/P-/LF:\BCC\LIB;F:\TEGL\LIB @&&|
c0s.obj+
pgp.obj+
basslib.obj+
basslib2.obj+
keygen.obj+
lfsr.obj+
lzh.obj+
md4.obj+
memmgr.obj+
random.obj+
rsaio.obj+
rsalib.obj+
fprims.obj
pgp
		# no map file
cs.lib
|


#		*Individual File Dependencies*
pgp.obj: pgp.c 

basslib.obj: basslib.c 

basslib2.obj: basslib2.c 

keygen.obj: keygen.c 

lfsr.obj: lfsr.c 

lzh.obj: lzh.c 

md4.obj: md4.c 

memmgr.obj: memmgr.c 

random.obj: random.c 

rsaio.obj: rsaio.c 

rsalib.obj: rsalib.c 

fprims.obj: fprims.asm 
	$(TASM) /MX /ZI /O FPRIMS.ASM,FPRIMS.OBJ

#		*Compiler Configuration File*
pgp.cfg: pgp.mak
  copy &&|
-f-
-ff-
-N
-G
-O
-Z
-H=PGP.SYM
-wamp
-wasm
-wpro
-wdef
-wnod
-w-sus
-wstv
-wuse
-IF:\BCC\INCLUDE;F;\TEGL\INCLUDE
-LF:\BCC\LIB;F:\TEGL\LIB
-P-.C
| pgp.cfg


