cseg      segment 'CODE'
GetDownSymbol proc     near
public    GetDownSymbol
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

DownLeftSymbolComp:
   cmp al, ds:[si]
   jnz DownLeftSymbolCont
   or  dh, 1
DownLeftSymbolCont:
   inc si
   loop DownLeftSymbolComp

   lea si, RightSymbol
   mov cx, 13

DownRightSymbolComp:
   cmp ah, ds:[si]
   jnz DownRightSymbolCont
   or  dh, 2
DownRightSymbolCont:
   inc si
   loop DownRightSymbolComp

;■······················································■

   lea si, ThickLeftSymbol
   mov cx, 13

DownThickLeftSymbolComp:
   cmp al, ds:[si]
   jnz DownThickLeftSymbolCont
   or  dh, 8
DownThickLeftSymbolCont:
   inc si
   loop DownThickLeftSymbolComp

   lea si, ThickRightSymbol
   mov cx, 13

DownThickRightSymbolComp:
   cmp ah, ds:[si]
   jnz DownThickRightSymbolCont
   or  dh, 16
DownThickRightSymbolCont:
   inc si
   loop DownThickRightSymbolComp

;■······················································■

   lea si, UpperSymbol
   mov cx, 13

DownUpperSymbolComp:
   cmp bh, ds:[si]
   jnz DownUpperSymbolCont
   or  dh, 4
DownUpperSymbolCont:
   inc si
   loop DownUpperSymbolComp
;■······················································■

GDSreturns:
   cmp dh, 28
   jg  DownFailed@0

   lea bx, GDS_SymbolsID
   mov al, dh
   xlat
   or al, al
   jnz DownEnd

DownFailed@0:
   mov dl, dh
   and dl, 3
   cmp dl, 0
   jz DownFailed@1
   and dh, 252
   jmp GDSreturns

DownFailed@1:
   mov dl, dh
   and dl, 4
   cmp dl, 0
   jz DownFailed@2
   and dh, 251
   jmp GDSreturns

DownFailed@2:
   mov ax, '│'

DownEnd:
  pop bx
  pop si
  pop dx
  pop cx
  ret

GDS_SymbolsID db '│','┐','┌','┬','│','┤','├','┼','╕', 0
              db  0 , 0 ,'╡', 0 , 0 , 0 ,'╒', 0 , 0 , 0
              db '╞', 0 , 0 , 0 ,'╤', 0 , 0 , 0 ,'╪', 0

;■······················································■
GetDownSymbol endp
cseg      ends
