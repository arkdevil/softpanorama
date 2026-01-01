{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,R-,S+,V+,X-}
{$M 8192,0,0}
program DiskType;
{
    ┌──────────────────────────────────────────────────────────┐
    │                                                           █
    │                  DiskType (FREEWARE)                      █
    │  Demonstration program to DSKTOOLS.TPU and DRVTOOLS.TPU   █
    │             (C) BZSoft Inc., august-1992.                 █
    │             (C) GalaSoft United Group International.      █
    │                      version 3.03                         █
    │                                                           █
    └─▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
}
uses
      BZTools,
     DskTools,
     DrvTools,
     Dos,
     TpDos,
     TPDate,
     TPCrt;

var i : byte;
    Help,Full,Jour : boolean;
    w : word;
    s : string;
    x : boolean;

procedure WriteDisksType;
VAR j,k : byte;
    b   : boolean;
procedure WriteName(name:string);
begin
  Write(name);
  W:=GetVolumeLabel(DiskNameArray[i],s);
  if (w=0) and (s<>'') Then
     begin
       Write(' (volume label ');
       TextColor(15);
       Write(s);
       TextColor(11);
       WriteLn(')')
     end
  else WriteLn
end;

procedure WriteFL(Disk : char);
var
    t : IOCTLDriveType;
begin
  t := GetIOCTLDriveType(Disk);
  case t of
   F360k         : Write('Floppy 360k');
   F1M2          : Write('Floppy 1.2M');
   F720k         : Write('Floppy 720k');
   F_SD8i        : Write('Floppy SD 8"');
   F_DD8i        : Write('Floppy DD 8"');
   FixedDisk     : Write('Fixed Disk');
   TapeDrv       : Write('Tape');
   F1M44         : Write('Floppy 1.44M');
   Optical_RW    : Write('Optical disk');
   F2M88         : Write('Floppy 2.88M');
   else            Write('Unknown');
  end; {case}
  if PhantomDisk(disk) Then WriteLn(' (phantom)') else WriteLn
end;

begin
TextColor(14);
WriteLn(^M^J'  DiskType version 3.03 (FREEWARE).');
WriteLn('  DskTools and DrvTools units demo.');
WriteLn('  (R) BZSoft Inc. 1992, (R) GalaSoft Units Group Intl. 1992'^M^J);
TextColor(10);
WriteLn('   Call DISKTYPE /? for HELP'^M^J); TextColor(11);
Write('   Number of Hard disks - '); TextColor(14); WriteLn(NumHardDisk);          TextColor(11);
Write('   Number of all disks  - '); TextColor(14); WriteLn(NumDrive);             TextColor(11);
Write('   Lastdrive            - '); TextColor(14); WriteLn(LastDriveChar,':');    TextColor(11);
Write('   Current drive        - '); TextColor(14); WriteLn(CurrentDriveChar,':'); TextColor(11);
i:=BootDisk; if (i>0) and (i<26) Then
Write('   Boot drive           - '); TextColor(14); WriteLn(chr(i+$40)+':'); TextColor(11);
Write('   Current DOS          - '); TextColor(14);
case Current_OS of
     _MSDOS      : begin Write('MS-DOS');
                   if DOS_Version=$31F Then Write(' (or compatible)');
                   end;
     _DRDOS      : Write('DR-DOS');
     _OS2        : Write('OS/2');
end; {case} 
WriteLn(' version ',Hi(OS_Version),'.',Lo(OS_Version));
w:=_4DOSInstalled; TextColor(11);
if w<>0 Then begin
   Write('   Command processor    - '); TextColor(14);
   WriteLn('4DOS version ',Hi(w),'.',Lo(w)); TextColor(11);
   end;
w:=_NDOSInstalled;
if w<>0 Then begin
   Write('   Command processor    - '); TextColor(14);
   WriteLn('NDOS version ',Hi(w),'.',Lo(w)); TextColor(11);
   end;
GetAppendStr(S);
if s<>'' Then begin
   Write('   APPEND set           - ');
   TextColor(14);WriteLn(s);TextColor(11);
   end;
if Drv800Installed Then WriteLn('   Driver 800 II installed');
if CacheActive Then WriteLn('   Cache driver  installed');
if F_DefenderInstalled Then WriteLn('   F_Defender    installed');
if NumDrive>0 Then
   For i:=1 to NumDrive do
       begin
         TextColor(14);
         Write('   ',DiskNameArray[i],':  -  ');
         TextColor(11);
         case DiskTypeArray[i] of
           Floppy           : WriteFL(DiskNameArray[i]);
           HD0              : WriteName('Part of Hard disk 0');
           HD1              : WriteName('Part of Hard disk 1');
           Encrypted        : WriteLn('Encrypted disk');
           VDisk            : WriteName('Disk in RAM (,XMS,EMS)');
           DeviceDriven     : WriteName('Device Driven');
           BernoulliDisk    : WriteName('Bernoulli disk');
           SubstitutedDisk  : WriteLn('SUBSTituted disk (',
                              SubstitutedTo(DiskNameArray[i]),')');
           EgaDisk          : WriteName('Disk in video memory');
           AssignedDisk     : begin
                              Write('ASSIGNed disk (to ',
                              AssignToChar[byte(DiskNameArray[i])-$40]);
              case AssignToType[byte(DiskNameArray[i])-$40] of
                Floppy           : WriteLn(': Floppy)');
                HD0              : WriteLn(': Hard disk 0)');
                HD1              : WriteLn(': Hard disk 1)');
                EgaDisk          : WriteLn(': EGA/VGA disk)');
                VDisk            : WriteLn(': Virtual disk)');
                Encrypted        : WriteLn(': Encrypted disk)');
                BernoulliDisk    : WriteLn(': Bernoulli disk)');
                DeviceDriven     : WriteLn(': Device Driven)');
                NetWorkDisk      : WriteLn(': Network disk)');
                            else   WriteLn(':)');
              end {case}
                              end;
           NetWorkDisk      : WriteLn('Network disk');
           else           WriteLn('Unknown');
         end {case}
       end;
 k := LastDrive; x :=false;
 for j := 1 to k do if GetJoinPath(chr(j+$40))<>'' Then x:=true;
 if x Then begin
 TextColor(9);
 WriteLn('   ------------------------------------------------------------');
 for j:=1 to k do begin
     s := GetJoinPath(chr(j+$40));
     if s <> '' Then begin
        TextColor(14);
        Write('   ',chr(j+$40),':  -  '); TextColor(11);
        Write('JOINed to ',s,', '); TextColor(12);
        WriteLn('disabled');
        end;
 end
 end;
 TextColor(7);
end;

procedure ParamHandler;
var s : string;
    i : byte;
begin
 Help := false;
 Full := false;
 Jour := false;
if ParamCount=0 Then Exit;
 for i:=1 to ParamCount do
   begin
     s := ParamStr(i);
     if ((pos('h',s)>1) or (pos('H',s)>1) or (pos('?',s)>1)) Then Help:=true;
     if ((pos('f',s)>1) or (pos('F',s)>1)) Then Full := true;
     if ((pos('j',s)>1) or (pos('J',s)>1)) Then Jour := true
   end
end;

procedure ShowHelp;
begin
  WriteLn;
  TextColor(14);
  WriteLn('    ╔══════════════════════════════════════════════════════════╗');
  WriteLn('    ║                  DiskType (FREEWARE)                     ║');
  WriteLn('    ║  Demonstration program to DSKTOOLS.TPU and DRVTOOL.TPU   ║');
  WriteLn('    ║             (R) BZSoft Inc., august-1992.                ║');
  WriteLn('    ║             (R) GalaSoft United Group International.     ║');
  WriteLn('    ║                      version 3.03                        ║');
  WriteLn('    ╚══════════════════════════════════════════════════════════╝');
  TextColor(10);
  WriteLn('  Usage: DiskType [/H|/?]|[/J[/F]] [>nul]');
  WriteLn('     if >NUL, Then return in ERRORLEVEL NDsk');
  WriteLn('     No parameters : displayed number and types of disks');
  WriteLn('     /H or /? - call this help');
  WriteLn('     /J - save information of boot time to Journal:');
  WriteLn('          DATE, TIME, NDsk - Number of disks drives');
  WriteLn('     /F enable check all disks (Full format):');
  WriteLn('        record D:T ; D - letter of disk, T - disk type:');
  WriteLn('               F - Floppy');
  WriteLn('               D - Device Driven');
  WriteLn('               S - Substituted');
  WriteLn('               N - NetWork');
  WriteLn('               E - Encrypted');
  WriteLn('               U - Unknown');
  WriteLn('               H###.# - Hard disk and size in Mb');
  TextColor(7); WriteLn;
  Halt(NumDrive);
end;

procedure WriteJournal;
var i : byte;
    f : text;
    r : real;
    s,x : string;
    day, month, year : integer;

begin
s:=ParamStr(0);
Delete(s,length(s)-2,3); s:=s+'SYS';
Assign(f,s); Append(f);
if IOResult<>0 Then
   begin ReWrite(f); if IOResult<>0 Then halt;
   WriteLn(f,'        Boot journal, (c) BZSoft Inc. ver 3.03');
   WriteLn(f,'-----------------------------------------------------');
   end;
DateToDMY(Today, day, month, year);
Str(day:3,x); s :=x+'-'+MonthString[month]+'-';
Str(year:4,x); Delete(x,1,2); s:=s+x;
while length(s)<17 do s:=s+' ';
s:=s+CurrentTimeString('hh:mm');
Str(NumDrive,x); s:=s+' NDsk='+x;
if Full Then begin
     while length(s)<30 do s:=s+' ';
if NumDrive>0 Then
   For i:=1 to NumDrive do
       begin
         s:=s+' '+DiskNameArray[i]+':';
         case DiskTypeArray[i] of
           Floppy           : s:=s+'F';
           HD0,HD1          : begin
                                s:=s+'H';
                                r:=DiskSize(ord(DiskNameArray[i])-$40);
                                r:=r/$100000;
                                str(r:6:1,x);
                                while x[1]=' ' do delete(x,1,1);
                                s:=s+x;
                              end;
           DeviceDriven,
           VDisk,
           EgaDisk          : s:=s+'D';
           AssignedDisk,
           SubstitutedDisk  : s:=s+'S';
           Encrypted        : s:=s+'E';
           NetWorkDisk      : s:=s+'N';
           else           s:=s+'U';
         end
       end;
   end;
 WriteLn(f,s);
 Close(f);
end;

begin
if not DskToolsVarInit Then InitDiskVariable;
ParamHandler;
if Help Then ShowHelp;
if Jour Then WriteJournal;
if not HandleIsConsole(StdOutHandle) Then Halt(NumDrive);
WriteDisksType;
end.
