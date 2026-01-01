Program Example1;
 { One of possible data sytructures realization }
 { Data structure description : Х - vector of real      }
 {                              Y - 2-D array of real   }

uses
  Globals,ArtGraph;

Const
  Rows  = 20;
  Cols  = 5;

Type
  ArrayType  = Array[1..Rows,1..Cols]  of real;
  VectorType = Array[1..Rows]  of real;

{$F+}
function MyGetMX(var X ; Row, Col: Longint) : Float;
var
  IntX : VectorType absolute X;
begin
  MyGetMX := IntX[Row]
end;

function MyGetMY(var Y ; Row, Col: Longint) : Float;
var
  IntY : ArrayType absolute Y;
begin
  MyGetMY := IntY[Row,Col]
end;

function MyNColX(var X) : longint;
Begin
  MyNColX := 1;
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
  i,j : integer;
  X : VectorType;
  Y : ArrayType;
begin
  GetMX := MyGetMX;
  GetMY := MyGetMY;
  NColX := MyNColX;
  NColY := MyNColY;
  NRowX := MyNRow;
  NRowY := MyNRow;
  DriversPath := 'D:\TP55';
  {------------ Calculating data for Plot ----------}
  For i := 1 to Rows do begin
    X[i] := i*2.689;
    For j := 1 to Cols do
      Y[i,j] := 38.0*Sin(i*j/40)+0.2;
  end;
  {_________________________________________________}
  Labels('Х - Vector Of Real,  Y - 2-D Array Of Real','Label X','Label Y');
  Plot(X,Y);
end.


