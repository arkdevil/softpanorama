;                          This is BAPRN module by A.Titov
BAPRN:
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
      cmp al,0e0h-48 ;  From B to A
      jl  ORI
      cmp al,0efh-48
      jg  ORI
          add al,48
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
setted  db 07H,0DH,0AH,"<BAPRN 0.1> Bulgar-on-Alternative printer font emulator",0dh,0ah,24h
       end BAPRN

