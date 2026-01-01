{$A+,B-,E+,F-,I+,N-,O-,R-,V-}
{$DEFINE DEBUG}
{$IFDEF DEBUG} {$D+,L+,S+} {$ELSE} {$D-,L-,S-} {$ENDIF}
Unit HelpStrt;

Interface

Uses YNSystem,YNCrt,NG,Window,StrInt,Help_Var,NGCL,SwapVars;


Procedure KeyBoardTask;
Procedure CheckParam;
Procedure CheckError(Error : TSRError);


Implementation


Procedure KeyBoardTask;
Label TheEnd;
Var K : Word;
Begin
 SaveAll;

 if (Lo(LastMode) In [CO40,BW40]) then
  Begin
   Sound(1000);
   Delay(200);
   NoSound;
   Goto TheEnd;
  End;

{$IFDEF TSR}
 StartNG;
{$ELSE}
 StartNG;
{$ENDIF}

TheEnd:
 RestoreAll;
End;


Procedure CheckParam;
Var Loop   : Byte;
    P      : String[80];
    Num    : Word;
    PError : Pointer;
    Error  : Word Absolute PError;
Begin
 FirstToDisk := KeepInMemory(0); { Default 0 kb in memory }

 For Loop := 1 to ParamCount Do
  Begin
   P := UpStr(ParamStr(Loop));
   if (P='/?') Or (P='/H') then
    Begin
     Writeln;
     Writeln('/? /H  Displays this help messages');
     Writeln('/1   Leave only small portion resident');
     Writeln('/2   Swap heap to disk');
     Writeln('/3   Don''t swap anything to disk');
     Writeln('/Mxx Keep xx kb in memory');
     Writeln('/D   Alternatief path for swap files');
     Writeln('/U   Remove HELP from memory');
     Halt;
    End;

   if P='/1' then FirstToDisk := FirstToSwap;
   if P='/2' then FirstToDisk := HeapOrg;
   if P='/3' then FirstToDisk := TopOfProgram;
   if P='/U' then
    Begin
     PError := CALLTSR(Signature,ReleaseTSR);
     if Error<>0 then Writeln(HelpName+': Couldn''t remove from memory')
      Else Writeln(HelpName+': Succesfully removed from memory');
     Halt;
    End;

   if Copy(P,1,2)='/M' then
    Begin
     Val(Copy(P,3,4),Num,Error);
     if Error=0 then
      Begin
       FirstToDisk := KeepInMemory(Num);
      End;
    End;
   if Copy(P,1,2)='/D' then
    Begin
     SwpPath := Copy(P,3,255);
     if (Length(SwpPath)>3) And (SwpPath[Length(SwpPath)]<>'\') then
      SwpPath := SwpPath + '\';
    End;
  End;
End;

Procedure CheckError(Error : TSRError);
Begin
 Case Error of
  DiskSpaceShortage : Writeln('Not enough disk space');
  Installed         : Writeln(HelpName+' is allready installed');
  Ok                : Begin
                       HotKeys;
                       Exit;
                      End;
 End;

 Halt(1);
End;



End.