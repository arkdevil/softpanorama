{$B-,D-,F-,I-,R-,S-,V-}
unit CRC32;

{ This unit is to obtain CRC-32 check code as it is evaluated by
  PKZIP of PKWARE, Inc., and ARJ by Robert K Jung. }

interface

  procedure InitCRC(var CRC: longint);
  { Initialize CRC-32 before evaluation }

  procedure IncCRC(var Buff; Count: word; var CRC: longint);
  { Accumulate CRC-32 for Count bytes from buffer Buff }

  procedure FinishCRC(var CRC: longint);
  { Complete CRC-32 evaluation }

  function CRCFileB(FileName: string;
                    var Buff; BuffLen: word; var CRC: longint): word;
  { Evaluate CRC-32 of a given file through user-disposed buffer;
    returns 0 if file is OK, IOResult on file error, $FFFF on BuffLen = 0 }

  function CRCFile(FileName: string; var CRC: longint): word;
  { Evaluate CRC-32 of a given file using GetMem for buffer;
    returns 0 if file is OK, IOResult on file error }

implementation

  const Magicon: longint = $EDB88320; { Constant used to fill array Magic }

  var Magic: array[byte] of longint;  { Table used to translate bytes to
                                        CRC-32 increments }

  procedure InitCRC(var CRC: longint);
  { Initialize CRC-32 before evaluation }
  begin
    CRC := $FFFFFFFF;
  end { InitCRC };

  {$F+}

  procedure InitMagic; external;

  procedure IncCRC(var Buff; Count: word; var CRC: longint); external;
  { Accumulate CRC-32 for Count bytes from buffer Buff }

  {$F-}

  {$L CRC32.OBJ}

  procedure FinishCRC(var CRC: longint);
  { Complete CRC-32 evaluation }
  begin
    CRC := not CRC;
  end { FinishCRC };

  function CRCFileB(FileName: string;
                    var Buff; BuffLen: word; var CRC: longint): word;
  { Evaluate CRC-32 of a given file through user-disposed buffer;
    returns 0 if file is OK, IOResult on file error, $FFFF on BuffLen = 0 }
    var
      Rest: longint;
      Portion, IOError, SaveFileMode: word;
      Fi: file;
  begin
    if BuffLen = 0 then begin
      CRC := 0; CRCFileB := $FFFF; Exit;
    end;
    SaveFileMode := FileMode;
    FileMode := 0;
    Assign(Fi, FileName);
    Reset(Fi, 1);
    IOError := IOResult;
    if IOError <> 0 then begin
      CRC := 0; CRCFileB := IOError; Exit;
    end;
    InitCRC(CRC);
    Rest := FileSize(Fi);
    IOError := IOResult;
    if IOError <> 0 then begin
      CRC := 0; CRCFileB := IOError; Close(Fi); Exit;
    end;
    while Rest > 0 do begin
      Portion := BuffLen;
      if Portion > Rest then Portion := Rest;
      BlockRead(Fi, Buff, Portion);
      IOError := IOResult;
      if IOError <> 0 then begin
        CRC := 0; CRCFileB := IOError; Close(Fi); Exit;
      end;
      IncCRC(Buff, Portion, CRC);
      Dec(Rest, Portion)
    end;
    Close(Fi);
    FileMode := SaveFileMode;
    FinishCRC(CRC);
    CRCFileB := 0;
  end { CRCFileB };

  function CRCFile(FileName: string; var CRC: longint): word;
  { Evaluate CRC-32 of a given file using GetMem for buffer;
    returns 0 if file is OK, IOResult on file error }
    const MaxBuffLen = 65520;
    var pBuff: ^char;
  begin
    GetMem(pBuff, MaxBuffLen);
    CRCFile := CRCFileB(FileName, pBuff^, MaxBuffLen, CRC);
    FreeMem(pBuff, MaxBuffLen)
  end { CRCFile };

begin
  InitMagic;
end.


