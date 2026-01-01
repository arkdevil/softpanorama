      unit extended;
interface
      uses graph;
      procedure extend1;
      procedure extend2;
      procedure extend3;
      procedure extend4;
      procedure extend5;
      procedure extend6;
      procedure extend7;
      procedure extend8;
      procedure extend9;
implementation

procedure extend1;
var i,j,k,l:integer;
  begin
{ начало поля операторов модуля EXTEND }
     setcolor(8);
     i:=10; j:=50;
     while j<getmaxy-45 do begin line(i,j,630,j); j:=j+10; end;
     k:=j-10;  i:=10; j:=50;
     while i<635 do begin line(i,j,i,k); i:=i+10; end;
{ конец поля операторов модуля EXTEND }
  end;
procedure extend2;
var xb,yb:integer;
    f:text;
  begin
{ начало поля операторов модуля EXTEND }

xb:=2; yb:=22;
setcolor(6);
setfillstyle(1,7);
bar3d(xb+2,yb+40,xb+626,yb+60,0,topoff);
line(xb+578,yb+60,xb+578,yb+40); line(xb+530,yb+40,xb+530,yb+60);
line(xb+482,yb+60,xb+482,yb+40); line(xb+434,yb+40,xb+434,yb+60);
line(xb+386,yb+60,xb+386,yb+40); line(xb+338,yb+40,xb+338,yb+60);
line(xb+290,yb+60,xb+290,yb+40); line(xb+242,yb+40,xb+242,yb+60);
line(xb+194,yb+60,xb+194,yb+40); line(xb+146,yb+40,xb+146,yb+60); line(xb+98,yb+60,xb+98,yb+40);
line(xb+50,yb+40,xb+50,yb+60);
assign(f,'progr.pas');
append(f);
writeln(f,'xb:=2; yb:=-22;');
writeln(f,'setcolor(6);');
writeln(f,'setfillstyle(1,7);');
writeln(f,'bar3d(xb+2,yb+40,xb+626,yb+60,0,topoff);');
writeln(f,'line(xb+578,yb+60,xb+578,yb+40); line(xb+530,yb+40,xb+530,yb+60);');
writeln(f,'line(xb+482,yb+60,xb+482,yb+40); line(xb+434,yb+40,xb+434,yb+60);');
writeln(f,'line(xb+386,yb+60,xb+386,yb+40); line(xb+338,yb+40,xb+338,yb+60);');
writeln(f,'line(xb+290,yb+60,xb+290,yb+40); line(xb+242,yb+40,xb+242,yb+60);');
writeln(f,'line(xb+194,yb+60,xb+194,yb+40); line(xb+146,yb+40,xb+146,yb+60); line(xb+98,yb+60,xb+98,yb+40);');
writeln(f,'line(xb+50,yb+40,xb+50,yb+60);');
close(f);



{ конец поля операторов модуля EXTEND }
  end;
procedure extend3;
  begin
{ начало поля операторов модуля EXTEND }


{ конец поля операторов модуля EXTEND }
  end;
procedure extend4;
  begin
{ начало поля операторов модуля EXTEND }


{ конец поля операторов модуля EXTEND }
  end;
procedure extend5;
  begin
{ начало поля операторов модуля EXTEND }


{ конец поля операторов модуля EXTEND }
  end;
procedure extend6;
  begin
{ начало поля операторов модуля EXTEND }


{ конец поля операторов модуля EXTEND }
  end;
procedure extend7;
  begin
{ начало поля операторов модуля EXTEND }


{ конец поля операторов модуля EXTEND }
  end;
procedure extend8;
  begin
{ начало поля операторов модуля EXTEND }


{ конец поля операторов модуля EXTEND }
  end;
procedure extend9;
  begin
{ начало поля операторов модуля EXTEND }


{ конец поля операторов модуля EXTEND }
  end;

end.
