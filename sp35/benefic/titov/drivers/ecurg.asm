ecurg:
        jmp start
;
hlet    db 14
wlet    db 8
svddots db 8 dup (0)
gccol   dw 0
gcrow   dw 0
scol    dw 0
countm  db 0
letcur  db 1
pausiz  dw 400           ; Blink pause
pause2  db 4
ccolor  db 14
;
;
ohandl9  equ this dword  ; Original INT 09H Address
ohoff9  dw ?
ohpar9  dw ?
myhandl9:
; ... My own interrupt handler  for INT 09H
;
      cli
      push ax
      in al,60H
      cmp al,83       ; Del
      je  delpres
ori9:
      pop ax
      sti
      JMP  DWORD PTR CS:OHANDL9
delpres:
;
      push bx
      push ds
      mov ax,0
      mov ds,ax
      mov bx,0417H
      mov al,[bx]
      pop ds
      and al,02H        ; Left Shift
      cmp al,02H
      jne ret09
      in al,61H
      mov ah,al
      or al,80H
      out 61H,al
      xchg ah,al
      out 61H,al
      mov al,20H
      out 20H,al
      mov al,cs:letcur
      cmp al,0
      je  make1
          mov al,0
          push cx
          push ax
          push bx
          push dx
          mov al,1
          mov cs:erased,al
          call RESTOLD
          pop dx
          pop bx
          pop ax
          pop cx
          jmp annov
make1:
      mov al,1
annov:
      mov cs:letcur,al
      pop bx
      pop ax
      sti
      iret
ret09:
      pop bx
      jmp ori9
chkid dw 1313
handle10:
;
         cli
         push ds
         push cx
         push dx
         push bx
         push ax
;
         mov ah,0fh
         call ORIGINAL
         mov cs:erapag,bh
         cmp al,4
         jl exori
;        cmp al,7
;        je exori ; Hercules is not processing !
;
         pop ax
         push ax
         cmp ah,02H
         jne m5
         jmp setpos
m5:
;
         cmp ah,09H
         jne m3
         jmp writca
m3:
;
         cmp ah,0AH
         jne m2
         jmp writc
m2:
;
         cmp ah,0EH
         jne m1
         jmp writt
m1:
         cmp ah,06h
         jne m00
         jmp scroll
m00:
         cmp ah,07h
         jne m000
         jmp scroll
m000:
;
exori:
         pop ax
         pop bx
         pop dx
         pop cx
         pop ds
         sti
         jmp DWORD PTR cs:ori10
;
reti:
         pop ax
         pop bx
         pop dx
         pop cx
         pop ds
         sti
         iret
;
scroll:
setpos:
        call RESTOLD
; ... Locate to new
        pop ax
        pop bx
        pop dx
        CALL ORIGINAL
        push dx
        push bx
        push ax
;
        jmp reti
;
writc:
;
writca:
;
writt:
        call RESTOLD
        pop ax
        pop bx
        pop dx
        pop cx
        CALL ORIGINAL
        push cx
        push dx
        push bx
        push ax
;
        jmp reti
;
RESTOLD  PROC
         push bp
         mov al,cs:erased
         cmp al,0
         je retr
            mov al,0
            mov cs:erased,al
        mov bh,cs:erapag
        mov dx,cs:gcrow
        lea bp,svddots
        mov cx,8
lrest:
        push cx
        mov cx,cs:gccol
        mov al,cs:[bp]
        mov ah,0ch
        CALL ORIGINAL
        inc cx
        inc bp
        mov cs:gccol,cx
        pop cx
        loop lrest
retr:
        pop bp
        ret
RESTOLD ENDP
;
ORIGINAL PROC
      pushf
      call DWORD PTR cs:ori10
      ret
ORIGINAL ENDP
;
SCUR     PROC
         push bp
; ... Get the char
        mov al,0
        mov cs:erased,al
        mov al,cs:letcur
        cmp al,0
        jne ntr
            jmp exgc
ntr:
        mov bh,cs:erapag
        mov ah,03h
        CALL ORIGINAL
        mov cs:crow,dh
        mov cs:ccol,dl
;       cmp dh,24
;       jl  pro
;       jmp exgc
pro:
         mov al,1
         mov cs:erased,al
        xor ax,ax
        mov al,cs:crow
        inc al
        mul cs:hlet
        dec ax
        dec ax
        mov cs:gcrow,ax
        xor ax,ax
        mov al,cs:ccol
        mul cs:wlet
        mov cs:gccol,ax
;
        mov bh,cs:erapag
        mov dx,cs:gcrow
        lea bp,svddots
        mov cx,cs:gccol
        mov cs:scol,cx
        mov cx,8
lget:
        push cx
        mov cx,cs:scol
        mov ah,0dh
        CALL ORIGINAL
        cmp al,cs:hlet
        je nosave
        mov cs:[bp],al
nosave:
        inc cx
        inc bp
        mov cs:scol,cx
        pop cx
        loop lget
; ... Visualize the cursor
        mov bh,cs:erapag
        mov dx,cs:gcrow
        mov cx,cs:gccol
        mov cs:scol,cx
        mov cx,8
        mov al,cs:countm
        cmp al,cs:pause2
        jg  resc
            inc al
            mov cs:countm,al
            mov al,cs:ccolor
            jmp gcurs
resc:
        mov al,0
        mov cs:countm,al
gcurs:
        push cx
        push ax
        mov cx,cs:scol
        mov ah,0ch
        CALL ORIGINAL
        inc cx
        mov cs:scol,cx
        pop ax
        pop cx
        loop gcurs
;
exgc:
        pop bp
        ret
SCUR    ENDP
;
handle16:
;
         cli
         push ds
         push cx
         push dx
         push bx
         push ax
;
         cmp ah,00H  ; Wait for key
         je  nocountr
         cmp ah,01H  ; Scan keycode
         je  testi
         jmp exori16
testi:
         mov ax,cs:countr
         inc ax
         mov cs:countr,ax
         cmp ax,cs:pausiz
         jl  exori16
             mov ax,0
             mov cs:countr,ax
nocountr:
         mov ah,0fh
         call ORIGINAL
         cmp al,4
         jl exori16
         cmp al,7
         je exori16 ; Hercules is not processing !
            call SCUR
exori16:
         pop ax
         pop bx
         pop dx
         pop cx
         pop ds
         sti
         jmp dword ptr cs:ori16
;
;
;TOREBI1:
; STORE CURSOR ADDR IN THE BIOS         (internal proc)
; INPUT:
;         DX is the cursor addr
;
;         push ds
;         push dx
;         mov dx,0
;         mov ds,dx
;         pop dx
;         mov ds:[0450H],dx     ; BIOS data area cursor addr
;         pop ds
;         ret
;
;
;NQBI1:
; INQ   CURSOR ADDR FR THE BIOS         (internal proc)
; OUTPUT:
;         trow,tcol
;
;         push ds
;         push dx
;         mov dx,0
;         mov ds,dx
;         mov dx,ds:[0450H]
;         mov cs:trow,dh
;         mov cs:tcol,dl
;         pop dx
;         pop ds
;         ret
;
cursor  db '_'
countr  dw 100
cchr    db 00h  ; Cur displ char
del     db 08h
crow    db 0    ; 0-based current cursor row
ccol    db 0    ; ---"---                column
erachr  db " "  ; character erased by cursor
erased  db 0    ; no chars erased
erapag  db 0
        dd ?
ori10   equ this DWORD        ; Original int10 address
ohoff2  dw ?
ohpar2  dw ?
ori16   equ this DWORD        ; Original int16 address
ohoff16 dw ?
ohpar16 dw ?
;
start:
         call TESTMODE
         push es
         mov ah,35H
         mov al,10H   ; Interrupt number = Video
         int 21H      ; ES:bx - Handler address
         mov cs:ohpar2,es
         mov cs:ohoff2,bx
         mov ax,cs:chkid
         cmp es:[bx-2],ax
              jne ini
              pop es
              jmp present
ini:
         pop es
; ... Set vector
         lea dx,handle10
         mov al,10H
         mov ah,25H
         int 21H
;
         push es
         mov ah,35H
         mov al,16H   ; Interrupt number = Kybd
         int 21H      ; ES:bx - Handler address
         mov cs:ohpar16,es
         mov cs:ohoff16,bx
         pop es
; ... Set vector
         lea dx,handle16
         mov al,16H
         mov ah,25H
         int 21H
; ............................ INT 09H ...................
;
; ... Get interrupt vector
;
         push es
         mov al,09H   ; Interrupt number = Low-Level-Keyboard
         mov ah,35h   ; ES:bx - Handler address
         int 21H
         mov cs:ohpar9,es
         mov cs:ohoff9,bx
         pop es
;
; ... Set vector
;
         lea dx,myhandl9
         mov al,09H
         mov ah,25H
         int 21h
;
         lea dx,setted
         mov ah,09H
         int 21H
; ... TSR this handle
;
         lea dx,start
         inc dx
         int 27H
present:
         lea dx,alrdpre
         mov ah,09H
         int 21H
eeeee:   mov ah,4CH
         int 21H
;
setted  db 07H,0DH,0AH,"<EcurG 0.6> Эмулятор курсора в графическом режиме",0dh,0ah
        db             "            Левый Shift + Del  -> Курсор есть/нет",0dh,0ah
        db             "            (C) Copyright  ОНИЛ САПР КИСМ, 1990  ",0dh,0ah,24h
alrdpre db 07H,0DH,0AH,"<EcurG 0.6> уже загружен !",0DH,0AH
        db             "(C)Copyright ОНИЛ САПР,1990 г.Кировоград УССР 8:052-22:93-9-28",0DH,0AH
        db 0DH,0AH,24H
;
TESTMODE:
;                          Test CRT type
;----------- Is any (DCP or Hercles plus) emlator present ? ----------
        push ax
        push bx
        push es
        mov al,10H   ; Interrupt number = Videoserv
        mov ah,35H
        int 21H      ; ES:bx - Handler address
        mov ax,666   ; DCP chkid
        cmp es:[bx-2],ax
        je thisDCP
        mov ax,6666
        cmp es:[bx-2],ax
        je thisHRC
             jmp CGAEGA
; ----------- Hercles pls GB112 -------------
thisHRC:
        mov al,14
        mov cs:hlet,al
        mov ax,400
        mov cs:pausiz,ax
        mov al,4
        mov cs:pause2,al
        mov al,1
        mov cs:ccolor,al
        jmp set
; ----------- DCP Robotron ------------------
thisDCP:
        mov al,84
        mov cs:hlet,al
        mov ax,100
        mov cs:pausiz,ax
        mov al,12
        mov cs:pause2,al
        mov al,4
        mov cs:ccolor,al
        jmp set
;----------- What adapter,CGA or EGA ? ---------------
CGAEGA:
        mov bx,04A8H      ; 4-byte EGA SAVE_PTR
        xor ax,ax
        mov es,ax
        mov ax,es:[bx]
        mov bx,04AAH      ; low word
        mov bx,es:[bx]
        cmp ax,0
        jne ega
        cmp bx,0
        jne ega
;----------- CGA ---------------------------
cga:
        mov al,8
        mov cs:hlet,al
        mov ax,160
        mov cs:pausiz,ax
        mov al,4
        mov cs:pause2,al
        mov al,1
        mov cs:ccolor,al
        jmp set
;----------- EGA ---------------------------
ega:
        mov al,14
        mov cs:hlet,al
        mov ax,400
        mov cs:pausiz,ax
        mov al,4
        mov cs:pause2,al
        mov al,14
        mov cs:ccolor,al
;----------- Exit          -----------------
set:
        pop es
        pop bx
        pop ax
        ret
      end ecurg
