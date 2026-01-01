unit Cus_Bas;

interface

uses Classes, Controls, winprocs,SysUtils, Messages, WinTypes, Forms, Graphics ;

type
  PCustomControl_Base = ^TCustomControl_Base ;
  TCustomControl_Base = class(TCustomControl)
    private
    protected
      procedure DessinerOmbre(MyRectangle:TRect;IsUp,IsFond,IsContour:Boolean;Epaisseur:Integer) ;
      procedure DessinerBitmap(Canvas : TCanvas;Bitmap : TBitmap;Zone : TRect) ;
    public
      procedure Redraw ;
    published
  end;

implementation

procedure TCustomControl_Base.Redraw ;
begin
  InvalidateRect(Handle,nil,TRUE) ;
end ;

procedure TCustomControl_Base.DessinerBitmap(Canvas : TCanvas;Bitmap : TBitmap;Zone : TRect) ;
begin
  with Zone,Canvas do
    Draw(left+((right-left-Bitmap.Width) DIV 2),
         top+((bottom-top-Bitmap.Height) DIV 2),
         Bitmap) ;
end ;

procedure TCustomControl_Base.DessinerOmbre(MyRectangle:TRect;IsUp,IsFond,IsContour:Boolean;Epaisseur:Integer) ;
var
  i       : Integer ;
begin
  with Canvas,MyRectangle do
  begin
    if IsFond then
    begin
         Pen.Color:=RGB(192,192,192) ;
         Brush.Color:=RGB(192,192,192) ;
         Rectangle(left,top,right,bottom) ;
    end ;

    Pen.Color:=RGB(0,0,0) ;

    if IsContour then
    begin
      MoveTo(left,top) ;
      LineTo(right,top) ;
      MoveTo(left,top) ;
      LineTo(left,bottom) ;
    end ;

    if IsUp then
      Pen.Color:=RGB(255,255,255)
    else
      Pen.Color:=RGB(128,128,128) ;

    for i:=1 to Epaisseur do
    begin
      MoveTo(left+1,top+i) ;
      LineTo(right-i,top+i) ;
      MoveTo(left+i,top+1) ;
      LineTo(left+i,bottom-i) ;
    end ;

    Pen.Color:=RGB(0,0,0) ;

    if IsContour then
    begin
      MoveTo(right-1,top+1) ;
      LineTo(right-1,bottom) ;
      MoveTo(left,bottom-1) ;
      LineTo(right,bottom-1) ;
    end ;

    if not IsUp then
      Pen.Color:=RGB(255,255,255)
    else
      Pen.Color:=RGB(128,128,128) ;

    for i:=1 to Epaisseur do
    begin
      MoveTo(left+Epaisseur-i,bottom-Epaisseur-2+i) ;
      LineTo(right-1,bottom-Epaisseur-2+i) ;
      MoveTo(right-Epaisseur-2+i,top+Epaisseur+1-i) ;
      LineTo(right-Epaisseur-2+i,bottom-1) ;
    end ;
  end ;
end ;

end.
