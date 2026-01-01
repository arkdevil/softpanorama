Uses TpVFont;

Var
  P : Pointer;

Procedure Lat; External;

Begin
  {$L LAT.OBJ}
  P := @Lat;
  WipeFnt(75,48,0,16);
  QuietFnt(75,48,Seg(P^),Ofs(P^),0,14,Load);
  LoadByExit := False;
End.