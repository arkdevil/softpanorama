unit WinLan;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  EWinLan = class(Exception);  { exception used in TWinLan }

  TWinLan = class(TComponent)
  private
    { Private declarations }
    FMachineName,
    FUserName:String;
    Procedure RaiseError(Error:Word);
    Function GetWorkStationInfo(GetType:Word):String;
  protected
    { Protected declarations }
    Function GetMachineName:String;
    Function GetUserName:String;
  public
    { Public declarations }
    Function FindDisk:String;
    Function FindPrinter:String;
    Procedure ConnectDisk;
    Procedure ConnectPrinter;
    Procedure DisconnectDisk;
    Procedure DisconnectPrinter;
    Function FindMachine:String;
    Procedure ChangePassword;
    Function AutoLogon:Boolean;
    Function Logoff:Boolean;
    Function AddConnection(Const NetPath,Password,LocalName:String):Boolean;
    Function CancelConnection(Const LocalName:String; ForceIfOpenFiles:Boolean):Boolean;
  published
    { Published declarations }
    property MachineName:String read GetMachineName;
    property UserName:String read GetUserName;
  end;

procedure Register;

implementation

Const WNBD_CONN_UNKNOWN       =0;
      WNBD_CONN_DISKTREE      =1;
      WNBD_CONN_PRINTQ        =3;
      WNBD_MAX_LENGTH         =$80;
      NERR_SUCCESS  =0;

      WKSTAINFO_COMPUTER = 0;
      WKSTAINFO_USER     = 1;

Function WNetGetCaps(w:Word):THandle; far; external 'USER';
Function WNetBrowseDialog(hwndParent:HWnd; nType:Word; szPath:PChar):Word; far;
         external 'WFWNET.DRV';
Function WNetConnectDialog(hwndOwner:Hwnd; iType:Word):Word; far;
         external 'WFWNET.DRV';
Function WNetDisconnectDialog(hwndOwner:Hwnd; iType:Word):Word; far;
         external 'WFWNET.DRV';
Function WNetServerBrowseDialog(hwndParent:HWnd; lpszSectionName, lpszBuffer:PChar; cbBuffer:Word; flFlags:Longint):Word; far;
         external 'WFWNET.DRV';
Procedure I_ChangeCachePassword(hwndOwner:HWnd); far; external 'WFWNET.DRV';
Procedure I_ChangePassword(hwndOwner:HWnd); far; external 'WFWNET.DRV';
Function I_AutoLogon(hwndOwner:HWnd; lpszReserved:PChar; fPrompt:Bool; pfLoggedOn:PBool):Bool; far;
         external 'WFWNET.DRV';
Function I_Logoff(hwndOwner:HWnd; lpszReserved:PChar):Bool; far;
         external 'WFWNET.DRV';
Function NetWkstaGetInfo( pszServer:PChar;
                          sLevel:Integer;
                          pbBuffer:PChar;
                          cbBuffer:Word;
                          pcbTotalAvail:PWord):Word; far; external 'NETAPI';
Function WNetGetErrorText(nError:Word;  lpszText:Pchar; cbText:Word):Word; far;
         external 'WFWNET.DRV';

Type TString=Array[0..255] of Char;
     PWksta_info_0=^TWksta_info_0;
     Twksta_info_0=Record
        wki0_reserved_1:Word;	{ reserved; must be zero }
        wki0_reserved_2:Longint;	{ reserved; must be zero }
        wki0_root:PChar;	{ path to network directory }
        wki0_computername:PChar;	{ name of computer }
        wki0_username:PChar;	{ name of user logged on }
        wki0_langroup:PChar;	{ name of workgroup }
        wki0_ver_major:Byte;	{ major version number }
        wki0_ver_minor:Byte;	{ minor version number }
        wki0_reserved_3:Longint;	{ reserved; must be zero }
        wki0_charwait:Word;	{ reserved; must be zero }
        wki0_chartime:Longint;	{ reserved; must be zero }
        wki0_charcount:Word;	{ reserved; must be zero }
        wki0_reserved_4:Word;	{ reserved; must be zero }
        wki0_reserved_5:Word;	{ reserved; must be zero }
        wki0_keepconn:Word;	{ maximum time to keep inactive connection }
        wki0_keepsearch:Word;	{ maximum time to keep inactive search }
        wki0_maxthreads:Word;	{ reserved; must be zero }
        wki0_maxcmds:Word;	{ maximum simultaneous network connections }
        wki0_reserved_6:Word;	{ reserved; must be zero }
        wki0_numworkbuf:Word;	{ internal work buffers }
        wki0_sizworkbuf:Word;	{ size of work buffer, in bytes }
        wki0_maxwrkcache:Word;	{ reserved; must be zero }
        wki0_sesstimeout:Word;	{ reserved; must be zero }
        wki0_sizerror:Word;	{ reserved }
        wki0_numalerts:Word;	{ reserved }
        wki0_numservices:Word;	{ reserved }
        wki0_errlogsz:Word;	{ reserved }
        wki0_printbuftime:Word;	{ reserved }
        wki0_numcharbuf:Word;	{ reserved }
        wki0_sizcharbuf:Word;	{ reserved }
        wki0_logon_server:PChar;	{ reserved }
        wki0_wrkheuristics:PChar;	{ reserved }
        wki0_mailslots:Word;	{ mailslot flag }
     End;
     PWksta_info_1=^TWksta_info_1;
     Twksta_info_1=Record
        wki1_reserved_1:Word;	{ reserved; must be zero }
        wki1_reserved_2:Longint;	{ reserved; must be zero }
        wki1_root:PChar;	{ path to network directory }
        wki1_computername:PChar;	{ name of computer }
        wki1_username:PChar;	{ name of user logged on }
        wki1_langroup:PChar;	{ name of workgroup }
        wki1_ver_major:Byte;	{ major version number }
        wki1_ver_minor:Byte;	{ minor version number }
        wki1_reserved_3:Longint;	{ reserved; must be zero }
        wki1_charwait:Word;	{ reserved; must be zero }
        wki1_chartime:Longint;	{ reserved; must be zero }
        wki1_charcount:Word;	{ reserved; must be zero }
        wki1_reserved_4:Word;	{ reserved; must be zero }
        wki1_reserved_5:Word;	{ reserved; must be zero }
        wki1_keepconn:Word;	{ maximum time to keep inactive connection }
        wki1_keepsearch:Word;	{ maximum time to keep inactive search }
        wki1_maxthreads:Word;	{ reserved; must be zero }
        wki1_maxcmds:Word;	{ maximum simultaneous network connections }
        wki1_reserved_6:Word;	{ reserved; must be zero }
        wki1_numworkbuf:Word;	{ internal work buffers }
        wki1_sizworkbuf:Word;	{ size of work buffer, in bytes }
        wki1_maxwrkcache:Word;	{ reserved; must be zero }
        wki1_sesstimeout:Word;	{ reserved; must be zero }
        wki1_sizerror:Word;	{ reserved }
        wki1_numalerts:Word;	{ reserved }
        wki1_numservices:Word;	{ reserved }
        wki1_errlogsz:Word;	{ reserved }
        wki1_printbuftime:Word;	{ reserved }
        wki1_numcharbuf:Word;	{ reserved }
        wki1_sizcharbuf:Word;	{ reserved }
        wki1_logon_server:PChar;	{ reserved }
        wki1_wrkheuristics:PChar;	{ reserved }
        wki1_mailslots:Word;	{ mailslot flag }
        wki1_logon_domain:PChar;	{ name of logon workgroup }
        wki1_oth_domains:Word;	{ reserved }
        wki1_numdgrambuf:Word;	{ reserved }
     End;
     PWkSta_info_10=^TWkSta_info_10;
     Twksta_info_10=Record
        wki10_computername:PChar;	{ name of computer }
        wki10_username:PChar;	{ name of logged on user}
        wki10_langroup:PChar;	{ name of workgroup}
        wki10_ver_major:Byte;	{ major version number}
        wki10_ver_minor:Byte;	{ minor version number }
        wki10_logon_domain:PChar;	{ name of logon workgroup}
        wki10_oth_domains:PChar;	{ reserved; must be zero  }
     End;

Function TWinLan.FindDisk:String;
Var St:TString;
    Res:Word;
Begin
  result:='';
  Res:=WNetBrowseDialog(0,WNBD_CONN_DISKTREE,St);
  if Res=NERR_SUCCESS then result:=StrPas(St)
                      else if Res<>12 then RaiseError(Res);
End;

Function TWinLan.FindPrinter:String;
Var St:TString;
    Res:Word;
Begin
  result:='';
  Res:=WNetBrowseDialog(0,WNBD_CONN_PRINTQ,St);
  if Res=NERR_SUCCESS then result:=StrPas(St)
                      else if Res<>12 then RaiseError(Res);
End;

Procedure TWinLan.ConnectDisk;
Begin
  WNetConnectDialog(0,WNBD_CONN_DISKTREE);
End;

Procedure TWinLan.ConnectPrinter;
Begin
  WNetConnectDialog(0,WNBD_CONN_PRINTQ);
End;

Procedure TWinLan.DisconnectDisk;
Begin
  WNetDisconnectDialog(0,WNBD_CONN_DISKTREE);
End;

Procedure TWinLan.DisconnectPrinter;
Begin
  WNetDisconnectDialog(0,WNBD_CONN_PRINTQ);
End;

Function TWinLan.FindMachine:String;
Var St:TString;
    Res:Word;
Begin
  Result:='';
  Res:=WNetServerBrowseDialog(0,nil,St,Sizeof(St),0);
  if Res=NERR_SUCCESS then result:=StrPas(St)
                      else if Res<>12 then RaiseError(Res);
End;

Procedure TWinLan.ChangePassword;
Begin
  I_ChangeCachePassword(0);
End;

Function TWinLan.AutoLogon:Boolean;
Var WasLogged:PBool;
Begin
  I_AutoLogon(0,nil,True,@WasLogged);
  result:=WasLogged^;
End;

Function TWinLan.Logoff:Boolean;
Begin
  result:=I_Logoff(0,nil);
End;

Function TWinLan.GetWorkStationInfo(GetType:Word):String;
Const Size=60000;
Var TotalSize,Res:Word;
    Pw:PChar;
Begin
  GetMem(pw,Size);
  Res:=NetWkstaGetInfo(nil,10,pw,Size,@TotalSize);
  try
    if Res=NERR_SUCCESS Then
    Begin
      Case GetType of
         WKSTAINFO_COMPUTER: Result:=StrPas(PWksta_info_10(PW)^.wki10_ComputerName);
         WKSTAINFO_USER    : Result:=StrPas(PWksta_info_10(PW)^.wki10_UserName);
      else
         Raise EWinLan.Create('Not available Workstation information.');
      End;
    End
    else RaiseError(Res);
  finally
    FreeMem(pw,Size);
  end;
End;

Function TWinLan.GetMachineName:String;
Begin
  result:=GetWorkStationInfo(WKSTAINFO_COMPUTER);
End;

Function TWinLan.GetUserName:String;
Begin
  result:=GetWorkStationInfo(WKSTAINFO_USER);
End;

Function TWinLan.AddConnection(Const NetPath,Password,LocalName:String):Boolean;
Var S1,S2,S3:TString;
    Res:Word;
Begin
  Result:=False;
  Res:=WNetAddConnection( StrPcopy(S1,NetPath),
                          StrPCopy(S2,Password),
                          StrPCopy(S3,LocalName));
  if Res=NERR_SUCCESS then result:=True else RaiseError(Res);
End;

Function TWinLan.CancelConnection(Const LocalName:String; ForceIfOpenFiles:Boolean):Boolean;
Var S1:TString;
    Res:Word;
Begin
  Result:=False;
  Res:=WNetCancelConnection(StrPcopy(S1,LocalName),ForceIfOpenFiles);
  if Res=NERR_SUCCESS then result:=True else RaiseError(Res);
End;

Procedure TWinLan.RaiseError(Error:Word);
Var SError:TString;
    StError:String;
Begin
  if WNetGetErrorText(Error,SError,SizeOf(SError))=0 then
     StError:=StrPas(SError)
  else
     StError:='WinLan error: '+IntToStr(Error);
  Raise EWinLan.Create(StError);
End;

procedure Register;
begin
  RegisterComponents('Samples', [TWinLan]);
end;

end.
