cseg      segment 'CODE'
GetLeftSymbol proc     near
public    GetLeftSymbol
          assume cs: cseg
;■······················································■
; input : unsigned int BothHoriz = AX
; AH    : RightSymbol
; AL    : LeftSymbol
;
; input : unsigned int BothVert = BX
; BH    : UpperSymbol
; BL    : LowerSymbol
;
; output: AL
;■······················································■
;■······················································■
; DH    : Status
; DL    : st
;■······················································■

  push cx
  push dx
  push si
  push bx

   lea si, UpperSymbol
   mov cx, 13
   mov dx, 0

LeftUpperSymbolComp:
   cmp bh, ds:[si]
   jnz LeftUpperSymbolCont
   or  dh, 1
LeftUpperSymbolCont:
   inc si
   loop LeftUpperSymbolComp

   lea si, LowerSymbol
   mov cx, 13

LeftLowerSymbolComp:
   cmp bl, ds:[si]
   jnz LeftLowerSymbolCont
   or  dh, 2
LeftLowerSymbolCont:
   inc si
   loop LeftLowerSymbolComp

;■······················································■

   lea si, ThickUpperSymbol
   mov cx, 13

LeftThickUpperSymbolComp:
   cmp bh, ds:[si]
   jnz LeftThickUpperSymbolCont
   or  dh, 8
LeftThickUpperSymbolCont:
   inc si
   loop LeftThickUpperSymbolComp

   lea si, ThickLowerSymbol
   mov cx, 13

LeftThickLowerSymbolComp:
   cmp bl, ds:[si]
   jnz LeftThickLowerSymbolCont
   or  dh, 16
LeftThickLowerSymbolCont:
   inc si
   loop LeftThickLowerSymbolComp

;■······················································■

   lea si, LeftSymbol
   mov cx, 13

LeftSymbolComp:
   cmp al, ds:[si]
   jnz LeftSymbolCont
   or  dh, 4
LeftSymbolCont:
   inc si
   loop LeftSymbolComp
;■······················································■

GLSreturns:

   cmp dh, 28
   jg  LeftFailed@0

   lea bx, GLS_SymbolsID
   mov al, dh
   xlat
   or al, al
   jnz LeftEnd

LeftFailed@0:

   mov dl, dh
   and dl, 3
   cmp dl, 0
   jz LeftFailed@1
   and dh, 252
   jmp GLSreturns

LeftFailed@1:
   mov dl, dh
   and dl, 4
   cmp dl, 0
   jz LeftFailed@2
   and dh, 251
   jmp GLSreturns

LeftFailed@2:
   mov ax, '─'

LeftEnd:
  pop bx
  pop si
  pop dx
  pop cx
  ret

GLS_SymbolsID  db '─','└','┌','├','─','┴','┬','┼','╙', 0
               db  0 , 0 ,'╨', 0 , 0 , 0 ,'╓', 0 , 0 , 0
               db '╥', 0 , 0 , 0 ,'╟', 0 , 0 , 0 ,'╫', 0


;■······················································■
GetLeftSymbol endp
cseg      ends

