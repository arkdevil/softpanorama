(*
            Сие есть маленький учебный пример
               созданный во время освоения
          объектных возможностей Turbo Pascal 7.0

Написан от того, что авторы книжки, по которой я изучал ООП, сочли
        недостойным себя печатать маленькие примеры и
               опубликовали НУ ОЧЕНЬ БОЛЬШОЙ :-(

               Павел Северов сентябрь 1993
*)

uses Crt;
const
MainBackground=Black;
MainColor=Black;
BrightLight=White;

type
  pPoint=^tPoint;
  tPoint=object
    XCoord,YCoord:byte;
    constructor Draw(X,Y:byte);
    destructor Erase;
    procedure On;virtual;
    procedure Off;virtual;
    procedure Move(X,Y:byte);
    procedure Right;
    end;

  pBox=^tBox;
  tBox=object(tPoint)
    Width:byte;
    constructor Draw(X,Y,W:byte);
    procedure On;virtual;
    procedure Off;virtual;
    end;

var
  i:integer;
  Point:pPoint;
  Box:pBox;

{***************************************************************************}

procedure tPoint.On;
begin
TextBackground(BrightLight);TextColor(BrightLight);
Window(XCoord,YCoord,XCoord,YCoord);
ClrScr;
end;

procedure tPoint.Off;
begin
TextBackground(MainBackground);TextColor(MainColor);
Window(XCoord,YCoord,XCoord,YCoord);
ClrScr;
end;

constructor tPoint.Draw;
begin XCoord:=X; YCoord:=Y; On; end;

destructor tPoint.Erase;
begin Off end;

procedure tPoint.Move;
begin Off;XCoord:=X; YCoord:=Y;On end;

procedure tPoint.Right;
begin Move(XCoord+1,YCoord);Delay(10); end;

{***************************************************************************}

procedure tBox.On;
begin
TextBackground(BrightLight);TextColor(BrightLight);
Window(XCoord,YCoord,XCoord+Width,YCoord+Width);
ClrScr;
end;

procedure tBox.Off;
begin
TextBackground(MainBackground);TextColor(MainColor);
Window(XCoord,YCoord,XCoord+Width,YCoord+Width);
ClrScr;
end;

constructor tBox.Draw;
begin XCoord:=X; YCoord:=Y; Width:=W; On; end;

{***************************************************************************}

begin
TextBackground(MainBackground);
TextColor(BrightLight);ClrScr;
write('                      Для следующего шага нажмите ENTER');
TextColor(MainColor);

ReadKey;New(Point,Draw(10,5));
ReadKey;for i:=1 to 60 do Point^.Right;
ReadKey;Dispose(Point,Erase);

ReadKey;New(Box,Draw(10,5,5));
ReadKey;for i:=1 to 60 do Box^.Right;
ReadKey;Dispose(Box,Erase);

Readkey;
end.
