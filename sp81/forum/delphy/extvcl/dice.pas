{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
unit Dice;

interface

uses SysUtils, Messages, WinTypes, WinProcs, Classes, Graphics, 
  Controls, Forms, StdCtrls, ExtCtrls, Menus;

type

  TDiceValue = 1..6;

{ TDice }

  TDice = class(TCustomControl)
  private
    { Private declarations }
    FActive: Boolean;
    FAutoSize: Boolean;
    FBitmap: TBitmap;
    FInterval: Word;
    FOnChange: TNotifyEvent;
    FRotate: Boolean;
    FShowFocus: Boolean;
    FTimer: TTimer;
    FValue: TDiceValue;
    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure AdjustBounds;
    procedure CreateBitmap;
    procedure SetAutoSize(Value: Boolean);
    procedure SetInterval(Value: Word);
    procedure SetRotate(Value: Boolean);
    procedure SetShowFocus(Value: Boolean);
    procedure SetValue(Value: TDiceValue);
    procedure TimerExpired(Sender: TObject);
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure Change; dynamic;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RandomValue;
  published
    { Published declarations }
    property AutoSize: Boolean read FAutoSize write SetAutoSize default True;
    property Color;
    property Cursor;
    property DragMode;
    property DragCursor;
    property Interval: Word read FInterval write SetInterval default 60;
    property ParentColor;
    property ParentShowHint;
    property PopupMenu;
    property Rotate: Boolean read FRotate write SetRotate;
    property ShowFocus: Boolean read FShowFocus write SetShowFocus;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Value: TDiceValue read FValue write SetValue default 1;
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
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

{$R *.RES}

const
  ResName: array [TDiceValue] of PChar = ('DICE1', 'DICE2', 'DICE3', 
    'DICE4', 'DICE5', 'DICE6');

{ TDice }

constructor TDice.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Randomize;
  ControlStyle := [csClickEvents, csSetCaption, csCaptureMouse,
    csOpaque, csDoubleClicks];
  FValue := 1;
  FInterval := 60;
  CreateBitmap;
  FAutoSize := True;
  Width := FBitmap.Width + 2;
  Height := FBitmap.Height + 2;
end;

destructor TDice.Destroy;
begin
  if FBitmap <> nil then FBitmap.Free;
  inherited Destroy;
end;

procedure TDice.RandomValue;
var
  Val: Byte;
begin
  Val := Random(6) + 1;
  if Val = Byte(FValue) then begin
    if Val = 1 then Inc(Val)
    else Dec(Val);
  end;
  SetValue(TDiceValue(Val));
end;

procedure TDice.CMFocusChanged(var Message: TCMFocusChanged);
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

procedure TDice.WMSize(var Message: TWMSize);
begin
  inherited;
  AdjustBounds;
end;

procedure TDice.CreateBitmap;
begin
  if FBitmap = nil then FBitmap := TBitmap.Create;
  FBitmap.Handle := LoadBitmap(hInstance, ResName[FValue]);
end;

procedure TDice.AdjustBounds;
var
  Rect: TRect;
  MinSide: Integer;
begin
  if not (csReading in ComponentState) then begin
    if FAutoSize and (FBitmap.Width > 0) and (FBitmap.Height > 0) then
    begin
      SetBounds(Left, Top, FBitmap.Width + 2, FBitmap.Height + 2);
    end
    else begin
      { Adjust aspect ratio if control size changed }
      { << Bitmap.Width = Bitmap.Height }
      MinSide := Width;
      if Height < Width then  MinSide:= Height;
      SetBounds(Left, Top, MinSide, MinSide);
    end;
  end;
end;

procedure TDice.Paint;
var
  ARect: TRect;

  procedure DrawBitmap;
  var
    TmpImage: TBitmap;
    IWidth, IHeight: Integer;
    IRect: TRect;
  begin
    IWidth := FBitmap.Width;
    IHeight := FBitmap.Height;
    IRect := Rect(0, 0, IWidth, IHeight);
    TmpImage := TBitmap.Create;
    try
      TmpImage.Width := IWidth;
      TmpImage.Height := IHeight;
      TmpImage.Canvas.Brush.Color := Self.Brush.Color;
      TmpImage.Canvas.BrushCopy(IRect, FBitmap, IRect, clOlive);
      InflateRect(ARect, -1, -1);
      Canvas.StretchDraw(ARect, TmpImage);
      if Focused and FShowFocus and not (csDesigning in ComponentState) then
      begin
        InflateRect(ARect, 1, 1);
        Canvas.DrawFocusRect(ARect);
      end;
    finally
      TmpImage.Free;
    end;
  end;

begin
  ARect := GetClientRect;
  with Canvas do begin
    Brush.Color := Color;
    FillRect(ARect);
    Brush.Style := bsClear;
    if FBitmap <> nil then DrawBitmap;
  end;
end;

procedure TDice.TimerExpired(Sender: TObject);
var
  ParentForm: TForm;
begin
  RandomValue;
  if not FRotate then begin
    FTimer.Free;
    FTimer := nil;
    if (csDesigning in ComponentState) then
    begin
      ParentForm := GetParentForm(Self);
      if ParentForm <> nil then
        ParentForm.Designer.Modified;
    end;
  end;
end;

procedure TDice.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TDice.SetValue(Value: TDiceValue);
begin
  if FValue <> Value then begin
    FValue := Value;
    CreateBitmap;
    AdjustBounds;
    Invalidate;
    Change;
  end;
end;

procedure TDice.SetAutoSize(Value: Boolean);
begin
  if Value <> FAutoSize then begin
    FAutoSize := Value;
    AdjustBounds;
    Invalidate;
  end;
end;

procedure TDice.SetInterval(Value: Word);
begin
  if FInterval <> Value then begin
    FInterval := Value;
    if FTimer <> nil then FTimer.Interval := FInterval;
  end;
end;

procedure TDice.SetRotate(Value: Boolean);
begin
  if FRotate <> Value then begin
    if Value then begin
      if FTimer = nil then FTimer := TTimer.Create(Self);
      try
        with FTimer do begin
          OnTimer := TimerExpired;
          Interval := FInterval;
          Enabled := True;
        end;
        FRotate := Value;
      except
        FTimer.Free;
        FTimer := nil;
        raise;
      end;
    end
    else FRotate := Value;
  end;
end;

procedure TDice.SetShowFocus(Value: Boolean);
begin
  if FShowFocus <> Value then begin
    FShowFocus := Value;
    if not (csDesigning in ComponentState) then Invalidate;
  end;
end;

end.
