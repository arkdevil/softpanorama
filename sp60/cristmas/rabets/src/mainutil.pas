{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V-,X-}

unit MainUtil;  { Детализация TreeMain }
                { Unit for ChristmasTree.  Edition 22-11-92.  V.S. Rabets }
interface

uses DOS, CRT,
     TreeGvar, TreeUtil, TreGraph;

type StarType = record X,Y: integer; end;
     SnowType = record X,Y: integer; ColorSave: word;  end;
     SphereType=record R,H: integer; A: real; Size:byte; Color:byte;  end;
     ChainType =record R1,H1, R2,H2: integer;
                                     A: real; Size:byte; Color:byte;  end;
var Star : array [1..StarCount] of StarType;
    Storm: array [1..StormSnowFlakeCount] of SnowType;
    Snow : array [1..     SnowFlakeCount] of SnowType;
    Sphere:array [1..        SphereCount] of SphereType;
    Chain :array [1..         ChainCount] of ChainType;
    HorL, HorR: integer;  { Горизонт }
    TlastMoving, TS {TimeSpend}: longint;

procedure Sky;
procedure SkyLine;
procedure Forest;
procedure FirTree (X,Y, High: integer; ColorT,ColorB: byte; FullFill: byte);
procedure Wind (Color: byte);
procedure Hut;
procedure OpenStorm;
procedure MoveStorm;
procedure CloseStorm;
procedure OpenSnow;
procedure MoveSnow;
procedure CloseSnow;
procedure MakeSpheres;
procedure MakeChains;
procedure RotateFirTree;


implementation

const PredStarNum: word = 1;            { for BlinkStars }
      SavePixelColor: word = StarColor; { for BlinkStars }
var   BlinkSaveInt8: pointer;           { for BlinkStars }

{$F+}
procedure BlinkStars; interrupt;
begin
  asm pushF
      call dword ptr BlinkSaveInt8
      STI
  end;
  if GraphInProgress then exit;
  GraphInProgress:=true;
  with Star[PredStarNum] do BlinkPutPixel (X,Y, SavePixelColor);
            PredStarNum:=succ(random(StarCount));
  with Star[PredStarNum] do begin
       SavePixelColor:=BlinkGetPixel (X,Y);
       BlinkPutPixel (X,Y, SkyColor);
  end;
  GraphInProgress:=false;
end;
{$F-}

procedure MakeStars;
var w: word;
begin
  for w:=1 to StarCount div 2 do
  with Star[w] do
  begin X:=random(639);
        Y:=random(150);
        TreePutPixel (X,Y, StarColor);
  end;

  for w:=StarCount div 2 + 1 to StarCount do
  with Star[w] do
  begin X:=200+random(50);
        Y:=    random(200);
        TreePutPixel (X,Y, StarColor);
  end;
end;

procedure Moon;
begin
  SetColor(DarkMoonColor);
  circle ( 100,60, 10);
  SetFillStyle (SolidFill,DarkMoonColor);
  TreeFloodFill (100,60, DarkMoonColor);
  SetColor(SkyColor);
  Arc ( 90,60, 270,90, 14);
  SetFillStyle (SolidFill,LightMoonColor);
  TreeFloodFill (109,60, SkyColor);
end;

procedure Sky;
begin
  SetFillStyle (SolidFill, SkyColor);
  TreeFloodFill (0,0, SkyColor);
  MakeStars;
  GetIntVec (8, BlinkSaveInt8);
  if BlinkStarsEnable then SetIntVec (8, @BlinkStars);
  Moon;
end;

procedure SkyLine;
begin
  HorL:=250-random(50);  HorR:=260-random(10);  { HorR>HorL }
  SetColor (0);
  TreeLine (0,HorL, 639,HorR);
end;
{---------------------------^SKY^--vFORESTv----------------}

procedure FirTree (X,Y, High: integer; ColorT,ColorB: byte; FullFill: byte);
var Width,
    Ydec, Wdec: integer;
    b: byte;
begin
  TreeX:=X;                { global FirTree coordinate }
  TreeRadius:=High div 3;  { global FirTree coordinate }
  Width:=TreeRadius;
  Wdec:=Width div 8;
  Ydec:=High div 7;
  TreeBotY:=Y-Ydec;        { global FirTree coordinate }
  SetFillStyle (SolidFill, ColorT);
  TreeBar (X-Width div 6,Y, X+Width div 6,TreeBotY);
  SetColor (ColorB+8);
  SetFillStyle (SolidFill, ColorB);
  for b:=1 to 6 do
  begin
    dec (Y,Ydec);
    TreeTopY:=Y-round(Ydec*1.5);   { global FirTree coordinate }
    TreeLine ( X-Width,Y, X+Width,Y);
    TreeLine ( X-Width,Y, X, TreeTopY);
    TreeLine ( X+Width,Y, X, TreeTopY);
    TreeFloodFill (X,Y-1-Ydec*FullFill, ColorB+8);
    dec (Width,Wdec);
  end
end;

procedure Forest;
var X, Y: integer;
    UnderSnow,
    b: byte;
begin
  UnderSnow:= random(2);
  SetColor (ForestColor+8);
  for b:=1 to random(20)+20 do
  begin
    X:=random(500);
   {if HorL=HorR then Y:=HorL else}  { HorR>HorL }
      Y:= HorL + (HorR-HorL)*X div (639-X);
    FirTree (X,Y, random(50)+21, ForestColor,ForestColor, UnderSnow);
  end;
end;
{-----------------------------^FOREST^---vHUTv-------------}

procedure Wind (Color: byte);
var HorR_20, HorR_30, HorR_40: integer;
begin
    HorR_20:=HorR-20; HorR_30:=HorR-30; HorR_40:=HorR-40;
    SetFillStyle (SolidFill, Color);
    TreeBar  (135+1,HorR_20-1, 165-1,HorR_40+1);
    SetColor(Color+8);
    TreeLine (135,HorR_20, 165,HorR_20);
    TreeLine (135,HorR_30, 165,HorR_30);
    TreeLine (135,HorR_40, 165,HorR_40);
    TreeLine (135,HorR_20, 135,HorR_40);
    TreeLine (150,HorR_20, 150,HorR_40);
    TreeLine (165,HorR_20, 165,HorR_40);
end;

procedure Hut;
   procedure Roof;
   begin
       TreeLine ( 100,HorR-50, 150,HorR-75);
       TreeLine ( 200,HorR-50, 150,HorR-75);
       TreeLine ( 100,HorR-50, 200,HorR-50);
   end;
begin
    SetFillStyle (SolidFill, 0);
    TreeBar  ( 100,HorR,    200,HorR-50);
    SetColor(7); Roof;
    TreeFloodFill ( 150, HorR-60, 7);
    SetColor(8); Roof;
    Wind (0);
end;
{-------------------------------^HUT^---vSNOWv-------------}

procedure OpenStorm;
var w: word;
begin
  SetWriteMode(XORput);
  TlastMoving:=CurrentTime;
  for w:=1 to StormSnowFlakeCount do
  with Storm[w] do
  begin X:=139+random(500);
        Y:=random(250);
        ColorSave:=TreeGetPixel(X,Y);
        TreePutPixel (X,Y, StormColor);
  end;
end;

procedure MoveStorm;
var Down,
    Left,
    X1, X2, Y1, Y2: integer;
    w: word;
begin
  InitProcessEnd;
  repeat
    TS:=CurrentTime-TlastMoving;
    TlastMoving:=CurrentTime;
    Down:=integer(50)-random(100);
    Left:=TS*(640 div 18);  { 1 screen/sec }

    for w:=1 to StormSnowFlakeCount do
    with Storm[w] do
    begin
       if ColorSave<>StormColor then TreePutPixel (X,Y, ColorSave);
       X1:=X; Y1:=Y;
       dec (X,Left); dec (Y,Down);
       X2:=X; if X2<0   then X2:=0;
             {if X2>639 then X2:=639;} {Движение только влево}
       Y2:=Y; if Y2<0   then Y2:=0;
              if Y2>349 then Y2:=349;
       if random(32)=0 then  begin
          TreeLine (X1,Y1, Y2,Y2);
          TreeLine (X1,Y1, Y2,Y2);
       end;

       if X<0   then inc(X,640);
      {if X>639 then dec(X,640);} {Движение только влево}
       if Y<0   then inc(Y,350);
       if Y>349 then dec(Y,350);
      ColorSave:=TreeGetPixel(X,Y);
      TreePutPixel (X,Y, StormColor);
    end;
  until ProcessEnd (StormDuration);
end;

procedure CloseStorm;
var w: word;
begin
  for w:=1 to StormSnowFlakeCount do
  with Storm[w] do
    if ColorSave<>StormColor then TreePutPixel (X,Y, ColorSave);
end;

procedure OpenSnow;
var w: word;
begin
  TlastMoving:=CurrentTime;
  for w:=1 to SnowFlakeCount do
  with Snow[w] do
  begin X:=random(640);
        Y:=-350+(random(350));
  end;
end;

procedure MoveSnow;
var w: word;
begin
  InitProcessEnd;
  repeat
    TS:=CurrentTime-TlastMoving;
    TlastMoving:=CurrentTime;

    for w:=1 to SnowFlakeCount do
    with Snow[w] do begin
      if ColorSave<>SnowColor then TreePutPixel (X,Y, ColorSave);
      Y:=Y+ TS*(350 div 18 div 8) * succ(random(2)); { 1 screen / 8 sec }
      if Y>349 then dec(Y,350);
      ColorSave:=TreeGetPixel(X,Y);
      TreePutPixel (X,Y, SnowColor);
    end;
  until ProcessEnd (SnowDuration);
end;

procedure CloseSnow;
const SnowEndY = 400;
var w: word;
    SnowEnd: boolean;
begin
  repeat
    TS:=CurrentTime-TlastMoving;
    TlastMoving:=CurrentTime;
    if keypressed then SnowEndSpeedFactor:=SnowEndSpeedFactor*2; ClearKBDbuf;
    for w:=1 to SnowFlakeCount do
    with Snow[w] do begin
      if ColorSave<>SnowColor then TreePutPixel (X,Y, ColorSave);
      Y:=Y+ TS*(350 div 18 div 8) * succ(random(2)) * SnowEndSpeedFactor;
      if (Y<0) or (Y>349) then Y:=SnowEndY;
      ColorSave:=TreeGetPixel(X,Y);
      TreePutPixel (X,Y, SnowColor);
    end;
    SnowEnd:=true;
    for w:=1 to SnowFlakeCount do
     with Snow[w] do
      if Y<>SnowEndY then SnowEnd:=false;
  until SnowEnd;
end;
{--------------------------^SNOW^---vSPHERESv-vCHAINSv-----}

procedure ShowSphere (w: word);
var X: integer;
begin
  with Sphere[w] do begin
       SetColor(Color);
       if A<180 then
       begin
          X:=TreeX + round(cos(A/180*Pi)*R-Size*0.5);
          TreeRectangle (X,H, X+Size,H+Size);
       end;
  end;
end;

procedure MakeSpheres;
var tmp, w: word;
begin
  { SetWriteMode(XORput); }
  TlastMoving:=CurrentTime;
  with Sphere[1] do
    begin H:=TreeTopY-4; R:=0;  A:=0;  Size:=5; Color:=14 end;
  with Sphere[2] do
    begin H:=TreeTopY-4; R:=0; A:=180; Size:=5; Color:=14 end;
  for w:=3 to SphereCount do
  with Sphere[w] do
  begin Tmp:=TreeBotY-TreeTopY;
        H:= TreeBotY - random(Tmp-random(Tmp));
        R:=round (TreeRadius * (1-(TreeBotY-H)/Tmp) );
        A:=random(360);
        Size:=random(3)+2;
        Color:=random(8)+8;
  end;
  for w:=1 to SphereCount do ShowSphere (w);
end;

procedure ShowChain (w: word);
var X: integer;
begin
  with Chain[w] do begin
        if A<180 then
        begin
           X:=TreeX + round(cos(A/180*Pi)*TreeRadius);
           SetColor (succ(Color));
           SetLineStyle (1+w mod 3, 0, ThickWidth);
           TreeLine (TreeX,H1, X,H2);
           SetColor (Color);
           SetLineStyle (SolidLn, 0, NormWidth);
           TreeLine (TreeX,H1, X,H2);
        end;
  end;
end;

procedure MakeChains;
var w: word;
begin
  for w:=1 to ChainCount do
  with Chain[w] do begin
    R1:=0;        R2:=TreeRadius;
    H1:=TreeTopY; H2:=TreeBotY;
        A:=w*360/ChainCount;
        Color:=w+8;
        ShowChain(w);
  end;
end;
{---------------^SPHERES^-^CHAINS^---vROTATIONv------------}

procedure RotateFirTree;
var w: word;
    X: integer;
    IncAngle: real;
    Direction: shortint;
begin
  InitProcessEnd;
  ProcessEndKeys:=[];   { not break by any keys }
  Direction:=1;
  while not ( RotateFirTreeEnd or ProcessEnd (RotatFirTreeDuration) ) do
  begin
    TS:=CurrentTime-TlastMoving;
    TlastMoving:=CurrentTime;
    IncAngle:=TS*(360/18/16)*Direction;  { 1 turnover / 16 sec }
    for w:=1 to SphereCount do
    with Sphere[w] do begin
      ShowSphere (w);
      A:=A + IncAngle;
      if A>359 then A:=A-360;
      if A<0   then A:=A+360;
       Sphere[1].Color:=random(8)+8;
       Sphere[2].Color:=random(8)+8;
      ShowSphere (w);
    end;
    for w:=1 to ChainCount do
    with Chain[w] do begin
      ShowChain (w);
      A:=A + IncAngle;
      if A>359 then A:=A-360;
      if A<0   then A:=A+360;
      ShowChain(w);
    end;
    if ShiftPressed then Direction:=-Direction;
    if keypressed then if readkey=#27 then RotateFirTreeEnd:=true
                                      else SwapPalette;
                                    { Esc - end, other keys - swap palette }
  end; {while}
end;

end.
