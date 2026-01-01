{$M 4032,0,0 }
{$I-}
Uses Dos;
Const
  Ext_Lzh = '.LZH';
  Ext_Ice = '.ICE';
  Ext_Pak = '.PAK';
  Ext_Arc = '.ARC';
  Ext_Zip = '.ZIP';
  Ext_Arj = '.ARJ';
  Ext_Hyp = '.HYP';
  Ext_Zoo = '.ZOO';
  Ext_Chz = '.CHZ';
  Exe_Lzh = 'LHA x -a                   ..\';
  Exe_Pak = 'PAK e                      ..\';
  Exe_Arc = 'PKXARC                     ..\';
  Exe_Zip = 'PKUNZIP -d                 ..\';
  Exe_Arj = 'ARJ x -i1                  ..\';
  Exe_Hyp = 'HYPER -x                   ..\';
  Exe_Zoo = 'ZOO x                      ..\';
  Exe_Chz = 'CHARC x                    ..\';

Var
  F      : SearchRec;
  Command: String;
  Ok,
  I      : integer;
  E      : ExtStr;

Procedure UpperCase(S : string);
Var
  i : Integer;
Begin
  For i := 1 To Length(E) do
    E[i] := UpCase(S[i]);
End;

Function CheckFile(FileName: String): Byte;
Var
  P: PathStr;
  D: DirStr;
  N: NameStr;
Begin
  Command := '';
  FSplit(FileName, D, N, E);
  UpperCase(E);
    If (E = Ext_Lzh) or (E = Ext_Ice) Then Begin
      Command := Exe_Lzh + FileName;
      CheckFile := 1;
      Exit;
    End;
    If E = Ext_Pak Then Begin
      Command := Exe_Pak + FileName;
      CheckFile := 1;
      Exit;
    End;
    If E = Ext_Arc Then Begin
      Command := Exe_Arc + FileName;
      CheckFile := 1;
      Exit;
    End;
    If E = Ext_Zip Then Begin
      Command := Exe_Zip + FileName;
      CheckFile := 1;
      Exit;
    End;
    If E = Ext_Arj Then Begin
      Command := Exe_Arj + FileName;
      CheckFile := 1;
      Exit;
    End;
    If E[2] = 'A' Then Begin
      If (Ord(E[3]) > 47) And
         (Ord(E[3]) < 58) And
         (Ord(E[4]) > 47) And
         (Ord(E[4]) < 58) Then Begin
           Command := Exe_Arj + FileName;
           CheckFile := 1;
           Exit;
      End;
    End;
    If E = Ext_Hyp Then Begin
      Command := Exe_Hyp + FileName;
      CheckFile := 1;
      Exit;
    End;
    If E = Ext_Zoo Then Begin
      Command := Exe_Zoo + FileName;
      CheckFile := 1;
      Exit;
    End;
    If E = Ext_Chz Then Begin
      Command := Exe_Chz + FileName;
      CheckFile := 1;
      Exit;
    End;
  CheckFile := 0;
End;

Procedure  UnPack(FileName: String);
Var
  Count:   integer;
  P:       PathStr;
  D:       DirStr;
  N:       NameStr;
  E:       ExtStr;
  DirInfo: SearchRec;

Begin
  if CheckFile(FileName) = 0 Then exit;
  FSplit(FileName, D, N, E);
  MkDir(N);
  ChDir(N);
  Exec(GetEnv('COMSPEC'),'/C '+Command);
  ChDir('..');
End;

Begin
  if ParamStr(1) <> '' Then
      For i := 1 to ParamCount do
        UnPack(ParamStr(i))
  Else Begin
    FindFirst('*.*', AnyFile, F);
    While DosError = 0 Do Begin
      UnPack(F.Name);
      FindNext(F);
    End;
  End;
End.
