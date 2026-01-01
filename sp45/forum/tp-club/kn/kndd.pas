{$I-}
Uses Dos;
Var
  y, m, d, dow : Word;

Function Lz(w : Word) : String;
Var
  S : String;
Begin
  Str(w:0,s);
  if Length(s) = 1 then
    S := '0' + S;
  Lz := S;
End;

Begin
  WriteLn('Make DATE-DIR, The KN Programs, Copyright (C) May 1992, Nikita E.Korzun (KN)');
  WriteLn('               Version 3.0, Last Edition 05/05/92');
  WriteLn;
  GetDate(y,m,d,dow);
  MkDir(Copy(Lz(y),3,2) + '_' + Lz(m) + '_' + Lz(d));
End.
