title   stactest
        .MODEL TINY
        .CODE
        org     100h
start:  lea     dx,obomne
        mov     ah,9
        int     21h
        mov     ax,0cdcdh
        lea     bx,bufs
        mov     cx,1
        xor     dx,dx
        int     25h
        cmp     ax,0cdcdh
        jz      ok_p
        pop     dx
        lea     dx,notstac
        mov     ah,9
        int     21h
        int     20h
ok_p:   lea     si,bufs+4
        lds     si,dword ptr [si]
        lodsw
        lodsw
        xor     dx,dx
        mov     bx,100
        div     bx
        add     al,'0'
        mov     byte ptr es:vern,al
        mov     ax,dx
        mov     bx,10
        div     bx
        add     al,'0'
        mov     byte ptr es:verl,al
        add     dl,'0'
        mov     byte ptr es:verl+1,dl
        push    ds
        push    cs
        pop     ds
        lea     dx,yesstac
        mov     ah,9
        int     21h
        int     20h

bufs    dw      0,0
        dd      0
notstac db      'Stacker not found !',0dh,0ah,'$'
yesstac db      'Stacker '
vern    db      'X.'
verl    db      'XX found !'
        db      0dh,0ah,'$'
obomne  db      0dh,0ah,'* Tsyganok Service * 1993 * Stacker Test *'
        db      0dh,0ah,'$'
        end     start
