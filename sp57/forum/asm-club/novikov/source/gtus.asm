cseg      segment 'CODE'
GetThickUpSymbol proc     near
public    GetThickUpSymbol
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

   lea si, LeftSymbol
   mov cx, 13
   mov dx, 0

@UpLeftSymbolComp:
   cmp al, ds:[si]
   jnz @UpLeftSymbolCont
   or  dh, 8
@UpLeftSymbolCont:
   inc si
   loop @UpLeftSymbolComp

   lea si, RightSymbol
   mov cx, 13

@UpRightSymbolComp:
   cmp ah, ds:[si]
   jnz @UpRightSymbolCont
   or  dh, 16
@UpRightSymbolCont:
   inc si
   loop @UpRightSymbolComp

;■······················································■
   lea si, ThickLeftSymbol
   mov cx, 13

@UpThickLeftSymbolComp:
   cmp al, ds:[si]
   jnz @UpThickLeftSymbolCont
   or  dh, 1
@UpThickLeftSymbolCont:
   inc si
   loop @UpThickLeftSymbolComp

   lea si, ThickRightSymbol
   mov cx, 13

@UpThickRightSymbolComp:
   cmp ah, ds:[si]
   jnz @UpThickRightSymbolCont
   or  dh, 2
@UpThickRightSymbolCont:
   inc si
   loop @UpThickRightSymbolComp

;■······················································■

   lea si, ThickLowerSymbol
   mov cx, 13

@UpLowerSymbolComp:
   cmp bl, ds:[si]
   jnz @UpLowerSymbolCont
   or  dh, 4
@UpLowerSymbolCont:
   inc si
   loop @UpLowerSymbolComp
;■······················································■

GTUSreturns:

   cmp dh, 28
   jg  @UpFailed@0

   lea bx, GTUS_SymbolsID
   mov al, dh
   xlat
   or al, al
   jnz @UpEnd

@UpFailed@0:

   mov dl, dh
   and dl, 3
   cmp dl, 0
   jz @UpFailed@1
   and dh, 252
   jmp GTUSreturns

@UpFailed@1:
   mov dl, dh
   and dl, 4
   cmp dl, 0
   jz @UpFailed@2
   and dh, 251
   jmp GTUSreturns

@UpFailed@2:
   mov ax, '║'

@UpEnd:

  pop bx
  pop si
  pop dx
  pop cx
  ret

GTUS_SymbolsID db '║','╝','╚','╩','║','╣','╠','╬','╜', 0
               db  0 , 0 ,'╢', 0 , 0 , 0 ,'╙', 0 , 0 , 0
               db '╟', 0 , 0 , 0 ,'╨', 0 , 0 , 0 ,'╫', 0

;■······················································■
GetThickUpSymbol endp
cseg      ends
