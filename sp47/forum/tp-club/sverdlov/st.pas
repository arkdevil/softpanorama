{  Просмотр дерева каталогов, начиная с текущего }
{  (C) С.Свердлов, 1992 }
{  Вологда, тел. (817-22) 2-01-62, (817-22) 4-61-77 }

program ShowTree;

uses
   Dos;

const
   Step  = 3;  { Отступ при выводе }

var
   Level       : integer;        { Уровень подкаталога }
   DirCount    : word;           { Счетчик количества каталогов }
   ContLevels  : set of 0..31;   { Множество незавершенных уровней }

procedure ShowCurrDir(  var DirCount : word );
   { Рекурсивный просмотр текущего каталога }

var
   Info           : SearchRec;
   TotalDir, DC   : integer;
   i              : integer;

begin
   with Info do begin

   { Cчитаем подкаталоги }

      DC := 0;
      FindFirst( '*.*', Directory, Info );
      while DosError = 0 do begin
         if ( Attr = Directory ) and (  Name <> '.' ) and ( Name <> '..' )
         then
            DC := DC + 1;
         FindNext( Info );
      end;
      TotalDir := DC;
      DirCount := DirCount + DC;

   { Теперь выводим дерево }

      DC := 0;
      FindFirst( '*.*', Directory, Info );
      while DosError = 0 do begin
         if ( Attr = Directory ) and (  Name <> '.' ) and ( Name <> '..' )
         then begin
            DC := DC + 1;
            if  DC = TotalDir then
               ContLevels := ContLevels - [Level]
            else
               ContLevels := ContLevels + [Level];
            for i := 1 to Level-1 do
               if i in ContLevels then
                  Write('│  ')
               else
                  Write('   ');
            if Level in ContLevels then
               WriteLn( '├──',Name )
            else
               WriteLn( '└──',Name );
            ChDir( Name );
            Level := Level + 1;
            { Здесь рекурсия }
               ShowCurrDir( DirCount );
            Level := Level - 1;
            ChDir('..');
         end;
         FindNext( Info );
      end;
   end;
end;

begin
   WriteLn;
   WriteLn;
   WriteLn('ShowTree: Просмотр дерева  каталогов, начиная с текущего.');
   Writeln('(C) С.Свердлов, 1991');
   Level := 1;
   ContLevels:= [];
   DirCount  := 0;
   ShowCurrDir( DirCount );
   Writeln;
   WriteLn('Подкаталогов ', DirCount : 10 );
end.
