{ ----------------------------------------------------------------------------}
{ A Gradient Fill component for Delphi.                                       }
{ Copyright 1995, Curtis White.  All Rights Reserved.                         }
{ Portions copyright 1995, OKO ROSNO, Moscow                                  }
{ This component can be freely used and distributed in commercial and private }
{ environments, provied this notice is not modified in any way.               }
{ ----------------------------------------------------------------------------}
{ Feel free to contact me if you have any questions, comments or suggestions  }
{ at cwhite@teleport.com                                                      }
{ ----------------------------------------------------------------------------}
{ Date last modified:  16/06/95                                               }
{ ----------------------------------------------------------------------------}
{ TGradientFill v1.01                                                         }
{ ----------------------------------------------------------------------------}
{ Description:                                                                }
{   A graphic control that displays a gradient beginning with a chosen color  }
{   and ending with another chosen color.                                     }
{ Features:                                                                   }
{   The begin and end colors can be any colors.                               }
{   The fill direction can be set to Top-To-Bottom, Bottom-To-Top,            }
{     Right-To-Left, or Left-To-Right.                                        }
{   The number of colors, between 1 and 255 can be set for the fill.          }
{ ----------------------------------------------------------------------------}
{ Revision History:                                                           }
{ 1.00:  Initial release                                                      }
{ 1.01:  Corrected by OKO ROSNO                                               }
{ ----------------------------------------------------------------------------}

unit GradFill;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls, Menus,
  Forms, Dialogs, ExtCtrls;

type

  { Direction of fill }
  TFillDirection = (fdTopToBottom, fdBottomToTop, fdLeftToRight, fdRightToLeft);

  { Range of valid colors }
  TNumberOfColors = 1..255;

  TGradientFill = class(TGraphicControl)
  private
    { Variables for properties }
    FDirection: TFillDirection;
    FBeginColor: TColor;
    FEndColor: TColor;
    FCenter: Boolean;
    FNumberOfColors: TNumberOfColors;
    procedure SetFillDirection(Value: TFillDirection);
    procedure SetBeginColor(Value: TColor);
    procedure SetEndColor(Value: TColor);
    procedure SetNumberOfColors(Value: TNumberOfColors);
    procedure GradientFill;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property BeginColor: TColor read FBeginColor write SetBeginColor default clBlue;
    property EndColor: TColor read FEndColor write SetEndColor default clBlack;
    property FillDirection: TFillDirection read FDirection write SetFillDirection
      default fdTopToBottom;
    property NumberOfColors: TNumberOfColors read FNumberOfColors
      write SetNumberOfColors default 64;
    property Align;
    property DragCursor;
    property DragMode;
    property Enabled;
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

{ Designer registration }

procedure Register;

implementation

Uses ExtConst;

{ Register the component }

procedure Register;
begin
  RegisterComponents(GetExtStr(srGadgets), [TGradientFill]);
end;

{ TGradientFill }

{ Override the constructor to initialize variables }
constructor TGradientFill.Create(AOwner: TComponent);
begin
  { Inherit original constructor }
  inherited Create(AOwner);
  { Add new initializations }
  Height := 105;
  Width := 105;
  FBeginColor := clBlue;
  FEndColor := clBlack;
  FDirection := fdTopToBottom;
  FNumberOfColors := 64;
end;

{ Set begin color when property is changed }
procedure TGradientFill.SetBeginColor(Value: TColor);
begin
  if FBeginColor <> Value then begin
    FBeginColor := Value;
    Invalidate;
  end;
end;

{ Set end color when property is changed }
procedure TGradientFill.SetEndColor(Value: TColor);
begin
  if FEndColor <> Value then begin
    FEndColor := Value;
    Invalidate;
  end;
end;

{ Set the number of colors to be used in the fill }
procedure TGradientFill.SetNumberOfColors(Value: TNumberOfColors);
begin
  if FNumberOfColors <> Value then begin
    FNumberOfColors := Value;
    Invalidate;
  end;
end;

{ Set the fill direction }
procedure TGradientFill.SetFillDirection(Value: TFillDirection);
begin
  if Value <> FDirection then begin
    FDirection := Value;
    Invalidate;
  end;
end;

{ Perform the fill when paint is called }
procedure TGradientFill.Paint;
begin
  GradientFill;
end;

{ Gradient fill procedure - the actual routine }
procedure TGradientFill.GradientFill;
var
  BeginRGBValue: array[0..2] of Byte;    { Begin RGB values }
  RGBDifference: array[0..2] of Integer; { Difference between begin and end RGB values }
  ColorBand: TRect;    { Color band rectangular coordinates }
  I        : Integer;  { Color band index }
  R        : Byte;     { Color band Red value }
  G        : Byte;     { Color band Green value }
  B        : Byte;     { Color band Blue value }
begin
  { Extract the begin RGB values }
  case FDirection of
    { If direction is set to TopToBottom or LeftToRight }
    fdTopToBottom, fdLeftToRight: begin
      { Set the Red, Green and Blue colors }
      BeginRGBValue[0] := GetRValue(ColorToRGB(FBeginColor));
      BeginRGBValue[1] := GetGValue(ColorToRGB(FBeginColor));
      BeginRGBValue[2] := GetBValue(ColorToRGB(FBeginColor));
      { Calculate the difference between begin and end RGB values }
      RGBDifference[0] := GetRValue(ColorToRGB(FEndColor)) - BeginRGBValue[0];
      RGBDifference[1] := GetGValue(ColorToRGB(FEndColor)) - BeginRGBValue[1];
      RGBDifference[2] := GetBValue(ColorToRGB(FEndColor)) - BeginRGBValue[2];
    end;
    { If direction is set to BottomToTop or RightToLeft}
    fdBottomToTop, fdRightToLeft: begin
      { Set the Red, Green and Blue colors }
      { Reverse of TopToBottom and LeftToRight directions }
      BeginRGBValue[0] := GetRValue(ColorToRGB(FEndColor));
      BeginRGBValue[1] := GetGValue(ColorToRGB(FEndColor));
      BeginRGBValue[2] := GetBValue(ColorToRGB(FEndColor));
      { Calculate the difference between begin and end RGB values }
      { Reverse of TopToBottom and LeftToRight directions }
      RGBDifference[0] := GetRValue(ColorToRGB(FBeginColor)) - BeginRGBValue[0];
      RGBDifference[1] := GetGValue(ColorToRGB(FBeginColor)) - BeginRGBValue[1];
      RGBDifference[2] := GetBValue(ColorToRGB(FBeginColor)) - BeginRGBValue[2];
    end;
  end; {case}
  case FDirection of
    { Calculate the color band's top and bottom coordinates }
    { for TopToBottom and BottomToTop fills }
    fdTopToBottom, fdBottomToTop: begin
      ColorBand.Left := 0;
      ColorBand.Right := Width;
    end;
    { Calculate the color band's left and right coordinates }
    { for LeftToRight and RightToLeft fills }
    fdLeftToRight, fdRightToLeft: begin
      ColorBand.Top := 0;
      ColorBand.Bottom := Height;
    end;
  end; {case}
  with Canvas.Pen do begin
    { Set the pen style and mode }
    Style := psSolid;
    Mode := pmCopy;
  end;
  { Perform the fill }
  for I := 0 to FNumberOfColors do begin
    case FDirection of
      { Calculate the color band's top and bottom coordinates }
      fdTopToBottom, fdBottomToTop: begin
          ColorBand.Top := MulDiv(I, Height, FNumberOfColors);
          ColorBand.Bottom := MulDiv(I + 1, Height, FNumberOfColors);
      end;
      { Calculate the color band's left and right coordinates }
      fdLeftToRight, fdRightToLeft: begin
          ColorBand.Left := MulDiv(I, Width, FNumberOfColors);
          ColorBand.Right := MulDiv(I + 1, Width, FNumberOfColors);
      end;
    end; {case}
    { Calculate the color band's color }
    if FNumberOfColors > 1 then begin
      R := BeginRGBValue[0] + MulDiv(I, RGBDifference[0], FNumberOfColors - 1);
      G := BeginRGBValue[1] + MulDiv(I, RGBDifference[1], FNumberOfColors - 1);
      B := BeginRGBValue[2] + MulDiv(I, RGBDifference[2], FNumberOfColors - 1);
    end
    else begin
      { Set to the Begin Color if set to only one color }
      R := BeginRGBValue[0];
      G := BeginRGBValue[1];
      B := BeginRGBValue[2];
    end;
    with Canvas do begin
      { Select the brush and paint the color band }
      Brush.Color := RGB(R, G, B);
      FillRect(ColorBand);
    end;
  end;
end;

end.
