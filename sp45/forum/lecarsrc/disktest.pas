{$A+,B-,D+,F+,I-,O-,R-,L+}
{************************************************}
{                                                }
{   Lecar v.1.0  2nd Edition                     }
{   Turbo Pascal 5.X, 6.X                        }
{   Попросту, без чинов и Copyright-ов  1991     }
{                                                }
{************************************************}

Unit DiskTest;

{
  Предназначен для обнаружения Boot-СДЯВов, вариант начальный
  и подлежит серьезной доработке. Основной модуль - TestDisk.
}

Interface

Const
     Fag : Boolean = False;

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
                  Part,  { еще и в Partition }
                  Sys    { драйвера }
                 );


Implementation

Uses
    Crt,
    Dos,    { Для использования Intr, Registers }
    Memvir, { Имена СДЯВов }
    LogDisk;{ Процедуры чтения/записи логических секторов(int 25/26) }

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
     Max_Boot = 9;          { Общее число Boot-СДЯВов }
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
                      Maska   : ($90,$8E,$D0,$BC,$00); { Sex Revolution }
                      Offs    : ($A5,$A6,$A7,$A8,$A9);
                      Name    : 79;
                      VType   : Part
                    ),
                    (
                      Maska   : ($FA,$B4,$0E,$B7,$00); { Stone }
                      Offs    : ($A5,$122,$123,$124,$125);
                      Name    : 1;
                      VType   : Part
                    ),
                    (
                      Maska   : ($13,$BA,$80,$00,$89); { Rostov }
                      Offs    : ($10D,$122,$123,$124,$125);
                      Name    : 86;
                      VType   : Part
                    ),
                    (
                      Maska   : ($8E,$C0,$8E,$D0,$BC); { Hercen RBSE 2048 }
                      Offs    : ($26,$27,$2C,$2D,$2E);
                      Name    : 84;
                      VType   : Boot
                    ),
                    (
                      Maska   : ($26,$F8,$7D,$80,$F9); { Ping-Pong RB1024 }
                      Offs    : ($4F,$50,$51,$52,$56);
                      Name    : 3;
                      VType   : Boot
                    ),
                    (
                      Maska   : ($26,$FA,$7D,$80,$F7); { Misspeller RB2048 }
                      Offs    : ($4F,$50,$51,$52,$56);
                      Name    : 87;
                      VType   : Boot
                    ),
                    (
                      Maska   : ($B8,$03,$00,$E8,$1F); { Flip }
                      Offs    : ($09,$0A,$0B,$0C,$0D);
                      Name    : 16;
                      VType   : Part
                    ),
                    (
                      Maska   : ($50,$8B,$0E,$08,$00); { Mikelangelo }
                      Offs    : ($BD,$103,$104,$105,$106);
                      Name    : 92;
                      VType   : Part
                    )
                   );

Var
    Buffer     : Array [0..511] of Byte;
    CBuffer    : Array [0..511] of Char Absolute Buffer;
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
var Regs : Registers;
    F    : File;
Begin
  Case Vir_Boot[Virus_ID].Name of
 1,92: begin { Stone standart}
        If DiskStatus = HardDisk then
           If (Not ReadSector  ( Drive , 0, 0, 7, 1, Buffer )) OR
              (Not WriteSector ( Drive , 0, 0, 1, 1, Buffer )) then Exit
           else
        else begin
              If (Not ReadSector  ( Drive , 1, 0, 3, 1, Buffer )) OR
                 (Not WriteSector ( Drive , 0, 0, 1, 1, Buffer )) then Exit;
              For K := 0 to 511 do Buffer[K] := 0;
              If Not WriteSector ( Drive , 1, 0, 3, 1, Buffer ) then Exit;
             end;
       end;
   79: begin { Export of Sex Revolution }
        If DiskStatus = HardDisk then
           If (Not ReadSector  ( Drive , 0, 0, 8, 1, Buffer )) OR
              (Not WriteSector ( Drive , 0, 0, 1, 1, Buffer )) then Exit
           else
        else begin
              If (Not ReadSector  ( Drive , 1, 0, 3, 1, Buffer )) OR
                 (Not WriteSector ( Drive , 0, 0, 1, 1, Buffer )) then Exit;
              For K := 0 to 511 do Buffer[K] := 0;
              If Not WriteSector ( Drive , 1, 0, 3, 1, Buffer ) then Exit;
             end;
       end;
   86: begin { Rostov }
        If DiskStatus = HardDisk then
           If (Not ReadSector  ( Drive , 0, 0, 2, 1, Buffer )) OR
              (Not WriteSector ( Drive , 0, 0, 1, 1, Buffer )) then Exit
           else
        else begin
              If (Not ReadSector  ( Drive , 1, 0, 3, 1, Buffer )) OR
                 (Not WriteSector ( Drive , 0, 0, 1, 1, Buffer )) then Exit;
              For K := 0 to 511 do Buffer[K] := 0;
              If Not WriteSector ( Drive , 1, 0, 3, 1, Buffer ) then Exit;
             end;
       end;
    4: begin { Den - Zuk }
            If (Not ReadSector  ( Drive , 0, $28, $21, 1, Buffer )) OR
               (Not WriteSector ( Drive , 0,   0,   1, 1, Buffer )) then Exit;
       end;
    3: begin { Ping-Pong RB1024 }
         If (Not DiskRead(Drive,0,1,Buffer)) OR
            (Not DiskRead(Drive,((Buffer[$1FA] Shl 4)+Buffer[$1F9]+1),1,Buffer)) then Exit
            else If DiskWrite(Drive,0,1,Buffer) then Exit;
       end;
   87: begin { Misspeller RB1024 }
         If (Not DiskRead(Drive,0,1,Buffer)) OR
            (Not DiskRead(Drive,((Buffer[$1F8] Shl 4)+Buffer[$1F7]+1),1,Buffer)) then Exit
            else If DiskWrite(Drive,0,1,Buffer) then Exit;
       end;
    84:begin { Hercen RBSE2048 }
         If Not DiskRead(Drive, 0, 1, Buffer) then Exit;
         With Regs do begin
           CH := $2;
           AX := (Word(Buffer[$1FA]) Shl 8) + Buffer[$1F9];
           DX := AX MOD (Word(Buffer[$19]) Shl 8+Buffer[$18]);
           AX := AX DIV (Word(Buffer[$19]) Shl 8+Buffer[$18]);
           Inc(DL);
           BX := DX;
           DX := AX MOD (Word(Buffer[$1B]) Shl 8+Buffer[$1A]);
           AX := AX DIV (Word(Buffer[$1B]) Shl 8+Buffer[$1A]);
           CH := AL;
           CL := $6;
           AH := AH Shl CL;
           CL := AH;
           DH := BL;
           CL := CL OR DH;
           DH := DL;
         end;
         If Not ReadSector (Drive , Regs.DH, Regs.CH,Regs.CL,1, Buffer) then;
         If Not DiskWrite(Drive, 0, 1, Buffer) then;
       end;
    16:begin
         If Not ReadSector(Drive ,0,0,1,1,Buffer) then;
         With Regs do begin
           CH := Buffer[$2B];
           CL := Buffer[$2A];
           DH := Buffer[$2D];
           DL := Buffer[$2C];
         end;
         If Not ReadSector (Drive , Regs.DH, Regs.CH,Regs.CL,1, Buffer) then;
         If (Buffer[510]=$55) AND (Buffer[511]=$AA) then
            If Not WriteSector (Drive , 0, 0, 1,1, Buffer) then else
         else Write (' не');
       end;
  end {Case};
  WriteLn(' дезактивировал');
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
          If (Vir_Boot[I].Vtype = None) OR (Not Fag) then begin { неизвестно как лечить }
             FindVirus := False; {чтобы не циклить на незнакомом}
             WriteLn (' - пустите меня с /f');
          end
          else ClearDisk ( I, Drive ); { вылечить, если известно как }
          I := Max_Boot;
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
           Write ( #13,'Master Boot диска '+ Char_Drive+':' );
           VerifyBuffer ( DiskName );
           If DiskStatus = HardDisk then begin
              If Not DiskRead( DiskName, 0, 1, Buffer ) then Exit;
              Write ( #13,'Boot диска '+Char_Drive+':' );
              VerifyBuffer ( DiskName );
           end;
        end;
     end;

     Write( #13,' ':40, #13 );
End;

End.