{Программа перекодировки файлов из формата PC в формат СМ.
Формат вызова: recoder input_file [output_file].}
program recoder;

uses
Crt;

var
f, u : Text;
ch : Char;
ps : Byte;
buf : array [1..10240] of Char; {10К в буфере}
begin

SetTextBuf(f,buf); {увеличение скорости счёта}
SetTextBuf(u,buf); {увеличение скорости записи}
if ParamCount < 1 then
begin
WriteLn('Input file is missing: aborting');
Halt;
end;

if ParamCount > 2 then
begin
WriteLn('Too many files in comma line: aborting');
Halt;
end;

if ParamCount = 1 then
begin
ps := 1;
WriteLn('Warning! Output file is the same. Continue? [NO - N/n]');
ch := ReadKey;
if ((ch = 'n') or (ch = 'N')) then Halt;
end
else
begin
ps := 2;
end;

Assign (f, ParamStr(1));
Reset(f);
if ps = 2 then
begin
Assign (u, ParamStr(2));
end
else
begin
Assign (u, 'unparm');
end;
Rewrite(u);

writeln('Converting in progress...');
While not Eof(f) do
begin
Read(f, ch);
Case ch of
'А', 'а' : ch := 'a';
'Б', 'б' : ch := 'b';
'В', 'в' : ch := 'w';
'Г', 'г' : ch := 'g';
'Д', 'д' : ch := 'd';
'Е', 'е' : ch := 'e';
'Ё', 'ё' : ch := 'e';
'Ж', 'ж' : ch := 'v';
'З', 'з' : ch := 'z';
'И', 'и' : ch := 'i';
'Й', 'й' : ch := 'j';
'К', 'к' : ch := 'k';
'Л', 'л' : ch := 'l';
'М', 'м' : ch := 'm';
'Н', 'н' : ch := 'n';
'О', 'о' : ch := 'o';
'П', 'п' : ch := 'p';
'Р', 'р' : ch := 'r';
'С', 'с' : ch := 's';
'Т', 'т' : ch := 't';
'У', 'у' : ch := 'u';
'Ф', 'ф' : ch := 'f';
'Х', 'х' : ch := 'h';
'Ц', 'ц' : ch := 'c';
'Ч', 'ч' : ch := '~';
'Ш', 'ш' : ch := '{';
'Щ', 'щ' : ch := '}';
'Ъ', 'ъ' : ch := '''';
'Ы', 'ы' : ch := 'y';
'Ь', 'ь' : ch := 'x';
'Э', 'э' : ch := '|';
'Ю', 'ю' : ch := '`';
'Я', 'я' : ch := 'q';
'┌', '╔', '╒', '╓' : ch := '-';
'┬', '╦', '╤', '╥' : ch := '-';
'┐', '╗', '╕', '╖' : ch := '-';
'│', '║' : ch := 'I';
'├', '╠', '╞', '╟' : ch := 'I';
'┼', '╬', '╪', '╫' : ch := '+';
'┤', '╣', '╡', '╢' : ch := 'I';
'└', '╚', '╘', '╙' : ch := '-';
'┴', '╩', '╧', '╨' : ch := '-';
'┘', '╝', '╛', '╜' : ch := '-';
'─', '═' : ch := '-';
end;
Write(u, ch);
end;
Close(f);
Close(u);

if ((ParamStr(2) = Paramstr(1)) or (ps = 1)) then
begin
WriteLn('Deleting input file ', ParamStr(1));
Erase(f);
Rename(u, ParamStr(1));
end;
end.