{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,R-,S-,V-,X+}

UNIT AuxDos;

{Auxiliary DOS-Interface-Routines}
{Written by Christoph H. Hochstätter}
{FixDisk added by Alexander V. Sessa}
{Written in Turbo-Pascal 6.0}

INTERFACE

USES dos;

{File open mode and sharing constants}

CONST OReadOnly = 0;
  OWriteOnly    = 1;
  OReadWrite    = 2;
  OCompatibility= $00;
  ODenyAll      = $10;
  ODenyWrite    = $20;
  ODenyRead     = $30;
  ODenyNone     = $40;
  ONoInheritance= $80;

{DOS-File-Handles}

CONST StdNulHandle = 0;
  StdOutHandle     = 1;
  StdErrHandle     = 2;

VAR StdErr        : Text;                       {Define a file variable for standard error output}
    old1B         : Pointer;                                       {Save old Ctrl-Break-Interrupt}
    old23         : Pointer;                                     {Save Old abnormal End Procedure}

CONST ExitRequest : Boolean   = FALSE;                                       {Ctrl-Break pressed?}

PROCEDURE CtrlBreak;
PROCEDURE EndProgram(x: Byte;s: String);
PROCEDURE DefExitProc;
PROCEDURE IgnoreInt;

IMPLEMENTATION

  PROCEDURE CtrlBreak; Assembler;                     {Don't invoke directly (or go to neverland)}
  ASM
    push    ds                 {Save DS}
    push    ax                 {Save AX, because it is interrupt}
    mov     ax,seg @data       {Get data segment in AX}
    mov     ds,ax              {Put it in DS}
    pop     ax                 {Restore AX}
    mov     ExitRequest,True   {Set ExitRequest}
    pop     ds                 {Restore DS}
    iret                       {Exit}
  END;

  PROCEDURE IgnoreInt; Assembler;
  ASM
    iret
  END;

  PROCEDURE FixDisk; Assembler;
  ASM
    push    ds
    xor     ax,ax
    mov     ds,ax
    mov     si,1
  @1:
    mov     al,ds:[$490+si]
    and     al,$C0
    cmp     al,$40
    jne     @2
    mov     byte ptr ds:[$490+si],$61
  @2:
     dec     si
     jz      @1
     pop     ds
  END;

  PROCEDURE EndProgram;
  BEGIN
    IF ExitRequest THEN BEGIN
      WriteLn(stderr,#13#10,s);
      Halt(x);
    END;
  END;

  PROCEDURE DefExitProc;                                                  {Default Exit-Procedure}
  BEGIN
    SetIntVec($1B,old1B);                                       {Restore old Ctrl-Break-Procedure}
    SetIntVec($23,old23);                                   {Restore old abnormal abort Procedure}
    FixDisk;
    ExitProc:=NIL;
  END;

BEGIN
  move(Output,stderr,SizeOf(stderr));           {Copy Standard-Output File to Standard-Error File}
  TextRec(stderr).Handle:=StdErrHandle;                      {Standard-Error is DOS-File-Handle 2}
  TextRec(stderr).BufPtr:=@TextRec(stderr).Buffer;                            {set our own Buffer}
  GetIntVec($1B,old1B);                                            {Save old Ctrl-Break interrupt}
  GetIntVec($13,old23);
  ExitProc:=@DefExitProc;                             {Restore Ctrl-Break-Interrupt, when exiting}
END.





