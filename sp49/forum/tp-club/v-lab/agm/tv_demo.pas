{ ╔═════════════════════════════════════════════════════════════════════════╗ }
{ ║    Демонстpация совместимости "Alpha-Graphics Mouse" с Turbo Vision     ║ }
{ ║                                                                         ║ }
{ ║                    Copyright (c) V-LAB 1991,92                          ║ }
{ ╚═════════════════════════════════════════════════════════════════════════╝ }
program TV_Demo;
{$X+}

uses
  Objects,
  Drivers,
  Memory,
  Menus,
  Views,
  Dialogs,
  App,
  AGMouse,
  Graph;

const
  cmAbout           = 1000;
  cmSetMode8x14     = 1001;
  cmSetMode8x8      = 1002;
  cmStandartMouse   = 1003;
  cmGraphicsMouse   = 1004;
  smCurrentMode     : word = smCO80;
  EgaOrVga          : string [11] = ' 80 x ~4~3 ';

type

  PTVDemo = ^TTVDemo;
  TTVDemo = object(TApplication)
    constructor Init;
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
  end;

constructor TTVDemo.Init;
var
   M_Present     : Byte;
   GrDrv, GrMode : Integer;
begin
{ ────────────────── Пpовеpка , установлен - ли дpайвеp мыши ────────────── }   
  asm
    MOV   AX, 0
    INT   33H
    MOV   M_PRESENT, AL
  end;
 if M_Present <> $FF then begin
    Writeln ('Mouse drive not installed. Program aborted !',Chr(7));
    Halt (1);
 end;
{ ────────────── Пpовеpка , установлен - ли EGA или VGA ─────────────────── }
  DetectGraph(GrDrv, GrMode);
  case GrDrv of
   EGA,EGA64,EGAMono : EgaOrVga := ' 80 x ~4~3 ';
   VGA: EgaOrVga := ' 80 x ~5~0 ';
  else begin
        Writeln ('Program supported ONLY (!) EGA/VGA mode. Program aborted !',Chr(7));
        Halt (2);
       end;
  end;
  EnableAGMouse;
  TApplication.Init;
end;

procedure TTVDemo.HandleEvent(var Event: TEvent);

procedure SetMode (Mode : word);
begin
 if Mode = smCO80 then smCurrentMode := Mode else
                     smCurrentMode := smCO80 + Mode;
 HideMouse;
 SetScreenMode (smCurrentMode);
 ResetAGMouse;
 ShowMouse;
end;

procedure SetStandartMouse;
begin
 HideMouse;
 DisableAGMouse;
 asm
    MOV   AX, 4
    XOR   CX, CX
    XOR   DX, DX
    INT   33H
 end;
 ShowMouse;
end;

procedure SetGraphicsMouse;
begin
 HideMouse;
 EnableAGMouse;
 ShowMouse;
end;

procedure About;
var
  D: PDialog;
  Control: PView;
  R: TRect;
begin
  R.Assign(0, 0, 49, 14);
  D := New(PDialog, Init(R, 'About'));
  with D^ do
  begin
    Options := Options or ofCentered;
    R.Grow(-1, -1);
    Dec(R.B.Y, 3);
    Insert(New(PStaticText, Init(R,
      #13 +
      ^C'ALPHA - GRAPHICS MOUSE DEMO PROGRAM'#13 +
      #13 +
      ^C'This program supported only EGA or VGA card'#13 +
      ^C'and Microsoft compatible mouse driver'#13 +
      #13 +
      ^C'Copyright V-LAB 1991,92'#13 +
      #13 +
      ^C'See also "AGM.DOC" ...')));
    R.Assign(18, 11, 28, 13);
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
          cmAbout: About;
          cmSetMode8x14: if smCurrentMode <> smCO80 then SetMode (smCO80);
          cmSetMode8x8: if smCurrentMode = smCO80 then SetMode (smFont8x8);
          cmStandartMouse: SetStandartMouse;
          cmGraphicsMouse: SetGraphicsMouse;
        else
          Exit;
        end;
        ClearEvent(Event);
      end;
  end;
end;

procedure TTVDemo.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y+1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu(' ~V~ideoMode ', 0 , NewMenu(
      NewItem(' 80 x ~2~5 ', '', kbNoKey, cmSetMode8x14, 0,
      NewItem( EgaOrVga, '', kbNoKey, cmSetMode8x8, 0, nil ))),
    NewSubMenu(' ~M~ouse ', 0 , NewMenu(
      NewItem(' ~S~tandart ', '', kbNoKey, cmStandartMouse, 0,
      NewItem(' ~G~raphics ', '', kbNoKey, cmGraphicsMouse, 0, nil ))),
    NewSubMenu(' ~Q~uit! ', 0 , NewMenu (
      NewItem(' ~Q~uit! ', '', kbAltX, cmQuit, 0, nil )),
    NewSubMenu(' ~A~bout ', 0 , NewMenu (
      NewItem(' ~A~bout ', ' F1 ', kbF1, cmAbout, 0, nil )) , nil )))))));
end;

procedure TTVDemo.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~F1~ About', kbF1, cmAbout,
      NewStatusKey('~Alt-X~ Quit', kbAltX, cmQuit, nil)), nil)));
end;

destructor TTVDemo.Done;
begin
  DoneSysError;
  DoneEvents;
  DoneMemory;
  DoneVideo;
  DisableAGMouse;
  SetMemTop(HeapPtr);
end;

var
  Demo: TTVDemo;

begin
  Demo.Init;
  Demo.Run;
  Demo.Done;
end.