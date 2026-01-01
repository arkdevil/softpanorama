{************************************************}
{                                                }
{        L e c a r                               }
{   Turbo Pascal 6.X                             }
{   Попросту, без чинов и Copyright-ов  1992     }
{   Версия 2.0 от                                }
{************************************************}

{$A+,B-,D+,E-,F-,I+,L+,N-,O-,R+,S+,V+,X+,G-}
{$M 16384,0,655360}

Unit Vir2;

Interface

Uses
  ErrHand,
  Common;

Type

  P512Virus = ^T512Virus;
  T512Virus = Object(TFileVirus)
    procedure Kill(var F : File); Virtual;
  End;
  PHrenVirus = ^THrenVirus;
  THrenVirus = Object(TFileVirus)
    procedure Kill(var F : File); Virtual;
  End;
  PBCVVirus = ^TBCVVirus;
  TBCVVirus = Object(TFileVirus)
    procedure Kill(var F : File); Virtual;
  End;

Implementation

procedure T512Virus.Kill(var F : File);
Var
  Tmp : Longint;
begin
  ErrorInfo := 0;
  If (Carier = COM) OR (Carier = EXE) then
  begin
    Tmp := FileSize(F);
    Seek(F, 0);
    Seek(F, Tmp + 512);
    Truncate(F);
    ErrorInfo := ErrorInfo Or IOResult;
    Seek(F, 0);
    Seek(F, Tmp);
    BlockRead(F, Buff, 512, ByteRead);
    ErrorInfo := ErrorInfo Or IOResult;
    Seek(F, 0);
    BlockWrite(F, Buff, 512);
    ErrorInfo := ErrorInfo Or IOResult;
    Seek(F, Tmp);
    Truncate(F);
  end
  else Exit;
end;

procedure THrenVirus.Kill(var F : File);
Var
  WBuff   : Array [0..$100-1] of Word;
  EnPoint : Longint;
  I       : Byte;
begin
  ErrorInfo := 0;
  Case Carier of
  COM : begin
    Seek(F, 1);
    BlockRead(F, Buff, 10, ByteRead); { 10 можно увеличить }
    ErrorInfo := ErrorInfo Or IOResult;
    EntPoint := (Longint(Buff[1]) Shl 8) + Buff[0]+2+1-$974;
    Seek(F, EntPoint);         { Сдвинемся на начало данных }
    BlockRead(F, WBuff, 30, ByteRead); { и считаем исходные байты }
    ErrorInfo := ErrorInfo Or IOResult;
    WBuff[14] := WBuff[14] XOR $9590; { ХР }
    For I:=0 to 11 do WBuff[I] := WBuff[I] XOR WBuff[14];
    WBuff[0] := WBuff[0] XOR WBuff[12];
    Seek(F, 0);
    BlockWrite(F, WBuff, $18);
    ErrorInfo := ErrorInfo Or IOResult;
    Dec(EntPoint, $13);
    Seek(F, EntPoint+$10);
  end;
  EXE : begin
    Seek(F, 0);
    ErrorInfo := ErrorInfo Or IOResult;
    BlockRead(F, Buff, 136, ByteRead);
    ErrorInfo := ErrorInfo Or IOResult;
    EntPoint := GetExeEntry;
    Seek(F, EntPoint-$974); { Сдвинемся на начало данных }
    BlockRead(F, WBuff, 30, ByteRead); { и считаем исходные байты }
    ErrorInfo := ErrorInfo Or IOResult;
    WBuff[14] := WBuff[14] XOR $9590; { ХР }
    For I:=0 to 11 do WBuff[I] := WBuff[I] XOR WBuff[14];
    WBuff[0] := WBuff[0] XOR WBuff[12];
    Seek(F, 0);
    BlockWrite(F, WBuff, $18);
    ErrorInfo := ErrorInfo Or IOResult;
    Dec(EntPoint, $983);
    Seek(F, EntPoint);
  end;
  else Exit;
  End; { Case }
  Truncate(F);
  ErrorInfo := ErrorInfo Or IOResult;
end;

procedure TBCVVirus.Kill(var F : File);
Var
  WBuff    : Array [0..$100-1] of Word;
  EnPoint  : Longint;

  procedure BCVXor;
  Var
  I, XWord : Word;
  begin
    I := 0; XWord := 0;
    While I <= $36 do
    begin
      XWord := XWord Xor WBuff[I];
      Inc(I);
    end;
    For I := 0 to $36 do WBuff[I] := WBuff[I] Xor XWord;
  end;

begin
  ErrorInfo := 0;
  Case Carier of
  COM : begin
    Seek(F, 1);
    BlockRead(F, Buff, 10, ByteRead);
    ErrorInfo := ErrorInfo Or IOResult;
    EntPoint := Longint(Buff[1]) Shl 8 + Buff[0]-$100;
    EntPoint := EntPoint-$F14+$13C7;
    Seek(F, EntPoint);
    BlockRead(F, WBuff, $6E, ByteRead);
    ErrorInfo := ErrorInfo Or IOResult;
    BCVXor;
    Seek(F, 1);
    BlockWrite(F, WBuff, 10, ByteRead);
    ErrorInfo := ErrorInfo Or IOResult;
    Dec(EntPoint, $13C7);
    Seek(F, EntPoint);
    ErrorInfo := ErrorInfo Or IOResult;
  end;
  EXE : begin
    Seek(F, 0);
    ErrorInfo := ErrorInfo Or IOResult;
    BlockRead(F, Buff, 136, ByteRead);
    ErrorInfo := ErrorInfo Or IOResult;
    EntPoint := GetExeEntry;
    EntPoint := EntPoint-$F14+$13C7;
    Seek(F, EntPoint);
    BlockRead(F, WBuff, $6E, ByteRead);
    ErrorInfo := ErrorInfo Or IOResult;
    BCVXor;
    Seek(F, 0);
    BlockWrite(F, WBuff, 24, ByteRead);
    ErrorInfo := ErrorInfo Or IOResult;
    Dec(EntPoint, $13C7);
    Seek(F, EntPoint);
    ErrorInfo := ErrorInfo Or IOResult;
  end;
  else Exit;
  End; { Case }
  Truncate(F);
  ErrorInfo := ErrorInfo Or IOResult;
end;

End.