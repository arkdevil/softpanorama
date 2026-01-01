program GVDemo;
{$V-}
{$X+}

uses Objects, Drivers, Views, Menus, Dialogs, App, MsgBox, Memory, Dos,
     Graph, GVision;
(*
{$L VGARFONT}
procedure VgaFont; external;
*)
var
  ModeStr: string[1];
  Mode: word;

(*{$define Trace}*)

{$ifdef Trace}
var
  Trace: text;
  TraceBuf: array[1..8*1024] of byte;
  I: word;
  S: string;
type
  String16=string[16];
const
  sfName: array[0..11] of string16=
    ('sfVisible','sfCursorVis','sfCursorIns','sfShadow',
     'sfActive','sfSelected','sfFocused','sfDragging',
     'sfDisabled','sfModal','sfDefault','sfExposed');
  evName: array[0..6] of string16=
    ('evMouseDown','evMouseUp','evMouseMove','evMouseAuto','evKeyDown',
     'evCommand','evBroadcast');
{$endif}

const
  WinCount: Integer =   0;

  cmFileOpen        = 100;
  cmNewWindow       = 101;
  cmNewSpecWin      = 102;
  cmReadPCX         = 103;
  cmWritePCX        = 104;
  cmNewDialog       = 106;
  cmDosShell        = 110;
  cmSaveDesktop     = 111;
  cmRetrieveDesktop = 112;

  ActiveCommands: TCommandSet = [cmReadPCX, cmWritePCX, cmTile, cmCascade];
  WindowCnt: word = 0;

type
  RGBPaletteType = array[0..47] of byte;

  TMyApp = object(TApplication)
    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure NewWindow(UseBuf: boolean);
    procedure NewDialog;
    procedure LoadDesktop(var S: TStream);
    procedure OutOfMemory; virtual;
    procedure StoreDesktop(var S: TStream);
  end;

  PDemoWindow = ^TDemoWindow;
  TDemoWindow = object(TWindow)
    Interior: PGView;
    constructor Init(Bounds: TRect; WindowNo: Word; UseBuf: boolean);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream); virtual;
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  PInterior = ^TInterior;
  TInterior = object(GView)
    UseBuf: boolean;
    PCXPage: word;
    PCXPalette: RGBPaletteType;
    FirstDrawFlag: boolean;
    constructor Init(var Bounds: TRect; BufBounds: TRect; AUseBuf: boolean);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream); virtual;
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetState(AState: word; Enable: boolean); virtual;
  end;

  PDemoDialog = ^TDemoDialog;
  TDemoDialog = object(TDialog)
  end;

  DialogDataType = record
    MouseShape:  word;
    MouseAction: word;
    SwapMode:    word;
    PaletteData: word;
  end;

var
  DialogData: DialogDataType;
  PCXName: FNameStr;
  StandardPalette: RGBPaletteType;
  LastPCXPalette: RGBPaletteType;

const
  RDemoWindow: TStreamRec = (
    ObjType: 200;
    VmtLink: Ofs(TypeOf(TDemoWindow)^);
    Load: @TDemoWindow.Load;
    Store: @TDemoWindow.Store
  );
  RInterior: TStreamRec = (
    ObjType: 201;
    VmtLink: Ofs(TypeOf(TInterior)^);
    Load: @TInterior.Load;
    Store: @TInterior.Store
  );


constructor TDemoWindow.Init(Bounds: TRect; WindowNo: Word; UseBuf: boolean);
var
  S: string[3];
  R: trect;
begin
  if WindowCnt = 0 then
    EnableCommands(ActiveCommands);
  Inc(WindowCnt);

  Str(WindowNo, S);
  if UseBuf then
  begin
    TWindow.Init(Bounds, 'Demo Window ' + S, wnNoNumber);
    Options := Options or ofTileable;
{    Options := Options and not ofBuffered;}{}
    GetClipRect(Bounds);
    Bounds.Grow(-1, -1);
    R.Assign(0, 0, 80, 58);
    Interior := New(PInterior, Init(Bounds, R, UseBuf));
    Insert(Interior);

    Interior^.InitScrollBar(sbHorizontal, 1, 1);
    Interior^.InitScrollBar(sbVertical, 0, 0);
  end
  else
  begin
    TWindow.Init(Bounds, 'Spec Window ' + S, wnNoNumber);
    GetClipRect(Bounds);
    Bounds.Grow(-1, -1);
    R.Assign(0, 0, 0, 0);
    Interior := New(PInterior, Init(Bounds, R, UseBuf));
    Insert(Interior);
  end;
end;

constructor TDemoWindow.Load(var S: TStream);
begin
  TWindow.Load(S);
  GetSubViewPtr(S, Interior);

  if WindowCnt = 0 then
    EnableCommands(ActiveCommands);
  Inc(WindowCnt);
end;{constructor TDemoWindow.Load}

procedure TDemoWindow.Store(var S: TStream);
begin
  TWindow.Store(S);
  PutSubViewPtr(S, Interior);
end;{TDemoWindow.Store}

destructor TDemoWindow.Done;
begin
  Dec(WindowCnt);
  if WindowCnt = 0 then
    DisableCommands(ActiveCommands);
  TWindow.Done;
end;

procedure TDemoWindow.HandleEvent(var Event: TEvent);
begin
  if Event.What and evCommand<>0 then
    Interior^.HandleEvent(Event);
  TWindow.HandlEevent(Event);
end;

constructor TInterior.Init(var Bounds: TRect; BufBounds: TRect;
                           AUseBuf: boolean);
begin
  GView.Init(Bounds, BufBounds);
  GrowMode := gfGrowHiX + gfGrowHiY;
  Options := Options or ofFramed;

  if DialogData.SwapMode <> 0 then
    SetSwapMode(True);

  UseBuf := AUseBuf;
  if UseBuf then
    PCXPage := 1
  else
    PCXPage := 0;

  PCXPalette := StandardPalette;
  FirstDrawFlag := True;
end;

constructor TInterior.Load(var S: TStream);
begin
  GView.Load(S);
  S.Read(UseBuf, SizeOf(TInterior) - SizeOf(GView));
end;

procedure TInterior.Store(var S: TStream);
begin
  GView.Store(S);
  S.Write(UseBuf, SizeOf(TInterior) - SizeOf(GView));
end;

procedure DrawStr(S: string; X, Y: integer; DX, DY: integer; Color: word);
type
  FontType = array[0..256*16-1] of byte;
var
  Font: ^FontType absolute SysFontPtr;
  CharI: byte;
  CharFontOfs: word;
  DotX, DotY: integer;
  Row, Col: integer;
begin
  SetFillStyle(SolidFill, Color);
  for CharI := 1 to Length(S) do
  begin
    CharFontOfs := Byte(S[CharI]) * FontSize;
    DotY := Y;
    for Row := 0 to FontSize - 1 do
    begin
      DotX := X + (CharI-1)*DX*10 - Row*2;
      for Col := 0 to 7 do
      begin
        if Font^[CharFontOfs + Row] and ($80 shr Col) > 0 then
        begin
          Bar(DotX, DotY,
              DotX + DX-1, DotY + DY-1);
        end;
        Inc(DotX, DX);
      end;{for Col := 0 to 7 do}
      Inc(DotY, DY);
    end;{for Row := 0 to FontSize - 1 do}
  end;{for CharI := 1 to Length(S) do}
end;{procedure DrawStr}

procedure TInterior.Draw;
var
  Mouse: TPoint;
  I: word;
  X, Y: integer;
  S: string;
begin
  Str(GPtrI:2, S);
  if S[1] = ' ' then
    S[1] := '0';

  InitDraw;

  if GState and gsSwapError > 0 then
  begin
    Str(SwapErrorCode, S);
    ClearViewPort;
    SetColor(LightRed);
    OutTextXY(0, 0, 'Swap error. Dos error code = ' + S);
    DoneDraw;
    Exit;
  end;

  if FirstDrawFlag then
  begin
    FirstDrawFlag := False;

    with Mouse do
    begin
      X := 0;
      Y := 0;
      GetGlobalPos(0, Mouse, Mouse);
      SetMousePos(Mouse);
    end;

    ClearViewPort;

    SetColor(LightRed);
    OutTextXY(300, 50, 'ABCabc1234567890');

    Circle(319, 200, 100);
    Circle(639, 21*14+200, 300);

    X := 0;
    Y := 0;
    for I := 1 to 15 do
    begin
      SetFillStyle(SolidFill, I);
      Bar(X, Y, X+80, Y+40);
      Inc(X, 40);
      Inc(Y, 20);
    end;

    DrawStr(S, 90, 30, 10, 10, Yellow);

    if UseBuf then
    begin
      SetColor(Yellow);
      OutTextXY(0,  0, 'You may draw with Mouse in this Window');
      OutTextXY(0, 10, 'or Scroll after ''Scroll Lock'' was pressed');
      OutTextXY(0, 20, 'or read(F3)/write(F2) PCX files');
    end
    else
    begin
      SetColor(LightRed);
      OutTextXY(0,  0, 'This is a Special Window');
      OutTextXY(0, 10, 'Do not overlap or move it');
      SetColor(Yellow);
      OutTextXY(0, 20, 'You may draw with Mouse in this Window');
      OutTextXY(0, 30,'or read(F3)/write(F2) PCX files');
    end;
  end;{if FirstDrawFlag then}

  DoneDraw;

  WriteStr(2 - Scroll.X, 5 - Scroll.Y, S, 2);
end;{procedure TInterior.Draw}

procedure TInterior.HandleEvent(var Event: TEvent);

function InputPCXName(ALabel: string): word;
var
  C: word;
begin
  C := InputBox('PCX File', ALabel, PCXName, SizeOf(PCXName)-1);
  if C <> cmCancel then
  begin
    if Pos('.', PCXName)=0 then
      PCXName := PCXName+'.PCX';
  end;
  InputPCXName := C;
end;

procedure ErrorMsg;
var
  Msg: string;
begin
  case GError of
    2: Msg := 'File ' + PCXName + ' not found';
    3: Msg := 'Path not found';
    4: Msg := 'Too many open files';
    5: Msg := 'Access denied';
    8: Msg := 'Insufficient memory';
    11:Msg := 'Invalid format';
    29:Msg := 'Write fault error';
    30:Msg := 'Read fault error';
    80:Msg := 'File ' + PCXName + 'already exists';
  else
    Str(GError, Msg);
    Msg := 'GError = ' + Msg;
  end;{case GError of}
  MessageBox(Msg + '.', nil, mfError + mfOkButton);
end;{procedure ErrorMsg}

var
  C: word;
  kbState: byte absolute 0:$417;
  Start: boolean;
  Mouse: TPoint;
  Scroll0: TPoint;

begin{procedure TInterior.HandleEvent}
{$ifdef Trace}
  with Event do
  begin
    I := 0;
    while 1 shl I < What do
      inc(I);
    if I >= 8 then
      dec(I, 3);
    Write(Trace, GPtrI, '    What = ', evName[I]);
    if I >= 5 then
      Write(Trace,' Command = ', Command);
    Writeln(Trace);
  end;
{$endif}

  GView.HandlEevent(Event);

  case Event.What of
    evCommand:
    begin
      case Event.Command of
        cmReadPCX:
        begin
          if InputPCXName('Enter Input PCX File Name') <> cmCancel then
          begin
            SetViewPage(PCXPage);
            ReadView(foPCX, PCXName, PCXPalette);
            if GError <> 0 then
              ErrorMsg;
            if UseBuf then
              DrawView;
            if GError = 0 then
            begin
              LastPCXPalette := PCXPalette;
              if DialogData.PaletteData = 1 then
                SetAllRGBPalette(0, PCXPalette);
            end;
          end;{if InputPCXName <> cmCancel then}
          ClearEvent(Event);
        end;{cmReadPCX:}
        cmWritePCX:
        begin
          if InputPCXName('Enter Output PCX File Name') <> cmCancel then
          begin
            SetViewPage(PCXPage);
            WriteView(foPCX + foCheckFile, PCXName, PCXPalette);
            if GError = 80 then
            begin
              if MessageBox('File ' + PCXName + ' already exists.' +
                 ' Overwrite?', nil, mfWarning + mfYesNoCancel) = cmYes then
                WriteView(foPCX, PCXName, PCXPalette)
              else
                GError := 0;
            end;
            if GError<>0 then
              ErrorMsg;
          end;{if InputPCXName <> cmCancel then}
          ClearEvent(Event);
        end;{cmWritePCX:}
      end;
    end;{evCommand:}

    evMouseDown:
    begin
      if (kbState and kbScrollState = 0) and
        (DialogData.MouseAction = 0) then
      begin
        Start := True;
        SetLineStyle(SolidLn, 0, 1);
        SetColor(Yellow);
        SetViewPage(0);

        repeat
          GetLocalPos(0, GMouseWhere, Mouse);
          with Mouse do
          begin
            if Start then
            begin
              Start := False;
              Graph.MoveTo(X, Y);
            end
            else
            begin
              HideMouse;
              LineTo(X, Y);
              ShowMouse;
            end;
          end;{with Mouse do}
        until not MouseEvent(Event, evMouseMove);

        SaveView;
      end{if (kbState and kbScrollState = 0) and}
      else
      begin
        Mouse := MouseWhere;
        Scroll0 := Scroll;
        repeat
          ScrollTo(Scroll0.X+(Mouse.X-MouseWhere.X),
                   Scroll0.Y+(Mouse.Y-MouseWhere.Y));
          if GState and gsScrollEnd > 0 then
          begin
            Mouse := MouseWhere;
            Scroll0 := Scroll;
          end;
        until not MouseEvent(Event, evMouseMove);
      end;{if (kbState and kbScrollState = 0) and}

      ClearEvent(Event);
    end;{evMouseDown:}
  end;{case Event.What of}
end;{procedure TInterior.HandleEvent}

procedure TInterior.SetState(AState: word; Enable: boolean);
begin
  if (AState and sfActive > 0) and Enable and
     (DialogData.PaletteData = 1) then
  begin
    SetAllRGBPalette(0, PCXPalette);
    LastPCXPalette := PCXPalette;
  end;

{$ifdef Trace}
  I := 0;
  while 1 shl I < AState do
    Inc(I);
  WriteLn(Trace, GPtrI, ' AState = ', sfName[I],'   ',Enable);
{$endif}

  GView.SetState(AState,Enable);
end;

procedure Tile;
var
  R: TRect;
begin
  Desktop^.GetExtent(R);
  Desktop^.Tile(R);
end;

procedure Cascade;
var
  R: TRect;
begin
  Desktop^.GetExtent(R);
  Desktop^.Cascade(R);
end;

constructor TMyApp.Init;
begin
  TApplication.Init;
  RegisterTypes;
  RegisterGVision;
  RegisterType(RDemoWindow);
  RegisterType(RInterior);
end;

procedure TMyApp.HandleEvent(var Event: TEvent);

procedure RetrieveDesktop;
var
  S: PStream;
begin
  S := New(PBufStream, Init('GVDEMO.DSK', stOpenRead, 1024));
  if LowMemory then OutOfMemory
  else if S^.Status <> stOk then
    MessageBox('Could not open desktop file', nil, mfOkButton + mfError)
  else
  begin
    LoadDesktop(S^);
    if S^.Status <> stOk then
      MessageBox('Could not read desktop file', nil, mfOkButton + mfError);
  end;
  Dispose(S, Done);
end;

procedure SaveDesktop;
var
  S: PStream;
  F: File;
  Msg: string;
begin
  S := New(PBufStream, Init('GVDEMO.DSK', stCreate, 1024));
  if not LowMemory and (S^.Status = stOk) then
  begin
    StoreDesktop(S^);
    if S^.Status <> stOk then
    begin
      Str(S^.Status, Msg);
      MessageBox(Msg + ': Could not create GVDEMO.DSK.', nil,
                 mfOkButton + mfError);
      {$I-}
      Dispose(S, Done);
      Assign(F, 'GVDEMO.DSK');
      Erase(F);
      Exit;
    end;
  end;
  Dispose(S, Done);
end;

procedure DosShell;
begin
  DoneSysError;
  DoneEvents;
  DoneVideo;
  DoneMemory;
  SaveGVision;
  SetMemTop(HeapPtr);
  PrintStr('Type EXIT to return...');
  SwapVectors;
  Exec(GetEnv('COMSPEC'), '');
  SwapVectors;
  SetMemTop(HeapEnd);
  RestoreGVision;
  InitMemory;
  InitVideo;
  InitEvents;
  InitSysError;
  Redraw;
end;

begin{procedure TMyApp.HandleEvent}
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmNewWindow: NewWindow(True);
      cmNewSpecWin: NewWindow(False);
      cmNewDialog: NewDialog;
      cmCascade: Cascade;
      cmTile: Tile;
      cmDosShell: DosShell;
      cmSaveDesktop: SaveDesktop;
      cmRetrieveDesktop: RetrieveDesktop;
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure TMyApp.InitMenuBar;
var R: TRect;
begin
  DisableCommands(ActiveCommands);

  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      NewItem('~W~indow', 'F4', kbF4, cmNewWindow, hcNoContext,
      NewItem('D~i~alog', 'F7', kbF7, cmNewDialog, hcNoContext,
      NewItem('~S~pecWin', 'F8', kbF8, cmNewSpecWin, hcNoContext,
      NewItem('~R~ead PCX', 'F3', kbF3, cmReadPCX, hcNoContext,
      NewItem('Wri~t~e PCX', 'F2', kbF2, cmWritePCX, hcNoContext,
      NewLine(
      NewItem('~D~OS shell', '', kbNoKey, cmDosShell, hcNoContext,
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      nil))))))))),
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
      NewItem('~Z~oom', 'F5', kbF5, cmZoom, hcNoContext,
      NewItem('~N~ext', 'F6', kbF6, cmNext, hcNoContext,
      NewItem('~C~lose' , 'Alt-F3', kbAltF3, cmClose, hcNoContext,
      NewItem('~T~ile', '', kbNoKey, cmTile, hcNoContext,
      NewItem('C~a~scade', '', kbNoKey, cmCascade, hcNoContext,
      nil)))))),
    NewSubMenu('~D~esktop', hcNoContext, NewMenu(
      NewItem('~S~ave desktop', '', kbNoKey, cmSaveDesktop, hcNoContext,
      NewItem('~R~etrieve desktop', '', kbNoKey, cmRetrieveDesktop, hcNoContext,
      nil))),
    nil))
  ))));
end;

procedure TMyApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~F4~ Window', kbF4, cmNewWindow,
      NewStatusKey('~F7~ Dialog', kbF7, cmNewDialog,
      NewStatusKey('~F8~ SpecWin', kbF8 ,cmNewSpecWin,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      nil)))))),
    nil)
  ));
end;

procedure TMyApp.NewWindow(UseBuf: boolean);
var
  Window: PView;
  R: TRect;
begin
  Inc(WinCount);
  R.Assign(0, 0, 43, 12);
  R.Move(Random(40), Random(16));
  Window := ValidView(New(PDemoWindow, Init(R, WinCount, UseBuf)));
  if Window <> nil then
    DeskTop^.Insert(Window)
  else
    MessageBox('Number of graphics windows exceeds 63' +
               ' or insufficient memory.', nil, mfError + mfOkButton);
end;

procedure ExecDialog;
const
  MouseCross: array[1..2, 1..16] of word=
    (($ffff,$fc7f,$fc7f,$fc7f,$fc7f,$fc7f,$0380,$0380,
      $0380,$fc7f,$fc7f,$fc7f,$fc7f,$fc7f,$fc7f,$ffff),
     ($0000,$0100,$0100,$0100,$0100,$0100,$0000,$fc7f,
      $0000,$0100,$0100,$0100,$0100,$0100,$0100,$0000));

begin
  with DialogData do
  begin
    case MouseShape of
      0: SetMouseStandard;
      1: SetMouseShape(7, 7, MouseCross);
    end;

    case PaletteData of
      0: SetRGBStandard(0);
      1: SetAllRGBPalette(0, LastPCXPalette);
      2: SetRGBGrayShades(0);
    end;
  end;
end;

procedure TMyApp.NewDialog;
var
  Bruce: PView;
  Dialog: PDemoDialog;
  R: TRect;
  C: Word;
begin
  R.Assign(20, 6, 60, 19);
  Dialog := New(PDemoDialog, Init(R, 'Dialog'));
  with Dialog^ do
  begin
    R.Assign(2, 3, 15, 5);
    Bruce := New(PRadioButtons, Init(R,
      NewSItem('~A~rrow',
      NewSItem('~C~ross',
      nil))
    ));
    Insert(Bruce);
    R.Assign(2, 2, 15, 3);
    Insert(New(PLabel, Init(R, 'Mouse Shape', Bruce)));

    R.Assign(2, 7, 15, 9);
    Bruce := New(PRadioButtons, Init(R,
      NewSItem('~D~raw',
      NewSItem('~S~croll',
      nil))
    ));
    Insert(Bruce);
    R.Assign(2, 6, 15, 7);
    Insert(New(PLabel, Init(R, 'Mouse Action', Bruce)));

    R.Assign(21, 3, 37, 4);
    Bruce := New(PCheckBoxes, Init(R,
      NewSItem('Swap ~M~ode',
      nil)
    ));
    Insert(Bruce);
    R.Assign(21, 2, 37, 3);
    Insert(New(PLabel, Init(R, 'Virtual Windows', Bruce)));

    R.Assign(21, 6, 37, 9);
    Bruce := New(PRadioButtons, Init(R,
      NewSItem('S~t~andard',
      NewSItem('~P~cx',
      NewSItem('~G~ray Shades',
      nil)))
    ));
    Insert(Bruce);
    R.Assign(21, 5, 37, 6);
    Insert(New(PLabel, Init(R, 'Palette', Bruce)));

    R.Assign(13, 10, 23, 12);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(27, 10, 37, 12);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
  end;
  Dialog^.SetData(DialogData);
  C := DeskTop^.ExecView(Dialog);
  if C <> cmCancel then
  begin
    Dialog^.GetData(DialogData);
    ExecDialog;
  end;
  Dispose(Dialog, Done);
end;{procedure TMyApp.NewDialog}

procedure TMyApp.OutOfMemory;
begin
  MessageBox('Not enough memory available to complete operation.',
    nil, mfError + mfOkButton);
end;

{ Since the safety pool is only large enough to guarantee that allocating
  a window will not run out of memory, loading the entire desktop without
  checking LowMemory could cause a heap error.  This means that each
  window should be read individually, instead of using Desktop's Load.
}

procedure TMyApp.LoadDesktop(var S: TStream);
var
  P: PView;

procedure CloseView(P: PView); far;
begin
  Message(P, evCommand, cmClose, nil);
end;

begin
  if Desktop^.Valid(cmClose) then
  begin
    Desktop^.ForEach(@CloseView); { Clear the desktop }
    repeat
      P := PView(S.Get);
      Desktop^.InsertBefore(ValidView(P), Desktop^.Last);
    until P = nil;
  end;
end;

procedure TMyApp.StoreDesktop(var S: TStream);

procedure WriteView(P: PView); far;
begin
  if P <> Desktop^.Last then S.Put(P);
end;

begin
  Desktop^.ForEach(@WriteView);
  S.Put(nil);
end;

var
  MyApp: TMyApp;

begin
  if ParamCount=0 then
  begin
    Mode := ModeAvail;
    if Mode = smVGA then
      Mode := smVGA400;
  end{if ParamCount=0 then}
  else
  begin
    ModeStr := ParamStr(1);
    Mode := word(ModeStr[1]);
    if Mode <= $32 then
      Mode := (Mode and 3) + smEGA
    else
      Mode := (((Mode and 3) - 1) or smFont8x8) + smEGA;
  end;

{$ifdef Trace}
  Assign(Trace,'Trace');
  ReWrite(Trace);
  SetTextBuf(Trace,TraceBuf);
{$endif}

  InitGVision(Mode);
  if GError<>grOk then
  begin
    WriteLn(GraphErrorMsg(GError));
    Halt(1);
  end;
(*
  SetFont2(@VGAFont);
*)
  with DialogData do
  begin
    MouseShape  := 0;
    MouseAction := 0;
    SwapMode    := 0;
    PaletteData := 0;
  end;

  SetSwapParams('', 5);
  PCXName := '';
  GetAllRGBPalette(0, StandardPalette);
  LastPCXPalette := StandardPalette;

  MyApp.Init;
  MyApp.Run;
  MyApp.Done;

  DoneGVision;

{$ifdef Trace}
  Close(Trace);
{$endif}

  if ParamCount=0 then
  begin
    WriteLn;
    WriteLn('Specify graphics mode with parameter:');
    WriteLn('  0 - EGA,    8*14 font');
    WriteLn('  1 - VGA400, 8*16 font');
    WriteLn('  2 - VGA,    8*16 font');
    WriteLn('  A/B/C - same modes as 0/1/2, but 8*8 font');
    WriteLn('Defaults are:');
    WriteLn('  0 - EGA, 1 - VGA');
    WriteLn('Example:');
    WriteLn('  GVDemo B');
  end{if ParamCount=0 then}
end.
