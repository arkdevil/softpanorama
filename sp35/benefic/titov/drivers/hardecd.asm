HARDECD:
;       EGA hardcopyer for Amstrad DMP4000 printer   (C) Titov, 1989
;
        jmp start
grmode  db 0           ; 1 if in graphic mode 0 if text 25*80
nticks  dw 0           ; Tick interval for int 09H restoring
videopag    db 0       ; Videopag num
hdots0  dw 639         ; 0-based horisontally dot-number
vdots0  dw 349         ; 0-based vertically   dot-number
trow    db 0           ; Text-row 0-24
tcol    db 0           ; Text-col 0-79
trowold db 0           ; Text-row & col before text screen priting
tcolold db 0
PRNbase dw 0           ; Base printer port 0-offset
strnum dw 0            ; Screen 0-based string num
prow   db 0            ; Print  1-based row num
maxprow db 0           ; Num of of print rows
sbyte  dw 0            ; Screen 0-based column 0-639
prbyte1 db 0           ; Bytes for printer
prbyte2 db 0
colrow  db 0           ; Screen-point printer dot-matrix number 0-3
color   db 0           ; Screen-point color 0-15
lparta  dw 0           ; Offsets of matrix-parts
rparta  dw 0
lf      db 10
cr      db 13
ESCcode     db 27
can     db 24
skips   db 48
nul     db 0
ichar   db 'i'
atcom   db '@'
cden    db 'L'
Prbacksp   db 'j'
matroffs dw 0          ; Matrix offset
;
align   dd ?
ohandl9  equ this dword  ; Old      INT 09H Address
ohoff9  dw ?
ohpar9  dw ?
;
EGAM:                  ; 2 bytes per color; color is in low 2 bits
        db 11b  ; Color 0
        db 11b
;
        db 11b  ; Color 1    01
        db 10b  ;            00
;
        db 11b  ; Color 2    11
        db 01b  ;            10
;
        db 11b  ; Color 3
        db 00b
;
        db 10b  ; Color 4
        db 11b
;
        db 10b  ; Color 5
        db 10b
;
        db 10b  ; Color 6
        db 01b
;
        db 10b  ; Color 7
        db 00b
;
        db 01b  ; Color 8
        db 11b
;
        db 01b  ; Color 9
        db 10b
;
        db 01b  ; Color 10
        db 01b
;
        db 01b  ; Color 11
        db 00b
;
        db 00b  ; Color 12
        db 11b
;
        db 00b  ; Color 13
        db 10b
;
        db 00b  ; Color 14
        db 01b
;
        db 00b  ; Color 15
        db 00b
;
CGAL:                  ; 2 bytes per color; color is in low 2 bits
        db 11b  ; Color 0
        db 11b
;
        db 11b  ; Color 1    01
        db 10b  ;            00
;
        db 10b  ; Color 2    11
        db 01b  ;            10
;
        db 11b  ; Color 3
        db 00b
;
        db 01b  ; Color 4
        db 10b
;
        db 10b  ; Color 5
        db 10b
;
        db 00b  ; Color 6
        db 01b
;
        db 00b  ; Color 7
        db 00b
;
CGAH:                  ; 2 bytes per color; color is in low 2 bits
        db 00b  ; Color 0
        db 00b
;
        db 11b  ; Color 1    01
        db 11b  ;            00
myhandl9:
; ... My own interrupt handler  for INT 09H
;
      push ax
      in al,60H
      cmp al,55       ; Prt Sc
      je  homepres
      cmp al,54H      ; Prt Sc
      je  homepres
ori9:
      pop ax
      jmp  DWORD PTR CS:OHANDL9
homepres:
;
      cli
      push ds
      push bx
      mov ax,0
      mov ds,ax
      mov bx,0417H
      mov al,[bx]
      pop bx
      pop ds
      and al,08H        ; Alt
      cmp al,08H
      jne ori9
      in al,61H
      mov ah,al
      or al,80H
      out 61H,al
      xchg ah,al
      out 61H,al
      mov al,20H
      out 20H,al
      sti
          push bp
          push ax
          push bx
          push cx
          push dx
          push di
          push si
          push ds
          push es
              push cs
              pop ds
      call ACTION
          pop  es
          pop  ds
          pop  si
          pop  di
          pop  dx
          pop  cx
          pop  bx
          pop  ax
          pop bp
      mov al,0
      pop ax
      iret
;
ACTION:
       call CHECKHDW
       cmp ah,0
       jne exit
;
       mov al,grmode
       cmp al,0
       jne egag
           call DOTEXT
           jmp  exit
egag:
       call DOEGA
exit:
       ret
;
DOTEXT:
       mov bh,videopag
       mov ah,03H   ; Get position
       int 10H
       mov trowold,dh
       mov tcolold,dl
;
       mov al,0
       mov trow,al
rowc:
       mov al,trow
       cmp al,24
       jg  exrowc
           mov al,0
           mov tcol,al
colc:      mov al,tcol
           cmp al,79
           jg excolc
              mov bh,videopag
              mov dh,trow
              mov dl,tcol
              mov ah,02H   ; Set position
              int 10H
              mov bh,videopag
              mov ah,08H   ; Get char
              int 10H
              call OUTPRN  ; print char in al
           mov al,tcol
           inc al
           mov tcol,al
           jmp colc
excolc:
       mov al,cr
       call OUTPRN
       mov al,lf
       call OUTPRN
       mov al,trow
       inc al
       mov trow,al
       jmp rowc
exrowc:
       mov bh,videopag
       mov dh,trowold
       mov dl,tcolold
       mov ah,02H   ; Set position
       int 10H
       ret
;
DOEGA:
       mov bx,vdots0
       inc bx
       shr bx,1
       shr bx,1
       inc bx
       mov maxprow,bl
;
       mov ax,0
       mov strnum,ax
;
       mov al,1
       mov prow,al
for1:
       mov al,prow
       cmp al,maxprow
       jg exfor1
          call CLEARROW
          call SIGNALROW
          call FORMROW
          call SKIPLINE
          mov ax,strnum
          add ax,4
          mov strnum,ax
       mov al,prow
       inc al
       mov prow,al
       jmp for1
exfor1:
       ret
;
CHECKHDW:
       push ds
       xor ax,ax
       mov ds,ax
       mov bx,0408H    ; 1st BIOS-detected printer of 0408H-040EH
prndl:                 ; Printer-detection loop
       cmp bx,040eH
       jg  notfound
       mov ax,[bx]
       cmp ax,0
       jne detected
       add bx,2
       jmp prndl
notfound:
       pop ds
bells: mov cx,3
belll: push cx
       call BELL
       pop cx
       loop belll
       mov ah,16
       ret
detected:
       pop ds
       mov PRNbase,ax
;
       mov ah,0FH     ; Get video-mode
       int 10H
       mov videopag,bh
       cmp al,10H
       je  egagr
       cmp al,0FH
       je egagr
       cmp al,3
       je textm
       cmp al,2
       je textm
       cmp al,7
       je textm
       cmp al,4
       je g320200
       cmp al,5
       je g320200
       cmp al,6
       je g640200
       cmp al,0dH
       je g320200
       cmp al,0eH
       je g640200
          jmp bells
graphm:
       mov al,1
       jmp setm
g320200:
       mov ax,319
       mov hdots0,ax
       mov ax,199
       mov vdots0,ax
       mov al,'K'
       mov cden,al
       lea ax,CGAL
       mov matroffs,ax
       jmp graphm
g640200:
       mov ax,639
       mov hdots0,ax
       mov ax,199
       mov vdots0,ax
       mov al,'L'
       mov cden,al
       lea ax,CGAH
       mov matroffs,ax
       jmp graphm
egagr:
       mov ax,639
       mov hdots0,ax
       mov ax,349
       mov vdots0,ax
       mov al,'L'
       mov cden,al
       lea ax,EGAM
       mov matroffs,ax
       jmp graphm
textm:
       mov al,0
setm:  mov grmode,al
;
       call READYPRN
       mov dx,PRNbase
       add dx,2        ; Printer-Control
       mov al,8        ; Initialize
       out dx,al
       mov ax,10000
b9:    dec ax
       jnz b9
       mov al,0CH
       out dx,al
;      mov al,0
;      out dx,al
       mov ah,0
       ret
;
CLEARROW:
       xor al,al
       mov prbyte1,al
       mov prbyte2,al
       ret
;
SIGNALROW:
       mov al,lf
       call OUTPRN
       mov al,ESCcode
       call OUTPRN
       mov al,ichar
       call OUTPRN
       mov al,nul
       call OUTPRN
       mov al,ESCcode
       call OUTPRN
       mov al,atcom
       call OUTPRN
       mov al,cr
       call OUTPRN
       mov al,lf
       call OUTPRN
;
       mov al,ESCcode
       call OUTPRN
       mov al,cden
       call OUTPRN
       mov bx,hdots0
       inc bx
       shl bx,1
       mov ax,bx
       mov dx,0
       mov bx,256
       div bx
       push ax
       mov al,dl
       call OUTPRN
       pop ax
       call OUTPRN
; ...  Ready for graphic receiving
       ret
;
SKIPLINE:
       mov al,ESCcode
       call OUTPRN
       mov al,Prbacksp
       call OUTPRN
       mov al,skips
       call OUTPRN
       mov al,cr
       call OUTPRN
       ret
;
FORMROW:
       mov ax,0
       mov sbyte,ax
for2:
       mov ax,sbyte
       cmp ax,hdots0
       jg exfor2
          call FORMCOL
          mov al,prbyte1
          call OUTPRN
          mov al,prbyte2
          call OUTPRN
       mov ax,sbyte
       inc ax
       mov sbyte,ax
       jmp for2
exfor2:
        ret
;
FORMCOL:
        mov al,0
        mov colrow,al
for3:
        mov al,colrow
        cmp al,3
        jg exfor3
           mov ax,strnum
           mov bh,0
           mov bl,colrow
           add ax,bx
           cmp ax,vdots0
           jg arif1
                            ; String in ax
              mov bx,sbyte  ; Column in bx
              call GETCOLOR ; Out byte "color"
              call PUTCOLOR
arif1:
        mov al,colrow
        inc al
        mov colrow,al
        jmp for3
exfor3:
        ret
;
PUTCOLOR:
        mov bh,0
        mov bl,color
        shl bx,1           ; bx=color*2
        mov ax,matroffs
        add bx,ax          ; bx is 1st bit-column addr
        mov lparta,bx
        inc bx             ;       2nd
        mov rparta,bx
;
        mov bh,0
        mov bl,colrow
        shl bx,1           ; al now is 0-based bit num for matrix location
        mov al,bl
        mov bx,lparta      ; matrix offset
        mov dl,prbyte1     ; byte to be changed
        call LOCATE
        mov prbyte1,dl     ; Out parameter!
        mov bh,0
        mov bl,colrow
        shl bx,1           ; al now is 0-based bit num for matrix location
        mov al,bl
        mov bx,rparta      ; matrix offset
        mov dl,prbyte2     ; byte to be changed
        call LOCATE
        mov prbyte2,dl     ; Out parameter!
;
        ret
;
LOCATE:
;       al is bit-num for location 0-6
;       bx is matrix byte offset; matrix byte: 0000 0011 <- Significant 2 low
;       dl is the byte to be chang. OUT parm!
;
        mov cl,6
        sub cl,al         ; Shift no in cl
        push bx
        mov bh,0
        mov bl,00000011B
        shl bx,cl
        not bx
        and dl,bl
        pop bx
        mov cl,6
        sub cl,al         ; Shift no in cl
        mov bl,[bx]
        mov bh,0
        shl bx,cl
        or dl,bl
        ret
;
OUTPRN:
;       Send byte in al  to system-printer
        push ax
        call READYPRN
        mov dx,PRNbase
        add dx,2          ; Printer control
        mov bx,dx
        mov al,4
        out dx,al
        mov dx,PRNbase    ; Data latch
        pop ax
        out dx,al
        mov dx,bx         ; Printer control
        mov al,5
        out dx,al
        ret
;
BELL:
        mov al,7
        mov bl,0
        mov ah,0EH      ; Bell in Teletype mode
        INT 10H
        ret
;
READYPRN:
        mov dx,PRNbase
        inc dx           ; Printer status
testerr:
        in al,dx
        mov bl,al
        and al,80H
        cmp al,80H        ; No busy,offline,err
        jne testerr
        mov al,bl
        and al,0f0H
;       cmp al,80H        ; Power is off
;       je testerr
        cmp al,40H        ; Off-line
        je testerr
        cmp al,60H        ; No paper
        je testerr
        ret
;
GETCOLOR:
;      Get screen-dot color 0-15 to "color" byte
;      0-based row in ax
;      0-based col in bx
       mov dx,ax
       mov cx,bx
       mov bh,videopag
       mov ah,0DH
       int 10H
       mov color,al
       ret
last:
start:
; ............................ INT 09H ...................
         push es
         mov al,09H   ; Interrupt number = Low-Level-Keyboard
         call GETINT  ; ES:bx - Handler address
         mov cs:ohpar9,es
         mov cs:ohoff9,bx
         pop es
         lea dx,myhandl9
         mov al,09H
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
setted  db 07H,0DH,0AH,"Amstrad ECD,CD,MM screen hardcopy maker for DMP4000 printer",0DH,0AH
        db             "V.M 1.2 Use Alt+PrtSc to print screen   (C) A.A.Titov,1989",0DH,0AH,0DH,0AH,24H ;
;
GETINT   PROC
         cli
         push bp
         mov bx,0
         mov es,bx
         mov ah,0
         mul cs:c4
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
         mul cs:c4
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
;
c4       db 04H
       END HARDECD
