{$A+,B-,D+,E+,F-,I-,L+,N+,O-,R-,S-}
unit BZTools;

Interface

uses
    TPCrt,
    TPMouse,
    TPString,
      Dos,
    TPDos;

type
    FrameChars = array[1..8] of Char;

const
    CBreakPressed  : boolean = false;
    DivideOnZero   : boolean = false;
    fE_UpCase      : boolean = true;
    fTruncLastPart : boolean = false;
    RightArrow     : char = #16;
    LeftArrow      : char = #17;
                                            { Standard frame character sets }
    SingleFrame    : FrameChars= '┌─┐││└─┘';
    DoubleFrame    : FrameChars= '╔═╗║║╚═╝';
    XLatTableSize  = 33;
    XLatTable      : array[1..XLatTableSize] of word =
                                                         { Кирилица (альт.) }
        ($80A0,$81A1,$82A2,$83A3,$84A4,$85A5,$86A6,$87A7,
         $88A8,$89A9,$8AAA,$8BAB,$8CAC,$8DAD,$8EAE,$8FAF,
         $90E0,$91E1,$92E2,$93E3,$94E4,$95E5,$96E6,$97E7,
         $98E8,$99E9,$9AEA,$9BEB,$9CEC,$9DED,$9EEE,$9FEF,
         $F0F1);
    HexSet : set of Char = ['0'..'9','A'..'F','a'..'f'];
    cwHyperColor0 : byte = 30;
    cwHyperColor1 : byte = 31;
    cwHyperColor2 : byte = 28;
    cwHyperColor3 : byte =112;
    TimeKey_Word : word = 0;
var
    Int00Save,
    Int1BSave : pointer;

procedure WriteCharToScreen(c:char);
function GetRealStr(R : real; L : byte) : string;
function GetRealStrLPad(R : real; L : byte) : string;
function GetRealStrForm(R : real; L,D : byte) : string;
function GetRealStrFormLPad(R : real; L,D : byte) : string;
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
procedure DrawTextBox( X1,Y1,X2,Y2: byte;
                       Frame: FrameChars; FrameAttr: Byte);
procedure DrawTextBoxWin( X1,Y1,X2,Y2: byte;
                       Frame: FrameChars; FrameAttr: Byte);
function HyperLength(s : string) : byte;
procedure HyperWrite (S : string; y,x : byte);
procedure HyperWritePad(S : string; y, x, len : byte);
procedure HyperWriteWin (S : string; y,x : byte);
procedure HyperWritePadWin(S : string; y, x, len : byte);
{ Write text string, use FastWriteWindow }
function _StrUpCase(s : string) : string;
function ZipFileName(S : string; Len : byte) : string;

Implementation

function GetRealStr(R : real; L : byte) : string;
{ Возвращает строку - вещественное число }
var
   p : integer;
   q : real;
   S,V : string;
   i : byte;
begin
  if R=0.0 Then begin GetRealStr := '0'; Exit end;
  p := Trunc(Ln(Abs(R)) / Ln(10));
  if (p<(L-2)) and (p>=0) Then
     begin
       i := L-P-3;
       Str(R:L:i,S);
       i:=pos('.',s);
       if i>0 Then begin
          while s[Length(s)]='0' do delete(s,Length(s),1);
          if s[Length(s)]='.' Then delete(s,Length(s),1) end
     end else begin
       if p<0 Then Dec(p);
       q := R * Exp(-p*Ln(10));
       Str(p:4,V);
       if fE_UpCase Then V:='E'+Trim(V) else V:='e'+Trim(V);
       i := L-3-Length(V);
       Str(q:i+3:i,S);
       i:=pos('.',s);
       if i>0 Then begin
          while s[Length(s)]='0' do delete(s,Length(s),1);
          if s[Length(s)]='.' Then delete(s,Length(s),1) end;
       S:=S+V;
     end;
  GetRealStr:=S;
end;

function GetRealStrLPad(R : real; L : byte) : string;
{ Возвращает число как строку заданной длины }
begin
  GetRealStrLPad := LeftPad(GetRealStr(r,l),l);
end;

function GetRealStrForm(R : real; L,D : byte) : string;
{ Преобразует число в строку с заданной точностью }
{ За неверное задание параметров отвечает пользователь  этого модуля }
var
   p : integer;
   q : real;
   S,V : string;
begin
  if R=0.0 Then begin GetRealStrForm := '0'; Exit end;
  p := Trunc(Ln(Abs(R)) / Ln(10));
  if (p<(L-2)) and (p>=0) Then
     begin
       Str(R:L:d,S);
       if fTruncLastPart and (pos('.',s)>0) Then begin
          while s[Length(s)]='0' do delete(s,Length(s),1);
          if s[Length(s)]='.' Then delete(s,Length(s),1) end
     end else begin
       if p<0 Then Dec(p);
       q := R * Exp(-p*Ln(10));
       Str(p:4,V);
       if fE_UpCase Then V:='E'+Trim(V) else V:='e'+Trim(V);
       Str(q:d+3:d,S);
       if fTruncLastPart and (pos('.',s)>0) Then begin
          while s[Length(s)]='0' do delete(s,Length(s),1);
          if s[Length(s)]='.' Then delete(s,Length(s),1) end;
       S:=S+V;
     end;
  GetRealStrForm:=S;
end;

function GetRealStrFormLPad(R : real; L,D : byte) : string;
{ Возвращает строку заданного размера с заданной точностью }
begin
  GetRealStrFormLPad := LeftPad(GetRealStrForm(r,l,d),l);
end;

procedure WriteCharToScreen(c:char);
{ DOSовский вывод на экран, позволяет перенаправлять вывод ">" }
var Regs : Registers;
begin
  Regs.ah:=2;
  Regs.dl:=byte(c);
  MSDos(Regs)
end;

procedure WriteToScreen(s:string);
{ Вывод на экран строки через DOS }
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
{ Аналог POS, но ищет справа налево }
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
{ Перехватчик ^C }
begin
CBreakPressed:=true;
end;

procedure SetDivZeroFlag; Interrupt;
{ Перехватчик деления на нуль }
begin
DivideOnZero:=true;
end;
{$F-}

procedure SetBreakInt;
{ Устанавливает ловушку ^Break }
begin
   GetIntVec($1B,Int1BSave);
   SetIntVec($1B,Addr(LookBreak))
end;

procedure RestoreBreakInt;
{ Восстанавливает ловушку ^Break }
begin
   SetIntVec($1B,Int1BSave)
end;

procedure SetDivZeroInt;
{ Устанавливает ловушку деления на нуль }
begin
   GetIntVec($00,Int00Save);
   SetIntVec($00,Addr(SetDivZeroFlag))
end;

procedure RestoreDivZeroInt;
{ Восстанавливает ловушку деления на нуль }
begin
   SetIntVec($00,Int00Save)
end;

procedure BEEP;
{ звуковой сигнал, аналог процедуры BASICa }
begin
Sound(800); Delay(250); NoSound
end;

procedure ClearKeyBuf;
{ очищает буфер клавиатуры }
var Key : Word;
begin
  while keypressed or MousePressed do Key:=ReadKeyOrButton;
  CBreakPressed:=false
end;

procedure TimeOrKeyPress(t : LongInt);
{ ожидает, пока не пройдет время или будет нажата клавиша или кнопка мыши }
var
    i:LongInt;
begin
  ClearKeyBuf;
  i:=TimeMS; t:=t+i;
  while (TimeMS<t) and (not keyPressed) and (not MousePressed) do ;
  if KeyPressed or MousePressed Then TimeKey_Word := ReadKeyOrButton
                                else TimeKey_Word := 0;
  ClearKeyBuf;
end;

procedure DrawTextBox(X1, Y1, X2, Y2 : byte;
                      Frame : FrameChars; FrameAttr : Byte);
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

procedure DrawTextBoxWin( X1, Y1, X2, Y2 : byte;
                          Frame : FrameChars; FrameAttr : Byte);
{ рисует рамку относительно координат окна }
var
  W, H, Y: Word;
begin
  W := X2 - X1 + 1;
  H := Y2 - Y1 + 1;
  FastFillWindow (   1, Frame[1],  Y1,  X1, FrameAttr);
  FastFillWindow ( W-1, Frame[2],  Y1,X1+1, FrameAttr);
  FastFillWindow (   1, Frame[3],  Y1,  X2, FrameAttr);
  for Y := 1 to H - 2 do
  begin
    FastFillWindow (   1, Frame[4],Y1+Y,  X1, FrameAttr);
    FastFillWindow (   1, Frame[5],Y1+Y,  X2, FrameAttr);
  end;
  FastFillWindow (   1, Frame[6],  Y2,  X1, FrameAttr);
  FastFillWindow ( W-1, Frame[7],  Y2,X1+1, FrameAttr);
  FastFillWindow (   1, Frame[8],  Y2,  X2, FrameAttr);
end;

function HyperLength(s : string) : byte;
{ Возвращает истинную длину строки формата Hyper }
var
   l  : byte;
   Pt : byte;
begin
  l := 0;
  while pos('~',s)>0 do
     begin
       Pt := pos('~',s);
       if (Pt=pos('~~',s)) or (Pt=Length(s)) Then
          begin
            Inc(L,Pt);
            Delete(s,1,Pt+1);
          end else begin
             Inc(l,Pt-1);
             if UpCase(s[Pt+1])='A' Then Delete(s,Pt,2);
             Delete( s, 1, Pt+1)
          end
     end;
  Inc(l,Length(s));
end;

procedure HyperWrite (S : string; y, x : byte);
{ Вывод строки в формате Hyper (абсолютные координаты) }
var T,A : string;
    Pt,
    C,i : byte;
    code : integer;
begin
  if S='' Then Exit;
  C := cwHyperColor0; A := S; T := '';
  while pos('~',A)>0 do
     begin
       Pt := pos('~',A);
       if (Pt=pos('~~',A)) or (Pt=Length(A)) Then
          begin
            T := T + copy(A,1,Pt);
            Delete(A,1,Pt+1);
          end else begin
            T := T + copy(A,1,Pt-1);
            if Length(T) > 0 Then
               begin
                 FastWrite(T,Y,X,C); Inc(X,Length(T)); T[0] := #0
               end;
             case A[Pt+1] of
               '1'  : C := cwHyperColor1; { Установить атрибут N1 }
               '2'  : C := cwHyperColor2; { Установить атрибут N2 }
               '3'  : C := cwHyperColor3; { Установить атрибут N2 }
           'A','a'  : begin { Установить атрибут, значение которого
                             после символа 'A' задается в шестнадцате-
                             ричной форме - 2 байта }
                        if a[Pt+2] in HexSet Then
                           if a[Pt+3] in HexSet Then begin
                              Val('$'+a[Pt+2]+a[Pt+3],C,code);
                              Delete(A,Pt,2) end
                           else begin Val('$'+a[Pt+2],C,code);
                                Delete(A,Pt,1) end
                         else C :=  cwHyperColor0
                      end;
               else  C := cwHyperColor0;
             end;
             Delete( A, 1, Pt+1);
          end
     end;
  FastWrite(A,Y,X,C);
end;

procedure HyperWritePad(S : string; y, x, len : byte);
{ Вывод строки в формате Hyper (абсолютные координаты) с дополнением
  пробелами справа до указанной длины }
var
   i : byte;
begin
  i:= HyperLength(s);
  HyperWrite(s+CharStr(' ',Len-i),y,x)
end;

procedure HyperWriteWin (S : string; y, x : byte);
{ Вывод строки в формате Hyper (относительные координаты) }
var T,A : string;
    Pt,
    C,i : byte;
    code : integer;
begin
  if S='' Then Exit;
  C := cwHyperColor0; A := S; T := '';
  while pos('~',A)>0 do
     begin
       Pt := pos('~',A);
       if (Pt=pos('~~',A)) or (Pt=Length(A)) Then
          begin
            T := T + copy(A,1,Pt);
            Delete(A,1,Pt+1);
          end else begin
            T := T + copy(A,1,Pt-1);
            if Length(T) > 0 Then
               begin
                 FastWriteWindow(T,Y,X,C); Inc(X,Length(T)); T[0] := #0
               end;
             case A[Pt+1] of
               '1'  : C := cwHyperColor1; { Установить атрибут N1 }
               '2'  : C := cwHyperColor2; { Установить атрибут N2 }
               '3'  : C := cwHyperColor3; { Установить атрибут N2 }
           'A','a'  : begin { Установить атрибут, значение которого
                             после символа 'A' задается в шестнадцате-
                             ричной форме - 2 байта }
                        if a[Pt+2] in HexSet Then
                           if a[Pt+3] in HexSet Then begin
                              Val('$'+a[Pt+2]+a[Pt+3],C,code);
                              Delete(A,Pt,2) end
                           else begin Val('$'+a[Pt+2],C,code);
                                Delete(A,Pt,1) end
                         else C :=  cwHyperColor0
                      end;
               else  C := cwHyperColor0;
             end;
             Delete( A, 1, Pt+1);
          end
     end;
  FastWriteWindow(A,Y,X,C);
end;

procedure HyperWritePadWin(S : string; y, x, len : byte);
{ Вывод строки в формате Hyper (относительные координаты) с дополнением
  пробелами справа до указанной длины }
var
   i : byte;
begin
  i:= HyperLength(s);
  HyperWriteWin(s+CharStr(' ',Len-i),y,x)
end;

function _StrUpCase(s : string) : string;
{ Перевести строку в верхний регистр с учетом национальных символов }
var i,j : byte;
    t : string;
begin
  t := s;
  for i:= 1 to Length(t) do
      if t[i] in [#97..#122] Then Dec(t[i],32)
         else for j:=1 to XLatTableSize do
          if byte(t[i])=Lo(XLatTable[j]) Then t[i]:=char(Hi(XLatTable[j]));
  _StrUpCase := t
end;

function ZipFileName(S : string; Len : byte) : string;
{ Сокращает имя файла для вывода строки длины "не более" типа
  - "C:\...\ME\ME.EXE
        ^^^ - невмещающиеся имена подкаталогов заменяются "..." }
var T : string[6];
begin
 if Length(S)> Len Then
    begin
      t := Copy(S,1,3)+'...';
      Delete(S,1,Length(S)-Len);
      while (Length(S)>0) and (s[1]<>'\') do Delete(S,1,1);
      S := T + S
    end;
 ZipFileName := Pad(S,Len)
end;

end.
