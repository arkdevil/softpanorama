{$A+,B-,D+,E+,F-,I-,L+,N-,O-,R-,S-}
unit BZTools;

Interface

uses Dos,TPCrt,TPMouse,TPDos;

type
    FrameChars = array[1..8] of Char;

const
    CBreakPressed : boolean = false;
    DivideOnZero  : boolean = false;
{ Standard frame character sets }
    SingleFrame: FrameChars = '┌─┐││└─┘';
    DoubleFrame: FrameChars = '╔═╗║║╚═╝';

var
    Int00Save,
    Int1BSave : pointer;

procedure WriteCharToScreen(c:char);
procedure WriteToScreen(s:string);
function Long2Str(l:LongInt):string;
function RPos ( SubString, SourceStr : string) : byte;
procedure SetBreakInt;
procedure RestoreBreakInt;
procedure beep;
procedure ClearKeyBuf;
procedure TimeOrKeyPress(t : LongInt);
procedure SetDivZeroInt;
procedure RestoreDivZeroInt;
procedure DrawTextBox(X1,Y1,X2,Y2: byte; var Frame: FrameChars; FrameAttr: Byte);

Implementation

procedure WriteCharToScreen(c:char);
var Regs : Registers;
begin
  Regs.ah:=2;
  Regs.dl:=byte(c);
  MSDos(Regs)
end;

procedure WriteToScreen(s:string);
var
   i : byte;
begin
    while (Length(s)>0) and (s[Length(s)]=' ') do Delete(s,Length(s),1);
    For i:=1 to Length(s) do WriteCharToScreen(s[i]);
    WriteCharToScreen(#13); WriteCharToScreen(#10)
end;

function Long2Str(l:LongInt):string;
var s:string;
begin
  Str(l,s);
  Long2Str:=s
end;

function RPos ( SubString, SourceStr : string) : byte;
var s,ss : string;
    i,L1,L2,N : byte;
{ функция, аналогичная POS, но определяет позицию справа налево }
begin
   s[0]:=SourceStr[0]; L1:=Length(SourceStr);
  ss[0]:=SubString[0]; L2:=Length(SubString);
  if (L1<L2) or ((L1=L2) and (SubString<>SourceStr)) Then
     begin RPos:=0; Exit end;
  for i:=1 to L1 do  s[i]:=SourceStr[L1-i+1];
  for i:=1 to L2 do ss[i]:=SubString[L2-i+1];
  N := Pos(ss,s); if N=0 Then begin RPos:=0; Exit end;
  RPos:=N-L2-N+2;
end;

{$F+}
procedure LookBreak; Interrupt;
begin
CBreakPressed:=true;
end;

procedure SetDivZeroFlag; Interrupt;
begin
DivideOnZero:=true;
end;
{$F-}

procedure SetBreakInt;
{ ловит ^Break }
begin
   GetIntVec($1B,Int1BSave);
   SetIntVec($1B,Addr(LookBreak))
end;

procedure RestoreBreakInt;
begin
   SetIntVec($1B,Int1BSave)
end;

procedure SetDivZeroInt;
begin
   GetIntVec($00,Int00Save);
   SetIntVec($00,Addr(SetDivZeroFlag))
end;

procedure RestoreDivZeroInt;
begin
   SetIntVec($00,Int00Save)
end;

procedure BEEP;
begin
Sound(800); Delay(250); NoSound
end;

procedure ClearKeyBuf;
{ очищает буфер клавиатуры }
var Key,But : Word;
begin
  if MouseInstalled Then
     while keypressed or MousePressed do but:=ReadKeyOrButton
   else
     while keypressed do Key:=ReadKeyWord;
  CBreakPressed:=false;
end;

procedure TimeOrKeyPress(t : LongInt);
{ ожидает, пока не пройдет время или будет нажата клавиша или кнопка мыши }
var
    i:LongInt;
begin
  ClearKeyBuf;
  i:=TimeMS; t:=t+i;
  if MouseInstalled Then
     while (TimeMS<t) and (not keyPressed) and (not MousePressed) do
   else
     while (TimeMS<t) and (not keyPressed) do ;
  ClearKeyBuf;
end;

procedure DrawTextBox(X1,Y1,X2,Y2: byte; var Frame: FrameChars; FrameAttr: Byte);
{ рисует рамку }
var
  W, H, Y: Word;
begin
  W := X2 - X1 + 1;
  H := Y2 - Y1 + 1;
  FastFill (   1, Frame[1],  Y1,  X1, FrameAttr);
  FastFill ( W-1, Frame[2],  Y1,X1+1, FrameAttr);
  FastFill (   1, Frame[3],  Y1,  X2, FrameAttr);
  for Y := 1 to H - 2 do
  begin
    FastFill (   1, Frame[4],Y1+Y,  X1, FrameAttr);
    FastFill (   1, Frame[5],Y1+Y,  X2, FrameAttr);
  end;
  FastFill (   1, Frame[6],  Y2,  X1, FrameAttr);
  FastFill ( W-1, Frame[7],  Y2,X1+1, FrameAttr);
  FastFill (   1, Frame[8],  Y2,  X2, FrameAttr);
end;

end.
