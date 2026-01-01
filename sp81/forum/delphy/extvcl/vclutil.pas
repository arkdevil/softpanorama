{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
unit VCLUtil;

{$P+,W-,R-,B-}

interface

Uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls;

{ Windows resources VCL-oriented routines }

procedure DrawBitmapTransparent(Dest: TCanvas; XOrigin, YOrigin: Integer;
  Bitmap: TBitmap; TransparentColor: TColor);
procedure DrawBitmapRectTransparent(Dest: TCanvas; XOrigin, YOrigin: Integer;
  Rect: TRect; Bitmap: TBitmap; TransparentColor: TColor);
function MakeBitmap(ResID: PChar): TBitmap;
function MakeBitmapID(ResID: Word): TBitmap;
function MakeModuleBitmap(Module: THandle; ResID: PChar): TBitmap;
function CreateTwoColorsBrushPattern(Color1, Color2: TColor): TBitmap;
function ChangeBitmapColor(Bitmap: TBitmap; Color, NewColor: TColor): TBitmap;
procedure SaveBitmapToFile(const FileName: string; Bitmap: TBitmap;
  Colors: Integer);

function MakeIcon(ResID: PChar): TIcon;
function MakeIconID(ResID: Word): TIcon;
function MakeModuleIcon(Module: THandle; ResID: PChar): TIcon;
function IconExtract(const FileName: string; Id: Integer): TIcon;
function CreateBitmapFromIcon(Icon: TIcon; BackColor: TColor): TBitmap;

{ Service routines }

procedure NotImplemented;
function PointInRect(P: TPoint; const R: TRect): Boolean;
procedure PaintInverseRect(RectOrg, RectEnd: TPoint);
procedure Delay(MSecs: Longint);

{ String routines }

function AnsiUpperFirstChar(const S: string): string;
function DelChars(S: string; Chr: Char): string;

{ Wait cursor routines }

procedure StartWait;
procedure StopWait;

{ Windows API level routines }

procedure DrawTransparentBitmap(DC: HDC; Bitmap: HBitmap;
  xStart, yStart: Integer; TransparentColor: TColorRef);

implementation

Uses SysUtils, ShellAPI, Dialogs, Consts, ExtConst;

{ Bitmap exception }

procedure InvalidBitmap; near;
begin
  raise EInvalidGraphic.Create(LoadStr(SInvalidBitmap));
end;

{**************************************************************************}

{ Bitmap }

function MakeBitmap(ResID: PChar): TBitmap;
begin
  Result := MakeModuleBitmap(hInstance, ResID);
end;

function MakeBitmapID(ResID: Word): TBitmap;
begin
  Result := MakeModuleBitmap(hInstance, MakeIntResource(ResID));
end;

function MakeModuleBitmap(Module: THandle; ResID: PChar): TBitmap;
begin
  Result := TBitmap.Create;
  Result.Handle := LoadBitmap(Module, ResID);
  if Result.Handle = 0 then begin
    Result.Free;
    Result := nil;
  end;
end;

{**************************************************************************}

{ Transparent bitmap }

procedure DrawTransparentBitmapRect(DC: HDC; Bitmap: HBitmap;
  xStart, yStart: Integer; Rect: TRect; TransparentColor: TColorRef);
var
  BM: WinTypes.TBitmap;
  cColor: TColorRef;
  bmAndBack, bmAndObject, bmAndMem, bmSave: HBitmap;
  bmBackOld, bmObjectOld, bmMemOld, bmSaveOld: HBitmap;
  hdcMem, hdcBack, hdcObject, hdcTemp, hdcSave: HDC;
  ptSize, ptRealSize, ptOrigin: TPoint;
begin
  hdcTemp := CreateCompatibleDC(DC);
  SelectObject(hdcTemp, Bitmap);      { Select the bitmap    }
  GetObject(Bitmap, SizeOf(BM), @BM);

  ptRealSize.x := Rect.Right - Rect.Left;
  ptRealSize.y := Rect.Bottom - Rect.Top;
  DPtoLP(hdcTemp, ptRealSize, 1);
  ptOrigin.x := Rect.Left;
  ptOrigin.y := Rect.Top;
  DPtoLP(hdcTemp, ptOrigin, 1);

  ptSize.x := BM.bmWidth;             { Get width of bitmap  }
  ptSize.y := BM.bmHeight;            { Get height of bitmap }
  DPtoLP(hdcTemp, ptSize, 1);         { Convert from device  }
                                      { to logical points    }
  if ptRealSize.x = 0 then ptRealSize.x := ptSize.x;
  if ptRealSize.y = 0 then ptRealSize.y := ptSize.y;
  { Create some DCs to hold temporary data }
  hdcBack   := CreateCompatibleDC(DC);
  hdcObject := CreateCompatibleDC(DC);
  hdcMem    := CreateCompatibleDC(DC);
  hdcSave   := CreateCompatibleDC(DC);
  { Create a bitmap for each DC. DCs are required for a number of }
  { GDI functions                                                 }
  { Monochrome DC }
  bmAndBack   := CreateBitmap(ptSize.x, ptSize.y, 1, 1, Nil);
  bmAndObject := CreateBitmap(ptSize.x, ptSize.y, 1, 1, Nil);
  bmAndMem    := CreateCompatibleBitmap(DC, ptSize.x, ptSize.y);
  bmSave      := CreateCompatibleBitmap(DC, ptSize.x, ptSize.y);
  { Each DC must select a bitmap object to store pixel data }
  bmBackOld   := SelectObject(hdcBack, bmAndBack);
  bmObjectOld := SelectObject(hdcObject, bmAndObject);
  bmMemOld    := SelectObject(hdcMem, bmAndMem);
  bmSaveOld   := SelectObject(hdcSave, bmSave);
  { Set proper mapping mode }
  SetMapMode(hdcTemp, GetMapMode(DC));
  { Save the bitmap sent here, because it will be overwritten }
  BitBlt(hdcSave, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCCOPY);
  { Set the background color of the source DC to the color,         }
  { contained in the parts of the bitmap that should be transparent }
  cColor := SetBkColor(hdcTemp, TransparentColor);
  { Create the object mask for the bitmap by performing a BitBlt()  }
  { from the source bitmap to a monochrome bitmap                   }
  BitBlt(hdcObject, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0,
    SRCCOPY);
  { Set the background color of the source DC back to the original  }
  { color                                                           }
  SetBkColor(hdcTemp, cColor);
  { Create the inverse of the object mask }
  BitBlt(hdcBack, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0,
    NOTSRCCOPY);
  { Copy the background of the main DC to the destination }
  BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, DC, xStart, yStart,
    SRCCOPY);
  { Mask out the places where the bitmap will be placed }
  BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, SRCAND);
  { Mask out the transparent colored pixels on the bitmap }
  BitBlt(hdcTemp, 0, 0, ptSize.x, ptSize.y, hdcBack, 0, 0, SRCAND);
  { XOR the bitmap with the background on the destination DC }
  BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCPAINT);
  { Copy the destination to the screen }
  BitBlt(DC, xStart, yStart, ptRealSize.x, ptRealSize.y, hdcMem,
    ptOrigin.x, ptOrigin.y, SRCCOPY);
  { Place the original bitmap back into the bitmap sent here }
  BitBlt(hdcTemp, 0, 0, ptSize.x, ptSize.y, hdcSave, 0, 0, SRCCOPY);
  { Delete the memory bitmaps }
  DeleteObject(SelectObject(hdcBack, bmBackOld));
  DeleteObject(SelectObject(hdcObject, bmObjectOld));
  DeleteObject(SelectObject(hdcMem, bmMemOld));
  DeleteObject(SelectObject(hdcSave, bmSaveOld));
  { Delete the memory DCs }
  DeleteDC(hdcMem);
  DeleteDC(hdcBack);
  DeleteDC(hdcObject);
  DeleteDC(hdcSave);
  DeleteDC(hdcTemp);
end;

procedure DrawTransparentBitmap(DC: HDC; Bitmap: HBitmap;
  xStart, yStart: Integer; TransparentColor: TColorRef);
begin
  DrawTransparentBitmapRect(DC, Bitmap, xStart, yStart, Rect(0, 0, 0, 0),
    TransparentColor);
end;

procedure DrawBitmapRectTransparent(Dest: TCanvas; XOrigin, YOrigin: Integer;
  Rect: TRect; Bitmap: TBitmap; TransparentColor: TColor);
begin
  try
    DrawTransparentBitmapRect(Dest.Handle, Bitmap.Handle, XOrigin, YOrigin,
      Rect, ColorToRGB(TransparentColor and not $02000000));
  except
    raise;
  end;
end;

procedure DrawBitmapTransparent(Dest: TCanvas; XOrigin, YOrigin: Integer;
  Bitmap: TBitmap; TransparentColor: TColor);
begin
  try
    DrawTransparentBitmapRect(Dest.Handle, Bitmap.Handle,
      XOrigin, YOrigin, Rect(0, 0, 0, 0),
      ColorToRGB(TransparentColor and not $02000000));
    { TBitmap.TransparentColor property return TColor value equal }
    { to (Bitmap.Canvas.Pixels[0, Height - 1] or $02000000).      }
  except
    raise;
  end;
end;

{ ChangeBitmapColor. This function create new TBitmap object.
  You must destroy it outside by calling TBitmap.Free method. }

function ChangeBitmapColor(Bitmap: TBitmap; Color, NewColor: TColor): TBitmap;
var
  R: TRect;
begin
  Result := TBitmap.Create;
  try
    with Result do begin
      Height := Bitmap.Height;
      Width := Bitmap.Width;
      R := Bounds(0, 0, Width, Height);
      Canvas.Brush.Color := NewColor;
      Canvas.FillRect(R);
      Canvas.BrushCopy(R, Bitmap, R, Color);
    end;
  except
    Result.Free;
    Result := nil;
    raise;
  end;
end;

{**************************************************************************}

function CreateTwoColorsBrushPattern(Color1, Color2: TColor): TBitmap;
var
  X, Y: Integer;
begin
  Result := TBitmap.Create;
  Result.Width := 8;
  Result.Height := 8;
  with Result.Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := Color1;
    FillRect(Rect(0, 0, Result.Width, Result.Height));
    for Y := 0 to 7 do
      for X := 0 to 7 do
        if (Y mod 2) = (X mod 2) then  { toggles between even/odd pixles }
          Pixels[X, Y] := Color2;      { on even/odd rows }
  end;
end;

{**************************************************************************}

{ Write Bitmap to stream utilities. Copied from implementation of }
{ GRAPHCS.PAS unit.                                               }

function WidthBytes(I: Longint): Longint;
begin
  Result := ((I + 31) div 32) * 4;
end;

procedure InitializeBitmapInfoHeader(Bitmap: HBITMAP; var BI: TBitmapInfoHeader;
  Colors: Integer);
var
  BM: WinTypes.TBitmap;
begin
  GetObject(Bitmap, SizeOf(BM), @BM);
  with BI do
  begin
    biSize := SizeOf(BI);
    biWidth := BM.bmWidth;
    biHeight := BM.bmHeight;
    if Colors <> 0 then
      case Colors of
        2: biBitCount := 1;
        16: biBitCount := 4;
        256: biBitCount := 8;
      end
    else biBitCount := BM.bmBitsPixel * BM.bmPlanes;
    biPlanes := 1;
    biXPelsPerMeter := 0;
    biYPelsPerMeter := 0;
    biClrUsed := 0;
    biClrImportant := 0;
    biCompression := BI_RGB;
    if biBitCount in [16, 32] then biBitCount := 24;
    biSizeImage := WidthBytes(biWidth * biBitCount) * biHeight;
  end;
end;

procedure InternalGetDIBSizes(Bitmap: HBITMAP; var InfoHeaderSize: Integer;
  var ImageSize: Longint; Colors: Integer);
var
  BI: TBitmapInfoHeader;
begin
  InitializeBitmapInfoHeader(Bitmap, BI, Colors);
  with BI do
  begin
    case biBitCount of
      24: InfoHeaderSize := SizeOf(TBitmapInfoHeader);
    else
      InfoHeaderSize := SizeOf(TBitmapInfoHeader) + SizeOf(TRGBQuad) *
       (1 shl biBitCount);
    end;
  end;
  ImageSize := BI.biSizeImage;
end;

function InternalGetDIB(Bitmap: HBITMAP; Palette: HPALETTE;
  var BitmapInfo; var Bits; Colors: Integer): Boolean;
var
  OldPal: HPALETTE;
  Focus: HWND;
  DC: HDC;
begin
  InitializeBitmapInfoHeader(Bitmap, TBitmapInfoHeader(BitmapInfo), Colors);
  OldPal := 0;
  Focus := GetFocus;
  DC := GetDC(Focus);
  try
    if Palette <> 0 then
    begin
      OldPal := SelectPalette(DC, Palette, False);
      RealizePalette(DC);
    end;
    Result := GetDIBits(DC, Bitmap, 0, TBitmapInfoHeader(BitmapInfo).biHeight, @Bits,
      TBitmapInfo(BitmapInfo), DIB_RGB_COLORS) <> 0;
  finally
    if OldPal <> 0 then SelectPalette(DC, OldPal, False);
    ReleaseDC(Focus, DC);
  end;
end;

function DIBFromBit(Src: HBITMAP; Pal: HPALETTE; Colors: Integer;
  var Length: Longint): Pointer;
var
  HeaderSize: Integer;
  ImageSize: Longint;
  FileHeader: PBitmapFileHeader;
  BI: PBitmapInfoHeader;
  Bits: Pointer;
begin
  if Src = 0 then InvalidBitmap;
  InternalGetDIBSizes(Src, HeaderSize, ImageSize, Colors);
  Length := SizeOf(TBitmapFileHeader) + HeaderSize + ImageSize;
  Result := MemAlloc(Length);
  try
    FillChar(Result^, Length, 0);
    FileHeader := Result;
    with FileHeader^ do
    begin
      bfType := $4D42;
      bfSize := Length;
      bfOffBits := SizeOf(FileHeader^) + HeaderSize;
    end;
    BI := PBitmapInfoHeader(Longint(FileHeader) + SizeOf(FileHeader^));
    Bits := Pointer(Longint(BI) + HeaderSize);
    InternalGetDIB(Src, Pal, BI^, Bits^, Colors);
  except
    FreeMem(Result, Length);
    raise;
  end;
end;

procedure WriteBitmap(Stream: TStream; Bitmap: HBITMAP; Pal: HPALETTE;
  WriteLength: Boolean; Colors: Integer);
var
  Length: Longint;
  Data: Pointer;
begin
  Data := DIBFromBit(Bitmap, Pal, Colors, Length);
  try
    if WriteLength then Stream.Write(Length, SizeOf(Length));
    Stream.Write(Data^, Length);
  finally
    FreeMem(Data, Length);
  end;
end;

{ Save TBitmap object to BMP-file with specified colors count }

procedure SaveBitmapToFile(const Filename: string; Bitmap: TBitmap;
  Colors: Integer);
var
  Stream: TStream;
begin
  if Bitmap.Monochrome then Colors := 2;
  Stream := TFileStream.Create(Filename, fmCreate);
  try
    WriteBitmap(Stream, Bitmap.Handle, Bitmap.Palette, False, Colors);
  finally
    Stream.Free;
  end;
end;

{**************************************************************************}

{ Icon }

function MakeIcon(ResID: PChar): TIcon;
begin
  Result := MakeModuleIcon(hInstance, ResID);
end;

function MakeIconID(ResID: Word): TIcon;
begin
  Result := MakeModuleIcon(hInstance, MakeIntResource(ResID));
end;

function MakeModuleIcon(Module: THandle; ResID: PChar): TIcon;
begin
  Result := TIcon.Create;
  Result.Handle := LoadIcon(Module, ResID);
  if Result.Handle = 0 then begin
    Result.Free;
    Result := nil;
  end;
end;

function IconExtract(const FileName: string; Id: Integer): TIcon;
var
  S: array[0..SizeOf(TFileName)] of char;
  IconHandle: HIcon;
begin
  Result := TIcon.Create;
  try
    StrPCopy(S, FileName);
    IconHandle := ExtractIcon(hInstance, S, Id);
    if IconHandle < 2 then begin
      if IconHandle = 1 then 
        raise EResNotFound.Create(GetExtStr(SFileNotExec))
      else begin
        Result.Free;
        Result := nil;
      end;	
    end
    else Result.Handle := IconHandle;
  except
    Result.Free;
    Result := nil;
    raise;
  end;
end;

{ Create TBitmap object from TIcon }

function CreateBitmapFromIcon(Icon: TIcon; BackColor: TColor): TBitmap;
var
  IWidth, IHeight: Integer;
  TmpImage: TBitmap;
begin
  Result := nil;
  IWidth := Icon.Width;
  IHeight := Icon.Height;
  TmpImage := TBitmap.Create;
  try
    TmpImage.Width := IWidth;
    TmpImage.Height := IHeight;
    with TmpImage.Canvas do begin
      Brush.Color := BackColor;
      FillRect(Rect(0, 0, IWidth, IHeight));
      Draw(0, 0, Icon);
    end;
    Result := TmpImage;
  except
    TmpImage.Free;
    raise;
  end;
end;

{**************************************************************************}

{ Service routines }

procedure NotImplemented;
begin
  MessageDlg(GetExtStr(SNotImplemented), mtInformation, [mbOk], 0);
end;

procedure PaintInverseRect(RectOrg, RectEnd: TPoint);
var
  DC: HDC;
begin
  DC := GetDC(0);
  try
    BitBlt(DC, RectOrg.X, RectOrg.Y,
      RectEnd.X - RectOrg.X, RectEnd.Y - RectOrg.Y,
      0, 0, 0, DSTINVERT);
  finally
    ReleaseDC(0, DC);
  end;
end;

function PointInRect(P: TPoint; const R: TRect): Boolean;
begin
  with R do begin
    Result := (Left <= P.X) and (Top <= P.Y) and
      (Right >= P.X) and (Bottom >= P.Y);
  end;
end;

procedure Delay(MSecs: Longint);
var
  FirstTickCount: Longint;
begin
  FirstTickCount := GetTickCount;
  repeat
    Application.ProcessMessages;
    { allowing access to other controls, etc. }
  until ((GetTickCount - FirstTickCount) >= MSecs);
end;

{**************************************************************************}

function AnsiUpperFirstChar(const S: string): string;
var
  Temp: string[1];
begin
  Result := AnsiLowerCase(S);
  if S <> '' then begin
    Temp := Result[1];
    Temp := AnsiUpperCase(Temp);
    Result[1] := Temp[1];
  end;
end;

function DelChars(S: string; Chr: Char): string;
begin
  asm
    Lea   Si,S
    Lea   Di,S
    XOR   Cx,Cx
    Mov   Cl,Byte Ptr SS:[Si]
    Or    Cl,Cl
    Jz    @@Quitt
    Mov   Al,Cl
@@Translate:
    Inc   Si
    Inc   Di
    Mov   Ah,Byte Ptr SS:[Si]
    Cmp   Ah,Chr
    Jne   @@Exit
    Dec   Di
    Dec   Al
    Jmp   @@Loop
@@Exit:
    Mov   Byte Ptr SS:[Di],Ah
@@Loop:
    Loop  @@Translate
    Lea   Si,S
    Mov   Byte Ptr SS:[Si],Al
@@Quitt:
  end;
  DelChars := S;
end;

{**************************************************************************}

{ Wait routines }

const
  WaitCount: Integer = 0;
  SaveCursor: TCursor = crDefault;

procedure StartWait;
begin
  if WaitCount = 0 then begin
    SaveCursor := Screen.Cursor;
    Screen.Cursor := crHourGlass;
  end;
  Inc(WaitCount);
end;

procedure StopWait;
begin
  if WaitCount > 0 then begin
    Dec(WaitCount);
    if WaitCount = 0 then Screen.Cursor := SaveCursor;
  end;
end;


end.