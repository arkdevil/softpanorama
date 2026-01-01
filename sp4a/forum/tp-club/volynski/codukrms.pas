Program CodUkrMS;
uses Crt,Dos,VES;

var
    CurStr : word;
    PosX,PosY : byte;
    StrSum : Longint;
    LenStr : integer;

begin

  DelCur; { Убрать курсор }
  Ver:='v 1.0';  CreateDate:='04.09.92';

  WriteLn (CRLF+
  '(c)  VES   Перекодировка украинских символов из стандарта MicroSoft '+
           CRLF+
  '           в стандарт Украины и наоборот   '+Ver+'  '+CreateDate);
  Writeln (CRLF+
  '                      MicroSoft          УКРАИНА'   + CRLF +
  '                      #73  ( I )  <──>  #242 ( Є )' + CRLF +
  '                      #105 ( i )  <──>  #243 ( є )' + CRLF +
  '                      #242 ( Є )  <──>  #248 ( ° )'          );
  Writeln (
  '                      #243 ( є )  <──>  #249 ( ∙ )' + CRLF +
  '                      #244 ( Ї )  <──>  #246 ( Ў )' + CRLF +
  '                      #245 ( ї )  <──>  #247 ( ў )' + CRLF   );

  if ParamCount < 2 then begin
     Writeln ('Формат :   CodUkrMS filename[.ext] {M|U}' + CRLF +
              '              M ── из украинской в MicroSoft' + CRLF +
              '              U ── из MicroSoft в украинскую' );
     Delay (1000); Halt (1)
                         end;

  
  path1:=ParamStr (1);  str1:=ParamStr (2); ch3:=UpCase ( str1 [1] );
  if (ch3<>'M') AND (ch3<>'U') then begin
     Writeln ('Формат :   CodUkrMS filename[.ext] {M|U}' + CRLF +
              '              M ── из украинской в MicroSoft' + CRLF +
              '              U ── из MicroSoft в украинскую' );
     Delay (1000); Halt (1)
                                    end;


  OpenInpFile (path1);   { Открыть входной файл }

  { Определить, хватит ли на диске места для промежуточного файла }
  if DiskFree(0)<FileSpec.Size then begin   { Не хватит ! }
      Close (InpF); Writeln ('Disk is full !'); Beep; Halt (2)
                                    end;

  { Вычислить промежуточное имя выходного файла и открыть его }
  FSplit (path1,fd1,fn1,fe1);
  path2:=fd1+fn1+'.cum';
  OpenOutFile (path2);

                   {  Читаем построчно исходный файл и  }
                   {      производим  перекодировку     }

  Write ('Обработано  ');   PosX:=WhereX; PosY:=WhereY; StrSum:=0;
  while not Eof(InpF) do
   begin
     Read (Inpf,InStr); LenStr:=Length (InStr);
     if LenStr<>0 then
             for i:=1 to LenStr do
               case ch3 of
                'M' : { Из украинской в MicroSoft }
                      case InStr[i] of
                 { Є }  #242 : InStr[i]:=#73;   { I }
                 { є }  #243 : InStr[i]:=#105;  { i }
                 { Ў }  #246 : InStr[i]:=#244;  { Ї }
                 { ў }  #247 : InStr[i]:=#245;  { ї }
                 { ° }  #248 : InStr[i]:=#242;  { Є }
                 { ∙ }  #249 : InStr[i]:=#243;  { є }
                      end;
                'U' : { Из MicroSoft в украинскую }
                      case InStr[i] of
                 { I }  #73  : InStr[i]:=#242;  { Є }
                 { i }  #105 : InStr[i]:=#243;  { є }
                 { Ї }  #244 : InStr[i]:=#246;  { Ў }
                 { ї }  #245 : InStr[i]:=#247;  { ў }
                 { Є }  #242 : InStr[i]:=#248;  { ° }
                 { є }  #243 : InStr[i]:=#249;  { ∙ }
                      end;
              end;
     Write (OutF,InStr);
     Inc(StrSum,LenStr);
     Read (InpF, ch1, ch2);
     if (ch1=#13) and (ch2=#10) then begin
        Inc (StrSum, 2);  Write (OutF, ch1, ch2);
                                     end;
     GotoXY (PosX,PosY); Write ((StrSum/FileSpec.Size*100):5:1,'%');
   end;

  Writeln;
  { Закрыть файлы }
  Close (InpF); Close (OutF);
end.