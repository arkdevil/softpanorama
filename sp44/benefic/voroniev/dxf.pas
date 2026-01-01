{Программа перевода *.dxf 10-й версии ACAD-а в 9-ю}
program dxf;
var
f : Text;
u : Text;
s : String;
begin
if (ParamStr(1) <> '') then
begin
Assign (f, ParamStr(1));
Reset(f);
end
else
begin
WriteLn('Missing parameter');
Halt;
end;
write('Преобразование ',Paramstr(1),' (10.0) -> (9.0)...');
Assign (u, 'dxf.dxf');
Rewrite(u);
While not Eof(f) do
begin
ReadLn(f, s);
if s = 'INSERT' then
begin
     while s <> '  0' do readln(f,s);
end
else
begin
    if s = 'POLYLINE' then
    begin
    writeln(u, s);
    while s <> '  0' do
    begin
    readln(f, s);
        if ((s = ' 66') or (s = ' 71') or (s = ' 72') or (s = ' 73') or (s = ' 74') or (s = ' 75')) then
        begin
        readln(f, s);
        end
        else
        begin
        writeln(u, s);
        end;
    end;
    end
    else
    begin
    WriteLn(u, s); {иначе запись}
    end;
end;
end;
Close(f);
Close(u);
Erase(f);
Rename(u, ParamStr(1));
write('завершено.');
end.
