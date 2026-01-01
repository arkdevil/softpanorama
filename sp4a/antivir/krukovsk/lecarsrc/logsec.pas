Uses
  Crt,
  Disk;

Type
  PBuff = ^TBuff;
  TBuff = Array [0..$FFFE] of Byte;

Var
  Buff  : PBuff;
  I, J,
  Count : Word;
  SecPerRead : Word;
  Ch         : Char;

Begin
  ClrScr;
  GetMem(Buff, SizeOf(Buff));
  WriteLn('Partition table');
  If AbsRead($80, 0, 0, 1, 1, Buff^) <> 0 then Halt;
  For I := 0 to 511 do If Buff^[I] <> 7 then Write(Char(Buff^[I]));
  WriteLn;
  Ch := ReadKey;
  If Ch = 'p' then
    For I := 0 to 1023 do
    begin
      For J := 0 to 10 do 
        If AbsRead($80, I, J, 1, 17, Buff^) = 0 then 
          Write('Cylinder : ', I:4, ' Head : ', J : 2, #13);
    end;
  WriteLn('Boot sector');
  If DiskRead(2, 0, 1, Buff^) <> 0 then Halt;
  For I := 0 to 511 do If Buff^[I] <> 7 then Write(Char(Buff^[I]));
  WriteLn;
  Ch := ReadKey;
  J := Buff^[$0B] + Word(Buff^[$0C]) Shl 8;
  I := Buff^[$13] + Word(Buff^[$14]) Shl 8;
  WriteLn('Detected Total sector : ', I, '  ', 'Bytes per sector : ', J);
  WriteLn('Partition size : ', (I*Longint(J)) Div 1024, ' Kb');
  SecPerRead := SizeOf(TBuff) Div J;
  Count := 0;
  Repeat
    If DiskRead(2, Count, SecPerRead, Buff^) <> 0 then Halt;
    Inc(Count, SecPerRead);
    Write('Sector processed : ', Count:6, #13);
  Until Count >= I;
  FreeMem(Buff, SizeOf(Buff));
End.