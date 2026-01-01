{           Copyright_(c)_VES__Волынский_Е.С.  24. 9.1992                    }
{         Уничтожение постраничной разбивки текстового файла                 }
Program DelPage;
uses Crt,
     Dos,
     VES,
     VESStr;

var
    ParCnt : word;
    PosX,PosY : byte;
    StrSum : Longint;
    CR,LF : char;

begin

  DelCur;
  Ver:='v 1.1';   CreateDate:='24.09.92';

  WriteLn (CRLF+
  '(c)  VES  Уничтожение постраничной разбивки файла  '+Ver+'   '+CreateDate+
           CRLF);

  ParCnt:=ParamCount;
  case ParCnt of

   0..1 : 
       begin { ------------------------------------------------------ }
    WriteLn ('Формат :  DelPage Вх-файл [Вых-файл] {/L|/C}');
    WriteLn ('          /L - Уничтожить строку с символом  в первой позиции');
    WriteLn ('          /C - Уничтожить первый символ строки, если это - ');
    Delay (1000);    Halt (1)
       end;

   2 : begin { ------------------------------------------------------ }

         path1:=ParamStr(1); str1:=ParamStr(2);
         if (str1='/l') or (str1='/L') or
            (str1='/c') or (str1='/C') then begin
               ch1:=UpCase (str1[2]);
              { Вычислить имя выходного файла }
               FSplit (path1,fd1,fn1,fe1);
               path2:=fd1+fn1+'.dpg';
                                            end
                                       else begin
    WriteLn ('Формат :  DelPage Вх-файл [Вых-файл] {/L|/C}');
    WriteLn ('          /L - Уничтожить строку с символом  в первой позиции');
    WriteLn ('          /C - Уничтожить первый символ строки, если это - ');
    Delay (1000);    Halt (1)
                                            end;

  OpenInpFile (path1);   { Открыть входной файл }

  { Определить, хватит ли на диске места для промежуточного файла }
  if (DiskFree(0) < (FileSpec.Size+500))  then begin   { Не хватит ! }
      Close (InpF); WriteLn ('Disk is full !'); Beep; Halt (2)
                                               end;

    OpenOutFile (path2);
       end;

   3 : begin { ------------------------------------------------------ }

         path1:=ParamStr(1);  path2:=ParamStr(2);
         path3:=ParamStr(3);  ch1:=UpCase(path3[2]);

  if (ch1<>'L') and (ch1<>'C') then begin
    WriteLn ('Формат :  DelPage Вх-файл [Вых-файл] {/L|/C}');
    WriteLn ('          /L - Уничтожить строку с символом  в первой позиции');
    WriteLn ('          /C - Уничтожить первый символ строки, если это - ');
    Delay (1000);    Halt (1)
                                    end;

  OpenInpFile (path1);   { Открыть входной файл }

  { Определить, хватит ли на диске места для промежуточного файла }
  if (DiskFree(0) < (FileSpec.Size+500))  then begin   { Не хватит ! }
      Close (InpF); WriteLn ('Disk is full !'); Beep; Halt (2)
                                               end;

    OpenOutFile (path2);
       end;

  end;


  {  Читаем построчно исходный файл и ликвидируем разбивку на страницы  }

  StrSum:=0;
  Write ('Обработано  ');            PosX:=WhereX; PosY:=WhereY;
  while not Eof(InpF) do begin

     Read (InpF,InStr);
     Read(InpF,CR,LF);
     if InStr='' then begin OutStr:=''; Writeln (OutF) end
                 else
      if Pos(#12,InStr) = 1 then
              case ch1 of
               'L' : OutStr:='';
               'C' : begin
                       OutStr:=InStr;
                       Delete (OutStr,1,1);
                       if OutStr='' then Writeln (OutF);
                     end;
              end
                            else
              OutStr:=InStr;

     if OutStr <> '' then begin 
             Write (OutF,OutStr);
             if CR+LF = CRLF then Writeln (OutF);
                          end;
     Inc(StrSum,Length(InStr));
     if CR+LF = CRLF then Inc (StrSum, 2);
     GotoXY (PosX,PosY); Write ((StrSum/FileSpec.Size*100):5:1,'%');

                         end;

  Writeln;
  Close (InpF);   Close (OutF);

end.
