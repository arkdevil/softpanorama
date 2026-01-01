Uses TpVFont;

Type
  ChArray = array[1..14] of byte;
  XPtr = ^XArr;
  XArr = array[1..8] of ChArray;

Var
  P,R,G : XPtr;
  i : Byte;
  F : File;


Procedure Anthrax; External;

Procedure Beer; External;

Begin
  {$I-}
  {$L A.OBJ}
  {$L C.OBJ}
  New(P);
  New(R);
  P := @Anthrax;
  R := @P^[6];
  G := @Beer;
  Move(G^,R^,14*3);
  WipeFnt(8,128,0,16);
  QuietFnt(8,128,Seg(P^),Ofs(P^),0,14,Load);
  LoadByExit := False;
  Release(P);
  Release(R);
  WriteLn('I love АБВГД and ЕЖЗ.');
End.