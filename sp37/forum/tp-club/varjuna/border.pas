{$A-,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}
{$M 1024,0,0}
program Border;
uses
  TPCrt,
  Dos,
  TPString;
const
  Copyright : string [80] =
    'Set Screen Border Color '#4' Copyright (c) by Slon. '#4' Tallinn 1991';

  Colors : array [0..15] of string [20] = (
    'Black', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Brown',
    'LightGray', 'DarkGray', 'LightBlue', 'LightGreen', 'LightCyan',
    'LightRed', 'LightMagenta', 'Yellow', 'White');
  ShortColors : array [0..15] of string [3] = (
    'Bk', 'Bl', 'Gr', 'Cn', 'Rd', 'Mg', 'Br',
    'LGy', 'DG', 'LB', 'LGn', 'LC',
    'LR', 'LM', 'Ye', 'Wh');

  I : integer = -1;
  J : integer = -1;

  procedure WriteHelp;
  begin
    TextAttr := $07;
    Writeln(^M, Copyright);
    Writeln('Available only with CGA, EGA and VGA video cards.');
    Writeln('Usage: BORDER color');
    Writeln('  where color - word from the next set:');
    for I := 0 to 15 do Writeln(' ':3, Pad(ShortColors[I],3),' ':5, Colors[I]);
    Writeln;
    Writeln('Examples:     border red        - set red border');
    Write  ('   or         border ye         - set yellow border');
    Halt(1)
  end;

begin
  for J := 0 to 15 do if StUpcase(ParamStr(1)) = StUpcase(Colors[J])
    then I := J;
  for J := 0 to 15 do if StUpcase(ParamStr(1)) = StUpcase(ShortColors[J])
    then I := J;
  if I = -1 then WriteHelp;
  I := I shl 4;
  ReinitCrt;
  if CurrentDisplay in [CGA, EGA, VGA] then
    SetCrtBorder(Lo(I))
  else WriteHelp;
end.
{eof border.pas}
