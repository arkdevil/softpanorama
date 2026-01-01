{$A+,B-,E+,F-,I+,N-,O-,R-,V-}
{$DEFINE DEBUG}
{$IFDEF DEBUG} {$D+,L+,S+} {$ELSE} {$D-,L-,S-} {$ENDIF}
Unit NGCL;

Interface

Uses YNSystem,YNDos,YNCrt,FastScr,StrInt,Invoer,Help_Var,Window,NG;

Procedure InitVars_NG;
Procedure ChangeWindowSize(Big : Boolean);
Procedure LookUp(Beep : Boolean);

Procedure LoadNGGuide;
Procedure ProccessKeyStrokeNG; {Proccess a key stroke}
Procedure BuildScreenNG; {Build ng screen from nothing}

Procedure StartNG;


Implementation


Const MaxMenuBars = 13;
      MaxPull     = 8;

Type PullRec = Record
      PullName   : Array [1..MaxPull] of String[20]; {naam pulldown menu}
      PullEntry  : Array [1..MaxPull] of Longint;
     End;
     MenuStr = String[10];
     SubStr  = String[25];

Var UpdateMenu    : Boolean; {When to refresh BG's menu}
    UpdateSub     : Boolean;
    SubMenuActive : Boolean; {Needed to filter out keystrokes}
    (* Menu interface voor NG *)
    MainMenuStr   : Array [1..MaxMenuBars] of MenuStr;{Standaard menus}
    PullInfo      : Array [3..MaxMenuBars] of PullRec;
    MainMenuCount : Byte; {Max 255 mainmenus}
    MainMenuBar   : Byte; {Highlighted menu}
    PullMenuBar   : Byte;
    SeeAlsoBar    : Byte;
    MainNum,
    PullNum       : Byte; {Voor Tag}
    DrawSub       : Boolean; {Draw the submenu from scratch}
    SubMenu       : WindowOBJ;
        (* Var voor het norton guide hulp gedeelte *)
    Short         : Boolean;
    GuideMenu     : GuideMenuOBJ;
    GuideShort    : GuideShortOBJ;
    GuideLong     : GuideLongOBJ;

    HTekst,STekst : Longint;


Procedure NGHelpScreen;
Var ExitCode : Char;
    Loop     : Byte;
Begin
 With AskWindow Do
  Begin
   Init;
   AddTitle(' About Help''s Norton Guide Cloon ');
   AddLine(FillStr(Space,72));
   AddLine('      <esc>  Back one level        <->  Show Previous long entry');
   AddLine('      F9     Full/Half screen      <+>  Show Next long entry');
   AddLine('^F10    Exit the guide');
   AddLine('');
   AddLine('^The Norton Guide Cloon incorporated in HELP');
   AddLine('^Copyright 1991 by Yvo Nelemans');
   AddLine('');

   For Loop := 1 to 5 Do AddLine('    '+Copy(Credit(Loop),1,70));
   AddLine('');

   AddButton('Ok');
   Go(ExitCode);
   Done;
  End;
End;

Procedure ChangeColor(Color : Boolean);
Begin
 Default.Color := Color;

 if Not Color then
  Begin {Maak Black/White}
   WindowC_NG := LightGray+BlackBG;
   WindowH_NG := Black+LightGrayBG;
   MenuC_NG   := White+BlackBG;
   BoldFase   := White+BlackBG;
   UnderLine  := Green+BlackBG;
   Reverse    := Black+LightGrayBG;
  End Else Begin {Maak Color}
            WindowC_NG := LightCyan+BlueBG;
            WindowH_NG := Black+CyanBG;
            MenuC_NG   := Yellow+BlueBG;
            BoldFase   := Yellow+BlueBG;
            UnderLine  := LightMagenta+BlueBG;
            Reverse    := Black + CyanBG;
           End;
End;

Procedure ChangeWindowSize(Big : Boolean);
Begin
 X1_NG := 1; X2_NG := 80;

 Default.BigScreen := Big;

 if Not Big then
  Begin
   if YPosition>12 then
    Begin
     Y1_NG  :=  1;
     Y2_NG  := Y1_NG+11;
    End Else Begin
              Y2_NG := MaxRows;
              Y1_NG := Y2_NG-11;
             End;
  End Else Begin
            Y1_NG  :=  1;
            Y2_NG  := MaxRows;
           End;
End;

Procedure InitVars_NG;
Begin
 UpdateMenu    := False;
 UpdateSub     := False;
 SubMenuActive := False;
 DrawSub       := True;
 Short         := True;

 HTekst  := 1; STekst := 1;
 MainNum := 0; PullNum := 0;

 ChangeColor(Default.Color);
End;

Procedure FreeGuideMem;
Begin
 if NoGuide then Exit;
 if Short then
  With GuideShort Do Done
  Else With GuideLong Do Done;
End;

Procedure ClearMenuVars;
Begin
 MainMenuBar    := 1; {Start met 'Expand' highlighted}
 MainMenuStr[1] := 'Expand';
 MainMenuStr[2] := 'Search...';
 MainMenuStr[3] := 'Options';
 FillChar(PullInfo,Sizeof(PullInfo),#0);
 PullInfo[3].PullName[1] := 'Database';
 PullInfo[3].PullName[2] := 'Color';
 PullInfo[3].PullName[3] := 'Full screen  F9';
 PullInfo[3].PullName[4] := 'Auto lookup';
 PullInfo[3].PullName[5] := 'Hot key';
 PullInfo[3].PullName[6] := 'Uninstall';
 PullInfo[3].PullName[7] := 'Save options';
{ PullInfo[3].PullName[8] := 'Go to THELP';}
 MainMenuCount  := 3; {3 menus}
 PullMenuBar    := 1;
End;

Procedure SubInfo(Var Len,Depth : Byte);
Var Loop : Byte;
Begin
 Len := Length(PullInfo[MainMenuBar].PullName[1]);
 Depth := 0;
 For Loop := 1 to MaxPull Do
  Begin
   if Length(PullInfo[MainMenuBar].PullName[Loop])>Len then
    Len := Length(PullInfo[MainMenuBar].PullName[Loop]);
   if Length(PullInfo[MainMenuBar].PullName[Loop])<>0 then Inc(Depth)
  End;
End;

Procedure ClearStatusLine;
Begin
 Screen.FastWrite(2,2,WindowC_NG,FillStr(Space,78));
End;

Procedure WriteSubMenu;
Var Len,Depth,
    Loop,XPos : Byte;
    St        : String[24];
Begin
 UpdateSub := False;
 if (MainMenuBar=1) Or (MainMenuBar=2) then Exit;

 XPos := 3;
 For Loop := 1 to Pred(MainMenuBar) Do
  XPos := XPos + Length(MainMenuStr[Loop]) + 2;
 SubInfo(Len,Depth);

 if DrawSub then
  Begin
   DrawSub := False;
   With SubMenu Do
    Begin
     Init;
     SetColor(WindowC_NG);
     SetSize(Depth,Len+3,SingleBrdr);
     if XPos+Len+4>79 then XPos := 79-(Len+4);
     ShowWindow(XPos,Y1_NG+2);
     With Screen Do
      Begin
       vWindowIgnore := True;
       FastPWrite(XPos,Y1_NG+2,#194);
       FastPWrite(XPos+Len+4,Y1_NG+2,#194);
       vWindowIgnore := False;
      End;
    End;
  End;

 For Loop := 1 to Depth Do With Screen Do
  Begin
   St := FillRight('  '+PullInfo[MainMenuBar].PullName[Loop],Len+3);
   if MainMenuBar=3 then
    Begin
     if (Loop=2) And Default.Color then St[1] := #251;
     if (Loop=4) And Default.AutoLookUp then St[1] := #251;
    End;

   if (MainMenuBar=MainNum) And (Loop=PullNum) then St[1] := #251;
   if Loop=PullMenuBar then
    FastWrite(1,Loop,WindowH_NG,St)
    Else FastWrite(1,Loop,MenuC_NG,St);
  End

End;

Procedure WriteMenuBar;
Var Loop,
    XPos,
    Color : Byte;
Begin
 if Not UpdateMenu then Exit;
 UpdateMenu := False;

 XPos := 3;
 With Screen Do
  Begin
   For Loop := 1 to MainMenuCount Do
    Begin
     if Loop=MainMenuBar then
      FastWrite(XPos,2,WindowH_NG,Space+MainMenuStr[Loop]+Space)
      Else FastWrite(XPos,2,MenuC_NG,Space+MainMenuStr[Loop]+Space);
     XPos := XPos + Length(MainMenuStr[Loop]) + 2;
    End;
  End;
 WriteSubMenu;
End;

Procedure ClearBar;
Begin
 Screen.ChangeAttr(2,HTekst-STekst+4,WindowC_NG,78);
End;

Procedure WriteBar;
Begin
 Screen.ChangeAttr(2,HTekst-STekst+4,WindowH_NG,78);
End;

Procedure FillWord(Var Dest;Width,Value : Word;Var XPos : Byte);
Begin
 Inc(XPos,Width);

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

Procedure WriteLine(St : Str80;LineNo : Word);
Var TxtPtr ,
    XPos,
    Color     : Byte;
    Position  : Word;
    EndPos    : Word;
    Key       : Char;
    TempKey   : Byte;

  Procedure GetChar;
  Begin
   Inc(TxtPtr);
   Key := St[TxtPtr];
  End;

  Procedure ProcesNum;
  Begin
   GetChar;
   if (Byte(Key)>47) And (Byte(Key)<58) then
    TempKey := Byte(Key)-48;
   if (Byte(Key)>64) And (Byte(Key)<71) then
    TempKey := Byte(Key)-55;
   TempKey := 16*TempKey;
   GetChar;
   if (Byte(Key)>47) And (Byte(Key)<58) then
    TempKey := TempKey + Byte(Key)-48;
   if (Byte(Key)>64) And (Byte(Key)<71) then
    TempKey := TempKey + Byte(Key)-55;
  End;

Begin
 TxtPtr   := 0;
 Color    := WindowC_NG;
 {Werkt alleen in 80 char mode}
 EndPos   := (LineNo-STekst+3+Screen.vWindow.Y1)*160-2;
 Position := EndPos - 156;
 XPos     := 2;

 With Screen Do
  While (TxtPtr<Byte(St[0])) And (XPos<=79) Do
   Begin
    GetChar;
    if Key<>'^' then {No NG code, write char}
     Begin
      if Key=#255 then {Expand spaces}
       Begin
        GetChar;
        FillWord(Mem[VideoSeg:Position],Byte(Key),
                 Byte(Space)+Color Shl 8,XPos);
        Inc(Position,Byte(Key)*2);
       End Else Begin
                 FillWord(Mem[VideoSeg:Position],1,Byte(Key)+Color Shl 8,XPos);
                 Inc(Position,2);
                End;
     End Else Begin
               GetChar;
               Key := Upcase(Key);
               Case Key of
                '^' : Begin
                       FillWord(Mem[VideoSeg:Position],1,
                                Byte(Key)+Color Shl 8,XPos);
                       Inc(Position,2);
                      End;
                'C' : Begin {Difficult char}
                       ProcesNum;
                       FillWord(Mem[VideoSeg:Position],1,TempKey+Color Shl 8,XPos);
                       Inc(Position,2);
                      End;
                'B' : Begin {BoldFase}
                       if Color=BoldFase then Color := WindowC_NG
                        Else Color := BoldFase;
                      End;
                'U' : Begin {UnderLine}
                       Color := UnderLine;
                      End;
                'R' : Begin {Reverse}
                       if Color=Reverse then Color := WindowC_NG
                        Else Color := Reverse;
                      End;
                'A' : Begin {Color attribuut}
                       ProcesNum;
                       Color := TempKey;
                      End;
                'N' : Begin {Normal color}
                       Color := WindowC_NG;
                      End;
               End;{Case}
              End;
   End;

 {Fill end with spaces}
 if Position<EndPos then
  FillWord(Mem[VideoSeg:Position],(EndPos-Position) Div 2,
           Byte(Space)+WindowC_NG Shl 8,XPos);

 if LineNo=HTekst then WriteBar;
End;

Function DepthTekst : Byte;
Begin
 DepthTekst := Y2_NG-Y1_NG-4;
End;

Procedure Midden(Max : Word);
Var Helft : Integer;
Begin
 if HTekst > Max then Exit;
 Helft := DepthTekst Div 2;
 if HTekst-Helft+1 < 1 then STekst := 1
   Else STekst := HTekst-Helft+1;
End;

Procedure WriteSeeAlso;
Var Loop : Byte;
    XPos : Byte;
Begin
 With Screen,GuideLong.SeeAlso Do
  Begin
   FastPWrite(3,2,'See also:');
   XPos := 13;
   For Loop := 1 to Count Do
    Begin
     if Loop=SeeAlsoBar then
      FastWrite(XPos,2,WindowH_NG,Space+Line(Loop)+Space)
      Else FastWrite(XPos,2,WindowC_NG,Space+Line(Loop)+Space);
     XPos := XPos + Length(Line(Loop)) + 2;
    End;
  End;
End;

Procedure WriteTekst;
Var Loop : Word;
Begin
 if NoGuide then Exit;

 if Short then With GuideShort Do
  Begin
   For Loop := STekst to STekst+DepthTekst Do
    WriteLine(RawLine(Loop),Loop);
  End Else With GuideLong Do
            Begin
             For Loop := STekst to STekst+DepthTekst Do
              WriteLine(RawLine(Loop),Loop);
             if SeeAlso.Count>0 then WriteSeealso;
            End;
End;

Procedure GoRight;
Begin
 if Short then
  Begin
   if MainMenuBar=MainMenuCount then MainMenuBar := 1
    Else Inc(MainMenuBar);
   if Not DrawSub then SubMenu.Done;
   PullMenuBar := 1;
   DrawSub     := True;
   UpdateMenu  := True;
  End Else With GuideLong.SeeAlso Do
            Begin
             if Count=0 then Exit;
             if SeeAlsoBar>=Count then SeeAlsoBar := 1
              Else Inc(SeeAlsoBar);
             WriteSeeAlso;
            End;
End;

Procedure GoLeft;
Begin
 if Short then
  Begin
   if MainMenuBar=1 then MainMenuBar := MainMenuCount
    Else Dec(MainMenuBar);
   if Not DrawSub then SubMenu.Done;
   PullMenuBar := 1;
   DrawSub     := True;
   UpdateMenu  := True;
  End Else With GuideLong.SeeAlso Do
            Begin
             if Count=0 then Exit;
             if SeeAlsoBar=1 then SeeAlsoBar := Count
              Else Dec(SeeAlsoBar);
             WriteSeeAlso;
            End;
End;

Procedure GoDown;
Var Len,Depth : Byte;
Begin
 if (MainMenuBar<>1) And (MainMenuBar<>2) then
  Begin
   SubInfo(Len,Depth);
   if PullMenuBar>=Depth then PullMenuBar := 1
    Else Inc(PullMenuBar);
   UpdateSub := True;
  End Else Begin
            if Short then
             With GuideShort Do
              Begin
               if HTekst<Count then
                Begin
                 ClearBar;
                 Inc(HTekst);
                 if HTekst>STekst+DepthTekst then Inc(STekst);
                 WriteTekst;
                End;
              End Else With GuideLong Do
                        Begin
                         if STekst+DepthTekst<Count then
                          Begin
                           Inc(STekst);
                           WriteTekst;
                          End;
                        End;
           End;
End;

Procedure GoUp;
Var Len,Depth : Byte;
Begin
 if (MainMenuBar<>1) And (MainMenuBar<>2) then
  Begin
   SubInfo(Len,Depth);
   if PullMenuBar=1 then PullMenuBar := Depth
    Else Dec(PullMenuBar);
   UpdateSub := True;
  End Else Begin
            if Short then
             With GuideShort Do
              Begin
               if HTekst>1 then
                Begin
                 ClearBar;
                 Dec(HTekst);
                 if HTekst<STekst then Dec(STekst);
                 WriteTekst;
                End;
              End Else With GuideLong Do
                        Begin
                         if STekst>1 then
                          Begin
                          Dec(STekst);
                          WriteTekst;
                         End;
                        End;
           End;
End;

Procedure GoHome;
Begin
 if (MainMenuBar<>1) And (MainMenuBar<>2) then
  Begin
   PullMenuBar := 1;
   UpdateSub := True;
  End Else Begin
            if Short then
             Begin
              ClearBar;
              HTekst := 1;
             End;
            STekst := 1;
            WriteTekst;
           End;
End;

Procedure GoEnd;
Var Len,Depth : Byte;
Begin
 if (MainMenuBar<>1) And (MainMenuBar<>2) then
  Begin
   SubInfo(Len,Depth);
   PullMenuBar := Depth;
   UpdateSub := True;
  End Else Begin
            if Short then
             With GuideShort Do
              Begin
               ClearBar;
               HTekst := Count;
               STekst := Count;
              End Else With GuideLong Do
                        Begin
                         STekst := Count;
                        End;
             if STekst-DepthTekst>1 then STekst := STekst-DepthTekst
              Else STekst := 1;
            WriteTekst;
           End;
End;

Procedure GoPgDn;
Var MaxCount : Longint;
Begin
 if (MainMenuBar<>1) And (MainMenuBar<>2) then
  Begin
   GoEnd;
  End Else Begin
            if Short then
             With GuideShort Do
              Begin
               ClearBar;
               MaxCount := Count;
               HTekst := HTekst+DepthTekst;
               if HTekst+DepthTekst>=Count then HTekst := Count;
               if HTekst<1 then HTekst := 1;
              End Else With GuideLong Do
                        Begin
                         MaxCount := Count;
                        End;

            STekst := STekst+DepthTekst;
            if STekst+DepthTekst>=MaxCount then STekst := MaxCount-DepthTekst;
            if STekst<1 then STekst := 1;
            WriteTekst;
           End;
End;

Procedure GoPgUp;
Begin
 if (MainMenuBar<>1) And (MainMenuBar<>2) then
  Begin
   GoHome;
  End Else Begin
            if Short then
             With GuideShort Do
              Begin
               ClearBar;
               if HTekst-DepthTekst>0 then HTekst := HTekst-DepthTekst
                Else HTekst := 1;
              End;

            if STekst-DepthTekst>0 then STekst := STekst-DepthTekst
             Else STekst := 1;
            WriteTekst;
           End;
End;

Procedure MakeBox;
Var S : String[80];
Begin
 With Screen Do
  Begin
   SetWindow(X1_NG,Y1_NG,X2_NG,Y2_NG);
   BoxEngine(X1_NG,Y1_NG,X2_NG,Y2_NG,WindowC_NG,DoubleBrdr,True);
   S := FillStr('─',78);
   FastWrite(X1_NG,3,WindowC_NG,'╟'+S+'╢');
  End;
End;

Procedure BuildScreenNG;
Begin
 MakeBox;
 WriteMenuBar;
 WriteTekst;
End;

Procedure ExpandTekst(NGEntry : Longint;Free : Boolean);
Begin
 if EntryType(NGEntry)=NoEntry then Exit;

 if Free then
  if Short then With GuideShort Do
   Begin
    ClearBar;
    Done;
   End Else With GuideLong Do
             Begin
              Done;
             End;

 Case EntryType(NGEntry) of
  ShortEntry : Begin
                UpdateMenu := True;
                Short := True;
                HTekst := 1; STekst := 1;
                With GuideShort Do
                 Begin
                  Load(NGEntry);
                 End;
               End;
  LongEntry  : Begin
                SeeAlsoBar := 1;
                Short := False;
                HTekst := 0; STekst := 1;
                With GuideLong Do
                 Begin
                  Load(NGEntry);
                 End;
                ClearStatusLine;
               End;
 End; {Case}

 if Short then With GuideShort Do
  Begin
   MainNum := MenuParent+4;
   PullNum := Succ(MenuLine);
  End Else With GuideLong Do
            Begin
             MainNum := MenuParent;
             PullNum := MenuLine;
            End;
End;

Procedure LookUp(Beep : Boolean);
Var Loop : Word;
    S    : String[30];
Begin
 if Short then With GuideShort Do
  Begin
   S := UpStr(SearchStr);
   if S='' then Exit;

   For Loop := Succ(HTekst) to Count Do
    Begin
     if Pos(S,UpStr(Line(Loop)))<>0 then
      Begin
       HTekst := Loop;
       Midden(Count);
       WriteTekst;
       Exit;
      End;
    End;

   For Loop := 1 to HTekst Do
    Begin
     if Pos(S,UpStr(Line(Loop)))<>0 then
      Begin
       HTekst := Loop;
       Midden(Count);
       WriteTekst;
       Exit;
      End;
    End;
   if Beep then
    Begin
     Sound(1000);
     Delay(200);
     NoSound;
    End;
  End;
End;

Procedure SearchGuide;
Var SRWindow : WindowOBJ;
    ExitCh   : Char;
    S        : String[30];
Begin
 With SRWindow Do
  Begin
   Init;
   SetColor(WindowC_NG);
   SetSize(1,33,SingleBrdr);
   ShowWindow(11,Y1_NG+2);
   With Screen Do
    Begin
     vWindowIgnore := True;
     FastPWrite(11,Y1_NG+2,#194);
     FastPWrite(11+34,Y1_NG+2,#194);
     vWindowIgnore := False;
    End;
   GotoXY(2,1);
   S := SearchStr;
   EditStr(S,30,31,[#32..#255],ExitCh,WindowH_NG);
   if ExitCh=#13 then SearchStr := S;
   Done;
  End;
 if ExitCh=#13 then Lookup(True);
End;

Procedure LoadNGGuide;
Var Loop,
    Loop2 : Byte;
Begin
 ClearMenuVars;
 NoGuide := False;
 UpdateMenu := True;

 if Not OpenGuide(Default.NGPath+Default.NGName) then
  Begin
   NoGuide := True;
   Exit;
  End;

 MainMenuCount := MainMenuCount + Menus;
 With GuideMenu Do
  Begin
   For Loop := 1 to Menus Do
    Begin
     Load(MenuEntry(Loop));
     MainMenuStr[Loop+3] := Title;
     For Loop2 := 1 to Count Do With PullInfo[Loop+3] Do
      Begin
       PullName[Loop2]  := Line(Loop2);
       PullEntry[Loop2] := Entry(Loop2);
      End;
     Done;
    End;
  End;

 if Menus=0 then ExpandTekst(FirstEntry,False)
  Else ExpandTekst(PullInfo[4].PullEntry[1],False);
End;

Procedure DataBase;
Const NumRows = 8;

Type NewGuideRec = Record
      Titel : String[52];
      Name  : String[12];
     End;
     NewGuidePtr = ^NewGuideRec;

Var DBWindow  : WindowOBJ;
    GuidesNum : Byte;
    Sr        : SearchRec;
    NewGuide  : Array [1..20] of NewGuidePtr;
    Key       : Char;
    HBar,
    STxt      : Integer;

  Procedure Display;
  Var Loop : Byte;
      YPos : Byte;
      S    : String[52];
  Begin
   YPos := 1;
   With Screen Do
    Begin
     For Loop := STxt to STxt+NumRows-2 Do
      Begin
       if NewGuide[Loop]<>Nil then S := FillRight(NewGuide[Loop]^.Titel,52)
        Else S := FillStr(Space,52);
       if Loop=HBar then
        FastWrite(1,YPos,WindowC_NG,S)
        Else FastWrite(1,YPos,WindowH_NG,S);
       Inc(YPos);
      End;
    End;
  End;

Begin
 For GuidesNum := 1 to 20 Do NewGuide[GuidesNum] := Nil;
 GuidesNum := 0;
 HBar      := 1;
 STxt      := 1;

 FindFirst(Default.NGPath+'*.NG',AnyFile,Sr);
 While DosError=0 Do
  Begin
   if MaxAvail>Sizeof(NewGuideRec) then
    Begin
     Inc(GuidesNum);
     New(NewGuide[GuidesNum]);
     NewGuide[GuidesNum]^.Titel := '  ' + LookGuide(Default.NGPath+Sr.Name);
     NewGuide[GuidesNum]^.Name  := Sr.Name;
     if Sr.Name=Default.NGName then NewGuide[GuidesNum]^.Titel[1] := #251;
     FindNext(Sr);
    End;
  End;
 if GuidesNum=0 then Exit;

 With DBWindow Do
  Begin
   Init;
   SetSize(NumRows,53,DoubleBrdr);
   SetColor(WindowH_NG);
   SetTitle(' Database ');
   ShowWindow(14,7);

   Repeat
    Display;
    Key := ReadKey;
    if Key=#0 then
     Begin
      Key := ReadKey;
      Case Key of
       #80 : Begin {Down}
              if HBar<GuidesNum then Inc(HBar);
              if HBar>STxt+NumRows-2 then STxt := HBar-NumRows+2;
             End;
       #72 : Begin {Up}
              if HBar>1 then Dec(HBar);
              if HBar<STxt then STxt := HBar;
             End;
       #71,#73 : Begin {Home,PgUp}
                  HBar := 1;
                  STxt := 1;
                 End;
       #79,#81 : Begin {End,PgDn}
                  HBar := GuidesNum;
                  STxt := HBar-NumRows+2;
                  if STxt<1 then STxt := 1;
                 End;
      End;
     End;

   Until (Key=#27) Or (Key=#13);

   Done;
  End;

 if Key=#13 then Sr.Name := NewGuide[HBar]^.Name;

 While GuidesNum<>0 Do
  Begin
   Dispose(NewGuide[GuidesNum]);
   Dec(GuidesNum);
  End;

 if Key=#13 then
  Begin
   FreeGuideMem;
   With Default Do
    Begin
     NGName := Sr.Name;
     if NGPath = '' then NGPath := FExpand(NGPath);
     if NGPath[Byte(NGPath[0])]<>'\' then NGPath := NGPath + '\';
    End;
   CloseGuide;
   LoadNGGuide;
   BuildScreenNG;
  End;
End;

Procedure Color;
Begin
 With Default Do Color := Not Color;
 ChangeColor(Default.Color);

 MainMenuBar := 1;
 PullMenuBar := 1;
 UpdateMenu  := True;
 BuildScreenNG;
End;

Procedure FlipScreen;
Begin
 RestorePartScreen(OrginalScr); {First orginal screen back}

 if DepthTekst+4>=Pred(MaxRows) then ChangeWindowSize(False)
  Else ChangeWindowSize(True);

 if Short then Midden(GuideShort.Count);

 MainMenuBar := 1;
 PullMenuBar := 1;
 if Short then UpdateMenu  := True;
 BuildScreenNG;
End;

Procedure FlipAutoLookUp;
Begin
 With Default Do AutoLookUp := Not AutoLookUp;
End;


Procedure BackUpOneLevel;
Var Bar : Word;
Begin
 if NoGuide then
  Begin
   Quit := True;
   Exit;
  End;

 if (MainMenuBar<>1) And (MainMenuBar<>2) then
  Begin
   if Not DrawSub then SubMenu.Done;
   MainMenuBar := 1;
   PullMenuBar := 1;
   DrawSub     := True;
   UpdateMenu  := True;
  End;

 if Short then With GuideShort Do
  Begin
   if Parent=-1 then
    Begin
     Done;
     Quit := True;
    End Else Begin
              Bar := Current;
              ExpandTekst(Parent,True);
              if Bar<>$FFFF then HTekst := Succ(Bar);
              Midden(Count);
             End;
  End Else With GuideLong Do
            Begin
             if Parent=-1 then
              Begin
               ExpandTekst(PullInfo[4].PullEntry[1],True);
              End Else Begin
                        Bar := Current;
                        ExpandTekst(Parent,True);
                        if Bar<>$FFFF then HTekst := Succ(Bar);
                        if Short then
                         Midden(GuideShort.Count);
                       End;
             ClearStatusLine;
            End;
 WriteTekst;
End;

Procedure MoveScreenUp;
Begin
 if Y1_NG<=1 then Exit;
 Dec(Y1_NG);
 Dec(Y2_NG);

 if Not DrawSub then SubMenu.Done;
 DrawSub := True;
 RestorePartScreen(OrginalScr);
 UpdateMenu := True;
 MakeBox;
 WriteTekst;
 WriteMenuBar;
End;

Procedure MoveScreenDown;
Begin
 if Y2_NG>=MaxRows then Exit;
 Inc(Y1_NG);
 Inc(Y2_NG);

 if Not DrawSub then SubMenu.Done;
 DrawSub := True;
 RestorePartScreen(OrginalScr);
 UpdateMenu := True;
 MakeBox;
 WriteTekst;
 WriteMenuBar;
End;

Procedure ProccessKeyStrokeNG;
Begin
 if Extended then
  Begin
   With KeyBoard Do
    Begin
     if (ScrollLock) And Not Default.BigScreen And
        ((Key=#80) Or (Key=#72)) then
      Begin
       Case Key of
        #72 : MoveScreenUp;
        #80 : MoveScreenDown;
       End;
       Key := #0;
      End;
    End;

   Case Key of
    #59 : NGHelpScreen;
    #67 : FlipScreen;
    #75 : GoLeft;
    #77 : GoRight;
    #80 : GoDown;
    #72 : GoUp;
    #81 : GoPgDn;
    #73 : GoPgUp;
    #71 : GoHome;
    #79 : GoEnd;
   End; {Case}
  End Else Begin
            if (Not Short) And ((Key='+') Or (Key='-')) then
             With GuideLong Do
              Begin
               Case Key of
                '-' : if Previous<>-1 then
                        ExpandTekst(Previous,True);
                '+' : if Next<>-1 then
                       ExpandTekst(Next,True);
               End;{Case}
               WriteTekst;
              End;

            if (MainMenuBar=1) And (Key=#13) then
             Begin
              if Short then With GuideShort Do
               Begin
                ExpandTekst(Entry(HTekst),True);
               End Else With GuideLong.SeeAlso Do
                         Begin {SeeAlso}
                          ExpandTekst(Entry(SeeAlsoBar),True);
                         End;
              WriteTekst;
             End;

            if (MainMenuBar=2) And (Key=#13) then
             Begin
              MainMenuBar := 1;
              PullMenuBar := 1;
              UpdateMenu  := True;

              SearchGuide;
             End;

            if (MainMenuBar=3) And (Key=#13) then
             Begin {Option menu}
              SubMenu.Done;

              Case PullMenuBar of
               1 : DataBase;
               2 : Color;
               3 : FlipScreen;
               4 : FlipAutoLookUp;
               5 : ChangeHotKey;
               6 : UnInstallHelp;
               7 : Write_CFG;
              End;

              MainMenuBar := 1;
              PullMenuBar := 1;
              UpdateMenu  := True;
             End;

            if (MainMenuBar>3) And (Key=#13) then
             Begin
              SubMenu.Done;

              ExpandTekst(PullInfo[MainMenuBar].PullEntry[PullMenuBar],True);
              MainMenuBar := 1;
              PullMenuBar := 1;

              WriteTekst;
             End;
            if Key=#27 then BackUpOneLevel;
           End;

 if UpdateMenu then WriteMenuBar;
 if UpdateSub  then WriteSubMenu;
End;


Procedure StartNG;
Begin
 ChangeWindowSize(Default.BigScreen);
 LoadNGGuide;
 LookUp(False);
 BuildScreenNG;

 Repeat
  Extended := False;
  Key      := ReadKey;
  if Key=#0 then
   Begin
    Extended := True;
    Key      := ReadKey;
   End;
  if Key=#68 then
   Begin
   End;
  ProccessKeyStrokeNG;
 Until Quit;

 CloseGuide;
End;




End.