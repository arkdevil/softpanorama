public pic
.286
cseg segment
    assume cs:cseg,ds:cseg,ss:cseg
        org 100h
 pp proc far
oldint label byte
        JMP FIRST
SIZER equ 33h
list db 10,13
db 9,'╔═══════════════════════════════════════════════╗',10,13
db 9,'║  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓      ║',10,13
db 9,'║  ▓  : для выxода в поpождающий поцесс  ▓══╗   ║',10,13
db 9,'║  ▓                                     ▓  ║   ║',10,13
db 9,'║  ▓  нажмите <PRT SCR>                  ▓  ║   ║',10,13
db 9,'║  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ║   ║',10,13
db 9,'║    ║ v 1.0                    Фирсов А.А. ║   ║',10,13
db 9,'║    ╚══════════════════════════════════════╝   ║',10,13
db 9,'╚═══════════════════════════════════════════════╝',10,13,'$'
first: xor ax,ax
        mov ds,ax
        mov ds:[+20],offset pic
        mov ds:[+22],cs

        ;***********************************************
        ;store from 0000:0000 to 0000:0200
        mov ax,cs
        mov ds,ax
        MOV ah,9
        lea dx,list
        int 21h

        xor ax,ax
        mov ds,ax
        mov cx,200h
        mov si,ax
        lea di,oldint
        cld
        rep movsb
        mov dx,SIZER
        mov ax,3100h
        int 21h
    pic proc far
        mov ax,cs
        mov ds,ax
        xor ax,ax
        mov es,ax
        mov cx,200h
        lea si,oldint
        mov di,ax
        cld
        rep movsb
        mov ah,2
        mov dl,7
        int 21h
        mov ax,4c00h
         int 21h
      iret
 latest:
 pic endp
 pp endp
 cseg ends
 end pp
