{$A+,B-,E+,F-,I+,N-,O-,R-,V-}
{$UNDEF DEBUG}
{$IFDEF DEBUG} {$D+,L+,S+} {$ELSE} {$D-,L-,S-} {$ENDIF}
{$DEFINE USECRT}
Unit FastScr;

Interface

Uses YNSystem{$IFDEF USECRT},YNCRT{$ENDIF};


Type BorderTypes               = (NoBrdr,
                                  SpaceBrdr,SingleBrdr,DoubleBrdr,
                                  HorizDoubleVertSingleBrdr,
                                  HorizSingleVertDoubleBrdr,
                                  Hatch1Brdr,Hatch2Brdr,Hatch3Brdr);

     Borders                   = (HorizTop, HorizBottom,
                                  VertLeft, VertRight, HorizBorders,
                                  VertBorders, AllBorders);
     BorderParts               = (TL,TR,BL,BR,HT,HB,VR,VL,LC,RC,TC,BC,CC);
     BorderArray               = Array[TL..CC] of Char;

Const Black                     = $00;
      Blue                      = $01;
      Green                     = $02;
      Cyan                      = $03;
      Red                       = $04;
      Magenta                   = $05;
      Brown                     = $06;
      LightGray                 = $07;
      DarkGray                  = $08;
      LightBlue                 = $09;
      LightGreen                = $0A;
      LightCyan                 = $0B;
      LightRed                  = $0C;
      LightMagenta              = $0D;
      Yellow                    = $0E;
      White                     = $0F;
      Blink                     = $80;
      BlackBG                   = $00;
      BlueBG                    = $10;
      GreenBG                   = $20;
      CyanBG                    = $30;
      RedBG                     = $40;
      MagentaBG                 = $50;
      BrownBG                   = $60;
      LightGrayBG               = $70;

      BorderSt                 : Array [SpaceBrdr..Hatch3Brdr] of
                                  BorderArray=
                                  ('█████████████',
                                   '┌┐└┘──││├┤┬┴┼',
                                   '╔╗╚╝══║║╠╣╦╩╬',
                                   '╒╕╘╛══││╞╡╤╧╪',
                                   '╓╖╙╜──║║╟╢╥╙╫',
                                   '░░░░░░░░░░░░░',
                                   '▒▒▒▒▒▒▒▒▒▒▒▒▒',
                                   '▓▓▓▓▓▓▓▓▓▓▓▓▓');


Type StrScreen   = String[80];

     WindowCoord = Record
      X1,Y1,X2,Y2 : Byte;
     End;

     DisplayOBJ  = Object
      vScreenPtr    : Pointer;
      vWindow       : WindowCoord;
      vWindowIgnore : Boolean;
      vWidth        : Byte;

      Constructor Init;
      Procedure   FastWrite(X,Y,Attr : Byte;St : StrScreen);
      Procedure   FastPWrite(X,Y : Byte;St : StrScreen);
      Procedure   WriteCenter(Y,Attr : Byte;St : StrScreen);
      Procedure   WriteHi(X,Y,AttrHi,Attr : Byte;St : StrScreen);
      Procedure   ChangeAttr(X,Y,Attr,Len : Byte);
      Function    ReadChar(X,Y : Byte) : Char;
      Function    ReadScreenLn(Y : Byte) : String;
      Procedure   SetWindow(X1,Y1,X2,Y2 : Byte);
      Procedure   TitleEngine(X1,Y1,X2,Y2 : Byte;Title : StrScreen);
      Procedure   BoxEngine(X1,Y1,X2,Y2,Attr : Byte;Bordertype : BorderTypes;
                            Filled : Boolean);
      Function    WhereX : Byte;
      Function    WhereY : Byte;
      Procedure   GotoXY(X,Y : Byte);
      Destructor  Done;
     End;



Var Screen : DisplayOBJ;

Implementation

(*------ Externals ---------------------------------------------------------*)
{$L FASTSCR.OBJ}
{$F+}
Procedure AsmWrite(Var ScrPtr;Wid,Col,Row,Attr : Byte;St : String); External;
Procedure AsmPWrite(Var ScrPtr;Wid,Col,Row : Byte;St : String);     External;
Procedure AsmAttr(Var ScrPtr;Wid,Col,Row,Attr,Len : Byte);          External;
Procedure AsmMoveFromScreen(Var Source,Dest;Length : Word);         External;
Procedure AsmMoveToScreen(Var Source,Dest;Length : Word);           External;
{$F-}
(*--------------------------------------------------------------------------*)

Function Duplicate(Ch : Char;Times : Byte) : String;
Var F : String;
Begin
 FillChar(F,Times+1,Ch);
 Byte(F[0]) := Times;
 Duplicate := F;
End;

(*--------------------------------------------------------------------------*)

Procedure FillWord(Var Dest;Width,Value : Word);
Begin
 if CheckSnow then
  Inline($C4/$BE/Dest/            {         LES     DI,Dest[BP]       }
         $8B/$8E/Width/           {         MOV     CX,Width[BP]      }
         $8B/$9E/Value/           {         MOV     BX,Value[BP]      }
         $FC/                     {         CLD                       }
         $E3/$16/                 {         JCXZ    READY             }
         $BA/$03DA/               {         MOV     DX,3DAH           }
         $B4/$09/                 {         MOV     AH,9              }
         $EC/                     { TEST1:  IN      AL,DX             }
         $D0/$D8/                 {         RCR     AL,1              }
         $72/$FB/                 {         JB      TEST1             }
         $FA/                     {         CLI                       }
         $EC/                     { TEST2:  IN      AL,DX             }
         $22/$C4/                 {         AND     AL,AH             }
         $74/$FB/                 {         JZ      TEST2             }
         $8B/$C3/                 {         MOV     AX,BX             }
         $AB/                     {         STOSW                     }
         $FB/                     {         STI                       }
         $E2/$EF) Else            {         LOOP    TEST1             }
                                  { READY:                            }
  Inline($C4/$BE/Dest/            {         LES     DI,Dest[BP]       }
         $8B/$8E/Width/           {         MOV     CX,Width[BP]      }
         $8B/$86/Value/           {         MOV     AX,Value[BP]      }
         $FC/                     {         CLD                       }
         $F3/$AB);                {         REP     STOSW             }
End;


Constructor DisplayOBJ.Init;
Begin
 vScreenPtr    := VideoPtr;
 vWidth        := MaxCols;
 vWindowIgnore := False;

 vWindow.X1 := 1;
 vWindow.Y1 := 1;
 vWindow.X2 := MaxCols;
 vWindow.Y2 := MaxRows;
End;

Procedure DisplayOBJ.FastWrite(X,Y,Attr : Byte;St : StrScreen);
Begin
 if vWindowIgnore then
  AsmWrite(vScreenPtr^,vWidth,X,Y,Attr,St)
  Else Begin
        St := Copy(St,1,vWindow.X2-Pred(X)-Pred(vWindow.X1));
        if Y+Pred(vWindow.Y1) <= vWindow.Y2 then
        AsmWrite(vScreenPtr^,vWidth,Pred(vWindow.X1)+X,Pred(vWindow.Y1)+Y,
                 Attr,St);
       End;
End;

Procedure DisplayOBJ.FastPWrite(X,Y : Byte;St : StrScreen);
Begin
 if vWindowIgnore then
  ASMPWrite(vScreenPtr^,vWidth,X,Y,St)
  Else Begin
        St := Copy(St,1,vWindow.X2-Pred(X)-Pred(vWindow.X1));
        if Y+Pred(vWindow.Y1) <= vWindow.Y2 then
        ASMPWrite(vScreenPtr^,vWidth,Pred(vWindow.X1)+X,Pred(vWindow.Y1)+Y,St);
       End;
End;

Procedure DisplayOBJ.WriteCenter(Y,Attr : Byte;St : StrScreen);
Var X : Integer;
Begin
 if vWindowIgnore then
  Begin
   X :=  (MaxCols - Length(St)) Div 2;
   if X < 1 then X := 1;
  End Else Begin
            X := (Succ(vWindow.X2-vWindow.X1) - Length(St)) Div 2;
           End;
 FastWrite(X,Y,Attr,St);
End;

Procedure DisplayOBJ.WriteHi(X,Y,AttrHi,Attr : Byte;St : StrScreen);
Const HiMarker = '~';

Var P  : Byte;
    Hi : Boolean;

  Procedure WriteBit(St : StrScreen);
  Begin
   if Hi then FastWrite(X,Y,AttrHi,St)
    Else FastWrite(X,Y,Attr,St);
  End;

Begin
 Hi := False;
 P := Pos(HiMarker,St);
 While P <> 0 do
  Begin
   if P > 1 then
   WriteBit(Copy(St,1,pred(P)));
   Delete(St,1,P);
   Inc(X,Pred(P));
   P := Pos(HiMarker,St);
   Hi := Not Hi;
  End;
 WriteBit(St);
End;


Procedure DisplayOBJ.ChangeAttr(X,Y,Attr,Len : Byte);
Begin
 if vWindowIgnore then
  ASMAttr(vScreenPtr^,vWidth,X,Y,Attr,Len)
  Else Begin
        Inc(X,Pred(vWindow.X1));
        Inc(Y,Pred(vWindow.Y1));
        if (X <= vWindow.X2) and (Y <= vWindow.Y2) then
         Begin
          if X + Len > vWindow.X2 then
           Len := vWindow.X2 - Pred(X);
          ASMAttr(vScreenPtr^,vWidth,X,Y,Attr,Len)
         End;
       End;
End;

Function DisplayOBJ.ReadChar(X,Y : Byte) : Char;
Var Offset : Word;
    Ch     : Word;
    ChA    : Array [1..2] of Byte Absolute Ch;
Begin
 ReadChar := #0;
 if (X>MaxCols) Or (Y>Succ(vWidth)) then Exit;

 Offset := Ofs(vScreenPtr^) + Pred(X)*2 + Pred(Y)*MaxCols*2;
 AsmMoveFromScreen(Mem[Seg(vScreenPtr^):Offset],Ch,1);
 ReadChar := Char(ChA[1]);
End;

Function DisplayOBJ.ReadScreenLn(Y : Byte) : String;
Var S    : String;
    Loop : Byte;
Begin
 For Loop := 1 to MaxCols Do
  S[Loop] := ReadChar(Loop,Y);
 Byte(S[0]) := Loop;
 ReadScreenLn := S;
End;

Procedure DisplayOBJ.SetWindow(X1,Y1,X2,Y2 : Byte);
Begin
{$IFDEF USECRT}
 YNCRT.Window(X1,Y1,X2,Y2);
{$ENDIF}
 vWindow.X1 := X1;
 vWindow.Y1 := Y1;
 vWindow.X2 := X2;
 vWindow.Y2 := Y2;
End;

Procedure DisplayOBJ.TitleEngine(X1,Y1,X2,Y2 : Byte;Title : StrScreen);
Var sWindowIgnore : Boolean;
    Width         : Integer;
Begin
 sWindowIgnore := vWindowIgnore;
 vWindowIgnore := True;

 Width := (X2-X1)-2;

 if (Width>1) And (Title<>'') then
  Begin
   Delete(Title,Succ(Width),255);

   FastPWrite(X1+2,Y1,'['+ Title + ']');
  End;

 vWindowIgnore := sWindowIgnore;
End;

Procedure DisplayOBJ.BoxEngine(X1,Y1,X2,Y2,Attr : Byte;
                               Bordertype : BorderTypes;Filled : Boolean);
Var sWindowIgnore : Boolean;
    Loop          : Byte;
Begin
 sWindowIgnore := vWindowIgnore;
 vWindowIgnore := True;

 FastWrite(X1,Y1,Attr,BorderSt[BorderType,TL] +
                      Duplicate(BorderSt[BorderType,HT],Pred(X2-X1)) +
                      BorderSt[BorderType,TR]);

 if Filled then
  For Loop := Succ(Y1) to Pred(Y2) Do
   Begin
    FastWrite(X1,Loop,Attr,BorderSt[BorderType,VL]+Duplicate(' ',Pred(X2-X1))+
                           BorderSt[BorderType,VR]);
   End
  Else For Loop := Succ(Y1) to Pred(Y2) Do
        Begin
         FastWrite(X1,Loop,Attr,BorderSt[BorderType,VL]);
         FastWrite(X2,Loop,Attr,BorderSt[BorderType,VR]);
        End;

 FastWrite(X1,Y2,Attr,BorderSt[BorderType,BL] +
                      Duplicate(BorderSt[BorderType,HB],Pred(X2-X1)) +
                      BorderSt[BorderType,BR]);

 vWindowIgnore := sWindowIgnore;
End;

Function DisplayOBJ.WhereX : Byte;
Begin
 WhereX := YNCrt.WhereX;
End;

Function DisplayOBJ.WhereY : Byte;
Begin
 WhereY := YNCrt.WhereY;
End;

Procedure DisplayOBJ.GotoXY(X,Y : Byte);
Begin
 YNCrt.GotoXY({Pred(vWindow.X1)+}X,{Pred(vWindow.Y1)+}Y);
End;

Destructor DisplayOBJ.Done;
Begin
End;




Begin
 Screen.Init;
End.