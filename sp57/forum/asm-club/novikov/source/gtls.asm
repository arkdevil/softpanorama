cseg      segment 'CODE'
GetThickLeftSymbol proc     near
public    GetThickLeftSymbol
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

@ThickLeftUpperSymbolComp:
   cmp bh, ds:[si]
   jnz @ThickLeftUpperSymbolCont
   or  dh, 1
@ThickLeftUpperSymbolCont:
   inc si
   loop @ThickLeftUpperSymbolComp

   lea si, ThickLowerSymbol
   mov cx, 13

@ThickLeftLowerSymbolComp:
   cmp bl, ds:[si]
   jnz @ThickLeftLowerSymbolCont
   or  dh, 2
@ThickLeftLowerSymbolCont:
   inc si
   loop @ThickLeftLowerSymbolComp

;

   lea si, UpperSymbol
   mov cx, 13

@LeftUpperSymbolComp:
   cmp bh, ds:[si]
   jnz @LeftUpperSymbolCont
   or  dh, 8
@LeftUpperSymbolCont:
   inc si
   loop @LeftUpperSymbolComp

   lea si, LowerSymbol
   mov cx, 13

@LeftLowerSymbolComp:
   cmp bl, ds:[si]
   jnz @LeftLowerSymbolCont
   or  dh, 16
@LeftLowerSymbolCont:
   inc si
   loop @LeftLowerSymbolComp

;■······················································■

   lea si, ThickLeftSymbol
   mov cx, 13

@LeftSymbolComp:
   cmp al, ds:[si]
   jnz @LeftSymbolCont
   or  dh, 4
@LeftSymbolCont:
   inc si
   loop @LeftSymbolComp


GTLSreturns:

   cmp dh, 28
   jg  @LeftFailed@0

   lea bx, GTLS_SymbolsID
   mov al, dh
   xlat
   or al, al
   jnz @LeftEnd

@LeftFailed@0:

   mov dl, dh
   and dl, 24
   cmp dl, 0
   jz @LeftFailed@1
   and dh, 231
   jmp GTLSreturns

@LeftFailed@1:
   mov dl, dh
   and dl, 4
   cmp dl, 0
   jz @LeftFailed@2
   and dh, 251
   jmp GTLSreturns

@LeftFailed@2:
   mov ax, '═'
@LeftEnd:

  pop bx
  pop si
  pop dx
  pop cx
  ret

GTLS_SymbolsID db '═','╚','╔','╠','═','╩','╦','╬','╘', 0
               db  0 , 0 ,'╧', 0 , 0 , 0 ,'╒', 0 , 0 , 0
               db '╤', 0 , 0 , 0 ,'╞', 0 , 0 , 0 ,'╪', 0

;■······················································■
GetThickLeftSymbol endp
cseg      ends


