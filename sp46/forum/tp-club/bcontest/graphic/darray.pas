{$I defaults.inc}
unit DArray;
  { Error-protected realization of dynamically }
  { allocated arrays }
interface

uses
  Globals,   { Global definitions }
  ArtGraph,  { Basic package unit }
  Graph;     { Standart TP unit }

Type
  AElType = real;
  AnyArray = array[1..64500 div SizeOf(AElType)] of AElType;
  AType = record  { Structure type definition }
    Row : word;
    Col : word;
    Ap  : ^AnyArray;
    InitOK : word
  end;
procedure FreeA(X : AType);
  { Dispose array }

procedure MakeA(var X : AType; R,C : word);
  { Allocate array of R x C dinensions}

procedure LetA(X : AType; R,C : word; V : AElType);
  { Sets the R,C-th element of array to value }

function GetA(X : AType; R,C : word) : AElType;
  { Return R,C-th element of array }

function ARow(X : AType) : word;
  { Return number of rows in array }

function ACol(X : AType) : word;
  { Return number of columns in array }

implementation

const
  OK = 12345;

procedure AError(S : string);
begin
  RestoreCrtMode;
  Writeln(S);
  Halt
end; {AError}

procedure MakeA(var X : AType; R,C : word);
begin
  With X do begin
    If 1.0 * R * C * SizeOf(AElType) > 64500 then
      AError('MakeArray Error : Array too big');
    If MaxAvail < R * C * SizeOf(AElType) + 200 then
      AError('MakeArray Error : Not enough memory');
    GetMem(Ap,R * C * SizeOf(AElType));
    Row := R;
    Col := C;
    InitOK := OK
  end;
end; {MakeA}

procedure FreeA(X : AType);
begin
  With X do begin
    If InitOK <> OK then AError('FreeA Error : Array not initialised');
    InitOK := 0;
    FreeMem(Ap,Row * Col * SizeOf(AElType));
  end;
end; {FreeA}

procedure LetA(X : AType; R,C : word; V : AElType);
begin
  With X do begin
    If InitOK <> OK then AError('LetA Error : Array not initialised');
    If (R > Row) or (C > Col) or (R = 0) or (C = 0) then
      AError('LetA Error : Invalid index');
    Ap^[Pred(C) * Row + R] := V
  end;
end; {LetA}

function GetA(X : AType; R,C : word) : AElType;
begin
  With X do begin
    If InitOK <> OK then AError('GetA Error : Array not initialised');
    If (R > Row) or (C > Col) or (R = 0) or (C = 0) then
      AError('GetA Error : Invalid index');
    GetA := Ap^[Pred(C) * Row + R]
  end;
end; {GetA}

function ARow(X : AType) : word;
begin
  If X.InitOK <> OK then AError('ARow Error : Array not initialised');
  ARow := X.Row
end; {ARow}

function ACol(X : AType) : word;
begin
  If X.InitOK <> OK then AError('ACol Error : Array not initialised');
  ACol := X.Col
end; {ACol}

{$F+}
function MyGet(var X ; Row, Col: Longint) : Float;
begin
  MyGet := GetA(AType(X),Row,Col)
end;

function MyCol(var X) : longint;
Begin
  MyCol := ACol(AType(X))
End;

function MyRow(var X; j : longint) : longint;
Begin
  MyRow := ARow(AType(X));
End;
{$F-}

begin
  GetMX := MyGet;
  GetMY := MyGet;
  NColX := MyCol;
  NColY := MyCol;
  NRowX := MyRow;
  NRowY := MyRow;
end. {Main}
