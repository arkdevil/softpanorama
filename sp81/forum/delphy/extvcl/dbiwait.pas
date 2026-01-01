unit DbiWait;

interface

uses
  StdCtrls, Gauges;

const
  DbiProgressLabel: TLabel = nil;
  DbiProgressBar: TGauge = nil;

procedure EnableDbiWait;
procedure DisableDbiWait;

implementation

uses
  DbiTypes, DbiProcs, WinTypes, WinProcs, Forms, DB,
  Controls, SysUtils;

const
  StartTime: Longint = 0;
  ServerTimer: Word = 0;
  DbiWaitEnabled: Boolean = False;
  ServerData: pCBPROGRESSDesc = nil;
  ExitProcAdded: Boolean = False;

var
  OldCallBack: TCallBack;

{ Timer callback function }

procedure TimerCallBack(hWnd: HWND; Message: Word; TimerID: Word;
  SysTime: LongInt); export;
begin
  KillTimer(0, TimerID);
  ServerTimer := 0;
  Screen.Cursor := crDefault;
  StartTime := 0;
  if DbiProgressBar <> nil then begin
    DbiProgressBar.Progress := 0;
    DbiProgressBar.Update;
  end;
  if DbiProgressLabel <> nil then begin
    DbiProgressLabel.Caption := '';
    DbiProgressLabel.Update;
  end;
end;

{ Server callback function }

function ServerCallBack(CallType: CBType; Data: Longint;
  var Info: Pointer): CBRType; export;
const
  MinWait = 300;
var
  CallInfo: pCBPROGRESSDesc;
begin
  Result := cbrUSEDEF;
  if CallType = cbGENPROGRESS then begin
    CallInfo := pCBPROGRESSDesc(@Info);
    if StartTime = 0 then begin
        ServerTimer := SetTimer(0, 0, 1000, @TimerCallBack);
        StartTime := GetTickCount;
      end
    else
     if (ServerTimer <> 0) and (GetTickCount - StartTime > MinWait) then
        Screen.Cursor := crSQLWait;
    if DbiProgressBar <> nil then
      if CallInfo^.iPercentDone >= 0 then begin
        DbiProgressBar.Progress := CallInfo^.iPercentDone;
        DbiProgressBar.Update;
      end;
    if DbiProgressLabel <> nil then begin
      DbiProgressLabel.Caption := StrPas(CallInfo^.szMsg);
      DbiProgressLabel.Update;
    end;
    with OldCallBack do
      if ChainedFunc <> nil then Result := pfDBICallBack(ChainedFunc)(cbGENPROGRESS, Data, Buffer)
  end;
end;

procedure DbiWaitExitProc; far;
begin
  DisableDbiWait;
end;

procedure EnableDbiWait;
begin
  if not DbiWaitEnabled then begin
    if ServerData = nil then ServerData := AllocMem(SizeOf(CBPROGRESSDesc));
    if not ExitProcAdded then AddExitProc(DbiWaitExitProc);
    DbiWaitEnabled := True;
    with OldCallBack do
      DbiGetCallBack(nil, cbGENPROGRESS, Data, BufLen, Buffer, @ChainedFunc);
    DbiRegisterCallBack(nil, cbGENPROGRESS, 0,
      SizeOf(CBPROGRESSDesc), ServerData, ServerCallBack);
  end;
end;

procedure DisableDbiWait;
begin
  if DbiWaitEnabled then begin
    DbiRegisterCallBack(nil, cbGENPROGRESS, 0,
      SizeOf(CBPROGRESSDesc), ServerData, nil);
    if ServerData <> nil then FreeMem(ServerData, SizeOf(CBPROGRESSDesc));
    if ServerTimer <> 0 then begin
      KillTimer(0, ServerTimer);
      ServerTimer := 0;
    end;
    DbiWaitEnabled := False;
  end;
end;

end.
