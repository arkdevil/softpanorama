 program Branch_Info;
{─────────────────────────────────────┐
│  Program gives summary information  │
│ of size of current 'branch' of di-  │
│ rectory tree.                       │
│  Norton Integrator 4.50's File Size │
│ (FS) must be accessible.            │
└─────────────────────────────────────}
 uses
   TPstring,
   TPDate;

 var
   S : string;
   BytesNumber,
   FilesNumber,
   BytesOnDisk : longint;
   CountDone : Boolean;
   i : byte;
   WA : array [1..5] of string [20];

 function GetPointChar : char;
 {---------------------------------------------}
 {  Get CommaSym from Dos country information. }
 {---------------------------------------------}
  var
    CInf : CountryInfo;
    IsDos2 : Boolean;
  begin
    if not GetCountryInfo (IsDos2, CInf)
      then GetPointChar := ','
      else if IsDos2
             then GetPointChar := CInf.CommaSym1
             else GetPointChar := CInf.CommaSym2;
  end; {GetPointChar}

 function DelPoints2Long (S : string) : longint;
 {-------------------------------------------}
 {  Deletes decimal points from input string }
 { and converts it to longint.               }
 {-------------------------------------------}
  var
    i  : byte;
    WS : string;
    WL : longint;
  begin
    WS := S;
    i := 1;
    while i <= Length(WS) do  if WS[i] = GetPointChar then Delete(WS, i, 1)
                                                      else Inc(i);
    if Str2Long(WS, WL) then DelPoints2Long := WL
                        else DelPoints2Long := 0;
  end; {DelPoints2Long}

 function InsPoints2Str (L : longint) : string;
 {-------------------------------------------}
 {  Inserts decimal points in input longint  }
 { and converts it to string.                }
 {-------------------------------------------}
  var
    n,i,sl : byte;
    WS : string;
  begin
    WS := Long2Str(L);
    sl := Length(WS);
    n := sl div 3;
    if (sl mod 3) = 0 then Dec(n);
    i := 1;
    while i <= n do
     begin
      Insert(GetPointChar, WS, sl+1-3*i);
      Inc(i);
     end;
    InsPoints2Str := WS;
  end; {InsPoints2Str}

 begin
   BytesNumber := 0;
   FilesNumber := 0;
   BytesOnDisk := 0;
   CountDone := False;
   repeat
     ReadLn (S);
     if (Trim(S) = 'Total of all files found') or (Trim(S) = 'Drive usage')
       then CountDone := True
       else if WordCount(S, [' ']) >= 5 then
              begin
                for i:=1 to 5 do WA[i] := ExtractWord(i, S, [' ']);
                if (WA[2]+' '+WA[3]+' '+WA[4]) = 'total bytes in' then
                  begin
                    BytesNumber := BytesNumber + DelPoints2Long(WA[1]);
                    FilesNumber := FilesNumber + DelPoints2Long(WA[5]);
                    ReadLn (S);
                    BytesOnDisk := BytesOnDisk + DelPoints2Long(ExtractWord(1, S, [' ']));
                  end;
              end;
   until CountDone;
   if BytesOnDisk <> 0 then i := (100 * (BytesOnDisk - BytesNumber)) div BytesOnDisk
                       else i := 0;
   WriteLn ('						(c) BIP, Tbilisi, 1991');
   WriteLn;
   WriteLn ('Summary information of size of given [ current ] ''branch'' of directory tree :');
   WriteLn;
   WriteLn ('     ',InsPoints2Str(BytesNumber),' total bytes in current directory & subdirs (',FilesNumber,' files).');
   WriteLn ('     ',InsPoints2Str(BytesOnDisk),' bytes disk space occupied, ',i,'% slack.');
   for BytesOnDisk := 1 to 4000 do  { Delay }
     S := Long2Str(BytesOnDisk)     {  !!!  }
 end.
