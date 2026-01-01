program ScrollTest;
uses
    Crt, Win, ScrlWin;

var
    A : array[0..3] of PopUpWinObj;
    i : byte;

procedure PlayAll;
var
    i : byte;
    Ch : char;
begin
     i:=0;
     repeat
           i:=Succ(i) mod 4;
           A[i].Select;
           Write(chr(32 + Random(224)))
     until KeyPressed;
     Ch:=ReadKey;
end;

begin
     ClrScr;
     A[0].Init(1, 1, 45, 15, Attr(LightGray, Black),
            DoubleFrame, Attr(White, Black),
            ' Window 1 ', Attr(Black, LightGray),
            DefaultFlag);
     A[1].Init(47, 10, 80, 19, Attr(LightGray, Black),
            DoubleFrame, Attr(White, Black),
            ' Window 2 ', Attr(Black, LightGray),
            DefaultFlag);
     A[2].Init(15, 17, 45, 20, Attr(LightGray, Black),
            DoubleFrame, Attr(White, Black),
            ' Window 3 ', Attr(Black, LightGray),
            DefaultFlag);
     A[3].Init(5, 21, 75, 25, Attr(LightGray, Black),
            DoubleFrame, Attr(White, Black),
            ' Window 4 ', Attr(Black, LightGray),
            DefaultFlag);

     for i:=0 to 3 do
         A[i].Open;

     PlayAll;

     for i:=3 downto 0 do
         begin
              A[i].Select;
              Delay(500);
              A[i].Close
         end;

     Delay(1000)

end.
