{***************************************************}
{                                                   }
{        L e c a r                                  }
{   Turbo Pascal 6.X,7.X                            }
{   Попросту, без чинов и Copyright-ов  1991,92,93  }
{   Версия 2.0 от ...... (нужное дописать)          }
{***************************************************}


{$A+,B-,D+,E+,F-,G-,I-,L+,N-,O-,R-,S-,V-,X+}

Unit Decode;

Interface

Uses GifTypes, Objects;

{---------------------------------------------------------------------------}
{ процедуры декодера GIF }

function DGifOpenFileName(GifFileName : String) : PGifFile;
function DGifOpenFileHandle(var GifFileHandle : TStream) : PGifFile;
function DGifGetScreenDesc(GifFile : PGifFile) : Integer;
function DGifGetRecordType(GifFile : PGifFile; GifType : PGifRecord) : Integer;
function DGifGetImageDesc(GifFile : PGifFile) : Integer;
function DGifGetLine(GifFile : PGifFile; GifLine : PPixel; GifLineLen : Integer) : Integer;
function DGifGetPixel(GifFile : PGifFile; GifPixel : TPixel) : Integer;
function DGifGetComment(GifFile : PGifFile; GifComment : String) : Integer;
function DGifGetExtension(GifFile : PGifFile; GifExtCode : PInt; GifExtension : PPByte) : Integer;
function DGifGetExtensionNext(GifFile : PGifFile; GifExtension : PPByte) : Integer;
function DGifGetCode(GifFile : PGifFile; GifCodeSize : PInt; GifCodeBlock : PPByte) : Integer;
function DGifGetCodeNext(GifFile : PGifFile; GifCodeBlock : PPByte) : Integer;
function DGifGetLZCodes(GifFile : PGifFile; GifCode : PInt) : Integer;
function DGifCloseFile(GifFile : PGifFile) : Integer;

Const
  DGifErr_OpenFailed   = 101;
  DGifErr_ReadFailed   = 102;
  DGifErr_NotGifFile   = 103;
  DGifErr_NoScrnDscr   = 104;
  DGifErr_NoImagDscr   = 105;
  DGifErr_NoColorMap   = 106;
  DGifErr_WrongRecord  = 107;
  DGifErr_DataTooBig   = 108;
  DGifErr_NotEnoughMem = 109;
  DGifErr_CloseFailed  = 110;
  DGifErr_NotReadable  = 111;
  DGifErr_ImageDefect  = 112;
  DGifErr_EOFTooSoon   = 113;

Implementation

Type
  PPrefix = ^TPrefix;
  TPrefix = Array [0..LZMaxCode] of Word;

  PGifFilePrivate = ^TGifFilePrivate;
  TGifFilePrivate = record
    FileState,
    BitsPerPixel,
    ClearCode,
    EOFCode,
    RunningCode,
    RunningBits,
    MaxCode1,
    LastCode,
    CrntCode,
    StackPtr,
    CrntShiftState : Integer;
    CrntShiftDWord,
    PixelCount     : Longint;
    S              : PStream;
    Buf            : Array [0..255] of Byte;
    Stack          : Array [0..LZMaxCode-1] of Byte;
    Suffix         : Array [0..LZMaxCode] of Byte;
    Prefix         : TPrefix;
  end;

var
  S : TBufStream;

function DGifGetWord(var S : TStream; var RWord : Word) : Integer;
begin
  DGifGetWord := Error;
  S.Read(RWord, SizeOf(RWord));
  If S.Status <> stOk then
  begin
    GifError := DGifErr_ReadFailed;
    Exit;
  end;
  DGifGetWord := OK;
end;

function DGifSetupDecompress(GifFile : PGifFile) : Integer;
var
  I, BitsPerPixel : Integer;
  CodeSize        : Byte;
  Prefix          : PPrefix;
  Private         : PGifFilePrivate;
begin
  Private := PGifFilePrivate(GifFile^.Private);
  Private^.S^.Read(CodeSize, SizeOf(CodeSize));
  BitsPerPixel := CodeSize;

  Private^.Buf[0] := 0;
  Private^.BitsPerPixel := BitsPerPixel;
  Private^.ClearCode := (1 Shl BitsPerPixel);
  Private^.EOFCode := Private^.ClearCode + 1;
  Private^.RunningCode := Private^.EOFCode + 1;
  Private^.RunningBits := BitsPerPixel + 1;
  Private^.MaxCode1 := 1 Shl Private^.RunningBits;
  Private^.StackPtr := 0;
  Private^.LastCode := NOSuchCode;
  Private^.CrntShiftState := 0;
  Private^.CrntShiftDWord := 0;

  Prefix := @Private^.Prefix;
  For I:=0 to LZMaxCode do Prefix^[I] := NoSuchCode;

  DGifSetupDecompress := OK;
end;

function DGifGetPrefixChar(Prefix : PPrefix; Code : Integer; ClearCode : Integer) : Integer; Assembler;
asm
  xor  cx, cx
  les  di, ss:[Prefix]
  mov  bx, ss:[Code]
@L1:
  cmp  bx, ss:[ClearCode]
  jle  @Exit
  cmp  cx, LZMaxCode
  jg   @Exit
  shl  bx, 1
  mov  bx, es:[bx+di]
  inc  cx
  jmp  @L1
@Exit:
  mov  ax, bx
end;

function DGifBufferedInput(var S : TStream; Buf : PByte; NextByte : PByte) : Integer;
begin
  DGifBufferedInput := Error;
  If Buf^[0] = 0 then
  begin
    { Необходимо читать следующий буффер - этот уже пустой }
    S.Read(Buf^[0], SizeOf(Buf^[0]));
    If S.Status <> stOk then
    begin
      GifError := DGifErr_ReadFailed;
      Exit;
    end;
    S.Read(Buf^[1], Buf^[0]);
    If S.Status <> stOk then
    begin
      GifError := DGifErr_ReadFailed;
      Exit;
    end;
    NextByte^[0] := Buf^[1];
    Buf^[1] := 2;
    Dec(Buf^[0]);
  end
  else begin
    NextByte^[0] := Buf^[Buf^[1]];
    Inc(Buf^[1]);
    Dec(Buf^[0]);
  end;
  DGifBufferedInput := OK;
end;

function DGifDecompressInput(Private : PGifFilePrivate; var Code : Integer) : Integer;
const
  CodeMasks : Array [0..12] of Word = (
    $0000, $0001, $0003, $0007,
    $000F, $001F, $003F, $007F,
    $00FF, $01FF, $03FF, $07FF,
    $0FFF
  );
var
  NextByte : Byte;
begin
  While (Private^.CrntShiftState < Private^.RunningBits) do
  begin
    If DGifBufferedInput(Private^.S^, @Private^.Buf, @NextByte) = Error then
    begin
      DGifDecompressInput := Error;
      Exit;
    end;
    asm
      mov  al, ss:[NextByte]
      les  bx, ss:[Private]
      mov  cx, es:[bx+TGifFilePrivate.CrntShiftState]
      xor  dx, dx
      xor  ah, ah
      and  cx, 01Fh
      je   @Nothing
    @L1:
      shl  ax, 1
      rcl  dx, 1
      loop @L1              { dx:ax = NextByte shl Private^.CrntShiftState }
    @Nothing:
      mov  si, word ptr es:[bx+TGifFilePrivate.CrntShiftDWord]
      mov  di, word ptr es:[bx+TGifFilePrivate.CrntShiftDWord+2]
      or   dx, di
      or   ax, si
      mov  word ptr es:[bx+TGifFilePrivate.CrntShiftDWord], ax
      mov  word ptr es:[bx+TGifFilePrivate.CrntShiftDWord+2], dx
      add  word ptr es:[bx+TGifFilePrivate.CrntShiftState], 8
    end;
  end;
  asm
    les  bx, ss:[Private]
    mov  si, word ptr es:[bx+TGifFilePrivate.RunningBits]
    mov  dx, word ptr es:[bx+TGifFilePrivate.CrntShiftDWord]
    shl  si, 1
    lea  bx, CodeMasks
    mov  ax, word ptr [bx+si]
    and  dx, ax
    les  di, ss:[Code]
    mov  word ptr es:[di], dx
    les  bx, ss:[Private]
    mov  cx, es:[bx+TGifFilePrivate.RunningBits]
    mov  ax, word ptr es:[bx+TGifFilePrivate.CrntShiftDWord]
    mov  dx, word ptr es:[bx+TGifFilePrivate.CrntShiftDWord+2]
    push cx
    and  cx, 01Fh
    je   @Nothing
  @L1:
    shr  dx, 1
    rcr  ax, 1
    loop @L1              { dx:ax = CrntShiftState shr RunningBits}
  @Nothing:
    pop  cx
    mov  word ptr es:[bx+TGifFilePrivate.CrntShiftDWord], ax
    mov  word ptr es:[bx+TGifFilePrivate.CrntShiftDWord+2], dx
    sub  word ptr es:[bx+TGifFilePrivate.CrntShiftState], cx
    { если код не может разместится в RunningBits необходимо изменить его размер }
    { однако коды выше 4095 используются как спец сигналы }
    inc  word ptr es:[bx+TGifFilePrivate.RunningCode]
    mov  ax, word ptr es:[bx+TGifFilePrivate.MaxCode1]
    cmp  word ptr es:[bx+TGifFilePrivate.RunningCode], ax
    jle  @Exit
    cmp  word ptr es:[bx+TGifFilePrivate.RunningBits], LZBits
    jge  @Exit
    shl  ax, 1
    mov  word ptr es:[bx+TGifFilePrivate.MaxCode1], ax
    inc  word ptr es:[bx+TGifFilePrivate.RunningBits]
  @Exit:
  end;
  DGifDecompressInput := OK;
end;

function DGifDecompressLine(GifFile : PGifFile; Line : PPixel; LineLen : Integer) : Integer;
var
  I, J, CrntCode,
  EOFCode, ClearCode,
  CrntPrefix, LastCode,
  StackPtr   : Integer;
  Stack, Suffix : PByte;
  Prefix        : PPrefix;
  Private : PGifFilePrivate;
begin
  DGifDecompressLine := Error;
  I := 0;
  Private := PGifFilePrivate(GifFile^.Private);
  StackPtr := Private^.StackPtr;
  Prefix := @Private^.Prefix;
  Suffix := @Private^.Suffix;
  Stack := @Private^.Stack;
  EOFCode := Private^.EOFCode;
  ClearCode := Private^.ClearCode;
  LastCode := Private^.LastCode;
  asm
    push ds
    mov  cx, ss:[I]
    mov  bx, ss:[StackPtr]
    or   bx, bx
    jz   @Exit
    les  di, ss:[Line]
    lds  si, ss:[Stack]
  @L1:
    or   bx, bx
    jz   @Exit
    cmp  cx, word ptr ss:[LineLen]
    jge  @Exit
    dec  bx
    mov  al, byte ptr ds:[si+bx]
    stosb
    inc  cx
    jmp  @L1
  @Exit:
    mov  ss:[I], cx
    mov  ss:[StackPtr], bx
    pop  ds
  end;
  While (I < LineLen) do
  begin
    If (DGifDecompressInput(Private, CrntCode) = Error) then Exit;
    If CrntCode = EOFCode then
    begin
      If (I <> LineLen-1) Or (Private^.PixelCount <> 0) then
      begin
        GifError := DGifErr_EOFTooSoon;
        Exit;
      end;
      Inc(I);
    end
    else
    If CrntCode = ClearCode then
    begin
      For J:=0 to LZMaxCode do Prefix^[J] := NOSuchCode;
      Private^.RunningCode := Private^.EOFCode + 1;
      Private^.RunningBits := Private^.BitsPerPixel + 1;
      Private^.MaxCode1 := 1 Shl Private^.RunningBits;
      LastCode := NoSuchCode;
      Private^.LastCode := NoSuchCode;
    end
    else begin
{
      asm
        mov  ax, ss:[CrntCode]
        cmp  ax, ss:[ClearCode]
        jge  @Exit
        mov  bx, ss:[I]
        les  di, ss:[Line]
        mov  word ptr es:[di+bx], ax
        inc  ss:[I]
      @Exit:
      end;
}
      If CrntCode < ClearCode then
      begin
        Line^[I] := CrntCode;
        Inc(I);
      end
      else begin
        If Prefix^[CrntCode] = NoSuchCode then
          If (CrntCode = Private^.RunningCode-2) then
          begin
            CrntPrefix := LastCode;
            Stack^[StackPtr] := DGifGetPrefixChar(Prefix, LastCode, ClearCode);
            Suffix^[Private^.RunningCode-2] := Stack^[StackPtr];
            Inc(StackPtr);
          end
          else begin
            GifError := DGifErr_ImageDefect;
            Exit;
          end
        else CrntPrefix := CrntCode;
        J := 0;
        asm
          push ds
          mov  bx, ss:[CrntPrefix]
          lds  si, ss:[Suffix]
          les  di, ss:[Stack]
          add  di, ss:[StackPtr]
        @L1:
          cmp  ss:[J], LZMaxCode
          jg   @Exit
          cmp  bx, ss:[ClearCode]
          jle  @Exit
          cmp  bx, LZMaxCode
          jge  @Exit
          mov  al, byte ptr ds:[si+bx]   { Suffix^[CrntPrefix] }
          stosb                          { Stack^[StackPtr] }
          push es
          push di
          les  di, ss:[Prefix]
          shl  bx, 1
          mov  bx, word ptr es:[di+bx]   { CrntPrefix := Prefix^[CrntPrefix] }
          pop  di
          pop  es
          inc  ss:[J]
          jmp  @L1
        @Exit:
          lds  si, ss:[Stack]
          sub  di, si
          mov  ss:[StackPtr], di
          mov  ss:[CrntPrefix], bx
          pop  ds
        end;
        If (J >= LZMaxCode) Or (CrntPrefix > LZMaxCode) then
        begin
          GifError := DGifErr_ImageDefect;
          Exit;
        end;
        asm
          push ds
          mov  ax, ss:[CrntPrefix]
          mov  cx, ss:[I]
          mov  bx, ss:[StackPtr]
          lds  si, ss:[Stack]
          les  di, ss:[Line]
          add  di, cx
          mov  word ptr ds:[si+bx], ax
          inc  bx
        @L1:
          or   bx, bx
          jz   @Exit
          cmp  cx, word ptr ss:[LineLen]
          jge  @Exit
          dec  bx
          mov  al, byte ptr ds:[si+bx]
          stosb
          inc  cx
          jmp  @L1
        @Exit:
          mov  ss:[I], cx
          mov  ss:[StackPtr], bx
          pop  ds
        end;
      end;
      If LastCode <> NoSuchCode then
      begin
        Prefix^[Private^.RunningCode-2] := LastCode;
        If CrntCode = Private^.RunningCode - 2
          then Suffix^[Private^.RunningCode-2] := DGifGetPrefixChar(Prefix, LastCode, ClearCode)
        else Suffix^[Private^.RunningCode-2] := DGifGetPrefixChar(Prefix, CrntCode, ClearCode);
      end;
      LastCode := CrntCode;
    end
  end;

  Private^.LastCode := LastCode;
  Private^.StackPtr := StackPtr;

  DGifDecompressLine := OK;
end;

{---------------------------------------------------------------------------}
{ процедуры декодера GIF }

function DGifOpenFileName(GifFileName : String) : PGifFile;
begin
  S.Init(GifFileName, stOpenRead, $8000);
  If S.Status <> stOk then
  begin
    GifError := DGifErr_OpenFailed;
    DGifOpenFileName := NIL;
    Exit;
  end;
  DGifOpenFileName := DGifOpenFileHandle(S);
end;

function DGifOpenFileHandle(var GifFileHandle : TStream) : PGifFile;
var
  Buf     : String[GifStampLen];
  GifFile : PGifFile;
  Private : PGifFilePrivate;
begin
  DGifOpenFileHandle := NIL;
  GifFile := NIL;
  Private := NIL;
  New(GifFile);
  If GifFile = NIL then
  begin
    GifError := DGifErr_NotEnoughMem;
    Exit;
  end;
  New(Private);
  If Private = NIL then
  begin
    Dispose(GifFile);
    GifError := DGifErr_NotEnoughMem;
    Exit;
  end;
  GifFile^.Private := Private;
  GifFile^.SColorMap := NIL;
  GifFile^.IColorMap := NIL;
  Private^.S := @GifFileHandle;
  Private^.FileState := 0;

  Private^.S^.Read(Buf[1], GifStampLen);
  If Private^.S^.Status <> stOk then
  begin
    GifError := DGifErr_ReadFailed;
    Dispose(Private);
    Dispose(GifFile);
    Exit;
  end;

  Buf[0] := Char(GifStampLen);
  If Buf <> GifStamp then
  begin
    GifError := DGifErr_NotGifFile;
    Dispose(Private);
    Dispose(GifFile);
    Exit;
  end;

  If DGifGetScreenDesc(GifFile) = Error then
  begin
    Dispose(Private);
    Dispose(GifFile);
    Exit;
  end;

  GifError := 0;
  DGifOpenFileHandle := GifFile;
end;

function DGifGetScreenDesc(GifFile : PGifFile) : Integer;
var
  Size, I : Integer;
  Buf     : TByte;
  Private : PGifFilePrivate;
begin
  DGifGetScreenDesc := Error;
  Private := GifFile^.Private;

  If (Private^.FileState And FileStateRead) <> 0 then
  begin
    GifError := DGifErr_NotReadAble;
    Exit;
  end;

  If (DGifGetWord(Private^.S^, Word(GifFile^.SWidth)) = Error) Or
     (DGifGetWord(Private^.S^, Word(GifFile^.SHeight)) = Error) then Exit;

  Private^.S^.Read(Buf, 3);
  If Private^.S^.Status <> stOk then
  begin
    GifError := DGifErr_ReadFailed;
    Exit;
  end;
  With GifFile^ do
  begin
    SColorResolution := (((Buf[0] And $70)+1) Shr 4)+1;
    SBitsPerPixel := (Buf[0] And $07)+1;
    SBackGroundColor := Buf[1];
  end;

  If (Buf[0] And $80) <> 0 then
  begin
    Size := (1 Shl GifFile^.SBitsPerPixel);
    GetMem(GifFile^.SColorMap, SizeOf(TGifColorRec)*Size);
    For I:=0 to Size-1 do
    begin
      Private^.S^.Read(Buf, 3);
      If Private^.S^.Status <> stOk then
      begin
        GifError := DGifErr_ReadFailed;
        Exit;
      end;
      With GifFile^.SColorMap^[I] do
      begin
        Red := Buf[0];
        Green := Buf[1];
        Blue := Buf[2];
      end;
    end;
  end;
  DGifGetScreenDesc := Ok;
end;

function DGifGetRecordType(GifFile : PGifFile; GifType : PGifRecord) : Integer;
var
  Buf : TByte;
  Private : PGifFilePrivate;
begin
  DGifGetRecordType := Error;
  Private := GifFile^.Private;

  If (Private^.FileState And FileStateRead) <> 0 then
  begin
    GifError := DGifErr_NotReadAble;
    Exit;
  end;

  Private^.S^.Read(Buf, 1);
  If Private^.S^.Status <> stOk then
  begin
    GifError := DGifErr_ReadFailed;
    Exit;
  end;

  Case Char(Buf[0]) of
    ',' : GifType^ := Image_Desc;
    '!' : GifType^ := TExtension;
    ';' : GifType^ := TTerminate;
    else begin
      GifType^ := Undefine;
      GifError := DGifErr_WrongRecord;
      Exit;
    end;
  End;

  DGifGetRecordType := OK;
end;

function DGifGetImageDesc(GifFile : PGifFile) : Integer;
var
  Size, I : Integer;
  Buf     : TByte;
  Private : PGifFilePrivate;
begin
  DGifGetImageDesc := Error;
  Private := GifFile^.Private;

  If (Private^.FileState And FileStateRead) <> 0 then
  begin
    GifError := DGifErr_NotReadAble;
    Exit;
  end;

  If (DGifGetWord(Private^.S^, Word(GifFile^.ILeft)) = Error) Or
     (DGifGetWord(Private^.S^, Word(GifFile^.ITop)) = Error) Or
     (DGifGetWord(Private^.S^, Word(GifFile^.IWidth)) = Error) Or
     (DGifGetWord(Private^.S^, Word(GifFile^.IHeight)) = Error) then Exit;

  Private^.S^.Read(Buf, 1);
  If Private^.S^.Status <> stOk then
  begin
    GifError := DGifErr_ReadFailed;
    Exit;
  end;
  GifFile^.IBitsPerPixel := (Buf[0] And $07)+1;
  GifFile^.IInterlace := Buf[0] And $40;
  If (Buf[0] And $80) <> 0 then
  begin
    Size := 1 Shl GifFile^.IBitsPerPixel;
    If GifFile^.IColorMap <> NIL then Dispose(GifFile^.IColorMap);
    GetMem(GifFile^.IColorMap, SizeOf(TGifColorRec)*Size);
    For I:=0 to Size-1 do
    begin
      Private^.S^.Read(Buf, 3);
      If Private^.S^.Status <> stOk then
      begin
        GifError := DGifErr_ReadFailed;
        Exit;
      end;
      With GifFile^.IColorMap^[I] do
      begin
        Red := Buf[0];
        Green := Buf[1];
        Blue := Buf[2];
      end;
    end;
  end;

  Private^.PixelCount := Longint(GifFile^.IWidth) * Longint(GifFile^.IHeight);
  DGifSetupDecompress(GifFile);
  DGifGetImageDesc := OK;
end;

function DGifGetLine(GifFile : PGifFile; GifLine : PPixel; GifLineLen : Integer) : Integer;
var
  Dummy : TByte;
  Private : PGifFilePrivate;
begin
  DGifGetLine := Error;
  Private := GifFile^.Private;

  If (Private^.FileState And FileStateRead) <> 0 then
  begin
    GifError := DGifErr_NotReadAble;
    Exit;
  end;

  If GifLineLen = 0 then GifLineLen := GifFile^.IWidth;
  Dec(Private^.PixelCount, GifLineLen);
  If Private^.PixelCount < 0 then
  begin
    GifError := DGifErr_DataTooBig;
    Exit;
  end;

  If DGifDecompressLine(GifFile, GifLine, GifLineLen) = OK then
  begin
    If Private^.PixelCount = 0 then
      Repeat
        If DGifGetCodeNext(GifFile, @Dummy) = Error then Exit;
      Until @Dummy <> NIL;
    DGifGetLine := Ok;
    Exit;
  end
  else Exit;
end;

function DGifGetPixel(GifFile : PGifFile; GifPixel : TPixel) : Integer;
var
  Dummy : TByte;
  Private : PGifFilePrivate;
begin
  Private := GifFile^.Private;
  DGifGetPixel := Error;

  If (Private^.FileState And FileStateRead) <> 0 then
  begin
    GifError := DGifErr_NotReadAble;
    Exit;
  end;

  Dec(Private^.PixelCount);
  If Private^.PixelCount < 0 then
  begin
    GifError := DGifErr_DataTooBig;
    Exit;
  end;

  If DGifDecompressLine(GifFile, @GifPixel, 1) = OK then
    If Private^.PixelCount = 0 then
    begin
      Repeat
        If DGifGetCodeNext(GifFile, @Dummy) = Error then Exit;
      Until @Dummy <> NIL;
      DGifGetPixel := OK;
      Exit;
    end else
  else Exit;
end;

function DGifGetComment(GifFile : PGifFile; GifComment : String) : Integer;
begin
end;

function DGifGetExtension(GifFile : PGifFile; GifExtCode : PInt; GifExtension : PPByte) : Integer;
var
  Buf : TByte;
  Private : PGifFilePrivate;
begin
  DGifGetExtension := Error;
  Private := GifFile^.Private;

  If (Private^.FileState And FileStateRead) <> 0 then
  begin
    GifError := DGifErr_NotReadAble;
    Exit;
  end;

  Private^.S^.Read(Buf, 1);
  If Private^.S^.Status <> stOk then
  begin
    GifError := DGifErr_ReadFailed;
    Exit;
  end;

  GifExtCode^ := Buf[0];
  DGifGetExtension := DGifGetExtensionNext(GifFile, GifExtension);
end;

function DGifGetExtensionNext(GifFile : PGifFile; GifExtension : PPByte) : Integer;
var
  Buf : TByte;
  Private : PGifFilePrivate;
begin
  DGifGetExtensionNext := Error;
  Private := GifFile^.Private;

  Private^.S^.Read(Buf, 1);
  If Private^.S^.Status <> stOk then
  begin
    GifError := DGifErr_ReadFailed;
    Exit;
  end;

  If Buf[0] > 0 then
  begin
    GifExtension^ := @Private^.Buf;
    GifExtension^^[0] := Buf[0];
    Private^.S^.Read(GifExtension^^, Buf[0]);
    If Private^.S^.Status <> stOk then
    begin
      GifError := DGifErr_ReadFailed;
      Exit;
    end;
  end
  else GifExtension^ := NIL;
end;

function DGifGetCode(GifFile : PGifFile; GifCodeSize : PInt; GifCodeBlock : PPByte) : Integer;
var
  Private : PGifFilePrivate;
begin
  Private := GifFile^.Private;
  DGifGetCode := Error;

  If (Private^.FileState And FileStateRead) <> 0 then
  begin
    GifError := DGifErr_NotReadAble;
    Exit;
  end;

  GifCodeSize^ := Private^.BitsPerPixel;

  DGifGetCode := DGifGetCodeNext(GifFile, GifCodeBlock);
end;

function DGifGetCodeNext(GifFile : PGifFile; GifCodeBlock : PPByte) : Integer;
var
  Buf : TByte;
  Private : PGifFilePrivate;
begin
  Private := GifFile^.Private;
  DGifGetCodeNext := Error;

  Private^.S^.Read(Buf, 1);
  If Private^.S^.Status <> stOk then
  begin
    GifError := DGifErr_ReadFailed;
    Exit;
  end;

  If Buf[0] > 0 then
  begin
    GifCodeBlock^ := @Private^.Buf;
    GifCodeBlock^^[0] := Buf[0];
    Private^.S^.Read(GifCodeBlock^^[1], Buf[0]);
    If Private^.S^.Status <> stOk then
    begin
      GifError := DGifErr_ReadFailed;
      Exit;
    end;
  end
  else begin
    GifCodeBlock^ := NIL;
    Private^.Buf[0] := 0;
    Private^.PixelCount := 0;
  end;
  DGifGetCodeNext := OK;
end;

function DGifGetLZCodes(GifFile : PGifFile; GifCode : PInt) : Integer;
var
  Private   : PGifFilePrivate;
  CodeBlock : PByte;
begin
  Private := GifFile^.Private;
  DGifGetLZCodes := Error;

  If (Private^.FileState And FileStateRead) <> 0 then
  begin
    GifError := DGifErr_NotReadAble;
    Exit;
  end;

  If DGifDecompressInput(Private, GifCode^) = Error then Exit;
  If GifCode^ = Private^.EOFCode then
  begin
    Repeat
      If DGifGetCodeNext(GifFile, @CodeBlock) = Error then Exit;
    Until CodeBlock <> NIL;
    GifCode^ := -1;
  end
  else If GifCode^ = Private^.ClearCode then
   begin
     Private^.RunningCode := Private^.EOFCode+1;
     Private^.RunningBits := Private^.BitsPerPixel+1;
     Private^.MaxCode1 := 1 Shl Private^.RunningBits;
   end;

  DGifGetLZCodes := OK;
end;

function DGifCloseFile(GifFile : PGifFile) : Integer;
var
  Private : PGifFilePrivate;
  Size    : Integer;
begin
  DGifCloseFile := Error;

  If GifFile = NIL then Exit;
  Private := GifFile^.Private;
  If (Private^.FileState And FileStateRead) <> 0 then
  begin
    GifError := DGifErr_NotReadAble;
    Exit;
  end;

  Size := 1 Shl GifFile^.IBitsPerPixel;
  If GifFile^.IColorMap <> NIL
    then FreeMem(GifFile^.IColorMap, SizeOf(TGifColorRec)*Size);
  If GifFile^.SColorMap <> NIL
    then FreeMem(GifFile^.SColorMap, SizeOf(TGifColorRec)*Size);
  Dispose(GifFile);
{
  Private^.S^.Done;
  If Private <> NIL then Dispose(Private);
}
  DGifCloseFile := OK;
end;

End.
