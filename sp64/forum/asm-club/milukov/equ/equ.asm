locals
.model tiny
.data

Cache   equ 4000                ; 4символа x 1000 меток
Too_Big db 'Файл слишком велик для pаботы$'
Help    db 'Убиpалка невостpебованных адpесов в *[.osm] (C) Milukow 1994',10,13,'$'
Err_    db 'Ошибка pаботы с файлом$'
Len     dw  0
nBuf    db  4


.CODE
 org 100h

start:
mov     bl,ds:[80h]
or      bl,bl
jne     is_cmd
lea     dx,Help
jmp     Txt
is_cmd:
xor  bh,bh
mov  byte ptr 81h[bx],0
mov  dx,82h
mov  ax,3D00h
call  DosFn
mov  bx,ax
xor  cx,cx
xor  dx,dx
mov  ax,4202h
call  DosFn
mov  Len,ax
or   dx,dx
je   no_big

lea dx,Too_Big
jmp  Txt

no_big:
xor  cx,cx
xor  dx,dx
mov  ax,4200h
call  DosFn

mov  cx,Len
mov  ah,3Fh
lea  dx,nBuf + Cache
call  DosFn

mov  ah,3Eh
call  DosFn

lea     si,nBuf + Cache
lea     di,nBuf
cld
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ ищем цифpы ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
Re:
        call    Is4digit        ; число ли это ?
        jc      @@next
        cmp     byte ptr [si+4],':'     ; число заканчивается : метка
        jne     @@save
        add     si,5
        jmp     short @@next
@@save:
        mov     cx,4
        rep     movsb
@@next:
        inc     si
        lea     ax,nBuf + Cache
        add     ax,Len
        cmp     si,ax
        jc      re

        mov     dx,di           ; конец списка чисел
        lea     si,nBuf + Cache

;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ заменяем цифpы ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
Re1:
        call    Is4digit        ; число ли это ?
        jc      @@next
        cmp     byte ptr [si+4],':'     ; число заканчивается : метка
        je      @@replace
@@skip:
        add     si,5
        jmp     short @@next
@@replace:
        call    Found
        jnc     @@skip
        mov     [si],2020h
        mov     [si+2],2020h
        mov     byte ptr [si+4],' '
@@next:
        inc     si
        lea     ax,nBuf + Cache
        add     ax,Len
        cmp     si,ax
        jc      re1

mov  dx,82h
xor  cx,cx
mov  ax,3C00h
call  DosFn
mov  bx,ax

mov  cx,Len
mov  ah,40h
lea  dx,nBuf + Cache
call  DosFn

mov  ah,3Eh
call  DosFn

jmp short Done


DosFn:
int  21h
jc   _err
ret
_Err: lea dx, Err_
Txt:
mov  ah,09h
int 21h
Done: mov ah,4Ch
int 21h


Is4digit proc near
        xor     bp,bp
@@2:
        call    IsDigit
        jnc     @@1
        retn
@@1:
        inc     bp
        cmp     bp,4
        jc      @@2
        retn
endp


IsDigit proc near
        cmp     byte ptr [si+bp],'0'
        jc      @@not
        cmp     byte ptr [si+bp],'F'
        ja      @@not
        cmp     byte ptr [si+bp],'A'
        jnc     @@1
        cmp     byte ptr [si+bp],'9'
        ja      @@not
@@1:
        clc
        retn
@@not:
        stc
        retn
endp

Found proc near
        lea     bx,nBuf
@@1:
        cmp     bx,dx
        jae     @@notfound
        mov     ax,[si]
        cmp     ax,[bx]
        jne     @@2
        mov     ax,[si+2]
        cmp     ax,[bx+2]
        jne     @@2
        clc
        retn
@@2:
        add     bx,4
        jmp     short @@1
@@notfound:
        stc
        retn
endp

end  start
