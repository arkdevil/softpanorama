{           Copyright_(c)_VES__Волынский_Е.С.  24. 7.1992   10:53            }
Program PosFile;
uses Crt,Dos,VES,TPString;

var
    FileStr : string [255];
    PosX, PosY : byte;
    StrSum : Longint;
    NumPos, LenStr, StPos : integer;

begin

  DelCur; { Убрать курсор }
  Ver:='v 1.2';   CreateDate:='24.07.92';

  Writeln (CRLF+
  '(c) VES  Позиционирование строк текстового файла на заданное число позиций'+
           CRLF+
  '         начиная с заданной позиции   '+Ver+'   '+CreateDate+
           CRLF);

  if ParamCount < 2 then begin
     Writeln ('Формат :   PosFile filename[.ext] [+|-]NumPos [StartPos]');
     Writeln ('               NumPos - количество позиций для сдвига');
     Writeln ('                "+" ─ вправо,   "-" ─ влево');
     Writeln ('               StartPos - первая сдвигаемая позиция');
     Writeln ('                          по умолчанию = 2');
     Delay (1000); Halt (1)
                         end;

  path1:=ParamStr (1);

  if NOT Str2Int ( ParamStr (3), StPos ) then StPos:=2;

  if NOT Str2Int ( ParamStr (2), NumPos ) then begin
                     writeln ('Неверный параметр'); Halt (2)
                                               end;

  OpenInpFile (path1);   { Открыть входной файл }

  { Определить, хватит ли на диске места для промежуточного файла }
  if DiskFree(0)<FileSpec.Size then begin   { Не хватит ! }
      Close (InpF); Writeln ('Disk is full !'); Beep; Halt (2)
                                    end;

  { Вычислить промежуточное имя выходного файла и открыть его }
  FSplit (path1,fd1,fn1,fe1);
  path2:=fd1+fn1+'.pos';
  OpenOutFile (path2);

            {  Читаем построчно исходный файл и  }
            {    позиционируем каждую строку     }

  Write ('Обработано  ');   PosX:=WhereX; PosY:=WhereY; StrSum:=0;
  while not Eof(InpF) do
   begin
     Read (Inpf,FileStr); LenStr:=Length (FileStr);
     if LenStr<>0 then
             if NumPos < 0 then
                  Delete (FileStr,StPos,Abs(NumPos))   { Удаляем пробелы }
                                  else
                  for i:=1 to NumPos do
                       Insert (' ',FileStr,StPos);       { Вставляем пробелы }
     Writeln (OutF,FileStr);
     Inc(StrSum,LenStr);
     Read (InpF, ch1, ch2);
     if (ch1=#13) and (ch2=#10) then Inc (StrSum, 2);
     GotoXY (PosX,PosY); Write ((StrSum/FileSpec.Size*100):5:1,'%');
   end;

  Writeln;
  { Закрыть файлы }
  Close (InpF); Close (OutF);

end.
