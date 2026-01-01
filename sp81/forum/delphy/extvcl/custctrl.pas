{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
unit CustCtrl;

{$W-,R-,B-}

interface

uses Messages, WinTypes, WinProcs, Classes, Controls, Graphics,
  StdCtrls, ExtCtrls, Forms, Menus;

type

{ TTextListBox }

  TTextListBox = class(TCustomListBox)
  private
    FMaxItemWidth: Integer;
    procedure ResetHorizontalExtent;
    procedure SetHorizontalExtent;
  protected
    procedure WndProc(var Message: TMessage); override;
  published
    property Align;
    property BorderStyle;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property ExtendedSelect;
    property Font;
    property IntegralHeight;
    property ItemHeight;
    property Items;
    property MultiSelect;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Sorted;
    property TabOrder;
    property TabStop;
    property Visible;
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

{ TShadowLabel }

  TShadowPosition = (spLeftTop, spLeftBottom, spRightBottom, spRightTop);

  TShadowLabel = class(TGraphicControl)
  private
    FFocusControl: TWinControl;
    FAlignment: TAlignment;
    FAutoSize: Boolean;
    FShadowColor: TColor;
    FShadowSize: Byte;
    FShadowPos: TShadowPosition;
    FWordWrap: Boolean;
    FShowAccelChar: Boolean;
    procedure AdjustBounds;
    procedure DoDrawText(var Rect: TRect; Flags: Word);
    function GetTransparent: Boolean;
    procedure SetAlignment(Value: TAlignment);
    procedure SetAutoSize(Value: Boolean);
    procedure SetShadowColor(Value: TColor);
    procedure SetShadowSize(Value: Byte);
    procedure SetShadowPos(Value: TShadowPosition);
    procedure SetShowAccelChar(Value: Boolean);
    procedure SetTransparent(Value: Boolean);
    procedure SetWordWrap(Value: Boolean);
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Canvas;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default True;
    property FocusControl: TWinControl read FFocusControl write FFocusControl;
    property ShowAccelChar: Boolean read FShowAccelChar write SetShowAccelChar default True;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clBtnHighlight;
    property ShadowSize: Byte read FShadowSize write SetShadowSize default 1;
    property ShadowPos: TShadowPosition read FShadowPos write SetShadowPos default spLeftTop;
    property Transparent: Boolean read GetTransparent write SetTransparent default False;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
    property Align;
    property Caption;
    property Color;
    property DragCursor;
    property DragMode;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

{ TSecretPanel }

  TGlyphLayout = (glGlyphLeft, glGlyphRight, glGlyphTop, glGlyphBottom);

  TSecretPanel = class(TCustomPanel)
  private
    FActive: Boolean;
    FLines: TStrings;
    FScrollCnt: Integer;
    FTxtDivider: Byte;
    FTimer: TTimer;
    FTxtRect: TRect;
    FGlyphOrigin: TPoint;
    FMemoryImage: TBitmap;
    FGlyph: TBitmap;
    FGlyphLayout: TGlyphLayout;
    FOnStartPlay: TNotifyEvent;
    FOnStopPlay: TNotifyEvent;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure SetGlyph(Value: TBitmap);
    procedure SetLines(Value: TStrings);
    procedure SetActive(Value: Boolean);
    procedure SetGlyphLayout(Value: TGlyphLayout);
    procedure RecalcDrawRect;
    procedure PaintGlyph;
    procedure PaintText;
  protected
    procedure Paint; override;
    procedure TimerExpired(Sender: TObject); dynamic;
    procedure StartPlay; dynamic;
    procedure StopPlay; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Active: Boolean read FActive write SetActive default False;
    property Glyph: TBitmap read FGlyph write SetGlyph;
    property GlyphLayout: TGlyphLayout read FGlyphLayout write SetGlyphLayout
      default glGlyphLeft;
    property Lines: TStrings read FLines write SetLines;
    property Align;
    property BevelInner;
    property BevelOuter default bvLowered;
    property BevelWidth;
    property BorderWidth;
    property BorderStyle;
    property DragCursor;
    property DragMode;
    property Color;
    property Ctl3D;
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
    property OnStartPlay: TNotifyEvent read FOnStartPlay write FOnStartPlay;
    property OnStopPlay: TNotifyEvent read FOnStopPlay write FOnStopPlay;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

{ TColorComboBox }

  TColorComboBox = class(TCustomComboBox)
  private
    FColorValue: TColor;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure SetColorValue(NewValue: TColor);
    procedure ResetItemHeight;
  protected
    FOnChange: TNotifyEvent;
    procedure CreateWnd; override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    procedure Click; override;
    procedure BuildList; virtual;
    procedure Change; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    property Text;
  published
    property ColorValue: TColor read FColorValue write SetColorValue
      default clBlack;
    property Color;
    property Ctl3D;
    property DragMode;
    property DragCursor;
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
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
  end;

implementation

uses SysUtils, Dialogs, VCLUtil;

{ TTextListBox }

procedure TTextListBox.SetHorizontalExtent;
begin
  SendMessage(Handle, LB_SETHORIZONTALEXTENT, Cardinal(FMaxItemWidth), 0);
end;

procedure TTextListBox.ResetHorizontalExtent;
var
  I: Integer;
  ItemWidth: Word;
begin
  FMaxItemWidth := 0;
  for I := 0 to Pred(Items.Count) do begin
    ItemWidth := Canvas.TextWidth(Items[I]);
    if ItemWidth > FMaxItemWidth then
      FMaxItemWidth := ItemWidth;
  end;
  SetHorizontalExtent;
end;

procedure TTextListBox.WndProc(var Message: TMessage);
var
  ItemWidth: Word;
begin
  case Message.Msg of
    LB_ADDSTRING, LB_INSERTSTRING:
      begin
        ItemWidth := Canvas.TextWidth(StrPas(PChar(Message.lParam)));
        if ItemWidth > FMaxItemWidth then
        begin
          FMaxItemWidth := ItemWidth;
          SetHorizontalExtent;
        end;
      end;
    LB_DELETESTRING:
      begin
        ItemWidth := Canvas.TextWidth(Items[Message.wParam]);
        if ItemWidth = FMaxItemWidth then
        begin
          SendMessage(Handle, WM_HSCROLL, SB_TOP, 0);
          inherited WndProc(Message);
          ResetHorizontalExtent;
          Exit;
        end;
      end;
    LB_RESETCONTENT:
      begin
        FMaxItemWidth := 0;
        SetHorizontalExtent;
        SendMessage(Handle, WM_HSCROLL, SB_TOP, 0);
      end;
    WM_SETFONT:
      begin
        inherited WndProc(Message);
        ResetHorizontalExtent;
        Exit;
      end;
  end;
  inherited WndProc(Message);
end;

{ TShadowLabel }

function DrawShadowText(DC: HDC; Str: PChar; Count: Integer; var Rect: TRect;
  Format: Word; ShadowSize: Byte; ShadowColor: TColorRef;
  ShadowPos: TShadowPosition): Integer;
var
  RText, RShadow: TRect;
  Color: TColorRef;
begin
  RText := Rect;
  RShadow := Rect;
  Color := SetTextColor(DC, ShadowColor);
  case ShadowPos of
    spLeftTop:
      begin
        OffsetRect(RText, ShadowSize, ShadowSize);
      end;
    spLeftBottom:
      begin
        OffsetRect(RText, ShadowSize, 0);
        OffsetRect(RShadow, 0, ShadowSize);
      end;
    spRightBottom:
      begin
        OffsetRect(RShadow, ShadowSize, ShadowSize);
      end;
    spRightTop:
      begin
        OffsetRect(RText, 0, ShadowSize);
        OffsetRect(RShadow, ShadowSize, 0);
      end;
  end; { case }
  Result := DrawText(DC, Str, Count, RShadow, Format);
  if Result > 0 then Inc(Result, ShadowSize);
  SetTextColor(DC, Color);
  DrawText(DC, Str, Count, RText, Format);
  UnionRect(Rect, RText, RShadow);
end;

constructor TShadowLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 65;
  Height := 17;
  FAutoSize := True;
  FShowAccelChar := True;
  FShadowColor := clBtnHighlight;
  FShadowSize := 1;
  FShadowPos := spLeftTop;
end;

procedure TShadowLabel.DoDrawText(var Rect: TRect; Flags: Word);
var
  Text: array[0..255] of Char;
begin
  Flags := Flags or DT_EXPANDTABS;
  GetTextBuf(Text, SizeOf(Text));
  if (Flags and DT_CALCRECT <> 0) and ((Text[0] = #0) or FShowAccelChar and
    (Text[0] = '&') and (Text[1] = #0)) then StrCopy(Text, ' ');
  if not FShowAccelChar then Flags := Flags or DT_NOPREFIX;
  Canvas.Font := Font;
  if not Enabled then Canvas.Font.Color := clGrayText;
  DrawShadowText(Canvas.Handle, Text, StrLen(Text), Rect, Flags,
    FShadowSize, ColorToRGB(FShadowColor), FShadowPos);
end;

procedure TShadowLabel.Paint;
const
  Alignments: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
var
  Rect: TRect;
begin
  with Canvas do begin
    if not Transparent then begin
      Brush.Color := Self.Color;
      Brush.Style := bsSolid;
      FillRect(ClientRect);
    end;
    Brush.Style := bsClear;
    Rect := ClientRect;
    DoDrawText(Rect, DT_WORDBREAK or Alignments[FAlignment]);
  end;
end;

procedure TShadowLabel.AdjustBounds;
const
  WordWraps: array[Boolean] of Word = (0, DT_WORDBREAK);
var
  DC: HDC;
  X: Integer;
  Rect: TRect;
begin
  if {not (csReading in ComponentState) and} FAutoSize then begin
    Rect := ClientRect;
    DC := GetDC(0);
    Canvas.Handle := DC;
    DoDrawText(Rect, DT_CALCRECT or WordWraps[FWordWrap]);
    Canvas.Handle := 0;
    ReleaseDC(0, DC);
    X := Left;
    if FAlignment = taRightJustify then Inc(X, Width - Rect.Right);
    SetBounds(X, Top, Rect.Right, Rect.Bottom);
  end;
end;

procedure TShadowLabel.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then begin
    FAlignment := Value;
    Invalidate;
  end;
end;

procedure TShadowLabel.SetAutoSize(Value: Boolean);
begin
  if FAutoSize <> Value then begin
    FAutoSize := Value;
    AdjustBounds;
  end;
end;

procedure TShadowLabel.SetShadowColor(Value: TColor);
begin
  if Value <> FShadowColor then begin
    FShadowColor := Value;
    Invalidate;
  end;
end;

procedure TShadowLabel.SetShadowSize(Value: Byte);
begin
  if Value <> FShadowSize then begin
    FShadowSize := Value;
    AdjustBounds;
    Invalidate;
  end;
end;

procedure TShadowLabel.SetShadowPos(Value: TShadowPosition);
begin
  if Value <> FShadowPos then begin
    FShadowPos := Value;
    Invalidate;
  end;
end;

function TShadowLabel.GetTransparent: Boolean;
begin
  Result := not (csOpaque in ControlStyle);
end;

procedure TShadowLabel.SetShowAccelChar(Value: Boolean);
begin
  if FShowAccelChar <> Value then begin
    FShowAccelChar := Value;
    Invalidate;
  end;
end;

procedure TShadowLabel.SetTransparent(Value: Boolean);
begin
  if Transparent <> Value then begin
    if Value then ControlStyle := ControlStyle - [csOpaque]
    else ControlStyle := ControlStyle + [csOpaque];
    Invalidate;
  end;
end;

procedure TShadowLabel.SetWordWrap(Value: Boolean);
begin
  if FWordWrap <> Value then begin
    FWordWrap := Value;
    AdjustBounds;
  end;
end;

procedure TShadowLabel.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FFocusControl) then
    FFocusControl := nil;
end;

procedure TShadowLabel.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
  AdjustBounds;
end;

procedure TShadowLabel.CMFontChanged(var Message: TMessage);
begin
  inherited;
  AdjustBounds;
end;

procedure TShadowLabel.CMDialogChar(var Message: TCMDialogChar);
begin
  if (FFocusControl <> nil) and Enabled and ShowAccelChar and
    IsAccel(Message.CharCode, Caption) then
  begin
    with FFocusControl do
      if CanFocus then begin
        SetFocus;
        Message.Result := 1;
      end;
  end;
end;

{ TSecretPanel }

constructor TSecretPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FScrollCnt := 0;
  FActive := False;
  FTxtDivider := 1;
  FGlyphLayout := glGlyphLeft;
  Caption := '';
  BevelOuter := bvLowered;
  FLines := TStringList.Create;
  FGlyph := TBitmap.Create;
  FTimer := TTimer.Create(Self);
  with FTimer do begin
    Enabled := False;
    OnTimer := TimerExpired;
    Interval := 30;
  end;
end;

destructor TSecretPanel.Destroy;
begin
  SetActive(False);
  FGlyph.Free;
  FLines.Free;
  inherited Destroy;
end;

procedure TSecretPanel.CMTextChanged(var Message: TMessage);
begin
  if Caption <> '' then Caption := '';
end;

procedure TSecretPanel.RecalcDrawRect;
var
  R: TRect;
  InflateWidth: Integer;
begin
  R := GetClientRect;
  InflateWidth := BorderWidth + 3;
  if BevelOuter <> bvNone then Inc(InflateWidth, BevelWidth);
  if BevelInner <> bvNone then Inc(InflateWidth, BevelWidth);
  InflateRect(R, -InflateWidth, -InflateWidth);
  FTxtRect := R;
  with FGlyphOrigin do begin
    case FGlyphLayout of
      glGlyphLeft:
        begin
          X := R.Left;
          Y := (R.Bottom + R.Top - Glyph.Height) div 2;
          if Y < R.Top then Y := R.Top;
          Inc(X, 3);
          FTxtRect.Left := X + Glyph.Width;
        end;
      glGlyphRight:
        begin
          Y := (R.Bottom + R.Top - Glyph.Height) div 2;
          if Y < R.Top then Y := R.Top;
          X := R.Right - Glyph.Width;
          Dec(X, 3);
          if X < R.Left then X := R.Left;
          FTxtRect.Right := X;
        end;
      glGlyphTop:
        begin
          Y := R.Top;
          X := (R.Right + R.Left - Glyph.Width) div 2;
          if X < R.Left then X := R.Left;
          Inc(Y, 2);
          FTxtRect.Top := Y + Glyph.Height;
        end;
      glGlyphBottom:
        begin
          X := (R.Right + R.Left - Glyph.Width) div 2;
          if X < R.Left then X := R.Left;
          Y := R.Bottom - Glyph.Height;
          Dec(Y, 2);
          if Y < R.Top then Y := R.Top;
          FTxtRect.Bottom := Y;
        end;
    end;
  end;
  with FTxtRect do
    if (Left >= Right) or (Top >= Bottom) then FTxtRect := Rect(0, 0, 0, 0);
end;

procedure TSecretPanel.PaintGlyph;
begin
  if (FGlyph.Handle = 0) or (Glyph.Height = 0) or (Glyph.Width = 0) then
    Exit;
  RecalcDrawRect;
  DrawBitmapTransparent(Canvas, FGlyphOrigin.X, FGlyphOrigin.Y,
    FGlyph, FGlyph.TransparentColor);
end;

procedure TSecretPanel.PaintText;
var
  STmp: array[0..255] of char;
  R, IRect: TRect;
  I, HalfWidth: Integer;
  FDC: HDC;
begin
  if (FLines.Count = 0) then Exit;
  with R do begin
    Left := 0;
    Right := FTxtRect.Right - FTxtRect.Left;
    Top := 0;
    Bottom := FTxtRect.Bottom - FTxtRect.Top;
  end;
  IRect := R;
  FDC := GetDC(Handle);
  try
    FMemoryImage.Canvas.FillRect(R);
    SetTextAlign(FMemoryImage.Canvas.Handle, TA_CENTER);
    Dec(R.top, FScrollCnt mod FTxtDivider);
    R.bottom := R.top + FTxtDivider;
    HalfWidth := (R.Right + R.Left) div 2;
    for I := (FScrollCnt div FTxtDivider) to FLines.Count do
    begin
      if I = FLines.Count then StrCopy(STmp, ' ')
      else StrPCopy(STmp, FLines[I]);
      if R.Top >= FTxtRect.Bottom then Break;
      ExtTextOut(FMemoryImage.Canvas.Handle, HalfWidth, R.Top,
        ETO_CLIPPED, @IRect, STmp, StrLen(STmp), nil);
      OffsetRect(R, 0, FTxtDivider);
    end;
    with FTxtRect do
      BitBlt(FDC, Left, Top, (Right - Left), (Bottom - Top),
        FMemoryImage.Canvas.Handle, 0, 0, SrcCopy);
  finally
    ReleaseDC(Handle, FDC);
  end;
end;

procedure TSecretPanel.Paint;
begin
  inherited Paint;
  if FActive then PaintGlyph;
end;

procedure TSecretPanel.StartPlay;
begin
  if Assigned(FOnStartPlay) then FOnStartPlay(Self);
end;

procedure TSecretPanel.StopPlay;
begin
  if Assigned(FOnStopPlay) then FOnStopPlay(Self);
end;

procedure TSecretPanel.TimerExpired(Sender: TObject);
begin
  if (FScrollCnt < (FLines.Count - 1) * FTxtDivider) then
  begin
    Inc(FScrollCnt);
    PaintText;
  end
  else SetActive(False);
end;

procedure TSecretPanel.SetActive(Value: Boolean);
var
  DC: HDC;
  TM: TTextMetric;
  I: Integer;
begin
  if Value <> FActive then begin
    FActive := Value;
    FScrollCnt := 0;
    if FActive then begin
      DC := GetDC(Handle);
      try
        SelectObject(DC, Self.Font.Handle);
        GetTextMetrics(DC, TM);
        FTxtDivider := TM.tmHeight + TM.tmExternalLeading;
        RecalcDrawRect;
        if FMemoryImage = nil then FMemoryImage := TBitmap.Create;
        FMemoryImage.Width := FTxtRect.Right - FTxtRect.Left;
        FMemoryImage.Height := FTxtRect.Bottom - FTxtRect.Top;
        with FMemoryImage.Canvas do begin
          Font := Self.Font;
          Brush.Color := Self.Color;
          SetBkMode(Handle, Transparent);
          SetBkColor(Handle, ColorToRGB(Self.Color));
          SetTextColor(Handle, ColorToRGB(Self.Font.Color));
        end;
        FMemoryImage.Canvas.FillRect(FTxtRect);
        FTimer.Enabled := True;
        StartPlay;
      except
        FActive := False;
        raise;
      end;
      ReleaseDC(Handle, DC);
    end
    else begin
      try
        FTimer.Enabled := False;
        if FMemoryImage <> nil then begin
          FMemoryImage.Free;
          FMemoryImage := nil;
        end;
        StopPlay;
        if (csDesigning in ComponentState) then
          ValidParentForm(Self).Designer.Modified;
      except
        raise;
      end;
    end;
    for I := 0 to Pred(ControlCount) do Controls[I].Visible := not FActive;
    Invalidate;
  end;
end;

procedure TSecretPanel.SetGlyph(Value: TBitmap);
begin
  FGlyph.Assign(Value);
  if FActive then Invalidate;
end;

procedure TSecretPanel.SetGlyphLayout(Value: TGlyphLayout);
begin
  if FGlyphLayout <> Value then begin
    FGlyphLayout := Value;
    if FActive then Invalidate;
  end;
end;

procedure TSecretPanel.SetLines(Value: TStrings);
begin
  FLines.Assign(Value);
  if FActive then begin
    FScrollCnt := 0;
    Invalidate;
  end;
end;

{ TColorComboBox }

const
  ColorsInList = 16;
  ColorValues: array [1..ColorsInList] of TColor = (
    clBlack,
    clMaroon,
    clGreen,
    clOlive,
    clNavy,
    clPurple,
    clTeal,
    clGray,
    clSilver,
    clRed,
    clLime,
    clYellow,
    clBlue,
    clFuchsia,
    clAqua,
    clWhite);

constructor TColorComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Style := csOwnerDrawFixed;
  FColorValue := clBlack;  { make default color selected }
end;

procedure TColorComboBox.BuildList;
var
  I: Integer;
  ColorName: string[30];
begin
  Clear;
  for I := 1 to ColorsInList do
  begin
    { delete two first characters which prefix "cl" educated }
    ColorName := Copy(ColorToString(ColorValues[I]), 3, 30);
    Items.AddObject(ColorName, TObject(ColorValues[I]));
  end;
end;

procedure TColorComboBox.SetColorValue(NewValue: TColor);
var
  Item: Integer;
  CurrentColor: TColor;
begin
  if (ItemIndex < 0) or (NewValue <> FColorValue) then
    { change selected item }
    for Item := 0 to Pred(Items.Count) do begin
      CurrentColor := TColor(Items.Objects[Item]);
      if CurrentColor = NewValue then
      begin
        FColorValue := NewValue; 
        if ItemIndex <> Item then
          ItemIndex := Item;
        Change;
        Break;
      end;
    end;
end;

procedure TColorComboBox.CreateWnd;
begin
  inherited CreateWnd;
  BuildList;
  SetColorValue(FColorValue);
end;

procedure TColorComboBox.DrawItem(Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
const
  ColorWidth = 22;
var
  DrawColor: TColor;
  ARect: TRect;
  Text: array[0..255] of Char;
  Safer: TColor;
begin
  ARect := Rect;
  Inc(ARect.Top, 2);
  Inc(ARect.Left, 2);
  Dec(ARect.Bottom, 2);
  ARect.Right := ARect.Left + ColorWidth;
  with Canvas do
  begin
    FillRect(Rect);
    Safer := Brush.Color;
    DrawColor := TColor(Items.Objects[Index]);
    Pen.Color := clBlack;
    Rectangle(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
    Brush.Color := DrawColor;
    InflateRect(ARect, -1, -1);
    FillRect(ARect);
    Brush.Color := Safer;
    StrPCopy(Text, Items[Index]);
    Rect.Left := Rect.Left + ColorWidth + 6;
    DrawText(Canvas.Handle, Text, StrLen(Text), Rect,
      DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
  end;
end;

procedure TColorComboBox.Click;
begin
  if ItemIndex >= 0 then
    ColorValue := TColor(Items.Objects[ItemIndex]);
  inherited Click;
end;

procedure TColorComboBox.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ResetItemHeight;
  RecreateWnd;
end;

procedure TColorComboBox.ResetItemHeight;
var
  nuHeight: Integer;
begin
  nuHeight := -MulDiv(Font.Height, 12, 10);
  if nuHeight < 10 then nuHeight := 10;
  ItemHeight := nuHeight;
end;

procedure TColorComboBox.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

end.
