.AUTODEPEND

#		*Translator Definitions*
CC = bcc +MAILX.CFG
TASM = TASM
TLINK = tlink


#		*Implicit Rules*
.c.obj:
  $(CC) -c {$< }

.cpp.obj:
  $(CC) -c {$< }

#		*List Macros*


EXE_dependencies =  \
  cmd1.obj \
  cmd2.obj \
  cmd3.obj \
  cmdtab.obj \
  collect.obj \
  config.obj \
  date.obj \
  edit.obj \
  fio.obj \
  getconf.obj \
  getname.obj \
  head.obj \
  lex.obj \
  list.obj \
  local.obj \
  lock.obj \
  main.obj \
  maux.obj \
  names.obj \
  optim.obj \
  popen.obj \
  quit.obj \
  send.obj \
  sendprog.obj \
  strings.obj \
  temp.obj \
  tty.obj \
  tzset.obj \
  unpack.obj \
  vars.obj \
  version.obj

#		*Explicit Rules*
mailx.exe: mailx.cfg $(EXE_dependencies)
  $(TLINK) /v/x/c/P-/L\BCC\LIB @&&|
c0l.obj+
cmd1.obj+
cmd2.obj+
cmd3.obj+
cmdtab.obj+
collect.obj+
config.obj+
date.obj+
edit.obj+
fio.obj+
getconf.obj+
getname.obj+
head.obj+
lex.obj+
list.obj+
local.obj+
lock.obj+
main.obj+
maux.obj+
names.obj+
optim.obj+
popen.obj+
quit.obj+
send.obj+
sendprog.obj+
strings.obj+
temp.obj+
tty.obj+
tzset.obj+
unpack.obj+
vars.obj+
version.obj
mailx
		# no map file
cl.lib
|


#		*Individual File Dependencies*
cmd1.obj: cmd1.c 

cmd2.obj: cmd2.c 

cmd3.obj: cmd3.c 

cmdtab.obj: cmdtab.c 

collect.obj: collect.c 

config.obj: config.c 

date.obj: date.c 

edit.obj: edit.c 

fio.obj: fio.c 

getconf.obj: getconf.c 

getname.obj: getname.c 

head.obj: head.c 

lex.obj: lex.c 

list.obj: list.c 

local.obj: local.c 

lock.obj: lock.c 

main.obj: main.c 

maux.obj: maux.c 

names.obj: names.c 

optim.obj: optim.c 

popen.obj: popen.c 

quit.obj: quit.c 

send.obj: send.c 

sendprog.obj: sendprog.c 

strings.obj: strings.c 

temp.obj: temp.c 

tty.obj: tty.c 

tzset.obj: tzset.c 

unpack.obj: unpack.c 

vars.obj: vars.c 

version.obj: version.c 

#		*Compiler Configuration File*
mailx.cfg: mailx.mak
  copy &&|
-ml
-f-
-ff-
-N
-v
-G
-O
-k-
-wamp
-w-par
-wasm
-wdef
-w-pia
-w-rvl
-w-aus
-w-sus
-wstv
-I\BCC\INCLUDE
-L\BCC\LIB
-DMSDOS
-P-.C
| mailx.cfg


