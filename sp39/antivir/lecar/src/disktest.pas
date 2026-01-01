{$A+,B-,D-,F+,I-,O-,R-,L-}
{************************************************}
{                                                }
{   Lecar v.1.0  2nd Edition                     }
{   Turbo Pascal 5.X, 6.X                        }
{   Попросту, без чинов и Copyright-ов  1991     }
{                                                }
{************************************************}

Unit DiskTest;

{ Предназначен для обнаружения Boot-СДЯВов, вариант начальный
  и подлежит серьезной доработке, нуждаемся в процедуре чтения
  логического сектора. Основной модуль - TestDisk.
}

Interface

Procedure TestDisk ( DiskName : Byte );
Type
   VirusType = (
                  COM1,  { Обычный JMP, сам в концу файла }
                  COM2,  { Исходные данные отмеряются от конца COM2Type }
                  COM3,  { Заглушка }
                  EXE1,  { Точка входа на себя, сам в конце файла }
                  EXE2,  { Заглушка }
                  EXE3,  { Заглушка }
                  Other, { подарки }
                  Delete,{ Перезаписывющие }
                  None,  { Ни знаю как лечить }
                  Boot,  { Только в Boot }
                  Part   { еще и в Partition }
                 );


Implementation

Uses
    Crt,
    Dos,    { Для использования Intr, Registers }
    Memvir; { Имена СДЯВов }

Type
    DiskStatusT = ( { Для корректной работы чтения абс. секторов }
                   HardDisk,
                   FloppyDisk
                  );
    { Структура для обнаружения Boot-СДЯВов :
      ищет в считанном секторе байты из поля Memo с смещением
      из поля Offs соответственно.
    }
    DiskVirusType = Record
                          Maska : Array [0..4] of Byte;
                          Offs  : Array [0..4] of Word;
                          Name  : Word;
                          VType : VirusType;
                    End;

Const
     Max_Boot = 2;          { Общее число Boot-СДЯВов }
     I        : Integer = 0;
     J        : Integer = 0;
     K        : Integer = 0;

     { Данные по Boot-СДЯВам }
     Vir_Boot      : Array [1..Max_Boot] of DiskVirusType =
                   (
                    (
                      Maska   : ($29,$FA,$FA,$BC,$F0); { Den - Zuk }
                      Offs    : ($01,$2B,$2C,$33,$35);
                      Name    : 4;
                      VType   : Boot
                    ),
                    (
                      Maska   : ($EA,$05,$00,$C0,$07); { Stone }
                      Offs    : ($00,$01,$02,$03,$04);
                      Name    : 1;
                      VType   : Part
                    )
                   );

Var
    Buffer     : Array [0..511] of Byte;
    DiskStatus : DiskStatusT;
    FindVirus  : Boolean;
    Regs       : Registers;

{ Устанавливает тип диска, если возвращает False, такого диска нет }
Function GetDiskStatus (DiskName:Byte) : Boolean;
Var
   Tmp : ^Byte;

Begin
     GetDiskStatus := True;
     Regs.BL := DiskName+1;
     Regs.AX := $440E;
     MsDos ( Regs );
     If Regs.AX = 15 then GetDiskStatus := False { такого диска нет }
     else begin
          Regs.AH := $1C;
          Regs.DL := DiskName+1;
          MsDos (Regs);
          Tmp := Ptr (Regs.DS,Regs.BX);
          If  Tmp^= $F8 then DiskStatus := HardDisk
             else DiskStatus := FloppyDisk;
     end;
End;

{Read absolute disk sector,return TRUE or FALSE}
Function ReadSector (Drive : Byte; Head: Byte; Track: Byte; Sector: Byte;
                     Count : Byte; Var Buff) : Boolean;
Var
   Regs : Registers;
Begin
     Regs.AH := $02; { Read sector }

     If ( DiskStatus = HardDisk ) then Regs.DL := $80
        else Regs.DL := Drive;

     Regs.DH := Head;
     Regs.CH := Track;
     Regs.CL := Sector;
     Regs.AL := Count;
     Regs.ES := Seg( Buffer );
     Regs.BX := Ofs( Buffer );
     Intr ( $13, Regs);
     ReadSector := Not Odd( LongInt(Regs.Flags) );
End;

{Write absolute disk sector,return TRUE or FALSE}
Function WriteSector (Drive : Byte; Head: Byte; Track: Byte; Sector: Byte;
                      Count : Byte; Var Buffer) : Boolean;
Begin
     Regs.AH := $03; { Write sector }

     If ( DiskStatus = HardDisk ) then Regs.DL := $80
        else Regs.DL := Drive;

     Regs.DH := Head;
     Regs.CH := Track;
     Regs.CL := Sector;
     Regs.AL := Count;
     Regs.ES := Seg( Buffer );
     Regs.BX := Ofs( Buffer );
     Intr ( $13, Regs);
     WriteSector := Not Odd( LongInt(Regs.Flags) );
End;

{ Удаление вируса }
Procedure ClearDisk ( Virus_ID : Integer; Drive : Byte );
Begin
     If Vir_Boot[I].Name = 1 then begin
     { Stone standart}
        If DiskStatus = HardDisk then
           If (Not ReadSector  ( Drive , 0, 0, 7, 1, Buffer )) OR
              (Not WriteSector ( Drive , 0, 0, 1, 1, Buffer )) then Exit
        else begin
             If (Not ReadSector  ( Drive , 1, 0, 3, 1, Buffer )) OR
                (Not WriteSector ( Drive , 0, 0, 1, 1, Buffer )) then Exit;
             For K := 0 to 511 do Buffer[K] := 0;
             If Not WriteSector ( Drive , 1, 0, 3, 1, Buffer ) then Exit;
        end;
     end

     { Den - Zuk }
     else If Vir_Boot[I].Name = 4 then begin
             If (Not ReadSector  ( Drive , 0, $28, $21, 1, Buffer )) OR
                (Not WriteSector ( Drive , 0,   0,   1, 1, Buffer )) then Exit;
          end
     else;
End;

{ Поиск вируса в считанном буфере }
Procedure VerifyBuffer (Drive : Byte);
Var
   I, J    : Integer;
   Present : Boolean;

Begin
     For I := 1 to Max_Boot do begin
       Present := True;
       J := 0;
       Repeat
             If Buffer[Vir_Boot[I].Offs[J]] <> Vir_Boot[I].Maska[J]
               then Present := False;
             Inc (J);
       Until (NOT Present) OR (J>4);

       FindVirus := Present;
       If Present then begin
          Write ( ' вирус ', Virus_Name[Vir_Boot[I].Name] );
          If Vir_Boot[I].Vtype = None then begin { неизвестно как лечить }
             FindVirus := False; {чтобы не циклить на незнакомом}
             WriteLn (' в следующей версии');
          end
          else ClearDisk ( I, Drive ); { вылечить, если известно как }
       end;

     end; { For }
End;

{ Основной модуль }
Procedure TestDisk ( DiskName : Byte );
Var
   Char_Drive : Char;

Begin
     FindVirus := True;
     Char_Drive := Char( DiskName + Byte('A')  );
     If GetDiskStatus (DiskName) then begin { если таковой диск есть }
        While FindVirus do begin { Для раскручивания матрешек }
           If Not ReadSector ( DiskName, 0,0, 1, 1, Buffer ) then Exit;
           Write ( #13,Char_Drive,': А ну-ка ' );
           VerifyBuffer ( DiskName );
           If DiskStatus = HardDisk then begin
              If Not ReadSector ( DiskName, 1, 0, 1, 1, Buffer ) then Exit;
              Write ( #13,Char_Drive,': А ну-ка, а ну-ка ' );
              VerifyBuffer ( DiskName );
           end;
        end;
     end;

     Write( #13,' ':40, #13 );
End;

End.