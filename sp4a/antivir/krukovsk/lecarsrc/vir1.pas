{************************************************}
{                                                }
{        L e c a r                               }
{   Turbo Pascal 6.X                             }
{   Попросту, без чинов и Copyright-ов  1992     }
{   Версия 2.0 от                                }
{************************************************}

{$A+,B-,D+,E-,F-,I-,L+,N-,O-,R+,S+,V+,X+,G-}
{$M 16384,0,655360}

Unit Vir1;

Interface

Uses
  ErrHand,
  Common;

Type

  P648Virus = ^T648Virus;
  T648Virus = Object(TFileVirus)
    constructor Init(N : String; R : Boolean;
                     M0, M1, M2, M3, M4, M5 : Byte;
                     O0, O1, O2, O3, O4, O5 : Byte;
                     MK0, MK1, MK2, MK3, MK4, MK5 : Byte;
                     F0, F1, F2, F3, F4, F5 : Byte;
                     FO0, FO1, FO2, FO3, FO4, FO5 : Integer;
                     OJ : Byte; O : Integer; C : Byte);
    procedure Kill(var F : File); Virtual;
    procedure Action(var F : File); Virtual;
    procedure PrintInfo; Virtual;
  End;
  PLoveVirus = ^TLoveVirus;
  TLoveVirus = Object(T648Virus)
    Backer : Integer;
    constructor Init(N : String; R : Boolean;
                     M0, M1, M2, M3, M4, M5 : Byte;
                     O0, O1, O2, O3, O4, O5 : Byte;
                     MK0, MK1, MK2, MK3, MK4, MK5 : Byte;
                     F0, F1, F2, F3, F4, F5 : Byte;
                     FO0, FO1, FO2, FO3, FO4, FO5 : Integer;
                     OJ : Byte; O : Integer; C : Byte;
                     Back : Integer);
    procedure Action(var F : File); Virtual;
    procedure PrintInfo; Virtual;
  End;
  PAidsKillVirus = ^TAidsKillVirus;
  TAidsKillVirus = Object(T648Virus)
    procedure Action(var F : File); Virtual;
  End;
  PLetterVirus = ^TLetterVirus;
  TLetterVirus = Object(T648Virus)
    procedure Action(var F : File); Virtual;
  End;

Implementation

constructor T648Virus.Init(N : String; R : Boolean;
                      M0, M1, M2, M3, M4, M5 : Byte;
                      O0, O1, O2, O3, O4, O5 : Byte;
                      MK0, MK1, MK2, MK3, MK4, MK5 : Byte;
                      F0, F1, F2, F3, F4, F5 : Byte;
                      FO0, FO1, FO2, FO3, FO4, FO5 : Integer;
                      OJ : Byte; O : Integer; C : Byte);
begin
  TFileVirus.Init(N,R,M0,M1,M2,M3,M4,M5,O0,O1,O2,O3,O4,O5,MK0,MK1,MK2,MK3,MK4,MK5,
                  F0,F1,F2,F3,F4,F5,FO0,FO1,FO2,FO3,FO4,FO5);
  OffsJmp := OJ;
  Offs := O;
  Count := C;
end;

procedure T648Virus.PrintInfo;
var
  I : Byte;
begin
  TFileVirus.PrintInfo;
  PrintStr(' '+HexByte(OffsJmp)+' '+HexWord(Word(Offs))+' '+HexByte(Count));
end;

procedure T648Virus.Kill(var F : File);
begin
  Seek(F, OffsJmp );
  BlockRead(F, Buff, 10, ByteRead); { 10 можно увеличить }
  ErrorInfo := ErrorInfo Or IOResult;
  EntPoint := PWord(@Buff[0])^ + 2 + Word(OffsJmp);
  Seek(F, EntPoint + Offs); {Сдвинемся на JMP}
  BlockRead( F, Buff, Count, ByteRead ); {и считаем исходные байты}
  ErrorInfo := ErrorInfo Or IOResult;
  Action(F);
  Seek(F, 0);
  BlockWrite(F, Buff, Count);
  ErrorInfo := ErrorInfo Or IOResult;
  Seek(F, EntPoint);
  Truncate(F);
  ErrorInfo := ErrorInfo Or IOResult;
end;

procedure T648Virus.Action(var F : File);
begin
end;

constructor TLoveVirus.Init(N : String; R : Boolean;
                     M0, M1, M2, M3, M4, M5 : Byte;
                     O0, O1, O2, O3, O4, O5 : Byte;
                     MK0, MK1, MK2, MK3, MK4, MK5 : Byte;
                     F0, F1, F2, F3, F4, F5 : Byte;
                     FO0, FO1, FO2, FO3, FO4, FO5 : Integer;
                     OJ : Byte; O : Integer; C : Byte;
                     Back : Integer);
begin
  T648Virus.Init(N,R,M0,M1,M2,M3,M4,M5,O0,O1,O2,O3,O4,O5,MK0,MK1,MK2,MK3,MK4,MK5,
                 F0,F1,F2,F3,F4,F5,FO0,FO1,FO2,FO3,FO4,FO5,OJ,O,C);
  Backer := Back;
end;

procedure TLoveVirus.PrintInfo;
var
  I : Byte;
begin
  T648Virus.PrintInfo;
  PrintStr(' '+HexWord(Backer));
end;

procedure TLoveVirus.Action(var F : File);
begin
  Dec(EntPoint, Backer);
end;

procedure TAidsKillVirus.Action(var F : File);
begin
  { Расшифровка AidsKiller }
  Seek(F, FilePos(F) - Longint(Count));
  BlockRead(F, Buff, 210, ByteRead);
  ErrorInfo := ErrorInfo Or IOResult;
  Buff[0] := Buff[$B7] XOR Buff[$B];
  Buff[1] := Buff[$BD] XOR Buff[$B];
  Buff[2] := Buff[$C3] XOR Buff[$B];
  Buff[3] := Buff[$C9] XOR Buff[$B];
end;

procedure TLetterVirus.Action(var F : File);
Var
  _SP, _SI, K : Word;
begin
  { Расшифровка Letter Fall }
  Seek(F, FilePos(F) - Count);
  BlockRead(F, Buff, 55, ByteRead);
  ErrorInfo := ErrorInfo Or IOResult;
  _SP := PWord(@Buff[$18])^;          { SP }
  _SI := EntPoint + $22 + $100;       { SI }
  for K := $22 to $30 do
  begin
    Buff[K] :=(Buff[K] XOR Lo(_SI)) XOR Lo(_SP);
    Buff[K+1] :=(Buff[K+1] XOR Hi(_SI)) XOR Hi(_SP);
    Inc(_SI);
    Dec(_SP);
  end;
  Buff[0] := Buff[$2D];
  Buff[1] := Buff[$2E];
  Buff[2] := Buff[$2F];
  Dec(EntPoint);
end;

End.