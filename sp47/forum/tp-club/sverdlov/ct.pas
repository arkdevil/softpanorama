{  Пoдсчет числа байт в файлах дерева каталогов }
{  (C) С.Свердлов, 1992 }
{  Вологда, тел. (817-22) 2-01-62, (817-22) 4-61-77 }

program TreeCount;

uses
   Dos;

var
   ByteCount   : longint;        { Счетчик числа байт }
   DirCount    : word;           { Счетчик количества каталогов }
   FileCount   : word;           { Счетчик количества файлов }
   Level       : integer;        { Уровень подкаталога }
   ContLevels  : set of 0..31;   { Множество незавершенных уровней }

procedure WriteTriad( A : longint );
{ Печать целого числа триадами через пробел (рекурсивно) }
begin
   if A < 0 then begin
      Write('-');
      WriteTriad( -A );
      end
   else if A < 1000 then
      Write(A)
   else begin
      WriteTriad( A div 1000 );
      Write(' ',  (A mod 1000) div 100, (A mod 100) div 10, A mod 10 );
   end;
end;

procedure CountCurrDir( var DirCount,FileCount: word; var ByteCount: longint );
   {
      Рекурсивный просмотр текущего каталога и его подкаталогов

      DirCount  - общее количество подкаталогов текущего каталога;
      FileCount - общее количество файлов текущего каталога и подкаталогов;
      ByteCount - общее количество байт в файлах текущего каталога и
                  всех его подкаталогов.
   }

const
   Step           = 3;        { Отступ при выводе }
   CurrDrive      = 0;        { текущий диск }
var
   Info        : SearchRec;   { запись о файле ( см. модуль DOS ) }
   CurrDC      : integer;     { количество подкаталогов текущего каталога }
   DirNum      : integer;     { порядковый номер подкаталога }
   DC, FC      : word;        { количество подкаталогов и файлов в каталоге}
   BC          : longint;     { количество байт в подкаталоге }
   i           : integer;
begin
   with Info do begin

      {  Сначала считаем  количество, суммарный объем файлов и
         число подкаталогов в текущем каталоге }

         FileCount := 0;
         ByteCount := 0;
         DirCount  := 0;
         FindFirst( '*.*', AnyFile, Info );
         while DosError = 0 do begin
            if ( Attr = Directory ) and (  Name <> '.' ) and ( Name <> '..' )
            then
               DirCount := DirCount + 1
            else if Attr <> Directory then begin
               FileCount := FileCount + 1;
               ByteCount := ByteCount + Size;
            end;
            FindNext( Info );
         end;
         CurrDC := DirCount;

      { Теперь выводим дерево  и ведем подсчеты }

         DirNum := 0;
         FindFirst( '*.*', Directory, Info );
         while DosError = 0 do begin
            if ( Attr = Directory ) and (  Name <> '.' ) and ( Name <> '..' )
            then begin
               ChDir( Name );
               Level := Level + 1;
               { Здесь рекурсия }
                  CountCurrDir( DC, FC, BC );
               Level := Level - 1;
               ChDir('..');
               DirNum := DirNum + 1;
               if  DirNum = CurrDC then
                  ContLevels := ContLevels - [Level]
               else
                  ContLevels := ContLevels + [Level];
               for i := 1 to Level-1 do
                  if i in ContLevels then
                     Write('│  ')
                  else
                     Write('   ');
               if DirNum <> 1 then
                  Write( '├──',Name )
               else
                  Write( '┌──',Name );
               Write( ' ': 9 - Length(Name) );
               WriteTriad( BC );
               WriteLn;
               DirCount  := DirCount + DC;
               FileCount := FileCount + FC;
               ByteCount := ByteCount + BC;
            end;
            FindNext( Info );
         end;
   end;
end;

begin
   WriteLn;
   WriteLn;
   WriteLn('CountTree: Подсчет числа байт в файлах дерева  каталогов.');
   Writeln('(C) С.Свердлов, 1992');
   WriteLn;
   Level := 1;
   ContLevels:= [];
   CountCurrDir( DirCount, FileCount, ByteCount );
   Writeln;
   WriteLn('Каталогов ', DirCount );
   WriteLn('Файлов    ', FileCount );
   Write('Байт      ');
   WriteTriad( ByteCount );
   WriteLn;
end.
