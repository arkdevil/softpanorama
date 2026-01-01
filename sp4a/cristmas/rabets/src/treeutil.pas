{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V-,X+}

unit TreeUtil;  { Вспомогательные подпрограммы Christmas-Tree }
                { Unit for ChristmasTree.  Edition 22-11-92.  V.S. Rabets }
interface

uses DOS, CRT, TreeGvar;

procedure Sorry (S: string);
function  EgaOrBetter: boolean;
procedure ClearKBDbuf;
function  ShiftPressed: boolean;
procedure KeyOrTimePause (t: longint);
procedure InitProcessEnd;
function  ProcessEnd (t: longint): boolean;
procedure SetOnePaletteRegister (EGAregister, RGBcolor: byte);
procedure SwapPalette;
procedure SetBeginPalette;
procedure TurnOffStars;
procedure TurnOnStars;
procedure LightStars;
procedure SetOriginPalette;


implementation

procedure Sorry (S: string);
begin
   SorryMessage:=S;
   halt;
end;

function EgaOrBetter: boolean;
var H487: byte absolute 0:$487;
begin
  EgaOrBetter:=(not CheckEGA) or
               (H487<>0) and (H487 and (8+2) = 0);
          {EGA present^}     {EGA active^ ^color}
end;

procedure ClearKBDbuf;
begin  while keypressed do readkey;  end;

const PredKBDfl: word = $FFff;
function ShiftPressed: boolean;
var KBDfl: word absolute 0:$0417;
begin
   ShiftPressed:=KBDfl>PredKBDfl;
   PredKBDfl:=KBDfl;
end;

procedure KeyOrTimePause (t: longint);
begin
   InitProcessEnd;
   repeat until ProcessEnd (t);
end;

procedure InitProcessEnd;
begin ClearKBDbuf;
      BeginTime:=CurrentTime;
end;

function ProcessEnd (t: longint): boolean;
begin
  ProcessEnd:= ( keypressed and (readkey in ProcessEndKeys) ) or
               ( not Pause and (CurrentTime-BeginTime>t) );
end;
{----------------------------^MIXT^---vPALETTEv------------}

const rl=32; RH=4;  { RGB colors }
      gl=16; GH=2;
      bl= 8; BH=1;

procedure SetOnePaletteRegister (EGAregister, RGBcolor: byte);
var R: registers;
begin
  with R do begin
    AX:=$1000;     { AH:=$10; AL:=0; }
    BL:=EGAregister;
    BH:=RGBcolor;
    intr ($10,R);
  end;
end;

procedure TurnOffStars;
begin
  if TurnStarsEnable then SetOnePaletteRegister (StarColor, GH+BH);
end;

procedure TurnOnStars;
begin
  if TurnStarsEnable then SetOnePaletteRegister (StarColor, RH+GH+BH);
end;

procedure LightStars;
begin
  if TurnStarsEnable then SetOnePaletteRegister (StarColor, RH+GH+rl+gl);
end;

procedure SwapPalette;
begin
  if PaletteHi then begin
     SetOnePaletteRegister (11, BH+GH);
     SetOnePaletteRegister (12, RH);
     SetOnePaletteRegister (13, BH+RH);
     SetOnePaletteRegister (14, RH+GH);
  end else begin
     SetOnePaletteRegister (11, BH+GH+ bl+gl);
     SetOnePaletteRegister (12, RH+    rl);
     SetOnePaletteRegister (13, BH+RH+ bl+rl);
     SetOnePaletteRegister (14, RH+GH+ rl+gl);
  end;
  PaletteHi:= not PaletteHi;
end;

procedure SetBeginPalette;
begin
  SetOnePaletteRegister ( 2, gl);
  SetOnePaletteRegister (10, GH);
  SetOnePaletteRegister ( 6, rl+gl);
  SwapPalette;
end;

procedure SetOriginPalette;
begin
  SetOnePaletteRegister (2, GH);
  SetOnePaletteRegister (10,gl+GH);
  SetOnePaletteRegister ( 6, RH+GH);
   PaletteHi:=false;
   SwapPalette;
end;

end.
