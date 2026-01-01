cseg      segment 'CODE'
DecBuffer proc     near
public    DecBuffer
          assume cs: cseg
;■······················································■
; input : NONE
; output: NONE
;■······················································■

  cli

  push bx
  push si
  push di
  push ds

  mov bx, 40H
  mov ds, bx
  mov si, ds:[1AH]
  mov di, ds:[1CH]

  cmp si, di
  jz  @@End
  cmp di, 30
  jz  Over

Decrement:
  dec di
  dec di
  mov ds:[1CH], di
  jmp @@End

Over:
  mov di, 60
  mov ds:[1CH], di

@@End:

  pop ds
  pop di
  pop si
  pop bx

  ret
;■······················································■
DecBuffer endp
cseg      ends

