{  Удаление BAK-файлов на текущем диске }
{  (C) С.Свердлов, 1992 }
{  Вологда, тел. (817-22) 2-01-62, (817-22) 4-61-77 }

program BakTree;

uses
   Dos, Crt;

const
   Step           = 3;                                { Отступ при выводе }
   CurrDrive      = 0;                                { Текущий диск }
   Message        = 'Вы действительно хотите удалить все BAK-файлы (Y/N) ?';

   Level          : integer = 1;                      { Уровень отступа }

var
   Reply       : char;              { Ответ пользователя }
   F           : file;
   ByteCount   : longint;           { Счетчик числа байт }
   DirCount    : integer;           { Счетчик количества каталогов }
   FileCount   : integer;           { Счетчик количества файлов }
   CurrDir     : string;

procedure DelCurrDir;
   { Рекурсивное удаление файлов текущего каталога }
var
   Info  : SearchRec;
begin
   with Info do begin

   {  Сначала удаляем файлы }

      FindFirst( '*.BAK', AnyFile-Directory, Info );
      while DosError = 0 do begin
         Assign( f, Name );
         WriteLn(' ':Level, Name, Size : FileFmt - Length(Name) );
         FileCount := FileCount + 1;
         ByteCount := ByteCount + Size;
         {$i-}
         Erase(F);
         {$i+}
         if ( IOResult <> 0 ) then begin
            WriteLn;
            WriteLn(' Нельзя удалить файл');
            Halt(1);
         end;
         FindNext( Info );
      end;

   { Теперь идем в подкаталоги }

      FindFirst( '*.*', Directory, Info );
      while DosError = 0 do begin
         if ( Attr = Directory ) and (  Name <> '.' ) and ( Name <> '..' )
         then begin
            HighVideo;
            WriteLn( ' ':Level,Name );
            DirCount := DirCount + 1;
            LowVideo;
            ChDir( Name );
            Level := Level + Step;
            { Здесь рекурсия }
               DelCurrDir;
            Level := Level-Step;
            ChDir('..');
         end;
         FindNext( Info );
      end;
   end;
end;

begin
   WriteLn;
   WriteLn;
   HighVideo;
   WriteLn('BakTree: Удаление BAK-файлов текущего диска');
   LowVideo;
   Writeln('(C) С.Свердлов, 1992');
   WriteLn;
   GetDir( CurrDrive, CurrDir );
   Write(Message);
   ReadLn( Reply );
   if ( UpCase(Reply) = 'Y' ) then begin
      ChDir('\');
      DirCount  := 0;
      FileCount := 0;
      ByteCount := 0;
      DelCurrDir;
      ChDir(CurrDir);
      WriteLn;
      WriteLn('Каталогов ', DirCount : 10 );
      WriteLn('Файлов    ', FileCount: 10 );
      WriteLn('Байт      ', ByteCount: 10 );
   end;
end.
