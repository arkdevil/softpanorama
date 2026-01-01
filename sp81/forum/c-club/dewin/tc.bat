rem tcc -1 -ID:\TC\INC -c -mc -K -O -Z dewin.c 
tcc -1 -ID:\TC\INC -c -mc -K -O -Z -S dewin.c 
tlink /x d:\tc\lib\c0c.obj dewin.obj dess_l.obj, dewin.exe,, d:\tc\lib\cc.lib
del dewin.obj