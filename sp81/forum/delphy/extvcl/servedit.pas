{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
unit ServEdit;

interface

uses WinTypes, Classes, StdCtrls, Controls, Messages, SysUtils,
  Forms, Graphics, Menus, Buttons, Dialogs, FileCtrl, Mask;

const
  scAltDown = scAlt + vk_Down;

type

{ TCustomComboEdit }

  TCustomComboEdit = class(TCustomMaskEdit)
  private
    FButton: TSpeedButton;
    FBtnControl: TWinControl;
    FOnButtonClick: TNotifyEvent;
    FClickKey: TShortCut;
    FReadOnly: Boolean;
    FDirectInput: Boolean;
    FAlwaysEnable: Boolean;
    function GetMinHeight: Integer;
    procedure SetEditRect;
    procedure AdjustBounds;
    procedure EditButtonClick(Sender: TObject);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMEnter(var Message: TMessage); message CM_ENTER;
    function GetGlyph: TBitmap;
    procedure SetGlyph(Value: TBitmap);
    function GetButtonWidth: Integer;
    procedure SetButtonWidth(Value: Integer);
    function GetButtonHint: string;
    procedure SetButtonHint(const Value: string);
    function GetDirectInput: Boolean;
    procedure SetDirectInput(Value: Boolean);
    procedure SetReadOnly(Value: Boolean);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure ButtonClick; dynamic;
    property AlwaysEnable: Boolean read FAlwaysEnable write FAlwaysEnable default False;
    property Button: TSpeedButton read FButton;
    property ButtonWidth: Integer read GetButtonWidth write SetButtonWidth
      default 21;
    property ClickKey: TShortCut read FClickKey write FClickKey
      default scAltDown;
    property Glyph: TBitmap read GetGlyph write SetGlyph;
    property ButtonHint: string read GetButtonHint write SetButtonHint;
    property DirectInput: Boolean read GetDirectInput write SetDirectInput default True;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SelectAll;
  end;

{ TComboEdit }

  TComboEdit = class(TCustomComboEdit)
  public
    property Button;
  published
    property AutoSelect;
    property ButtonHint;
    property ButtonWidth;
    property CharCase;
    property ClickKey;
    property Color;
    property Ctl3D;
    property DirectInput;
    property DragCursor;
    property DragMode;
    property EditMask;
    property Enabled;
    property Font;
    property Glyph;
    property MaxLength;
    property OEMConvert;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnButtonClick;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

{ TFileDirEdit }
{ The common parent of TFilenameEdit and TDirectoryEdit          }
{ For internal use only; it's not intended to be used separately }

  TExecOpenDialogEvent = procedure(Sender: TObject; var Name: TFileName;
    var Action: Boolean) of object;

  TFileDirEdit = class(TCustomComboEdit)
  private
    FOnBeforeDialog: TExecOpenDialogEvent;
    FOnAfterDialog: TExecOpenDialogEvent;
  protected
    procedure DoAfterDialog(var FileName: TFileName; var Action: Boolean); dynamic;
    procedure DoBeforeDialog(var FileName: TFileName; var Action: Boolean); dynamic;
    property Glyph stored False;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property OnBeforeDialog: TExecOpenDialogEvent read FOnBeforeDialog
      write FOnBeforeDialog;
    property OnAfterDialog: TExecOpenDialogEvent read FOnAfterDialog
      write FOnAfterDialog;
  end;

{ TFilenameEdit }

  TFilenameEdit = class(TFileDirEdit)
  private
    FDialog: TOpenDialog;
    function GetDefaultExt: TFileExt;
    function GetFileEditStyle: TFileEditStyle;
    function GetFilter: string;
    function GetFilterIndex: Integer;
    function GetInitialDir: string;
    function GetHistoryList: TStrings;
    function GetOptions: TOpenOptions;
    function GetDialogTitle: string;
    function GetDialogFiles: TStrings;
    procedure SetDefaultExt(Value: TFileExt);
    procedure SetFileEditStyle(Value: TFileEditStyle);
    procedure SetFilter(const Value: string);
    procedure SetFilterIndex(Value: Integer);
    procedure SetInitialDir(const Value: string);
    procedure SetHistoryList(Value: TStrings);
    procedure SetOptions(Value: TOpenOptions);
    procedure SetDialogTitle(const Value: string);
    function IsCustomTitle: Boolean;
    function IsCustomFilter: Boolean;
  protected
    procedure ButtonClick; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Dialog: TOpenDialog read FDialog;
    property DialogFiles: TStrings read GetDialogFiles;
  published
    property DefaultExt: TFileExt read GetDefaultExt write SetDefaultExt;
    property FileEditStyle: TFileEditStyle read GetFileEditStyle write SetFileEditStyle
      default fsEdit;
    property Filter: string read GetFilter write SetFilter stored IsCustomFilter;
    property FilterIndex: Integer read GetFilterIndex write SetFilterIndex default 1;
    property InitialDir: string read GetInitialDir write SetInitialDir;
    property HistoryList: TStrings read GetHistoryList write SetHistoryList;
    property DialogOptions: TOpenOptions read GetOptions write SetOptions default [];
    property DialogTitle: string read GetDialogTitle write SetDialogTitle
      stored IsCustomTitle;
    property AutoSelect;
    property ButtonHint;
    property CharCase;
    property ClickKey;
    property Color;
    property Ctl3D;
    property DirectInput;
    property DragCursor;
    property DragMode;
    property EditMask;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

{ TDirectoryEdit }

  TDirectoryEdit = class(TFileDirEdit)
  private
    FOptions: TSelectDirOpts;
  protected
    procedure ButtonClick; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property DialogOptions: TSelectDirOpts read FOptions write FOptions default [];
    property AutoSelect;
    property ButtonHint;
    property CharCase;
    property ClickKey;
    property Color;
    property Ctl3D;
    property DirectInput;
    property DragCursor;
    property DragMode;
    property EditMask;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

{ TCustomDateEdit }

  TExecDateDialog = procedure(Sender: TObject; var Date: TDateTime;
    var Action: Boolean) of object;

  TCustomDateEdit = class(TCustomComboEdit)
  private
    FTitle: PString;
    FOnAfterDialog: TExecDateDialog;
    FDefaultToday: Boolean;
    function GetDialogTitle: string;
    function GetDate: TDateTime;
    procedure SetDialogTitle(const Value: string);
    procedure SetDate(Value: TDateTime);
    function IsCustomTitle: Boolean;
  protected
    procedure ButtonClick; override;
    property DialogTitle: string read GetDialogTitle write SetDialogTitle
      stored IsCustomTitle;
    property DefaultToday: Boolean read FDefaultToday write FDefaultToday
      default False;
    property Glyph stored False;
    property EditMask stored False;
    property OnAfterDialog: TExecDateDialog read FOnAfterDialog write FOnAfterDialog;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetDateMask: string;
    property Date: TDateTime read GetDate write SetDate;
  end;

{ TDateEdit }

  TDateEdit = class(TCustomDateEdit)
  public
    constructor Create(AOwner: TComponent); override;
    property EditMask;
  published
    property AutoSelect;
    property ButtonHint;
    property CharCase;
    property ClickKey;
    property Color;
    property Ctl3D;
    property DefaultToday;
    property DialogTitle;
    property DirectInput;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnAfterDialog;
    property OnButtonClick;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

function ValidFileName(const AName: TFileName): Boolean;

implementation

uses WinProcs, ExtConst, PickDate;

{$R *.RES}

const
  fResName = 'FEDITBMP'; { Filename Editor button glyph }
  dResName = 'DEDITBMP'; { Date Editor button glyph }

{ TCustomComboEdit }

constructor TCustomComboEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoSize := False;
  FDirectInput := True;
  FClickKey := scAltDown;
  FBtnControl := TWinControl.Create(Self);
  FBtnControl.Width := 21;
  FBtnControl.Height := 17;
  FBtnControl.Visible := True;
  FBtnControl.Parent := Self;
  FButton := TSpeedButton.Create(Self);
  FButton.SetBounds(0, 0, FBtnControl.Width, FBtnControl.Height);
  FButton.Visible := True;
  FButton.Parent := FBtnControl;
  FButton.OnClick := EditButtonClick;
  Height := 21;
end;

destructor TCustomComboEdit.Destroy;
begin
  FButton.OnClick := nil;
  inherited Destroy;
end;

procedure TCustomComboEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
end;

procedure TCustomComboEdit.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

procedure TCustomComboEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if FClickKey = ShortCut(Key, Shift) then begin
    EditButtonClick(Self);
    Key := 0;
  end;
end;

function TCustomComboEdit.GetButtonWidth: Integer;
begin
  Result := FButton.Width;
end;

procedure TCustomComboEdit.SetButtonWidth(Value: Integer);
var
  Msg: TMessage;
begin
  if (Value <> ButtonWidth) and (Value < ClientWidth) then
  begin
    FButton.Width := Value;
    AdjustBounds;
  end;
end;

function TCustomComboEdit.GetButtonHint: string;
begin
  Result := FButton.Hint;
end;

procedure TCustomComboEdit.SetButtonHint(const Value: string);
begin
  FButton.Hint := Value;
end;

function TCustomComboEdit.GetGlyph: TBitmap;
begin
  Result := FButton.Glyph;
end;

procedure TCustomComboEdit.SetGlyph(Value: TBitmap);
begin
  FButton.Glyph := Value;
end;

procedure TCustomComboEdit.SetEditRect;
var
  Loc: TRect;
begin
  Loc.Bottom := ClientHeight + 1;  {+1 is workaround for windows paint bug}
  Loc.Right := FBtnControl.Left - 2;
  Loc.Top := 0;
  Loc.Left := 0;
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@Loc));
end;

procedure TCustomComboEdit.WMSize(var Message: TWMSize);
begin
  inherited;
  AdjustBounds;
end;

procedure TCustomComboEdit.AdjustBounds;
var
  Loc: TRect;
  MinHeight: Integer;
begin
  MinHeight := GetMinHeight;
  { text edit bug: if size to less than minheight, then edit ctrl does
    not display the text }
  if Height < MinHeight then Height := MinHeight
  else begin
    FBtnControl.SetBounds(Width - FButton.Width, 0, FButton.Width, Height);
    FButton.Height := FBtnControl.Height;
    SetEditRect;
  end;
end;

function TCustomComboEdit.GetMinHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);
  GetTextMetrics(DC, SysMetrics);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  I := SysMetrics.tmHeight;
  if I > Metrics.tmHeight then I := Metrics.tmHeight;
  Result := Metrics.tmHeight + (I div 4) + GetSystemMetrics(SM_CYBORDER) * 4;
end;

procedure TCustomComboEdit.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  FButton.Enabled := Enabled;
end;

procedure TCustomComboEdit.CMEnter(var Message: TMessage);
begin
  if AutoSelect and not (csLButtonDown in ControlState) then SelectAll;
  inherited;
end;

procedure TCustomComboEdit.EditButtonClick(Sender: TObject);
begin
  if (not FReadOnly) or AlwaysEnable then begin
    ButtonClick;
    WinProcs.SetFocus(Handle);
  end;
end;

procedure TCustomComboEdit.ButtonClick;
begin
  if Assigned(FOnButtonClick) then FOnButtonClick(Self);
end;

procedure TCustomComboEdit.SelectAll;
begin
  if DirectInput then inherited SelectAll;
end;

function TCustomComboEdit.GetDirectInput: Boolean;
begin
  Result := FDirectInput;
end;

procedure TCustomComboEdit.SetDirectInput(Value: Boolean);
begin
  inherited ReadOnly := not Value or FReadOnly;
  FDirectInput := Value;
end;

procedure TCustomComboEdit.SetReadOnly(Value: Boolean);
begin
  if Value <> FReadOnly then begin
    FReadOnly := Value;
    inherited ReadOnly := Value or not FDirectInput;
  end;
end;

{ TFileDirEdit }

constructor TFileDirEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OEMConvert := True;
  MaxLength := SizeOf(TFileName) + 1;
  FButton.Glyph.Handle := LoadBitmap(hInstance, fResName);
end;

procedure TFileDirEdit.DoBeforeDialog(var FileName: TFileName;
  var Action: Boolean);
begin
  if Assigned(FOnBeforeDialog) then FOnBeforeDialog(Self, FileName, Action);
end;

procedure TFileDirEdit.DoAfterDialog(var FileName: TFileName;
  var Action: Boolean);
begin
  if Assigned(FOnAfterDialog) then FOnAfterDialog(Self, FileName, Action);
end;

{ TFilenameEdit }

function ValidFileName(const AName: TFileName): Boolean;
const
  MaxNameLen = 12; {file name and extension}
  MaxExtLen  =  4; {extension with point}
  MaxPathLen = 79; {full file path in DOS}
var
  Dir, Name, Ext: TFileName;

  function HasAny(Str, SubStr: string): Boolean; near; assembler;
  asm
        PUSH   DS
        CLD
        LDS    SI,Str
        LES    DI,SubStr
        INC    DI
        MOV    DX,DI
        XOR    AH,AH
        LODSB
        MOV    BX,AX
        OR     BX,BX
        JZ     @@2
        MOV    AL,ES:[DI-1]
        XCHG   AX,CX
  @@1:  PUSH   CX
        MOV    DI,DX
        LODSB
        REPNE  SCASB
        POP    CX
        JE     @@3
        DEC    BX
        JNZ    @@1
  @@2:  XOR    AL,AL
        JMP    @@4
  @@3:  MOV    AL,1
  @@4:  POP    DS
  end;

begin
  Result := True;
  Dir := Copy(ExtractFilePath(AName), 1, MaxPathLen);
  Name := Copy(ExtractFileName(AName), 1, MaxNameLen);
  Ext := Copy(ExtractFileExt(AName), 1, MaxExtLen);
  if (Dir + Name <> AName) or (not DirectoryExists(Dir)) or
    HasAny(Name, ';,=+<>|"[] \') or
    HasAny(Copy(Ext, 2, 255), ';,=+<>|"[] \.') then Result := False;
end;

constructor TFilenameEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDialog := TOpenDialog.Create(Self);
  FDialog.Title := GetExtStr(SBrowse);
  FDialog.Filter := GetExtStr(SDefaultFilter);
end;

function TFilenameEdit.IsCustomTitle: Boolean;
begin
  Result := CompareStr(GetExtStr(SBrowse), FDialog.Title) <> 0;
end;

function TFilenameEdit.IsCustomFilter: Boolean;
begin
  Result := CompareStr(GetExtStr(SDefaultFilter), FDialog.Filter) <> 0;
end;

procedure TFilenameEdit.ButtonClick;
var
  Temp: TFileName;
  Action: Boolean;
begin
  Temp := Text;
  Action := True;
  DoBeforeDialog(Temp, Action);
  if not Action then Exit;
  if ValidFileName(Temp) then begin
    FDialog.FileName := Temp;
    if DirectoryExists(ExtractFilePath(Temp)) then
      SetInitialDir(ExtractFilePath(Temp));
  end;
  FDialog.HelpContext := Self.HelpContext;
  Action := FDialog.Execute;
  if Action then Temp := FDialog.FileName;
  DoAfterDialog(Temp, Action);
  if Action then Text := Temp;
end;

function TFilenameEdit.GetDialogFiles: TStrings;
begin
  Result := FDialog.Files;
end;

function TFilenameEdit.GetDefaultExt: TFileExt;
begin
  Result := FDialog.DefaultExt;
end;

function TFilenameEdit.GetFileEditStyle: TFileEditStyle;
begin
  Result := FDialog.FileEditStyle;
end;

function TFilenameEdit.GetFilter: string;
begin
  Result := FDialog.Filter;
end;

function TFilenameEdit.GetFilterIndex: Integer;
begin
  Result := FDialog.FilterIndex;
end;

function TFilenameEdit.GetInitialDir: string;
begin
  Result := FDialog.InitialDir;
end;

function TFilenameEdit.GetHistoryList: TStrings;
begin
  Result := FDialog.HistoryList;
end;

function TFilenameEdit.GetOptions: TOpenOptions;
begin
  Result := FDialog.Options;
end;

function TFilenameEdit.GetDialogTitle: string;
begin
  Result := FDialog.Title;
end;

procedure TFilenameEdit.SetDefaultExt(Value: TFileExt);
begin
  FDialog.DefaultExt := Value;
end;

procedure TFilenameEdit.SetFileEditStyle(Value: TFileEditStyle);
begin
  FDialog.FileEditStyle := Value;
end;

procedure TFilenameEdit.SetFilter(const Value: string);
begin
  FDialog.Filter := Value;
end;

procedure TFilenameEdit.SetFilterIndex(Value: Integer);
begin
  FDialog.FilterIndex := Value;
end;

procedure TFilenameEdit.SetInitialDir(const Value: string);
begin
  FDialog.InitialDir := Value;
end;

procedure TFilenameEdit.SetHistoryList(Value: TStrings);
begin
  FDialog.HistoryList := Value;
end;

procedure TFilenameEdit.SetOptions(Value: TOpenOptions);
begin
  FDialog.Options := Value;
end;

procedure TFilenameEdit.SetDialogTitle(const Value: string);
begin
  FDialog.Title := Value;
end;

{ TDirectoryEdit }

constructor TDirectoryEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOptions := [];
end;

procedure TDirectoryEdit.ButtonClick;
var
  Temp: TFileName;
  Action: Boolean;
begin
  Temp := Text;
  Action := True;
  DoBeforeDialog(Temp, Action);
  if not Action then Exit;
  if not DirectoryExists(Temp) then Temp := '';
  Action := SelectDirectory(Temp, FOptions, Self.HelpContext);
  DoAfterDialog(Temp, Action);
  if Action then Text := Temp;
end;

{ TCustomDateEdit }

constructor TCustomDateEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTitle := NewStr(GetExtStr(SDateDlgTitle));
  FButton.Glyph.Handle := LoadBitmap(hInstance, dResName);
end;

class function TCustomDateEdit.GetDateMask: string;
begin
  if Pos('YYYY', AnsiUpperCase(ShortDateFormat)) > 0 then
    Result := '!99/99/9999;1; '
  else Result := '!99/99/99;1; ';
end;

destructor TCustomDateEdit.Destroy;
begin
  DisposeStr(FTitle);
  inherited Destroy;
end;

function TCustomDateEdit.GetDialogTitle: string;
begin
  Result := FTitle^;
end;

function TCustomDateEdit.GetDate: TDateTime;
begin
  try
    Result := StrToDate(Text);
  except
    if DefaultToday then Result := SysUtils.Date
    else Result := 0;
  end;
end;

procedure TCustomDateEdit.SetDialogTitle(const Value: string);
begin
  AssignStr(FTitle, Value);
end;

procedure TCustomDateEdit.SetDate(Value: TDateTime);
begin
  if Value <> 0 then Text := DateToStr(Value)
  else begin
    if DefaultToday then Text := DateToStr(SysUtils.Date)
    else Text := '';
  end;
end;

function TCustomDateEdit.IsCustomTitle: Boolean;
begin
  Result := (CompareStr(GetExtStr(SDateDlgTitle), DialogTitle) <> 0) and
    (FTitle <> NullStr);
end;

procedure TCustomDateEdit.ButtonClick;
var
  D: TDateTime;
  Action: Boolean;
begin
  inherited ButtonClick;
  D := Self.Date;
  Action := SelectDate(D, DialogTitle);
  if Action then begin
    if Assigned(FOnAfterDialog) then FOnAfterDialog(Self, D, Action);
    if Action then Self.Date := D;
  end;
end;

{ TDateEdit }

constructor TDateEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  EditMask := GetDateMask;
end;

end.