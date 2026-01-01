{$B-,D-,F-,I+,R-,S-,V-}
{$M 65520,65535,655360}
program CRCDir;

  uses
    Dos, TPCrt, TPString, TPDos, CRC32;

  const
    MaxWidth = 80;

  var
    Out: text;
    Options: string;
    Masks: array[1..64] of string;
    LineCount, NMasks: word;
    b, DisplayCRC, Help, Page, SubDirs, Wide: Boolean;
    ClustersAvailable, TotalClusters, BytesPerSector, SectorsPerCluster: word;
    BytesPerCluster: longint;

  procedure WaitAKey;
    var c: char;
  begin
    while KeyPressed do begin
      c := ReadKey; if c = #0 then c := ReadKey;
    end;
    repeat until KeyPressed;
    c := ReadKey; if c = #0 then c := ReadKey;
  end { WaitAKey };

  procedure WriteLine(s: string);
  begin
    if CtrlBreakFlag then Halt;
    Writeln(Out, s);
    if Page then begin
      Inc(LineCount);
      if LineCount = CurrentHeight then begin
        Write('...press any key...'); WaitAKey; Writeln; LineCount := 0;
      end;
    end;
  end { WriteLine };

  procedure HelpInfo;
  begin
    WriteLine('CRCDIR [mask ...] [/HNPSW]');
    WriteLine('   mask   - 0, 1, or more filename masks;');
    WriteLine('            dir, path, wildcards are OK, default is *.*;');
    WriteLine('   /HNPSW - 0..5 options;');
    WriteLine('   /H, /? - this Help info;');
    WriteLine('   /N     - No CRC-32 display;');
    WriteLine('   /P     - display one Page at a time;');
    WriteLine('   /S     - scan Subdirectories;');
    WriteLine('   /W     - Wide display.');
    WriteLine('');
  end { HelpInfo };

  procedure LastHelp;
  begin
    if not Help then begin
      if Page then begin
        WriteLine('CRCDIR /? - help info.');
        if LineCount <> 0 then WriteLine('') end
      else begin
        Writeln('CRCDIR /? - help info.');
        Writeln;
      end;
    end;
    if Page and (LineCount <> 0) then begin
        Write('...press any key...'); WaitAKey; Writeln;
    end;
  end { LastHelp };

  procedure ScanParms;
    var
      DriveLetterPos: array['A'..'Z'] of word;
      c: char;
      i: word;
      s: string;
  begin
    Options := '';
    DriveLetterPos['A'] := 1;
    for c := 'B' to 'Z' do DriveLetterPos[c] := 0;
    for i := 1 to ParamCount do begin
      s := StUpcase(ParamStr(i));
      if s[1] = '/' then
        Options :=  Options + s
      else begin
        if (Length(s) < 2) or (s[2] <> ':') then
          c := DefaultDrive
        else
          c := s[1]; { Drive letter };
        if c <> 'Z' then Inc(DriveLetterPos[Succ(c)]);
      end;
    end;
    for c := 'B' to 'Z' do Inc(DriveLetterPos[c], DriveLetterPos[Pred(c)]);
    NMasks := 0;
    for i := 1 to ParamCount do begin
      s := StUpcase(ParamStr(i));
      if s[1] <> '/' then begin
        if (Length(s) < 2) or (s[2] <> ':') then
          s := DefaultDrive + ':' + s;
        c := s[1];
        if c < Chr(Ord('A')+NumberOfDrives-1) then begin
          Inc(NMasks);
          Masks[DriveLetterPos[c]] := s; Inc(DriveLetterPos[c]);
        end;
      end;
    end;
    DisplayCRC := (Pos('N', Options) = 0);
    Help := (Pos('?', Options) <> 0) or (Pos('H', Options) <> 0);
    Page := (Pos('P', Options) <> 0) and HandleIsConsole(StdOutHandle);
    LineCount := 0;
    if Help then HelpInfo;
    SubDirs := (Pos('S', Options) <> 0);
    Wide := (Pos('W', Options) <> 0);
    if NMasks = 0 then begin
      if Help and DisplayCRC and
         not Page and not Subdirs and not Wide
      then Halt;
      NMasks := 1;
      Masks[1] := DefaultDrive + ':*.*';
    end;
  end { ScanParms };

  {$I-}
  procedure DisplayDirectory(Mask, LeadIn: string);
    var
      F: SearchRec;
      Count, FCount, DirCount, TotalClu, Clu, w: word;
      S: string;
      T: DateTime;
      CRC, Total : longint;
    procedure DisplayFile;
    const
      MonthStr: array[0..12] of string[3] = (
        '   ',
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
    begin
      if Wide then begin
        w := Length(S);
        if (F.Attr and Directory) = 0
        then S := S + Pad(F.Name, 13)
        else S := S + Pad(F.Name+'\', 13);
        if DisplayCRC then begin
          if (F.Attr and Directory) = 0 then begin
            if CRCFile(LeadIN+F.Name, CRC) = 0
            then S := S + ' ' + StLocase(HexL(CRC))
            else S := S + '  -Error-'; end
          else
            S := S + ' --------'
        end;
        S := S + '  ';
        if 2*Length(S) - w > MaxWidth then begin
          WriteLine(S); S := '';
        end; end
      else begin
        Str(Count: 5, S);
        S := S  + ' ';
        if (F.Attr and Directory) = 0
        then S := S +
                  Pad(F.Name, 13) +
                  LeftPad(Long2Str(F.Size), 11) + ' ' +
                  LeftPad(Long2Str(Clu), 5)
        else S := S + Pad(F.Name+'\', 13) + ' -Directory      ';
        if (F.Attr and Hidden) = 0
        then S := S + ' .'
        else S := S + ' H';
        if (F.Attr and SysFile) = 0
        then S := S + '.'
        else S := S + 'S';
        if (F.Attr and ReadOnly) = 0
        then S := S + '.'
        else S := S + 'R';
        if (F.Attr and Archive) = 0
        then S := S + '. '
        else S := S + 'A ';
        UnpackTime(F.Time, T);
        if (T.Month < 1) or (12 < T.Month) then T.Month := 0;
        S := S + ' ' +
             MonthStr[T.Month] + '-' +
             LeftPadCh(Long2Str(T.Day), '0', 2) + '-' +
             Long2Str(T.Year) + ' ' +
             LeftPadCh(Long2Str(T.Hour), '0', 2) + '.' +
             LeftPadCh(Long2Str(T.Min), '0', 2) + '.' +
             LeftPadCh(Long2Str(T.Sec), '0', 2);
        if DisplayCRC then begin
          if (F.Attr and Directory) = 0 then begin
            if CRCFile(LeadIN+F.Name, CRC) = 0
            then S := S + ' ' + StLocase(HexL(CRC))
            else S := S + '  -Error-'; end
          else
            S := S + ' --------';
        end;
        WriteLine(S); S := '';
      end
    end { DisplayFile };
  begin
    Count := 0; FCount := 0; DirCount := 0; TotalClu := 0; Total := 0;
    S := '';
    WriteLine('Directory of '+Mask);
    WriteLine('');
    if not Wide then begin
      S := '    # Filename.Ext        Size   Clu Attr         Date     Time';
      if DisplayCRC then S := S + '   CRC-32';
      WriteLine(S);
      if DisplayCRC then S := CharStr('-', 72) else S := CharStr('-', 63);
      WriteLine(S);
    end;
    FindFirst(Mask, ReadOnly+Hidden+SysFile+Directory+Archive, F);
    while DosError = 0 do begin
      Inc(Count);
      if (F.Attr and Directory) = 0 then begin
        Inc(FCount);
        Inc(Total, F.Size);
        Clu := (F.Size + BytesPerCluster - 1) div BytesPerCluster;
        Inc(TotalClu, Clu); end
      else
        Inc(DirCount);
      DisplayFile;
      FindNext(F);
    end;
    if S <> '' then WriteLine(S);
    if not Wide then begin
      if DisplayCRC then S := CharStr('-', 72) else S := CharStr('-', 63);
      WriteLine(S);
    end;
    Str(FCount: 5, S);
    S := S  +
         ' file(s)      ' +
         LeftPad(Long2Str(Total), 11) + ' ' +
         LeftPad(Long2Str(TotalClu), 5) + '=' +
         LeftPad(Long2Str(BytesPerCluster*longint(TotalClu)), 11);
    WriteLine(S);
    Str(DirCount: 5, S);
    S := S +
         ' dir(s)             Total;  Clu=       Used';
    WriteLine(S);
    WriteLine('') ;
  end { DisplayDirectory };
  {$I+}

  procedure ProcessMask(Mask, LeadIn: string); forward;

  {$I-}
  procedure ScanSubdirectories(Path, FileMask: string);
    var
      S: SearchRec;
  begin
    FindFirst(Path+'*.*', Directory, S);
    while DosError = 0 do begin
      if (S.Name[1] <> '.') and ((S.Attr and Directory) <> 0) then
        ProcessMask(Path+S.Name+'\'+FileMask, Path+S.Name+'\');
      FindNext(S);
    end;
  end { ScanSubdirectories };
  {$I+}

  procedure ProcessMask(Mask, LeadIn: string);
  begin
    DisplayDirectory(Mask, LeadIn);
    if SubDirs then ScanSubdirectories(LeadIn, JustFileName(Mask));
  end { ProcessMask };

  {$I-}
  procedure DisplayVolId(Drive: char);
    var V: SearchRec;
  begin
    FindFirst(Drive+':\*.*', VolumeId, V);
    while DosError = 0 do begin
      if (V.Attr and VolumeId) <> 0 then begin
        if Length(V.Name) > 8 then Delete(V.Name, 9, 1);
        WriteLine('Volume in drive '+Drive+': is '+V.Name);
        WriteLine('');
        Exit;
      end;
      FindNext(V);
    end;
    WriteLine('Volume in drive '+Drive+': has no label');
    WriteLine('');
  end { DisplayVolId };
  {$I+}

  procedure DisplayFreeBytes(Drive: char);
    var
      f: longint;
      s: string;
  begin
    f := longint(ClustersAvailable) *  BytesPerCluster;
    s := ' Volume in drive ' + Drive + ': cluster(s) ' +
         LeftPad(Long2Str(ClustersAvailable), 5) + '=' +
         LeftPad(Long2Str(f), 11) + ' byte(s) free';
    WriteLine(s);
    WriteLine('');
  end { DisplayFreeBytes };

  procedure ScanMasks;
    var
      i, j, p: word;
      Drive: char;
      SearchMask, LeadIn, s: string;
      bDisk, bMask: Boolean;
  begin
    for i := 1 to NMasks do begin
      Drive := Masks[i][1];
      if (i = 1) or (Drive <> Masks[i-1][1]) then begin
        bDisk := GetDiskInfo(Ord(Drive)-64,
                             ClustersAvailable, TotalClusters,
                             BytesPerSector, SectorsPerCluster);
        if bDisk then begin
          BytesPerCluster :=
            longint(BytesPerSector) * longint(SectorsPerCluster);
          DisplayVolId(Drive);
        end;
      end;
      if bDisk then begin
        s := FExpand(Masks[i]);
        bMask := ParsePath(s, SearchMask, LeadIn);
        if bMask then ProcessMask(SearchMask, LeadIn);
      end;
      if bDisk and ((i = NMasks) or (Drive <> Masks[i+1][1])) then
        DisplayFreeBytes(Drive);
    end;
  end { ScanMasks };

begin
  b := OpenStdDev(Out, StdOutHandle);
  ScanParms;
  ScanMasks;
  LastHelp;
  Close(Out);
end.



