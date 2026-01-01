{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
unit Slider;

interface

uses
  WinTypes, Classes, Messages, Controls, Graphics;

type
  TSliderKind = (skValue, skPercent, skEnum);
  TSliderStyle = (slHorizontal, slVertical);
  TSliderImage = (imRuler, imSlider);

const
  idxHRuler = Integer(slHorizontal) * (Integer(High(TSliderStyle)) + 1) + Integer(imRuler);
  idxHSlider = Integer(slHorizontal) * (Integer(High(TSliderStyle)) + 1) + Integer(imSlider);
  idxVRuler = Integer(slVertical) * (Integer(High(TSliderStyle)) + 1) + Integer(imRuler);
  idxVSlider = Integer(slVertical) * (Integer(High(TSliderStyle)) + 1) + Integer(imSlider);

type
  TSlider = class;

  TSliderImages = class(TPersistent)
  private
    FSlider: TSlider;
    FImages: array[TSliderStyle, TSliderImage] of TBitmap;
    FIsCustom: array[TSliderStyle, TSliderImage] of Boolean;
    FTransparentColor: TColor;
    FEdgeSize: Integer;
    procedure ReadIsCustom(Reader: TReader);
    procedure WriteIsCustom(Writer: TWriter);
    function GetImage(Index: Integer): TBitmap;
    procedure SetImage(Index: Integer; Value: TBitmap);
    procedure SetTransparentColor(Value: TColor);
    procedure SetEdgeSize(Value: Integer);
  protected
    procedure DefineProperties(Filer: TFiler); override;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property HRuler: TBitmap index idxHRuler read GetImage write SetImage
      stored FIsCustom[slHorizontal, imRuler];
    property HSlider: TBitmap index idxHSlider read GetImage write SetImage
      stored FIsCustom[slHorizontal, imSlider];
    property VRuler: TBitmap index idxVRuler read GetImage write SetImage
      stored FIsCustom[slVertical, imRuler];
    property VSlider: TBitmap index idxVSlider read GetImage write SetImage
      stored FIsCustom[slVertical, imRuler];
    property TransparentColor: TColor read FTransparentColor
      write SetTransparentColor default clOlive;
    property EdgeSize: Integer read FEdgeSize write SetEdgeSize;
  end;

  TSliderGetTextEvent = procedure(Sender: TSlider; var Text: string) of object;

  TSlider = class(TCustomControl)
  private
    { Images }
    FImages: TSliderImages;
    FHandCursor: HCursor;
    FRulerBmp: TBitmap;
    { Styles }
    FStyle: TSliderStyle;
    FKind: TSliderKind;
    FShowFocus: Boolean;
    FAutoSize: Boolean;
    { Values }
    FEnumValues: TStrings;
    FMinValue: Longint;
    FMaxValue: Longint;
    FIncrement: Longint;
    { Internal }
    FRealValue: Real;
    FRulerPoints: Integer;
    FHitTest: TPoint;
    FCanResize: Boolean;
    FCanDrag: Boolean;
    FActive: Boolean;
    FOnGetText: TSliderGetTextEvent;
    FOnSliderMove: TNotifyEvent;
    FOnChange: TNotifyEvent;
    { Get/Set prop. methods }
    procedure SetImages(Value: TSliderImages);
    function Ruler: TBitmap;
    function Slider: TBitmap;
    procedure SetStyle(Value: TSliderStyle);
    procedure SetKind(Value: TSliderKind);
    procedure SetRulerPoints(Value: Integer);
    procedure SetEnumValues(Value: TStrings);
    procedure SetMinValue(Value: Longint);
    procedure SetMaxValue(Value: Longint);
    procedure SetIncrement(Value: Longint);
    function GetValue: Longint;
    procedure SetValue(Value: Longint);
    { Internal methods }
    procedure ImageChanged;
    function GetImageRect: TRect;
    function GetRulerRect: TRect;
    function GetSliderRect: TRect;
    function GetCaptionRect: TRect;
    function GetValueRect: TRect;
    function GetValueStr: string;
    procedure BuildRulerBmp;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure SetRealValue(Value: Real);
    property RealValue: Real read FRealValue write SetRealValue;
  protected
    procedure Paint; override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Images: TSliderImages read FImages write SetImages stored True;
    property Style: TSliderStyle read FStyle write SetStyle
      default slHorizontal;
    property Kind: TSliderKind read FKind write SetKind default skValue;
    property ShowFocus: Boolean read FShowFocus write FShowFocus default True;
    property AutoSize: Boolean read FAutoSize write FAutoSize default True;
    property RulerPoints: Integer read FRulerPoints write SetRulerPoints;
    property EnumValues: TStrings read FEnumValues write SetEnumValues;
    property MinValue: Longint read FMinValue write SetMinValue;
    property MaxValue: Longint read FMaxValue write SetMaxValue;
    property Increment: Longint read FIncrement write SetIncrement;
    property Value: Longint read GetValue write SetValue;
    property OnGetText: TSliderGetTextEvent read FOnGetText write FOnGetText;
    property OnSliderMove: TNotifyEvent read FOnSliderMove write FOnSliderMove;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Align;
    property Caption;
    property Color;
    property Cursor;
    property DragMode;
    property DragCursor;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
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
  end;

procedure Register;

implementation

uses Forms, WinProcs, ExtConst, SysUtils, VCLUtil;

{$R *.RES}

const
  ImagesResNames: array[TSliderStyle, TSliderImage] of PChar =
    (('H_RULER', 'H_SLIDER'), ('V_RULER', 'V_SLIDER'));
  rnAD_Hand: PChar = 'AD_HAND';

function PointInRect(P: TPoint; const R: TRect): Boolean;
begin
  with R do begin
    Result := (Left <= P.X) and (Top <= P.Y) and
              (Right >= P.X) and (Bottom >= P.Y);
  end;
end;

function Max(Val1, Val2: Integer): Integer;
begin
  if Val1 > Val2 then
    Result := Val1
  else
    Result := Val2;
end;

function Min(Val1, Val2: Integer): Integer;
begin
  if Val1 < Val2 then
    Result := Val1
  else
    Result := Val2;
end;

{ TSliderImages }

constructor TSliderImages.Create;
var
  I: Integer;
begin
  inherited Create;
  for I := idxHRuler to idxVSlider do begin
    SetImage(I, nil);
  end;
  FTransparentColor := clOlive;
  FEdgeSize := 1;
end;

destructor TSliderImages.Destroy;
var
  I: TSliderStyle;
  J: TSliderImage;
begin
  for I := Low(TSliderStyle) to High(TSliderStyle) do
    for J := Low(TSliderImage) to High(TSliderImage) do
      FImages[I, J].Free;
  inherited Destroy;
end;

procedure TSliderImages.DefineProperties(Filer: TFiler);
begin
  if Filer is TReader then inherited DefineProperties(Filer);
  Filer.DefineProperty('IsCustom', ReadIsCustom, WriteIsCustom, True);
end;

procedure TSliderImages.ReadIsCustom(Reader: TReader);
var
  I: TSliderStyle;
  J: TSliderImage;
begin
  Reader.ReadListBegin;
  for I := Low(TSliderStyle) to High(TSliderStyle) do
    for J := Low(TSliderImage) to High(TSliderImage) do
      FIsCustom[I, J] := Reader.ReadBoolean;
  Reader.ReadListEnd;
end;

procedure TSliderImages.WriteIsCustom(Writer: TWriter);
var
  I: TSliderStyle;
  J: TSliderImage;
begin
  Writer.WriteListBegin;
  for I := Low(TSliderStyle) to High(TSliderStyle) do
    for J := Low(TSliderImage) to High(TSliderImage) do
      Writer.WriteBoolean(FIsCustom[I, J]);
  Writer.WriteListEnd;
end;

function TSliderImages.GetImage(Index: Integer): TBitmap;
var
  StyleIdx: TSliderStyle;
  ImageIdx: TSliderImage;
begin
  StyleIdx := TSliderStyle(Index div (Integer((High(TSliderStyle))) + 1));
  ImageIdx := TSliderImage(Index mod (Integer(High(TSliderStyle)) + 1));
  Result := FImages[StyleIdx, ImageIdx];
end;

procedure TSliderImages.SetImage(Index: Integer; Value: TBitmap);
var
  StyleIdx: TSliderStyle;
  ImageIdx: TSliderImage;
begin
  StyleIdx := TSliderStyle(Index div (Integer((High(TSliderStyle))) + 1));
  ImageIdx := TSliderImage(Index mod (Integer(High(TSliderStyle)) + 1));
  if Value = nil then begin
    if FImages[StyleIdx, ImageIdx] = nil then
      FImages[StyleIdx, ImageIdx] := TBitmap.Create;
    FImages[StyleIdx, ImageIdx].Handle := LoadBitmap(HInstance,
      ImagesResNames[StyleIdx, ImageIdx]);
  end
  else
    FImages[StyleIdx, ImageIdx].Assign(Value);
  FIsCustom[StyleIdx, ImageIdx] := (Value <> nil);
  if FSlider <> nil then FSlider.ImageChanged;
end;

procedure TSliderImages.SetTransparentColor(Value: TColor);
begin
  if FTransparentColor <> Value then begin
    FTransparentColor := Value;
    if FSlider <> nil then FSlider.ImageChanged;
  end;
end;

procedure TSliderImages.SetEdgeSize(Value: Integer);
var
  RulerWidth: Integer;
begin
  if FEdgeSize <> Value then begin
    if FSlider.Style = slHorizontal then
      RulerWidth := FSlider.Ruler.Width
    else
      RulerWidth := FSlider.Ruler.Height;
    if 2 * Value < RulerWidth then begin
      FEdgeSize := Value;
      if FSlider <> nil then FSlider.ImageChanged;
    end;
  end;
end;

{ TSlider }

constructor TSlider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csClickEvents, csDoubleClicks, csSetCaption,
                   csDesignInteractive, csOpaque];
  Width := 118;
  Height := 40;
  FImages := TSliderImages.Create;
  FImages.FSlider := Self;
  FHandCursor := LoadCursor(HInstance, rnAD_Hand);
  FRulerBmp := TBitmap.Create;
  FKind := skValue;
  FStyle := slHorizontal;
  FShowFocus := True;
  FAutoSize := True;
  FEnumValues := TStringList.Create;
  FMinValue := 1;
  FMaxValue := 100;
  FIncrement := 1;
  FRealValue := 49;
  FRulerPoints := 100;
  FCanResize := False;
  FCanDrag := False;
  TabStop := True;
  BuildRulerBmp;
end;

destructor TSlider.Destroy;
begin
  FImages.Free;
  DestroyCursor(FHandCursor);
  FRulerBmp.Free;
  FEnumValues.Free;
  inherited Destroy;
end;

procedure TSlider.Paint;
var
  DstBmp: TBitmap;
  R: TRect;

  procedure DrawImage;
  begin
    R := GetRulerRect;
    with R do
      BitBlt(DstBmp.Canvas.Handle, Left, Top, Right - Left, Bottom - Top,
             FRulerBmp.Canvas.Handle, 0, 0, SrcCopy);
    R := GetSliderRect;
    DrawBitmapTransparent(DstBmp.Canvas, R.Left, R.Top, Slider, Images.TransparentColor);
  end;

begin
  R := ClientRect;
  DstBmp := TBitmap.Create;
  try
    DstBmp.Width := R.Right - R.Left;
    DstBmp.Height := R.Bottom - R.Top;
    with DstBmp.Canvas do begin
      Brush.Style := bsSolid;
      Brush.Color := Color;
      FillRect(Rect(0, 0, DstBmp.Width, DstBmp.Height));

      DrawImage;

      Font := Self.Font;
      R := GetCaptionRect;
      TextOut(R.Left, R.Top, Caption);
      R := GetValueRect;
      TextOut(R.Left, R.Top, GetValueStr);
    end;
    if Focused and not (csDesigning in ComponentState) then begin
      R := GetImageRect;
      InflateRect(R, 3, 3);
      if ShowFocus then DstBmp.Canvas.DrawFocusRect(R);
    end;

    R := ClientRect;
    Canvas.Draw(R.Left, R.Top, DstBmp);
  finally
    DstBmp.Free;
  end;
end;

procedure TSlider.Loaded;
begin
  inherited Loaded;
  BuildRulerBmp;
end;

procedure TSlider.SetImages(Value: TSliderImages);
begin
  FImages.Assign(Value);
end;

function TSlider.Ruler: TBitmap;
begin
  if Style = slHorizontal then
    Result := Images.HRuler
  else
    Result := Images.VRuler;
end;

function TSlider.Slider: TBitmap;
begin
  if Style = slHorizontal then
    Result := Images.HSlider
  else
    Result := Images.VSlider;
end;

procedure TSlider.SetStyle(Value: TSliderStyle);
begin
  if Style <> Value then begin
    FStyle := Value;
    ImageChanged;
  end;
end;

procedure TSlider.SetKind(Value: TSliderKind);
begin
  if Kind <> Value then begin
    if Value = skEnum then begin
      FMinValue := 0;
      FIncrement := 1;
      if EnumValues.Count = 0 then
        FMaxValue := 0
      else
        FMaxValue := EnumValues.Count - 1;
    end;
    FKind := Value;
    Invalidate;
  end;
end;

procedure TSlider.SetRulerPoints(Value: Integer);
var
  SliderWidth, MaxWidth: Integer;
begin
  if FRulerPoints <> Value then begin
    if Style = slHorizontal then begin
      SliderWidth := Slider.Width;
      MaxWidth := ClientWidth;
    end
    else begin
      SliderWidth := Slider.Height;
      MaxWidth := ClientHeight;
    end;
    if (Value >= SliderWidth + 2 * Images.EdgeSize + 2) and
       (Value + 2 * Images.EdgeSize + SliderWidth + 6 <= MaxWidth ) then begin
      FRealValue := FRealValue * (Value / FRulerPoints);
      FRulerPoints := Value;
      ImageChanged;
    end;
  end;
end;

procedure TSlider.SetEnumValues(Value: TStrings);
begin
  FEnumValues.Assign(Value);
  if Kind = skEnum then begin
    FMinValue := 0;
    if EnumValues.Count = 0 then
      FMaxValue := 0
    else
      FMaxValue := EnumValues.Count - 1;
    Invalidate;
  end;
end;

procedure TSlider.SetMinValue(Value: Longint);
begin
  if FMinValue <> Value then begin
    if Value <= MaxValue then begin
      FMinValue := Value;
    end;
  end;
end;

procedure TSlider.SetMaxValue(Value: Longint);
begin
  if FMaxValue <> Value then begin
    if Value >= MinValue then begin
      FMaxValue := Value;
    end;
  end;
end;

procedure TSlider.SetIncrement(Value: Longint);
begin
  if Value > 0 then
    if FIncrement <> Value then begin
      FIncrement := Value;
      Invalidate;
    end;
end;

procedure TSlider.SetRealValue(Value: Real);
var
  ValueBefore, ValueAfter: Longint;
begin
  if FRealValue <> Value then begin
    if Value < 0 then Value := 0
    else
      if Round(Value) >= RulerPoints then Value := RulerPoints - 1;
    if Round(FRealValue) <> Value then
      if Assigned(FOnSliderMove) then FOnSliderMove(Self);
    ValueBefore := Self.Value;
    FRealValue := Value;
    ValueAfter := Self.Value;
    if ValueBefore <> ValueAfter then
      if Assigned(FOnChange) then FOnChange(Self);
    Invalidate;
  end;
end;

function TSlider.GetValue: Longint;
var
  V: Longint;
begin
  V := Round((RealValue * (MaxValue - MinValue)) / (RulerPoints - 1));
  Result := MinValue + ((V div Increment) * Increment);
end;

procedure TSlider.SetValue(Value: Longint);
begin
  if (MaxValue - MinValue = 0) then
    RealValue := 0
  else
    RealValue := ((Value - MinValue) * (RulerPoints - 1)) / (MaxValue - MinValue);
  Invalidate;
end;

procedure TSlider.ImageChanged;
begin
  BuildRulerBmp;
  Invalidate;
end;

function TSlider.GetImageRect: TRect;
var
  P: TPoint;
  ImageWidth, ImageHeight: Integer;
begin
  P := Point(3, 3);
  if Style = slHorizontal then begin
    ImageWidth := 2 * Images.EdgeSize + RulerPoints - 1 + Slider.Width;
    ImageHeight := Max(Slider.Height, Ruler.Height);
  end
  else begin
    ImageWidth := Max(Slider.Width, Ruler.Width);
    ImageHeight := 2 * Images.EdgeSize + RulerPoints - 1 + Slider.Height;
  end;
  Result := Rect(P.X, P.Y, P.X + ImageWidth, P.Y + ImageHeight);
end;

function TSlider.GetRulerRect: TRect;
var
  R: TRect;
begin
  R := GetImageRect;
  if Style = slHorizontal then begin
    Dec(R.Bottom, (R.Bottom - R.Top - Ruler.Height) div 2);
    R.Top := R.Bottom - Ruler.Height;
  end
  else begin
    Dec(R.Right, (R.Right - R.Left - Ruler.Width) div 2);
    R.Left := R.Right - Ruler.Width;
  end;
  Result := R;
end;

function TSlider.GetSliderRect: TRect;
var
  R: TRect;
begin
  R := GetImageRect;
  if Style = slHorizontal then begin
    Inc(R.Left, Images.EdgeSize + Round(RealValue));
    R.Right := R.Left + Slider.Width;
    Dec(R.Bottom, (R.Bottom - R.Top - Slider.Height) div 2);
    R.Top := R.Bottom - Slider.Height;
  end
  else begin
    Inc(R.Top, Images.EdgeSize + Round(RealValue));
    R.Bottom := R.Top + Slider.Height;
    Dec(R.Right, (R.Right - R.Left - Slider.Width) div 2);
    R.Left := R.Right - Slider.Width;
  end;
  Result := R;
end;

function TSlider.GetCaptionRect: TRect;
var
  R: TRect;
  TxtHeight: Integer;
begin
  R := GetImageRect;
  TxtHeight := FRulerBmp.Canvas.TextHeight('W');
  if Style = slHorizontal then begin
    {Result := Rect(R.Left, R.Bottom + 4, R.Right, R.Bottom + 4 + TxtHeight);}
    Result := Rect(R.Left, ClientHeight - 4 - TxtHeight, R.Right, ClientHeight - 4);
  end
  else begin
    Result := Rect(R.Right + 4, R.Top, ClientWidth, R.Top + TxtHeight);
  end;
end;

function TSlider.GetValueRect: TRect;
var
  R: TRect;
  Txt: Integer;
  S: string;
begin
  if Style = slHorizontal then begin
    R := GetCaptionRect;
    S := GetValueStr;
    Txt := FRulerBmp.Canvas.TextWidth(GetValueStr);
    Result := Rect(R.Right - Txt, R.Top, R.Right, R.Bottom);
  end
  else begin
    R := GetImageRect;
    Txt := FRulerBmp.Canvas.TextHeight('W');
    Result := Rect(R.Right + 4, R.Bottom - Txt, ClientWidth, R.Bottom);
  end;
end;

function TSlider.GetValueStr: string;
begin
  case Kind of
    skValue:
      Result := IntToStr(Value);
    skPercent:
      Result := IntToStr(Value) + '%';
    skEnum:
      if EnumValues.Count = 0 then
        Result := ''
      else
        Result := EnumValues.Strings[Value];
  end;
  if Assigned(FOnGetText) then FOnGetText(Self, Result);
end;

procedure TSlider.BuildRulerBmp;
var
  R, DstR, BmpR: TRect;
  I, L, B, N, C, Offs, Len, RulerWidth: Integer;
  TmpBmp: TBitmap;
begin
  TmpBmp := TBitmap.Create;
  try
    R := GetRulerRect;
    TmpBmp.Width := R.Right - R.Left;
    TmpBmp.Height := R.Bottom - R.Top;
    if Style = slHorizontal then begin
      L := R.Right - R.Left - 2 * Images.EdgeSize;
      B := Ruler.Width - 2 * Images.EdgeSize;
      RulerWidth := Ruler.Width;
    end
    else begin
      L := R.Bottom - R.Top - 2 * Images.EdgeSize;
      B := Ruler.Height - 2 * Images.EdgeSize;
      RulerWidth := Ruler.Height;
    end;
    N := (L div B) + 1;
    C := L mod B;
    for I := 0 to N - 1 do begin
      if I = 0 then begin
        Offs := 0;
        Len := RulerWidth - Images.EdgeSize;
      end
      else begin
        Offs := Images.EdgeSize + I * B;
        if I = N - 1 then Len := C + Images.EdgeSize
        else Len := B;
      end;
      if Style = slHorizontal then
        DstR := Rect(Offs, 0, Offs + Len, TmpBmp.Height)
      else
        DstR := Rect(0, Offs, Ruler.Width, Offs + Len);
      if I = 0 then
        Offs := 0
      else
        if I = N - 1 then
          Offs := Images.EdgeSize + B - C
        else
          Offs := Images.EdgeSize;
      if Style = slHorizontal then
        BmpR := Rect(Offs, 0, Offs + DstR.Right - DstR.Left, Ruler.Height)
      else
        BmpR := Rect(0, Offs, Ruler.Width, Offs + DstR.Bottom - DstR.Top);
      TmpBmp.Canvas.CopyRect(DstR, Ruler.Canvas, BmpR);
    end;
    with FRulerBmp do begin
      Width := TmpBmp.Width;
      Height := TmpBmp.Height;
      Canvas.Font := Font;
      Canvas.Brush.Color := Color;
      Canvas.FillRect(Rect(0, 0, Width, Height));
    end;
    DrawBitmapTransparent(FRulerBmp.Canvas, 0, 0, TmpBmp, Images.TransparentColor);
  finally
    TmpBmp.Free;
  end;
end;

procedure TSlider.WMSize(var Message: TWMSize);
var
  SliderWidth, CtrlWidth: Integer;
begin
  inherited;
  if not (csReading in ComponentState) then begin
    if AutoSize then begin
      if Style = slHorizontal then begin
        SliderWidth := Slider.Width;
        CtrlWidth := ClientWidth;
      end
      else begin
        SliderWidth := Slider.Height;
        CtrlWidth := ClientHeight;
      end;
      RulerPoints := CtrlWidth - 6 - SliderWidth - (2 * Images.EdgeSize);
    end;
  end;
end;

procedure TSlider.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;
  FHitTest := SmallPointToPoint(Msg.Pos);
  FHitTest := ScreenToClient(FHitTest);
end;

procedure TSlider.WMSetCursor(var Msg: TWMSetCursor);
var
  Cur: HCURSOR;
  R: TRect;
begin
  Cur := 0;
  FCanResize := False;
  FCanDrag := False;
  with Msg do begin
    if HitTest = HTCLIENT then begin
      R := GetSliderRect;
      if not FCanResize and PointInRect(FHitTest, R) then begin
        Cur := FHandCursor;
        FCanDrag := True;
      end
      else begin
        if csDesigning in ComponentState then begin
          R := GetRulerRect;
          if Style = slHorizontal then begin
            R.Left := R.Right - 2;
            R.Right := R.Right + 2;
          end
          else begin
            R.Top := R.Bottom - 2;
            R.Bottom := R.Bottom + 2;
          end;
          if not FCanDrag and PointInRect(FHitTest, R) then begin
            if Style = slHorizontal then
              Cur := LoadCursor(0, IDC_SIZEWE)
            else
              Cur := LoadCursor(0, IDC_SIZENS);
            FCanResize := True;
          end;
        end;
      end;
    end;
  end;
  if Cur = 0 then inherited
  else SetCursor(Cur);
end;

procedure TSlider.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if ((csDesigning in ComponentState) and
      (Button = mbRight)) or (Button = mbLeft) then
    if FCanResize or FCanDrag then begin
      SetCapture(Handle);
    end;
end;

procedure TSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  OrgPos, ActPos, SliderWidth: Integer;
  R1: TRect;
begin
  inherited MouseMove(Shift, X, Y);
  if (GetCapture = Handle) then begin
    R1 := GetImageRect;
    if Style = slHorizontal then begin
      ActPos := X;
      OrgPos := R1.Left;
      SliderWidth := Slider.Width;
    end
    else begin
      ActPos := Y;
      OrgPos := R1.Top;
      SliderWidth := Slider.Height;
    end;
    if FCanResize then begin
      RulerPoints := ActPos - OrgPos - 2 * Images.EdgeSize - SliderWidth;
    end;
    if FCanDrag then begin
      RealValue := ActPos - (SliderWidth div 2) - OrgPos - Images.EdgeSize;
    end;
  end;
end;

procedure TSlider.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Form: TForm;
begin
  if FCanResize or FCanDrag then begin
    ReleaseCapture;
    if csDesigning in ComponentState then begin
      Form := GetParentForm(Self);
      if Form <> nil then
        Form.Designer.Modified;
    end;
    FCanResize := False;
    FCanDrag := False;
  end;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TSlider.KeyDown(var Key: Word; Shift: TShiftState);
var
  Offs: Integer;
begin
  inherited KeyDown(Key, Shift);
  Offs := 0;
  case Key of
    VK_LEFT:
      if Style = slHorizontal then Offs := -1;
    VK_RIGHT:
      if Style = slHorizontal then Offs := 1;
    VK_UP:
      if Style = slVertical then Offs := -1;
    VK_DOWN:
      if Style = slVertical then Offs := 1;
    VK_PRIOR:
      Offs := -3;
    VK_NEXT:
      Offs := 3;
  end;
  RealValue := RealValue + Offs;
end;

procedure TSlider.CMFocusChanged(var Message: TCMFocusChanged);
var
  Active: Boolean;
begin
  with Message do Active := (Sender = Self);
  if Active <> FActive then begin
    FActive := Active;
    Invalidate;
  end;
  inherited;
end;

procedure TSlider.CMTextChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TSlider.CMColorChanged(var Message: TMessage);
begin
  inherited;
  ImageChanged;
end;

procedure TSlider.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ImageChanged;
end;

procedure Register;
begin
  RegisterComponents(GetExtStr(srGadgets), [TSlider]);
end;

end.
