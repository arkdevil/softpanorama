{To install this control in you VCL place it in your
 C:\DELPHI\LIB directory and from IDE Options Menu select
 Install Components. In the Install Components dialog
 box click Add Button, then in Add Module box type
 C:\DELPHI\LIB\DIALER.PAS, click OK, then in the Install
 Components Dialog box click OK again and wait a while.
 Dialer icon will appear in the Samples section of
 your Components Palette}

unit Dialer;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type

  TComPort = (dpCOM1,dpCOM2,dpCOM3,dpCOM4);
  TMethod  = (dmTone,dmPulse);

  TDialer = class(TComponent)
  private
    { Private declarations }
    FComPort : TComPort;
    FNumberToDial : string;
    FConfirm : boolean;
    FMethod : TMethod;
  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure Execute;
  published
    property ComPort : TComPort read FComPort
                 write FComPort;
    property Confirm : boolean read FConfirm
                 write FConfirm;
    property Method  : TMethod read FMethod
                 write FMethod;
    property NumberToDial : string read FNumberToDial
                 write FNumberToDial;
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TDialer]);
end;

procedure TDialer.Execute;
var
  s : string;
  CId : Integer;
  Status : Integer;
  Buf : array[1..32] of Char;
begin
  if FConfirm then
  begin
   if MessageDlg('About to dial the number '+FNumberToDial+'. Are you sure?',
      mtConfirmation, [mbYes,mbNo], 0)=mrNo then Exit;
  end;
  {Create a string to send to modem}
  s:=Concat('ATDT',FNumberToDial,^M^J);
  if FMethod=dmPulse then s[4]:='P';
  {Open Com Port}
  StrPCopy(@Buf,'COM ');
  Buf[4]:=Chr(49+Ord(FComPort));
  CId:=OpenComm(@Buf,512,512);
  if CId<0 then
  begin
    MessageDlg('Unable to open '+StrPas(@Buf),mtError,
                [mbOk], 0);
    Exit;
  end;
  {Send phone number to modem}
  StrPCopy(@Buf,s);
  Status:=WriteComm(CId,@Buf,StrLen(@Buf));
  if Status>=0 then
  begin
    MessageDlg('Pick up the phone',mtInformation,
                [mbOk], 0);
    WriteComm(CId,'ATH'^M^J,5);
  end
  else
    MessageDlg('Unable to dial number',mtError,
                [mbOk], 0);
  {Close communication port}
  CloseComm(CId);
end;

end.
