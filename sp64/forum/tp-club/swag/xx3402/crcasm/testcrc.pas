
{$A+,B-,D-,E-,F-,I+,L-,N-,O-,R-,S-,V+}

{$M 8192,0,0}

{ TESTCRC - Simple test program for crc routines.  This program opens the
  file specified in the first command line parameter, computes three
  kinds of CRC, and writes them to stdout in hex.  Then it checks the
  peculiar behavior of the XModem CRC.  E. Floyd [76067,747], 10-29-89. }

program TestCRC;
uses CRC;
const
  BufSize = 32768;
type
  Str2 = string[2];
  Str4 = string[4];
  Str8 = string[8];
var
  Crc32 : longint;
  InFile : file;
  InBuf : array[1..BufSize] of byte;
  Len, Crc16, CrcArc, SaveCrc : word;

  function HexByte(b : byte) : Str2;
  const
    Hex : array[$0..$F] of char = '0123456789abcdef';
  begin
    HexByte := Hex[b shr 4] + Hex[b and $F];
  end;

  function HexWord(w : word) : Str4;
  begin
    HexWord := HexByte(hi(w)) + HexByte(lo(w));
  end;

  function HexLong(ww : longint) : Str8;
  var
    w : array[1..2] of word absolute ww;
  begin
    HexLong := HexWord(w[2]) + HexWord(w[1]);
  end;

BEGIN
  if paramcount < 1 then
    begin
      writeln('Run like: TESTCRC <filename>');
      writeln('Prints crc16, CrcArc and crc32 in hex');
    end
  else
    begin
      {$I-}
      assign(InFile, paramstr(1));
      reset(InFile, 1);
      {$I+}
      if ioresult = 0 then begin
        Crc16 := 0;                    { "XModem" crc starts with zero.. }
        CrcArc := 0;                   { ..as does ARC crc }
        Crc32 := $FFFFFFFF;            { 32 bit crc starts with all bits on }
        repeat
          blockread(InFile, InBuf, BufSize, Len);
          Crc16 := UpdateCrc16(Crc16, InBuf, Len);
          CrcArc := UpdateCrcArc(CrcArc, InBuf, Len);
          Crc32 := UpdateCrc32(Crc32, InBuf, Len);
        until eof(InFile);
        close(InFile);
        SaveCrc := Crc16;              { Save near-complete XModem crc for test below }
        fillchar(InBuf, 2, 0);         { Finish XModem crc with two nulls }
        Crc16 := UpdateCrc16(Crc16, InBuf, 2);
        Crc32 := not(Crc32);           { Finish 32 bit crc by inverting all bits }
        writeln('Crc16 = ', HexWord(Crc16), ', CrcArc = ', HexWord(CrcArc),
                ', Crc32 = ', HexLong(Crc32));
        { Now test for XModem crc trick - update the near-complete crc with.. }
        Crc16 := swap(Crc16);          { ..the complete crc in hi:lo order in memory. }
        writeln('XModem crc test = ', HexWord(UpdateCrc16(SaveCrc, Crc16, 2)));
        { The result should always be zero }
      end
    else
      writeln('Unable to open file ', paramstr(1));
    end;
END.
