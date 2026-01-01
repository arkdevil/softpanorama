
{***************************************************}
{                                                   }
{        L e c a r                                  }
{   Turbo Pascal 6.X,7.X                            }
{   Попросту, без чинов и Copyright-ов  1991,92,93  }
{   Версия 2.0 от ...... (нужное дописать)          }
{***************************************************}


{$A+,B-,D+,E-,F-,G+,I-,L+,N-,O-,R-,S-,V-,X+}
{$M 16384,0,655360}

Unit Giftypes;

Interface

Const
  HT_Size     = 8192;      { 12 бит = 4096 в два раза больше }
  HT_KeyMask  = $1FFF;     { 13 битный ключ }
  HT_Numbits  = 13;
  HT_MaxKey   = 8191;      { 13 бит -1, максимально возможный код }
  HT_MaxCode  = 4095;      { Максимально возможный 12 - битный код }
  Error       = 0;
  OK          = 1;

  GifStamp    : String[6] = 'GIF87a';
  GifStampLen = SizeOf(GifStamp)-1;

  LZMaxCode   = 4095;
  LZBits      = 12;

  FileStateRead   = 1;
  FileStateWrite  = 1;
  FileStateScreen = 2;
  FileStateImage  = 4;
  FlushOutput   = 4096;
  FirstCode     = 4097;
  NoSuchCode    = 4098;

Type
  PGifHashTable = ^TGifHashTable;
  TGifHashTable = Array [0..HT_Size-1] of Longint;

  TByte  = Array [0..$FFF] of Byte;
  PPixel = ^TPixel;
  TPixel = TByte;
  PByte  = ^TByte;
  PPByte = ^PByte;
  PInt   = ^Integer;
  PWord  = ^Word;
  PGifColor = ^TGifColor;
  PGifFile = ^TGifFile;
  TGifColorRec = record
    Red, Green, Blue : Byte;
  end;
  TGifColor = Array [0..$100] of TGifColorRec;
  TGifFile = record
    SWidth, SHeight,                   { размер экрана }
    SColorResolution, SBitsPerPixel,   { количество возможных цветов }
    SBackGroundColor,
    ILeft, ITop, IWidth, IHeight,      { текущий размер изображения }
    IInterlace,
    IBitsPerPixel : Integer;
    SColorMap, IColorMap : PGifColor;
    Private : Pointer;
  end;
  PGifRecord = ^TGifRecord;
  TGifRecord = (Undefine, Screen_Desc, Image_Desc, TExtension, TTerminate);

Var
  GifError : Integer;

Implementation

End.