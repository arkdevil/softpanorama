#
# Makefile for Windows Info-ZIP Unzip, WizUnZip 2.0
# A non-profit Windows unzipper.
#
# by Robert Heath, Columbia,SC
# CIS: 71600,437
# July 4, 1993
#
# To make WizUnZip 2.0, type:
#	
#	nmake wizunzip.mk
#
# Make Win 3.0-compatible binaries
#
DEFS= -DMSWIN  -DWINVER=0x0300

# Uncomment following statement to insert CodeView debugging info
# and turn off optimization. Put back as comment for production.
#CDEBUGDEFS=-Zi -Od

# Uncomment following three statements for production. Turn on space
# optimization (-Os) for production. Put back as comment for debugging.
# Do not turn on aliasing (-Oa) per  comment at the bottom of WIZUNZIP.C.
OPT=-Os
REGISTER=register
CDEBUGDEFS=-DNDEBUG 

CFLAGS=/nologo -AM $(DEFS) -Gw $(OPT) -W3 -Zpe $(CDEBUGDEFS) -DREGISTER=$(REGISTER)

# Uncomment following statement to insert CodeView debugging information.
# Put comment back for production.
#LDEBUG=/CO

LFLAGS=/M /NOD $(LDEBUG)

.c.obj:
	cl -c $(CFLAGS) -NT wizu_$* $*.c


O=.obj

# original unzip .objs
UNZIPOBJSA=unzip$O file_io$O mapname$O match$O misc$O
UNZIPOBJSB=explode$O unreduce$O unshrink$O extract$O inflate$O

WINOBJSA=wizunzip.obj status.obj winit.obj replace.obj rename.obj
WINOBJSB=wndproc.obj about.obj action.obj sizewndw.obj updatelb.obj
WINOBJSC=kbdproc.obj pattern.obj seldir.obj sound.obj
OBJS=$(WINOBJSA) $(WINOBJSB) $(WINOBJSC) $(UNZIPOBJSA) $(UNZIPOBJSB)

all: wizunzip.exe wizunzip.hlp

#
# Make Win 3.0-compatible resources
#
wizunzip.exe: $(OBJS) wizunzip.def wizunzip.res wizunzip.lnk 
	link @wizunzip.lnk
	rc -30 wizunzip.res


wizunzip.lnk: wizunzip.mk
	echo $(LFLAGS) 			+>$@
	echo $(WINOBJSA)	   +>>$@
	echo $(WINOBJSB)	   +>>$@
	echo $(WINOBJSC)	   +>>$@
	echo $(UNZIPOBJSA)	+>>$@
	echo $(UNZIPOBJSB)		>>$@
	echo wizunzip.exe		>>$@
	echo wizunzip.map		>>$@
	echo libw mlibcew commdlg oldnames shell >>$@
	echo wizunzip.def		>>$@

wizunzip.hlp: wizunzip.rtf helpids.h wizunzip.hpj
    hc wizunzip

action.obj: action.c wizunzip.h 

kbdproc.obj: kbdproc.c wizunzip.h 

pattern.obj: pattern.c wizunzip.h pattern.h helpids.h

replace.obj: replace.c replace.h wizunzip.h helpids.h

rename.obj: rename.c rename.h wizunzip.h helpids.h

seldir.obj: seldir.c seldir.h wizunzip.h helpids.h

sizewndw.obj: sizewndw.c wizunzip.h 

sound.obj: sound.c wizunzip.h helpids.h sound.h

status.obj: status.c wizunzip.h 

updatelb.obj: updatelb.c wizunzip.h 

winit.obj: winit.c wizunzip.h 

wizunzip.obj: wizunzip.c wizunzip.h 

wndproc.obj: wndproc.c wizunzip.h helpids.h

# targets for Windows-independent targets
explode.obj unreduce.obj unshrink.obj inflate.obj: unzip.h

# targets for Windows-dependent targets
unzip.obj mapname.obj match.obj misc.obj : unzip.h wizunzip.h

file_io.obj: file_io.c unzip.h wizunzip.h replace.h

wizunzip.res: wizunzip.rc wizunzip.ico wizunzip.h \
		 replace.h rename.h pattern.h seldir.h sound.h help.cur \
		 about.dlg pattern.dlg replace.dlg rename.dlg sound.dlg seldir.dlg
       rc -r wizunzip.rc

