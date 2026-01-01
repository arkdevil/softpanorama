{           Copyright_(c)_VES__Волынский_Е.С.  24. 7.1992   10:53            }
Program GCopy;
{ "Мракование" файлов заданным паролем }

uses Crt,Dos,VES;
var
   password : string[8];
   NextInpSimb,NextOutSimb : Char;
   PosX,PosY : Byte;
   NumCurSimb : Longint;
begin

  DelCur; { Убрать курсор }
  Ver:='v 1.0';   CreateDate:='24.07.92';

  Writeln (CRLF+
           '(c) VES  Шифрование текстового файла  '+Ver+'   '+CreateDate+
           CRLF);

  if ParamCount < 2 then begin
     writeln ('Формат :  GCopy filename[.ext] password');
     Delay (1000); Halt (1);
                         end;

  path1:=ParamStr (1); password:=ParamStr (2);
  l:=Length(password); i:=1; NumCurSimb:=0;

  OpenInpFile (path1);   { Открыть входной файл }

  { Определить, хватит ли на диске места для промежуточного файла }
  if DiskFree(0)<FileSpec.Size then begin   { Не хватит ! }
      Close (InpF); Writeln ('Disk is full !'); Beep; Halt (2)
                                    end;

  { Вычислить промежуточное имя выходного файла и открыть его }
  FSplit (path1,fd1,fn1,fe1);
  path2:=fd1+fn1+'.grb';
  OpenOutFile (path2);

  { Начать "мракование" }
  Write ('Обработано  '); PosX:=WhereX; PosY:=WhereY;
  while NumCurSimb<FileSpec.Size do begin
     if i>l then i:=1;
     Read(InpF,NextInpSimb);
     NextOutSimb:=Chr(Ord(NextInpSimb) xor Ord(password[i]));
     Write(OutF,NextOutSimb);
     Inc(i); Inc(NumCurSimb);
     GotoXY (PosX,PosY); Write ((NumCurSimb/FileSpec.Size*100):5:1,'%');
                          end;

  Writeln;
  { Закрыть файлы }
  Close (InpF); Close (OutF);

end.
