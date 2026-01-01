' Copyright (C) Telelink Systems 1991
' Phone:  (916) 332-2671
' Fax:    (916) 332-2529
' Cserve: 70523,2574


Declare Function VBEnumFonts Lib "enumfont.dll" (ByVal hDC%, ByVal lpFaceName As Any, lpLogFontArray As Any, lpTextMetricArray As Any, nFontTypeArray As Any, ByVal nArraySize%) As Integer


'-- Logical font structure
Global Const LF_FACESIZE = 32
Type LOGFONT
    lfheight As Integer
    lfwidth As Integer
    lfEscapement As Integer
    lforientation As Integer
    lfWeight As Integer
    lfItalic As String * 1
    lfUnderline As String * 1
    lfStrikeout As String * 1
    lfCharSet As String * 1
    lfOutPrecision As String * 1
    lfClipPrecision As String * 1
    lfQuality As String * 1
    lfPitchAndFamily As String * 1
    lfFaceName As String * LF_FACESIZE
End Type

'-- text metrics structure
Type TEXTMETRIC
    tmHeight As Integer
    tmAscent As Integer
    tmDescent As Integer
    tmInternalLeading As Integer
    tmExternalLeading As Integer
    tmAveCharWidth As Integer
    tmMaxCharWidth As Integer
    tmWeight As Integer
    tmItalic As String * 1
    tmUnderlined As String * 1
    tmStruckout As String * 1
    tmFirstChar As String * 1
    tmLastChar As String * 1
    tmDefaultChar As String * 1
    tmBreakChar As String * 1
    tmPitchAndFamily As String * 1
    tmCharSet As String * 1
    tmOverhang As Integer
    tmDigitizedAspectX As Integer
    tmDigitizedAspectY As Integer
End Type

Global Const OUT_DEFAULT_PRECIS = 0
Global Const OUT_STRING_PRECIS = 1
Global Const OUT_CHARACTER_PRECIS = 2
Global Const OUT_STROKE_PRECIS = 3

Global Const CLIP_DEFAULT_PRECIS = 0
Global Const CLIP_CHARACTER_PRECIS = 1
Global Const CLIP_STROKE_PRECIS = 2

Global Const DEFAULT_QUALITY = 0
Global Const DRAFT_QUALITY = 1
Global Const PROOF_QUALITY = 2

Global Const DEFAULT_PITCH = 0
Global Const FIXED_PITCH = 1
Global Const VARIABLE_PITCH = 2

Global Const ANSI_CHARSET = 0
Global Const SYMBOL_CHARSET = 2
Global Const SHIFTJIS_CHARSET = 128
Global Const OEM_CHARSET = 255

'  Font Families
'
Global Const FF_DONTCARE = 0    '  Don't care or don't know.
Global Const FF_ROMAN = 16  '  Variable stroke width, serifed.

'  Times Roman, Century Schoolbook, etc.
Global Const FF_SWISS = 32  '  Variable stroke width, sans-serifed.

'  Helvetica, Swiss, etc.
Global Const FF_MODERN = 48 '  Constant stroke width, serifed or sans-serifed.

'  Pica, Elite, Courier, etc.
Global Const FF_SCRIPT = 64 '  Cursive, etc.
Global Const FF_DECORATIVE = 80 '  Old English, etc.


'-- mapping modes
Declare Function SetMapMode Lib "GDI" (ByVal hDC As Integer, ByVal nMapMode As Integer) As Integer
Declare Function GetMapMode Lib "GDI" (ByVal hDC As Integer) As Integer

'  Mapping Modes
Global Const MM_TEXT = 1
Global Const MM_LOMETRIC = 2
Global Const MM_HIMETRIC = 3
Global Const MM_LOENGLISH = 4
Global Const MM_HIENGLISH = 5
Global Const MM_TWIPS = 6
Global Const MM_ISOTROPIC = 7
Global Const MM_ANISOTROPIC = 8

Declare Function GetDeviceCaps Lib "GDI" (ByVal hDC As Integer, ByVal nIndex As Integer) As Integer
'  Device Parameters for GetDeviceCaps()
Global Const DRIVERVERSION = 0  '  Device driver version
Global Const TECHNOLOGY = 2 '  Device classification
Global Const HORZSIZE = 4   '  Horizontal size in millimeters
Global Const VERTSIZE = 6   '  Vertical size in millimeters
Global Const HORZRES = 8    '  Horizontal width in pixels
Global Const VERTRES = 10   '  Vertical width in pixels
Global Const BITSPIXEL = 12 '  Number of bits per pixel
Global Const PLANES = 14    '  Number of planes
Global Const NUMBRUSHES = 16    '  Number of brushes the device has
Global Const NUMPENS = 18   '  Number of pens the device has
Global Const NUMMARKERS = 20    '  Number of markers the device has
Global Const NUMFONTS = 22  '  Number of fonts the device has
Global Const NUMCOLORS = 24 '  Number of colors the device supports
Global Const PDEVICESIZE = 26   '  Size required for device descriptor
Global Const CURVECAPS = 28 '  Curve capabilities
Global Const LINECAPS = 30  '  Line capabilities
Global Const POLYGONALCAPS = 32 '  Polygonal capabilities
Global Const TEXTCAPS = 34  '  Text capabilities
Global Const CLIPCAPS = 36  '  Clipping capabilities
Global Const RASTERCAPS = 38    '  Bitblt capabilities
Global Const ASPECTX = 40   '  Length of the X leg
Global Const ASPECTY = 42   '  Length of the Y leg
Global Const ASPECTXY = 44  '  Length of the hypotenuse

Global Const LOGPIXELSX = 88    '  Logical pixels/inch in X
Global Const LOGPIXELSY = 90    '  Logical pixels/inch in Y

Global Const SIZEPALETTE = 104  '  Number of entries in physical palette
Global Const NUMRESERVED = 106  '  Number of reserved entries in palette
Global Const COLORRES = 108 '  Actual color resolution

