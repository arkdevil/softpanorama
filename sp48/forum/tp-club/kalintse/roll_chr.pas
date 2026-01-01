unit roll_chr;

{**************************************************************************}
{*           UNIT Roll_Chr.PAS V1.0  Last updated on 12/28/91             *}
{*                   Copyright (c) 1991, DEK SoftWorks                    *}
{**************************************************************************}

interface

uses Dos,TpCrt,ChgChar,Inter;

function Init_Roll: Boolean;
{-This routine installs new $1C handler what updates rolling "DEK" message}

procedure Finit_Roll;
{-This routine cancells rolling and changes all of #0,#1 and #2 to D,E & K}

implementation

var
   OldInt1C: procedure;
   Sv0,Sv1,Sv2: BitMask;
   C0,C1,C2: ^BitMask;
   C: Char;
   Phase: Byte;
   C0o: Word absolute C0;
   C1o: Word absolute C1;
   C2o: Word absolute C2;
   D: Boolean;
   CanRoll: Boolean;
   A: Byte;
   Z: Byte;
   MyFont: Array[0..16*3] Of BitMask;
   D1,E1,K1: BitMask;
   i,j,k: Byte;

function InvByte(B: Byte): Byte;
begin
  asm
    clc
    mov  cx,8
    xor  bx,bx
    mov  ah,B
    mov  al,80h
    @@loop_1:
    ror  ah,1
    jnc  @@m001
    clc
    or   bl,al
    @@m001:
    shr  al,1
    loop @@loop_1
    mov  B,bl
  end;
  InvByte := B;
end;

{$F+}
procedure UpdateDEK; interrupt;
{-This routine for internal use only}
var
   MyPtr: Pointer;
   Myo: Word absolute MyPtr;

begin
     if A = 0 then 
     begin
       MyPtr := @MyFont;
       if Phase = 0 then D := True;
       if Phase = 16 then D := False;
       if D then begin
          Inc(Myo,Phase*16*3);
          Inc(Phase);
       end
       else 
       begin
         Dec(Phase);
         Inc(Myo,Phase*16*3);
       end;
       C0 := MyPtr;
       C1 := C0;
       Inc(C1o,16);
       C2 := C1;
       Inc(C2o,16);
       ChangeChar(#0,C0^);
       ChangeChar(#1,C1^);
       ChangeChar(#2,C2^);
     end;
     Inc(A);
     if A > 1 then A := 0;
     Inc(Z);
     if Z = 192 then
     begin
       SetIntVec($1C,AnmProc);
       Z := 0;
     end;
     asm
        pushf
     end;
     Old1C;
end;
{$F-}

function Init_Roll: Boolean;
{-This routine installs new $1C handler what updates rolling "DEK" message}

procedure SetE(A: Byte);
var
  W1,W2: Word;
  C: Byte;

begin
  if A > 7 then C := 15-A else C := A;
  for i := 1 to SL do
  begin
    W1 := D1[i];
    W1 := ((W1 shl 8) and $FF00) shr C;
    W2 := E1[i];
    W2 := W2 and $00FF;
    W1 := W1 or W2;
    MyFont[0+A*3][i] := Hi(W1);
    W2 := K1[i];
    W2 := (W2 and $00FF) shl C;
    W1 := ((W1 and $00FF) shl 8) or W2;
    MyFont[1+A*3][i] := Hi(W1);
    MyFont[2+A*3][i] := Lo(W1);
  end;
end;

procedure BuildPhases;
var
  W: Word;
  B1,B2: Byte;

begin
  SetE(0);
  for j := 1 to 4 do
  begin
    for i := 1 to SL do
    begin W:=0; B1:=D1[i]; B2:=(B1 and $F0) shr 1; B1:=(B1 and $0F) or B2; D1[i]:=B1; end;
    for i := 1 to SL do
    begin W:=0; B1:=E1[i]; B2:=(B1 and $F0) shr 1; B1:=(B1 and $0F) or B2; E1[i]:=B1; end;
    for i := 1 to SL do
    begin W:=0; B1:=K1[i]; B2:=(B1 and $F0) shr 1; B1:=(B1 and $0F) or B2; K1[i]:=B1; end;
    SetE(j*2-1);
    for i := 1 to SL do
    begin W:=0; B1:=D1[i]; B2:=(B1 and $0F) shl 1; B1:=(B1 and $F0) or B2; D1[i]:=B1; end;
    for i := 1 to SL do
    begin W:=0; B1:=E1[i]; B2:=(B1 and $0F) shl 1; B1:=(B1 and $F0) or B2; E1[i]:=B1; end;
    for i := 1 to SL do
    begin W:=0; B1:=K1[i]; B2:=(B1 and $0F) shl 1; B1:=(B1 and $F0) or B2; K1[i]:=B1; end;
    SetE(j*2);
  end;

  for i := 1 to SL do
  begin
    K1[i] := InvByte(Sv0[i]);
    E1[i] := InvByte(Sv1[i]);
    D1[i] := InvByte(Sv2[i]);
  end;
  SetE(15);
  for j := 7 downto 4 do
  begin
    for i := 1 to SL do
    begin W:=0; B1:=D1[i]; B2:=(B1 and $0F) shl 1; B1:=(B1 and $F0) or B2; D1[i]:=B1; end;
    for i := 1 to SL do
    begin W:=0; B1:=E1[i]; B2:=(B1 and $0F) shl 1; B1:=(B1 and $F0) or B2; E1[i]:=B1; end;
    for i := 1 to SL do
    begin W:=0; B1:=K1[i]; B2:=(B1 and $0F) shl 1; B1:=(B1 and $F0) or B2; K1[i]:=B1; end;
    SetE(j*2);
    for i := 1 to SL do
    begin W:=0; B1:=D1[i]; B2:=(B1 and $F0) shr 1; B1:=(B1 and $0F) or B2; D1[i]:=B1; end;
    for i := 1 to SL do
    begin W:=0; B1:=E1[i]; B2:=(B1 and $F0) shr 1; B1:=(B1 and $0F) or B2; E1[i]:=B1; end;
    for i := 1 to SL do
    begin W:=0; B1:=K1[i]; B2:=(B1 and $F0) shr 1; B1:=(B1 and $0F) or B2; K1[i]:=B1; end;
    SetE(j*2-1);
  end;
end;

begin
     CanRoll := True;
     if CanRoll then begin
        if CurrentDisplay <> EGA then 
        begin
          SL := 16;
          MyBH := 6;
        end;
        if Font8x8Selected then
        begin
          SL := 8;
          MyBH := 3;
        end;
        A := 0;
        D := True;
        Phase := 0;
        GetOldChar('D',Sv0);
        GetOldChar('E',Sv1);
        GetOldChar('K',Sv2);
        GetOldChar('D',D1);
        GetOldChar('E',E1);
        GetOldChar('K',K1);
        BuildPhases;
        C0 := @MyFont;
     end;
     Init_Roll := CanRoll;
     Z := 0;
     RollProc := @UpdateDEK;
end;

procedure Finit_Roll;
{-This routine cancells rolling and changes all of #0,#1 and #2 to D,E & K}

begin
     if CanRoll then begin
        SetIntVec($1C, @Old1C);
        ChangeChar(#0,Sv0);
        ChangeChar(#1,Sv1);
        ChangeChar(#2,Sv2);
        asm
             mov ax,VideoSegment
             mov es,ax
             mov ax,00
             mov bl,'D'
             call @a
             jmp  @b
             @a: mov cx,4000
             xor di,di
             @loop1: repne scasb
             jne @bye1
             mov byte ptr es:[di-1],bl
             cmp cx,0
             jne @loop1
             @bye1: retn
             @b:
             mov ax,01
             mov bl,'E'
             call @a
             mov ax,02
             mov bl,'K'
             call @a
        end;
     end;
end;

end.
