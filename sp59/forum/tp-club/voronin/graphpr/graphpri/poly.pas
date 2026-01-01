unit poly;
interface

{ модуль, выполняющий функцию "построение многоугольника" }

procedure  polynom(var xk,yk,xsp,ysp,cl,cf,tl,rl,tf:integer);
implementation
uses dos,crt,graph;
var xk,yk,xsp,ysp,cl,cf,tl,rl,tf:integer;
procedure  polynom;
var xi:array[1..500] of integer;
    yi:array[1..500] of integer;
    ch:char;
    a:real;
    s,s1:string;
    f,f1:text;
    xv,yv,kol,kol1,i,j,xks,yks,k,sc:integer;
label 100,120,1,2,3,200,300;
begin
xk:=xk+2; yk:=yk+15;
assign(f,'progr.bak'); rewrite(f); close(f); erase(f);
kol1:=1;    xks:=xk; yks:=yk;  i:=1;   kol:=0;     sc:=getpixel(xk-2,yk+3);
1:

      setcolor(0); outtextxy(595,28,'█████'); outtextxy(595,38,'█████');
      setcolor(9);
      s:='X:';  str(xk,s1);  s:=s+s1;  outtextxy(595,28,s);
      s:='Y:';  str(yk,s1);  s:=s+s1;  outtextxy(595,38,s);

     ch:=readkey; if ch=chr(0) then ch:=readkey;
    if ch=chr(13) then begin
    xi[i]:=xk-2; yi[i]:=yk-15; kol:=i; i:=i+1;
    k:=getpixel(xk,yk);setcolor(k);
    line(xk-1,yk-1,xk+1,yk+1); line(xk-1,yk+1,xk+1,yk-1); sc:=k;
    goto 1;
    end;
    if ch=chr(117) then goto 100;
    if ch=chr(159) then goto 100;
    if ch=chr(79) then goto 100;
    if ch=chr(60) then goto 300;
    if ch=chr(67) then goto 200;
setcolor(8);
if ch=chr(56) then ch:=chr(72);
if ch=chr(54) then ch:=chr(77);
if ch=chr(50) then ch:=chr(80);
if ch=chr(52) then ch:=chr(75);
if ch=chr(72) then begin putpixel(xk,yk,sc); xk:=xk; yk:=yk-ysp;
         sc:=getpixel(xk,yk);  putpixel(xk,yk,15);
         goto 1; end;
if ch=chr(80) then begin putpixel(xk,yk,sc); xk:=xk; yk:=yk+ysp;
         sc:=getpixel(xk,yk);  putpixel(xk,yk,15);
         goto 1; end;
if ch=chr(77) then begin putpixel(xk,yk,sc); xk:=xk+xsp; yk:=yk;
         sc:=getpixel(xk,yk);  putpixel(xk,yk,15);
         goto 1; end;
if ch=chr(75) then begin putpixel(xk,yk,sc); xk:=xk-xsp; yk:=yk;
         sc:=getpixel(xk,yk);  putpixel(xk,yk,15);
         goto 1; end;
if ch=chr(57) then begin putpixel(xk,yk,sc); xk:=xk+xsp; yk:=yk-ysp;
         sc:=getpixel(xk,yk); putpixel(xk,yk,15);
         goto 1; end;
if ch=chr(51) then begin putpixel(xk,yk,sc); xk:=xk+xsp; yk:=yk+ysp;
         sc:=getpixel(xk,yk);  putpixel(xk,yk,15);
         goto 1; end;
if ch=chr(49) then begin putpixel(xk,yk,sc); xk:=xk-xsp; yk:=yk+ysp;
         sc:=getpixel(xk,yk);  putpixel(xk,yk,15);
         goto 1; end;
if ch=chr(55) then begin putpixel(xk,yk,sc); xk:=xk-xsp; yk:=yk-ysp;
         sc:=getpixel(xk,yk);  putpixel(xk,yk,15);
         goto 1; end;
goto 1;
100: assign(f,'progr.pas');
     rename(f,'progr.bak');
     assign(f,'progr.pas');
     assign(f1,'progr.bak');
     rewrite(f); reset(f1);
     readln(f1,s); writeln(f,s);
     readln(f1,s); writeln(f,s);
     readln(f1,s);
        if s<>'const' then writeln(f,'const') else writeln(f,s);
        writeln(f,'     pol',kol1,': array[1..',kol+1,'] of pointtype =');
        writeln(f,'                      (( x:',xi[1],'; y:',yi[1],'),');
        for j:=2 to kol do
        writeln(f,'                       ( x:',xi[j],'; y:',yi[j],'),');
        writeln(f,'                       ( x:',xi[1],'; y:',yi[1],'));');
      2: writeln(f,s);
         if eof(f1)=true then goto 3;
         readln(f1,s);
         goto 2;

      3: if ch=chr(79) then begin
         setcolor(cl); setlinestyle(tl,0,rl);
         for j:=1 to kol-1 do line(xi[j]+2,yi[j]+15,xi[j+1]+2,yi[j+1]+15);
         line(xi[kol]+2,yi[kol]+15,xi[1]+2,yi[1]+15);  setlinestyle(0,0,0);
         writeln(f,'drawpoly(',kol+1,',pol',kol1,');'); end;

         if ch=chr(117) then begin
         setcolor(cl); setfillstyle(tf,cf); setlinestyle(tl,0,rl);
         for j:=1 to kol-1 do line(xi[j]+2,yi[j]+15,xi[j+1]+2,yi[j+1]+15);
         line(xi[kol]+2,yi[kol]+15,xi[1]+2,yi[1]+15);setfillstyle(tf,cf); setlinestyle(0,0,0);
         floodfill(xk,yk,cl);
         writeln(f,'fillpoly(',kol+1,',pol',kol1,');');
         end;

         close(f); erase(f1);

         i:=1;  kol1:=kol1+1;
         goto 1;


   200:  sc:=getpixel(xk-2,yk+3); setcolor(sc);
         for j:=1 to kol do begin
         line(xi[j]-1,yi[j]-1,xi[j]+1,yi[j]+1); line(xi[j]-1,yi[j]+1,xi[j]+1,yi[j]-1);
         end;
  300:  xk:=xks-2; yk:=yks-15;
end;


end.
