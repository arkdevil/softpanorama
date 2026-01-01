
{***************************************************}
{                                                   }
{        L e c a r                                  }
{   Turbo Pascal 6.X,7.X                            }
{   Попросту, без чинов и Copyright-ов  1991,92,93  }
{   Версия 2.0 от ...... (нужное дописать)          }
{***************************************************}

{$A+,B-,D+,E-,F-,I-,L+,N-,O-,R-,S+,V+,X+,G-}
{$M 16384,0,655360}

unit Vir1;

interface

uses
  ErrHand,
  Common;

type

  P648Virus = ^T648Virus;
  T648Virus = object(TFileVirus)
    constructor Init(N : String; R : Boolean;
                     M0, M1, M2, M3, M4, M5 : Byte;
                     O0, O1, O2, O3, O4, O5 : Integer; {Byte}
                     MK0, MK1, MK2, MK3, MK4, MK5 : Byte;
                     F0, F1, F2, F3, F4, F5 : Byte;
                     FO0, FO1, FO2, FO3, FO4, FO5 : Integer;
                     OJ : Byte; O : Integer; C : Byte);
    procedure Kill(var F : File); Virtual;
    procedure Action(var F : File); Virtual;
    procedure PrintInfo; Virtual;
  end;
  PLoveVirus = ^TLoveVirus;
  TLoveVirus = object(T648Virus)
    Backer : Integer;
    constructor Init(N : String; R : Boolean;
                     M0, M1, M2, M3, M4, M5 : Byte;
                     O0, O1, O2, O3, O4, O5 : Integer; {Byte}
                     MK0, MK1, MK2, MK3, MK4, MK5 : Byte;
                     F0, F1, F2, F3, F4, F5 : Byte;
                     FO0, FO1, FO2, FO3, FO4, FO5 : Integer;
                     OJ : Byte; O : Integer; C : Byte;
                     Back : Integer);
    procedure Action(var F : File); Virtual;
    procedure PrintInfo; Virtual;
  end;
  PAidsKillVirus = ^TAidsKillVirus;
  TAidsKillVirus = object(T648Virus)
    procedure Action(var F : File); Virtual;
  end;
  PLetterVirus = ^TLetterVirus;
  TLetterVirus = object(T648Virus)
    procedure Action(var F : File); Virtual;
  end;
  PAtas2Virus = ^TAtas2Virus;
  TAtas2Virus = object(T648Virus)
    procedure Action(var F : File); Virtual;
  end;
  PMurphyVirus = ^TMurphyVirus;
  TMurphyVirus = object(T648Virus)
    procedure Kill(var F : File); Virtual;
  end;
  PYankeeSVirus = ^TYankeeSVirus;
  TYankeeSVirus = object(TFileVirus)
    procedure Kill(var F : File); Virtual;
  end;
  PFlipVirus = ^TFlipVirus;
  TFlipVirus = object(TFileVirus)
    procedure Kill(var F : File); Virtual;
  end;
  PCrazyVirus = ^TCrazyVirus;
  TCrazyVirus = object(TFileVirus)
    procedure Kill(var F : File); Virtual;
  end;
  P763Virus = ^T763Virus;
  T763Virus = object(TFileVirus)
    procedure Kill(var F : File); Virtual;
  end;
  PFedaVirus = ^TFedaVirus;
  TFedaVirus = object(TFileVirus)
    procedure Kill(var F : File); Virtual;
  end;
  PVinyVirus = ^TVinyVirus;
  TVinyVirus = object(TFileVirus)
    function TestFile(var F : File; T : TCarier): Boolean; Virtual;
    procedure Kill(var F : File); Virtual;
  end;
  PMaryVirus = ^TMaryVirus;
  TMaryVirus = object(T648Virus)
    procedure Action(var F : File); Virtual;
  end;

implementation

constructor T648Virus.Init(N : String; R : Boolean;
                      M0, M1, M2, M3, M4, M5 : Byte;
                      O0, O1, O2, O3, O4, O5 : Integer; {Byte}
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
                     O0, O1, O2, O3, O4, O5 : Integer; {Byte}
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


procedure TAtas2Virus.Action(var F : File);
var
  ii : byte;
begin
  { Расшифровка Atas2 }
  for ii:= 0 to 5 do
    Buff[ii] := Buff[ii] XOR ($D0+ii);
  EntPoint := EntPoint -$4-$100;
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

procedure TMurphyVirus.Kill(var F : File);
begin
  ErrorInfo := 0;
  Case Carier of
  COM : T648Virus.Kill(F);
  EXE : begin
    Seek(F, 0);
    ErrorInfo := ErrorInfo Or IOResult;
    BlockRead(F, Buff, 136, ByteRead);
    ErrorInfo := ErrorInfo Or IOResult;
    EntPoint := GetExeEntry;
    Seek(F, EntPoint + $1B);
    BlockRead(F, Buff[$0A*2], 4, ByteRead);
    ErrorInfo := ErrorInfo or IOResult;
    PWord(@Buff[$2*2])^ := Word(EntPoint shr 9);
    if (EntPoint mod 512) <> 0 then Inc(PWord(@Buff[$2*2])^);
    Seek(F, 0);
    BlockWrite(F, Buff, $1C);
    ErrorInfo := ErrorInfo Or IOResult;
    Seek(F, EntPoint);
  end;
  else Exit;
  End; { Case }
  Truncate(F);
  ErrorInfo := ErrorInfo Or IOResult;
end;

procedure TYankeeSVirus.Kill(var F : File);
begin
  ErrorInfo := 0;
  Case Carier of
  EXE : begin
    Seek(F, 0);
    ErrorInfo := ErrorInfo Or IOResult;
    BlockRead(F, Buff, 136, ByteRead);
    ErrorInfo := ErrorInfo Or IOResult;
    EntPoint := GetExeEntry;
    Seek(F, EntPoint + 1851);
    BlockRead(F, Buff[$0A*2], 4, ByteRead);
    ErrorInfo := ErrorInfo or IOResult;
    Seek(F, EntPoint+1855);
    BlockRead(F, Buff[$07*2], 2, ByteRead);
    ErrorInfo := ErrorInfo or IOResult;
    if EntPoint < Longint(PWord(@Buff[$2*2])^ shl 9) then Dec(PWord(@Buff[$2*2])^, 4);
    Seek(F, 0);
    BlockWrite(F, Buff, $1C);
    ErrorInfo := ErrorInfo or IOResult;
    Seek(F, EntPoint);
  end;
  else Exit;
  End; { Case }
  Truncate(F);
  ErrorInfo := ErrorInfo Or IOResult;
end;

procedure TFlipVirus.Kill(var F : File);
var
  K : Byte;
  I : Integer;
  Ofs1, Ofs2 : Word;
  _Buff : TBuff;
begin
  ErrorInfo := 0;
  Case Carier of
  COM : begin
    Seek(F, 1);
    BlockRead(F, Buff, 10, ByteRead); { 10 можно увеличить }
    ErrorInfo := ErrorInfo or IOResult;
    EntPoint := PWord(@Buff[0])^ + 3;
    Seek(F, EntPoint);
    BlockRead(F, Buff, $30, ByteRead);
    ErrorInfo := ErrorInfo or IOResult;
    K := Buff[$9];
    Ofs1 := PWord(@Buff[$02])^+PInt(@Buff[$15])^;
    Ofs2 := PWord(@Buff[$06])^+PInt(@Buff[$0C])^;
    Seek(F, EntPoint-$81C); { offset from EP to stored data COM of file}
    BlockRead(F, Buff, 3, ByteRead);
    ErrorInfo := ErrorInfo or IOResult;
    Buff[0] := Buff[0] + K;
    Buff[1] := Buff[1] + K;
    Buff[2] := Buff[2] + K;
    Seek(F, 0);
    BlockWrite(F, Buff, 3);
    ErrorInfo := ErrorInfo or IOResult;
    Seek(F, EntPoint-Ofs2);
  end;
  EXE : begin
    Seek(F, 0);
    ErrorInfo := ErrorInfo Or IOResult;
    BlockRead(F, Buff, 136, ByteRead);
    _Buff := Buff;
    ErrorInfo := ErrorInfo Or IOResult;
    EntPoint := GetExeEntry;
    Seek(F, EntPoint);
    BlockRead(F, Buff, $30, ByteRead);
    ErrorInfo := ErrorInfo or IOResult;
    K := Buff[$9];
    Ofs2 := PWord(@Buff[$06])^+PInt(@Buff[$0C])^;
    Seek(F, EntPoint-$819); { offset from EP to stored data of EXE file }
    BlockRead(F, Buff, $A, ByteRead);
    for I:=0 to $A do Inc(Buff[I], K);
    PWord(@_Buff[$A*2])^ := PWord(@Buff[0])^;
    PWord(@_Buff[$B*2])^ := PWord(@Buff[2])^;
    PWord(@_Buff[$7*2])^ := PWord(@Buff[4])^;
    Dec(PWord(@_Buff[$B*2])^, $10);
    Dec(PWord(@_Buff[$7*2])^, $10);
    PWord(@_Buff[$2*2])^ := Word((EntPoint-Ofs2) div 512)+1;
    PWord(@_Buff[$1*2])^ := Word((EntPoint-Ofs2) mod 512);
    Seek(F, 0);
    BlockWrite(F, _Buff, $1C, ByteRead);
    ErrorInfo := ErrorInfo or IOResult;
    Seek(F, EntPoint-Ofs2);
  end;
  else Exit;
  End; { Case }
  Truncate(F);
  ErrorInfo := ErrorInfo Or IOResult;
end;

procedure TCrazyVirus.Kill(var F : File);
begin
  ErrorInfo := 0;
  Seek(F, 7);
  BlockRead(F, Buff, 2, ByteRead);
  ErrorInfo := ErrorInfo Or IOResult;
  EntPoint := PWord(@Buff[0])^;
  Seek(F, EntPoint);
  BlockRead(F, Buff, $0B, ByteRead);
  ErrorInfo := ErrorInfo Or IOResult;
  Seek(F, 0);
  BlockWrite(F, Buff, $0B);
  ErrorInfo := ErrorInfo Or IOResult;
  Seek(F, EntPoint);
  Truncate(F);
  ErrorInfo := ErrorInfo or IOResult;
end;

procedure T763Virus.Kill(var F : File);
begin
  ErrorInfo := 0;
  Seek(F, 0);
  BlockRead(F, Buff, 10, ByteRead); { 10 можно увеличить }
  ErrorInfo := ErrorInfo or IOResult;
  EntPoint := PWord(@Buff[1])^-$100+$2D3;
  Seek(F, EntPoint);
  BlockRead(F, Buff, 5, ByteRead);
  ErrorInfo := ErrorInfo or IOResult;
  Seek(F, 0);
  BlockWrite(F, Buff, 5);
  ErrorInfo := ErrorInfo or IOResult;
  Seek(F, FileSize(F)-763);
  Truncate(F);
  ErrorInfo := ErrorInfo or IOResult;
end;

procedure TFedaVirus.Kill(var F : File);
begin
  ErrorInfo := 0;
  Case Carier of
  COM : begin
  end;
  EXE : begin
  end;
  else Exit;
  End; { Case }
  Truncate(F);
  ErrorInfo := ErrorInfo or IOResult;
end;

function TVinyVirus.TestFile(Var F : File; T : TCarier) : Boolean;
const
  TrashSize = $10;
var
  J       : Byte;
begin
  J := 0;
  if T = COM then
  begin
    TestFile:= False;
    repeat
      while (J < TrashSize) and (PWord(@Buff[J])^ <> $04B1) do Inc(J);
      if Buff[J+2] = $E8 then break else Inc(J);
    until J >= TrashSize;
    if J < TrashSize then
    begin
       Reset(F, 1);
       Seek(F, J+2+3+Longint(PWord(@Buff[J+3])^));
       ErrorInfo := ErrorInfo or IOResult;
       BlockRead(F, Buff, $100, ByteRead);
       ErrorInfo := ErrorInfo or IOResult;
       Close(F);
       ErrorInfo := ErrorInfo or IOResult;
       if ErrorInfo <> noError then Exit;
    end;
  end;
  TestFile:= inherited TestFile(F, T);
end;

procedure TVinyVirus.Kill(var F : File);
var
  K : Byte;
  I : Integer;
  Ofs1, Ofs2,Ofs3 : Word;
  Key        : LongInt;
  _Buff : TBuff;
begin
  ErrorInfo := 0;
  Case Carier of
  EXE : begin
    Seek(F, 0);
    ErrorInfo := ErrorInfo Or IOResult;
    BlockRead(F, Buff, 136, ByteRead);
    _Buff := Buff;
    ErrorInfo := ErrorInfo Or IOResult;
    EntPoint := GetExeEntry;
    Seek(F, EntPoint);
    BlockRead(F, Buff, $30, ByteRead);
    ErrorInfo := ErrorInfo or IOResult;
    K := Buff[$9];
    Seek(F, EntPoint+$63C);
    BlockRead(F, Buff, $1C, ByteRead);
    ErrorInfo := ErrorInfo or IOResult;
    for I := 0 to 28 do
      Buff[I] := Buff[I] xor K;
    Seek(F, EntPoint+$A1);
    BlockRead(F, _Buff, $20, ByteRead);
    ErrorInfo := ErrorInfo or IOResult;
    for I := 0 to 32 do
      _Buff[I] := _Buff[I] xor K;
    Buff[14] := _Buff[6];
    Buff[15] := _Buff[7];
    Buff[16] := _Buff[4];
    Buff[17] := _Buff[5];
    Buff[20] := _Buff[0];
    Buff[21] := _Buff[1];

    Key :=  LongInt(Word((Word(Buff[7]) Shl 8) + Buff[8])); {hdr[8]}
    Ofs1 := Word((Word(_Buff[3]) Shl 8) + _Buff[2]); {cs:[A3]}
    Ofs2 := Word(Ofs1 + Word (EntPoint Shr 4)) - Key;

    Buff[22] := Lo(Ofs2);
    Buff[23] := Hi(Ofs2);
    Ofs1 := EntPoint div 512;
    Ofs2 := EntPoint mod 512;
    if  Ofs2 <> 0 then Inc (Ofs1);
    Buff[2] := Lo (Ofs2);
    Buff[3] := Hi (Ofs2);
    Buff[4] := Lo (Ofs1);
    Buff[5] := Hi (Ofs1);
    Seek (F, $0);
    BlockWrite(F, Buff, $18, ByteRead);
    ErrorInfo := ErrorInfo or IOResult;
    Seek (F,EntPoint);
  end;
  COM : begin
    Seek(F, $0);
    BlockRead(F, Buff, 40, ByteRead); { 10 можно увеличить }
    ErrorInfo := ErrorInfo or IOResult;
    I := 0;
    while not ((Buff[I]=$B1) and (Buff[I+1]=$04) and (Buff[I+2]=$E8)) do Inc(I);
    EntPoint := PWord(@Buff[I+3])^ + 3 + I+2;
    Seek(F, EntPoint);
    BlockRead(F, Buff, $10, ByteRead);
    ErrorInfo := ErrorInfo or IOResult;
    K := Buff[$9];
    Seek(F, EntPoint+$63C);
    BlockRead(F, Buff, $18, ByteRead);
    ErrorInfo := ErrorInfo or IOResult;
    for I := 0 to 23 do
      Buff[I] := Buff[I] xor K;
    Seek (F, $0);
    BlockWrite(F, Buff, $18, ByteRead);
    ErrorInfo := ErrorInfo or IOResult;
    Seek (F,EntPoint);
  end;
  else Exit;
  End; { Case }
  Truncate(F);
  ErrorInfo := ErrorInfo Or IOResult;
end;

procedure TMaryVirus.Action(var F : File);
var
  I : Word;
begin
  I := (Buff[2] shl 8) or Buff[1];
  I := I + EntPoint + $11;
  Buff[1] := Lo(I);
  Buff[2] := Hi(I);
  EntPoint := EntPoint -500;
end;


end.