unit gid;
interface
uses
  Crt,Graph;
const
  OFF = 0;
  ON  = 1;
  BARCOD = 2;
  BAR3COD = 3;
  PLAYCOD = 4;
  GRAFCOD = 5;
  MAXBAR = 18;
  MAXPlAY = 10;
  MAXSTRING = 10;
  MAXGRAF = 5;
  MAXPOINT = 25;

type
  DatBarTyp = record
     Color : word;
     Font  : word;
     X     : word;
     Y     : word;
     Text  : string[13];
   end;

  DatPlayTyp = record
     Prozent :  real;
     Color   : word;
     Font    : word;
     Text    : string[13];
   end;

  DatGrafTyp = record
     Common                   : integer;
     Color                    : word;
     Ln                       : word;
     X     : array[1..MAXPOINT] of  real;
     Y     : array[1..MAXPOINT] of  real;
     Text : string[13];
   end;
  GrafixTyp = record
     Name                     : string[40];
     LabeX,LabeY              : string[10];
     Flag,X_Flag,Y_Flag       : integer;
     x1,x2,y1,y2              : integer;
     Xstep,Ystep,Xmax,Ymax    : integer;
     Xmin,Ymin                : integer;
     Cursiv                   : integer;
     Common                   : integer;
     TextX : array[1..MAXSTRING] of  string[10];
     TextY : array[1..MAXSTRING] of  string[10];
     case Cod : 2..6 of
       BARCOD  ,
       BAR3COD : (Bar : array[1..MAXBAR]  of DatBarTyp );
       PLAYCOD : (Play: array[1..MAXPLAY] of DatPlayTyp);
       GRAFCOD : (Graf: array[1..MAXGRAF] of DatGrafTyp);
   end;
var
  DatGid      : array[1..5] of GrafixTyp;
  MaxX, MaxY  : word;     { The maximum resolution of the screen }
  MinX, MinY  : word;     { The minimum resolution of the screen }

procedure Initialize;
function StartGid(NambeDispl : integer) : integer;
procedure CloseGid(Kz : integer);

implementation
const
  Sd = 3;
  SCICOD = 6;
  LABE = 8;
var
  GraphDriver : integer;  { The Graphics device driver }
  GraphMode   : integer;  { The Graphics mode value }
  ErrorCode   : integer;  { Reports any graphics errors }
  MaxColor    : word;     { The maximum color value available }
  OldExitProc : Pointer;  { Saves exit procedure address }
  AdrWindow   : array[1..6] of Pointer;
  SizeWindow  : word;
  Page        : word;
  Size        : word;
  Adr         : pointer;
  Ch          : char;
  Index       : 0..5;

{$I CloseGid.imp}
{$I Init.imp}
{$I WordProc.imp}
{$I HaveProc.imp}
{$I PiePlay.imp}
{$I BarPlay.imp}
{$I GrafPlay.imp}
{$I StartGid.imp}
end .
