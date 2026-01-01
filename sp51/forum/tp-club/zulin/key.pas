{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,R+,S+,V+,X-}
{$M 16384,0,0}
{*************************************************************************}
{*                                                                       *}
{*                   KEY - пpогpамма индикации кода                      *}
{*                   нажатой клавиши (и сканкода)                        *}
{*                   пеpехватывает 9 пpеpывание!                         *}
{*                                                                       *}
{*                   version 2.0                                         *}
{*                                                                       *}
{*   (C) Copyright BZSoft Inc., 1990-92.                                 *}
{*   (C) Portion copyright GalaSoft United Group International, 1992.    *}
{*                                                                       *}
{*   > Для свободного копиpования и использования (FREEWARE)             *}
{*                                                                       *}
{*************************************************************************}

program KeyScanCodeViewer;

uses TPCRT,TPString,Dos;
label cont;
var
   Key : word;
   kk,ww,
   ks    : byte;
   b,
   PR    : boolean;
   KbdIntVec : Procedure;
   kbdF : byte absolute $0040:$0017;
   kbdS : byte absolute $0040:$0018;

{$F+}
procedure Keysc; interrupt; assembler;
asm
        mov     dx, 60h
        in      al, dx
        cmp     al, 80h
        ja      @1
        mov     PR, true
        mov     KS, al
@1:
        pushf
        call    KbdIntVec
        sti
end;
{$F-}

function AKeyPressed : byte;
begin
if PR Then AKeyPressed := KS else AKeyPressed := $FF;
PR := false;
end;

procedure KeyStat;
var c : byte;
begin
FastWrite(BinaryB(kbdF),1,65,11);
FastWrite(BinaryB(kbdS),2,65,11);
if (kbdS and $40) = $40 Then c:=10 else c:=0;
if (kbdF and $40) = $40 Then inc(c,112);
FastWrite ('CapsLock',3,25,c);
if (kbdS and $20) = $20 Then c:=10 else c:=0;
if (kbdF and $20) = $20 Then inc(c,112);
FastWrite ('NumLock',3,34,c);
if (kbdS and $10) = $10 Then c:=10 else c:=0;
if (kbdF and $10) = $10 Then inc(c,112);
FastWrite ('ScrollLock',3,42,c);
if (kbdF and $1) = $1 Then c:=116 else c:=0;
FastWrite ('LShift',3,2,c);
if (kbdF and $2) = $2 Then c:=116 else c:=0;
FastWrite ('RShift',3,9,c);
if (kbdF and $4) = $4 Then c:=116 else c:=0;
FastWrite ('Ctrl',3,16,c);
if (kbdF and $8) = $8 Then c:=116 else c:=0;
FastWrite ('Alt',3,21,c);
end;

begin
CheckBreak := false;
Key:=0; b := true; PR := false; kk := 0; ww := kk; ClrScr;
Window (1,5,ScreenWidth,ScreenHeight-2);
FastWrite('0040h:0017h - ',1,50,3);
FastWrite('0040h:0018h - ',2,50,3);
WriteLn;
  GetIntVec($9,@KbdIntVec);
  SetIntVec($9,Addr(Keysc));
repeat
  b := Key = $011B;
  if not b Then FastWrite('Press ESC twice for exit',1,10,12)
           else FastWrite('Press ESC for exit      ',1,10,12);
  kk := AKeypressed;
  while kk>$80 {not keypressed} do
      begin
      KeyStat;
      kk := AKeypressed;
      end;
  if KeyPressed Then while KeyPressed do Key:=ReadKeyWord else Key := 0;
  if kk<>ww Then begin 
    TextAttr := 10; Write  ('   Key word ',HexW(Key));
    TextAttr :=  9; Write  ('h  ');
    TextAttr := 14; Write  ( '  Scancode ',kk:3,' (',HexB(Kk));
    TextAttr :=  9; Write  ( 'h'); TextAttr := 14; Write (')  ');
    TextAttr := 15; Write  ( '  Symbol - (',Lo(Key):3,') ');
    FastWriteWindow(Chr(Lo(Key)),WhereY,WhereX,15); WriteLn;
  end;
  ww := kk;
until b and (Key=$011B);
SetIntVec($9,@KbdIntVec);
FastWrite('                        ',1,10,7);
TextAttr := 7;
WriteLn(^M^J^M^J' Вы пользовались пpогpаммой опpеделения кодов нажатия клавиш KEY v2.0');
WriteLn(' (C) Copyright BZSoft Inc., 1990-92.');
WriteLn(' (C) Portion copyright GalaSoft United Group International, 1992.');
Window(1,1,ScreenWidth, ScreenHeight);
end.

                                              20 июля 1992.  Боpис Зулин.