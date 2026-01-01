Uses TpVFont;

Var
  P : Pointer;

Procedure VGAFont; External;

Begin
  {$L VGAFont.OBJ}
  P := @VGAFont;
  WipeFnt(256,0,0,16);
  QuietFnt(240,0,Seg(P^),Ofs(P^),0,16,Load);
  LoadByExit := False;
End.