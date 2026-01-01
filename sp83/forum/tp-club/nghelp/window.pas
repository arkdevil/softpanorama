{$A+,B-,E+,F-,I+,N-,O-,R-,V-}
{$UNDEF DEBUG}
{$IFDEF DEBUG} {$D+,L+,S+} {$ELSE} {$D-,L-,S-} {$ENDIF}
Unit Window;

Interface

Uses YNSystem,YNCrt,FastScr,StrInt;

Const MaxButton = 2;

Type LargeArray     = Array [1..32000] of Word;

     SaveScrPtr     = ^SaveScrRec;
     SaveScrRec     = Record
      X1,Y1,X2,Y2  : Byte;
      ScreenSize   : Word;
      SavedScr     : LargeArray;
     End;

     WindowOBJ      = Object
      vOpen         : Boolean;
      sWindowCoord  : WindowCoord; {From previous window}
      sWindMin,
      sWindMax      : Word;
      vBuffer       : SaveScrPtr;  {Buffer of saved screen}
      vWindowCoord  : WindowCoord;
      vRows,vCols   : Byte;
      vTitle        : StrScreen; {Eventuele boder message}
      vStyle        : BorderTypes; {Style of border}
      vColor        : Byte; {Window color}

      Constructor Init;
      Procedure   SetColor(Color : Byte);
      Procedure   SetSize(Rows,Cols : Byte;Style : BorderTypes);
      Procedure   SetTitle(Title : StrScreen);
      Procedure   ShowWindow(X,Y : Byte);
      Procedure   CloseWindow;
      Destructor  Done;
     End;


     MessageStrPtr  = ^StrRec;
     StrRec         = Record
      NextPtr   : MessageStrPtr;
      StrMes    : StrScreen;
     End;

     MessageOBJ     = Object
      vTotalStr     : Word;
      vFirstPtr     : MessageStrPtr;
      vMesWindow    : WindowOBJ;
      vMesColor     : Byte; {Color of text}
      vIndent       : Byte; {spaces at beginning and end}

      Constructor Init;
      Procedure   SetVars(IndentLvl,Color1 : Byte);
      Procedure   AddTitle(St : StrScreen);
      Procedure   AddLine(St : StrScreen);
      Function    Line(Nr : Word) : String;
      Procedure   ShowMessage;
      Destructor  Done;
     End;

     ButtonRec      = String[10];

     AskOBJ         = Object(MessageOBJ)
      vButton       : Array [1..MaxButton] of ButtonRec;
      vActiveButton,        {Aktieve button}
      vTotalButtons,        {number of buttons}
      vHColor,              {Highlighted color}
      vNColor       : Byte; {Normal color}

      Constructor Init;
      Procedure   AddButton(Bt : Str12);
      Procedure   DisplayButton;
      Procedure   Go(Var ExitChar : Char);
      Function    ButtonNum : Byte;
      Destructor  Done;
     End;


Function  SavePartScreen(X1,Y1,X2,Y2 : Byte) : SaveScrPtr;
Procedure RestorePartScreen(Var ScrPtr : SaveScrPtr);
Procedure DisposePartScreen(Var ScrPtr : SaveScrPtr);


Implementation


(*------- Code to save and restore screen. Needs YNCrt to function. -------*)

Function CalcSizeScreen(X1,Y1,X2,Y2 : Byte) : Word;
Begin
 CalcSizeScreen := ((X2-(X1-1))*(Y2-(Y1-1)))*2 + 6;
End;


Function SavePartScreen(X1,Y1,X2,Y2 : Byte) : SaveScrPtr;
Var TempScrPtr : SaveScrPtr;
    Loop,
    Count,
    TempSize,
    LenLine,
    Offset     : Word;
Begin
 TempSize := CalcSizeScreen(X1,Y1,X2,Y2);
 if TempSize>MaxAvail then
  Begin
   SavePartScreen := Nil;
   Exit;
  End;

 GetMem(TempScrPtr,TempSize);
 TempScrPtr^.X1 := Pred(X1); TempScrPtr^.Y1 := Y1;
 TempScrPtr^.X2 := X2;       TempScrPtr^.Y2 := Y2;
 With TempScrPtr^ Do
  Begin
   ScreenSize := TempSize;
   Count      := 1;
   LenLine    := X2-X1;
   For Loop := Y1 to Y2 Do
    Begin
     OffSet := VideoOfs + (X1*2) + (MaxCols*2*(Loop-1));
     MoveFromScreen(Mem[VideoSeg:OffSet],SavedScr[Count],LenLine);
     Inc(Count,LenLine);
    End;
  End;
 SavePartScreen := TempScrPtr;
End;


Procedure RestorePartScreen(Var ScrPtr : SaveScrPtr);
Var Loop     : Byte;
    LenLine,
    Count,
    Offset   : Word;
Begin
 if ScrPtr=Nil then Exit;

 With ScrPtr^ Do
  Begin
   Count   := 1;
   LenLine := X2-X1;
   For Loop := Y1 to Y2 Do
    Begin
     OffSet := VideoOfs + (X1*2)+(MaxCols*2*(Loop-1));
     MoveToScreen(SavedScr[Count],Mem[VideoSeg:OffSet],LenLine);
     Count := Count + LenLine; {*2 voor attr}
    End;
  End;
End;


Procedure DisposePartScreen(Var ScrPtr : SaveScrPtr);
Begin
 if ScrPtr=Nil then Exit;

 FreeMem(ScrPtr,ScrPtr^.ScreenSize);
 ScrPtr := Nil;
End;

(*---------------- End Code to save and restore screen. -------------------*)

Constructor WindowOBJ.Init;
Begin
 vOpen           := False;
 vWindowCoord.X1 := 10;
 vWindowCoord.Y1 := 5;
 vWindowCoord.X2 := 70;
 vWindowCoord.Y2 := 20;
 vStyle          := SingleBrdr;
 vTitle          := '';
 sWindowCoord    := Screen.vWindow;
 sWindMax        := YNCrt.WindMax;
 sWindMin        := YNCrt.WindMin;
 vColor          := White+CyanBG;
 vBuffer         := Nil;
End;

Procedure WindowOBJ.SetColor(Color : Byte);
Begin
 vColor := Color;
End;

Procedure WindowOBJ.SetSize(Rows,Cols : Byte;Style : BorderTypes);
Begin
 vRows  := Rows;
 vCols  := Cols;
 vStyle := Style;
End;

Procedure WindowOBJ.SetTitle(Title : StrScreen);
Begin
 vTitle := Title;
End;

Procedure WindowOBJ.ShowWindow(X,Y : Byte);
Begin
 vOpen := True;
 With vWindowCoord Do
  Begin
   X1 := X;
   Y1 := Y;
   X2 := Succ(X+vCols);
   Y2 := Succ(Y+vRows);
   if vBuffer=Nil then vBuffer := SavePartScreen(X1,Y1,X2,Y2);
   Screen.BoxEngine(X1,Y1,X2,Y2,vColor,vStyle,True);
   Screen.TitleEngine(X1,Y1,X2,Y2,vTitle);

   if vStyle=NoBrdr then
    Screen.SetWindow(X1,Y1,X2,Y2)
    Else Screen.SetWindow(Succ(X1),Succ(Y1),Pred(X2),Pred(Y2));
  End;

End;


Procedure WindowOBJ.CloseWindow;
Begin
 if vOpen then
  Begin
   RestorePartScreen(vBuffer);
   Screen.vWindow := sWindowCoord;
   YNCrt.WindMax  := sWindMax;
   YNCrt.WindMin  := sWindMin;
  End;
 vOpen := False;
End;

Destructor WindowOBJ.Done;
Begin
 CloseWindow;
 DisposePartScreen(vBuffer);
End;

(*--------------------------------------------------------------------------*)

Constructor MessageOBJ.Init;
Begin
 vMesWindow.Init;
 vTotalStr := 0;
 vFirstPtr := Nil;
 vMesColor := White+CyanBG;
 vIndent   := 1;
End;

Procedure MessageOBJ.SetVars(IndentLvl,Color1 : Byte);
Begin
 vIndent   := IndentLvl;
 vMesColor := Color1;
End;

Procedure MessageOBJ.AddTitle(St : StrScreen);
Begin
 vMesWindow.SetTitle(St);
End;

Procedure MessageOBJ.AddLine(St : StrScreen);

  Function LastPtr : MessageStrPtr;
  Var P : MessageStrPtr;
  Begin
   P := vFirstPtr;
   While P^.NextPtr<>Nil Do P := P^.NextPtr;
   LastPtr := P;
  End;

Var P : MessageStrPtr;
Begin
 if vTotalStr>=MaxRows-2 then Exit;
 if MaxAvail<5+Length(St) then Exit;

 if vFirstPtr=Nil then
  Begin
   GetMem(vFirstPtr,5+Length(St));
   vFirstPtr^.NextPtr := Nil;
   vFirstPtr^.StrMes  := St;
  End Else Begin
            P := LastPtr;
            GetMem(P^.NextPtr,5+Length(St));
            P := P^.NextPtr;
            P^.NextPtr := Nil;
            P^.StrMes  := St;
           End;
 Inc(vTotalStr);
End;

Function MessageOBJ.Line(Nr : Word) : String;
Var Loop : Byte;
    P    : MessageStrPtr;
Begin
 P := vFirstPtr;
 For Loop := 2 to Nr Do
  Begin
   P := P^.NextPtr;
  End;

 if P=Nil then Line := ''
  Else Line := P^.StrMes;
End;

Procedure MessageOBJ.ShowMessage;

  Function MaxLength : Byte;
  Var P : MessageStrPtr;
      L : Byte;
  Begin
   P := vFirstPtr;
   L := Length(vFirstPtr^.StrMes);
   While P^.NextPtr<>Nil Do
    Begin
     P := P^.NextPtr;
     if Length(P^.StrMes)>L then L := Length(P^.StrMes);
    End;
   L := L + vIndent*2;
   if L>MaxCols-2 then L := MaxCols-2;
   MaxLength := L;
  End;

Var Len,
    R,C,
    Loop       : Byte;
    S          : StrScreen;
Begin
 if vTotalStr=0 then Exit;

 Len := MaxLength;

 With vMesWindow Do
  Begin
   SetSize(vTotalStr,Len,DoubleBrdr);
   SetColor(vColor);
   R := (MaxRows-vTotalStr) Div 2;
   C := (MaxCols-Len) Div 2;
   ShowWindow(C,R);

   For Loop := 1 to vTotalStr Do With Screen Do
    Begin
     S := Line(Loop);
     Case S[1] of
      '^' : Begin
             Delete(S,1,1);
             WriteCenter(Loop,vColor,S);
            End;
      Else FastWrite(1+vIndent,Loop,vColor,S);
     End;{case}
    End;
  End;
End;

Destructor MessageOBJ.Done;
Var P,P2 : MessageStrPtr;
Begin
 vMesWindow.Done;
 P := vFirstPtr;
 While P<>Nil Do
  Begin
   P2 := P^.NextPtr;
   FreeMem(P,5+Length(P^.StrMes));
   P := P2;
  End;
End;

(*--------------------------------------------------------------------------*)

Constructor AskOBJ.Init;
Begin
 MessageOBJ.Init;
 vActiveButton := 1;
 vTotalButtons := 0;
 vHColor       := White+BlackBG;
 vNColor       := White+CyanBG;
End;

Procedure AskOBJ.AddButton(Bt : Str12);
Begin
 if vTotalButtons>=MaxButton then Exit;
 Inc(vTotalButtons);
 vButton[vTotalButtons] := Bt;
End;

Procedure AskOBJ.DisplayButton;
Var Len,
    Loop,
    XPos,
    C     : Byte;
Begin
 With vMesWindow Do
  Begin
   Len := 0;
   For Loop := 1 to vTotalButtons Do Len := Len + Length(vButton[Loop]) + 3;

   XPos := (vCols Div 2) - (Len Div 2);
  End;
 C := XPos;

 For Loop := 1 to vTotalButtons Do With Screen Do
  Begin
   if Loop=vActiveButton then
    FastWrite(XPos,vTotalStr,vHColor,Space+vButton[Loop]+Space)
    Else FastWrite(XPos,vTotalStr,vNColor,Space+vButton[Loop]+Space);
   XPos := XPos + (3+Length(vButton[Loop]));
  End;
End;

Procedure AskOBJ.Go(Var ExitChar : Char);
Var Ch         : Char;
    CursorSize : Word;
Begin
 AddLine('');
 ShowMessage;
 CursorSize := GetCursorShape; HideCursor;
 vActiveButton := 1;

 Repeat
  DisplayButton;
  Ch := ReadKey;
  if Ch=#0 then
   Begin
    Ch := ReadKey;
    Case Ch of
     #77 : if vTotalButtons=vActiveButton then vActiveButton := 1
            Else Inc(vActiveButton);
     #75 : if vActiveButton=1 then vActiveButton := vTotalButtons
            Else Dec(vActiveButton);
    End;{Case}
   End Else Begin

            End;
 Until (Ch=#13) Or (Ch=#27);

 ExitChar := Ch;
 SetCursorShape(CursorSize);
End;

Function AskOBJ.ButtonNum : Byte;
Begin
 ButtonNum := vActiveButton;
End;

Destructor AskOBJ.Done;
Begin
 MessageOBJ.Done;
End;



End.