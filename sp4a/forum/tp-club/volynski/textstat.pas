{           Copyright_(c)_VES__Волынский_Е.С.  24. 7.1992   10:52            }
Program TextStat;
uses Crt,Dos,VES;

var
    CurStr : word;
    PosX,PosY : byte;
    StrSum : Longint;
    LenStr, LinesInPage : integer;
    SaveAttr : byte;
{ ------ Статистические переменные -----}
    MaxLenStr,       { Максимальная длина строки }
    NumStrMaxLen,    { Номер строки максимальной длины (считая от начала) }
    LinesInFile,     { Всего строк в файле }
    MaxLinesInPage,  { Максимальное количество строк в странице }
    NumPageMaxLine,  { Номер страницы максимальной длины }
    PagesInFile      { Страниц в файле }
                     : Longint;

begin

  DelCur; { Убрать курсор }
  Ver:='v 1.0';   CreateDate:='04.09.92';

  WriteLn (CRLF+
  '(c)  VES   Статистика для текстовых файлов   '+Ver+'   '+CreateDate+CRLF);


  if ParamCount = 0 then begin
     Writeln ('Формат :   TextStat filename[.ext]'); Delay (1000); Halt (1)
                         end;

  path1:=ParamStr (1);

  OpenInpFile (path1);   { Открыть входной файл }

            {  Читаем построчно исходный файл и ведем  }
            {           для него статистику            }

  MaxLenStr:=0;
  NumStrMaxLen:=0;
  LinesInFile:=0;
  MaxLinesInPage:=0;
  NumPageMaxLine:=0;
  PagesInFile:=1;
  LinesInPage:=0;

  
  Write ('Обработано  ');   PosX:=WhereX; PosY:=WhereY; StrSum:=0;
  while not Eof(InpF) do begin
     Read (Inpf,InStr,ch1,ch2); LenStr:=Length (InStr);
     Inc (LinesInFile);
     if  (Copy (InStr, 1, 1)='') OR (EOF(InpF)) then
         if LinesInPage > MaxLinesInPage then begin
             MaxLinesInPage:=LinesInPage; NumPageMaxLine:=PagesInFile;
                                              end;
     if Copy (InStr, 1, 1)='' then begin
        Inc (PagesInFile);  LinesInPage:=0;
                                    end;
     Inc (LinesInPage);
     if LenStr > MaxLenStr then begin
          MaxLenStr:=LenStr;  NumStrMaxLen:=LinesInFile;
                                end;

     Inc(StrSum,LenStr);
     if (ch1=#13) and (ch2=#10) then Inc (StrSum, 2);
     GotoXY (PosX,PosY); Write ((StrSum/FileSpec.Size*100):5:1,'%');
                         end;

  Writeln;  Writeln;
  if PagesInFile = 1 then begin
             MaxLinesInPage:=LinesInPage; NumPageMaxLine:=PagesInFile;
                          end;
  { Закрыть файл }
  Close (InpF);

{ -------   Выдача статистики ------- }
  SaveAttr:=TextAttr;

  Write ('Статистика для файла : ');
  TextColor ( LightRed );
  Writeln (path1);
  TextAttr:=SaveAttr;

  TextColor ( Yellow );
  Writeln ('──────────────────────────────────');
  TextAttr:=SaveAttr;

  Write ('Число строк в файле : ');
  TextColor ( LightRed );
  Writeln (LinesInFile);
  TextAttr:=SaveAttr;

  Write ('Максимальная длина строки : ');
  TextColor ( LightRed );
  Writeln (MaxLenStr);
  TextAttr:=SaveAttr;

  Write ('Номер самой длинной строки : ');
  TextColor ( LightRed );
  Writeln (NumStrMaxLen);
  TextAttr:=SaveAttr;

  Write ('Число страниц в файле : ');
  TextColor ( LightRed );
  Writeln (PagesInFile);
  TextAttr:=SaveAttr;

  Write ('Максимальное число строк в странице : ');
  TextColor ( LightRed );
  Writeln (MaxLinesInPage);
  TextAttr:=SaveAttr;

  Write ('Номер самой длинной страницы : ');
  TextColor ( LightRed );
  Writeln (NumPageMaxLine);
  TextAttr:=SaveAttr;
  Writeln;

end.
