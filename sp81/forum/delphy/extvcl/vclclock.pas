{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
unit VCLClock;

interface

uses WinTypes, WinProcs, SysUtils, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls, ExtCtrls, Menus;

type

  TShowClock = (scDigital, scAnalog);
  TPaintMode = (pmPaintAll, pmHandPaint);
  THourEnum = 0..23;
  TMinSecEnum = 0..59;

{ TClock }

  TClock = class(TCustomPanel)
  private
    { Private declarations }
    FTimer: TTimer;
    FAutoSize: Boolean;
    FShowMode: TShowClock;
    FAlarm: TDateTime;
    FAlarmEnabled: Boolean;
    FAlarmWait: Boolean;
    FOnAlarm: TNotifyEvent;
    FAnalogLoaded: Boolean;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure TimerExpired(Sender: TObject);
    function IsAlarmTime(ATime: TDateTime): Boolean;
    procedure SetShowMode(Value: TShowClock);
    function GetAlarmElement(Index: Integer): Byte;
    procedure SetAlarmElement(Index: Integer; Value: Byte);
    procedure SetAutoSize(Value: Boolean);
    procedure PaintAnalogClock(PaintMode: TPaintMode);
    procedure Paint3DFrame;
    procedure PaintTimeStr(var Rect: TRect; AFull: Boolean);
    procedure ResizeFont(const Rect: TRect);
    procedure ResetAlarm;
  protected
    { Protected declarations }
    procedure Alarm; dynamic;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure Loaded; override;
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetAlarmTime(AlarmTime: TDateTime);
  published
    { Published declarations }
    property Align;
    property AlarmEnabled: Boolean read FAlarmEnabled write FAlarmEnabled;
    property AlarmHour: Byte index 1 read GetAlarmElement write SetAlarmElement;
    property AlarmMinute: Byte index 2 read GetAlarmElement write SetAlarmElement;
    property AlarmSecond: Byte index 3 read GetAlarmElement write SetAlarmElement;
    property AutoSize: Boolean read FAutoSize write SetAutoSize;
    property BevelInner default bvLowered;
    property BevelOuter default bvRaised;
    property BevelWidth;
    property BorderWidth;
    property BorderStyle;
    property Color;
    property Ctl3D;
    property Cursor;
    property DragMode;
    property DragCursor;
    property Font;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowMode: TShowClock read FShowMode write SetShowMode;
    property ShowHint;
    property OnAlarm: TNotifyEvent read FOnAlarm write FOnAlarm;
    property OnClick;
    property OnDblClick;
    property OnMouseMove;
    property OnMouseDown;
    property OnMouseUp;
    property OnDragOver;
    property OnDragDrop;
    property OnEndDrag;
    property OnResize;
  end;

implementation

const
  AlarmSecDelay = 60; { seconds for try alarm event after alarm time occured }

{ Exception routine }

const
  SInvalidTime = 65411; { from SYSUTILS.INC }

procedure InvalidTime(Hour, Min, Sec: Word);
var
  sTime: string[50];
begin
  sTime := IntToStr(Hour) + TimeSeparator + IntToStr(Min) +
    TimeSeparator + IntToStr(Sec);
  raise EConvertError.Create(FmtLoadStr(SInvalidTime, [sTime]));
end;

{ Common routine }

type
  TClockTime = record
    hour: Integer;
    minute: Integer;
    second: Integer;
  end;

procedure GetTime(var T: TClockTime); assembler;
asm
      mov     ax,2c00h    {get time}
      int     21h
      cmp     ch,12       {if hour < 12}
      jl      @@1         {we're ok}
      sub     ch,12       {else adjust it}
@@1:  xor     ax,ax
      mov     al,ch
      les     bx,T
      mov     es:[bx].TClockTime.hour,ax
      mov     al,cl
      mov     es:[bx].TClockTime.minute,ax
      mov     al,dh
      mov     es:[bx].TClockTime.second,ax
end;

{ Analog clock constants and routines }

{$R CLOCKDAT.RES}

type
  TArrPoint = array [0..60 * 2 - 1] of TPoint;

const
  Ids_Clock = 'PCLOCK'; { resource name }

const
  MaxDotWidth   = 25; { maximum hour-marking dot width  }
  MinDotWidth   = 2;  { minimum hour-marking dot width  }
  MinDotHeight  = 1;  { minimum hour-marking dot height }

  { hand flags }
  HHand = True;
  MHand = False;

  { distance from the center of the clock to... }
  HourSide   = 7;   { ...either side of the hour hand   }
  MinuteSide = 5;   { ...either side of the minute hand }
  HourTip    = 65;  { ...the tip of the hour hand       }
  MinuteTip  = 80;  { ...the tip of the minute hand     }
  SecondTip  = 80;  { ...the tip of the second hand     }
  HourTail   = 15;  { ...the tail of the hour hand      }
  MinuteTail = 20;  { ...the tail of the minute hand    }

  { conversion factors }
  CirTabScale = 8000; { circle table values scale down value  }
  MmPerDm     = 100;  { millimeters per decimeter             }

  { number of hand positions on... }
  HandPositions = 60;                    { ...entire clock         }
  SideShift     = (HandPositions div 4); { ... 90 degrees of clock }
  TailShift     = (HandPositions div 2); { ...180 degrees of clock }

var
  oTime: TClockTime;   { the time currently displayed on the clock }
  nTime: TClockTime;

  hCirTab: THandle;     { Circle table for the circular clock face positions }
  lpCirTab: ^TArrPoint; { Pointer to the circle table }

  ClockRect: TRect;     { rectangle that EXACTLY bounds the clock face }
  ClockRadius: Longint; { clock face radius }
  ClockCenter: TPoint;  { clock face center }

  HRes: Integer;    { width of the display (in pixels)                    }
  VRes: Integer;    { height of the display (in raster lines)             }
  AspectH: Longint; { number of pixels per decimeter on the display       }
  AspectV: Longint; { number of raster lines per decimeter on the display }

function VertEquiv(l : Integer) : Integer;
begin
  VertEquiv := Longint(l) * AspectV div AspectH;
end;

function HorzEquiv(l : Integer) : Integer;
begin
  HorzEquiv := Longint(l) * AspectH div AspectV;
end;

procedure ClockCreate;
var
  pos: Integer;   { hand position index into the circle table }
  vSize: Integer; { height of the display in millimeters      }
  hSize: Integer; { width of the display in millimeters       }
  DC: HDC;
  rc: TRect;
begin
  DC := GetDC(0);
  VRes := GetDeviceCaps(DC, VERTRES);
  HRes := GetDeviceCaps(DC, HORZRES);
  vSize := GetDeviceCaps(DC, VERTSIZE);
  hSize := GetDeviceCaps(DC, HORZSIZE);
  ReleaseDC(0, DC);
  AspectV := (Longint(VRes) * MmPerDm) div Longint(vSize);
  AspectH := (Longint(HRes) * MmPerDm) div Longint(hSize);
  pos := 0;
  while pos < HandPositions do begin
    lpCirTab^[pos].y := VertEquiv(lpCirTab^[pos].y);
    Inc(pos);
  end;
  GetTime(nTime);
  GetTime(oTime);
  while ((nTime.second = oTime.second) and (nTime.minute = oTime.minute) and
    (nTime.hour   = oTime.hour)) do GetTime(oTime);
end;

function ClockInit: Boolean;
var
  hResource : THandle;
begin
  ClockInit := False;
  hResource := FindResource(hInstance, Ids_Clock, 'DATA');
  if hResource = 0 then Exit;
  hCirTab := LoadResource(hInstance, hResource);
  lpCirTab := LockResource(hCirTab);
  ClockCreate;
  ClockInit := True;
end;

procedure ClockDone;
begin
  UnlockResource(hCirTab);
  FreeResource(hCirTab);
end;

function HourHandPos(T : TClockTime) : Integer;
begin
  HourHandPos := (T.hour * 5) + (T.minute div 12);
end;

procedure CircleClock(maxWidth, maxHeight: Integer);
var
  ClockHeight: Integer;
  ClockWidth: Integer;
begin
  if maxWidth > HorzEquiv(maxHeight) then begin
    ClockWidth := HorzEquiv(maxHeight);
    ClockRect.left := ClockRect.left + ((maxWidth - ClockWidth) div 2);
    ClockRect.right := ClockRect.left + ClockWidth;
  end
  else begin
    ClockHeight := VertEquiv(maxWidth);
    ClockRect.top := ClockRect.top + ((maxHeight - ClockHeight) div 2);
    ClockRect.bottom := ClockRect.top + ClockHeight;
  end;
end;

procedure ClockSize(const Rect: TRect); { WM_SIZE }
begin
  ClockRect := Rect;
  CircleClock(Rect.right - Rect.left, Rect.bottom - Rect.top);
end;

{ Analog clock drawing routines }

procedure DrawFace(Canvas: TCanvas);
var
  pos: Integer;
  dotHeight: Integer;
  dotWidth: Integer;
  dotCenter: TPoint;
  rc: TRect;
  Safer: TColor;
begin
  dotWidth := (MaxDotWidth * Longint(ClockRect.right -
    ClockRect.left)) div HRes;
  dotHeight := VertEquiv(dotWidth);
  if dotHeight < MinDotHeight then dotHeight := MinDotHeight;
  if dotWidth < MinDotWidth then dotWidth := MinDotWidth;
  dotCenter.x := dotWidth div 2;
  dotCenter.y := dotHeight div 2;
  InflateRect(ClockRect, -dotCenter.y, -dotCenter.x);
  ClockRadius := ((ClockRect.right - ClockRect.left) div 2);
  ClockCenter.x := ClockRect.left + ClockRadius;
  ClockCenter.y := ClockRect.top + ((ClockRect.bottom -
    ClockRect.top) div 2);
  InflateRect(ClockRect, dotCenter.y, dotCenter.x);
  Safer := Canvas.Brush.Color;
  Canvas.Brush.Color := Canvas.Pen.Color;
  for pos := 0 to HandPositions - 1 do begin
    rc.top := (lpCirTab^[pos].y * ClockRadius) div CirTabScale +
      ClockCenter.y;
    rc.left := (lpCirTab^[pos].x * ClockRadius) div CirTabScale +
      ClockCenter.x;
    if (pos mod 5) <> 0 then begin
      if ((dotWidth > MinDotWidth) and (dotHeight > MinDotHeight)) then
      begin
        rc.right := rc.left + 1;
        rc.bottom := rc.top + 1;
        Canvas.FillRect(rc);
      end;
    end
    else begin
      rc.right := rc.left + dotWidth;
      rc.bottom := rc.top + dotHeight;
      OffsetRect(rc, -dotCenter.x, -dotCenter.y);
      Canvas.FillRect(rc);
    end;
  end;
  Canvas.Brush.Color := Safer;
end;

procedure DrawSecondHand(Canvas: TCanvas; Pos: Integer);
var
  Radius: Longint;
begin
  Radius := (ClockRadius * SecondTip) div 100;
  SetRop2(Canvas.Handle, R2_NOT);
  Canvas.MoveTo(ClockCenter.x, ClockCenter.y);
  Canvas.LineTo(ClockCenter.x + ((lpCirTab^[pos].x * radius) div CirTabScale),
    ClockCenter.y + ((lpCirTab^[pos].y * radius) div CirTabScale));
end;

procedure DrawFatHand(Canvas: TCanvas; Pos: Integer; WhichHand: Bool);
var
  ptSide, ptTail, ptTip: TPoint;
  index, Hand: Integer;
  Scale: Longint;
begin
  SetROP2(Canvas.Handle, R2_COPYPEN);
  if WhichHand then Hand := HourSide
  else Hand := MinuteSide;
  Scale := (ClockRadius * Hand) div 100;
  Index := (Pos + SideShift) mod HandPositions;
  ptSide.y := (lpCirTab^[index].y * scale) div CirTabScale;
  ptSide.x := (lpCirTab^[index].x * scale) div CirTabScale;
  if WhichHand then Hand := HourTip
  else Hand := MinuteTip;
  Scale := (ClockRadius * Hand) div 100;
  ptTip.y := (lpCirTab^[pos].y * scale) div CirTabScale;
  ptTip.x := (lpCirTab^[pos].x * scale) div CirTabScale;
  if WhichHand then Hand := HourTail
  else Hand := MinuteTail;
  scale := (ClockRadius * Hand) div 100;
  index := (pos + TailShift) mod HandPositions;
  ptTail.y := (lpCirTab^[index].y * scale) div CirTabScale;
  ptTail.x := (lpCirTab^[index].x * scale) div CirTabScale;
  with Canvas do begin
    MoveTo(ClockCenter.x + ptSide.x, ClockCenter.y + ptSide.y);
    LineTo(ClockCenter.x + ptTip.x, ClockCenter.y + ptTip.y);
    MoveTo(ClockCenter.x - ptSide.x, ClockCenter.y - ptSide.y);
    LineTo(ClockCenter.x + ptTip.x, ClockCenter.y + ptTip.y);
    MoveTo(ClockCenter.x + ptSide.x, ClockCenter.y + ptSide.y);
    LineTo(ClockCenter.x + ptTail.x, ClockCenter.y + ptTail.y);
    MoveTo(ClockCenter.x - ptSide.x, ClockCenter.y - ptSide.y);
    LineTo(ClockCenter.x + ptTail.x, ClockCenter.y + ptTail.y);
  end;
end;

procedure ClockPaint(Canvas: TCanvas; paintType: TPaintMode);
var
  nTime: TClockTime;
begin
  SetBkMode(Canvas.Handle, TRANSPARENT);
  if paintType = pmPaintAll then begin
    with Canvas do begin
      FillRect(ClockRect);
      Pen.Color := Font.Color;
      DrawFace(Canvas);
      DrawFatHand(Canvas, HourHandPos(oTime), HHand);
      DrawFatHand(Canvas, oTime.minute, MHand);
      Pen.Color := Brush.Color;
      DrawSecondHand(Canvas, oTime.second);
    end;
  end
  else begin
    with Canvas do begin
      Pen.Color := Brush.Color;
      GetTime(nTime);
      if (nTime.second <> oTime.second) then
        DrawSecondHand(Canvas, oTime.second);
      if ((nTime.minute <> oTime.minute) or (nTime.hour <> oTime.hour)) then
      begin
        DrawFatHand(Canvas, oTime.minute, MHand);
        DrawFatHand(Canvas, HourHandPos(oTime), HHand);
        Pen.Color := Font.Color;
        DrawFatHand(Canvas, nTime.minute, MHand);
        DrawFatHand(Canvas, HourHandPos(nTime), HHand);
      end;
      Pen.Color := Brush.Color;
      if (nTime.second <> oTime.second) then begin
        DrawSecondHand(Canvas, nTime.second);
        oTime.minute := nTime.minute;
        oTime.hour   := nTime.hour;
        oTime.second := nTime.second;
      end;
    end;
  end;
end;

{ Digital clock font routine }

procedure SetNewFontSize(Canvas: TCanvas; MaxH, MaxW: Integer);
const
  fHeight = 1000;
var
  Font: TFont;
  NewH: Integer;
  Metrics: TTextMetric;
begin
  Font := Canvas.Font;
  { empiric calculate character height by cell height }
  MaxH := MulDiv(MaxH, 4, 5);
  with Font do begin
    Height := -fHeight;
    NewH := MulDiv(fHeight, MaxW, LoWord(GetTextExtent(Canvas.Handle,
      '8', 1)));
    if NewH > MaxH then NewH := MaxH;
    Height := -NewH;
  end;
end;

{ TClock class }

constructor TClock.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := TimeToStr(Time);
  BevelOuter := bvRaised;
  BevelInner := bvLowered;
  FTimer := TTimer.Create(Self);
  FTimer.OnTimer := TimerExpired;
  FTimer.Interval := 450; { every second }
  FTimer.Enabled := True;
  FAnalogLoaded := ClockInit;
  FAlarmWait := True;
end;

destructor TClock.Destroy;
begin
  if FAnalogLoaded then ClockDone;
  inherited Destroy;
end;

procedure TClock.Loaded;
begin
  inherited Loaded;
  ResetAlarm;
end;

procedure TClock.CMTextChanged(var Message: TMessage);
begin
  {Skip this message, no repaint}
end;

procedure TClock.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if FAutoSize then Realign;
end;

procedure TClock.ResetAlarm;
begin
  FAlarmWait := FAlarm > Time;
end;

function TClock.IsAlarmTime(ATime: TDateTime): Boolean;
var
  Hour, Min, Sec, MSec: Word;
  AHour, AMin, ASec: Word;
begin
  DecodeTime(FAlarm, Hour, Min, Sec, MSec);
  DecodeTime(ATime, AHour, AMin, ASec, MSec);
  IsAlarmTime := FAlarmWait and (Hour = AHour) and (Min = AMin) and
    (ASec >= Sec) and (ASec <= Sec + AlarmSecDelay);
end;

procedure TClock.ResizeFont(const Rect: TRect);
var
  H, W: Integer;
  DC: HDC;
begin
  H := Rect.Bottom - Rect.Top - 4;
  W := (Rect.Right - Rect.Left - 30) shr 3;
  if (H <= 0) or (W <= 0) then Exit;
  DC := GetDC(0);
  try
    Canvas.Handle := DC;
    Canvas.Font := Font;
    SetNewFontSize(Canvas, H, W);
    Font := Canvas.Font;
  finally
    Canvas.Handle := 0;
    ReleaseDC(0, DC);
  end;
end;

procedure TClock.AlignControls(AControl: TControl; var Rect: TRect);
begin
  inherited AlignControls(AControl, Rect);
  ClockSize(Rect);
  if FAutoSize then ResizeFont(Rect);
end;

procedure TClock.Alarm;
begin
  if Assigned(FOnAlarm) then FOnAlarm(Self);
end;

procedure TClock.SetAutoSize(Value: Boolean);
begin
  if (Value <> FAutoSize) then
  begin
    FAutoSize := Value;
    if FAutoSize then begin
      Invalidate;
      Realign;
    end;
  end;
end;

procedure TClock.SetShowMode(Value: TShowClock);
begin
  if FShowMode <> Value then begin
    if Value = scAnalog then begin
      if FAnalogLoaded then FShowMode := Value;
    end
    else FShowMode := Value;
    Invalidate;
  end;
end;

function TClock.GetAlarmElement(Index: Integer): Byte;
var
  Hour, Min, Sec, MSec: Word;
begin
  DecodeTime(FAlarm, Hour, Min, Sec, MSec);
  case Index of
    1: Result := Hour;
    2: Result := Min;
    3: Result := Sec;
    else Result := 0;
  end;
end;

procedure TClock.SetAlarmElement(Index: Integer; Value: Byte);
var
  Hour, Min, Sec, MSec: Word;
begin
  DecodeTime(FAlarm, Hour, Min, Sec, MSec);
  case Index of
    1: Hour := Value;
    2: Min := Value;
    3: Sec := Value;
    else Exit;
  end;
  if (Hour < 24) and (Min < 60) and (Sec < 60) then begin
    FAlarm := EncodeTime(Hour, Min, Sec, 0);
    ResetAlarm;
  end
  else InvalidTime(Hour, Min, Sec);
end;

procedure TClock.SetAlarmTime(AlarmTime: TDateTime);
var
  Hour, Min, Sec, MSec: Word;
begin
  DecodeTime(FAlarm, Hour, Min, Sec, MSec);
  if (Hour < 24) and (Min < 60) and (Sec < 60) then begin
    FAlarm := AlarmTime;
    ResetAlarm;
  end
  else InvalidTime(Hour, Min, Sec);
end;

procedure TClock.TimerExpired(Sender: TObject);
var
  DC: HDC;
  Rect: TRect;
  InflateWidth: Integer;
begin
  DC := GetDC(Handle);
  try
    Canvas.Handle := DC;
    Canvas.Brush.Color := Color;
    Canvas.Font := Font;
    Canvas.Pen.Color := Font.Color;
    if FShowMode = scAnalog then
      PaintAnalogClock(pmHandPaint)
    else begin
      Rect := GetClientRect;
      InflateWidth := BorderWidth;
      if BevelOuter <> bvNone then Inc(InflateWidth, BevelWidth);
      if BevelInner <> bvNone then Inc(InflateWidth, BevelWidth);
      InflateRect(Rect, -InflateWidth, -InflateWidth);
      PaintTimeStr(Rect, False);
    end;
  finally
    Canvas.Handle := 0;
    ReleaseDC(Handle, DC);
  end;
  if FAlarmEnabled and IsAlarmTime(Time) then begin
    FAlarmWait := False;
    Alarm;
  end
  else ResetAlarm;
end;

procedure TClock.PaintAnalogClock(PaintMode: TPaintMode);
begin
  if not FAnalogLoaded then Exit;
  Canvas.Pen.Color := Font.Color;
  Canvas.Brush.Color := Color;
  ClockPaint(Canvas, PaintMode);
end;

procedure TClock.PaintTimeStr(var Rect: TRect; AFull: Boolean);
var
  FontHeight, FontWidth, I: Integer;
  TimeStr: string[8];
  nTime: TClockTime;

  procedure DrawSym(Sym: Char; Num: Byte);
  var
    Draw: Boolean;
  begin
    case Num of
      1,2: Draw := AFull or (nTime.hour <> oTime.hour);
      3,6: Draw := AFull;
      4,5: Draw := AFull or (nTime.minute <> oTime.minute);
      7,8: Draw := AFull or (nTime.second <> oTime.second);
    end;
    if Draw then begin
      Canvas.FillRect(Rect);
      WinProcs.DrawText(Canvas.Handle, @Sym, 1, Rect, DT_EXPANDTABS or
        DT_VCENTER or DT_CENTER or DT_NOCLIP or DT_SINGLELINE);
    end;
  end;

begin
  GetTime(nTime);
  DateTimeToString(TimeStr, 'HH' + TimeSeparator + 'MM' +
    TimeSeparator + 'SS', Time);
  with Canvas do begin
    Font := Self.Font;
    FontHeight := TextHeight('8');
    FontWidth := TextWidth('8');
    with Rect do begin
      Left := ((Right + Left) - FontWidth shl 3) shr 1;
      Right := Left + FontWidth shl 3;
      Top := ((Bottom + Top) - FontHeight) shr 1;
      Bottom := Top + FontHeight;
    end;
    Brush.Color := Color;
    for I := 1 to Length(TimeStr) do begin
      Rect.Right := Rect.Left + FontWidth;
      DrawSym(TimeStr[I], I);
      Inc(Rect.Left, FontWidth);
    end;
  end;
  oTime.minute := nTime.minute;
  oTime.hour   := nTime.hour;
  oTime.second := nTime.second;
end;

procedure TClock.Paint3DFrame;
var
  Rect: TRect;
  TopColor, BottomColor: TColor;

  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    TopColor := clBtnHighlight;
    if Bevel = bvLowered then TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if Bevel = bvLowered then BottomColor := clBtnHighlight;
  end;

begin
  Rect := GetClientRect;
  if BevelOuter <> bvNone then
  begin
    AdjustColors(BevelOuter);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  InflateRect(Rect, -BorderWidth, -BorderWidth);
  if BevelInner <> bvNone then
  begin
    AdjustColors(BevelInner);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  with Canvas do
  begin
    Brush.Color := Color;
    FillRect(Rect);
    if FShowMode = scDigital then
      PaintTimeStr(Rect, True);
  end;
end;

procedure TClock.Paint;
begin
  Paint3DFrame;
  if FShowMode = scAnalog then begin
    PaintAnalogClock(pmPaintAll);
  end;
end;

end.
