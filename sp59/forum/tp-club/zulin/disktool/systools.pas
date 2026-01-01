{$A+,B-,D+,E-,F-,I-,L+,N-,O-,R-,S-}
{
      █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
      █                                                             █▒▒
      █                         SysTools                            █▒▒
      █                                                             █▒▒
      █   (C) Copyright BZSoft, sep 1992.                           █▒▒
      █   (C) Copyright GalaSoft United Group International, 1992.  █▒▒
      █                                                             █▒▒
      █                        version 1.00                         █▒▒
      █                                                             █▒▒
      █                                                             █▒▒
      █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▒▒
        ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
}
unit SysTools;

Interface

uses Dos;

const CBreakPressed  : boolean = false; { нажата ^C }
const DivideOnZero   : boolean = false; { было деление на ноль? }
const POSTptr        : LongInt = $FFFF0000;

var
    Int00Save,
    Int1BSave : pointer;
procedure ColdReboot;
procedure WarmReboot;
procedure HangMachine;
procedure StopMachine;
procedure LockKeyboard;
procedure UnLockKeyboard;
procedure SetBreakInt;
procedure RestoreBreakInt;
procedure SetDivZeroInt;
procedure RestoreDivZeroInt;

Implementation

procedure ColdReboot; assembler;
asm
        MOV     AX, 40h
        MOV     ES, AX
        MOV     DI, 72h
        MOV     WORD PTR ES:[DI], 0
        JMP     DWORD PTR POSTptr
end;

procedure WarmReboot; assembler;
asm
        MOV     AX, 40h
        MOV     ES, AX
        MOV     DI, 72h
        MOV     WORD PTR ES:[DI], 1234h
        JMP     DWORD PTR POSTptr
end;

procedure HangMachine; assembler;
asm
        CLI
        MOV     DX, 61h
        IN      AL, DX
        OR      AL, 10000000b
        OUT     DX, AL
        XOR     AX, AX
        MOV     ES, AX
        MOV     BX, 33h*4
        PUSH    CS
        POP     AX
        MOV     DX, OFFSET CS:@IRET
        MOV     WORD PTR ES:[BX], DX
        MOV     WORD PTR ES:[BX+2], AX
        MOV     BX, 1Ch*4
        MOV     WORD PTR ES:[BX], DX
        MOV     WORD PTR ES:[BX+2], AX
        STI
@CYCLE:
        JMP     @CYCLE
@IRET:
        IRET
end;

procedure StopMachine; assembler;
asm
        CLI
        HLT
end;

procedure LockKeyboard; assembler;
asm
        CLI
        MOV     DX, 61h
        IN      AL, DX
        OR      AL, 10000000b
        OUT     DX, AL
        STI
end;

procedure UnLockKeyboard; assembler;
asm
        CLI
        MOV     DX, 61h
        IN      AL, DX
        AND     AL, 01111111b
        OUT     DX, AL
        STI
end;

{$F+}
procedure LookBreak; Interrupt;
{ Перехватчик ^C }
begin
CBreakPressed:=true;
end;

procedure SetDivZeroFlag; Interrupt;
{ Перехватчик деления на нуль }
begin
DivideOnZero:=true;
end;
{$F-}

procedure SetBreakInt;
{ Устанавливает ловушку ^Break }
begin
   GetIntVec($1B,Int1BSave);
   SetIntVec($1B,Addr(LookBreak))
end;

procedure RestoreBreakInt;
{ Восстанавливает ловушку ^Break }
begin
   SetIntVec($1B,Int1BSave)
end;

procedure SetDivZeroInt;
{ Устанавливает ловушку деления на нуль }
begin
   GetIntVec($00,Int00Save);
   SetIntVec($00,Addr(SetDivZeroFlag))
end;

procedure RestoreDivZeroInt;
{ Восстанавливает ловушку деления на нуль }
begin
   SetIntVec($00,Int00Save)
end;

end.
