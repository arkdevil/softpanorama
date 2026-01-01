program recod;
uses dos,graph,slaid;
{┌──────────────────────────────────────────────────────────────────────┐}
{│          Программа предназначена для перекодировки слайдов           │}
{│          из старого формата в новый.  Надеюсь, что она бу-           │}
{│          дет работать нормально.                                     │}
{└──────────────────────────────────────────────────────────────────────┘}
var
  grmode,grdriver:integer;
  s:pathstr;
  a1:dirstr;
  a2:namestr;
  a3:extstr;
  f:text;
  s1:string;
  x1,y1,x2,y2:integer;
    procedure slideout (var s:string; xs,ys,d:integer);
    var i,i1,j,k,n,x1,x2,y1,y2:integer;
        ch:char;
        f:text;
    label 1,2,3;
    begin
     assign(f,s);
     reset(f);
     readln(f,x1,y1,x2,y2);
      for j:=1 to y2-y1+1 do begin
       i1:=0;
   2:    read(f,ch,n);
        k:=ord(ch);
        k:=k-100;
        if d<>0 then begin
          if k<>0 then k:=k-d;
          if k<0 then k:=k+16;
          if k>15 then k:=k-15;
          end;
        setcolor(k);
        line(i1+xs,j+ys,i1+n+xs,j+ys); i1:=i1+n;
        if i1>x2-x1 then goto 1;
        i1:=i1-1;
       if i1<x2-x1 then begin read(f,ch); goto 2; end;
   1: readln(f);
      end;
   3: close(f);
  end;


begin
   grdriver:=detect;
   initgraph(grdriver,grmode,'');
  s:=paramstr(1);
  assign(f,s);
  fsplit(s,a1,a2,a3);
  assign(f,a2+'.bak');
  erase(f);
  assign(f,a2+a3);
  rename(f,a2+'.bak');
  reset(f);
  readln(f,x1,y1,x2,y2);
  close(f);
  s1:=a2+'.bak';
  slideout(s1,x1,y1,0);
  s1:=a2+a3;
  slidesave(s1,x1,y1,x2,y2);
end.






