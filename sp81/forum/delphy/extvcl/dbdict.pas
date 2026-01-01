{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
unit DBDict;

interface

uses WinTypes, Classes, StdCtrls, ExtCtrls, DB, Controls, Messages, SysUtils,
  Forms, Graphics, Menus, Buttons, DBGrids, DBTables, Grids;

type

{ TDBDictCombo }

  TPopupDBGrid = class;

  TDBDictComboStyle = (csDropDown, csDropDownList);
  TDBDictListOption = (loColLines, loRowLines, loTitles);
  TDBDictListOptions = set of TDBDictListOption;

  TDBDictCombo = class(TCustomEdit)
  private
    FTimer: TTimer;                            {!!.17.04.95}
    FHintWindow: THintWindow;                  {!!.17.04.95}
    FHintActive: Boolean;                      {!!.17.04.95}
    FCanvas: TControlCanvas;
    FDropDownCount: Integer;
    FDropDownWidth: Integer;
    FTextMargin: Integer;
    FFieldLink: TFieldDataLink;
    FGrid: TPopupDBGrid;
    FButton: TSpeedButton;
    FBtnControl: TWinControl;
    FStyle: TDBDictComboStyle;
    FOnDropDown: TNotifyEvent;
    FOnCloseUp: TNotifyEvent;                  {!!.10.05.95}
    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetLookupSource: TDataSource;
    function GetLookupDisplay: string;
    function GetLookupField: string;
    function GetReadOnly: Boolean;
    function GetValue: string;
    function GetDisplayValue: string;
    function GetMinHeight: Integer;
    function GetOptions: TDBDictListOptions;
    function GetSortedField: string;                  {!!.21.03.95}
    function GetIgnoreCase: Boolean;                  {!!.21.03.95}
    function CanEdit: Boolean;
    function Editable: Boolean;
    procedure SetValue(const NewValue: string);
    procedure SetDisplayValue(const NewValue: string);
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure SetLookupSource(Value: TDataSource);
    procedure SetLookupDisplay(const Value: string);
    procedure SetLookupField(const Value: string);
    procedure SetReadOnly(Value: Boolean);
    procedure SetOptions(Value: TDBDictListOptions);
    procedure SetStyle(Value: TDBDictComboStyle);
    procedure SetSortedField(const Value: string);    {!!.07.03.95}
    procedure SetIgnoreCase(Value: Boolean);          {!!.07.03.95}
    procedure UpdateData(Sender: TObject);
    procedure TimerExpired(Sender: TObject);          {!!.17.04.95}
    procedure FieldLinkActive(Sender: TObject);
    procedure NonEditMouseDown(var Message: TWMLButtonDown);
    procedure DoSelectAll;
    procedure SetEditRect;
    procedure WMPaste (var Message: TMessage); message WM_PASTE;
    procedure WMCut (var Message: TMessage); message WM_CUT;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Change; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure GridClick (Sender: TObject);
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DropDown; dynamic;
    procedure CloseUp; dynamic;
    procedure ResetField;                        {!!.21.04.95}
    function IsDropDown: Boolean;                {!!.10.05.95}
    property Value: string read GetValue write SetValue;
    property DisplayValue: string read GetDisplayValue write SetDisplayValue;
    property BorderStyle;                        {!!.10.05.95}
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property LookupSource: TDataSource read GetLookupSource write SetLookupSource;
    property LookupDisplay: string read GetLookupDisplay write SetLookupDisplay;
    property LookupField: string read GetLookupField write SetLookupField;
    property Options: TDBDictListOptions read GetOptions write SetOptions default [];
    property Style: TDBDictComboStyle read FStyle write SetStyle default csDropDownList;
    property SortedField: string read GetSortedField write SetSortedField; {!!.07.03.95}
    property IgnoreCase: Boolean read GetIgnoreCase write SetIgnoreCase
      default True; {!!.07.03.95}
    property AutoSelect;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property DropDownCount: Integer read FDropDownCount write FDropDownCount default 8;
    property DropDownWidth: Integer read FDropDownWidth write FDropDownWidth default 0;
    property Enabled;
    property Font;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown: TNotifyEvent read FOnDropDown write FOnDropDown;
    property OnCloseUp: TNotifyEvent read FOnCloseUp write FOnCloseUp;
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

{ TDBDictList }

  TDBDictList = class(TCustomDBGrid)
  private
    FSortedField: PString;                 {!!.07.03.95}
    FSearchPos: Integer;                   {!!.07.03.95}
    FIgnoreCase: Boolean;                  {!!.07.03.95}
    FCurString: string;                    {!!.07.03.95}
    FFieldLink: TFieldDataLink;
    FLookupDisplay: PString;
    FLookupField: PString;
    FDisplayFld: TField;
    FValueFld: TField;
    FValue: PString;
    FDisplayValue: PString;
    FHiliteRow: Integer;
    FOptions: TDBDictListOptions;
    FTitleOffset: Integer;
    FFoundValue: Boolean;
    FInCellSelect: Boolean;
    FOnListClick: TNotifyEvent;
    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetLookupSource: TDataSource;
    function GetLookupDisplay: string;
    function GetLookupField: string;
    function GetValue: string;
    function GetDisplayValue: string;
    function GetReadOnly: Boolean;
    function GetSortedField: string;                  {!!.07.03.95}
    procedure FieldLinkActive(Sender: TObject);
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure SetLookupSource(Value: TDataSource);
    procedure SetLookupDisplay(const Value: string);
    procedure SetLookupField(const Value: string);
    procedure SetValue(const Value: string);
    procedure SetDisplayValue(const Value: string);
    procedure SetReadOnly(Value: Boolean);
    procedure SetOptions(Value: TDBDictListOptions);
    procedure SetSortedField(const Value: string);    {!!.07.03.95}
    procedure UpdateData(Sender: TObject);
    procedure NewLayout;
    procedure DoLookup;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
  protected
    function HighlightCell(DataCol, DataRow: Integer; const Value: string;
      AState: TGridDrawState): Boolean; override;
    function CanGridAcceptKey(Key: Word; Shift: TShiftState): Boolean; override;
    procedure DefineFieldMap; override;
    procedure SetColumnAttributes; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    function CanEdit: Boolean; virtual;
    procedure InitFields(ShowError: Boolean);
    procedure CreateWnd; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure LinkActive(Value: Boolean); override;
    procedure Paint; override;
    procedure Scroll(Distance: Integer); override;
    procedure ListClick; dynamic;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Value: string read GetValue write SetValue;
    property DisplayValue: string read GetDisplayValue write SetDisplayValue;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property LookupSource: TDataSource read GetLookupSource write SetLookupSource;
    property LookupDisplay: string read GetLookupDisplay write SetLookupDisplay;
    property LookupField: string read GetLookupField write SetLookupField;
    property Options: TDBDictListOptions read FOptions write SetOptions default [];
    property OnClick: TNotifyEvent read FOnListClick write FOnListClick;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property SortedField: string read GetSortedField write SetSortedField; {!!.07.03.95}
    property IgnoreCase: Boolean read FIgnoreCase write FIgnoreCase default True; {!!.07.03.95}
    property Align;
    property BorderStyle;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
  end;

{ TPopupDBGrid }

  TPopupDBGrid = class(TDBDictList)
  private
    FCombo: TDBDictCombo;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;             {!!.05.05.95}
    function CanEdit: Boolean; override;
    procedure LinkActive(Value: Boolean); override;
  public
    property RowCount;
    constructor Create(AOwner: TComponent); override;
  end;

{ TDictButton }

  TDictButton = class(TSpeedButton)
  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  end;

implementation

uses WinProcs, DBConsts, DBTools;

{ TDBDictCombo }

constructor TDBDictCombo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoSize := False;
  FFieldLink := TFieldDataLink.Create;
  FFieldLink.Control := Self;
  FFieldLink.OnDataChange := DataChange;
  FFieldLink.OnEditingChange := EditingChange;
  FFieldLink.OnUpdateData := UpdateData;
  FFieldLink.OnActiveChange := FieldLinkActive;

  FBtnControl := TWinControl.Create (Self);
  FBtnControl.Width := 17;
  FBtnControl.Height := 17;
  FBtnControl.Visible := True;
  FBtnControl.Parent := Self;

  FButton := TDictButton.Create (Self);
  FButton.SetBounds (0, 0, FBtnControl.Width, FBtnControl.Height);
  FButton.Glyph.Handle := LoadBitmap(0, PChar(32738));
  FButton.Visible := True;
  FButton.Parent := FBtnControl;

  FGrid := TPopupDBGrid.Create(Self);
  FGrid.FCombo := Self;
  FGrid.Parent := Self;
  FGrid.Visible := False;
  FGrid.OnClick := GridClick;

  Height := 25;
  FDropDownCount := 8;
{!!.17.04.95}
  FStyle := csDropDownList;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := 100;
  FTimer.OnTimer := TimerExpired;
  FTimer.Enabled := False;
  FHintWindow := THintWindow.Create(Self);
{!!.17.04.95}
end;

destructor TDBDictCombo.Destroy;
begin
  FTimer.Free;  {!!.17.04.95}
  FFieldLink.OnDataChange := nil;
  FFieldLink.Free;
  FFieldLink := nil;
  inherited Destroy;
end;

procedure TDBDictCombo.ResetField;
{!!.21.04.95}
begin
  if FGrid.Visible then CloseUp;
  Value := '';
  FFieldLink.Reset;
end;

function TDBDictCombo.IsDropDown: Boolean;
{!!.10.05.95}
begin
  Result := FGrid.Visible;
end;

procedure TDBDictCombo.TimerExpired(Sender: TObject);
{!!.17.04.95}
var
  R: TRect;
begin
  if (FGrid.FSearchPos > 0) then begin
    R := ClientRect;
    Dec(R.Right, FButton.Width);
    InflateRect(R, -2, -4);
    Inc(R.Top, Height div 2);
    Inc(R.Bottom, Height div 2);
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
    if not FHintActive then begin
      FHintWindow.ActivateHint(R, '');
      FHintActive := True;
    end;
    FHintWindow.Caption := FGrid.FCurString;
  end
  else begin
    FHintWindow.ReleaseHandle;
    FHintActive := False;
  end;
end;

procedure TDBDictCombo.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FFieldLink <> nil) then
  begin
    if (AComponent = DataSource) then
      DataSource := nil
    else if (AComponent = LookupSource) then
      LookupSource := nil;
  end;
end;

function TDBDictCombo.Editable: Boolean;
{!!.07.03.95}
begin
  Result := (FStyle <> csDropDownList) and ((FFieldLink.DataSource = nil) or
    (FGrid.FValueFld = FGrid.FDisplayFld));
end;

function TDBDictCombo.CanEdit: Boolean;
{!!.07.03.95}
begin
  Result := (FStyle <> csDropDownList) and ((FFieldLink.DataSource = nil) or
    (FFieldLink.Editing and Editable));
end;

procedure TDBDictCombo.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown (Key, Shift);
  if Key in [VK_BACK, VK_DELETE, VK_INSERT] then
  begin
    if Editable then
      FFieldLink.Edit;
    if not CanEdit then
      Key := 0;
  end
  else if not Editable and (Key in [VK_HOME, VK_END, VK_LEFT, VK_RIGHT]) then
    Key := 0;

  if (Key in [VK_UP, VK_DOWN, VK_NEXT, VK_PRIOR] ) then
  begin
    if not FGrid.Visible then
      DropDown
    else
    begin
      FFieldLink.Edit;
      if (FFieldLink.DataSource = nil) or FFieldLink.Editing then
        FGrid.KeyDown(Key, Shift);
    end;
    Key := 0;
  end;
end;

procedure TDBDictCombo.KeyPress(var Key: Char);
{!!.07.03.95}
begin
  inherited KeyPress(Key);
  if (Key in [#32..#255]) and (FFieldLink.Field <> nil) and
      not FFieldLink.Field.IsValidChar(Key) and
      Editable then
  begin
    Key := #0;
    MessageBeep(0)
  end;

  case Key of
    ^H, ^V, ^X, #32..#255:
      begin
        {!!.07.03.95}
        if (SortedField <> '') then begin
          if not Editable then DropDown;
          if FGrid.Visible then FGrid.KeyPress(Key);
          if not Editable then Key := #0;
        end
        {!!.07.03.95}
        else begin
          if Editable then
            FFieldLink.Edit;
          if not CanEdit then
            Key := #0;
        end;
      end;
    Char (VK_RETURN):
      begin
        CloseUp;    {!!.07.03.95}
        Key := #0;  { must catch and remove this, since is actually multi-line }
      end;
    Char (VK_ESCAPE):
      begin
        if not FGrid.Visible then
          ResetField                             {!!.21.04.95}
        else
          CloseUp;
        DoSelectAll;
        Key := #0;
      end;
  end;
end;

procedure TDBDictCombo.Change;
begin
  if FFieldLink.Editing then
    FFieldLink.Modified;
  inherited Change;
end;

function TDBDictCombo.GetDataSource: TDataSource;
begin
  Result := FFieldLink.DataSource;
end;

procedure TDBDictCombo.SetDataSource(Value: TDataSource);
begin
  if (Value <> nil) and (Value = LookupSource) then
    raise EInvalidOperation.Create (LoadStr (SLookupSourceError));
  if (Value <> nil) and (LookupSource <> nil) and (Value.DataSet <> nil) and
    (Value.DataSet = LookupSource.DataSet) then
    raise EInvalidOperation.Create (LoadStr (SLookupSourceError));
  FFieldLink.DataSource := Value;
end;

function TDBDictCombo.GetLookupSource: TDataSource;
begin
  Result := FGrid.LookupSource;
end;

procedure TDBDictCombo.SetLookupSource(Value: TDataSource);
begin
  if (Value <> nil) and ((Value = DataSource) or
    ((Value.DataSet <> nil) and (Value.DataSet = FFieldLink.DataSet))) then
    raise EInvalidOperation.Create (LoadStr (SLookupSourceError));
  FGrid.LookupSource := Value;
  DataChange (Self);
end;

procedure TDBDictCombo.SetLookupDisplay(const Value: string);
begin
  FGrid.LookupDisplay := Value;
  FGrid.InitFields(True);
  SetValue('');   {force a data update}
  DataChange(Self);
end;

function TDBDictCombo.GetLookupDisplay: string;
begin
  Result := FGrid.LookupDisplay;
end;

procedure TDBDictCombo.SetLookupField(const Value: string);
begin
  FGrid.LookupField := Value;
  FGrid.InitFields(True);
  DataChange (Self);
end;

function TDBDictCombo.GetLookupField: string;
begin
  Result := FGrid.LookupField;
end;

function TDBDictCombo.GetDataField: string;
begin
  Result := FFieldLink.FieldName;
end;

procedure TDBDictCombo.SetDataField(const Value: string);
begin
  FFieldLink.FieldName := Value;
end;

procedure TDBDictCombo.DataChange(Sender: TObject);
var
  Str: String;
begin
  if (FFieldLink.Field <> nil) and not (csLoading in ComponentState) then
    Value := FFieldLink.Field.AsString
  else
    Text := EmptyStr;
end;

function TDBDictCombo.GetValue: String;
begin
  if Editable then
    Result := Text
  else
    Result := FGrid.Value;
end;

function TDBDictCombo.GetDisplayValue: String;
begin
  Result := Text;
end;

procedure TDBDictCombo.SetDisplayValue(const NewValue: String);
begin
  if FGrid.DisplayValue <> NewValue then
  begin
    if FGrid.DataLink.Active then
    begin
      FGrid.DisplayValue := NewValue;
      Text := FGrid.DisplayValue;
    end;
  end;
end;

procedure TDBDictCombo.SetValue(const NewValue: String);
begin
  if FGrid.DataLink.Active and FFieldLink.Active and
      ((DataSource = LookupSource) or
      (DataSource.DataSet = LookupSource.DataSet)) then
    raise EInvalidOperation.Create (LoadStr (SLookupSourceError));

  if (FGrid.Value <> NewValue) or (Text <> NewValue) then
  begin
    if FGrid.DataLink.Active then
    begin
      FGrid.Value := NewValue;
      Text := FGrid.DisplayValue;
    end;
  end;
end;

function TDBDictCombo.GetReadOnly: Boolean;
begin
  Result := FFieldLink.ReadOnly;
end;

procedure TDBDictCombo.SetReadOnly(Value: Boolean);
begin
  FFieldLink.ReadOnly := Value;
  inherited ReadOnly := not CanEdit;
end;

procedure TDBDictCombo.EditingChange(Sender: TObject);
begin
  inherited ReadOnly := not CanEdit;
end;

procedure TDBDictCombo.UpdateData(Sender: TObject);
begin
  if FFieldLink.Field <> nil then
  begin
    if Editable then
      FFieldLink.Field.AsString := Text
    else
      FFieldLink.Field.AsString := FGrid.Value;
  end;
end;

procedure TDBDictCombo.FieldLinkActive(Sender: TObject);
begin
  if FFieldLink.Active and FGrid.DataLink.Active then
  begin
    FGrid.SetValue ('');   {force a data update}
    DataChange (Self)
  end;
end;

procedure TDBDictCombo.WMPaste(var Message: TMessage);
begin
  if Editable then
    FFieldLink.Edit;
  if CanEdit then inherited;
end;

procedure TDBDictCombo.WMCut(var Message: TMessage);
begin
  if Editable then
    FFieldLink.Edit;
  if CanEdit then inherited;
end;

procedure TDBDictCombo.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
end;

procedure TDBDictCombo.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
  FGrid.HandleNeeded;
  DataChange (Self);  {update to current value}
end;

procedure TDBDictCombo.SetEditRect;
var
  Loc: TRect;
begin
  Loc.Bottom := ClientHeight + 1;  {+1 is workaround for windows paint bug}
  Loc.Right := FBtnControl.Left - 2;
  Loc.Top := 0;
  Loc.Left := 0;
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@Loc));
end;

procedure TDBDictCombo.WMSize(var Message: TWMSize);
var
  Loc: TRect;
  MinHeight: Integer;
begin
  inherited;
  if (csDesigning in ComponentState) then
    FGrid.SetBounds (0, Height + 1, 10, 10);
  MinHeight := GetMinHeight;
    { text edit bug: if size to less than minheight, then edit ctrl does
      not display the text }
  if Height < MinHeight then Height := MinHeight
  else
  begin
    if not NewStyleControls then
      FBtnControl.SetBounds (Width - FButton.Width, 0, FButton.Width, Height)
    else
      FBtnControl.SetBounds (Width - FButton.Width - 2, 2, FButton.Width, ClientHeight - 4);
    FButton.Height := FBtnControl.Height;
    SetEditRect;
  end;
end;

function TDBDictCombo.GetMinHeight: Integer;
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
  FTextMargin := I div 4;
  {!!.17.04.95}
  if FStyle = csDropDown then
    Result := Metrics.tmHeight + FTextMargin + GetSystemMetrics(SM_CYBORDER) * 4 + 1
  else
    Result := Metrics.tmHeight + FTextMargin + 1;
  {!!.17.04.95}
end;

procedure TDBDictCombo.WMPaint(var Message: TWMPaint);
var
  PS: TPaintStruct;
  ARect: TRect;
  S: array[0..255] of Char;
  TextLeft, TextTop: Integer;
  Focused: Boolean;
  DC: HDC;
const
  Formats: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT,
    DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX);
begin
  if Editable then
  begin
    inherited;
    Exit;
  end;

  { if not editable with focus, need to do drawing to show proper focus }
  if FCanvas = nil then
  begin
    FCanvas := TControlCanvas.Create;
    FCanvas.Control := Self;
  end;

  DC := Message.DC;
  if DC = 0 then DC := BeginPaint(Handle, PS);
  FCanvas.Handle := DC;
  try
    Focused := GetFocus = Handle;
    FCanvas.Font := Font;
    with FCanvas do
    begin
      ARect := ClientRect;
      Brush.Color := clWindowFrame;
      FrameRect(ARect);   { draw the border }
      InflateRect(ARect, -1, -1);
      Brush.Style := bsSolid;
      Brush.Color := Color;
      FillRect(ARect);
      TextTop := FTextMargin;
      ARect.Left := ARect.Left + 2;
      ARect.Right := FBtnControl.Left - 2;
      StrPCopy (S, Text);
      TextLeft := FTextMargin;
      if Focused then
      begin
        Brush.Color := clHighlight;
        Font.Color := clHighlightText;
        ARect.Top := ARect.Top + 2;
        ARect.Bottom := ARect.Bottom - 2;
      end;
      ExtTextOut(FCanvas.Handle, TextLeft,
        TextTop, ETO_OPAQUE or ETO_CLIPPED, @ARect,
        S, StrLen(S), nil);
      if Focused then
        DrawFocusRect(ARect);
    end;
    FButton.Invalidate;        {!!.10.05.95}
  finally
    FCanvas.Handle := 0;
    if Message.DC = 0 then EndPaint(Handle, PS);
  end;
end;

procedure TDBDictCombo.CMFontChanged(var Message: TMessage);
begin
  inherited;
  GetMinHeight;  { set FTextMargin }
end;

procedure TDBDictCombo.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  FButton.Enabled := Enabled;
end;

procedure TDBDictCombo.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  CloseUp;
end;

procedure TDBDictCombo.CMCancelMode(var Message: TCMCancelMode);
begin
  with Message do
    if (Sender <> Self) and (Sender <> FBtnControl) and
      (Sender <> FButton) and (Sender <> FGrid) then CloseUp;
end;

procedure TDBDictCombo.DropDown;
{!!.07.03.95}
var
  ItemCount: Integer;
  P: TPoint;
  Y:  Integer;
  GridWidth, GridHeight, BorderWidth: Integer;
begin
  if not FGrid.Visible and (Width > 20) then
  begin
    FTimer.Enabled := True;  {!!.17.04.95}
    FGrid.FSearchPos := 0;   {!!.07.03.95}
    if Assigned(FOnDropDown) then FOnDropDown(Self);
    ItemCount := DropDownCount;
    if DropDownCount = 0 then ItemCount := 1;
    P := ClientOrigin;
    BorderWidth := 0;
    if loRowLines in Options then BorderWidth := 1;
    GridHeight := (FGrid.DefaultRowHeight + BorderWidth) *
      (ItemCount + FGrid.FTitleOffset) + 2;
    FGrid.Height := GridHeight;
    if ItemCount > FGrid.RowCount then
    begin
      ItemCount := FGrid.RowCount;
      GridHeight := (FGrid.DefaultRowHeight + BorderWidth) *
        (ItemCount + FGrid.FTitleOffset) + 4;
    end;
    Y := P.Y + Height - 1;
    if (Y + GridHeight) > Screen.height then Y := P.Y - GridHeight + 1;
    if Y < 0 then Y := P.Y + Height - 1;
    GridWidth := DropDownWidth;
    if GridWidth = 0 then GridWidth := Width - 4;
    SetWindowPos (FGrid.Handle, 0, P.X + Width - GridWidth, Y,
      GridWidth, GridHeight, SWP_NOACTIVATE);
    if Length (LookupField) = 0 then
      FGrid.DisplayValue := Text;
    FGrid.Visible := True;
    WinProcs.SetFocus(Handle);
  end;
end;

procedure TDBDictCombo.CloseUp;
{!!.07.03.95}
begin
  if FGrid.Visible then begin
    FGrid.Visible := False;
{!!.17.04.95}
    FTimer.Enabled := False;
    FHintWindow.ReleaseHandle;
    FHintActive := False;
{!!.17.04.95}
    if Assigned(FOnCloseUp) then FOnCloseUp(Self);  {!!.10.05.95}
  end;
  FGrid.FSearchPos := 0;   {!!.07.03.95}
end;

procedure TDBDictCombo.GridClick (Sender: TObject);
begin
  FFieldLink.Edit;
  if (FFieldLink.DataSource = nil) or FFieldLink.Editing then
  begin
    FFieldLink.Modified;
    Text := FGrid.DisplayValue;
  end;
end;

procedure TDBDictCombo.SetStyle(Value: TDBDictComboStyle);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
  end;
end;

procedure TDBDictCombo.WMLButtonDown(var Message: TWMLButtonDown);
begin
  if Editable then inherited
  else NonEditMouseDown(Message);
end;

procedure TDBDictCombo.WMLButtonUp(var Message: TWMLButtonUp);
begin
  if not Editable then MouseCapture := False;
  inherited;
end;

procedure TDBDictCombo.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  if Editable then inherited
  else NonEditMouseDown(Message);
end;

procedure TDBDictCombo.NonEditMouseDown(var Message: TWMLButtonDown);
var
  CtrlState: TControlState;
begin
  SetFocus;
  HideCaret(Handle);
{  SelectAll;  }
  if FGrid.Visible then CloseUp
  else DropDown;
  MouseCapture := True;
  if csClickEvents in ControlStyle then
  begin
    CtrlState := ControlState;
    Include(CtrlState, csClicked);
    ControlState := CtrlState;
  end;
  with Message do
    MouseDown(mbLeft, KeysToShiftState(Keys), XPos, YPos);
end;

procedure MouseDragToGrid(Ctrl: TControl; Grid: TPopupDBGrid; X, Y: Integer);
var
  pt, clientPt: TPoint;
begin
  if (Grid.Visible) then
  begin
    pt.X := X;
    pt.Y := Y;
    pt := Ctrl.ClientToScreen (pt);
    clientPt := Grid.ClientOrigin;
    if (pt.X >= clientPt.X) and (pt.Y >= clientPt.Y) and
       (pt.X <= clientPt.X + Grid.ClientWidth) and
       (pt.Y <= clientPt.Y + Grid.ClientHeight) then
    begin
      Ctrl.Perform(WM_LBUTTONUP, 0, MakeLong (X, Y));
      pt := Grid.ScreenToClient(pt);
      Grid.Perform(WM_LBUTTONDOWN, 0, MakeLong (pt.x, pt.y));
    end;
  end;
end;

procedure TDBDictCombo.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove (Shift, X, Y);
  if (ssLeft in Shift) and not Editable and (GetCapture = Handle) then
    MouseDragToGrid (Self, FGrid, X, Y);
end;

procedure TDBDictCombo.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not Editable then HideCaret (Handle);
end;

procedure TDBDictCombo.CMExit(var Message: TCMExit);
begin
  try
    FFieldLink.UpdateRecord;
  except
    DoSelectAll;
    SetFocus;
    raise;
  end;
  inherited;
  if not Editable then Invalidate;
end;

procedure TDBDictCombo.CMEnter(var Message: TCMGotFocus);
begin
  if AutoSelect and not (csLButtonDown in ControlState) then DoSelectAll;
  inherited;
  if not Editable then Invalidate;
end;

procedure TDBDictCombo.DoSelectAll;
begin
  if Editable then SelectAll;
end;

procedure TDBDictCombo.SetOptions(Value: TDBDictListOptions);
begin
  FGrid.Options := Value;
end;

function TDBDictCombo.GetOptions: TDBDictListOptions;
begin
  Result := FGrid.Options;
end;

procedure TDBDictCombo.SetIgnoreCase(Value: Boolean);
{!!.07.03.95}
begin
  FGrid.IgnoreCase := Value;
end;

function TDBDictCombo.GetIgnoreCase: Boolean;
{!!.07.03.95}
begin
  Result := FGrid.IgnoreCase;
end;

procedure TDBDictCombo.SetSortedField(const Value: string);
{!!.07.03.95}
begin
  FGrid.SortedField := Value;
end;

function TDBDictCombo.GetSortedField: string;
{!!.07.03.95}
begin
  Result := FGrid.SortedField;
end;

procedure TDBDictCombo.Loaded;
begin
  inherited Loaded;
  DataChange(Self);
end;

{ TLookupList }

constructor TDBDictList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFieldLink := TFieldDataLink.Create;
  FFieldLink.Control := Self;
  FFieldLink.OnDataChange := DataChange;
  FFieldLink.OnEditingChange := EditingChange;
  FFieldLink.OnUpdateData := UpdateData;
  FFieldLink.OnActiveChange := FieldLinkActive;
  FTitleOffset := 0;
  FUpdateFields := False;
  FValue := NullStr;
  FDisplayValue := NullStr;
  FLookupDisplay := NullStr;
  FLookupField := NullStr;
  FSortedField := NullStr;   {!!.07.03.95}
  FSearchPos := 0;           {!!.07.03.95}
  FIgnoreCase := True;       {!!.07.03.95}
  FHiliteRow := -1;
  inherited Options := [dgRowSelect];
  FixedCols := 0;
  FixedRows := 0;
  Width := 121;
  Height := 97;
end;

destructor TDBDictList.Destroy;
begin
  FFieldLink.OnDataChange := nil;
  FFieldLink.Free;
  FFieldLink := nil;
  DisposeStr(FValue);
  DisposeStr(FDisplayValue);
  DisposeStr(FLookupDisplay);
  DisposeStr(FLookupField);
  DisposeStr(FSortedField);   {!!.07.03.95}
  inherited Destroy;
end;

procedure TDBDictList.CreateWnd;
begin
  inherited CreateWnd;
  DataChange(Self);  {update to current value}
end;

procedure TDBDictList.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FFieldLink <> nil) and
     (AComponent = DataSource) then
    DataSource := nil;
end;

function TDBDictList.GetDataSource: TDataSource;
begin
  Result := FFieldLink.DataSource;
end;

procedure TDBDictList.SetDataSource(Value: TDataSource);
begin
  if (Value <> nil) and ((Value = LookupSource) or ((Value.DataSet <> nil)
    and (Value.DataSet = DataLink.DataSet))) then
    raise EInvalidOperation.Create (LoadStr (SLookupSourceError));
  FFieldLink.DataSource := Value;
end;

function TDBDictList.GetLookupSource: TDataSource;
begin
  Result := inherited DataSource;
end;

procedure TDBDictList.NewLayout;
begin
  InitFields(True);
  LayoutChanged;
  AssignStr (FValue, '');
  DataChange (Self);
end;

procedure TDBDictList.SetLookupSource(Value: TDataSource);
begin
  if (Value <> nil) and ((Value = DataSource) or
    ((Value.DataSet <> nil) and (Value.DataSet = FFieldLink.DataSet))) then
    raise EInvalidOperation.Create (LoadStr (SLookupSourceError));
  if (Value <> nil) and (Value.DataSet <> nil) and
{!!.07.03.95}
      not (Value.DataSet.InheritsFrom(TDBDataSet)) then
{!!.07.03.95}
    raise EInvalidOperation.Create(LoadStr(SLookupTableError));
  inherited DataSource := Value;
  NewLayout;
end;

procedure TDBDictList.SetLookupDisplay(const Value: string);
begin
  if Value <> LookupDisplay then
  begin
    AssignStr (FLookupDisplay, Value);
    NewLayout;
  end;
end;

procedure TDBDictList.SetLookupField(const Value: string);
begin
  if Value <> LookupField then
  begin
    AssignStr (FLookupField, Value);
    NewLayout;
  end;
end;

procedure TDBDictList.SetValue(const Value: string);
var
  DataSet: TDataSet;
begin
  if DataLink.Active and FFieldLink.Active and
      ((DataSource = LookupSource) or
      (DataSource.DataSet = LookupSource.DataSet)) then
    raise EInvalidOperation.Create (LoadStr (SLookupSourceError));

  if (FValue^ <> Value) or (Row = FTitleOffset) then
  begin
    if DataLink.Active and (FValueFld <> nil) then
    begin
      AssignStr(FValue, Value);
      FHiliteRow := -1;     { to be reset in .HighlightCell }
      DoLookup;
      if FFoundValue and (FValueFld <> FDisplayFld) then
        AssignStr(FDisplayValue, FDisplayFld.AsString)
      else if FFoundValue and (FValueFld = FDisplayFld) then
        AssignStr(FDisplayValue, FValue^)
      else
        AssignStr(FDisplayValue, '');
    end;
  end;
end;

function TDBDictList.GetSortedField: string;
{!!.07.03.95}
begin
  Result := FSortedField^;
end;

procedure TDBDictList.SetSortedField(const Value: string);
{!!.07.03.95}
begin
  if Value <> SortedField then
  begin
    AssignStr(FSortedField, Value);
    NewLayout;
  end;
end;

procedure TDBDictList.SetDisplayValue(const Value: string);
{!!.07.03.95}
var
  DataSet: TDataSet;
begin
  if (FDisplayValue^ <> Value) or (Row = FTitleOffset) then
  begin
    FFoundValue := False;
    if DataLink.Active and (FDisplayFld <> nil) then
    begin
      FHiliteRow := -1;     { to be reset in .HighlightCell }
      FFoundValue := False;
      if (inherited DataSource.DataSet is TTable)
        and (FDisplayFld.IsIndexField)  {!!.07.03.95}
      then
        with TTable(inherited DataSource.DataSet) do
        begin
          SetKey;
          FDisplayFld.AsString := Value;
          FFoundValue := GotoKey;
        end;
      {!!.07.03.95}
      if not FFoundValue then
        FFoundValue := DataSetGotoValue(inherited DataSource.DataSet, Value,
          FDisplayFld.FieldName);
      {!!.07.03.95}
      AssignStr (FDisplayValue, Value);
      if (FValueFld = FDisplayFld) then
        AssignStr (FValue, FDisplayValue^)
      else if not FFoundValue then
      begin
        AssignStr (FDisplayValue, '');
        AssignStr (FValue, '');
      end
      else { if (FValueFld <> FDisplayFld) then }
        AssignStr (FValue, FValueFld.AsString);
    end;
  end;
end;

procedure TDBDictList.DoLookup;
{!!.07.03.95}
begin
  FFoundValue := False;
  if not HandleAllocated then Exit;
  if Value = '' then Exit;
  if inherited DataSource.DataSet is TTable then
  begin
    with TTable(inherited DataSource.DataSet) do
    begin
      {!!.07.03.95} { remark }
      {
      if (IndexFieldCount > 0) then
      begin
        if AnsiCompareText(IndexFields[0].FieldName, LookupField) <> 0 then
          raise EInvalidOperation.Create
            (FmtLoadStr(SLookupIndexError, [LookupField]));
      end;
      }
      if (IndexFieldCount = 0) or (FValueFld.IsIndexField) then begin  {!!.07.03.95}
        if State = dsSetKey then Exit;
        SetKey;
        FValueFld.AsString := Value;
        FFoundValue := GotoKey;
      end;
    end;
  end;
  {!!.07.03.95}
  if not FFoundValue then
    FFoundValue := DataSetGotoValue(inherited DataSource.DataSet, Value,
      FValueFld.FieldName);
  {!!.07.03.95}
  if not FFoundValue then inherited DataSource.DataSet.First; {!!.07.03.95}
end;

function TDBDictList.GetLookupDisplay: string;
begin
  Result := FLookupDisplay^;
end;

function TDBDictList.GetLookupField: string;
begin
  Result := FLookupField^;
end;

function TDBDictList.GetValue: string;
begin
  Result := FValue^;
end;

function TDBDictList.GetDisplayValue: string;
begin
  Result := FDisplayValue^;
end;

function TDBDictList.GetDataField: string;
begin
  Result := FFieldLink.FieldName;
end;

procedure TDBDictList.SetDataField(const Value: string);
begin
  FFieldLink.FieldName := Value;
end;

function TDBDictList.GetReadOnly: Boolean;
begin
  Result := FFieldLink.ReadOnly;
end;

function TDBDictList.CanEdit: Boolean;
begin
  Result := (FFieldLink.DataSource = nil) or FFieldLink.Editing;
end;

procedure TDBDictList.SetReadOnly(Value: Boolean);
begin
  FFieldLink.ReadOnly := Value;
end;

procedure TDBDictList.DataChange(Sender: TObject);
begin
  if (FFieldLink.Field <> nil) and not (csLoading in ComponentState) then
    Value := FFieldLink.Field.AsString
  else
    Value := EmptyStr;
end;

procedure TDBDictList.EditingChange(Sender: TObject);
begin
end;

procedure TDBDictList.UpdateData(Sender: TObject);
begin
  if FFieldLink.Field <> nil then
    FFieldLink.Field.AsString := Value;
end;

procedure TDBDictList.InitFields(ShowError: Boolean);
var
  Pos: Integer;
begin
  FDisplayFld := nil;
  FValueFld := nil;
  if not DataLink.Active or (Length(LookupField) = 0) then Exit;
  with Datalink.DataSet do
  begin
    FValueFld := FindField(LookupField);
    if (FValueFld = nil) and ShowError then
      raise EInvalidOperation.Create(FmtLoadStr(SFieldNotFound, [LookupField]))
    else if FValueFld <> nil then
    begin
      if Length (LookupDisplay) > 0 then
      begin
        Pos := 1;
        FDisplayFld := FindField(ExtractFieldName(LookupDisplay, Pos));
        if (FDisplayFld = nil) and ShowError then
        begin
          Pos := 1;
          raise EInvalidOperation.Create(FmtLoadStr(SFieldNotFound,
            [ExtractFieldName(LookupDisplay, Pos)]));
        end;
      end;
      if FDisplayFld = nil then FDisplayFld := FValueFld;
    end;
  end;
end;

procedure TDBDictList.DefineFieldMap;
{!!.07.03.95}
var
  Pos: Integer;
  Fld: TField;
begin
  InitFields(False);
  if FValueFld <> nil then
  begin
    if Length (LookupDisplay) = 0 then
      Datalink.AddMapping (FValueFld.FieldName)
    else
    begin
      Pos := 1;
      while Pos <= Length(LookupDisplay) do
        Datalink.AddMapping (ExtractFieldName(LookupDisplay, Pos));
    end;
  end;
  {!!.07.03.95}
  { Check SortedField }
  if SortedField <> '' then begin
    Fld := Datalink.DataSet.FindField(SortedField);
    if (Fld = nil) or (Fld.DataType <> ftString) then
      AssignStr(FSortedField, '');
  end;
  {!!.07.03.95}
end;

procedure TDBDictList.SetColumnAttributes;
var
  I: Integer;
  TotalWidth, BorderWidth: Integer;
begin
  inherited SetColumnAttributes;
  if FieldCount > 0 then
  begin
    BorderWidth := 0;
    if loColLines in FOptions then BorderWidth := 1;
    TotalWidth := 0;
    for I := 0 to ColCount -2 do
      TotalWidth := TotalWidth + ColWidths[I] + BorderWidth;
    if (ColCount = 1) or (TotalWidth < (ClientWidth - 15)) then
      ColWidths[ColCount-1] := ClientWidth - TotalWidth;
  end;
end;

procedure TDBDictList.WMSize(var Message: TWMSize);
begin
  inherited;
  SetColumnAttributes;
end;

function TDBDictList.CanGridAcceptKey(Key: Word; Shift: TShiftState): Boolean;
var
  MyOnKeyDown: TKeyEvent;
begin
  Result := True;
  if Key = VK_INSERT then Result := False
  else if Key in [VK_UP, VK_DOWN, VK_NEXT, VK_RIGHT, VK_LEFT, VK_PRIOR,
    VK_HOME, VK_END] then
  begin
    FFieldLink.Edit;
    if (Key in [VK_UP, VK_DOWN, VK_RIGHT, VK_LEFT]) and not CanEdit then
      Result := False
    else if (inherited DataSource <> nil) and
        (inherited DataSource.State <> dsInactive) then
    begin
      if (FHiliteRow >= 0) and (FHiliteRow <> DataLink.ActiveRecord) then
      begin
        Row := FHiliteRow;
        Datalink.ActiveRecord := FHiliteRow;
      end
      else if (FHiliteRow < 0) then
      begin
        if FFoundValue then
          DoLookup
        else
        begin
          DataLink.DataSource.DataSet.First;
          Row := FTitleOffset;
          Key := 0;
          MyOnKeyDown := OnKeyDown;
          if Assigned(MyOnKeyDown) then MyOnKeyDown(Self, Key, Shift);
          InvalidateRow (FTitleOffset);
          ListClick;
          Result := False;
        end;
      end;
    end;
  end;
end;

procedure TDBDictList.KeyDown(var Key: Word; Shift: TShiftState);
{!!.07.03.95}
var
  OldRow: Longint;  {!!.07.03.95}
begin
  OldRow := Row;                  {!!.07.03.95}
  try
    FInCellSelect := True;
    inherited KeyDown(Key, Shift);
  finally
    FInCellSelect := False;
  end;
  if (Key in [VK_UP, VK_DOWN, VK_NEXT, VK_PRIOR, VK_HOME, VK_END]) and
      CanEdit then
    ListClick;
  if OldRow <> Row then FSearchPos := 0;  {!!.07.03.95}
end;

procedure TDBDictList.KeyPress(var Key: Char);
{!!.07.03.95}
var
  Field: TField;  {!!.07.03.95}
  OldPos: Integer;
begin
  inherited KeyPress (Key);
  {!!.07.03.95}
  if (SortedField <> '') and (Byte(Key) in [VK_BACK, 32..255]) then begin
    try
      Field := inherited DataSource.DataSet.FieldByName(SortedField);
      FCurString := Field.AsString;
      OldPos := FSearchPos;
      if (Key = Char(VK_BACK)) then begin
        if FSearchPos <> 0 then Dec(FSearchPos);
      end
      else begin
        Inc(FSearchPos);
        FCurString[FSearchPos] := Key;
      end;
      FCurString[0] := Char(FSearchPos);
      if not DataSetSortedSearch(inherited DataSource.DataSet, FCurString,
        SortedField, False, FIgnoreCase) then
      begin
        FSearchPos := OldPos;
        FCurString[0] := Char(FSearchPos);
        MessageBeep(0);
        Exit;
      end
      else begin
        { Set to found value }
        ListClick;
        if (Row >= FTitleOffset) then
          Datalink.ActiveRecord := Row - FTitleOffset;
        Exit;
      end;
    except
      raise;
    end;
  end;
  {!!.07.03.95}
  case Key of
    #32..#255:
      DataLink.Edit;
    Char (VK_ESCAPE):
      begin
        FFieldLink.Reset;
        Value := '';
        Key := #0;
      end;
  end;
end;

procedure TDBDictList.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
{!!.07.03.95}
var
  OldRow: Longint;   {!!.07.03.95}
  CellHit: TGridCoord;
  MyOnMouseDown: TMouseEvent;
begin
  OldRow := Row;                  {!!.07.03.95}
  if not (csDesigning in ComponentState) and CanFocus and TabStop then
  begin
    SetFocus;
    if ValidParentForm(Self).ActiveControl <> Self then
    begin
      MouseCapture := False;
      Exit;
    end;
  end;
  if ssDouble in Shift then
  begin
    DblClick;
    Exit;
  end;
  if (Button = mbLeft) and (DataLink.DataSource <> nil) and
    (FDisplayFld <> nil)  then
  begin
    CellHit := MouseCoord (X, Y);
    if (CellHit.Y >= FTitleOffset) then
    begin
      FFieldLink.Edit;
      FGridState := gsSelecting;
      SetTimer(Handle, 1, 60, nil);
      if (CellHit.Y <> (FHiliteRow + FTitleOffset)) then
      begin
        InvalidateRow (FHiliteRow + FTitleOffset);
        InvalidateRow (CellHit.Y);
      end;
      Row := CellHit.Y;
      Datalink.ActiveRecord := Row - FTitleOffset;
    end;
  end;
  MyOnMouseDown := OnMouseDown;
  if Assigned(MyOnMouseDown) then MyOnMouseDown(Self, Button, Shift, X, Y);
  if OldRow <> Row then FSearchPos := 0;  {!!.07.03.95}
end;

procedure TDBDictList.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove (Shift, X, Y);
  if FGridState = gsSelecting then
    if (Row >= FTitleOffset) then
      Datalink.ActiveRecord := Row - FTitleOffset;
end;

procedure TDBDictList.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
{!!.07.03.95}
var
  OldState: TGridState;
  OldRow: Longint;   {!!.07.03.95}
begin
  OldState := FGridState;
  OldRow := Row;                  {!!.07.03.95}
  inherited MouseUp(Button, Shift, X, Y);
  if OldState = gsSelecting then
  begin
    if (Row >= FTitleOffset) then
      Datalink.ActiveRecord := Row - FTitleOffset;
    ListClick;
  end;
  if OldRow <> Row then FSearchPos := 0;  {!!.07.03.95}
end;

procedure TDBDictList.ListClick;
begin
  if CanEdit and (FDisplayFld <> nil) then
  begin
    if FFieldLink.Editing then
      FFieldLink.Modified;
    AssignStr (FDisplayValue, FDisplayFld.AsString);
    if (FValueFld <> FDisplayFld) then
      AssignStr (FValue, FValueFld.AsString)
    else
      AssignStr (FValue, FDisplayValue^);
  end;
  if Assigned (FOnListClick) then FOnListClick(Self);
end;

function TDBDictList.HighlightCell(DataCol, DataRow: Integer; const Value: string;
      AState: TGridDrawState): Boolean;
var
  OldActive: Integer;
begin
  Result := False;
  if not DataLink.Active or (FValueFld = nil) then Exit;
  if (CanEdit) and ((FGridState = gsSelecting) or FInCellSelect) then
  begin
    if Row = (DataRow + FTitleOffset) then
    begin
      Result := True;
      FHiliteRow := DataRow;
    end;
  end
  else
  begin
    OldActive := DataLink.ActiveRecord;
    try
      DataLink.ActiveRecord := DataRow;
      if GetValue = FValueFld.AsString then
      begin
        Result := True;
        FHiliteRow := DataRow;
      end;
    finally
      DataLink.ActiveRecord := OldActive;
    end;
  end;
end;

procedure TDBDictList.Paint;
begin
  FHiliteRow := -1;
  inherited Paint;
  {!!.05.05.95}
  { Skip DrawFocusRect function }
end;

procedure TDBDictList.Scroll(Distance: Integer);
begin
  if FHiliteRow >= 0 then
  begin
    FHiliteRow := FHiliteRow - Distance;
    if FHiliteRow >= VisibleRowCount then
      FHiliteRow := -1;
  end;
  inherited Scroll(Distance);
end;

procedure TDBDictList.LinkActive(Value: Boolean);
begin
  inherited LinkActive (Value);
  if DataLink.Active then
  begin
{!!.07.03.95}
    if not (LookupSource.DataSet.InheritsFrom(TDBDataSet)) then
{!!.07.03.95}
      raise EInvalidOperation.Create(LoadStr(SLookupTableError));
    SetValue('');   {force a data update}
    DataChange(Self);
  end;
end;

procedure TDBDictList.FieldLinkActive(Sender: TObject);
begin
  if FFieldLink.Active and DataLink.Active then
    DataChange(Self);
end;

procedure TDBDictList.CMEnter(var Message: TCMEnter);
begin
  inherited;
  if FHiliteRow <> -1 then InvalidateRow(FHiliteRow);
end;

procedure TDBDictList.CMExit(var Message: TCMExit);
begin
  try
    FFieldLink.UpdateRecord;
  except
    SetFocus;
    raise;
  end;
  inherited;
  if FHiliteRow <> -1 then InvalidateRow(FHiliteRow);
end;

procedure TDBDictList.SetOptions(Value: TDBDictListOptions);
var
  NewGridOptions: TDBGridOptions;
begin
  if FOptions <> Value then
  begin
    FOptions := Value;
    FTitleOffset := 0;
    NewGridOptions := [dgRowSelect];  {!!.05.05.95}
    if loColLines in Value then
      NewGridOptions := NewGridOptions + [dgColLines];
    if loRowLines in Value then
      NewGridOptions := NewGridOptions + [dgRowLines];
    if loTitles in Value then
    begin
      FTitleOffset := 1;
      NewGridOptions := NewGridOptions + [dgTitles];
    end;
    inherited Options := NewGridOptions;
  end;
end;

procedure TDBDictList.Loaded;
begin
  inherited Loaded;
  DataChange(Self);
end;

{ TPopupDBGrid }

constructor TPopupDBGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAcquireFocus := False;
  TabStop := False;
end;

procedure TPopupDBGrid.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WindowClass.Style := CS_SAVEBITS;
end;

procedure TPopupDBGrid.CreateWnd;
var
  Rect: TRect;
begin
  inherited CreateWnd;
  if not (csDesigning in ComponentState) then
    WinProcs.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);
  FCombo.DataChange (Self);  {update to current value}
end;

procedure TPopupDBGrid.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  with Message do
    FCombo.CloseUp;
end;

function TPopupDBGrid.CanEdit: Boolean;
begin
  Result := (FCombo.FFieldLink.DataSource = nil) or FCombo.FFieldLink.Editing;
end;

procedure TPopupDBGrid.Paint;
{!!.05.05.95}
begin
  inherited Paint;
  if Focused and (FHiliteRow <> -1) then
    Canvas.DrawFocusRect(BoxRect(0, FHiliteRow, MaxInt, FHiliteRow));
end;

procedure TPopupDBGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  FCombo.FFieldLink.Edit;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TPopupDBGrid.LinkActive(Value: Boolean);
begin
  if Parent = nil then Exit;   {grid being destroyed}
  inherited LinkActive (Value);
  if DataLink.Active then
  begin
    if FValueFld = nil then InitFields(True);
    SetValue('');   {force a data update}
    FCombo.DataChange (Self);
  end;
end;

{ TDictButton }

procedure TDictButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  with TDBDictCombo (Parent.Parent) do
  begin
    if not FGrid.Visible then
    begin
      if (Handle <> GetFocus) and CanFocus then
      begin
        SetFocus;
        if GetFocus <> Handle then Exit;
      end;
    end;
  end;
  inherited MouseDown (Button, Shift, X, Y);
  with TDBDictCombo (Parent.Parent) do
  begin
    if FGrid.Visible then
      CloseUp
    else
    begin
      DropDown;
    end;
  end;
end;

procedure TDictButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove (Shift, X, Y);
  if (ssLeft in Shift) and (GetCapture = Parent.Handle) then
    MouseDragToGrid (Self, TDBDictCombo(Parent.Parent).FGrid, X, Y);
end;

end.