unit Bitmap;

{ define bmp_usegraph if you don't have VgaMem
}

{ Unit Bitmap, Version 1.20, Copr. 1994,95 Matthias KФppe

  Translate a device-independent bitmap, loaded by LoadBitmap or
  LoadBitmapFile, into an image, which can be drawn by PutImage.

  Supported video modes		Supported bitmaps
  * 16-color modes		* monochrome bitmaps
  * 256-color modes		* 16-color bitmaps
				* 256-color bitmaps

  Call BitmapToImage, and a nearest-color mapping table will be used.
  This is created by analyzing the bitmap's and the device's palette.

  Call BitmapToImageWithUserPalette if you want to use a user-defined
  mapping table. Set UserPalette nil for using an original map with
  color bitmaps, or the Color/BkColor variables with monochrome bitmaps.

  Instead of Graph's PutImage procedure, we recommend using the
  one implemented in our VgaMem unit: It performs correct clipping.
}

interface

uses WinRes;

var
  Color, BkColor: Word;

const
  ColorWeights: TRGBTriple = (rgbtBlue: 1; rgbtGreen: 1; rgbtRed: 1);

{ Bitmap functions
}

function BitmapToImage(ABitmap: PBitmap): pointer;
function BitmapToImageWithUserPalette(ABitmap: PBitmap;
  UserPalette: pointer): pointer;
procedure AddDevicePalette(ABitmap: PBitmap);

{ Palette functions
}

type
  TColorRef = LongInt;

function GetNearestPaletteIndex(Color: TColorRef): Word;

{
}

procedure SetTable(Table: Word);

implementation { ────────────────────────────────────────────────────────── }

{$ifdef bmp_usegraph}
uses Graph, Objects;	{ for ImageSize/Stream }

procedure FreeImage(Image: pointer);
begin
  with PImage(Image)^ do
    FreeMem(Image, ImageSize(0, 0, imSizeXm1, imSizeYm1))
end;

{$else}
uses VgaMem, Objects;	{ for ImageSize/Stream }
{$endif}

{ Low-level bitmap functions ──────────────────────────────────────────────
}
var
  Bmp2ImgRowProc: Word;

procedure Bmp2ImgRow_16; near; external;
procedure Bmp2ImgRow_256; near; external;

procedure DoBitmapToImage(ABitmap: PBitmap; Image: pointer;
  Palette: pointer); near; external;

{$L bmp.obj (bmp.asm) }

{ Low-level palette functions ────────────────────────────────────────────
}
var
  GetDevPalProc: Word;

procedure GetDevPal_16; near; external;
procedure GetDevPal_256; near; external;

procedure GetDevicePalette(var Palette: array of TRGBTriple); near; external;
procedure DoCalcPalette(var BmpPal; Count, EntrySize: Word;
  var PalBuf); near; external;

{$L palette.obj (palette.asm) }

procedure TripleToQuad(var Triple, Quad; Count: Word); near; external;

{$L wrespal.obj (wrespal.asm) }

{ ────────────────────────────────────────────────────────────────────────
}

function PrepareImage(SrcBmp: PBitmap): pointer;
var
  Image: PImage;
  size: LongInt;
begin
  Image := nil;
  with SrcBmp^ do
  begin
    size := ImageSize(0, 0, bmWidth-1, abs(bmHeight)-1);
    If size <> 0
    then begin		{ small image }
      GetMem(Image, size);
      with Image^ do
      begin
	imSizeXm1 := bmWidth - 1;
	imSizeYm1 := abs(bmHeight) - 1;
      end
    end
{$ifndef bmp_usegraph}
    else begin
      New(Image);
      with Image^ do
      begin
	imSizeXm1 := -1;
	imSizeYm1 := -1;
	imFast := BitmapAllocProc(SrcBmp, imBmpPtr);
      end
    end
{$endif}
  end;
  PrepareImage := Image
end;

function BitmapToImageWithUserPalette(ABitmap: PBitmap;
  UserPalette: pointer): pointer;
var
  Image: pointer;
Begin
  with ABitmap^ do Begin
    Image := PrepareImage(ABitmap);
    If Image <> nil then
      DoBitmapToImage(ABitmap, Image, UserPalette)
  End;
  BitmapToImageWithUserPalette := Image
End;

function BitmapToImage(ABitmap: PBitmap): pointer;
var
  PalBuf: array[0..255] of Byte;
  Pal: pointer;
Begin
  Pal := nil;
  with ABitmap^ do
    If bmPalette <> nil then Begin
      DoCalcPalette(bmPalette^, 1 shl (bmBitsPixel * bmPlanes),
	SizeOf(TRGBQuad), PalBuf);
      Pal := @PalBuf
    End;
  BitmapToImage := BitmapToImageWithUserPalette(ABitmap, Pal)
End;

procedure AddDevicePalette(ABitmap: PBitmap);
var
  DevPal: array[0..255] of TRGBTriple;
  count: Word;
Begin
  with ABitmap^ do
    If bmPalette = nil then Begin
      GetDevicePalette(DevPal);
      count := 1 shl (bmBitsPixel * bmPlanes);
      GetMem(bmPalette, SizeOf(TRGBQuad) * count);
      If Count = 2 then Begin
	FillChar(bmPalette^, SizeOf(TRGBQuad) * 2, 0);
	Move(DevPal[BkColor], bmPalette^, SizeOf(TRGBTriple));
	Move(DevPal[Color], (PChar(bmPalette)+SizeOf(TRGBQuad))^,
	  SizeOf(TRGBTriple));
      End
      else TripleToQuad(DevPal, bmPalette^, Count)
    End
End;

function GetNearestPaletteIndex(Color: TColorRef): Word;
var
  Res: TColorRef;
Begin
  DoCalcPalette(Color, 1, 4, Res);
  GetNearestPaletteIndex := Res
End;

procedure SetTable(Table: Word);
Begin
  if Table and 1 = 0
  then Begin
    Bmp2ImgRowProc := Ofs(Bmp2ImgRow_16);
    GetDevPalProc := Ofs(GetDevPal_16)
  End
  else Begin
    Bmp2ImgRowProc := Ofs(Bmp2ImgRow_256);
    GetDevPalProc := Ofs(GetDevPal_256)
  End
End;

var
  oldBitmapLoadProc: TBitmapLoadProc;

function BmpBitmapLoad(var BitmapInfoHeader: TBitmapInfoHeader;
  var S: TStream; Size: LongInt; Palette: pointer;
  CreateImage: Boolean): pointer; far;
var
  Bitmap: PBitmap;
  Image: pointer;
Begin
  Bitmap := oldBitmapLoadProc(BitmapInfoHeader, S, Size, Palette, false);
  If CreateImage then Begin
    Image := BitmapToImage(Bitmap);
    DeleteBitmap(Bitmap);
    BmpBitmapLoad := Image
  End
  else
    BmpBitmapLoad := Bitmap
End;

begin
  SetTable(0);
  oldBitmapLoadProc := BitmapLoadProc;
  BitmapLoadProc := BmpBitmapLoad
end.
