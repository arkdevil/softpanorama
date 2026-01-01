{************************************************}
{     Unit contain objects - Arrays.             }
{         1991. Igor Gorin.                      }
{************************************************}

unit Arrays;

interface

uses Objects;

type
  { type for float array }
  TFloat = Real;
  PFloat = ^TFloat;

function NewFloat(X : TFloat) : Pointer;
{ - locate TFloat in heap and return pointer}

procedure DisposeFloat(P : Pointer);
{ - dispose TFloat from heap }

{**********  Abstract Array of the Float *********}

type
  { Abstract array }
  PArrayFloat = ^TArrayFloat;
  TArrayFloat= object
    constructor Init (AMaxLine, AMaxCol : Integer);
    destructor Done; virtual;
    function GetValue (L, C : Integer ) : TFloat; virtual;
    procedure SetValue (L, C : Integer; X : TFloat); virtual;
    function GetMaxCol : Integer; virtual;
    function GetMaxLine : Integer; virtual;
  end;

{**********  Dinamic array of the Float *********}

type
  { array of the float. SizeOf array <= 64K }
  PDinArrFloat = ^TDinArrFloat;
  TDinArrFloat= object (TArrayFloat)
    MaxCol, MaxLine : Integer;
    ArrayPtr : Pointer;
    constructor Init (AMaxLine, AMaxCol : Integer);
    destructor Done; virtual;
    procedure Clear;
    function GetValue ( L, C : Integer ) : TFloat; virtual;
    procedure SetValue ( L, C : Integer; X : TFloat); virtual;
    function GetMaxCol : Integer; virtual;
    function GetMaxLine : Integer; virtual;
  end;

{**********  Dinamic array of the Byte  *********}

type
  { array of the byte. SizeOf array <= 64K }
  PDArrByte = ^TDArrByte;
  TDArrByte = object
    MaxCol, MaxLine : Integer;
    ArrayPtr : Pointer;
    constructor Init ( AMaxLine, AMaxCol : Integer );
    destructor Done; virtual;
    procedure FillValue(V : Byte);
    function GetValue (L, C : Integer ) : Integer;
    procedure SetValue (L, C : Integer; X : Byte);
    function GetMaxCol : Integer;
    function GetMaxLine : Integer;
    end;

{*****************  CollectionArray *****************}

type
  { Element of the array }
  PElement = ^TElement;
  TElement = record
    Value : TFloat;
    Col : Integer;
  end;

type
  { Line of the array }
  PArrayLine = ^TArrayLine;
  TArrayLine = object(TSortedCollection)
    Line : Integer;  { line number }
    constructor Init(ALimit, ADelta: Integer; ALine : Integer);
    destructor Done; virtual;
    function Compare(Key1, Key2 : Pointer) : Integer; virtual;
    procedure Store(var S : TStream);
    constructor Load(var S : TStream);
    procedure PutItem(var S : TStream; Item : Pointer); virtual;
    function GetItem(var S : TStream) : Pointer; virtual;
  end;

type
  { CollectionArray }
  PCollectionArray = ^TCollectionArray;
  TCollectionArray = object(TSortedCollection)
    function Compare(Key1, Key2 : Pointer) : Integer; virtual;
    procedure SetValue(L, C : Integer; V : TFloat);
    function GetValue(L, C : Integer) : TFloat;
    procedure DeleteCol(C : Integer);
    procedure DeleteLine(L : Integer);
    function GetMaxCol : Integer;
    function GetMaxLine : Integer;
  end;

const
  RCollectionArray : TStreamRec = (
    ObjType : 5000;
    VmtLink : Ofs(TypeOf(TCollectionArray)^);
    Load : @TCollectionArray.Load;
    Store : @TCollectionArray.Store);

const
  RArrayLine : TStreamRec = (
    ObjType : 5001;
    VmtLink : Ofs(TypeOf(TArrayLine)^);
    Load : @TArrayLine.Load;
    Store : @TArrayLine.Store);

{***********************  Packed Array *************************}

type
  { Packed Array }
  PPackedArray = ^TPackedArray;
  TPackedArray = object (TArrayFloat)
    CollectionArray : TCollectionArray;
    constructor Init (StartCol, StartLine : Integer );
    destructor Done; virtual;
    function GetValue (L, C : Integer ) : TFloat; virtual;
    procedure SetValue (L, C : Integer; X : TFloat); virtual;
    function GetMaxCol : Integer; virtual;
    function GetMaxLine : Integer; virtual;
  end;

implementation

type
  HidnArrByte = Array[1..1] of Byte;
  HidnArrWord = Array[1..1] of Integer;
  HidnArrFloat = Array[1..1] of TFloat;
  HidnArrBytePtr = ^HidnArrByte;
  HidnArrWordPtr = ^HidnArrWord;
  HidnArrFloatPtr = ^HidnArrFloat;

function NewFloat(X : TFloat) : Pointer;
{ - locate TFloat in heap and return pointer}
var
  P : Pointer;
begin
  GetMem(P, SizeOf(TFloat));
  PFloat(P)^ := X;
  NewFloat := P;
end;

procedure DisposeFloat(P : Pointer);
{ - dispose TFloat from heap }
begin
  FreeMem(P, SizeOf(TFloat));
end;

{ Abstract array -----------------------------------------------}
constructor TArrayFloat.Init ( AMaxLine, AMaxCol : Integer );
begin
  Abstract;
end;

destructor TArrayFloat.Done;
begin
  Abstract;
end;

function TArrayFloat.GetValue ( L, C : Integer ) : TFloat;
begin
  Abstract;
end;

procedure TArrayFloat.SetValue ( L, C : Integer; X : TFloat);
begin
  Abstract;
end;

function TArrayFloat.GetMaxCol : Integer;
begin
  Abstract;
end;

function TArrayFloat.GetMaxLine : Integer;
begin
  Abstract;
end;

{---------------------------- DinArrFloat -------------------------}

constructor TDinArrFloat.Init (AMaxLine, AMaxCol : Integer);
begin
  MaxCol := AMaxCol;
  MaxLine := AMaxLine;
  if MaxAvail > MaxCol*MaxLine*SizeOf(TFloat)
  then
    GetMem(ArrayPtr,MaxCol*MaxLine*SizeOf(TFloat))
  else
    ArrayPtr := nil;
end;

destructor TDinArrFloat.Done;
begin
  FreeMem(ArrayPtr,MaxCol*MaxLine*SizeOf(TFloat));
end;

function TDinArrFloat.GetValue (L, C : Integer ) : TFloat;
begin
  {$R-}
  if L <> 1
    then  GetValue := HidnArrFloatPtr(ArrayPtr)^[(L-1)*MaxCol+C]
    else  GetValue := HidnArrFloatPtr(ArrayPtr)^[C];
end;

procedure TDinArrFloat.SetValue (L, C : Integer; X : TFloat );
begin
  {$R-}
  if L <> 1
    then  HidnArrFloatPtr(ArrayPtr)^[(L-1)*MaxCol+C] := X
    else  HidnArrFloatPtr(ArrayPtr)^[C] := X;
end;

procedure TDinArrFloat.Clear;
begin
  fillChar(ArrayPtr^, MaxCol*MaxLine*SizeOf(TFloat), 0);
end;

function TDinArrFloat.GetMaxCol : Integer;
begin
  GetMaxCol := MaxCol;
end;

function TDinArrFloat.GetMaxLine : Integer;
begin
  GetMaxLine := MaxLine;
end;

{---------------------------- DArrByte -------------------------}

constructor TDArrByte.Init (AMaxLine ,AMaxCol : Integer);
begin
  MaxCol := AMaxCol;
  MaxLine := AMaxLine;
  if MaxAvail > MaxCol*MaxLine*SizeOf(Byte)
  then
    GetMem(ArrayPtr,MaxCol*MaxLine*SizeOf(Byte))
  else
    ArrayPtr := nil;
end;

destructor TDArrByte.Done;
begin
  if ArrayPtr <> nil then FreeMem(ArrayPtr,MaxCol*MaxLine*SizeOf(Byte));
end;

function TDArrByte.GetValue (L, C : Integer ) : Integer;
begin
{$R-}
if L <> 1
  then  GetValue := HidnArrBytePtr(ArrayPtr)^[(L-1)*MaxCol+C]
  else  GetValue := HidnArrBytePtr(ArrayPtr)^[C];
end;

procedure TDArrByte.SetValue (L, C : Integer; X : Byte);
begin
  {$R-}
  if L <> 1
    then  HidnArrBytePtr(ArrayPtr)^[(L-1)*MaxCol+C] := X
    else  HidnArrBytePtr(ArrayPtr)^[C] := X;
end;

procedure TDArrByte.FillValue(V : Byte);
begin
  fillChar(ArrayPtr^, MaxCol*MaxLine*SizeOf(Byte), V);
end;

function TDArrByte.GetMaxCol : Integer;
begin
  GetMaxCol := MaxCol;
end;

function TDArrByte.GetMaxLine : Integer;
begin
  GetMaxLine := MaxLine;
end;

{----------------------- TArrayLine --------------------------}

constructor TArrayLine.Init(ALimit, ADelta: Integer; ALine : Integer);
begin
  TSortedCollection.Init(ALimit, ADelta);
  Line := ALine;
end;

destructor TArrayLine.Done;
begin
  DeleteAll;
  TSortedCollection.Done;
end;

function TArrayLine.Compare(Key1, Key2 : Pointer) : Integer;
begin
  if PElement(Key1)^.Col = PElement(Key2)^.Col then
    Compare := 0
  else
    if PElement(Key1)^.Col < PElement(Key2)^.Col then
      Compare := -1
    else
      Compare := 1;
end;

procedure TArrayLine.Store(var S : TStream);
begin
  TSortedCollection.Store(S);
  S.Write(Line, SizeOf(Line));
end;

constructor TArrayLine.Load(var S : TStream);
begin
  TSortedCollection.Load(S);
  S.Read(Line, SizeOf(Line));
end;

procedure TArrayLine.PutItem(var S : TStream; Item : Pointer);
begin
  with PElement(Item)^ do
  begin
    S.Write(Value, SizeOf(Value));
    S.Write(Col, SizeOf(Col));
  end;
end;

function TArrayLine.GetItem(var S : TStream) : Pointer;
var
  E : PElement;
begin
  New(E);
  with E^ do
  begin
    S.Read(Value, SizeOf(Value));
    S.Read(Col, SizeOf(Col));
  end;
  GetItem := E;
end;

{--------------------------- TCollectionArray ----------------------}

function TCollectionArray.Compare(Key1, Key2 : Pointer) : Integer;
begin
  if PArrayLine(Key1)^.Line = PArrayLine(Key2)^.Line then
    Compare := 0
  else
    if PArrayLine(Key1)^.Line < PArrayLine(Key2)^.Line then
      Compare := -1
    else
      Compare := 1;
end;

procedure TCollectionArray.SetValue(L, C : Integer; V : TFloat);
var
  CurLine : PArrayLine;
  ViewElement : PElement;

  function EqualLine(P : PArrayLine) : Boolean; far;
  begin
    EqualLine := P^.Line = L;
  end;

  function EqualCol(P : PElement) : Boolean; far;
  begin
    EqualCol := P^.Col = C;
  end;

begin
  { find line }
  CurLine := FirstThat(@EqualLine);

  { if Line not found }
  if CurLine = nil then
  begin
    CurLine := New(PArrayLine, Init(10, 5, L));
    Insert(CurLine);
  end;

  { find element }
  ViewElement := CurLine^.FirstThat(@EqualCol);

  if ViewElement <> nil then
    ViewElement^.Value := V
  else
  begin
    { if col not found }
    New(ViewElement);

    with ViewElement^ do  begin  Value := V;   Col := C;  end;

    CurLine^.Insert(ViewElement);
  end;

end;

function TCollectionArray.GetValue(L, C : Integer) : TFloat;
var
  CurLine : PArrayLine;
  ViewElement : PElement;

  function EqualLine(P : PArrayLine) : Boolean; far;
  begin
    EqualLine := P^.Line = L;
  end;

  function EqualCol(P : PElement) : Boolean; far;
  begin
    EqualCol := P^.Col = C;
  end;

begin
  { find line }
  CurLine := FirstThat(@EqualLine);

  { if Line not found }
  if CurLine = nil then  begin   GetValue := 0;   Exit;   end;

  { find element }
  ViewElement := CurLine^.FirstThat(@EqualCol);

  if ViewElement <> nil then
    GetValue := ViewElement^.Value
  else
    GetValue := 0;

end;

procedure TCollectionArray.DeleteCol(C : Integer);

  procedure DeleteColNomer(P : PArrayLine); far;
  var
    ViewElement : PElement;
    I : Integer;

    function FindCol(L : PElement) : Boolean; far;
    begin
      FindCol := L^.Col = C;
    end;

  begin
    ViewElement := P^.FirstThat(@FindCol);

    if ViewElement <> nil then
    begin
      { shift index }
      for I := P^.IndexOf(ViewElement) to P^.Count - 1 do
        if PElement(P^.At(I))^.Col >= C then
          Dec(PElement(P^.At(I))^.Col);
      P^.Delete(ViewElement);
    end
    else
      for I := 0 to P^.Count - 1 do
        if PElement(P^.At(I))^.Col > C then
          Dec(PElement(P^.At(I))^.Col);

  end;

begin
  ForEach(@DeleteColNomer);
end;

procedure TCollectionArray.DeleteLine(L : Integer);
var
  I : Integer;
  ViewLine : PArrayLine;

  function FindLine(P : PArrayLine) : Boolean; far;
  begin
    FindLine := P^.Line = L;
  end;

begin
  ViewLine := FirstThat(@FindLine);
  if ViewLine <> nil then
  begin
    for I := IndexOf(ViewLine) to Count - 1 do
      if PArrayLine(At(I))^.Line > L then
        Dec(PArrayLine(At(I))^.Line);
    Self.Delete(ViewLine);
  end
  else
    for I := 0 to Count - 1 do
      if PArrayLine(At(I))^.Line > L then
         Dec(PArrayLine(At(I))^.Line);
end;

function TCollectionArray.GetMaxCol : Integer;
var
  MaxCol, ViewCol, I, J : Integer;
  ViewLine : PArrayLine;

begin
  MaxCol := 0;
  for I := 0 to Count - 1 do
  begin
    ViewLine := PArrayLine(At(I));
    for J := 0 to ViewLine^.Count - 1 do
    begin
      ViewCol := PElement(ViewLine^.At(J))^.Col;
      if ViewCol > MaxCol then MaxCol := ViewCol;
    end;
  end;
  GetMaxCol := MaxCol;
end;

function TCollectionArray.GetMaxLine : Integer;
begin
  if Count <> 0 then
    GetMaxLine := PArrayLine(At(Count - 1))^.Line
  else
    GetMaxLine := 0;
end;

{ Packed Array -----------------------------------------------}

constructor TPackedArray.Init (StartCol, StartLine : Integer );
begin
  CollectionArray.Init(StartCol, StartLine);
end;

destructor TPackedArray.Done;
begin
  CollectionArray.Done;
end;

function TPackedArray.GetValue ( L, C : Integer ) : TFloat;
begin
  GetValue := CollectionArray.GetValue(L, C);
end;

procedure TPackedArray.SetValue ( L, C : Integer; X : TFloat);
begin
  CollectionArray.SetValue(L, C, X);
end;


function TPackedArray.GetMaxCol : Integer;
begin
  GetMaxCol := CollectionArray.GetMaxCol;
end;

function TPackedArray.GetMaxLine : Integer;
begin
  GetMaxLine := CollectionArray.GetMaxLine;
end;

end.