{$A+,B-,D+,E+,F-,I-,L+,N-,O-,R-,S+,V+,X+}
{$M 65520,0,655360}

program AntiVirus600;
uses
  TPCrt,
  TPWindow,
  TPInline,
  TPDos,
  TPString,
  Dos;

const
  NoVirus      = 0;
  OpenError    = 1;
  ReadError    = 2;
  WriteError   = 3;
  SeekError    = 4;
  CloseError   = 5;
  TruncateError= 6;
  VirusCleaned = 255;

  Author : string [50] = 'Автоp: Сеpгей Ваpюха, Таллинн 1991, 20.01.91';

  Copyright : string [76] =
    ' Anti 600  Version 1.0  Copyright (c) 1991 by Serge N. Varjukha ';

  WAttr : byte = $71;    { windows }
  FAttr : byte = $71;    { frames  }
  HAttr : byte = $74;    { headers }
  EAttr : byte = $70;    { error messages }

  MainWAttr : byte = $70;  {Window body }
  MainFAttr : byte = $17;  {Frame }
  MainHAttr : byte = $4E;  {Header }

type
  PathName = string[64];

var
  MainW,
  FirstW   : WindowPtr;
  StartDir : PathName;       {Drive:directory where searching starts}
  FileMask : PathName;       {Mask to decide which files to match}
  CurrentDir : PathName;
  ExitSave : pointer;
  F : file;
  B : array [0..1023] of byte;
  Blongint : longint absolute B;
  CodedPart : longint;
  I   : integer;
  Ch  : char;
  CmdLine, S : string;
  VirusChecked : boolean;
  VirusRemoved : boolean;
  VirusKilled  : boolean;

function Check600(S : string): byte;
const
  VersionPosition = 560;
  VersionString   = #$88#$27#$43#$E2#$F6#$5B#$5A#$59#$53;
var
  Attr : word;
begin
  Check600 := NoVirus;
  Assign(F, S);
  Reset(F, 1);
  if IOResult <> 0 then begin
    Check600 := OpenError;
    GetFAttr(F, Attr);
    if DosError = 0 then begin
      Attr := Attr and $FE;
      SetFAttr(F, Attr);
      if DosError <> 0 then Exit
    end
    else Exit
  end;
  if FileSize(F) < 1200 then Exit;
  BlockRead(F, B, 600);
  if IOResult <> 0 then begin
    Check600 := ReadError;
    Exit
  end;
  Move(B[VersionPosition], S[1], length(VersionString));
  S[0] := char(length(VersionString));
  if (S <> VersionString) or
     (B[599] <> $C3)      or
     (B[0] <> $BE)        or
     (B[1] <> $10)        then Exit;
  CodedPart := FileSize(F) - 600;
  Seek(F, CodedPart);
  if IOResult <> 0 then begin
    Check600 := SeekError;
    Exit
  end;
  BlockRead(F, B, 600);
  if IOResult <> 0 then begin
    Check600 := ReadError;
    Exit
  end;
  for I := 0 to 599 do B[I] := B[I] xor $BB;
  Seek(F, 0);
  if IOResult <> 0 then begin
    Check600 := SeekError;
    Exit
  end;
  SetFAttr(F, Archive);
  I := DosError;
  BlockWrite(F, B, 600);
  if IOResult <> 0 then begin
    Check600 := WriteError;
    Exit
  end;
  Seek(F, CodedPart);
  if IOResult <> 0 then begin
    Check600 := SeekError;
    Exit
  end;
  Truncate(F);
  if IOResult <> 0 then begin
    Check600 := TruncateError;
    Exit
  end;
  Close(F);
  if IOResult <> 0 then begin
    Check600 := CloseError;
    Exit
  end;
  Check600 := VirusCleaned
end;


procedure Terminate; far;
begin
  ExitProc := ExitSave;
  TextMode(CO80);
  case ExitCode of
     0    : ;
     1    : ;
     255  : Writeln(^M^J'Terminated by user!')
     else   Writeln(^M^J'ALARM! Program terminated!')
  end;
  ErrorAddr := nil;
  ExitCode := 0;
end;

procedure SearchDir(FDir : PathName); {-search files in one directory}
var
  Frec : SearchRec;

  procedure Detect;
  var
    S : string;
  begin
    S := FullPathName(AddBackSlash(FDir) + Frec.Name);
    S := StUpCase(S);
    Write(Pad(' ' + S, 50));
    case Check600(S) of
      NoVirus      : Write(^M);
      OpenError    : Writeln('open error') ;
      ReadError    : Writeln('read error') ;
      WriteError   : Writeln('write error') ;
      SeekError    : Writeln('seek error') ;
      CloseError   : Writeln('close error') ;
      TruncateError: Writeln('truncate error') ;
      VirusCleaned : Writeln('virus removed!'^G)
    end;
    Close(F);
    if IOResult <> 0 then {};
  end;

begin
  FindFirst(AddBackSlash(FDir)+FileMask, AnyFile, Frec);
  while DosError = 0 do
  begin
    with Frec do
      if (Attr and (Directory + VolumeID)) = 0 then Detect;
    FindNext(Frec)
  end;

  {Scan the subdirectories of the current directory}
  FindFirst(AddBackSlash(FDir) + '*.*', AnyFile, Frec);
  while DosError = 0 do
  begin
    with Frec do
      if ((Attr and Directory) <> 0) and (Name[1] <> '.') then
      begin
        SearchDir(AddBackSlash(FDir) + Name);   {Search subdirectory}
        SetDta(@Frec);            {Restore DTA}
      end;
    FindNext(Frec)
  end
end;

procedure CheckMemory;
const
  VirusVector21 : string [18] = #$FB#$80#$FC#$AB#$75#$04#$B8#$55#$55#$CF#$50#$FE#$C4#$3D#$00#$4C#$58#$75;
var
  P : pointer;
  S : string [20];
  I : byte;
  R : registers;
begin
  Write(' RAM checking');
  for I := 1 to 16 do begin
    Write('.');
    Delay(80)
  end;
  with R do begin
    AH := $AB;
    Intr($21, R);
    if AX = $5555 then begin
      VirusChecked := True;
      VirusRemoved := False;
      Write(^G'   virus in memory!')
    end
    else Writeln(' Ok!');
  end;
  if not VirusChecked then Exit;
  GetIntVec($21, P);
  Move(P^, S[1], 18);
  S[0] := #18;
  if S <> VirusVector21 then begin
    VirusVector21[18] := #$EB;
    if S <> VirusVector21 then
      Writeln(^G'    Virus can''t be removed!')
    else begin
      Writeln(^G'    Virus already killed!');
      VirusKilled := True;
    end;
    Delay(400);
    Exit
  end;
  S[18] := #$EB;
  inline($FA); { cli }
  Move(S[1], P^, 18);
  inline($FB); { sti }
  Delay(500);
  VirusRemoved := True;
  Writeln(^G' ...removed');
end;

procedure ClearKbd;
begin
  while KeyPressed do ReadKey
end;

procedure Initialize;    {-Initialize globals}
var
  DirMask : string;
begin
  CmdLine := ParamStr(1);
  ExitSave  := ExitProc;
  ExitProc  := @Terminate;
  ClearKbd;
  HiddenCursor;
  CheckBreak := True;
  VirusChecked := False;
  VirusRemoved := True;
  VirusKilled  := False;
  DirMask := ParamStr(1);
  GetDir(0, CurrentDir);
  I := DosError;
  StartDir := '';
  FileMask := '*.COM';
  if DirMask <> '' then
    StartDir := StUpcase(DirMask);
  if StartDir[length(StartDir)] = '\' then Dec(StartDir[0]);
  Explode := False;
  ExplodeDelay := 10;
  if not MakeWindow(FirstW, 1, 1, ScreenWidth, 4, True, True,
    False, WAttr, FAttr, HAttr,'') then {};
  if not DisplayWindow(FirstW) then {};
  FastCenter(Copyright,0, HAttr);
  FastCenter('Please connect with me when detecting new versions of the virus.', 1, EAttr);
  if not MakeWindow(MainW, 1, 5, ScreenWidth, ScreenHeight, True, True,
    False, MainWAttr, MainFAttr, MainHAttr,'') then {};
  if not DisplayWindow(MainW) then {};
end;
{ Initialize }

begin
  Initialize;
  CheckMemory;
  Writeln;
  SearchDir(CmdLine);
  TextColor(Red);
  Writeln;
  NormalCursor;
  case VirusChecked of
    False : Writeln(' Virus not detected in memory.');
    True  : Writeln(' Virus was detected in memory!');
  end;
  if VirusKilled then Writeln(' Virus in memory was already killed.')
  else
    if VirusChecked then
         case VirusRemoved of
           False : Writeln(' Virus not removed from memory!');
           True  : Writeln(' Virus removed from memory.');
         end;
  Writeln;
  if (not VirusRemoved) and (not VirusKilled) then begin
    Write('Press <Esc> for system rebooting or <Enter> for exit to DOS ');
    repeat
      ClearKbd;
      Ch := ReadKey
    until Ch in [#13, #27];
    if Ch = #27 then inline($EA/$F0/$FF/$00/$F0);
  end
  else begin
    Write(' Press any key ...');
    ClearKbd;
    if ReadKeyWord = 0 then {};
  end;
  ClearKbd;
  Writeln;
  ChDir(CurrentDir);
  I := IOResult;
end.
{eof a600.pas}
