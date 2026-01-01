      unit expand;
{
  ***************************************************************************
  *                                                                         *
  *                        Модуль    " EXPAND "                             *
  *                                                                         *
  *   Модуль содержит ряд функций для обработки видеоинформации и исполь-   *
  *   зуется для получения альтернативного меню в программе GRAPHPR по ко-  *
  *   мандам  ALT - F2  и  CTRL - F2, а также для обеспечения работы эле-   *
  *   ментов этого меню.                                                    *
  *                                                                         *
  ***************************************************************************
}
interface
      uses dirgraph,foread,slaid,crt,graph,tpdos1;

      procedure frag(var x1,y1,x2,y2,xk,yk,sc,xsp,ysp:integer);
      procedure tipimage(var ci:integer);
      procedure titul(var tip:integer);
      procedure helper(var tip,look:integer);
      procedure readtxt(var xk,yk,sc,cl,cf,t1,t2,t3,tip,xsp,ysp:integer);
      procedure inpslaid(var xk,yk,sc,xsp,ysp,tip:integer);
      procedure last(var xk,yk,sc,xsp,ysp,cf,tf:integer);
      procedure saveslaid(var xk,yk,sc,xsp,ysp:integer);
      procedure writeslaid(var xk,yk,sc,xsp,ysp:integer);
      procedure palitra(var xk,yk,sc,xsp,ysp:integer);
      procedure stampm(var xk,yk,sc,xsp,ysp,tim:integer);
      procedure stamp(var xk,yk,sc,xsp,ysp,tim:integer);
      procedure pesok(var xk,yk,sc,xsp,ysp:integer);
      procedure pix(var xk,yk,sc,xsp,ysp,cl:integer);
      procedure orihor(var xk,yk,sc,xsp,ysp:integer);
      procedure oriver(var xk,yk,sc,xsp,ysp:integer);
      procedure fon(var xk,yk,sc,xsp,ysp,cf:integer);
      procedure chcol(var xk,yk,sc,xsp,ysp,cf:integer);
      procedure RGBpalitra;
      procedure colors(var ci:integer);
      procedure menu1(var elem:integer);
      procedure menu2(var elem:integer);
implementation

    {  изменение цветов }

procedure colors(var ci:integer);
 var
   p:array[1..10702] of byte;
   xc,yc:integer;
   ch:char;
   funckey:boolean;
 label 10,20;
 begin
    setfillstyle(1,1);
    setcolor(9);
    getimage(500,120,610,310,p);
    bar(500,120,610,310);
    outtextxy(510,130,'ВЫБОР ЦВЕТА');
    setcolor(0);  outtextxy(510,150,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(1);  outtextxy(510,160,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(2);  outtextxy(510,170,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(3);  outtextxy(510,180,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(4);  outtextxy(510,190,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(5);  outtextxy(510,200,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(6);  outtextxy(510,210,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(7);  outtextxy(510,220,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(8);  outtextxy(510,230,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(9);  outtextxy(510,240,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(10); outtextxy(510,250,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(11); outtextxy(510,260,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(12); outtextxy(510,270,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(13); outtextxy(510,280,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(14); outtextxy(510,290,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(15); outtextxy(510,300,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(15);
    xc:=505; yc:=148;ci:=0;
    rectangle(xc,yc,xc+99,yc+7);
10: ch:=readkey;
    if ch<>#0 then funckey:=false else
    begin
       funckey:=true;
       ch:=readkey;
    end;
    if ch=chr(72) then begin
      setcolor(1);  rectangle(xc,yc,xc+99,yc+7);   yc:=yc-10;  ci:=ci-1;
      if yc<147 then begin ci:=15;  yc:=298; end;
      setcolor(15);  rectangle(xc,yc,xc+99,yc+7);
    end;
    if ch=chr(80) then begin
      setcolor(1);  rectangle(xc,yc,xc+99,yc+7);   yc:=yc+10;  ci:=ci+1;
      if yc>299 then begin ci:=0;  yc:=148; end;
      setcolor(15);  rectangle(xc,yc,xc+99,yc+7);
    end;
    if ch=chr(27) then begin ci:=100; goto 20; end;
    if ch=chr(13) then goto 20;
    goto 10;
20: putimage(500,120,p,normalput);
 end;


{ Процедура установления типа вывода участка в PUTIMAGE }

procedure tipimage(var ci:integer);
 var
   p:array[1..12000] of byte;
   xc,yc,i:integer;
   ch:char;
   funckey:boolean;
 label 10,20;
 begin
    setfillstyle(1,1);
    setcolor(9);
    getimage(400,120,610,220,p);
    bar(400,120,610,220);
    outtextxy(460,130,'ВЫБОР ТИПА ');
    setcolor(14);
    outtextxy(410,160,'Наложение      (NORMAL)');
    outtextxy(410,180,'Совмещение     (OR)    ');
    outtextxy(410,200,'Инвертирование (NOT)   ');
    setcolor(15);
    xc:=405; yc:=155; ci:=1;
    rectangle(xc,yc,xc+199,yc+20);
10: ch:=readkey;
    if ch<>#0 then funckey:=false else
    begin
       funckey:=true;
       ch:=readkey;
    end;
    if ch=chr(72) then begin
      setcolor(1);  rectangle(xc,yc,xc+199,yc+20);   yc:=yc-20;  ci:=ci-1;
      if yc<147 then begin ci:=3;  yc:=195; end;
      setcolor(15);  rectangle(xc,yc,xc+199,yc+20);
    end;
    if ch=chr(80) then begin
      setcolor(1);  rectangle(xc,yc,xc+199,yc+20);   yc:=yc+20;  ci:=ci+1;
      if yc>200 then begin ci:=1;  yc:=155; end;
      setcolor(15);  rectangle(xc,yc,xc+199,yc+20);
    end;
    if ch=chr(27) then begin ci:=100; goto 20; end;
    if ch=chr(13) then goto 20;
    goto 10;
20: putimage(400,120,p,normalput);
    i:=ci;
    case i of
     1: ci:=normalput;
     2: ci:=orput;
     3: ci:=notput;
    end;
      setcolor(10); setfillstyle(1,0);
      bar(1,getmaxy+1-24,50,getmaxy+1-18);
    case i of
     1: outtextxy(1,getmaxy+1-24,'NORM');
     2: outtextxy(1,getmaxy+1-24,'OR');
     3: outtextxy(1,getmaxy+1-24,'NOT');
   end;
end;

{ процедура управления курсором }

procedure mov(var xk,yk,sc,xsp,ysp,k:integer; var ch:char);
label 1,2;
begin
    putpixel(xk,yk,sc);
    if (ch=chr(72)) or (ch=chr(56))  then begin  xk:=xk; yk:=yk-ysp;  goto 1; end;
    if (ch=chr(80)) or (ch=chr(50))  then begin  xk:=xk; yk:=yk+ysp;  goto 1; end;
    if (ch=chr(77)) or (ch=chr(54))  then begin  xk:=xk+xsp; yk:=yk;  goto 1; end;
    if (ch=chr(75)) or (ch=chr(52))  then begin  xk:=xk-xsp; yk:=yk;  goto 1; end;
    if ch=chr(57) then begin  xk:=xk+xsp; yk:=yk-ysp;  goto 1; end;
    if ch=chr(51) then begin  xk:=xk+xsp; yk:=yk+ysp;  goto 1; end;
    if ch=chr(49) then begin  xk:=xk-xsp; yk:=yk+ysp;  goto 1; end;
    if ch=chr(55) then begin  xk:=xk-xsp; yk:=yk-ysp;  goto 1; end;
    k:=0;
    goto 2;
1:  k:=1;
    sc:=getpixel(xk,yk);  putpixel(xk,yk,15);
2:  end;

  {  поцедура формирования заставки программы  }

procedure titul;
 var
    xb,yb,i:integer;
    s:string;
    ch:char;
    funckey:boolean;
 label 10;
 begin
    s:='titul.psl'; xb:=0; yb:=0;
    slideout(s,1,13,0,0);
    sound(700); delay(100); sound(100); delay(50);
    sound(700) ; delay(50); sound(100); delay(30);
    sound(600); delay(100); nosound; xb:=0; yb:=0;
    setcolor(14);
    setfillstyle(1,4);
    bar3d(xb+180,yb+154,xb+472,yb+294,0,topon);
    settextstyle(0,0,1);
    outtextxy(xb+229,yb+164,'    " G R A P H P R "    ');
    outtextxy(xb+229,yb+174,'ПРОГРАММИРОВАHИЕ  ГРАФИКИ');
    setcolor(13);
    outtextxy(xb+183,yb+189,'Пpогpамма пpедназначена для пеpевода');
    outtextxy(xb+183,yb+203,'гpафических  изобpажений в опеpатоpы');
    outtextxy(xb+183,yb+217,'пpогpаммы на языке TURBO-PASCAL.');
    setcolor(11);
    outtextxy(xb+212,yb+239,'Автоp пpогpаммы - Д.А.Воpонин');
    setcolor(9);
    rectangle(xb+188,yb+254,xb+465,yb+288);
    outtextxy(xb+195,yb+258,'Для pаботы 640x350-нажмите "ENTER"');
    outtextxy(xb+197,yb+267,'Для pаботы 640x480-нажмите "V"');
    outtextxy(xb+197,yb+276,'    Для выхода нажмите  "ESC"');
    xb:=xb+5; yb:=yb+30;
    setcolor(10);
    setfillstyle(1,5);
    bar(xb+223,yb+270,xb+418,yb+296);
    rectangle(xb+417,yb+296,xb+222,yb+270);
    rectangle(xb+227,yb+274,xb+412,yb+291);
    settextstyle(0,0,1);
    outtextxy(xb+274,yb+279,'Веpсия  5.0'); xb:=0; yb:=0;
    i:=0;
10: while keypressed=false do begin
       i:=i+1; if i>15 then i:=0;
       slideout(s,1,13,i,0);
    end;
    ch:=readkey;
    if ch<>#0 then funckey:=false else
    begin
       funckey:=true;
       ch:=readkey;
    end;
    if ch=chr(27) then begin    closegraph; halt; end;
    if ch=chr(13) then begin cleardevice; tip:=0; exit; end;
    if (ch='v') or (ch='V') then begin cleardevice; tip:=1; exit; end;
    sound(900); delay(30); nosound;
    setcolor(15);
    rectangle(xb+188,yb+254,xb+465,yb+288);
    outtextxy(xb+195,yb+258,'Для pаботы 640x350-нажмите "ENTER"');
    outtextxy(xb+197,yb+267,'Для pаботы 640x480-нажмите "V"');
    outtextxy(xb+197,yb+276,'    Для выхода нажмите  "ESC"');
    setcolor(9);
    rectangle(xb+188,yb+254,xb+465,yb+288);
    outtextxy(xb+195,yb+258,'Для pаботы 640x350-нажмите "ENTER"');
    outtextxy(xb+197,yb+267,'Для pаботы 640x480-нажмите "V"');
    outtextxy(xb+197,yb+276,'    Для выхода нажмите  "ESC"');
    goto 10;
end;

{ смена цвета фона }

procedure casecol(var c,l:integer);
 begin
    case c of
      1:  setcolor(12);
      2:  setcolor(10);
      3:  setcolor(9);
    end;
    case c of
      1:  outtextxy(l,293,' red');
      2:  outtextxy(l,293,'green');
      3:  outtextxy(l,293,'blue');
    end;
 end;

procedure col(var ci,i1,i2,i3:integer);
 var
    p:array[1..10702] of byte;
    p1:array[1..5298] of byte;
    xc,yc,tip,c,l:integer;
    funckey:boolean;
    ch:char;
 label 10,20,21,25;
 begin
    if ci=100 then tip:=1 else tip:=0;
    setfillstyle(1,1);
    setcolor(9);
    getimage(500,120,610,310,p);
    bar(500,120,610,310);
    outtextxy(510,130,'ВЫБОР ЦВЕТА');
    setcolor(0);  outtextxy(510,150,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(1);  outtextxy(510,160,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(2);  outtextxy(510,170,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(3);  outtextxy(510,180,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(4);  outtextxy(510,190,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(5);  outtextxy(510,200,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(6);  outtextxy(510,210,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(7);  outtextxy(510,220,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(8);  outtextxy(510,230,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(9);  outtextxy(510,240,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(10); outtextxy(510,250,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(11); outtextxy(510,260,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(12); outtextxy(510,270,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(13); outtextxy(510,280,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(14); outtextxy(510,290,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(15); outtextxy(510,300,'▀▀▀▀▀▀▀▀▀▀▀');
    setcolor(15);
    xc:=505; yc:=148;ci:=0;
    rectangle(xc,yc,xc+99,yc+7);
10: ch:=readkey;
    if ch<>#0 then funckey:=false else
    begin
       funckey:=true;
       ch:=readkey;
    end;
    if ch=chr(72) then begin
       setcolor(1);  rectangle(xc,yc,xc+99,yc+7);   yc:=yc-10;  ci:=ci-1;
       if yc<147 then begin ci:=15;  yc:=298; end;
       setcolor(15);  rectangle(xc,yc,xc+99,yc+7);
    end;
    if ch=chr(80) then begin
       setcolor(1);  rectangle(xc,yc,xc+99,yc+7);   yc:=yc+10;  ci:=ci+1;
       if yc>299 then begin ci:=0;  yc:=148; end;
       setcolor(15);  rectangle(xc,yc,xc+99,yc+7);
    end;
    if ch=chr(27) then begin ci:=100; goto 20; end;
    if ch=chr(13) then goto 20;
    goto 10;
20: if tip=0 then goto 21;
    getimage(100,290,600,310,p1);
    setfillstyle(1,2);
    setcolor(13);
    bar3d(100,290,600,310,0,topon);
    setcolor(12); outtextxy(105,293,' red');
    setcolor(10); outtextxy(165,293,'green');
    setcolor(9);  outtextxy(225,293,'blue');
    setfillstyle(1,ci);
    setcolor(14);
    bar3d(300,293,590,307,0,topon);
    setcolor(0);
    outtextxy(105,293,'█████');
    setcolor(12);
    outtextxy(105,293,' red ');
    if ci=0  then begin i1:=000;  i2:=000; i3:=000; end;
    if ci=1  then begin i1:=000;  i2:=000; i3:=234; end;
    if ci=2  then begin i1:=000;  i2:=234; i3:=000; end;
    if ci=3  then begin i1:=006;  i2:=234; i3:=234; end;
    if ci=4  then begin i1:=234;  i2:=000; i3:=065; end;
    if ci=5  then begin i1:=170;  i2:=000; i3:=234; end;
    if ci=6  then begin i1:=-86;  i2:=-363;i3:=256; end;
    if ci=7  then begin i1:=170;  i2:=170; i3:=170; end;
    if ci=8  then begin i1:=052;  i2:=052; i3:=052; end;
    if ci=9  then begin i1:=000;  i2:=000; i3:=112; end;
    if ci=10 then begin i1:=000;  i2:=112; i3:=000; end;
    if ci=11 then begin i1:=000;  i2:=112; i3:=112; end;
    if ci=12 then begin i1:=112;  i2:=000; i3:=000; end;
    if ci=13 then begin i1:=112;  i2:=000; i3:=112; end;
    if ci=14 then begin i1:=252;  i2:=252; i3:=036; end;
    if ci=15 then begin i1:=252;  i2:=252; i3:=252; end;
    c:=1;    l:=105;
25: ch:=readkey; if ch=chr(0) then ch:=readkey;
    if ch=chr(77) then begin
    setcolor(2);
    outtextxy(l,293,'█████');
    casecol(c,l);
    c:=c+1; l:=l+60;  if c>3 then begin l:=105; c:=1; end;
    setcolor(0);
    outtextxy(l,293,'█████');
    casecol(c,l);
    goto 25;
    end;
    if ch=chr(75) then begin
    setcolor(2);
    outtextxy(l,293,'█████');
    casecol(c,l);
    c:=c-1; l:=l-60;  if c=0 then begin l:=225; c:=3; end;
    setcolor(0);
    outtextxy(l,293,'█████');
    casecol(c,l);
    goto 25;
    end;
    if ch=chr(72) then begin
    case c of
      1:  i1:=i1+1;
      2:  i2:=i2+1;
      3:  i3:=i3+1;
    end;
    setrgbpalette(ci,i1,i2,i3);
    goto 25;
    end;
    if ch=chr(80) then begin
    case c of
      1:  i1:=i1-1;
      2:  i2:=i2-1;
      3:  i3:=i3-1;
    end;
    setrgbpalette(ci,i1,i2,i3);
    goto 25;
    end;
    if ch=chr(27) then begin
       if ci=0  then begin i1:=000;  i2:=000; i3:=000; end;
       if ci=1  then begin i1:=000;  i2:=000; i3:=234; end;
       if ci=2  then begin i1:=000;  i2:=234; i3:=000; end;
       if ci=3  then begin i1:=006;  i2:=234; i3:=234; end;
       if ci=4  then begin i1:=234;  i2:=000; i3:=065; end;
       if ci=5  then begin i1:=170;  i2:=000; i3:=234; end;
       if ci=6  then begin i1:=-86;  i2:=-363;i3:=256; end;
       if ci=7  then begin i1:=170;  i2:=170; i3:=170; end;
       if ci=8  then begin i1:=052;  i2:=052; i3:=052; end;
       if ci=9  then begin i1:=000;  i2:=000; i3:=112; end;
       if ci=10 then begin i1:=000;  i2:=112; i3:=000; end;
       if ci=11 then begin i1:=000;  i2:=112; i3:=112; end;
       if ci=12 then begin i1:=112;  i2:=000; i3:=000; end;
       if ci=13 then begin i1:=112;  i2:=000; i3:=112; end;
       if ci=14 then begin i1:=252;  i2:=252; i3:=036; end;
       if ci=15 then begin i1:=252;  i2:=252; i3:=252; end;
       setrgbpalette(ci,i1,i2,i3);
       goto 21;
    end;
    if ch=chr(79) then goto 21;
    goto 25;
21:
    putimage(100,290,p1,normalput);
    putimage(500,120,p,normalput);
end;


{ редактирование по пикселям }

procedure pix;
 var
   funckey:boolean;
   i,xt,xr,yt,yr,t,j,k,c,cp,ci:integer;
   a:array[1..19,1..19] of integer;
   p:array[1..15000] of byte;
   s,s1:string;
   f:text;
   ch:char;
label 1,2,10,15,20,12,100;
begin
    xk:=xk+2; yk:=yk+15;
100: setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(9);
    outtextxy(5,getmaxy-15,'Редактирование по пикселям      : ESC - отмена ;    TAB,ShiftTab - скорость');setcolor(10);
    outtextxy(4,getmaxy-7,'Укажите прямоугольный участок (нажатием ENTER)');
    setcolor(15);
    setwritemode(1);
    rectangle(xk,yk,xk+20,yk+20);
    setwritemode(0);
10: ch:=readkey;
    if ch=chr(0) then begin funckey:=true; ch:=readkey; end else funckey:=false;

    setcolor(15);
    setwritemode(1);
    rectangle(xk,yk,xk+20,yk+20);
    setwritemode(0);
    mov(xk,yk,sc,xsp,ysp,k,ch);
    setcolor(15);
    setwritemode(1);
    rectangle(xk,yk,xk+20,yk+20);
    setwritemode(0);
    if k=1 then goto  10;
    if ch=chr(27) then  goto 2;
    if ch=chr(13) then begin
        setcolor(1);
        outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
        outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
        setcolor(9);
        outtextxy(5,getmaxy-15,'Редактирование по пикселям');setcolor(10);
        outtextxy(4,getmaxy-7,'F4 - цвет,    ENTER - поставить пиксель,   ESC - конец работы');
        cp:=cl;
        for j:=yk+1 to yk+19 do
            for i:=xk+1 to xk+19 do a[i-xk,j-yk]:=getpixel(i,j);
        if xk<300 then xt:=320 else xt:=20;
        yt:=30;
        getimage(xt-1,yt-1,xt+141,yt+151,p);
        setcolor(10); setfillstyle(1,1);
        bar3d(xt,yt,xt+140,yt+150,0,topon);
        setfillstyle(1,cp);
        bar(xt+5,yt+144,xt+135,yt+148);

        for j:=1 to 19 do
           for i:=1 to 19 do begin
             setfillstyle(1,a[i,j]);
             bar(xt+(i-1)*7+5,yt+(j-1)*7+5,xt+(i-1)*7+10,yt+(j-1)*7+10);
           end;
        setcolor(15);
        xr:=xt+4; yr:=yt+4;
        setwritemode(1);
        rectangle(xr,yr,xr+7,yr+7);
        setwritemode(0);
20:     ch:=readkey;
        if ch=chr(0) then begin funckey:=true; ch:=readkey; end else funckey:=false;
        setwritemode(1); rectangle(xr,yr,xr+7,yr+7);
        if  (ch=chr(72)) or (ch=chr(56)) then begin  xr:=xr; yr:=yr-7;      goto 1; end;
        if  (ch=chr(80)) or (ch=chr(50)) then begin  xr:=xr; yr:=yr+7;      goto 1; end;
        if  (ch=chr(77)) or (ch=chr(54)) then begin  xr:=xr+7; yr:=yr;      goto 1; end;
        if  (ch=chr(75)) or (ch=chr(52)) then begin  xr:=xr-7; yr:=yr;      goto 1; end;
        if ch=chr(57) then begin  xr:=xr+7; yr:=yr-7;  goto 1; end;
        if ch=chr(51) then begin  xr:=xr+7; yr:=yr+7;  goto 1; end;
        if ch=chr(49) then begin  xr:=xr-7; yr:=yr+7;  goto 1; end;
        if ch=chr(55) then begin  xr:=xr-7; yr:=yr-7;  goto 1; end;
        setwritemode(1); rectangle(xr,yr,xr+7,yr+7);
        goto 12;
1:      if yr<yt+4 then begin sound(1000); delay(20); nosound; yr:=yt+4; end;
        if xr<xt+4 then begin sound(1000); delay(20); nosound; xr:=xt+4; end;
        if yr>yt+130 then begin sound(1000); delay(20); nosound; yr:=yt+130; end;
        if xr>xt+130 then begin sound(1000); delay(20); nosound; xr:=xt+130; end;
        setwritemode(1); rectangle(xr,yr,xr+7,yr+7);
        goto 20;
12:     if ch=chr(13) then begin
          setfillstyle(1,cp);
          bar(xr+1,yr+1,xr+6,yr+6);
          goto 20;
        end;
        if (ch=chr(62)) and (funckey=true) then begin
          setwritemode(0);
          colors(ci); if ci<>100 then cp:=ci;
          setfillstyle(1,cp);
          bar(xt+5,yt+144,xt+135,yt+148);
          goto 20;
        end;
        if ch=chr(27) then begin
          setfillstyle(1,1);
          bar(xt+5,yt+144,xt+135,yt+148);
          setcolor(14);
          outtextxy(xt+3,yt+140,'Сохранять y/n [y]');
15:       ch:=readkey;
          if (ch='y') or (ch='Y') or (ch=chr(13)) or (ch=' ') then begin
            for j:=1 to 19 do
            for i:=1 to 19 do a[i,j]:=getpixel(xt+(i-1)*7+8,yt+(j-1)*7+8);
            assign(f,'progr.pas'); append(f);
            for j:=yk+1 to yk+19 do
            for i:=xk+1 to xk+19 do begin
                 ci:=getpixel(i,j);
                 if ci<>a[i-xk,j-yk] then begin
                     putpixel(i,j,a[i-xk,j-yk]);
                     writeln(f,'putpixel(xb+',i-2,',yb+',j-15,',',a[i-xk,j-yk],');');
                 end;
            end;
            close(f);
            setwritemode(0);
            putimage(xt-1,yt-1,p,normalput);
            setcolor(15);
            setwritemode(1);
            rectangle(xk,yk,xk+20,yk+20);
            setwritemode(0);
            goto 100;
          end;
          if (ch='n') or (ch='N') then begin
            setwritemode(0);
            putimage(xt-1,yt-1,p,normalput);
            setcolor(15);
            setwritemode(1);
            rectangle(xk,yk,xk+20,yk+20);
            setwritemode(0);
            goto 100;
         end;
         goto 15;
      end;  { Конец блока обработки изображения по пикселям }
      goto 20;
    end;
    goto 10;
2:  setcolor(15);
    setwritemode(1);
    rectangle(xk,yk,xk+20,yk+20);
    setcolor(0); setwritemode(0);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    xk:=xk-2; yk:=yk-15;

end;

{ стирание изображения }

procedure last;
 var
   funckey:boolean;
   r,t,k,tip,x1,x2,y1,y2,i,rn:integer;
   s,s1:string;
   f:text;
   ch:char;
 label 1,2,7,10;
 begin
    assign(f,'progr.pas'); append(f);
    r:=6;     tip:=0;   xk:=xk+2; yk:=yk+15;
    setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(11);
    outtextxy(5,getmaxy-15,'Стирание изображения: F10 - выход из режима ; TAB,ShiftTab - диаметр резинки');
    outtextxy(4,getmaxy-7,'Стрелки - движ-е,Enter+стрелки - рисование, +/- размер резинки,  F5-цвет');
    setcolor(15);
    setwritemode(1);
    rectangle(xk,yk,xk+r,yk+r);
    setwritemode(0);
10: ch:=readkey;
    if ch=chr(0) then begin funckey:=true; ch:=readkey; end else funckey:=false;

    setcolor(15);
    setwritemode(1);
    rectangle(xk,yk,xk+r,yk+r);
    setwritemode(0);
    mov(xk,yk,sc,xsp,ysp,k,ch);
    setcolor(15);
    setwritemode(1);
    rectangle(xk,yk,xk+r,yk+r);
    setwritemode(0);
    if k=1 then goto 1;
    if ch=chr(13) then begin
       if t=1 then t:=0 else begin
           writeln(f,'setcolor(',cf,');');
           writeln(f,'setfillstyle(',tf,',',cf,');');
           setcolor(cf); setfillstyle(tf,cf);
           x1:=xk+1; x2:=xk+r-1;
           y1:=yk+1; y2:=yk+r-1;
           bar(x1,y1,x2,y2);
           writeln(f,'bar(xb+',x1-2,',yb+',y1-15,',xb+',x2-2,',yb+',y2-15,');');
           t:=1;
       end;
       if t=1 then setfillstyle(1,9) else setfillstyle(1,0);
       bar(145,getmaxy-23,253,getmaxy-17);
       sound(1300); delay(20); nosound;
    end;
    if ch=chr(63) then begin
       col(cf,i,i,i);
       setfillstyle(1,cf);
       bar(505,getmaxy-23,613,getmaxy-17);
          writeln(f,'setcolor(',cf,');');
          writeln(f,'setfillstyle(',tf,',',cf,');');
       goto 10;
    end;
    if ch=chr(43) then begin rn:=r+1;  goto 7; end;
    if ch=chr(45) then begin rn:=r-1;  if rn=0 then rn:=1; goto 7; end;
    if ch=chr(9) then begin xsp:=xsp+1; ysp:=ysp+1; goto 10; end;
    if ch=chr(15) then begin xsp:=xsp-1; ysp:=ysp-1;
      if (xsp=0) or (ysp=0) then begin xsp:=1; ysp:=1;end;  goto 10; end;
    if ch=chr(59) then if tip=0 then tip:=1 else tip:=0;
    if ch=chr(68) then goto 2;
    goto 10;
7:  setcolor(15);
    setwritemode(1);
    rectangle(xk,yk,xk+r,yk+r);
    r:=rn;
    rectangle(xk,yk,xk+r,yk+r);
    setwritemode(0);
    goto 10;

1:  if t=1 then begin
      setcolor(cf); setfillstyle(tf,cf);
           x1:=xk+1; x2:=xk+r-1;
           y1:=yk+1; y2:=yk+r-1;
           bar(x1,y1,x2,y2);
           writeln(f,'bar(xb+',x1-2,',yb+',y1-15,',xb+',x2-2,',yb+',y2-15,');');
    end;
    setcolor(0); outtextxy(595,28,'█████'); outtextxy(595,38,'█████');
    setcolor(9);
    s:='X:';  str(xk,s1);  s:=s+s1;  outtextxy(595,28,s);
    s:='Y:';  str(yk,s1);  s:=s+s1;  outtextxy(595,38,s);
    goto 10;
2:
    setcolor(15);
    setwritemode(1);
    rectangle(xk,yk,xk+r,yk+r);
    setcolor(0);  close(f);      xk:=xk-2; yk:=yk-15;
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
end;

{ Выбор прямоугольного участка экрана }

procedure frag;
 var
   ch:char;
   p:array[1..10702] of byte;
   t,k:integer;
   s,s1:string;
   funckey:boolean;
 label 1,2,10;
 begin
    getimage(200,1,460,16,p);
    setcolor(14); setfillstyle(1,1);
    bar3d(200,1,460,16,0,topon);
    setcolor(15);
    outtextxy(205,5,'Покажите один угол участка');
    t:=0;
10: ch:=readkey; if ch=chr(0) then ch:=readkey;

    if ch=chr(13) then begin
      t:=t+1;
      if t=1 then begin
        setcolor(14); setfillstyle(1,1);
        bar3d(200,1,460,16,0,topon);
        setcolor(15);
        outtextxy(205,5,'Покажите другой угол участка');
        x1:=xk; y1:=yk;
      end;
      if t=2 then begin
        x2:=xk; y2:=yk;
        setcolor(15);
        setwritemode(1);
        rectangle(x1,y1,x2,y2);
        setwritemode(0);
        if x1>x2 then begin t:=x1; x1:=x2; x2:=t; end;
        if y1>y2 then begin t:=y1; y1:=y2; y2:=t; end;
        goto 2;
      end;
    end;
    if ch=chr(9) then begin sound(100); delay(5); xsp:=xsp+1; ysp:=ysp+1; nosound; goto 10; end;
    if ch=chr(15) then begin
      xsp:=xsp-1; if xsp=0 then xsp:=1;
      ysp:=ysp-1; if ysp=0 then ysp:=1;
      sound(100); delay(5); nosound; goto 10;
    end;
    if t=1 then begin
      setcolor(15);
      setwritemode(1);
      rectangle(x1,y1,xk,yk);
      setwritemode(0);
    end;
    if (ch=chr(8)) and (t=1) then begin
      x2:=x1; y2:=y1; x1:=xk; y1:=yk; xk:=x2; yk:=y2; x2:=0; y2:=0;
    end;
    if ch=chr(56) then ch:=chr(72);
    if ch=chr(54) then ch:=chr(77);
    if ch=chr(50) then ch:=chr(80);
    if ch=chr(52) then ch:=chr(75);
    mov(xk,yk,sc,xsp,ysp,k,ch);
    k:=1;
    if t=1 then begin
      setcolor(15);
      setwritemode(1);
      rectangle(x1,y1,xk,yk);
      setwritemode(0);
    end;
    if ch=chr(27) then begin
      if t=0 then begin x1:=0; x2:=0; y1:=0; y2:=0; goto 2; end;
      setcolor(15);
      setwritemode(1);
      rectangle(x1,y1,xk,yk);
      setwritemode(0);
      x1:=0; x2:=0; y1:=0; y2:=0;
      goto 2;
    end;
    setcolor(0); outtextxy(595,28,'█████'); outtextxy(595,38,'█████');
    setcolor(9);
    s:='X:';  str(xk,s1);  s:=s+s1;  outtextxy(595,28,s);
    s:='Y:';  str(yk,s1);  s:=s+s1;  outtextxy(595,38,s);
    goto 10;
2:  putimage(200,1,p,normalput);
end;

{ вывод слайда  ЭКРАН --> ДИСК  }

procedure saveslaid;
 var
   funckey:boolean;
   ag1,ag2:array[1..640]of integer;
   av1,av2:array[1..480]of integer;
   i,x1,x2,y1,y2,t,k:integer;
   s,s1:string;
   ch:char;
label 1,2,10;
begin
    xk:=xk+2; yk:=yk+15;
    setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(11);
    outtextxy(5,getmaxy-15,'Вывод слайда:  ESC - отмена ;   TAB,ShiftTab - скорость курсора ');setcolor(10);
    outtextxy(4,getmaxy-7,'Укажите прямоугольный участок (нажатием ENTER)');
    frag(x1,y1,x2,y2,xk,yk,sc,xsp,ysp);
    if (x1+y1+x2+y2)<=0 then goto 2;
    setcolor(1);
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(10); moveto(44,getmaxy-7);
    outtext('Укажите имя файла ( до 8 символов без расширения ) > ');
    setcolor(15); setfillstyle(1,1);
    gread(s);
    if (s='') or (s=' ') then goto 2;
    s:=s+'.psl';
    setcolor(1);
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(10);
    outtextxy(44,getmaxy-7,'Ожидайте.  Указанный прямоугольный участок выводится на диск.');
    slidesave(s,x1+1,y1+1,x2-1,y2-1);
2:  putpixel(xk,yk,15);
    xk:=xk-2; yk:=yk-15;
    setcolor(0);
    outtextxy(1,getmaxy-8,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
end;

{ вывод слайда   ДИСК --> ЭКРАН }

procedure inpslaid;
 var
   funckey:boolean;
   i,i1,x1,y1,t,k:integer;
   f,s,s1:string;
   f1:text;
   ch:char;
 label 1,2,10;
 begin
    xk:=xk+2; yk:=yk+15;
    if tip=0 then begin dir('*.psl',f); if f='' then goto 2; end;
    setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(11);
    outtextxy(5,getmaxy-15,'Ввод слайда:    ESC - выход из режима ; TAB,ShiftTab - скорость');setcolor(10);
    if tip=1 then begin
        setcolor(10); moveto(44,getmaxy-7);
        outtext('Укажите имя слайда  ( без расширения )  > ');
        setcolor(15); setfillstyle(1,1);
        gread(f); if f='' then goto 2;
        f:=f+'.psl';
        setcolor(1);
        outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
        setcolor(10);
    end;
    outtextxy(4,getmaxy-7,'Установите курсор в левый верхний угол прямоугольного участка и нажмите ENTER');
10: ch:=readkey; if ch=chr(0) then ch:=readkey;

    if ch=chr(13) then begin
        x1:=xk; y1:=yk;
        setcolor(1);
        outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
        setcolor(10); moveto(44,getmaxy-7);
        outtext('Укажите цветовое смещение  ( целое число )  > ');
        setcolor(15); setfillstyle(1,1);
        gread(s); if s='' then i:=0 else val(s,i,t);
        setcolor(1);
        outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
        setcolor(10); moveto(44,getmaxy-7);
        outtext('Сохранить фон ? (y/n) [N]  > ');
        setcolor(15); setfillstyle(1,1);
        gread(s);
        if s='' then i1:=0;
        if s='y' then i1:=1;
        if s='Y' then i1:=1;
        if s='n' then i1:=0;
        if s='N' then i1:=0;
        setcolor(1);
        outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
        setcolor(10);
        outtextxy(44,getmaxy-7,'Ожидайте.  Указанный прямоугольный участок выводится на экран.');
        assign(f1,'progr.pas'); append(f1);
        writeln(f1,'s:=''',f,''';');
        writeln(f1,'slideout(s,',x1-2,',',y1-15,',',i,',',i1,');'); close(f1);
        slideout(f,x1,y1,i,i1);
        goto 2;
    end;
    if ch=chr(9) then begin xsp:=xsp+1; ysp:=ysp+1; goto 10; end;
    if ch=chr(15) then begin
        xsp:=xsp-1; if xsp=0 then xsp:=1;
        ysp:=ysp-1; if ysp=0 then ysp:=1; goto 10;
    end;
    setcolor(8);
    if ch=chr(56) then ch:=chr(72);
    if ch=chr(54) then ch:=chr(77);
    if ch=chr(50) then ch:=chr(80);
    if ch=chr(52) then ch:=chr(75);
    mov(xk,yk,sc,xsp,ysp,k,ch);
    if k=1 then goto 1;
    if ch=chr(27) then goto 2;
    goto 10;
1:  setcolor(0); outtextxy(595,28,'█████'); outtextxy(595,38,'█████');
    setcolor(9);
    s:='X:';  str(xk,s1);  s:=s+s1;  outtextxy(595,28,s);
    s:='Y:';  str(yk,s1);  s:=s+s1;  outtextxy(595,38,s);
    goto 10;
2:  setcolor(0);  xk:=xk-2; yk:=yk-15;
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
end;

{ цветовой сдвиг изображения }

procedure palitra;
 var
   funckey:boolean;
   i,x1,x2,y1,y2,t,j,k,c:integer;
   s,s1:string;
   ch:char;
   f:text;
label 1,2,10;
begin
    xk:=xk+2; yk:=yk+15;
    setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(11);
    outtextxy(5,getmaxy-15,'Cдвиг цветов:  ESC - отмена ;                          TAB,ShiftTab - скорость');setcolor(10);
    outtextxy(4,getmaxy-7,'Укажите прямоугольный участок (нажатием ENTER)');
    frag(x1,y1,x2,y2,xk,yk,sc,xsp,ysp);
    if (x1+y1+x2+y2)<=0 then goto 2;
    setcolor(1);
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(10); moveto(24,getmaxy-7);
    outtext('Укажите цветовой сдвиг ( целое число  от -15 до 15 ) > ');
    setcolor(15); setfillstyle(1,1);
    gread(s);   val(s,c,i);
    for i:=x1+1 to x2-1 do begin
      for j:=y1+1 to y2-1 do begin
       k:=getpixel(i,j);
       if k<>0 then begin
           k:=k-c;
           if k<0 then k:=k+15;
           if k>15 then k:=k-15;
       end;
       putpixel(i,j,k);
      end;
    end;
    assign(f,'progr.pas'); append(f);
    writeln(f,'palitra(xb+',x1-2,',yb+',y1-15,',xb+',x2-2,',yb+',y2-15,',',c,');');
    close(f);
2:  setcolor(0);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    xk:=xk-2; yk:=yk-15;
end;

{ Ножницы }

procedure stampm;
 var
   p:array[1..15000] of byte;
   funckey:boolean;
   f:text;
   lx1,lx2,ly1,ly2:longint;
   i,x1,x2,y1,y2,t,j,k,c,xs1,ys1,xs2,ys2:integer;
   s,s1:string;
   ch:char;
label 1,2,3,4,10;
begin
    xk:=xk+2; yk:=yk+15;
    setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(11);
    outtextxy(5,getmaxy-15,'Ножницы :     ESC - отмена ;                          TAB,ShiftTab - скорость');setcolor(10);
    outtextxy(4,getmaxy-7,'Укажите прямоугольный участок (нажатием ENTER)');
3:  frag(x1,y1,x2,y2,xk,yk,sc,xsp,ysp);
    putpixel(xk,yk,sc);
    if (x1+y1+x2+y2)<=0 then goto 2;
    xk:=x1; yk:=y1;
    lx1:=x1; lx2:=x2; ly1:=y1; ly2:=y2;
    if ((lx2-lx1+1)*(ly2-ly1+1)+20)>15000 then begin
        setcolor(1);
        outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
        setcolor(10); moveto(24,getmaxy-7);
        outtext('Вы указали слишком уж большой участок, повторите ');
        goto 3;
    end;
    xs1:=x1;ys1:=y1;xs2:=x2;ys2:=y2;
    setcolor(1);
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(10); moveto(24,getmaxy-7);
    outtext('Перемещайте участок в нужное место ');
    getimage(x1,y1,x2,y2,p);
4:  ch:=readkey;
    if ch=chr(0) then begin funckey:=true; ch:=readkey; end;
    putimage(xk,yk,p,XORput);
    if ch=chr(56) then ch:=chr(72);
    if ch=chr(54) then ch:=chr(77);
    if ch=chr(50) then ch:=chr(80);
    if ch=chr(52) then ch:=chr(75);
    mov(xk,yk,sc,xsp,ysp,k,ch);
    if k=1 then begin
        putimage(xk,yk,p,XORput);
        goto 4;
    end;
    if ch=chr(27) then goto 2;
    if ch=chr(13) then begin
        putimage(xk,yk,p,tim);
        assign(f,'progr.pas');
        append(f);
        xs1:=xs1-2; ys1:=ys1-15; xs2:=xs2-2; ys2:=ys2-15; xk:=xk-2; yk:=yk-15;
        writeln(f,'getimage(xb+',xs1,',yb+',ys1,',xb+',xs2,',yb+',ys2,',p);');
        writeln(f,'putimage(xb+',xs1,',yb+',ys1,',p,XORput);');
        writeln(f,'putimage(xb+',xk,',yb+',yk,',p,',tim,');');
        xk:=xk+2; yk:=yk+15;
        close(f);
        goto 2;
    end;
    putimage(xk,yk,p,XORput);
    goto 4;
2:  setcolor(0);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    xk:=xk-2; yk:=yk-15;
end;

{ Штамп }

procedure stamp;
 var
   p:array[1..15000] of byte;
   funckey:boolean;
   i,x1,x2,y1,y2,t,j,k,c:integer;
   px1,px2,py1,py2,pxk,pyk:integer;
   lx1,lx2,ly1,ly2:longint;
   f:text;
   s,s1:string;
   ch:char;
label 1,2,3,4,5,10;
begin

    xk:=xk+2; yk:=yk+15;
    setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(11);
    outtextxy(5,getmaxy-15,'Штамп:  ESC - отмена ;                          TAB,ShiftTab - скорость');setcolor(10);
    outtextxy(4,getmaxy-7,'Укажите прямоугольный участок (нажатием ENTER)');
3:  frag(x1,y1,x2,y2,xk,yk,sc,xsp,ysp);
    putpixel(xk,yk,sc);
    lx1:=x1; lx2:=x2; ly1:=y1; ly2:=y2;
    px1:=x1-2; px2:=x2-2; py1:=y1-15; py2:=y2-15;
    if (x1+y1+x2+y2)<=0 then goto 2;
    xk:=x1; yk:=y1;
    if ((lx2-lx1+1)*(ly2-ly1+1)+20)>15000 then begin
        setcolor(1);
        outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
        setcolor(10); moveto(24,getmaxy-7);
        outtext('Вы указали слишком уж большой участок, повторите ');
        goto 3;
    end;
    assign(f,'progr.pas');
    append(f);
    writeln(f,'getimage(xb+',px1,',yb+',py1,',xb+',px2,',yb+',py2,',p);');
    close(f);
    setcolor(1);
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(10); moveto(24,getmaxy-7);
    outtext('Копируйте участок в нужное место клавишей ENTER ');
    getimage(x1,y1,x2,y2,p);
5:  putimage(xk,yk,p,XORput);
4:  ch:=readkey;
    if ch=chr(0) then begin funckey:=true; ch:=readkey; end;
    putimage(xk,yk,p,XORput);
    if ch=chr(56) then ch:=chr(72);
    if ch=chr(54) then ch:=chr(77);
    if ch=chr(50) then ch:=chr(80);
    if ch=chr(52) then ch:=chr(75);
    mov(xk,yk,sc,xsp,ysp,k,ch);
    if k=1 then begin
        putimage(xk,yk,p,XORput);
        goto 4;
    end;
    if ch=chr(27) then goto 2;
    if ch=chr(13) then begin
        assign(f,'progr.pas');
        append(f);
        putimage(xk,yk,p,tim);
        pxk:=xk-2; pyk:=yk-15;
        writeln(f,'putimage(xb+',pxk,',yb+',pyk,',p,',tim,');');
        close(f);
        goto 5;
    end;
    putimage(xk,yk,p,XORput);
    goto 4;
2:  setcolor(0);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    xk:=xk-2; yk:=yk-15;
end;

{ залить поле фоновым цветом с сохранением одного из цветов }

procedure fon;
 var
   funckey:boolean;
   i,x1,x2,y1,y2,t,j,k,c:integer;
   s,s1:string;
   ch:char;
   f:text;
label 1,2,10;
begin
    xk:=xk+2; yk:=yk+15;
    setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(11);
    outtextxy(5,getmaxy-15,'Стирание всех, кроме одного: ESC - отмена ;             TAB,ShiftTab - скорость');setcolor(10);
    outtextxy(4,getmaxy-7,'Укажите прямоугольный участок (нажатием ENTER)');
    frag(x1,y1,x2,y2,xk,yk,sc,xsp,ysp);
    if (x1+y1+x2+y2)<=0 then goto 2;
    setcolor(1);
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(10); moveto(24,getmaxy-7);
    outtext('Какой цвет оставить ? ( целое число  от 0 до 15 ) > ');
    setcolor(15); setfillstyle(1,1);
    gread(s);   val(s,c,i);
    for i:=x1+1 to x2-1 do begin
      for j:=y1+1 to y2-1 do begin
       k:=getpixel(i,j);
       if k<>c then putpixel(i,j,cf);
      end;
    end;
    assign(f,'progr.pas'); append(f);
    writeln(f,'fon(xb+',x1-2,',yb+',y1-15,',xb+',x2-2,',yb+',y2-15,',',cf,',',c,');');
    close(f);
2:  setcolor(0);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    xk:=xk-2; yk:=yk-15;
end;

{ Изменить цвет }

procedure chcol;
 var
   funckey:boolean;
   i,i1,i2,x1,x2,y1,y2,t,j,k,c:integer;
   s,s1:string;
   ch:char;
   f:text;
label 1,2,10;
begin
    xk:=xk+2; yk:=yk+15;
    setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(11);
    outtextxy(5,getmaxy-15,'Сменить цвет  на другой: ESC - отмена ;             TAB,ShiftTab - скорость');setcolor(10);
    outtextxy(4,getmaxy-7,'Укажите прямоугольный участок (нажатием ENTER)');
    frag(x1,y1,x2,y2,xk,yk,sc,xsp,ysp);
    if (x1+y1+x2+y2)<=0 then goto 2;
    setcolor(1);
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(10); moveto(24,getmaxy-7);
    outtext('Какой цвет менять ?  > ');
    colors(i1);
    if i1=100 then goto 2;
    setcolor(i1);
    outtextxy(1,getmaxy-7,'                                     ███████████████                            ');
    setcolor(1); moveto(24,getmaxy-7);
    outtext('███████████████████████');
    setcolor(10); moveto(24,getmaxy-7);
    outtext('На какой цвет ?      > ');
    colors(i2);
    if i2=100 then goto 2;
    setcolor(i2);
    outtextxy(1,getmaxy-7,'                                                      --->   ███████████████    ');
    for i:=x1+1 to x2-1 do begin
      for j:=y1+1 to y2-1 do begin
       k:=getpixel(i,j);
       if k=i1 then putpixel(i,j,i2);
      end;
    end;
    assign(f,'progr.pas'); append(f);
    writeln(f,'chcol(xb+',x1-2,',yb+',y1-15,',xb+',x2-2,',yb+',y2-15,',',i1,',',i2,');');
    close(f);
2:  setcolor(0);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    xk:=xk-2; yk:=yk-15;
end;

{ Смена ориентации по горизонтали }

procedure orihor;
 var
   funckey:boolean;
   i,x1,x2,y1,y2,t,j,k,c:integer;
   a:array[1..640] of integer;
   s,s1:string;
   ch:char;
   f:text;
label 1,2,10;
begin
    xk:=xk+2; yk:=yk+15;
    setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(11);
    outtextxy(5,getmaxy-15,'Смена ориентации по горизонтали : ESC - отмена ;    TAB,ShiftTab - скорость');setcolor(10);
    outtextxy(4,getmaxy-7,'Укажите прямоугольный участок (нажатием ENTER)');
    frag(x1,y1,x2,y2,xk,yk,sc,xsp,ysp);
    if (x1+y1+x2+y2)<=0 then goto 2;
    setcolor(1);
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    for i:=1 to 640 do a[i]:=0;
    for j:=y1+1 to y2-1 do begin
      for i:=x1+1 to x2-1 do a[i-x1]:=getpixel(i,j);
      for i:=x1+1 to x2-1 do putpixel(i,j,a[x2-i]);
    end;
    assign(f,'progr.pas'); append(f);
    writeln(f,'orihor(xb+',x1-2,',yb+',y1-15,',xb+',x2-2,',yb+',y2-15,');');
    close(f);
2:  setcolor(0);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    xk:=xk-2; yk:=yk-15;
end;

{ Смена ориентации по вертикали }

procedure oriver;
 var
   funckey:boolean;
   i,x1,x2,y1,y2,t,j,k,c:integer;
   a:array[1..480] of integer;
   s,s1:string;
   ch:char;
   f:text;
label 1,2,10;
begin
    xk:=xk+2; yk:=yk+15;
    setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(11);
    outtextxy(5,getmaxy-15,'Смена ориентации по вертикали   : ESC - отмена ;    TAB,ShiftTab - скорость');setcolor(10);
    outtextxy(4,getmaxy-7,'Укажите прямоугольный участок (нажатием ENTER)');
    frag(x1,y1,x2,y2,xk,yk,sc,xsp,ysp);
    if (x1+y1+x2+y2)<=0 then goto 2;
    setcolor(1);
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    for i:=1 to 480 do a[i]:=0;
    for i:=x1+1 to x2-1 do begin
      for j:=y1+1 to y2-1 do a[j-y1]:=getpixel(i,j);
      for j:=y1+1 to y2-1 do putpixel(i,j,a[y2-j]);
    end;
    assign(f,'progr.pas'); append(f);
    writeln(f,'oriver(xb+',x1-2,',yb+',y1-15,',xb+',x2-2,',yb+',y2-15,');');
    close(f);
2:  setcolor(0);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    xk:=xk-2; yk:=yk-15;
end;

{ процедура "Звездное небо" }

procedure pesok;
 var
   funckey:boolean;
   i,x1,x2,y1,y2,t,j,k,c:integer;
   s,s1:string;
   ch:char;
label 1,2,10,11,12;
begin
    xk:=xk+2; yk:=yk+15;
    setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(11);
    outtextxy(5,getmaxy-15,'Звездное небо: ESC - отмена ;                         TAB,ShiftTab - скорость');setcolor(10);
    outtextxy(4,getmaxy-7,'Укажите прямоугольный участок (нажатием ENTER)');
    frag(x1,y1,x2,y2,xk,yk,sc,xsp,ysp);
    if (x1+y1+x2+y2)<=0 then goto 2;
    setcolor(1);
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(10); moveto(24,getmaxy-7);
    outtext('Какой цвет  ? ( целое число  от 0 до 15 ) > ');
    setcolor(15); setfillstyle(1,1);
    gread(s);   val(s,c,i);
    randomize;
11: i:=random(x2-x1)+x1;
    j:=random(y2-y1)+y1;
    putpixel(i,j,c);
    delay(10);
    if keypressed then goto 2;
    goto 11;
2:  setcolor(0);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    xk:=xk-2; yk:=yk-15;
end;

{ вывод слайда  ЭКРАН --> LPT1  }

procedure writeslaid;
 var
   funckey:boolean;
   i,x1,x2,y1,y2,t,k,j,t1:integer;
   s,s1:string;
   f:text;
   ch:char;
label 1,2,8,9,10;
begin
    xk:=xk+2; yk:=yk+15;
    setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(11);
    outtextxy(5,getmaxy-15,'Печать слайда:  ESC - отмена ;                          TAB,ShiftTab - скорость');setcolor(10);
    outtextxy(4,getmaxy-7,'Укажите прямоугольный участок (нажатием ENTER)');
    frag(x1,y1,x2,y2,xk,yk,sc,xsp,ysp);
    if (x1+y1+x2+y2)<=0 then goto 2;
    setcolor(1);
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(10); moveto(44,getmaxy-7);
    outtext('Установите бумагу на принтер и нажмите любую клавишу ');
    ch:=readkey;
    setcolor(1);
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(10);
    outtextxy(44,getmaxy-7,'Ожидайте.  Указанный прямоугольный участок выводится на диск.');
    assign(f,'LPT1');
    rewrite(f);
    t:=x2-x1+1;
    writeln(f,chr(27),'3',chr(12));
    i:=round(int((x2-x1+1)/256));
    j:=(x2-x1+1)-256*i;
    s1:=chr(27)+chr(89)+chr(j)+chr(i);
    for j:=y1 to y2 do begin
        write(f,s1);    t1:=0;
        for i:=x1 to x2 do begin
              k:=0;
              if getpixel(i,j+3)<>0 then k:=k+4;
              if getpixel(i,j+2)<>0 then k:=k+8;
              if getpixel(i,j+1)<>0 then k:=k+16;
              if getpixel(i,j+0)<>0 then k:=k+32;
              write(f,chr(k));
              t1:=t1+1;
              if t1>=t then goto 8;
       end;
8:     write(f,chr(0));
       writeln(f);
       j:=j+3;
       if j>y2 then begin close(f); goto 2; end;
    end;
2:  setcolor(0);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    xk:=xk-2; yk:=yk-15;
end;

{ Изменение цветов основной палитры }

procedure RGBpalitra;
 var
   funckey:boolean;
   f:text;
   s,s1:string;
   i1,i2,i3,ci:integer;
   ch:char;
label 1,2,8,9,10;
begin
    ci:=100;
10: setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(11);
    outtextxy(5,getmaxy-15,'Палитра:  Изменение цветов основной палитры                   ');setcolor(10);
    outtextxy(4,getmaxy-7,'ESC - закончить работу       ENTER - меню цветов                             ');
    ch:=readkey; if ch=chr(0) then ch:=readkey;

    if ch=chr(13) then begin
        setcolor(1);
        outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
        setcolor(10);
        outtextxy(4,getmaxy-7,'    Выберите нужный цвет ( один из первых 8 ), используя стрелки');
        col(ci,i1,i2,i3);
        assign(f,'progr.pas');
        append(f);
        s:='setrgbpalette(';
        str(ci,s1);
        s:=s+s1+',';
        str(i1,s1);
        s:=s+s1+',';
        str(i2,s1);
        s:=s+s1+',';
        str(i3,s1);
        s:=s+s1+');';
        writeln(f,s);
        close(f);
        ci:=100;
        goto 10;
    end;
    if ch=chr(27) then goto 2;
    goto 10;
2:  setcolor(0);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
end;

{ вывод на экран текста из файла}

procedure readtxt;
 var
   funckey:boolean;
   i,x1,y1,t,k:integer;
   f,f1:text;
   s,s1,s2:string;
   ch:char;
label 1,2,3,4,5,6,7,8,9,10;
begin
    assign(f,'progr.pas'); append(f);    xk:=xk+2; yk:=yk+15;
    if tip=0 then begin dir('*.*',s2); if s2='' then goto 2; end;
    setcolor(1);
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setcolor(11);
    outtextxy(5,getmaxy-15,'Ввод текста:    F10 - выход из режима ; TAB,ShiftTab - скорость');setcolor(10);
    if tip=1 then begin
        setcolor(10); moveto(44,getmaxy-7);
        outtext('Укажите имя файла с расширением         > ');
        setcolor(15); setfillstyle(1,1);
        gread(s2); if s2='' then goto 2;
        setcolor(1);
        outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
        setcolor(10);
    end;
    outtextxy(4,getmaxy-7,'Установите курсор в начало вывода текста (левый верхний угол); нажмите ENTER');
10: ch:=readkey; if ch=chr(0) then ch:=readkey;

    if ch=chr(13) then begin
       setfillstyle(1,9);
       bar(145,getmaxy-23,253,getmaxy-17);
       x1:=xk; y1:=yk;
       setcolor(1);
       outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
       setcolor(10);
       outtextxy(44,getmaxy-7,'При необходимости переместите текст стрелками или нажмите ENTER для окончания.  ');
       settextstyle(t1,t2,t3);
    7: setcolor(cl);
       assign(f1,s2); reset(f1);
    3: readln(f1,s);
       outtextxy(xk+2,yk+15,s);
       yk:=yk+textheight('│');
       if eof(f1)=true then begin close(f1); goto 4; end;
       if yk>getmaxy+1-28 then begin close(f1); goto 4; end;
       goto 3;
    4: ch:=readkey; if ch=chr(0) then ch:=readkey;   xk:=x1; yk:=y1;
       if (ch=chr(49)) or (ch=chr(50)) or (ch=chr(51)) or (ch=chr(52)) or (ch=chr(53)) or
          (ch=chr(54)) or (ch=chr(55)) or (ch=chr(56)) or (ch=chr(57)) or (ch=chr(79)) or
          (ch=chr(80)) or (ch=chr(81)) or (ch=chr(75)) or (ch=chr(77)) or (ch=chr(71)) or
          (ch=chr(72)) or (ch=chr(73)) or (ch=chr(27)) then begin
       setcolor(cf);
       assign(f1,s2); reset(f1);
    5: readln(f1,s);
       outtextxy(xk+2,yk+15,s);
       yk:=yk+textheight('│');
       if eof(f1)=true then begin close(f1); goto 6; end;
       if yk>getmaxy+1-28 then begin close(f1); goto 6; end;
       goto 5;
       6: if ch=chr(56) then ch:=chr(72); xk:=x1; yk:=y1;
          if ch=chr(54) then ch:=chr(77);
          if ch=chr(50) then ch:=chr(80);
          if ch=chr(52) then ch:=chr(75);
          if ch=chr(27) then goto 8;
          mov(xk,yk,sc,xsp,ysp,k,ch);     x1:=xk; y1:=yk;
          goto 7;
       end;
    8: if ch=chr(13) then begin
       assign(f1,s2); reset(f1);  xk:=x1; yk:=y1;
    9: readln(f1,s);
       writeln(f,'outtextxy(xb+',xk,',yb+',yk,',''',s,''');');
       yk:=yk+textheight('│');
       if eof(f1)=true then begin close(f1); goto 2; end;
       if yk>getmaxy+1-28 then begin close(f1); goto 2; end;
       goto 9;
       end;
       goto 2;
    end;
    if ch=chr(9) then begin xsp:=xsp+1; ysp:=ysp+1; goto 10; end;
    if ch=chr(15) then begin
      xsp:=xsp-1; if xsp=0 then xsp:=1;
      ysp:=ysp-1; if ysp=0 then ysp:=1; goto 10;
    end;
    setcolor(8);
    if ch=chr(56) then ch:=chr(72);
    if ch=chr(54) then ch:=chr(77);
    if ch=chr(50) then ch:=chr(80);
    if ch=chr(52) then ch:=chr(75);
    mov(xk,yk,sc,xsp,ysp,k,ch);
    if k=1 then goto 1;
    if ch=chr(27) then goto 2;
    if ch=chr(68) then goto 2;
    goto 10;
1:  setcolor(0); outtextxy(595,28,'█████'); outtextxy(595,38,'█████');
    setcolor(9);
    s:='X:';  str(xk,s1);  s:=s+s1;  outtextxy(595,28,s);
    s:='Y:';  str(yk,s1);  s:=s+s1;  outtextxy(595,38,s);
    goto 10;
2:  setcolor(0); close(f);  settextstyle(0,0,0); xk:=xk-2; yk:=yk-12;
    outtextxy(1,getmaxy-15,'████████████████████████████████████████████████████████████████████████████████');
    outtextxy(1,getmaxy-7,'████████████████████████████████████████████████████████████████████████████████');
    setfillstyle(1,0);
    bar(145,getmaxy-23,253,getmaxy-17);
end;


{  процедура, осуществляющая просмотр файла помощи }

procedure helper;
  var f,f1:text;
           j,i,k,m,x1,y1:integer;
           i1:longint;
           s:string;
           p:array[1..10702] of byte;
           ks:array[1..150] of longint;
           otv,funckey:boolean;
           ch:char;
           a:string[80];
  label
           2,5,8,10,15,25;
begin
    if tip=1 then begin      {tip=1}
    getimage(200,1,460,16,p);
    setcolor(14); setfillstyle(1,1);
    bar3d(200,1,460,16,0,topon);
    setcolor(15);
    outtextxy(205,5,'Ждите, HELP выводится на экран!');
    s:='savescr';
    slidesave(s,100,20,530,310);
    setcolor(9); setfillstyle(1,1);
    bar3d(101,21,529,309,0,topon);
    if look=1 then begin
      putimage(200,1,p,normalput);
      setviewport(100,20,525,305,clipon);
      goto 25;
    end;
    j:=103;k:=23;setcolor(14);
    assign(f1,'minihelp'); reset(f1);
    for m:=1 to 57 do begin
        readln(f1,s);
        outtextxy(j,k,s);
        k:=k+5;
    end;
    close(f1);
    putimage(200,1,p,normalput);
    ch:=readkey; if ch=chr(0) then ch:=readkey;
    s:='savescr';
    slideout(s,100,20,0,0);
    assign(f,s); erase(f);
    exit;
    end;
    setactivepage(0);
    setvisualpage(0);
    cleardevice;
25: setfillstyle(1,4);
    setcolor(10);
    bar(10,10,630,30);
    rectangle(10,10,630,30);
    setfillstyle(1,1);
    setcolor(13);
    bar(3,40,637,340);
    rectangle(3,40,637,340);
    moveto(20,16);
    setcolor(13); outtext('PgDn,');
    setcolor(13); outtext('PgUp,');
    setcolor(13); outtext('Home,');
    setcolor(13); outtext('End '); setcolor(10); outtext('──> Управление просмотром  ');
    setcolor(13); outtext('ESC ');  setcolor(10); outtext('Выход  ');
5:  if look=1 then assign(f,'progr.pas') else assign(f,'graphpr.hlp'); k:=1;
    reset(f);
    j:=1;   ks[1]:=0;
    while eof(f)=false do begin
    for i:=1 to 28 do  readln(f,s);
    j:=j+1;
    ks[j]:=textpos(f);
    end;
    j:=j-1;
8:  otv:=textseek(f,ks[k]);
    setcolor(4); outtextxy(570,16,'██████');
    setcolor(7); str(k:4,s); outtextxy(550,16,'Стp:'+s);setcolor(14);
    for i:=1 to 28 do begin
    if eof(f) then goto 2;
    readln(f,a);
    outtextxy(9,40+i*10,a);
    end;
2:  ;
10: ch:=readkey;
    if ch<>#0 then funckey:=false else
      begin
      funckey:=true;
      ch:=readkey;
    end;
    if ch=chr(73) then begin
      if k=1 then goto 10;
      k:=k-1;
      otv:=textseek(f,ks[i]);
      setfillstyle(1,1);
      setcolor(13);
      bar3d(3,40,637,340,0,topon);
      goto 8;
    end;
    if ch=chr(81) then begin
      if k=j then goto 10;
      k:=k+1;
      setfillstyle(1,1);
      setcolor(13);
      bar3d(3,40,637,340,0,topon);
      setcolor(14);
      goto 8;
    end;
    if ch=chr(79) then begin
       if k=j then goto 10;
       k:=j;
       setfillstyle(1,1);
       setcolor(13);
       bar3d(3,40,637,340,0,topon);
       setcolor(14);
       goto 8;
    end;
    if ch=chr(71) then begin
       if k=1 then goto 10;
       k:=1;
       setfillstyle(1,1);
       setcolor(13);
       bar3d(3,40,637,340,0,topon);
       setcolor(14);
       goto 8;
    end;
    if ch=chr(27) then goto 15;
    goto 10;
15:
    if (look=1) and (tip=1) then begin
      setviewport(0,0,getmaxx,getmaxy,clipon);
      s:='savescr';
      slideout(s,100,20,0,0);
      assign(f,s); erase(f);
      exit;
    end;
    setactivepage(1);
    setvisualpage(1);
end;

{ Дополнительное меню 1 }

procedure menu1(var elem:integer);
  var xb,yb,i:integer;
     ch:char;
     p:array[1..15000] of byte;
     funckey:boolean;

  label 9,10;
begin;

  { Вычерчивание МЕНЮ - 1 }

xb:=2; yb:=-22;
setfillstyle(1,7);
setlinestyle(0,0,0);
setcolor(6);
getimage(xb+1,yb+39,xb+627,yb+61,p);
xb:=2; yb:=-22;
bar3d(xb+2,yb+40,xb+626,yb+60,0,topoff);
line(xb+578,yb+60,xb+578,yb+40); line(xb+530,yb+40,xb+530,yb+60);
line(xb+482,yb+60,xb+482,yb+40); line(xb+434,yb+40,xb+434,yb+60);
line(xb+386,yb+60,xb+386,yb+40); line(xb+338,yb+40,xb+338,yb+60);
line(xb+290,yb+60,xb+290,yb+40); line(xb+242,yb+40,xb+242,yb+60);
line(xb+194,yb+60,xb+194,yb+40); line(xb+146,yb+40,xb+146,yb+60); line(xb+98,yb+60,xb+98,yb+40);
line(xb+50,yb+40,xb+50,yb+60);
setfillstyle(1,1);
bar(xb+22,yb+56,xb+6,yb+44);
bar(xb+55,yb+44,xb+71,yb+56);
setcolor(0);
line(xb+30,yb+49,xb+30,yb+52); line(xb+30,yb+52,xb+37,yb+52); line(xb+37,yb+52,xb+37,yb+55); line(xb+37,yb+55,xb+44,yb+50);
line(xb+30,yb+48,xb+37,yb+48); line(xb+37,yb+48,xb+37,yb+45); line(xb+37,yb+45,xb+44,yb+50); line(xb+92,yb+48,xb+85,yb+48);
line(xb+85,yb+48,xb+85,yb+45); line(xb+85,yb+45,xb+79,yb+50); line(xb+92,yb+48,xb+92,yb+52); line(xb+92,yb+52,xb+85,yb+52);
line(xb+85,yb+52,xb+85,yb+55); line(xb+85,yb+55,xb+79,yb+50);
xb:=xb-2; yb:=yb-15;
putpixel(xb+65,yb+60,0); putpixel(xb+65,yb+61,0); putpixel(xb+65,yb+62,0); putpixel(xb+64,yb+64,0);
putpixel(xb+65,yb+64,0); putpixel(xb+66,yb+64,0); putpixel(xb+64,yb+65,0); putpixel(xb+65,yb+65,0);
putpixel(xb+66,yb+65,0); putpixel(xb+64,yb+66,0); putpixel(xb+65,yb+66,0); putpixel(xb+66,yb+66,0);
putpixel(xb+16,yb+60,0); putpixel(xb+16,yb+61,0); putpixel(xb+16,yb+62,0); putpixel(xb+15,yb+64,0);
putpixel(xb+16,yb+64,0); putpixel(xb+17,yb+64,0); putpixel(xb+15,yb+65,0); putpixel(xb+16,yb+65,0);
putpixel(xb+17,yb+65,0); putpixel(xb+15,yb+66,0); putpixel(xb+16,yb+66,0); putpixel(xb+17,yb+66,0);
xb:=xb+2; yb:=yb+15;
setcolor(6);
line(xb+121,yb+53,xb+140,yb+53); line(xb+140,yb+53,xb+141,yb+56);
line(xb+141,yb+56,xb+120,yb+56); line(xb+120,yb+56,xb+121,yb+53);
line(xb+120,yb+54,xb+118,yb+54); line(xb+140,yb+54,xb+143,yb+54);
line(xb+143,yb+54,xb+143,yb+58); line(xb+143,yb+58,xb+118,yb+58);
line(xb+118,yb+58,xb+118,yb+55);
setcolor(15);
rectangle(xb+126,yb+52,xb+135,yb+45);
setcolor(15);
setfillstyle(1,15);
floodfill(xb+132,yb+48,15);
setcolor(6);
line(xb+123,yb+53,xb+123,yb+50); line(xb+123,yb+50,xb+125,yb+50);
line(xb+125,yb+50,xb+125,yb+52); line(xb+136,yb+52,xb+136,yb+50);
line(xb+136,yb+50,xb+138,yb+50); line(xb+138,yb+50,xb+138,yb+53);
setcolor(0);
line(xb+102,yb+52,xb+109,yb+52); line(xb+109,yb+52,xb+109,yb+54);
line(xb+109,yb+54,xb+109,yb+55); line(xb+109,yb+55,xb+114,yb+50);
line(xb+102,yb+52,xb+102,yb+48); line(xb+102,yb+48,xb+109,yb+48);
line(xb+109,yb+48,xb+109,yb+45); line(xb+109,yb+45,xb+114,yb+50);
setcolor(13);
settextstyle(1,0,2);
setcolor(1);
setfillstyle(1,1);
settextstyle(2,0,4);
outtextxy(xb+158,yb+41,'Импорт');
outtextxy(xb+158,yb+49,'текста');
settextstyle(0,0,1);
setcolor(3);
line(xb+215,yb+43,xb+234,yb+43);
line(xb+227,yb+56,xb+207,yb+56);
xb:=xb-2; yb:=yb-15;
putpixel(xb+215,yb+59,3); putpixel(xb+216,yb+59,3); putpixel(xb+213,yb+60,3); putpixel(xb+214,yb+60,3);
putpixel(xb+212,yb+61,3); putpixel(xb+211,yb+62,3); putpixel(xb+210,yb+63,3); putpixel(xb+209,yb+64,3);
putpixel(xb+208,yb+65,3); putpixel(xb+208,yb+66,3); putpixel(xb+207,yb+67,3); putpixel(xb+207,yb+68,3);
putpixel(xb+207,yb+69,3); putpixel(xb+208,yb+70,3); putpixel(xb+234,yb+59,3); putpixel(xb+235,yb+59,3);
putpixel(xb+236,yb+59,8); putpixel(xb+237,yb+59,3); putpixel(xb+232,yb+60,3); putpixel(xb+233,yb+60,3);
putpixel(xb+234,yb+60,8); putpixel(xb+235,yb+60,8); putpixel(xb+236,yb+60,8); putpixel(xb+237,yb+60,8);
putpixel(xb+238,yb+60,3); putpixel(xb+230,yb+61,3); putpixel(xb+231,yb+61,3); putpixel(xb+234,yb+61,3);
putpixel(xb+235,yb+61,8); putpixel(xb+236,yb+61,8); putpixel(xb+237,yb+61,8); putpixel(xb+238,yb+61,3);
putpixel(xb+229,yb+62,3); putpixel(xb+235,yb+62,3); putpixel(xb+236,yb+62,3); putpixel(xb+237,yb+62,3);
putpixel(xb+228,yb+63,3); putpixel(xb+227,yb+64,3); putpixel(xb+227,yb+65,3); putpixel(xb+226,yb+66,3);
putpixel(xb+226,yb+67,3); putpixel(xb+227,yb+67,3); putpixel(xb+228,yb+67,3); putpixel(xb+229,yb+67,3);
putpixel(xb+230,yb+67,3); putpixel(xb+231,yb+67,3); putpixel(xb+232,yb+67,3); putpixel(xb+226,yb+68,3);
putpixel(xb+227,yb+68,8); putpixel(xb+228,yb+68,8); putpixel(xb+229,yb+68,8); putpixel(xb+230,yb+68,3);
putpixel(xb+231,yb+68,8); putpixel(xb+232,yb+68,8); putpixel(xb+233,yb+68,3); putpixel(xb+227,yb+69,3);
putpixel(xb+228,yb+69,8); putpixel(xb+229,yb+69,8); putpixel(xb+230,yb+69,3); putpixel(xb+231,yb+69,8);
putpixel(xb+232,yb+69,8); putpixel(xb+233,yb+69,3); putpixel(xb+228,yb+70,3); putpixel(xb+229,yb+70,8);
putpixel(xb+230,yb+70,8); putpixel(xb+231,yb+70,3); putpixel(xb+232,yb+70,3); putpixel(xb+230,yb+71,3);
xb:=xb+2;yb:=yb+15;
setfillstyle(1,8);
floodfill(xb+219,yb+45,3);
setcolor(11);
line(xb+216,yb+45,xb+226,yb+45); line(xb+213,yb+47,xb+220,yb+47);
line(xb+210,yb+49,xb+222,yb+49); line(xb+209,yb+51,xb+211,yb+51);
line(xb+209,yb+53,xb+218,yb+53);
setcolor(0);
setcolor(3);
setcolor(0);
setfillstyle(1,3);
fillellipse(xb+260,yb+50,8,6);
line(xb+268,yb+50,xb+286,yb+50); line(xb+284,yb+49,xb+272,yb+49);
line(xb+272,yb+51,xb+284,yb+51); line(xb+288,yb+51,xb+288,yb+49);
setcolor(13);
xb:=xb-2;yb:=yb-15;
putpixel(xb+269,yb+56,13); putpixel(xb+268,yb+57,13); putpixel(xb+267,yb+58,13); putpixel(xb+266,yb+59,13);
putpixel(xb+267,yb+59,13); putpixel(xb+264,yb+60,13); putpixel(xb+265,yb+60,13); putpixel(xb+263,yb+61,13);
putpixel(xb+264,yb+61,13); putpixel(xb+265,yb+61,13); putpixel(xb+266,yb+61,13); putpixel(xb+262,yb+62,13);
putpixel(xb+263,yb+62,13); putpixel(xb+264,yb+62,13); putpixel(xb+265,yb+62,13); putpixel(xb+261,yb+63,13);
putpixel(xb+262,yb+63,13); putpixel(xb+263,yb+63,13); putpixel(xb+264,yb+63,13); putpixel(xb+260,yb+64,13);
putpixel(xb+261,yb+64,13); putpixel(xb+262,yb+64,13); putpixel(xb+263,yb+64,13); putpixel(xb+259,yb+65,13);
putpixel(xb+260,yb+65,13); putpixel(xb+261,yb+65,13); putpixel(xb+262,yb+65,13); putpixel(xb+258,yb+66,13);
putpixel(xb+259,yb+66,13); putpixel(xb+260,yb+66,13); putpixel(xb+261,yb+66,13); putpixel(xb+257,yb+67,13);
putpixel(xb+258,yb+67,13); putpixel(xb+259,yb+67,13); putpixel(xb+260,yb+67,13); putpixel(xb+256,yb+68,13);
putpixel(xb+257,yb+68,13); putpixel(xb+258,yb+68,13); putpixel(xb+259,yb+68,13); putpixel(xb+257,yb+69,13);
putpixel(xb+258,yb+69,13); putpixel(xb+255,yb+70,13); putpixel(xb+254,yb+71,13); putpixel(xb+253,yb+72,13);
putpixel(xb+252,yb+73,13);
xb:=xb+2;yb:=yb+15;

setcolor(0);
line(xb+309,yb+42,xb+305,yb+50); line(xb+305,yb+50,xb+307,yb+50);
line(xb+307,yb+50,xb+309,yb+42); line(xb+309,yb+50,xb+302,yb+50);
line(xb+302,yb+50,xb+301,yb+52); line(xb+301,yb+52,xb+308,yb+52);
line(xb+308,yb+52,xb+309,yb+50);
xb:=xb-2; yb:=yb-15;

putpixel(xb+303,yb+68,0); putpixel(xb+305,yb+68,0);  putpixel(xb+307,yb+68,0); putpixel(xb+309,yb+68,0);
putpixel(xb+303,yb+69,0); putpixel(xb+305,yb+69,0);  putpixel(xb+307,yb+69,0); putpixel(xb+309,yb+69,0);
putpixel(xb+302,yb+70,0); putpixel(xb+304,yb+70,0);  putpixel(xb+306,yb+70,0); putpixel(xb+308,yb+70,0);
putpixel(xb+302,yb+71,0); putpixel(xb+304,yb+71,0);  putpixel(xb+306,yb+71,0); putpixel(xb+308,yb+71,0);
putpixel(xb+301,yb+72,0); putpixel(xb+303,yb+72,0);  putpixel(xb+305,yb+72,0); putpixel(xb+307,yb+72,0);
putpixel(xb+301,yb+73,0); putpixel(xb+303,yb+73,0);  putpixel(xb+305,yb+73,0); putpixel(xb+307,yb+73,0);
putpixel(xb+319,yb+57,10);putpixel(xb+320,yb+57,10); putpixel(xb+321,yb+57,10);putpixel(xb+322,yb+57,10);
putpixel(xb+323,yb+57,10);putpixel(xb+324,yb+57,10); putpixel(xb+317,yb+58,10);putpixel(xb+318,yb+58,10);
putpixel(xb+315,yb+59,10);putpixel(xb+316,yb+59,10); putpixel(xb+314,yb+60,10);putpixel(xb+323,yb+60,10);
putpixel(xb+324,yb+60,10);putpixel(xb+313,yb+61,10); putpixel(xb+321,yb+61,10);putpixel(xb+322,yb+61,10);
putpixel(xb+312,yb+62,10);putpixel(xb+320,yb+62,10); putpixel(xb+312,yb+63,10);putpixel(xb+319,yb+63,10);
putpixel(xb+313,yb+64,10);putpixel(xb+319,yb+64,10); putpixel(xb+313,yb+65,10);putpixel(xb+320,yb+65,10);
putpixel(xb+311,yb+66,10);putpixel(xb+312,yb+66,10); putpixel(xb+320,yb+66,10);putpixel(xb+311,yb+67,10);
putpixel(xb+319,yb+67,10);putpixel(xb+310,yb+68,10); putpixel(xb+317,yb+68,10);putpixel(xb+318,yb+68,10);
putpixel(xb+310,yb+69,10);putpixel(xb+315,yb+69,10); putpixel(xb+316,yb+69,10);putpixel(xb+309,yb+70,10);
putpixel(xb+312,yb+70,10);putpixel(xb+313,yb+70,10); putpixel(xb+314,yb+70,10);putpixel(xb+309,yb+71,10);
putpixel(xb+310,yb+71,10);putpixel(xb+311,yb+71,10); putpixel(xb+308,yb+72,10);putpixel(xb+325,yb+57,10);
putpixel(xb+326,yb+57,10);putpixel(xb+327,yb+58,10); putpixel(xb+328,yb+58,10);putpixel(xb+329,yb+59,10);
putpixel(xb+329,yb+60,10);putpixel(xb+325,yb+61,10); putpixel(xb+326,yb+61,10);putpixel(xb+327,yb+61,10);
putpixel(xb+328,yb+61,10);
xb:=xb+2; yb:=yb+15;
setcolor(10);
setfillstyle(1,10);
floodfill(xb+314,yb+48,10);
setcolor(8);
setfillstyle(1,8);
fillellipse(xb+363,yb+50,18,8);
xb:=xb-2;yb:=yb-15;
putpixel(xb+376,yb+67,7); putpixel(xb+377,yb+67,7); putpixel(xb+378,yb+67,7); putpixel(xb+379,yb+67,7);
putpixel(xb+374,yb+68,7); putpixel(xb+375,yb+68,7); putpixel(xb+376,yb+68,7); putpixel(xb+377,yb+68,7);
putpixel(xb+378,yb+68,7); putpixel(xb+379,yb+68,7); putpixel(xb+380,yb+68,7); putpixel(xb+381,yb+68,7);
putpixel(xb+373,yb+69,7); putpixel(xb+374,yb+69,7); putpixel(xb+375,yb+69,7); putpixel(xb+376,yb+69,7);
putpixel(xb+377,yb+69,7); putpixel(xb+378,yb+69,7); putpixel(xb+379,yb+69,7); putpixel(xb+380,yb+69,7);
putpixel(xb+381,yb+69,7); putpixel(xb+373,yb+70,7); putpixel(xb+374,yb+70,7); putpixel(xb+375,yb+70,7);
putpixel(xb+376,yb+70,7); putpixel(xb+377,yb+70,7); putpixel(xb+378,yb+70,7); putpixel(xb+379,yb+70,7);
putpixel(xb+374,yb+71,7); putpixel(xb+375,yb+71,7); putpixel(xb+376,yb+71,7); putpixel(xb+377,yb+71,7);
putpixel(xb+378,yb+71,7);
xb:=xb+2;yb:=yb+15;

setlinestyle(0,0,3);
setcolor(14); line(xb+361,yb+45,xb+365,yb+45);
setcolor(10); line(xb+370,yb+46,xb+374,yb+46);
setcolor(13); line(xb+352,yb+47,xb+356,yb+47);
setcolor(15); line(xb+349,yb+52,xb+353,yb+52);
setcolor(4);  line(xb+356,yb+55,xb+360,yb+55);
setcolor(11); line(xb+364,yb+56,xb+368,yb+56);
setlinestyle(0,0,0);
setcolor(0);
line(xb+401,yb+48,xb+421,yb+48); line(xb+421,yb+48,xb+421,yb+45);
line(xb+421,yb+45,xb+429,yb+50); line(xb+429,yb+50,xb+421,yb+55);
line(xb+421,yb+55,xb+421,yb+52); line(xb+421,yb+52,xb+401,yb+52);
line(xb+401,yb+52,xb+401,yb+55); line(xb+401,yb+55,xb+393,yb+50);
line(xb+393,yb+50,xb+401,yb+45); line(xb+401,yb+45,xb+401,yb+48);
line(xb+459,yb+43,xb+454,yb+48); line(xb+454,yb+48,xb+457,yb+48);
line(xb+457,yb+48,xb+457,yb+51); line(xb+457,yb+51,xb+454,yb+51);
line(xb+454,yb+51,xb+459,yb+56); line(xb+459,yb+56,xb+464,yb+51);
line(xb+464,yb+51,xb+461,yb+51); line(xb+461,yb+51,xb+461,yb+48);
line(xb+461,yb+48,xb+464,yb+48); line(xb+464,yb+48,xb+459,yb+43);
setcolor(0);
setfillstyle(1,1);
bar3d(xb+488,yb+43,xb+528,yb+58,0,topoff);
xb:=xb-2;yb:=yb-15;
putpixel(xb+500,yb+60,14); putpixel(xb+493,yb+62,14); putpixel(xb+505,yb+63,14); putpixel(xb+497,yb+66,14);
putpixel(xb+506,yb+67,14); putpixel(xb+494,yb+70,14); putpixel(xb+500,yb+70,14); putpixel(xb+509,yb+71,14);
putpixel(xb+525,yb+60,14); putpixel(xb+509,yb+61,14); putpixel(xb+515,yb+62,14); putpixel(xb+512,yb+65,14);
putpixel(xb+520,yb+65,14); putpixel(xb+515,yb+68,14); putpixel(xb+525,yb+69,14); putpixel(xb+520,yb+71,14);
xb:=xb+2; yb:=yb+15;
bar3d(xb+536,yb+43,xb+576,yb+58,0,topoff);
bar3d(xb+584,yb+58,xb+624,yb+43,0,topoff);
setcolor(10);
setfillstyle(11,13);
fillellipse(xb+556,yb+50,16,5);
fillellipse(xb+604,yb+50,16,5);
xb:=xb-2; yb:=yb-15;
putpixel(xb+539,yb+59,0); putpixel(xb+540,yb+59,0);  putpixel(xb+541,yb+59,0); putpixel(xb+542,yb+59,0);
putpixel(xb+543,yb+59,0); putpixel(xb+544,yb+59,0);  putpixel(xb+545,yb+59,0); putpixel(xb+546,yb+59,0);
putpixel(xb+547,yb+59,0); putpixel(xb+548,yb+59,0);  putpixel(xb+549,yb+59,0); putpixel(xb+550,yb+59,0);
putpixel(xb+551,yb+59,0); putpixel(xb+552,yb+59,0);  putpixel(xb+553,yb+59,0); putpixel(xb+554,yb+59,0);
putpixel(xb+555,yb+59,0); putpixel(xb+556,yb+59,0);  putpixel(xb+539,yb+60,0); putpixel(xb+540,yb+60,0);
putpixel(xb+541,yb+60,0); putpixel(xb+542,yb+60,0);  putpixel(xb+543,yb+60,0); putpixel(xb+544,yb+60,0);
putpixel(xb+545,yb+60,0); putpixel(xb+546,yb+60,0);  putpixel(xb+547,yb+60,0); putpixel(xb+548,yb+60,0);
putpixel(xb+549,yb+60,0); putpixel(xb+550,yb+60,0);  putpixel(xb+551,yb+60,0); putpixel(xb+539,yb+61,0);
putpixel(xb+540,yb+61,0); putpixel(xb+541,yb+61,0);  putpixel(xb+542,yb+61,0); putpixel(xb+543,yb+61,0);
putpixel(xb+544,yb+61,0); putpixel(xb+545,yb+61,0);  putpixel(xb+546,yb+61,0); putpixel(xb+539,yb+62,0);
putpixel(xb+540,yb+62,0); putpixel(xb+541,yb+62,0);  putpixel(xb+542,yb+62,0); putpixel(xb+543,yb+62,0);
putpixel(xb+544,yb+62,0); putpixel(xb+550,yb+62,0);  putpixel(xb+554,yb+62,0); putpixel(xb+539,yb+63,0);
putpixel(xb+540,yb+63,0); putpixel(xb+541,yb+63,0);  putpixel(xb+542,yb+63,0); putpixel(xb+539,yb+64,0);
putpixel(xb+540,yb+64,0); putpixel(xb+541,yb+64,0);  putpixel(xb+544,yb+64,0); putpixel(xb+548,yb+64,0);
putpixel(xb+552,yb+64,0); putpixel(xb+556,yb+64,0);  putpixel(xb+539,yb+65,0); putpixel(xb+540,yb+65,0);
putpixel(xb+541,yb+65,0); putpixel(xb+539,yb+66,0);  putpixel(xb+540,yb+66,0); putpixel(xb+541,yb+66,0);
putpixel(xb+546,yb+66,0); putpixel(xb+550,yb+66,0);  putpixel(xb+554,yb+66,0); putpixel(xb+539,yb+67,0);
putpixel(xb+540,yb+67,0); putpixel(xb+541,yb+67,0);  putpixel(xb+542,yb+67,0); putpixel(xb+539,yb+68,0);
putpixel(xb+540,yb+68,0); putpixel(xb+541,yb+68,0);  putpixel(xb+542,yb+68,0); putpixel(xb+543,yb+68,0);
putpixel(xb+544,yb+68,0); putpixel(xb+548,yb+68,0);  putpixel(xb+552,yb+68,0); putpixel(xb+556,yb+68,0);
putpixel(xb+539,yb+69,0); putpixel(xb+540,yb+69,0);  putpixel(xb+541,yb+69,0); putpixel(xb+542,yb+69,0);
putpixel(xb+543,yb+69,0); putpixel(xb+544,yb+69,0);  putpixel(xb+545,yb+69,0); putpixel(xb+546,yb+69,0);
putpixel(xb+539,yb+70,0); putpixel(xb+540,yb+70,0);  putpixel(xb+541,yb+70,0); putpixel(xb+542,yb+70,0);
putpixel(xb+543,yb+70,0); putpixel(xb+544,yb+70,0);  putpixel(xb+545,yb+70,0); putpixel(xb+546,yb+70,0);
putpixel(xb+547,yb+70,0); putpixel(xb+548,yb+70,0);  putpixel(xb+549,yb+70,0); putpixel(xb+550,yb+70,0);
putpixel(xb+551,yb+70,0); putpixel(xb+539,yb+71,0);  putpixel(xb+540,yb+71,0); putpixel(xb+541,yb+71,0);
putpixel(xb+542,yb+71,0); putpixel(xb+543,yb+71,0);  putpixel(xb+544,yb+71,0); putpixel(xb+545,yb+71,0);
putpixel(xb+546,yb+71,0); putpixel(xb+547,yb+71,0);  putpixel(xb+548,yb+71,0); putpixel(xb+549,yb+71,0);
putpixel(xb+550,yb+71,0); putpixel(xb+551,yb+71,0);  putpixel(xb+552,yb+71,0); putpixel(xb+553,yb+71,0);
putpixel(xb+554,yb+71,0); putpixel(xb+555,yb+71,0);  putpixel(xb+556,yb+71,0); putpixel(xb+539,yb+72,0);
putpixel(xb+540,yb+72,0); putpixel(xb+541,yb+72,0);  putpixel(xb+542,yb+72,0); putpixel(xb+543,yb+72,0);
putpixel(xb+544,yb+72,0); putpixel(xb+545,yb+72,0);  putpixel(xb+546,yb+72,0); putpixel(xb+547,yb+72,0);
putpixel(xb+548,yb+72,0); putpixel(xb+549,yb+72,0);  putpixel(xb+550,yb+72,0); putpixel(xb+551,yb+72,0);
putpixel(xb+552,yb+72,0); putpixel(xb+553,yb+72,0);  putpixel(xb+554,yb+72,0); putpixel(xb+555,yb+72,0);
putpixel(xb+556,yb+72,0); putpixel(xb+587,yb+59,4);  putpixel(xb+588,yb+59,4); putpixel(xb+589,yb+59,4);
putpixel(xb+590,yb+59,4); putpixel(xb+591,yb+59,4);  putpixel(xb+592,yb+59,4); putpixel(xb+593,yb+59,4);
putpixel(xb+594,yb+59,4); putpixel(xb+595,yb+59,4);  putpixel(xb+596,yb+59,4); putpixel(xb+597,yb+59,4);
putpixel(xb+598,yb+59,4); putpixel(xb+599,yb+59,4);  putpixel(xb+600,yb+59,4); putpixel(xb+601,yb+59,4);
putpixel(xb+602,yb+59,4); putpixel(xb+603,yb+59,4);  putpixel(xb+604,yb+59,4); putpixel(xb+587,yb+60,4);
putpixel(xb+588,yb+60,4); putpixel(xb+589,yb+60,4);  putpixel(xb+590,yb+60,4); putpixel(xb+591,yb+60,4);
putpixel(xb+592,yb+60,4); putpixel(xb+593,yb+60,4);  putpixel(xb+594,yb+60,4); putpixel(xb+595,yb+60,4);
putpixel(xb+596,yb+60,4); putpixel(xb+597,yb+60,4);  putpixel(xb+598,yb+60,4); putpixel(xb+599,yb+60,4);
putpixel(xb+600,yb+60,14);putpixel(xb+601,yb+60,14); putpixel(xb+602,yb+60,14);putpixel(xb+603,yb+60,14);
putpixel(xb+604,yb+60,14);putpixel(xb+587,yb+61,4);  putpixel(xb+588,yb+61,4); putpixel(xb+589,yb+61,4);
putpixel(xb+590,yb+61,4); putpixel(xb+591,yb+61,4);  putpixel(xb+592,yb+61,4); putpixel(xb+593,yb+61,4);
putpixel(xb+594,yb+61,4); putpixel(xb+595,yb+61,14); putpixel(xb+596,yb+61,14);putpixel(xb+597,yb+61,14);
putpixel(xb+598,yb+61,14);putpixel(xb+599,yb+61,14); putpixel(xb+587,yb+62,4); putpixel(xb+588,yb+62,4);
putpixel(xb+589,yb+62,4); putpixel(xb+590,yb+62,4);  putpixel(xb+591,yb+62,4); putpixel(xb+592,yb+62,4);
putpixel(xb+593,yb+62,14);putpixel(xb+594,yb+62,14); putpixel(xb+598,yb+62,1); putpixel(xb+602,yb+62,1);
putpixel(xb+587,yb+63,4); putpixel(xb+588,yb+63,4);  putpixel(xb+589,yb+63,4); putpixel(xb+590,yb+63,4);
putpixel(xb+591,yb+63,14);putpixel(xb+592,yb+63,14); putpixel(xb+587,yb+64,4); putpixel(xb+588,yb+64,4);
putpixel(xb+589,yb+64,4); putpixel(xb+590,yb+64,14); putpixel(xb+592,yb+64,1); putpixel(xb+596,yb+64,1);
putpixel(xb+600,yb+64,1); putpixel(xb+604,yb+64,1);  putpixel(xb+587,yb+65,4); putpixel(xb+588,yb+65,4);
putpixel(xb+589,yb+65,4); putpixel(xb+590,yb+65,14); putpixel(xb+587,yb+66,4); putpixel(xb+588,yb+66,4);
putpixel(xb+589,yb+66,4); putpixel(xb+590,yb+66,14); putpixel(xb+594,yb+66,1); putpixel(xb+598,yb+66,1);
putpixel(xb+602,yb+66,1); putpixel(xb+587,yb+67,4);  putpixel(xb+588,yb+67,4); putpixel(xb+589,yb+67,4);
putpixel(xb+590,yb+67,4); putpixel(xb+591,yb+67,14); putpixel(xb+592,yb+67,14);putpixel(xb+587,yb+68,4);
putpixel(xb+588,yb+68,4); putpixel(xb+589,yb+68,4);  putpixel(xb+590,yb+68,4); putpixel(xb+591,yb+68,4);
putpixel(xb+592,yb+68,4); putpixel(xb+593,yb+68,14); putpixel(xb+594,yb+68,14);putpixel(xb+596,yb+68,1);
putpixel(xb+600,yb+68,1); putpixel(xb+604,yb+68,1);  putpixel(xb+587,yb+69,4); putpixel(xb+588,yb+69,4);
putpixel(xb+589,yb+69,4); putpixel(xb+590,yb+69,4);  putpixel(xb+591,yb+69,4); putpixel(xb+592,yb+69,4);
putpixel(xb+593,yb+69,4); putpixel(xb+594,yb+69,4);  putpixel(xb+595,yb+69,14);putpixel(xb+596,yb+69,14);
putpixel(xb+597,yb+69,14);putpixel(xb+598,yb+69,14); putpixel(xb+599,yb+69,14);putpixel(xb+587,yb+70,4);
putpixel(xb+588,yb+70,4); putpixel(xb+589,yb+70,4);  putpixel(xb+590,yb+70,4); putpixel(xb+591,yb+70,4);
putpixel(xb+592,yb+70,4); putpixel(xb+593,yb+70,4);  putpixel(xb+594,yb+70,4); putpixel(xb+595,yb+70,4);
putpixel(xb+596,yb+70,4); putpixel(xb+597,yb+70,4);  putpixel(xb+598,yb+70,4); putpixel(xb+599,yb+70,4);
putpixel(xb+600,yb+70,14);putpixel(xb+601,yb+70,14); putpixel(xb+602,yb+70,14);putpixel(xb+603,yb+70,14);
putpixel(xb+604,yb+70,14);putpixel(xb+587,yb+71,4);  putpixel(xb+588,yb+71,4); putpixel(xb+589,yb+71,4);
putpixel(xb+590,yb+71,4); putpixel(xb+591,yb+71,4);  putpixel(xb+592,yb+71,4); putpixel(xb+593,yb+71,4);
putpixel(xb+594,yb+71,4); putpixel(xb+595,yb+71,4);  putpixel(xb+596,yb+71,4); putpixel(xb+597,yb+71,4);
putpixel(xb+598,yb+71,4); putpixel(xb+599,yb+71,4);  putpixel(xb+600,yb+71,4); putpixel(xb+601,yb+71,4);
putpixel(xb+602,yb+71,4); putpixel(xb+603,yb+71,4);  putpixel(xb+604,yb+71,4); putpixel(xb+587,yb+72,4);
putpixel(xb+588,yb+72,4); putpixel(xb+589,yb+72,4);  putpixel(xb+590,yb+72,4); putpixel(xb+591,yb+72,4);
putpixel(xb+592,yb+72,4); putpixel(xb+593,yb+72,4);  putpixel(xb+594,yb+72,4); putpixel(xb+595,yb+72,4);
putpixel(xb+596,yb+72,4); putpixel(xb+597,yb+72,4);  putpixel(xb+598,yb+72,4); putpixel(xb+599,yb+72,4);
putpixel(xb+600,yb+72,4); putpixel(xb+601,yb+72,4);  putpixel(xb+602,yb+72,4); putpixel(xb+603,yb+72,4);
putpixel(xb+604,yb+72,4);
setcolor(15);
setwritemode(1);

  { Конец вычерчивания МЕНЮ - 1 }

xb:=4; yb:=18; elem:=1;
setlinestyle(0,0,3);
9: rectangle(xb,yb,xb+48,yb+20);
10: ch:=readkey;
    if ch=chr(0) then begin
       funckey:=true; ch:=readkey; end else funckey:=false;

    if (ch=chr(77)) and (funckey=true) then begin
       rectangle(xb,yb,xb+48,yb+20);
       xb:=xb+48; elem:=elem+1; if xb>610 then begin xb:=4; elem:=1; end;
       sound(1000); delay(20); nosound;
       goto 9;
       end;
    if (ch=chr(75)) and (funckey=true) then begin
       rectangle(xb,yb,xb+48,yb+20);
       xb:=xb-48; elem:=elem-1; if xb<0 then begin elem:=13; xb:=580;  end;
       sound(1000); delay(20); nosound;
       goto 9;
       end;
    if ch=chr(13) then begin
       setwritemode(0);
       setlinestyle(0,0,0);
       putimage(3,17,p,normalput);
       exit;
       end;
    if ch=chr(27) then begin
       setwritemode(0);
       setlinestyle(0,0,0);
       putimage(3,17,p,normalput);
       elem:=0;
       exit;
       end;
    goto 10;
 end;

{ Дополнительное меню 2 }

procedure menu2(var elem:integer);
  var xb,yb,i:integer;
     ch:char;
     p:array[1..15000] of byte;
     funckey:boolean;

  label 9,10;
begin;

  { Вычерчивание МЕНЮ - 2 }

xb:=2; yb:=-22;
setfillstyle(1,7);
setlinestyle(0,0,0);
setcolor(6);
getimage(xb+1,yb+39,xb+627,yb+61,p);
xb:=2; yb:=-22;
bar3d(xb+2,yb+40,xb+626,yb+60,0,topoff);
line(xb+578,yb+60,xb+578,yb+40); line(xb+530,yb+40,xb+530,yb+60);
line(xb+482,yb+60,xb+482,yb+40); line(xb+434,yb+40,xb+434,yb+60);
line(xb+386,yb+60,xb+386,yb+40); line(xb+338,yb+40,xb+338,yb+60);
line(xb+290,yb+60,xb+290,yb+40); line(xb+242,yb+40,xb+242,yb+60);
line(xb+194,yb+60,xb+194,yb+40); line(xb+146,yb+40,xb+146,yb+60); line(xb+98,yb+60,xb+98,yb+40);
line(xb+50,yb+40,xb+50,yb+60);
yb:=-28;
putpixel(xb+39,yb+49,1); putpixel(xb+40,yb+49,1); putpixel(xb+41,yb+49,1); putpixel(xb+45,yb+49,1);
putpixel(xb+46,yb+49,1); putpixel(xb+47,yb+49,1); putpixel(xb+38,yb+50,1); putpixel(xb+42,yb+50,1);
putpixel(xb+43,yb+50,1); putpixel(xb+44,yb+50,1); putpixel(xb+48,yb+50,1); putpixel(xb+37,yb+51,1);
putpixel(xb+48,yb+51,1); putpixel(xb+37,yb+52,1); putpixel(xb+48,yb+52,1); putpixel(xb+38,yb+53,1);
putpixel(xb+47,yb+53,1); putpixel(xb+38,yb+54,1); putpixel(xb+47,yb+54,1); putpixel(xb+37,yb+55,1);
putpixel(xb+47,yb+55,1); putpixel(xb+37,yb+56,1); putpixel(xb+48,yb+56,1); putpixel(xb+37,yb+57,1);
putpixel(xb+48,yb+57,1); putpixel(xb+36,yb+58,1); putpixel(xb+48,yb+58,1); putpixel(xb+36,yb+59,1);
putpixel(xb+47,yb+59,1); putpixel(xb+37,yb+60,1); putpixel(xb+47,yb+60,1); putpixel(xb+38,yb+61,1);
putpixel(xb+39,yb+61,1); putpixel(xb+46,yb+61,1); putpixel(xb+40,yb+62,1); putpixel(xb+41,yb+62,1);
putpixel(xb+45,yb+62,1); putpixel(xb+42,yb+63,1); putpixel(xb+43,yb+63,1); putpixel(xb+44,yb+63,1);
putpixel(xb+9,yb+49,4);  putpixel(xb+10,yb+49,4); putpixel(xb+11,yb+49,4); putpixel(xb+6,yb+50,4);
putpixel(xb+7,yb+50,4);  putpixel(xb+8,yb+50,4);  putpixel(xb+12,yb+50,4); putpixel(xb+13,yb+50,4);
putpixel(xb+14,yb+50,4); putpixel(xb+5,yb+51,4);  putpixel(xb+15,yb+51,4); putpixel(xb+5,yb+52,4);
putpixel(xb+15,yb+52,4); putpixel(xb+5,yb+53,4);  putpixel(xb+16,yb+53,4); putpixel(xb+6,yb+54,4);
putpixel(xb+16,yb+54,4); putpixel(xb+7,yb+55,4);  putpixel(xb+16,yb+55,4); putpixel(xb+7,yb+56,4);
putpixel(xb+17,yb+56,4); putpixel(xb+7,yb+57,4);  putpixel(xb+17,yb+57,4); putpixel(xb+6,yb+58,4);
putpixel(xb+17,yb+58,4); putpixel(xb+5,yb+59,4);  putpixel(xb+16,yb+59,4); putpixel(xb+5,yb+60,4);
putpixel(xb+16,yb+60,4); putpixel(xb+5,yb+61,4);  putpixel(xb+14,yb+61,4); putpixel(xb+15,yb+61,4);
putpixel(xb+6,yb+62,4);  putpixel(xb+10,yb+62,4); putpixel(xb+11,yb+62,4); putpixel(xb+12,yb+62,4);
putpixel(xb+13,yb+62,4); putpixel(xb+7,yb+63,4);  putpixel(xb+8,yb+63,4);  putpixel(xb+9,yb+63,4);
setcolor(4);
setfillstyle(1,4);
floodfill(xb+10,yb+55,4);
setcolor(1);
setfillstyle(1,1);
floodfill(xb+42,yb+55,1);
setcolor(0);
line(xb+21,yb+55,xb+21,yb+59); line(xb+21,yb+59,xb+27,yb+59);
line(xb+27,yb+59,xb+27,yb+62); line(xb+27,yb+62,xb+33,yb+57);
line(xb+33,yb+57,xb+27,yb+52); line(xb+27,yb+52,xb+27,yb+55);
line(xb+27,yb+55,xb+22,yb+55);
yb:=yb-2;
bar3d(xb+58,yb+60,xb+85,yb+64,7,topon);
setlinestyle(0,0,3);
line(xb+75,yb+57,xb+75,yb+51);
line(xb+70,yb+51,xb+80,yb+51);
setlinestyle(0,0,0);
putpixel(xb+134,yb+50,0);  putpixel(xb+135,yb+50,0); putpixel(xb+136,yb+50,0);  putpixel(xb+133,yb+51,0);
putpixel(xb+137,yb+51,0);  putpixel(xb+132,yb+52,0); putpixel(xb+138,yb+52,0);  putpixel(xb+132,yb+53,0);
putpixel(xb+138,yb+53,0);  putpixel(xb+122,yb+54,0); putpixel(xb+131,yb+54,0);  putpixel(xb+132,yb+54,0);
putpixel(xb+138,yb+54,0);  putpixel(xb+123,yb+55,0); putpixel(xb+124,yb+55,0);  putpixel(xb+130,yb+55,0);
putpixel(xb+131,yb+55,0);  putpixel(xb+133,yb+55,0); putpixel(xb+137,yb+55,0);  putpixel(xb+125,yb+56,0);
putpixel(xb+127,yb+56,0);  putpixel(xb+129,yb+56,0); putpixel(xb+134,yb+56,0);  putpixel(xb+135,yb+56,0);
putpixel(xb+136,yb+56,0);  putpixel(xb+126,yb+57,0); putpixel(xb+127,yb+57,0);  putpixel(xb+128,yb+57,0);
putpixel(xb+126,yb+58,0);  putpixel(xb+127,yb+58,0); putpixel(xb+128,yb+58,0);  putpixel(xb+125,yb+59,0);
putpixel(xb+127,yb+59,0);  putpixel(xb+129,yb+59,0); putpixel(xb+134,yb+59,0);  putpixel(xb+135,yb+59,0);
putpixel(xb+136,yb+59,0);  putpixel(xb+123,yb+60,0); putpixel(xb+124,yb+60,0);  putpixel(xb+130,yb+60,0);
putpixel(xb+131,yb+60,0);  putpixel(xb+133,yb+60,0); putpixel(xb+137,yb+60,0);  putpixel(xb+122,yb+61,0);
putpixel(xb+131,yb+61,0);  putpixel(xb+132,yb+61,0); putpixel(xb+138,yb+61,0);  putpixel(xb+132,yb+62,0);
putpixel(xb+138,yb+62,0);  putpixel(xb+132,yb+63,0); putpixel(xb+138,yb+63,0);  putpixel(xb+133,yb+64,0);
putpixel(xb+137,yb+64,0);  putpixel(xb+134,yb+65,0); putpixel(xb+135,yb+65,0);  putpixel(xb+136,yb+65,0);
putpixel(xb+116,yb+53,0);  putpixel(xb+117,yb+53,0); putpixel(xb+118,yb+53,0);  putpixel(xb+119,yb+53,0);
putpixel(xb+120,yb+53,0);  putpixel(xb+115,yb+54,0); putpixel(xb+116,yb+54,0);  putpixel(xb+117,yb+54,0);
putpixel(xb+118,yb+54,0);  putpixel(xb+119,yb+54,0); putpixel(xb+120,yb+54,0);  putpixel(xb+121,yb+54,0);
putpixel(xb+122,yb+55,0);  putpixel(xb+124,yb+56,0); putpixel(xb+125,yb+57,0);  putpixel(xb+125,yb+58,0);
putpixel(xb+124,yb+59,0);  putpixel(xb+122,yb+60,0); putpixel(xb+115,yb+61,0);  putpixel(xb+116,yb+61,0);
putpixel(xb+117,yb+61,0);  putpixel(xb+118,yb+61,0); putpixel(xb+119,yb+61,0);  putpixel(xb+120,yb+61,0);
putpixel(xb+121,yb+61,0);  putpixel(xb+116,yb+62,0); putpixel(xb+117,yb+62,0);  putpixel(xb+118,yb+62,0);
putpixel(xb+119,yb+62,0);  putpixel(xb+120,yb+62,0);
line(xb+100,yb+50,xb+100,yb+65); line(xb+100,yb+65,xb+112,yb+65);
line(xb+112,yb+65,xb+112,yb+60); line(xb+112,yb+60,xb+104,yb+60);
line(xb+104,yb+60,xb+104,yb+50); line(xb+104,yb+50,xb+100,yb+50);
line(xb+107,yb+50,xb+107,yb+57); line(xb+107,yb+57,xb+112,yb+57);
line(xb+112,yb+57,xb+112,yb+50); line(xb+112,yb+50,xb+107,yb+50);
setfillstyle(1,2);
floodfill(xb+109,yb+52,0);
floodfill(xb+109,yb+62,0);
settextstyle(2,0,4);
setcolor(0);
outtextxy(xb+152,yb+47,'Or');
outtextxy(xb+176,yb+47,'Not');
outtextxy(xb+155,yb+57,'Normal');
setcolor(4);
settextstyle(0,0,1);
outtextxy(xb+165,yb+52,'?');
settextstyle(0,0,2);
setcolor(1);
outtextxy(xb+211,yb+51,'?');
outtextxy(xb+258,yb+51,'?'); outtextxy(xb+305,yb+51,'?');
outtextxy(xb+353,yb+51,'?'); outtextxy(xb+403,yb+51,'?');
outtextxy(xb+451,yb+51,'?'); outtextxy(xb+500,yb+51,'?');
outtextxy(xb+546,yb+51,'?'); outtextxy(xb+594,yb+51,'?');
settextstyle(0,0,1);
setcolor(15);
setwritemode(1);

  { Конец вычерчивания МЕНЮ - 2 }

xb:=4; yb:=18; elem:=1;
setlinestyle(0,0,3);
9: rectangle(xb,yb,xb+48,yb+20);
10: ch:=readkey;
    if ch=chr(0) then begin
       funckey:=true; ch:=readkey; end else funckey:=false;

    if (ch=chr(77)) and (funckey=true) then begin
       rectangle(xb,yb,xb+48,yb+20);
       xb:=xb+48; elem:=elem+1; if xb>610 then begin xb:=4; elem:=1; end;
       sound(1000); delay(20); nosound;
       goto 9;
       end;
    if (ch=chr(75)) and (funckey=true) then begin
       rectangle(xb,yb,xb+48,yb+20);
       xb:=xb-48; elem:=elem-1; if xb<0 then begin elem:=13; xb:=580;  end;
       sound(1000); delay(20); nosound;
       goto 9;
       end;
    if ch=chr(13) then begin
       setwritemode(0);
       setlinestyle(0,0,0);
       putimage(3,17,p,normalput);
       exit;
       end;
    if ch=chr(27) then begin
       setwritemode(0);
       setlinestyle(0,0,0);
       putimage(3,17,p,normalput);
       elem:=0;
       exit;
       end;
    goto 10;
 end;


end.
