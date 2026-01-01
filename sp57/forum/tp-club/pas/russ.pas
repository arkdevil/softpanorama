{$F+}
Uses TpVFont;
Const
  Rus : Array[1..52] of Char =
  ('А','Б','Ц','Д','Е','Ф','Г','Х','И','Й','К','Л','М',
  'Н','О','П','Ш','Р','С','Т','У','В','В','Щ','И','З',
  'а','б','ц','д','е','ф','г','х','и','й','к','л','м',
  'н','о','п','ш','р','с','т','у','в','в','щ','и','з'
  );
  Lat : Array[1..52] of Char =
  ('A','B','C','D','E','F','G','H','I','J','K','L','M',
  'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
  'a','b','c','d','e','f','g','h','i','j','k','l','m',
  'n','o','p','q','r','s','t','u','v','w','x','y','z'
  );
Var
  Curr : Array[1..16] of Byte;
  I : Byte;
Begin
  For i := 1 to 52 do begin
    ReadRAMChar(Ord(Rus[I]),  16, @Curr);
    ChangeSymbol(Ord(Lat[I]), 16, @Curr);
  end;
  LoadByExit := False;
End.