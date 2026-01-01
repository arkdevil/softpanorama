{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
unit Animate;

interface

uses SysUtils, Messages, WinTypes, WinProcs, Classes, Graphics, Controls, 
  Forms, StdCtrls, ExtCtrls, Menus;

type

{ TAnimateImage }

  TAnimateImage = class(TCustomControl)
  private
    { Private declarations }
    FActive: Boolean;
    FAutoSize: Boolean;
    FGlyph: TBitmap;
    FOnStart: TNotifyEvent;
    FOnStop: TNotifyEvent;
    FTimer: TTimer;
    FImageWidth: Integer;
    FImageHeight: Integer;
    FNumGlyphs: Integer;
    FGlyphNum: Integer;
    FTransparentColor: TColor;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure DefineBitmapSize;
    procedure ResetImageWidth;
    procedure AdjustBounds;
    function GetInterval: Word;
    procedure SetAutoSize(Value: Boolean);
    procedure SetInterval(Value: Word);
    procedure SetActive(Value: Boolean);
    procedure SetGlyph(Value: TBitmap);
    procedure SetGlyphNum(Value: Integer);
    procedure SetNumGlyphs(Value: Integer);
    procedure SetTransparentColor(Value: TColor);
    procedure TimerExpired(Sender: TObject);
    procedure PaintGlyph;
  protected
    { Protected declarations }
    procedure Loaded; override;
    procedure Paint; override;
    procedure Start; dynamic;
    procedure Stop; dynamic;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Active: Boolean read FActive write SetActive;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default True;
    property Glyph: TBitmap read FGlyph write SetGlyph;
    property GlyphNum: Integer read FGlyphNum write SetGlyphNum;
    property Interval: Word read GetInterval write SetInterval default 100;
    property NumGlyphs: Integer read FNumGlyphs write SetNumGlyphs default 1;
    property TransparentColor: TColor read FTransparentColor write SetTransparentColor
      default clOlive;
    property Cursor;
    property DragMode;
    property DragCursor;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
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
    property OnStart: TNotifyEvent read FOnStart write FOnStart;
    property OnStop: TNotifyEvent read FOnStop write FOnStop;
  end;

implementation

const
{ see TBitmap.GetTransparentColor in GRAPHICS.PAS }
  TransparentMask = $02000000;

{ TAnimateImage }

constructor TAnimateImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csClickEvents, csSetCaption, csCaptureMouse,
    csOpaque, csDoubleClicks];
  FTimer := TTimer.Create(Self);
  Interval := 100;
  FGlyph := TBitmap.Create;
  FGlyphNum := 0;
  FNumGlyphs := 1;
  FTransparentColor := clOlive;
  FAutoSize := True;
  Width := 32;
  Height := 32;
end;

destructor TAnimateImage.Destroy;
begin
  Active := False;
  FGlyph.Free;
  inherited Destroy;
end;

procedure TAnimateImage.Loaded;
begin
  inherited Loaded;
  ResetImageWidth;
end;

procedure TAnimateImage.WMSize(var Message: TWMSize);
begin
  inherited;
  AdjustBounds;
end;

procedure TAnimateImage.SetTransparentColor(Value: TColor);
begin
  if Value <> TransparentColor then begin
    FTransparentColor := Value;
    Invalidate;
  end;
end;

procedure TAnimateImage.SetGlyph(Value: TBitmap);
begin
  FGlyph.Assign(Value);
  FTransparentColor := Value.TransparentColor and not TransparentMask;
  DefineBitmapSize;
  AdjustBounds;
  Invalidate;
end;

procedure TAnimateImage.SetGlyphNum(Value: Integer);
begin
  if Value <> FGlyphNum then begin
    if (Value < FNumGlyphs) and (Value >= 0) then begin
      FGlyphNum := Value;
      Invalidate;
    end;
  end;
end;

procedure TAnimateImage.SetNumGlyphs(Value: Integer);
begin
  FNumGlyphs := Value;
  FGlyphNum := 0;
  ResetImageWidth;
  AdjustBounds;
  Invalidate;
end;

procedure TAnimateImage.DefineBitmapSize;
begin
  FImageHeight := 0;
  FNumGlyphs := 0;
  FImageWidth := 0;
  FGlyphNum := 0;
  if FGlyph.Handle > 0 then begin
    FNumGlyphs := FGlyph.Width div FGlyph.Height;
    ResetImageWidth;
  end;
end;

procedure TAnimateImage.ResetImageWidth;
begin
  FImageHeight := FGlyph.Height;
  if FNumGlyphs = 0 then FNumGlyphs := 1;
  if FNumGlyphs = 1 then
    FImageWidth := FGlyph.Width
  else
    FImageWidth := FGlyph.Width div FNumGlyphs;
end;

procedure TAnimateImage.AdjustBounds;
begin
  if not (csReading in ComponentState) then begin
    if FAutoSize and (FImageWidth > 0) and (FImageHeight > 0) then
    begin
      SetBounds(Left, Top, FImageWidth + 2, FImageHeight + 2);
    end;
  end;
end;

procedure TAnimateImage.PaintGlyph;
var
  IRect, SrcRect: TRect;
  TmpImage: TBitmap;
begin
  if FGlyph.Handle > 0 then begin
    TmpImage := TBitmap.Create;
    try
      with TmpImage do begin
        Width := FImageWidth;
        Height := FImageHeight;
        IRect := Bounds(0, 0, Width, Height);
        SrcRect := Bounds(FGlyphNum * FImageWidth, 0, FImageWidth,
          FImageHeight);
        Canvas.Brush.Color := Self.Color;
        Canvas.BrushCopy(IRect, FGlyph, SrcRect, FTransparentColor or
          TransparentMask);
      end;
      IRect := GetClientRect;
      InflateRect(IRect, -1, -1);
      Canvas.StretchDraw(IRect, TmpImage);
    finally
      TmpImage.Free;
    end;
  end;
end;

procedure TAnimateImage.Paint;
begin
  Canvas.Brush.Color := Self.Color;
  if (csDesigning in ComponentState) then
    with Canvas do begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;
  PaintGlyph;
end;

procedure TAnimateImage.TimerExpired(Sender: TObject);
var
  DC: HDC;
begin
  if FGlyphNum < (FNumGlyphs - 1) then Inc(FGlyphNum)
  else FGlyphNum := 0;
  DC := GetDC(Handle);
  Canvas.Handle := DC;
  try
    PaintGlyph;
  finally
    Canvas.Handle := 0;
    ReleaseDC(Handle, DC);
  end;
end;

procedure TAnimateImage.Stop;
begin
  if Assigned(FOnStop) then FOnStop(Self);
end;

procedure TAnimateImage.Start;
begin
  if Assigned(FOnStart) then FOnStart(Self);
end;

procedure TAnimateImage.SetAutoSize(Value: Boolean);
begin
  if Value <> FAutoSize then begin
    FAutoSize := Value;
    AdjustBounds;
    Invalidate;
  end;
end;

procedure TAnimateImage.SetInterval(Value: Word);
begin
  FTimer.Interval := Value;
end;

function TAnimateImage.GetInterval: Word;
begin
  Result := FTimer.Interval;
end;

procedure TAnimateImage.SetActive(Value: Boolean);
begin
  if FActive <> Value then begin
    if Value then begin
      try
        FTimer.OnTimer := TimerExpired;
        FTimer.Enabled := True;
        FActive := FTimer.Enabled;
        Start;
      except
        raise;
      end;
    end
    else begin
      FTimer.Enabled := False;
      FTimer.OnTimer := nil;
      FActive := False;
      Stop;
    end;
  end;
end;

end.