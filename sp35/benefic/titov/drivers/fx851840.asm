;                          This is fx851840 module by A.Titov
fx851840:
        jmp last
;
align   dd ?
;
ohandl2  equ this dword  ; Original Handler Address
ohoff2  dw ?
ohpar2  dw ?
;
;
PRNhandle:
;
      cli
      CMP aH,00H
      JNE ORI
      cmp al,128
      jl  ori
      cmp al,133
      jg  p2
          add al,161-128
          jmp ORI
p2:
      cmp al,159
      jg  p3
          add al,168-134
          jmp ORI
p3:
      cmp al,165
      jg  p4
          add al,209-160
          jmp ORI
p4:
      cmp al,175
      jg  p5
          add al,216-166
          jmp ORI
p5:
      cmp al,224
      jl  ori
      cmp al,239
      jg  ori
          add al,226-224
;
; ... issue original service
;
ORI:  JMP  DWORD PTR CS:OHANDL2
;
;
last:
;
;
; ............................ PRINTER ...................
;
; ... Get interrupt vector
;
         push es
         mov ah,35H
         mov al,17H   ; Interrupt number = PRNout
         int 21H      ; ES:bx - Handler address
         mov cs:ohpar2,es
         mov cs:ohoff2,bx
         pop es
;
; ... Set vector
;
         lea dx,PRNhandle
         mov al,17H
         mov ah,25H
         int 21H
;
         lea dx,setted
         mov ah,09H
         int 21H
; ... TSR this handle
;
         lea dx,last
         inc dx
         int 27H
;
setted  db 07H,0DH,0AH,"<FX851840 0.1> Эмулятор альтернативной кодировки принтера FX-85,",0dh,0ah
        db             "               предназначенного для ЕС-1840.  (C) А.Титов, 1990",0dh,0ah,24H
        end fx851840
