{$S-,R-,V-,I-,B-,F+}

{$IFNDEF Ver40}
  {$I OPLUS.INC}
{$ENDIF}

{*********************************************************}
{*                    TPDOS.PAS 5.01                     *}
{*        Copyright (c) TurboPower Software 1987.        *}
{* Portions copyright (c) Sunny Hill Software 1985, 1986 *}
{*     and used under license to TurboPower Software     *}
{*                 All rights reserved.                  *}
{*********************************************************}

unit TpDos1;
  {-Miscellaneous DOS/BIOS call routines}

interface
uses
  Dos;

function TextSeek(var F : Text; Target : LongInt) : Boolean;
 {-Do a Seek for a text file opened for input. Returns False in case of I/O
   error.}

function TextFileSize(var F : Text) : LongInt;
  {-Return the size of text file F. Returns -1 in case of I/O error.}

function TextPos(var F : Text) : LongInt;
 {-Return the current position of the logical file pointer (that is,
   the position of the physical file pointer, adjusted to account for
   buffering). Returns -1 in case of I/O error.}

implementation
type
  TextBuffer = array[0..65520] of Byte;
  FIB =
    record
      Handle : Word;
      Mode : Word;
      BufSize : Word;
      Private : Word;
      BufPos : Word;
      BufEnd : Word;
      BufPtr : ^TextBuffer;
      OpenProc : Pointer;
      InOutProc : Pointer;
      FlushProc : Pointer;
      CloseProc : Pointer;
      UserData : array[1..16] of Byte;
      Name : array[0..79] of Char;
      Buffer : array[0..127] of Char;
    end;


  LongRec = record
              LowWord, HighWord : Word; {structure of a LongInt}
            end;

  function TextSeek(var F : Text; Target : LongInt) : Boolean;
    {-Do a Seek for a text file opened for input. Returns False in case of I/O
      error.}
  var
    T : LongRec absolute Target;
    Regs : Registers;
    Pos : LongInt;
  begin
    with Regs, FIB(F) do begin
      {assume failure}
      TextSeek := False;

      {check for file opened for input}
      if Mode <> FMInput then
        Exit;

      {get current position of the file pointer}
      AX := $4201;           {move file pointer function}
      BX := Handle;          {file handle}
      CX := 0;               {if CX and DX are both 0, call returns the..}
      DX := 0;               {current file pointer in DX:AX}
      MsDos(Regs);

      {check for I/O error}
      if Odd(Flags) then
        Exit;

      {calculate current position for the start of the buffer}
      LongRec(Pos).HighWord := DX;
      LongRec(Pos).LowWord := AX;
      Dec(Pos, BufEnd);

      {see if the Target is within the buffer}
      Pos := Target-Pos;
      if (Pos >= 0) and (Pos < BufEnd) then
        {it is--just move the buffer pointer}
        BufPos := Pos
      else begin
        {have DOS seek to the Target-ed offset}
        AX := $4200;         {move file pointer function}
        BX := Handle;        {file handle}
        CX := T.HighWord;    {CX has high word of Target offset}
        DX := T.LowWord;     {DX has low word}
        MsDos(Regs);

        {check for I/O error}
        if Odd(Flags) then
          Exit;

        {tell Turbo its buffer is empty}
        BufEnd := 0;
        BufPos := 0;
      end;
    end;

    {if we get to here we succeeded}
    TextSeek := True;
  end;

  function TextFileSize(var F : Text) : LongInt;
    {-Return the size of text file F. Returns -1 in case of I/O error.}
  var
    Regs : Registers;
    OldHi, OldLow : Integer;
  begin
    with Regs, FIB(F) do begin
      {check for open file}
      if Mode = FMClosed then begin
        TextFileSize := -1;
        Exit;
      end;

      {get current position of the file pointer}
      AX := $4201;           {move file pointer function}
      BX := Handle;          {file handle}
      CX := 0;               {if CX and DX are both 0, call returns the..}
      DX := 0;               {current file pointer in DX:AX}
      MsDos(Regs);

      {check for I/O error}
      if Odd(Flags) then begin
        TextFileSize := -1;
        Exit;
      end;

      {save current position of the file pointer}
      OldHi := DX;
      OldLow := AX;

      {have DOS move to end-of-file}
      AX := $4202;           {move file pointer function}
      BX := Handle;          {file handle}
      CX := 0;               {if CX and DX are both 0, call returns the...}
      DX := 0;               {current file pointer in DX:AX}
      MsDos(Regs);           {call DOS}

      {check for I/O error}
      if Odd(Flags) then begin
        TextFileSize := -1;
        Exit;
      end;

      {calculate the size}
      TextFileSize := LongInt(DX) shl 16+AX;

      {reset the old position of the file pointer}
      AX := $4200;           {move file pointer function}
      BX := Handle;          {file handle}
      CX := OldHi;           {high word of old position}
      DX := OldLow;          {low word of old position}
      MsDos(Regs);           {call DOS}

      {check for I/O error}
      if Odd(Flags) then
        TextFileSize := -1;
    end;
  end;

  function TextPos(var F : Text) : LongInt;
    {-Return the current position of the logical file pointer (that is,
      the position of the physical file pointer, adjusted to account for
      buffering). Returns -1 in case of I/O error.}
  var
    Position : LongInt;
    Regs : Registers;
  begin
    with Regs, FIB(F) do begin
      {check for open file}
      if Mode = FMClosed then begin
        TextPos := -1;
        Exit;
      end;

      {get current position of the physical file pointer}
      AX := $4201;           {move file pointer function}
      BX := Handle;          {file handle}
      CX := 0;               {if CX and DX are both 0, call returns the...}
      DX := 0;               {current file pointer in DX:AX}
      MsDos(Regs);           {call DOS}

      {check for I/O error}
      if Odd(Flags) then begin
        TextPos := -1;
        Exit;
      end;

      {calculate the position of the logical file pointer}
      LongRec(Position).HighWord := DX;
      LongRec(Position).LowWord := AX;
      if Mode = FMOutput then
        {writing}
        Inc(Position, BufPos)
      else
        {reading}
        if BufEnd <> 0 then
          Dec(Position, BufEnd-BufPos);

      {return the calculated position}
      TextPos := Position;
    end;
  end;

end.
