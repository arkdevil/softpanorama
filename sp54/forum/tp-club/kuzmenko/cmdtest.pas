
{ Tester of TCmdLine object }

uses CmdLine;

var 
 T: TCmdLine;
 i: integer;
begin
 T.Init;
 Writeln('paramcount: ', T.Count);
 Writeln('parameters:');
 for i:=0 to T.Count - 1 do
  Writeln(' ', T.At(i));
 T.Done;
end.