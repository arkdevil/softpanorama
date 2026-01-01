{           Copyright_(c)_VES__Волынский_Е.С.  24. 7.1992   10:52            }
Program PrtUkr;
uses Crt,Dos,VES;

const  SelectASCII = #27 + #116 + #0;
       SelectCyrillic = #27 + #116 + #1;

var
    CurStr : word;
    PosX,PosY : byte;
    StrSum : Longint;
    LenStr : integer;

begin

  DelCur; { Убрать курсор }
  Ver:='v 2.0';   CreateDate:='24.07.92';

  WriteLn (CRLF+
  '(c)  VES   Перекодировка для печати украинских букв ї и Є'
          +CRLF+
  '           на принтерах OKI Microline 182/183   '+Ver+'   '+CreateDate+
           CRLF );
  Writeln (
  '               Исх.                       Рез. ' + CRLF );
  Writeln (
  '            #242 ( Є )  ──>  #27+#116+#0+#238+#27+#116+#1' + CRLF +
  '            #243 ( є )  ──>            #101  ( e )'        + CRLF +
  '            #244 ( Ї )  ──>            #73   ( I )'        + CRLF +
  '            #245 ( ї )  ──>  #27+#116+#0+#139+#27+#116+#1' + CRLF   );

  if ParamCount = 0 then begin
     writeln ('Формат :   PrtUkr filename[.ext]');
     Delay (1000); Halt (1)
                         end;

  path1:=ParamStr (1);

  OpenInpFile (path1);   { Открыть входной файл }

  { Определить, хватит ли на диске места для промежуточного файла }
  if DiskFree(0)<FileSpec.Size then begin   { Не хватит ! }
      Close (InpF); Writeln ('Disk is full !'); Beep; Halt (2)
                                    end;

  { Вычислить промежуточное имя выходного файла и открыть его }
  FSplit (path1,fd1,fn1,fe1);
  path2:=fd1+fn1+'.ukr';
  OpenOutFile (path2);

                {  Читаем построчно исходный файл и  }
                {      производим  перекодировку     }

  Write ('Обработано  ');   PosX:=WhereX; PosY:=WhereY; StrSum:=0;
  while not Eof(InpF) do
   begin
     Read (Inpf,InStr); LenStr:=Length (InStr); i:=1;
     if LenStr<>0 then
             while i <= Length (InStr) do
               case InStr[i] of
       { Є }      #242 : begin
                     Delete (InStr,i,1);
                     Insert (SelectASCII+#238+SelectCyrillic,InStr,i);
                     Inc (i,7);
                         end;
       { є }      #243 : begin  InStr[i]:=#101; Inc (i);  end;
       { Ї }      #244 : begin  InStr[i]:=#73;  Inc (i);  end;
       { ї }      #245 : begin
                     Delete (InStr,i,1);
                     Insert (SelectASCII+#139+SelectCyrillic,InStr,i);
                     Inc (i,7);
                         end;
                  else   Inc (i);
               end;

     Writeln (OutF,InStr);
     Inc(StrSum,LenStr);
     Read (InpF, ch1, ch2);
     if (ch1=#13) and (ch2=#10) then Inc (StrSum, 2);
     GotoXY (PosX,PosY); Write ((StrSum/FileSpec.Size*100):5:1,'%');
   end;

  Writeln;
  { Закрыть файлы }
  Close (InpF); Close (OutF);
end.
