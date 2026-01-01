PROJ	=TST3
DEBUG	=0
CC	=qcl
CFLAGS_G	= /AL /W0 /Ze 
CFLAGS_D	= /Zi /Od 
CFLAGS_R	= /Od /Gs /DNDEBUG 
CFLAGS	=$(CFLAGS_G) $(CFLAGS_R)
LFLAGS_G	= /CP:0xffff /NOI /SE:0x80 /ST:0x2800 
LFLAGS_D	= /CO 
LFLAGS_R	= 
LFLAGS	=$(LFLAGS_G) $(LFLAGS_R)
RUNFLAGS	=
OBJS_EXT = 	
LIBS_EXT = 	

all:	$(PROJ).exe

coproc.obj:	coproc.c

tst3.obj:	tst3.c

$(PROJ).exe:	coproc.obj tst3.obj $(OBJS_EXT)
	echo >NUL @<<$(PROJ).crf
coproc.obj +
tst3.obj +
$(OBJS_EXT)
$(PROJ).exe

$(LIBS_EXT);
<<
	link $(LFLAGS) @$(PROJ).crf

run: $(PROJ).exe
	$(PROJ) $(RUNFLAGS)

