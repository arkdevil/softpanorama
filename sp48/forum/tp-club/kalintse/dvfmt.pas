{$M 10000,50000,650000}

{$X+,G-,V-}

Uses
  Dos,Objects,Drivers,App,Dialogs,MsgBox,TpString,
  Views,Menus,VFormat,DEK_Anm,Huh,Defence,TpDate;

type
  TFormatApp = object(TApplication)
    procedure InitDeskTop; virtual;
    procedure InitStatusLine; virtual;
    procedure InitMenuBar; virtual;
    procedure OutOfMemory; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure EventError(var Event: TEvent); virtual;
  end;

  PMyStatus = ^TMyStatus;
  TMyStatus = object(TStatusLine)
    function Hint(AHelpCtx: Word): String; virtual;
  end;

  PInfWindow = ^TInfWindow;
  TInfWindow = object(TWindow)
    constructor Init;
  end;

  PInfoView = ^TInfoView;
  TInfoView = object(TView)
    constructor Init(Bounds: TRect);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Draw; virtual;
  end;

  PInfoWindow = ^TInfoWindow;
  TInfoWindow = object(TWindow)
    constructor Init;
  end;

  PDiskParm = ^TDiskParm;
  TDiskParm = object(TObject)
    Heads,Tracks,Sectors: Byte;
    constructor Init(NH,NT,NS: Byte);
    destructor Done; virtual;
  end;

  PDriveList = ^TDriveList;
  TDriveList = object(TListBox)
    constructor Init(R: TRect; AScrollBar: PScrollBar);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  PSizeList = ^TSizeList;
  TSizeList = object(TListBox)
    constructor Init(R: TRect; AScrollBar: PScrollBar);
    procedure HandleEvent(var Event: TEvent); virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
  end;

  PMainDialog = ^TMainDialog;
  TMainDialog = object(TDialog)
    constructor Init;
  end;

  MainDlgTyp = record
    DrvC: PCollection;
    DrvN: Integer;
    SzC: PCollection;
    SzN: Integer;
    Lbl: String[11];
    RData: Word;
  end;

const
  VS: String[8] = 'V1.01';
  LU: String[8] = '01/23/92';
  DEK: String[3] = #0#1#2;

  cmAbout =    100;
  cmUserList = 101;
  cmRedraw =   102;
  cmBegin =    103;

var
  DrvPar: PDiskParm;
  MainDlg: MainDlgTyp;
  FormatApp: TFormatApp;
  OldExitProc: Pointer;
  Rg: Registers;
  DriveA: PCollection;
  DriveB: PCollection;
  Drives: PCollection;
  R: TRect;
  W2: PInfoWindow;
  W1: PInfWindow;
  MainD: PMainDialog;


procedure PError;
begin
  if Random(255) in [0..10,100..110,200..210] then
    MessageBox(^C+HuhS, nil, mfError+mfOkButton);
end;

procedure MyExitProc; far;
begin
  Old90 := Sv90;
  ExitProc := OldExitProc;
  if ErrorAddr <> nil then
  begin
    MessageBox(^C'DVFmt internal error #'+Long2Str(ExitCode)+
               ' at '+HexPtr(ErrorAddr)+'.'#13+
               ^C'Plase, contact DEK SoftWorks on'+#13+
               ^C'(377-71)594-97.', nil, mfError+mfOkButton);
    ErrorAddr := nil;
  end
  else
  begin
    if MessageBox(#13^C'Exit DVFormat ?', nil, mfConfirmation+mfYesButton+mfNoButton) <> cmYes then
      MessageBox(#13^C'Too late.', nil, mfError+mfOkButton);
  end;
  FormatApp.Done;
  Finit_Roll;
  WriteLn('DVFormat '+VS+' terminated.');
  WriteLn('This version was last updated on '+LU+'.');
  WriteLn('FREEWARE. Source code available from author without any fee.');
  WriteLn;
  WriteLn('Many thanx to: Christoph H. Hochstatter & Alx. V. Sessa');
  WriteLn('for source code for format module.');
  WriteLn;
  WriteLn('Please, send bug reports to:');
  WriteLn(LeftPad('Dee Eastman, DEK SoftWorks,',58));
  WriteLn(LeftPad('Severnaya 1/2, Chkalowsk, 735737 USSR',58));
  WriteLn(LeftPad('or call (377-71)594-97.',58));
end;

{ TInfoWindow }

constructor TInfoWindow.Init;
var
  R: TRect;
  B: PView;
begin
  R.Assign(0, 0, 40, 9);
  TWindow.Init(R, 'Process', 0);
  Options := Options or ofCentered;
  Flags := Flags and not (wfZoom + wfGrow + wfClose);    { Not resizeable }
  GrowMode :=0;
  Palette := wpGrayWindow;
  GetExtent(R);
  R.Grow(-1,-1);
  B := New(PInfoView, Init(R));
  B^.EventMask := B^.EventMask or evBroadcast;
  Insert(B);
  HelpCtx := 20;
end;

{ TInfoView }

constructor TInfoView.Init(Bounds: TRect);
begin
  TView.Init(Bounds);
  DrawView;
  EventMask := EventMask or evCommand;
end;

procedure TInfoView.HandleEvent(var Event: TEvent);
begin
  if (Event.What = evBroadcast) and
     (Event.Command = cmSendMessage) and
     (State and sfExposed <> 0) then
    DrawView;
  TView.HandleEvent(Event);
end;

procedure TInfoView.Draw;
const
  Width = 40;
var
  B: Array[0..Width] Of Word;
  NColor, HColor: Byte;
begin
  NColor := GetColor(6);
  HColor := GetColor(7);

  MoveChar(B, ' ', NColor, Width);
  WriteLine(0, 0, Width, 1, B);
  WriteLine(0, 6, Width, 1, B);
  MoveStr(B,' Status: '+Info.OpString,NColor);
  WriteLine(0, 1, Width, 1, B);

  MoveChar(B, ' ', NColor, Width);
  MoveStr(B, ' '+CharStr('─',35),NColor);
  WriteLine(0,2,Width,1,B);

  MoveChar(B, ' ', NColor, Width);
  MoveStr(B, ' Space good:',NColor);
  WriteLine(0,3,13,1,B);
  MoveChar(B, ' ', NColor, Width);
  MoveStr(B, Long2Str(Info.Good)+'K', HColor);
  WriteLine(13,3,Width-13,1,B);

  MoveChar(B, ' ', NColor, Width);
  MoveStr(B, ' Space bad: ',NColor);
  WriteLine(0,4,13,1,B);
  MoveChar(B, ' ', NColor, Width);
  MoveStr(B, Long2Str(Info.Bad)+'K', HColor);
  WriteLine(13,4,Width-13,1,B);

  MoveChar(B, ' ', NColor, Width);
  MoveStr(B, ' Percent complete: '+Long2Str(Info.ComplPerc)+'%' ,NColor);
  WriteLine(0,5,Width,1,B);
end;

{ TDriveList }
constructor TDriveList.Init(R: TRect; AScrollBar: PScrollBar);
begin
  TListBox.Init(R, 1, AScrollBar);
  EventMask := EventMask or evBroadcast;
  Options := Options or ofFramed;
  NewList(Drives);
end;

procedure TDriveList.HandleEvent(var Event: TEvent);
var
   A: Boolean;
begin
  A := Event.What and (evMouse or evKeyboard) <> 0;
  A := A and (State and sfSelected <> 0);
  TListBox.HandleEvent(Event);
  if A then
    Message(TopView, evBroadcast, cmRedraw, @Focused);
end;

{ TSizeList }
constructor TSizeList.Init(R: TRect; AScrollBar: PScrollBar);
begin
  TListBox.Init(R, 1, AScrollBar);
  EventMask := EventMask or evBroadcast;
  Options := Options or ofFramed;
  NewList(DriveA);
end;

procedure TSizeList.HandleEvent(var Event: TEvent);
var
  A: Integer;
begin
  TListBox.HandleEvent(Event);
  if (Event.What = evBroadcast) and (Event.Command = cmRedraw) and
    (State and sfSelected = 0) then
    begin
      A := Integer(Event.InfoPtr^);
      case A of
        0: if List <> DriveA then
           begin
             List := nil;
             NewList(DriveA);
           end;
        1: if List <> DriveB then
           begin
             List := nil;
             NewList(DriveB);
           end;
      end;
      DrawView;
    end;
end;

function TSizeList.GetText(Item: Integer; MaxLen: Integer): String;
var
  S: String;
  SR: PDiskParm;
begin
  SR := PDiskParm(List^.At(Item));
  S := Long2Str((LongInt(SR^.Heads) *
                LongInt(SR^.Tracks) *
                LongInt(SR^.Sectors) *
                LongInt(512)) div 1024);
  GetText := S+' Kb';
end;

{ TMainDialog }
constructor TMainDialog.Init;
var
  Control: PView;
begin
  R.Assign(0,0,55,13);
  TDialog.Init(R, 'Format options');
  Options := Options or ofCentered;
  R.Assign(15,3,16,8);
  Control := New(PScrollBar, Init(R));
  Insert(Control);
  R.Assign(4,3,15,8);
  Control := New(PDriveList, Init(R, PScrollBar(Control)));
  Control^.HelpCtx := 3;
  Insert(Control);
  R.Assign(4,2,12,3);
  Insert(New(PLabel, Init(R, '~D~rives', Control)));
  R.Assign(28,3,29,8);
  Control := New(PScrollBar, Init(R));
  Insert(Control);
  R.Assign(19,3,28,8);
  Control := New(PSizeList, Init(R,PScrollBar(Control)));
  Control^.HelpCtx := 4;
  Insert(Control);
  R.Assign(19,2,26,3);
  Insert(New(PLabel, Init(R, '~S~izes', Control)));
  R.Assign(32,3,51,4);
  Control := New(PInputLine, Init(R, 11));
  Control^.HelpCtx := 5;
  Control^.Options := Control^.Options or ofFramed;
  Insert(Control);
  R.Assign(32,2,46,3);
  Insert(New(PLabel, Init(R, '~V~olume label', Control)));
  R.Assign(32,6,51,8);
  Control := New(PRadioButtons, Init(R,
    NewSItem('~N~o (Vaccined)',
    NewSItem('~P~ut on disk',
    nil))
  ));
  Control^.HelpCtx := 6;
  Control^.Options := Control^.Options or ofFramed;
  Insert(Control);
  R.Assign(32,5,46,6);
  Insert(New(PLabel, Init(R, 'Sys~t~em files', Control)));
  R.Assign(24,10,40,12);
  Control := New(PButton, Init(R, '~B~egin format', cmBegin, bfDefault));
  Control^.HelpCtx := 8;
  Insert(Control);
  R.Assign(41,10,51,12);
  Control := New(PButton, Init(R, 'Cancel', cmQuit, bfNormal));
  Control^.HelpCtx := 9;
  Insert(Control);
  SelectNext(False);
end;

{ TDiskParm }
constructor TDiskParm.Init(NH,NT,NS: Byte);
begin
  Heads := NH;
  Tracks := NT;
  Sectors := NS;
end;

destructor TDiskParm.Done;
begin
end;

{ TInfoWindow }
constructor TInfWindow.Init;
var
  R: TRect;
  B: PView;
begin
  R.Assign(0, 0, 30, 5);
  TWindow.Init(R, '', 0);
  Options := Options or ofCentered;
  Flags := Flags and not (wfZoom + wfGrow + wfClose);    { Not resizeable }
  GrowMode := 0;
  Palette := wpGrayWindow;
  GetExtent(R);
  R.Grow(-1,-1);
  B := New(PView, Init(R));
  B^.HelpCtx := 2;
  Insert(B);
  Inc(R.A.Y,1);
  Insert(New(PStaticText, Init(R,
    ^C'Checking EXE module...'
  )));
end;

{ TMyStatus }
function TMyStatus.Hint(AHelpCtx: Word): String;
begin
  case byte(AHelpCtx) of
    0:  Hint := '';
    1:  Hint := 'Drop where you''ve got it and... NOW !!!';
    2:  Hint := 'Processing, be patient please ...';
    3:  Hint := 'Choose a drive with diskette to format';
    4:  Hint := 'Choose size for diskette. Some sizes may require 800.COM for use';
    5:  Hint := 'Enter disk volume label (Still not realized because I''m so lazy)';
    6:  Hint := 'Disk will be vaccined by Vitamin-B boot vaccine';
    7:  Hint := 'System files will be put on disk when formatted';
    8:  Hint := 'Press SPACE or ENTER to begin format';
    9:  Hint := 'Press that button to terminate program';
    10: Hint := 'Here is registered users list for current copy of program';
    11: Hint := 'Here is About window. Press ESC to close.';
    12: Hint := 'Press Enter to see "About" window';
    13: Hint := 'Press Enter to see registered users list for that copy of DVFmt';
    20: Hint := 'Formatting in progress, be patient please...';
  end;
end;

{ TFormatApp }
procedure TFormatApp.InitDeskTop;

procedure SetDriveParm(var Drive: PCollection);
begin
  Drive := New(PCollection, Init(15,2));
  case Rg.bl of
    1: begin
         Drive^.Insert(New(PDiskParm, Init(1,40,8)));
         Drive^.Insert(New(PDiskParm, Init(1,40,9)));
         Drive^.Insert(New(PDiskParm, Init(2,40,8)));
         Drive^.Insert(New(PDiskParm, Init(2,40,9)));
         Drive^.Insert(New(PDiskParm, Init(2,40,10)));
         Drive^.Insert(New(PDiskParm, Init(2,42,10)));
       end;
    2: begin
         Drive^.Insert(New(PDiskParm, Init(1,40,8)));
         Drive^.Insert(New(PDiskParm, Init(1,40,9)));
         Drive^.Insert(New(PDiskParm, Init(2,40,8)));
         Drive^.Insert(New(PDiskParm, Init(2,40,9)));
         Drive^.Insert(New(PDiskParm, Init(2,40,10)));
         Drive^.Insert(New(PDiskParm, Init(2,42,10)));
         Drive^.Insert(New(PDiskParm, Init(2,80,9)));
         Drive^.Insert(New(PDiskParm, Init(2,80,10)));
         Drive^.Insert(New(PDiskParm, Init(2,82,10)));
         Drive^.Insert(New(PDiskParm, Init(2,80,15)));
         Drive^.Insert(New(PDiskParm, Init(2,82,15)));
         Drive^.Insert(New(PDiskParm, Init(2,80,17)));
         Drive^.Insert(New(PDiskParm, Init(2,82,17)));
         Drive^.Insert(New(PDiskParm, Init(2,80,18)));
         Drive^.Insert(New(PDiskParm, Init(2,82,18)));
       end;
    3: begin
         Drive^.Insert(New(PDiskParm, Init(1,40,8)));
         Drive^.Insert(New(PDiskParm, Init(1,40,9)));
         Drive^.Insert(New(PDiskParm, Init(2,40,8)));
         Drive^.Insert(New(PDiskParm, Init(2,40,9)));
         Drive^.Insert(New(PDiskParm, Init(2,40,10)));
         Drive^.Insert(New(PDiskParm, Init(2,42,10)));
         Drive^.Insert(New(PDiskParm, Init(2,80,9)));
         Drive^.Insert(New(PDiskParm, Init(2,80,10)));
         Drive^.Insert(New(PDiskParm, Init(2,82,10)));
       end;
    4: begin
         Drive^.Insert(New(PDiskParm, Init(1,40,8)));
         Drive^.Insert(New(PDiskParm, Init(1,40,9)));
         Drive^.Insert(New(PDiskParm, Init(2,40,8)));
         Drive^.Insert(New(PDiskParm, Init(2,40,9)));
         Drive^.Insert(New(PDiskParm, Init(2,40,10)));
         Drive^.Insert(New(PDiskParm, Init(2,42,10)));
         Drive^.Insert(New(PDiskParm, Init(2,80,9)));
         Drive^.Insert(New(PDiskParm, Init(2,80,10)));
         Drive^.Insert(New(PDiskParm, Init(2,82,10)));
         Drive^.Insert(New(PDiskParm, Init(2,80,15)));
         Drive^.Insert(New(PDiskParm, Init(2,82,15)));
         Drive^.Insert(New(PDiskParm, Init(2,80,17)));
         Drive^.Insert(New(PDiskParm, Init(2,82,17)));
         Drive^.Insert(New(PDiskParm, Init(2,80,18)));
         Drive^.Insert(New(PDiskParm, Init(2,82,18)));
         Drive^.Insert(New(PDiskParm, Init(2,80,21)));
         Drive^.Insert(New(PDiskParm, Init(2,82,21)));
       end;
  end;
end;

begin
  TApplication.InitDeskTop;
  OldExitProc := ExitProc;
  ExitProc := @MyExitProc;
  Drives := New(PStringCollection, Init(2,1));
  Rg.ah:=$08; Rg.dl:=0;
  Intr($13,Rg);
  if Rg.bl in [1..4] then
  SetDriveParm(DriveA);
  if DriveA <> nil then
  case Rg.bl of
    1: Drives^.Insert(NewStr('A: [360K]'));
    2: Drives^.Insert(NewStr('A: [1.2M]'));
    3: Drives^.Insert(NewStr('A: [720K]'));
    4: Drives^.Insert(NewStr('A: [1.4M]'));
  end;
  Rg.ah:=$08; Rg.dl:=1;
  Intr($13,Rg);
  if Rg.bl in [1..4] then
  SetDriveParm(DriveB);
  if DriveB <> nil then
  case Rg.bl of
    1: Drives^.Insert(NewStr('B: [360K]'));
    2: Drives^.Insert(NewStr('B: [1.2M]'));
    3: Drives^.Insert(NewStr('B: [720K]'));
    4: Drives^.Insert(NewStr('B: [1.4M]'));
  end;
end;

procedure TFormatApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PMyStatus, Init(R,
    NewStatusDef(1, 9,
      NewStatusKey('~Alt-X~ Quit', kbAltX, cmQuit,
      NewStatusKey('', kbEsc, cmCancel,
      NewStatusKey('', kbF10, cmMenu,
      nil))),
    NewStatusDef(0, $FFFF,
      NewStatusKey('~ESC~ Cancel', kbEsc, cmCancel,
      nil),
    nil))
  ));
end;

procedure TFormatApp.InitMenuBar;
var
  R: TRect;
  DB: Array[0..12] Of Word;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  if not Init_Roll then DEK := 'DEK';
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu(DEK+' SoftWorks DVFormat '+VS, hcNoContext, NewMenu(
      NewItem('~A~bout...', '', kbAltSpace, cmAbout, 12,
      NewItem('A~c~count', 'F9', kbF9, cmUserList, 13,
      nil))),
    nil)
  )));
end;

procedure TFormatApp.OutOfMemory;
begin
  MessageBox('Not enough memory available to complete operation.',
    nil, mfError + mfOkButton);
end;

procedure TFormatApp.EventError(var Event: TEvent);
begin
  if Event.What = evKeyDown then
    PError;
  ClearEvent(Event);
end;

procedure TFormatApp.HandleEvent(var Event: TEvent);

procedure About;
var
  D: PDialog;
  R: TRect;

begin
  R.Assign(0, 0, 44, 15);
  D := New(PDialog, Init(R, 'About'));
  with D^ do
  begin
    Options := Options or ofCentered;
    HelpCtx := 11;
    R.Grow(-1, -1);
    Dec(R.B.Y, 3);
    Insert(New(PStaticText, Init(R,
      #13 +
      ^C'DVFormat '+VS+#13 +
      #13 +
      ^C'Interface programming & design'#13+
      #13 +
      ^C'Copyright (c) 1991,92 DEK SoftWorks (tm)'#13 +
      #13 +
      ^C'Diskette format module (VFORMAT 1.5) by'#13 +
      #13 +
      ^C'C.H. Hochstatter  &  A.V. Sessa'#13 +
      #13 +
      ^C'')));

    R.Assign(17, 12, 27, 14);
    Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));
  end;
  if ValidView(D) <> nil then
  begin
    Desktop^.ExecView(D);
    Dispose(D, Done);
  end;
end;

procedure ShowUserList;
var
  D: PDialog;
  R: TRect;

begin
  R.Assign(0, 0, 36, 18);
  D := New(PDialog, Init(R, 'Registered users list'));
  with D^ do
  begin
    Options := Options or ofCentered;
    HelpCtx := 10;
    R.Grow(-1, -1);
    Dec(R.B.Y, 3);
    Insert(New(PStaticText, Init(R,
      #13+
      ^C'User name     Date'#13+
      ^C+CharStr('─',20)+#13+
      ^C' 1.'+Pad(CArea.UserList[1].Name,12)+DateToDateString('mm/dd/yy',CArea.UserList[1].Date1)+#13+
      ^C' 2.'+Pad(CArea.UserList[2].Name,12)+DateToDateString('mm/dd/yy',CArea.UserList[2].Date1)+#13+
      ^C' 3.'+Pad(CArea.UserList[3].Name,12)+DateToDateString('mm/dd/yy',CArea.UserList[3].Date1)+#13+
      ^C' 4.'+Pad(CArea.UserList[4].Name,12)+DateToDateString('mm/dd/yy',CArea.UserList[4].Date1)+#13+
      ^C' 5.'+Pad(CArea.UserList[5].Name,12)+DateToDateString('mm/dd/yy',CArea.UserList[5].Date1)+#13
      )));
    Inc(R.A.Y,8);
    Insert(New(PStaticText, Init(R,
      ^C' 6.'+Pad(CArea.UserList[6].Name,12)+DateToDateString('mm/dd/yy',CArea.UserList[6].Date1)+#13+
      ^C' 7.'+Pad(CArea.UserList[7].Name,12)+DateToDateString('mm/dd/yy',CArea.UserList[7].Date1)+#13+
      ^C' 8.'+Pad(CArea.UserList[8].Name,12)+DateToDateString('mm/dd/yy',CArea.UserList[8].Date1)+#13+
      ^C' 9.'+Pad(CArea.UserList[9].Name,12)+DateToDateString('mm/dd/yy',CArea.UserList[9].Date1)+#13+
      ^C'10.'+Pad(CArea.UserList[10].Name,12)+DateToDateString('mm/dd/yy',CArea.UserList[10].Date1)+#13+

      ^C'')));

    R.Assign(12, 15, 22, 17);
    Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));
  end;
  if ValidView(D) <> nil then
  begin
    Desktop^.ExecView(D);
    Dispose(D, Done);
  end;
end;

begin
  TApplication.HandleEvent(Event);
  case Event.What of
    evCommand:
      begin
        case Event.Command of
          cmAbout:
            About;
          cmUserList:
            ShowUserList;
          cmCancel:
            Event.Command := cmQuit;
          cmBegin:
            begin
              W2 := New(PInfoWindow, Init);
              DeskTop^.Insert(W2);
              MainD^.GetData(MainDlg);
              DrvPar := PDiskParm(MainDlg.SzC^.At(MainDlg.SzN));
              with MainDlg do
                FormatMain(Char(DrvN+65),DrvPar^.Heads,DrvPar^.Tracks,
                DrvPar^.Sectors,Boolean(CArea.PS2),Boolean(RData));
              Dispose(W2, Done);
              Info.OpString := '';
              Info.ComplPerc := 0;
              Info.Bad := 0;
              Info.Good := 0;
            end;
        else
          Exit;
        end;
        ClearEvent(Event);
      end;
  end;
end;


begin
  Sv90 := Old90;
  FormatApp.Init;
  PTmpApp := @FormatApp;
  Info.OpString := '';
  Info.ComplPerc := 0;
  Info.Bad := 0;
  Info.Good := 0;
  W1 := New(PInfWindow, Init);
  DeskTop^.Insert(W1);
  InitDSystem; 
  Dispose(W1, Done);
  MainD := New(PMainDialog, Init);
  DeskTop^.Insert(MainD);
  FormatApp.Run;
end.
