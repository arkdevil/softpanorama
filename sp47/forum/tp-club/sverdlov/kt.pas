{  Удаление содержимого текущего каталога вместе со всеми подкаталогами }
{  (C) С.Свердлов, 1992 }
{  Вологда, тел. (817-22) 2-01-62, (817-22) 4-61-77 }

program KillTree;

uses
   Dos, Crt;

const
   Password       = 'Я хочу уничтожить этот каталог'; { Пароль }
   PassLen        = Length( Password );               { Длина пароля }
   Step           = 3;                                { Отступ при выводе }
   FileFmt        = 22;                               { Размер поля вывода }
   MyName         = 'KT.EXE';                         { имя программы }
   CurrDrive      = 0;                                { текущий диск }
   Message        = 'Если Вы действительно хотите уничтожить каталог';

   Level          : integer = 1;                      { Уровень отступа }

var
   Reply       : string[PassLen];   { Ответ пользователя }
   F           : file;
   ByteCount   : longint;           { Счетчик числа байт }
   DirCount    : integer;           { Счетчик количества каталогов }
   FileCount   : integer;           { Счетчик количества файлов }
   CurrDir     : string;

procedure DelCurrDir;
   { Рекурсивное уничтожение текущего каталога }
var
   Info  : SearchRec;
begin
   with Info do begin

   {  Сначала удаляем файлы }

      FindFirst( '*.*', AnyFile-Directory, Info );
      while DosError = 0 do begin
         if  ( Level <> 1 ) or ( Name <> MyName )   then begin
            Assign( f, Name );
            WriteLn(' ':Level, Name, Size : FileFmt - Length(Name) );
            FileCount := FileCount + 1;
            ByteCount := ByteCount + Size;
            {$i-}
            Erase(F);
            {$i+}
            if ( IOResult <> 0 ) and ( Level > 1 ) then begin
               WriteLn;
               WriteLn(' Нельзя удалить файл');
               Halt(1);
            end;
         end;
         FindNext( Info );
      end;

   { Теперь удаляем подкаталоги }

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
            RmDir(Name);
         end;
         FindNext( Info );
      end;
   end;
end;

begin
   WriteLn;
   WriteLn;
   HighVideo;
   WriteLn('KillTree: Удаление текущего каталога и всех его подкаталогов');
   LowVideo;
   Writeln('(C) С.Свердлов, 1991');
   WriteLn;
   GetDir( CurrDrive, CurrDir );
   Writeln(Message);
   Writeln( CurrDir : ( Length(Message) + Length(CurrDir) ) div 2, ' ,' );
   WriteLn('напишите > ',Password);
   Write(  '         > ' );
   ReadLn( Reply );
   if ( Reply = Password ) then begin
      DirCount  := 0;
      FileCount := 0;
      ByteCount := 0;
      DelCurrDir;
      Writeln;
      Writeln('Уничтожено:');
      WriteLn;
      WriteLn('Каталогов ', DirCount : 10 );
      WriteLn('Файлов    ', FileCount: 10 );
      WriteLn('Байт      ', ByteCount: 10 );
   end;
end.
