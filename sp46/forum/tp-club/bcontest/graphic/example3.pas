{$I defaults.inc}
program Example3;
  { Error-protected realization of dynamically }
  { allocated arrays with different column length }

uses
  Globals,   { Global definitions }
  ArtGraph,  { Basic package unit }
  Graph;     { Standart TP unit }

const
  MaxCol = 100;
  OK = 12345;
Type
  BElType = real;
  RowType = array[1..MaxCol] of word;
  AnyArray = array[1..64500 div SizeOf(BElType)] of BElType;
  BType = record  { Structure type definition }
    Col : word;
    Row : RowType;
    Bp  : array[1..MaxCol] of ^AnyArray;
    InitOK : word
  end;

procedure BError(S : string);
begin
  RestoreCrtMode;
  Writeln(S);
  Halt
end; {BError}

procedure MakeB(var X : BType; R : RowType; C : word);
var
  i : word;
begin
  With X do begin
    For i := 1 to C do begin
      If 1.0 * R[i] * C * SizeOf(BElType) > 64500 then
        BError('MakeB Error : Array too big');
      If MaxAvail < R[i] * C * SizeOf(BElType) + 200 then
        BError('MakeB Error : Not enough memory');
      GetMem(Bp[i],R[i] * SizeOf(BElType));
      Row[i] := R[i];
    end;
    Col := C;
    InitOK := OK
  end;
end; {MakeB}

procedure FreeB(X : BType);
var
  i : word;
begin
  With X do begin
    If InitOK <> OK then BError('FreeB Error : Array not initialised');
    InitOK := 0;
    For i := 1 to Col do
      FreeMem(Bp[i],Row[i] * SizeOf(BElType));
  end;
end; {FreeB}

procedure LetB(X : BType; R,C : word; V : BElType);
begin
  With X do begin
    If InitOK <> OK then BError('LetB Error : Array not initialised');
    If (R > Row[C]) or (C > Col) or (R = 0) or (C = 0) then
      BError('LetB Error : Invalid index');
    Bp[C]^[R] := V
  end;
end; {LetB}

function GetB(X : BType; R,C : word) : BElType;
begin
  With X do begin
    If InitOK <> OK then BError('GetB Error : Array not initialised');
    If (R > Row[C]) or (C > Col) or (R = 0) or (C = 0) then
      BError('GetB Error : Invalid index');
    GetB := Bp[C]^[R]
  end;
end; {GetB}

function BRow(X : BType; C : word) : word;
begin
  If X.InitOK <> OK then BError('BRow Error : Array not initialised');
  BRow := X.Row[C]
end; {BRow}

function BCol(X : BType) : word;
begin
  If X.InitOK <> OK then BError('BCol Error : Array not initialised');
  BCol := X.Col
end; {BCol}

{$F+}
function MyGet(var X ; Row, Col: Longint) : Float;
begin
  MyGet := GetB(BType(X),Row,Col)
end;

function MyCol(var X) : longint;
Begin
  MyCol := BCol(BType(X))
End;

function MyRow(var X; j : longint) : longint;
Begin
  MyRow := BRow(BType(X),j);
End;
{$F-}

var
  i,j  : integer;
  X,Y  : BType;
  R : RowType;
begin
  GetMX := MyGet;
  GetMY := MyGet;
  NColX := MyCol;
  NColY := MyCol;
  NRowX := MyRow;
  NRowY := MyRow;
  For i := 1 to 5 do R[i] := 10*i;
  MakeB(X,R,5);
  MakeB(Y,R,5);
  DriversPath := 'D:\TP55';
  {---------- Calculating data for Plot -----------------}
  For j := 1 to BCol(Y) do begin
    For i := 1 to BRow(Y,j) do begin
      LetB(X,i,j,i*2-j);
      LetB(Y,i,j,38.0*Sin(i*j/40)+0.2);
    end;
  end;
  {______________________________________________________}
  Labels('X,Y - 2-D Arrays With Differnet Column Length',
         'Label X','Label Y');
  Plot(X,Y);
end. {Main}
