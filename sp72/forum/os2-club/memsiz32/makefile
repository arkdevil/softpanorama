All: Memsize.exe Catala Deutsch English Espanol

Memsize.exe: $*.obj $*.res $*.def About.obj Config.obj Debug.obj Items.obj Process.obj Profile.obj Restring.obj Support.obj Cdlist.obj
  link386 /NOLOGO /MAP $*+About+Config+Debug+Items+Process+Profile+Restring+Support+Cdlist,$*,$*,libgpp+libc+os2386+os2286,$*;
  rc $*.res

Memsize.res: $*.rc $*.ico
  rc -r $*.rc

Memsize.obj: $*.cc $*.h About.h Config.h Debug.h Items.h Process.h Restring.h Support.h
  gcc -c -O $*.cc

About.obj: $*.cc $*.h
  gcc -c -O $*.cc

Config.obj: $*.cc $*.h Debug.h Support.h
  gcc -c -O $*.cc

Debug.obj: $*.cc $*.h
  gcc -c -O $*.cc

Items.obj: $*.cc $*.h Debug.h Support.h Restring.h
  gcc -c -O $*.cc

Process.obj: $*.cc $*.h Debug.h
  gcc -c -O $*.cc

Profile.obj: $*.cc $*.h Debug.h
  gcc -c -O $*.cc

Restring.obj: $*.cc $*.h Debug.h
  gcc -c -O $*.cc

Support.obj: $*.cc $*.h Debug.h
  gcc -c -O $*.cc

Cdlist.obj : $*.s
  gcc -c -O $*.s

Cdlist.s : Memsize.obj
  collect -o Cdlist.s Memsize.obj

Catala: $*.dll $*.hlp

Catala.hlp: $*.ipf Memsize.bmp
  ipfc /x /COU=003 /LAN=ESP $*.ipf

Catala.dll: $*.def $*.res dll.obj
  link dll, $*.dll /align:16, nul,, $* ;
  rc $*.res $*.dll

Catala.res: $*.rc
  rc -r $*

Deutsch: $*.dll $*.hlp

Deutsch.hlp: $*.ipf Memsize.bmp
  ipfc /x /COU=049 /LAN=DEU $*.ipf

Deutsch.dll: $*.def $*.res dll.obj
  link dll, $*.dll /align:16, nul,, $* ;
  rc $*.res $*.dll

Deutsch.res: $*.rc
  rc -r $*

English: $*.dll $*.hlp

English.hlp: $*.ipf Memsize.bmp
  ipfc /x /COU=001 /LAN=ENU $*.ipf

English.dll: $*.def $*.res dll.obj
  link dll, $*.dll /align:16, nul,, $* ;
  rc $*.res $*.dll

English.res: $*.rc
  rc -r $*

Espanol: $*.dll $*.hlp

Espanol.hlp: $*.ipf Memsize.bmp
  ipfc /x /COU=003 /LAN=ESP $*.ipf

Espanol.dll: $*.def $*.res dll.obj
  link dll, $*.dll /align:16, nul,, $* ;
  rc $*.res $*.dll

Espanol.res: $*.rc
  rc -r $*

dll.obj: $*.asm
  masm $* ;



