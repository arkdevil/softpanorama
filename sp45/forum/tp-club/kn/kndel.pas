{$I-}
Uses Dos;

Const
  Mess = 'Нет, ребята, пулемета я не дам - запускать в корне C: - здоровье портить...';
Var
  I  : Byte;
  S,
  Dr : String;

Procedure TrahDir(DirName : String);
Var
  FN : File;
Begin
  RmDir(DirName);
  If IOResult > 0 then Begin
    Assign(FN, DirName);
    SetFAttr(FN,$10);
    RmDir(DirName);
  End;
End;

Procedure FileFind(Path: PathStr);
Var
  F   : SearchRec;
  Fil : File;
Begin
  FindFirst(Path + '\*.*', AnyFile, F);
  While DosError = 0 Do Begin
    If (F.Name <> '.') And (F.Name <> '..') Then Begin
      If (F.Attr and Directory <> 0) Then Begin
        FileFind(Path + '\' + F.Name);
        TrahDir(Path + '\' + F.Name);
      End
      Else Begin
        Assign(Fil, Path + '\' + F.Name);
        Erase(Fil);
        If IOResult = 5 then Begin
          SetFAttr(Fil,$20);
          Erase(Fil);
        End;
      End;
    End;
    FindNext(F);
  End;
End;

Begin
  If ParamCount > 0 then
    For I := 1 to ParamCount do Begin
      FileFind(ParamStr(i));
      TrahDir(ParamStr(i));
    End
  Else Begin
    GetDir(0,Dr);
    If Dr = 'C:\' then
      WriteLn(Mess)
    Else begin
      FileFind('.');
      ChDir('..');
      TrahDir(Dr);
    End
  End
End.
