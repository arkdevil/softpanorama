{************************************************}
{                                                }
{        L e c a r                               }
{   Turbo Pascal 6.X                             }
{   Попросту, без чинов и Copyright-ов  1992     }
{   Версия 2.0 от                                }
{************************************************}

{$A+,B-,D+,E-,F-,I+,L+,N-,O-,R+,S+,V+,X+,G-}
{$M 16384,0,655360}

Unit Common;

Interface

Uses
  Dos,
  Objects;

Const
  noError = $0000;
  CPU : Array [0..5] of String[5] = ('V8086', '8086', '80286', '80386', '80486', '80586');
  Test8086 : Byte = $01;

Type
  TBuff = Array [0..1023] of Byte;
  PDevice = ^TDevice;
  TDevice = Record
    SpecFunc, DeviceType : Byte;
    DeviceAttr, NumOfCylinder : Word;
    Media : Byte;
    DeviceBPB : Array [0..$1E] of Byte;
    TrackLayout : Array [0..$6A] of Byte;
  End;

Var
  Buff      : TBuff;

Type

  PByte   = ^Byte;
  PWord   = ^Word;
  PInt    = ^Integer;
  PLong   = ^Longint;
  PArray  = ^TArray;
  TArray  = Array [0..$FFF0] of Byte;
  TCarier  = (COM, EXE, SYS, OtherFile, Floppy, Hard, CDROM, NetWork, OtherDisk);
  PSearchRec = ^SearchRec;

procedure DisableInterrupt; Inline( $FA );     { CLI }
procedure EnableInterrupt; Inline( $FB );     { STI }
procedure GetVector(Vect : Byte; Var Ptr : Pointer);
procedure SetVector(Vect : Byte; Ptr : Pointer);
function HexByte(B : Byte) : String;   { Вывод байта в HEX формате }
function HexWord(W : Word) : String;   { Вывод слова в HEX формате }
function HexPtr(P : Pointer) : String; { Вывод указателя в HEX формате }
function A20(Segment, Offset : Word) : Longint;
function GetExeEntry : Longint;
procedure PrintStr(S : String);
function GetDeviceType(Drv : Byte) : TCarier;
function Load_Rus_Font : Integer;
function UnLoad_Rus_Font : Integer;

Type
  PVirus = ^TVirus;
  TVirus = Object
    Name  : PString;
    Memo  : Array [0..5] of Byte;
    MemoOffs : Array [0..5] of Byte;
    MemoKill : Array [0..5] of Byte;
    ErrorInfo : Word;
    Resident : Boolean;
    Carier : TCarier;
    constructor Init(N : String; R : Boolean;
                     M0, M1, M2, M3, M4, M5 : Byte;
                     O0, O1, O2, O3, O4, O5 : Byte;
                     MK0, MK1, MK2, MK3, MK4, MK5 : Byte);
    function TestMemory(SSegm, SOffs : Word) : Boolean; Virtual;
    destructor Done; Virtual;
    procedure PrintInfo; Virtual;
  private
    procedure KillMemory(KSegm, KOffs : Word);
  End;

  PFileVirus = ^TFileVirus;
  TFileVirus = Object(TVirus)
    Mask    : Array [0..5] of Byte;
    FOffs   : Array [0..5] of Word;
    ByteRead : Word;
    EntPoint : Longint;
    OffsJmp : Byte;
    Offs    : Integer;
    Count   : Byte;
    constructor Init(N : String; R : Boolean;
                     M0, M1, M2, M3, M4, M5 : Byte;
                     O0, O1, O2, O3, O4, O5 : Byte;
                     MK0, MK1, MK2, MK3, MK4, MK5 : Byte;
                     F0, F1, F2, F3, F4, F5 : Byte;
                     FO0, FO1, FO2, FO3, FO4, FO5 : Integer);
    function TestFile(var F : File; T : TCarier) : Boolean; Virtual;
    function ClearFile(var F : File) : Byte; Virtual;
    destructor Done; Virtual;
    procedure PrintInfo; Virtual;
    procedure Kill(var F : File); Virtual;
  End;

  PDiskVirus = ^TDiskVirus;
  TDiskVirus = Object(TVirus)
    Mask    : Array [0..5] of Byte;
    DOffs   : Array [0..5] of Word;
    Drive : Byte;
    constructor Init(N : String; R : Boolean;
                     M0, M1, M2, M3, M4, M5 : Byte;
                     O0, O1, O2, O3, O4, O5 : Byte;
                     MK0, MK1, MK2, MK3, MK4, MK5 : Byte;
                     D0, D1, D2, D3, D4, D5 : Byte;
                     DO0, DO1, DO2, DO3, DO4, DO5 : Integer);
    function TestDisk(Drv : Byte) : Boolean; Virtual;
    function ClearDisk : Byte; Virtual;
    destructor Done; Virtual;
    procedure Kill; Virtual;
  End;

  PVirusCollection = ^TVirusCollection;
  TVirusCollection = Object(TCollection)
    procedure FreeItem(Item : Pointer); Virtual;
  End;

Implementation

Uses ErrHand;

function Load_Rus_Font : integer; external;
function UnLoad_Rus_Font : integer; external;
{$L fn.obj}

function GetDeviceType(Drv : Byte) : TCarier;
var
  ID : Byte;
  Dev : TDevice;
begin
  GetDeviceType := Hard;
  If (Drv And $80) <> 0 then Exit;
{
  asm
    mov  ah, 01Ch
    mov  dl, Drv
    inc  dl
    push ds
    int  21h
    mov  al, byte ptr [bx]
    pop  ds
    mov  ID, al
  end;
  case ID of
    $F8 : GetDeviceType := Hard;
    else GetDeviceType := Floppy;
  end;
  Exit;
}
  asm
    push ds
    mov  ax,  0440Dh
    mov  cx,  00860h
    mov  bl,  Drv
    inc  bl
    lea  dx,  Dev
    push ss
    pop  ds
    int  21h
    pop  ds
  end;
  with Dev do
  begin
    case DeviceType of
      $0,$1,$2,$3,$4,$7 : GetDeviceType := Floppy;
      $5 : GetDeviceType := Hard;
      $8 : GetDeviceType := OtherDisk;
      else GetDeviceType := OtherDisk;
    end;
  end;
end;

procedure SetVector( Vect : Byte; Ptr : Pointer );
  begin
    DisableInterrupt;
    MemL[0000:Vect*4] := Longint(Ptr);
    EnableInterrupt;
  end;

procedure GetVector ( Vect : Byte; Var Ptr : Pointer );
  begin
    DisableInterrupt;
    Ptr := Pointer (MemL[0000:Vect*4]);
    EnableInterrupt;
  end;

function GetMachine : Byte; Assembler;
asm
  Pushf
  Xor AX, AX
  Push AX
  Popf
  Pushf
  Pop AX
  And AX, 0F000h
  Cmp AX, 0F000h
  Jnz @80X86
  Mov AL, 1d
  Jmp @Exit
@80X86:
  Mov AX, 0F000h
  Push AX
  Popf
  Pushf
  Pop BX
  And BX, AX
  Jnz @80386
  Mov AL, 2d
  Jmp @Exit
@80386:
  Mov  AL, 03
  Db   066h, 053h        { push ebx }
  Db   066h, 051h        { push ecx }
                           Push DX
                           Mov  DX, SP
                           And  SP, 0FFFCh
  Db   066h, 09Ch        { pushfd }
  Db   066h, 05Bh        { pop ebx }
  Db   066h, 08Bh, 0CBh  { mov ecx, ebx }
                         { xor ebx, 00040000h }
  Db   066h, 081h, 0F3h, 00,00,04,00
  Db   066h, 053h        { push ebx }
  Db   066h, 09Dh        { popfd }
  Db   066h, 09Ch        { pushfd }
  Db   066h, 05Bh        { pop ebx }
  Db   066h, 033h, 0D9h  { xor ebx, ecx }
                         { test ebx, 00040000h }
  Db   066h, 0F7h, 0C3h, 00,00,04,00
                           Je @@386
                           Inc AX
@@386:
  Db   066h, 051h        { push ecx }
  Db   066h, 09Bh        { popfd }
                           Mov SP, DX
                           Pop DX
  Db   066h, 059h        { pop ecx }
  Db   066h, 05Bh        { pop ebx }
  Xchg AX, BX
  Db   00Fh, 001h, 0E0h  {  smsw ax }
  And  AL, 00000001b     {  Protected Enable = 1 ? }
  Xchg AX, BX
  Jnz  @V8086
  Jmp  @Exit
@V8086:
  Or   AL, 080h
@Exit:
  Popf
end;

function HexWord(W : Word) : String; { Вывод слова в HEX формате }
  Const
    HexChars : array [0..$F] of Char = '0123456789ABCDEF';
  begin
    HexWord := '';
    HexWord := HexChars[Hi(w) shr 4] + HexChars[Hi(w) and $F] +
               HexChars[Lo(w) shr 4] + HexChars[Lo(w) and $F];
  end;

function HexByte(B : Byte) : String;   { Вывод байта в HEX формате }
  Const
    HexChars : array [0..$F] of Char = '0123456789ABCDEF';
  begin
    HexByte := HexChars[B shr 4] + HexChars[B and $0F]
  end;

function HexPtr(P : Pointer) : String;
  begin
    HexPtr := Concat(HexWord(Seg(P^)), ':', HexWord(Ofs(P^)));
  end;

function A20(Segment, Offset : Word) : Longint;
begin
  A20 := (Longint(Segment) Shl 4 + Longint(Offset)) AND $FFFFF;
end;

function GetExeEntry : Longint;
begin
  GetExeEntry := A20(PWord(@Buff[$16])^, PWord(@Buff[$14])^)+Longint(PWord(@Buff[$08])^) Shl 4;
end;

procedure PrintStr(S : String);Assembler;
asm
  LES  BX, S
  MOV  CL, ES:[BX]
  XOR  CH, CH
  OR   CX, CX
  JZ   @Exit
  INC  BX
  STD
@L1:
  MOV  AH, 02h
  MOV  DL, ES:[BX]
  INT  21h
  INC  BX
  LOOP @L1
@Exit:
  CLD
end;

{ Реализация абстрактного объекта TVirus }

constructor TVirus.Init(N : String; R : Boolean;
                        M0, M1, M2, M3, M4, M5 : Byte;
                        O0, O1, O2, O3, O4, O5 : Byte;
                        MK0, MK1, MK2, MK3, MK4, MK5 : Byte);
begin
  Name := NIL;
  Name := NewStr(N);
  Resident := R;
  ErrorInfo := noError;
  Memo[0] := M0; Memo[1] := M1; Memo[2] := M2;
  Memo[3] := M3; Memo[4] := M4; Memo[5] := M5;
  MemoOffs[0] := O0; MemoOffs[1] := O1; MemoOffs[2] := O2;
  MemoOffs[3] := O3; MemoOffs[4] := O4; MemoOffs[5] := O5;
  MemoKill[0] := MK0; MemoKill[1] := MK1; MemoKill[2] := MK2;
  MemoKill[3] := MK3; MemoKill[4] := MK4; MemoKill[5] := MK5;
end;

procedure TVirus.PrintInfo;
var
  I : Byte;
  S : String[30];
begin
  FillChar(S, SizeOf(S), ' ');
  S[0] := Char(25);
  Move(Name^[1], S[1], Length(Name^));
  If Resident then PrintStr('Р ') else PrintStr('Н ');
  PrintStr(S);
  PrintStr(' ');
  For I := 0 to 3 do PrintStr(HexByte(Memo[I]));
  PrintStr(' ');
  For I := 0 to 3 do PrintStr(HexByte(MemoOffs[I]));
  PrintStr(' ');
  For I := 0 to 5 do PrintStr(HexByte(MemoKill[I]));
end;

function TVirus.TestMemory(SSegm, SOffs : Word) : Boolean;
Var
  Present : Boolean;
  J : Byte;
begin
  TestMemory := False;
  If Not Resident then Exit;
  Present := True;                { Пусть найдена }
  J := 0;
  Repeat
    If PByte(Ptr(SSegm,SOffs+MemoOffs[J]))^ <> Memo[J] then Present := False;
    Inc (J);
  Until (NOT Present) OR (J>5);
  If Present then
  begin
    TestMemory := True;
    KillMemory(SSegm, SOffs);
  end;
end;

procedure TVirus.KillMemory(KSegm, KOffs : Word);
Var
  J : Byte;
begin
  For J:=0 to 5 do Mem[KSegm:KOffs+J] := MemoKill[J];
  WriteLn('По адресу ', HexPtr(Ptr(KSegm, KOffs)), ' застигнут врасплох вирус ', Name^);
end;

destructor TVirus.Done;
begin
  If Name <> NIL then DisposeStr(Name);
end;

{ Реализация абстрактного объекта TFileVirus }

constructor TFileVirus.Init(N : String; R : Boolean;
                            M0, M1, M2, M3, M4, M5 : Byte;
                            O0, O1, O2, O3, O4, O5 : Byte;
                            MK0, MK1, MK2, MK3, MK4, MK5 : Byte;
                            F0, F1, F2, F3, F4, F5 : Byte;
                            FO0, FO1, FO2, FO3, FO4, FO5 : Integer);
begin
  TVirus.Init(N,R,M0,M1,M2,M3,M4,M5,O0,O1,O2,O3,O4,O5,MK0,MK1,MK2,MK3,MK4,MK5);
  Mask[0] := F0; Mask[1] := F1; Mask[2] := F2;
  Mask[3] := F3; Mask[4] := F4; Mask[5] := F5;
  FOffs[0] := FO0; FOffs[1] := FO1; FOffs[2] := FO2;
  FOffs[3] := FO3; FOffs[4] := FO4; FOffs[5] := FO5;
  Carier := OtherFile;
  OffsJmp := 0;
end;

procedure TFileVirus.PrintInfo;
var
  I : Byte;
begin
  TVirus.PrintInfo;
  PrintStr(' ');
  For I := 0 to 3 do PrintStr(HexByte(Mask[I]));
  PrintStr(' ');
  For I := 0 to 3 do PrintStr(HexWord(FOffs[I]));
end;

function TFileVirus.TestFile(Var F : File; T : TCarier) : Boolean;
Var
  J       : Byte;
  Present : Boolean;
begin
  Carier := T;
  J := 0;
  Present := True;
  Repeat
    If Buff[FOffs[J]] <> Mask[J] then Present := False;
    Inc(J);
  Until (J > 5) OR (NOT Present);
  If Present then { найден вирус }
  begin
    TestFile := True;
  end
  else TestFile := False;
end;

function TFileVirus.ClearFile(Var F : File) : Byte;
Var
  Ftime : Longint;
  Fattr : Word;
begin
  Reset(F);
  GetFTime(F, Ftime);
  GetFAttr(F, Fattr);
  Close(F);
  SetFAttr(F, Archive);
  FileMode := 2;
  Reset(F, 1);
  If IOResult <> 0 then
  begin
    ErrorInfo := GetError;
    WriteLn(^G' -> ', LastError);
  end
  else begin
    Kill(F);
    Reset(F);
    SetFTime(F, Ftime);
    Close(F);
    SetFAttr(F, Fattr);
    ClearFile := ErrorInfo;
  end;
  FileMode := 0;
  If ErrorInfo = $FF then
  begin
    WriteLn(' Еще не умею лечить');
    Exit;
  end;
  If ErrorInfo <> noError then
  begin
    WriteLn(' не лечится : ', LastError);
    Exit;
  end;
  WriteLn(' дезактивировал');
end;

destructor TFileVirus.Done;
begin
  TVirus.Done;
end;

procedure TFileVirus.Kill(Var F : File);
begin
  ErrorInfo := $FF;
end;

{ Реализация абстрактного объекта TDiskVirus }

constructor TDiskVirus.Init(N : String; R : Boolean;
                     M0, M1, M2, M3, M4, M5 : Byte;
                     O0, O1, O2, O3, O4, O5 : Byte;
                     MK0, MK1, MK2, MK3, MK4, MK5 : Byte;
                     D0, D1, D2, D3, D4, D5 : Byte;
                     DO0, DO1, DO2, DO3, DO4, DO5 : Integer);
begin
  TVirus.Init(N,R,M0,M1,M2,M3,M4,M5,O0,O1,O2,O3,O4,O5,MK0,MK1,MK2,MK3,MK4,MK5);
  Mask[0] := D0; Mask[1] := D1; Mask[2] := D2;
  Mask[3] := D3; Mask[4] := D4; Mask[5] := D5;
  DOffs[0] := DO0; DOffs[1] := DO1; DOffs[2] := DO2;
  DOffs[3] := DO3; DOffs[4] := DO4; DOffs[5] := DO5;
  Carier := OtherDisk;
end;

function TDiskVirus.TestDisk(Drv : Byte) : Boolean;
Var
  J : Integer;
  Present : Boolean;
begin
  Drive := Drv;
  Carier := GetDeviceType(Drv);
  J := 0;
  Present := True;
  Repeat
    If Buff[DOffs[J]] <> Mask[J] then Present := False;
    Inc(J);
  Until (J > 5) OR (NOT Present);
  If Present then { найден вирус }
  begin
    TestDisk := True;
  end
  else TestDisk := False;
end;

function TDiskVirus.ClearDisk : Byte;
begin
  Kill;
  ClearDisk := ErrorInfo;
end;

destructor TDiskVirus.Done;
begin
  TVirus.Done;
end;

procedure TDiskVirus.Kill;
begin
  ErrorInfo := $FF;
end;

procedure TVirusCollection.FreeItem(Item : Pointer);
begin
  Dispose(PVirus(Item), Done)
end;

Begin
  Test8086 := GetMachine;
End.
