#############################################################################
# PROJECT:  Mouse Routines
#############################################################################
# MODULE:  MAKEFILE.
#############################################################################
# DESCRIPTION:
#   Makefile for the mouse routines.
#
#   For NDMake (4.5 and up).
#
#############################################################################
# MODIFICATION NOTES:
#    Date     Author Comment
# 26-Oct-1990   dk   Initial file.
#############################################################################/

.RESPONSE_LINK: tlink

#>> Directories <<
INC=\tc\include
LIB=\tc\lib

LFLAGS = /v

OBJS = mou.obj test.obj

all : test.exe

.c.obj :
  tcc -ml -v -w -w-par -K -y -I$(INC);. -c -o$*.obj $<

test.exe : $(OBJS)
  tlink $(LFLAGS) $(LIB)\c0l $(OBJS) , test.exe , , $(LIB)\cl
