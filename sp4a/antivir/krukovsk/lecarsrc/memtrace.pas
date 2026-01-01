{************************************************}
{                                                }
{        L e c a r                               }
{   Turbo Pascal 6.X                             }
{   Попросту, без чинов и Copyright-ов  1992     }
{   Версия 2.0 от                                }
{************************************************}

{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V+,X-}
{$M 16384,0,655360}

Unit MemTrace;

Interface

Uses
  Dos,
  Objects,
  Common;

Type
  TDV = Record
    Present : Boolean;
    Version : Word;
  End;
  TMW = Record
    Present  : Boolean;
    Version  : Word;
    Enhanced : Boolean;
  End;

Const
  DosPtr   : Pointer = NIL;
  BiosPtr  : Pointer = NIL;
  MDos     : TDV = (Present : True;  Version : $0000);
  DesqView : TDV = (Present : False; Version : $0000);
  Windows  : TMW = (Present : False; Version : $0000; Enhanced : False);
  Net      : Boolean = False;

function TestMemoryOnViruses(P : PVirusCollection) : Boolean;

Implementation

Type
  PPCollection = ^TPCollection;
  TPCollection = Object(TSortedCollection)
    function Compare(Key1, Key2: Pointer): Integer; Virtual;
    procedure FreeItem(Item: Pointer); Virtual;
  End;

Var
  Regs      : Registers;
  SaveInt1  : Pointer;
  SaveInt8  : Procedure;
  Already   : Boolean;
  Keep_CS   : Word;
  Viruses   : Boolean;
  VirPtr    : PVirusCollection;
  MySegment : Word;
  Counter   : Longint;
  BiosList  : PPCollection;
  DosList   : PPCollection;
  CanTraced : Boolean;
  Traced    : Byte;
  I         : Byte;

procedure TPCollection.FreeItem(Item: Pointer);
  begin
  end;

function TPCollection.Compare(Key1, Key2: Pointer): Integer;
  Var
    L1, L2 : Longint;
    Result : Integer;
    Res    : Longint;
  begin
    L1 := Longint(Seg(Key1^)) Shl 4 + Longint(Ofs(Key1^));
    L2 := Longint(Seg(Key2^)) Shl 4 + Longint(Ofs(Key2^));
    Res := L2 - L1;
    If Res < 0 then Result := 1;
    If Res = 0 then Result := 0;
    If Res > 0 then Result := -1;
    Compare := Result;
  end;

function MayBeTraced : Boolean; Assembler;
  asm
    PushF
    PushF
    Pop  AX
    Or   AX, 0100h
    Push AX
    PopF
    PushF
    Pop  AX
    And  AX, 0100h
    Jz   @L1
    Mov  AX, True
    Jmp  @Exit
  @L1:
    Mov  AX, False
  @Exit:
    PopF
  end;

procedure ClearTrapFlag; Assembler;  { Сбросить флаг трассировки }
  asm
    PUSHF
    POP  AX
    AND  AX, 0FEFFH
    PUSH AX
    POPF
  end;

procedure SetTrapFlag; Assembler;    { Установить флаг трассировки }
  asm
    PUSHF
    POP  AX
    OR   AX, 0100H
    PUSH AX
    POPF
  end;

{ Обработчик INT 01H, должен иметь дальний тип вызовов }

{$F+}
procedure IntEmpty; Assembler; asm IRet end;

procedure Int8; Interrupt;
  begin
    CanTraced := True;
  end;

procedure Int1(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP : Word);Interrupt;
  Var
    I : Integer;
  begin
    If CS = Keep_CS then Exit;    { Если CS не изменился, ничего не делать }
    Inc(Counter);
    If Already then begin
      Flags := Flags AND $FEFF;
      Exit;                       { Если уже все кончено, ускорить процесс }
    end;
    DisableInterrupt;
    Case Traced of
      $8  : ;
      $13 : If (CS > $C000) AND (Longint(Ptr(CS, IP)) < Longint(Ptr($FFFF, $000F)))
              then BiosList^.Insert(Ptr(CS, IP));
      $21 : begin
          DosList^.Insert(Ptr(CS, IP));
          If (Ofs(DosPtr^)=$0000) AND (CS=Seg(DosPtr^))
          then DosPtr := Ptr(CS,IP);
        end;
      $2A : ;
    End;
    I := -1;
    Repeat
      Inc(I);
    Until (I = VirPtr^.Count) OR PVirus(VirPtr^.At(I))^.TestMemory(CS, IP);
    If I <> VirPtr^.Count then Viruses := True;
    Keep_CS := CS;                { Запомнить CS }
    Flags := Flags OR $0100;      { Возвести флаг трассировки на случай добрых людей }
    EnableInterrupt;
  end;
{$F-}

function TestMemoryOnViruses(P : PVirusCollection) : Boolean;
  Var
    I      : Integer;
    Status : Byte;
    Flags  : Word;
    P1     : Pointer;
  begin
    If NOT CanTraced then
    begin
      WriteLn('В памяти нечто ну очень гадкое. Виртуальная машина ? : ', CPU[Test8086]);
      If Test8086 = 0 then WriteLn('В натуре виртуальная машина, ай яй яй как нехорошо !!!');
      WriteLn('Работать без перезагрузки не бу...');
      WriteLn('Я не ду... потому и не бу...');
      Halt(1);
    end;
    BiosList := New(PPCollection, Init(10, 5));
    DosList := New(PPCollection, Init(10, 5));
    Regs.AX := $1203;                { Get DOS Segment }
    Intr($2F, Regs);
    DosPtr := Ptr(Regs.DS, $0000);
    VirPtr := P;
    TestMemoryOnViruses := False;
    CanTraced := False;
    GetVector($8, @SaveInt8);
    SetVector($1, Addr(Int1));       { Установить обработчик пошагового выполнения }
    SetVector($8, Addr(Int8));       { Установить обработчик таймера }
    Repeat Until CanTraced;
    MySegment := CSeg;
    Traced := $8;
    Viruses := False;
    Keep_CS := 0;
    Counter := 0;
    Already := False;
    SetTrapFlag;                     { Начать трассировку }
    asm
      Xor AX, AX
      Mov ES, AX
      PushF
      SegES Call dword ptr [4*8h]
    end;
    Already := True;
    ClearTrapFlag;                   { Закончить трассировку (на всякий случай ) }
    Traced := $13;
    Keep_CS := 0;
    Counter := 0;
    Already := False;
    SetTrapFlag;                     { Начать трассировку }
    asm
      Xor AX, AX
      Mov ES, AX
      Mov AH, 01h                    { Get диск information }
      Xor  DL, DL
      PushF
      SegES Call dword ptr [4*13h]
      Mov Status, AL
    end;
    Already := True;
    ClearTrapFlag;                   { Закончить трассировку (на всякий случай ) }
    Traced := $21;
    Keep_CS := 0;
    Counter := 0;
    Already := False;
    SetTrapFlag;                     { Начать трассировку }
    asm
      Xor AX, AX
      Mov ES, AX
      Mov AH, 62h                    { Get PSP segment }
      PushF
      SegES Call dword ptr [4*21h]
    end;
    Already := True;
    ClearTrapFlag;                   { Закончить трассировку (на всякий случай ) }
    Traced := $2A;
    Keep_CS := 0;
    Counter := 0;
    Already := False;
    SetTrapFlag;                     { Начать трассировку }
    asm
      Xor AX, AX
      Mov ES, AX
      PushF
      SegES Call dword ptr [4*2Ah]
    end;
    Already := True;
    ClearTrapFlag;                   { Закончить трассировку (на всякий случай ) }
    SetVector($1, SaveInt1);         { Восстановить INT 01H }
    SetVector($8, Addr(SaveInt8));   { Восстановить INT 08H }
    Port[$20] := $20;                { Разрешить обработку аппаратных прерываний }
    If BiosList^.Count = 1 then BiosPtr := BiosList^.At(0);
{$IFDEF DEBUG}
    I := 0;
    While I < BiosList^.Count do
    begin
      P1 := BiosList^.At(I);
      WriteLn('Found BIOS handler at ', HexPtr(P1));
      Inc(I);
    end;
    I := 0;
    While I < DosList^.Count do
    begin
      P1 := DosList^.At(I);
      WriteLn('Found DOS handler at ', HexPtr(P1));
      Inc(I);
    end;
    WriteLn('DOS entry point ', HexPtr(DosPtr));
    WriteLn('BIOS entry point ', HexPtr(BiosPtr));
    If BiosPtr = NIL then
      WriteLn(#13#10'Нечто странное имеет место в памяти'#13#10,'Ключ /b не имеет эффекта.' );
{$ENDIF}
    Dispose(BiosList, Done);
    Dispose(DosList, Done);
    If Viruses then TestMemoryOnViruses := True;
  end;

Begin
  asm
    Mov  AH, 30h
    Int  21h
    Xchg AH, AL
    Mov MDos.Version, AX
    Mov  AX, 2B01h
    Mov  CX, 4445h
    Mov  DX, 5351h
    Int  21h
    Cmp  AL, 0FFh
    Jz   @Exit
    Mov  DesqView.Present, True
    Mov  DesqView.Version, BX
  @Exit:
    Mov  AX, 4680h
    Int  2Fh
    Or   AX, AX
    Jnz  @L1
    Mov  Windows.Present, True
    Mov  Windows.Version, $0300
    Jmp  @Quit
  @L1:
    Mov  AX, 1600h
    Int  2Fh
    Cmp  AL, 00h
    Jz   @Quit
    Cmp  AL, 80h
    Jz   @Quit
    Cmp  AL, 01h
    Jz   @L2
    Cmp  AL, 0FFh
    Jz   @L2
    Xchg AH, AL
    Mov  Windows.Version, AX
    Jmp  @L3
  @L2:
    Mov  Windows.Version, $0200
  @L3:
    Mov  Windows.Enhanced, True
    Mov  Windows.Present, True
  @Quit:
  end;
  asm
    Mov AX, 7A00h
    Int 2Fh
    Cmp AL, 0FFh
    Jnz @L1
    Mov Net, True    { Novell NetWare }
  @L1:
(*
    Mov AX, 1100h    { netware redirector installation check }
    Int 2Fh
    Cmp AL, 0FFh
    Jnz @Exit
    Mov Net, True
*)
  @Exit:
  end;
  GetVector($1, SaveInt1);
  SetVector($1, Addr(IntEmpty));    { Установить обработчик пошагового выполнения }
  CanTraced := MayBeTraced;
  SetVector($1, SaveInt1);          { Восстановить INT 01H }
End.