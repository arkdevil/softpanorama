{====================================================================}
{                      Turbo Pascal 6.0 Library                      }
{====================================================================}
{             Copyright (c) 1992, 93 by Serge N. Varjukha            }
{                Estonia, Tallinn. Phone (0142) 666 500              }
{====================================================================}
{ Unit RusFont - Loadable fonts support.                             }
{====================================================================}

{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,R-,S-,V-,X+}

unit RusFont;

interface

type
  FontType      = (ftBadFont, ft8x8, ft8x14, ft8x16);

  procedure LoadRusFont(F : FontType);
    {Load russian alternative font into fonts block number 0 }

  function LoadFontFile(FileName : string;
                        FirstChar, CharSize, Block: byte): boolean;
    {Loads font from file}

  function RusUpCase(C : char): char;
    {Converts char C into uppercase in alternative character set }

{=========================== implementation =========================}

implementation

var
  vjFile : file;

  procedure RusFont8x16; external;
  {$L rus8x16.obj}

  procedure RusFont8x14; external;
  {$L rus8x14.obj}

  procedure RusFont8x8; external;
  {$L rus8x8.obj}

  procedure LoadRusFont(F : FontType);
  var
    FontOffset : word;
    CharHeight, FontCode : byte;
  begin
    case F of
      ft8x8  : begin
                 FontOffset := Ofs(RusFont8x8);
                 FontCode := $12;
                 CharHeight := 8
               end;
      ft8x14 : begin
                 FontOffset := Ofs(RusFont8x14);
                 FontCode := $11;
                 CharHeight := 14
               end;
      ft8x16 : begin
                 FontOffset := Ofs(RusFont8x16);
                 FontCode := $14;
                 CharHeight := 16
               end
    end;
    asm
      mov   al, FontCode
      mov   ah, 11h
      int   10h
      mov   ax, 1100h
      mov   cx, 128
      mov   dx, 128
      xor   bl, bl
      mov   bh, CharHeight
      push  es
      push  bp
      push  cs
      pop   es                     { font segment is CS }
      mov   bp, FontOffset
      int   10h
      pop   bp
      pop   es
    end
  end;

  function LoadFontFile(FileName : string; FirstChar, CharSize, Block: byte): boolean;
  var
    P : pointer;
    S, O, I : word;
  begin
    LoadFontFile := False;
    Assign(vjFile, FileName);
    Reset(vjFile, 1);
    if IOResult <> 0 then Exit;
    I := (256 - FirstChar);
    GetMem(P, I * CharSize);
    S := Seg(P^);
    O := Ofs(P^);
    BlockRead(vjFile, P^, I * CharSize);
    if IOResult = 0 then Close(vjFile);
    asm
      mov   ax, 1100h
      mov   cx, I
      xor   dh, dh
      mov   dl, FirstChar
      mov   bl, Block
      mov   bh, CharSize
      push  es
      push  bp
      push  ax
      mov   ax, S
      mov   es, ax
      pop   ax
      mov   bp, O
      int   10h
      pop   bp
      pop   es
    end;
    FreeMem(P, I * CharSize);
    LoadFontFile := True
  end;

  function RusUpCase(C : char): char;
  begin
    case ord(C) of
      $00..$7F,
      $B0..$DF,
      $F0..$FF  : RusUpCase := System.UpCase(C);
      $A0..$AF  : RusUpCase := char(ord(C) - $20);
      $E0..$EF  : RusUpCase := char(ord(C) - $50)
      else        RusUpCase := C   { $80..$9F }
    end
  end;

end.
{eof rusfont.pas}
