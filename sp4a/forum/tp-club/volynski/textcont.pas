{           Copyright_(c)_VES__Волынский_Е.С.   8.10.1992                    }
{                   Генерация оглавления документа                           }
Program TextCont;
uses Crt,
     Dos,
     VES,
     VESStr,
     TPString;

const
    PointSimb = #4;    { Символ ─ признак пункта оглавления }
    PointLen  = 65;    { Длина строки оглавления            }

var
    ParCnt, NumPage : word;
    LenInStr        : byte absolute InStr;
    PosX,PosY       : byte;
    StrSum          : Longint;
    CR,LF           : char;

begin

  DelCur;
  Ver:='v 1.0';   CreateDate:='8.10.92';

  WriteLn (CRLF+
  '(c)  VES  Генерация оглавления документа  '+Ver+'   '+CreateDate+CRLF);

  ParCnt:=ParamCount;
  case ParCnt of

   0 :
       begin { ------------------------------------------------------ }
    WriteLn ('Формат :  TextCont Вх-файл [НомСтр]');
    WriteLn ('             НомСтр - номер страницы первого пункта '+
                           '( по умолчанию ─ 1 )');
    Writeln ('             Признак пункта оглавления ─  (#4) в первой '+
                           'позиции строки'+CRLF+
             '             Несколько символов  подряд могут '+
                           'задавать подпункты');
    Delay (1000);    Halt (1)
       end;

   1 : begin { ------------------------------------------------------ }

         path1:=ParamStr(1);  NumPage:=1;
         { Вычислить имя выходного файла с оглавлением }
         FSplit (path1,fd1,fn1,fe1);
         path2:=fd1+fn1+'.cnt';

         OpenInpFile (path1);   { Открыть входной файл }

  { Определить, хватит ли на диске места для промежуточного файла }
  if (DiskFree(0) < (FileSpec.Size div 10))  then begin   { Не хватит ! }
      Close (InpF); WriteLn ('Disk is full !'); Beep; Halt (2)
                                               end;

         OpenOutFile (path2);
       end;

   2 : begin { ------------------------------------------------------ }

         path1:=ParamStr(1);  str1:=ParamStr(2);

         if not Str2Word(str1,NumPage) then begin
    WriteLn ('Формат :  TextCont Вх-файл [НомСтр]');
    WriteLn ('             НомСтр - номер первой страницы документа');
    Writeln ('             Признак пункта оглавления ─  (#4) в первой '+
                           'позиции строки'+CRLF+
             '             Несколько символов  подряд могут '+
                           'задавать подпункты');
    Beep;   Delay (1000);    Halt (1)
                                            end;

         { Вычислить имя выходного файла с оглавлением }
         FSplit (path1,fd1,fn1,fe1);
         path2:=fd1+fn1+'.cnt';

         OpenInpFile (path1);   { Открыть входной файл }

  { Определить, хватит ли на диске места для промежуточного файла }
  if (DiskFree(0) < (FileSpec.Size div 10))  then begin   { Не хватит ! }
      Close (InpF); WriteLn ('Disk is full !'); Beep; Halt (2)
                                               end;

         OpenOutFile (path2);
       end;
  else begin
    WriteLn ('Формат :  TextCont Вх-файл [НомСтр]');
    WriteLn ('             НомСтр - номер первой страницы документа');
    Writeln ('             Признак пункта оглавления ─  (#4) в первой '+
                           'позиции строки'+CRLF+
             '             Несколько символов  подряд могут '+
                           'задавать подпункты');
    Beep;   Delay (1000);    Halt (1)
       end;
  end;

  {  Читаем построчно исходный файл и фиксируем признаки пунктов оглавления  }

  StrSum:=0;
  Write ('Обработано  ');            PosX:=WhereX; PosY:=WhereY;
  while not Eof(InpF) do begin

     Read (InpF,InStr);
     Read (InpF,CR,LF);
     if Pos(#12,InStr)=1 then Inc (NumPage);
     if Pos(PointSimb,Instr)=1 then begin  { Найден новый пункт оглавления }
        { А может это подпункт ? }
           i:=1;  while Pos(CharStr(PointSimb,i),InStr)=1 do Inc (i);  Dec (i);
        { Подравниваем строку по длине }
           j:=VerifyStr(' ', InStr, NotPresent, i+1);
           str1:=Copy(InStr, j, LenInStr-j+1);
           if (Length(str1)+i-1) > PointLen-5 then
                            str1:=Copy(str1, 1, PointLen-5-i+1);
           str1:=CharStr(' ',i-1)+str1;
           str1:=str1+CharStr('.', PointLen-3-Length(str1));
           OutStr:=str1+Long2Str(NumPage);
           Writeln (OutF, OutStr);
                             end;

     Inc(StrSum,Length(InStr));
     if CR+LF = CRLF then Inc (StrSum, 2);
     GotoXY (PosX,PosY); Write ((StrSum/FileSpec.Size*100):5:1,'%');

                         end;

  Writeln;
  Close (InpF);   Close (OutF);

end.
