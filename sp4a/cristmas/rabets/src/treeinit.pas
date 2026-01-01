{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V-,X-}

unit TreeInit;  { Инициализация Christmas-Tree }
                { Unit for ChristmasTree.  Edition 21-11-92.  V.S. Rabets }
interface

uses DOS, CRT,
     TreeGvar, TreeUtil, TreGraph;

procedure V_LESU_RODILAS_YOLOCHKA  (S: string);

{---------------------------------------------------------------------------}
implementation

procedure V_LESU_RODILAS_YOLOCHKA  (S: string);
var Par: string;
    Pw: word absolute Par;
    b: byte;
begin
  CopyRight:=S;
  if ParamCount>0 then for b:=1 to ParamCount do
  begin Par:=ParamStr(b);
        if (Par[1]='-') or (Par[1]='/') then delete (Par,1,1);
        Par[1]:=UpCase(Par[1]);
        case Pw of
             ord('M')*256+1 {#1'M'} : Music := false;
             ord('P')*256+1 {#1'P'} : Pause := true;
             ord('B')*256+1 {#1'B'} : BlinkStarsEnable:= false;
             ord('T')*256+1 {#1'T'} : TurnStarsEnable := false;
             ord('C')*256+1 {#1'C'} : CheckEGA:= false;
             ord('?')*256+1,{#1'?'}
             ord('H')*256+1 {#1'H'} : halt;
             else Sorry ('Unknown parameter '+Par);
        end;
  end;
  if not EgaOrBetter then Sorry ('EGA or better required');
  OpenGraphMode;
  SetBeginPalette;
end;

procedure TextScreen;
var b: byte;
begin
   TextAttr:=$F; writeln (CopyRight);
   TextAttr:=7;
                 writeln ('FreeSourceWare':67);
  writeln ('Usage:  !ChrTree [m] [p] [b] [t] [c]'#10);
  writeln ('        m - NO music');
  writeln ('        p - pauses (wait any key)');
  writeln ('        b - NO blink stars');
  writeln ('        t - NO turn On/Off stars');
  writeln ('        c - NO check video adapter'#10);
  writeln ('At least color EGA required.'#10);
   TextAttr:=3;
  writeln ('    22-11-92               e-mail:   rabets@icph20.sherna.msk.su');
  writeln ;
  writeln ('   В.С. Рабец             Address:   142 432');
  writeln ('                                     Московская обл.');
  writeln ('                                     Ногинский р-н');
  writeln ('                                     п. Черноголовка');
  writeln ('                                     Школьный б-р, 18, кв. 241');
  writeln ('                                     Рабцу В.С.');
   TextAttr:=$70;
    if ExitCode=255 then SorryMessage:='Ctrl-Breack pressed';
    if SorryMessage<>'' then write (' Sorry, ', SorryMessage, ' ');
  TextAttr:=7;
end;
{---------------------------------------------------------------------------}

var SaveExitProc: pointer;

procedure ExitProcedure; far;
begin
  ExitProc:=SaveExitProc;
  SetIntVec (8, SaveInt8);
  CheckBreak:=false;
  TextMode (CO80);
  SetOriginPalette;
  TextScreen;
  NoSound;
  ClearKBDBuf;
end;

begin
  GetIntVec (8, SaveInt8);
  SaveExitProc:=ExitProc;  ExitProc:=@ExitProcedure;
  randomize;
end.
