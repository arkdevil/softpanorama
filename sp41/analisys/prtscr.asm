.radix    16
size_all        =       1000h
b_b             =       1h * 0A0h ;(1-ая строка)
c_s             =       17h       ;(1-24 строки )
hot_key         =       51h       ;(popup-key<PgDn>)
c_b             EQU     c_s * 52h
c_b1            EQU     c_s * 50h
OLD_INT9        EQU     9h
OLD_ADDR9       EQU     OLD_INT9*4H
CODE            SEGMENT PARA
        ASSUME CS:CODE,DS:CODE,SS:CODE,ES:CODE
        ORG 100H
START:  JMP RESIDENT
;-------------------------------------------
Start9:
                                PUSH CX
                                PUSH ES
                                PUSH DS
                                PUSH SI
                                PUSH DI
                                PUSH DX
                                PUSH AX
                                PUSH BX
                                cmp word ptr cs:int_9,0
                                jne outpjmp9
               push cs
               pop  ds
               in      al,60H        ;читать ключ
               cmp     al,hot_key    ;PgDn
               jne     outpjmp9
              mov word ptr cs:int_9,1
         in      al,61H             ;взять значениe порта управления клавиатурой
         mov     ah,al              ; сохранить его
         or      al,80h             ;установить бит разрешения для клавиатуры
         out     61H,al             ; и вывести его в управляющий порт
         xchg    ah,al              ;извлечь исходное значение порта
         out     61H,al             ; и записать его обратно
         mov     al,20H             ;послать сигнал "конец прерывания"
         out     20H,al             ; контроллеру прерываний 8259
              mov ax,0
              mov ds,ax
              mov si,417h
              mov ah,BYTE PTR ds:[si]
              push    cs
              pop     ds
              test ah,0Ch
              jz   dali_1
              call    save_f
              mov word ptr cs:int_9,0
              jmp     outpjmp9
dali_1:
              test ah,02h
              jz   dali_11
              call    save_s
dali_11:      mov word ptr cs:int_9,0
outpjmp9:
                                POP BX
                                POP AX
                                POP DX
                                POP DI
                                POP SI
                                POP DS
                                POP ES
                                POP CX
cod_jmp9        db  0EAh
keep_ip9        dw 1460h
keep_cs9        dw 0252h
;--------------
save_s:
               mov si,cs:beg_b
               mov ax,0b800h
               mov ds,ax
               push cs
               pop es
               cmp word ptr CS:buffer_uk,0
               jne dali_3
               mov word ptr cs:str_col,0
dali_3:        mov di,offset buffer
               add di,word ptr cs:buffer_uk
               mov ax,word ptr cs:col_b
               add ax,word ptr cs:buffer_uk
               mov word ptr cs:buffer_uk,ax
               mov cl,04
               shr ax,cl
               cmp ax,word ptr cs:buffer_size
               jnb err1
               mov cx,word ptr cs:col_b1
               inc cs:str_col
               xor bx,bx
cop:           lodsb
               mov byte ptr es:[di],al
               inc di
               inc si
               inc bx
               cmp bx,50h
               jne lop1
               xor bx,bx
               mov byte ptr es:[di],0dh
               inc di
               mov byte ptr es:[di],0ah
               inc di
lop1:          loop cop
               ret
err1:
               mov word ptr cs:buffer_uk,0
               mov dx,50
               call bel
               mov dx,10
               call bel
               mov dx,10
               call bel
               mov dx,60
               call bel
              ; call save_f
               ret
;--------------
save_f:
               push    cs
               pop     ds
               call    opend
               cmp     ah,0
               je    dali_2
               mov dx,10
               call bel
               mov dx,20
               call bel
               mov dx,10
               call bel
               mov dx,20
               call bel
               ret
dali_2:
               mov   ax,word ptr str_col
               mov   bx,word ptr col_b
               mul   bx
               mov   cx,ax
               mov dx, OFFSET buffer
               mov     bx, di
               mov     ah, 40h
               int     21h
               mov     word ptr str_col,0
               mov     word ptr cs:buffer_uk,0
               jmp     close1
;-----------------------------------------------------------------------------
bel:
FREQUENCY      EQU   300
PORT_B         EQU   61H
               CLI                 ;запрет прерываний
               IN    AL,PORT_B     ;получаем значение из порта B
               AND   AL,11111110B  ;отключаем динамик от таймера
NEXT_CYCLE:    OR    AL,00000010B  ;включаем динамик
               OUT   PORT_B,AL     ;посылаем команду в порт B
               MOV   CX,FREQUENCY  ;задержка на пол-цикла в CX
FIRST_HALF:    LOOP  FIRST_HALF    ;делаем задержку
               AND   AL,11111101B  ;выключаем динамик
               OUT   PORT_B,AL     ;посылаем команду в порт B
               MOV   CX,FREQUENCY  ;задержка на пол-цикла в CX
SECOND_HALF:   LOOP  SECOND_HALF   ;делаем задержку
               DEC   DX            ;вычитаем единицу из счетчика
               JNZ   NEXT_CYCLE    ;если 0, то надо кончать
               STI                 ;разрешаем прерывания
               ret
;------------------------------------
opend:
               mov     dx,offset buf
               mov     ah, 3dh                 ; No?  Request Create File
               mov     al,1                    ; Normal attribute for target
               int     21h                     ; DOS function for target file
               jc      close1                  ; If open error, abort
               mov     di, ax                  ; DI = file handle for target
               mov     bx, di
               mov     cx, 0
               mov     dx, 0
               mov     al, 2
               mov     ah, 42h
               int     21h
               mov     ah,0
               ret
close1:
               mov     bx, di                  ; Handle for target file
               mov     ah, 3Eh                 ; Request DOS Function 3Eh
               int     21h                     ; Close File
               mov     ah,1
               ret
;--------------
BUFFER_SIZE     dw      1900h
buffer_uk       dd      0h
beg_b           dw      b_b
col_b           dw      c_b
col_b1          dw      c_b1
col_str         db      c_s
erra            db     'ERROR OPEN FILE:  ',0
buf             db      30h dup(' ')
str_col         dw      0h
int_9           dw      0h
buffer          dw      0h
;================================================================================================
GREETING        DB 'PRTSCR  $'
final           db 'OK!',0dh,0Ah,'$'
err_s           db 'USE: PRTSCR <d:\path\file>',0dh,0ah
                db '   <Shift+PgDn>-PrtScR to buffer',0dh,0ah
                db '   <Ctrl+Alt+PgDn>-Write buffer to file',0dh,0ah,'$'
;---------------------------
RESIDENT:
                MOV DX,OFFSET GREETING
                MOV AH,09H
                int 21h
                mov  si,80h
                mov  cl,es:[si]
                mov  ch,0
                inc  si
                call space
                cmp  cx,0
                jne  dali
                mov dx,offset err_s
                jmp exit_z
dali:
                MOV  bx,offset buf     ;
lop_1:          lodsb                  ;
                MOV  byte ptr [BX],Al  ; копировать параметр
                INC  BX                ;
                loop  lop_1            ;
                mov  al,0h             ;
                MOV  byte ptr [BX],Al  ;
                INC  BX                ;
                mov  al,'$'            ;
                MOV  byte ptr [BX],Al  ;
;-------------------------------------- open file ---------
ope:           mov     dx,offset buf
               mov     ah, 5bh                 ; No?  Request Create File
               sub     cx, cx                  ; Normal attribute for target
               int     21h                     ; DOS function for target file
               mov     di, ax                  ; DI = file handle for target
               jnc     dalie                   ; If open error, abort
               call    opend
               cmp     ah,0
               jne     errs
dalie:
close:         pushf                           ; Preserve flags while closing
               mov     bx, di                  ; Handle for target file
               mov     ah, 3Eh                 ; Request DOS Function 3Eh
               int     21h                     ; Close File
               popf                            ; Recover flags
               jnc     exit_c                  ; If successful, exit
               mov     dx,offset buf
               mov     ah, 41H
               int     21h
errs:          mov     dx,offset erra
               jmp     exit_z
;---------------------------------- exit & .not. tsr  -----------------
exit_c :        MOV DX,OFFSET final
                MOV AH,09H
                int 21h
                mov ax,0
                mov ds,ax
                MOV     AX,DS:[OLD_ADDR9]
                MOV     DX,DS:[OLD_ADDR9+2H]
                MOV     CS:keep_ip9,AX
                MOV     CS:keep_cs9,DX
                MOV     SI,OLD_ADDR9
                MOV     WORD PTR DS:[SI],OFFSET start9
                MOV     WORD PTR DS:[SI+2H],CS
                mov ax,size_all
                MOV DX,OFFSET GREETING
                sub ax,dx
                mov cs:buffer_size,ax
                mov dx,size_all
                mov ah,31h
                INT 21H
exit_z:
                push cs
                pop ds
                mov ah,09h
                int 21h
                ret
space:
                lodsb                           ;Load AL with DS:[SI]
                cmp     al,20h ;( )
                jne     RET_2
                LOOP    SPACE
RET_2:          dec     si
                ret
last:
CODE            ENDS
                END       START
