{$A+,B-,E+,F-,I+,N-,O-,R-,V-}
{$UNDEF DEBUG}
{$IFDEF DEBUG} {$D+,L+,S+} {$ELSE} {$D-,L-,S-} {$ENDIF}
{$M 5096,25600,25600}
Program NGHelp;

Uses YNSystem,Help_Var,HelpStrt,NGCL,SwapVars,Swapopup;

Begin
 With Default Do
  Begin
   NGPath     := '';
   NGName     := '';
   AutoLookUp := True;
   BigScreen  := False;
   Color      := ColorMonitor;
  End;
 SearchStr := '';

 Read_CFG; {Read config}
 InitVars_NG;

 Writeln(Copyright);

{$IFNDEF TSR}
 KeyBoardTask;
{$ELSE}
 SwpPath := '';

 CheckParam;

 With TSRInfo Do
  Begin
   HotKey1       := LeftShift+$3B;
   HotKey2       := $4C;
   GraphicModeOn := False;
   IDStr         := Signature;
   SwapFileName  := SwpPath+'$NGHELP$.SWP';
   FirstToSave   := FirstToDisk;
   PRGStart      := @KeyBoardTask;
  End;

 CheckError(CheckTSRInstallData);
 GoTSR;
{$ENDIF}
End.
