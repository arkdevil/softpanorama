{$R-}
program partitn;
uses dos, crt, sounds;

const ESC = #$1b;
      EndChars : set of char = ['Q','q','x','X', ESC];
type
    FileNameStr  = String[64];

    DiskAddress = record
        Head     : byte;
        Sector   : byte;
        Track    : byte;
        end;

    PartitionRecord  = record
        IsStartUp   : byte;     { 0x80: is startup,  00: is not }
        StartDA     : DiskAddress;
        SystemId    : byte;     {  1: first MS_DOS (12 bit FAT)
				   2: root Xenix
				   3: user Xenix
				   4: first MS_DOS (16 bit FAT)
                                  63: Interactive Unix
				  F2: Second MS_DOS (either FAT)
				  FF: bad track info of Xenix 	}
	EndDA       : DiskAddress;
	StartLogicalSector : LongInt;
	NumLogicalSectors  : LongInt;
	end;

    PartitionTable = record
	BootCode  : array[1..$1be] of byte;
        Partitions: array[1..4] of PartitionRecord;
        Marker    : word;
        end;

    Bigbuf = array[0..511] of byte;

Var
    PTfile    : file of Bigbuf;
    PTfilename: FileNameStr;
    chh       : char;
    DeviceNum : byte;         {info for current disk device}
    DeviceChar: char;
    PTtemp    : PartitionTable;
    PTtempx   : Bigbuf Absolute PTtemp;
    PT        : PartitionTable;
    PTx       : Bigbuf absolute PT;
    PTsource  : FileNameStr;  {where we got current PT record from}
    PTdevice  : char;         {if from a drive, the letter}
    I,J       : Word;
    regs      : Registers;
    PTDA      : DiskAddress; {raw boot record disk address}
    UserDA    : DiskAddress; {when user enters a disk address}
    PThasPartitions : Boolean;      {type of recd in PT}
    PThasSomething  : Boolean;
    SaveMainY : Byte;


Procedure DisplayHelp;
var ch:char;
begin
clrscr;
writeln('This program lets you read and write disk and partition boot records.');
writeln('It lets you move these records into a file and lets you put whatever');
writeln('you want into a boot record.  You can change a partition type and can');
writeln('merge the code from one boot record with the partition table of another.');
writeln;
writeln('The program NEVER writes anything out until you enter a Write command.');
writeln('All changes are done to an in memory buffer.  This buffer gets written');
writeln('by the write command.  The write command asks for verification before');
writeln('overwriting a boot record on the hard disk.  BUT BE CAREFUL !!!');
writeln;
writeln('For all commands, <esc>, Q, or X mean the same thing: quit to the next level');
writeln;
writeln('The first record on a disk is a boot record.  It gets read in at the start');
writeln('of the boot sequence.  The code in it can do whatever it wants.  By');
writeln('convention a HARD disk boot record has a partition table in it.  A');
writeln('partition is a hunk of disk; on the front of a BOOTABLE partition is');
writeln('another boot record.  The disk boot record reads in and transfers control');
writeln('to the partition boot record.  A floppy disk boot record is essentially');
writeln('a partition boot record to boot off drive A:');
writeln;
writeln('If you have a disk with two bootable systems (Unix and MS-DOS), you can');
writeln('copy the respective partition boot records to the boot record on a');
writeln('diskette.  Then this diskette will directly boot that partition.');
writeln;
write('continue . . .');
beep;  ch:=ReadKey;  clrscr;
end {DisplayHelp};

Procedure MainWindow;
begin  Window(1,1,40,25); GotoXY(1,SaveMainY); end;

Procedure PartitionWindow;
begin SaveMainY:=WhereY; Window(41,1,80,25); end;

Procedure PrintDiskAddress (Var DA:DiskAddress);
Var ccc : word;
Begin with DA do begin
	ccc := ((Sector and $c0) shl 2) + Track;
	write (ccc, '/', Head, '/', Sector and $3F);
end end {PrintDiskAddress};


function NullDA(DA:DiskAddress):boolean;
    begin  NullDA := (DA.head=0) and (DA.track=0) and (DA.sector=0);  end;


Procedure PrintPartition (Var pp:PartitionRecord; num:byte);
var UnKnown:boolean;
begin with pp do begin
        write(' ', num);
	if IsStartup = $80 then write(' A')
                           else write('  ');

        UnKnown:=False;
	write(' type : ');
	case SystemId of
	      1:  write ('MS-DOS1 (12 fat)');
	      2:  write ('XENIX root');
              3:  write ('XENIX user');
	      4:  write ('MS-DOS1 (16 fat)');
            $63:  write ('Interactive Unix');
	    $F2:  write ('MS-DOS2');
	    $FF:  write ('XENIX bad track ');
	   else   begin
                  UnKnown := True;
                  write ('unknown (', SystemId, ')');
                  end;
	    end {case};
        writeln;
        if (not NullDA(StartDA)) or (not NullDA(EndDA)) then
            begin
            write('     c/h/r: ');     PrintDiskAddress(StartDA);
	    write(' to ');  PrintDiskAddress(EndDA);
            writeln;
            end;

        if (not UnKnown) or
           (StartLogicalSector<>0) or (NumLogicalSectors<>0) then
              writeln ('     1st/#: ', StartLogicalSector,
                       '/', NumLogicalSectors, ' sectors');

        writeln;
end end {PrintPartition};


Function CheckRecordMarker(var PT:PartitionTable):boolean;
begin
        CheckRecordMarker:=true;
        if PT.Marker<>$AA55 then
           begin
           CheckRecordMarker:=false;
           Writeln('NOT A VALID BOOT RECORD !!!');  blat;
           end;
end {CheckRecordMarker};


Function CheckPartitionTable(var PT:PartitionTable):boolean;
var i,cnt:byte;
begin with PT do begin
      CheckPartitionTable:=true;
      cnt:=0;
      for i:=1 to 4 do
          if Partitions[i].IsStartUp=$80 then cnt:=cnt+1
          else if Partitions[i].IsStartUp<>0 then cnt:=cnt+10;
      if cnt<>1 then
          begin
          CheckPartitionTable:=false;
          Writeln('THIS IS A VALID BOOT RECORD');
          Writeln('( DOES NOT HAVE A PARTITION TABLE )');
          blat;
          end;
end end {CheckPartitionTable};


Procedure PrintPartitionRecord(var PT:PartitionTable);
begin with PT do begin
        PartitionWindow;
        clrscr;
        writeln(PTsource);
        PThasPartitions:=false;
        if PThasSomething then
           if CheckRecordMarker(PT) then
              if CheckPartitionTable(PT) then
                  begin
                  PThasPartitions:=true;
                  for i:=4 downto 1 do
                          PrintPartition(PT.Partitions[i], 5-i);
                  end;
        MainWindow;
end end {PrintPartitionRecord};


Procedure ClearDiskette(Device:byte);
{if device is diskette, read change status so IO will not fail if changed}
begin
     if Device < $80 then
        With Regs do begin
             AH := $00;
             DL := Device;
             Intr($13, Regs);
             writeln('** ', AH);
             end;
end {ClearDiskette};

Procedure WriteDisk (Var DA:DiskAddress; Device:byte; var buffer:BigBuf);
var XX : byte;
begin with Regs, DA do begin
      XX := 0;
      DH := Head;
      DL := Device;
      CH := Track;
      CL := Sector;
      BX := Ofs(buffer);
      ES := Seg(buffer);
      Repeat
            XX := XX+1;
            AH := 3;          {write}
            AL := 1;          {1 sector}
            Intr($13, Regs);
            Until (Device>=$80) or (XX>1) or (AH<>6);
      if AH<>0 then
          begin  WriteLn('DISK WRITE ERROR ', AH, ' !!!');  blat;  end
       else
          WriteLn('Record Successfully Written');
end end {WriteDisk};


Function ReadDisk (Var DA:DiskAddress; Device:byte; var buffer:BigBuf):boolean;
var XX : Byte;
begin with Regs, DA do begin
      XX := 0;
      DH := Head;
      DL := Device;
      CH := Track;
      CL := Sector;
      BX := Ofs(buffer);
      ES := Seg(buffer);
      Repeat
            XX := XX+1;
            AH := 2;     {read}
            AL := 1;     {1 sector}
            Intr($13, Regs);
            Until (Device>=$80) or (XX>1) or (AH<>6);
      ReadDisk := true;
      if AH<>0 then
          begin
          writeln('DISK READ ERROR ', AH, ' !!!');
          blat;  ReadDisk:=False;
          end
       else
          WriteLn('Record Successfully Read In.');
end end {ReadDisk};

function TestForEndChars(ch:char):boolean;
begin
     if ch<>ESC then write(ch);
     writeln;
     TestForEndChars := ch in EndChars;
end;


Function SaveToFile:boolean;
label QUIT;
var TempName : fileNameStr;
     ch : char;
begin
     PTfileName := 'BOOT' + PTdevice + '.RCD';
     Write('File to Save to (', PTfileName, ') : ');
     beep;  ReadLn(TempName);
     if (length(TempName)=1) and (UpCase(TempName[1])='Q') then goto QUIT;
     if TempName <>'' then  PTfileName := TempName;
     Assign(PTfile, PTfileName);
     ch:='Y';
     {$I-} Reset(PTfile); {$I+}
     if IOresult=0 then
        begin
        writeln('FILE ', PTfileName, ' EXISTS!');
        write  ('     OVERWRITE (Y/N) ? ');
        beep;  ch := UpCase(ReadKey); Writeln(ch);
        close(PTfile);
        end;

     if ch='Y' then
        begin
        ReWrite(PTfile);
        Write(PTfile, PTx);
                Close(PTfile);
        SaveToFile:=True;
        Writeln('Successful Write');
        end
     else
QUIT:   begin  SavetoFile:=False;  end;
     WriteLn;
     end {SavetoFile};


Function GetFromFile:boolean;
var TempName : FileNameStr;
begin
     PTfileName := 'BOOT' + DeviceChar + '.RCD';
     Write('File to read from (', PTfileName, ') : ');
     beep;  Readln(TempName);
     if TempName<>'' then PTfileName:=TempName;
     Assign(PTfile, PTfileName);
     {$I-} reset(PTfile); {$I+}
     if IOresult<>0 then
        begin
        Writeln('OPEN FAILURE FILE ', PTfilename, ', NOTHING READ !!!');
        blat;
        GetFromFile:=false;
        end
     else
        begin
        Read(PTfile, PTx);
        Close(PTfile);
        WriteLn('Successful file read');
        GetFromFile := True;
        end;
     writeln;
end {GetFromFile};

Function GetPartitionDA (var Ption:PartitionRecord; var DA:DiskAddress)
                : boolean;
begin
GetPartitionDA:=false;
if (not NullDA(Ption.StartDA)) and
   (not NullDA(Ption.EndDA)) then
       begin  DA:=Ption.StartDA;  GetPartitionDA:=true;  end;
end {GetPArtitionDA};


Function GetCRH(var DA:DiskAddress):boolean;
{ask user for a disk address cc/hh/rr}
label BAD;
var sc,sh,sr:string[4];
    temp    :string[24];
    i,track :word;
begin
GetCRH:=false;
write('Enter cc/hh/rr : ');
readln(temp);
i:=pos('/',temp);
if i=0 then goto BAD;
sc:=copy(temp,1,i-1);  temp:=copy(temp,i+1,255);
i:=pos('/',temp);
if i=0 then goto BAD;
sh:=copy(temp,1,i-1);  sr:=copy(temp,i+1,255);
val(sc, track, i);
if i<>0 then goto BAD;
val(sh, DA.head, i);
if i<>0 then goto BAD;
val(sr, DA.sector, i);
if i<>0 then goto BAD;
DA.sector := DA.sector or ((track and $ff00) shr 2);
DA.track  := track and $00ff;
GetCRH:=True;
if i<>0 then
BAD: writeln('INVALID CC/HH/RR');
end {GetCRH};


Procedure ReadWhat;
{Read selected, ask what to read}
var ch, chp : char;
    st,sh,ss: string[4];
begin
     Writeln('1  - Read disk ', DeviceChar, ' boot record');
     Writeln('2  - Read record from MS-DOS file');
     Writeln('3  - Read from disk address');
     if PThasSOmething and PThasPartitions then
        Writeln('Pn - Read partition n boot record');
     Write  ('    : ');
     repeat
          beep; ch:=UpCase(ReadKey);
          until (ch in ['1','2','3', 'P']) or (ch in EndChars);
     chp:=ch;
     if ch='P' then
        begin
        write(ch);
        repeat
           beep; chp:=UpCase(ReadKey);
           until (chp in ['1' .. '4']) or (chp in EndChars);
        end;

     if TestForEndChars(chp) then exit;

     if ch='1' then
        begin
        PThasSomething :=  ReadDisk(PTDA, DeviceNum, PTx);
        PTdevice :=  DeviceChar;
        PTSource := 'Device: ' + PTdevice;
        end
     else if ch='2' then
        begin
        if GetFromFile then
           begin
           PThasSomething:=true;
           PTdevice := '?';
           PTsource := PTfileName;
           end;
        end
     else if ch='3' then
        begin
        if GetCRH(UserDA) then
           begin
           PThasSomething := ReadDisk(UserDA, DeviceNum, PTx);
           PTdevice := DeviceChar;
           Str(UserDA.track + ((UserDA.Sector and $c0) shl 2) , st);
           Str(UserDA.head,  sh);
           Str(UserDA.Sector and $3f,ss);

           PTsource := PTdevice + ':' + st + '/' + sh + '/' + ss;
           end;
        end
     else if (ch='P') and PThasSomething and PThasPartitions then
        begin
        if GetPartitionDA(PT.Partitions[5-Ord(chp)+Ord('0')], UserDA) then
           begin
           PThasSOmething := ReadDisk(UserDA, DeviceNum, PTx);
           PTdevice := DeviceChar;
           PTsource := 'Partition ' + chp;
           end
        else
           begin  WriteLn('Invalid Partition');  blat;  exit;  end;
        end;

     PrintPartitionRecord(PT);
end {ReadWhat};


Procedure WriteWhat;
label FIN1;
var ch,chh:char;
    OK:boolean;
begin
     if not PThasSomething then
        begin  Writeln('Nothing to write');  exit; end;

     Writeln('1 - Write disk ', DeviceChar, ' boot record');
     Writeln('2 - Write record to MS-DOS file');
     Writeln('3 - Write to disk address');
     Write  ('    : ');
     repeat
          beep; ch:=UpCase(ReadKey);
          until (ch in ['1','2','3']) or (ch in EndChars);
     if TestForEndChars(ch) then goto FIN1;

     chh:='Y';
     OK :=True;
     if (ch='1') or (ch='3') then
        begin
        Writeln('Are you sure you want to overwrite');
        Write  ('the boot record on drive ', DeviceChar, ' (Y/N) ? ');
        beep;  chh:= UpCase(ReadKey);  Writeln(chh);
        if chh<>'Y' then goto FIN1;

        if (ch='1') and (not PThasPartitions) and (DeviceChar>='C') then
              begin
              writeln('The record does not have a valid partition table');
              write  ('Are you sure you want to do this (Y/N) ? ');
              beep;  chh:=UpCase(ReadKey);  Writeln(chh);
              if chh<>'Y' then goto FIN1;
              end;

        writeln;
        writeln('One last chance, this is DANGEROUS!');
        write  ('    ARE YOU SURE (Y/N) ? ');
        beep;  chh:=UpCase(ReadKey);  Writeln(chh);
        if chh<>'Y' then goto FIN1;
        end;

     if ch='1' then
        WriteDisk(PTDA, DeviceNum, PTx);

     if ch='2' then
        OK:=SaveToFile;

     if (not OK) then
FIN1:   begin  writeln('NOTHING WRITTEN !!!');  blat;  end;
end {WriteWhat};


Function Merger : boolean;
{this procedure merges the partition table and code portions of record
in buffer and current record on disk}
var ch:char;
begin
     Merger := false;
     if PThasSomething and PThasPartitions and
        ReadDisk(PTDA, DeviceNum, PTtempx) and
        CheckRecordMarker(PTtemp)          and
        CheckPartitionTable(PTtemp) then
        begin
        writeln('Merge:');
        writeln('1 - code on disk, table in buffer');
        write  ('2 - table on disk, code in buffer  : ');
        repeat
             beep; ch:=ReadKey
             until (ch in ['1','2']) or (ch in EndChars);
        if TestForEndChars(ch) then exit;

        if ch='1' then
           PT.BootCode := PTtemp.BootCode;
        if ch='2' then
           PT.Partitions := PTtemp.PArtitions;

        PrintPartitionRecord(PT);
        Merger := true;
        end;
end {Merger};


function EditPartition : boolean;
var ch, chh : char;
    PartType: byte;
begin
   EditPartition := false;
   if not (PThasSomething and PThasPartitions) then  exit;
   write('ENTER PARTITION NUMBER : ');
   repeat
       beep;  ch := UpCase(ReadKey);
       until (ch in ['1' .. '4']) or (ch in EndChars);
   if TestForEndChars(ch) then exit;
   writeln;
   writeln('ENTER NEW PARTION SYSTEM ID');
   writeln ('1 - MS-DOS1 (12 fat)');
   writeln ('2 - XENIX root');
   writeln ('3 - XENIX user');
   writeln ('4 - MS-DOS1 (16 fat)');
   writeln ('5 - Interactive Unix');      { $63}
   writeln ('6 - MS-DOS2 (not boot)');    { $F2}
   write   ('7 - XENIX bad track  : ');   { $FF}
   repeat
         beep;  chh := UpCase(ReadKey);
         until (ch in ['1' .. '7']) or (ch in EndChars);
   if TestForEndChars(chh) then exit;
   PartType := Ord(chh) - Ord('0');
   if chh='5' then PartType := $63;
   if chh='6' then PartType := $F2;
   if chh='7' then PartType := $FF;
   PT.Partitions[5 - Ord(ch)+Ord('0')].SystemID := PartType;
   PrintPartitionRecord(PT);
   EditPartition := true;
end {EditPartition};


Function GetDiskName : Boolean;
var ch : char;
begin
        GetDiskName:=False;
        write('ENTER DISK TO WORK WITH (A ... D) : ');
        repeat
              beep; ch:=UpCase(ReadKey);
              until (ch in ['A' .. 'D']) or (ch in EndChars);
        if TestForEndChars(ch) then exit;
        DeviceChar := ch;
        if DeviceChar<'C'
              then  DeviceNum := Ord(DeviceChar) - Ord('A')
              else  DeviceNum := Ord(DeviceChar) - Ord('C') + $80;
         GetDiskName:=true;
end {GetDiskName};


begin {main}
        Clrscr;
        repeat
            Writeln('PARTITN 2.0 by Richard Marks.  (FREE WARE)');
            Writeln;
            Writeln('WARNING: IF YOU DO NOT KNOW WHAT YOU ARE DOING');
            Writeln;
            Writeln(' YOU CAN TRASH THE HARD DISK WITH THIS PROGRAM');
            writeln;  write('PROCEED (Y/N/H) ? ');
            beep;  chh:=UpCase(ReadKey);
            if chh='H' then DisplayHelp;
            until (chh<>'H');
        if chh<>'Y' then Halt;
        ClrScr;

        SaveMainY:=1; MainWindow;
        Writeln;
        PTDA.Track := 0;
        PTDA.Head  := 0;
        PTDA.Sector:= 1;

        PThasSomething :=False;
        PThasPartitions:=False;
        PTsource := ' ';
        PTdevice := '?';

        if not GetDiskName then halt;

  while true do
        begin
        writeln;
        writeln('N - work with new disk');
        writeln('R - read record');
        if PThasSomething then
             writeln('W - write record');
        if PThasSomething and PThasPartitions then
            begin
            writeln('M - merge portions of records');
            writeln('E - edit partition info');
            end;
        ClrEol; write  ('    : ');
        repeat
              beep;  chh:=UpCase(ReadKey);
              until (chh in ['E','N','R','W','M']) or (chh in EndChars);
        if TestForEndChars(chh) then Halt;
        writeln;

        case chh of
        'N' : if GetDiskName then;
        'R' : ReadWhat;
        'W' : if PThasSomething then  WriteWhat;
        'M' : if Merger then;
        'E' : if EditPartition then;
        end {case};
     end {while};
end.
