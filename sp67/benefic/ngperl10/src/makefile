#-------------------------------------------------------------------- MAKFILE
#  Borland MAKE 3.0 file to build "PERL Reference Guide"
#  for Norton Guides
#  by Kevin Grover, 26 Dec 1991, Mod: 27 Feb 1993
#--------------------------------------- MACROS

NGPATH = c:/etc/ng/
OBJS = commands.ngo options.ngo regexprs.ngo special.ngo operator.ngo \
       credits.ngo debug.ngo literals.ngo ascii.ngo language.ngo

#--------------------------------------- Implicit Rule for .DAT to .NGO files

.dat.ngo:
        $(NGPATH)ngc $*.dat

#--------------------------------------- Make line for PERL.NG

perl.ng: perl $(OBJS)
        $(NGPATH)ngml perl

# ------------

clean:
        del /y *.ngo *.bak
