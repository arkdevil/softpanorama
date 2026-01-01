
* CLS.PRG
call curs_off
i=1
y1=11
x1=40
y2=11
x2=40
*set color to &st_color
do while i <> 14
@ y1,x1,y2,x2 box ''
if y1<>1
   y1=y1-1
      endif
if x1>1
   x1=x1-2
      endif
if y2<>21
   y2=y2+1
     endif
if x2<>79
   x2=x2+2
     endif
i=i+1
enddo
clear
call curs_on
return 
