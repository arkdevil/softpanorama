CAPSALT:
        jmp start
;
trtab    db 34 dup (?)
         db 34 dup (?)
         db 34 dup (?)
;
align   dd ?
;
;
ohandl1  equ this dword  ; Original Kybd    Address
ohoff1  dw ?
ohpar1  dw ?
;
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
chkid   dw 555
myhandl1:
; ... KYBD
      cli
;
      cmp ah,02H
      jnl ori16
      jmp kbdp
ori16: JMP DWORD PTR CS:ohoff1
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
      cmp al,"Н"
      jne noNG
          mov al,"H"
          jmp reti
noNG: cmp al,"р'
      jne noRG
          mov al,"p"
          jmp reti
noRG: cmp al,"К"
      jne noKG
          mov al,"K"
          jmp reti
noKG:
      cmp al,0
      je  reti
      cmp al,33
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
      SUB AL,34
      add BL,al
      mov al,cs:[bx]
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
         SUB AL,34
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
         mov ah,4CH
         int 21H
setted  db 07H,0DH,0AH,"CAPS LOCK  FoxPro alternative russian keyboard",0DH,0AH
        db             "(C)Copyright ОНИЛ САПР,1990   г.Кировоград УССР  8:052-22:93-9-28",0DH,0AH
        db 0DH,0AH,24h
tabstart:
         db '#','#'
         db '$','$'
         db '%','%'
         db '&','&'
         db '(','('
         db ')',')'
         db '*','*'
         db '+','+'
         db '-','-'
         db '0','0'
         db '1','1'
         db '2','2'
         db '3','3'
         db '4','4'
         db '5','5'
         db '6','6'
         db '7','7'
         db '8','8'
         db '9','9'
         db 'q','Й'
         db 'w','Ц'
         db 'e','У'
         db 'r','K'
         db 't','Е'
         db 'y','H'
         db 'u','Г'
         db 'i','Ш'
         db 'o','Щ'
         db 'p','З'
         db '{','Х'
         db '}','Ъ'
         db 'a','Ф'
         db 's','Ы'
         db 'd','В'
         db 'f','А'
         db 'g','П'
         db 'h','Р'
         db 'j','О'
         db 'k','Л'
         db 'l','Д'
         db ';','ж'
         db '"','Э'
         db 'z','Я'
         db 'x','Ч'
         db 'c','С'
         db 'v','М'
         db 'b','И'
         db 'n','Т'
         db 'm','Ь'
         db '<','Б'
         db '>','Ю'
         db '?','Е'
         db '^','^'
         db '_','_'
         db '|','|'
         db '\','\'
         db 'Q','й'
         db 'W','ц'
         db 'E','у'
         db 'R','к'
         db 'T','е'
         db 'Y','н'
         db 'U','г'
         db 'I','ш'
         db 'O','щ'
         db 'P','з'
         db '[','х'
         db ']','ъ'
         db 'A','ф'
         db 'S','ы'
         db 'D','в'
         db 'F','а'
         db 'G','п'
         db 'H','p'
         db 'J','о'
         db 'K','л'
         db 'L','д'
         db ':','Ж'
         db 39,'э'
         db 'Z','я'
         db 'X','ч'
         db 'C','с'
         db 'V','м'
         db 'B','и'
         db 'N','т'
         db 'M','ь'
         db ',','б'
         db '.','ю'
tabend:  db '/','е'
;
GETINT   PROC
         cli
         mov bx,0
         mov es,bx
         mov ah,0
         mul cs:c4
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
       end CAPSALT
