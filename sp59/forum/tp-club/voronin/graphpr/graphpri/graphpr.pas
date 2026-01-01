
{$M 32768,0,655360}
      program grafpr;
{┌───────────────────────────────────────────────────────────────────────┐}
{│                       Программа GRAPHPR                               │}
{│                                                                       │}
{│  Программа предназначена для генерации текста программы на языке      │}
{│  Turbo-Pascal, которая будет воспроизводить графические построения    │}
{│  которые вы делаете на экране.  Программа использует стандартные      │}
{│  процедуры языка и несколько специально подготовленных функций        │}
{│  находящихся в модуле  EXPANDER.TPU .  Результатом работы программы   │}
{│  является готовая к компиляции программа  PROGR.PAS                   │}
{│                                                                       │}
{└───────────────────────────────────────────────────────────────────────┘}
      uses  extended,slaid,expand,foread,crt,graph,poly;
 const k=1;
 var
   tip,tip1,xm,ym,xp,yp,xsp,ysp,i,no,t1,t2,t3,sc,pcf,errcode:integer;
   t,j,tl,tf,rl,vell,tipl,ksk,xk,yk,xks,yks,cl,cf,ci,ldr,le,m:integer;
   plus,grmode,grdriver,nowr,reg,look,tim,xb,yb:integer;
   x1,x2,y1,y2,r1,r2:real;
   r,xi1,xi2,x3,x4,yi1,yi2,y3,y4,xo1,yo1,xo2,yo2,xo,yo,un,uk:longint;
   am,ap:array[1..10] of string;
   apr:array[1..200] of string;
   p1:array[1..2250] of byte;
   s,s1,st,s10,s11:string;
   f,f1:text;
   funckey:boolean;
   ch:char;
 label
   1,9,10,11,20,30,40,50,60,70,900;

    { процедура сохранения в файле накопленных операторов }

procedure writ;
   label
   10,30;
   begin
          if apr[1]=' ' then goto 10;
          for i:=1 to 200 do begin;
             if apr[i]=' ' then goto 30;
             writeln(f,apr[i]);
          end;
  30:     for i:=1 to 200 do apr[i]:=' ';
          no:=0;
  10: end;

    { движение курсора в восьми направлениях }

procedure move;
label 100,101;
    begin
m:=0;  putpixel(xk,yk,sc);
if (ch=chr(72)) or (ch=chr(56)) then begin xk:=xk; yk:=yk-ysp;      goto 100; end;
if (ch=chr(80)) or (ch=chr(50)) then begin xk:=xk; yk:=yk+ysp;      goto 100; end;
if (ch=chr(77)) or (ch=chr(54)) then begin xk:=xk+xsp; yk:=yk;      goto 100; end;
if (ch=chr(75)) or (ch=chr(52)) then begin xk:=xk-xsp; yk:=yk;      goto 100; end;
if ch=chr(57) then begin xk:=xk+xsp; yk:=yk-ysp;  goto 100; end;
if ch=chr(51) then begin xk:=xk+xsp; yk:=yk+ysp;  goto 100; end;
if ch=chr(49) then begin xk:=xk-xsp; yk:=yk+ysp;  goto 100; end;
if ch=chr(55) then begin xk:=xk-xsp; yk:=yk-ysp;  goto 100; end;
goto 101;
100: m:=1; sc:=getpixel(xk,yk);  putpixel(xk,yk,15);
101: end;

  {  процедура выхода из программы }

  procedure qu(var s:string);
  var
  p2:array[1..11030] of byte;
  begin
   getimage(220,100,420,205,p2);
   bar(220,100,420,205);

   outtextxy(230,110,'   В H И М А H И Е !   ');   setcolor(10);
   outtextxy(230,130,'Hе вся инфоpмация  сох-');
   outtextxy(230,140,'pанена, пpи выходе  она');
   outtextxy(230,150,'будет утеpяна.Так надо?');
   outtextxy(230,170,'Y- да;  S- сохр.и выйти');
   outtextxy(230,180,'N-пpодолжить; B-сначала');
   moveto(230,190); outtext('>>>>>   '); gread(s);
   putimage(220,100,p2,normalput);
  end;
  procedure tit;
  begin
   titul(tip);
  end;
  procedure help(i:integer);
  begin
  if tip=1 then i:=1;
   helper(i,look);
  end;

   {   pисование  линии     }

procedure  plin;
label 100,120;
   begin
  setwritemode(1);
  setlinestyle(0,0,0);
  if ch=chr(67) then begin
  if ldr=1 then begin
     setcolor(15);
     line(xks,yks,xk,yk);
     putpixel(xk,yk,15);
  end;
  xks:=xk; yks:=yk; goto 100;
end;
if ch=chr(10) then ch:=chr(13);
if ch=chr(13) then goto 120;
if le=1 then begin
if ldr=1 then begin
      setcolor(15);
      line(xks,yks,xk,yk);
      end;
end;
if ch=chr(56) then ch:=chr(72);
if ch=chr(54) then ch:=chr(77);
if ch=chr(50) then ch:=chr(80);
if ch=chr(52) then ch:=chr(75);
         move;
         if m=1 then begin
         if le=1 then if ldr=1 then begin
          line(xks,yks,xk,yk);
          end;
         goto 100; end;
   120: if ch=chr(13) then begin
if le=0 then begin
     setcolor(cl);   setlinestyle(tl,0,rl);  setwritemode(0);
     line(xks,yks,xk,yk);  sc:=cl;
     s:='line(xb+';  setlinestyle(0,0,0);
     str(xks,s1); s:=s+s1+',yb+';
     str(yks,s1); s:=s+s1+',xb+';
     str(xk,s1);  s:=s+s1+',yb+';
     str(yk,s1);  s:=s+s1+');';
     no:=no+1;
     apr[no]:=s;
     if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
     if no=200 then writ;
     xks:=xk; yks:=yk;
 end else begin
     xks:=xk;  yks:=yk; end;
        end;
   100: setwritemode(0);
   end;

      {  pисование пpямоугольника      }

procedure  pbar;
var gl,glo:integer;
label 100,110,120,130,131,132,133;
   begin
setwritemode(1);
setlinestyle(0,0,0);
if ch=chr(67) then begin
      if ldr=1 then begin
         setcolor(15);
         rectangle(xks,yks,xk,yk);
      end;
         xks:=xk; yks:=yk; goto 100;
 end;
if ch=chr(10) then goto 130;
if ch=chr(13) then goto 120;
if le=1 then begin
if ldr=1 then begin
     setcolor(15);
     rectangle(xks,yks,xk,yk);
   end;
end;
setcolor(15);
if ch=chr(56) then ch:=chr(72);
if ch=chr(54) then ch:=chr(77);
if ch=chr(50) then ch:=chr(80);
if ch=chr(52) then ch:=chr(75);
         move;
         if m=1 then begin
         if le=1 then if ldr=1 then begin
         setcolor(15);
         rectangle(xks,yks,xk,yk); end;
         goto 100; end;

   120: if ch=chr(13) then begin
     if le=0 then begin
    setcolor(cl);
    setfillstyle(tf,cf);    setlinestyle(tl,0,rl);  setwritemode(0);
    bar(xks,yks,xk,yk);
    s:='bar(xb+';  setfillstyle(1,cf);        setlinestyle(0,0,0);
    str(xks,s1); s:=s+s1+',yb+';
    str(yks,s1); s:=s+s1+',xb+';
    str(xk,s1);  s:=s+s1+',yb+';
    str(yk,s1);  s:=s+s1+');';
    no:=no+1;
    apr[no]:=s;
    if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
    if no=200 then writ;

    xks:=xk; yks:=yk;  sc:=cf;
    putpixel(xk,yk,15);
     end else begin
     xks:=xk;  yks:=yk;  end;

   end;
   goto 100;
   130: if ch=chr(10) then begin
      if le=0 then begin
  setcolor(cl);
  setfillstyle(tf,cf);       setlinestyle(tl,0,rl);   setwritemode(0);
  gl:=0;  glo:=0;

131:  bar3d(xks,yks,xk,yk,gl,topon);
  ch:=readkey; if ch=chr(0) then ch:=readkey;
  if ch=chr(72) then begin gl:=gl+1; goto 132; end;
  if ch=chr(80) then begin gl:=gl-1; goto 132; end;
  if ch=chr(79) then goto 133;
  sound(3000); delay(10); nosound;
  goto 131;
132: setcolor(sc);
  bar3d(xks,yks,xk,yk,glo,topon);
     setcolor(cl);
     glo:=gl;
     goto 131;

133:      sound(100); delay(10); nosound;

  s:='bar3d(xb+';  setfillstyle(1,cf);   setlinestyle(0,0,0);
  str(xks,s1); s:=s+s1+',yb+';
  str(yks,s1); s:=s+s1+',xb+';
  str(xk,s1);  s:=s+s1+',yb+';
  str(yk,s1);  s:=s+s1+',';
  str(gl,s1);  s:=s+s1+',topon);';
  no:=no+1;
  apr[no]:=s;
  if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
  if no=200 then writ;

  xks:=xk; yks:=yk;
  putpixel(xk,yk,15);  sc:=cl;
   end else begin
   xks:=xk;  yks:=yk;  end;

       end;

   100: setwritemode(0);
   end;

   {   pисование контуpа пpямоугольника    }

procedure  prec;
label 100,110,120,130;
   begin
 setwritemode(1);
 setlinestyle(0,0,0);
 if ch=chr(67) then begin
   if ldr=1 then begin
          setcolor(15);
          rectangle(xks,yks,xk,yk);
          end;
   xks:=xk; yks:=yk; goto 100;
   end;
 if ch=chr(10) then goto 130;
 if ch=chr(13) then goto 120;
 if le=1 then begin
 if ldr=1 then begin
    setcolor(15);
    rectangle(xks,yks,xk,yk);
    end;
   end;
 setcolor(15);
 if ch=chr(56) then ch:=chr(72);
 if ch=chr(54) then ch:=chr(77);
 if ch=chr(50) then ch:=chr(80);
 if ch=chr(52) then ch:=chr(75);
         move;
         if m=1 then begin
         if le=1 then if ldr=1 then begin
         setcolor(15);
         rectangle(xks,yks,xk,yk);
         end;
         goto 100; end;
 130: if ch=chr(10) then begin
      if le=0 then begin
  setcolor(cl);
  setfillstyle(tf,cf);  setlinestyle(tl,0,rl); setwritemode(0);
  bar3d(xks,yks,xk,yk,0,topoff);
  s:='bar3d(xb+';  setfillstyle(1,cf);         setlinestyle(0,0,0);
  str(xks,s1); s:=s+s1+',yb+';
  str(yks,s1); s:=s+s1+',xb+';
  str(xk,s1);  s:=s+s1+',yb+';
  str(yk,s1);  s:=s+s1+',0,topoff);';
  no:=no+1;
  apr[no]:=s;
  if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
  if no=200 then writ;

  xks:=xk; yks:=yk;
  putpixel(xk,yk,15);  sc:=cl;
   end else begin
   xks:=xk;  yks:=yk;  end;
   end;

   120: if ch=chr(13) then begin
       if le=0 then begin
  setcolor(cl);             setlinestyle(tl,0,rl); setwritemode(0);
  rectangle(xks,yks,xk,yk);
  s:='rectangle(xb+';       setlinestyle(0,0,0);
  str(xks,s1); s:=s+s1+',yb+';
  str(yks,s1); s:=s+s1+',xb+';
  str(xk,s1);  s:=s+s1+',yb+';
  str(yk,s1);  s:=s+s1+');';
  no:=no+1;
  apr[no]:=s;
  if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
  if no=200 then writ;

  xks:=xk; yks:=yk;
  putpixel(xk,yk,15); sc:=cl;
   end else begin
   xks:=xk;  yks:=yk;  end;
        end;
        goto 100;
   110:  setfillstyle(1,4);
         bar(265,326,373,332);
         sound(600); delay(300); nosound;
         setfillstyle(1,0);
         bar(265,326,373,332);
   100: setwritemode(0);
   end;


   {   pисование эллипса  }

procedure  pell;
label 100,120,130;
   begin
 setwritemode(1);
      if ch=chr(67) then begin
         if ldr=1 then begin
          setcolor(15);
          line(xks-abs(xk-xks),yks,xks,yks-abs(yk-yks));
          line(xks+abs(xk-xks),yks,xks,yks+abs(yk-yks));
          line(xks,yks-abs(yk-yks),xks+abs(xk-xks),yks);
          line(xks,yks+abs(yk-yks),xks-abs(xk-xks),yks);

          end;
    xks:=xk; yks:=yk; goto 100;
    end;
 if ch=chr(10) then goto 130;

 if ch=chr(13) then goto 120;
 if le=1 then begin
 if ldr=1 then begin
          setcolor(15);
          line(xks-abs(xk-xks),yks,xks,yks-abs(yk-yks));
          line(xks+abs(xk-xks),yks,xks,yks+abs(yk-yks));
          line(xks,yks-abs(yk-yks),xks+abs(xk-xks),yks);
          line(xks,yks+abs(yk-yks),xks-abs(xk-xks),yks);
    end;
    end;
 setcolor(8);
 if ch=chr(56) then ch:=chr(72);
 if ch=chr(54) then ch:=chr(77);
 if ch=chr(50) then ch:=chr(80);
 if ch=chr(52) then ch:=chr(75);
         move;
         if m=1 then begin
         if le=1 then if ldr=1 then begin
          setcolor(15);
          line(xks-abs(xk-xks),yks,xks,yks-abs(yk-yks));
          line(xks+abs(xk-xks),yks,xks,yks+abs(yk-yks));
          line(xks,yks-abs(yk-yks),xks+abs(xk-xks),yks);
          line(xks,yks+abs(yk-yks),xks-abs(xk-xks),yks);
          end;
         goto 100; end;

   120: if ch=chr(13) then begin
         if le=0 then begin
          setcolor(15);
          line(xks-abs(xk-xks),yks,xks,yks-abs(yk-yks));
          line(xks+abs(xk-xks),yks,xks,yks+abs(yk-yks));
          line(xks,yks-abs(yk-yks),xks+abs(xk-xks),yks);
          line(xks,yks+abs(yk-yks),xks-abs(xk-xks),yks);
      setwritemode(0);
    setcolor(cl);    setlinestyle(tl,0,rl);
     ellipse(xks,yks,0,360,abs(xk-xks),abs(yk-yks)); setlinestyle(0,0,0);
    s:='ellipse(xb+';
    str(xks,s1); s:=s+s1+',yb+';
    str(yks,s1); s:=s+s1+',0,360,';
    str(abs(xk-xks),s1);  s:=s+s1+',';
    str(abs(yk-yks),s1);  s:=s+s1+');';
    no:=no+1;
    apr[no]:=s;
    if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
    if no=200 then writ;
    putpixel(xk,yk,sc);
    xk:=xks; yk:=yks;
    sc:=getpixel(xk,yk);
    putpixel(xk,yk,15);
     end else begin
     xks:=xk;  yks:=yk;
      end;
         goto 100;
          end;
   130: if ch=chr(10) then begin
          if le=0 then begin
 setcolor(15);
          setcolor(15);
          line(xks-abs(xk-xks),yks,xks,yks-abs(yk-yks));
          line(xks+abs(xk-xks),yks,xks,yks+abs(yk-yks));
          line(xks,yks-abs(yk-yks),xks+abs(xk-xks),yks);
          line(xks,yks+abs(yk-yks),xks-abs(xk-xks),yks);
      setwritemode(0);
     setcolor(cl); setfillstyle(tf,cf); setlinestyle(tl,0,rl);
      fillellipse(xks,yks,abs(xk-xks),abs(yk-yks));   setfillstyle(1,cf);
     s:='fillellipse(xb+';              setlinestyle(0,0,0);
     str(xks,s1); s:=s+s1+',yb+';
     str(yks,s1); s:=s+s1+',';
     str(abs(xk-xks),s1);  s:=s+s1+',';
     str(abs(yk-yks),s1);  s:=s+s1+');';
     no:=no+1;
     apr[no]:=s;
     if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
     if no=200 then writ;
     putpixel(xk,yk,sc);
     xk:=xks; yk:=yks;
     sc:=getpixel(xk,yk);
     putpixel(xk,yk,15);
      end else begin
      xks:=xk;  yks:=yk;
       end;
           end;
   100: setwritemode(0);
   end;

{ определение координат для рисования дуги }

procedure koord;
var
  a,b,c,a1,b1,c1,x,y:real;
  x1,x2,y1,y2,fi1,fi2,fi3,fi4,fi,yt:real;
  k:integer;

  label 1,2,3;
  begin
  xo:=0; xo1:=0; xo2:=0; yo:=0; yo1:=0; yo2:=0;
  if xi2=xi1 then begin xi1:=xi1+1; xi2:=xi2-1;
                        goto 1;
  end;
  x1:=xi1; x2:=xi2; y1:=yi1; y2:=yi2;
  a:=(y1-y2)/(x2-x1);
  b:=((x2*x2-x1*x1)+(y2*y2-y1*y1))/(2*(x2-x1));
  c:=r*r-x1*x1-y1*y1;
  a1:=a*a+1;
  b1:=2*a*b-2*a*x1-2*y1;
  c1:=b*b-2*b*x1-c;
  y:=((-1)*b1+sqrt(abs(b1*b1-4*a1*c1)))/(2*a1);
  x:=y*a+b;
  xo1:=round(x);
  yo1:=round(y);
  y:=((-1)*b1-sqrt(abs(b1*b1-4*a1*c1)))/(2*a1);
  x:=y*a+b;
  xo2:=round(x);
  yo2:=round(y);
1:    { определение углов }
  x1:=xi1; x2:=xi2; y1:=yi1; y2:=yi2;
  x:=sqrt((xo1-xk)*(xo1-xk)+(yo1-yk)*(yo1-yk));
  y:=sqrt((xo2-xk)*(xo2-xk)+(yo2-yk)*(yo2-yk));

  if x>y then begin xo:=xo1; yo:=yo1; end else begin xo:=xo2; yo:=yo2; end;

  setcolor(8);
  if (yi1<>yo) and (yi2<>yo) then begin
  fi1:=90-arctan(abs((xi1-xo)/(yi1-yo)))*180/pi;
  fi2:=90-arctan(abs((xi2-xo)/(yi2-yo)))*180/pi;
  end;
  if (abs(fi1)>360) or (abs(fi2)>360) then goto 3;
  if ((xi1-xo)<0) and ((yi1-yo)<0) then fi1:=180-fi1;
  if ((xi1-xo)<0) and ((yi1-yo)>0) then fi1:=180+fi1;
  if ((xi1-xo)>0) and ((yi1-yo)>0) then fi1:=fi1*(-1);
  if ((xi2-xo)<0) and ((yi2-yo)<0) then fi2:=180-fi2;
  if ((xi2-xo)<0) and ((yi2-yo)>0) then fi2:=180+fi2;
  if ((xi2-xo)>0) and ((yi2-yo)>0) then fi2:=fi2*(-1);
  fi3:=fi1+180; fi4:=180+fi2; k:=0;
  if fi3>fi4 then begin
     if (fi2<0) and (fi1>0) and (fi1<90) then begin k:=1; goto 2; end;
     if (fi1<0) and (fi2<0) then begin k:=1; goto 2; end;
     if (fi2<0) and (round(fi1+fi2)<=180) then begin k:=0; goto 2; end;
     if (fi2<0) and (round(abs(360-fi1+fi2))>180) then begin k:=1; goto 2; end;
     if (fi1>0) and (fi2>0) and ((fi3-fi4)<180) then begin k:=1; goto 2; end;
  end;
  if (fi1<0) and ((fi4-fi3)>180) then begin k:=1; goto 2; end;
  if (fi2-fi1)>180 then begin k:=1; goto 2; end;

2:  if k=1 then begin x:=fi1; fi1:=fi2; fi2:=x; end;
  un:=round(fi1); uk:=round(fi2);
3: end;


   {   pисование дуги  }

procedure  duga;
label 100,120,130;
   begin
      if ch=chr(67) then begin
         if ldr=1 then begin
        pcf:=getpixel(xk,yk-1);
        setcolor(pcf);
         ellipse(xo,yo,un,uk,r,r);
        putpixel(xk,yk,15);
        end;
    xks:=xk; yks:=yk; goto 100;
    end;

 if (ch=chr(13)) or (ch=chr(10)) then goto 120;
 if t=2 then begin
 if ldr=1 then begin
     setcolor(pcf);
     ellipse(xo,yo,un,uk,r,r);
     end;
    end;
 setcolor(8);
 if ch=chr(56) then ch:=chr(72);
 if ch=chr(54) then ch:=chr(77);
 if ch=chr(50) then ch:=chr(80);
 if ch=chr(52) then ch:=chr(75);
         move;

      if m=1 then begin

      if t=2 then begin
      x4:=round((xi1+xi2)/2);
      y4:=round((yi1+yi2)/2);
      x1:=sqrt(((xi1-xk)*(xi1-xk)+(yi1-yk)*(yi1-yk)));
      x2:=sqrt(((xi2-xk)*(xi2-xk)+(yi2-yk)*(yi2-yk)));
      r1:=((x1+x2)/2);
      x1:=sqrt(((xi1-xi2)*(xi1-xi2)+(yi1-yi2)*(yi1-yi2)))/2;
      y1:=2000;
      x2:=x1*2;
      y2:=x1;
      if r2<0 then r2:=0;
      r:=0;
      if round(r1)<>round(x1) then r:=round(x1+1000/abs(r1-x1)) else goto 100;
      koord;
      if (xo=xi1) or (yo=yi1) then begin xo:=0; yo:=0; r:=0; goto 100; end;
      setcolor(cl);
      ellipse(xo,yo,un,uk,r,r);
      end;
         goto 100; end;

   120: if (ch=chr(13)) or (ch=chr(10)) then begin
     t:=t+1;
     if t=1 then begin
     setfillstyle(1,9);
  bar(145,getmaxy-23,190,getmaxy-17);
  sound(1300); delay(20); nosound;
       setcolor(8);
       line(xk-2,yk-2,xk+2,yk+2);
       line(xk-2,yk+2,xk+2,yk-2);
       xi1:=xk;yi1:=yk;
     pcf:=getpixel(xi1,yi1-1);
       goto 100;
       end;
     if t=2 then begin
     setfillstyle(1,9);
  bar(145,getmaxy-23,253,getmaxy-17);
  sound(1300); delay(20); nosound;
       setcolor(8);
       line(xk-2,yk-2,xk+2,yk+2);
       line(xk-2,yk+2,xk+2,yk-2);
       xi2:=xk; yi2:=yk;
       line(xi1,yi1,xi2,yi2);
       goto 100;
       end;
     if t=3 then begin
      t:=0;
      setcolor(sc); line(xi1,yi1,xi2,yi2);
      ellipse(xo,yo,un,uk,r,r);
      setcolor(cl);
      if ch=chr(10) then setfillstyle(tf,cf);

      if ch=chr(10) then sector(xo,yo,un,uk,r,r) else
      ellipse(xo,yo,un,uk,r,r);
      setfillstyle(1,cf);
      if no<195 then writ;
     str(un,s1); s:='un:='+s1+';';
     no:=no+1; apr[no]:=s;
     str(uk,s1); s:='uk:='+s1+';';
     no:=no+1; apr[no]:=s;
     s:='ellipse(xb+';
     str(xo,s1); s:=s+s1+',yb+';
     str(yo,s1); s:=s+s1+',un,uk,';
     str(r,s1);  s:=s+s1+',';
     str(r,s1);  s:=s+s1+');';
     r:=0; xo:=0; yo:=0; un:=0; uk:=0;
    no:=no+1;
    apr[no]:=s;
    if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
    putpixel(xk,yk,sc);
    xk:=xi1; yk:=yi1;
      goto 100;
      end;
end;


100:  end;

   {   Заполнение замкнутого контуpа   }

procedure  pflo;
   label 100,110,120;
   begin
if ch=chr(56) then ch:=chr(72);
if ch=chr(54) then ch:=chr(77);
if ch=chr(50) then ch:=chr(80);
if ch=chr(52) then ch:=chr(75);
         move;
         if m=1 then  goto 100;
  if ch=chr(10) then ch:=chr(13);
   120: if ch=chr(13) then begin
        if le=0 then begin
    setfillstyle(tf,cf);
    floodfill(xk,yk,cl);    setfillstyle(1,cf);
    s:='floodfill(xb+';
    str(xk,s1); s:=s+s1+',yb+';
    str(yk,s1); s:=s+s1+',';
    str(cl,s1);  s:=s+s1+');';
    no:=no+1;
    apr[no]:=s;
    if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
    if no=200 then writ;
    sc:=getpixel(xk,yk);
    xks:=xk; yks:=yk;
     end;
         end;
                  100: ;
   end;

   {   pисование  кpивой   }


procedure  pmov;
label 100,110,120,101,102;
   begin
if ch=chr(10) then ch:=chr(13);
if ch=chr(13) then goto 120;

setcolor(8);
if ch=chr(56) then ch:=chr(72);
if ch=chr(54) then ch:=chr(77);
if ch=chr(50) then ch:=chr(80);
if ch=chr(52) then ch:=chr(75);
if ch=chr(72) then begin xk:=xk; yk:=yk-1;
      if le=1 then goto 110;
      putpixel(xk,yk+1,sc);
      goto 101; end;
if ch=chr(77) then begin xk:=xk+1; yk:=yk;
      if le=1 then goto 110;
      putpixel(xk-1,yk,sc);
      goto 101; end;
if ch=chr(80) then begin xk:=xk; yk:=yk+1;
      if le=1 then goto 110;
      putpixel(xk,yk-1,sc);
      goto 101; end;
if ch=chr(75) then begin xk:=xk-1; yk:=yk;
      if le=1 then goto 110;
      putpixel(xk+1,yk,sc);
      goto 101; end;
if ch=chr(57) then begin xk:=xk+1; yk:=yk-1;
      if le=1 then goto 110;
      putpixel(xk-1,yk+1,sc);
      goto 101; end;
if ch=chr(51) then begin xk:=xk+1; yk:=yk+1;
      if le=1 then goto 110;
      putpixel(xk-1,yk-1,sc);
      goto 101; end;
if ch=chr(49) then begin xk:=xk-1; yk:=yk+1;
      if le=1 then goto 110;
      putpixel(xk+1,yk-1,sc);
      goto 101; end;
if ch=chr(55) then begin xk:=xk-1; yk:=yk-1;
      if le=1 then goto 110;
      putpixel(xk+1,yk+1,sc);
      goto 101; end;
      goto 120;
  101: sc:=getpixel(xk,yk);
      putpixel(xk,yk,15);
      goto 100;
   120: if ch=chr(13) then begin
       if le=0 then begin
   putpixel(xk,yk,cl);
   s:='putpixel(xb+';
   str(xk,s1); s:=s+s1+',yb+';
   str(yk,s1); s:=s+s1+',';
   str(cl,s1);  s:=s+s1+');';
   no:=no+1;
   apr[no]:=s;
   if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
   if no=200 then writ;
   xk:=xk; yk:=yk; sc:=cl; goto 100;
    end else begin
    xks:=xk;  yks:=yk;  putpixel(xk,yk,cl);
    setcolor(cl);  goto 100; end;
        end;
   110: if le=0 then goto 100;

setcolor(cl);
    putpixel(xk,yk,cl);
    s:='putpixel(xb+';
    str(xk,s1);  s:=s+s1+',yb+';
    str(yk,s1);  s:=s+s1+',';
    str(cl,s1);  s:=s+s1+');';
    no:=no+1;
    apr[no]:=s;
    if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
    if no=200 then writ;
    xks:=xk; yks:=yk;
   100: ;
   end;



{ ввод текста  }

procedure vvodtxt(var st:string);
var p:array[1..5298] of byte;
   begin
   getimage(100,290,600,310,p);
   setfillstyle(1,2);
   bar(100,290,600,310);
   setcolor(13);
   rectangle(150,293,595,305);
   outtextxy(105,295,'Текст:');
   moveto(160,295); setcolor(15);
   gread(st);
   putimage(100,290,p,normalput);
   end;


procedure  ptxt;
   label 10,100,110,120;
   begin
if ch=chr(56) then ch:=chr(72);
if ch=chr(54) then ch:=chr(77);
if ch=chr(50) then ch:=chr(80);
if ch=chr(52) then ch:=chr(75);
         move;
         if m=1 then goto 100;

   if ch=chr(10) then ch:=chr(13);

   120: if ch=chr(13) then begin
 if le=1 then begin
         vvodtxt(st);
         if st='' then goto 100;
         settextstyle(t1,t2,t3);
         setcolor(cl);
         outtextxy(xk,yk,st);
 10: ch:=readkey;
     if ch<>#0 then funckey:=false else
     begin
        funckey:=true;
        ch:=readkey;
     end;
     if ch=chr(52) then ch:=chr(75);
     if ch=chr(56) then ch:=chr(72);
     if ch=chr(50) then ch:=chr(80);
     if ch=chr(54) then ch:=chr(77);
     if ch=chr(77) then begin
     setcolor(getpixel(xk-1,yk));
     outtextxy(xk,yk,st);
     setcolor(cl); xk:=xk+1;
     outtextxy(xk,yk,st);
     goto 10;   end;
     if ch=chr(80) then begin
     setcolor(getpixel(xk-1,yk));
     outtextxy(xk,yk,st);
     setcolor(cl); yk:=yk+1;
     outtextxy(xk,yk,st);
     goto 10;       end;
     if ch=chr(75) then begin
     setcolor(getpixel(xk-1,yk));
     outtextxy(xk,yk,st);
     setcolor(cl); xk:=xk-1;
     outtextxy(xk,yk,st);
     goto 10;      end;
     if ch=chr(72) then begin
     setcolor(getpixel(xk-1,yk));
     outtextxy(xk,yk,st);
     setcolor(cl); yk:=yk-1;
     outtextxy(xk,yk,st);
     goto 10;          end;
     if ch=chr(67) then begin
                 ci:=getpixel(xk-4,yk-4);
                 setcolor(ci);
                 outtextxy(xk,yk,st);
         settextstyle(0,0,1); le:=0;
          setfillstyle(1,0);
          bar(145,326,253,332);
          sound(1300); delay(20); nosound;


                 goto 100;
                 end;
  if ch=chr(10) then ch:=chr(13);
  if ch=chr(13) then begin
         s:='outtextxy(xb+';
         str(xk,s1); s:=s+s1+',yb+';
         str(yk,s1); s:=s+s1+','''+st+''');';
         no:=no+1;
         apr[no]:=s;
         if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
         if no=200 then writ;
         xks:=xk; yks:=yk;
         settextstyle(0,0,1); le:=0;
          setfillstyle(1,0);
          bar(145,326,253,332);
          sound(1300); delay(20); nosound;
         goto 100;
         end;
         goto 10;
          end;
  end;
            100: ;
   end;

{ изменения типа закраски }

   procedure tipfon(var ci:integer);
  var
   p:array[1..10702] of byte;
          xc,yc:integer;
    label 10,20;
   begin
 setfillstyle(1,1);
 setcolor(9);
 getimage(500,120,610,310,p);
 bar(500,120,610,310);
 outtextxy(510,130,'ВЫБОР  ТИПА');
 for i:=0 to 11 do begin
 setfillstyle(i,10); bar(510,150+i*10,600,156+i*10); end;
 setcolor(15);
 xc:=505; yc:=148;ci:=0;
 rectangle(xc,yc,xc+99,yc+10);
  10: ch:=readkey;
if ch<>#0 then funckey:=false else
begin
   funckey:=true;
   ch:=readkey;
end;
if ch=chr(72) then begin
setcolor(1);  rectangle(xc,yc,xc+99,yc+10);   yc:=yc-10;  ci:=ci-1;
if yc<147 then begin ci:=11;  yc:=258; end;
setcolor(15);  rectangle(xc,yc,xc+99,yc+10);
                   end;
if ch=chr(80) then begin
setcolor(1);  rectangle(xc,yc,xc+99,yc+10);   yc:=yc+10;  ci:=ci+1;
if yc>259 then begin ci:=0;  yc:=148; end;
setcolor(15);  rectangle(xc,yc,xc+99,yc+10);
                   end;
if ch=chr(27) then begin ci:=100; goto 20; end;
if ch=chr(13) then goto 20;
goto 10;
20: putimage(500,120,p,normalput);
    end;


{ изменение типа линии }
   procedure tiplin(var ci:integer);
    var
   p:array[1..10702] of byte;
        xc,yc:integer;
    label 10,20;
   begin
 setfillstyle(1,1);
 setcolor(9);
 getimage(500,120,610,310,p);
 bar(500,120,610,310); setcolor(10);
 outtextxy(510,130,'ВЫБОР ЦВЕТА');

 setlinestyle(0,0,1); line(510,153,600,153);
 setlinestyle(1,0,1); line(510,163,600,163);
 setlinestyle(2,0,1); line(510,173,600,173);
 setlinestyle(3,0,1); line(510,183,600,183);
 setlinestyle(0,0,3); line(510,193,600,193);
 setlinestyle(1,0,3); line(510,203,600,203);
 setlinestyle(2,0,3); line(510,213,600,213);
 setlinestyle(3,0,3); line(510,223,600,223);
 setcolor(15);  setlinestyle(0,0,0);
 xc:=505; yc:=148;ci:=1;
 rectangle(xc,yc,xc+99,yc+7);
  10: ch:=readkey;
if ch<>#0 then funckey:=false else
begin
   funckey:=true;
   ch:=readkey;
end;
if ch=chr(72) then begin
setcolor(1);  rectangle(xc,yc,xc+99,yc+7);   yc:=yc-10;  ci:=ci-1;
if yc<147 then begin ci:=8;  yc:=218; end;
setcolor(15);  rectangle(xc,yc,xc+99,yc+7);
                   end;
if ch=chr(80) then begin
setcolor(1);  rectangle(xc,yc,xc+99,yc+7);   yc:=yc+10;  ci:=ci+1;
if yc>219 then begin ci:=0;  yc:=148; end;
setcolor(15);  rectangle(xc,yc,xc+99,yc+7);
                   end;
if ch=chr(27) then begin ci:=100; goto 20; end;
if ch=chr(13) then goto 20;
goto 10;
20: putimage(500,120,p,normalput);
    end;
    {   изменение шpифта    }

   procedure textst(var t1,t2,t3:integer);
    var
   p:array[1..10702] of byte;
        xc,yc:integer;
    label 10,20,30,40,50;
   begin
  setfillstyle(1,1);
  setcolor(9);
  getimage(500,120,610,310,p);
  bar(500,120,610,310);
  outtextxy(510,130,'ВЫБОР ШРИФТА');
  setcolor(13); outtextxy(510,150,'Default');
                outtextxy(510,170,'Triplex');
                outtextxy(510,190,'Small');
                outtextxy(510,210,'SanSerif');
                outtextxy(510,230,'Gothic');
  setcolor(15);
  xc:=505; yc:=148;ci:=0;
  rectangle(xc,yc,xc+99,yc+10);
  10: ch:=readkey;
      if ch<>#0 then funckey:=false else
      begin
         funckey:=true;
         ch:=readkey;
      end;
      if ch=chr(72) then begin
      setcolor(1);  rectangle(xc,yc,xc+99,yc+10);   yc:=yc-20;  ci:=ci-1;
      if yc<147 then begin ci:=4;  yc:=228; end;
      setcolor(15);  rectangle(xc,yc,xc+99,yc+10);
                         end;
      if ch=chr(80) then begin
      setcolor(1);  rectangle(xc,yc,xc+99,yc+10);   yc:=yc+20;  ci:=ci+1;
      if yc>229 then begin ci:=0;  yc:=148; end;
      setcolor(15);  rectangle(xc,yc,xc+99,yc+10);
                         end;
      if ch=chr(27) then goto 20;
      if ch=chr(13) then begin
                         t1:=ci;
                         goto 30;
                         end;
      goto 10;
      30: setcolor(9);
       bar(500,120,610,310);
       outtextxy(510,130,' ОРИЕHТАЦИЯ  ');
       setcolor(13); outtextxy(510,150,'Horizdir');
                     outtextxy(510,170,'Vertdir');
       setcolor(15);
       xc:=505; yc:=148;ci:=0;
       rectangle(xc,yc,xc+99,yc+10);
  40: ch:=readkey;
      if ch<>#0 then funckey:=false else
      begin
         funckey:=true;
         ch:=readkey;
      end;
      if ch=chr(72) then begin
      setcolor(1);  rectangle(xc,yc,xc+99,yc+10);   yc:=yc-20;  ci:=ci-1;
      if yc<147 then begin ci:=1;  yc:=168; end;
      setcolor(15);  rectangle(xc,yc,xc+99,yc+10);
                         end;
      if ch=chr(80) then begin
      setcolor(1);  rectangle(xc,yc,xc+99,yc+10);   yc:=yc+20;  ci:=ci+1;
      if yc>169 then begin ci:=0;  yc:=148; end;
      setcolor(15);  rectangle(xc,yc,xc+99,yc+10);
                         end;
      if ch=chr(27) then goto 20;
      if ch=chr(13) then begin
                         t2:=ci;
                         goto 50;
                         end;
      goto 40;
      50:  setfillstyle(1,4); setcolor(14);
           bar(510,200,600,300);
           outtextxy(520,220,'Размеp :');
           rectangle(520,240,590,270);
           moveto(530,255); gread(s);
           if s='' then s:='1';
           val(s,ci,i);
      s:='settextstyle(';
      str(t1,s1);  s:=s+s1+',';
      str(t2,s1);  s:=s+s1+',';
      str(ci,s1);  s:=s+s1+');';
      no:=no+1;
      apr[no]:=s;
      if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
      if no=200 then writ;
      t3:=ci;
      case t1 of
       0: s:='default   ';
       1: s:='triplex   ';
       2: s:='small     ';
       3: s:='sanserif  ';
       4: s:='gothic    ';
      end;
      case t2 of
       0: s:=s+'g';
       1: s:=s+'v';
      end;
      s:=s+s1;
      setcolor(7); setfillstyle(1,0);
      bar3d(264,getmaxy-24,374,getmaxy-16,0,topon);
      setcolor(10); outtextxy(267,getmaxy-23,s);
    20: ;
            putimage(500,120,p,normalput);
            end;

{ процедура поддержки верхнего меню }

   procedure menu;
   var
      xm,ym,xs,ys,i,j:integer;
   label 1,10,20;
   begin
   1:   xm:=1; ym:=1;   i:=1;
      setfillstyle(1,14); setcolor(1);
      bar(xm+1,ym+1,xm+67,ym+10);
      outtextxy(xm+5,ym+2,am[1]);
  10: ch:=readkey;
      if ch<>#0 then funckey:=false else
      begin
         funckey:=true;
         ch:=readkey;
      end;
      if ch=chr(59) then begin help(0); goto 10; end;
      if ch=chr(94) then begin help(1); goto 10; end;
      if ch=chr(27) then begin
   sound(100); delay(250); nosound;
   setfillstyle(1,4); setcolor(14);
   bar(xm+1,ym+1,xm+67,ym+10);
   outtextxy(xm+5,ym+2,am[i]);
   goto 20;
   end;
      if ch=chr(75) then begin
   sound(750); delay(15); nosound;
   setfillstyle(1,4); setcolor(14);
   if i=reg then begin setfillstyle(1,10); setcolor(4);  end;
   bar(xm+1,ym+1,xm+67,ym+10);
   outtextxy(xm+5,ym+2,am[i]);
   xm:=xm-70;
   i:=i-1;
   if xm<0 then begin
                xm:=561; i:=9;
                end;
   setfillstyle(1,14); setcolor(1);
   bar(xm+1,ym+1,xm+67,ym+10);
   outtextxy(xm+5,ym+2,am[i]);

   goto 10;
   end;
      if ch=chr(77) then begin
   sound(750); delay(15); nosound;
   setfillstyle(1,4); setcolor(14);
   if i=reg then begin setfillstyle(1,10); setcolor(4);  end;
   bar(xm+1,ym+1,xm+67,ym+10);
   outtextxy(xm+5,ym+2,am[i]);
   xm:=xm+70;
   i:=i+1;
   if xm>600 then begin
                xm:=1; i:=1;
                end;
   setfillstyle(1,14); setcolor(1);
   bar(xm+1,ym+1,xm+67,ym+10);
   outtextxy(xm+5,ym+2,am[i]);

   goto 10;
   end;
      if ch=chr(13) then begin
   sound(250); delay(100); nosound;
   setfillstyle(1,4); setcolor(15);
   xs:=1; ys:=1;
   for j:=1 to 9 do begin
   bar(xs,ys,xs+76,ys+11);
   rectangle(xs,ys,xs+68,ys+11); setcolor(14);
   outtextxy(xs+5,ys+2,am[j]);   setcolor(15);
   xs:=xs+70;
   end;
   setfillstyle(1,10); setcolor(4);
   bar(xm+1,ym+1,xm+67,ym+10);
   outtextxy(xm+5,ym+2,am[i]);
   reg:=i;
   if reg=4 then begin
   writ; close(f); polynom(xk,yk,xsp,ysp,cl,cf,tl,rl,tf);
   assign(f,'progr.pas'); append(f);   goto 1; end;

   goto 20;
   end;
        goto 10;

   20: ;
   end;
   procedure vosst;
   begin
      setcolor(15);
      setfillstyle(1,2);
      xp:=4; yp:=getmaxy+1-15;
      for i:=1 to 10 do begin
      bar(xp,yp,xp+60,yp+11);
      if i=10 then line(xp+18,yp,xp+18,yp+11) else line(xp+10,yp,xp+10,yp+11);
      str(i,s);
      rectangle(xp,yp,xp+60,yp+11); setcolor(14);
      outtextxy(xp+3,yp+2,s); setcolor(13);
      if i=10 then outtextxy(xp+24,yp+2,ap[i]) else outtextxy(xp+15,yp+2,ap[i]);   setcolor(15);
      xp:=xp+63;
      end;
   end;
   procedure ust;
    begin
     setfillstyle(1,0); floodfill(300,150,0);
     for i:=1 to 200 do apr[i]:=' ';
          apr[1]:='program progr;';
          apr[2]:='uses crt,graph,slaid,expander;';
          apr[3]:='var';
          apr[4]:='    funckey:boolean;';
          apr[5]:='    grmode,grdriver:integer;  ';
          apr[6]:='    errcode,xb,yb,un,uk:integer;          ';
          apr[7]:='    ch:char;';
          apr[8]:='    f1,f2:text;';
          apr[9]:='    s:string;';
          apr[10]:='    p:array[1..15000] of byte;';
          apr[11]:='procedure screen1;';
          apr[12]:= 'begin;              ';
          no:=12;         ksk:=1;
      am[1]:='Отрезок';         am[2]:='Квадpат';      am[3]:='Пpямоуг.';
      am[4]:='Контур';          am[6]:='Закpаска';     am[5]:='Эллипс';
      am[7]:='Линия';        am[8]:='Текст';    am[9]:='Дуга';
      ap[1]:='Help';       ap[2]:='Menu';         ap[3]:='Save';
      ap[4]:='LineC';         ap[5]:='FillC';     ap[6]:='Font';
      ap[7]:='LinDrw';        ap[8]:='NoWrite '; ap[9]:='Erase'; ap[10]:='Quit';
      xm:=1; ym:=1;  le:=0;     ldr:=1;     sc:=0; cl:=0; cf:=0;  nowr:=0;
      t1:=0; t2:=0; t3:=1;  tim:=2;
      setfillstyle(1,4); setcolor(15);
      for i:=1 to 9 do begin
      bar(xm,ym,xm+76,ym+11);
      rectangle(xm,ym,xm+68,ym+11); setcolor(14);
      outtextxy(xm+5,ym+2,am[i]);   setcolor(15);
      xm:=xm+70;
      end;
      xp:=4; yp:=getmaxy+1-15;
      setfillstyle(1,2);
      for i:=1 to 10 do begin
      bar(xp,yp,xp+60,yp+11);
      if i=10 then line(xp+18,yp,xp+18,yp+11) else line(xp+10,yp,xp+10,yp+11);
      str(i,s);
      rectangle(xp,yp,xp+60,yp+11); setcolor(14);
      outtextxy(xp+3,yp+2,s); setcolor(13);
      if i=10 then outtextxy(xp+24,yp+2,ap[i]) else outtextxy(xp+15,yp+2,ap[i]);   setcolor(15);
      xp:=xp+63;
      end;
      setcolor(9);
      rectangle(1,14,638,getmaxy+1-27);
      setcolor(7);
      rectangle(54,getmaxy+1-25,134,getmaxy+9-25);
      xp:=144; yp:=getmaxy+1-25; setcolor(7);
      for i:=2 to 5 do begin
      rectangle(xp,yp,xp+110,yp+8);
      xp:=xp+120;
      end;
      setcolor(10); outtextxy(267,getmaxy+1-24,'default    g1');
      settextstyle(0,0,1);
      setfillstyle(1,10); setlinestyle(0,0,0);
      bar(55,getmaxy+1-24,133,getmaxy+1-18);
      setcolor(10); setfillstyle(1,0);
      bar(1,getmaxy+1-24,50,getmaxy+1-18);
      outtextxy(1,getmaxy+1-24,'OR');


    end;

   {  ГОЛОВНОЙ МОДУЛЬ }

   begin

 1:   grdriver:=detect;
      initgraph(grdriver,grmode,'');
      tit;
      i:=getgraphmode;
      {  если i=1 т.е. обнаружен терминал EGA, то
         графический режим принудительно устанивливается
         640x350 и переменная tip принимает значение 0 }
      if i<>1 then tip1:=1 else tip1:=0;
      if (i=1) and (tip=1) then tip:=0;
      if tip=0 then begin setgraphmode(1);
      setactivepage(1);
      setvisualpage(1);
      end else setgraphmode(VGAHI);
      plus:=1;      reg:=0; tf:=1; tl:=0; rl:=0;  t:=0;
                          assign(f,'progr.pas');
                          rewrite(f);

 50:  ust;
      menu;
      xk:=320;  yk:=160;   xks:=xk; yks:=yk;     xsp:=5; ysp:=5;
      putpixel(xk+2,yk+15,15);
      setcolor(10); outtextxy(595,18,'Pg 1  ');
  10:
      setviewport(2,15,637,getmaxy+1-28,clipon);
      setcolor(0); outtextxy(593,13,'█████'); outtextxy(593,23,'█████');
      setcolor(9);
      s:='X:';  str(xk,s1);  s:=s+s1;  outtextxy(593,13,s);
      s:='Y:';  str(yk,s1);  s:=s+s1;  outtextxy(593,23,s);
      setviewport(0,0,getmaxx,getmaxy,clipon);
      if plus=1 then begin
      setwritemode(1);
      setcolor(15);
      line(xk,yk+15,xk+4,yk+15);
      line(xk+2,yk+17,xk+2,yk+13);
      end;
      ch:=readkey;
      if ch<>#0 then funckey:=false else
      begin
         funckey:=true;
         ch:=readkey;
      end;
      if plus=1 then begin
      line(xk+2,yk+17,xk+2,yk+13);
      line(xk,yk+15,xk+4,yk+15);
      setwritemode(0);
      end;
  { вывод маркера в виде '+' или '.' }
      if (ch=chr(43)) and (funckey=false) then begin
      if plus=1 then plus:=0 else plus:=1;
      sound(700);delay(10);
      sound(600);delay(10);
      sound(500);delay(10);
      sound(400);delay(10);
      sound(300);delay(10);nosound; goto 10; end;

  { Сохранить слайд на диск }
   9:   if (ch=chr(24)) and (funckey=true) then begin
      saveslaid(xk,yk,sc,xsp,ysp);
      vosst;
      goto 10;
      end;
  { Распечатать слайд }
      if (ch=chr(17)) and (funckey=true) then begin
      writeslaid(xk,yk,sc,xsp,ysp);
      vosst;
      goto 10;
      end;
  { Цветовой сдвиг изображения }
      if (ch=chr(46)) and (funckey=true) then begin
      writ; close(f);
        palitra(xk,yk,sc,xsp,ysp);
      append(f);
      vosst;
      goto 10;
      end;
  { Вывести слайд на экран }
      if (ch=chr(23)) and (funckey=true) then begin
      writ; close(f);
        inpslaid(xk,yk,sc,xsp,ysp,tip);
       append(f);
      writeln(f,'setcolor(',cl,');');
      writeln(f,'setfillstyle(',tf,',',cf,');');
      close(f); append(f);
      vosst;
      goto 10;
      end;
  { Звездное небо }
      if (ch=chr(25)) and (funckey=true) then begin
        pesok(xk,yk,sc,xsp,ysp);
      vosst;
      goto 10;
      end;
  { Ввод текста из файла }
      if (ch=chr(20)) and (funckey=true) then begin
      writ; close(f);
      readtxt(xk,yk,sc,cl,cf,t1,t2,t3,tip,xsp,ysp);
      vosst;
      append(f);
      goto 10;
      end;
  { Замена цветов на цвет фона }
      if (ch=chr(32)) and (funckey=true) then begin
      writ; close(f);
        fon(xk,yk,sc,xsp,ysp,cf);
      append(f);
      vosst;
      goto 10;
      end;
  { Замена цветов  }
      if (ch=chr(44)) and (funckey=true) then begin
      writ; close(f);
        chcol(xk,yk,sc,xsp,ysp,cf);
      append(f);
      vosst;
      goto 10;
      end;
  { Ножницы  }
      if (ch=chr(50)) and (funckey=true) then begin
        writ;
        close(f);
        stampm(xk,yk,sc,xsp,ysp,tim);
        append(f);
      vosst;
      goto 10;
      end;
  { Штамп  }
      if (ch=chr(31)) and (funckey=true) then begin
        writ;
        close(f);
        stamp(xk,yk,sc,xsp,ysp,tim);
        append(f);
      vosst;
      goto 10;
      end;
  { Смена ориентации по горизонтали }
      if (ch=chr(115)) and (funckey=true) then begin
      writ; close(f);
      orihor(xk,yk,sc,xsp,ysp);
      append(f);
      vosst;
      goto 10;
      end;
  { Редактирование по пикселям }
      if (ch=chr(48)) and (funckey=true) then begin
      writ; close(f);
      pix(xk,yk,sc,xsp,ysp,cl);
      append(f);
      vosst;
      goto 10;
      end;
  { Смена ориентации по вертикали }
      if (ch=chr(116)) and (funckey=true) then begin
      writ; close(f);
      oriver(xk,yk,sc,xsp,ysp);
      append(f);
      vosst;
      goto 10;
      end;
  { Смена принципа наложения изображения в ножницах и штампе }
      if (ch=chr(98)) and (funckey=true) then begin
      tipimage(tim);
      goto 10;
      end;
  { Изменить палитру }
      if (ch=chr(37)) and (funckey=true) then begin
        if tip1=1 then begin
          writ;
          close(f);
          RGBpalitra;
          vosst;
          append(f);
        end;
      goto 10;
      end;
  { Подсветить положение курсора }
      if ch=' ' then begin
         setcolor(15);
         setwritemode(1);
         xk:=xk+2; yk:=yk+15;
         line(xk-8,yk,xk+8,yk);
         line(xk,yk-8,xk,yk+8);
         delay(40);
         line(xk-8,yk,xk+8,yk);
         line(xk,yk-8,xk,yk+8);
         setwritemode(0);
         xk:=xk-2; yk:=yk-15;
         goto 10; end;
{ Вызов функций модуля EXTENDED }
      if (ch=chr(120)) and (funckey=true) then begin extend1; goto 10; end;
      if (ch=chr(121)) and (funckey=true) then begin
         writ;
         close(f);
         extend2;
         append(f);
         goto 10; end;
      if (ch=chr(122)) and (funckey=true) then begin extend3; goto 10; end;
      if (ch=chr(123)) and (funckey=true) then begin extend4; goto 10; end;
      if (ch=chr(124)) and (funckey=true) then begin extend5; goto 10; end;
      if (ch=chr(125)) and (funckey=true) then begin extend6; goto 10; end;
      if (ch=chr(126)) and (funckey=true) then begin extend7; goto 10; end;
      if (ch=chr(127)) and (funckey=true) then begin extend8; goto 10; end;
      if (ch=chr(128)) and (funckey=true) then begin extend9; goto 10; end;
{ Стирание изображения }
      if (ch=chr(19)) and (funckey=true) then begin
        writ; close(f);
        last(xk,yk,sc,xsp,ysp,cf,tf);
        append(f);
      vosst;
      goto 10;
      end;

{ Просмотр готовой программы }
      if ch=chr(38) then begin
        look:=1;
        writ; close(f);
        help(0);
        append(f);
        look:=0; goto 10; end;

{ Просмотр полной помощи }
      if ch=chr(59) then begin help(0); goto 10; end;
{ Просмотр краткой помощи }
      if ch=chr(94) then begin help(1); goto 10; end;
{ Вызов верхнего меню }
      if ch=chr(60) then begin menu;  goto 10; end;
{ Вызов верхнего меню 1 }
      if ch=chr(105) then begin menu1(i);
      case i of
      1: begin ch:=chr(023); funckey:=true; goto 9; end;
      2: begin ch:=chr(024); funckey:=true; goto 9; end;
      3: begin ch:=chr(017); funckey:=true; goto 9; end;
      4: begin ch:=chr(020); funckey:=true; goto 9; end;
      5: begin ch:=chr(038); funckey:=true; goto 9; end;
      6: begin ch:=chr(048); funckey:=true; goto 9; end;
      7: begin ch:=chr(019); funckey:=true; goto 9; end;
      8: begin ch:=chr(037); funckey:=true; goto 9; end;
      9: begin ch:=chr(115); funckey:=true; goto 9; end;
     10: begin ch:=chr(116); funckey:=true; goto 9; end;
     11: begin ch:=chr(025); funckey:=true; goto 9; end;
     12: begin ch:=chr(032); funckey:=true; goto 9; end;
     13: begin ch:=chr(046); funckey:=true; goto 9; end;
     end;
     goto 10;
      end;
{ Вызов верхнего меню 2 }
      if ch=chr(95) then begin menu2(i);
      case i of
      1: begin ch:=chr(044); funckey:=true; goto 9; end;
      2: begin ch:=chr(031); funckey:=true; goto 9; end;
      3: begin ch:=chr(050); funckey:=true; goto 9; end;
      4: begin ch:=chr(098); funckey:=true; goto 9; end;
      5: begin goto 11; end;
      6: begin goto 11; end;
      7: begin goto 11; end;
      8: begin goto 11; end;
      9: begin goto 11; end;
     10: begin goto 11; end;
     11: begin goto 11; end;
     12: begin goto 11; end;
     13: begin goto 11; end;
     end;
     goto 10;
  11:
setcolor(1);
outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
setcolor(10);
outtextxy(1,getmaxy-10,'    Прошу прощения, но этот пункт альтернативного меню пока не активен !!!!!    ');
ch:=readkey; if ch=chr(0) then begin funckey:=true; ch:=readkey; end;
vosst;
goto 10;
      end;


{ Сохранение данных }
  20: if ch=chr(61) then begin
          sound(800); delay(100); nosound;
          if apr[1]=' ' then goto 10;
          for i:=1 to 200 do begin;
             if apr[i]=' ' then goto 30;
             writeln(f,apr[i]);
          end;
  30:     for i:=1 to 200 do apr[i]:=' ';
          no:=0;
      goto 10; end;

{ Установка цвета линии }
  if ch=chr(62) then begin setcolor(9); outtextxy(196,getmaxy+1-13,'4');
  colors(ci);
  if ci=100 then begin
    setcolor(14); outtextxy(196,getmaxy+1-13,'4');
    goto 10;
    end;
  str(ci,s);
  s:='setcolor('+s+');';
  no:=no+1;
  apr[no]:=s;
    if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
  setcolor(14); outtextxy(196,getmaxy+1-13,'4');
  cl:=ci;
  setfillstyle(1,cl);
  bar(385,getmaxy+1-24,493,getmaxy+1-18);
  if cl=10 then setcolor(15) else setcolor(10);setlinestyle(tl,0,rl);line(387,getmaxy-20,491,getmaxy-20);setlinestyle(0,0,0);
  goto 10; end;
  { Установка типа линии }
 if ch=chr(97) then begin setcolor(9); outtextxy(196,getmaxy+1-13,'4');
  tiplin(ci);
  if ci=100 then begin
    setcolor(14); outtextxy(196,getmaxy+1-13,'4');
    goto 10;
    end;
  case ci of
     1: begin tipl:=0; vell:=0; end;
     2: begin tipl:=1; vell:=0; end;
     3: begin tipl:=2; vell:=0; end;
     4: begin tipl:=3; vell:=0; end;
     5: begin tipl:=0; vell:=3; end;
     6: begin tipl:=1; vell:=3; end;
     7: begin tipl:=2; vell:=3; end;
     8: begin tipl:=3; vell:=3; end;
 end;
  str(tipl,s10); str(vell,s11);
  s:='setlinestyle('+s10+',0,'+s11+');';
  no:=no+1;
  apr[no]:=s;
    if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
  setcolor(14); outtextxy(196,getmaxy-13+1,'4');
  tl:=tipl; rl:=vell;
  setfillstyle(1,cl);
  bar(385,getmaxy-23,493,getmaxy-17);
  if cl=10 then setcolor(15) else setcolor(10); setlinestyle(tl,0,rl);line(387,getmaxy-20,491,getmaxy-20);setlinestyle(0,0,0);
  goto 10; end;
  { Установка цвета линии по пикселю }
  if ch=chr(107) then begin
  ci:=sc;
  str(ci,s);
  cl:=ci;
  if no>=198 then writ;
  s:='setcolor('+s+');';
  no:=no+1;
  apr[no]:=s;
  if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
  cl:=ci;
  setfillstyle(1,cl);
  bar(385,getmaxy+1-24,493,getmaxy+1-18);
  if cl=10 then setcolor(15) else setcolor(10);setlinestyle(tl,0,rl);line(387,getmaxy-20,491,getmaxy-20);setlinestyle(0,0,0);
  goto 10; end;

   { Установка цвета и типа фона }
  if ch=chr(63) then begin setcolor(9); outtextxy(259,getmaxy-12,'5');colors(ci);
  if ci=100 then goto 10;
  str(ci,s);
  cf:=ci;
  tipfon(ci);
  if ci=100 then goto 10;
  str(ci,s10);
  tf:=ci;
  s:='setfillstyle('+s10+','+s+');';
  no:=no+1;
  setcolor(14); outtextxy(259,getmaxy-12,'5');
  setfillstyle(tf,cf);
  bar(505,getmaxy-23,613,getmaxy-17); setfillstyle(1,cf);
  apr[no]:=s;
    if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
  goto 10; end;

{ Установка цвета фона по пикселю }
  if ch=chr(108) then begin
  ci:=sc;
  str(tf,s);
  cf:=ci;
  str(cf,s10);
  s:='setfillstyle('+s+','+s10+');';
  if no>=198 then writ;
  no:=no+1;
  setfillstyle(tf,cf);
  bar(505,getmaxy-23,613,getmaxy-17); setfillstyle(1,cf);
  apr[no]:=s;
    if nowr=1 then begin apr[no]:=' '; no:=no-1; end;
  goto 10; end;
{ Установка типа текста }
      if ch=chr(64) then begin  textst(t1,t2,t3); goto 10; end;
{ Переключение режимов LineDraw /NO }
      if ch=chr(65) then begin
  if ldr=1 then ldr:=0 else ldr:=1;
  if ldr=1 then setfillstyle(1,10) else setfillstyle(1,0);
      bar(55,getmaxy+1-24,133,getmaxy+1-18);
  sound(900); delay(40); nosound;
  goto 10; end;
{ Клавиша ENTER }
      if ch=chr(13) then begin
  if le=1 then le:=0 else le:=1;
  if reg=9 then le:=0;
  if le=1 then
     setfillstyle(1,9)
     else setfillstyle(1,0);
  bar(145,getmaxy-23,253,getmaxy-17);
  sound(1300); delay(20); nosound;
  goto 70; end;

{ Клавиша CTRL ENTER }
      if ch=chr(10) then begin
  if le=1 then le:=0 else le:=1;
  if le=1 then
     setfillstyle(1,9)
     else setfillstyle(1,0);
  bar(145,getmaxy-23,253,getmaxy-17);
  sound(1300); delay(20); nosound;
  goto 70; end;
{ Удаление последней операции }
      if ch=chr(67) then begin
       setfillstyle(1,0);
    bar(145,getmaxy-23,253,getmaxy-17);
    sound(1300); delay(15); nosound;
    le:=0;  goto 70;
    end;
{ Вставка комментария в текст программы }
      if ch=chr(82) then begin
   sound(700); delay(15); nosound;
   vvodtxt(s);
   if s='' then goto 10;
   if s=' ' then goto 10;
   no:=no+1; apr[no]:=s;
   if no=200 then writ;
   goto 10;
   end;
{ Очистка экрана }
      if ch=chr(83) then begin
                         sound(1300); delay(455); nosound;
      ch:=readkey;
      if ch<>#0 then funckey:=false else
      begin
         funckey:=true;
         ch:=readkey;
      end;
      if ch=chr(83) then begin setfillstyle(1,0); bar(2,15,637,getmaxy-27); no:=no+1;
      setcolor(0); outtextxy(595,18,'██████');   str(ksk,s1);
      setcolor(10); outtextxy(595,18,'Pg '+s1+'  ');
      apr[no]:='cleardevice;'; sound(300); delay(250); nosound;
      if no=200 then writ;  end;
         goto 10;
         end;
{ Переключение режимов WRITE / NOWRITE }
   if ch=chr(66) then begin
   if nowr=0 then begin nowr:=1;  setfillstyle(1,9);
                        setcolor(0); end else  begin
                         nowr:=0;  setfillstyle(1,2);
                        setcolor(13); end;
   bar(457,getmaxy-13,504,getmaxy-4);
   outtextxy(459,getmaxy-12,'NoWrit');
   sound(1000); delay(35); nosound;
   goto 10;
   end;
{ Скорость перемещения курсора }
      if ch=chr(9) then begin
   getimage(500,250,580,300,p1);
   setfillstyle(1,3);
   setcolor(13);
   bar3d(500,250,580,300,0,topoff);
   setcolor(14);
   outtextxy(510,257,'SPEED');
   moveto(510,275); outtext('X: '); setcolor(15);
   gread(s1);
   val(s1,xsp,i);                     setcolor(14);
   moveto(510,285); outtext('Y: '); setcolor(15);
   gread(s1); val(s1,ysp,i);
   sound(1000); delay(100); nosound;
   putimage(500,250,p1,normalput);
   goto 10;

   end;

{ Перемещение курсора в указанную точку }
      if ch=chr(15) then begin
   putpixel(xk+2,yk+15,sc);
   getimage(500,250,580,300,p1);
   setfillstyle(1,3);
   setcolor(13);
   bar3d(500,250,580,300,0,topoff);
   setcolor(14);
   outtextxy(504,257,'GOTO(X,Y)');
   moveto(510,275); outtext('X: '); setcolor(15);
   gread(s1);
   val(s1,xk,i);                     setcolor(14);
   moveto(510,285); outtext('Y: '); setcolor(15);
   gread(s1); val(s1,yk,i);
   sound(800); delay(30); nosound;
   putimage(500,250,p1,normalput);
   xk:=xk-xsp; ch:=chr(77); goto 70;
   sc:=getpixel(xk,yk);
   end;
{ Переход к следующей экранной странице }
      if ch=chr(81) then begin
                 writ;     ksk:=ksk+1;  str(ksk,s1);
      setcolor(0); outtextxy(595,18,'██████');
      setcolor(10); outtextxy(595,18,'Pg '+s1+'  ');
   writeln(f,'end;');
   writeln(f);
   writeln(f,'procedure screen'+s1+';');
   writeln(f,'begin');
   sound(600); delay(100); sound(200); delay(50);
   sound(1300);delay(200); sound(100); delay(50);
   sound(1500); delay(100); sound(2200); delay(100);
   nosound;
   goto 10;
   end;

{ Конец работы }
      if ch=chr(68) then begin
   if apr[1]=' ' then begin closegraph; goto 900; end;
   for i:=1 to 5 do begin
                    sound(800); delay(10);
                    nosound;    delay(10);
                    end;
   setfillstyle(1,4);
   setcolor(14);
   qu(s);
   if s='n' then s:='N';
   if s='N' then goto 10;
   if s='b' then goto 1;
   if s='B' then goto 1;
   if s='y' then s:='Y';
   if s='Y' then goto 900;
   if s='s' then s:='S';
   if s='S' then begin;
                 for i:=1 to 200 do begin;
                 if apr[i]=' ' then goto 900;
                 writeln(f,apr[i]);
                 end;
                          end;
 end;
{ Перемещение курсора }
 if (ch=chr(72)) or (ch=chr(77)) or (ch=chr(80)) or (ch=chr(75)) or
    (ch=chr(56)) or (ch=chr(57)) or (ch=chr(54)) or (ch=chr(51)) or
    (ch=chr(50)) or (ch=chr(49)) or (ch=chr(52)) or (ch=chr(55)) then goto 70;

{ Прочие нажатия клавиш }
sound(500); delay(10); nosound; delay(10);
sound(500); delay(10); nosound; delay(10);
sound(500); delay(10); nosound; delay(10);
       goto 10;
   70:
 setviewport(2,15,637,getmaxy+1-28,clipon);
 case reg of
 1 : plin;
 2 : pbar;
 3 : prec;
 5 : pell;
 6 : pflo;
 7 : pmov;
 8 : ptxt;
 9 : duga;
   end;
 setviewport(0,0,getmaxx,getmaxy,clipon);
 goto 10;
900: 
{  Работа программы завершена, формируется конец файла .
   символы псевдографики в фигурных скобках - служебные,
   они используются режимом восстановления результатов 
   предыдущего  сеанса работы                              }
     writeln(f,'{░}end;');
     writeln(f,'{');
     writeln(f,'           MAIN    ');
     writeln(f,'}');
     writeln(f,'begin');
 writeln(f,'{█}   grdriver:=detect;  ');
 writeln(f,'{█}   initgraph(grdriver,grmode,''''); ');
 if tip=0 then  writeln(f,'{█}       setgraphmode(1);')
 else  writeln(f,'{█}       setgraphmode(',VGAHI,');');
     writeln(f,'   xb:=0; yb:=0;');
      for i:=1 to ksk do begin;
      str(i,s1);
      writeln(f,'   screen'+s1+';');
      writeln(f,'   ch:=readkey;');
      writeln(f,'   if ch<>#0 then funckey:=false else');
      writeln(f,'   begin              ');
      writeln(f,'      funckey:=true;     ');
      writeln(f,'      ch:=readkey;          ');
      writeln(f,'   end;                        ');
      end;
      writeln(f,'{▒}closegraph; ');
      writeln(f,'end.');
      close(f);
      closegraph;

       halt;
  end.
{ конец программы  }
