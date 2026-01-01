Unit TpLabel;

Interface

Uses Dos,TpCrt,TpVFont;


Const
  NumSet = 4;

Type
  CharSet  = array[1..NumSet] of char;
  Font814  = array[1..NumSet,1..14] of byte;
  Font816  = array[1..NumSet,1..16] of byte;

Const
   Zero      : byte = 4;
   CGASet    : CharSet = ('╣','╩','╠','╦');
   EGASet    : CharSet = ('√','№','¤','■');
   CountZero : byte = 1;
   CountSet  : byte = 1;
   Columns   : byte = 1;
   Rows      : byte = 1;
   EnableShow: Boolean = True;
   OldInt1C  : Pointer = NIL;
   Picture   : Font814 = ((0,32,33,162,164,232,176,232,164,162,33,32,0,0),
			  (0,16,16,145,210,180,184,180,210,145,16,16,0,0),
			  (0,8,8,136,201,170,156,170,201,136,8,8,0,0),
			  (0,4,132,196,164,149,158,149,164,196,132,4,0,0));

Var
   LabelProcPtr : Procedure;
   SaveFont     : Font816;

Procedure ReInitLabelFonts;

Procedure Exits;

Implementation

Var
  ExitSave  : Pointer;
  FirmSet   : CharSet;
  I         : Byte;

Procedure ReInitLabelFonts;
Begin
  QuietFnt(NumSet,Ord(EGASet[1]),Seg(Picture),Ofs(Picture),0,14,Load);
End;

Procedure Exits;
Begin
  SetIntVec($1C,OldInt1C);
  if LoadByExit then 
    for i := 1 to NumSet do ChangeSymbol(250 + I, 16, @SaveFont[I]);
  ExitProc := ExitSave;
End;

Procedure LabelProc; 	Far;
Begin
  if CountZero = Zero then CountZero := 1 else Inc(CountZero);
  if CountZero = Zero then begin
    if CountSet = NumSet then CountSet := 1 else Inc(CountSet);
    if EnableShow then FastText(FirmSet[CountSet],Rows,Columns);
  end;
End;

Procedure New1C(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp : word);
Interrupt;
Begin
  LabelProcPtr;
  Inline($FA/$9C/$3E/$FF/$1E/OldInt1C/$FB);
End;

Begin
  LoadByExit := False;
  ExitSave := ExitProc;
  ExitProc := @Exits;
  if CurrentDisplay >= EGA then begin
    for i := 1 to NumSet do ReadRAMChar(250 + I, 16, @SaveFont[I]);
    FirmSet := EGASet;
    ReInitLabelFonts;
  end
  else FirmSet := CGASet;
  @LabelProcPtr := @LabelProc;
  GetIntVec($1C,OldInt1C);
  SetIntVec($1C,@New1C);
End.