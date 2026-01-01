Declare Function AnsiToAscii$ Lib "VBIT.DLL" (ByVal strIn$)
Declare Function AsciiToAnsi$ Lib "VBIT.DLL" (ByVal strIn$)
Declare Function CRLF$ Lib "VBIT.DLL" (ByVal strIn$, ByVal ascii%)
Declare Function Decrypt$ Lib "VBIT.DLL" (ByVal strIn$, ByVal cryptStr$)
Declare Function Decrypt7$ Lib "VBIT.DLL" (ByVal strIn$, ByVal cryptStr$)
Declare Function DecryptZ$ Lib "VBIT.DLL" (ByVal strIn$, ByVal cryptStr$)
Declare Function Encrypt$ Lib "VBIT.DLL" (ByVal strIn$, ByVal cryptStr$)
Declare Function Encrypt7$ Lib "VBIT.DLL" (ByVal strIn$, ByVal cryptStr$)
Declare Function EncryptZ$ Lib "VBIT.DLL" (ByVal strIn$, ByVal cryptStr$)
Declare Function FileExist% Lib "VBIT.DLL" (ByVal fileName$)
Declare Function FileFindPath$ Lib "VBIT.DLL" (ByVal fileName$)
Declare Function FileGetAttr$ Lib "VBIT.DLL" (ByVal fileName$)
Declare Function FileGetDate$ Lib "VBIT.DLL" (ByVal fileName$)
Declare Function FileGetExt$ Lib "VBIT.DLL" (ByVal fileName$)
Declare Function FileGetFilename$ Lib "VBIT.DLL" (ByVal fileName$)
Declare Function FileGetName$ Lib "VBIT.DLL" (ByVal fileName$)
Declare Function FileGetPath$ Lib "VBIT.DLL" (ByVal fileName$)
Declare Function FileGetSize& Lib "VBIT.DLL" (ByVal fileName$)
Declare Function FileGetTime$ Lib "VBIT.DLL" (ByVal fileName$)
Declare Function FileGetVersion$ Lib "VBIT.DLL" (ByVal fileName$)
Declare Function Find% Lib "VBIT.DLL" (ByVal findString$, ByVal inString$, ByVal pos%)
Declare Function FullPath$ Lib "VBIT.DLL" (ByVal filePattern$)
Declare Function InifileGetString$ Lib "VBIT.DLL" (ByVal fileName$, ByVal section$, ByVal entry$)
Declare Function IniFilePutString% Lib "VBIT.DLL" (ByVal fileName$, ByVal section$, ByVal entry$, ByVal newString$)
Declare Function LicenseGetCode$ Lib "VBIT.DLL" (ByVal lname$, ByVal lcode$)
Declare Function LicenseVBIT% Lib "VBIT.DLL" (ByVal lname$, ByVal lcode$)
Declare Function LicenseProgram% Lib "VBIT.DLL" (ByVal lname$, ByVal lcode$, ByVal key$)
Declare Function Modulus10$ Lib "VBIT.DLL" (ByVal strIn$)
Declare Function Modulus10Calc$ Lib "VBIT.DLL" (ByVal strIn$)
Declare Function Modulus10Valid% Lib "VBIT.DLL" (ByVal strIn$)
Declare Function Modulus11$ Lib "VBIT.DLL" (ByVal strIn$)
Declare Function Modulus11Calc$ Lib "VBIT.DLL" (ByVal strIn$)
Declare Function Modulus11Valid% Lib "VBIT.DLL" (ByVal strIn$)
Declare Function Num0$ Lib "VBIT.DLL" (ByVal value&, ByVal nDigits%)
Declare Function Pick$ Lib "VBIT.DLL" (ByVal strIn$, ByVal pos%, ByVal num%)
Declare Function PickWord$ Lib "VBIT.DLL" (ByVal strIn$, ByVal pos%, ByVal delim%)
Declare Function PickWords$ Lib "VBIT.DLL" (ByVal strIn$, ByVal pos%, ByVal num%, ByVal delim%)
Declare Function Place$ Lib "VBIT.DLL" (ByVal fromStr$, ByVal toStr$, ByVal pos%, ByVal num%)
Declare Function Strip$ Lib "VBIT.DLL" (ByVal strIn$, ByVal delim$, ByVal stripType%)
Declare Function Subst$ Lib "VBIT.DLL" (ByVal oldStr$, ByVal newStr$, ByVal inString$, pos%)
Declare Function SubstAll$ Lib "VBIT.DLL" (ByVal oldStr$, ByVal newStr$, ByVal inString$)
Declare Function SwapChrs$ Lib "VBIT.DLL" (ByVal strIn$, ByVal chrs$)
Declare Function SwapDate$ Lib "VBIT.DLL" (ByVal dateIn$)
Declare Function SwapStr$ Lib "VBIT.DLL" (ByVal strIn$, ByVal fromFmt$, ByVal toFmt$)
Declare Function SysInfo$ Lib "VBIT.DLL" (ByVal what%)
Declare Function SysInfoNum& Lib "VBIT.DLL" (ByVal what%)
Declare Sub Trace Lib "VBIT.DLL" (ByVal strIn$)
Declare Sub TraceStr Lib "VBIT.DLL" (ByVal strIn$)

' Types for Strip (Leading/Trailing or Left/Right):
Global Const STRIP_L% = &H100
Global Const STRIP_T% = &H200
Global Const STRIP_R% = &H200
Global Const STRIP_LT% = &H300
Global Const STRIP_LR% = &H300
Global Const STRIP_ALL% = &H400

' Types for SysInfo:
Global Const SCREEN_SIZE_X% = 1
Global Const SCREEN_SIZE_Y% = 2
Global Const SCREEN_SIZE_PALETTE% = 3
Global Const MEMORY_FREE_KB% = 4
Global Const MEMORY_BIGGEST_FREE_BLOCK_KB% = 5
Global Const DISK_DRIVE% = 6
Global Const DIR_WINDOWS% = 7
Global Const DIR_WINDOWS_SYSTEM% = 8
Global Const DISK_FREE_KB% = &H80
Global Const DISK_SIZE_KB% = &H100
Global Const DISK_PATH% = &H1000
Global Const DISK_TYPE% = &H1080
Global Const DISK_VOLUME_SERIAL_NUMBER% = &H1100
Global Const DISK_VOLUME_LABEL% = &H1180
Global Const DISK_VOLUME_DATE% = &H1200
Global Const DISK_VOLUME_TIME% = &H1280

' SysInfo(DISK_TYPE) returns:
Global Const DRIVE_REMOVABLE% = 2
Global Const DRIVE_FIXED% = 3
Global Const DRIVE_REMOTE% = 4

Declare Sub ITabCopy Lib "VBIT.DLL" (ByVal fromTab&, ByVal fromLine%, ByVal toTab&, ByVal toLine%, ByVal num%)
Declare Function ITabDir& Lib "VBIT.DLL" (ByVal fileName$, ByVal fileType&)
Declare Function ITabEnvList& Lib "VBIT.DLL" ()
Declare Function ITabEnvString& Lib "VBIT.DLL" (ByVal envVar$)
Declare Function ITabFileInfo& Lib "VBIT.DLL" (ByVal fileName$)
Declare Function ITabFind% Lib "VBIT.DLL" (ByVal table&, ByVal findStr$, ByVal row%, ByVal col%, ByVal typ%)
Declare Function ITabFindGE% Lib "VBIT.DLL" (ByVal table&, ByVal findStr$, ByVal col%)
Declare Function ITabFromString& Lib "VBIT.DLL" (ByVal s$, ByVal delim$)
Declare Function ITabGet$ Lib "VBIT.DLL" (ByVal table&, ByVal lin%, ByVal col%)
Declare Function ITabGetColWidth% Lib "VBIT.DLL" (ByVal table&, ByVal col%)
Declare Function ITabGetInt% Lib "VBIT.DLL" (ByVal table&, ByVal lin%, ByVal col%)
Declare Function ITabGetLine$ Lib "VBIT.DLL" (ByVal table&, ByVal lin%)
Declare Function ITabGetLong& Lib "VBIT.DLL" (ByVal table&, ByVal lin%, ByVal col%)
Declare Function ITabGetNumColumns% Lib "VBIT.DLL" (ByVal table&)
Declare Function ITabGetNumLines% Lib "VBIT.DLL" (ByVal table&)
Declare Function ITabGetReal# Lib "VBIT.DLL" (ByVal table&, ByVal lin%, ByVal col%)
Declare Function ITabGetSize& Lib "VBIT.DLL" (ByVal table&)
Declare Function ITabNew& Lib "VBIT.DLL" (ByVal lines%, ByVal cols%)
Declare Function ITabNewArray& Lib "VBIT.DLL" (ByVal lines%)
Declare Function ITabRead& Lib "VBIT.DLL" (ByVal fileName$, ByVal fileType&)
Declare Function ITabReadFixedRecLenFile& Lib "VBIT.DLL" (ByVal fileName$, ByVal fmt$)
Declare Function ITabWrite% Lib "VBIT.DLL" (ByVal table&, ByVal fileName$, ByVal fileType&)
Declare Sub ITabBlankLine Lib "VBIT.DLL" (ByVal table&, ByVal atLine%)
Declare Sub ITabBlankLines Lib "VBIT.DLL" (ByVal table&, ByVal atLine%, ByVal num%)
Declare Sub ITabCopyToGRID Lib "VBIT.DLL" (ByVal table&, ByVal ssHandle&)
Declare Sub ITabDelete Lib "VBIT.DLL" (table&)
Declare Sub ITabInsertLine Lib "VBIT.DLL" (ByVal table&, ByVal atLine%)
Declare Sub ITabInsertLines Lib "VBIT.DLL" (ByVal table&, ByVal atLine%, ByVal num%)
Declare Sub ITabPut Lib "VBIT.DLL" (ByVal table&, ByVal lin%, ByVal col%, ByVal dataStr$)
Declare Sub ITabPutInt Lib "VBIT.DLL" (ByVal table&, ByVal lin%, ByVal col%, ByVal value%)
Declare Sub ITabPutLine Lib "VBIT.DLL" (ByVal table&, ByVal lin%, ByVal dataStr$)
Declare Sub ITabPutLong Lib "VBIT.DLL" (ByVal table&, ByVal lin%, ByVal col%, ByVal value&)
Declare Sub ITabPutReal Lib "VBIT.DLL" (ByVal table&, ByVal lin%, ByVal col%, value#)
Declare Sub ITabRemoveLine Lib "VBIT.DLL" (ByVal table&, ByVal atLine%)
Declare Sub ITabRemoveLines Lib "VBIT.DLL" (ByVal table&, ByVal atLine%, ByVal num%)
Declare Sub ITabFastSort Lib "VBIT.DLL" (ByVal table&, ByVal col%)
Declare Sub ITabSmartSort Lib "VBIT.DLL" (ByVal table&, ByVal col%)

' For debug/testing:
Declare Function ITabUsed& Lib "VBIT.DLL" ()
Declare Function ITabChainGetFirst& Lib "VBIT.DLL" ()
Declare Function ITabChainGetNext& Lib "VBIT.DLL" (ByVal table&)
Declare Function ITabDeleteAll& Lib "VBIT.DLL" ()

'Constants for ITabRead/ITabWrite (may also use STRIP* defined above)
Global Const IT_TEXTFILE% = 0
Global Const IT_TABFILE& = &H10000
Global Const IT_CSVFILE& = &H20000
Global Const IT_CSV0FILE& = &H40000
Global Const IT_ASCII% = &H800

'Constants for ITabFind..
Global Const IT_EXACT% = 0
Global Const IT_GE% = 1024
Global Const IT_WILD% = 2048
Global Const IT_FOLD% = 4096


