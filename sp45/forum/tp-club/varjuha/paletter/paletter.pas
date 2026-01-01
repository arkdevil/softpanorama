{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,R-,S-,V-,X-}
{$M 16384,0,655360}
program Paletter;
uses
   TpCrt,
   TpString,
   Dos;

type
  PaletteRegs   = 0..15;
  Palette       = array [0..16] of byte;
  CrtCRegs      = $00..$18;
  RgbValue      = 0..63;
  RgbRec = record
    R, G, B : RgbValue
  end;
  DacColorRegs  = array [0..255] of RgbRec;
  DacColorBuf   = ^DacColorRegs;

const
  ColorNames : array [0..15] of string [12] = (
    'Black', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Brown',
    'LtGray', 'DarkGray', 'LtBlue', 'LtGreen', 'LtCyan', 'LtRed',
    'LtMagenta', 'Yellow', 'White');

  DefaultPalette  : Palette =
    (0, 1, 2, 3, 4, 5, $14, 7, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, 0);

var
  Regs : registers;
  I, J : byte;
  RegEdit, RegSaved : array [PaletteRegs] of RgbRec;

const
  UseDacBios     : boolean = False;
  UsePaletteBios : boolean = False;
  CrtBase : word = $3D4;

procedure GetColorReg(ColorReg: byte; var R, G, B : RgbValue); assembler;
asm
  push  es
  cmp   UseDacBios, False
  je    @UseDac
  mov   ax, 1015h
  xor   bh, bh
  mov   bl, ColorReg
  int   10h
  mov   ah, dh
  jmp   @Exit
@UseDac:
  cli
  mov   dx, 3C7h
  mov   al, ColorReg
  out   dx, al
  mov   dx, 3C9h
@ReadDacPort:
  in    al, dx
  mov   ah, al
  jmp   @00
@00:
  in    al, dx
  mov   ch, al
  jmp   @01
@01:
  in    al, dx
  mov   cl, al
  mov   dx, 3C7h
  in    al, dx
  sti
@Exit:
  les   di, R
  mov   al, ah
  stosb
  les   di, G
  mov   al, ch
  stosb
  les   di, B
  mov   al, cl
  stosb
  pop   es
end;


procedure SetColorReg(ColorReg: byte; R, G, B : RgbValue); assembler;
asm
  cmp   UseDacBios, False
  je    @UseDac
  mov   ax, 1010h
  xor   bh, bh
  mov   bl, ColorReg
  mov   dh, R
  mov   ch, G
  mov   cl, B
  int   10h
  jmp   @Exit
@UseDac:
  cli
  mov   dx, 3C8h
  mov   al, ColorReg
  out   dx, al
  mov   dx, 3C9h
@WriteDacPort:
  mov   al, R
  out   dx, al
  jmp   @00
@00:
  mov   al, G
  out   dx, al
  jmp   @01
@01:
  mov   al, B
  out   dx, al
  sti
@Exit:
end;

procedure SavePalette(P : Palette); assembler;
asm
  push  es
  cmp   UsePaletteBios, False
  je    @UseAttr
  les   dx, P
  mov   ax, 1009h
  int   10h
  jmp   @Exit
@UseAttr:
  cli
  les   di, P
  mov   dx, CrtBase
  add   dx, 6
  in    al, dx
  mov   bx, dx
  mov   dx, 3C0h
  xor   cl, cl
  cld
@Next:
  mov   al, cl
  out   dx, al
  inc   dx
  in    al, dx
  stosb
  xchg  dx, bx
  in    al, dx
  xchg  dx, bx
  dec   dx
  inc   cl
  test  cl, 00010000b
  jz    @Next
  mov   al, 11h
  out   dx, al
  inc   dx
  in    al, dx
  stosb
  xchg  dx, bx
  in    al, dx
  mov   dx, bx
  dec   dx
  mov   al, 20h
  out   dx, al
  sti
@Exit:
  pop   es
end;

procedure RestorePalette(P : Palette); assembler;
asm
  cmp   UsePaletteBios, False
  je    @UseAttr
  push  es
  les   bx, P
  mov   ax, 1002h
  int   10h
  pop   es
  jmp   @Exit
@UseAttr:
  cli
  push  ds
  lds   si, P
  mov   dx, CrtBase
  add   dx, 6
  in    al, dx
  mov   bx, dx
  mov   dx, 3C0h
  xor   cl, cl
  cld
@Next:
  mov   al, cl
  out   dx, al
  lodsb
  out   dx, al
  inc   cl
  test  cl, 00010000b
  jz    @Next
  mov   al, 11h
  out   dx, al
  lodsb
  out   dx, al
  mov   al, 20h
  out   dx, al
  sti
  pop   ds
@Exit:
end;

procedure SetPaletteReg(Reg : PaletteRegs; Value : RgbValue); assembler;
asm
  cmp   UsePaletteBios, False
  je    @UseAttr
  mov   ax, 1000h
  mov   bl, Reg
  mov   bh, Value
  int   10h
  jmp   @Exit
@UseAttr:
  cli
  mov   dx, CrtBase
  add   dx, 6
  in    al, dx
  mov   dx, 3C0h
  mov   al, Reg
  out   dx, al
  mov   al, Value
  out   dx, al
  mov   al, 20h
  out   dx, al
  sti
@Exit:
end;

function GetPaletteReg(Reg : PaletteRegs): RgbValue; assembler;
asm
  cmp   UsePaletteBios, False
  je    @UseAttr
  mov   ax, 1007h
  mov   bl, Reg
  int   10h
  mov   al, bh
  jmp   @Exit
@UseAttr:
  cli
  mov   dx, CrtBase
  add   dx, 6
  mov   bx, dx
  in    al, dx
  mov   dx, 3C0h
  mov   al, Reg
  out   dx, al
  inc   dx
  in    al, dx
  push  ax
  xchg  bx, dx
  in    al, dx
  xchg  bx, dx
  dec   dx
  mov   al, 20h
  out   dx, al
  pop   ax
  sti
@Exit:
end;

procedure StandardPalette;
begin
  RestorePalette(DefaultPalette)
end;

procedure DefaultPaletteOn(On : boolean); assembler;
asm
  mov   ah, 12h
  mov   bl, 31h
  mov   al, On
  not   al
  and   al, 1
  int   10h
end;

procedure TitleScreen;
begin
  SetColorReg(Magenta, 0, 0, 0);
  Window(20, 8, 63, 18);
  TextAttr := $05;
  ClrScr;
  Writeln(^J'      This program was created for internal');
  Writeln(' use only.');
  Writeln(^J'    When using this program, please send me');
  Writeln(' $10 or 250 soviet roubles as contribution.');
  Writeln(^J' Connect me: USSR, Tallinn, (0142)-666-500');
  Writeln(^J'                         Serge N. Varjukha');
  for I := 0 to 63 do begin
    SetColorReg(Magenta, I, I, 0);
    Delay(100);
  end;
  for I := 63 downto 0 do begin
    SetColorReg(Magenta, I, I, 0);
    Delay(100);
  end;
  ClrScr;
  Writeln(^J^J^J^J^J'                  Thank You!');
  for I := 0 to 63 do begin
    SetColorReg(Magenta, I, 0, 0);
    Delay(30);
  end;
  for I := 63 downto 0 do begin
    SetColorReg(Magenta, I, 0, 0);
    Delay(30);
  end;
  Window(1,2,80,25);
  TextAttr := $10;
  TextChar := '▒';
  ClrScr;
end;

procedure MainScreen;
begin
  TextAttr := $10;
  TextChar := '▒';
  ClrScr;
  FastCenter(Center('VGA Palette Setup Utility  Copyright (c) 1991 by Serge N. Varjukha  Tallinn', 80), 1, $74);
  if ParamCount <> 0 then TitleScreen;
  for I := 0 to 15 do begin
    FastWrite(Pad(ColorNames[I], 10) + HexB(I), 3 + I, 3, $17);
    FastWrite(LeftPad(Long2Str(I), 2), 3 + I, 77, $17);
  end;
  FastWrite(Pad(' Use arrow keys to Select color. Press Enter to Modify or Esc to Quit.', 80), 25, 1, $70);
  for I := 0 to 15 do FastWrite('        ', 3 + I, 18, I shl 4);
  for I := 0 to 15 do
    GetColorReg(DefaultPalette[I], RegEdit[I].R, RegEdit[I].G, RegEdit[I].B);
  Move(RegEdit, RegSaved, sizeof(RegSaved));
end;

procedure SoundIn;
begin
  Sound(600);
  Delay(30);
  NoSound;
end;

procedure SoundOut;
begin
  Sound(800);
  Delay(30);
  NoSound;
end;

procedure SetupReg(Reg : byte);
var
  X, X1, Y : byte;
  Done     : boolean;
begin
  SoundIn;
  FastWrite(Pad(' Use arrow keys to Modify color. Press Enter to Accept or Esc to Ignore.', 80), 25, 1, $70);
  X  := 0;
  X1 := 0;
  Y := RegEdit[Reg].R;
  Done := False;

  repeat
    SetColorReg(DefaultPalette[Reg], RegEdit[Reg].R, RegEdit[Reg].G, RegEdit[Reg].B);
    FastWrite('▒', 21 + X1, 1, $10);
    FastWrite('', 21 + X, 1, $1E);
    X1 := X;

    FastWrite('Red      (00)', 21, 2, $1F);
    FastWrite('Green    (00)', 22, 2, $1F);
    FastWrite('Blue     (00)', 23, 2, $1F);

    FastWrite(Long2Str(RegEdit[Reg].R), 21, 8, $17);
    FastWrite(HexB(RegEdit[Reg].R), 21, 12, $17);

    FastWrite(Long2Str(RegEdit[Reg].G), 22, 8, $17);
    FastWrite(HexB(RegEdit[Reg].G), 22, 12, $17);

    FastWrite(Long2Str(RegEdit[Reg].B), 23, 8, $17);
    FastWrite(HexB(RegEdit[Reg].B), 23, 12, $17);

    FastWrite(CharStr(' ', 63), 21, 16, $00);
    FastWrite(CharStr(' ', 63), 22, 16, $00);
    FastWrite(CharStr(' ', 63), 23, 16, $00);

    FastWrite(CharStr(' ', RegEdit[Reg].R), 21, 16, Red shl 4);
    FastWrite(CharStr(' ', RegEdit[Reg].G), 22, 16, Green shl 4);
    FastWrite(CharStr(' ', RegEdit[Reg].B), 23, 16, Blue shl 4);

    case ReadKeyWord of
      $5000 : if X < 2  then Inc(X);
      $4800 : if X > 0  then Dec(X);
      $4D00 : case X of
                0 : if RegEdit[Reg].R < 63 then Inc(RegEdit[Reg].R);
                1 : if RegEdit[Reg].G < 63 then Inc(RegEdit[Reg].G);
                2 : if RegEdit[Reg].B < 63 then Inc(RegEdit[Reg].B)
              end;
      $4B00 : case X of
                0 : if RegEdit[Reg].R > 0 then Dec(RegEdit[Reg].R);
                1 : if RegEdit[Reg].G > 0 then Dec(RegEdit[Reg].G);
                2 : if RegEdit[Reg].B > 0 then Dec(RegEdit[Reg].B)
              end;
      $1C0D : begin
                Move(RegEdit, RegSaved, sizeof(RegEdit));
                Done := True
              end;
      $011B : Done := True;
    end
  until Done;
  for I := 0 to 15 do
    SetColorReg(DefaultPalette[I], RegSaved[I].R, RegSaved[I].G, RegSaved[I].B);
  FastWrite('▒', 21 + X1, 1, $10);
  FastWrite(Pad(' Use arrow keys to Select color. Press Enter to Modify or Esc to Quit.', 80), 25, 1, $70);
  Move(RegSaved, RegEdit, sizeof(RegEdit));
  SoundOut
end;

procedure SoundProgIn;
begin
  Sound(1400);
  Delay(30);
  NoSound;
end;

procedure SoundProgOut;
begin
  Sound(1000);
  Delay(30);
  NoSound;
end;

procedure SetRegisters;
var
  X, X1 : byte;
begin
  X  := 0;
  X1 := 0;
  Window(29, 3, 49, 18);
  repeat
    FastWrite(ColorNames[X1], 3 + X1, 3, $17);
    FastWrite('▒', 3 + X1, 1, $10);
    FastWrite('', 3 + X, 1, $1E);
    FastWrite(ColorNames[X], 3 + X, 3, $1E);

    FastWrite('▒', 3 + X1, 80, $10);
    FastWrite(#17, 3 + X, 80, $1E);

    FastWrite('▒', 3 + X1, 16, $10);
    FastWrite('', 3 + X, 16, $1E);

    FastWrite('▒', 3 + X1, 27, $10);
    FastWrite('', 3 + X, 27, $1E);

    FastWrite('▒', 3 + X1, 51, $10);
    FastWrite('', 3 + X, 51, $1E);

    FastWrite('▒', 3 + X1, 75, $10);
    FastWrite('', 3 + X, 75, $1E);

    X1 := X;

    FastWrite('Red      (00)', 21, 2, $1F);
    FastWrite('Green    (00)', 22, 2, $1F);
    FastWrite('Blue     (00)', 23, 2, $1F);

    FastWrite(Long2Str(RegSaved[X].R), 21, 8, $17);
    FastWrite(HexB(RegSaved[X].R), 21, 12, $17);

    FastWrite(Long2Str(RegSaved[X].G), 22, 8, $17);
    FastWrite(HexB(RegSaved[X].G), 22, 12, $17);

    FastWrite(Long2Str(RegSaved[X].B), 23, 8, $17);
    FastWrite(HexB(RegSaved[X].B), 23, 12, $17);

    FastWrite(CharStr(' ', 63), 21, 16, $00);
    FastWrite(CharStr(' ', 63), 22, 16, $00);
    FastWrite(CharStr(' ', 63), 23, 16, $00);

    FastWrite(CharStr(' ', RegSaved[X].R), 21, 16, Red shl 4);
    FastWrite(CharStr(' ', RegSaved[X].G), 22, 16, Green shl 4);
    FastWrite(CharStr(' ', RegSaved[X].B), 23, 16, Blue shl 4);

    TextAttr := X shl 4;
    ClrScr;
    for I := 0 to 15 do begin
      FastWrite('Selected background', I + 3, 30, I + (X shl 4));
      FastWrite(' Selected foreground ', I + 3, 53, X + (I shl 4));
    end;
    case ReadKeyWord of
      $5000 : if X < 15 then Inc(X);
      $4800 : if X > 0  then Dec(X);
      $1C0D : SetupReg(X);
      $011B : Exit;
    end
  until False;
end;

begin
  CheckBreak := False;
  ReinitCrt;
  if CurrentDisplay <> VGA then begin
    Writeln(^J' VGA card nor detected. Aborting...');
    Halt(1)
  end;
  DefaultPaletteOn(True);
  TextMode(CO80);
  StandardPalette;
  SetBlink(False);
  HiddenCursor;
  MainScreen;
  SoundProgIn;
  SetRegisters;
  SoundProgOut;
  Window(1,1,80,25);
  TextAttr := $07;
  TextChar := ' ';
  ClrScr;
end.
{eof paletter.pas}
