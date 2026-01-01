{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Demo program from the Turbo Vision Guide     }
{                                                }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}
{$X+ }
program TVGUID08;

uses Objects, Drivers, Dialogs, Views, Menus, App, StdDlg,
     Fonts,  HelpFile, MsgBox, PCXRead, TxtRead;

const
 SizeXHelp : integer = 64;
 SizeYHelp : integer = 32;
 PicHelp : array[0..335] of byte =
($12,$07,$1c,$09,$12,$07
,$0c,$07,$28,$09,$0c,$07
,$08,$07,$14,$09,$02,$00,$1a,$09,$08,$07
,$06,$07,$15,$09,$01,$00,$02,$0f,$01,$00,$1b,$09,$06,$07
,$04,$07,$13,$09,$01,$00,$0a,$0f,$01,$00,$19,$09,$04,$07
,$04,$07,$13,$09,$01,$00,$0a,$0f,$01,$00,$19,$09,$04,$07
,$02,$07,$13,$09,$01,$00,$0e,$0f,$01,$00,$19,$09,$02,$07
,$02,$07,$15,$09,$01,$00,$0a,$0f,$01,$00,$1b,$09,$02,$07
,$02,$07,$15,$09,$01,$00,$0a,$0f,$01,$00,$1b,$09,$02,$07
,$1b,$09,$01,$00,$02,$0f,$01,$00,$21,$09
,$1c,$09,$02,$00,$22,$09
,$15,$09,$10,$00,$1b,$09
,$15,$09,$01,$00,$0e,$0f,$01,$00,$1b,$09
,$15,$09,$01,$00,$01,$09,$01,$00,$01,$09,$01,$00,$0a,$0f,$01,$00,$1b,$09
,$19,$09,$01,$00,$0a,$0f,$01,$00,$1b,$09
,$19,$09,$01,$00,$0a,$0f,$01,$00,$1b,$09
,$19,$09,$01,$00,$0a,$0f,$01,$00,$1b,$09
,$19,$09,$01,$00,$0a,$0f,$01,$00,$1b,$09
,$19,$09,$01,$00,$0a,$0f,$01,$00,$1b,$09
,$19,$09,$01,$00,$0a,$0f,$01,$00,$1b,$09
,$19,$09,$01,$00,$0a,$0f,$01,$00,$1b,$09
,$02,$07,$17,$09,$01,$00,$0a,$0f,$01,$00,$19,$09,$02,$07
,$02,$07,$17,$09,$01,$00,$0a,$0f,$01,$00,$19,$09,$02,$07
,$02,$07,$17,$09,$01,$00,$0a,$0f,$07,$00,$13,$09,$02,$07
,$04,$07,$15,$09,$01,$00,$10,$0f,$01,$00,$11,$09,$04,$07
,$04,$07,$17,$09,$01,$00,$0c,$0f,$01,$00,$13,$09,$04,$07
,$06,$07,$17,$09,$01,$00,$08,$0f,$01,$00,$13,$09,$06,$07
,$08,$07,$16,$09,$07,$00,$13,$09,$08,$07
,$0c,$07,$28,$09,$0c,$07
,$12,$07,$1c,$09,$12,$07
,$40,$07
,$40,$07
);
var
 HelpPic : TPicture absolute SizeXHelp;

const
 SizeXIcs : integer = 64;
 SizeYIcs : integer = 32;
 PicIcs : array[0..555] of byte =
   ($40,$0a,$0a,$0a,$04,$00,$32,$0a,$0a,$0a,$04,$00,$32,$0a,$40,$0a
   ,$19,$0a,$06,$00,$0d,$0a,$06,$00,$0e,$0a,$09,$0a,$05,$00,$09,$0a
   ,$0a,$00,$09,$0a,$0a,$00,$0c,$0a,$0a,$0a,$05,$00,$06,$0a,$05,$00
   ,$04,$0a,$05,$00,$05,$0a,$05,$00,$04,$0a,$05,$00,$0a,$0a,$0b,$0a
   ,$04,$00,$06,$0a,$03,$00,$07,$0a,$04,$00,$05,$0a,$04,$00,$06,$0a
   ,$04,$00,$0a,$0a,$0b,$0a,$04,$00,$05,$0a,$04,$00,$0f,$0a,$05,$00
   ,$14,$0a,$0b,$0a,$04,$00,$05,$0a,$04,$00,$0f,$0a,$05,$00,$14,$0a
   ,$0b,$0a,$04,$00,$05,$0a,$04,$00,$0f,$0a,$06,$00,$13,$0a,$0b,$0a
   ,$04,$00,$05,$0a,$04,$00,$10,$0a,$0b,$00,$0d,$0a,$0b,$0a,$04,$00
   ,$05,$0a,$04,$00,$11,$0a,$0c,$00,$0b,$0a,$0b,$0a,$04,$00,$05,$0a
   ,$04,$00,$13,$0a,$0b,$00,$0a,$0a,$0b,$0a,$04,$00,$05,$0a,$04,$00
   ,$19,$0a,$06,$00,$09,$0a,$0b,$0a,$04,$00,$05,$0a,$04,$00,$1a,$0a
   ,$05,$00,$09,$0a,$0b,$0a,$04,$00,$05,$0a,$04,$00,$1a,$0a,$05,$00
   ,$09,$0a,$0b,$0a,$04,$00,$06,$0a,$03,$00,$07,$0a,$04,$00,$05,$0a
   ,$04,$00,$06,$0a,$04,$00,$0a,$0a,$0b,$0a,$06,$00,$04,$0a,$05,$00
   ,$04,$0a,$05,$00,$05,$0a,$05,$00,$04,$0a,$05,$00,$0a,$0a,$0c,$0a
   ,$05,$00,$05,$0a,$0b,$00,$09,$0a,$0a,$00,$0c,$0a,$0d,$0a,$03,$00
   ,$09,$0a,$06,$00,$0d,$0a,$06,$00,$0e,$0a,$40,$0a,$40,$0a,$40,$0a
   ,$04,$0a,$03,$00,$03,$0a,$05,$00,$04,$0a,$01,$00,$08,$0a,$03,$00
   ,$07,$0a,$02,$00,$09,$0a,$03,$00,$05,$0a,$03,$00,$04,$0a,$03,$0a
   ,$01,$00,$03,$0a,$01,$00,$06,$0a,$01,$00,$04,$0a,$01,$00,$07,$0a
   ,$01,$00,$03,$0a,$01,$00,$05,$0a,$01,$00,$01,$0a,$01,$00,$08,$0a
   ,$01,$00,$03,$0a,$01,$00,$03,$0a,$01,$00,$03,$0a,$01,$00,$03,$0a
   ,$07,$0a,$01,$00,$06,$0a,$01,$00,$03,$0a,$02,$00,$0b,$0a,$01,$00
   ,$04,$0a,$01,$00,$02,$0a,$01,$00,$08,$0a,$01,$00,$03,$0a,$01,$00
   ,$03,$0a,$01,$00,$03,$0a,$01,$00,$03,$0a,$05,$0a,$02,$00,$06,$0a
   ,$01,$00,$05,$0a,$01,$00,$09,$0a,$02,$00,$04,$0a,$01,$00,$03,$0a
   ,$01,$00,$09,$0a,$03,$00,$04,$0a,$01,$00,$03,$0a,$01,$00,$03,$0a
   ,$04,$0a,$01,$00,$07,$0a,$01,$00,$06,$0a,$01,$00,$0b,$0a,$01,$00
   ,$03,$0a,$01,$00,$03,$0a,$01,$00,$08,$0a,$01,$00,$03,$0a,$01,$00
   ,$04,$0a,$04,$00,$03,$0a,$03,$0a,$01,$00,$07,$0a,$01,$00,$07,$0a
   ,$01,$00,$07,$0a,$01,$00,$03,$0a,$01,$00,$03,$0a,$06,$00,$07,$0a
   ,$01,$00,$03,$0a,$01,$00,$07,$0a,$01,$00,$03,$0a,$03,$0a,$05,$00
   ,$03,$0a,$01,$00,$07,$0a,$01,$00,$08,$0a,$03,$00,$08,$0a,$01,$00
   ,$09,$0a,$03,$00,$05,$0a,$03,$00,$04,$0a,$40,$0a);
var
  IcsPic : TPicture absolute SizeXIcs;

const
  HLPNameR          = 'myhelp.hlp';
  FileToRead        = 'tvg08.PAS';
  MaxLines          = 100;
  WinCount: Integer =   0;

  cmAbout      = 100;
  cmPicWindow  = 101;
  cmPcxWindow  = 102;
  cmTxtWindow  = 103;
  cmDialog     = 104;
  cmDemoFonts  = 105;

var
  LineCount: Integer;
  Lines: array[0..MaxLines - 1] of PString;
   
type
  PBar = ^TBar ;
  TBar = object ( TView )
    procedure Draw; virtual ;
  end ;

  TMyApp = object(TApplication)
    procedure GetEvent(var Event: TEvent); virtual;
    function  GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure DemoDialog;
    procedure TxtWindow;
    procedure PicWindow;
    procedure PcxWindow;
    procedure DemoFonts;
    procedure About;
    procedure OutOfMemory; virtual;
  end;

procedure TBar.Draw;
begin
  SetColor(10);
  WriteLine(0,0,Size.X,Size.Y);
end ;

procedure TMyApp.DemoDialog;
var
  R: TRect;
  D: PDialog;
  Bruce: PView;
  C: Word;
begin
  GetExtent(R);
  R.Assign((DeskTop^.Size.X - 250) div 2, (DeskTop^.Size.Y - 180) div 2 ,
            (DeskTop^.Size.X - 250) div 2 + 250, (DeskTop^.Size.Y - 180) div 2 + 180);
  D := New(PDialog, Init(R, 'Dialog Window' ));
  with D^ do
  begin
    R.Assign(30, 40, 120,  40 + 3 * CurrentFont^.Height + 2);
    Bruce := New(PCheckBoxes, Init(R,
      NewSItem('~А~varti',
      NewSItem('~Б~ilset',
      NewSItem('~В~arlsberg',
      nil)))
    ));
    Insert(Bruce);
    R.Assign(30, 25, 120, 40);
    Insert(New(PLabel, Init(R, 'C~h~eeses', Bruce)));
    R.Assign(140, 40, 230,  40 + 3 * CurrentFont^.Height + 2);
    Bruce := New(PRadioButtons, Init(R,
      NewSItem('~S~olid',
      NewSItem('~R~unny',
      NewSItem('~M~elted',
      nil)))
    ));
    Insert(Bruce);
    R.Assign(140, 25, 230, 40);
    Insert(New(PLabel, Init(R, '~C~onsistency', Bruce)));
    R.Assign(30,  90 + CurrentFont^.Height + 2, 230, 90 + 2 * CurrentFont^.Height + 6);
    Bruce := New(PInputLine, Init(R, 128));
    Insert(Bruce);
    R.Assign(25,  90, 230,  90 + CurrentFont^.Height + 2);
    Insert(New(PLabel, Init(R, '~D~elivery instructions', Bruce)));
    R.Assign(90, 140, 140, 160);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(160, 140, 235, 160);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
  end;
{  D^.SetData(DemoDialogData); }
  C := DeskTop^.ExecView(D);
 {  if C <> cmCancel then Dialog^.GetData(DemoDialogData); }
  Dispose(D, Done);
end;


{ TMyApp }

procedure TMyApp.DemoFonts;
var
  Bruce: PView;
  R: TRect;
  D: PDialog;
  SaveFont: PFont;

begin
  SaveFont := CurrentFont;
  GetExtent(R);
  R.Assign((DeskTop^.Size.X - 200) div 2, (DeskTop^.Size.Y - 130) div 2 ,
            (DeskTop^.Size.X - 200) div 2 + 200, (DeskTop^.Size.Y - 130) div 2 + 130);
  D := New(PDialog, Init(R, 'Fonts  Window' ));
  with D^ do begin
    SetFont(@Font8x8);
    R.Assign(20, 35, 180, 45);
    Insert(New(PLabel, Init(R, '█ This is font ~8x8~', Bruce)));
    SetFont(@Font8x14);
    R.Assign(20, 60, 180, 80);
    Insert(New(PLabel, Init(R, '█ This is font ~8x14~', Bruce)));
    SetFont(@Font8x16);
    R.Assign(20, 100, 180, 120);
    Insert(New(PLabel, Init(R, '█ This is font ~8x16~', Bruce)));
  end;
  CurrentFont := SaveFont;
  DeskTop^.Insert(D);
end;

procedure TMyApp.GetEvent(var Event: TEvent);
var
  W: PWindow;
  HelpFile: PHelpFile;
  HelpStrm: PDosStream;
const
  HelpInUse: Boolean = False;
begin
  TApplication.GetEvent(Event);
  if (Event.What = evCommand) and (Event.Command = cmHelp) and
    not HelpInUse then
  begin
    HelpStrm := New(PDosStream, Init(HLPNameR, stOpenRead));
    HelpFile := New(PHelpFile, Init(HelpStrm));
    if HelpStrm^.Status <> stOk then
    begin
      MessageBox(^C'Could not open help file.', nil, mfError + mfOkButton);
      Dispose(HelpFile, Done);
    end
    else
    begin
      HelpInUse := True;
      W := New(PHelpWindow,Init(Helpfile, GetHelpCtx));
      W^.HelpCtx := $FFFF;
      if ValidView(W) <> nil then
      begin
        DeskTop^.ExecView(W);
        Dispose(W, Done);
      end;
      HelpInUse := False;
      ClearEvent(Event);
    end;
  end;
end;

function TMyApp.GetPalette: PPalette;
const
  CNewColor = CColor + CHelpColor;
  CNewBlackWhite = CBlackWhite + CHelpBlackWhite;
  CNewMonochrome = CMonochrome + CHelpMonochrome;
  P: array[apColor..apMonochrome] of string[Length(CNewColor)] =
    (CNewColor, CNewBlackWhite, CNewMonochrome);
begin
  GetPalette := @P[AppPalette];
end;

procedure TMyApp.HandleEvent(var Event: TEvent);
var R: TRect;
begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmAbout    : About;
      cmPicWindow: PicWindow;
      cmPcxWindow: PcxWindow;
      cmTxtWindow: TxtWindow;
      cmDialog   : DemoDialog ;
      cmDemoFonts:DemoFonts ;
   else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure TMyApp.InitMenuBar;
var R: TRect;
begin
  GetExtent ( R );
  R.B.Y := R.A.Y + CurrentFont^.Height + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
      NewItem('~A~bout', '',    kbAltSpace,  cmAbout, hcNoContext,
   NewSubMenu('~F~ile', hcNoContext, NewMenu(
      NewItem('~T~ext', 'F3',    kbF3,   cmTxtWindow,hcNoContext,
      NewItem('~P~cx' , 'F4',    kbF4,   cmPcxWindow,hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit,     hcNoContext,
      nil))))),
   NewSubMenu('~W~indow', hcNoContext, NewMenu(
      NewItem('~N~ext', 'F6', kbF6, cmNext, hcNoContext,
      NewItem('~Z~oom', 'F5', kbF5, cmZoom, hcNoContext,
      NewItem('~T~ile', 'F7', kbF7, cmTile, hcNoContext,
      NewItem('~C~ascade', 'F8', kbF8, cmCascade, hcNoContext,
      NewItem('~R~esize', 'CtrlF5', kbCtrlF5, cmResize, hcNoContext,
      NewLine(
      NewItem('~F~onts' , 'F7', kbF7,    cmDemoFonts, hcNoContext,
      NewItem('~D~ialog', 'F9', kbF9,    cmDialog,    hcNoContext,
      NewItem('~P~icto' ,   '', kbNoKey, cmPicWindow, hcNoContext,
      nil)))))))))),
    nil))
  ))));
  MenuBar^.State := MenuBar^.State or sfActive;
end;

procedure TMyApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - CurrentFont^.Height;;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFF0,
      NewStatusKey('', kbF5, cmZoom,
      NewStatusKey('', kbCtrlF5, cmReSize,
      NewStatusKey('~F1~ Help', kbF1, cmHelp,
      NewStatusKey('~F10~ Menu', kbF10, cmMenu,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      nil)))))),
    NewStatusDef($FFF0, $FFFF,
      NewStatusKey('', kbF5, cmZoom,
      NewStatusKey('', kbCtrlF5, cmReSize,
      NewStatusKey('~Tab~ Next Topic', kbTab, cmNextTopic,
      NewStatusKey('~Shift-Tab~ Prev Topic', kbShiftTab, cmPrevTopic,
      NewStatusKey('~Alt-F1~ Prev Screen', kbAltF1, cmPrevScreen,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      nil)))))),
    nil))
  ));
end;

procedure TMyApp.TxtWindow;
var
  D: PFileDialog;
  FileName: String[79];
  W: PWindow;
begin
  D := PFileDialog(ValidView(New(PFileDialog, Init('*.*', 'Open a File',
    '~N~ame', fdOpenButton, 100))));
  if D <> nil then
  begin
    if Desktop^.ExecView(D) <> cmCancel then
    begin
      D^.GetFileName(FileName);
      W := PWindow(ValidView(New(PFileWindow,Init(FileName))));
      if W <> nil then Desktop^.Insert(W);
    end;
    Dispose(D, Done);
  end;
end;

procedure TMyApp.PicWindow;
var
  W: PWindow;
  R: TRect;
begin
  R.Assign( 0, 0, 300, 130);
  W := New(PWindow, Init(R, 'Demo Pictogram', WinCount));
  with W^ do begin
    R.Assign( 20, 40, 130, 100 ); Insert(New(PPicButton, Init(R, '~I~nformation', cmHelp, bfNormal, @HelpPic)));
    R.Assign(140, 40, 250, 100 ); Insert(New(PPicButton, Init(R, '~A~bout', cmHelp, bfNormal, @IcsPic)));
  end;
  DeskTop^.Insert(W);
end;

procedure TMyApp.PcxWindow;
var
  W: PWindow;
  R: TRect;
  HScrollBar, VScrollBar: PScrollBar;
  Dialog  : PFileDialog;
  FileName: string[79];
  Control: word;
begin
  Dialog := New(PFileDialog,Init('*.pcx', 'Open a PCX-File',
                '~F~ile name',fdOpenButton,1));
  Control := Desktop^.ExecView(Dialog);
  if Control <> cmCancel then Dialog^.GetData(FileName);
  Dispose(Dialog,Done);
  if Control = cmCancel then exit;
  R.Assign( 0, 0, 300, 130);
  W := New(PWindow, Init(R, FileName, WinCount));
  with W^ do begin
     GetExtentWin( R );
     VScrollBar := StandardScrollBar(sbVertical + sbHandleKeyboard);
     HScrollBar := StandardScrollBar(sbHorizontal + sbHandleKeyboard);
     GetExtentWin(R);
     dec(R.B.X,ScrollSize);  dec(R.B.Y,ScrollSize);
     Insert( New(PPCXWindow, Init( R, HScrollBar, VScrollBar, FileName)));
     Options := Options or ofTileable;
  end;
  DeskTop^.Insert(W);
end;

procedure TMyApp.About;
var
  W: PWindow;
  R: TRect;
begin
  R.Assign( 200, 100, 400, 300);
  W := New(PDialog, Init(R, 'About'));
  with W^ do begin
    GetExtentWin( R ); R.B.Y := R.A.Y + Font^.Height;
    R.Move( 0, 25 ); Insert(New(PStaticText, Init(R, ^C'Graphic Vision')));
    R.Move( 0, 25 ); Insert(New(PStaticText, Init(R, ^C'Demo  Program')));
    R.Move( 0, 25 ); Insert(New(PStaticText, Init(R, ^C'Kiev 1992')));
    R.Move( 0, 25 ); Insert(New(PStaticText, Init(R, ^C'ICS Co. Ltd.')));
    R.Move( 0, 30 ); Insert(New(PStaticText, Init(R, ^C'tel. (044)271-34-89')));
  end;
  DeskTop^.Insert(W);
end;


procedure TMyApp.OutOfMemory;
begin
  MessageBox(^C'Не хватает памяти для выполнения операции',
    nil, mfError + mfOkButton);
end;


var
  MyApp: TMyApp;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.
