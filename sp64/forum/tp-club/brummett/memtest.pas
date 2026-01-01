program memtest;
uses newmem;

type intptr=^integer;
     arrayptr=^arraytype;
     arraytype=array[1..20] of word;


var b1,b2,b3:MemTypePtr;
    p1:intptr;
    p2,p3:arrayptr;
    q:byte;

begin

memdebug:=TRUE;

writeln('');

writeln('Allocating blocks...');
b1:=AllocateBuffer(1024,4);
b2:=AllocateBuffer(1024,2);
b3:=AllocateBuffer(1024,8);
p1:=MemGet(b1,sizeof(integer));
p2:=MemGet(b1,sizeof(arraytype));
p3:=MemGet(b1,sizeof(arraytype));

writeln('Setting Values...');
p1^:=3;
for q:=1 to 20 do begin
  p2^[q]:=q;
  p3^[q]:=2*q;
end;{for}

writeln('Printing values...');
writeln('p1=',p1^);
write('Press enter to go on...');
readln;

writeln('p2:');
for q:=1 to 20 do
  writeln(q,':  ',p2^[q]);
write('Press enter to go on...');
readln;

writeln('p3:');
for q:=1 to 20 do
  writeln(q,':  ',p3^[q]);
write('Press enter to go on...');
readln;

writeln('Freeing pointers...');
MemFree(b1,p1,sizeof(integer));
MemFree(b1,p2,sizeof(arraytype));
MemFree(b1,p3,sizeof(arraytype));
ReleaseBuffer(b1);
ReleaseBuffer(b2);
ReleaseBuffer(b3);

end.