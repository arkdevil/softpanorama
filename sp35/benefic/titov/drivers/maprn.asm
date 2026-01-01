;                          This is MAPRN module by A.Titov
MAPRN:
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
      cmp al,080h+48
      jl  exr2
      cmp al,0afh+48
      jg  ORI
          sub al,48
      jmp ORI
exr2:
      cmp al,080H
      jl ORI
      sub al,080H
      push bx
      lea bx,pseudo
      add bx,ax
      mov al,cs:[bx]
      pop bx
;
; ... issue original service
;
ORI:  JMP  DWORD PTR CS:OHANDL2
;
pseudo:
       db 0CFH       ; The Soviet Paranoya !
       db 0D0H
       db 0D1H
       db 0B5H
       db 0B6H
       db 0B7H
       db 0B8H
       db 0D2H
       db 0D3H
       db 0D4H
       db 0D5H
       db 0BDH
       db 0BEH
       db 0C6H
       db 0C7H
       db 0D6H
       db 0C9H
       db 0BBH
       db 0BCH
       db 0C8H
       db 0CDH
       db 0BAH
       db 0CBH
       db 0B9H
       db 0CAH
       db 0CCH
       db 0CEH
       db 0B0H
       db 0B1H
       db 0B2H
       db 0D7H
       db 0D8H
       db 0DAH
       db 0BFH
       db 0D9H
       db 0C0H
       db 0C4H
       db 0B3H
       db 0C2H
       db 0B4H
       db 0C1H
       db 0C3H
       db 0C5H
       db 0DBH
       db 0DCH
       db 0DDH
       db 0DEH
       db 0DFH
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
setted  db 07H,0DH,0AH,"<MAPRN 0.1> Main-on-Alternative printer font emulator",0dh,0ah,24h
       end MAPRN
