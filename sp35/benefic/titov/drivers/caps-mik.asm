CAPSMIK:
        jmp start        ; The CAPS-LOCK ЙЦУКЕН keyboard driver for PRAVETS MIK
;                          by  A.A.Titov
trtab    db 34 dup (?)
         db 34 dup (?)
;
align   dd ?
;
ohandl1  equ this dword  ; Original Kybd    Address
ohoff1  dw ?
ohpar1  dw ?
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
chkid   dw 666
myhandl1:
; ... KYBD
      cli
;
      cmp ah,02H
      jnl ori16
      jmp kbdp
ori16:
      sti
      JMP DWORD PTR CS:ohoff1
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
      jmp reti
great:
      mov al,157
      jmp reti
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
alsopre db 07H,0DH,0AH,"CAPS-MIK:КЛАВИАТУРНЫЙ ДРАЙВЕР ДЛЯ ПРАВЕЦ-16/CGA/MIK ЗАГРУЖЕН",0DH,0AH
        db 07H,0DH,0AH,24H
;
setted  db 07H,0DH,0AH,"CAPS-MIK:КЛАВИАТУРНЫЙ ДРАЙВЕР ДЛЯ ПРАВЕЦ-16/CGA/MIK ЗАГРУЖЕН",0DH,0AH
        db 0DH,0AH
        db             "Переключение русский/латинский: *------*   г.Кировоград УССР",0DH,0AH
        db             "э - Alt+e ;  Э - Alt+E          | Caps |     Тел. 93-9-28",0DH,0AH
        db             "                                | Lock |                       ",0DH,0AH
        db             "(C)Copyright A.A.Титов,  1990   *------*     Edition 1.0",0DH,0AH
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
       end CAPSMIK
