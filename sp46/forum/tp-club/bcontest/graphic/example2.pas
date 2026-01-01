Program Example2;
 { One of possible data sytructures realization }
 { Data structure description : Х - 2-D array of integer }
 {                              Y - 2-D array of real    }

uses
  Globals,ArtGraph;

Const
  Rows  = 20;
  Cols  = 5;
Type
  IntegerArray  = Array[1..Rows,1..Cols]  of integer;
  RealArray     = Array[1..Rows,1..Cols]  of real;

{$F+}
function MyGetMX(var X ; Row, Col: Longint) : Float;
var
  IntX : IntegerArray absolute X;
begin
  MyGetMX := IntX[Row,Col]
end;

function MyGetMY(var Y ; Row, Col: Longint) : Float;
var
  IntY : RealArray absolute Y;
begin
  MyGetMY := IntY[Row,Col]
end;

function MyNColX(var X) : longint;
Begin
  MyNColX := Cols;
End;

function MyNColY(var Y) : longint;
Begin
  MyNColY := Cols;
End;

function MyNRow(var X; i : longint) : longint;
Begin
  MyNRow := Rows;
End;
{$F-}

var
  X : IntegerArray;
  Y : RealArray;
  i,j : integer;
begin
  GetMX := MyGetMX;
  GetMY := MyGetMY;
  NColX := MyNColX;
  NColY := MyNColY;
  NRowX := MyNRow;
  NRowY := MyNRow;
  DriversPath := 'D:\TP55';
  {---------- Calculating data for Plot -----------------}
  For j := 1 to Cols do
    For i := 1 to Rows do begin
      X[i,j] := i*2-j;
      Y[i,j] := 38.0*Sin(i*j/40)+0.2;
    end;
  {______________________________________________________}
  Labels('X - 2-D Array Of Integer,  Y -  2-D Array Of Real',
         'Label X','Label Y');
  Plot(X,Y);
end.


