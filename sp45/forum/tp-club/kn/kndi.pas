Uses Dos;
Var
  Drive,
  NumOfDr    : Byte;
  St         : String;
  S1,S2,S3   : Longint;
  PR         : Integer;
  SH,SH1,SH2 : String[34];
  R          : Registers;

Begin
  WriteLn('Disk Info, The KN Programs, Copyright (C) May 1992, Nikita E.Korzun (KN)');
  WriteLn('           Version 3.0, Last Edition 05/05/92');
  WriteLn;
  R.Ah := $0E;                                   { Установить текущий диск }
  R.Dl := 100;                                   { Берем несущ. диск и идем }
  Intr($21,R);
  NumOfDr := R.Al;                               { В AL сидит число дисков }
  Sh1 := '████████████████████████████████████████';
  Sh2 := '▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒';
  WriteLn('╔════╤═══════════╤═══════════╤═══════════╤════════════════════════════════════╗');
  WriteLn('║ Dr │      SIze │      Free │      Used │ Percent                            ║');
  WriteLn('╠════╪═══════════╪═══════════╪═══════════╪════════════════════════════════════╣');
  For Drive := 3 to NumOfDr Do Begin
    S1 := DiskSize(Drive);
    If S1 <> -1 Then Begin
      S2 := DiskFree(Drive);
      S3 := DiskSize(Drive)-DiskFree(Drive);
      Pr := Trunc(100*(S3/S1));
      Sh := Copy(Sh1,1,Trunc((S3/S1)*Length(Sh1))) +
            Copy(Sh2,Trunc((S3/S1)*Length(Sh2)),Length(Sh1));
      WriteLn('║ ',Chr(64+Drive),': │',S1:10,' │',S2:10,' │',S3:10,' │ ',Sh,' ║');
    End;
  End;
  WriteLn('╚════╧═══════════╧═══════════╧═══════════╧════════════════════════════════════╝');
End.
