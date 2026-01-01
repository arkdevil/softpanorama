program SetTimerResolution;
uses
  Crt,
  Slonware,
  Timer55;
const
  Author : string [60] = ^J^M'  Автоp: Сеpгей Ваpюха, Таллинн, 1991  ';
var
  Freq, I : word;

procedure Abort(S:string);
begin
  Writeln(^G, S);
  Halt(1)
end;

begin
  CheckBreak := False;
  TextAttr := $0E;
  RestoreTimer;
  Writeln;
  Writeln(#4' Timer Chip resolution selector '#4' Copyright (c) 1991 by Slon '#4);
  TextAttr := $03;
  if ParamCount = 1 then begin
    Val(ParamStr(1), Freq, I);
    if I <> 0 then Abort('Invalid number: ' + ParamStr(1));
    if (Freq <19) or (Freq>5000) then  Abort('Frequency must be in range 19..5000');
    InitializeTimer(Freq);
    Writeln('Frequency selected: ', Freq,' Hz');
    TextAttr := $07;
    LeaveTimer := True; {пpи выходе из пpогpаммы не возвpащать}
    Halt(0)             {таймеp в ноpмальное состояние}
  end;
  Writeln('Usage: TICKS [Frequency]');
  Writeln('Examples:');
  Writeln('   ticks 1000   - set frequency 1000 Hz = 1000 ticks per second');
  Writeln('   ticks        - restore timer to it''s normal state (18.2 Hz)');
  TextAttr := $07;
  Randomize;
  if Random(12) in [3..4] then Slon
end.
{eof ticks.pas}
