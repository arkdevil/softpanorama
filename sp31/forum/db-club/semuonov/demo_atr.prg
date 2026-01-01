
load SHADOW.BIN

set colo to
clear
atr = 1
r=1
c=5
do while atr <> 256
   @ r,c say str(atr,4)
   call SHADOW with (chr(1)+chr(r+1)+chr(c+1)+chr(r+1)+chr(c+4)+chr(atr) )
   c=c+4
   if c>64
      r=r+1
      c=5
    endif
atr = atr+1
 enddo   
@ 19,1 say 'Демонстрация соответствия атрибутов и цветов. (SL, 1990, Simferopol)'
wait
return
