#####################################################################
#
#
#                   MAKEFILE to create WINDOW.LIB
#
#                        (C) by MacSoft 1990
#
#
#####################################################################


window.lib: window.obj shrnkwnd.obj statwnd.obj pushwnd.obj \
snowtest.obj mkhmenu.obj popwnd.obj getswnd.obj getwinp.obj \
makewnd.obj closewnd.obj forgtwnd.obj drawbox.obj prtcwnd.obj \
prtwnd.obj locate.obj scrldn.obj scrlup.obj clearwnd.obj _fromvid.obj \
_tovid.obj _vgetc.obj _vlwrite.obj _vputc.obj _vputs.obj \
_mymallo.obj _scrbase.obj _recolor.obj _timer.obj putcwnd.obj keybio.obj \
vidmode.obj _myrand.obj rawmenu.obj _myfail.obj

  del window.lib
  tlib window.lib /C @wndlib.inp

.asm.obj:
  @tasm /ml $<

rawmenu.obj  : window.h rawmenu.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
window.obj : window.h window.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
vidmode.obj : window.h vidmode.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
shrnkwnd.obj : window.h shrnkwnd.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
statwnd.obj : window.h statwnd.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
pushwnd.obj : window.h pushwnd.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
snowtest.obj : window.h snowtest.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
mkhmenu.obj : window.h mkhmenu.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
getswnd.obj : window.h getswnd.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
getwinp.obj : window.h getwinp.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
makewnd.obj : window.h makewnd.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
closewnd.obj : window.h closewnd.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
forgtwnd.obj : window.h forgtwnd.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
drawbox.obj : window.h drawbox.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
prtcwnd.obj : window.h prtcwnd.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
prtwnd.obj : window.h prtwnd.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
locate.obj : window.h locate.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
scrldn.obj : window.h scrldn.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
scrlup.obj : window.h scrlup.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
clearwnd.obj : window.h clearwnd.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
popwnd.obj : window.h popwnd.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
putcwnd.obj : window.h putcwnd.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
keybio.obj : keybio.c
  @tcc -ml -I\tc\inc -c -w -K -Z -k- -r -O $*.c
