{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
unit Switch;

interface

uses SysUtils, Messages, WinTypes, WinProcs, Classes, Graphics, 
  Controls, Forms, StdCtrls, ExtCtrls, Menus;

type

{ TSwitch }

  TTextPos = (tpRight, tpLeft, tpAbove, tpBelow, tpNone);
  TSwitchBitmaps = set of Boolean;

  TSwitch = class(TCustomControl)
  private
    { Private declarations }
    FActive: Boolean;
    FBitmaps: array [Boolean] of TBitmap;
    FOnOn: TNotifyEvent;
    FOnOff: TNotifyEvent;
    FStateOn: Boolean;
    FTextPosition: TTextPos;
    FBorderStyle: TBorderStyle;
    FToggleKey: TShortCut;
    FShowFocus: Boolean;
    FUserBitmaps: TSwitchBitmaps;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure SetStateOn(Value: Boolean);
    procedure SetTextPosition(Value: TTextPos);
    procedure SetBorderStyle(Value: TBorderStyle);
    function GetSwitchGlyph(Index: Integer): TBitmap;
    procedure SetSwitchGlyph(Index: Integer; Value: TBitmap);
    function StoreBitmap(Index: Integer): Boolean;
    procedure SetShowFocus(Value: Boolean);
    procedure ReadBinaryData(Stream: TStream);
    procedure WriteBinaryData(Stream: TStream);
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Paint; override;
    procedure DoOn; dynamic;
    procedure DoOff; dynamic;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ToggleSwitch;
  published
    { Published declarations }
    property Align;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle
      default bsNone;
    property Caption;
    property Color;
    property Cursor;
    property DragMode;
    property DragCursor;
    property Font;
    property GlyphOff: TBitmap index 0 read GetSwitchGlyph write SetSwitchGlyph
      stored StoreBitmap;
    property GlyphOn: TBitmap index 1 read GetSwitchGlyph write SetSwitchGlyph
      stored StoreBitmap;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowFocus: Boolean read FShowFocus write SetShowFocus default True;
    property ToggleKey: TShortCut read FToggleKey write FToggleKey
      default VK_SPACE;
    property ShowHint;
    property StateOn: Boolean read FStateOn write SetStateOn default False;
    property TabOrder;
    property TabStop default True;
    property TextPosition: TTextPos read FTextPosition write SetTextPosition
      default tpNone;
    property OnClick;
    property OnDblClick;
    property OnMouseMove;
    property OnMouseDown;
    property OnMouseUp;
    property OnKeyDown;
    property OnKeyUp;
    property OnKeyPress;
    property OnDragOver;
    property OnDragDrop;
    property OnEndDrag;
    property OnOn: TNotifyEvent read FOnOn write FOnOn;
    property OnOff: TNotifyEvent read FOnOff write FOnOff;
  end;

implementation

{$R *.RES}

const
  ResName: array [Boolean] of PChar = ('SWITCH_OFF', 'SWITCH_ON');
  BorderStyles: array[TBorderStyle] of Longint = (0, WS_BORDER);

{ TSwitch component }

constructor TSwitch.Create(AOwner: TComponent);
var
  I: Byte;
begin
  inherited Create(AOwner);
  ControlStyle := [csClickEvents, csSetCaption, csCaptureMouse,
    csOpaque, csDoubleClicks];
  Width := 50;
  Height := 60;
  for I := 0 to 1 do begin
    FBitmaps[Boolean(I)] := TBitmap.Create;
    SetSwitchGlyph(I, nil);
  end;
  FUserBitmaps := [];
  FShowFocus := True;
  FStateOn := False;
  FTextPosition := tpNone;
  FBorderStyle := bsNone;
  FToggleKey := VK_SPACE;
  TabStop := True;
end;

destructor TSwitch.Destroy;
var
  I: Byte;
begin
  for I := 0 to 1 do FBitmaps[Boolean(I)].Free;
  inherited Destroy;
end;

procedure TSwitch.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do begin
    WindowClass.Style := WindowClass.Style or CS_HREDRAW or CS_VREDRAW;
    Style := Style or BorderStyles[FBorderStyle];
  end;
end;

procedure TSwitch.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Data', ReadBinaryData, WriteBinaryData,
    FUserBitmaps <> []);
end;

procedure TSwitch.ReadBinaryData(Stream: TStream);
begin
  Stream.ReadBuffer(FUserBitmaps, SizeOf(FUserBitmaps));
end;

procedure TSwitch.WriteBinaryData(Stream: TStream);
begin
  Stream.WriteBuffer(FUserBitmaps, SizeOf(FUserBitmaps));
end;

function TSwitch.StoreBitmap(Index: Integer): Boolean;
begin
  Result := Boolean(Index) in FUserBitmaps;
end;

function TSwitch.GetSwitchGlyph(Index: Integer): TBitmap;
begin
  if csLoading in ComponentState then Include(FUserBitmaps, Boolean(Index));
  Result := FBitmaps[Boolean(Index)]
end;

procedure TSwitch.SetSwitchGlyph(Index: Integer; Value: TBitmap);
begin
  if Value <> nil then begin
    FBitmaps[Boolean(Index)].Assign(Value);
    Include(FUserBitmaps, Boolean(Index));
  end
  else begin
    FBitmaps[Boolean(Index)].Handle := LoadBitmap(HInstance,
      ResName[Boolean(Index)]);
    Exclude(FUserBitmaps, Boolean(Index));
  end;
  Invalidate;
end;

procedure TSwitch.CMFocusChanged(var Message: TCMFocusChanged);
var
  Active: Boolean;
begin
  with Message do Active := (Sender = Self);
  if Active <> FActive then begin
    FActive := Active;
    if FShowFocus then Invalidate;
  end;
  inherited;
end;

procedure TSwitch.CMTextChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TSwitch.CMDialogChar(var Message: TCMDialogChar);
begin
  if IsAccel(Message.CharCode, Caption) and CanFocus then begin
    SetFocus;
    Message.Result := 1;
  end;
end;

procedure TSwitch.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    SetFocus;
    ToggleSwitch;
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TSwitch.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if FToggleKey = ShortCut(Key, Shift) then begin
    ToggleSwitch;
    Key := 0;
  end;
end;

procedure TSwitch.Paint;
var
  ARect: TRect;
  Text: array[0..255] of Char;
  FontHeight: Integer;

  procedure DrawBitmap(Bmp: TBitmap);
  var
    TmpImage: TBitmap;
    IWidth, IHeight, X, Y: Integer;
    IRect: TRect;
  begin
    IWidth := Bmp.Width;
    IHeight := Bmp.Height;
    IRect := Rect(0, 0, IWidth, IHeight);
    TmpImage := TBitmap.Create;
    try
      TmpImage.Width := IWidth;
      TmpImage.Height := IHeight;
      TmpImage.Canvas.Brush.Color := Self.Brush.Color;
      TmpImage.Canvas.BrushCopy(IRect, Bmp, IRect, Bmp.TransparentColor);
      case FTextPosition of
        tpRight:
          begin
            X := 0;
            Y := ((Height - IHeight) div 2);
            Inc(ARect.Left, IWidth);
          end;
        tpLeft:
          begin
            X := Width - IWidth;
            Y := ((Height - IHeight) div 2);
            Dec(ARect.Right, IWidth);
          end;
        tpBelow:
          begin
            X := ((Width - IWidth) div 2);
            Y := 0;
            Inc(ARect.Top, IHeight);
          end;
        tpAbove:
          begin
            X := ((Width - IWidth) div 2);
            Y := Height - IHeight;
            Dec(ARect.Bottom, IHeight);
          end;
        tpNone:
          begin
            X := ((Width - IWidth) div 2);
            Y := ((Height - IHeight) div 2);
          end;
      end;
      Canvas.Draw(X, Y, TmpImage);
      if Focused and FShowFocus and not (csDesigning in ComponentState) then
        Canvas.DrawFocusRect(Rect(X, Y, X + IWidth, Y + IHeight));
    finally
      TmpImage.Free;
    end;
  end;

begin
  ARect := GetClientRect;
  with Canvas do
  begin
    Brush.Color := Color;
    FillRect(ARect);
    Brush.Style := bsClear;
    Font := Self.Font;
    FontHeight := TextHeight('W');
    DrawBitmap(FBitmaps[FStateOn]);
    if FTextPosition <> tpNone then begin
      with ARect do
      begin
        Top := ((Bottom + Top) - FontHeight) shr 1;
        Bottom := Top + FontHeight;
      end;
      StrPCopy(Text, Caption);
      WinProcs.DrawText(Handle, Text, StrLen(Text), ARect, DT_EXPANDTABS or
        DT_VCENTER or DT_CENTER);
    end;
  end;
end;

procedure TSwitch.DoOn;
begin
  if Assigned(FOnOn) then FOnOn(Self);
end;

procedure TSwitch.DoOff;
begin
  if Assigned(FOnOff) then FOnOff(Self);
end;

procedure TSwitch.ToggleSwitch;
begin
  StateOn := not StateOn;
end;

procedure TSwitch.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TSwitch.SetStateOn(Value: Boolean);
begin
  if FStateOn <> Value then begin
    FStateOn := Value;
    Invalidate;
    if Value then DoOn
    else DoOff;
  end;
end;

procedure TSwitch.SetTextPosition(Value: TTextPos);
begin
  if FTextPosition <> Value then begin
    FTextPosition := Value;
    Invalidate;
  end;
end;

procedure TSwitch.SetShowFocus(Value: Boolean);
begin
  if FShowFocus <> Value then begin
    FShowFocus := Value;
    if not (csDesigning in ComponentState) then Invalidate;
  end;
end;

end.