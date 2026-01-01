{====================================================================}
{                      Turbo Pascal 6.0 Library                      }
{====================================================================}
{             Copyright (c) 1992, 93 by Serge N. Varjukha            }
{                Estonia, Tallinn. Phone (0142) 666 500              }
{====================================================================}
{ Unit RusKbd - Russian keyboard support.                            }
{====================================================================}

{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,R-,S-,V-,X+}

unit RusKbd;

interface

  procedure InstallRusKbd;

  procedure RemoveRusKbd;

implementation
uses
  TpInline,
  Dos;

var
  ExitSave, SaveInt09 : pointer;

const
  SwitchKey = $38; { Alt key }
  RusKbdOn : boolean = False;
  ScanCode : byte = 0;
  JumpToBIOS : boolean = True;
  PrevCode : byte = 0;
  RusCode  : word = 0;
  RusMode  : boolean = False;
  BorderColor : array [boolean] of byte = (0, 4);  { 4 = red }

  {
    You can include Table0 for translate symbols in upper row
    of keyboard (from '!' to '=') as shown here:

  Table0   : array [1..13] of char =
    ('!', '"', ''', ';', ':', ',', '.', '*', '(', ')', '_', '=');
  }

  Table1   : array [16..27] of char =
    ('й','ц','у','к','е','н','г','ш','щ','з','х','ъ');
  Table2   : array [30..40] of char =
    ('ф','ы','в','а','п','p','о','л','д','ж','э');
  Table3   : array [44..52] of char =
    ('я','ч','с','м','и','т','ь','б','ю');

var
  I, J : byte;

  function UpCase(C : char): char;
  begin
    case ord(C) of
      $00..$7F,
      $B0..$DF,
      $F0..$FF  : UpCase := System.UpCase(C);
      $A0..$AF  : UpCase := char(ord(C) - $20);
      $E0..$EF  : UpCase := char(ord(C) - $50)
      else        UpCase := C   { $80..$9F }
    end
  end;

  function Capital: byte; assembler;
  asm
    push  es
    mov   ax, 40h
    mov   es, ax
    mov   ah, es:[17h]
    and   ah, 01000000b
    rol   ah, 1
    rol   ah, 1
    mov   al, es:[17h]
    and   al, 00000011b
    jz    @Exit
    mov   al, 2
  @Exit:
    add   al, ah
    pop   es
  end;

  procedure StuffKey(Key : char);
  begin
    if Capital in [1, 2] then Key := Upcase(Key);
    asm
      mov  ah, 5
      mov  cl, Key
      mov  ch, ScanCode
      int  16h
      mov  JumpToBios, 0
    end
  end;

  procedure Int09; interrupt;
  begin
    ScanCode := port[$60];
    if (ScanCode = (SwitchKey or $80)) and (PrevCode = SwitchKey) then
    begin
      RusMode := not RusMode;
      PrevCode := ScanCode;
      I := BorderColor[RusMode];
      asm
        mov   ax, 1001h
        mov   bh, I
        int   10h
      end;
      JumpToOldIsr(SaveInt09)
    end;
    PrevCode := ScanCode;
    if not RusMode then JumpToOldIsr(SaveInt09);
    JumpToBIOS := True;
    if ScanCode in [16..27] then StuffKey(Table1[ScanCode]);
    if ScanCode in [30..40] then StuffKey(Table2[ScanCode]);
    if ScanCode in [44..52] then StuffKey(Table3[ScanCode]);
    if JumpToBIOS then JumpToOldIsr(SaveInt09);
    I := port[$61];
    J := I;
    I := I or $80;
    port[$61] := I;
    port[$61] := J;
    asm cli end;
    port[$20] := $20;
    asm sti end
  end;

  procedure InstallRusKbd;
  begin
    if RusKbdOn then Exit;
    SetIntVec($09, @Int09);
    RusKbdOn := True;
  end;

  procedure RemoveRusKbd;
  begin
    if not RusKbdOn then Exit;
    SetIntVec($09, SaveInt09);
    RusKbdOn := False;
    I := BorderColor[False];
    asm
      mov   ax, 1001h
      mov   bh, I
      int   10h
    end
  end;

  procedure ExitRoutine; far;
  begin
    ExitProc := ExitSave;
    RemoveRusKbd
  end;

begin
  ExitSave := ExitProc;
  ExitProc := @ExitRoutine;
  GetIntVec($09, SaveInt09)
end.
{eof ruskbd.pas}
