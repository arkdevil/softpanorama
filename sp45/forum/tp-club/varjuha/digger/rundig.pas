
{ Катапульта, веpсия 1.0  }
{ Сеpгей Ваpюха, год 1991 }

{$A-,B-,D+,E-,F-,G-,I-,L+,N-,O-,R-,S-,V-,X-}
{$M 16384,0,655360}

program RunDigger;
uses
  Crt,
  TpInline,
  Memory,
  Dos;

{$DEFINE UseCommand}

var
  SaveInt08 : pointer;
  Status, I : byte;
  Vectors   : array [1..1024] of byte;
  S         : string;

  procedure Abort;
  begin
    SetIntVec($08, SaveInt08);
    Sound(1000);
    Delay(50);
    NoSound;
    Move(Vectors, mem[0:0], 1024);
    Halt(255)
  end;

  procedure Int08(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP:Word);
  interrupt;

    procedure SwapCsIp;
    begin
      SetIntVec($08, SaveInt08);
      CS := Seg(Abort);
      IP := Ofs(Abort)
    end;

  begin
    CallOldIsr(SaveInt08);
    asm
      mov    ah, 02h
      xor    dx, dx
      int    17h
      mov    al, Status
      cmp    ah, al
      je     @Exit
      push   ax
      call   Abort
      pop    ax
    @Exit:
      mov    Status, ah
    end
  end;

begin
  Writeln('Digger Killer ■ Version 1.0 ■ Copyright (c) 1991 by Serge N. Varjukha');
  Writeln('Usage: rundig ProgramName');
  Writeln('Switch printer power button to abort started ProgramName.');
  Move(mem[0:0], Vectors, 1024);
  S := '';
  for I := 2 to ParamCount do S := S + ParamStr(I) + ' ';
  asm                    { Get printer status }
    mov  ah, 02h
    xor  dx, dx
    int  17h
    mov  Status, ah
  end;
  GetIntVec($08, SaveInt08);
  SetIntVec($08, @Int08);
  SetMemTop(HeapPtr);
  SwapVectors;

{$IFDEF UseCommand}
  Exec(GetEnv('COMSPEC'), ' /C '+ParamStr(1)+ S); {Path searching allowed}

{$ELSE}
  Exec(ParamStr(1), S);        {Full program name must be specified}
{$ENDIF}

  SwapVectors;
  SetMemTop(HeapEnd);
  SetIntVec($08, SaveInt08);
end.
{eof rundig.pas}


▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

                   This page kidnapped from Tech Help 4.0

▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

 These functions provide access to the parallel printer ports (LPT1, etc.)
 The printer port addresses are stored starting at 0:0408.  See BIOS Data
 See Printer Ports for a description of the hardware interface.               
 Printer timeout values start at 0:0478.  Print Screen routine is INT 05H     
                                                                              
AH  Service                                                                   
▀▀▀ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
00H Print a character                                                         
    Input: AL = ASCII character.  See also: ASCII Control Codes               
           DX = printer number (0,1, or 2)                                    
   Output: AH = 01H if character could not be printed (timeout occurred)      
                other bits set as in SubFn 02H (status flags)                 
                                                                              
01H initialize a printer port                                                 
    Input: DX = printer number (0,1, or 2)                                    
   Output: AH = set as in SubFn 02H (status flags)                            
                                                                              
02H get printer status                                                        
    Input: DX = printer number (0,1, or 2)                                    
   Output: AH = printer status flags                                          
           ╓7┬6┬5┬4┬3┬2┬1┬0╖
           ║ │ │ │ │ │   │ ║                                                  
           ╙╥┴╥┴╥┴╥┴╥┴─┴─┴╥╜                                                  
            ║ ║ ║ ║ ║ ╚╦╝ ╚═> timeout      (AH & 01H)                         
            ║ ║ ║ ║ ║  ╚════> (not used)                                      
            ║ ║ ║ ║ ╚═══════> I/O error    (AH & 08H)                         
            ║ ║ ║ ╚═════════> selected     (AH & 10H) (00H means off-line)    
            ║ ║ ╚═══════════> out of paper (AH & 20H)                         
            ║ ╚═════════════> acknowledge  (AH & 40H) (40H = printer attached)
            ╚═══════════════> not busy     (AH & 80H) note: 0 means busy      
──────────────────────────────────────────────────────────────────────────────
