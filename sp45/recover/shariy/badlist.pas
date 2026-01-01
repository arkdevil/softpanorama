{$i-}

{ ================================================================ }
{                                                                  }
{      BADLIST  ver. 1.0.  5 января  1992                          }
{      автор      Шарий Максим Борисович                           }
{                 340005, г.Донецк, Речная, 4-34                   }
{                 тел. (0622) 91-92-77 (рабочий)                   }
{      транслятор - Turbo Pascal ver. 6.0.                         }
{      Программа для быстрого контроля физического состояния       }
{      дискет и отметки плохих и сомнительных секторов в FAT.      }
{                                                                  }
{ ================================================================ }

Program BadList;

Uses Floppy, Crt, Dos;

TYPE
   TDiskTable = array[0..11] of byte;

CONST
   FoundBadClust : word = 0;
   BadFound      : boolean = false;
   FATCorrected  : boolean = false;

VAR
   DiskTable                         : TDiskTable;
   Track,Head,Sect                   : byte;
   f                                 : text;
   FAT, Buffer, Old1e, Old23         : Pointer;
   Correct                           : boolean;
   r                                 : registers;

Procedure My23; interrupt;
var r: registers;
begin
FreeMem(FAT,BootInfo.SectSize*BootInfo.FatSize);
FreeMem(Buffer,BootInfo.SectSize*BootInfo.TrkSecs);
Close(f);
SetIntVec($1e,Old1e);
SetIntVec($23,Old23);
Intr($23,r)
end;

Procedure SetDiskTable(var OldVector);
var OldTable: TDiskTable absolute OldVector;
begin
DiskTable:=OldTable;
if DiskTable[4]<BootInfo.TrkSecs then DiskTable[4]:=BootInfo.TrkSecs;
DiskTable[5]:=2;
SetIntVec($1e,@DiskTable);
end;

Procedure Teach;
begin
Writeln('Использование: BADLIST drive output [c]');
writeln('.......................................');
writeln('drive  - имя проверяемого диcковода');
writeln('output - имя файла, в который будет помещен список найденных');
writeln('         дефектных секторов');
writeln('с      - необязательный параметр. Если он присутствует, то найденные');
writeln('         дефектные сектора будут отмечены в FAT.');
writeln('.......................................');
writeln('Примеры:');
writeln('badlist  a:  bad.a');
writeln('badlist  b:  prn  c');
Intr($23,r);
end;



Procedure Init;
Const Header:string=#10#13+'BadList ver. 1.0.  Шарий М.Б.  ДонГУ.  (c) 1991.'
                   +#10#13+'Поиск и отметка сбойных секторов на дискете.';
var ch: char;
    s:  string[1];
    i:  byte;
begin
Writeln(Header);
Writeln;
if (ParamCount<2) or (ParamCount>3) then    Teach;
if ParamCount=3 then
   begin
   s:=ParamStr(3);
   ch:=s[1];
   if UpCase(ch)<>'C' then  Teach;
   Correct:=true;
   end
else Correct:=false;
GetBootInfo(ParamStr(1));
if not InfoAvail then
   begin
   Writeln('Can''t access boot sector of drive ',ParamStr(1));
   Intr($23,r);
   end;
GetMem(FAT,BootInfo.SectSize*BootInfo.FatSize);
GetMem(Buffer,BootInfo.SectSize*BootInfo.TrkSecs);
if not ReadFAT(FAT^) then
   begin
   Writeln('Can''t read FAT of drive ',ParamStr(1));
   Intr($23,r);
   end;
if Correct then
   begin
   Writeln('В случае обнаружения сбойных секторов будут внесены исправления в таблицу');
   writeln('размещения файлов. Файлы, содержащие сбойные сектора, будут безнадежно ');
   writeln('испорчены. Поэтому необходимо предварительно считать с дискеты все, что ');
   writeln('получится.    Продолжать(Y/N)?');
   Readln(ch);
   if UpCase(ch)<>'Y' then Intr($23,r);
   end;
Assign(f,ParamStr(2));
Rewrite(f);
if IOResult<>0 then
   begin
   Writeln('Can''t open ',ParamStr(2));  Intr($23,r);
   end;
writeln(f,'Анализ диска ',ParamStr(1));
if IOResult<>0 then
   begin
   Writeln('Error while writing ',ParamStr(2));  Close(f);  Intr($23,r);
   end;
writeln(f,'.....................');
if IOResult<>0 then
   begin
   Writeln('Error while writing ',ParamStr(2));  Close(f);  Intr($23,r);
   end;
writeln(f,'Cluster':8,'Track':7,'Head':7,'Sector':7);
if IOResult<>0 then
   begin
   Writeln('Error while writing ',ParamStr(2));  Close(f);  Intr($23,r);
   end;
GetIntVec($1e,Old1e);
SetDiskTable(Old1e^);
GetIntVec($23,Old23);
SetIntVec($23,@My23);
end;


Procedure ScanSector;
var LogSect, Clust, NextClust: word;
    buf                      : array[1..2048] of byte;
begin
LogSect:=LogicSectNo(Track,Head,Sect);
Clust:=ClusterNo(LogSect);
if Clust > 0 then
   begin
   NextClust:=FATContents(Clust,FAT^);
   if NextClust = $ff7 then
      begin
      if (Clust<>FoundBadClust) then
         begin
         writeln(f,Clust:8,'':22,'Уже отмечен как сбойный.');
         if IOResult<>0 then
            begin
            Writeln('Error while writing ',ParamStr(2));  Intr($23,r);
            end;
         BadFound:=True;
         FoundBadClust:=Clust;
         end;
      end
   else
      begin
      ReadSectors(DriveNo,Track,Head,Sect,1,Buf);
      if CarrySet then
         begin
         ResetDrive;
         if Correct then
            begin
            SetFATContents(ClusterNo(LogicSectNo(Track,Head,Sect)),$ff7,FAT^);
            FATCorrected:=true;
            end;
         Write(f,Clust:8,Track:7,Head:7,Sect:7,' Сбойный. ');
         if Correct then
            begin
            writeln(f,'В FAT сделана отметка.');
            if IOResult<>0 then
               begin
               Writeln('Error while writing ',ParamStr(2));  Intr($23,r);
               end;
            end
         else
            begin
            Writeln(f,'Имейте в виду!');
            if IOResult<>0 then
               begin
               Writeln('Error while writing ',ParamStr(2));  Intr($23,r);
               end;
            end;
         BadFound:=true;
         end;
      end;
   end
else      { Sector in System area }
   begin
   ReadSectors(DriveNo,Track,Head,Sect,1,Buf);
   if CarrySet then
      begin
      ResetDrive;
      Writeln(f,'':8,Track:7,Head:7,Sect:7,' Сбойный сектор в системной области. Очень плохо.');
      if IOResult<>0 then
         begin
         Writeln('Error while writing ',ParamStr(2));  Intr($23,r);
         end;
      BadFound:=true;
      end;
   end;
end;


Procedure Done;
begin
if Correct and FATCorrected then
   if not WriteFAT(FAT^) then
      begin
      Writeln(f,'Error while updating FAT.   All changes lost!');
      if IOResult<>0 then
         begin
         Writeln('Error while writing ',ParamStr(2));  Intr($23,r);
         end;
      end;
FreeMem(FAT,BootInfo.SectSize*BootInfo.FatSize);
FreeMem(Buffer,BootInfo.SectSize*BootInfo.TrkSecs);
if not BadFound then
   begin
   writeln(f,' Сбойные сектора не найдены.');
   if IOResult<>0 then
      begin
      Writeln('Error while writing ',ParamStr(2));  Intr($23,r);
      end;
   GotoXY(1,WhereY-1); ClrEOL;
   writeln(' Сбойные сектора не найдены.');
   end
else
   begin
   writeln(f,' Обнаружены сбойные сектора.');
   if IOResult<>0 then
      begin
      Writeln('Error while writing ',ParamStr(2));  Intr($23,r);
      end;
   GotoXY(1,WhereY-1); ClrEOL;
   writeln(' Обнаружены сбойные сектора.');
   end;
Close(f);
SetIntVec($1e,Old1e);
end;


begin
Init;
With BootInfo do
   for Track:=0 to MaxTrackNo do
      for Head:=0 to HeadCnt-1 do
         begin
         GotoXY(1,WhereY-1); ClrEOL;
         Writeln('Track: ',Track,' Head: ',Head);
         ReadSectors(DriveNo,Track,Head,1,TrkSecs,Buffer^);
         if CarrySet then
            begin
            ResetDrive;
            for Sect:=1 to TrkSecs do
               begin
               r.AH:=$0B;
               MsDos(r);
               ScanSector;
               end;
            end;
         end;
Done;
end.