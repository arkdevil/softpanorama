Uses CType, Crt;

Var
  I, J: Byte;
  C: Char;

begin
  For  J := 2 To 15 Do
    begin
      ClrScr;
      TextColor(Yellow);
      Writeln('Char ToLow ToUpp IsDig IsHex IsLat IsRus IsAlp IsAlN IsAlf IsLow IsUpp');
      TextColor(LightGreen);
      For  I := J*16 To J*16 + 15 Do
        begin
          C := Chr(I);
          WriteLn('  ', C, '    ', ToLower(C), '     ', ToUpper(C),
                  '   ', IsDigit(C):5, ' ', IsHexDigit(C):5,
                  ' ', IsLatChar(C):5, ' ', IsRusChar(C):5,
                  ' ', IsAlpha(C):5, ' ', IsAlNum(C):5, ' ', IsAlfa(C):5,
                  ' ', IsLower(C):5, ' ', IsUpper(C):5);
        end;
      C := ReadKey;
    end;
end.