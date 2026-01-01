{$A+,B-,D+,F+,I-,O-,R-,L+}
{************************************************}
{                                                }
{   Lecar v.1.0  2nd Edition                     }
{   Turbo Pascal 5.X, 6.X                        }
{   Попросту, без чинов и Copyright-ов  1991     }
{                                                }
{************************************************}

Unit LogDisk;

{
  Предназначен для чтения/записи логических дисков в системах
  MS DOS и PC DOS версий 2.XX, 3.XX, 4.XX, 5.00
}

Interface

Var
  DosVersion : Byte;    { для различных версий обработчик int 25,26 отличается }

Function DiskRead( Drive: Byte; StartSect: Longint; SectNum: Word; Var Buff ): Boolean;
 { Предназначена для чтения логических секторов. Возвращает True, если
   чтение выполнено успешно }
Function DiskWrite( Drive: Byte; StartSect: Longint; SectNum: Word; Var Buff ): Boolean;
 { Предназначена для записи логических секторов. Возвращает True, если
   чтение выполнено успешно }

Implementation

Uses Dos;

Type
  TPacket = Record             { Формат пакета данных для обработчиков }
    StartSect : Longint;       { Int 25,26 в системах старше 3.XX }
    SectNum   : Word;
    Buff      : Pointer;
  End;

Var
  Regs   : Registers;
  Packet : TPacket;

Function DiskRead( Drive: Byte; StartSect: Longint; SectNum: Word; Var Buff ): Boolean;
  Var
     Start : Word;
  Begin
    DiskRead := False;
    If Drive > Byte('Z')-Byte('A') then Exit;   { Проверка на корректность входных данных }
    If DosVersion <= 3 then begin               { Версия DOS ниже 4.XX }
      If StartSect >= $FFFF then Exit else Start := StartSect;
      Inline(
        $1E/                   {           push ds                          }
        $8B/$46/<Buff/         {           mov  ax, word ptr [Buff]         }
        $8B/$D8/               {           mov  bx, ax                      }
        $8B/$46/<Buff+2/       {           mov  ax, word ptr [Buff+2]       }
        $8E/$D8/               {           mov  ds, ax                      }
        $8B/$46/<SectNum/      {           mov  ax, word ptr [SectNum]      }
        $8B/$C8/               {           mov  cx, ax                      }
        $8B/$46/<Start/        {           mov  ax, word ptr [Start]        }
        $8B/$D0/               {           mov  dx, ax                      }
        $8A/$46/<Drive         {           mov  al, byte ptr [Drive]        }
            );
    end
    else begin
      Packet.StartSect := StartSect;
      Packet.SectNum := SectNum;
      Packet.Buff := Ptr(Seg(Buff),Ofs(Buff));
      Inline(
        $1E/                   {           push ds                          }
        $B9/$FFFF/             {           mov  cx, 0FFFFh                  }
        $8D/$1E/>Packet/       {           lea  bx, word ptr [Packet]       }
        $8A/$46/<Drive         {           mov  al, byte ptr [Drive] }
            );
    end;
    Inline(
      $55/                   {           push bp                          }
      $CD/$25/               {           int  25h                         }
      $5D/                   {           pop  bp                          }
      $5D/                   {           pop  bp                          }
      $72/$05/               {           jc   Error                       }
      $B8/>$0001/            {           mov  ax, 1                       }
      $EB/$03/               {           jmp  short Exit                  }
                             {     Error:                                 }
      $B8/>$0000/            {           mov  ax, 0                       }
                             {     Exit:                                  }
      $88/$46/$FF/           {           mov  [bp-1], al                  }
      $1F                    {           pop  ds                          }
          );
  End;

Function DiskWrite( Drive: Byte; StartSect: Longint; SectNum: Word; Var Buff ): Boolean;
  Var
    Start : Word;
  Begin
    DiskWrite := False;
    If Drive > Byte('Z')-Byte('A') then Exit;
    If DosVersion <= 3 then begin               { Версия DOS ниже 4.XX }
      If StartSect >= $FFFF then Exit else Start := StartSect;
      Inline(
        $1E/                   {           push ds                          }
        $8B/$46/<Buff/         {           mov  ax, word ptr [Buff]         }
        $8B/$D8/               {           mov  bx, ax                      }
        $8B/$46/<Buff+2/       {           mov  ax, word ptr [Buff+2]       }
        $8E/$D8/               {           mov  ds, ax                      }
        $8B/$46/<SectNum/      {           mov  ax, word ptr [SectNum]      }
        $8B/$C8/               {           mov  cx, ax                      }
        $8B/$46/<Start/        {           mov  ax, word ptr [Start]        }
        $8B/$D0/               {           mov  dx, ax                      }
        $8A/$46/<Drive         {           mov  al, byte ptr [Drive]        }
            );
    end
    else begin
      Packet.StartSect := StartSect;
      Packet.SectNum := SectNum;
      Packet.Buff := Ptr(Seg(Buff),Ofs(Buff));
      Inline(
        $1E/                   {           push ds                          }
        $B9/$FFFF/             {           mov  cx, 0FFFFh                  }
        $8D/$1E/>Packet/       {           lea  bx, word ptr [Packet]       }
        $8A/$46/<Drive         {           mov  al, byte ptr [Drive]        }
            );
    end;
    Inline(
      $55/                   {           push bp                          }
      $CD/$26/               {           int  26h                         }
      $5D/                   {           pop  bp                          }
      $5D/                   {           pop  bp                          }
      $72/$05/               {           jc   Error                       }
      $B8/>$0001/            {           mov  ax, 1                       }
      $EB/$03/               {           jmp  short Exit                  }
                             {     Error:                                 }
      $B8/>$0000/            {           mov  ax, 0                       }
                             {     Exit:                                  }
      $88/$46/$FF/           {           mov  [bp-1], al                  }
      $1F                    {           pop  ds                          }
          );
  End;

Begin
  Regs.AH := $30;
  MsDos( Regs );            { Узнать версию системы }
  DosVersion := Regs.AL;    { и сохранить в себе }
End.