{programma wywoda *.dxf 9-j wersii ACAD-a na |kran}
program zastavka;
uses
crt, graph;
label
10;
var
ch : Char;
f : Text;
prov : boolean;
s, s1, s2 : String;
cvet : byte;
t0 ,t1, z0 ,z1, z2, Gd, Gm, code : Integer;
k1, x0, y0, x1, y1, y2 : Real;
begin
if (ParamStr(1) <> '') then
begin
Assign (f, ParamStr(1));
Reset(f);
end
else
begin
{WriteLn('Missing parameter');
Halt;}
write('Введите имя файла без расширения .dxf: ');
readln(s2);
      if (length(s2) > 8) or (length(s2) = 0) then begin
      writeln('Too many or few simbols in filename');
      Halt;
      end
      else begin
      k1:=1; {коэффициент заполнения экрана}
10:   assign(f,s2+'.dxf');
      reset(f);
      end;
end;

Gd := Detect; Initgraph(Gd, Gm, '');
if GraphResult <> GrOk then Halt(1);
SetBkColor(0);
While not Eof(f) do
begin
ReadLn(f, s);
s1 := s;
if (s1 = 'LINE') or (s1 = 'ARC') or (s1 = 'CIRCLE') then begin
     while s <> '  0' do
     begin
     readln(f,s);
     readln(f,s);
     if s='BLACK' then s:='0';
     if s='BLUE' then s:='1';
     if s='GREEN' then s:='2';
     if s='CYAN' then s:='3';
     if s='RED' then s:='4';
     if s='MAGENTA' then s:='5';
     if s='BROWN' then s:='6';
     if s='YELLOW' then s:='14';
     if s='WHITE' then s:='15';
     if s='DARKGRAY' then s:='8';
     if s='DARKRED' then s:='4';
     if s='DARKBROWN' then s:='6';
     if s='DARKGREEN' then s:='2';
     if s='DARKCYAN' then s:='3';
     if s='DARKBLUE' then s:='1';
     if s='DARKMAGENTA' then s:='5';
     if s='LIGHTGRAY' then s:='7';
     val(s,cvet,code);
     if code <> 0 then Halt;
     case cvet of
     0 : Setcolor(15);  {belyj}
     21 : Setcolor(8);  {temno-seryj}
     31 : Setcolor(9);  {swetlo-goluboj}
     41 : Setcolor(10); {swetlo-zelenyj}
     51 : Setcolor(13); {swetlo-fioletowyj}
     61 : Setcolor(14); {veltyj}
     22 : Setcolor(4);  {morskoj wolny}
     32 : Setcolor(5);  {krasnyj}
     42 : Setcolor(6);  {fioletowyj}
     52 : Setcolor(15); {powtor}
     62 : Setcolor(15); {powtor}
     else
     SetColor(cvet);
     end;
     readln(f,s);
     readln(f,s);
     val(s,x0,code); x0 := x0/k1;
     if code <> 0 then Halt;
     readln(f,s);
     readln(f,s);
     val(s,y0,code); y0 := y0/k1;
     if code <> 0 then Halt;
     readln(f,s);
     readln(f,s);
     val(s,x1,code); x1 := x1/k1;
     if code <> 0 then Halt;
     t0 := round(x0); z0 := round(y0); t1 := round(x1);
        if s1 = 'CIRCLE' then begin
        circle(t0,350-z0,t1);
        end;
        if s1 = 'LINE' then begin
        readln(f,s);
        readln(f,s);
        val(s,y1,code); y1 := y1/k1;
        if code <> 0 then Halt;
        z1 := round(y1);
        line(t0,350-z0,t1,350-z1);
        end;
        if s1 = 'ARC' then begin
        readln(f,s);
        readln(f,s);
        val(s,y1,code);
        if code <> 0 then Halt;
        readln(f,s);
        readln(f,s);
        val(s,y2,code);
        if code <> 0 then Halt;
        z1 := round(y1); z2 := round(y2);
        arc(t0,350-z0,z1,z2,t1);
        end;
     readln(f,s);
     end;
end;
end;
outtext('Press <ESC> to quit or <GREYup> and <GREYdown> to zoom...');
ch := Readkey;
   if ch = #0 then prov:=true else prov:=false;
   if prov then ch := Readkey;
   case ch of
   #27 : Halt;
   #80 : k1:=k1-0.5;
   #72 : k1:=k1+0.5;
   end;
CloseGraph;
Close(f); goto 10;
end.