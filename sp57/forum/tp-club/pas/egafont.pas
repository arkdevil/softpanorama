Uses TpVFont;

Var
  P : Pointer;

Procedure EGAFont; External;

Begin
  {$L EGAFont.OBJ}
  P := @EGAFont;
  WipeFnt(256,0,0,16);
  QuietFnt(240,0,Seg(P^),Ofs(P^),0,14,Load);
  LoadByExit := False;
End.