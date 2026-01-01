;---------------------------------------------------------------------------
; Резидентная программа для рисования линий псевдографикой.
; Перехватывает прерывания :
; 09H  -  Клавиатуры
; 16H  -  Для контроля загрузки (функция F3 отсутствует)
; При нажатии клавиши вызывается INT 09Н, а с ним и программа.
; Берет напрямую скэн-код нажатой клавиши, и если "горячая" - то
; удаляет код клавиши, и вместо него запихивает коды псевдографики и
; клавиш перемещения курсора.
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
initab  segment at 0H
        org 9H*4
kbaddr  label dword
initab  ends
;---------------------------------------------------------------------------
Contrl  segment at 0H
        org 16H*4
CADDR   label dword
Contrl  ends
;---------------------------------------------------------------------------

INCLUDE defines.asm

cseg    segment   'CODE'
        assume cs:cseg
        org 100H
begin:
        jmp Init

KBSAVE  DD ?
CSAVE   DD ?
Thickness DW 1
Direction DB 255

Handler proc far
        cli
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push es
        push ds

        pushf
        call KBSAVE
        cli
        push cs
        pop ds

        mov ax, 40H
        mov es, ax
        mov si, es:[1AH]
        mov di, es:[1CH]

        mov ah, es:[17H]
        test ah, 00001000b
        jnz Cont@1
        mov al, 255
        mov Direction, al

Cont@1:
        cmp di, si
        jz  Continue

        sub di, 2
        cmp di, 28
        jnz Cont@2
        mov di, 60
Cont@2:

        mov bx, es:[di]
        cmp bx, 38912
        jz  PUL
        cmp bx, 40960
        jz  PDL
        cmp bx, 39680
        jz  PLL
        cmp bx, 40192
        jz  PRL
        cmp bx, 3920H
        jne Continue
        mov ah, es:[17h]
        test ah,00001000b
        jnz Switch

Continue:
        pop ds
        pop es
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        sti
        iret

PUL:    call DecBuffer
        call GetBufferSize
        cmp ax, 22
        jg  Continue
        mov ax, Thickness
        call PutUpLine
        jmp Continue
PDL:    call DecBuffer
        call GetBufferSize
        cmp ax, 22
        jg  Continue
        mov ax, Thickness
        call PutDownLine
        jmp Continue
PLL:    call DecBuffer
        call GetBufferSize
        cmp ax, 22
        jg  Continue
        mov ax, Thickness
        call PutLeftLine
        jmp Continue
PRL:    call DecBuffer
        call GetBufferSize
        cmp ax, 22
        jg  Continue
        mov ax, Thickness
        call PutRightLine
        jmp Continue
Switch:
        call DecBuffer
        mov ax, Thickness
        cmp ax, 1
        jnz Switch__1
        mov ax, 0
        mov Thickness, ax
        jmp Continue
Switch__1:
        mov ax, 1
        mov Thickness, ax
        jmp Continue
Handler endp

ControlProcedure proc far
        cmp ax, 0F3AAH
        jz  Installed
        jmp CSAVE
Installed:
        mov ax, 1234
        iret
ControlProcedure endp
cseg    ends

INCLUDE symbols.asm

INCLUDE grs.asm
INCLUDE gls.asm
INCLUDE gds.asm
INCLUDE gus.asm

INCLUDE gtrs.asm
INCLUDE gtls.asm
INCLUDE gtus.asm
INCLUDE gtds.asm

INCLUDE horiz.asm
INCLUDE vert.asm
INCLUDE _draw.asm

INCLUDE buffer.asm
INCLUDE decbuff.asm

cseg    segment  'CODE'
       nop
       nop

AlreadyInstalled proc near
       mov ah, 09
       mov dx, offset AIMessage
       int 21H
       mov ax, 4C00H
       int 21H
AIMessage db 'Driver already installed.',13,10,'$'
AlreadyInstalled endp

init   proc near
       assume ds:initab

       mov ax, 0F3AAH
       int 16H
       cmp ax, 1234
       jz  AlreadyInstalled

       push cs
       pop ds

       mov dx, offset Message
       mov ah,09
       int 21H

       mov    ax,initab
       mov    ds, ax
       cli
       mov    ax, word ptr kbaddr
       mov    word ptr kbsave, ax
       mov    ax, word ptr kbaddr+2
       mov    word ptr kbsave+2,ax
       mov    word ptr kbaddr, offset handler
       mov    word ptr kbaddr+2,cs

       assume ds:Contrl

       mov    ax, word ptr CADDR
       mov    word ptr CSAVE, ax
       mov    ax, word ptr CADDR+2
       mov    word ptr CSAVE+2,ax
       mov    word ptr CADDR, offset ControlProcedure
       mov    word ptr CADDR+2,cs
       sti

       mov    dx, offset AlreadyInstalled
       int    27H

Message db '┌─────────────────────────────────────────────────────────┐',13,10
        db '│   Live Line Utility v2.1       (c) 1993 Novikov Artem.  │',13,10
        db '├─────────────────────────────────────────────────────────┤',13,10
        db '│   Controls:  < ALT > + <     >  - move              │',13,10
        db '│              < ALT > + < SPACE >    - toggle thickness  │',13,10
        db '└─────────────────────────────────────────────────────────┘',13,10
TheEnd  db '$',0
init    endp
cseg    ends
        end begin
