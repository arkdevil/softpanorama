#
# NMAKE-compatible MAKE file for building REXX/SQL with C Set/2
#
# will generate:
#
#      rexxsql.dll
#      rexxsql.exe
#      rexxora.dll
#      rexxora.exe
# 
# Usage: nmake [LIST=1] [DEBUG=1] [rexxsql.dll|rexxsql.exe|rexxora.dll|rexxora.exe]
#

!ifdef LIST
listopt = /Fl /Le /Ls+
!endif

!ifdef DEBUG
copts  = /Ti- /O- /dDEBUG /I.. /I..\..\common #/Kf+
lopts  = /NOLOGO /NOE /NOD /EXEPACK /ALIGN:4 /DEBUG /MAP:FULL
!else
copts  = /Ti+ /O+ /dNDEBUG /I.. /I..\..\common #/Kf+
lopts  = /NOLOGO /NOE /NOD /EXEPACK /PACKCODE /PACKDATA /ALIGN:4
!endif

cflagsdll = $(copts) /C /Ms /Ge- /Q /Sa /J+ 
cflagsexe = $(copts) /C /Mp /Ge+ /Q /Sa /J+ 
lflagsdll = $(lopts)
lflagsexe = /ST:900000 /SE:512 $(lopts)

objssqldll = hashdll.obj rsqldll.obj osqldll.obj
objssqlexe = getopt.obj hashexe.obj rsqlexe.obj osqlexe.obj
objsoradll = hashdll.obj roradll.obj ooradll.obj
objsoraexe = getopt.obj hashexe.obj roraexe.obj ooraexe.obj

ccsqldll = icc $(cflagsdll) $(listopt)
ccsqlexe = icc $(cflagsexe) $(listopt)
ccoradll = icc $(cflagsdll) $(listopt) -DORA_PREFIX
ccoraexe = icc $(cflagsexe) $(listopt) -DORA_PREFIX

all: rexxsql.dll rexxsql.exe rexxora.dll rexxora.exe

getopt.obj: ..\..\common\getopt.c
    $(ccsqlexe) /Fogetopt.obj ..\..\common\getopt.c

hashdll.obj: ..\..\common\hash.c
    $(ccsqldll) /Fohashdll.obj ..\..\common\hash.c

hashexe.obj: ..\..\common\hash.c
    $(ccsqlexe) /Fohashexe.obj ..\..\common\hash.c

rsqldll.obj: ..\rexxsql.c ..\oci.h ..\rexxsql.h
    $(ccsqldll) /Forsqldll.obj ..\rexxsql.c

rsqlexe.obj: ..\rexxsql.c ..\oci.h ..\rexxsql.h
    $(ccsqlexe) /Forsqlexe.obj ..\rexxsql.c

osqldll.obj: ..\orasql.c ..\oci.h ..\rexxsql.h
    $(ccsqldll) /Foosqldll.obj ..\orasql.c

osqlexe.obj: ..\orasql.c ..\oci.h ..\rexxsql.h
    $(ccsqlexe) /Foosqlexe.obj ..\orasql.c

roradll.obj: ..\rexxsql.c ..\oci.h ..\rexxsql.h
    $(ccoradll) /Fororadll.obj ..\rexxsql.c

roraexe.obj: ..\rexxsql.c ..\oci.h ..\rexxsql.h
    $(ccoraexe) /Fororaexe.obj ..\rexxsql.c

ooradll.obj: ..\orasql.c ..\oci.h ..\rexxsql.h
    $(ccoradll) /Foooradll.obj ..\orasql.c

ooraexe.obj: ..\orasql.c ..\oci.h ..\rexxsql.h
    $(ccoraexe) /Foooraexe.obj ..\orasql.c

rexxsql.dll: $(objssqldll)
    link386 $(lflagsdll) @sqldll.lnk

rexxsql.exe: $(objssqlexe)
    link386 $(lflagsexe) @sqlexe.lnk

rexxora.dll: $(objsoradll)
    link386 $(lflagsdll) @oradll.lnk

rexxora.exe: $(objsoraexe)
    link386 $(lflagsexe) @oraexe.lnk
