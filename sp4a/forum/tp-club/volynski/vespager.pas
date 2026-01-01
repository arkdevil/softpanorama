{           Copyright_(c)_VES__Волынский_Е.С.  24. 7.1992   10:52            }
Program VESPager;
uses Crt,Dos,VES,VESStr;

var
    ParCnt,STRSTR,NOMSTR,CurStr,CurPage : word;
    bufstr : string[3];
    PosX1,PosX2,PosY1,PosY2 : byte;
    StrSum : Longint;

procedure Init_STRSTR_NUMSTR (s : PathStr);
var code : integer;
begin
         case UpCase(s[2]) of
            'L': begin
                   Val(Copy(s,3,Length(s)-2),STRSTR,code);
                   if code<>0 then begin
                      writeln ('Неверно задан параметр'); Halt (3)
                                end;
                 end;
            'N': begin
                   Val(Copy(s,3,Length(s)-2),NOMSTR,code);
                   if code<>0 then begin
                      WriteLn ('Неверно задан параметр'); Halt (3)
                                end;
                 end;
            else begin WriteLn ('Неверно задан параметр'); Halt (3) end;
         end;
end;

procedure NewPage;
begin
     CurStr:=1; Inc(CurPage);
     if CurPage<>1 then begin
        if CurPage <> NOMSTR then
               OutStr:=#12+'                                -     -'
                          else
               OutStr:=#32+'                                -     -';
        Str(CurPage,bufstr); Delete (OutStr,36,3); Insert (bufstr,OutStr,36);
        WriteLn (OutF,OutStr); WriteLn (OutF);
        CurStr:=3
                        end;
end;

begin

  DelCur;
  Ver:='v 2.2';   CreateDate:='24.07.92';

  WriteLn (CRLF+
  '(c)  VES  Разбивка текстового файла на страницы  '+Ver+'   '+CreateDate+
           CRLF);

  ParCnt:=ParamCount;  STRSTR:=55; NOMSTR:=1;
  case ParCnt of

   0 : begin { ------------------------------------------------------ }
    WriteLn ('Формат :  VESPager Вх-файл [Вых-файл] [/lСТРСТР] [/nНОМСТР]');
    WriteLn ('           СТРСТР - количество строк в странице');
    WriteLn ('                    (по умолчанию - 55)');
    WriteLn ('           НОМСТР - номер первой страницы (по умолчанию - 1)');
    WriteLn ('                    (Если нумерация начинается с 1, то');
    WriteLn ('                     первая страница не нумеруется)');
    Delay (1000);    Halt (1)
       end;

   1 : begin { ------------------------------------------------------ }
         path1:=ParamStr(1);

  OpenInpFile (path1);   { Открыть входной файл }

  { Определить, хватит ли на диске места для промежуточного файла }
  if (DiskFree(0) < (FileSpec.Size+500))  then begin   { Не хватит ! }
      Close (InpF); WriteLn ('Disk is full !'); Beep; Halt (2)
                                               end;

  { Вычислить имя выходного файла и открыть его }
  FSplit (path1,fd1,fn1,fe1);
  Insert ('.~'+Copy(fe1,2,2),fe1,1);
  path2:=fd1+fn1+fe1;
  OpenOutFile (path2);
       end;

   2 : begin { ------------------------------------------------------ }

         path1:=ParamStr(1);  path2:=ParamStr(2);

  OpenInpFile (path1);   { Открыть входной файл }

  { Определить, хватит ли на диске места для промежуточного файла }
  if (DiskFree(0) < (FileSpec.Size+500))  then begin   { Не хватит ! }
      Close (InpF); WriteLn ('Disk is full !'); Beep; Halt (2)
                                               end;

  if path2[1]<>'/' then begin
    OpenOutFile (path2);
                        end
                   else begin
  { Вычислить имя выходного файла и открыть его }
  FSplit (path1,fd1,fn1,fe1);
  Insert ('.~'+Copy(fe1,2,2),fe1,1);
  path4:=fd1+fn1+fe1;
  Init_STRSTR_NUMSTR (path2);
  OpenOutFile (path4);
                        end;
       end;

   3 : begin { ------------------------------------------------------ }

         path1:=ParamStr(1);  path2:=ParamStr(2);  path3:=ParamStr(3);

  OpenInpFile (path1);   { Открыть входной файл }

  { Определить, хватит ли на диске места для промежуточного файла }
  if (DiskFree(0) < (FileSpec.Size+500))  then begin   { Не хватит ! }
      Close (InpF); WriteLn ('Disk is full !'); Beep; Halt (2)
                                               end;

  if path2[1]<>'/' then begin
    Init_STRSTR_NUMSTR (path3);
    OpenOutFile (path2);
                        end
                   else begin
  { Вычислить имя выходного файла и открыть его }
  FSplit (path1,fd1,fn1,fe1);
  Insert ('.~'+Copy(fe1,2,2),fe1,1);
  path4:=fd1+fn1+fe1;
  Init_STRSTR_NUMSTR (path2);
  Init_STRSTR_NUMSTR (path3);
  OpenOutFile (path4);
                        end;
       end;

   else begin { ------------------------------------------------------ }

  path1:=ParamStr(1);  path2:=ParamStr(2);
  path3:=ParamStr(3);  path4:=ParamStr(4);

  OpenInpFile (path1);   { Открыть входной файл }

  { Определить, хватит ли на диске места для промежуточного файла }
  if (DiskFree(0) < (FileSpec.Size+500))  then begin   { Не хватит ! }
      Close (InpF); WriteLn ('Disk is full !'); Beep; Halt (2)
                                               end;

  Init_STRSTR_NUMSTR (path3);
  Init_STRSTR_NUMSTR (path4);
  OpenOutFile (path2);

        end;
  end;


  {    Читаем построчно исходный файл и разбиваем его на страницы    }
  {    Предполагается, что в файле нет символов #26 (конец файла)    }
  { Если в файле есть символы #12, то они стоят в 1-й позиции строки }


  CurPage:=NOMSTR-1;  StrSum:=0;  NewPage;
  Write ('Обработано  ');            PosX1:=WhereX; PosY1:=WhereY;
  Write ('         Страница   ');    PosX2:=WhereX; PosY2:=WhereY;
  while not Eof(InpF) do begin

     if CurStr>STRSTR then NewPage;
     Read (InpF,InStr);
     InStr:= ReplStr ( InStr, '', ' ', 2 );

     if Pos(#12,InStr) = 1 then begin
              NewPage; OutStr:=InStr; Delete (OutStr,1,1);
                                end
                           else OutStr:=InStr;

     WriteLn (OutF,OutStr);
     Inc(CurStr); Inc(StrSum,Length(InStr));
     Read (InpF, ch1, ch2);
     if (ch1=#13) and (ch2=#10) then Inc (StrSum, 2);
     GotoXY (PosX1,PosY1); Write ((StrSum/FileSpec.Size*100):5:1,'%');
     GotoXY (PosX2,PosY2); Write (CurPage:3);

                         end;

  Write (OutF,#12); Writeln;
  Close (InpF);   Close (OutF);

end.
