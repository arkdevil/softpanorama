program memtest2;
uses newmem2;

type intptr=^integer;
     longptr=^longint;
     arraytype=array[1..40] of byte;
     arrayptr=^arraytype;

var p1,p2,p3,p4:descriptor;
    b1,b2,b3,b4:HeaderTypePtr;
    q:byte;

begin

  writeln('********* Allocating buffers ********');
  MemDebug:=TRUE;
  writeln;
  b1:=AllocateBuffer(100,4);
  writeln;
  b2:=Allocatebuffer(100,8);
  writeln;
  b3:=AllocateBuffer(100,1);
  writeln;
  b4:=AllocateBuffer(100,50);

  writeln('********* Assigning values *********');

  writeln;
  MemGet(p1,b1,2);
  writeln('p1=',HexStr(seg(p1.addr^)),':',HexStr(ofs(p1.addr^)));
  intptr(p1.addr)^:=15;
  MemSwapOn('swap.fil',210);

  writeln;
  MemGet(p2,b2,2);
  intptr(p2.addr)^:=20;
  writeln('p2=',HexStr(seg(p2.addr^)),':',HexStr(ofs(p2.addr^)));

  writeln;
  MemGet(p3,b3,2);
  intptr(p3.addr)^:=10;
  writeln('Should swap now. p3=',HexStr(seg(p3.addr^)),':',HexStr(ofs(p3.addr^)));

{Comment out the next line to get a segmentation violation when printing
 the value of p4}
  MemGet(p4,b1,10);

  writeln('********* Printing values *********');

  writeln('p1=',intptr(p1.addr)^);
  writeln('p2=',intptr(p2.addr)^);
  writeln('p3=',intptr(p3.addr)^);
  writeln('p4=',intptr(p4.addr)^);

  MemGet(p4,b1,4);
  longptr(p4.addr)^:=300000;

  writeln('p1=',intptr(p1.addr)^);
  writeln('p2=',intptr(p2.addr)^);
  writeln('p3=',intptr(p3.addr)^);
  writeln('p4=',longptr(p4.addr)^);

  MemFree(p4,4);

  writeln('********* Allocating 40 byte array *********');
  MemGet(p4,b1,sizeof(ArrayType));

  writeln('********* Filling array *********');
  for q:=1 to 40 do
    arrayptr(p4.addr)^[q]:=q;

  writeln('********* Swapping array *********');
  SwapBlock(b1);

  writeln('********* Reading array values *********');
  for q:=1 to 40 do
    writeln('p4[',q,']=',arrayptr(p4.addr)^[q]);

  writeln('********* Lock test *********');
  MemLock(b1,TRUE);
  MemLock(b2,TRUE);
  writeln('This should kill it');
  writeln('p3=',intptr(p3.addr)^);

  MemSwapOff;

end.

