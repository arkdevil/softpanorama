EMAIN:
        jmp start        ; The MAIN-on-ALTERNATIVE font emulator
;                          by  A.A.Titov,  Advanced Edition
trtab    db 34 dup (?)
         db 34 dup (?)
;
align   dd ?
ohandle  equ this dword  ; Original Screen  Address
ohoffs  dw ?
ohpara  dw ?
;
;
ohandl1  equ this dword  ; Original Kybd    Address
ohoff1  dw ?
ohpar1  dw ?
;
;
ohandl2  equ this dword  ; Original Printer Address
ohoff2  dw ?
ohpar2  dw ?
;
;
ohandl9  equ this dword  ; Original INT 09H Address
ohoff9  dw ?
ohpar9  dw ?
;
recn    dw 31999
cursp   dw ?
oldrow  db 200
oldlin  db 200
oldpage db 200
disabled db 0
letmem  db 1     ; 0 if the DYNAMIC recoding disabled by Left Shift+Home
;
SCREEN  PROC NEAR
;       Recoding the CGA memory
;
      push ds
      push cx
      push ax
      push bx
      push dx
;
      mov al,cs:letmem
      cmp al,0
      jne rrr21
      jmp retcga
rrr21:
;
      mov ax,cs:recn
      cmp ax,16 ; For Amstrad PC1640
      jng tyrty
      jmp rece
tyrty:
      inc ax
      mov cs:recn,ax
      jmp retcga
NONCOND:
      push ds
      push cx
      push ax
      push bx
      push dx
;
      mov al,cs:letmem
      cmp al,0
      jne rrr22
      jmp retcga
rrr22:
;
      mov ah,0FH   ; Read video-mode
      int 10H      ; Page in bh
      mov ah,cs:oldpage
      mov cs:oldpage,bh
      cmp bh,ah
      jne rece
      mov ah,03H   ; Read cursor position
      int 10H      ; Row,lin in DH,DL
      mov al,cs:disabled
      cmp al,0
      je enabled
         cmp dl,0  ; Line
         je enabled
         cmp dl,23
         je enabled
         cmp dl,24
         je enabled
         jmp retcga
enabled:
      mov ah,cs:oldrow
      mov al,cs:oldlin
      mov cs:oldrow,dh
      mov cs:oldlin,dl
      cmp ah,dh
      je  tstl
      cmp al,dl
      jne rece
tsth:
      sub ah,dh
      cmp ah,1
      jne n1
      jmp retcga
n1:   cmp ah,-1
      jne n2
      jmp retcga
n2:   jmp rece
tstl:
      sub al,dl
      cmp al,1
      jne n3
      jmp retcga
n3:   cmp al,-1
      jne rece
      jmp retcga
rece:
      mov ax,0
      mov cs:recn,ax
;                           Is this an Graphic/MDA mode ?
      mov ds,ax
      mov bx,449H          ;Video-mode
      mov al,[bx]
      cmp al,3
      jng nogr
      jmp retcga
nogr:
      mov cx,2000
      cmp al,1
      jg  full
      mov cx,1000
full:
      dec cx
;
      cli
;
      mov dx,3DAH
      mov ax,0B800H
      mov ds,ax
;
lb800:
      mov bx,cx
      shl bx,1
p8:
        in al,dx
        test al,9
        jnz p8
p91:
        in al,dx
        test al,9
        jz  p91
;
      mov ah,[bx]
      cmp ah,080h+48
      jl  excons
      cmp ah,0afh+48
      jg  excons
          sub ah,48
p81:
;         in al,dx
;         test al,9
;         jnz p81
p92:
;         in al,dx
;         test al,9
;         jz  p92
          mov [bx],ah
excons:
      loop lb800
;
      sti
;
retcga:
      pop dx
      pop bx
      pop ax
      pop cx
      pop ds
        ret
;
SCREEN  ENDP
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
chkid   dw 666
myhandl1:
; ... My own interrupt handler  for KYBD
;
      cmp ah,02H
      jnl kbdp
      cmp ah,00H
      jg ccs
      call NONCOND
      jmp kbdp
ccs:
      call SCREEN
;                         Process KYBDIN
kbdp:
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
      cmp al,0
      je  cke
      cmp al,57
      jng reti
      cmp al,126
      jg  reti
      push es          ; Check, if CAPSLOCK is pressed
      mov bx,0
      mov es,bx
      mov bp,417H
      mov bl,es:[bp]
      pop es
      jmp reti
;
cke:
      cmp ah,72  ; Up arrow
      je arr
      cmp ah,80  ; Down arrow
      je arr
      jmp reti
arr:
      mov bl,1
      mov cs:disabled,bl
      jmp reti
;
myhandle:
; ... My own interrupt handler  for SCREEN
;
      CMP aH,09H
      JE  RECOD
      cmp ah,0AH
      je  recod
      CMP aH,0EH
      JE  RECOD
      jmp exr
recod:
      call CONVERT
exr:
; ... issue original service
;
      JMP  DWORD PTR CS:OHANDLE
;
;
myhandl2:
; ... My own interrupt handler  for PRINTER
;
      CMP aH,00H
      JE  RECOD2
      jmp exr2
recod2:
      call CONVERT
exr2:
; ... issue original service
;
      JMP  DWORD PTR CS:OHANDL2
;
;
myhandl9:
; ... My own interrupt handler  for INT 09H
;
      cli
      push ax
      in al,60H
      cmp al,71       ; Home
      je  homepres
      pop ax
      sti
      JMP  DWORD PTR CS:OHANDL9
homepres:
      in al,61H
      mov ah,al
      or al,80H
      out 61H,al
      xchg ah,al
      out 61H,al
      mov al,20H
      out 20H,al
;
      push ds
      push bx
      mov ax,0
      mov ds,ax
      mov bx,0417H
      mov al,[bx]
      and al,02H        ; Left Shift
      cmp al,02H
      jne ret09
      mov al,cs:letmem
      cmp al,0
      je  make1
          mov al,0
          jmp annov
make1:
      mov al,1
annov:
      mov cs:letmem,al
      call CONVERT
ret09:
      pop bx
      pop ds
      pop ax
      sti
      iret
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
         mov ax,cs:chkid
         cmp es:[bx-2],ax
              jne set
              pop es
              jmp present
set:
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
;
; ............................ PRINTER ...................
;
; ... Get interrupt vector
;
         push es
         mov al,17H   ; Interrupt number = PRNout
         call GETINT  ; ES:bx - Handler address
         mov cs:ohpar2,es
         mov cs:ohoff2,bx
         pop es
;
; ... Set vector
;
         lea dx,myhandl2
         mov al,17H
         call SETINT
;
;
; ............................ INT 09H ...................
;
; ... Get interrupt vector
;
         push es
         mov al,09H   ; Interrupt number = Low-Level-Keyboard
         call GETINT  ; ES:bx - Handler address
         mov cs:ohpar9,es
         mov cs:ohoff9,bx
         pop es
;
; ... Set vector
;
         lea dx,myhandl9
         mov al,09H
         call SETINT
;
;    .................. SCREEN ......................
;
; ... Get interrupt vector
;
         push es
         mov al,10H   ; Interrupt number = Videoserv
         call GETINT  ; ES:bx - Handler address
         mov cs:ohpara,es
         mov cs:ohoffs,bx
         pop es
;
; ... Set vector
;
         lea dx,myhandle
         mov al,10H
         call SETINT
;
; ... TSR this handle
;
         lea dx,setted
         mov ah,09H
         int 21H
         mov dx,cs
         mov ds,dx
         lea dx,last
         inc dx
         int 27H
;
present:
         lea dx,alsopre
         mov ah,09H
         int 21H
         mov ah,4CH
         int 21H
alsopre db 07H,0DH,0AH,"ЭМУЛЯТОР ОСНОВНОГО НАБОРА УЖЕ ЗАГРУЖЕН",0DH,0AH
        db 07H,0DH,0AH,24H
;
setted  db 07H,0DH,0AH,"ЭМУЛЯТОР ОСНОВНОГО НАБОРА ЗАГРУЖЕН",0DH,0AH
        db 0DH,0AH
        db             "г.Кировоград УССР тел. 93-9-28",0DH,0AH
        db             "(C)Copyright A.A.Титов,   1989  Advanced edition 2.4",0DH,0AH
        db 0DH,0AH
        db             "Теперь Вы сможете работать одновременно с ЛЮБЫМИ программами",0dh,0aH
        db             "основного и альтернативного наборов.",0dh,0aH
        db             "С клавиатуры вводятся АЛЬТЕРНАТИВНЫЕ коды.",0dh,0aH
        db 0DH,0AH
        db             "ВНИМАНИЕ: обычно эмуляция производится путем сканирования",0dh,0aH
        db             "          памяти видеоадаптера. Это иногда приводит ",0dh,0aH
        db             "          к назойливому замедлению, хотя сканирование и де-",0dh,0ah
        db             "          лается весьма хитроумно и не всегда. ",0dh,0ah
        db 0DH,0AH
        db             "СКАНИРОВАНИЕ ВЫКЛЮЧАЕТСЯ/ВКЛЮЧАЕТСЯ: Левый Shift + Home",0dh,0ah
        db 0DH,0AH
        db             "В режиме выключенного сканирования эмулируются только ",0dh,0ah
        db             "программы, работающие через DOS/BIOS.",0dh,0ah
        db 0DH,0AH,24H
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
       end EMAIN
