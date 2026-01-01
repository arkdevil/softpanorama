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

  mov ah, 0
  call PushIntoBuffer
  mov al, 0
  mov ah, 75
  call PushIntoBuffer

MoveLeft:
  mov al, 0
  mov ah, 75
  call PushIntoBuffer

ExitLeft:

  mov ah, LEFT
  mov Direction, ah

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

  push bx

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

  mov ah, 0
  call PushIntoBuffer
  jmp ExitLeft2

MoveRight:
  mov al,0
  mov ah,77
  call PushIntoBuffer

ExitLeft2:
  mov ah, RIGHT
  mov Direction, ah

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

  mov ah, 0
  call PushIntoBuffer
  mov al, 0
  mov ah, 75
  call PushIntoBuffer

MoveDown:
  mov al, 0
  mov ah, 80
  call PushIntoBuffer

ExitDown:
  mov ah, DOWN
  mov Direction, ah

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

  mov ah, 0
  call PushIntoBuffer
  mov al, 0
  mov ah, 75
  call PushIntoBuffer

MoveUp:
  mov al, 0
  mov ah, 72
  call PushIntoBuffer

ExitUp:
  mov ah, UP
  mov Direction, ah

  pop bx
  ret
PutUpLine endp
;■······················································■
cseg   ends

