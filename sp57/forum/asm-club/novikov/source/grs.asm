cseg      segment 'CODE'
GetRightSymbol proc     near
public    GetRightSymbol
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

UpperSymbolComp:
   cmp bh, ds:[si]
   jnz UpperSymbolCont
   or  dh, 1
UpperSymbolCont:
   inc si
   loop UpperSymbolComp

   lea si, LowerSymbol
   mov cx, 13

LowerSymbolComp:
   cmp bl, ds:[si]
   jnz LowerSymbolCont
   or  dh, 2
LowerSymbolCont:
   inc si
   loop LowerSymbolComp

;■······················································■

   lea si, ThickUpperSymbol
   mov cx, 13

ThickUpperSymbolComp:
   cmp bh, ds:[si]
   jnz ThickUpperSymbolCont
   or  dh, 8
ThickUpperSymbolCont:
   inc si
   loop ThickUpperSymbolComp

   lea si, ThickLowerSymbol
   mov cx, 13

ThickLowerSymbolComp:
   cmp bl, ds:[si]
   jnz ThickLowerSymbolCont
   or  dh, 16
ThickLowerSymbolCont:
   inc si
   loop ThickLowerSymbolComp

;■······················································■

   lea si, RightSymbol
   mov cx, 13

RightSymbolComp:
   cmp ah, ds:[si]
   jnz RightSymbolCont
   or  dh, 4
RightSymbolCont:
   inc si
   loop RightSymbolComp

GRSreturns:
   cmp dh, 28
   jg  RightFailed@0

   lea bx, GRS_SymbolsID
   mov al, dh
   xlat
   or al, al
   jnz RightEnd

RightFailed@0:

   mov dl, dh
   and dl, 3
   cmp dl, 0
   jz RightFailed@1
   and dh, 252
   jmp GRSreturns

RightFailed@1:
   mov dl, dh
   and dl, 4
   cmp dl, 0
   jz RightFailed@2
   and dh, 251
   jmp GRSreturns

RightFailed@2:
   mov ax, '─'
RightEnd:

  pop bx
  pop si
  pop dx
  pop cx
  ret

GRS_SymbolsID db '─','┘','┐','┤','─','┴','┬','┼','╜', 0
              db  0 , 0 ,'╨', 0 , 0 , 0 ,'╖', 0 , 0 , 0
              db '╥', 0 , 0 , 0 ,'╢', 0 , 0 , 0 ,'╫', 0

;■······················································■
GetRightSymbol endp
cseg      ends


