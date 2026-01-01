var
  B08 : array[0..255,0..7] of byte;
  B14: array[0..255,0..13] of byte;
  B16: array[0..255,0..15] of byte;
  A14: array[1..20,0..14] of byte;
  A16: array[1..18,0..16] of byte;
  F: file;
  i: word;

begin
  Assign(F,'8x08.Fnt');
  Reset(F,1);
  BlockRead(F,B08,2048);
  Close(F);
  Assign(F,'8x14.Fnt');
  Reset(F,1);
  BlockRead(F,B14,3584);
  Close(F);
  Assign(F,'8x16.Fnt');
  Reset(F,1);
  BlockRead(F,B16,4096);
  Close(F);

  Assign(F,'viotbl.dcp');
  Reset(F,1);
  Seek(F,364);
  BlockWrite(F,B08,2048);
  Seek(F,2436);
  BlockRead(F,B14,3584);
  Seek(F,6044);
  BlockWrite(F,B16,4096);

  Seek(F,$27B4);
  BlockRead(F,A14,20*15);
  Seek(F,$28F8);
  BlockRead(F,A16,18*17);
  for i:= 1 to 20 do
    Move(B14[A14[i,0],0],A14[i,1],14);
  for i:= 1 to 18 do
    Move(B16[A16[i,0],0],A16[i,1],16);
  Seek(F,$27B4);
  BlockWrite(F,A14,20*15);
  Seek(F,$28F8);
  BlockWrite(F,A16,18*17);
  Close(F);
end.
