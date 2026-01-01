{$IFDEF Debug}
  {$D+}
{$ELSE}
  {$D-}
{$ENDIF}

{$S-,R-,V-,I-,B-,F+}

{$IFNDEF Ver40}
  {$I OPLUS.INC}
{$ENDIF}

{*********************************************************}
{*                    TPDOS.PAS 5.05                     *}
{*        Copyright (c) TurboPower Software 1987.        *}
{* Portions copyright (c) Sunny Hill Software 1985, 1986 *}
{*     and used under license to TurboPower Software     *}
{*                 All rights reserved.                  *}
{*********************************************************}
{*  Модуль доработан О.П.Пилипенко для совместимости со  *}
{*     всеми версиями Turbo Pascal - от 4.0 до 6.0       *}
{*********************************************************}


unit TpDos;
  {-Miscellaneous DOS/BIOS call routines}

interface

uses
  Dos,
  TpString;

type
  ActionCodeType = (
    ExecSaveScreen, ExecShowMemory, ExecPauseAfterRun, ExecRestoreScreen);
  DiskClass = (
    Floppy360, Floppy720, Floppy12, Floppy144, OtherFloppy, Bernoulli,
    HardDisk, RamDisk, SubstDrive, UnknownDisk, InvalidDrive);

var
  IoResultPtr : Pointer;     {if not nil, must point to a routine like
                              Int24Result that returns an I/O error code}
const
  StackSafetyMargin : Word = 1000;
  MinSpaceForDos : Word = 20000; {Minimum bytes for DOS shell to run}

  StdInHandle = 0;           {handle numbers for OpenStdDev}
  StdOutHandle = 1;
  StdErrHandle = 2;
  StdPrnHandle = 4;

function DOSVersion : Word;
  {-Returns the DOS version number. High byte has major version number,
    low byte has minor version number. Eg., DOS 3.1 => $0301.}

function NumberOfDrives : Byte;
  {-Returns the number of logical drives}

procedure SelectDrive(Drive : Char);
  {-Selects the specified drive as default if possible}

function DefaultDrive : Char;
  {-Returns the default drive as an uppercase letter}

function GetDiskInfo(Drive : Byte; var ClustersAvailable, TotalClusters,
                     BytesPerSector, SectorsPerCluster : Word) : Boolean;
  {-Return technical info about the specified drive}

function GetDiskClass(Drive : Char; var SubstDriveChar : Char) : DiskClass;
  {-Return the disk class for the drive with the specified letter}

function ReadDiskSectors(Drive : Word; FirstSect : Longint;
                         NumSects : Word; var Buf) : Boolean;
  {-Read absolute disk sectors.}

function WriteDiskSectors(Drive : Word; FirstSect : Longint;
                          NumSects : Word; var Buf) : Boolean;
  {-Write absolute disk sectors.}

function GetFileMode(FName : string; var Attr : Word) : Byte;
  {-Returns a file's attribute in Attr and the DOS error code as the function
    result.}

function FileHandlesLeft : Byte;
  {-Return the number of available file handles}

function FileHandlesOpen(CountDevices : Boolean) : Byte;
  {-Return the number of open files owned by a program}

procedure SetDta(DTAptr : Pointer);
  {-Set the DOS DTA to point to DTAptr}

procedure GetDta(var DTAptr : Pointer);
  {-Return the DOS DTA pointer}

function VerifyOn : Boolean;
  {-Returns True if disk write verification is on}

procedure SetVerify(On : Boolean);
  {-Turn disk write verification on/off}

function ParsePath(var InputPath, SearchPath, LeadInPath : string) : Boolean;
  {-Takes a user entered path, trims blanks, and returns a valid global
    search path and a valid lead-in path.}

function PrintInstalled : Boolean;
  {-Returns True if PRINT.COM is installed}

function SubmitPrintFile(FileName : string) : Byte;
  {-This procedure submits a file to the PC DOS 3.0 or greater concurrent
   print utility.}

procedure CancelPrintFile(FileMask : string);
  {-Cancels the files matched by the file mask passed in FileMask.}

procedure CancelAllPrintFiles;
  {-Cancels all files in the print queue}

function GetPrintStatus(var QPtr : Pointer) : Byte;
 {-Halts printing, returns current error status, puts pointer to the filename
   queue in the QPtr variable. Filenames in the queue are 64-byte ASCIIZ
   strings. The end of the queue is marked by a name starting with a null.}

procedure EndPrintStatus;
  {-Releases the spooler from the GetPrintStatus procedure.}

function GetEnvironmentString(SearchString : string) : string;
  {-Return a string from the environment}

function SetBlock(var Paragraphs : Word) : Boolean;
  {-Change size of DOS memory block allocated to this program}

function ExecDos(Command : string; UseSecond : Boolean; UserRoutine : Pointer) : Integer;
 {-Execute any DOS command. Call with Command = '' for a new shell.
   If UseSecond is false, Command must be the full pathname of a program to
   be executed. UserRoutine is the address of a routine to display status,
   save/restore the screen, etc., or a nil pointer. It must be of the form:

   procedure UserRoutine(ActionCode : ActionCodeType; Param : Word);

   and it must have the FAR attribute. ExecDos return codes are as follows:
         0 : Success
        -1 : Insufficient memory to store free list
        -2 : DOS setblock error before EXEC call
        -3 : DOS setblock error after EXEC call  -- critical error!
        -4 : Insufficient memory to run DOS command
      else   a DOS error code
  }

function TextSeek(var F : Text; Target : LongInt) : Boolean;
 {-Do a Seek for a text file opened for input. Returns False in case of I/O
   error.}

function TextFileSize(var F : Text) : LongInt;
  {-Return the size of text file F. Returns -1 in case of I/O error.}

function TextPos(var F : Text) : LongInt;
 {-Return the current position of the logical file pointer (that is,
   the position of the physical file pointer, adjusted to account for
   buffering). Returns -1 in case of I/O error.}

function TextFlush(var F : Text) : Boolean;
  {-Flush the buffer(s) for a text file. Returns False in case of I/O error.}

function OpenStdDev(var F : Text; StdHandle : Word) : Boolean;
  {-Assign the text file to a standard DOS device: 0, 1, 2, or 4}

function HandleIsConsole(Handle : Word) : Boolean;
  {-Return true if handle is the console device}

procedure SetRawMode(var F : Text; On : Boolean);
  {-Set "raw" mode on or off for the specified text file (must be a device)}

function ExistFile(FName : string) : Boolean;
  {-Return true if file is found}

function ExistOnPath(FName : string; var FullName : string) : Boolean;
 {-Return true if fname is found in
   a) current directory
   b) program's directory (DOS 3.X only)
   c) any DOS path directory
  and return full path name to file}

function TimeMs : LongInt;
  {-Return time of day in milliseconds since midnight}

  {============================================================================}

implementation

type
  SegOfs = record
             O, S : Word;
           end;
  LongRec = record
              LowWord, HighWord : Word; {structure of a LongInt}
            end;

  {text buffer}
  TextBuffer = array[0..65520] of Byte;

  {structure of a Turbo File Interface Block}
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
const
  FMClosed = $D7B0;
  FMInput = $D7B1;
  FMOutput = $D7B2;
  FMInOut = $D7B3;
var
  Regs : Registers;

  function DOSVersion : Word;
  {-Returns the DOS version number. High byte has major version number,
    low byte has minor version number. Eg., DOS 3.1 => $030A ($A = 10).}
  begin
    with Regs do begin
      AH := $30;             {Get MS-DOS version number}
      MsDos(Regs);
      DOSVersion := Swap(AX); {put major version in high byte, minor in low}
    end;
  end;

  {$L TPDISK.OBJ}

  function NumberOfDrives : Byte; external;
  procedure SelectDrive(Drive : Char); external;
  function DefaultDrive : Char; external;
  function GetDiskInfo(Drive : Byte; var ClustersAvailable, TotalClusters,
                       BytesPerSector, SectorsPerCluster : Word) : Boolean;
    external;
  function ReadDiskSectors(Drive : Word; FirstSect : Longint;
                           NumSects : Word; var Buf) : Boolean;
    external;
  function WriteDiskSectors(Drive : Word; FirstSect : Longint;
                            NumSects : Word; var Buf) : Boolean;
    external;

  function GetDiskClass(Drive : Char; var SubstDriveChar : Char) : DiskClass;
    {-Return the disk class for the drive with the specified letter}
    {-This routine uses an undocumented DOS function ($32). Information about
      this function was obtained from Terry Dettmann's DOS Programmer's
      Reference (Que, 1988).}
  type
    ParamBlock =
      record
        DriveNumber, DeviceDriverUnit : Byte;
        BytesPerSector : Word;
        SectorsPerCluster, ShiftFactor : Byte;
        ReservedBootSectors : Word;
        FatCopies : Byte;
        RootDirEntries, FirstDataSector, HighestCluster : Word;
        SectorsPerFat : Byte;
        RootDirStartingSector : Word;
        DeviceDriverAddress : Pointer;
        Media2and3 : Byte; {media descriptor here in DOS 2.x and 3.x}
        Media4 : Byte;     {media descriptor here in DOS 4.x}
        NextDeviceParamBlock : Pointer;
      end;
    ParamBlockPtr = ^ParamBlock;
  var
    DriveNum : Byte;
    MediaDescriptor : Byte;
    Regs : Registers;
  begin
    {assume failure}
    GetDiskClass := InvalidDrive;

    {assume that this is not a SUBSTituted drive}
    SubstDriveChar := Drive;

    {convert drive letter to drive number}
    Drive := Upcase(Drive);
    case Drive of
      'A'..'Z' : DriveNum := Ord(Drive)-$40;
      else Exit;
    end;

    with Regs do begin
      {get pointer to media descriptor byte}
      AH := $1C;
      DL := DriveNum;
      MsDos(Regs);
      MediaDescriptor := Mem[DS:BX];

      {get pointer to drive parameter block}
      AH := $32;
      DL := DriveNum;
      MsDos(Regs);

      {drive invalid if AL = $FF}
      if (AL = $FF) then
        Exit;

      with ParamBlockPtr(Ptr(DS,BX))^ do begin
        {check for SUBSTituted drive}
        if (DriveNumber <> Pred(DriveNum)) then begin
          GetDiskClass := SubstDrive;
          SubstDriveChar := Char(Ord('A')+DriveNumber);
        end
        else if (FatCopies = 1) then
          {RAM disks have one copy of File Allocation Table}
          GetDiskClass := RamDisk
        else if (MediaDescriptor = $F8) then
          {MediaDescriptor of $F8 indicates hard disk}
          GetDiskClass := HardDisk
        else if (MediaDescriptor = $FD) and (SectorsPerFat <> 2) then
          {Bernoulli drives have more than 2 sectors per FAT}
          GetDiskClass := Bernoulli
        else if (MediaDescriptor >= $F9) then
          {media descriptors >= $F9 are for floppy disks}
          case HighestCluster of
             355 : GetDiskClass := Floppy360;
             714,
            1423 : GetDiskClass := Floppy720;
            2372 : GetDiskClass := Floppy12;
            else   GetDiskClass := OtherFloppy;
          end
        else if (MediaDescriptor = $F0) and (HighestCluster = 2848) then
          {it's a 1.44 meg floppy}
          GetDiskClass := Floppy144
        else
          {unable to classify disk/drive}
          GetDiskClass := UnknownDisk;
      end;
    end;
  end;

  function GetFileMode(FName : string; var Attr : Word) : Byte;
    {-Returns a file's attribute in Attr and the DOS error code as the function
      result.}
  var
    F : file;
  begin
    Assign(F, FName);
    {call routine in Turbo's DOS unit to get the attribute}
    GetFAttr(F, Attr);
    GetFileMode := DosError;
  end;

  procedure SetDta(DTAptr : Pointer);
    {-Set the DOS DTA to point to DTA}
  var
    Regs : Registers;
  begin
    with Regs do begin
      AH := $1A;
      DS := Seg(DTAptr^);
      DX := Ofs(DTAptr^);
      MsDos(Regs);
    end;
  end;

  procedure GetDta(var DTAptr : Pointer);
    {-Return the DOS DTA pointer}
  var
    Regs : Registers;
  begin
    with Regs do begin
      AH := $2F;
      MsDos(Regs);
      DTAptr := Ptr(ES, BX);
    end;
  end;

  function VerifyOn : Boolean;
    {-Returns True if disk write verification is on}
  begin
    Regs.AH := $54;          {Get verify state function}
    MsDos(Regs);
    VerifyOn := Boolean(Regs.AL);
  end;

  procedure SetVerify(On : Boolean);
    {-Turn disk write verification on/off}
  begin
    Regs.DL := 0;            {only MicroSoft knows for sure}
    Regs.AL := Byte(On);     {0 = off, 1 = on}
    Regs.AH := $2E;          {Set verify state function}
    MsDos(Regs);
  end;

  function ParsePath(var InputPath, SearchPath, LeadInPath : string) : Boolean;
    {-Takes a user entered path, trims blanks, and returns a valid global
      search path and a valid lead-in path.}
  var
    S : string[255];
    SLen : Byte absolute S;
    Attr : Word;

    function IsPath(S : string) : Boolean;
      {-Return True if S is empty or ends with ':' or '\'}
    var
      SLen : Byte absolute S;
    begin
      {check last character in S}
      case S[SLen] of
        ':', '\' : IsPath := True;
        else IsPath := (SLen = 0); {True if string is empty}
      end;
    end;

  begin
    {Assume success}
    ParsePath := True;

    {Get working copy of InputPath; convert to uppercase and trim blanks}
    S := StUpCase(Trim(InputPath));

    {if S is just a path name, add "*.*" to search path}
    if IsPath(S) then begin
      LeadInPath := S;
      SearchPath := S+'*.*';
    end
    else
      if SLen >= 77 then
        ParsePath := False
      else
        {test validity of pathname by calling routine to get file attribute}
        case GetFileMode(S, Attr) of

          0 : if (Attr and Directory {= $10} ) <> 0 then begin
                {Input path is valid directory name}
                SearchPath := S+'\*.*';
                LeadInPath := S+'\';
              end
              else begin
                {Input path is the name of a file}
                SearchPath := S;

                {trim end of string until only a path is left}
                while not IsPath(S) do
                  Dec(SLen);
                LeadInPath := S
              end;

          3 : begin
                {path not found}
                SearchPath := S;

                {trim end of string until only a path is left}
                while not IsPath(S) do
                  Dec(SLen);

                if (S[SLen] <> ':') or (SLen = 2) then
                  LeadInPath := S
                else
                  ParsePath := False;
              end;
        else
          ParsePath := False;
        end;
  end;

  function PrintInstalled : Boolean;
    {-Returns True if PRINT.COM is installed}
  begin
    {INT $2F functions available only in DOS 3}
    if DOSVersion >= $300 then
      with Regs do begin
        AX := $0100;         {get PRINT installed status}
        Intr($2F, Regs);     {print spool control interrupt}
        PrintInstalled := (AL = $FF); {DOS returns $FF in AL if PRINT installed}
      end
    else
      PrintInstalled := False;
  end;

  function SubmitPrintFile(FileName : string) : Byte;
    {-This procedure submits a file to the PC DOS 3.0 or greater concurrent
      print utility.}
  type
    AsciiZ = array[1..65] of Char;
    SubmitPacket = record
                     Level : Byte;
                     FilenamePtr : ^AsciiZ;
                   end;
  var
    SubPack : SubmitPacket;
    S : string;
    SLen : Byte absolute S;
  begin
    S := Trim(FileName);
    if SLen <> 0 then
      with SubPack, Regs do begin
        Level := 0;          {set level code}
        if SLen > 64 then
          SLen := 64;        {truncate filenames longer than 64 characters}
        S[Succ(SLen)] := #0; {add null to end of string}
        FilenamePtr := @S[1]; {point to first character in S}
        DS := Seg(SubPack);  {DS:DX points to the packet}
        DX := Ofs(SubPack);
        AX := $0101;         {submit file to be printed}
        Intr($2F, Regs);     {print spool control interrupt}
        if Odd(Flags) then   {check carry flag}
          SubmitPrintFile := AL {carry set, return code in AL}
        else
          SubmitPrintFile := 0;
      end
    else
      SubmitPrintFile := 2;  {return the code for a file not found error}
  end;

  procedure CancelPrintFile(FileMask : string);
    {-Cancels the files matched by the file mask passed in FileMask.}
  var
    Len : Byte absolute FileMask;
  begin
    if Len > 64 then
      Len := 64;             {truncate filenames longer than 64 characters}
    with Regs do begin
      FileMask[Succ(Len)] := #0; {make FileMask an ASCIIZ string}
      DS := Seg(FileMask);   {DS:DX points to the ASCIIZ string}
      DX := Ofs(FileMask[1]);
      AX := $0102;           {cancel print file}
      Intr($2F, Regs);       {print spool control interrupt}
    end;
  end;

  procedure CancelAllPrintFiles;
    {-Cancels all files in the print queue}
  begin
    Regs.AX := $0103;        {cancel all files function}
    Intr($2F, Regs);         {print spool control interrupt}
  end;

  function GetPrintStatus(var QPtr : Pointer) : Byte;
    {-Halts printing, returns current error status, puts pointer to the filename
      queue in the QPtr variable. Filenames in the queue are 64-byte ASCIIZ
      strings. The end of the queue is marked by a name starting with a null.}
  begin
    with Regs do begin
      AX := $0104;           {access print queue function}
      Intr($2F, Regs);       {print spool control interrupt}
      {check carry flag}
      if Odd(Flags) then begin
        {carry set, return code in AL}
        QPtr := nil;
        GetPrintStatus := AL;
      end
      else begin
        {DS:SI points to the queue}
        QPtr := Ptr(DS, SI);
        GetPrintStatus := 0;
      end;
    end;
  end;

  procedure EndPrintStatus;
    {-Releases the spooler from the GetPrintStatus procedure.}
  begin
    Regs.AX := $0105;        {unfreeze queue function}
    Intr($2F, Regs);         {print spool control interrupt}
  end;

  function GetEnvironmentString(SearchString : string) : string;
    {-Return a string from the environment}
  type
    Env = array[0..32767] of Char;
  var
    EPtr : ^Env;
    EStr : string;
    EStrLen : Byte absolute EStr;
    Done : Boolean;
    SearchLen : Byte absolute SearchString;
    I : Word;
  begin
    GetEnvironmentString := '';
    if SearchString = '' then
      Exit;

    {force upper case}
    for I := 1 to SearchLen do
      SearchString[I] := Upcase(SearchString[I]);

    EPtr := Ptr(MemW[PrefixSeg:$2C], 0);
    I := 0;
    if SearchString[SearchLen] <> '=' then
      SearchString := SearchString+'=';
    Done := False;
    EStrLen := 0;
    repeat
      if EPtr^[I] = #0 then begin
        if EPtr^[Succ(I)] = #0 then begin
          Done := True;
          if SearchString = '==' then begin
            EStrLen := 0;
            Inc(I, 4);
            while EPtr^[I] <> #0 do begin
              Inc(EStrLen);
              EStr[EStrLen] := EPtr^[I];
              Inc(I);
            end;
            GetEnvironmentString := EStr;
          end;
        end;
        if Copy(EStr, 1, SearchLen) = SearchString then begin
          GetEnvironmentString := Copy(EStr, Succ(SearchLen), 255);
          Done := True;
        end;
        EStrLen := 0;
      end
      else begin
        Inc(EStrLen);
        EStr[EStrLen] := EPtr^[I];
      end;
      Inc(I);
    until Done;
  end;

  {$IFNDEF Ver60}
  function EndOfHeap : Pointer;
    {-Returns a pointer to the end of the free list}
  var
    FreeSegOfs : SegOfs absolute FreePtr;
  begin
    if FreeSegOfs.O = 0 then
      {the free list is empty, add $1000 to the segment}
      EndOfHeap := Ptr(FreeSegOfs.S+$1000, 0)
    else
      EndOfHeap := Ptr(FreeSegOfs.S+(FreeSegOfs.O shr 4), 0);
  end;
  {$ENDIF}

  function PtrDiff(H, L : Pointer) : LongInt;
    {-Return the number of bytes between H^ and L^. H is the higher address}
  var
    High : SegOfs absolute H;
    Low : SegOfs absolute L;
  begin
    PtrDiff := (LongInt(High.S) shl 4+High.O)-(LongInt(Low.S) shl 4+Low.O);
  end;

  function SetBlock(var Paragraphs : Word) : Boolean;
    {-Change size of DOS memory block allocated to this program}
  begin
    with Regs do begin
      AH := $4A;
      ES := PrefixSeg;
      BX := Paragraphs;
      MsDos(Regs);
      Paragraphs := BX;
      SetBlock := not Odd(Flags);
    end;
  end;

{$IFNDEF Ver40}
  function UsingEmulator : Boolean;
    {-Return True if floating point emulator in use}
  type
    Array3 = array[1..3] of Char;
  const
    EmuSignature : Array3 = 'emu';
  var
    A3P : ^Array3;
  begin
    A3P := Ptr(SSeg, $E0);
    {using emulator if Test8087 is 0 and emulator's signature is found in SS}
    UsingEmulator := (Test8087 = 0) and (A3P^ = EmuSignature);
  end;
{$ENDIF}

  function ExecDos(Command : string; UseSecond : Boolean; UserRoutine : Pointer) : Integer;
    {-Execute any DOS command. Call with Command = '' for a new shell. If
      UseSecond is false, Command must be the full pathname of a program to be
      executed. UserRoutine is the address of a routine to display status,
      save/restore the screen, etc., or a nil pointer.}

    procedure CallUserRoutine(ActionCode : ActionCodeType; Param : Word);
      {-Call UserRoutine with an action code}
    inline(
      $FF/$5E/<UserRoutine); {call far dword ptr [bp+<UserRoutine]}

  label
    ExitPoint;
  var
    PathName,
    CommandTail : string[127];
    OurInt23,
    OurInt24,
    OldEndOfHeap,
    NewEndOfHeap,
    TopOfHeap : Pointer;
    BlankPos,
    Allocated,
    SizeOfFreeList,
    ParasToKeep,
    ParasWeHave,
    ParasForDos : Word;
    {$IFDEF Ver40}
    UsingEmulator : Boolean;
    {$ENDIF}
  begin
    {$IFNDEF Ver60}
    {Calculate number of bytes to save}
    TopOfHeap := Ptr(SegOfs(FreePtr).S+$1000, 0);
    SizeOfFreeList := PtrDiff(TopOfHeap, EndOfHeap);

    {If enough space available, use stack to store the free list}
    {$IFDEF Ver40}
    UsingEmulator := False;
    {$ENDIF}
    if (not UsingEmulator) and
       (LongInt(SizeOfFreeList)+StackSafetyMargin < LongInt(SPtr)) then begin
      NewEndOfHeap := Ptr(SSeg, 0);
      Allocated := 0;
    end
    else begin
      {Check for sufficient memory}
      if MaxAvail < LongInt(SizeOfFreeList) then begin
        {Insufficient memory to store free list}
        ExecDos := -1;
        Exit;
      end;

      {Allocate memory for a copy of free list}
      Allocated := SizeOfFreeList;
      if Allocated > 0 then
        GetMem(NewEndOfHeap, Allocated);

      {Recalculate the size of the free list}
      SizeOfFreeList := Word(PtrDiff(TopOfHeap, EndOfHeap));
    end;

    {Save the current pointer to the end of the free list}
    OldEndOfHeap := EndOfHeap;
    {$ELSE}
    TopOfHeap:=HeapEnd;
    {$ENDIF}

    {Current DOS memory allocation read from memory control block}
    ParasWeHave := MemW[Pred(PrefixSeg):3];

    {Calculate amount of memory to give up}
    ParasForDos := Pred(PtrDiff(TopOfHeap, HeapPtr) shr 4);

    {Calculate amount of memory to keep while in shell}
    ParasToKeep := ParasWeHave-ParasForDos;

    {See if enough memory to run DOS}
    if (ParasForDos > 0) and (ParasForDos < (MinSpaceForDos shr 4)) then begin
      ExecDos := -4;
      goto ExitPoint;
    end;

    {Deallocate memory for DOS}
    if not SetBlock(ParasToKeep) then begin
      ExecDos := -2;
      goto ExitPoint;
    end;

    {get parameters for Execute}
    if Command = '' then
      UseSecond := True;
    if not UseSecond {command processor} then begin
      {Command is assumed to be a full pathname for a program}
      BlankPos := Pos(' ', Command);
      if BlankPos = 0 then begin
        PathName := Command;
        CommandTail := '';
      end
      else begin
        CommandTail := Copy(Command, BlankPos, Length(Command));
        PathName := Copy(Command, 1, Pred(BlankPos));
      end;
    end
    else begin
      {Pathname is the full pathname for COMMAND.COM}
      PathName := GetEnvironmentString('COMSPEC');

      {if Command is empty, we're doing a shell}
      if Command = '' then
        CommandTail := ''
      else
        {we're asking COMMAND.COM to execute the command}
        CommandTail := '/C '+Command;
    end;

    {Let user routine store and clear the physical screen}
    if UserRoutine <> nil then
      CallUserRoutine(ExecSaveScreen, 0);

    {let user routine show status info if entering DOS shell}
    if (Command = '') and (UserRoutine <> nil) then
      {Pass user routine the approximate memory available in KB}
      CallUserRoutine(ExecShowMemory, (ParasForDos-240) shr 6);

    {$IFNDEF Ver60}
    {Copy the free list to a safe location}
    Move(OldEndOfHeap^, NewEndOfHeap^, SizeOfFreeList);
    {$ENDIF}

    {$IFDEF Ver40}
      {save our INT 23 and 24 vectors and put old ones back}
      GetIntVec($23, OurInt23);
      GetIntVec($24, OurInt24);
      SetIntVec($23, SaveInt23);
      SetIntVec($24, SaveInt24);
      {$ELSE}
      SwapVectors;
    {$ENDIF}

    {Call Turbo's EXEC function}
    Exec(PathName, CommandTail);

    {$IFDEF Ver40}
      {restore our INT 23 and 24 vectors}
      SetIntVec($23, OurInt23);
      SetIntVec($24, OurInt24);
    {$ELSE}
      SwapVectors;
    {$ENDIF}

    {Reallocate memory from DOS}
    if not SetBlock(ParasWeHave) then begin
      ExecDos := -3;
      goto ExitPoint;
    end;

    {$IFNDEF Ver60}
    {Put free list back where it was}
    Move(NewEndOfHeap^, OldEndOfHeap^, SizeOfFreeList);
    {$ENDIF}

    {if not in shell , let user routine allow time to see result}
    if ((Command <> '') or (DosError <> 0)) and (UserRoutine <> nil) then
      CallUserRoutine(ExecPauseAfterRun, 0);

    {give user routine a chance to restore the screen}
    if UserRoutine <> nil then
      CallUserRoutine(ExecRestoreScreen, 0);

    {If we get to here, our function result is in DosError}
    ExecDos := DosError;

ExitPoint:
    {$IFNDEF Ver60}
    {Deallocate any dynamic memory used}
    if Allocated <> 0 then
      FreeMem(NewEndOfHeap, Allocated);
    {$ENDIF}
  end;

  function UserDefinedIoResult : Word;
    {-Calls user-defined I/O checking routine}
  inline(
    $FF/$1E/>IoResultPtr);   {CALL DWORD PTR [IoResultPtr]}

  function IoResult : Word;
    {-Returns I/O result if IoResultPtr is nil, else the code returned by
      the user-specified I/O error checking routine.}
  begin
    if IoResultPtr = nil then
      IoResult := System.IoResult
    else
      IoResult := UserDefinedIoResult;
  end;

  function DosBlockWrite(H : Word; var Src; N : Word) : Word;
  {-Calls DOS's BlockWrite routine. Returns 0 if successful, else the DOS
    error code.}
  begin
    with Regs do begin
      AH := $40;             {write to file}
      BX := H;               {file handle}
      CX := N;               {Number of bytes to write}
      DS := Seg(Src);        {DS:DX points to buffer}
      DX := Ofs(Src);
      MsDos(Regs);           {returns bytes written in AX}

      {check carry flag, also the number of bytes written}
      if Odd(Flags) or (AX <> N) then
        DosBlockWrite := AX
      else
        DosBlockWrite := 0;
    end;
  end;

  function TextSeek(var F : Text; Target : LongInt) : Boolean;
    {-Do a Seek for a text file opened for input. Returns False in case of I/O
      error.}
  var
    T : LongRec absolute Target;
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

  function TextFlush(var F : Text) : Boolean;
    {-Flush the buffer(s) for a text file. Returns False in case of I/O error.}
  var
    Position : LongInt;
    P : LongRec absolute Position;
    Code : Word;
  begin
    with Regs, FIB(F) do begin
      {assume failure}
      TextFlush := False;

      {check for open file}
      if Mode = FMClosed then
        Exit;

      {see if file is opened for reading or writing}
      if Mode = FMInput then begin
        {get current position of the logical file pointer}
        Position := TextPos(F);

        {exit in case of I/O error}
        if Position = -1 then
          Exit;

        {set the new position of the physical file pointer}
        AX := $4200;         {move file pointer function}
        BX := Handle;        {file handle}
        CX := P.HighWord;    {CX has high word of offset}
        DX := P.LowWord;     {DX has low word}
        MsDos(Regs);         {call DOS}

        {check for I/O error}
        if Odd(Flags) then
          Exit;
      end
      else begin
        {write the current contents of the buffer, if any}
        if BufPos <> 0 then begin
          Code := DosBlockWrite(Handle, BufPtr^, BufPos);
          if Code <> 0 then
            Exit;
        end;

        {dupe the file handle}
        AH := $45;
        BX := Handle;
        MsDos(Regs);
        if Odd(Flags) then
          Exit;

        {close the duped file}
        BX := AX;
        AH := $3E;
        MsDos(Regs);
        if Odd(Flags) then
          Exit;
      end;

      {tell Turbo its buffer is empty}
      BufEnd := 0;
      BufPos := 0;
    end;

    {if we get to here we succeeded}
    TextFlush := True;
  end;

  function OpenStdDev(var F : Text; StdHandle : Word) : Boolean;
    {-Assign the text file to the specified standard DOS device}
  begin
    OpenStdDev := False;
    case StdHandle of
      StdInHandle,
      StdOutHandle,
      StdErrHandle,
      StdPrnHandle :
        begin
          {Initialize the file variable}
          Assign(F, '');
          Rewrite(F);
          if IoResult = 0 then begin
            FIB(F).Handle := StdHandle;
            if StdHandle = StdErrHandle then
              FIB(F).BufSize := 1;
            OpenStdDev := True;
          end;
        end;
    end;
  end;

  function HandleIsConsole(Handle : Word) : Boolean;
    {-Return true if handle is the console device (input or output)}
  begin
    with Regs do begin
      AX := $4400;
      BX := Handle;
      MsDos(Regs);
      if (DX and $80) = 0 then
        HandleIsConsole := False
      else
        HandleIsConsole := (DX and $02 <> 0) or (DX and $01 <> 0);
    end;
  end;

  procedure SetRawMode(var F : Text; On : Boolean);
    {-Set "raw" mode on or off for the specified text file (must be a device)}
  var
    FH : Word absolute F; {F's file handle}
    FMod : Word;
  begin
    {check for open file}
    FMod := FIB(F).Mode;
    if (FMod < FMInput) or (FMod > fmInOut) then begin
      {Turbo's file not found error code}
      DosError := 103;
      Exit;
    end;

    DosError := 0;
    with Regs do begin
      AX := $4400;           {Get device information}
      BX := FH;
      MsDos(Regs);           {returns device info in DX}

      if not Odd(Flags) then begin
        {check bit 7 for device flag}
        if DL and $80 = 0 then
          Exit;

        {clear unwanted bits}
        DX := DX and $00AF;

        {select raw/cooked mode}
        if On then
          {set bit 5 of DX}
          DL := DL or $20
        else
          {clear bit 5 of DX}
          DL := DL and $DF;

        AX := $4401;           {Set device information}
        BX := FH;              {BX has file handle}
        MsDos(Regs);
      end;

      if Odd(Flags) then
        DosError := AX
      else
        DosError := 0;
    end;
  end;

  function FileHandlesOpen(CountDevices : Boolean) : Byte;
    {-Return the number of open files owned by a program}
  type
    HandleTable = array[0..19] of Byte;
  var
    HandlesPtr : ^HandleTable;
    I, N : Byte;
  begin
    {file handles table starts at PrefixSeg:$18}
    HandlesPtr := Ptr(PrefixSeg, $18);
    N := 0;
    for I := 0 to 19 do
      if HandlesPtr^[I] <> $FF then
        case I of
          0..4 : Inc(N, Ord(CountDevices));
        else Inc(N);
        end;
    FileHandlesOpen := N;
  end;

  function FileHandlesLeft : Byte;
    {-Return the number of available file handles}
  const
    MaxFiles = 20;
  var
    Files : array[1..MaxFiles] of file;
    I, N : Byte;
    OK : Boolean;
  begin
    N := 0;
    repeat
      {try opening the N+1'th file}
      Assign(Files[N+1], 'NUL');
      Reset(Files[N+1]);
      OK := IoResult = 0;
      Inc(N, Ord(OK));
    until (N = MaxFiles) or not OK;

    for I := 1 to N do begin
      {close each of the files that we opened}
      Close(Files[I]);
      OK := (IoResult = 0);
    end;

    FileHandlesLeft := N;
  end;

  function ExistFile(FName : string) : Boolean;
    {-Return true if file is found}
  var
    Regs : Registers;
    FLen : Byte absolute FName;
  begin
    {check for empty string}
    if Length(FName) = 0 then
      ExistFile := False
    else with Regs do begin
      Inc(FLen);
      FName[FLen] := #0;
      AX := $4300;           {get file attribute}
      DS := Seg(FName);
      DX := Ofs(FName[1]);
      MsDos(Regs);
      ExistFile := (not Odd(Flags)) and (IoResult = 0);
    end;
  end;

  function ExistOnPath(FName : string; var FullName : string) : Boolean;
   {-Return true if fname is found in
      a) current directory (returns just name, no path)
      b) program's directory (DOS 3.X only)
      c) any DOS path directory
    and return path name to file}
  type
    Environment = array[0..32766] of Char;
  const
    Null : Char = #0;
    DoubleNull : string[2] = #0#0;
    PathStr : string[5] = 'PATH=';
  var
    E : ^Environment;
    Elast : Word;
    Epos : Word;
    Fpos : Word;
    Found : Boolean;
  begin
    {Assume success}
    ExistOnPath := True;

    {Check current directory -- If you need the complete path name,
     call TPString.FullPathname after calling ExistOnPath}
    FullName := FName;
    if ExistFile(FullName) then
      Exit;

    {Get a pointer to the DOS environment}
    E := Ptr(MemW[PrefixSeg:$2C], 0);

    {Find the end of the environment}
    Elast := Search(E^[0], 32767, DoubleNull[1], 2);
    if Elast = $FFFF then begin
      {Something is wrong}
      ExistOnPath := False;
      Exit;
    end;

    {If DOS 3 or higher, check the directory where the program was found}
    if DOSVersion >= $300 then begin
      {Skip over the doublenull and a word count}
      Epos := Elast+4;
      {Find the next null}
      Fpos := Search(E^[Epos], 100, Null, 1);
      if Fpos <> $FFFF then begin
        {Move from the environment into the return string}
        FullName[0] := Chr(Fpos);
        Move(E^[Epos], FullName[1], Fpos);
        FullName := AddBackSlash(JustPathname(FullName))+FName;
        if ExistFile(FullName) then
          Exit;
      end;
    end;

    {Check the path}
    Found := False;
    Epos := 0;
    repeat
      Fpos := Search(E^[Epos], Elast-Epos, PathStr[1], Length(PathStr));
      if Fpos <> $FFFF then begin
        {PATH= was found}
        Inc(Epos, Fpos);
        Found := (Epos = 0) or (E^[Pred(Epos)] = Null);
        if not(Found) then
          {Something like DPATH= was found}
          Inc(Epos);
      end;
    until (Fpos = $FFFF) or Found;

    if Found then begin
      {True PATH= was found, skip over the PATH= part}
      Inc(Epos, Length(PathStr));

      {Scan each item in the path}
      repeat

        {Find the termination of the current path entry}
        Fpos := Epos;
        while (E^[Fpos] <> ';') and (E^[Fpos] <> Null) do
          Inc(Fpos);

        if Fpos > Epos then begin
          {A path entry found}
          FullName[0] := Char(Fpos-Epos);
          Move(E^[Epos], FullName[1], Fpos-Epos);
          FullName := AddBackSlash(FullName)+FName;
          if ExistFile(FullName) then
            Exit;
        end;

        {Prepare to look at next item}
        Epos := Succ(Fpos);

      until E^[Fpos] = Null;
    end;

    {Not found, even on the path}
    ExistOnPath := False;
    FullName := FName;
  end;

  function TimeMs : LongInt;
    {-Return time of day in milliseconds since midnight}
  begin
    with Regs do begin
      AH := $2C;
      MsDos(Regs);
      TimeMs := 1000*(LongInt(DH)+60*(LongInt(CL)+60*LongInt(CH)))+10*LongInt(DL);
    end;
  end;

begin
  {No user-defined ioresult routine yet}
  IoResultPtr := nil;
end.
