{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y+}
{$M $8000,$45000,$45000}
{.$DEFINE USETABLE}

program INTL2NG; {version 1.1}

{ Interupt List files (v37+) converter to Norton Guide source
  (C)Copyright BZSoft Inc, 1993,94 by Boris Zulin.
     (0572)400-875, Kharkov, Ukraine
  (C)Portion copyright GalaSoft United Group International, 1994.

  Return: (in ERRORLEVEL)
  0 - Successful
  1 - File I/O error
  2 - Files not found
  3 - Help
  4 - Ctrl Break

  Compile: TPC INTL2NG   or   BPC INTL2NG

  Interrupt List   is  Copyright (C) 1989,1990,1991,1992,1993 Ralf Brown
  Norton Guides  1.04, Copyright (C) 1987 by Peter Norton Computing
  Borland Pascal 7.01, Copyright (C) 1983-93 by Borland International, Inc.}

uses Crt,Dos;

type
   RangeOfFlafs = 'A'..'z';
   Categories = set of RangeOfFlafs;
const
   BufSize  = $4000;
   MaxBig   = 100;
   TabSize  = 8;
   NGLimit  = 12000;   { bytes }
   NGShortLimit = 100; { lines, with reserve 30% }
   BaseName : string [8] = 'INTERRUP';
   TmpFile1 : string [8] = 'FILE1.TMP';
   TmpFile2 : string [8] = 'FILE2.TMP';
   CN       : string [4] = 'NGC ';
   Bright   : string [2] = '^B';
   Underline: string [2] = '^U';
   _Short   : string [7] = '!Short:';
   _File    : string [7] = '!File: ';
   _Video   : string [20]= '       ^BVideo^B    ';
   _System  : string [30]= '       ^BSystem^B   ';
   _Tools   : string [20]= '       ^BTools^B    ';
   _Keyboard: string [20]= '       ^BKeyboard   ';
   _DOS     : string [20]= '       ^BDOS^B      ';
   _Mouse   : string [20]= '       ^BMouse^B    ';
   _Multi   : string [26]= '       ^BDOS Multiplexor^B ';
   Line     : string [8] = '--------';
   PadChar  : char = ' ';
   LineChar : char = '-';
   Header1  : string[78] =
   ' Converter INTERRUPT LIST to NG-listing format v1.1'+
   ' (C)BZSoft, Inc., 1993,94';
   Header2  : string[78] =
   ' This FREEWARE program writed by Boris Zulin, Kharkov, Ukraine.';
   Y     : byte = 0;
   BN    : word = 0;
   BC    : word = 1;
   NI    : LongInt = 0;
   CI    : LongInt = 0;
   _NumI : LongInt = 0;
   _NumF : word    = 3;
   FO    : boolean = false;
   BreakPressed : boolean = false;
   Path1 : string[80] = '';
   Path2 : string[80] = '';
   CommentsNeed  : boolean = true;
   PortsListNeed : boolean = true;
   MemoryNeed    : boolean = true;
   CMOSNeed      : boolean = true;
   GlossaryNeed  : boolean = true;
   VirusNeed     : boolean = true;
   Message       : boolean = true;
   EndOfList     : boolean = false;
   ConfigLoaded  : boolean = false;
   BaseCategories : Categories =
     ['B','b','C','D','d','f','H','h','I','J','K',
      'l','M','m','N','O','p','Q','S','T','V','W','X'];
   VideoCategories : Categories =
     ['B','b','C','H','h','I','J','S','V','X'];
   KeyboardCategories : Categories = ['B','b','C','H'];
   DosCategories : Categories = ['B','C','D','H'];
   MultiCategories : Categories = ['D'];
   MouseCategories : Categories = ['M'];

   ParseStr : set of char =
     [' ',#9,',',';','.','!','?','(',')',':'];
{$IFDEF USETABLE}   {Russian 866 code table}
   UpCaseTable : array[0..255] of byte =
   (  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
     16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
     32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
     48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
     64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
     80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
     96, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
     80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90,123,124,125,126,127,
    128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,
    144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,
    128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,
    176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,
    192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,
    208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,
    144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,
    240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255
   );
   LoCaseTable : array[0..255] of byte =
   (  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
     16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
     32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
     48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
     64, 97, 98, 99,100,101,102,103,104,105,106,107,108,109,110,111,
    112,113,114,115,116,117,118,119,120,121,122, 91, 92, 93, 94, 95,
     96, 97, 98, 99,100,101,102,103,104,105,106,107,108,109,110,111,
    112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,
    160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,
    224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,
    160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,
    176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,
    192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,
    208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,
    224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,
    240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255
   );
{$ENDIF}
type
   TBuf = array[1..BufSize] of byte;
   TBufPtr = ^TBuf;
   TimeRec = record
     H,M,S,S100 : word;
   end;
   CategArray = array[0..255] of Categories ;
   NameArray  = array[0..255] of string[30];
var
   CategPtr : ^CategArray;
   NamePtr  : ^NameArray;
   UseCateg : array[0..255] of boolean;
   Tm1,Tm2 : TimeRec;
   VersionIL: string[4];
   tmp1,        {Temporary}
   tmp2,
   t1,          {Source File}
   t2,          {Target File}
   t3,
   t4,
   tv,
   ts,
   tl : text;
   Nul,
   S1,
   Name1, Name2,
   Ext1  : string;
   NumF  : byte;        {Number of INTERRUP.? files}
   i     : byte;        {index variable}
   N     : word;
   Z     : LongInt;     {}
   SZ    : LongInt;
   Buf1,Buf2,Buf3,Buf4,Buf5,
   Buf   : TBufPtr;       {buffer}
   SaveBreakPtr : pointer;

   IL    : array[0..255,1..3] of word; {number of items}
   BI    : array[1..MaxBig] of LongInt;

procedure Copyright; assembler;
asm
        JMP     @QUIT
        DB      'INTL2NG 1.1 (C) Copyright BZSoft Inc., 1993,94.'
@QUIT:
end;

function HeapFunc (Size: Word): Integer; far;
begin
  HeapFunc := 1;  { Return NIL, if out of memory }
end;

{$F+}
procedure BreakFunc; interrupt;
begin
  BreakPressed := true;
end;

procedure MyExit;
begin
  ExitProc := nil;
  if BreakPressed Then begin
    ExitCode := 4;
    if Message Then WriteLn(^M^J' * User Break *'^M^J);
    SetIntVec($1B,SaveBreakPtr);
  end;
  if TextRec(t1).Mode <> fmClosed Then Close(t1);
  if TextRec(t2).Mode <> fmClosed Then Close(t2);
  if TextRec(t3).Mode <> fmClosed Then Close(t3);
  if TextRec(t4).Mode <> fmClosed Then Close(t4);
  if TextRec(tl).Mode <> fmClosed Then Close(tl);
  if TextRec(tv).Mode <> fmClosed Then Close(tv);
  if TextRec(ts).Mode <> fmClosed Then Close(ts);
  if TextRec(tmp1).Mode <> fmClosed Then Close(tmp1);
  if TextRec(tmp2).Mode <> fmClosed Then Close(tmp2);
end;
{F-}

procedure Error;
begin
  if Message Then begin
    if Y>0 Then GotoXY(1,Y);
    WriteLn(' * File access error, terminated. *');
  end;
  Halt(1);
end;

function TrimLead(S : string) : string; assembler;
asm
        PUSH    DS
        LDS     SI, S
        LES     DI, @Result
        MOV     CL, [SI]
        XOR     CH, CH
        OR      CX, CX
        JZ      @STOP
        INC     SI
@LOOP:
        CMP     BYTE PTR [SI], 9
        JE      @CONT
        CMP     BYTE PTR [SI], 32
        JE      @CONT
        JMP     @STOP
@CONT:
        INC     CH
        INC     SI
        CMP     CL, CH
        JE      @STOP
        JMP     @LOOP
@STOP:
        SUB     CL, CH
        XOR     CH, CH
        MOV     ES:[DI], CL
        OR      CL, CL
        JZ      @QUIT
        INC     DI
        CLD
    REP MOVSB
@QUIT:
        POP     DS
end;

function TrimTrail(S : string) : string; assembler;
asm
        PUSH    DS
        LDS     SI, S
        MOV     CL, [SI]
        XOR     CH, CH
        OR      CL, CL
        JZ      @CONT
        ADD     SI, CX
@LOOP:
        CMP     BYTE PTR [SI], 32
        JE      @DECR
        CMP     BYTE PTR [SI], 9
        JNE     @CONT
@DECR:
        DEC     SI
        LOOP    @LOOP
@CONT:
        LES     DI, @Result
        MOV     ES:[DI], CL
        OR      CL, CL
        JZ      @QUIT
        LDS     SI, S
        INC     SI
        INC     DI
        CLD
    REP MOVSB
@QUIT:
        POP     DS
end;

function Trim(S:string) : string;
begin
  Trim:=TrimLead(TrimTrail(S));
end;

function StrUpCase(S : string) : string; assembler;
asm
        PUSH    DS
        LDS     SI, S
        LES     DI, @Result
        MOV     CL, [SI]
        XOR     CH, CH
        INC     SI
        MOV     ES:[DI], CL
        INC     DI
        OR      CL, CL
        JZ      @QUIT
@LOOP:
        LODSB
{$IFDEF USETABLE}
        PUSH    DS
        MOV     DS, SEG @DATA
        LEA     BX, UpCaseTable
        XLAT
        POP     DS
{$ELSE}
        CMP     AL, 'a'
        JB      @CONT
        CMP     AL, 'z'
        JA      @CONT
        XOR     AL, 20h
@CONT:
{$ENDIF}
        STOSB
        LOOP    @LOOP
@QUIT:
        POP     DS
end;

function StrLoCase(S : string) : string; assembler;
asm
        PUSH    DS
        LDS     SI, S
        LES     DI, @Result
        MOV     CL, [SI]
        XOR     CH, CH
        INC     SI
        MOV     ES:[DI], CL
        INC     DI
        OR      CL, CL
        JZ      @QUIT
@LOOP:
        LODSB
{$IFDEF USETABLE}
        PUSH    DS
        MOV     DS, SEG @DATA
        LEA     BX, LoCaseTable
        XLAT
        POP     DS
{$ELSE}
        CMP     AL, 'A'
        JB      @CONT
        CMP     AL, 'Z'
        JA      @CONT
        OR      AL, 20h
@CONT:
{$ENDIF}
        STOSB
        LOOP    @LOOP
@QUIT:
        POP     DS
end;

function Pad(S : String; Len : byte) : string; assembler;
asm
        PUSH    ES
        PUSH    DS
        CLD
        MOV     BL, BYTE PTR PadChar
        LDS     SI, S
        LES     DI, @Result
        MOV     AL, Len
        XOR     AH, AH
        MOV     CL, [SI]
        XOR     CH, CH
        CMP     AH, AL
        JAE     @COPY
        MOV     ES:[DI], AL
        INC     SI
        INC     DI
        SUB     AX, CX
    REP MOVSB
        MOV     CX, AX
        MOV     AL, BL
    REP STOSB
        JMP     @QUIT
@COPY:
        INC     CX
    REP MOVSB
@QUIT:
        POP     DS
        POP     ES
end;

function BHex(B : byte) : string; assembler;
{       CMP     AL, 0Ah         ; AL-byte 0..0Fh -> '0'..'F'
        SBB     AL, 69h         ; Thanks to bulletin AnyKey
        DAS                     }
asm
        LES     DI, @Result
        MOV     BYTE PTR ES:[DI], 2
        MOV     AH, BYTE PTR B
        MOV     AL, AH
        SHR     AL, 1
        SHR     AL, 1
        SHR     AL, 1
        SHR     AL, 1
        CMP     AL, 0Ah
        SBB     AL, 69h
        DAS
        MOV     ES:[DI+1], AL
        MOV     AL, AH
        AND     AL, 0Fh
        CMP     AL, 0Ah
        SBB     AL, 69h
        DAS
        MOV     ES:[DI+2], AL
end;

function ChangeTab(S : string) : string; assembler;
asm
        PUSH    DS
        LES     DI, @Result
        LDS     SI, S
        MOV     BL, [SI]
        XOR     BH, BH
        OR      BL, BL
        JZ      @QUIT
        INC     SI
        INC     DI
        MOV     DX, BX
        CLD
@MAINLOOP:
        LODSB
        CMP     AL, 9
        JNE     @CONT1
        MOV     AL, BH
        XOR     AH, AH
        MOV     CL, TabSize
        DIV     CL
        SUB     CL, AH
        XOR     CH, CH
        MOV     AL, ' '
        ADD     BH, CL
    REP STOSB
        JMP     @CONT2
@CONT1:
        INC     BH
        STOSB
@CONT2:
        DEC     DX
        JNZ     @MAINLOOP
@QUIT:
        LES     DI, @Result
        MOV     ES:[DI], BH
        POP     DS
end;

function AddBackSlash(S : string) : string;
begin
 if (S[Length(S)]<>':') and (S[Length(S)]<>'\') Then
   AddBackSlash := S + '\'
 else
   AddBackSlash := S;
end;

function Str2Word(S: string; var i : word) : boolean;
var c : integer;
begin
  Val(S,i,c);
  Str2Word:= c=0;
end;

function Word2Str( i : word) : string;
var S : string;
begin
  Str(i,S);
  Word2Str := TrimLead(S);
end;

procedure GetILVer(S : string);
begin
  VersionIL := '';
  if pos('Release',S)>0 Then begin
    VersionIL := ' '+Trim(copy(S,pos('Release',S)+8,3));
  end;
end;

function GetFlags(C : char) : string;
begin
  case C of
  'U' : GetFlags:='undocumented function';
  'u' : GetFlags:='partially documented function';
  'P' : GetFlags:='available only in protected mode';
  'R' : GetFlags:='available only in real or V86 mode';
  'C' : GetFlags:='callout or callback (usually hooked rather than called)';
  'O' : GetFlags:='obsolete (no longer present in current versions)';
  else GetFlags:='';
  end; {case}
end;

function GetCategories(C : char) : string;
begin
  case C of
  'A' : GetCategories:= 'applications';
  'a' : GetCategories:= 'access software (screen readers, etc)';
  'B' : GetCategories:= 'BIOS';
  'b' : GetCategories:= 'vendor-specific BIOS extensions';
  'C' : GetCategories:= 'CPU-generated';
  'c' : GetCategories:= 'caches/spoolers';
  'D' : GetCategories:= 'DOS kernel';
  'd' : GetCategories:= 'disk I/O enhancements';
  'E' : GetCategories:= 'DOS extenders';
  'e' : GetCategories:= 'electronic mail';
  'F' : GetCategories:= 'FAX';
  'f' : GetCategories:= 'file manipulation';
  'G' : GetCategories:= 'debuggers/debugging tools';
  'H' : GetCategories:= 'hardware';
  'h' : GetCategories:= 'vendor-specific hardware';
  'I' : GetCategories:= 'IBM workstation/terminal emulators';
  'J' : GetCategories:= 'Japanese';
  'j' : GetCategories:= 'joke programs';
  'K' : GetCategories:= 'keyboard enhancers';
  'k' : GetCategories:= 'file compression';
  'l' : GetCategories:= 'shells/command interpreters';
  'M' : GetCategories:= 'mouse/pointing device';
  'm' : GetCategories:= 'memory management';
  'N' : GetCategories:= 'network';
  'O' : GetCategories:= 'other operating systems';
  'P' : GetCategories:= 'printer enhancements';
  'p' : GetCategories:= 'power management';
  'Q' : GetCategories:= 'DESQview/TopView and Quarterdeck programs';
  'R' : GetCategories:= 'remote control/file access';
  'r' : GetCategories:= 'runtime support';
  'S' : GetCategories:= 'serial I/O';
  's' : GetCategories:= 'sound/speech';
  'T' : GetCategories:= 'DOS-based task switchers/multitaskers';
  't' : GetCategories:= 'TSR libraries';
  'U' : GetCategories:= 'resident utilities';
  'u' : GetCategories:= 'emulators';
  'V' : GetCategories:= 'video';
  'v' : GetCategories:= 'virus/antivirus';
  'W' : GetCategories:= 'MS Windows';
  'X' : GetCategories:= 'expansion bus BIOSes';
  'y' : GetCategories:= 'security';
  '*' : GetCategories:= 'reserved (& not otherwise classified)';
  end; {case}
end;

function FileFound(Name : string) : boolean;
var r : SearchRec;
begin
  FindFirst(Name,$20,r);
  FileFound := DosError = 0;
end;

procedure SkipLines;
begin
  repeat
    if EOF(t1) Then Exit;
    if BreakPressed Then Halt(4);
    ReadLn(t1,S1);
  until ((pos(Line,S1)=1) and (S1[9] <> '!') and (S1[12] <> '-'));
end;

procedure AnalyzeLines;
begin
  Z := 0;
  repeat
    if EOF(t1) Then Exit;
    if BreakPressed Then Halt(4);
    ReadLn(t1,S1);
    Z := Z + Length(S1);
  until (pos(Line,S1)=1);
  if (S1[9] = '!') Then SkipLines;
end;

function IntNum(s:string) : byte;
var i : word;
begin
  if Str2Word('$'+copy(S,11,2),i) Then IntNum := i else IntNum := 0;
end;

procedure GetLine;
begin
  if (TextRec(t1).Mode <> fmClosed) and EOF(t1) Then begin
     Close(t1);
     Inc(Ext1[2]);
  end;
  if TextRec(t1).Mode = fmClosed Then begin
     Name1:=Path1+BaseName+Ext1;
     Assign(t1,Name1);
     Reset(t1);
     if IOResult>0 Then begin
        S1 := '';
        EndOfList := true;
        Exit;
     end;
     if Message Then begin GotoXY(2,Y); Write(Name1); end;
     if Buf<>nil Then SetTextBuf(t1,Buf^,BufSize);
     SkipLines;
     Exit;
  end; {if}
  if BreakPressed Then Halt(4);
  ReadLn(t1,S1);
  if IOResult<>0 Then Error;
  if (pos(Line,S1)=1) and (S1[9] = '!') Then SkipLines;
  if EOF(t1) Then GetLine
end;

procedure SkipItem;
begin
  repeat
    GetLine;
  until (pos(Line,S1)=1);
end;

procedure CheckWrite(var T : text; S : String);
var j,p : byte;
const
    NumResWord = 7;
    BrightText : array[1..NumResWord] of string[8] =
    ('DESC:','NOTE:','NOTES:','BUGS:','SEEALSO:','RETURN:','INDEX:');
begin
  if BreakPressed Then Halt(4);
  S := ChangeTab(S);
  for j := 1 to NumResWord do
    if pos(BrightText[j],StrUpCase(TrimLead(S)))=1 Then begin
       p:=pos(BrightText[j],StrUpCase(S));
       Insert(Bright,S,p+Length(BrightText[j]));
       Insert(Bright,S,p);
       Break;
    end;
  WriteLn(T,S);
end;

function IntHeader(S1,S2 : string) : string;
var S : String;
    i : byte;
begin
  S := Copy(S1,11,Length(S1)-10);
  while S[Length(S)]=LineChar do Dec(S[0]);
  while pos(LineChar,S)>0 do Delete(S,pos(LineChar,S),1);
  if Length(S)>8 Then S[0]:=#8 else S:=Pad(S,8);
  i := pos(' - ',S2);
  IntHeader := S+copy(S2,i+2,Length(S2)-i-1)
end;

procedure WriteItem(var T : text;Comments : boolean);
var S : string;
begin
  S := S1;
  GetLine;
  if EndOfList Then Exit;
  WriteLn(T,_Short+IntHeader(S,S1)); Inc(_NumI);
  if S1[8]<>LineChar Then
    WriteLn(T,Underline+copy(S1,1,7)+copy(S1,10,Length(S1)-9)+Underline)
  else
    WriteLn(T,Underline+S1+Underline);
  if Comments Then begin
    if S[9]<>LineChar Then WriteLn(T,Bright+GetCategories(S[9])+Bright);
    if S1[8]<>LineChar Then begin
      WriteLn(T,Bright+GetFlags(S1[8])+Bright);
      if (S1[9]<>PadChar) and (S1[9]<>LineChar) Then
        WriteLn(T,Bright+GetFlags(S1[9])+Bright);
    end;
  end;
  GetLine;
  if (pos(Line,S1)=0) and not EndOfList Then
    repeat
      CheckWrite(T,S1);
      GetLine;
    until (pos(Line,S1)=1) or EndOfList;
end;

procedure WriteLongItem(var T : text;Comments : boolean);
var
    x1, x2,
    S,Name  : string;
    L       : word;
begin
  S := S1;
  GetLine;
  if EndOfList Then Exit;
  WriteLn(T,_Short+Bright+IntHeader(S,S1)+Bright); Inc(_NumI);
  Name := 'I_L'+Word2Str(BC)+'.N';
  WriteLn(T,_File+Name+'GO');
  WriteLn(tl,CN+Name+NUL);
  Assign(ts,Path2+Name);
  ReWrite(ts);
  if IOResult<>0 Then Error;
  if Buf5<>nil Then SetTextBuf(ts,Buf5^,BufSize);
  Inc(_NumF);

  if S1[8]<>LineChar Then begin
    x1:=_Short+copy(S1,1,7)+copy(S1,10,Length(S1)-9);
    x2:=Underline+copy(S1,1,7)+copy(S1,10,Length(S1)-9)+Underline
  end else begin
    x1:=_Short+S1;
    x2:=Underline+S1+Underline;
  end;
  WriteLn(ts,x1); Inc(_NumI);
  WriteLn(ts,x2);
  L := 0;
  if Comments Then begin
    if S[9]<>LineChar Then WriteLn(ts,Bright+GetCategories(S[9])+Bright);
    if S1[8]<>LineChar Then begin
      WriteLn(ts,Bright+GetFlags(S1[8])+Bright);
      if (S1[9]<>PadChar) and (S1[9]<>LineChar) Then
        WriteLn(ts,Bright+GetFlags(S1[9])+Bright);
    end;
  end;
  GetLine;
  if EndOfList Then Exit;
  repeat
    Inc(L);
    if L>NGShortLimit Then begin
      WriteLn(ts,x1); Inc(_NumI);
      WriteLn(ts,x2);
      L := 0;
    end;
    CheckWrite(ts,S1);
    GetLine;
  until ((pos(Line,S1)=1) or (Length(Trim(S1))=0) or EndOfList);
  while (Length(Trim(S1))=0) and not EndOfList do GetLine;
  if (pos(Line,S1)=0) and not EndOfList Then
    repeat
      if S1[Length(S1)]=':' Then
        x1:=_Short+copy(S1,1,Length(S1)-1)
      else
        x1:=_Short+S1;
      x2:=Underline+S1+Underline;
      WriteLn(ts,x1); Inc(_NumI);
      WriteLn(ts,x2);
      L := 0;
      GetLine;
      if (pos(Line,S1)=0) and not EndOfList Then
        repeat
          Inc(L);
          if L>NGShortLimit Then begin
            WriteLn(ts,x1); Inc(_NumI);
            WriteLn(ts,x2);
            L := 0;
          end;
          CheckWrite(ts,S1);
          GetLine;
        until ((pos(Line,S1)=1) or (Length(Trim(S1))=0) or EndOfList);
      while (Length(Trim(S1))=0) and not EndOfList do GetLine;
    until (pos(Line,S1)=1) or EndOfList;
  Close(ts);
  Inc(BC);
end;

procedure XXXXList(i:byte; Base : Categories; Description : string);
var Name1,Name2,
    M1,M2  : string;
    nf1,nf2,
    l1,l2,
    j,n1,n2: word;
    B1,B2,
    Y1,Y2,
    D1,D2  : boolean;
begin
   B1 := IL[i,1]>1; B2 := IL[i,2]>1;
   D1 := IL[i,1]>=(NGShortLimit+NGShortLimit div 5);
   D2 := IL[i,2]>=(NGShortLimit+NGShortLimit div 5);
   Y1 := D1;
   Y2 := D1 or D2;
   nf1:=1; l1:=0; nf2:=1; l2:=0;
   if not D1 Then begin
     n1:=IL[i,1]; M1 := '';
   end else begin
     n1:=NGShortLimit; M1 := copy(S1,13,2);
     if M1='--' Then M1:='00...' else M1 := M1+'...';
   end; {if}
   if Y1 Then begin
     Assign(Tmp1,Path2+TmpFile1); ReWrite(Tmp1);
     if IOResult<>0 Then Error;
   end; {if}
   if not D2 Then begin
     n2:=IL[i,2]; M2 := '';
   end else begin
     n2:=NGShortLimit; M2 := copy(S1,13,2);
     if M2='--' Then M2:='00...' else M2 := M2+'...';
   end; {if}
   if Y2 Then begin
     Assign(Tmp2,Path2+TmpFile2); ReWrite(Tmp2);
     if IOResult<>0 Then Error;
   end; {if}
   if B1 Then begin
     Name1 := 'I'+BHex(i)+'_S'+Word2Str(nf1)+'.N';
     Assign(t3,Path2+Name1); ReWrite(t3); Inc(_NumF);
     if IOResult<>0 Then Error;
     if Buf3<>nil Then SetTextBuf(t3,Buf3^,BufSize);
     WriteLn(tl,CN+Name1+NUL);
     if Y1 Then begin
       WriteLn(tmp1,_Short+copy(S1,11,2)+Description+M1); Inc(_NumI);
       WriteLn(tmp1,_File+Name1+'GO');
     end else begin
       WriteLn(t2,_Short+copy(S1,11,2)+Description+M1); Inc(_NumI);
       WriteLn(t2,_File+Name1+'GO');
     end;
   end; {if}
   if B2 Then begin
     Name2 := 'I'+BHex(i)+'_T'+Word2Str(nf2)+'.N';
     Assign(t4,Path2+Name2); ReWrite(t4); Inc(_NumF);
     if IOResult<>0 Then Error;
     if Buf4<>nil Then SetTextBuf(t4,Buf4^,BufSize);
     WriteLn(tl,CN+Name2+NUL);
     if Y2 Then begin
       WriteLn(tmp2,_Short+copy(S1,11,2)+_Tools+M2); Inc(_NumI);
       WriteLn(tmp2,_File+Name2+'GO');
     end else begin
       WriteLn(t2,_Short+copy(S1,11,2)+_Tools+M2); Inc(_NumI);
       WriteLn(t2,_File+Name2+'GO');
     end; {if}
   end; {if}

   for j:=1 to (IL[i,1]+IL[i,2]+IL[i,3]) do begin
     Inc(CI);
     if S1[9] in Base Then begin
       Inc(l1);
       if l1>n1 Then begin
         Close(t3); Inc(nf1); M1 := copy(S1,13,2)+'...';
         Name1 := 'I'+BHex(i)+'_S'+Word2Str(nf1)+'.N';
         Assign(t3,Path2+Name1); ReWrite(t3); Inc(_NumF);
         if IOResult<>0 Then Error;
         if Buf3<>nil Then SetTextBuf(t3,Buf3^,BufSize);
         WriteLn(tl,CN+Name1+NUL);
         if Y1 Then begin
           WriteLn(tmp1,_Short+copy(S1,11,2)+Description+M1); Inc(_NumI);
           WriteLn(tmp1,_File+Name1+'GO');
         end else begin
           WriteLn(t2,_Short+copy(S1,11,2)+Description+M1); Inc(_NumI);
           WriteLn(t2,_File+Name1+'GO');
         end;
         if (n1+(NGShortLimit div 5 + NGShortLimit))>IL[i,1] Then
           n1 := IL[i,1]
         else
           n1 := n1 + NGShortLimit;
       end; {if}
       if CI=BI[BC] Then
         if B1 Then WriteLongItem(t3,true)
         else WriteLongItem(t2,true)
       else
         if B1 Then WriteItem(t3,true)
         else WriteItem(t2,true)
     end else if S1[9]='v'Then
       if CI=BI[BC] Then
         if VirusNeed Then WriteLongItem(tv,false)
         else begin Inc(BC); SkipItem; end
       else
         if VirusNeed Then WriteItem(tv,false)
         else SkipItem
     else begin
       Inc(l2);
       if l2>n2 Then begin
         Close(t4); Inc(nf2); M2 := copy(S1,13,2)+'...';
         Name2 := 'I'+BHex(i)+'_T'+Word2Str(nf2)+'.N';
         Assign(t4,Path2+Name2); ReWrite(t4); Inc(_NumF);
         if IOResult<>0 Then Error;
         if Buf4<>nil Then SetTextBuf(t4,Buf4^,BufSize);
         WriteLn(tl,CN+Name2+NUL);
         if Y2 Then begin
           WriteLn(tmp2,_Short+copy(S1,11,2)+_Tools+M2); Inc(_NumI);
           WriteLn(tmp2,_File+Name2+'GO');
         end else begin
           WriteLn(t2,_Short+copy(S1,11,2)+_Tools+M2); Inc(_NumI);
           WriteLn(t2,_File+Name2+'GO');
         end;
         if (n2+(NGShortLimit div 5 + NGShortLimit))>IL[i,2] Then
           n2 := IL[i,2]
         else
           n2 := n2 + NGShortLimit;
       end; {if}
       if CI=BI[BC] Then
         if B2 Then WriteLongItem(t4,true)
         else WriteLongItem(t2,true)
       else
         if B2 Then WriteItem(t4,true)
         else WriteItem(t2,true);
     end;
     if EndOfList Then Break;
   end; {for}

   if B1 Then Close(t3);
   if B2 Then Close(t4);
   if Y1 Then begin
     Close(tmp1);
     Reset(tmp1);
     while not EOF(tmp1) do begin
       ReadLn(tmp1,M1);
       WriteLn(t2,M1);
     end;
     Close(tmp1);
     Erase(tmp1);
   end;
   if Y2 Then begin
     Close(tmp2);
     Reset(tmp2);
     while not EOF(tmp2) do begin
       ReadLn(tmp2,M2);
       WriteLn(t2,M2);
     end;
     Close(tmp2);
     Erase(tmp2);
   end;
end;

procedure MakeIntList;
var S : string;
    i,j : word;
begin
  Assign(tl,Path2+'INTL.LNK');
  ReWrite(tl);
  WriteLn(tl,'!NAME: Interrupt List'+VersionIL);
  WriteLn(tl,'!CREDITS:');
  WriteLn(tl,'           Interrupt List'+VersionIL+' (C) by Ralf Brown');
  WriteLn(tl,'     Converted by INTL2NG v1.1, (C) BZSoft Inc., 1993,94');
  WriteLn(tl,'!MENU: Lists');
  WriteLn(tl,'Interrupt  INTL.NGO');
  if MemoryNeed    Then WriteLn(tl,'Memory     MEMORY.NGO');
  if PortsListNeed Then WriteLn(tl,'Ports      PORTS.NGO');
  if CMOSNeed      Then WriteLn(tl,'CMOS       CMOS.NGO');
  if VirusNeed     Then WriteLn(tl,'Viruses    VIRUS.NGO');
  if GlossaryNeed  Then WriteLn(tl,'Glossary   GLOSSARY.NGO');
  if CommentsNeed  Then WriteLn(tl,'Comments   COMMENTS.NGO');
  Close(tl);

  Assign(tl,Path2+'INTL.BAT');
  ReWrite(tl);
  WriteLn(tl,'@echo off');
  if MemoryNeed    Then WriteLn(tl,CN+'MEMORY.N'+NUL);
  if PortsListNeed Then WriteLn(tl,CN+'PORTS.N'+NUL);
  if CMOSNeed      Then WriteLn(tl,CN+'CMOS.N'+NUL);
  if GlossaryNeed  Then WriteLn(tl,CN+'GLOSSARY.N'+NUL);
  if VirusNeed     Then WriteLn(tl,CN+'VIRUS.N'+NUL);
  if CommentsNeed  Then WriteLn(tl,CN+'COMMENTS.N'+NUL);

  if VirusNeed Then begin
    Assign(tv,Path2+'VIRUS.N');
    ReWrite(tv);
    if IOResult<>0 Then begin
      VirusNeed := false;
      if Message Then WriteLn(' * Cannot create VIRUS.N *'^G);
    end else
      if Buf2<>nil Then SetTextBuf(tv,Buf2^,BufSize);
    Inc(_NumF);
  end;

  Assign(t2,Path2+'INTL.N');
  ReWrite(t2);
  if Buf1<>nil Then SetTextBuf(t2,Buf1^,BufSize);
  if Message Then WriteLn(''^M^J^M^J);
  Y := WhereY-3;

  GetLine;
  {     ___                biggest, but quickly...
     ┌─<___>────┐             < >─────────┐
     │   │      │              │          │
     │  < >──┐  │             ___        ___
     │   │   │  │          ┌─<___>─┐  ┌─<___>─┐
     │  [ ] [ ] │          │   │   │  │   │   │
     │   │   │  │          │  [ ]  │  │  [ ]  │
     └───■───┘  │          │   │   │  │   │   │
         │      │          └───┘   │  └───┘   │
         ■──────┘                  ■──────────┘
         │                         │
  }
  if not ConfigLoaded Then
    for i:=0 to 255 do begin
      if Message Then begin GotoXY(2,Y+1); Write('Int ',BHex(i)); end;
        case i of
        $10 : XXXXList(i,VideoCategories,_Video);
        $16 : XXXXList(i,KeyboardCategories,_Keyboard);
        $21 : XXXXList(i,DosCategories,_Dos);
        $2F : XXXXList(i,MultiCategories,_Multi);
        $33 : XXXXList(i,MouseCategories,_Mouse);
        else  XXXXList(i,BaseCategories,_System);
        end; {case}
      if EndOfList Then Break;
    end {for}
  else
    for i:=0 to 255 do begin
      if Message Then begin GotoXY(2,Y+1); Write('Int ',BHex(i)); end;
      if UseCateg[i] Then XXXXList(i,CategPtr^[i],NamePtr^[i])
                     else XXXXList(i,BaseCategories,_System);
      if EndOfList Then Break;
    end; {for}

  WriteLn(tl,CN+'INTL.N'+NUL);
  WriteLn(tl,'NGML INTL.LNK'+NUL);
  Close(tl);
end; {proc MakeIntList}

procedure Help;
begin
  WriteLn(Header1);
  WriteLn(Header2);
  WriteLn;
  WriteLn(' Usage:');
  WriteLn('       INTL2NG /? - call this HELP');
  WriteLn('  or   INTL2NG [Option] [SourceParh [TargetPath]]');
  WriteLn;
  WriteLn(' Option: (Default all option is ON)');
  WriteLn(' /R - Disable "COMMENTS" item');
  WriteLn(' /G - Disable "GLOSSARY" item');
  WriteLn(' /M - Disable "MEMORY"   item');
  WriteLn(' /P - Disable "PORTS"    item');
  WriteLn(' /C - Disable "CMOS"     item');
  WriteLn(' /V - Disable "VIRUS"    item');
  WriteLn(' /N - Disable message in program and bath files');
  Halt(3);
end;

procedure MakeComments;
label Quit;
var S,W : string;
    i : byte;
begin
  Assign(t1,Path1+'INTERRUP.A');
  Reset(t1); if IOResult<>0 Then Error;
  if Buf<>nil Then SetTextBuf(t1,Buf^,BufSize);
  Assign(t2,Path2+'COMMENTS.N');
  ReWrite(t2);if IOResult<>0 Then Error;
  if Buf1<>nil Then SetTextBuf(t2,Buf1^,BufSize);
  Inc(_NumF);

  ReadLn(t1,S); if IOResult<>0 Then Error;
  WriteLn(t2,S);if IOResult<>0 Then Error;
  ReadLn(t1,S); if IOResult<>0 Then Error;
  WriteLn(t2,S);if IOResult<>0 Then Error;

  repeat ReadLn(t1,S); if IOResult<>0 Then Error;
  until (pos(Line,S)=1) and (pos('CONTACT',S)=13);

  WriteLn(t2,^M^J'        ^BCONTACT INFO^B'^M^J); if IOResult<>0 Then Error;
  ReadLn(t1,S); if IOResult<>0 Then Error;
  repeat
    WriteLn(t2,S); if IOResult<>0 Then Error;
    ReadLn(t1,S);  if IOResult<>0 Then Error;
  until EOF(t1) or (pos(Line,S)=1);

  if S[9]<>'!' Then Goto Quit;
  if pos('DISCLAIMER',S)=0 Then
    repeat ReadLn(t1,S); if IOResult<>0 Then Error;
    until EOF(t1) or ((pos(Line,S)=1) and (pos('DISCLAIMER',S)=13));

  WriteLn(t2,^M^J'        ^BDISCLAIMER^B'^M^J); if IOResult<>0 Then Error;
  ReadLn(t1,S); if IOResult<>0 Then Error;
  repeat
    WriteLn(t2,S); if IOResult<>0 Then Error;
    ReadLn(t1,S);  if IOResult<>0 Then Error;
  until pos(Line,S)=1;

  if S[9]<>'!' Then Goto Quit;
  if pos('FLAGS',S)=0 Then
    repeat ReadLn(t1,S); if IOResult<>0 Then Error;
    until EOF(t1) or ((pos(Line,S)=1) and (pos('FLAGS',S)=13));

  WriteLn(t2,^M^J'        ^BFLAGS^B'^M^J); if IOResult<>0 Then Error;
  ReadLn(t1,S); if IOResult<>0 Then Error;
  repeat
    if pos(' - ',S)>0 Then begin
      W :='';
      while pos(' - ',S)>0 do begin
        i := pos(' - ',S);
        if (i=2) or (S[i-2] in ParseStr) Then
          W := W + copy(S,1,i-2)+Bright+S[i-1]+'^B - ' else
          W := copy(S,1,i+2);
        Delete(S,1,i+2);
      end; W := W + S;
      WriteLn(t2,W);
    end else WriteLn(t2,S);
    if IOResult<>0 Then Error;
    ReadLn(t1,S); if IOResult<>0 Then Error;
  until pos(Line,S)=1;

  if S[9]<>'!' Then Goto Quit;
  if pos('CATEGORIES',S)=0 Then
    repeat ReadLn(t1,S); if IOResult<>0 Then Error;
    until EOF(t1) or ((pos(Line,S)=1) and (pos('CATEGORIES',S)=13));

  WriteLn(t2,^M^J'        ^BCATEGORIES^B'^M^J); if IOResult<>0 Then Error;
  ReadLn(t1,S); if IOResult<>0 Then Error;
  repeat
    if pos(' - ',S)>0 Then begin
      W :='';
      while pos(' - ',S)>0 do begin
        i := pos(' - ',S);
        if (i=2) or (S[i-2] in ParseStr) Then
          W := W + copy(S,1,i-2)+Bright+S[i-1]+'^B - ' else
          W := copy(S,1,i+2);
        Delete(S,1,i+2);
      end; W := W + S;
      WriteLn(t2,W);
    end else WriteLn(t2,S);
    if IOResult<>0 Then Error;
    ReadLn(t1,S); if IOResult<>0 Then Error;
  until pos(Line,S)=1;

  WriteLn(t2,^M^J'        ^BADAPTATION^B'^M^J); if IOResult<>0 Then Error;
  WriteLn(t2,'INTL2NG has make this NG-base.');
          if IOResult<>0 Then Error;
  WriteLn(t2,'INTL2NG (with source) is FREEWARE by Boris D. Zulin');
          if IOResult<>0 Then Error;
  WriteLn(t2,'Chemical Engineering Department (OXT),');
                                                  if IOResult<>0 Then Error;
  WriteLn(t2,'Polytechnic University,');          if IOResult<>0 Then Error;
  WriteLn(t2,'Kharkov, Ukraine');                 if IOResult<>0 Then Error;
  WriteLn(t2,'(0572) 400-875 (voice),');          if IOResult<>0 Then Error;
  WriteLn(t2,'(0572) 400-893 (FAX).');            if IOResult<>0 Then Error;
Quit:
  Close(t2);
  Close(t1);
  if Message Then WriteLn(' COMMENTS file created.');
end;

procedure MakePorts;
var   i,M     : word;
      NewShort: boolean;
begin
  NewShort := false;
  Assign(t1,Path1+'PORTS.LST');
  Reset(t1);
  if IOResult<>0 Then begin
    PortsListNeed := false;
    Exit;
  end;
  if Buf<>nil Then SetTextBuf(t1,Buf^,BufSize);
  Assign(t2,Path2+'PORTS.N');
  ReWrite(t2); if IOResult<>0 Then Error;
  if Buf1<>nil Then SetTextBuf(t2,Buf1^,BufSize);
  Inc(_NumF);

  while (not EOF(t1)) and (pos(Line,S1)=0) do begin
    ReadLn(t1,S1); if IOResult<>0 Then Error;
  end;
  ReadLn(t1,S1); if IOResult<>0 Then Error;
  WriteLn(t2,_Short+ChangeTab(S1)); Inc(_NumI);
  WriteLn(t2,Underline+ChangeTab(S1)+Underline);
  while not EOF(t1) do begin
    ReadLn(t1,S1); if IOResult<>0 Then Error;
    if (pos(Line,S1)=1) Then begin
      ReadLn(t1,S1); if IOResult<>0 Then Error;
      if EOF(t1) Then Break;
      WriteLn(t2,_Short+ChangeTab(S1)); Inc(_NumI);
      WriteLn(t2,Underline+ChangeTab(S1)+Underline);
    end else WriteLn(t2,S1);
  end; {while}
  Close(t2);
  Close(t1);
  if Message Then WriteLn(' PORTS file created.');
end;

procedure MakeCMOS;
const MaxLine = 700;
type  ListA   = array[1..MaxLine] of string[80];
      PListA  = ^ListA;
var   P       : PListA;
      NL,i,M  : word;
begin
  Assign(t1,Path1+'CMOS.LST');
  Reset(t1);
  if IOResult<>0 Then begin
    CMOSNeed := false;
    Exit;
  end;
  if Buf<>nil Then SetTextBuf(t1,Buf^,BufSize);
  Assign(t2,Path2+'CMOS.N');
  ReWrite(t2); if IOResult<>0 Then Error;
  if Buf1<>nil Then SetTextBuf(t2,Buf1^,BufSize);
  Inc(_NumF);

  NL := 0; P:=nil; New(P);
  if P=nil Then begin
    if Message Then WriteLn(' * Out of memory, cannot make "CMOS" item *'^G);
    CMOSNeed := false;
    Exit;
  end;
  while not EOF(t1) do begin
    while (NL<MaxLine) and (not EOF(t1)) do begin
      Inc(NL);
      ReadLn(t1,P^[NL]); if IOResult<>0 Then Error;
    end; {while}
    if EOF(t1) Then M:=NL else M:=NL-1;
    for i := 1 to M do begin
      if (TrimLead(P^[i])='') and (i+2<=M) and
         (TrimLead(P^[i+2])='') and
         ((pos(^I^I,P^[i+1])=1) or
          (pos('       ',P^[i+1])=1)) Then begin
            WriteLn(t2,_Short,TrimLead(P^[i+1])); Inc(_NumI);
            P^[i+1]:=Underline+P^[i+1]+Underline;
      end; {if}
      WriteLn(t2,P^[i]);
    end; {for}
    if not EOF(t1) Then begin
      NL:=1;
      P^[1]:=P^[NL];
    end;
  end; {while}
  Dispose(P);
  Close(t2);
  Close(t1);
  if Message Then WriteLn(' CMOS file created.');
end;

procedure MakeLst(Name : string; var Ok : boolean);
var   i,M     : word;
      NewShort: boolean;
begin
  Ok := true;
  NewShort := false;
  Assign(t1,Path1+Name+'.LST');
  Reset(t1);
  if IOResult<>0 Then begin
    Ok := false;
    Exit;
  end;
  if Buf<>nil Then SetTextBuf(t1,Buf^,BufSize);
  Assign(t2,Path2+Name+'.N');
  ReWrite(t2); if IOResult<>0 Then Error;
  if Buf1<>nil Then SetTextBuf(t2,Buf1^,BufSize);
  Inc(_NumF);

  ReadLn(t1,S1); if IOResult<>0 Then Error;
  ReadLn(t1,S1); if IOResult<>0 Then Error;
  while not EOF(t1) do begin
    ReadLn(t1,S1); if IOResult<>0 Then Error;
    if (TrimLead(S1)='') Then NewShort := true
       else
         if NewShort Then begin
           NewShort := false;
           WriteLn(t2,_Short,TrimLead(S1)); Inc(_NumI);
           WriteLn(t2,Underline,TrimLead(S1),'^U'^M^J);
         end else WriteLn(t2,S1);
  end; {while}
  Close(t2);
  Close(t1);
  if Message Then WriteLn(' '+Name+' file created.');
end;

procedure IncCount(N : byte; C : char);
begin
  if not ConfigLoaded Then
  case N of
  $10 : if C in VideoCategories Then Inc(IL[N,1])
        else if C='v' Then Inc(IL[N,3]) else Inc(IL[N,2]);
  $16 : if C in KeyboardCategories Then Inc(IL[N,1])
        else if C='v' Then Inc(IL[N,3]) else Inc(IL[N,2]);
  $21 : if C in DosCategories Then Inc(IL[N,1])
        else if C='v' Then Inc(IL[N,3]) else Inc(IL[N,2]);
  $2F : if C in MultiCategories Then Inc(IL[N,1])
        else if C='v' Then Inc(IL[N,3]) else Inc(IL[N,2]);
  $33 : if C in MouseCategories Then Inc(IL[N,1])
        else if C='v' Then Inc(IL[N,3]) else Inc(IL[N,2]);
  else  if C in BaseCategories Then Inc(IL[N,1])
        else if C='v' Then Inc(IL[N,3]) else Inc(IL[N,2]);
  end {case}
  else begin
    if UseCateg[N] Then
      if (C in CategPtr^[N]) Then Inc(IL[N,1])
        else if C='v' Then Inc(IL[N,3]) else Inc(IL[N,2])
    else if C in BaseCategories Then Inc(IL[N,1])
        else if C='v' Then Inc(IL[N,3]) else Inc(IL[N,2]);
  end; {if}
end;

procedure ReadConfig;
var Path : string;
    SR : SearchRec;
    Attr : byte;
    Name : string;
    i,j,l: word;
begin
  Name := 'INTL2NG.CFG';
  Attr := ReadOnly+Archive+Hidden;
  FindFirst(Name,Attr,SR);
  if DosError>0 Then begin
    Path:=ParamStr(0);
    while ((Path[Length(Path)]<>'\') and (Length(Path)>0)) do Dec(Path[0]);
    Name := Path+Name;
    FindFirst(Name,Attr,SR);
    if DosError=0 Then Exit;
  end;
  Assign(ts,Name);
  Reset(ts); if IOResult<>0 Then Exit;
  {----- Parse config file ------------------------------------------}
  while (not EOF(ts)) do begin
    ReadLn(ts,S1); if IOResult<>0 Then Error;
    if ((S1[1]='/') or (S1[1]='-')) and (Length(S1)>1) Then
      case UpCase(S1[2]) of
      'V'     : VirusNeed     := false;
      'R'     : CommentsNeed  := false;
      'P'     : PortsListNeed := false;
      'M'     : MemoryNeed    := false;
      'C'     : CMOSNeed      := false;
      'G'     : GlossaryNeed  := false;
      'N'     : Message       := false;
      'I'     : Path1 := AddBackSlash(copy(S1,3,Length(S1)-2));
      'O'     : Path2 := AddBackSlash(copy(S1,3,Length(S1)-2));
      end {case} else begin
        if not ConfigLoaded Then begin
          ConfigLoaded:=true;
          New(CategPtr);
          New(NamePtr);
          for i:=0 to 255 do begin
            CategPtr^[i] := [];
            NamePtr^[i] := '';
            UseCateg[i] := false;
          end; {for}
          NamePtr^[$10]  := _Video;
          UseCateg[$10]  := true;
          CategPtr^[$10] := VideoCategories;
          NamePtr^[$16]  := _Keyboard;
          UseCateg[$16]  := true;
          CategPtr^[$16] := KeyboardCategories;
          NamePtr^[$21]  := _DOS;
          UseCateg[$21]  := true;
          CategPtr^[$21] := DosCategories;
          NamePtr^[$2F]  := _Multi;
          UseCateg[$2F]  := true;
          CategPtr^[$2F] := MultiCategories;
          NamePtr^[$33]  := _Mouse;
          UseCateg[$33]  := true;
          CategPtr^[$33] := MouseCategories;
        end;
        Name:=StrUpCase(copy(S1,1,pos(' ',S1)-1));
        if Name='BASE' Then begin
          Delete(S1,1,pos('(',S1));
          _System := '       ^B'+copy(S1,1,pos(')',S1)-1)+'^B  ';
          Delete(S1,1,pos('(',S1));
          Name := copy(S1,1,pos(')',S1)-1);
          BaseCategories := [];
          for l:=1 to Length(Name) do
            BaseCategories := BaseCategories+ [Name[l]];
        end;
        if not Str2Word(Name,j) Then Break;
        Delete(S1,1,pos('(',S1));
        NamePtr^[j] := '       ^B'+copy(S1,1,pos(')',S1)-1)+'^B  ';
        UseCateg[j] := true;
        Delete(S1,1,pos('(',S1));
        Name := copy(S1,1,pos(')',S1)-1);
        CategPtr^[j] := [];
        for l:=1 to Length(Name) do CategPtr^[j] := CategPtr^[j]+ [Name[l]];
      end; {if}
  end; {wile}
  {------------------------------------------------------------------}
  Close(ts);
end;

procedure ParamParse;
begin
  if ParamCount>0 Then
  for i := 1 to ParamCount do begin
    S1 := ParamStr(i);
    if ((S1[1]='/') or (S1[1]='-')) and (Length(S1)>1) Then begin
      repeat
      case UpCase(S1[2]) of
      'H','?' : Help;
      'V'     : VirusNeed     := false;
      'R'     : CommentsNeed  := false;
      'P'     : PortsListNeed := false;
      'M'     : MemoryNeed    := false;
      'C'     : CMOSNeed      := false;
      'G'     : GlossaryNeed  := false;
      'N'     : Message       := false;
      end; {case}
      if Length(S1)>2 Then Delete(S1,1,2);
      until (Length(S1)=0);
    end else
      if Length(Path1)=0 Then Path1:=AddBackSlash(S1)
      else if Length(Path2)=0 Then Path2:=AddBackSlash(S1)
  end; {for}
end;

procedure Analyze;
begin
  if Message Then WriteLn(^M^J' Analyze...');
  N:=0;
  while FileFound(Name1) do begin
    Inc(NumF); Inc(N);
    Assign(t1,Name1);
    if Message Then WriteLn(' ',Name1);
    Reset(t1);
    if IOResult<>0 Then Error;
    if Buf<>nil Then SetTextBuf(t1,Buf^,BufSize);
    ReadLn(t1,S1); if Ext1 = '.A' Then GetILVer(S1);
    SkipLines;

    while not EOF(t1) do begin
      Inc(NI);
      IncCount(IntNum(S1),S1[9]);
      AnalyzeLines;
      if Z > NGLimit Then begin
        Inc(BN);
        if BN<MaxBig Then BI[BN] := NI;
      end;
    end;

    Close(t1);
    Inc(Ext1[2]);
    Name1:=Path1+BaseName+Ext1;
  end;
  if N=0 Then begin
    if Message Then WriteLn(' * Files not found *');
    Halt(2);
  end;
  if Message Then WriteLn(' Analysis done, building listing...');
end;

procedure Report;
begin
  if Message Then begin
    WriteLn;
    WriteLn('Files :',_NumF);
    WriteLn('Items :',_NumI);
    GetTime(Tm2.H,Tm2.M,Tm2.S,Tm2.S100);
    asm
       MOV     AX, Tm1.M
       MOV     BX, 60
       MUL     BX
       ADD     Tm1.S, AX
       MOV     AX, Tm2.M
       MUL     BX
       ADD     Tm2.S, AX
       MOV     AX, Tm1.S100
       CMP     AX, Tm2.S100
       JB      @1
       MOV     BX, 100
       SUB     BX, AX
       ADD     Tm2.S100, BX
       DEC     Tm2.S
@1:
       SUB     Tm2.S100, AX
       MOV     AX, Tm1.S
       SUB     Tm2.S, AX
       MOV     AX, Tm2.S
       XOR     DX, DX
       MOV     BX, 60
       DIV     BX
       MOV     Tm2.M, AX
       MOV     Tm2.S, DX
    end;
    WriteLn(Tm2.M:3,' min ',Tm2.S:2,'.',Tm2.S100:2,' sec.');
    WriteLn;
    WriteLn(' INTL2NG done.');
  end;
end;

procedure Init;
var i : integer;
begin
  Ext1 := '.A'; GetTime(Tm1.H,Tm1.M,Tm1.S,Tm1.S100);
  for i:=0 to 255 do begin IL[i,1] := 0; IL[i,2] := 0; IL[i,3]:=0 end;
  NumF := 0; Buf := nil; Buf1 := nil; Buf2 := nil; Buf3 := nil;
  Buf4 := nil; Buf5 := nil;
  HeapError := @HeapFunc;
  TextRec(t1).Mode := fmClosed;
  TextRec(t2).Mode := fmClosed;
  TextRec(t3).Mode := fmClosed;
  TextRec(t4).Mode := fmClosed;
  TextRec(tl).Mode := fmClosed;
  TextRec(tv).Mode := fmClosed;
  TextRec(ts).Mode := fmClosed;
  TextRec(tmp1).Mode := fmClosed;
  TextRec(tmp2).Mode := fmClosed;
  GetIntVec($1B,SaveBreakPtr);
  SetIntVec($1B,@BreakFunc);
  ExitProc := @MyExit; Nul :='';
  ReadConfig;
end;

procedure Done;
begin
  if Buf <>nil Then Dispose(Buf);
  if Buf1<>nil Then Dispose(Buf1);
  if Buf2<>nil Then Dispose(Buf2);
  if Buf3<>nil Then Dispose(Buf3);
  if Buf4<>nil Then Dispose(Buf4);
  if Buf5<>nil Then Dispose(Buf5);
  if ConfigLoaded Then begin
     Dispose(CategPtr);
     Dispose(NamePtr);
  end;
end;

begin
   Copyright;
   Init;
   ParamParse;

   if Message Then begin
   WriteLn(Header1);
   WriteLn(Header2);
   end else Nul:= ' > nul';
   Name1:=Path1+BaseName+Ext1;

   New(Buf); New(Buf1); New(Buf2); New(Buf3); New(Buf4); New(Buf5);

   Analyze;

   Ext1 := '.A';

   MakeIntList;

   if Message Then GotoXY(1,Y+2);
   if CommentsNeed Then MakeComments;
   if PortsListNeed Then MakePorts;
   if MemoryNeed Then MakeLst('MEMORY',MemoryNeed);
   if CMOSNeed Then MakeCMOS;
   if GlossaryNeed Then MakeLst('GLOSSARY',GlossaryNeed);

   Report;
   Done;

end.
