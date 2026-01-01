{           Copyright_(c)_VES__Волынский_Е.С.  24. 7.1992   10:53            }
Program BackSp;
uses Crt,Dos,VES,VESStr;

var
    CurStr : word;
    PosX,PosY : byte;
    StrSum : Longint;
    LenStr : integer;

begin

  DelCur; { Убрать курсор }
  Ver:='v 1.1';   CreateDate:='24.07.92';

  WriteLn (CRLF+
  '(c)  VES   Удаление хвостовых пробелов из каждой строки текстового файла'+
           CRLF+
  '           '+Ver+'   '+CreateDate+
           CRLF);


  if ParamCount = 0 then begin
     writeln ('Формат :   BackSp filename[.ext]'); Delay (1000); Halt (1)
                         end;

  path1:=ParamStr (1);

  OpenInpFile (path1);   { Открыть входной файл }

  { Определить, хватит ли на диске места для промежуточного файла }
  if DiskFree(0)<FileSpec.Size then begin   { Не хватит ! }
      Close (InpF); Writeln ('Disk is full !'); Beep; Halt (2)
                                    end;

  { Вычислить промежуточное имя выходного файла и открыть его }
  FSplit (path1,fd1,fn1,fe1);
  path2:=fd1+fn1+'.bsp';
  OpenOutFile (path2);

            {  Читаем построчно исходный файл и удаляем  }
            {     хвостовые пробелы в каждой строке      }

  Write ('Обработано  ');   PosX:=WhereX; PosY:=WhereY; StrSum:=0;
  while not Eof(InpF) do begin
     Read (Inpf,InStr); LenStr:=Length (InStr);
     OutStr:=Trim ( InStr, Right, [' '] );
     Writeln (OutF,OutStr);
     Inc(StrSum,LenStr);
     Read (InpF, ch1, ch2);
     if (ch1=#13) and (ch2=#10) then Inc (StrSum, 2);
     GotoXY (PosX,PosY); Write ((StrSum/FileSpec.Size*100):5:1,'%');
   end;

  Writeln;
  { Закрыть файлы }
  Close (InpF); Close (OutF);

end.
