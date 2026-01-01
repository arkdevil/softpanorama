Uses Dos;
Var
  Fn    : File;
  FTime : Longint;
  DT    : DateTime;

Function KNr(S : String; N : Byte) : String;
Const
  Z : String = '              ';
Var
  i  : Byte;
  ss : String;
Begin
  If Length(S) >= N then
    KNr := S
  Else
    KNr := S + Copy(Z,1,N-Length(S));
End;


Function Zero(w : Word) : String;
Var
  s : String;
Begin
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  Zero := s;
End;

Procedure FindDir(Path: PathStr);
Var
  F: SearchRec;
Begin
  FindFirst(Path, AnyFile, F);
  While DosError = 0 Do Begin
    UnpackTime(F.Time,DT);
    Writeln(KNr(F.Name,15),
            F.Attr : 4,
            F.Size : 10,
            DT.Day : 4,'.',
            Zero(DT.Month),'.',
            DT.Year,'  ',
            Zero(DT.Hour),':',
            Zero(DT.Min),'.',
            Zero(DT.Sec));
    FindNext(F);
  End;
End;

Begin
  WriteLn('List DIR, The KN Programs, Copyright (C) May 1992, Nikita E.Korzun (KN)');
  WriteLn('          Version 3.0, Last Edition 05/05/92');
  WriteLn;
  If ParamCount = 0 then
    FindDir('*.*')
  Else
    FindDir(ParamStr(1));
End.
