
{ ================================================================ }
{                                                                  }
{      модуль   FLOPPY - набор процедур для чтения/записи          }
{      низкого уровня. Применяется только для работы с             }
{      дискетами. Использован в программе                          }
{      BADLIST  ver. 1.0.  5 января  1992                          }
{      автор      Шарий Максим Борисович                           }
{                 340005, г.Донецк, Речная, 4-34                   }
{                 тел. (0622) 91-92-77 (рабочий)                   }
{      транслятор - Turbo Pascal ver. 6.0.                         }
{                                                                  }
{ ================================================================ }



Unit Floppy;

INTERFACE

Uses Dos;

TYPE
   DriveName = string[2];
   TBootInfo = record
               JmpCmnd    : array[1..3] of byte;
               Name       : array[1..8] of char;
               SectSize   : word;
               ClustSize  : byte;
               ResSecs    : word;
               FatCnt     : byte;
               RootSize   : word;
               TotSecs    : word;
               Media      : byte;
               FatSize    : word;
               TrkSecs    : word;
               HeadCnt    : word;
               HidnSecs   : word;
               end;

VAR
   DriveNo, MaxTrackNo    : byte;
   FirstData              : word;
   BootInfo               : TBootInfo;
   CarrySet, InfoAvail    : boolean;

Procedure  GetBootInfo(Name: DriveName);
Function   FATContents(ClustNo: word; var FAT): word;
Procedure  SetFATContents(ClustNo,Contents: word; var FAT);
Procedure  ResetDrive;
Procedure  ReadSectors(Drive,Track,Head,Sect,N: byte; var Buf);
Procedure  WriteSectors(Drive,Track,Head,Sect,N: byte; var Buf);
   { Next functions work only if Boot Info is available }
Function   LogicSectNo(Track,Head,Sect: byte): word;
Function   LogicSector(ClustNo: word): word;
Function   ClusterNo(LogSectNo: word): word;
Function   ReadFAT(var FAT): boolean;
Function   WriteFAT(var FAT): boolean;
Function   Sector(LogSectNo: word; var Track,Head,Sect: byte): boolean;


IMPLEMENTATION

{ ---------------------------------------------------------------- }

Procedure  GetBootInfo(Name: DriveName);
var Buf : array[1..512] of byte;
    Boot: array[1..SizeOf(BootInfo)] of byte absolute BootInfo;
    i   : byte;
    r   : Registers;
begin
InfoAvail:=false;
for i:=1 to 2 do Name[i]:=UpCase(Name[i]);
if Name='A:' then DriveNo:=0
else if Name='B:' then DriveNo:=1
   else Exit;
i:=0;
Repeat
   ResetDrive;
   ReadSectors(DriveNo,0,0,1,1,Buf);
   Inc(i);
Until (not CarrySet) or (i=3);
if CarrySet then Exit;
for i:=1 to SizeOf(BootInfo) do Boot[i]:=Buf[i];
With BootInfo do
   begin
   MaxTrackNo:=((TotSecs div HeadCnt) div TrkSecs) - 1;
   FirstData:=ResSecs + FatSize*FatCnt + ((RootSize*32) div SectSize);
   end;
InfoAvail:=true;
end;

{ ---------------------------------------------------------------- }

Function   FATContents(ClustNo: word; var FAT): word;
var P       : ^word;
    Offset,x: word;
begin
Offset:=(ClustNo*3) div 2;
P:=Ptr(Seg(FAT),Ofs(FAT)+Offset);
x:=P^;
if not Odd(ClustNo) then FATContents:=x and $0fff
else FATContents:=x shr 4;
end;

{ ---------------------------------------------------------------- }

Procedure  SetFATContents(ClustNo,Contents: word; var FAT);
var P       : ^word;
    Offset,x: word;
begin
Offset:=(ClustNo*3) div 2;
P:=Ptr(Seg(FAT),Ofs(FAT)+Offset);
x:=P^;
if not Odd(ClustNo) then
   begin
   Contents:=Contents and $0fff;
   x:=x and $f000;
   end
else
   begin
   Contents:=Contents SHL 4;
   x:=x and $000f;
   end;
P^:=x or Contents;
end;

{ ---------------------------------------------------------------- }

Procedure  ResetDrive;
var R: Registers;
begin
R.DL:=0;
R.AH:=0;
Intr($13,R);
end;

{ ---------------------------------------------------------------- }

Procedure  ReadSectors(Drive,Track,Head,Sect,N: byte; var Buf);
var R: Registers;
begin
with R do
   begin
   AH:=2;
   DL:=Drive;
   DH:=Head;
   CH:=Track;
   CL:=Sect;
   AL:=N;
   ES:=Seg(Buf);  BX:=Ofs(Buf);
   end;
Intr($13,R);
if R.Flags and FCarry <> 0 then CarrySet:=true
else CarrySet:=false;
end;

{ ---------------------------------------------------------------- }

Procedure  WriteSectors(Drive,Track,Head,Sect,N: byte; var Buf);
var R: Registers;
begin
with R do
   begin
   AH:=3;
   DL:=Drive;
   DH:=Head;
   CH:=Track;
   CL:=Sect;
   AL:=N;
   ES:=Seg(Buf);  BX:=Ofs(Buf);
   end;
Intr($13,R);
if R.Flags and FCarry <> 0 then CarrySet:=true
else CarrySet:=false;
end;

{ ---------------------------------------------------------------- }

Function   LogicSectNo(Track,Head,Sect: byte): word;
begin
if InfoAvail then with BootInfo do
   begin
   LogicSectNo:=Sect - 1 + Head*TrkSecs + Track*HeadCnt*TrkSecs;
   end
else LogicSectNo:=$ffff;
end;

{ ---------------------------------------------------------------- }

Function   LogicSector(ClustNo: word): word;
begin
if InfoAvail then with BootInfo do
   begin
   LogicSector:=FirstData + (ClustNo - 2)*ClustSize;
   end
else LogicSector:=$ffff;
end;

{ ---------------------------------------------------------------- }

Function   ClusterNo(LogSectNo: word): word;
begin
if InfoAvail then with BootInfo do
   if LogSectNo>=FirstData then
      ClusterNo:=((LogSectNo - FirstData) div ClustSize) + 2
   else ClusterNo:=$0
else ClusterNo:=$0;
end;

{ ---------------------------------------------------------------- }

Function   ReadFAT(var FAT): boolean;
var R: Registers;
    i,count: byte;
begin
ReadFAT:=false;
if InfoAvail then with R do
   begin
   With BootInfo do
      for i:=0 to FatSize-1 do
         begin
         Count:=0;
         Repeat
            if not Sector(ResSecs+i,CH,DH,CL) then Exit;
            AH:=2;
            DL:=DriveNo;
            AL:=1;
            ES:=Seg(FAT); BX:=Ofs(FAT) + i*SectSize;
            Intr($13,R);
            if Flags and FCarry <> 0 then  ResetDrive;
            Inc(Count)
         until (not CarrySet) or (Count=3);
         if Flags and FCarry <> 0 then Exit;
         end;
   ReadFAT:=true;
   end;
end;

{ ---------------------------------------------------------------- }

Function   WriteFAT(var FAT): boolean;
var R: Registers;
    FATSectorNo,FATCopy,count: byte;
begin
WriteFAT:=false;
if InfoAvail then with R do
   begin
   With BootInfo do
      for FATCopy:=1 to FATCnt do
         for FATSectorNo:=0 to FatSize-1 do
            begin
            Count:=0;
            Repeat
               if not Sector(ResSecs + FATSectorNo + (FATCopy-1)*FATSize
                             ,CH,DH,CL) then Exit;
               AH:=3;
               DL:=DriveNo;
               AL:=1;
               ES:=Seg(FAT); BX:=Ofs(FAT) + FATSectorNo*SectSize;
               Intr($13,R);
               if Flags and FCarry <> 0 then ResetDrive;
               Inc(Count)
            until (not CarrySet) or (Count=3);
            if Flags and FCarry <> 0 then Exit;
            end;
   WriteFAT:=true;
   end;
end;

{ ---------------------------------------------------------------- }

Function   Sector(LogSectNo: word; var Track,Head,Sect: byte): boolean;
var A: word;
begin
if InfoAvail then with BootInfo do
   begin
   A:= HeadCnt*TrkSecs;
   Track:=LogSectNo div A;
   A:= LogSectNo mod A;
   Head:= A div TrkSecs;
   Sect:=(A mod TrkSecs) + 1;
   Sector:=true;
   end
else Sector:=false;
end;

{ ---------------------------------------------------------------- }


begin
InfoAvail:=false;
end.