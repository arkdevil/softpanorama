{$B-,D-,F-,I+,R-,S-,V-}
program CRCTest;

  uses TPString, CRC32;

  var
    InpFN: string;
    CRC: longint;

begin
  repeat
    Write('Input filename? '); Readln(InpFN);
    if CRCFile(InpFN, CRC) = 0 then
      Writeln('File ', StUpcase(InpFN), ' has CRC-32 = $',HexL(CRC))
    else
      Writeln('Error in file ', StUpcase(InpFN));
  until InpFN = '';
end.



