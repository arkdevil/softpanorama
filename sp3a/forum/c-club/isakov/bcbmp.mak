# ////////////////// Borland C++ v2.0 & Make 3.5 ///////////////////////// #

.AUTODEPEND

all: bcBmp.exe

BMP.obj: BMP.c BMPClass.h

Message.obj: Message.c Message.h

BMPClass.obj: BMPClass.c BMPClass.h Message.h

OBJS = BMP.obj Message.obj BMPClass.obj

# //////////////////////////////////////////////////////////////////////// #

WARN = -w -w-eff -w-rch -w-aus

COMP = bcc -c -ms -O -Z -d -WE -H=bcBmp.sym $(WARN)
LINK = tlink /x/c/Twe/P/A=16

STDL = cwins import cs

.c.obj:
    $(COMP) {$< }

bcBmp.exe: $(OBJS) bcBmp.def Bmp.res
    $(LINK) c0ws $(OBJS),bcBmp.exe,,$(STDL),bcBmp.def;
    rc Bmp.res bcBmp.exe

