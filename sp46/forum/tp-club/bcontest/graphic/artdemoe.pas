{$I defaults.inc}
Program ArtGraphDemo;
 { Program demonstrates ArtGraph functions }
Uses
  Crt,Graph, { standart TP unit }
  DArray,    { dynamic arrays manipulations }
  Globals,   { global definitions }
  MenuUtil,  { auxiliary procedures and functions }
  UtilUnit,  { auxiliary procedures and functions }
  ArtGraph,  { basic package unit }
  Present,   { presentational graphics unit }
  Spline,    { spline - interpolation }
  DynPlot;   { dynamical plotting }

const
  DynRows : longint = 500;
  ManualFN = 'Demoe.txt';
type
  ConstType = array[1..4] of Float;
const
  c1 : ConstType = (0.75,2,1,2);
  c2 : ConstType = (0.75,2,1,3.14);
  c3 : ConstType = (1.75,10,8,1.57);
  OldX : ConstType = (0,0,0,0);
  OldY : ConstType = (0,0,0,0);
var
  TextFN : text;

procedure  DemoText(N : integer; Cls : boolean);
  { Writes demonstrational comments }
const
  Delimiter = '###';
var
  MaxLen,WinWidth,WinHeight : integer;
  X1,X2,Y1,Y2,Code : integer;
  i,LastS : byte;
  DemoS : array[1..25] of AnyString;
  S : AnyString;
  Len : byte absolute S;
begin
  LastS := 0;
  MaxLen := 0;
  Repeat { Reading next text portion }
    Inc(LastS);
    Readln(TextFN,S);
    While S[Len] = ' ' do Delete(S,Len,1);
    If Len > MaxLen then MaxLen := Len;
    DemoS[LastS] := S;
  Until Pos(Delimiter,S) <> 0;
  S := Copy(S,Pos(Delimiter,S)+Length(Delimiter),
      Len - Pred(Pos(Delimiter,S)+Length(Delimiter)));
  Val(S,i,Code);
  If i <> N then
    NewError(not Fatal,'DemoText','Invalid text order',2);
  Dec(LastS);
  InitGraphMode;
  If LastS < 1 then Exit;
  MaxLen := MaxLen * CharWidth;

  SetTextStyle(0,HorizDir,2);

  If TextWidth(DemoS[1]) > MaxLen then MaxLen := TextWidth(DemoS[1]);
  WinWidth := MaxLen + 6 * CharWidth;
  WinHeight := Pred(LastS) * CharHeight * 3 div 2 + 9 * CharHeight;
  MaxField;
  If Cls then ClearViewPort;
  X1 := (GetMaxX - WinWidth) div 2;
  X2 := X1 + WinWidth;
  Y1 := (GetMaxY - WinHeight) div 2;
  Y2 := Y1 + Winheight;

  SetFillStyle(1,ComAttr div 16);
  Bar(X1,Y1,X2,Y2);

  SetColor(ActAttr div 16);
  SetLineStyle(SolidLn,0,ThickWidth);
  Rectangle(X1+6,Y1+5,X2-8,Y2-5);

  SetTextJustify(CenterText, TopText);
  SetColor(GetBkColor);
  OutTextXY(X1+WinWidth div 2,Y1+2*CharHeight,DemoS[1]);
  SetColor(Redattr and $F);
  OutTextXY(X1+WinWidth div 2 - 4,Y1+2*CharHeight-2,DemoS[1]);

  SetTextStyle(DefaultFont, HorizDir, 1);
  SetTextJustify(LeftText,TopText);
  SetColor(ComAttr and $F);
  For i := 2 to LastS do
    OutTextXY(X1 + 3 * CharWidth,
      Y1 + 3 * CharHeight + i*CharHeight*3 div 2,DemoS[i]);
  SetTextJustify(RightText,TopText);
  OutTextXY(X2 - 3 * CharWidth,
      Y2 - 2 * CharHeight,' SOFT-ARTEL group 1991');
  Pause
end; {DemoText}



{-------------- Functions used in dynamic plotting -------------}
{$F+}
function MyNRow(var X; j : longint) : longint;
Begin
  MyNRow := DynRows
End;

function CalcX(i,j : longint) : Float;
begin
  OldX[j] := OldX[j] + Sin(c1[j]*i + c2[j]*Sin(c3[j]*i));
  CalcX := OldX[j]
end;

function CalcY(i,j : longint) : Float;
const
  Attr : array[1..15] of string[2] =
    ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15');
begin
  DefLineColor(Attr[j],Attr[(i div 50 + j) mod 15 + 1]);
  OldY[j] := OldY[j] + Cos(c1[j]*i + c2[j]*Sin(c3[j]*i));
  CalcY := OldY[j]
end;
{______________________________________________________________}

function MyLabel(i : longint) : AnyString;
{ Labels for bar chart and pie chart }
var
  S : AnyString;
begin
  Str(1988+i,S);
  MyLabel := S
end;
{$F-}

var
  X,Y,B,P,H : AType; { Type imported from DArray unit }
  i,j : integer;
  GrDriver,GrMode : integer;

begin
  DriversPath := 'D:\TP55';
  If not Exists(ManualFN) then
    NewError(Fatal,'ArtDemo',ManualFN,8);
  Assign(TextFN,ManualFN);
  Reset(TextFN);

  {---------- Preparing data for graphics------------}
  MakeA(X,25,16);
  MakeA(Y,25,16);
  For j := 1 to ACol(X) do
    For i := 1 to ARow(Y) do begin
      LetA(X,i,j,i*4.8-j*0.3);
      LetA(Y,i,j,0.8*(j+20)*Sin(i*j/60))
    end;
   MakeA(B,3,7);
   MakeA(P,14,5);
   MakeA(H,100,2);

   Randomize;
   For j := 1 to ACol(B) do
    For i := 1 to ARow(B) do
      LetA(B,i,j,7.3 * i/j);
   For j := 1 to ACol(P) do
    For i := 1 to ARow(P) do
      LetA(P,i,j,Random * 10);

   For j := 1 to ACol(H) do
    For i := 1 to ARow(H) do
      LetA(H,i,j,(i-20)*j*Random);
   {_________________________________________________}

{---------------------------- Demo start-------------------------------------}
   InitGraphMode;
   DetectGraph(GrDriver,GrMode);
   If GrDriver <> EGA then
     NewError(not Fatal,'','Attention : Demo is tested in EGA mode only',101);
   DemoText(1,True);
   DemoText(2,True);

   { Plot procedure demo }
   DefMarker('1..16','0');
   DefLineStyle('1..16','1');
   Labels('Plot(X,Y) Procedure.      ArtGraph 3.0','Label X','Label Y');
   Plot(X,Y);
   DemoText(3,False);

   { Changing grid density }
   MaxGridsX := 20;
   MaxGridsY := 20;
   Labels('Grid Density Changed.     ArtGraph 3.0','Label X','Label Y');
   Plot(X,Y);
   MaxGridsX := 8;
   MaxGridsY := 8;
   DemoText(17,False);

   { 16 line styles demo }
   DefLineStyle('1..16','1..16');
   StrictPattern := True;  { Now line styles are strictly supported }
   Labels('16 Line Styles Available.   ArtGraph 3.0','Label X','Label Y');
   Plot(X,Y);
   DemoText(4,False);

   { 16 marker types demo }
   DefMarker('1..16','1..16');
   DefLineStyle('1..16','1');
   StrictPattern := False; { Now lines are drawn by TP procedures }
   Labels('16 Marker Types Available.    ArtGraph 3.0','Label X','Label Y');
   Plot(X,Y);
   DemoText(5,False);

   { Changing marker size }
   MarkerSize := 10;
   Labels('Change Marker Size.   ArtGraph 3.0','Label X','Label Y');
   Plot(X,Y);
   DemoText(6,False);

   { Thick lines demo }
   Labels('Line thickness can be changed.  ArtGraph 3.0','Label X','Label Y');
   DefThickness('1..16','3');
   DefLineStyle('1..16','1..16');
   DefMarker('1..16','0');
   StrictPattern := True;  { Now line styles are strictly supported }
   Plot(X,Y);
   DemoText(7,False);

   { SubPlot procedure demo }
   StrictPattern := False;  { Now lines are drawn by TP procedures }
   DefThickness('1..16','1');
   DefLineStyle('1..16','1');
   UseMenu := False;
   Labels('SubPlot Procedure. ArtGraph 3.0','','');
   MaxField;
   ClearViewPort;
   For i := 1 to 3 do begin
     SubPlot(2,2,i);
     Plot(X,Y);
   end;
{$IFDEF MENU}
   UseMenu := True;
{$ENDIF}
   SubPlot(2,2,4);
   Plot(X,Y);
   DemoText(8,False);

   { Reassigning axes limits }
   SubPlot(1,1,1);
   Axis(10,-10,60,30);
   Labels('Manual Axes Limits Reassigning.    ArtGraph 3.0','','Label Y');
   YLabelDirect := Horiz;
   Plot(X,Y);
   DemoText(9,False);

   { Square scaling demo }
   Labels('Square Plot Demonstration.    ArtGraph 3.0','','Label Y');
   YLabelDirect := Vert;
   Axis(Missing,Missing,Missing,Missing); { Automatic axes scaling }
   SquareOn(Vert,True);
   Plot(X,Y);
   DemoText(10,False);
   SquareOff;

   { Pie chart demo }
   GetLabel := MyLabel; { Assigning user label function }
   Labels('PieChart Demo.       ArtGraph 3.0','','');
   PulledOut := [2,5];  { Sectors pulled out }
   PieChart(P,1);
   DemoText(11,False);

   { Bar chart demo }
   GetLabel := MyLabel;
   Labels('BarChart Demo.       ArtGraph 3.0',
               'Profits In Branches; 1985 = 100%','%');
   BarSpace := 1;
   BarChart(B);
   DemoText(12,False);

   { Frequency histogram demo }
   Labels('Frequency Histogram','','');
   Hist(H,1);
   DemoText(17,False);

   { Combination of presentational graphics }
   Labels('"Thick" Bars  ArtGraph 3.0','','');
   Subplot(2,2,1);
   BarChart(B);
   ThickBar := False;
   Subplot(2,2,2);
   Labels('"Тhin" Bars  ArtGraph 3.0','','');
   BarChart(B);
   Subplot(2,2,3);
   Labels('PieChart  ArtGraph 3.0','','');
   PieChart(P,2);
   Subplot(2,2,4);
   Labels('Histogram  ArtGraph 3.0','','');
   Hist(H,2);

   {--------- Calculating data for spline --------}
   FreeA(X);
   FreeA(Y);
   MakeA(X,7,5);
   MakeA(Y,7,5);
   Randomize;
   For j := 1 to ACol(X) do
     For i := 1 to ARow(Y) do begin
       LetA(X,i,j,i*0.689);
       LetA(Y,i,j,Random*5.0)
     end;
   {______________________________________________}

   { Spline demo }
   DefMarker('1..16','1..16');
   DemoText(13,True);
   SplineType := Global;
   DefLineStyle('1..16','1..16');
   SubPlot(1,1,1);
   Labels('Spline Demo. Global And Local Splines. ArtGraph 3.0','','');
   PlotSpline(X,Y);

   HoldOn; { Next plot uses previosly established graph coordinates }
   SplineType := Local;
   DefLineColor('1..16','6..15');
   PlotSpline(X,Y);
   HoldOff;

   { Dynamic plot demo }
   DemoText(14,True);
   NRowX := MyNRow;  { Assigning max dots number }
   NRowY := MyNRow;
   DefMarker('1..16','0');

  {----------- Assigning dynamic plot windows------------}
  Labels('Window N1  ArtGraph 3.0','','');
  SubPlot(2,2,1);
  InitWindow(-0.5,-2.5,3.5,1.5,[1]);

  Labels('Window N2  ArtGraph 3.0','','');
  SubPlot(2,2,2);
  InitWindow(-2,-3,2,2,[2]);

  Labels('Window N3  ArtGraph 3.0','','');
  SubPlot(2,2,3);
  InitWindow(-1,-2.5,3,1.5,[3]);

  Labels('Window N4  ArtGraph 3.0','','');
  SubPlot(2,2,4);
  InitWindow(-3,-2.5,1.2,1.5,[4]);
  {___________________________________________________}

  DPlot(CalcX,CalcY);

  DemoText(15,False);
  DemoText(16,True);

  Close(TextFN);
  ExitGraphMode;
end.




