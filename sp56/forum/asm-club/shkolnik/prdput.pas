program prdpu;
label lp,lg,gv,lm;
const kees:array[1..4] of string[3]=('/1','/2','/3','/4');
var ii,jj,pp,po,pg:byte;
sa:string;

procedure ucase(var ss:string);
var ii,ll:byte;
begin
ll:=length(ss);
for ii:=1 to ll do ss[ii]:=upcase(ss[ii]);
end;

begin
writeln('Printer Redirection Program Utility.'^m^j,
        'Copyright (C) Yu.A.Shkolnikov. Kiev, 1993.');
asm
   push ax
   mov  ah,0d7h
   int  17h
   or   ah,ah
   pop  ax
   jz   lg
end;
writeln('Can''t run without resident PRDP.COM.');goto lp;
lg:pp:=paramcount;
if pp=0 then lp:begin
writeln('Usage PRDPUT /1=file_1 /2=file_2 /3=file_3 /4=file_4'^m^j,
        'where /i:file_i means redirection of the LPT<i> to file_i,'^m^j,
        '/i without a filename means closing file_i opened before'^m^j,
        'and restoring LPT<i>.'^m^j); exit end;
for ii:=1 to pp do begin
sa:=paramstr(ii); ucase(sa);
jj:=1;
repeat
po:=pos(kees[jj],sa);
inc(jj)
until ((jj=5) or (po=1));
dec(jj);
if po<>1 then goto lp;
po:=length(sa)-2;
pg:=byte(sa[2])-49;
if po=0 then sa:=' ' else
   if sa[3]<>'=' then goto lp else sa:=copy(sa,4,po-1);
if sa=' ' then begin
asm
        push    ax
        mov     ah,0d0h
        mov     dl,byte ptr [pg]
        xor     dh,dh
        int     17h
end;
writeln('LPT',pg+1:1,' has been restored.') end
else begin
po:=1+length(sa); pp:=ord(sa[po]); sa[po]:=#0;
asm
        push    dx
        push    bx
        push    ax
        mov     ah,0d0h
        mov     dl,byte ptr [pg]
        xor     dh,dh
        int     17h
        mov     ah,0d1h
        mov     bl,byte ptr [pg]
        xor     bh,bh
        mov     dx,1+offset sa
        int     17h
        pop     ax
        pop     bx
        pop     dx
        jnc     gv
end;
writeln('Can''t redirect LPT',pg+1:1,' to ',sa,'.'); goto lm;
gv:writeln('LPT',pg+1:1,' is redirected to ',sa,'.')
end;
lm: sa[po]:=chr(pp)
end;
end.