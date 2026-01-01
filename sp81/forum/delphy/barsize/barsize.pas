unit Barsize;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Cus_Bas;

const
  HAUTEUR_BARRE_RESIZE    = 5 ;

type
  TSL_Mouvement = procedure(Sender: TObject) of Object ;
  TSL_DuringSlide = procedure(Sender: TObject;X,Y:Integer) of Object ;

  TBarreResize = class(TCustomControl_Base)
  private
    FIsHorizontale          : Boolean ;
    IsBuildMode             : Boolean ;
    ValeurDecallage         : Integer ;
    FOnSl_mouvement         : TSL_Mouvement ;
    FOnDuringSlide          : TSL_DuringSlide ;

    procedure SetIsHorizontale(Value: Boolean);
    procedure Dessiner ;
  protected
    constructor Create(AOwner: TComponent); override;
    procedure   Paint; override;
    procedure   CreateParams(var Params: TCreateParams); override;
    procedure   MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer); override;
    procedure   MouseUp(Button: TMouseButton; Shift: TShiftState;X, Y: Integer); override;
    procedure   MouseMove(Shift: TShiftState; X, Y: Integer); override;
  public
  published
    property IsHorizontal : Boolean read FIsHorizontale write SetIsHorizontale;
    property OnNewPosition : TSL_Mouvement read FOnSl_mouvement write FOnSl_mouvement ;
    property OnSliding : TSL_DuringSlide read FOnDuringSlide write FOnDuringSlide ;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Staff And Line', [TBarreResize]);
end;

{---------------------------------------------------------------------------}

constructor TBarreResize.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width:=100 ;
  Height:=HAUTEUR_BARRE_RESIZE ;
  FIsHorizontale:=TRUE ;
end;

procedure TBarreResize.CreateParams(var Params: TCreateParams);
var
  Chaine    : PString ;
begin
  inherited CreateParams(Params);
  IsBuildMode:=(Pos('.DCL',Application.ExeName)>0) ;

  if FISHorizontale then
  begin
    Height:=5 ;
    Cursor:=crVSplit ;
  end
  else
  begin
    Width:=5 ;
    Cursor:=crHSplit ;
  end ;
end;

procedure TBarreResize.Paint;
begin
{
  if FISHorizontale then
    Height:=5
  else
    Width:=5 ;
}
  with Canvas do
  begin
    Pen.Color:=RGB(0,0,0) ;
    Brush.Color:=RGB(192,192,192) ; ;
    if FIsHorizontale then
    begin
      Rectangle(0,0,Width,HAUTEUR_BARRE_RESIZE) ;
      Pen.Color:=RGB(128,128,128) ;
      MoveTo(1,1) ;
      LineTo(Width-1,1) ;
      Pen.Color:=RGB(255,255,255) ;
      MoveTo(1,3) ;
      LineTo(Width-1,3) ;
    end
    else
    begin
      Rectangle(0,0,HAUTEUR_BARRE_RESIZE,Height) ;
      Pen.Color:=RGB(128,128,128) ;
      MoveTo(1,1) ;
      LineTo(1,Height-1) ;
      Pen.Color:=RGB(255,255,255) ;
      MoveTo(3,1) ;
      LineTo(3,Height-1) ;
    end ;
  end ;
end ;

procedure TBarreResize.SetIsHorizontale(Value: Boolean);
begin
  if (IsBuildMode) and (FIsHorizontale<>Value) then
  begin
    if Value then
    begin
      Width:=Height ;
      Height:=HAUTEUR_BARRE_RESIZE ;
    end
    else
    begin
      Height:=Width ;
      Width:=HAUTEUR_BARRE_RESIZE ;
    end ;
  end ;

  FIsHorizontale:=Value ;
  if FISHorizontale then
    Height:=5
  else
    Width:=5 ;
  Redraw ;
end ;

procedure TBarreResize.MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);
var
  Mypoint       : TPoint ;
begin
  if Button = mbLeft then
  begin
    MyPoint.X:=X;
    MyPoint.Y:=Y ;
    MyPoint:=ClientToScreen(MyPoint) ;
    MyPoint:=TForm(Parent).ScreenToClient(MyPoint) ;
    if FIsHorizontale then
      ValeurDecallage:=MyPoint.Y
    else
      ValeurDecallage:=MyPoint.X ;
    Dessiner ;
  end ;
  inherited MouseDown(Button,Shift, X, Y);
end ;

procedure TBarreResize.MouseUp(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);
var
  IsMouvement       : Boolean ;
begin
  if Button = mbLeft then
  begin
    Dessiner ;
    IsMouvement:=FALSE ;
    if FIsHorizontale then
    begin
      if (ValeurDecallage<(TForm(Parent).ClientHeight-HAUTEUR_BARRE_RESIZE-2)) and
         (ValeurDecallage>2) then
      begin
        IsMouvement:=(Top<>ValeurDecallage) ;
        Top:=ValeurDecallage ;
      end ;
    end
    else
    begin
      if (ValeurDecallage<(TForm(Parent).ClientWidth-HAUTEUR_BARRE_RESIZE-2)) and
         (ValeurDecallage>2) then
      begin
        IsMouvement:=(Left<>ValeurDecallage) ;
        Left:=ValeurDecallage ;
      end ;
    end ;
    if (IsMouvement) and (Assigned(FOnSL_Mouvement)) then
    begin
      OnNewPosition(Self) ;
    end ;
  end ;
  inherited MouseUp(Button,Shift, X, Y);
end ;

procedure TBarreResize.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  MyPoint       : TPoint ;
  Temp          : Integer ;
  Temp2         : Integer ;
begin
  if ssLeft in Shift then
  begin
    MyPoint.X:=X;
    MyPoint.Y:=Y ;
    MyPoint:=ClientToScreen(MyPoint) ;
    MyPoint:=TForm(Parent).ScreenToClient(MyPoint) ;
    if FIsHorizontale then
    begin
      Temp:=MyPoint.Y ;
      Temp2:=TForm(Parent).ClientHeight ;
    end
    else
    begin
      Temp:=MyPoint.X ;
      Temp2:=TForm(Parent).ClientWidth ;
    end ;
    if (Temp<=0) then
      Temp:=1
    else if (Temp>=Temp2-HAUTEUR_BARRE_RESIZE-1) then
      Temp:=Temp2-HAUTEUR_BARRE_RESIZE-2 ;

    Dessiner ;
    if (Assigned(FOnDuringSlide)) then
    begin
      if FIsHorizontale then
        OnSliding(Self,Left,ValeurDecallage)
      else
        OnSliding(Self,ValeurDecallage,Top) ;
    end ;
    ValeurDecallage:=Temp ;
    Dessiner ;
  end ;
  inherited MouseMove(Shift, X, Y);
end ;

procedure TBarreResize.Dessiner ;
var
  MyRect       : TRect ;
  MyDC         : HDC ;
  MyPoint      : TPoint ;
begin
  MyDC:=GetDC(0) ;
  if FIsHorizontale then
  begin
    MyPoint.X:=Left ;
    MyPoint.Y:=ValeurDecallage ;
    MyPoint:=TForm(Parent).ClientToScreen(MyPoint) ;
    BitBlt(MyDC,MyPoint.X,MyPoint.Y,Width,Height,0,0,0,DSTINVERT) ;
  end
  else
  begin
    MyPoint.X:=ValeurDecallage ;
    MyPoint.Y:=Top ;
    MyPoint:=TForm(Parent).ClientToScreen(MyPoint) ;
    BitBlt(MyDC,MyPoint.X,MyPoint.Y,Width,Height,0,0,0,DSTINVERT) ;
  end ;
  ReleaseDC(0,MyDC) ;
end ;

end.
