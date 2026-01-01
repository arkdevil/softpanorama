{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,R-,S-,V-,X+}
{$M 63840,0,655360}
{$IFNDEF Ver60}
   Sorry, this program can work under Turbo 6.0 only...
{$ENDIF}
uses
  Crt,
  Dos,
  Graph,
  Drivers,
  VgaJokes;

const
  Key : word  = kbGrayPlus;

  ProcCount   = 9;
  CurrentProc : word = 0;
  PrevProc    : word = 0;

var
  I, J, C, D : word;
  S : string;
  F : file;

  function ValidKeyPressed: boolean;
  begin
    ValidKeyPressed := False;
    if not KeyPressed then Exit;
    Key := ReadLastKey;
    case Key of
      kbEsc,
      kbGrayPlus,
      kbGrayMinus : ValidKeyPressed := True
    end
  end;

  procedure Wait;
   begin
    repeat until ValidKeyPressed
  end;

  procedure AsciiChart(X, Y, A : byte);
  var
    I, J : word;
  begin
    DrawFrame(Y, X, Y + 49, X + 17, A);
    Inc(X);
    Inc(Y);
    J := Y;
    for I := 1 to 256 do begin
      FastWrite(' '+char(pred(I))+' ', X, J, A);
      Inc(J, 3);
      if I mod 16 = 0 then begin
        Inc(X);
        J := Y
      end;
    end;
  end;

  procedure ColorsChart(T : string);
  var
    A : byte;
  begin
    DrawFrame(7, 7, 74, 24, White);
    for I := 0 to 15 do begin
      for J := 0 to 15 do begin
        A := (J shl 4) + I;
        FastWrite(T, I + 8, J * 4 + 9, A)
      end
    end
  end;

  procedure FirstScreen;
    procedure GreenFlash;
    begin
      repeat
        for I := 20 to 63 do begin
          Delay(70);
          WaitVerticalRetrace;
          SetColorReg(Green, I, I, 0);
          SetColorReg(Red, 83 - I, 0, 0);
          if ValidKeyPressed then Exit
        end;
        for I := 63 downto 20 do begin
          Delay(70);
          WaitVerticalRetrace;
          SetColorReg(Green, I, I, 0);
          SetColorReg(Red, 83 - I, 0, 0);
          if ValidKeyPressed then Exit
        end
      until False
    end;

  begin
    SetVideoMode(CO80);
    ResetScreen;
    LoadRusFont(ft8x16);
    CursorOff;
    SetBlinkOn(False);
    ScreenOff;
    DrawTitle(2,  4, $3E);
    DrawTitle(3,  7, $9E);
    DrawTitle(4, 10, $1E);
    SetPaletteReg(Cyan, 11);
    ScreenOn;
    for I := 0 to 17 do begin
      Delay(20);
      WaitVerticalRetrace;
      SetColorReg(Black, I, I, I);
    end;
    SetBorderColor(1);
    FastWrite('VGA Jokes  Beta Release', 2, 51, Red);
    FastWrite('Created by Serge N. Varjukha', 3, 51, Red);
    FastWrite('Copyright № 1992, 93', 4, 51, Red);
    FastWrite('You can contact with me:', 6, 51, Red);
    FastWrite('Tallinn, Estonia', 7, 51, Red);
    FastWrite('Call: (0142) 666 500', 8, 51, Red);
    for I := 0 to 63 do begin
      Delay(20);
      if ValidKeyPressed then Exit;
      WaitVerticalRetrace;
      SetColorReg(Red, I, 0, 0);
    end;
    DrawFrame(4, 10, 77, 24, Cyan);
    SetColorReg(Green, 17, 17, 17);
    FastWrite('This Demo Program presents VGAJokes - the library of video functions', 11, 8, Green);
    FastWrite('designated for using on MCGA, VGA adapters. VGAJokes was developed for', 12, 6, Green);
    FastWrite('Turbo Pascal 6.0 users only. Please excuse me all Turbo 3.0 fans!', 13, 6, Green);
    FastWrite('To control this Demo Program use the next keys:', 14, 8, Green);
    FastWrite('Gray Plus  - Next Demo page.', 15, 20, Green);
    FastWrite('Gray Minus - Previous Demo page.', 16, 20, Green);
    FastWrite('Esc        - leave the Demo.', 17, 20, Green);
    FastWrite('VGAJokes is free to use, copy and distribute for non-commercial use.', 18, 8, Green);
    FastWrite('If You find VGAJokes useful, You are encouraged to send the modest', 19, 6, Green);
    FastWrite('donation of $10 or 600 soviet roubles to address:', 20, 6, Green);
    FastWrite('200004, Kopli 86 - 51', 22, 6, Green);
    FastWrite('Tallinn, Estonia', 23, 6, Green);
    FastWrite('Serge N. Varjukha', 23, 59, Green);
    GreenFlash
  end;

  procedure Information;
  begin
    SetVideoMode(CO80);
    SecondCharSet(0);
    CursorOff;
    SetPaletteReg(Black, 56);
    DrawFrame(2, 1, 79, 25, Red);
    FastWrite('About 100 useful functions classified to the next groups', 2, 12, Yellow);
    FastWrite('────────────────────────────────────────────────────────', 3, 12, Red);
    FastWrite('Information', 4, 4, Yellow);
    FastWrite('  a) Video parameters', 5, 4, White);
    FastWrite('  b) Resident programs', 6, 4, White);
    FastWrite('Screen', 8, 4, Yellow);
    FastWrite('  a) Modes', 9, 4, White);
    FastWrite('  b) Sizes', 10, 4, White);
    FastWrite('  c) Movings', 11, 4, White);
    FastWrite('  d) Scrolling', 12, 4, White);
    FastWrite('Digital-to-Analog-Converter (DAC)', 14, 4, Yellow);
    FastWrite('  a) Save/restore all DAC color registers', 15, 4, White);
    FastWrite('  b) Settings any color register', 16, 4, White);
    FastWrite('Palette', 18, 4, Yellow);
    FastWrite('  a) Save/restore all palette registers', 19, 4, White);
    FastWrite('  b) Settings any palette register', 20, 4, White);
    FastWrite('Fonts', 22, 4, Yellow);
    FastWrite('  a) Russian & estonian alphabets support', 23, 4, White);
    FastWrite('  b) Character Sets switching', 24, 4, White);
    FastWrite('Cursor, Keyboard and Mouse', 4, 47, Yellow);
    FastWrite('Screen border', 5, 47, Yellow);
    FastWrite('  a) Colors', 6, 47, White);
    FastWrite('  b) Width', 7, 47, White);
    FastWrite('Split Screens', 9, 47, Yellow);
    FastWrite('  a) Setup Split Screens', 10, 47, White);
    FastWrite('  b) FastWrite for Screen A', 11, 47, White);
    FastWrite('Video savings', 13, 47, Yellow);
    FastWrite('  a) Save screen in text modes', 14, 47, White);
    FastWrite('  b) Save VGA state', 15, 47, White);
    FastWrite('  c) Save downloaded fonts', 16, 47, White);
    FastWrite('VGA BIOS operations', 18, 47, Yellow);
    FastWrite('  a) Resets VGA BIOS', 19, 47, White);
    FastWrite('  b) Calling BIOS int 10h', 20, 47, White);
    FastWrite('Video pages', 22, 47, Yellow);
    FastWrite('  a) 8 text pages support', 23, 47, White);
    FastWrite('  b) 16 text pages support', 24, 47, White);
    Wait;
    if Key = kbGrayPlus then
      for I := 0 to 399 do
       if ValidKeyPressed then Exit else VerticalScroll(I);
  end;

  procedure ScreenSizes;

    procedure DemoSize(R, Code : byte);
    begin
      SetVideoMode(CO80);
      ResetScreen;
      case Code of
        1 : ;
        2 : SetScreenSize(R, 82);
        3 : SetScreenRows(R);
        4 : BigScreen;
        5 : ElegantScreen;
        6 : RoyalScreen(English);
        7 : CgaScreen(English);
        8 : EgaLongScreen(English);
        9 : CheapScreen(English);
       10 : MediumScreen
      end;
      CursorOff;
      SetPaletteReg(Black, 33);
      SetBorderColor(Red);
      SetPaletteReg(Black, 56); {32, 24, 40}
      DrawFrame(18, 5, 65, 11, Yellow);
      FastWrite('This Demo Screen illustrates using of the Screen Sizing Functions', 3, 12, Yellow);
      FastWrite(' Select Function ', 5, 35, Yellow);
      FastWrite('F1  - ResetScreen', 6, 20, White);
      FastWrite('F2  - SetScreenSize', 7, 20, White);
      FastWrite('F3  - SetScreenRows', 8, 20, White);
      FastWrite('F4  - BigScreen', 9, 20, White);
      FastWrite('F5  - ElegantScreen', 10, 20, White);

      FastWrite('F6  - RoyalScreen', 6, 45, White);
      FastWrite('F7  - CgaScreen', 7, 45, White);
      FastWrite('F8  - EgaLongScreen', 8, 45, White);
      FastWrite('F9  - CheapScreen', 9, 45, White);
      FastWrite('F10 - MediumScreen', 10, 45, White);
      For I := 1 to 8 do FastWrite(ltoa(I), 2, I * 10, White);
      For I := 1 to R do FastWrite('Line ' + ltoa(I), I, 1, White);
      For I := 1 to VideoColumns do FastWrite(ltoa(I mod 10), 1, I, White);
      FastWrite('This is the screen '+ltoa(R) + ' x ' + ltoa(VideoColumns),
        VideoRows div 2 + 7, VideoColumns div 2 - 10, White);
    end;

  begin
    Key := kbF1;
    repeat
      case Key of
        kbF1 : DemoSize(25, 1);
        kbF2 : DemoSize(26, 2);
        kbF3 : DemoSize(20, 3);
        kbF4 : DemoSize(25, 4);
        kbF5 : DemoSize(25, 5);
        kbF6 : DemoSize(51, 6);
        kbF7 : DemoSize(25, 7);
        kbF8 : DemoSize(28, 8);
        kbF9 : DemoSize(12, 9);
        kbF10: DemoSize(25, 10);
        kbEsc,
        kbGrayPlus,
        kbGrayMinus : begin
                        ResetScreen;
                        Exit
                      end
      end;
      Key := ReadLastKey
    until False
  end;

  procedure FontsDemo;

    procedure SetupFontScreen(Code : byte);
    begin
      ResetScreen;
      SetVideoMode(CO80);
      case Code of
        11 : VgaScreen(Russian);
        13 : EgaScreen(Russian);
        15 : CgaScreen(Russian);
        17 : VgaScreen(Estonian);
        19 : EgaScreen(Estonian);
        21 : CgaScreen(Estonian);
      end;
      SetBorderColor(11);
      SetPaletteReg(Black, 56);
      CursorOff;
      AsciiChart(7, 5, $1E);
      FastWrite('Supported Fonts Demo', 2, 32, White);
      FastWrite('Use cursor keys', 7, 60, Yellow);
      FastWrite('to select font.', 8, 60, Yellow);
      FastWrite('Russian 8x16', 11, 60, White);
      FastWrite('Russian 8x14', 13, 60, White);
      FastWrite('Russian 8x8', 15, 60, White);
      FastWrite('Estonian 8x16', 17, 60, White);
      FastWrite('Estonian 8x14', 19, 60, White);
      FastWrite('Estonian 8x8', 21, 60, White);
    end;

  begin
    SetVideoMode(CO80);
    I := 11;
    J := I;
    SetupFontScreen(I);
    FastWrite('<====', I, 74, Yellow);
    repeat
      if KeyPressed then Key:= ReadLastKey else Key:= 0;
      case Key of
        kbDown : if I < 21 then Inc(I, 2) else I := 11;
        kbUp   : if I > 11 then Dec(I, 2) else I := 21
      end;
      if I <> J then begin
        SetupFontScreen(I);
        FastWrite('     ', J, 74, Black);
        FastWrite('<====', I, 74, Yellow);
        J := I;
      end;
    until (Key = kbEsc) or (Key= kbGrayPlus) or (Key = kbGrayMinus);
    ResetScreen;
  end;

  procedure BorderDemo;
  begin
    SetVideoMode(CO80);
    SetBorderColor(Blue);
    CursorOff;
    SetPaletteReg(Black, 56);
    SetPaletteReg(Red, 44);
    FastWrite('IncBorderWidth/DecBorderWidth Functions Demo', 2, 21, White);
    FastWrite('Use the next keys:  LeftArrow  - decrease border width', 8, 6, White);
    FastWrite('RightArrow - increase border width', 9, 26, White);
    FastWrite('Enter      - standard border width', 10, 26, White);
    FastWrite('Warning! Your actions are not checked!', 13, 24, Red);
    repeat
      if KeyPressed then Key:= ReadLastKey else Key:= 0;
      case Key of
        kbLeft  : DecBorderWidth;
        kbRight : IncBorderWidth;
        kbEnter : NormalBorderWidth;
      end
    until (Key = kbEsc) or (Key= kbGrayPlus) or (Key = kbGrayMinus);
  end;

  procedure SaveGraphicsDemo;
  var
    grDriver : Integer;
    grMode   : Integer;
    ErrCode  : Integer;
    X, Y : word;
  begin
    SetVideoMode(CO80);
    if DiskFree(0) > 257 * 1024 then begin
      grDriver := Detect;
      InitGraph(grDriver,grMode,'');
      ErrCode := GraphResult;
      if ErrCode = grOk then
      begin
        OutTextXY(GetMaxX div 2 - 100, 20, 'Save/Restore VGA State Demo');
        X := 0;
        Y := 0;
        for I := 0 to 15 do begin
          SetFillStyle(SolidFill, I);
          Bar(X, Y, X+25, Y+25);
          Bar(X+40, Y, X+65, Y+25);
          Inc(Y, 28);
        end;
        for I := 0 to 15 do begin
          SetColor(I);
          Circle(GetMaxX div 2, GetMaxY div 2, succ(I) * 10)
        end;
        I := 20;
        SetColor(Blue);
        Randomize;
        repeat
          if I >= 440 then begin
            I := 20;
            SetColor(Black);
            SetFillStyle(SolidFill, Black);
            Bar(GetMaxX - 100, 20, GetMaxX - 10, 479);
            SetColor(Blue);
          end;
          SetColor((GetColor mod 15) + 1);
          Inc(I, 20);
          if not KeyPressed then begin
            OutTextXY(GetMaxX - 90, I, 'Saving...');
            SaveGraphScreen('vjdemo.dmp');
            ClearViewPort
          end;
          if not KeyPressed then begin
            Inc(I, 20);
            RestoreGraphScreen('vjdemo.dmp');
            OutTextXY(GetMaxX - 90, I, 'Restored.');
          end
        until ValidKeyPressed;

        Assign(F, 'vjdemo.dmp');
        Erase(F);
        I := IOResult;
        CloseGraph;
        Exit
      end
      else FastWrite('Graphics error: ' + GraphErrorMsg(ErrCode), 12, 12, Red)
    end
    else FastWrite('Not enough free space to create Save File', 12, 19, Red);
    Wait
  end;

  procedure ScreenMoves;
  begin
    SetVideoMode(CO80);
    SetBorderColor(Blue);
    SetPaletteReg(Black, 56);
    SetPaletteReg(Red, 44);
    FastWrite('Screen Moving Demo', 2, 33, White);
    FastWrite('Use cursor keys to move the screen', 10, 25, Yellow);
    FastWrite('or press Enter to center screen.', 11, 26, Yellow);
    FastWrite('Warning! Your actions are not checked!', 13, 24, Red);
    CursorOff;
    repeat
      if KeyPressed then Key:= ReadLastKey else Key:= 0;
      case Key of
        kbUp    : ScreenUp;
        kbDown  : ScreenDown;
        kbLeft  : ScreenLeft;
        kbRight : ScreenRight;
        kbEnter : CenterScreen;
      end
    until (Key = kbEsc) or (Key= kbGrayPlus) or (Key = kbGrayMinus);
    CenterScreen
  end;

  procedure GrayDemo;
  var
    P : DacColorBuf;
  begin
    SetVideoMode(CO80);
    SetBlinkOn(False);
    SetBorderColor(Green);
    CursorOff;
    GetMem(P, sizeof(DacColorRegs));
    SaveAllColors(P);
    FastWrite(' GrayColors Function Demo ', 2, 27, $1F);
    ColorsChart('Text');
    repeat
      FastWrite('Standard Colors Set', 5, 31, White);
      RestoreAllColors(P);
      if not KeyPressed then Delay(1000);
      FastWrite('  Gray Colors Set  ', 5, 31, White);
      GrayColors;
      if not KeyPressed then Delay(1000);
    until ValidKeyPressed;
    FreeMem(P, sizeof(DacColorRegs))
  end;

  procedure DacDemo;
  var
    P, P0 : DacColorBuf;
    I : byte;
  begin
    GetMem(P, sizeof(DacColorRegs));
    P0 := P;
    SetVideoMode($13);
    SaveAllColors(P);
    SetVideoMode(CO80);
    SetBlinkOn(False);
    CursorOff;
    ColorsChart('    ');
    I := 0;
    FastWrite('DAC Colors Programming Demo', 2, 27, White);
    FastWrite('This Colors Grabbed from 256 colors graphics video mode 13h (320 x 200)', 4, 5, White);
    repeat
      RestoreColors(0, 64, P);
      FastWrite('Colors Shifted At Register ' + ltoa(I) + '  ', 6, 25, White);
      if not KeyPressed then Delay(100);
      Inc(longint(P), 3);
      Inc(I);
      if I = 0 then P := P0;
    until ValidKeyPressed;
    FreeMem(P0, sizeof(DacColorRegs))
  end;

  procedure CleanUp;
  begin
    SetVideoMode(CO80);
    ResetScreen;
{    ResetVgaBios;}
{   Writeln('Thank You for using VGAJokes!');}
    Halt
  end;

  procedure NextScreen;
  var
    W: word;
  begin
    repeat
      repeat
        case Key of
          kbGrayPlus  : if CurrentProc < ProcCount then Inc(CurrentProc)
                          else CurrentProc := 1;
          kbGrayMinus : if CurrentProc > 1 then Dec(CurrentProc)
                          else CurrentProc := ProcCount;
          kbEsc       : CleanUp
        end
      until PrevProc <> CurrentProc;
      PrevProc := CurrentProc;
      case CurrentProc of
        1  : FirstScreen;
        2  : Information;
        3  : ScreenSizes;
        4  : FontsDemo;
        5  : BorderDemo;
        6  : SaveGraphicsDemo;
        7  : ScreenMoves;
        8  : GrayDemo;
        9  : DacDemo;
      end
    until False
  end;

  procedure Initialize;
  begin
    if not VgaPresent then begin
      Write('VGA card not detected. Press Enter to continue or Esc to Abort...');
      repeat
        C := ReadLastKey;
        if C = kbEsc then begin
          Writeln(^M^J'Program aborted.');
          Halt(1)
        end
      until C = kbEnter
    end;
    InitVideo;
    InitSysError
  end;

begin
  Initialize;
  NextScreen
end.
{eof vjdemo.pas}
