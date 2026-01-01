cseg      segment 'CODE'
GetBufferSize proc     near
public    GetBufferSize
          assume cs: cseg
;■······················································■
; input : NONE
; output: AX
;■······················································■

  push bx
  push di
  push ds

  mov ax, 40H
  mov ds, ax

  mov di,1AH
  mov ax,[di]
  inc di
  inc di
  mov bx,[di]

  cmp ax, bx
  jz  BufferEmpty
  jb  HeadFirst

HeadLast:
  sub ax, bx
  mov bx, 30
  sub bx, ax
  mov ax, bx
  add ax, 2
  jmp @End

HeadFirst:
  sub bx, ax
  mov ax, bx
  jmp @End

BufferEmpty:
  mov ax,0
  jmp @End

@End:
  pop ds
  pop di
  pop bx
  ret
GetBufferSize endp
;■······················································■


PushIntoBuffer proc     near
public    PushIntoBuffer
;■······················································■
; input : AX
; output: NONE
;■······················································■

  push bx
  push di
  push ds

  mov bx, ax
  call GetBufferSize
  cmp ax, 30
  jz PushIntoBufferEnd

  mov ax, bx

  mov bx, 40H
  mov ds, bx
  mov di, ds:[1CH]

  mov ds:[di], ax
  add di, 2

  cmp di, 62
  jnz  Cont
  mov di, 30

Cont:
  mov ds:[1CH], di
PushIntoBufferEnd:
  pop ds
  pop di
  pop bx
  ret
;■······················································■
PushIntoBuffer endp
cseg      ends

