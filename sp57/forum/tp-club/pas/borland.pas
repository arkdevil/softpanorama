{$R-,S-,I-}
Uses TpVFont;

Var
  X : Array [1..16] of byte;

Begin
  ReadRamChar(109,16,@X);
  ChangeSymbol(108,16,@X);
  ReadRamChar(77,16,@X);
  ChangeSymbol(76,16,@X);
  LoadByExit := False;
End.