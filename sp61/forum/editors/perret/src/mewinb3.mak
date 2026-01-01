.AUTODEPEND

# This makefile for Borland C 3.0 compiles MEWIN.EXE (with source-level
# debugging information which you may want to remove with TDSTRIP)
# Be advised that you need to change the path of the INCLUDE and LIB
# directories to match their real location on your computer.

#		*Translator Definitions*
CC = bcc +MEWIN.CFG
TASM = TASM
TLINK = tlink
LIBPATH = C:\BC30\LIB
INCLUDEPATH = C:\BC30\INCLUDE

#		*Implicit Rules*
.c.obj:
  $(CC) -c {$< }

.cpp.obj:
  $(CC) -c {$< }

#		*List Macros*
Link_Exclude =  \
  mewin.res

Link_Include =  \
  basic.obj \
  bind.obj \
  buffer.obj \
  char.obj \
  crypt.obj \
  display.obj \
  dolock.obj \
  eval.obj \
  exec.obj \
  file.obj \
  fileio.obj \
  input.obj \
  isearch.obj \
  line.obj \
  lock.obj \
  main.obj \
  mouse.obj \
  random.obj \
  region.obj \
  screen.obj \
  search.obj \
  window.obj \
  word.obj \
  mswdisp.obj \
  mswdrv.obj \
  mswemacs.obj \
  mswexec.obj \
  mswfile.obj \
  mswfont.obj \
  mswinput.obj \
  mswmem.obj \
  mswmenu.obj \
  mswsys.obj \
  mewin.def

#		*Explicit Rules*
MEWIN.exe: MEWIN.cfg $(Link_Include) $(Link_Exclude)
  $(TLINK) /v/s/c/Twe/P-/L$(LIBPATH) @&&|
c0wl.obj+
basic.obj+
bind.obj+
buffer.obj+
char.obj+
crypt.obj+
display.obj+
dolock.obj+
eval.obj+
exec.obj+
file.obj+
fileio.obj+
input.obj+
isearch.obj+
line.obj+
lock.obj+
main.obj+
mouse.obj+
random.obj+
region.obj+
screen.obj+
search.obj+
window.obj+
word.obj+
mswdisp.obj+
mswdrv.obj+
mswemacs.obj+
mswexec.obj+
mswfile.obj+
mswfont.obj+
mswinput.obj+
mswmem.obj+
mswmenu.obj+
mswsys.obj
MEWIN,MEWIN
mathwl.lib+
import.lib+
cwl.lib
mewin.def
|
  RC -T mewin.res MEWIN.exe


#		*Individual File Dependencies*
mewin.res: mewin.rc mswrid.h mswmenu.h mswmenu.rc mswfile.dlg mswabout.dlg \
           mswfonts.dlg mswmodes.dlg mswprg.dlg mswmlh.dlg \
           mswapp.ico mswscr.ico mswcur.cur mswnot.cur mswwait.ico \
           mswgrin1.cur mswgrin2.cur mswgrin3.cur mswgrin4.cur \
           mswgrin5.cur mswgrin6.cur mswgrin7.cur mswgrin8.cur
	RC -R -I$(INCLUDEPATH) -FO mewin.res MEWIN.RC

basic.obj: basic.c 

bind.obj: bind.c 

buffer.obj: buffer.c 

char.obj: char.c 

crypt.obj: crypt.c 

display.obj: display.c 

dolock.obj: dolock.c 

eval.obj: eval.c 

exec.obj: exec.c 

file.obj: file.c 

fileio.obj: fileio.c 

input.obj: input.c 

isearch.obj: isearch.c 

line.obj: line.c 

lock.obj: lock.c 

main.obj: main.c 

mouse.obj: mouse.c 

random.obj: random.c 

region.obj: region.c 

screen.obj: screen.c 

search.obj: search.c 

window.obj: window.c 

word.obj: word.c 

mswdisp.obj: mswdisp.c 

mswdrv.obj: mswdrv.c 

mswemacs.obj: mswemacs.c 

mswexec.obj: mswexec.c 

mswfile.obj: mswfile.c 

mswfont.obj: mswfont.c 

mswinput.obj: mswinput.c 

mswmem.obj: mswmem.c 

mswmenu.obj: mswmenu.c 

mswsys.obj: mswsys.c 

#		*Compiler Configuration File*
MEWIN.cfg: MEWIN.mak
  copy &&|
-ml
-2
-v
-Os
-d
-WE
-w-par
-w-cpt
-w-rng
-w-pia
-w-rvl
-w-rpt
-I$(INCLUDEPATH)
-L$(LIBPATH)
| MEWIN.cfg


