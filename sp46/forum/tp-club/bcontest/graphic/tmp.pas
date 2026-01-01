{$I defaults.inc}  { compiler directives }
Program ArtGraphTest;
Uses
  Graph,     { standart TP unit }
  DArray,    { dynamic arrays manipulations }
{---- Include this units to test Present/Spline/DynPlot routines ----}
  Present,   { presentation graphics unit }
  Spline,    { spline-interpolation }
  DynPlot,   { dynamic plotting }
{____________________________________________________________________}

  Globals,   { global definitions }
  ArtGraph;  { basic package unit }
var
  X,Y : AType;
  i,j : integer;

begin
  MakeA(Y,105,2);
  Randomize;
  For i := 1 to ARow(Y) do begin
    LetA(Y,i,1,i -10- Random);
  {  For j := 1 to ACol(Y) do
      LetA(Y,i,j,Random); }
  end;
  TickLen := -4;
  Hist(Y,1);
end.

