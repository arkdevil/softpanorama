{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
Unit VerInfo;

{ Working with VERSIONINFO resourse type }

interface

Uses Ver;

type

  TVersionLanguage = (vlArabic, vlBulgarian, vlCatalan, vlTraditionalChinese,
    vlCzech, vlDanish, vlGerman, vlGreek, vlUSEnglish, vlCastilianSpanish,
    vlFinnish, vlFrench, vlHebrew, vlHungarian, vlIcelandic, vlItalian,
    vlJapanese, vlKorean, vlDutch, vlNorwegianBokmel, vlPolish,
    vlBrazilianPortuguese, vlRhaetoRomanic, vlRomanian, vlRussian,
    vlCroatoSerbian, vlSlovak, vlAlbanian, vlSwedish, vlThai, vlTurkish,
    vlUrdu, vlBahasa, vlSimplifiedChinese, vlSwissGerman, vlUKEnglish,
    vlMexicanSpanish, vlBelgianFrench, vlSwissItalian, vlBelgianDutch,
    vlNorwegianNynorsk, vlPortuguese, vlSerboCroatian, vlCanadianFrench,
    vlSwissFrench, vlUnknown);

  TVersionCharSet = (vcsASCII, vcsJapan, vcsKorea, vcsTaiwan, vcsUnicode,
    vcsEasternEuropean, vcsCyrillic, vcsMultilingual, vcsGreek, vcsTurkish,
    vcsHebrew, vcsArabic, vcsUnknown);

{ TVersionInfo }

  TVersionInfo = class(TObject)
  private
    FFileName: PChar;
    FValid: Boolean;
    FSize: Longint;
    FBuffer: PChar;
    FHandle: Longint;
    procedure ReadVersionInfo;
    function GetFileName: string;
    procedure SetFileName(const Value: string);
    function GetTranslation: Pointer;
    function GetFixedFileInfo: Pvs_FixedFileInfo;
    function GetTranslationString: string;
    function GetComments: string;
    function GetCompanyName: string;
    function GetFileDescription: string;
    function GetFileVersion: string;
    function GetVersionNum: Longint;
    function GetInternalName: string;
    function GetLegalCopyright: string;
    function GetLegalTrademarks: string;
    function GetOriginalFilename: string;
    function GetProductVersion: string;
    function GetProductName: string;
    function GetSpecialBuild: string;
    function GetPrivateBuild: string;
    function GetVersionLanguage: TVersionLanguage;
    function GetVersionCharSet: TVersionCharSet;
  public
    constructor Create(const AFileName: string);
    destructor Destroy; override;
    function GetVerValue(const VerName: string): string;
    property Valid: Boolean read FValid;
    property FileName: string read GetFileName write SetFileName;
    property FixedFileInfo: Pvs_FixedFileInfo read GetFixedFileInfo;
    property Translation: Pointer read GetTranslation;
    property VersionLanguage: TVersionLanguage read GetVersionLanguage;
    property VersionCharSet: TVersionCharSet read GetVersionCharSet;
    property Comments: string read GetComments;
    property CompanyName: string read GetCompanyName;
    property FileDescription: string read GetFileDescription;
    property FileVersion: string read GetFileVersion;
    property VersionNum: Longint read GetVersionNum;
    property InternalName: string read GetInternalName;
    property LegalCopyright: string read GetLegalCopyright;
    property LegalTrademarks: string read GetLegalTrademarks;
    property OriginalFilename: string read GetOriginalFilename;
    property ProductVersion: string read GetProductVersion;
    property ProductName: string read GetProductName;
    property SpecialBuild: string read GetSpecialBuild;
    property PrivateBuild: string read GetPrivateBuild;
  end;

{ Installation utility routines }

function OkToWriteModule(ModuleName: string; NewVer: Longint): Boolean;

implementation

Uses WinTypes, WinProcs, SysUtils;

function MemAlloc(Size: Longint): Pointer;
var
  Handle: THandle;
begin
  if Size < 65535 then
    GetMem(Result, Size)
  else
  begin
    Handle := GlobalAlloc(HeapAllocFlags, Size);
    Result := GlobalLock(Handle);
  end;
end;

const
  LanguageValues: array[TVersionLanguage] of Word = ($0401, $0402, $0403,
    $0404, $0405, $0406, $0407, $0408, $0409, $040A, $040B, $040C, $040D,
    $040E, $040F, $0410, $0411, $0412, $0413, $0414, $0415, $0416, $0417,
    $0418, $0419, $041A, $041B, $041C, $041D, $041E, $041F, $0420, $0421,
    $0804, $0807, $0809, $080A, $080C, $0810, $0813, $0814, $0816, $081A,
    $0C0C, $100C, $0000);

const
  CharacterSetValues: array[TVersionCharSet] of Integer = (0, 932, 949, 950,
    1200, 1250, 1251, 1252, 1253, 1254, 1255, 1256, -1);

{ TVersionInfo }

constructor TVersionInfo.Create(const AFileName: string);
begin
  FFileName := StrPCopy(StrAlloc(Length(AFileName) + 1), AFileName);
  ReadVersionInfo;
end;

destructor TVersionInfo.Destroy;
begin
  if FBuffer <> nil then FreeMem(FBuffer, FSize);
  StrDispose(FFileName);
end;

procedure TVersionInfo.ReadVersionInfo;
begin
  FValid := False;
  FSize := GetFileVersionInfoSize(FFileName, FHandle);
  if FSize > 0 then begin
    try
      FBuffer := MemAlloc(FSize);
      FValid := GetFileVersionInfo(FFileName, FHandle, FSize, FBuffer);
    except
      FValid := False;
      raise;
    end;
  end;
end;

function TVersionInfo.GetFileName: string;
begin
  Result := StrPas(FFileName);
end;

procedure TVersionInfo.SetFileName(const Value: string);
begin
  if FBuffer <> nil then FreeMem(FBuffer, FSize);
  StrDispose(FFileName);
  FFileName := StrPCopy(StrAlloc(Length(Value) + 1), Value);
  ReadVersionInfo;
end;

function TVersionInfo.GetTranslation: Pointer;
var
  Len: Word;
begin
  if Valid then VerQueryValue(FBuffer, '\VarFileInfo\Translation', Result, Len)
  else Result := nil;
end;

function TVersionInfo.GetTranslationString: string;
var
  P: Pointer;
begin
  P := GetTranslation;
  Result := '';
  if P <> nil then
    Result := IntToHex(MakeLong(HiWord(Longint(P^)), LoWord(Longint(P^))), 8);
end;

function TVersionInfo.GetVersionLanguage: TVersionLanguage;
var
  P: Pointer;
begin
  P := GetTranslation;
  for Result := vlArabic to vlUnknown do begin
    if LoWord(Longint(P^)) = LanguageValues[Result] then Break;
  end;
end;

function TVersionInfo.GetVersionCharSet: TVersionCharSet;
var
  P: Pointer;
begin
  P := GetTranslation;
  for Result := vcsASCII to vcsUnknown do begin
    if HiWord(Longint(P^)) = CharacterSetValues[Result] then Break;
  end;
end;

function TVersionInfo.GetFixedFileInfo: Pvs_FixedFileInfo;
var
  Len: Word;
begin
  if Valid then VerQueryValue(FBuffer, '\', Pointer(Result), Len)
  else Result := nil;
end;

function TVersionInfo.GetVersionNum: Longint;
begin
  Result := 0;
  if Valid then Result := FixedFileInfo^.dwFileVersionMS;
end;

function TVersionInfo.GetVerValue(const VerName: string): string;
var
  szName: array[0..255] of Char;
  Value: Pointer;
  Len: Word;
begin
  Result := '';
  if Valid then begin
    StrPCopy(szName, '\StringFileInfo\' + GetTranslationString +
      '\' + VerName);
    if VerQueryValue(FBuffer, szName, Value, Len) then
      Result := StrPas(PChar(Value));
  end;
end;

function TVersionInfo.GetComments: string;
begin
  Result := GetVerValue('Comments');
end;

function TVersionInfo.GetCompanyName: string;
begin
  Result := GetVerValue('CompanyName');
end;

function TVersionInfo.GetFileDescription: string;
begin
  Result := GetVerValue('FileDescription');
end;

function TVersionInfo.GetFileVersion: string;
begin
  Result := GetVerValue('FileVersion');
end;

function TVersionInfo.GetInternalName: string;
begin
  Result := GetVerValue('InternalName');
end;

function TVersionInfo.GetLegalCopyright: string;
begin
  Result := GetVerValue('LegalCopyright');
end;

function TVersionInfo.GetLegalTrademarks: string;
begin
  Result := GetVerValue('LegalTrademarks');
end;

function TVersionInfo.GetOriginalFilename: string;
begin
  Result := GetVerValue('OriginalFilename');
end;

function TVersionInfo.GetProductVersion: string;
begin
  Result := GetVerValue('ProductVersion');
end;

function TVersionInfo.GetProductName: string;
begin
  Result := GetVerValue('ProductName');
end;

function TVersionInfo.GetSpecialBuild: string;
begin
  Result := GetVerValue('SpecialBuild');
end;

function TVersionInfo.GetPrivateBuild: string;
begin
  Result := GetVerValue('PrivateBuild');
end;

{ Installation utility routines }

function OkToWriteModule(ModuleName: string; NewVer: Longint): Boolean;
{ Return True if it's ok to overwrite ModuleName with NewVer }
begin
  {Assume we should overwrite}
  OkToWriteModule := True;
  with TVersionInfo.Create(ModuleName) do begin
    try
      if Valid then {Should we overwrite?}
        OkToWriteModule := NewVer > VersionNum;
    finally
      Free;
    end;
  end;
end;

end.