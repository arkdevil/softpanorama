{$A+,B-,E+,F-,I-,N-,O-,R-,V-}
{$UNDEF DEBUG}
{$IFDEF DEBUG} {$D+,L+,S+} {$ELSE} {$D-,L-,S-} {$ENDIF}
Unit Help_Var;

Interface

Uses YNSystem,YNDos,YNCrt,Cursor,FastScr,Window,NG,StrInt,SwapVars;

Const HelpName  = 'NGHelp v3.01';
      Copyright = HelpName+', Copyright (C) 1991-1994 by Yvo Nelemans';
      CFGFName  = 'NGHELP.CFG';
      Signature = 'NGHELP3.01';

Type CFGRec = Record
      Color      : Boolean;
      AutoLookUp : Boolean;
      BigScreen  : Boolean;
      NGPath     : String[79];
      NGName     : String[12];
     End;

Var OrginalScr    : SaveScrPtr;
    CursorShape   : CursorShapeOBJ;

    UpdateScreen  : Boolean; {Build screen from nothing}

    X1_NG,Y1_NG,
    X2_NG,Y2_NG   : Byte; {Coordinaten van NGCL window}
    WindowC_NG    : Byte; {Color of window for NGCL}
    WindowH_NG    : Byte; {HiColor of window for NGCL}
    MenuC_NG      : Byte;
    BoldFase      : Byte;
    UnderLine     : Byte;
    Reverse       : Byte;

    Default       : CFGRec;

    Key           : Char;
    Extended      : Boolean;

    NoGuide       : Boolean;
    Quit          : Boolean; {End this session of Help}

    SearchStr     : String[30];

    AskWindow     : AskOBJ;

    XPosition,
    YPosition     : Byte;
    CursorSize    : Word;

    FirstToDisk   : Pointer;
    SwpPath       : String[79];


Procedure Read_CFG;
Procedure Write_CFG;

Procedure SaveAll;
Procedure RestoreAll;

Procedure HotKeys;
Procedure ChangeHotKey;

Procedure UnInstallHelp;

Implementation


Function CFGPath : Str79;
Var D : DirStr;
    N : NameStr;
    E : ExtStr;
Begin
 FSplit(ParamStr(0),D,N,E);
 if (Length(D)>3) And (D[Length(D)]<>'\') then D := D + '\';
 D := D + CFGFName;
 CFGPath := D;
End;

Procedure Read_CFG;
Var F : File of CfgRec;
Begin
 Assign(F,CFGPath);
 Reset(F);
 if IOResult<>0 then Exit;
 Read(F,Default);
 if IOResult<>0 then ;
 Close(F);
 if IOResult<>0 then ;
End;

Procedure Write_CFG;
Var F : File of CfgRec;
Begin
 With AskWindow Do
  Begin
   Init;
   AddTitle(' Setup ');
   AddLine('^Saving current setup to :');
   AddLine(CenterStr(Copy(CFGPath,1,38),40));
   ShowMessage;
  End;

 Assign(F,CFGPath);
 Rewrite(F);
 if IOResult<>0 then Exit;
 Write(F,Default);
 if IOResult<>0 then ;
 Close(F);
 if IOResult<>0 then ;
 AskWindow.Done;
End;

Procedure LookUpStr;
Var S : String;
    P : Byte;
Begin
 SearchStr := '';
 S := Screen.ReadScreenLn(YPosition);
 P := XPosition;

 if S[P]<>' ' then
  Begin
   Repeat
    Dec(P);
   Until Not (S[P] in ['A'..'z',#128..#165]);
  End Else Begin
            While (P>1) And Not (S[P] in ['A'..'z',#128..#165]) Do Dec(P);
            While (P>1) And (S[P] in ['A'..'z',#128..#165]) Do Dec(P);
           End;
 Inc(P);
 Repeat
  SearchStr := SearchStr + S[P];
  Inc(P);
 Until Not (S[P] in ['A'..'z',#128..#165]) Or (P>Succ(MaxCols));

 StripVar(SearchStr);
End;

Procedure SaveAll;
Begin
 Quit := False;
 InitDetect; {Check videomode first}
 XPosition := WhereX; YPosition := WhereY;
 With CursorShape Do
  Begin
   Init; { 5 cursor shapes can be saved }
   PushCursor;
  End;
 HideCursor; { Detect.tpu }

 OrginalScr := SavePartScreen(1,1,Succ(MaxCols),Succ(MaxRows));
 LookUpStr;
End;

Procedure RestoreAll;
Type WordRec = Record
      X,Y  : Byte;
     End;
Begin
 RestorePartScreen(OrginalScr);
 DisposePartScreen(OrginalScr);

 WordRec(WindMin).X := 0;
 WordRec(WindMin).Y := 0; { window to entire Scr }
 WordRec(WindMax).X := Pred(MaxCols);
 WordRec(WindMax).Y := Pred(MaxRows);

 GotoXY(XPosition,YPosition);
 With CursorShape Do
  Begin
   PopCursor;
   Done; { Free memory }
  End;
End;

Procedure HotKeys;
Begin
 Writeln('To activated the NG Cloon : LeftShift-F1');
End;

Procedure ChangeHotKey;
Var ExitCode : Char;
Begin
 With AskWindow Do
  Begin
   Init;
   AddTitle(' Change Hotkey ');
   AddLine('Sorry, this option isn''t available yet.');
   AddLine('This is soon to come.');
   AddLine('');
   AddButton('Ok');
   Go(ExitCode);
   Done;
  End;
End;


Procedure UnInstallHelp;
Var ExitCode : Char;
Begin
 With AskWindow Do
  Begin
   Init;
   AddTitle(' Uninstall ');
   AddLine('Do you wish to remove HELP');
   AddLine('from memory ?');
   AddLine('');
   AddButton('Yes');
   AddButton('No');
   Go(ExitCode);
   Done;
   if ExitCode=#27 then Exit;
   if ButtonNum=1 then
    Begin
{$IFDEF TSR}
     if UnInstall<>0 then
      Begin
       Init;
       AddTitle(' Error ');
       AddLine('Cann''t remove HELP from memory.');
       AddLine('Other program loaded after HELP.');
       AddLine('');
       AddButton('Ok');
       Go(ExitCode);
       Done;
       Exit;
      End Else Begin
                CloseGuide;

                RestoreAll;
                StopPrg;
               End;
{$ELSE}
     Halt;
{$ENDIF}
    End;
  End;
End;




End.