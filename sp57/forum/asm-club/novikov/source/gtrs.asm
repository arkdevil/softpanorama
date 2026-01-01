cseg      segment 'CODE'
GetThickRightSymbol proc     near
public    GetThickRightSymbol
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

  push cx
  push dx
  push si
  push bx

   lea si, ThickUpperSymbol
   mov cx, 13
   mov dx, 0

@ThickRightUpperSymbolComp:
   cmp bh, ds:[si]
   jnz @ThickRightUpperSymbolCont
   or  dh, 1
@ThickRightUpperSymbolCont:
   inc si
   loop @ThickRightUpperSymbolComp

   lea si, ThickLowerSymbol
   mov cx, 13

@ThickRightLowerSymbolComp:
   cmp bl, ds:[si]
   jnz @ThickRightLowerSymbolCont
   or  dh, 2
@ThickRightLowerSymbolCont:
   inc si
   loop @ThickRightLowerSymbolComp

;

   lea si, UpperSymbol
   mov cx, 13

@RightUpperSymbolComp:
   cmp bh, ds:[si]
   jnz @RightUpperSymbolCont
   or  dh, 8
@RightUpperSymbolCont:
   inc si
   loop @RightUpperSymbolComp

   lea si, LowerSymbol
   mov cx, 13

@RightLowerSymbolComp:
   cmp bl, ds:[si]
   jnz @RightLowerSymbolCont
   or  dh, 16
@RightLowerSymbolCont:
   inc si
   loop @RightLowerSymbolComp

;■······················································■

   lea si, ThickRightSymbol
   mov cx, 13

@RightSymbolComp:
   cmp ah, ds:[si]
   jnz @RightSymbolCont
   or  dh, 4
@RightSymbolCont:
   inc si
   loop @RightSymbolComp


GTRSreturns:

   cmp dh, 28
   jg  @RightFailed@0

   lea bx, GTRS_SymbolsID
   mov al, dh
   xlat
   or al, al
   jnz @RightEnd

@RightFailed@0:

   mov dl, dh
   and dl, 24
   cmp dl, 0
   jz @RightFailed@1
   and dh, 231
   jmp GTRSreturns

@RightFailed@1:
   mov dl, dh
   and dl, 4
   cmp dl, 0
   jz @RightFailed@2
   and dh, 251
   jmp GTRSreturns

@RightFailed@2:
   mov ax, '═'
@RightEnd:

  pop bx
  pop si
  pop dx
  pop cx
  ret

GTRS_SymbolsID db '═','╝','╗','╣','═','╩','╦','╬','╛', 0
               db  0 , 0 ,'╧', 0 , 0 , 0 ,'╕', 0 , 0 , 0
               db '╤', 0 , 0 , 0 ,'╡', 0 , 0 , 0 ,'╪', 0
;■······················································■
GetThickRightSymbol endp
cseg      ends
