
type
    ArrayElemType  = real;
    ArrayIndexType = integer;
    ArrayBuffer    = array[1..$FFF8 div SizeOf(ArrayElemType)] of ArrayElemType;
    ArrayBufPtr    = ^ArrayBuffer;
    VecHandler     = array[1..$3FFE] of ArrayBufPtr;
    VecHandlerPtr  = ^VecHandler;

    BigVector = object
                      constructor Init(VSize : ArrayIndexType);
                      procedure SetVal(i : ArrayIndexType; V : ArrayElemType);
                      function GetVal(i : ArrayIndexType) : ArrayElemType;
                      destructor Done;
                private
                      Handler : ArrayBufPtr;
                      Size    : ArrayIndexType;
                end;

    BigMatrix = object
                      constructor Init(MCols, MRows : ArrayIndexType);
                      procedure SetVal(i, j : ArrayIndexType; V : ArrayElemType);
                      function GetVal(i, j : ArrayIndexType) : ArrayElemType;
                      destructor Done;
                private
                      Handler : VecHandlerPtr;
                      Cols, Rows : ArrayIndexType;
                end;

constructor BigVector.Init(VSize : ArrayIndexType);
begin
     Size:=VSize;
     GetMem(Handler, Size * SizeOf(ArrayElemType))
end;

procedure BigVector.SetVal(i : ArrayIndexType; V : ArrayElemType);
begin
     Handler^[i]:=V
end;

function BigVector.GetVal(i : ArrayIndexType) : ArrayElemType;
begin
     GetVal:=Handler^[i]
end;

destructor BigVector.Done;
begin
     FreeMem(Handler, Size * SizeOf(ArrayElemType))
end;

constructor BigMatrix.Init(MCols, MRows : ArrayIndexType);
var
  i : ArrayIndexType;
begin
     Cols:=MCols;
     Rows:=MRows;
     GetMem(Handler, Rows * SizeOf(ArrayBufPtr));
     for i:=1 to Rows do
         GetMem(Handler^[i], Cols * SizeOf(ArrayElemType))
end;

procedure BigMatrix.SetVal(i, j : ArrayIndexType; V : ArrayElemType);
begin
     Handler^[i]^[j]:=V
end;

function BigMatrix.GetVal(i, j : ArrayIndexType) : ArrayElemType;
begin
     GetVal:=Handler^[i]^[j]
end;

destructor BigMatrix.Done;
var
  i : ArrayIndexType;
begin
     for i:=1 to Rows do
         FreeMem(Handler^[i], Cols * SizeOf(ArrayElemType));
     FreeMem(Handler, Rows * SizeOf(ArrayBufPtr))
end;
