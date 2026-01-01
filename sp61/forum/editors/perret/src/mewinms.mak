# makefile for MEWIN (MicroEMACS for Windows)
# for Microsoft C compiler (6.0 or 7.0) on i386 or MIPS CPU
# 
# define TARGET as C6, C7 or NT (or some other short suffix)
# for Windows/NT, use TARGET=NT
# other suffixes compile for Windows 3.1

!IFNDEF DEBUG
DEBUG = 0
!ENDIF

!IFNDEF TARGET
!IFDEF NTVERSION
TARGET = NT
!ELSE
TARGET = C7
!ENDIF
!ENDIF

!IFNDEF CPU
!IF "$(TARGET)"=="NT"
CPU = i386
!ENDIF
!ENDIF 

OBJ = $(TEMP)\MEWIN.$(TARGET)
PROJ = MEWIN$(TARGET)

DEF_FILE = MEWIN.DEF
RES_FILE = MEWIN.RES
RC_FILE = MEWIN.RC
DLG_FILES = mswmodes.dlg mswmlh.dlg mswfonts.dlg mswprg.dlg mswabout.dlg\
        mswfile.dlg
ICO_FILES = mswapp.ico mswscr.ico mswwait.ico
CUR_FILES = mswcur.cur mswnot.cur mswgrin1.cur mswgrin2.cur mswgrin3.cur \
        mswgrin4.cur mswgrin5.cur mswgrin6.cur mswgrin7.cur mswgrin8.cur
BMP_FILES =
MNU_FILES = mswmenu.rc

!IF "$(TARGET)"=="NT"
!IF "$(CPU)"=="MIPS"
# MIPS specific build stuff
CPUTYPE=2
CC = cc
cvtobj = mip2coff
CFLAGS_G  = -std -G0 -O -EL -DMIPS=1 -DWIN32 -DWINNT=1 -D__cdecl= -D__export= $(C_FLAGS)
CFLAGS_D  =
CFLAGS_R  =
LFLAGS_G  = /SUBSYSTEM:windows /ENTRY:WinMainCRTStartup\
        /OUT:$(PROJ).exe $(L_FLAGS)
LFLAGS_D  = /DEBUG:full
LFLAGS_R  = 
LLIBS_G   = $(OBJ)\$(PROJ).lib $(LIB)\libcmt.lib $(LIB)\*.lib
LLIBS_R  =
LLIBS_D  =
!ELSE
# x86 build stuff
!if "$(CPU)"=="i386"
CC  = cl386
CFLAGS_G  = /G3 /Gd /BATCH /Di386=1 /DWIN32 /DWINNT=1 $(C_FLAGS)
CFLAGS_D  = /Od /Zi
CFLAGS_R  = /Os /Og
LFLAGS_G  = /SUBSYSTEM:windows /ENTRY:WinMainCRTStartup\
        /OUT:$(PROJ).exe $(L_FLAGS)
LFLAGS_D  = /DEBUG:full /DEBUGTYPE:cv
LFLAGS_R  = 
LLIBS_G   = $(OBJ)\$(PROJ).lib $(LIB)\libcmt.lib $(LIB)\*.lib
LLIBS_R  =
LLIBS_D  =
!ELSE
!ERROR  Must specify CPU Environment Variable (set CPU=i386 or set CPU=MIPS )
!ENDIF
!ENDIF
!ELSE
CC  = cl
CFLAGS_G  = /AL /G2 /Gx /GA /DWINVER=0x030a /Zp /BATCH
CFLAGS_D  = /Od /Zi
CFLAGS_R  = /Os /Og /Gs
LFLAGS_G  = /BATCH /ONERROR:NOEXE
LFLAGS_D  = /CO /NOF
LFLAGS_R  = /F
LLIBS_G  = LIBW.LIB SHELL.LIB
LLIBS_R  = /NOD:LLIBCE LLIBCEW.LIB
LLIBS_D  = /NOD:LLIBCE LLIBCEW.LIB
!ENDIF
MAPFILE_D  = $(OBJ)\$(PROJ).map
MAPFILE_R  = NUL
LINKER	= link
LRF  = echo > NUL
RC  = rc
RCFLAGS2  = /30 /t
CVFLAGS  = /25

FILES  = BASIC.C BIND.C BUFFER.C CHAR.C CRYPT.C DISPLAY.C DOLOCK.C EVAL.C\
	EXEC.C FILE.C FILEIO.C INPUT.C ISEARCH.C LINE.C LOCK.C MAIN.C MOUSE.C\
	MSWDISP.C MSWDRV.C MSWEMACS.C MSWEXEC.C MSWFILE.C MSWFONT.C MSWINPUT.C\
	MSWMEM.C MSWMENU.C MSWSYS.C RANDOM.C REGION.C SCREEN.C SEARCH.C\
	WINDOW.C WORD.C

OBJ_FILES = $(OBJ)\BASIC.obj $(OBJ)\BIND.obj $(OBJ)\BUFFER.obj $(OBJ)\CHAR.obj\
        $(OBJ)\CRYPT.obj $(OBJ)\DISPLAY.obj $(OBJ)\DOLOCK.obj $(OBJ)\EVAL.obj\
        $(OBJ)\EXEC.obj $(OBJ)\FILE.obj $(OBJ)\FILEIO.obj $(OBJ)\INPUT.obj\
        $(OBJ)\ISEARCH.obj $(OBJ)\LINE.obj $(OBJ)\LOCK.obj $(OBJ)\MAIN.obj\
        $(OBJ)\MOUSE.obj $(OBJ)\MSWDISP.obj $(OBJ)\MSWDRV.obj\
        $(OBJ)\MSWEMACS.obj $(OBJ)\MSWEXEC.obj $(OBJ)\MSWFILE.obj\
        $(OBJ)\MSWFONT.obj $(OBJ)\MSWINPUT.obj $(OBJ)\MSWMEM.obj\
        $(OBJ)\MSWMENU.obj $(OBJ)\MSWSYS.obj $(OBJ)\RANDOM.obj\
        $(OBJ)\REGION.obj $(OBJ)\SCREEN.obj $(OBJ)\SEARCH.obj\
        $(OBJ)\WINDOW.obj $(OBJ)\WORD.obj

all: $(PROJ).exe

.SUFFIXES:
.SUFFIXES: .obj .c
.SUFFIXES: .obj .c

$(OBJ)\BASIC.obj : BASIC.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\BIND.obj : BIND.C estruct.h eproto.h edef.h elang.h epath.h english.h

$(OBJ)\BUFFER.obj : BUFFER.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\CHAR.obj : CHAR.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\CRYPT.obj : CRYPT.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\DISPLAY.obj : DISPLAY.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\DOLOCK.obj : DOLOCK.C estruct.h eproto.h elang.h english.h

$(OBJ)\EVAL.obj : EVAL.C estruct.h eproto.h edef.h elang.h evar.h english.h

$(OBJ)\EXEC.obj : EXEC.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\FILE.obj : FILE.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\FILEIO.obj : FILEIO.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\INPUT.obj : INPUT.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\ISEARCH.obj : ISEARCH.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\LINE.obj : LINE.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\LOCK.obj : LOCK.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\MAIN.obj : MAIN.C estruct.h eproto.h efunc.h edef.h elang.h ebind.h\
        english.h

$(OBJ)\MOUSE.obj : MOUSE.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\MSWDISP.obj : MSWDISP.C estruct.h elang.h eproto.h edef.h mswin.h\
        english.h mswrid.h

$(OBJ)\MSWDRV.obj : MSWDRV.C estruct.h elang.h eproto.h edef.h mswin.h\
	 english.h mswrid.h

$(OBJ)\MSWEMACS.obj : MSWEMACS.C estruct.h eproto.h edef.h elang.h mswin.h\
	 english.h mswmenu.h mswrid.h

$(OBJ)\MSWEXEC.obj : MSWEXEC.C estruct.h eproto.h edef.h elang.h mswin.h\
	 english.h mswrid.h

$(OBJ)\MSWFILE.obj : MSWFILE.C estruct.h eproto.h edef.h mswin.h mswrid.h

$(OBJ)\MSWFONT.obj : MSWFONT.C estruct.h eproto.h edef.h mswin.h mswrid.h

$(OBJ)\MSWINPUT.obj : MSWINPUT.C estruct.h elang.h eproto.h edef.h mswin.h\
	 english.h mswrid.h

$(OBJ)\MSWMEM.obj : MSWMEM.C estruct.h eproto.h edef.h elang.h mswin.h\
	 english.h mswrid.h

$(OBJ)\MSWMENU.obj : MSWMENU.C estruct.h elang.h eproto.h edef.h mswin.h\
	 mswmenu.h mswhelp.h english.h mswrid.h

$(OBJ)\MSWSYS.obj : MSWSYS.C estruct.h elang.h eproto.h edef.h mswin.h\
	 english.h mswrid.h

$(OBJ)\RANDOM.obj : RANDOM.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\REGION.obj : REGION.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\SCREEN.obj : SCREEN.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\SEARCH.obj : SEARCH.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\WINDOW.obj : WINDOW.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\WORD.obj : WORD.C estruct.h eproto.h edef.h elang.h english.h

$(OBJ)\$(RES_FILE) : $(RC_FILE) mswin.h mswrid.h mswmenu.h\
        $(DLG_FILES) $(ICO_FILES) $(CUR_FILES) $(BMP_FILES) $(MENU_FILES)
        $(RC) /r /fo $(OBJ)\$(RES_FILE) $(RC_FILE)

$(PROJ).exe : $(OBJ) $(OBJ_FILES) $(OBJ)\$(RES_FILE)
!IF $(DEBUG)
!IF "$(TARGET)"=="NT"
	$(LRF) @<<$(OBJ)\$(PROJ).lrf
$(OBJ_FILES)
$(LIBS) $(LLIBS_G) $(LLIBS_D)
$(LFLAGS_G) $(LFLAGS_D);
<<
!ELSE
	$(LRF) @<<$(OBJ)\$(PROJ).lrf
$(RT_OBJS: = +^
) $(OBJ_FILES: = +^
)
$@
$(MAPFILE_D)
$(LIBS: = +^
) +
$(LLIBS_G: = +^
) +
$(LLIBS_D: = +^
)
$(DEF_FILE) $(LFLAGS_G) $(LFLAGS_D);
<<
!ENDIF
!ELSE
!IF "$(TARGET)"=="NT"
	$(LRF) @<<$(OBJ)\$(PROJ).lrf
$(OBJ_FILES)
$(LIBS) $(LLIBS_G) $(LLIBS_R)
$(LFLAGS_G) $(LFLAGS_R);
<<
!ELSE
	$(LRF) @<<$(OBJ)\$(PROJ).lrf
$(RT_OBJS: = +^
) $(OBJ_FILES: = +^
)
$@
$(MAPFILE_R)
$(LIBS: = +^
) +
$(LLIBS_G: = +^
) +
$(LLIBS_R: = +^
)
$(DEF_FILE) $(LFLAGS_G) $(LFLAGS_R);
<<
!ENDIF
!ENDIF
!IF "$(TARGET)"=="NT"
        cvtres -$(CPU) $(OBJ)\$(RES_FILE)
        LIB /OUT:$(OBJ)\$(PROJ).lib /DEF:$(DEF_FILE) /MACHINE:$(CPU)
	$(LINKER) $(OBJ)\MEWIN.OBJ @$(OBJ)\$(PROJ).lrf
!ELSE
	$(LINKER) @$(OBJ)\$(PROJ).lrf
        $(RC) $(RCFLAGS2) $(OBJ)\$(RES_FILE) $(PROJ).exe
!ENDIF

$(OBJ):
        mkdir $(OBJ)

.c{$(OBJ)}.obj :
!IF "$(CPU)"=="MIPS"
!IF $(DEBUG)
	@$(CC) -c $(CFLAGS_G) $(CFLAGS_D) -o $@ $<
!ELSE
	@$(CC) -c $(CFLAGS_G) $(CFLAGS_R) -o $@ $<
!ENDIF
        @$(cvtobj) $@
!ELSE
!IF $(DEBUG)
	@$(CC) /c $(CFLAGS_G) $(CFLAGS_D) /Fo$@ $<
!ELSE
	@$(CC) /c $(CFLAGS_G) $(CFLAGS_R) /Fo$@ $<
!ENDIF
!ENDIF
