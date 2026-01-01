{************************************************************}
{                                                            }
{   Program is maked by Turbo Vision Constructor 2.0 1992.   }
{                                                            }
{************************************************************}

program Exampl;

{$X+}

uses Objects, Views, Drivers, Dialogs, App, Menus, MsgBox, TVDTools,
     HelpFile, TVFields, TVColl;

const
  { Commands }
  cmItem                   = 100;

const
  { HelpCtx }
  hcSubMenu                = 1000;
  hcItem                   = 1001;

type
  PExampl = ^TExampl;
  TExampl = object (TApplication)
    constructor Init;
    destructor Done; virtual;
    procedure HandleEvent(var Event : TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure OutOfMemory; virtual;
    function GetPalette : PPalette; virtual;
    procedure GetEvent(var Event : TEvent); virtual;
  end;

type
  TDialogData = record
    Name : String[32];
    Num  : LongInt;
  end;

var
  ProtectResFile : TResourceFile;
  DialogData : TDialogData;

{ TExampl }
constructor TExampl.Init;
begin
  RegisterType(RHelpStatusLine);
  RegisterHelpFile;
  RegisterDialogs;
  RegisterViews;
  RegisterFields;
  RegisterKeyCollection;

  { Init Resource }
  ProtectResFile.Init( New(PProtectStream, Init('Exampl.RES', stOpenRead, 1024)));

  { Load context help }
  Strings := PKeyCollection(ProtectResFile.Get('STRINGS'));

  TApplication.Init;

  { Init data }
  with DialogData do
  begin
    Name := 'This is a InputLine';
    Num  := 1992;
  end;
end;

destructor TExampl.Done;
begin
  Dispose(Strings, Done);
  TApplication.Done;
end;

procedure TExampl.HandleEvent(var Event : TEvent);

  procedure Item;
  var
    Dialog : PDialog;
  begin
    { Read Dialog from resource }
    Dialog := PDialog(ProtectResFile.Get('DIALOG'));

    { detects LowMemory }
    if ValidView(Dialog) <> nil then
    begin
      { set data in the Dialog }
      Dialog^.SetData(DialogData);

      { Exec the Dialog }
      if DeskTop^.ExecView(Dialog) <> cmCancel then
      begin
        { set data from Dialog }
        Dialog^.GetData(DialogData);
      end;

      { dispose dilaog from memory }
      Dispose(Dialog, Done);
    end;
  end;

begin
  TApplication.HandleEvent(Event);
  case Event.What of
    evCommand:
      begin
      case Event.Command of
        cmItem : Item;
      else
        Exit;
      end;
    ClearEvent(Event);
    end;
  end;
end;

procedure TExampl.InitMenuBar;
var
  R : TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y+1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~S~ubMenu', hcSubMenu, NewMenu(
      NewItem('~I~tem', '', kbNoKey, cmItem, hcItem,
      nil)),
    nil)
  )));
end;

procedure TExampl.InitStatusLine;
begin
  StatusLine := PStatusLine(ProtectResFile.Get('STATUSLINE'));
end;

function TExampl.GetPalette: PPalette;
const
  CNewColor = CColor + CHelpColor;
  CNewBlackWhite = CBlackWhite + CHelpBlackWhite;
  CNewMonochrome = CMonochrome + CHelpMonochrome;
  P: array[apColor..apMonochrome] of string[Length(CNewColor)] =
    (CNewColor, CNewBlackWhite, CNewMonochrome);
begin
  GetPalette := @P[AppPalette];
end;

procedure TExampl.GetEvent(var Event : TEvent);
var
  W : PWindow;
  HFile : PHelpFile;
  HelpStrm : PDosStream;
const
  HelpInUse : Boolean = False;
begin
  TApplication.GetEvent(Event);
  case Event.What of
    evCommand:
      if (Event.Command = cmHelp) and not HelpInUse then
      begin
        HelpInUse := True;
        HelpStrm := New(PDosStream, Init('Exampl.HLP', stOpenRead));
        HFile := New(PHelpFile, Init(HelpStrm));
        if HelpStrm^.Status <> stOk then
        begin
          MessageBox('Could not open help file.', nil, mfError + mfOkButton);
        end
        else
        begin
          W := New(PHelpWindow,Init(HFile, GetHelpCtx));
          if ValidView(W) <> nil then
          begin
            ExecView(W);
            Dispose(W, Done);
          end;
          ClearEvent(Event);
        end;
        HelpInUse := False;
      end;
  end;
end;

procedure TExampl.OutOfMemory;
begin
  MessageBox(^C'Not enough memory.', nil, mfError + mfOkButton);
end;

var
  AExampl : TExampl;

begin
  AExampl.Init;
  AExampl.Run;
  AExampl.Done;
end.
