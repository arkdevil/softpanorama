cseg      segment 'CODE'
PutLeftLine proc     near
public    PutLeftLine
          assume cs: cseg
;■······················································■
; input : AX = Thickness
;
; output: AL
;■······················································■
;■······················································■
; DH    : Status
; DL    : st
;■······················································■

  push bx
  push cx
  push dx

  cmp ax, 1
  jne ThickLeftLine
  call ReadVert
  mov bx, ax
  call ReadHoriz
  call GetRightSymbol
  jmp PLLcont
ThickLeftLine:
  call ReadVert
  mov bx, ax
  call ReadHoriz
  call GetThickRightSymbol
PLLcont:

  mov bh, Direction
  cmp bh, RIGHT
  jz MoveLeft

  mov ah,0AH
  mov bh,0
  mov cx,1
  int 10H

MoveLeft:
  mov ax,0300H
  mov bx,0
  int 10H

  cmp dl,0
  je ExitLeft
  dec dl
  mov ax,0200H
  mov bx,0
  int 10H

ExitLeft:
  mov ah, LEFT
  mov Direction, ah
  pop dx
  pop cx
  pop bx
  ret

PutLeftLine endp
;■······················································■

PutRightLine proc     near
public    PutRightLine
;■······················································■
; input : AX = Thickness
;
; output: AL
;■······················································■
;■······················································■
; DH    : Status
; DL    : st
;■······················································■

  push bx
  push cx
  push dx

  cmp ax, 1
  jne ThickRightLine
  call ReadVert
  mov bx, ax
  call ReadHoriz
  call GetLeftSymbol
  jmp PRLcont
ThickRightLine:
  call ReadVert
  mov bx, ax
  call ReadHoriz
  call GetThickLeftSymbol
PRLcont:

  mov bh, Direction
  cmp bh, LEFT
  jz MoveRight

  mov ah,0AH
  mov bh,0
  mov cx,1
  int 10H

MoveRight:
  mov ax,0300H
  mov bx,0
  int 10H

  cmp dl,79
  je ExitLeft2
  inc dl
  mov ax,0200H
  mov bx,0
  int 10H

ExitLeft2:
  mov ah, RIGHT
  mov Direction, ah

  pop dx
  pop cx
  pop bx
  ret
PutRightLine endp
;■······················································■


PutDownLine proc     near
public    PutDownLine
;■······················································■
; input : AX = Thickness
;
; output: AL
;■······················································■

  push bx
  push cx
  push dx

  cmp ax, 1
  jne ThickDownLine
  call ReadVert
  mov bx, ax
  call ReadHoriz
  call GetDownSymbol
  jmp PDLcont
ThickDownLine:
  call ReadVert
  mov bx, ax
  call ReadHoriz
  call GetThickDownSymbol
PDLcont:

  mov bh, Direction
  cmp bh, UP
  jz MoveDown

  mov ah,0AH
  mov bh,0
  mov cx,1
  int 10H

MoveDown:
  mov ax,0300H
  mov bx,0
  int 10H

  cmp dh,24
  je  ExitDown
  inc dh

  mov ax,0200H
  mov bx,0
  int 10H

ExitDown:
  mov ah, DOWN
  mov Direction, ah

  pop dx
  pop cx
  pop bx
  ret
PutDownLine endp
;■······················································■


PutUpLine proc     near
public    PutUpLine
;■······················································■
; input : AX = Thickness
;
; output: AL
;■······················································■

  push bx
  push cx
  push dx

  cmp ax, 1
  jne ThickUpLine
  call ReadVert
  mov bx, ax
  call ReadHoriz
  call GetUpSymbol
  jmp PULcont
ThickUpLine:
  call ReadVert
  mov bx, ax
  call ReadHoriz
  call GetThickUpSymbol
PULcont:

  mov bh, Direction
  cmp bh,DOWN
  jz MoveUp

  mov ah,0AH
  mov bh,0
  mov cx,1
  int 10H

MoveUp:
  mov ax,0300H
  mov bx,0
  int 10H

  cmp dh,0
  je  ExitUp
  dec dh

  mov ax,0200H
  mov bx,0
  int 10H

ExitUp:
  mov ah, UP
  mov Direction, ah

  pop dx
  pop cx
  pop bx
  ret
PutUpLine endp
;■······················································■
cseg   ends

