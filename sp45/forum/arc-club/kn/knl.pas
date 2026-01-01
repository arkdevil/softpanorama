{$M 4736,0,0}
Uses Dos;

Const
  Lzh_Dir = '            C:\LZH\';
  ArcExe  = 'LHA                ';
  Pru     = 'u -rxa             ';
  Prm     = 'm -rxa             ';

Var
  Cfg,
  Sear,
  LastDir,
  ArcName,
  Drive,
  Path,
  Str,
  Tmp_Str,
  Run_Str,
  Command,
  ParamS,
  Pr      : String;
  L,
  I       : Integer;

Function CheckFlag(S: String):Integer;  { На входе - имя директории, на }
Var                                     { выходе - имя Last SUB-DIR }
  i: Integer;                           { крутимся несколько раз }

Begin
  For i:= 1 To Length(S) Do Begin
    if S[i] = '\' Then Begin
      CheckFlag := i;
      Exit;
    End;
  End;
  CheckFlag := 0;
End;

Begin
  If ParamStr(1) = '-' Then Begin
    Pr := Prm;
    ParamS := ParamStr(2);
  End
  Else Begin
    Pr := Pru;
    ParamS := ParamStr(1);
  End;
  GetDir(0,LastDir);                            { Имя диска и директории }
  Drive:= Copy(LastDir,1,1);                    { Имя диска }
  Path := Copy(LastDir,3,Length(LastDir));      { Имя директории }
  If Path = '\' then Begin
    LastDir := 'Root_' + Drive;                 { Если корневая }
    Path:= '';
  End
  Else
    While CheckFlag(LastDir) <> 0 do
      LastDir:= Copy(LastDir,CheckFlag(LastDir)+1,Length(LastDir));

  If ParamS <> '' then
    If (Copy(ParamS,Length(ParamS),1) = ':')
    Or (Copy(ParamS,Length(ParamS),1) = '\') Then
      if ParamS = '\' Then
        ArcName := Lzh_Dir+LastDir
      Else
        ArcName := ParamS+LastDir
    Else
      ArcName := ParamS
  Else
    ArcName := LastDir;                         { Если параметров нет }
                                                { Last Dir }
  Cfg := FSearch('KNL.CFG',GetEnv('PATH'));
  If Cfg = '' then Begin                        { Если CFG нет }
    Command := ' /C ' + ArcExe + Pr + ' ' + ArcName;
  End
  Else Begin
    Command := '';
    Assign(Input,FExpand(Cfg));
    Reset(Input);
    ReadLn(Input,Str);
    Close(Input);
    L := Length(Str);
    For I:=1 To L do Begin
      If Copy(Str,I,2) = '!!' Then Begin
        Tmp_Str := '!';
        I := I + 1;
      End
      Else
      if Copy(Str,I,2) = '!:' Then
        Tmp_Str := Copy(Drive,1,1)
      Else
      if Copy(Str,I,2) = '!\' Then
        Tmp_Str := Path
      Else
      if Copy(Str,I,2) = '!#' Then Begin
        Tmp_Str := LastDir;
        I := I + 1;
      End
      Else
      if Copy(Str,I,2) = '!%' Then Begin
        Tmp_Str := ParamS;
        I := I + 1;
      End
      Else
      if Copy(Str,I,2) = '!@' Then Begin
        Tmp_Str := ArcName;
        I := I + 1;
      End
      Else
        Tmp_Str:=Copy(Str,I,1);
      Command := Command + Tmp_Str;
    End;
    Command := ' /C ' + Command;
  End;

  Run_Str := GetEnv('COMSPEC');
  Exec(Run_Str,Command);
  Halt(DosExitCode);
End.
