{$A+,B-,D+,F+,I-,O-,R-,L+}
{************************************************}
{                                                }
{   Lecar v.2.0                                  }
{   Turbo Pascal 6.X                             }
{   Попросту, без чинов и Copyright-ов  1992     }
{                                                }
{************************************************}

Unit Disk;

{
  Предназначен для чтения/записи логических дисков в системах
  MS DOS и PC DOS версий 2.XX, 3.XX, 4.XX, 5.00
}

Interface

{ Предназначена для чтения логических секторов. Возвращает True, если чтение выполнено успешно }
function DiskRead(Drive: Byte; StartSect: Longint; SectNum: Word; Var Buff): Word;
{ Предназначена для записи логических секторов. Возвращает True, если чтение выполнено успешно }
function DiskWrite(Drive: Byte; StartSect: Longint; SectNum: Word; Var Buff): Word;
function AbsRead(Drive:Byte; Track:Word; Head,Sector,Count : Byte; Var Buff) : Byte;
function AbsWrite(Drive:Byte; Track:Word; Head,Sector,Count : Byte; Var Buff) : Byte;

Implementation

Uses Dos, ErrHand;

Type
  TPacket = Record             { Формат пакета данных для обработчиков }
    StartSect : Longint;       { Int 25,26 в системах старше 3.XX }
    SectNum   : Word;
    Buff      : Pointer;
  End;

Var
  Packet : TPacket;
  DOSV   : Word;

function DiskRead(Drive: Byte; StartSect: Longint; SectNum: Word; Var Buff) : Word;
Var
  Start : Word;
begin
  DiskRead := $0D;
  If Drive > Byte('Z')-Byte('A') then Exit;   { Проверка на корректность входных данных }
  If Lo(DOSV) <= 3 then                       { Версия DOS ниже 4.XX }
  begin
    If StartSect >= $FFFF then Exit else Start := StartSect;
    asm
      push  ds
      lds   bx,  Buff
      mov   cx,  SectNum
      mov   dx,  Start
      mov   al,  Drive
    end;
  end
  else begin
    Packet.StartSect := StartSect;
    Packet.SectNum := SectNum;
    Packet.Buff := Ptr(Seg(Buff),Ofs(Buff));
    asm
      push  ds
      mov   cx,  0FFFFh
      lea   bx,  Packet
      mov   al,  Drive
    end;
  end;
  asm
    push bp
    int  25h
    pop  bp
    pop  bp
    pop  ds
    jc   @Error
    xor  ax,  ax
    jmp  @Exit
  @Error:
    call GetError
  @Exit:
    mov  word ptr [bp-02], ax
  end;
end;

function DiskWrite(Drive: Byte; StartSect: Longint; SectNum: Word; Var Buff) : Word;
Var
  Start : Word;
begin
  DiskWrite := $0D;
  If Drive > Byte('Z')-Byte('A') then Exit;   { Проверка на корректность входных данных }
  If Lo(DOSV) <= 3 then                       { Версия DOS ниже 4.XX }
  begin
    If StartSect >= $FFFF then Exit else Start := StartSect;
    asm
      push  ds
      lds   bx,  Buff
      mov   cx,  SectNum
      mov   dx,  Start
      mov   al,  Drive
    end;
  end
  else begin
    Packet.StartSect := StartSect;
    Packet.SectNum := SectNum;
    Packet.Buff := Ptr(Seg(Buff),Ofs(Buff));
    asm
      push  ds
      mov   cx,  0FFFFh
      lea   bx,  Packet
      mov   al,  Drive
    end;
  end;
  asm
    push bp
    int  26h
    pop  bp
    pop  bp
    pop  ds
    jc   @Error
    xor  ax,  ax
    jmp  @Exit
  @Error:
    call GetError
  @Exit:
    mov  word ptr [bp-02], ax
  end;
end;

{Read absolute disk sector, return error code}
function AbsRead(Drive:Byte; Track:Word; Head,Sector,Count : Byte; Var Buff) : Byte; Assembler;
asm
  mov  ah,  02h      { Read sector }
  mov  dl,  Drive
  mov  dh,  Head
  mov  cl,  02h
  mov  bx,  Track
  shr  bx,  cl
  and  bl,  011000000b
  mov  cl,  Sector
  and  cl,  0111111b
  or   cl,  bl
  mov  ch,  byte ptr Track
  mov  al,  Count
  les  bx,  Buff
  int  13h
  jc   @Error
  xor  ax,  ax
@Error:
  mov  al,  ah
end;

{Write absolute disk sector,return error code}
function AbsWrite(Drive:Byte; Track:Word; Head,Sector,Count : Byte; Var Buff) : Byte; Assembler;
asm
  mov  ah,  03h      { Write sector }
  mov  dl,  Drive
  mov  dh,  Head
  mov  cl,  02h
  mov  bx,  Track
  shr  bx,  cl
  and  bl,  011000000b
  mov  cl,  Sector
  and  cl,  0111111b
  or   cl,  bl
  mov  ch,  byte ptr Track
  mov  al,  Count
  les  bx,  Buff
  int  13h
  jc   @Error
  xor  ax,  ax
@Error:
  mov  al,  ah
end;

Begin
  DOSV := DosVersion;
End.