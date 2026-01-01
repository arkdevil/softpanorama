{ ╔═════════════════════════════════════════════════════════════════════════╗ }
{ ║  Демонстpация совместимости "Alpha-Graphics Mouse" с Turbo Proffesional ║ }
{ ║                                                                         ║ }
{ ║                    Copyright (c) V-LAB 1991,92                          ║ }
{ ╚═════════════════════════════════════════════════════════════════════════╝ }
program TP_Demo;
{$X+}

uses
  TPCrt,
  TPWindow,
  TPMenu,
  TPMouse,
  AGMouse;
{ ───────────────────────────────────────────────────────────────────────── }
const
  MenuEnable  : Boolean = False;
  Color1      : MenuColorArray = ($03, $00, $30, $0F, $30, $3F, $19, $07);
  Frame1      : FrameArray = NoFrame;
{ ───────────────────────────────────────────────────────────────────────── }
var
  EgaOrVga    : String;
  M           : Menu;
  Ch          : Char;
  Key         : MenuKey;
{ ═════════════════════════════════════════════════════════════════════════ }
procedure InitMenu(var M : Menu);
const
  Color2 : MenuColorArray = ($30, $00, $30, $0F, $3E, $3F, $19, $07);
  Frame2 : FrameArray = '┌└┐┘─│';
begin
  M := NewMenu([#187], nil);
  SubMenu(1,1,ScreenHeight,Horizontal,Frame1,Color1,'');
    MenuWidth(80);
    MenuItem('  VideoMode  ',3,0,1,' Set video-mode');
    SubMenu(3,2,ScreenHeight,Vertical,Frame2,Color2,'');
      MenuMode(False, True, False);
      MenuItem('  80 x 25  ',1,8,4,' 25 rows and 80 columns mode');
      MenuItem(EgaOrVga,2,8,5,' 43/50 rows and 80 columns mode');
      PopSublevel;
    MenuItem('  Mouse  ',16,0,8,' Set mouse mode');
    SubMenu(16,2,ScreenHeight,Vertical,Frame2,Color2,'');
      MenuMode(False, True, False);
      MenuItem(' Standart ',1,2,6,' Standart text mouse cursor');
      MenuItem(' Graphics ',2,2,7,' Alpha-graphics mouse cursor');
      PopSublevel;
    MenuItem('  Quit!  ',25,0,2,' Exit to DOS');
    MenuItem('  F1=About  ',68,0,3,' Show information about this program');
    PopSublevel;
  ResetMenu(M);
end;
{ ════════════════════════════════════════════════════════════════════════ }
procedure About;
const
  HelpMessage : array [1..8] of String [43] = (
  '    ALPHA - GRAPHICS MOUSE DEMO PROGRAM    ',
  '                                           ',
  'This program supported only EGA or VGA card',
  '   and Microsoft compatible mouse driver   ',
  '                                           ',
  '         Copyright V-LAB 1991,92           ',
  '                                           ',
  '          See also "AGM.DOC" ...           ');
var Win : WindowPtr;
    Mn  : Menu;
    I   : Byte;
begin
  Shadow:=True;
  SetFrameChars ('║','═','╝','╗','╚','╔');
  if MakeWindow(Win,15,6,65,19,True,True,False, $7F, $7F, $7F,'') then
   if DisplayWindow(Win) then
      begin
        for i:=1 to 8 do FastWriteWindow (HelpMessage[i],i+1,4,$70);
        Mn:=NewMenu([],Nil);
        SubMenu(36,17,ScreenHeight,Horizontal,Frame1,Color1,'');
        MenuWidth(8);
        MenuMode(False, False, False);
        MenuItem('   OK   ',1,0,1,' Continue...');
        ResetMenu (Mn);
        Key := MenuChoice (Mn,Ch);
        Ch:=#0;
        EraseMenu(Mn, True);
        DisposeWindow (EraseTopWindow);
      end;
end;
{ ═════════════════════════════════════════════════════════════════════════ }
procedure SetMode (Mode : MenuKey);
begin
 if MenuEnable then EraseMenu(M, False);
 if (Mode=3) or ((Mode=4) and (Font8x8Selected)) or
    ((Mode=5) and (not Font8x8Selected)) then begin
   case Mode of
  3,4:  TextMode (CO80);
    5:  TextMode (CO80+Font8x8);
   end;
   TextColor (White); TextBackGround (Blue); ClrScr;
   InitMenu(M);
   MenuEnable := True;
   ResetAGMouse;
 end;
end;
{ ═════════════════════════════════════════════════════════════════════════ }
procedure SetStandartMouse;
begin
 DisableAGMouse;
 MouseGotoXY (1,1);
 EraseMenu(M,True);
end;
{ ═════════════════════════════════════════════════════════════════════════ }
procedure SetGraphicsMouse;
begin
 EnableAGMouse;
 EraseMenu(M,True);
end;
{ ══════════════════════════ Основной модуль ══════════════════════════════ }
begin
 if not MouseInstalled then begin
    Writeln ('Mouse drive not installed. Program aborted !',Chr(7));
    Halt (1);
 end;
 case CurrentDisplay of
  EGA: EgaOrVga := '  80 x 43  '; 
  VGA: EgaOrVga := '  80 x 50  '; 
 else begin
       Writeln ('Program supported ONLY (!) EGA/VGA mode. Program aborted !',Chr(7));
       Halt (2);
      end;
 end;
 EnableAGMouse;     {  <───────────────  Подключение AGMouse                 }
 EnableMenuMouse;   {  <───────────────  Подключение мыши Turbo Proffesional } 
 SetMode (3);
 repeat
    Key := MenuChoice(M, Ch);
     case Ch of
       #187: About;
       #13 : case Key of
                 3: About;
               4,5: SetMode (Key);
                 6: SetStandartMouse;
                 7: SetGraphicsMouse;
             end;
     end;
 until (Key = 2) or (Ch = #27);
 DisableMenuMouse;
 DisableAGMouse;
 EraseMenu(M, False);
 TextMode (CO80);
end.