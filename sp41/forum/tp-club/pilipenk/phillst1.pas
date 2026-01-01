type
    ArrayElemType  = integer;
    ArrayIndexType = integer;
    BigVector = object
                      constructor Init(Size : ArrayIndexType);
                      procedure SetVal(i : ArrayIndexType; V : ArrayElemType);
                      function GetVal(i : ArrayIndexType) : ArrayElemType;
                      destructor Done;
                private

                        . . .

                end;

    BigMatrix = object
                      constructor Init(Cols, Rows : ArrayIndexType);
                      procedure SetVal(i, j : ArrayIndexType; V : ArrayElemType);
                      function GetVal(i, j : ArrayIndexType) : ArrayElemType;
                      destructor Done;
                private

                        . . .

                end;
