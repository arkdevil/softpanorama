{$F+}
Unit TpVFont;

Interface

Uses Dos;

Type
  LoadFont = (Load,Restore814,Restore88,SetBlock);

Const
   LoadByExit: Boolean = True;

Procedure ChangeSymbol(ExpChar : Word; Matrix : Byte; XData : Pointer);

Procedure ReadRAMChar(ExpChar : Word; Matrix : Byte; XData : Pointer);

Procedure VideoFnt(NumSymbols,Offset,SegData,OfsData : word;Block,Matrix : byte;SubFunc : LoadFont);

Procedure QuietFnt(NumSymbols,Offset,SegData,OfsData : word;Block,Matrix : byte;SubFunc : LoadFont);

Procedure WipeFnt(NumSymbols,Offset : word;Block,Matrix : byte);

Procedure RestoreNormalFonts;

Procedure IncP(var PXs : Pointer; I : Word);

Procedure Exits;

Implementation
{F+}

Var
  ExitSave,C : Pointer;
  R          : Registers;
  I          : Word;

Procedure IncP(var PXs : Pointer; I : Word);
Var
  sg,os    : Word;
Begin
  os := Ofs(PXs^);
  sg := Seg(PXs^) + (os div 16);
  os := Ofs(PXs^) - (os div 16)*16 + I;
  PXs := Ptr(sg,os);
End;

{$L VGEN.OBJ}

Procedure OpenEgaOutput; External;

Procedure CloseEgaOutput; External;

Procedure SendEGAFont(ExpChar : Word; Matrix : Byte; XData : Pointer);External;

Procedure ReceiveEGAFont(ExpChar : Word; Matrix : Byte; XData : Pointer);External;

Procedure VideoFnt(NumSymbols,Offset,SegData,OfsData : word;
                     Block,Matrix : byte;
                     SubFunc : LoadFont);
Begin
FillChar(R,SizeOf(R),0);
  with r do begin
    es := SegData;
    bp := OfsData;
    cx := NumSymbols;
    dx := Offset;
    bl := Block;
    bh := Matrix;
    al := Ord(SubFunc);
    ah :=$11;
    Intr($10,R);
  end;
End;

Procedure ChangeSymbol(ExpChar : Word; Matrix : Byte; XData : Pointer);
External;

Procedure ReadRAMChar(ExpChar : Word; Matrix : Byte; XData : Pointer);
External;

Procedure QuietFnt(NumSymbols,Offset,SegData,OfsData : word;Block,Matrix : byte;SubFunc : LoadFont);
Begin
  C := Ptr(SegData,OfsData);
  OfsData := Block;
  OfsData := OfsData shl 8;

  OpenEgaOutput;
  For I := Offset + OfsData to NumSymbols + Offset + OfsData - 1 do begin
    SendEGAFont(I,Matrix,C);
    IncP(C,Matrix);
  end;
  CloseEgaOutput;

  if ((SubFunc = Restore88) or (SubFunc = Restore814)) then
    VideoFnt(NumSymbols,Offset,SegData,OfsData,Block,Matrix,SubFunc);
End;


Procedure WipeFnt(NumSymbols,Offset : word;Block,Matrix : byte);
Var
  X : Array[1..18] of Byte;
  Z : Word;
Begin
  C := @X;
  Z := Block;
  Z := Z shl 8;
  FillChar(X,SizeOf(X),0);
  OpenEgaOutput;
  For I := Offset + Z to NumSymbols + Offset + Z - 1 do
    SendEGAFont(I,Matrix,C);
  CloseEgaOutput;
End;

Procedure RestoreNormalFonts;
Begin
  VideoFnt(255,0,0,0,0,16,Restore814);
End;

Procedure Exits;
Begin
  if LoadByExit then RestoreNormalFonts;
  ExitProc := ExitSave;
End;

Begin
  ExitSave := ExitProc;
  ExitProc := @Exits;
End.