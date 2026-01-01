{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
unit DBExtCtl;

interface

uses WinTypes, Messages, Classes, Controls, Forms, Grids, Graphics, Menus,
  StdCtrls, Mask, ServEdit, DB, DBGrids, DBTables;

type

{ TDBGlyphGrid }

  TGetFontPropsEvent = procedure (Sender: TObject; var FontColor: TColor;
    var FontStyle: TFontStyles; Field: TField) of object;

  TDBGlyphGrid = class(TCustomDBGrid)
  private
    FImage: TBitmap;
    FShowGlyphs: Boolean;
    FOnGetFontProps: TGetFontPropsEvent;
    FOnMouseDown: TMouseEvent;
    FDrawing: Boolean;
    FRowsHeight: Integer;
    function GetFieldImageIndex(Field: TField): Byte;
    function CreateFieldImage(Field: TField): TBitmap;
    procedure SetShowGlyphs(Value: Boolean);
    procedure SetRowsHeight(Value: Integer);
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
  protected
    function CanEditModify: Boolean; override;
    procedure GetFontProps(var FontColor: TColor; var FontStyle: TFontStyles;
      Field: TField); dynamic;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); override;
    procedure DrawDataCell(const Rect: TRect; Field: TField;
      State: TGridDrawState); override;
    procedure LayoutChanged; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure MouseToCell(X, Y: Integer; var ACol, ARow: Longint);
    property Canvas;
    property Col;
    property Row;
  published
    property Align;
    property BorderStyle;
    property Color;
    property Ctl3D;
    property DataSource;
    property DragCursor;
    property DragMode;
    property Enabled;
    property FixedColor;
    property Font;
    property Options;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property RowsHeight: Integer read FRowsHeight write SetRowsHeight default 0;
    property ShowGlyphs: Boolean read FShowGlyphs write SetShowGlyphs
      default True;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property TitleFont;
    property Visible;
    property OnColEnter;
    property OnColExit;
    property OnDrawDataCell;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetFontProps: TGetFontPropsEvent read FOnGetFontProps
      write FOnGetFontProps;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

{ TDBDateEdit }

  TDBDateEdit = class(TCustomDateEdit)
  private
    FDataLink: TFieldDataLink;
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetField: TField;
    function GetReadOnly: Boolean;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure SetReadOnly(Value: Boolean);
    procedure UpdateData(Sender: TObject);
    procedure AfterDialog(Sender: TObject; var Date: TDateTime; var Action: Boolean);
    procedure WMCut(var Message: TMessage); message WM_CUT;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
  protected
    procedure Change; override;
    function EditCanModify: Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Reset; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Field: TField read GetField;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
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
    property ShowHint;
    property TabOrder;
    property TabStop;
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

implementation

Uses WinProcs, DbiTypes, SysUtils;

{$R *.RES}

{ TDBGlyphGrid }

const
  sDbgImage = 'DBGRIDIMAGE';
  { Blob, Bytes -> # 1
    Text        -> # 2
    Graphic     -> # 3
    OLE         -> # 4 }

  DbgImageCount = 4;
  DbgImageList: array[TFieldType] of Byte =
    (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 3);

constructor TDBGlyphGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FImage := TBitmap.Create;
  FShowGlyphs := True;
  FImage.Handle := LoadBitmap(hInstance, sDbgImage);
  FRowsHeight := 0;
end;

destructor TDBGlyphGrid.Destroy;
begin
  FImage.Free;
  inherited Destroy;
end;

function TDBGlyphGrid.GetFieldImageIndex(Field: TField): Byte;
begin
  Result := 0;
  if FImage = nil then Exit;
  if not FShowGlyphs then Exit;
  if Field <> nil then Result := DbgImageList[Field.DataType];
end;

function TDBGlyphGrid.CreateFieldImage(Field: TField): TBitmap;
{ Create temporary bitmap for drawing cell, this bitmap must be
  destroyed in another (caller) method }
var
  BmpIndex: Byte;
  IRect, ORect: TRect;
  IWidth, IHeight: Integer;
  FTmpImage: TBitmap;
begin
  Result := nil;
  BmpIndex := GetFieldImageIndex(Field);
  if BmpIndex > 0 then begin
    IWidth := FImage.Width div DbgImageCount;
    IHeight := FImage.Height;
    IRect := Rect(0, 0, IWidth, IHeight);
    FTmpImage := TBitmap.Create;
    try
      FTmpImage.Width := IWidth;
      FTmpImage.Height := IHeight;
      FTmpImage.Canvas.Brush.Color := Self.Canvas.Brush.Color;
      ORect := Rect((BmpIndex - 1) * IWidth, 0, BmpIndex * IWidth, IHeight);
      FTmpImage.Canvas.BrushCopy(IRect, FImage, ORect, clOlive);
      Result := FTmpImage;
    except
      FTmpImage.Free;
      raise;
    end;
  end;
end;

procedure TDBGlyphGrid.SetShowGlyphs(Value: Boolean);
begin
  if FShowGlyphs <> Value then begin
    FShowGlyphs := Value;
    Invalidate;
  end;
end;

function TDBGlyphGrid.CanEditModify: Boolean;
begin
  Result := (GetFieldImageIndex(Fields[SelectedIndex]) = 0);
  if Result then Result := inherited CanEditModify;
end;

procedure TDBGlyphGrid.GetFontProps(var FontColor: TColor;
  var FontStyle: TFontStyles; Field: TField);
begin
  if Assigned(FOnGetFontProps) then FOnGetFontProps(Self, FontColor, FontStyle, Field);
end;

procedure TDBGlyphGrid.SetRowsHeight(Value: Integer);
begin
  if Value <> FRowsHeight then begin
    FRowsHeight := Value;
    LayoutChanged;
  end;
end;

procedure TDBGlyphGrid.LayoutChanged;
var
  TitleHeight: Integer;
begin
  if not HandleAllocated then Exit;
  if csLoading in ComponentState then Exit;
  inherited LayoutChanged;
  if dgTitles in Options then TitleHeight := RowHeights[0];
  if RowsHeight > DefaultRowHeight then begin
    DefaultRowHeight := RowsHeight;
    if dgTitles in Options then RowHeights[0] := TitleHeight;
    Invalidate;
  end
  else FRowsHeight := DefaultRowHeight;
end;

procedure TDBGlyphGrid.CMFontChanged(var Message: TMessage);
begin
  if not FDrawing then inherited;
end;

procedure TDBGlyphGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Assigned(FOnMouseDown) then FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TDBGlyphGrid.DrawDataCell(const Rect: TRect; Field: TField;
  State: TGridDrawState);
var
  FTmpImage: TBitmap;
  X, Y: Integer;
begin
  FTmpImage := CreateFieldImage(Field);
  if FTmpImage <> nil then begin
    try
      X := (Rect.Left + Rect.Right - FTmpImage.Width) div 2;
      Y := (Rect.Top + Rect.Bottom - FTmpImage.Height) div 2;
      Canvas.FillRect(Rect);
      Canvas.Draw(X, Y, FTmpImage);
    finally
      FTmpImage.Free;
    end;
  end;
  inherited DefaultDrawing := True;
  inherited DrawDataCell(Rect, Field, State);
end;

procedure TDBGlyphGrid.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
var
  TempCol: Longint;
  TempRow: Longint;
  OldActive: Integer;
  OldColor, FontColor: TColor;
  OldStyle, FontStyle: TFontStyles;
  Field: TField;
begin
  TempCol := ACol;
  if dgIndicator in Options then Dec(TempCol);
  TempRow := ARow;
  if dgTitles in Options then Dec(TempRow);
  Field := GetColField(TempCol);
  inherited DefaultDrawing := (GetFieldImageIndex(Field) = 0);
  if (Field <> nil) and (TempRow >= 0) then begin
    OldColor := Font.Color;
    OldStyle := Font.Style;
    FDrawing := True;
    try
      FontColor := OldColor;
      FontStyle := OldStyle;
      OldActive := DataLink.ActiveRecord;
      try
        DataLink.ActiveRecord := TempRow;
        GetFontProps(FontColor, FontStyle, Field);
      finally
        DataLink.ActiveRecord := OldActive;
      end;
      Font.Color := FontColor;
      Font.Style := FontStyle;
      inherited DrawCell(ACol, ARow, ARect, AState);
    finally
      Font.Color := OldColor;
      Font.Style := OldStyle;
      FDrawing := False;
    end;
  end
  else inherited DrawCell(ACol, ARow, ARect, AState);
end;

procedure TDBGlyphGrid.MouseToCell(X, Y: Integer; var ACol, ARow: Longint);
var
  Coord: TGridCoord;
begin
  Coord := MouseCoord(X, Y);
  ACol := Coord.X;
  ARow := Coord.Y;
end;

{ TDBDateEdit }

constructor TDBDateEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  inherited ReadOnly := True;
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
  Self.OnAfterDialog := AfterDialog;
  EditMask := GetDateMask;
  AlwaysEnable := True;
end;

destructor TDBDateEdit.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;
  inherited Destroy;
end;

procedure TDBDateEdit.AfterDialog(Sender: TObject; var Date: TDateTime;
  var Action: Boolean);
begin
  Action := DataSource.DataSet.CanModify and Action;
  if Action then begin
    EditCanModify;
  end;
end;

procedure TDBDateEdit.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TDBDateEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if not ReadOnly and ((Key = VK_DELETE) or ((Key = VK_INSERT)
    and (ssShift in Shift))) then
    FDataLink.Edit;
end;

procedure TDBDateEdit.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if (Key in [#32..#255]) and (FDataLink.Field <> nil) and
    not (Key in ['0'..'9']) and (Key <> DateSeparator) then
  begin
    MessageBeep(0);
    Key := #0;
  end;
  case Key of
    ^H, ^V, ^X, '0'..'9': FDataLink.Edit;
    #27:
      begin
        Reset;
        Key := #0;
      end;
  end;
end;

function TDBDateEdit.EditCanModify: Boolean;
begin
  Result := FDataLink.Edit;
end;

procedure TDBDateEdit.Reset;
begin
  FDataLink.Reset;
  SelectAll;
end;

procedure TDBDateEdit.Change;
begin
  FDataLink.Modified;
  inherited Change;
end;

function TDBDateEdit.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDBDateEdit.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

function TDBDateEdit.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TDBDateEdit.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TDBDateEdit.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly;
end;

procedure TDBDateEdit.SetReadOnly(Value: Boolean);
begin
  FDataLink.ReadOnly := Value;
end;

function TDBDateEdit.GetField: TField;
begin
  Result := FDataLink.Field;
end;

procedure TDBDateEdit.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then begin
    if FDataLink.Field.EditMask <> '' then
      EditMask := FDataLink.Field.EditMask
    else EditMask := GetDateMask;
    Self.Date := FDataLink.Field.AsDateTime;
  end
  else begin
    if csDesigning in ComponentState then begin
      EditMask := '';
      EditText := Name;
    end
    else begin
      EditMask := GetDateMask;
      if DefaultToday then Date := SysUtils.Date
      else Date := 0;
    end;
  end;
end;

procedure TDBDateEdit.EditingChange(Sender: TObject);
begin
  inherited ReadOnly := not FDataLink.Editing;
end;

procedure TDBDateEdit.UpdateData(Sender: TObject);
var
  D: TDateTime;
begin
  ValidateEdit;
  D := Self.Date;
  if D <> 0 then FDataLink.Field.AsDateTime := D
  else FDataLink.Field.Clear;
end;

procedure TDBDateEdit.WMPaste(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

procedure TDBDateEdit.WMCut(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

procedure TDBDateEdit.CMExit(var Message: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  except
    SelectAll;
    SetFocus;
    raise;
  end;
  DoExit;
end;

end.