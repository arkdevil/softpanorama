.8086
.model tiny
.code

gat     equ     bft+1
        org     100h
bft:    jmp     vkl
pst     dw      0,0,0,0
tpid    dw      ?
ppid    dw      ?
n17:    cmp     ah,0d7h
        jne     gd0
        xor     ah,ah
        iret
gd0:    cmp     ah,0d0h
        jne     gd1
        push    ds
        push    dx
        push    bx
        push    ax
        call    pidin
        mov     bx,cx
        mov     ax,1
        mov     cl,dl
        rol     al,cl
        mov     cx,bx
        not     al
        and     byte ptr cs:[gat],al
        mov     bx,cs
        mov     ds,bx
        mov     bx,dx
        rol     bx,1
        mov     bx,word ptr [pst+bx]
        mov     ah,3eh
        call    ti21
        call    pidout
        pop     ax
        pop     bx
        pop     dx
        pop     ds
        iret

gd1:    cmp     ah,0d1h
        jne     g02
        push    cx
        push    bx
        push    ax
        call    pidin
;       xor     cx,cx
        mov     cx,110b
        mov     ah,3ch
        call    ti21
	jc	dcg
        mov     ch,1
        mov     cl,bl
        rol     ch,cl
        or      byte ptr cs:[gat],ch
        rol     bx,1
        mov     word ptr cs:[pst+bx],ax
dcg:	pushf
        call    pidout
	popf
        pop     ax
        pop     bx
        pop     cx
        iret

g02:    cmp     ah,2
        ja      isr
        call    pdt
        jnz     ivi
isr:    db      0eah
o17:    dw      0,0
ivi:    cmp     ah,0
        je      ipr
ior:    mov     ah,090h
        iret
ipr:    push    ds
        push    dx
        push    cx
        push    bx
        push    ax
        call    pidin
        mov     byte ptr cs:[bft],al
        mov     cx,cs
        mov     ds,cx
        mov     cx,1
        rol     dx,1
        mov     bx,dx
        mov     bx,word ptr [pst+bx]
        mov     dx,offset bft
        mov     ah,40h
        call    ti21
        call    pidout
        pop     ax
        pop     bx
        pop     cx
        pop     dx
        pop     ds
        jmp     ior

n21     proc    far
        cmp     ah,40h
        jne     avu
        push    bx
        push    dx
        push    ax
        mov     ax,4400h
        call    ti21
        and     dl,10011111b
        cmp     dl,80h
        jne     avo
        call    pfsd
        jnz     avo
avm:    call    pdt
        jz      avo
        jcxz    avo
        rol     dx,1
        mov     bx,dx
        mov     bx,word ptr cs:[pst+bx]
        pop     ax
        pop     dx
        call    pidin
        call    ti21
        pop     bx
        pushf
        call    pidout
        popf
        ret     2

avo:    pop     ax
        pop     dx
        pop     bx
avu:    db      0eah
o21     dw      0,0
n21     endp

pidin:  push    ax
        push    bx
        mov     ah,62h
        call    ti21
        mov     cs:[ppid],bx
        mov     bx,cs:[tpid]
pido:   mov     ah,50h
        call    ti21
        pop     bx
        pop     ax
        ret

pidout: push    ax
        push    bx
        mov     bx,cs:[ppid]
        jmp     pido

pdt:    push    ax
        push    cx
        mov     al,1
        mov     cl,dl
        rol     al,cl
        test    byte ptr cs:[gat],al
        pop     cx
        pop     ax
        ret

ti21:   pushf
        call    dword ptr cs:o21
        ret

uhs:    mov     cx,4
        push    di
        repe    cmpsb
        jcxz    avr
        pop     di
        ret
avr:    add     sp,4
        jmp     aro

pfsd:   push    ds
        push    es
        push    si
        push    di
        push    cx
        call    sftfn
        cmp     di,0ffffh
        je      hre
        mov     cx,cs
        mov     ds,cx
        cld
        mov     si,offset pr0
        call    uhs
        mov     si,offset pr1
        call    uhs
        mov     si,offset pr2
        call    uhs
        mov     si,offset pr3
        call    uhs
        mov     si,offset pr4
        call    uhs
        jmp     hre
aro:    mov     cx,7
        mov     si,offset prz
        repe    cmpsb
        jne     hre
        pushf
        xor     dh,dh
        mov     dl,byte ptr es:[di-8]
        cmp     dl,' '
        je      dre
        sub     dl,'1'
        jmp     kre
dre:    xor     dl,dl
kre:    popf
hre:    pop     cx
        pop     di
        pop     si
        pop     es
        pop     ds
        ret

sftfn:  push    ax
        push    bx
        mov     ah,62h
        call    ti21
        mov     es,bx
        pop     bx
        push    bx
        les     di,dword ptr es:[34h]
        mov     al,byte ptr es:di[bx]
        mov     ah,52h
        call    ti21
        xor     ah,ah
        les     di,es:bx[4]
        xor     bx,bx
fnxt:   cmp     di,0ffffh
        je      badh
        add     bx,word ptr es:di[4]
        cmp     ax,bx
        jb      tbf
        les     di,dword ptr es:[di]
        jmp     fnxt
tbf:    sub     bx,word ptr es:di[4]
        sub     ax,bx
        mov     bl,35h
        push    cx
        push    bx
        push    ax
        mov     ah,30h
        call    ti21
        cmp     al,3
        pop     ax
        pop     bx
        pop     cx
        jb      badh
        je      vnt
        add     bl,6
vnt:    mul     bl
        add     di,ax ;****
        add     di,26h
dio:    pop     bx
        pop     ax
        ret
badh:   mov     di,0ffffh
        jmp     dio

pr0     db      'PRN '
pr1     db      'LPT1'
pr2     db      'LPT2'
pr3     db      'LPT3'
pr4     db      'LPT4'
prz     db      7 dup (' ')

mosl    db      'Printer redirection program is loaded.',0dh,0ah
        db      'Copyright (C) Yu.A.Shkolnikov. Kiev, 1993.',0dh,0ah,'$'
mesv    db      'PRDP is already loaded.',0dh,0ah,'$'
sprdp   db      'SPRDP'

vkl:    and     word ptr [bft],0
        mov     ah,0d7h
        int     17h
        or      ah,ah
        jnz     bvl

        mov     dx,offset mesv
avy:    mov     ah,9
        int     21h
        ret

bvl:    mov     ah,62h
        int     21h
        mov     cs:[tpid],bx

        mov     ax,3517h
        int     21h

bgl:    mov     word ptr o17,bx
        mov     word ptr [o17+2],es

        mov     al,21h
        int     21h
        mov     word ptr o21,bx
        mov     word ptr [o21+2],es

        mov     dx,offset n21
        mov     ah,25h
        int     21h

        mov     dx,offset n17
        mov     al,17h
        int     21h

        mov     dx,offset mosl
        call    avy
        int     27h

        end     bft
