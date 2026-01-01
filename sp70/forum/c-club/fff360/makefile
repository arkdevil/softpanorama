.AUTODEPEND

#               *Makefile for Turbo C++*
#                  created by PRJ2MAK

#		*Translator Definitions*
CC = tcc +FFF.CFG
TASM = TASM
TLINK = tlink


#		*Implicit Rules*
.c.obj:
  $(CC) -c {$< }

.cpp.obj:
  $(CC) -c {$< }

.asm.obj:
  $(TASM) {$< }


#		*List Macros*


EXE_dependencies =  \
  fff.obj \
  rootpath.obj \
  queue.obj \
  procarc.obj \
  proczip.obj \
  proczoo.obj \
  procarj.obj \
  proclha.obj \
  match.obj

#		*Explicit Rules*
fff.exe: fff.cfg $(EXE_dependencies)
  $(TLINK) /x/c @&&|
d:\tc\lib\c0s.obj+
fff.obj+
rootpath.obj+
queue.obj+
procarc.obj+
proczip.obj+
proczoo.obj+
procarj.obj+
proclha.obj+
match.obj
fff,
d:\tc\lib\cs.lib
|


#		*Individual File Dependencies*
fff.obj: fff.c 

rootpath.obj: rootpath.c 

queue.obj: queue.c 

procarc.obj: procarc.c 

proczip.obj: proczip.c 

proczoo.obj: proczoo.c 

procarj.obj: procarj.c 

proclha.obj: proclha.c 

match.obj: match.c 

#		*Compiler Configuration File*
fff.cfg: makefile.
  copy &&|
-f-
-G
-V
-vi-
-ID:\TC\INCLUDE
-LD:\TC\LIB
| fff.cfg


