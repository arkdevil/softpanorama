{$F+}
Program Train;
Uses TpCrt,TpLabel,TpVFont;
Const
   Fonts : array[1..5,1..14] of byte =
   ((0,0,14,12,12,12,31,48,81,56,127,106,149,10),
   (0,63,41,25,31,19,255,2,14,64,255,66,165,66),
   (0,0,0,248,8,232,170,234,14,10,250,32,80,32),
   (0,0,0,31,16,151,149,151,240,144,159,4,10,4),
   (0,238,68,255,0,126,90,90,126,0,255,66,165,66));
   Chain : string[12] = 'АБВГДВГДВГДВ';
   DelayMS : Word = 130;
   Color : Byte = 0;

Begin
  WipeFnt(5,128,0,16);
  QuietFnt(5,128,Seg(Fonts),Ofs(Fonts),0,14,Load); 
  HiddenCursor;
  ClrScr;
  GotoXY(2,23);
  TextAttr := 7;
  Write('286-BIOS (C) 1989 American Megatrends DK Inc.');
  GotoXY(2,24);
  Write('Press <Esc> to bypass MEMORY test');
  TextAttr := 14;
  GotoXy(68,25);
  FastFill(80,'.',25,1,12);
  ChangeAttribute(1,25,2,10);
  Repeat
    Write(Chain);
    GotoXy(WhereX - 1 - Length(Chain),25);
    Columns := 2;
    Rows := 25;
    Sound(20);
    Delay(10);Nosound;
    Delay(DelayMS);
    ClrEol;
    if Mem[0 : $41A] <> Mem[0 : $41C] then DelayMS := 20;
  Until WhereX = 1;
  Mem[0 : $41A] := Mem[0 : $41C];
  NormalCursor;
  TextAttr := 7;
  WriteLn('Press <CTRL-ALT-DEL> to run SETUP or DIAGS');
End.
