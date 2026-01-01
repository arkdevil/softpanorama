{$B-,N+,E+,I-,D-}
{**************************************************************}
{*                                                            *}
{*                        BZSoft 1990                         *}
{*                                                            *}
{**************************************************************}

{ Routine for search Disk Number }

uses
    Dos,
    Crt,
    TPDos;

VAR
    INT11Dat    : Word absolute $0:$0410;
    NumFloppy,
    NumDr,I     : BYTE;
    LD          : byte;
    r           : registers;
    d           : byte;

begin
 d:=NumberOfDrives;
 d:=ord(d)-64;
 r.dl := d;
 r.ah := $32;
 MsDos(r);
 While r.al=$0FF do begin dec(d); r.dl := d; MsDos(r); end;
 LD:=64+d;
if (INT11dat and $0001)=0 then
     NumFloppy := 0
   else
     begin
       case (INT11Dat and $00C0) of
          $00 : NumFloppy := 1;
          $40 : NumFloppy := 2;
          $80 : NumFloppy := 3;
          $C0 : NumFloppy := 4;
       end;
   end;
   NumDr := LD - 64 - ( NumFloppy and 1 );
if HandleIsConsole(StdOutHandle) Then
Writeln ('     BZSoft 1990. ( ',NumDr,' active logical (disk) drives found.)');
Halt(NumDr);
end.
