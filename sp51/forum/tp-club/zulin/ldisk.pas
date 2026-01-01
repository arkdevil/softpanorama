program LockDisks;
uses Dos, DskTools;
type   LCommandT = (Look, Lock, Unlock);
const  LCommand : LCommandT = Look;
var i : byte;
    s : string;
begin
  WriteLn('Lock Disks, version 1.00, (C) BZSoft Inc. 1992');
  if ParamCount=0 Then 
     begin WriteLn('Usage   : LDisk DisksList [/L|/U]'); 
           WriteLn('Example : LDisk ABCDE     - get status of disks');
           WriteLn('          LDisk E /L      - disable disk E:');
           WriteLn('          LDisl E /U      - enable disabled disk E:');
     Halt(1) end;
  s := '';
  for i := 1 to ParamCount do s := s+ParamStr(i);
  for i:=1 to Length(s) do 
      if s[i] in ['a'..'z'] Then s[i]:=char(byte(s[i]) and $5F);
  if Pos('/U',s)>0 Then 
     begin LCommand:=Unlock; Delete(s,Pos('/U',s),2) end else
  if Pos('/L',s)>0 Then
     begin LCommand:=Lock; ; Delete(s,Pos('/L',s),2) end;
  for i := Length(s) downto 1 do
      if not (s[i] in ['A'..'Z']) Then Delete(s,i,1);
  for i := Length(s) downto 1 do
      if pos(s[i],s)<>i Then Delete(s,i,1);
  for i:=1 to Length(S) do begin
     case LCommand of
     Look   : begin Write('Disk ',s[i],': '); if AvailableDisk(s[i]) Then
                    writeLn('enabled') else WriteLn('disabled') end;
     Lock   : begin if s[i]<=LastDriveChar Then DisableDrive(s[i]) end;
     Unlock : begin if s[i]<=LastDriveChar Then EnableDrive(s[i]) end;
    end {case}
  end
end.
