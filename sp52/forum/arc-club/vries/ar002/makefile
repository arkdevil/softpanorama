# Makefile adapted by Nico E de Vries

##############################################
#  'ar' -- compression archiver              #
#  makefile for Borland C++ C compact model  #
##############################################

MDL  = c  ##### compact model #####
OBJS = ar.obj io.obj encode.obj decode.obj maketree.obj maketbl.obj huf.obj

ar.exe: $(OBJS)
        tlink /c /d /x c:\borlandc\lib\c0$(MDL) c:\borlandc\lib\wildargs.obj \
        ar io encode decode maketree maketbl huf, ar, , c:\borlandc\lib\c$(MDL)

# The origional makefile didn't include wildargs.obj. I included it
# so AR can process wildcards on the commandline. (NEV)

.c.obj:
        bcc -c -m$(MDL) -N -w -w-stv -Ic:\borlandc\include $<

$(OBJS): ar.h
