ALT1840K:
        jmp start        ; The ALTERNATIVE set KYRYLYZER for es1840 kybd
;                          by  A.A.Titov
;
ohandl1  equ this dword  ; Original Kybd    Address
ohoff1  dw ?
ohpar1  dw ?
;
;
CONVERT PROC NEAR
;       Convert code in AL
      cmp al,080h+48
      jl  exconv
      cmp al,0afh+48
      jg  exconv
          sub al,48
exconv:
        ret
CONVERT ENDP
;
myhandl1:
;
      push cx
      push bp
      push bx
      push ax
      pushf
      CALL DWORD PTR CS:ohoff1
      pushf
      pop cx
      pop bx
      cmp bh,00H
      je  recode
      cmp bh,01H
      jne reti
      push cx
      popf
      jne recode  ; if ZF=0 then key is ready else iret
reti:
      pop bx
      mov bp,sp
      mov ss:[bp+8],cx
      pop bp
      pop cx
      iret
recode:
      call CONVERT
      jmp reti
;
last:
start:
;
; ............................ KEYBOARD ..................
;
;
; ... Get interrupt vector
;
         push es
         mov al,16H   ; Interrupt number = KYBDin
         call GETINT  ; ES:bx - Handler address
         mov cs:ohpar1,es
         mov cs:ohoff1,bx
         pop es
;
; ... Set vector
;
         lea dx,myhandl1
         mov al,16H
         call SETINT
;
; ... TSR this handle
;
         mov dx,cs
         mov ds,dx
         lea dx,last
         inc dx
         int 27H
;
GETINT   PROC
         cli
         mov bx,0
         mov es,bx
         mov ah,0
         mul c4
         push bp
         mov bp,ax
         mov bx,es:[bp]
         push bx
         add bp,2
         mov bx,es:[bp]
         mov es,bx
         pop bx
         pop bp
         sti
         ret
GETINT   ENDP
;
SETINT   PROC
         cli
         push es
         push bp
         push bx
         mov bx,0
         mov es,bx
         mov ah,0
         mul c4
         mov bp,ax
         mov es:[bp],dx
         add bp,2
         mov bx,cs
         mov es:[bp],bx
         pop bx
         pop bp
         pop es
         sti
         ret
SETINT   ENDP
c4       db 04H
;
       end ALT1840K
