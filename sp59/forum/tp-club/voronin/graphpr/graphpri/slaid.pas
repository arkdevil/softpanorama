unit slaid;
interface
uses crt,graph;
    procedure slidesave(var s:string; x1,y1,x2,y2:integer);
    procedure slideout (var s:string; xs,ys,d,t:integer);
   implementation
    procedure slidesave;
    var i,i1,k1,j,k,n:integer;
        ch:char;
        f:text;
    label 1,2;
    begin
      assign(f,s);
      rewrite(f);
      writeln(f,x1,' ',y1,' ',x2,' ',y2);
      for j:=y1 to y2 do begin
      i:=x1;
      k:=getpixel(i,j);
  1:  write(f,chr(100+k));
      n:=1;
      for i1:=i+1 to x2 do begin
         k1:=getpixel(i1,j);
         if k1<>k then begin
           write(f,n,' ');
           if i1=x2 then begin
           writeln(f,chr(100+k1),'1 Z');
           goto 2;
           end;
           k:=k1;  i:=i1;
           goto 1;
           end;
         n:=n+1;
      end;
      writeln(f,n-1,' Z');
   2: end;
    close(f);
end;
    procedure slideout;
    var i,i1,j,k,n,x1,x2,y1,y2:integer;
        ch,kk:char;
        f:text;
    label 1,2,3,4;
    begin
     assign(f,s);
     reset(f);
     readln(f,x1,y1,x2,y2);
      for j:=0 to y2-y1 do begin
       i1:=0;
   2:   read(f,ch);
        if ch='Z' then goto 1;
        read(f,n);
        if n=0 then goto 1;
        k:=ord(ch);
        k:=k-100;
        if d<>0 then begin
          if k<>0 then k:=k-d;
          if k<0 then k:=k+16;
          if k>15 then k:=k-15;
          end;
        setcolor(k);
        if keypressed then goto 3;
        if (k=0) and (t=1) then goto 4;
        if (n>1) then begin line(i1+xs,j+ys,i1+n+xs,j+ys); goto 4; end;
        if (n=1) then begin putpixel(i1+xs,j+ys,k); goto 4; end;
    4:  i1:=i1+n;
     {   i1:=i1-1;  }
        read(f,ch);
        if ch='Z' then goto 1;
        goto 2;
   1: readln(f);
      end;
   3: close(f);
  end;
end.
