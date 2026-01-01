{$A-,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}
{$M 8096,0,0}

program peekpoke;

(***********************************************************************
 NOTICE
 ======
     This program and every file distributed with it are copyright (C)
 by the authors, who retain authorship both of the pre-compiled and 
 compiled codes.  Their use and distribution are unrestricted, as long
 as nobody gets any richer in the process.  Although these programs 
 were developed to the best of the authors abilities, no guarantees
 can be given as to their performance.  By using them, the user
 accepts all risks and the authors decline all liability. 
************************************************************************)

uses crt;

var
  p1, p2, p3, p4, p5 : string;
  code               : integer;
  segw, ofsw         : word;
  by, oldby          : byte;
  byt                : longint;


{ ************************************************** }
{ Tranforms a word into a hex number string.         }
{ Taken from MEMMAP in PC Mag, Jun 12 1990, p. 343.  }
{ -Jose-                                             }
{ ************************************************** }
function w2x(w: word): string;
const hexdigit: array[0..15] of char = '0123456789ABCDEF';
begin
  w2x:= hexdigit[hi(w) shr 4] + hexdigit[hi(w) and $0F] +
        hexdigit[lo(w) shr 4] + hexdigit[lo(w) and $0F];
end;


{ ************************************************** }
{ Tranforms a byte into a binary number string.      }
{ This one may not be as elegant, but it is mine...  }
{ -Jose-                                             }
{ ************************************************** }

function power(a,b:real):real;
begin
  power:= exp(b * ln(a));
end;

function byte2binstr(by: byte): string;
var
  i: integer;
  pow : integer;
  bit : byte;
  strbit : string[1];
  strbin : string[8];
begin
  strbin:= '';
  for i:= 7 downto 0 do begin
    pow:= round(power(2,i));
    bit:= by div pow;
    str(bit,strbit);
    strbin:= strbin + strbit;
    by:= by - pow * bit;
  end;
  byte2binstr:= strbin;
end;


procedure error;
begin
  writeln('Program PeekPoke v. 1.2');
  writeln('Copyright (c) J. Campione/C.R.Parkinson.');
  writeln('April 29 1991.');
  inc(textattr,128);
  write('   WARNING!');
  dec(textattr,128);
  writeln(' This program can modify the memory of your computer...');
  writeln('   - Peek : <d:>\<path>\pp e $SEGW:$OFSW <!> <return>');
  writeln('   - Poke : <d:>\<path>\pp o $SEGW:$OFSW <byte value> <!> <return>');
  writeln('   In both cases the peeked old byte value is returned as the errorlevel.');
  writeln('   The segment and offset words can be entered as $hex or dec numbers.');
  writeln('   The optional "!" parameter causes the display of the byte value.');
  halt(1);
end;


begin

  { *********************** }
  { Process first parameter }
  { *********************** }
  p1:=  paramstr(1);
  if (ord(p1[0]) <> 1) or not (upcase(p1[1]) in ['E','O']) then error;
  if (upcase(p1[1]) = 'E') and (paramcount < 2) then error;
  if (upcase(p1[1]) = 'O') and (paramcount < 3) then error;

  { ********************************** }
  { process second parameter (address) }
  { ********************************** }
  p2:=  paramstr(2);
  p3:= copy(p2,1,pos(':',p2)-1);
  val(p3,segw,code);
  if (code <> 0) or (segw < 0) then error;
  p4:= copy(p2,pos(':',p2)+1,ord(p2[0])-pos(':',p2));
  val(p4,ofsw,code);
  if (code <> 0) or (ofsw < 0) then error;

  { ********************************** }
  { Process 3rd parameter (byte value) }
  { ********************************** }
  if upcase(p1[1]) = 'O' then begin
    p5:= paramstr(3);
    val(p5,byt,code);
    if (byt > 255) or (byt < 0) then error else by:= byt;
    if code <> 0 then error;
  end;

  { ***************************** }
  { Take action and report result }
  { ***************************** }
  oldby:= mem[segw:ofsw];
  if upcase(p1[1]) = 'O' then mem[segw:ofsw]:= by;
  if (paramstr(3) = '!') or (paramstr(4) = '!') then begin
    if upcase(p1[1]) = 'O' then begin
      writeln('old mem[',w2x(segw),'h:',w2x(ofsw),'h] = ',oldby,'d, ',w2x(oldby),'h, ',byte2binstr(oldby),'b.');
      writeln('new mem[',w2x(segw),'h:',w2x(ofsw),'h] = ',by,'d, ',w2x(by),'h, ',byte2binstr(by),'b.');
    end else writeln('mem[',w2x(segw),'h:',w2x(ofsw),'h] = ',oldby,'d, ',w2x(oldby),'h, ',byte2binstr(oldby),'b.');
  end;
  halt(oldby);

end.