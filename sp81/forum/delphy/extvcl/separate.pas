{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
unit Separate;

interface

uses
  Classes, WinTypes, Controls, ExtCtrls, Forms, Graphics;

type

{ TSeparator }

  TSeparatorStyle = (spUnknown, spHorizontalFirst, spHorizontalSecond,
    spVerticalFirst, spVerticalSecond);

  TSeparator = class(TCustomPanel)
  private
    FControlFirst: TControl;
    FControlSecond: TControl;
    FSizing: Boolean;
    FStyle: TSeparatorStyle;
    FPrevOrg: TPoint;
    procedure StartInverseRect;
    procedure EndInverseRect(X, Y: Integer);
    procedure MoveInverseRect(X, Y: Integer);
    procedure ShowInverseRect(X, Y: Integer; Clear: Boolean);
    function GetStyle: TSeparatorStyle;
    function GetCursor: TCursor;
    procedure SetControlFirst(Value: TControl);
    procedure SetControlSecond(Value: TControl);
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure UpdateState;
    property Cursor read GetCursor;
  published
    property ControlFirst: TControl read FControlFirst write SetControlFirst;
    property ControlSecond: TControl read FControlSecond write SetControlSecond;
    property Align;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Color;
    property Ctl3D;
    property Locked;
    property ParentColor;
    property ParentCtl3D;
    property ParentShowHint;
    property ShowHint;
    property Visible;
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

procedure Register;

implementation

uses
  WinProcs, ExtConst, VCLUtil;

{ TSeparator }

const
  INVERSE_THICKNESS = 2;

constructor TSeparator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents, csOpaque, csDoubleClicks];
  Width := 185;
  Height := 3;
  FSizing := False;
  FControlFirst := nil;
  FControlSecond := nil;
end;

procedure TSeparator.Loaded;
begin
  inherited Loaded;
  UpdateState;
end;

procedure TSeparator.UpdateState;
begin
  inherited Cursor := Cursor;
end;

procedure TSeparator.StartInverseRect;
begin
  ShowInverseRect(0, 0, False);
end;

procedure TSeparator.EndInverseRect(X, Y: Integer);
const
  DecSize = 3;
var
  NewSize: Integer;
  Rect: TRect;
  W, H: Integer;
begin
  ShowInverseRect(0, 0, True);
  if Parent = nil then Exit;
  Rect := Parent.ClientRect;
  H := Rect.Bottom - Rect.Top - Height;
  W := Rect.Right - Rect.Left - Width;
  if (ControlFirst.Align = alRight) or
    (ControlSecond.Align = alRight) then X := -X;
  if (ControlFirst.Align = alBottom) or
    (ControlSecond.Align = alBottom) then Y := -Y;
  if FStyle = spHorizontalFirst then begin
    NewSize := ControlFirst.Height + Y;
    if NewSize <= 0 then NewSize := 1;
    if NewSize >= H then NewSize := H - DecSize;
    ControlFirst.Height := NewSize;
  end
  else if FStyle = spHorizontalSecond then begin
    NewSize := ControlSecond.Height + Y;
    if NewSize <= 0 then NewSize := 1;
    if NewSize >= H then NewSize := H - DecSize;
    ControlSecond.Height := NewSize;
  end
  else if FStyle = spVerticalFirst then begin
    NewSize := ControlFirst.Width + X;
    if NewSize <= 0 then NewSize := 1;
    if NewSize >= W then NewSize := W - DecSize;
    ControlFirst.Width := NewSize;
  end
  else if FStyle = spVerticalSecond then begin
    NewSize := ControlSecond.Width + X;
    if NewSize <= 0 then NewSize := 1;
    if NewSize >= W then NewSize := W - DecSize;
    ControlSecond.Width := NewSize;
  end;
end;

procedure TSeparator.MoveInverseRect(X, Y: Integer);
begin
  ShowInverseRect(0, 0, True);
  ShowInverseRect(X, Y, False);
end;

procedure TSeparator.ShowInverseRect(X, Y: Integer; Clear: Boolean);
var
  P: TPoint;
  W, H: Integer;
  MaxRect: TRect;
begin
  P := Point(0, 0);
  if (FStyle = spHorizontalFirst) or (FStyle = spHorizontalSecond) then begin
    W := Width;
    H := INVERSE_THICKNESS;
    P.Y := Y;
  end
  else begin
    W := INVERSE_THICKNESS;
    H := Height;
    P.X := X;
  end;
  if Clear then P := FPrevOrg
  else begin
    MaxRect := Parent.ClientRect;
    P := ClientToScreen(P);
    with P, MaxRect do begin
      TopLeft := Parent.ClientToScreen(TopLeft);
      BottomRight := Parent.ClientToScreen(BottomRight);
      if X < Left then X := Left;
      if X > Right then X := Right;
      if Y < Top then Y := Top;
      if Y > Bottom then Y := Bottom;
    end;
    FPrevOrg := P;
  end;
  PaintInverseRect(P, Point(P.X + W, P.Y + H));
end;

function TSeparator.GetStyle: TSeparatorStyle;
begin
  Result := spUnknown;
  if (ControlFirst <> nil) and (ControlSecond <> nil) then
  begin
    if ((ControlFirst.Align = alTop) and (ControlSecond.Align = alClient)) or
       ((ControlFirst.Align = alBottom) and (ControlSecond.Align = alClient)) then
      Result := spHorizontalFirst
    else if ((ControlFirst.Align = alClient) and (ControlSecond.Align = alBottom)) or
       ((ControlFirst.Align = alClient) and (ControlSecond.Align = alTop)) then
      Result := spHorizontalSecond
    else if ((ControlFirst.Align = alLeft) and (ControlSecond.Align = alClient)) or
       ((ControlFirst.Align = alRight) and (ControlSecond.Align = alClient)) then
      Result := spVerticalFirst
    else if ((ControlFirst.Align = alClient) and (ControlSecond.Align = alRight)) or
       ((ControlFirst.Align = alClient) and (ControlSecond.Align = alLeft)) then
      Result := spVerticalSecond;
    case Result of
      spHorizontalFirst, spVerticalFirst:
        if Align <> FControlFirst.Align then Result := spUnknown;
      spHorizontalSecond, spVerticalSecond:
        if Align <> FControlSecond.Align then Result := spUnknown;
    end;
  end;
end;

function TSeparator.GetCursor: TCursor;
begin
  case GetStyle of
    spUnknown:
      Result := crDefault;
    spHorizontalFirst, spHorizontalSecond:
      Result := crVSplit;
    spVerticalFirst, spVerticalSecond:
      Result := crHSplit;
  end;
end;

procedure TSeparator.SetControlFirst(Value: TControl);
begin
  if Value <> FControlFirst then begin
    if Value = Self then FControlFirst := nil
    else FControlFirst := Value;
    UpdateState;
  end;
end;

procedure TSeparator.SetControlSecond(Value: TControl);
begin
  if Value <> FControlSecond then begin
    if Value = Self then FControlSecond := nil
    else FControlSecond := Value;
    UpdateState;
  end;
end;

procedure TSeparator.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  if AOperation = opRemove then
  begin
    if AComponent = ControlFirst then ControlFirst := nil
    else if AComponent = ControlSecond then ControlSecond := nil;
  end;
end;

procedure TSeparator.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if not (csDesigning in ComponentState) and (Button = mbLeft) then begin
    FStyle := GetStyle;
    if FStyle <> spUnknown then begin
      FSizing := True;
      SetCapture(Handle);
      StartInverseRect;
    end;
 end;
end;

procedure TSeparator.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if (GetCapture = Handle) and FSizing then begin
    MoveInverseRect(X, Y);
  end;
end;

procedure TSeparator.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if FSizing then begin
    ReleaseCapture;
    EndInverseRect(X, Y);
    FSizing := False;
  end;
  inherited MouseUp(Button, Shift, X, Y);
end;

{ Designer registration }

procedure Register;
begin
  RegisterComponents(GetExtStr(srGadgets), [TSeparator]);
end;

end.
