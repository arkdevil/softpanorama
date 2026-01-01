{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,P-,Q+,R+,S+,T+,V-,X+,Y+}
{$M 2048,65536,65536}
{ BP 7.0 }
{ #H#C#S, (C) V.S.Rabets, 1994. Edition 06.02.94 }
uses DOS;

type PartEntry = record Boot   : byte;
                        BegHead: byte;
                        BegSecCyl: word;
                        Sys: byte;
                        EndHead: byte;
                        EndSecCyl: word;
                        OtherInfo: array [1..2*4] of byte;
                 end;
     PartitionTable = record BootCode: array [1..$1BE] of byte;
                             PE: array [1..4] of PartEntry;
                      end;
var P: ^PartitionTable absolute HeapOrg;

const Drive: byte = $80;                                  { Исследуемый диск }
      MaxHeadP: byte = 0;  { Max значения Head, Cyl и Sec из Partition table }
      MaxCylP : word = 0;
      MaxSecP : byte = 1;
      ParamInt: byte = $41;  {Вектор, указывающий на таблицу параметров диска}
var ParamTable: record CylCnt : word;             { Таблица параметров диска }
                       HeadCnt: byte;
                       SomeInfo: array [3..$D] of byte;
                       SecPerTrack: byte;
                       OtherInfo: byte;
                end;
var  SaveParamAddr,              { Адрес исходной таблицы параметров диска }
     SaveExitProc: pointer;
     R: registers;
     DiskErr: byte;              { Ошибка дисковых операций }
     Start,
     i,w: word;
                                             { Установка параметров диска }
function SetDriveParams (ParamAddr: pointer): boolean;  {ParamAddr - @таблицы}
begin
  SetIntVec (ParamInt, ParamAddr);      { Установка int $41 или $46 }
  with R do begin
       DL:=Drive;
       AH:=9;                           { Initialize drive parameters table }
       intr ($13, R);
       SetDriveParams:=(Flags and fCarry)=0;
       DiskErr:=AH;
  end;
end;

function SetBigDisk: boolean;      { Установка max значений Head, Cyl, Sect }
begin
  move ( (pointer(MemL[0:ParamInt*4]))^, ParamTable, SizeOf(ParamTable) );
  with ParamTable do begin        { Копирование и модификация таблицы }
       CylCnt :=1024;
       if HeadCnt<16 then HeadCnt:=16;
       SecPerTrack:=64;
  end;
  SetBigDisk:=SetDriveParams(@ParamTable);  {Установка новых параметров диска}
end;

function ReadSector (Head:byte; Cyl:word; Sec:byte): boolean;
begin
  with R do begin
       ES:=seg(HeapOrg^);         { Размер хипа задан 64K }
       BX:=ofs(HeapOrg^);
       DL:=Drive;
       DH:=Head;
       CH:=lo(Cyl);
       CL:=Sec + (hi(Cyl) shl 6);
       AL:=1;                     { Читать 1 сектор }
       AH:=2;                     { Read sector     }
       intr ($13, R);
       ReadSector:=(Flags and fCarry)=0;
       DiskErr:=AH;
  end;
end;

function MaxWord (W1, W2, W3: word): word;     { Max из трех чисел }
var Max: word;
begin
   Max:=W1; if W2>Max then Max:=W2; if W3>Max then Max:=W3;  MaxWord:=Max;
end;

procedure ExitProcedure; far;
begin
  ExitProc:=SaveExitProc;
  if not SetDriveParams (SaveParamAddr)
     then writeln (#10'Restore disk parameters error'#7);
end;

{ ================================================================ MAIN === }
begin
  writeln (#10'#H#C#S, ver. 0.00. (C) V.S.Rabets, 1994'#10);
  writeln ('The program try to determine number of Heads, Cylinders and Sectors_per_track');
  writeln ('                      on hard disk. It is useful in the case of CMOS trouble.');
  writeln ('The program analyzes Partition table, then it reads some sectors and displays');
  writeln ('                        the last readable Head, Cylinder and Sector_on_track.');
  writeln ('Syntax:');
  writeln ('       #H#C#S /? - to get Help screen without work');
  writeln ('       #H#C#S    - to explore 1st hard disk');
  writeln ('       #H#C#S /2 - to explore 2nd hard disk');

  if ParamStr(1)=''   then                                     else
  if ParamStr(1)='/?' then halt                                else
  if ParamStr(1)='/2' then begin Drive:=$81; ParamInt:=$46 end else
     begin writeln (#10'Invalid parameters'#7); halt end;

  for w:=1 to 80 do write ('=');
  write ('Hard disk #',Drive-($80-1),':    ');
  { --------------------------------------------- Read Partition: --- }
  if not ReadSector (0,0,1) {Head=0,Cyl=0,Sec=1}
     then writeln ('Error reading Partition table'#7)
     else begin
          for i:=1 to 4 do with P^.PE[i] do begin
              MaxHeadP:=MaxWord (MaxHeadP,BegHead,EndHead);
              MaxCylP :=MaxWord (MaxCylP,
                                 hi(BegSecCyl) + (lo(BegSecCyl) shr 6)*256,
                                 hi(EndSecCyl) + (lo(EndSecCyl) shr 6)*256 );
              MaxSecP :=MaxWord (MaxSecP, lo(BegSecCyl) and $3F,
                                          lo(EndSecCyl) and $3F);
          end;
          writeln ('Max values from Partition table: Head-', MaxHeadP,
                   ', Cyl-', MaxCylP, ', Sector-', MaxSecP);
     end;
  { ---------------------------------------- Set new disk params: --- }
  GetIntVec (ParamInt, SaveParamAddr);   {Сохранение адреса исходной таблицы}
  SaveExitProc:=ExitProc;
  ExitProc:=@ExitProcedure;
  if not SetBigDisk then begin     { Установка max значений Head, Cyl, Sect }
     writeln (#10'Change disk parameters error'#7); halt end;
  { -------------------------------------------------- Read disk: --- }
  Start:=0; writeln;      { Поиск последней головки }
  for i:=0 to 1 do
  for w:=Start to $FF do
      if ReadSector(w,i,1) then begin    { Head=w, Cyl=0|1, Sec=1 }
         Start:=w;
         write (#13'Read Cylinder ',i,', Sector 1: last readable Head - ',w);
      end else begin writeln; break end;

  Start:=0; writeln;      { Поиск последнего цилиндра }
  while ( Start<1024-10 ) and ( ReadSector(0,Start+10,1) ) do begin
        inc (Start,10);
        write (#13'Read Head 0, Sector 1: last readable Cylinder - ',Start);
  end;
  for i:=0 to 1 do
  for w:=Start to 1023 do
      if ReadSector(i,w,1) then begin    { Head=0|1, Cyl=w, Sec=1 }
         Start:=w;
         write (#13'Read Head ',i,', Sector 1: last readable Cylinder - ',w);
      end else begin writeln; break end;

  Start:=1; writeln;      { Поиск последнего сектора }
  for i:=0 to 1 do
  for w:=Start to 64 do
      if ReadSector(i,0,w) then begin    { Head=0|1, Cyl=0, Sec=w }
         Start:=w;
         write (#13'Read Head ',i,', Cylinder 0: last readable Sector - ',w);
      end else begin writeln; break end;
end.
