{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V-,X-}

unit TreeGvar;  { Глобальные константы и переменные }
                { Unit for ChristmasTree.  Edition 22-11-92.  V.S. Rabets }
interface

const translated_to_TP60_by_Rabets = #10+
 'Christmas-Tree (В лесу родилась елочка).  Ver.1.00  (C) V.S. Rabets, 1992';
var CopyRight: string;

const SorryMessage: string = '';

      Music  : boolean = true;
      Pause  : boolean = false;
      BlinkStarsEnable: boolean = true;
      TurnStarsEnable : boolean = true;
      CheckEGA :        boolean = true;

      StarColor  = 7; { Меняется палитра в TurnOnPalette, -Off-, -Light- ! }
      SkyColor   = 1;
      ForestColor= 0;
      StormColor = $F;
      SnowColor  = $F;
      DarkMoonColor  = 9;
      LightMoonColor = StarColor;

      StarCount = 200;
      StormSnowFlakeCount = 200;
           SnowFlakeCount = 600;
      SphereCount = 40;
      ChainCount = 8;

      ProcessEndKeys: set of char = [#0..#255];
      PauseBetweenEvents=2*18;  { sec*(tick/sec) }
      StormDuration = 20*18;    { sec*(tick/sec) }
       SnowDuration = 20*18;    { sec*(tick/sec) }
      SnowEndSpeedFactor: byte = 2;
      RotatFirTreeDuration=10*18;{sec*(tick/sec) }
      TurnOffPictureDuration = 2000; { msec }

      GraphInProgress: boolean = false;
      PaletteHi:       boolean = true;
      RotateFirTreeEnd:boolean = false;

var CurrentTime: longint absolute 0:$46C;  { BIOS timer tick counter }
    BeginTime: longint;  {Process beginning time (ticks) }
    SaveInt8: pointer;

    TreeX,
    TreeRadius,
    TreeBotY,
    TreeTopY: integer;

implementation

end.
