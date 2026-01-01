{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V-,X-}

unit TreGraph;  { Прерывающая себя графика }
                { Unit for ChristmasTree.  Edition 22-11-92.  V.S. Rabets }
interface

uses Graph, TreeGvar, TreeUtil;

procedure OpenGraphMode;

const SetColor :    procedure (Color: word)         = Graph.SetColor;
      SetWriteMode: procedure (WriteMode: integer)  = Graph.SetWriteMode;
      SetLineStyle: procedure (LineStyle, Pattern, Thickness: word)
                                                     = Graph.SetLineStyle;
      SetFillStyle: procedure (Pattern, Color: word) = Graph.SetFillStyle;
      Circle: procedure (X,Y: integer; Radius: word) = Graph.Circle;
      Arc :   procedure (X,Y: integer; StAngle, EndAngle, Radius: word)
                                                     = Graph.Arc;
      BlinkPutPixel: procedure (X,Y: integer; Pixel: word) = Graph.PutPixel;
      BlinkGetPixel: function  (X,Y: integer): word        = Graph.GetPixel;

      XORput    = Graph.XORput;
      NormWidth = Graph.NormWidth;
      ThickWidth= Graph.ThickWidth;
      SolidLn   = Graph.SolidLn;
      SolidFill = Graph.SolidFill;

procedure      TreeLine (x1,y1, x2,y2: integer);
procedure       TreeBar (x1,y1, x2,y2: integer);
procedure TreeRectAngle (x1,y1, x2,y2: integer);
procedure TreeFloodFill (X,Y: integer; Border:word);
procedure  TreePutPixel (X,Y: integer; Pixel: word);
function   TreeGetPixel (X,Y: integer): word;
{----------------------------------------------------------}

implementation

procedure EgaVgaDriver; external;
 {$L EGAVGA.OBJ }

procedure OpenGraphMode;
var GrDr, GrMode, ErrCode: integer;
begin
  GrDr:=EGA {3}; GrMode:=EgaHi {1};
  if RegisterBGIdriver (@EgaVgaDriver) >= 0 then InitGraph (GrDr,GrMode,'');
  ErrCode:=GraphResult;
  if ErrCode <> grOk then Sorry ('Graphics init error:'#13#10'     ' +
                                      GraphErrorMsg (ErrCode) );
end;
{---------------^INIT^----vINTERRUPTEDv--------------------}

procedure TreeLine (x1,y1, x2,y2: integer);
begin
  GraphInProgress:=true;
    Line (x1,y1, x2,y2);
  GraphInProgress:=false;
end;

procedure TreeBar (x1,y1, x2,y2: integer);
begin
  GraphInProgress:=true;
    Bar (x1,y1, x2,y2);
  GraphInProgress:=false;
end;

procedure TreeRectAngle (x1,y1, x2,y2: integer);
begin
  GraphInProgress:=true;
    RectAngle (x1,y1, x2,y2);
  GraphInProgress:=false;
end;

procedure TreeFloodFill (X,Y: integer; Border: word);
begin
  GraphInProgress:=true;
    FloodFill (X,Y, Border);
  GraphInProgress:=false;
end;

procedure TreePutPixel (X,Y: integer; Pixel: word);
begin
  GraphInProgress:=true;
    PutPixel (X,Y, Pixel);
  GraphInProgress:=false;
end;

function TreeGetPixel (X,Y: integer): word;
begin
  GraphInProgress:=true;
    TreeGetPixel:=GetPixel (X,Y);
  GraphInProgress:=false;
end;

end.
