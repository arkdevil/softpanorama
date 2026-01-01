{$M 2048, 0, 0}
program model;

uses crt,dbg85p;

var daylight : boolean;

procedure pane(s:boolean; x,y:byte);
begin
  gotoxy(x,y);				{ вывод символа окна в заданном месте }
  if s then write(#$B1)
       else write(' ')
end;

{$F+}
procedure inm(n:byte);
begin
  retdbg(ord(daylight))			{ возврат значения освещенности }
end;

procedure outm(n,d:byte);
var s:boolean;
begin
  s:=boolean(d);
  case n of				{ для каждого порта вывод символа }
  1:  pane(s,32,10);			{ в своем месте    }
  2:  pane(s,35,10);
  3:  pane(s,32,12);
  4:  pane(s,35,12);
  end;
  retdbg(0)
end;

procedure clk;
var w:boolean;
begin
  w:=set85interrupt(0,8);		{ прерывание 0, вектор 8 }
  setnextcall(get85time+10000);		{ вызвать через 0.1 сек }
  retdbg(0)
end;

procedure dat;
begin
  daylight := not daylight;		{ инверсия значения освещенности }
  gotoxy(1,1);
  if daylight then write('день')	{ вывод текущего времени суток }
              else write('ночь');
  retdbg(0)
end;
{$F-}
begin
  adjustmodel(@outm,@inm,@dat,@clk);
  daylight:=false; clrscr; gotoxy(1,1); write('ночь');
  gotoxy(30,05); write('   /\ ');
  gotoxy(30,06); write('  /  \ ');
  gotoxy(30,07); write(' /    \ ');
  gotoxy(30,08); write('/      \');
  gotoxy(30,09); write('╔══════╗');
  gotoxy(30,10); write('║      ║');
  gotoxy(30,11); write('║      ║');
  gotoxy(30,12); write('║      ║');
  gotoxy(30,13); write('╚══════╝');
  linkwithdbg
end.
