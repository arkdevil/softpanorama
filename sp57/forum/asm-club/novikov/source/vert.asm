cseg    segment    "CODE"
ReadVert  proc     near
public    ReadVert
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

  cmp dh,0
  je LineNull
  dec dh
  jmp _ContDec

LineNull:
  mov ch, 0
  jmp _StartInc

_ContDec:
  mov ax,0200H
  mov bx,0
  int 10H
  mov ax,0800H
  mov bx,0
  int 10H

  mov ch,al

_StartInc:
  pop dx
  push dx

  cmp dh,24
  je LineFull
  inc dh
  jmp _ContInc

LineFull:
  mov cl,0
  jmp _EndOfLineTest

_ContInc:
  mov ax,0200H
  mov bx,0
  int 10H
  mov ax,0800H
  mov bx,0
  int 10H

  mov cl, al

_EndOfLineTest:
  pop dx
  mov ax,0200H
  mov bx,0
  int 10H

  mov ax, cx

  pop dx
  pop cx
  pop bx
  ret
;■······················································■
ReadVert  endp
cseg      ends



