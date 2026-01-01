{$M 4848,0,0 }
Uses Dos;
Const
  ArcExe = '         LHA u -rxa ..\';

Var
  DrivePath,Drive,Path,Command,S,Str,Cfg,Tmp_Str,DrivePathT,Run_str: String;
  T,I,L: Integer;
  F: SearchRec;

Function CheckFlag(S: String):Integer;
Var
  i: Integer;
Begin
  For i:= 1 to length(S) Do Begin
    If S[i] = '\' Then Begin
      CheckFlag := i;
      Exit;
    End;
  End;
  CheckFlag := 0;
End;

Procedure Up(NameDir: String);
Begin
  {$I-}
    ChDir(NameDir);
  {$I+}
  if IOResult <> 0 Then begin
    WriteLn('No found: ',NameDir);
    Exit;
  End;
  Tmp_Str := '';
  if Str <> '' Then begin
    L := Length(Str);
    For I:=1 to L Do Begin
      if copy(Str,I,2) = '!:' Then
        Tmp_Str := Drive
      Else
      if copy(Str,I,2) = '!\' Then
        Tmp_Str := Path
      Else
      if copy(Str,I,2) = '!#' Then begin
        Tmp_Str := DrivePath;
        I := I + 1;
      End
      Else
        if copy(Str,I,2) = '!%' Then begin
        Tmp_Str := NameDir;
        I := I + 1;
      End
      Else
        Tmp_Str:=Copy(Str,I,1);
      Command := Command + Tmp_Str;
      End;
      Command := ' /C ' + Command;
    End
  Else begin
    Command := ' /C ' + ArcExe + NameDir;
  End;
  GetDir(0,DrivePathT);
  Exec(Run_str,Command);
  Command := '';
  ChDir('..');
End;

Begin
  GetDir(0,DrivePath);                          { А где мы }
  Drive := Copy(DrivePath,1,1);                 { Диск }
  Path  := Copy(DrivePath,3,Length(DrivePath)); { Директория }
  If Path = '\' Then begin
    DrivePath := 'Root_' + Drive;               { А если корень, то LastDir }
    Path:= '';
  End
  Else
    While CheckFlag(DrivePath) <> 0 do          { Last Directory }
      DrivePath:= Copy(DrivePath,CheckFlag(DrivePath)+1,Length(DrivePath));
  if(Copy(ParamStr(1),Length(ParamStr(1)),1) = ':') or
    (Copy(ParamStr(1),Length(ParamStr(1)),1) = '\') Then
      DrivePath := ParamStr(1)+DrivePath;
  Run_Str := GetEnv('COMSPEC');
  Str := '';
  Command := '';
  Cfg := FSearch('KNLD.CFG',GetEnv('PATH'));    { Ищем CONFIG }
  If Cfg <> '' Then begin
    Assign(Input,FExpand(Cfg));
    Reset(Input);
    ReadLn(Input,Str);
  End;
  if ParamCount = 0 Then Begin
    FindFirst('*.*', Directory+ReadOnly+AnyFile+Hidden+SysFile+Archive, F);
    While DosError = 0 do begin
      If (F.attr = 16) And (F.Name <> '.') And (F.Name <> '..') Then Begin
        Up(F.Name);
      End;
      FindNext(F);
    End;
  End
  Else
    For i:=1 to ParamCount do
      Up(ParamStr(I));
End.
