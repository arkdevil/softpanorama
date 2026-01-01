cseg    segment    "CODE"
ReadHoriz proc     near
public    ReadHoriz
        assume cs:cseg, ds:cseg

;■······················································■
; input : NONE
; output: AX
;■······················································■

  push bx
  push cx
  push dx

  mov ax,0300H
  mov bx,0
  int 10H
  push dx

  cmp dl,0
  je RowNull
  dec dl
  jmp ContDec

RowNull:
  mov ch, 0
  jmp StartInc

ContDec:
  mov ax,0200H
  mov bx,0
  int 10H
  mov ax,0800H
  mov bx,0
  int 10H

  mov ch,al

StartInc:
  pop dx
  push dx

  cmp dl,79
  je RowFull
  inc dl
  jmp ContInc

RowFull:
  mov cl,0
  jmp EndOfLineTest

ContInc:
  mov ax,0200H
  mov bx,0
  int 10H
  mov ax,0800H
  mov bx,0
  int 10H

  mov cl, al

EndOfLineTest:
  pop dx
  mov ax,0200H
  mov bx,0
  int 10H

  mov ax, cx
  xchg ah, al

  pop dx
  pop cx
  pop bx
  ret

ReadHoriz endp
cseg      ends


