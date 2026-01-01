{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,R-,S-,V+,X+}
{$M $8000, 0, 655360}   { 32K stack, 640K heap }

{***************************************************}
{                                                   }
{        L e c a r                                  }
{   Turbo Pascal 6.X,7.X                            }
{   Попросту, без чинов и Copyright-ов  1991,92,93  }
{   Версия 2.0 от ...... (нужное дописать)          }
{   перед употреблением - PkLiiteить                }
{***************************************************}

{
 К сожалению, не можем похвастаться очень сильной
 прокомментированностью, поэтому доп. вопросы выяснять
 по FIDO 2:463/32 - MiKrOB Nest; 2:463/34 - Mikrob Point
 voice phone (044) 449-9767  до и после 11.0
}

Uses
  Crt, Dos, Objects, MemTrace, Common, Vir1, Vir2, DVir, ErrHand, Archiv, GViewer;

{$F+}
procedure Int23;Interrupt;
  begin
    Halt ($FF); { $FF - на шару }
  end;
{$F-}

Type
  PLecar = ^TLecar;
  TLecar = Object
    Save21, Save23, Save13 : Pointer;
    FViruses : PVirusCollection;
    DViruses : PVirusCollection;
    CmdLine  : ComStr;
    FName    : PathStr;
    Regs     : Registers;
    D        : DirStr;
    N        : NameStr;
    E        : ExtStr;
    TRec     : SearchRec;
    Lecar_Owner : String;
    Fag,
    TestAll,
    TestServers,
    Help,
    LzFlag,
    LzTmp,
    AllDrive,
    EraseUnLz,
    Hacker_Flag,
    VirusInfo,
    StrongMan,
    Registered    : Boolean;
    LzPath        : PathStr;
    CurrDir       : DirStr;
    Birth         : Boolean;
    ByteRead      : Word;
    TotalFiles,
    TotalInfected,
    GlobalTotalFiles,
    GlobalTotalInfected : Longint;
    EntPoint      : Longint;
    CurrentDrive  : Byte;
    constructor Init;
    procedure Run;
    destructor Done;
    function NeedFile(P : PathStr) : Boolean;
    procedure SearchDir( Dir : PathStr);
    function TestFile(FRec : PSearchRec) : Boolean;
    procedure Testing;
    procedure SelfTest;
    procedure PrintDiskInfo(P : PCollection);
    procedure PrintFileInfo(P : PCollection);
    function TestDisk(Drive : Byte) : Byte;
    function TestPartition(Drive : Byte) : Byte;
    procedure GetCmdLine;
    procedure GetConfFile;
  End;

function TLecar.NeedFile(P : PathStr) : Boolean;
  const
    MaxExtDefault = 7;
    NeedExt : Array[1..MaxExtDefault] of ExtStr =
    ('.EXE', '.COM', '.SYS', '.BIN', '.ARJ', '.ZIP', '.LZH');
  Var
    I            : Integer;
    SOffs, DOffs : Word;
    Need         : Boolean;
  begin
    NeedFile := True;
    If TestAll then Exit;
    DOffs := Ofs(P);
    For I := 1 to MaxExtDefault do
    begin
      Soffs := Ofs(NeedExt[I]);
      asm
        Push  SS
        Pop   ES
        Mov   DI, DOffs
        SegSS Mov AL, [DI]        { Длина строки }
        Xor   AH, AH
        Add   DI, AX              { DI -> последний символ }
        Mov   SI, SOffs
        Add   SI, 04h
        Mov   CX, 04h
        Std
        Repz  CmpsB
        Cld
        Mov   @Result, True
        Jz    @Exit
        Mov   @Result, False
      @Exit:
        Mov   AL, @Result
        Mov   Need, AL
      end;
      If Need then Exit;
    end;
 end;

{ Бегаем по директориям }
procedure TLecar.SearchDir(Dir : PathStr);
  Var
     SRec       : SearchRec;
     Error      : Integer;
     DTASeg,
     DTAOfs     : Word;
     Attempt    : Integer;
  begin
    Error := 0;
    If Dir[Length(Dir)] <> '\' then Dir := Concat(Dir, '\');
    FindFirst(Concat(Dir, '*.*'), AnyFile, SRec);
    While DosError = 0 do
    begin
      With SRec do
        If (Attr AND Directory <> 0) AND (Name[1] <> '.') then
        begin
          SearchDir(Concat(Dir, Name));   { Restore DTA }
          DTASeg := Seg(Srec);
          DTAOfs := Ofs(Srec);
          asm
            Push DS
            Mov  AH, 1Ah
            Mov  DX, DTASeg
            Mov  DS, DX
            Mov  DX, DTAOfs
            Int  21h
            Pop  DS
          end;
        end
        else If Name[1] <> '.' then If (Attr AND $18) = 0 then
          begin
            FName := Dir + Name;
            If NeedFile(FName) then
              If Error = 0 then
                If TestFile(@SRec) then
                begin
                  Inc(TotalInfected);
                  Attempt := 0;
                  If Fag then While (Attempt < 20) AND TestFile(@SRec) do Inc(Attempt);
                  If Attempt = 10 then WriteLn(' какя то беда !!!');
                end;
          end;
      FindNext( SRec );                    { Directory searching }
    end;
 end;

function TLecar.TestFile(FRec : PSearchRec) : Boolean;
 Var
   WhatFile : TCarier;
   F        : File;
   I, K     : Integer;
   P1       : PFileVirus;
   P2       : PArc;
   F1       : File;
   Err      : Word;
   GProgram : PSayProgram;
   DirInfo  : SearchRec;
   S        : PathStr;
 begin
   Err := noError;
   asm
     MOV DI, offset Buff
     MOV CX, 0200h
     CLD
     XOR AL, AL
     CLI
     SEGDS REP STOSB
     STI
   end;
   TestFile := False;
   Inc(TotalFiles);
   FSplit(FName, D, N, E);
   ClrEol;
   If Length(FName) < 40 then  Write(FName, #13)
   { Заложимся на длинное имя(с директориями) }
   else Write(Concat(D[1], ':\...\', N+E), #13);
   { Зараженный файл не может быть меньше 135 байт }

   if (Hacker_Flag) and (GoodPrograms <> nil) then { Поприкалываемся }
     for K := 0 to GoodPrograms^.Count-1 do
     begin
       GProgram := GoodPrograms^.At(K);
       if N+E = GProgram^.Ident^ then
         if Length(FName) < 40
           then WriteLn(FName, GProgram^.Say^)
         else WriteLn( D[1]+':\...\'+N+E, GProgram^.Say^)
       end;

   If FRec^.Size < 135 then Exit;
   WhatFile := OtherFile;
   FileMode := 0;
   Assign(F, FName);
   Reset(F, 1);
   Err := Err OR IOResult;
   BlockRead(F, Buff, $200, ByteRead);
   Err := Err OR IOResult;
   If (PWord(@Buff[0])^=$4D5A) OR (PWord(@Buff[0])^=$5A4D) then
   begin
     { EXE-файл }
     WhatFile := EXE;
     EntPoint := A20(PWord(@Buff[$16])^, PWord(@Buff[$14])^)+Longint(PWord(@Buff[$08])^) Shl 4;
     Seek(F, EntPoint); { пойдем по точке входа }
     If FilePos(F) > FRec^.Size - $10 then
     begin
       Close(F); { точка входа на конец файла или за него  }
       Exit;
     end;
     BlockRead(F, Buff, $200, ByteRead); { читаем с точки входа }
     Err := Err OR IOResult;
   end
   else begin
     WhatFile := COM;
     If(Buff[0] = $E8) OR (Buff[0] = $E9) then { проверяем на JMP в COM }
     begin
       Seek(F, FilePos(F)-ByteRead+3+Longint(PWord(@Buff[$1])^));
       If FilePos(F) > FRec^.Size - 200 then
         If FilePos(F) > FRec^.Size - 30 then
         begin
           Close(F);
           Exit;
         end
         else BlockRead(F, Buff, FRec^.Size-FilePos(F), ByteRead)
       else BlockRead(F, Buff, $200, ByteRead);
       Err := Err OR IOResult;
     end
     else begin
       { Проверка на отдачу Ret-ом }
       If (Buff[4] = $C3) AND ((Buff[3] AND $F0) = $50) then
       begin
         Seek(F, Longint(Buff[2]) Shl 8 + Buff[1]-$100);
         Err := Err OR IOResult;
         If FilePos(F) > FRec^.Size - 30 then
         begin
           Close(F);
           Exit;
         end;
         BlockRead(F, Buff, 100, ByteRead);
         Err := Err OR IOResult;
       end
       else If (Buff[5] = $C3) AND ((Buff[4] AND $F0) = $50) then
       begin
         Seek(F, Longint(Buff[3]) Shl 8 + Buff[2]-$100);
         Err := Err OR IOResult;
         If FilePos(F) > FRec^.Size - 30 then
         begin
           Close(F);
           Exit;
         end;
         BlockRead(F, Buff, 100, ByteRead);
         Err := Err OR IOResult;
       end

       else If PLong(@Buff[0])^ = $0FFFFFFFF then
       begin
         WhatFile := SYS;
         Seek(F, Longint(Buff[7]) Shl 8 + Buff[6]);
         BlockRead(F, Buff, $200, ByteRead);
         Err := Err OR IOResult;
       end
       else begin
         { проверка на вирусы, которые мы узнаем по началу файла }
         Close(F);
         I := -1;
         Repeat
           Inc(I);
         Until (I = FViruses^.Count) OR PFileVirus(FViruses^.At(I))^.TestFile(F, WhatFile);
         If I <> FViruses^.Count then
         begin { найден вирус }
           P1 := PFileVirus(FViruses^.At(I));
           If Length(FName) < 40 then Write(FName, ' вирус ', P1^.Name^)
           else Write(Concat(D[1], ':\...\', N, E, ' вирус ', P1^.Name^));
           TestFile := True;
           { нашли вирус и умеем его лечить, если что, раскручиваем матрешку }
           If Fag then P1^.ClearFile(F) else WriteLn;
         end { Нет вирусов и дисковая ошибка }
         else
           If (Err <> noError)
             then If Length(FName) < 40
                    then WriteLn(FName, ^G' - ', LastError)
                  else WriteLn(Concat(D[1], ':\...\', N, E, ^G' - ', LastError));
         if LzFlag and (Archivers <> nil) then
         begin
           I := -1;
           Repeat
             Inc(I);
           Until (I = Archivers^.Count) OR PArc(Archivers^.At(I))^.TestFile(FName);
           If I <> Archivers^.Count then
           begin { найден архив }
             P2 := PArc(Archivers^.At(I));
             WriteLn(FName, ' archive ', P2^.Name^);
             if P2^.Extract(FName, LZPath) then;
             FSplit(LZPath, D, N, E);
             D:= Concat(D, N);
             if D[Length(D)] <> '\' then D:= Concat(D, '\');
             FindFirst(Concat(D,'*.*'), Archive, DirInfo);
             S:= FName;
             while DosError = 0 do
             begin
               FName := Concat(D, DirInfo.Name);
               if TestFile(@DirInfo)
                 then P2^.MoveFile(S, Concat(D,Dirinfo.Name));
               Assign(F1, Concat(D,Dirinfo.Name));
               if EraseUnLZ then Erase(F1);
               InOutRes:= 0;
               FindNext(DirInfo);
             end;
           end;
         end;
         Exit;
       end;
     end;
   end;
   { Файл может иметь как тип EXE так и COM }
   If ((Buff[0] = $E8) OR (Buff[0] = $E9)) AND ((Buff[$1]<>$00) OR (Buff[$2]<>$00)) then
   begin
     { если что пойдем по JMP }
     Seek(F, FilePos(F)-ByteRead+3+Longint(PInt(@Buff[$01])^));
     If FilePos(F) > FRec^.Size - 100 then
     begin
       Close( F );
       Exit;
     end;
     BlockRead(F, Buff, $100, ByteRead);
     Err := Err OR IOResult;
   end;
   { СДЯВы, которые не узнаем по началу }
   Close(F);
   I := -1;
   Repeat
     Inc(I);
   Until (I = FViruses^.Count) OR PFileVirus(FViruses^.At(I))^.TestFile(F, WhatFile);
   If I <> FViruses^.Count then
   begin { найден вирус }
     P1 := PFileVirus(FViruses^.At(I));
     If Length(FName) < 40 then Write(FName, ' вирус ', P1^.Name^)
     else Write(Concat(D[1], ':\...\', N, E, ' вирус ', P1^.Name^));
     TestFile := True;
     { нашли вирус и умеем его лечить }
     If Fag then P1^.ClearFile(F) else WriteLn;
   end { Нет вирусов и дисковая ошибка }
   else If (Err <> noError)
     then If Length(FName) < 40
            then WriteLn(FName, ^G' - ', LastError)
          else WriteLn(Concat(D[1], ':\...\', N, E, ^G' - ', LastError));
   if LzFlag and (Archivers <> nil) then
   begin
     I := -1;
     Repeat
       Inc(I);
     Until (I = Archivers^.Count) OR PArc(Archivers^.At(I))^.TestFile(FName);
     If I <> Archivers^.Count then
     begin { найден архив }
       P2 := PArc(Archivers^.At(I));
       WriteLn(FName, ' archive ', P2^.Name^);
       if P2^.Extract(FName, LZPath) then;
       FSplit(LZPath, D, N, E);
       D:= Concat(D, N);
       if D[Length(D)] <> '\' then D:= Concat(D, '\');
       FindFirst(Concat(D,'*.*'), Archive, DirInfo);
       S:= FName;
       while DosError = 0 do
       begin
         FName := Concat(D, DirInfo.Name);
         if TestFile(@DirInfo)
           then P2^.MoveFile(S, Concat(D,Dirinfo.Name));
         Assign(F1, Concat(D,Dirinfo.Name));
         if EraseUnLZ then Erase(F1);
         InOutRes:= 0;
         FindNext(DirInfo);
       end;
     end;
   end;
   Write(#13);
 end;

{ Проверка диска }
procedure TLecar.Testing;
  Var
    Percent : Real;
    Result  : Byte;
  begin
    WriteLn;
    WriteLn(CurrDir, ' Дышите глубже');
    Repeat
      Result := TestDisk(CurrentDrive);        { на Boot }
    Until NOT (Fag And (Result = $FE)) ;
    SearchDir(CurrDir); { пошли шуршать по дискам }
    InOutRes := 0;
    { выведем статистику }
    WriteLn( #1, '':30, #13, 'Всего проверено файлов: ', TotalFiles, '':20 );
    If TotalInfected <> 0 then begin
      If Fag then WriteLn( 'Всего вылечено файлов:  ', TotalInfected )
      else WriteLn( 'Всего заражено файлов: ', TotalInfected );
      If Hacker_Flag then begin
        Percent := TotalInfected / TotalFiles;
        Write('ДИАГНОЗ:  ');
        If( Percent < 0.1 ) then WriteLn(' Не отчаивайтесь, бывает и хуже')
        else If( Percent < 0.3 ) then WriteLn(' И где Вы столько набрали ?')
             else If( Percent < 0.7 ) then WriteLn(' Больной перед смертью потел  ? ')
                  else WriteLn(' Ну вот, на коллекцию натравили');
      end;
    end
    else WriteLn('Проверено. Вирусов нет. Лекарь.');
  end;

function TLecar.TestPartition(Drive : Byte) : Byte;
  Var
    Tmp    : Byte;
    I      : Integer;
    Carier : TCarier;
    P      : PDiskVirus;
  begin
    FillChar(Buff, SizeOf(Buff), #0);
    Tmp := 0;
    Tmp := Tmp Or AbsRead(Drive, 0, 0, 1, 1, Buff);
    I := -1;
    Repeat
      Inc(I);
    Until (I = DViruses^.Count) OR PDiskVirus(DViruses^.At(I))^.TestDisk(Drive);
    If I <> DViruses^.Count then
    begin
      Inc(TotalInfected);
      P := PDiskVirus(DViruses^.At(I));
      Write(#13'Master - boot sector drive ', Char(Byte('C')+Drive And $7F), ': virus ', P^.Name^);
      if Fag then
      begin
        Tmp := Tmp Or P^.ClearDisk;
        If Tmp = noError then
        begin
          WriteLn(' дезактивировал');
          Tmp := $FE;
        end
        else begin
          If Tmp = $FF then WriteLn(' не умею лечить') else WriteLn(^G' не лечится');
          Tmp := $FF;
        end;
      end
      else WriteLn;
      FillChar(Buff, SizeOf(Buff), #0);
    end;
    TestPartition := Tmp;
  end;

function TLecar.TestDisk(Drive : Byte) : Byte;
  Var
    Tmp    : Byte;
    I      : Integer;
    Carier : TCarier;
    P      : PDiskVirus;
  begin
    FillChar(Buff, SizeOf(Buff), #0);
    Tmp := 0;
    Tmp := Tmp Or DiskRead(Drive, 0, 1, Buff);
    I := -1;
    Repeat
      Inc(I);
    Until (I = DViruses^.Count) OR PDiskVirus(DViruses^.At(I))^.TestDisk(Drive);
    If I <> DViruses^.Count then
    begin
      Inc(TotalInfected);
      P := PDiskVirus(DViruses^.At(I));
      Write(#13'Boot sector drive ', Char(Byte('A')+ Drive), ': virus ', P^.Name^);
      if Fag then
      begin

        P^.LogDrive := Drive; { Next step }

        Tmp := Tmp Or P^.ClearDisk;
        If Tmp = noError then
        begin
          WriteLn(' дезактивировал');
          Tmp := $FE;
        end
        else begin
          If Tmp = $FF then WriteLn(' не умею лечить') else WriteLn(^G' не лечится');
          Tmp := $FF;
        end;
      end
      else WriteLn;
      FillChar(Buff, SizeOf(Buff), #0);
    end;
    TestDisk := Tmp;
  end;

procedure TLecar.GetConfFile;
var
  F         : Text;
  SourceStr,
  Tmp_Str   : String;
  I,J       : Word;
const
  MaxReservedWords =11;
  ReservedWords : Array [1..MaxReservedWords] of String[20]=(
    'REGISTERED',
    'CHECKALLDRIVES',
    'CHECKALLFILES',
    'OWNER',
    'CURE',
    'NONDOCUMENTED',
    'EXPANDFILES',
    'ERASEEXPANDED',
    'PATHEXPAND',
    'BEGINDESCRIPTOR',
    'ENDDESCRIPTOR'
  );

function CompStr : Word;
var
  I,J    : Word;
  RetVal : Word;
begin
  RetVal :=0;
  If Pos(';',SourceStr) <> 0 then
    Delete(SourceStr,Pos(';',SourceStr),Byte(SourceStr[0])-Pos(';',SourceStr)+1);
  If Byte(SourceStr[0]) > 1 then
    For J :=1 to MaxReservedWords do
      If Pos(ReservedWords[J],SourceStr) <> 0 then RetVal := J;
  CompStr :=RetVal;
end;

begin
  Fag         := False;
  TestAll     := False;
  Hacker_Flag := False;
  LzFlag      := False;
  EraseUnLz   := True;
  StrongMan   := False;
  TestServers := False;
  AllDrive    := False;
  VirusInfo   := False;
  Help        := False;
  Registered  := True;
  Lecar_Owner := '';


  DosError := 0;
  FindFirst('LECAR.CTL',AnyFile,TRec);
  If DosError <> 0 then Exit;
  Assign(F, 'LECAR.CTL');
  Reset (F);
  While Not(Eof(F)) do begin
    ReadLn (F,SourceStr);
    SourceStr := UpString (SourceStr);
    Case CompStr of
      1: begin {Registered}
         I := Pos('REGISTERED',SourceStr)+11;
         If I<= Byte(SourceStr[0]) then begin
           Tmp_Str := '';
           For J:=I to Byte(SourceStr[0]) do Tmp_Str := Tmp_Str+UpCase(SourceStr[J]);
           If (Pos('NO',Tmp_Str)<>0) OR (Pos('неа',Tmp_Str)<>0)
              then Registered := False;
         end;
      end;
      2: begin {CheckAllDrives}
         I := Pos('CHECKAllDRIVES',SourceStr)+16;
         If I<= Byte(SourceStr[0]) then begin
           Tmp_Str := '';
           For J:=I to Byte(SourceStr[0]) do Tmp_Str := Tmp_Str+UpCase(SourceStr[J]);
           If (Pos('YES',Tmp_Str)<>0) OR (Pos('ага',Tmp_Str)<>0)
              then AllDrive := True;
         end;
      end;
      3: begin {CheckAllFiles}
         I := Pos('CHECKAllFILES',SourceStr)+15;
         If I<= Byte(SourceStr[0]) then begin
           Tmp_Str := '';
           For J:=I to Byte(SourceStr[0]) do Tmp_Str := Tmp_Str+UpCase(SourceStr[J]);
           If (Pos('YES',Tmp_Str)<>0) OR (Pos('ага',Tmp_Str)<>0)
              then TestAll := True;
         end;
      end;
      4: begin {Owner}
         I := Pos('OWNER',SourceStr)+6;
         If I<= Byte(SourceStr[0]) then begin
           Tmp_Str := '';
           For J:=I to Byte(SourceStr[0]) do Tmp_Str := Tmp_Str+UpCase(SourceStr[J]);
           Lecar_Owner := Tmp_Str;
         end;
      end;
      5: begin {Cure}
         I := Pos('CURE',SourceStr)+5;
         If I<= Byte(SourceStr[0]) then begin
           Tmp_Str := '';
           For J:=I to Byte(SourceStr[0]) do Tmp_Str := Tmp_Str+UpCase(SourceStr[J]);
           If (Pos('YES',Tmp_Str)<>0) OR (Pos('ага',Tmp_Str)<>0)
              then Fag := True;
         end;
      end;
      6: begin {NonDocumented}
         I := Pos('NONDOCUMENTED',SourceStr)+14;
         If I<= Byte(SourceStr[0]) then begin
           Tmp_Str := '';
           For J:=I to Byte(SourceStr[0]) do Tmp_Str := Tmp_Str+UpCase(SourceStr[J]);
           If (Pos('YES',Tmp_Str)<>0) OR (Pos('ага',Tmp_Str)<>0)
              then Hacker_Flag := True;
         end;
      end;
      7: begin {ExpandFiles}
         I := Pos('EXPANDFILES',SourceStr)+12;
         If I<= Byte(SourceStr[0]) then begin
           Tmp_Str := '';
           For J:=I to Byte(SourceStr[0]) do Tmp_Str := Tmp_Str+UpCase(SourceStr[J]);
           If (Pos('YES',Tmp_Str)<>0) OR (Pos('ага',Tmp_Str)<>0)
              then LzFlag := True;
         end;
      end;
      8: begin {EraseExpanded}
         I := Pos('ERASEEXPANDED',SourceStr)+14;
         If I<= Byte(SourceStr[0]) then begin
           Tmp_Str := '';
           For J:=I to Byte(SourceStr[0]) do Tmp_Str := Tmp_Str+UpCase(SourceStr[J]);
           If (Pos('NO',Tmp_Str)<>0) OR (Pos('неа',Tmp_Str)<>0)
              then EraseUnLz := False;
         end;
      end;
      9: begin {PathExpand}
         I := Pos('PATHEXPAND',SourceStr)+11;
         If I<= Byte(SourceStr[0]) then begin
           Tmp_Str := '';
           For J:=I to Byte(SourceStr[0]) do Tmp_Str := Tmp_Str+UpCase(SourceStr[J]);
           LzPath := Tmp_Str;
           if LzPath[Length(LzPath)] <> '\' then LzPath:= Concat(LzPath,'\');
         end;
      end;
      10 : begin
        Archivers := New(PArchiver, Init(2,1));
        ReadLn (F,SourceStr);
        SourceStr := UpString (SourceStr);
        while (CompStr <> 11) and (Not Eof (F)) do
        begin
          If Pos(';',SourceStr) <> 0 then
            Delete(SourceStr,Pos(';',SourceStr),Byte(SourceStr[0])-Pos(';',SourceStr)+1);
          if Length(SourceStr) <> 0
            then Archivers^.Insert(New(PArc, Init(SourceStr)));
          ReadLn (F,SourceStr);
          SourceStr := UpString (SourceStr);
        end;
      end;


    end; {Case}
  end;
  Close (F);
end;

procedure TLecar.GetCmdLine;
Var
  _I, _J : Byte;
  TmpStr : String;
begin
  CmdLine := '';
  For _I := 1 to Mem[PrefixSeg:$80] do
    CmdLine := Concat(CmdLine, UpCase(Char(Mem[PrefixSeg:$80+_I])));
  For _I := 1 to Length( CmdLine ) do begin
    If CmdLine[_I] = '*' then AllDrive := True;
    If CmdLine[_I] = ':' then CurrentDrive := Byte(CmdLine[_I-1])-Byte('A');
    If CmdLine[_I] = '/' then
      Case CmdLine[_I+1] of
        'F','C' : Fag         := True;
        'G','A' : TestAll     := True;
        'H'     : Hacker_Flag := True;
        'L'     : LzFlag      := True;
        'N'     : EraseUnLz   := False;
        'B'     : StrongMan   := True;
        'D'     : TestServers := True;
        'S'     : begin
          LzTmp := True;
          _J := _I+2;
          Repeat
            Inc( _J );
          Until(CmdLine[_J] = ' ') OR (_J > Ord(CmdLine[0])) OR (CmdLine[_J] = '/');
          LzPath := Copy(CmdLine, _I+3, _J-_I-3);
          If LzPath[Length(LzPath)] <> '\' then LzPath := Concat(LzPath, '\');
        end;
        'T'     : begin
          _J := _I+2;
          Repeat
            Inc( _J );
          Until(CmdLine[_J] = ' ') OR (_J > Ord(CmdLine[0])) OR (CmdLine[_J] = '/');
          TmpStr := Copy(CmdLine, _I+1, _J-_I-1);
          If TmpStr = 'TURMITE' then VirusInfo := True;
        end;
        else Help := True;
       end; { case }
     If(CmdLine[_I] = ':') AND(CmdLine[_I-2] <> '=') then
     begin
       _J := _I-1;
       CurrDir := '';
       Repeat
         CurrDir := Concat(CurrDir, CmdLine[_J]);
         Inc(_J);
       Until (CmdLine[_J] = ' ') OR(_J > Ord(CmdLine[0]));
     end;
   end;
end;


constructor TLecar.Init;
const
  StatusLine : String[60] = '└─────────────────────────────────────────────────────────┘';
var
  DateYear,
  DateMonth,
  DateDay,
  DateWeek : Word;
  PBDay    : PBirth;
  T        : Longint;
  J        : Byte;

  function IntToStr(N : Longint) : String;
    Var
      Tmp  : String[11];
      Code : Integer;
  begin
    Tmp := '';
    Str(N, Tmp);
    IntToStr := Tmp;
  end;

{ Титулка, выводится каждый раз }
procedure Titul;
  Const
    LNum : String[60] = '│               Л е к а р ь    v 2.XXX                    │';
  Var
    Tmp,
    Tmp1 : String;
    I   : Byte;
  begin
    Str(FViruses^.Count+DViruses^.Count : 3, Tmp);
    For I := 1 to Length(Tmp) do If Tmp[I] = ' ' then Tmp[I] := '0';
    Move(Tmp[1], LNum[36], Length(Tmp));
    WriteLn('┌─────────────────────────────────────────────────────────┐');
    WriteLn(LNum);
    If Hacker_Flag then
    begin
      WriteLn('│  раз, два, три, четыре, пять - вышел  ЛЕКАРЬ  погулять  │');
      WriteLn('│          Кто не спpятался, - я не виноват               │');
    end;
    WriteLn('│              Copyright MiKrOB&Turmite                   │');
    If (Lecar_Owner <>'') AND (Length(Lecar_Owner)<32) then begin
      Tmp := '│';
      If Registered then Tmp1 := 'Регистрирован на '+Lecar_Owner
      else Tmp1 := '  ПИРАТСКАЯ копия, немедленно зарегестрируйте !!!!';
      For I := 1 to ((55-Length(Tmp1)) Shr 1)+1 do Tmp := Tmp+' ';
      Tmp := Tmp+Tmp1;
      For I := Length(Tmp) to 57 do Tmp := Tmp+' ';
      Tmp := Tmp +'│';
      WriteLn(Tmp);
    end;
    WriteLn('│      Для получения справочной информации - Lecar /?     │');
    WriteLn('├─────────────────────────────────────────────────────────┤');
    If (Test8086 And $80) <> 0
      then Tmp := Concat(' V', CPU[Test8086-$80], ' ')
    else Tmp := Concat(' ', CPU[Test8086], ' ');
    Move(Tmp[1], StatusLine[4], Length(Tmp));
    If DesqView.Present then
    begin
      Tmp := Concat(' DesqView ', IntToStr(Hi(DesqView.Version)), '.',
      IntToStr(Lo(DesqView.Version)), ' ');
      Move(Tmp[1], StatusLine[14], Length(Tmp));
    end
    else begin
      Tmp := Concat(' DOS ', IntToStr(Hi(MDos.Version)), '.',
      IntToStr(Lo(MDos.Version)), ' ');
      Move(Tmp[1], StatusLine[14], Length(Tmp));
    end;
    If Windows.Present then
    begin
      Tmp := Concat(' Windows ', IntToStr(Hi(Windows.Version)), '.',
      IntToStr(Lo(Windows.Version)), ' ');
      Move(Tmp[1], StatusLine[31], Length(Tmp));
    end;
    If Net then
    begin
      Tmp := ' NetWork ';
      Move(Tmp[1], StatusLine[48], Length(Tmp));
    end;
    WriteLn(StatusLine);
  end;

  { Медленный вывод, используется в RunHelp }
  procedure WriteSlow( St : String );
  var
     I : Byte;
     J : Word;
  begin
    for I := 1 to Length( St ) do
      begin
        Sound(50);
        Write( St[I] );
        NoSound;
        Delay(55);
      end;
    WriteLn;
  end;

  { Если бул запущен без параметров или с ключом /? }
  procedure RunHelp;
  var
    Ch : Char;
  begin
    WriteLn;
    WriteLn(' Здравствуйте, я Лекарь');
    WriteLn(' Умею искать и лечить вирусы');
    WriteLn(' Понимаю следующие параметры :');
    WriteSlow(' Lecar [path] [/options]  , где');
    WriteSlow('       path    - вирусоопасное направление');
    WriteSlow('       *       - проверять все винты');
    WriteSlow('       options - методы искоренения:');
    WriteSlow('       /a      - проверять все, что плохо лежит');
    WriteSlow('       /c      - лечить настигнутых негодяев');
    WriteSlow('       /d      - работа в сети или многозадчке (применять при зависаниях)');
{
    WriteSlow('       /l      - разархивировать заархивированных LZEXE');
    WriteSlow('       /s=path - установить рабочий каталог( использовать совместно с /l )');
    WriteSlow('       /n      - раскрученнные файлы не удалять');
    WriteSlow('       /b      - применять при тяжелых случаях ADMa');
}
    WriteSlow('       /h      - недокументированный ключ');
    WriteSlow('       /?      - подсказка о ключах');
    WriteLn(#13,#10,
              ' Lecar *  /c/h - проверить с лечением все диски > B:');
    WriteLn(  ' Lecar c: /h   - проверить диск C:');
    WriteLn(#13,#10,' Cвязь по FIDO  : 2:463/34 ─── MiKrOB Point - (044) 268-9168');
    WriteLn(' Связь по Relcom: lecar@fund.kiev.ua');
    WriteLn(' Voice  phone   : (044) 449-97-67 ─── до и после 11.00');
    WriteLn;
    Write(' Нажмите любую клавишу для продолжения'#13);
    Ch := ReadKey;
    If Ch = #0 then Ch := ReadKey;
    ClrEol;
  end;

  begin
    GetVector($21, Save21);
    GetVector($13, Save13);
    GetVector($23, Save23);
    SetVector($23, @Int23);
    Load_Rus_Font;
    GetDir(0, CurrDir); { текущая директория }
    CurrDir := Copy(CurrDir, 1, 3);
    Regs.AH := $19;  { текущий диск }
    MsDos(Regs);
    CurrentDrive := Regs.AL;
{$IFDEF DEBUG}
    WriteLn('Current drive is : ', Char(Byte('A')+CurrentDrive));
{$ENDIF}
    GetConfFile;
    GetCmdLine;
    TotalFiles := 0;
    TotalInfected := 0;
    GlobalTotalFiles := 0;
    GlobalTotalInfected := 0;

    DViruses := New(PVirusCollection, Init(10, 5));
    DViruses^.Insert(New(PStoneVirus, Init(
      'Stone RB512', True, $1E,$C0,$8E,$D8,$8E,$D8, $00,$11,$12,$13,$12,$13,
      $2E,$FF,$2E,$09,$00,$54,
      $FA,$B4,$0E,$B7,$00,$00, $A5,$122,$123,$124,$125,$125)));
    DViruses^.Insert(New(PGenericVirus, Init(
      'Generic RB512', True, $FC,$F9,$CD,$D3,$72,$4A,$01,$02,$09,$0A,$0B,$0C,
      $CD,$D3,$CA,$02,$00,$54, { cd d3; ret far 02}
      $06,$04,$00,$83,$F9,$0D, $174,$163,$164,$165,$166,$167)));
    DViruses^.Insert(New(PSexRevolution, Init(
      'SexRevolution RB512', True, $1E,$80,$72,$17,$17,$17,$01,$02,$05,$06,$06,$06,
      $2E,$FF,$2E,$09,$00,$54,
      $90,$8E,$D0,$BC,$00,$08,
      $A5,$A6,$A7,$A8,$A9,$FC)));
    DViruses^.Insert(New(PRostov, Init(
      'Rostov RB512', False, $00,$01,$02,$03,$04,$05,
                             $00,$00,$02,$03,$04,$05,
      $54,$75,$72,$6D,$69,$79,
      $13,$BA,$80,$00,$89,$13,
      $10D,$122,$123,$124,$125,$10D)));
    DViruses^.Insert(New(PDenZuk, Init(
      'Den-Zuk RB512', True, $EB,$0A,$9C,$06,$06,$06,
                             $00,$01,$0C,$0D,$0D,$0D,
      $CD,$6F,$CF,$54,$75,$72,
      $29,$FA,$FA,$BC,$F0,$F0,
      $01,$2B,$2C,$33,$35,$35)));
    DViruses^.Insert(New(PMarch6Virus, Init(
      'March6 RB512', True, $1E,$50,$0A,$00,$00,$00,
                            $00,$01,$17,$18,$18,$18,
      $2E,$FF,$2E,$0A,$00,$72,
      $50,$8B,$0E,$08,$00,$00,
      $BD,$103,$104,$105,$106,$106)));
    DViruses^.Insert(New(PPFlipVirus, Init(
      'Flip', False,$00,$01,$0A,$00,$00,$00,
                    $00,$00,$17,$18,$18,$18,
      $54,$75,$72,$6D,$69,$79,
      $B8,$03,$00,$E8,$1F,$1F,
      $09,$0A,$0B,$0C,$0D,$0D)));
    DViruses^.Insert(New(PBallVirus, Init(
      'Ping-Pong RB1024', True,$1E,$06,$50,$53,$53,$53,
                               $00,$01,$02,$03,$03,$03,
      $2E,$FF,$2E,$2A,$7D,$54,
      $26,$F8,$7D,$80,$F9,$F9,
      $4F,$50,$51,$52,$56,$56)));
    DViruses^.Insert(New(PMisspelVirus, Init(
      'Misspeller RB1024', False,$00,$01,$50,$53,$53,$53,
                                 $00,$00,$02,$03,$03,$03,
      $54,$75,$72,$6D,$69,$79,
      $26,$FA,$7D,$80,$F7,$F7,
      $4F,$50,$51,$52,$56,$56)));
    DViruses^.Insert(New(PDHercenVirus, Init(
      'Hercen RBSE1024', False,$00,$01,$50,$53,$53,$53,
                               $00,$00,$02,$03,$03,$03,
      $54,$75,$72,$6D,$69,$79,
      $8E,$C0,$8E,$D0,$BC,$BC,
      $26,$27,$2C,$2D,$2E,$2E)));

{$IFDEF DEBUG}
    WriteLn(' Disk viruses initialized OK');
{$ENDIF}

    FViruses := New(PVirusCollection, Init(10, 5));
    FViruses^.Insert(New(P648Virus, Init(
      'Time Bomb C648 v.A', False, 0,1,2,3,4,5, 0,0,2,3,4,5, 0,1,2,3,4,5,
      $BA,$FC,$8B,$03,$8B,$03, $01,$04,$05,$0F,$05,$0F, 1,$203,3)));
    FViruses^.Insert(New(P648Virus, Init(
      'Incom C648 Я. Цурин', False, 0,1,2,3,4,5, 0,0,2,3,4,5, 0,1,2,3,4,5,
      $BA,$02,$01,$E9,$01,$E9, $00,$01,$02,$03,$02,$03, 4,$266,6)));
    FViruses^.Insert(New(P648Virus, Init(
      'Time Bomb C644', False, 0,1,2,3,4,5, 0,0,2,3,4,5, 0,1,2,3,4,5,
      $0E,$1F,$E8,$C3,$E8,$C3, $00,$01,$02,$05,$02,$05, 3,$204,6)));
    FViruses^.Insert(New(P648Virus, Init(
      'Kemerovo (Piter) C257', False, 0,1,2,3,4,5, 0,1,2,3,4,5, 0,1,2,3,4,5,
      $92,$E8,$92,$E8,$92,$E8, $00,$01,$00,$01,$00,$01, 2,$0C5,4)));
    FViruses^.Insert(New(P648Virus, Init(
      'RC506 Hero', True, $75,$05,$C0,$CF,$C0,$CF, $03,$04,$08,$09,$08,$09,
      $EB,$28,$54,$75,$72,$6D,
      $81,$2E,$85,$02,$85,$02, $03,$09,$0C,$0D,$0C,$0D, 1,$087,4)));
    FViruses^.Insert(New(P648Virus, Init(
      '417 Fuck You', True, $50,$03,$9B,$00,$9B,$00, $00,$05,$07,$08,$07,$08,
      $50,$E9,$A0,$00,$54,$75,
      $CD,$12,$06,$1E,$06,$1E, $04,$05,$14,$15,$14,$15, 1,$074,3)));
    FViruses^.Insert(New(P648Virus, Init(
      'Attention', True, $52,$06,$FC,$4B,$FC,$4B, $03,$07,$09,$0A,$09,$0A,
      $2E,$FF,$2E,$15,$00,$54,
      $79,$01,$02,$00,$02,$00, $07,$08,$0A,$0B,$0A,$0B, 1,-16,16)));
    FViruses^.Insert(New(P648Virus, Init(
      'Tiny RC144', True, $40,$03,$EB,$01,$EB,$01, $03,$0A,$0C,$0D,$0C,$0D,
      $2E,$FF,$2E,$5D,$00,$54,
      $60,$00,$C6,$31,$C6,$31, $00,$04,$08,$09,$08,$09, 1,$37,3)));
    FViruses^.Insert(New(P648Virus, Init(
      'Kiev 90 C483', False, 0,1,2,3,4,5, 0,1,2,3,4,5, 0,1,2,3,4,5,
      $8B,$E9,$8B,$87,$8B,$87, $00,$01,$07,$08,$07,$08, 1,$1D1,3)));
    FViruses^.Insert(New(P648Virus, Init(
      'Leninfo', False, 0,1,2,3,4,5, 0,1,2,3,4,5, 0,1,2,3,4,5,
      $90,$90,$83,$C6,$83,$C6, $00,$01,$08,$09,$08,$09, 1,$23C,3)));
    FViruses^.Insert(New(P648Virus, Init(
      'C377', False, 0,1,2,3,4,5, 0,1,2,3,4,5, 0,1,2,3,4,5,
      $B9,$79,$01,$CD,$01,$CD, $10E,$10F,$120,$121,$120,$121, 1,$14B,3)));
    FViruses^.Insert(New(P648Virus, Init(
      'TothLess C534 (MS Right)', False, 0,1,2,3,4,5, 0,1,2,3,4,5, 0,1,2,3,4,5,
      $B9,$65,$01,$83,$01,$83, $F2,$F3,$F4,$F5,$F4,$F5, 1,$14B,3)));
    FViruses^.Insert(New(P648Virus, Init(
      'Si RC492', False, 0,1,2,3,4,5, 0,1,2,3,4,5, 0,1,2,3,4,5,
      $8B,$1E,$01,$01,$01,$01, $01,$02,$03,$04,$03,$04, 1,$6F,6)));
    FViruses^.Insert(New(P648Virus, Init(
      'SoftPanorama RCE1864', True, $CD,$62,$CD,$62,$CD,$62, $00,$01,$00,$01,$00,$01,
      $2E,$3A,$26,$FF,$0D,$77,
      $E8,$00,$B1,$04,$B1,$04, $00,$01,$04,$05,$04,$05, 1,$1DE,14)));
    FViruses^.Insert(New(PLoveVirus, Init(
      'LoveChild', True, $EA,$CD,$02,$00,$02,$00, $00,$01,$02,$04,$02,$04,
      $2E,$3A,$26,$FF,$0D,$77,
      $FB,$E9,$FB,$E9,$FB,$E9, $00,$01,$00,$01,$00,$01, 2,$75,4, $16)));
    FViruses^.Insert(New(PLoveVirus, Init(
      'C713 имени Фомы', False, 0,1,2,3,4,5, 0,1,2,3,4,5, 0,1,2,3,4,5,
      $B8,$F0,$FF,$E9,$FF,$E9, $00,$01,$02,$03,$02,$03, 4,-55,6, $40)));
    FViruses^.Insert(New(PLoveVirus, Init(
      'Tumen - 1.0', True, $EB,$FD,$FC,$FD,$FC,$FD, $01,$02,$04,$05,$04,$05,
      $2E,$FF,$2E,$3C,$04,$54,
      $FA,$50,$FB,$C3,$FB,$C3, $00,$01,$12,$13,$12,$13, 1,-220,7, $3EA)));
    FViruses^.Insert(New(PLoveVirus, Init(
      'Tumen - 2.0', True, $80,$FF,$10,$E8,$10,$E8, $00,$02,$0C,$0D,$0C,$0D,
      $2E,$FF,$2E,$B0,$00,$54,
      $5B,$81,$84,$19,$84,$19, $03,$0C,$0E,$1A,$0E,$1A, 1,-385,3, $181)));
    FViruses^.Insert(New(PLoveVirus, Init(
      'Tumen - 1.2', True, $80,$FF,$14,$50,$14,$50, $00,$02,$0C,$0D,$0C,$0D,
      $2E,$FF,$2E,$25,$00,$54,
      $5B,$81,$36,$2C,$36,$2C, $00,$09,$0B,$17,$0B,$17, 1,-307,3, $133)));
    FViruses^.Insert(New(PLoveVirus, Init(
      'Time Bomb C623', False, 0,1,2,3,4,5, 0,1,2,3,4,5, 0,1,2,3,4,5,
      $BA,$FC,$00,$F3,$00,$F3, $01,$04,$0F,$10,$0F,$10, 1,-137,3, $93)));
    FViruses^.Insert(New(PLoveVirus, Init(
      'Joker 0.1', False, 0,1,2,3,4,5, 0,1,2,3,4,5, 0,1,2,3,4,5,
      $2E,$47,$53,$81,$53,$81, $01,$03,$05,$06,$05,$06, 1,-1153,3, $709F)));
    FViruses^.Insert(New(PLoveVirus, Init(
      '707 Zamorochka', True, $B7,$3A,$74,$EA,$74,$EA, $01,$03,$05,$08,$05,$08,
      $EB,$06,$54,$75,$72,$6D,
      $EB,$E8,$00,$5F,$00,$5F, $00,$03,$04,$06,$04,$06, 1,-226,5, $103)));
    FViruses^.Insert(New(PAidsKillVirus, Init(
      'AIDS Killer 1.0 (AntiLoz)', True, $80,$F9,$01,$75,$01,$75, $00,$01,$02,$03,$02,$03,
      $EB,$E7,$54,$75,$72,$6D,
      $2E,$8A,$44,$FC,$44,$FC, $10,$11,$12,$13,$12,$13, 1,$00,4)));
    FViruses^.Insert(New(PAidsKillVirus, Init(
      'AIDS Killer 1.1 (AntiLoz)', True, $90,$4B,$3D,$00,$3D,$00, $00,$03,$06,$07,$06,$07,
      $E9,$8E,$02,$54,$75,$6D,
      $2E,$8A,$44,$FC,$44,$FC, $10,$11,$12,$13,$12,$13, 1,$00,4)));
    FViruses^.Insert(New(PLetterVirus, Init(
      'Letter Fall 1701/1704', True, $80,$FC,$4B,$10,$4B,$10, $00,$01,$02,$04,$02,$04,
      $2E,$FF,$2E,$37,$01,$54,
      $BC,$34,$06,$31,$06,$31, $17,$1B,$19,$1A,$19,$1A, 1,$00,3)));
    FViruses^.Insert(New(P512Virus, Init(
      '512 (666 Virus)', True, $06,$3F,$74,$B0,$74,$B0, $00,$08,$09,$0A,$09,$0A,
      $2E,$FF,$2E,$04,$00,$54,
      $FF,$01,$F3,$A6,$F3,$A6, $2A,$2B,$2C,$2D,$2C,$2D)));
    FViruses^.Insert(New(P512Virus, Init(
      '512 A (666 Virus)', True, $06,$3F,$74,$B0,$74,$B0, $00,$08,$09,$0A,$09,$0A,
      $2E,$FF,$2E,$04,$00,$54,
      $00,$01,$F3,$A7,$F3,$A7, $35,$36,$37,$38,$37,$38)));
    FViruses^.Insert(New(P512Virus, Init(
      '512 B (666 Virus)', True, $55,$BF,$17,$01,$17,$01, $00,$0A,$0B,$0C,$0B,$0C,
      $2E,$FF,$2E,$04,$00,$54,
      $00,$01,$F3,$A7,$F3,$A7, $35,$36,$37,$38,$37,$38)));
    FViruses^.Insert(New(P512Virus, Init(
      '512 C (666 Virus)', True, $55,$BF,$17,$01,$17,$01, $00,$0A,$0B,$0C,$0B,$0C,
      $2E,$FF,$2E,$04,$00,$54,
      $54,$08,$13,$CD,$13,$CD, $08,$09,$0B,$0C,$0B,$0C)));
    FViruses^.Insert(New(P512Virus, Init(
      '512 D (666 Virus)', True, $55,$BF,$17,$01,$17,$01, $00,$0A,$0B,$0C,$0B,$0C,
      $2E,$FF,$2E,$04,$00,$54,
      $54,$08,$13,$CD,$13,$CD, $06,$07,$09,$0A,$09,$0A)));
    FViruses^.Insert(New(P512Virus, Init(
      '512 E (666 Virus)', True, $3F,$80,$FC,$3E,$FC,$3E, $02,$0D,$0E,$0F,$0E,$0F,
      $2E,$FF,$2E,$04,$00,$54,
      $54,$08,$13,$CD,$13,$CD, $0C,$0D,$0F,$10,$0F,$10)));
    FViruses^.Insert(New(P512Virus, Init(
      '512 F (666 Virus)', True, $3F,$80,$FC,$3E,$FC,$3E, $02,$0D,$0E,$0F,$0E,$0F,
      $2E,$FF,$2E,$04,$00,$54,
      $00,$01,$F3,$A7,$F3,$A7, $35,$36,$37,$38,$37,$38)));
    FViruses^.Insert(New(PHrenVirus, Init(
      'ХРЕН - 5 RCE4928', True, $F3,$C1,$28,$80,$28,$80, $02,$03,$05,$06,$05,$06,
      $2E,$FF,$2E,$2F,$00,$54,
      $E8,$5B,$86,$50,$86,$50, $00,$03,$06,$08,$06,$08)));
    FViruses^.Insert(New(PBCVVirus, Init(
      'BCV RCE5287', True, $50,$53,$EC,$14,$EC,$14, $00,$01,$0C,$0D,$0C,$0D,
      $E9,$69,$F6,$54,$54,$54,
      $89,$8C,$F4,$55,$F4,$55, $01,$06,$08,$09,$08,$09)));
    FViruses^.Insert(New(PHercenVirus, Init(
      'Hercen RBSE1024', True,
      $FA,$56,$3D,$00,$00,$00, $00,$01,$0A,$0B,$0B,$0B, $E9,$E0,$01,$54,$54,$54,
      $0E,$C0,$6C,$04,$04,$04, $02,$05,$0A,$0B,$0B,$0B)));
    FViruses^.Insert(New(PAtas2Virus, Init(
      'Atas2 C384', False,
      $00,$01,$02,$03,$04,$05, $01,$01,$01,$01,$01,$01, $54,$75,$72,$6D,$69,$79,
      $B9,$06,$00,$8D,$B6,$87, $08,$09,$0A,$0B,$0C,$0D, 2,-125,6)));
    FViruses^.Insert(New(PLoveVirus, Init(
      'Atas3 RC3451', True,
      $FB,$CD,$AB,$CF,$DC,$E6, $01,$03,$04,$0B,$09,-2995, $2E,$FF,$2E,$6C,$06,$54,
      $1C,$E2,$E6,$EB,$30,$E2, $04,$11,$09,$13,$24,$27,
      2,$BC2,6,$104)));
    FViruses^.Insert(New(PLoveVirus, Init(
      'Atas4 RC3378', True,
      $FB,$CD,$AB,$CF,$DC,$8E, $01,$03,$04,$0B,$09,-2995, $E9,$C1,$FB,$54,$75,$72,
      $1C,$E2,$8E,$EB,$30,$E2, $04,$11,$09,$13,$24,$27, 2,$b6a,6,$104)));
    FViruses^.Insert(New(PLoveVirus, Init(
      'Atas5 RC3345', True,
      $FB,$CD,$AB,$CF,$DC,$7C, $01,$03,$04,$0B,$09,-2995, $E9,$02,$01,$54,$75,$72,
      $1C,$E2,$7C,$EB,$30,$E2, $04,$11,$09,$13,$24,$27, 2,$b58,6,$104)));
    FViruses^.Insert(New(PLoveVirus, Init(
      'C400', False,
      $00,$01,$02,$03,$04,$05, $01,$01,$01,$01,$01,$01, $54,$75,$72,$6D,$69,$79,
      $0B,$E8,$5C,$0B,$8B,$F3, $01,$03,$04,$09,$0B,$0C, 1,$90,8,-3)));

{   *********************** Invalid data for virus************************
    FViruses^.Insert(New(PPhoenixVirus, Init(
      'Phoenix RC1704', False,
      $00,$01,$02,$03,$04,$05, $01,$01,$01,$01,$01,$01, $54,$75,$72,$6D,$69,$79,
      $BF,$8B,$33,$C9,$C9,$C9, $01,$07,$09,$0A,$0A,$0A)));
}
    FViruses^.Insert(New(PMurphyVirus, Init(
      'Murphy', True,
      $E8,$80,$FC,$74,$74,$74, $00,$11,$12,$14,$14,$14, $2E,$FF,$2E,$29,$01,$54,
      $1E,$4B,$E9,$01,$01,$01, $00,$06,$0B,$0D,$0D,$0D, 1,3,3)));
    FViruses^.Insert(New(PYankeeSVirus, Init(
      'Yankee Shot E1961', True,
      $65,$00,$E8,$03,$03,$03, $03,$04,$0C,$0D,$0D,$0D, $2E,$FF,$2E,$B9,$01,$54,
      $5B,$53,$FB,$C3,$C3,$C3, $01,$02,$03,$04,$04,$04)));
    FViruses^.Insert(New(PFlipVirus, Init(
      'Flip RCE2343', True,
      $75,$0A,$C0,$24,$24,$24, $04,$06,$07,$09,$09,$09, $2E,$FF,$2E,$DF,$00,$54,
      $0E,$BB,$1F,$B9,$B2,$EB, $00,$01,$04,$05,$08,$0E)));
    FViruses^.Insert(New(PCrazyVirus, Init(
      'Crazy Imp RCE1445', True,
      $80,$3E,$75,$2F,$2F,$2F, $01,$02,$06,$07,$07,$07, $2E,$FF,$2E,$DA,$06,$54,
      $0E,$E8,$27,$27,$27,$27, $00,$01,$05,$06,$06,$06)));
    FViruses^.Insert(New(P763Virus, Init(
      'RC763', True,
      $FC,$3D,$74,$05,$05,$05, $01,$02,$03,$04,$04,$04, $EB,$0B,$54,$54,$54,$54,
      $BB,$FF,$FF,$E3,$E3,$E3, $00,$03,$03,$04,$04,$04)));
    FViruses^.Insert(New(PVinyVirus, Init(
      'Viny RCE1620', True,
      $F4,$38,$FC,$29,$EA,$80, $01,$02,$04,$05,$07,$08, $2E,$FF,$2E,$2C,$06,$54,
      $B9,$2E,$80,$34,$E2,$F9, $03,$06,$07,$08,$0B,$0C)));
{
    FViruses^.Insert(New(PFedaVirus, Init(
      'Feda COM RCE2370', True,
      $3D,$DA,$FE,$0A,$0A,$0A, $01,$02,$03,$05,$05,$05, $EB,$6F,$90,$90,$90,$90,
      $EE,$67,$01,$E8,$E8,$E8, $05,$06,$07,$08,$08,$08)));
}
{$IFDEF DEBUG}
    WriteLn(' File viruses initialized OK');
{$ENDIF}

    DirectVideo := False;
    Titul;
    if Help then RunHelp; {если без параметров или с ключом /h}

    { Немного расслабимся, расскажем о днях рождения }
    if (Hacker_Flag) and (BirthDays <> nil) then
    begin
       GetDate(DateYear, DateMonth, DateDay, DateWeek);
       for J := 0 to Birthdays^.Count-1 do
       begin
         PBDay := BirthDays^.At(J);
         if (DateMonth = Word(PBDay^.Month)+1) and (DateDay  = PBDay^.Day) then
         begin
           Dec(DateYear, PBDay^.Year);
           WriteLn;
           WriteLn(' Поздравьте меня, у меня сегодня праздник !!!');
           WriteLn(' Одному из моих авторов исполнилось ', DateYear: 2,  ' лет');
         end;
       end;
    end;

    If Test8086 = 0 then
      WriteLn(#13#10'Ой йой, никак виртуальная машина. Ну ты даешь !!!'#13#10,
              'Lecar - и на виртуальной машине, ну ну, посмотрим...');
    If DesqView.Present then
    begin
      If Test8086 < 3 then DirectVideo := False;
      If StrongMan then WriteLn(#13#10^G'Ключ /b не имеет эффекта');
      TestServers := True;
      StrongMan := False;
    end
    else DirectVideo := True;
    If Windows.Present then
      If Windows.Enhanced then
      begin
        DirectVideo := True;
        If StrongMan then WriteLn(#13#10^G'Ключ /b не имеет эффекта');
        StrongMan := False;
        TestServers := True;
      end;
  end;

procedure TLecar.Run;
  Var
    I, Result : Byte;
    LecarRes  : TResourceFile;
    S         : PBufStream;
    Dev       : TDevice;
    TempoFlag : Boolean;
    SRec      : SearchRec;
  begin
    if TestMemoryOnViruses(DViruses) Or TestMemoryOnViruses(FViruses) then
    begin
      TempoFlag := Fag;     { Запомним состияние ключа }
      Fag := True;          {Если на дали /f, а лечиться надо}
      FName := ParamStr(0);
      FindFirst(FName, $3F, SRec);
      I := 0;
      While (I <= 21) and TestFile(@SRec) do Inc(I);
      FName := GetEnv('COMSPEC');
      FindFirst(FName, $3F, SRec);
      if DosError = 0 then
      begin
        I := 0;
        While (I <= 21) and TestFile(@SRec) do Inc(I);
      end
      else WriteLn( ' не могу найти COMMAND.COM по COMSPEC' ); { спрятали}
      Write(#13);
      ClrEol;
      Fag := TempoFlag;
    end;
    {$IFNDEF DEBUG}
    SelfTest;
    {$ENDIF}
    If VirusInfo then
    begin
      S := New(PBufStream, Init('LECAR.RES', stCreate, 1024));
      LecarRes.Init(S);
      if Message <> nil then LecarRes.Put(Message, 'ERRORS');
      if BirthDays <> nil then LecarRes.Put(BirthDays, 'BIRTHDAYS');
      if GoodPrograms <> nil then LecarRes.Put(GoodPrograms, 'GOODPROG');
      if Archivers <> nil then LecarRes.Put(Archivers, 'ARCHIVER');
      LecarRes.Done;
      PrintDiskInfo(DViruses);
      PrintFileInfo(FViruses);
      Halt($FD);
    end;
    Repeat
      Result := TestPartition($80);
    Until NOT (Fag And (Result = $FE)) ;
    Repeat
      Result := TestPartition($81);
    Until NOT (Fag And (Result = $FE)) ;
    If NOT AllDrive then begin
      Testing; { Шуршим по заданному диску и директории }
      Halt($FE);
    end;
    { Если дали * для поиска по всем дискам }
    For I := 2 to Byte('Z')-Byte('A') do
    begin
      CurrentDrive := I;
      if ExistDrive(CurrentDrive) then
      begin { существует ли такой диск }
        CurrDir := Concat(Char($41+CurrentDrive), ':\');
        InOutRes := 0;
        Testing; { проверяем }
        Inc(GlobalTotalFiles, TotalFiles);
        Inc(GlobalTotalInfected, TotalInfected);
        TotalFiles := 0; { сбрасываем статистику }
        TotalInfected := 0;
       end;
    end;
    WriteLn;
    WriteLn('Итого проверено файлов: ', GlobalTotalFiles);
    WriteLn('Итого заражено  файлов: ', GlobalTotalInfected);
  end;

procedure TLecar.SelfTest;
var
  F : File;
  I : Integer;
begin
  Assign(F, ParamStr(0));
  Reset(F, 1);
  if IOResult <> 0 then;
  BlockRead(F, Buff, 136);
  if IOResult <> 0 then;
  EntPoint := A20(PWord(@Buff[$16])^, PWord(@Buff[$14])^)+Longint(PWord(@Buff[$08])^) Shl 4;
  Seek(F, EntPoint ); { пойдем по точке входа }
  BlockRead(F,Buff, 136);
  if IOResult <> 0 then;
  Close(F);
  if IOResult <> 0 then;
  if(Buff[00] <> $B8) OR(Buff[03] <> $BA) OR
    (Buff[06] <> $05) OR(Buff[09] <> $3B) then
  begin
    WriteLn;
    WriteLn(' Апчхи, аааапчхи, я инфицирован неизвестным мне вирусом');
    WriteLn(' сообщите родителям по тел. (044) 449-97-67');
    I:=0;
    while I < 20 do
    begin
      Sound(600);
      Delay(35);
      Sound(1000);
      Delay(35);
      Inc(I);
    end;
    NoSound;
    Halt($11);
  end;
end;

procedure TLecar.PrintDiskInfo(P : PCollection);
  var
    I  : Integer;
    J  : Word;
    P1 : PDiskVirus;
    S  : String;
  begin
    P1 := NIL;
    DirectVideo := False;
    PrintStr(#13#10'  Информация о дисковых вирусах'#13#10);
    PrintStr('----------------------------------'#13#10);

    PrintStr('┌─┬─────┬──────────────────────┬──────────────────────────────'+
             '┬─────────────────────────────────────────────────┐'#13#10);

    PrintStr('│ │     │                      │           Память             '+
             '│                     Диск                        │'#13#10);

    PrintStr('│N│ Рези│        Имя           ├────────┬────────┬────────────'+
             '┼────────────────────────┬────────────────────────┤'#13#10);

    PrintStr('│ │ дент│                      │ маска  │смещения│дезактивация'+
             '│        маска           │        смещения        │'#13#10);

    PrintStr('└─┴─────┴──────────────────────┴────────┴────────┴────────────'+
             '┴────────────────────────┴────────────────────────┘'#13#10);

    For I := 0 to P^.Count-1 do
    begin
      P1 := P^.At(I);
      Str(I+1:3, S);
      PrintStr(S+' ');
      P1^.PrintInfo;

      PrintStr(' ');
      For J := 0 to 5 do PrintStr(HexWord(P1^.Mask[J]));
      PrintStr(' ');
      For J := 0 to 5 do PrintStr(HexWord(P1^.DOffs[J]));
      PrintStr(' ');

      PrintStr(#13#10);
    end;
  end;

procedure TLecar.PrintFileInfo(P : PCollection);
  var
    I : Integer;
    P1 : PFileVirus;
    S  : String;
  begin
    DirectVideo := False;
    PrintStr(#13#10'Информация о файловых вирусах'#13#10);
    PrintStr('┌─┬─────┬──────────────────────┬──────────────────────────────'+
             '┬─────────────────────────┬──────────────────┐'#13#10);
    PrintStr('│ │     │                      │           Память             '+
             '│         Файл            │     Лечение      │'#13#10);
    PrintStr('│N│ Рези│        Имя           ├────────┬────────┬────────────'+
             '┼────────┬────────────────┤  дополнительные  │'#13#10);
    PrintStr('│ │ дент│                      │ маска  │смещения│дезактивация'+
             '│ маска  │    смещения    │      данные      │'#13#10);
    PrintStr('└─┴─────┴──────────────────────┴────────┴────────┴────────────'+
             '┴────────┴────────────────┴──────────────────┘'#13#10);
    For I := 0 to P^.Count-1 do
    begin
      P1 := P^.At(I);
      Str(I+1:3, S);
      PrintStr(S+' ');
      P1^.PrintInfo;
      PrintStr(#13#10);
    end;
  end;

destructor TLecar.Done;
  var
    S : PStream;
    Res : TResourceFile;
    SaveX, SaveY : Byte;
    ScreenBuf : Array [0..1999] of Word;
    VideoPtr : Pointer;
  begin
    SetVector($21, Save21);
    SetVector($23, Save23);
    SetVector($13, Save13);
    UnLoad_Rus_Font;
    NoSound;
    if not Windows.Present then
    begin
      SaveX := WhereX;
      SaveY := WhereY;
      if LastMode = 7 then VideoPtr := Ptr($B000, $0000)
      else VideoPtr := Ptr($B800, $0000);
      Move(VideoPtr^, ScreenBuf, SizeOf(ScreenBuf));
      InOutRes := 0;
      {$IFDEF DEBUG}
      prgName:= 'picture.res';
      {$ENDIF}
      S:= New(PBufStream, Init(prgName, stOpenRead, 4096));
      InOutRes:=0;
      Res.Init(S);
      Picture := PPicture(Res.Get('PICTURE'));
      Res.Done;
    end;
    if Picture <> nil then
    begin
      Picture^.Done;
      TextMode(LastMode);
      Move(ScreenBuf, VideoPtr^, SizeOf(ScreenBuf));
      GotoXY(SaveX, SaveY);
    end;
    if Archivers <> nil then Dispose(Archivers, Done);
    If ErrorAddr <> nil then
    begin
      WriteLn;
      WriteLn('Лекарь утомился по адресу ', HexPtr(ErrorAddr));
{$IFDEF DEBUG}
      Exit;
{$ENDIF}
{$IFNDEF DEBUG}
      Halt($11);
{$ENDIF}
    end;
    If ExitCode <> $FF then Halt;
    { Нажали Ctrl-Break }
    WriteLn;
    WriteLn('* Надоело --- не пускай !!! *');
    Halt( $FE );
  end;

Var
  SaveExit : Pointer;
  Environment : TLecar;

procedure ExitHandler; far;
  begin
    ExitProc := SaveExit;
    Environment.Done;
  end;

Begin
  SaveExit := ExitProc;
  ExitProc := @ExitHandler;
  Environment.Init;
  Environment.Run;
End.