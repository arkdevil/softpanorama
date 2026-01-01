(****************************************************************)
(*                     DATABASE TOOLBOX 4.0                     *)
(*     Copyright (c) 1984, 87 by Borland International, Inc.    *)
(*                                                              *)
(*                Turbo Access High Level Unit                  *)
(*                                                              *)
(*  Purpose: Toolbox of high-level Turbo Access routines that   *)
(*           simplify programming databases that are made up    *)
(*           of one data file and one index file.               *)
(*                                                              *)
(*           Requires the Turbo Access Unit (TAccess.pas)       *)
(*                                                              *)
(****************************************************************)
unit TAHigh;
interface
uses DOS, CRT, TAccess;

const
  ExactMatch    = true;
  PartialMatch  = false;

type
  DataSet = record
               Data : DataFile;
               Index : IndexFile;
            end;
var
  TARecNum : LongInt;
{  Number of the last accessed record in the database.  You can
   use this variable to build upon the high level calls, say by
   adding a second index file. }

procedure TAClose(var DatSet : DataSet);

procedure TACreate(var DatSet : DataSet;
                   DatFName : FileName; RecordLen : word;
                   IndexFName : FileName; KeyLen : byte);

procedure TADelete(var DatSet : DataSet; var Key);

procedure TAErase(var DatSet : DataSet);

procedure TAFlush(var DatSet : DataSet);

procedure TAInsert(var DatSet : DataSet; var CurRec, Key);

procedure TANext(var DatSet : DataSet; var CurRec, Key);

procedure TAOpen(var DatSet : DataSet;
                 DatFName : FileName; RecordLen : word;
                 IndexFName : FileName; KeyLen : byte);

procedure TAPrev(var DatSet : DataSet; var CurRec, Key);

procedure TARead(var DatSet : DataSet; var CurRec, Key ;
                 FindExact : boolean);

procedure TAReset(var DatSet : DataSet);

procedure TAUpdate(var DatSet : DataSet; var CurRec, Key);

procedure TAWrite(var DatSet : DataSet; var CurRec, Key);


implementation

procedure TAClose(var DatSet : DataSet);
begin
  {$IFDEF TADebug}
    TADebugIn('TAClose');
  {$ENDIF}
  with DatSet do
  begin
    CloseIndex(Index);
    CloseFile(Data);
  end;
  {$IFDEF TADebug}
    TADebugOut;
  {$ENDIF}
end; { TAClose }

procedure TACreate(var DatSet : DataSet;
                   DatFName : FileName; RecordLen : word;
                   IndexFName : FileName; KeyLen : byte);
begin
  {$IFDEF TADebug}
    TADebugIn('TACreate');
  {$ENDIF}
  FillChar(DatSet, SizeOf(DatSet), 0);
  with DatSet do
  begin
    MakeFile(Data, DatFName, RecordLen);
    MakeIndex(Index, IndexFName, KeyLen, 0);
  end;
  {$IFDEF TADebug}
    TADebugOut;
  {$ENDIF}
end; { TACreate }

procedure TADelete(var DatSet : DataSet; var Key);
var
  temp : String;
  K : string absolute Key;

begin
  {$IFDEF TADebug}
    TADebugIn('TADelete');
  {$ENDIF}
  temp := K;
  with DatSet do
  begin
    FindKey(Index, TARecNum, temp);
    if Ok then
    begin
      DeleteRec(Data, TARecNum);
      DeleteKey(Index, TARecNum, Key);
    end;
  end;
  {$IFDEF TADebug}
    TADebugOut;
  {$ENDIF}
end; { TADelete }

procedure TAErase(var DatSet : DataSet);
begin
  {$IFDEF TADebug}
    TADebugIn('TAErase');
  {$ENDIF}
  with DatSet do
  begin
    EraseIndex(Index);
    EraseFile(Data);
  end;
  {$IFDEF TADebug}
    TADebugOut;
  {$ENDIF}
end; { TAErase }

procedure TAFlush(var DatSet : DataSet);
begin
   {$IFDEF TADebug}
    TADebugIn('TAFlush');
  {$ENDIF}
  with DatSet do
  begin
    FlushFile(Data);
    FlushIndex(Index);
  end;
  {$IFDEF TADebug}
    TADebugOut;
  {$ENDIF}
end; { TAFlush }

procedure TAInsert(var DatSet : DataSet; var CurRec, Key);
var
  temp : String;
  K : string absolute Key;
begin
  {$IFDEF TADebug}
    TADebugIn('TAInsert');
  {$ENDIF}
  temp := K;
  with DatSet do
  begin
    FindKey(Index, TaRecNum, temp);
    Ok := not Ok;
    if not Ok then
      Exit;
    AddRec(Data, TARecNum, CurRec);
    AddKey(Index, TARecNum, Key);
  end;
  {$IFDEF TADebug}
    TADebugOut;
  {$ENDIF}
end; { TAInsert }

procedure TANext(var DatSet : DataSet; var CurRec, Key);
begin
  {$IFDEF TADebug}
    TADebugIn('TANext');
  {$ENDIF}
  with DatSet do
  begin
    NextKey(Index, TARecNum, Key);
    if Ok then
      GetRec(Data, TARecNum, CurRec);
  end;
  {$IFDEF TADebug}
    TADebugOut;
  {$ENDIF}
end; { TANext }

procedure TAOpen(var DatSet : DataSet;
                 DatFName : FileName; RecordLen : word;
                 IndexFName : FileName; KeyLen : byte);
begin
  {$IFDEF TADebug}
    TADebugIn('TAOpen');
  {$ENDIF}
  FillChar(DatSet, SizeOf(DatSet), 0);
  with DatSet do
  begin
    OpenFile(Data, DatFName, RecordLen);
    if Ok then
      OpenIndex(Index, IndexFName, KeyLen, 0);
  end;
  {$IFDEF TADebug}
    TADebugOut;
  {$ENDIF}
end; { TAOpen }

procedure TAPrev(var DatSet : DataSet; var CurRec, Key);
begin
  {$IFDEF TADebug}
    TADebugIn('TAPrev');
  {$ENDIF}
  with DatSet do
  begin
    PrevKey(Index, TARecNum, Key);
    if Ok then
      GetRec(Data, TARecNum, CurRec);
  end;
  {$IFDEF TADebug}
    TADebugOut;
  {$ENDIF}
end; { TAPrev }

procedure TARead(var DatSet : DataSet; var CurRec, Key;
                 FindExact : boolean);
var
  S : String;
  K : String absolute Key;
begin
  {$IFDEF TADebug}
    TADebugIn('TARead');
  {$ENDIF}
  with DatSet do
  begin
    if FindExact then
      FindKey(Index, TARecNum, Key)
    else
    begin
      S := K;
      SearchKey(Index, TARecNum, Key);
      if Ok then
        Ok := Pos(S, K) > 0;
    end;
    if Ok then
      GetRec(Data, TARecNum, CurRec);
  end;
  {$IFDEF TADebug}
    TADebugOut;
  {$ENDIF}
end; { TARead }

procedure TAReset(var DatSet : DataSet);
begin
  with DatSet do
    ClearKey(Index);
end; { TAReset }

procedure TAUpdate(var DatSet : DataSet; var CurRec, Key);
begin
  {$IFDEF TADebug}
    TADebugIn('TAUpdate');
  {$ENDIF}
  with DatSet do
  begin
    FindKey(Index, TARecNum, Key);
    if Ok then
      PutRec(Data, TARecNum, CurRec);
  end;
  {$IFDEF TADebug}
    TADebugOut;
  {$ENDIF}
end; { TAUpdate }

procedure TAWrite(var DatSet : DataSet; var CurRec, Key);
begin
  {$IFDEF TADebug}
    TADebugIn('TAWrite');
  {$ENDIF}
  with DatSet do
  begin
    TAInsert(DatSet, CurRec, Key);
    if not Ok then
      TAUpdate(DatSet, CurRec, Key);
  end;
  {$IFDEF TADebug}
    TADebugOut;
  {$ENDIF}
end; { TAWrite }

end. { TAHigh.unit }
