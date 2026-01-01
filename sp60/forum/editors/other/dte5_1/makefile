# Make dte for UNIX [System V] systems

BINDIR = /usr/local/bin
OBJECTS = ed.o utils.o findrep.o block.o hwind.o hwsysv.o window.o

# -n - make code shareable
# -q - make pages demand loadable
# -z - check for dereferencing NULL pointer
#CCFLAGS = -O -z -n -q
CCFLAGS = -O

.c.o:           ; cc $(CCFLAGS) -c -DUNIX $*.c

dte: $(OBJECTS) ; cc $(CCFLAGS) -o dte $(OBJECTS) -lcurses
install:        dte ;\
                strip dte ;\
                mv dte ${BINDIR}/dte ;\
                chmod 755 ${BINDIR}/dte

$(OBJECTS):     common.h
ed.o:           utils.h findrep.h block.h window.h
utils.o:        utils.h
findrep.o:      utils.h findrep.h
window.o:       utils.h window.h
block.o:        utils.h block.h
hwind.o:        hwdep.h
hwsysv.o:       hwdep.h version.h

clean:          ; -rm -f $(OBJECTS)
