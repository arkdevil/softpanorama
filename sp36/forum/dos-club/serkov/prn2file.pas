{******************************************************************}
{*                   Turbo Pascal version 5.5                     *}
{*                           PRN2FILE                             *}
{*   Листинг программы переназначения вывода на принтер в файл    *}
{*            (C) Copyright 1991 by SVV&MaxiSoftware              *}
{* Во избежание недоразумений в работе программы не рекомендуется *}
{* изменять ее исходный текст.  Рекомендуем также ознакомиться  с *}
{*                содержанием файла PRN2FILE.DOC                  *}
{******************************************************************}

Uses Crt, Dos;        { Используются только стандартные библиотеки }
                      { функций и процедур, имеющиеся у всех поль- }
                      { зователей Turbo Pascal                     }

{$M $400, 0, 0}       { Назначить 1K стек                          }

{$R-,S-,V-,I-}        { Отключить лишние проверки                  }

Const
      MaxSize  = 63000 ;   { Максимальный размер буффера           }

Type
      Address_            = array [1..2] of Word ;
                       { Тип для изменения конфигурации при работе }

Var
      Param              : Record      { Запись рабочих параметров }
      { Имя файла             }  S              : String ;
      { Кол-во Exclude codes  }  Size           : Byte ;
      { Сами исключаемые коды }  B              : Array [1..70] of Byte ;
                           end ;

      FPos                    : LongInt; { Текущая позиция в файле }
      I, Ii, Segment, Offset  : Word ;   { Рабочие переменные      }
      Bo, Bb                  : Boolean ;
      Buf                     : Array [1..MaxSize] of Byte ;
                                { Резервируем буффер }
      C                       : Char ;
      Int_17, Reserv          : Pointer ;
      AddressM                : Address_ ;
      F                       : File ;
      Int_28, Int_8           : Procedure ; { Первичные процедуры  }
                                            { на указанных векторах}
      R                       : Registers ;
      B1, B2                  : Byte ;
      Ss                      : String[70] ;
      X, Y                    : Byte ;


{-----------------------------------------------------------------------------}

Function StrToByte(S : String) : Byte ;  { Перевод строки в байт }
Var
      I, Ii              : Integer ;
begin
     if S[Length(S)]='H' then S:='$'+Copy(S,1,Length(S)-1) ;
     Val(S,I,Ii) ;
     StrToByte:=I ;
end ; {StrToByte}

{-----------------------------------------------------------------------------}

Procedure Mode ;   { Интерпретация 2 командной строки }
begin
     for B1:=1 to Length(Param.S) do Param.S[B1]:=UpCase(Param.S[B1]) ;
     B1:=1 ;
     Param.Size:=0 ;
     Repeat
           Ss:='' ;
           Repeat
                 if Param.S[B1] in ['0'..'9','H','A'..'F'] then
                                                        Ss:=Ss+Param.S[B1] ;
                 Inc(B1) ;
           Until (not (Param.S[B1] in ['0'..'9','H','A'..'F']))
                   or (B1=Length(Param.S)+1) ;
           Inc(Param.Size) ;
           Param.B[Param.Size]:=StrToByte(Ss) ;
           if B1<>Length(Param.S)+1 then Inc(B1) ;
     Until B1=Length(Param.S)+1 ;
end ; {Mode}

{-----------------------------------------------------------------------------}

{$F+}

Procedure SetIntVec(IntNo : Byte; Vector:Pointer);
                              { Упрощенная процедура перестановки векторов }
   begin
      Move(Vector, Mem[0:4*IntNo], SizeOf(Vector));
   end ; {SetIntVec}

{-----------------------------------------------------------------------------}

Procedure WriteIntoFile;    { Запись в файл }
begin
     Inline($fa) ; {Cli}
     if I>0 then
     begin
          C:=#0 ;
          Bo:=False ;
          Assign(F, Param.S) ;
          Repeat
                SwapVectors ;  { Подавление системных сообщений об ошибках }
                Reset(f,1) ;
                if C<>#255 then begin FPos:=FileSize(F); C:=#255; end ;
                SwapVectors ;
                if IOResult<>0 then     { Файл неожиданно исчез }
                begin
                     for B1:=1 to 10 do
                     begin
                          Sound(500+B1*50) ;
                          Delay(30) ;
                          Sound(900+B1*50) ;
                          Delay(5) ;
                     end ;
                     NoSound ;
                     SwapVectors ;
                     Rewrite(F,1) ;    { Открыть новый с тем же именем }
                     SwapVectors ;
                end;
                SwapVectors ;
                Reset(F,1) ;
                Seek(F,FPos) ;
                BlockWrite(F, Buf, I) ;
                SwapVectors ;
                if IOResult<>0 then    { Ошибка записи на диск         }
                begin
                     X:=WhereX ;
                     Y:=WhereY ;
                     Write(#7) ;
                     GotoXY(1,1) ;
                     ClrEOL ;
                     Write('PRN2FILE :  OUTPUT FILE WRITE ERROR.   '+
                           'Retry (y/n) ? ') ;
                     Repeat
                           C:=ReadKey ;
                           C:=UpCase(C) ;
                     Until C in ['Y','N'] ;
                     Gotoxy(1,1) ;
                     ClrEOL ;
                     GotoXY(X, Y) ;
                     if C='N' then   { Если нет, то отключиться совсем }
                                  begin
                                     SetIntVec($17, Int_17) ;
                                     Bo:=True ;
                                  end ;
                end
                else Bo:=True ;
          Until Bo ;
          SwapVectors ;
          Close(F) ;
          SwapVectors ;
          I:=0 ;
     end ;
end ; {WriteIntoFile}

{-----------------------------------------------------------------------------}

Procedure Int28 ; Interrupt ;     { Запись в файл при свободном 28-м }
begin
     Inline($9c) ;  {PushF}
     Int_28 ;
     SetIntVec($28, @Int_28) ;
     WriteIntoFile ;
     if C<>'N' then SetIntVec($28, @Int28) else Bb:=False; { Отключение }
end;{Int28}

{-----------------------------------------------------------------------------}

Procedure Int8; Interrupt ;
                       { Запись в файл по статусу реентерабельности }
begin
     Inline($9c) ;  {PushF}
     Int_8 ;
     if (Mem[Segment:Offset]=0) and (I>Trunc(MaxSize/2)) and (Bb)
         then
             begin
              Move(Mem[0:32], Reserv, 4) ;
              SetIntVec($8, @Int_8) ;
              WriteIntoFile ;
              if C='N' then begin SetIntVec($28, @Int_28); Bb:=False; end ;
              SetIntVec($8, Reserv);
             end;
end ; {Int8}

{-----------------------------------------------------------------------------}

Procedure Int17(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word) ;
                Interrupt ;                       { Обработчик 17-го }
begin
     if (Hi(Ax)=$FF) then   { Нас проверяют на наличие в памяти уже  }
     begin
          Ax:=0 ;           { Значит мы там уже есть                 }
          Bx:=AddressM[1] ; { и даем адрес таблицы текущих параметров}
          Cx:=AddressM[2] ;
     end
     else
        if (Hi(Ax)=2) or (Hi(Ax)=1) then Ax:=$9000
           { Проверка статуса принтера - все OK }
        else
           if Hi(Ax)=0 then   { "печатать" символ }
           begin
                Bo:=True ;
                B1:=0 ;
                if Param.Size>0 then
                begin
                     Repeat
                           Inc(B1) ;   { А нет ли его в Exclude кодах }
                           if Lo(Ax)=Param.B[B1] then Bo:=False ;
                     Until (not Bo) or (B1=Param.Size) ;
                end ;
                if Bo then
                begin
                     Inc(I) ;
                     Buf[I]:=Lo(Ax) ;   { "напечатали" }
                     Ax:=$1000+Lo(Ax);
                     if I>=SizeOf(Buf) then   { Если буффер переполнен, то }
                     begin                    { вернуть код ошибки :       }
                          Ax:=$2900 ;         { No Paper Error             }
                          Dec(I)
                     end
                end
           end
end ; {Int17}

{$F-}

{-----------------------------------------------------------------------------}

Procedure Exists;   { Проверка возможности открытия указанного файла }
begin
     Param.S:=FExpand(Paramstr(1)) ;
     Writeln('Assigned output to file ''', Param.S, '''') ;
     C:=#0 ;
     Assign(F, Param.S) ;
     Reset(F, 1) ;
     if IOResult=0 then
     begin
          Writeln('Warning: file exists !') ;
          Repeat
                Write('Overwrite, Append, Exit ? ') ;
                C:=ReadKey ;
                C:=UpCase(C) ;
                WriteLn(C);
          Until C in ['O','A','E'] ;
          if (C='E') then Halt(2) ;
     end ;
     if (C=#0) or (C='O') then
     begin
          Rewrite(F, 1) ;
          if IOResult<>0 then
          begin
               WriteLn('Error open new file.') ;
               Halt(3) ;
          end ;
     end ;
     Close(F) ;
end ; {Exists}

{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}

Begin {PRN2FILE}
     II:=ParamCount ;
     DirectVideo:=False ;
     SwapVectors ;
     WriteLn ;
     WriteLn('PRN2FILE  Assign printer to file Utility  version 1.0  06-10-91') ;
     WriteLn('Seizes  standart  printer output  and  puts  it  into  the file') ;
     WriteLn('Copyright (C) 1991 SVV&MaxiSoftware            *** FREEWARE ***') ;
     WriteLn('Special thanks to R.Mitnitsky');
     WriteLn ;
     R.Ah:=$FF ;
     Intr($17, R) ;  { Проверка на наличие в памяти резидентной части }
     if R.Ax=0 then
     begin
          AddressM[1]:=R.Bx ;
                { если да, то получить адрес таблицы параметров }
          AddressM[2]:=R.Cx ;
          if Ii=0 then { Нас вызвали без параметров }
          begin
               Move(Mem[AddressM[1]:AddressM[2]], Param, SizeOf(Param)) ;
               WriteLn('Current FileName       : ''', Param.s, '''') ;
               if Param.Size>0 then
               begin
                    Write('Current Exclude Code(s): ') ;
                    for I:=1 to Param.Size do Write(Param.B[I], ';') ;
                    WriteLn ;
               end
          end
          else
          begin
               if Ii>1 then    { Вызов с параметрами для переназнечения }
               begin
                    Param.S:=ParamStr(2) ;
                    Mode ;
               end
               else Param.Size:=0 ;
               Exists ; { доверяй, но проверяй }
               Move(Param, Mem[AddressM[1]:AddressM[2]], SizeOf(Param)) ;
                    { "загнать" измененную таблицу назад в память }
          end ;
          WriteLn ;
          Halt(0) ;
      end ;
     if ParamStr(1)='' then
              { Если нас нет в памяти и запустили без параметров }
     begin
          WriteLn('Usage   :   Prn2File  <FileName[.Ext]>'+
                               '  [Exclude Code(s)...]') ;
          WriteLn('Where   :   FileName.Ext    - target file in '+
                               'which output will go') ;
          WriteLn('            Exclude Code(s) - Code(s) of exclude '+
                               'character(s) (dec. or hex.)') ;
          WriteLn ;
          WriteLn('Example :   PRN2FILE  PRNFILE.TXT  27;45;3FH;AAH;138') ;
          Halt(1) ;
     end ;
        { Если нас запустили первый раз с нужными параметрами }
     if ParamCount>1 then      { Если заданы исключаемые коды }
     begin
          Param.S:=ParamStr(2) ;
          Mode ;
     end
     else Param.Size:=0 ;
     Exists ;
     I:=0 ;
     C:=#0 ;
     AddressM[1]:=Seg(Param) ;
     AddressM[2]:=Ofs(Param.S[0]) ;
        R.Ah:=$34 ;                  { Получить адрес статуса }
        Intr($21,R) ;                { реентерабельности  DOS }
        Segment:=R.Es ;
        Offset :=R.Bx ;
        Bb:=True ;
     GetIntVec($17, Int_17)  ;       { перехват векторов      }
     SetIntVec($17, @Int17)  ;
     GetIntVec($28, @Int_28) ;
     SetIntVec($28, @Int28)  ;
     GetIntVec($8,  @Int_8)  ;
     SetIntVec($8, @Int8)    ;
     WriteLn('Resident part of Prn2file is now installed.') ;
     CheckBreak:=False ;
     Keep(0) ;
end . {PRN2FILE}
