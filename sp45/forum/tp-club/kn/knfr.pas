{$M 5792,0,0 }

Uses Dos;
Var
  P, FileName1, FileName2, FileName3: String[12];
  I: Integer;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  S: PathStr;
  R      : Registers;
  NumOfDr: Byte;

Procedure ExeFind(FileName: String);
Var
  Command,Mdir:String;
Begin
  FSplit(FileName, D, N, E);
  if Length(D) <> 3 then
    D := Copy(D,1,Length(D)-1);
  WriteLn('=> ',FileName);
  Command := '';
  for I := 2 to ParamCount do
    Command:= Command + ' ' + ParamStr(I);
  GetDir(0,Mdir);
  ChDir(D);
  SwapVectors;
  Exec(FileName,Command);
  WriteLn('=> Exec Successful. ','Child Process Exit Code #',DosExitCode);
  SwapVectors;
  ChDir(Mdir);
  Halt;
End;

Procedure FindDir(Path: PathStr);
var
  F: SearchRec;
begin
  FindFirst(Path + '\*.*', ReadOnly+Hidden+SysFile+Directory+Archive+AnyFile, F);
  while DosError = 0 do begin
    if (F.attr = 16) and (F.Name <> '.') and (F.Name <> '..') then begin
      FindDir(Path + '\' + F.Name);
    end;
    If (F.Name = FileName1) or (F.Name = FileName2) or (F.Name = FileName3) then
      ExeFind(Path + '\' + F.Name);
    FindNext(F);
  end;
end;

Procedure ReadCommand;
begin
  P := ParamStr(1);
  if ParamStr(1) = '' then begin
    WriteLn('File Run, The KN Programs, Copyright (C) May 1992, Nikita E.Korzun (KN)');
  WriteLn('            Version 3.0, Last Edition 05/05/92');
    WriteLn;
    Writeln('Usage: KNFR.EXE ExeTableFileName');
    Halt;
  End;
  For i := 1 to Length(P) do
    P[i] := UpCase(P[i]);
  FSplit(P, D, N, E);
  If ((E<>'.COM') And (E<>'.EXE') And (E<>'.BAT') And (E<>'')) then Begin
    WriteLn('Can''t Run ''',P,'''');
    Halt;
  End;
  if E = '' then begin
    FileName1 := P + '.COM';
    FileName2 := P + '.EXE';
    FileName3 := P + '.BAT';
  End
  Else
    FileName1 := P;
End;

Begin
  ReadCommand;
  S := FSearch(FileName1,GetEnv('PATH'));
  if S <> '' then
    ExeFind(FExpand(S));
  S := FSearch(FileName2,GetEnv('PATH'));
  if S <> '' then
    ExeFind(FExpand(S));
  S := FSearch(FileName3,GetEnv('PATH'));
  if S <> '' then
    ExeFind(FExpand(S));
  R.Ah := $0E;                                   { Установить текущий диск }
  R.Dl := 100;                                   { Берем несущ. диск и идем }
  Intr($21,R);
  NumOfDr := R.Al;                               { В AL сидит число дисков }
  For I:= 2 To NumOfDr-1 Do Begin                { Начиная с C: - все }
    FindDir(Chr(65+I) + ':');
  End;
  Writeln('File ''', P,''' not Found');
End.
