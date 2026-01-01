(*
TSREXAMP
example for using TSRUNIT v1.10
Copyright (c) 1995 Nir Sofer, All rights reserved


*)

{$f+}
{$m $800,0,0}
{$s-,r-}
uses tsrunit,crt;
const
  cursorpos=$50;
var
  w1,w2,w3,exmem,crtadr:word;
  ch:char;
  s:string;
  xmscheck,drives:byte;
  scrbuffer: array[1..4096] of byte;

function dayofweek(b:byte):string;
const
  d : array [0..6] of string[10] =
  ('sunday','monday','tuesday','wednesday','thursday','friday','saturday');
begin
  if b>6 then exit;
  dayofweek:=d[b];
end;
{***********************************************************************}
function drivetype(b:byte):string;
begin
case b of
   0 : drivetype:='no drive';
   1 : drivetype:='360K';
   2 : drivetype:='1.2M';
   3 : drivetype:='720K';
   4 : drivetype:='1.44M';
     else drivetype:='unknown';
   end;
end;
{***********************************************************************}
procedure getscreen(var buffer);assembler;
var
  saveds:word;
asm
        cld
        mov     saveds,ds
        les     di,buffer
        mov     si,cursorpos
        mov     ax,$40
        mov     ds,ax
        movsw
        mov     ds,saveds
        xor     si,si
        mov     ax,crtadr
        mov     ds,ax
        mov     cx,2000
        rep     movsw

@tend:
        mov     ds,saveds
end;
{***********************************************************************}
function fou(a:byte):string;
begin
  if a=0 then fou:='not found' else fou:='found';
end;
{***********************************************************************}
procedure putscreen(var buffer);assembler;
var
  saveds:word;
asm
        cld
        mov     saveds,ds
        mov     ah,02
        xor     bh,bh
        les     di,buffer
        mov     dx,[es:di]
        int     $10
        mov     di,cursorpos
        mov     ax,$40
        mov     es,ax
        mov     bx,crtadr
        lds     si,buffer
        movsw
        xor     di,di
        mov     es,bx
        mov     cx,2000
        rep     movsw

@tend:
        mov     ds,saveds
end;

procedure runme;
begin
  while (keypressed) do
  begin
    ch:=readkey;
    if ch=#0 then ch:=readkey;
  end;
  getscreen(scrbuffer);
  textattr:=(1 shl 4) + 14;
  clrscr;
  writeln('GENERAL INFORMATION');
  writeln;
  asm
                mov     ah,$47
                xor     dl,dl
                mov     si,offset s
                inc     si
                int     $21 {get current directory}
                mov     si,offset s
                xor     cx,cx
@loop:
                inc     si
                cmp     byte ptr [ds:si],0
                je      @exitloop
                inc     cx
                cmp     cx,64
                jae     @exitloop
                jmp     @loop
@exitloop:
                mov     si,offset s
                mov     [ds:si],cl
  end;
  textattr:=(1 shl 4) + 15;
  asm
    mov     ah,$2c
    int     $21     {get system time}
    mov     w1,cx
    mov     w2,dx
  end;
  writeln('system time               : ',hi(w1),':',lo(w1),':',hi(w2));
  asm
    mov     ah,$2a
    int     $21     {get system date}
    mov     w1,cx
    mov     w2,dx
    mov     w3,ax
  end;
  writeln('system date               : ',lo(w2),'.',hi(w2),'.',w1,' (',dayofweek(lo(w3))+')');

  asm
    mov     ah,$19
    int     $21  {get current default drive}
    mov     w1,ax
  end;
  writeln('current default drive     : ',chr(lo(w1)+65));
  writeln('current directory         : ',chr(lo(w1)+65),+':\'+s);
  writeln('diskette drive type for A : ',drivetype((drives shr 4) and 15));
  writeln('diskette drive type for B : ',drivetype(drives and 15));
  writeln('number of parallel devices: ',(mem[$40:$11] and 192) shr 6);
  writeln('number of serial devices  : ',(mem[$40:$11] and 14) shr 1);
  writeln('number of diskette drives : ',(mem[$40:$10] and 192) shr 6 +1);
  writeln('math co-processor         : ',fou(mem[$40:$10] and 2));
  writeln('base memory size          : ',memw[$40:$13],' Kb');
  writeln('extended memory size      : ',exmem,' Kb');
  writeln('xms driver                : ',fou(xmscheck));
  writeln;
  writeln;
  textattr:=(1 shl 4)+12;
  writeln('press ESC to remove TSR from memory, or any other key to exit');
  repeat;
  until keypressed;
  ch:=readkey;
  if ch=#27 then
  begin
    if checkintvectors=false then
    begin
      putscreen(scrbuffer);
      textattr:=12;
      writeln;
      writeln('cannot remove TSREXAMP from memory');
      writeln;
      exit;
    end;

    putscreen(scrbuffer);
    textattr:=15;
    writeln;
    writeln('TSREXAMP removed from memory');
    removetsr;
  end;
  if ch=#0 then ch:=readkey;
  putscreen(scrbuffer);
end;



begin
  SetUserSignature($ae34,$5511);
  if installationcheck=true then
  begin
    writeln;
    writeln('TSREXAMP have already installed !');
    writeln;
    halt;
  end;

  asm
    mov     al,$17
    out     $70,al
    in      al,$71
    mov     cl,al
    mov     al,$18
    out     $70,al
    in      al,$71
    mov     ch,al
    mov     exmem,cx  {get total of extended memory}
    mov     al,$10
    out     $70,al
    in      al,$71
    mov     drives,al
    mov     xmscheck,0
    mov     ax,$4300
    int     $2f {check xms installation}
    cmp     al,$80
    jne     @notins
    mov     xmscheck,1 {xms dirver found}
    @notins:
  end;
  if lastmode=3 then crtadr:=$b800 else crtadr:=$b000;
  keysc:=_i;   {keyboard scan code for 'I'}
  keyflag:=Alt + Ctrl;
  writeln;
  writeln('TSREXAMP installed.');
  writeln('press ALT+CTRL+I to view general information about your computer');
  installtsr(runme);
end.
