PRAVEALT:
        jmp start        ; The ALTERNATIVE set KYRYLYZER for PRAVETS
;                          by  A.A.Titov,  Excellent edition
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
ohandl9  equ this dword  ; Original INT 09H Address
ohoff9  dw ?
ohpar9  dw ?
;
recn    dw 31999
crow    db 0
cursp   dw ?
oldrow  db 200
oldlin  db 200
oldpage db 200
disabled db 0
letmem  db 1     ; 0 if the DYNAMIC recoding disabled by Left Shift+Home
;
avram    dw 0B800H ; CGA video-memory para  Note that Mono uses 0b000 !
statport dw 3DAH   ; CGA retrace state port
;
special db 0      ; 1 if special code occurs
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
      cli
;
      mov ax,cs:recn
      cmp ax,1000
      jng inccount
      jmp rece
inccount:
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
;     int 10H      ; Page in bh
      pushf
      CALL DWORD PTR CS:OHANDLE
      cli
      mov ah,cs:oldpage
      mov cs:oldpage,bh
      cmp bh,ah
      jne rece
      mov ah,03H   ; Read cursor position
;     int 10H      ; Row,lin in DH,DL
      pushf
      CALL DWORD PTR CS:OHANDLE
      cli
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
      mov al,cs:special
      cmp al,0
      jne rece
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
;
      mov dx,cs:statport
      mov ax,cs:avram
      mov ds,ax
;
lb800:
      mov bx,cx
      dec bx
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
      cmp ah,0e0h    ;  From Alternative to Bulgar
      jl  excons
      cmp ah,0efh
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
ALTtoBUL PROC NEAR
;       ALTtoBUL code in AL
      cmp al,0e0h    ;  From Alternative to Bulgar
      jl  exconv
      cmp al,0efh
      jg  exconv
          sub al,48
exconv:
        ret
ALTtoBUL ENDP
;
RECROW PROC NEAR
      push si
      push cx
      push bp
      push bx
      push ax
      mov al,cs:letmem
      cmp al,0
      je eex
     mov cx,0
     mov ah,0FH
;    int 10H
     pushf
     CALL DWORD PTR CS:OHANDLE
     cli
     mov cl,ah         ; Columns
     push cx
     mov ah,03H
;    int 10H           ; Get new pos
     pushf
     CALL DWORD PTR CS:OHANDLE
     cli
     pop cx
     cmp dh,24
     jnl eex
     cmp dh,0
     jl  eex
     mov ax,cx         ; Columns
     imul dh
     mov si,ax
     mov dx,cs:statport
     push ds
     mov ax,cs:avram
     mov ds,ax
lb800t:
      mov bx,si
      add bx,cx
      dec bx
      shl bx,1
p88:
        in al,dx
        test al,9
        jnz p88
p918:
        in al,dx
        test al,9
        jz  p918
;
      mov ah,[bx]
      cmp ah,0e0h    ;  From Alternative to Bulgar
      jl  excons8
      cmp ah,0efh
      jg  excons8
          sub ah,48
          mov [bx],ah
excons8:
      loop lb800t
      pop ds
eex:
      pop ax
      pop bx
      pop bp
      pop cx
      pop si
      ret
RECROW ENDP
;
BULtoALT  PROC NEAR
      cmp al,0e0h-48 ;  From B to A
      jl  exconv0
      cmp al,0efh-48
      jg  exconv0
          add al,48
exconv0:
      ret
BULtoALT  ENDP
;
chkid   dw 666
myhandl1:
; ... KYBD
      cli
;
      cmp ah,02H
      jnl ori16
      call RECROW
      cmp ah,00H
      jg ccs
      call NONCOND
      jmp kbdp
ori16:
      sti
      JMP DWORD PTR CS:ohoff1
ccs:
      call SCREEN
;                         Process KYBDIN
kbdp:
      cli
      push cx
      push bp
      push bx
      push ax
      pushf
      CALL DWORD PTR CS:ohoff1
      pushf
      cli
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
      sti
      iret
recode:
      mov bl,0
      mov cs:special,bl
      cmp al,32
      jnl n27
          mov bl,1
          mov cs:special,bl
n27:
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
      and bl,40H
      cmp bl,40H
      je  rus
      jmp reti
rus:
      lea bx,trtab
      SUB AL,58
      add BL,al
      mov al,cs:[bx]
      call BULtoALT
      jmp reti
;
cke:
      cmp ah,72  ; Up arrow
      je arr
      cmp ah,80  ; Down arrow
      je arr
      jmp et
arr:
      mov bl,1
      mov cs:disabled,bl
      jmp reti
et:
      mov bl,1
      mov cs:special,bl
      mov bl,0
      mov cs:disabled,bl
      cmp ah,18  ; "e" ALT- code
      jne reti
analz:
      push es
      mov bx,0
      mov es,bx
      mov bp,417H
      mov bl,es:[bp]
      pop es
      mov bp,bx
      and bl,01H
      cmp bl,01H
      je  great
      mov bx,bp
      and bl,02H
      cmp bl,02H
      je great
      mov al,189
      call BULtoALT
      jmp reti
great:
      mov al,157
      call BULtoALT
      jmp reti
;
myhandle:
; ... SCREEN
;
      CMP aH,09H
      JE  RECOD
      cmp ah,0AH
      je  recod
      CMP aH,0EH
      JE  RECOD
      jmp exr
recod:
      call ALTtoBUL
exr:
; ... issue original service
;
      JMP  DWORD PTR CS:OHANDLE
;
;
myhandl2:
; ...  PRINTER
;
      CMP aH,00H
      jne exr2
      call ALTtoBUL
exr2:
; ... issue original service
;
      JMP  DWORD PTR CS:OHANDL2
;
myhandl9:
; ... My own interrupt handler  for INT 09H
;
      cli
      push ax
      in al,60H
      cmp al,71       ; Home
      je  homepres
ori9:
      pop ax
      sti
      JMP  DWORD PTR CS:OHANDL9
homepres:
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
      mov al,cs:letmem
      cmp al,0
      je  make1
          mov al,0
          jmp annov
make1:
      mov al,1
annov:
      mov cs:letmem,al
      call NONCOND
      pop bx
      pop ax
      sti
      iret
ret09:
      pop bx
      jmp ori9
;
last:
start:
;
; ............................ BUILD KYBD TRTAB ..........
;
         MOV AH,0
         LEA BX,TABSTART
         LEA DX,TABEND
NXTBTR:
         CMP BX,DX
         JG  COMPTR
         LEA BP,TRTAB
         MOV AL,CS:[BX]
         SUB AL,58
         ADD BP,AX
         INC BX
         MOV AL,CS:[BX]
         MOV CS:[BP],AL
         INC BX
         JMP NXTBTR
COMPTR:
;
; ............................ KEYBOARD ..................
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
         lea dx,myhandl1
         mov al,16H
         call SETINT
;
;
; ............................ PRINTER ...................
;
         push es
         mov al,17H   ; Interrupt number = PRNout
         call GETINT  ; ES:bx - Handler address
         mov cs:ohpar2,es
         mov cs:ohoff2,bx
         pop es
;
         lea dx,myhandl2
         mov al,17H
         call SETINT
;
;
; ............................ INT 09H ...................
;
         push es
         mov al,09H   ; Interrupt number = Low-Level-Keyboard
         call GETINT  ; ES:bx - Handler address
         mov cs:ohpar9,es
         mov cs:ohoff9,bx
         pop es
;
         lea dx,myhandl9
         mov al,09H
         call SETINT
;
;    .................. SCREEN ......................
;
         push es
         mov al,10H   ; Interrupt number = Videoserv
         call GETINT  ; ES:bx - Handler address
         mov cs:ohpara,es
         mov cs:ohoffs,bx
         pop es
;
         lea dx,myhandle
         mov al,10H
         call SETINT
;
; ... TSR
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
alsopre db 07H,0DH,0AH,"ЭМУЛЯТОР АЛЬТЕРНАТИВНОГО НАБОРА ДЛЯ ПРАВЕЦ-16/CGA/MIK УЖЕ ЗАГРУЖЕН",0DH,0AH
        db 07H,0DH,0AH,24H
;
setted  db 07H,0DH,0AH,"PRAVEALT:ЭМУЛЯТОР АЛЬТЕРНАТИВНОГО НАБОРА ДЛЯ ПРАВЕЦ-16/CGA/MIK ЗАГРУЖЕН",0DH,0AH
        db 0DH,0AH
        db             "Переключение русский/латинский: *------*   г.Кировоград УССР",0DH,0AH
        db             "э - Alt+e ;  Э - Alt+E          | Caps |     тел. 93-9-28",0DH,0AH
        db             "                                | Lock |                       ",0DH,0AH
        db             "(C)Copyright A.A.Титов,  1990   *------*   Excellent edition 2.7",0DH,0AH
        db 0DH,0AH
        db             "Теперь Вы сможете работать одновременно с ЛЮБЫМИ программами",0dh,0aH
        db             "болгарского и альтернативного наборов.",0dh,0aH
        db             "Расположение клавиш как на русской пишущей машинке.",0dh,0aH
        db             "С клавиатуры вводятся АЛЬТЕРНАТИВНЫЕ коды.",0dh,0aH
        db 0DH,0AH
        db             "ВНИМАНИЕ: эмуляция производится путем сканирования",0dh,0aH
        db             "          памяти видеоадаптера с небольшой задержкой",0dh,0aH
        db 0DH,0AH
        db             "СКАНИРОВАНИЕ ВЫКЛЮЧАЕТСЯ/ВКЛЮЧАЕТСЯ: Левой Shift + Home",0dh,0ah
        db 0DH,0AH
        db             "В режиме выключенного сканирования эмулируются только ",0dh,0ah
        db             "программы, работающие через DOS,BIOS.",0dh,0ah
        db 0DH,0AH,24H
tabstart:
         db 'q','Й'
         db 'w','Ц'
         db 'e','У'
         db 'r','К'
         db 't','Е'
         db 'y','Н'
         db 'u','Г'
         db 'i','Ш'
         db 'o','Щ'
         db 'p','З'
         db '{','Х'
         db 'a','Ф'
         db 's','Ы'
         db 'd','В'
         db 'f','А'
         db 'g','П'
         db 'h','Р'
         db 'j','О'
         db 'k','Л'
         db 'l','Д'
         db '~','Ж'
         db 'z','Я'
         db 'x','Ч'
         db 'c','С'
         db 'v','М'
         db 'b','И'
         db 'n','Т'
         db 'm','Ь'
         db '}','Б'
         db ':','Ю'
         db '<','<'
         db '=','='
         db '>','>'
         db '?','?'
         db '^','^'
         db '_','_'
         db '|','|'
         db '\','\'
         db 'Q','й'
         db 'W','╢'
         db 'E','│'
         db 'R','к'
         db 'T','е'
         db 'Y','н'
         db 'U','г'
         db 'I','╕'
         db 'O','╣'
         db 'P','з'
         db '[','╡'
         db 'A','┤'
         db 'S','╗'
         db 'D','в'
         db 'F','а'
         db 'G','п'
         db 'H','░'
         db 'J','о'
         db 'K','л'
         db 'L','д'
         db '`','ж'
         db 'Z','┐'
         db 'X','╖'
         db 'C','▒'
         db 'V','м'
         db 'B','и'
         db 'N','▓'
         db 'M','╝'
         db ']','б'
tabend:  db ';','╛'
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
       end PRAVEALT
