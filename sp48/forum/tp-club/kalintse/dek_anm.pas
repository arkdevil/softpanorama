unit dek_anm;

{**************************************************************************}
{*           UNIT DEK_Anm.PAS V1.0  Last updated on 12/18/91              *}
{*                   Copyright (c) 1991, DEK SoftWorks                    *}
{**************************************************************************}

interface

uses Dos,TpCrt,ChgChar,Inter,Roll_Chr;

function Init_Roll: Boolean;
{-This routine installs new $1C handler what updates rolling "DEK" message}

procedure Finit_Roll;
{-This routine cancells rolling and changes all of #0,#1 and #2 to D,E & K}

implementation

type
  AnmA = Array[1..16] Of LongInt;

var
   OldInt1C: procedure;
   Sv0,Sv1,Sv2: BitMask;
   Sv0_,Sv1_,Sv2_: BitMask;
   C0,C1,C2: BitMask;
   C: Char;
   Phase: Byte;
   D: Boolean;
   CanRoll: Boolean;
   A: Byte;
   B: Byte;
   Buf1,Buf2: AnmA;
   L: LongInt;

{$F+}
procedure UpdateDEK; interrupt;
{-This routine for internal use only}
var
  i,j: Byte;

begin
     if B = 0 then
     begin
       case A Of
         0: begin { <=> }
             for i := 0 to Phase do
              for j := 1 to 16 do
                if Odd(j) then
                  Buf2[j] := Buf1[j] shl Phase
                else
                  Buf2[j] := Buf1[j] shr Phase;
             Inc(Phase);
             if Phase > 24 then
             begin
               Phase := 0;
               Inc(A);
             end;
            end;
         1: begin { >=< }
             for i := 0 to Phase do
              for j := 1 to 16 do
                if Odd(j) then
                  Buf2[j] := Buf1[j] shl (23-Phase)
                else
                  Buf2[j] := Buf1[j] shr (23-Phase);
             Inc(Phase);
             if Phase > 23 then
             begin
               Phase := 0;
               Inc(A);
             end;
            end;
         2: begin { <= }
             for i := 0 to Phase do
              for j := 1 to 16 do
                Buf2[j] := Buf1[j] shl Phase;
             Inc(Phase);
             if Phase > 24 then
             begin
               Phase := 0;
               Inc(A);
             end;
            end;
         3: begin { >= }
             for i := 0 to Phase do
              for j := 1 to 16 do
                Buf2[j] := Buf1[j] shl (23-Phase);
             Inc(Phase);
             if Phase > 24 then
             begin
               Phase := 0;
               Inc(A);
             end;
            end;
         4: begin { = }
             for i := 1 to 16-Phase do
              Buf2[i] := Buf1[16-Phase];
             Inc(Phase);
             if Phase > 15 then
             begin
               Phase := 0;
               Inc(A);
             end;
            end;
         5: begin { V }
             for i := 1 to 16 do
               if i < Phase+1 then
                 Buf2[i] := 0
               else
                 Buf2[i] := Buf1[i-Phase];
             Inc(Phase);
             if Phase > 15 then
             begin
               Phase := 0;
               Inc(A);
             end;
            end;
         6: begin { ^ }
             for i := 1 to 16-Phase do
               Buf2[i] := 0;
             for j := i to 16 do
               Buf2[j] := Buf1[j-i+1];
             Inc(Phase);
             if Phase > 15 then
             begin
               Phase := 0;
               A := 0;
               SetIntVec($1C, RollProc);
             end;
            end;
       end;
       for i := 1 to 16 do
       begin
         C0[i] := Word(Buf2[i] shr 16);
         C1[i] := Word(Buf2[i] shr 8);
         C2[i] := Word(Buf2[i]);
       end;
       ChangeChar(#0,C0);
       ChangeChar(#1,C1);
       ChangeChar(#2,C2);
     end;
     Inc(B);
     if B > 1 then B := 0;
     asm
        pushf
     end;
     Old1C;
end;
{$F-}

function Init_Roll: Boolean;
{-This routine installs new $1C handler what updates rolling "DEK" message}

begin
     CanRoll := False;
     ReInitCrt;
     if CurrentDisplay in [EGA, VGA, MCGA] then CanRoll := True;
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
        GetOldChar('D',Sv0_);
        GetOldChar('E',Sv1_);
        GetOldChar('K',Sv2_);
        GetOldChar(#0,Sv0);
        GetOldChar(#1,Sv1);
        GetOldChar(#2,Sv2);
        GetIntVec($1C, @Old1C);
        SetIntVec($1C, @UpdateDEK);
        for A := 1 to 16 do
        begin
          L := ((LongInt(Sv0_[A]) shl 16) and $00FF0000) + 
               ((LongInt(Sv1_[A] shl 8) and $0000FF00) + 
               LongInt(Sv2_[A]));
          Buf1[A] := L;
        end;
        A := 0;
        Phase := 0;
     end;
     CanRoll := Roll_Chr.Init_Roll;
     Init_Roll := CanRoll;
     AnmProc := @UpdateDEK;
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
