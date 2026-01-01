{$I-,R-,S-,V-}

unit Int24;

{ A unit for trapping DOS critical errors (INT 24) for retries

  Version 1.01 - 01/02/1987 - First general release
                 20/12/1991 - Some modifications made by Bogush A.V.

  Scott Bussinger
  Professional Practice Systems
  110 South 131st Street
  Tacoma, WA  98444
  (206)531-8944
  Compuserve 72247,2671 }

{Activate the following define to use the Turbo Professional units}
{$DEFINE TPROF}

interface

uses Dos,

{$IFDEF TPROF}                                   { You must DEFINE TPROF to use the Turbo Professional routines }
     TPCrt;
{$ELSE}
     Crt,FastWr,Cursors;
{$ENDIF}

var CriticalProc: pointer;                       { Address of special critical error handler }

implementation

const Attr = $4f;

var ExitSave: pointer;
    OldInt24: pointer;
    CurrentCriticalProc: pointer;

procedure CallUserHandler(var Retry: boolean;ErrorCode: word;var DeviceName: string);
  inline($FF/$1E/>CurrentCriticalProc);          { CALL DWORD [>CurrentCriticalProc] }

procedure JmpOldISR(OldISR: pointer);
  inline($5B/                   {  pop bx             ;BX = Ofs(OldIsr)}
         $58/                   {  pop ax             ;AX = Seg(OldIsr)}
         $87/$5E/$0E/           {  xchg bx,[bp+14]    ;Switch old BX and Ofs(OldIsr)}
         $87/$46/$10/           {  xchg ax,[bp+16]    ;Switch old AX and Seg(OldIsr)}
         $89/$EC/               {  mov sp,bp          ;Restore SP}
         $5D/                   {  pop bp             ;Restore BP}
         $07/                   {  pop es             ;Restore ES}
         $1F/                   {  pop ds             ;Restore DS}
         $5F/                   {  pop di             ;Restore DI}
         $5E/                   {  pop si             ;Restore SI}
         $5A/                   {  pop dx             ;Restore DX}
         $59/                   {  pop cx             ;Restore CX}
         $CB);                  {  retf               ;Chain to OldIsr, leaving CS and IP params on the stack}

{$F+}
procedure Int24Handler(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP: integer); interrupt;
  { Interrupt handler for the critical error interrupt }
  type DeviceHeader = record
         Next: pointer;
         Attributes: word;
         StrategyAddr: word;
         InterruptAddr: word;
         Name: array[1..8] of char
         end;
  var DeviceName: string[8];
      Retry: boolean;
      SaveCriticalProc: pointer;
  begin
  if (AX and $8000) = 0
   then
    DeviceName := chr(lo(AX)+ord('A')) + ':'     { Pass the drive name to user error handler }
   else
    with DeviceHeader(ptr(BP,SI)^) do
      if (Attributes and $8000) = 0
       then
        DeviceName := ''                         { Bad memory image of FAT - no device name available }
       else
        DeviceName := copy(Name,1,pred(pos(' ',Name+' '))); { Get name of character device }

  Retry := false;
  SaveCriticalProc := CriticalProc;
  while CriticalProc <> nil do                   { Allow for a chain of user critical error handlers }
    begin
    CurrentCriticalProc := CriticalProc;
    CriticalProc := nil;
    CallUserHandler(Retry,lo(DI),DeviceName)
    end;
  CriticalProc := SaveCriticalProc;
  if Retry
   then
    AX := 1
   else
    JmpOldISR(OldInt24)
  end;

procedure DefaultCriticalHandler(var Retry: boolean;ErrorCode: word;var DeviceName: string);
  { Default critical error handler for retrying on errors }
  const ErrorDesc: array[0..12] of string[18] = ('', { List of generic descriptions of critical errors }
                                                 'Unknown unit',
                                                 '',
                                                 'Unknown command',
                                                 'Data error (CRC)',
                                                 'Bad request length',
                                                 'Seek error',
                                                 'Unknown media type',
                                                 'Sector not found',
                                                 '',
                                                 'Write fault',
                                                 'Read fault',
                                                 'General failure');
        ScreenSize = 2000;
  var CurrentAttr: byte;
      CurrentLine: integer;
      I: integer;
      Key: char;
      SaveCheckBreak: boolean;
{$IFDEF TPROF}
      SaveCursorLoc: word;
      SaveCursorSize: word;
{$ELSE}
      SaveCursorSize: CursorSize;
      SaveX: byte;
      SaveY: byte;
{$ENDIF}
      SaveScreen: array[1..ScreenSize] of word;  { A place to save a copy of the screen temporarily }
      SaveTextAttr: byte;

  procedure OutLine(Line: string);
    { Output a line to the screen }
    begin
    if odd(length(Line)) then
      Line := ' ' + Line;
    while length(Line) < 44 do
      Line := ' ' + Line + ' ';
    FastWrite('║'+Line+'║',CurrentLine,18,Attr);
    inc(CurrentLine)
    end;

  begin
  if not Retry then                              { See if another handler has already decided to retry the error }
    begin                                        { Save screen and put up a warning message }
{$IFDEF TPROF}
    GetCursorState(SaveCursorLoc,SaveCursorSize); { Save current display }
    MoveScreen(mem[VideoSegment:0],SaveScreen,ScreenSize);
{$ELSE}
    GetCursor(SaveCursorSize);
    GetCursorLoc(SaveX,SaveY);
    MoveFromScreen(mem[BaseOfScreen:0],SaveScreen,ScreenSize);
{$ENDIF}
    SaveTextAttr := TextAttr;
    SaveCheckBreak := CheckBreak;
    CheckBreak := false;
    TextBackground(Black);
    {ClrScr;}                                   { Display the error message }
    CurrentLine := 10;
    FastWrite('╔════════════════════════════════════════════╗',9,18,Attr);
    OutLine('');
    case ErrorCode of                            { Check for obvious problems }
      0: begin
         OutLine('You cannot write to the disk in drive '+DeviceName);
         OutLine('because it has a write protect tab');
         OutLine('attached.  Remove the tab to continue.')
         end;
      2: if DeviceName[2] = ':'                  { Problem with a drive or device }
          then
           begin
           OutLine('Drive '+DeviceName+' is not ready.');
           OutLine('Check the disk and close the door.')
           end
          else
           OutLine('Printer is not ready.  Check device '+DeviceName);
      9: OutLine('Printer ('+DeviceName+') is out of paper.');
      else begin                                 { Handle bizarre errors more generically }
           if DeviceName[2] = ':'
            then
             OutLine('Error with disk drive '+DeviceName)
            else
             OutLine('Check the printer. ('+DeviceName+')');
           OutLine('');
           OutLine('Problem is '+ErrorDesc[ErrorCode]);
           end
      end;
    OutLine('');
    OutLine('Hit ESC or CTRL BREAK to abort operation');
    OutLine('or the SPACE BAR to try again.');
    FastWrite('╚════════════════════════════════════════════╝',CurrentLine,18,Attr);

    for I := 1 to 3 do                           { Whistle at user }
      begin
      sound(2000);
      delay(50)
      end;
    NoSound;
    while KeyPressed do                          { Clear keyboard buffer }
      Key := ReadKey;
    Key := ReadKey;
{$IFDEF TPROF}
    MoveScreen(SaveScreen,mem[VideoSegment:0],ScreenSize); { Restore display }
    RestoreCursorState(SaveCursorLoc,SaveCursorSize);
{$ELSE}
    MoveToScreen(SaveScreen,mem[BaseOfScreen:0],ScreenSize); { Restore display }
    SetCursor(SaveCursorSize);
    SetCursorLoc(SaveX,SaveY);
{$ENDIF}
    TextAttr := SaveTextAttr;
    CheckBreak := SaveCheckBreak;
    case upcase(Key) of                          { Either retry operation or return an error depending on key hit }
      ^C,^[,'A','Q': ;
      else Retry := true                         { Since CriticalProc not restored, no more handlers will be called }
      end;
    while KeyPressed do                          { Clear keyboard buffer }
      Key := ReadKey
    end
  end;

procedure ExitHandler;
  { Restore the original Int24 handler }
  begin
  ExitProc := ExitSave;
  SetIntVec($24,OldInt24)
  end;
{$F-}

begin
ExitSave := ExitProc;
ExitSave := @ExitHandler;
CriticalProc := @DefaultCriticalHandler;
GetIntVec($24,OldInt24);
SetIntVec($24,@Int24Handler)
end.
