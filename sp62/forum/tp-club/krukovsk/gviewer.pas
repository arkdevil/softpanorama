
{***************************************************}
{                                                   }
{        L e c a r                                  }
{   Turbo Pascal 6.X,7.X                            }
{   Попросту, без чинов и Copyright-ов  1991,92,93  }
{   Версия 2.0 от ...... (нужное дописать)          }
{***************************************************}


{$A+,B-,D+,E+,F-,G-,I-,L+,N-,O-,R-,S+,V-,X+}
{$M 16384,0,655360}

Unit GViewer;

Interface

Uses Objects, GifTypes, Decode, VTest;

type
  PPicture = ^TPicture;
  TPicture = object(TObject)
    F : File;
    isLoad : Boolean;
    GifFile : PGifFile;
    constructor Init(FName: String);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    destructor Done; virtual;
  end;

const
  Picture : PPicture = nil;
  WaitDelay: Byte = 3;

  RPicture: TStreamRec = (
    ObjType: 1004;
    VmtLink: Ofs(TypeOf(TPicture)^);
    Load:  @TPicture.Load;
    Store: @TPicture.Store);

procedure RegisterPicture;

Implementation

Uses Crt;

type
  TScreenBuff = Array [0..1000] of Byte;
  DacPalette256 = array[0..255] of array[0..2] of Byte;
  PDacPalette256 = ^DacPalette256;

const
  InterlacedOffset : Array [0..3] of Byte = ( 0, 4, 2, 1 );    (* The way Interlaced image should  *)
  InterlacedJumps  : Array [0..3] of Byte = ( 8, 8, 4, 2 );    (* be read - offsets and jumps... *)

var
  ColorMap : TGifColor;
  MaxX, MaxY : Integer;
  MaxColor : Integer;
  ExtCode : Integer;
  Extension : PByte;
  Tiks      : Longint Absolute $0000:$046C;
  OldTiks   : Longint;

procedure SetVGAPalette256(PalBuf : DacPalette256); near; assembler;
asm
  mov  ax, 1012h
  xor  bx, bx
  mov  cx, 256d
  les  dx, PalBuf
  int  10h
end;

procedure SetPalette(Color, Value: Byte); near; assembler;
asm
  mov  ax, 1000h
  mov  bl, Color
  mov  bh, Value
  int  10h
end;

procedure PutLine(LineNum, Width : Integer; var Buffer : TScreenBuff);
var
  Count  : Integer;
begin
  if MaxColor > 16 then
    asm
      cli
      cld
      push ds
      mov  cx, ss:[Width]
      xor  di, di
      mov  ax, ss:[LineNum]
      mul  cx
      add  di, ax
      lds  si, ss:[Buffer]
      mov  ax, 0A000h
      mov  es, ax
      rep  movsb
      pop  ds
      sti
    end
  else asm
    cli
    cld
    mov  bx, ss:[Width]
    dec  bx
    mov  cl, 3
    shr  bx, cl
    inc  bx
    xor  di, di
    mov  ax, ss:[LineNum]
    mul  bx
    add  di, ax
    add  bx, di
    mov  dx, 03CEh
    mov  ax, 0205h
    out  dx, ax
    push ds
    lds  si, ss:[Buffer]
    mov  ax, 0A000h
    mov  es, ax
    mov  ch, 8
    @L1:
      mov  ax, 08008h
      @L2:
        out  dx, ax
        mov  al, es:[di]
        lodsb
        mov  es:[di], al
        mov  al, ch
        shr  ah, 1
      jnc @L2
      inc  di
      cmp  di, bx
    jne  @L1
    pop  ds
    mov  ax, 00005h
    out  dx, ax
    mov  ax, 0FF08h
    out  dx, ax
    sti
  end;
end;

constructor TPicture.Init(FName: String);
begin
  TObject.Init;
  isLoad := False;
  GifFile := nil;
  Assign(F, FName);
  Reset(F, 1);
end;

constructor TPicture.Load(var S: TStream);
var
  I, J, Count, Row, BackGround,
  Col, Width, Height : Integer;
  ScreenBuffer : TScreenBuff;
  RecordType : TGifRecord;
  Size : Integer;

  procedure Initialize;
  var
    I : Integer;
    Pal : Byte;
    Divider : Byte;
  begin
    I := Size;
    asm
      mov  ax,  00013h
      cmp  word ptr ss:[I], 016d
      ja   @Set
      cmp  MaxX, 320d
      ja   @L1
      mov  al, 0Dh
      jmp  @Set
    @L1:
      cmp  MaxY, 200d
      ja   @L3
      mov  al, 0Eh
      jmp  @Set
    @L3:
      cmp  MaxY, 350d
      ja   @L2
      mov  al, 010h
      jmp  @Set
    @L2:
      mov  al, 012h
    @Set:
      int  10h
    end;
    If Size > 16 then Divider := 4 else Divider := 85;
    For I:=0 to Size-1 do With ColorMap[I] do
    begin
      Red := Red Div Divider;
      Green := Green Div Divider;
      Blue := Blue Div Divider;
    end;
    If (Size > 16) then SetVGAPalette256(PDACPalette256(@ColorMap)^)
    else
      For I:=0 to Size-1 do
      begin
        With ColorMap[I] do
        begin
          Pal := 0;
          Case Red of
            0 : Pal := Pal And $DB;
            1 : Pal := Pal Or $20;
            2 : Pal := Pal Or $04;
            3 : Pal := Pal Or $24
          End;
          Case Green of
            0 : Pal := Pal And $ED;
            1 : Pal := Pal Or $10;
            2 : Pal := Pal Or $02;
            3 : Pal := Pal Or $12;
          End;
          Case Blue of
            0 : Pal := Pal And $F6;
            1 : Pal := Pal Or $08;
            2 : Pal := Pal Or $01;
            3 : Pal := Pal Or $09;
          End;
         SetPalette(I, Pal)
        end;
      end;
  end;

begin
  isLoad := True;
  GifFile := DGifOpenFileHandle(S);
  If GifFile = nil then Exit;
  Col := 0;
  Row:=0;

  (* Lets display it - set the global variables required and do it: *)
  BackGround := GifFile^.SBackGroundColor;
  If GifFile^.IColorMap <> NIL then ColorMap := GifFile^.IColorMap^
  else ColorMap := GifFile^.SColorMap^;
  Size := 1 Shl GifFile^.SBitsPerPixel;
  MaxX := GifFile^.SWidth;
  MaxY := GifFile^.SHeight;
  MaxColor := Size-1;
  TestVideo(Video);
  Video.TVideo0 := Video.TVideo0 and $7F;
  Video.TVideo1 := Video.TVideo1 and $7F;
  if (Video.TVideo0 < 4) and (Video.TVideo1 < 4) then
    if ((Video.TVideo0 < 3) and (Video.TVideo1 < 3)) or (MaxColor > 15) then
    begin
      If DGifCloseFile(GifFile) = Error then;
      Exit;
    end;
  Initialize;
  Repeat
    If DGifGetRecordType(GifFile, @RecordType) = Error then Exit;
    Case RecordType of
      Image_Desc :
      begin
        If DGifGetImageDesc(GifFile) = Error then Exit;
        Row := GifFile^.ITop;
        Col := GifFile^.ILeft;
        Width := GifFile^.IWidth;
        Height := GifFile^.IHeight;
        If GifFile^.IInterlace <> 0 then
        begin
          For I:=0 to 3 do
          begin
            Count := 0;
            J := Row+InterlacedOffset[I];
            Repeat
              If DGifGetLine(GifFile, @ScreenBuffer, Width) = Error then Exit;
              PutLine(J, Width, ScreenBuffer);
              If KeyPressed then
              begin
                If DGifCloseFile(GifFile) = Error then;
                TextMode(LastMode);
                Exit;
              end;
              Inc(J, InterlacedJumps[I]);
            Until J >= Row+Height;
          end;
        end
        else For I:=0 to Height-1 do
          begin
            If DGifGetLine(GifFile, @ScreenBuffer, Width) = Error then Exit;
            PutLine(I, Width, ScreenBuffer);
            If KeyPressed then
            begin
              If DGifCloseFile(GifFile) = Error then;
              TextMode(LastMode);
              Exit;
            end;
            Inc(Row);
          end;
      end;
      TExtension : begin
        If DGifGetExtension(GifFile, @ExtCode, @Extension) = Error then Exit;
        While Extension <> NIL do
          If DGifGetExtensionNext(GifFile, @Extension) = Error then Exit;
      end;
      TTerminate : ;
      else ;
    End; { case }
  Until RecordType = TTerminate;
  If DGifCloseFile(GifFile) = Error then Exit;
  OldTiks := Tiks;
  Repeat Until KeyPressed or ((Tiks-OldTiks) > WaitDelay*18);
end;

procedure TPicture.Store(var S: TStream);
var
  Buf : array [0..4095] of byte;
  NumRead : Integer;
begin
  repeat
    BlockRead(F, Buf, SizeOf(Buf), NumRead);
    S.Write(Buf, NumRead);
  until (NumRead = 0) or (S.Status <> stOk);
  if S.Status <> stOk then S.Reset;
end;

destructor TPicture.Done;
begin
  if not isLoad then Close(F);
end;

procedure RegisterPicture;
begin
  RegisterType(RPicture);
end;

begin
  RegisterPicture;
end.