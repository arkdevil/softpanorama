CODE      SEGMENT PARA
          ASSUME CS:CODE,DS:CODE,SS:CODE,ES:CODE
          ORG 100H
;----------------- Program Entry point --------------------------
Entry:
         jmp Init                ;go to initialization
OLD_INT21      EQU     21h
OLD_ADDR21     EQU     OLD_INT21*4H
OLD_INT9       EQU     9h
OLD_ADDR9      EQU     OLD_INT9*4H
buffer         dw      0h
int9           dw      00h
int21          dw      00h
status         db     'COPYR status:      ',00
LSTATUS        DW      17D
exec_c         db      0h
BUFFER_SIZE    dw      0h
eof_flag       db      0h
AH_            db      0h
AL_            db      0h
DX_            dw      0h
DX1_           dw      0h
ds1            dw      0h
dx1            dw      0h
ds2            dw      0h
dx2            dw      0h
DS_            dw      0h
SI_            dw      0h
nnn            dw      0h
buf            db      50d dup(0)  ;параметр
bufa           db      50d dup(0),'\';пром. буффер
dtab           dw      4
tabp           dw      offset  prg1
               dw      offset  prg2
               dw      offset  prg3
               dw      offset  prg4
tabd           dw      11d
               dw      10d
               dw      6d
               dw      11d
prg1           db      'COMMAND.COM'
prg2           db      'NCMAIN.EXE'
prg3           db      'NC.EXE'
prg4           db      '4DOSCOM.COM'
len            dw      00h
fl             dw      00h
;-------------------------------- START
Start21:
               PUSHF
               cmp ah,0f8h     ;ah f8 - обработать
               jne dda
               mov al,0ffh                ;
               popf                       ;   else : al<-ff
               iret
dda:
               PUSH CX
               PUSH SI
               PUSH DI
               PUSH AX
               PUSH ES
               PUSH BX
               PUSH DS
               PUSH DX
               cmp  cs:int21,00h
               jne  outpjmp21
;--------
                mov  cs:fl,0
                cmp  ah,4bh     ;запуск программы
                je  mod4_bh
                cmp  ah,3dh     ;OPEN
                je  mod3_dh
;-------
outpjmp21:
                POP DX
                POP DS
                POP BX
                POP ES
                POP AX
                POP DI
                POP SI
                POP CX
                POPf
cod_jmp21       db 00EAh    ;call 09Ah
keep_ip21       dw 1460h
keep_cs21       dw 0252h
;------------
mod3_dh:        mov cs:fl,1
mod4_bh:  ;     int 3
                cmp cs:exec_c,0
                jne dd6
                jmp outpjmp21
           ;
dd6:
                MOV  cs:AH_,AH
                MOV  cs:AL_,AL
                MOV  cs:DX_,DX
                MOV  cs:DS_,DS
          ;
                MOV  AX,cs:DS_       ;ds:dx - string
                MOV  ds,AX
                MOV  si,cs:DX_
                cld
bega:           lodsb
                cmp  al,'\'
                jne  b1
b1:             cmp  al,0
                jne  bega
                mov  cs:nnn,0
begb:           dec  si
                cmp  si,cs:DX_
                jl   brek
                inc  cs:nnn
                MOV  AL,ds:[si]
                cmp  al,'\'
                jne  begb
brek:
                push cs
                pop  ds
                inc  si
                dec  nnn
                mov  si_,si
                mov  es,ds_
                mov  cx,dtab
                mov  bx,0
                call cmpall
                cmp  al,0
                je   daliq
                jmp  outpjmp21
;
daliq:          push  cs
                pop   ds
                MOV  AX,DS
                MOV  ES,AX
                MOV  DI,offset bufa
                mov  si,offset buf
                cld
                mov  cx,len
                rep  movsb
                mov  si,cs:si_
                mov  ds,cs:ds_
                cld
                mov  cx,cs:nnn
                rep  movsb
;
                push  cs
                pop   ds
                mov  ax,ds_
                mov  ds1,ax
                mov  ax,dx_
                mov  dx1,ax
                mov  ds2,ds
                mov  dx2,offset bufa
                call copyr
                or   ax,cs:fl
                cmp  ax,1
                je   lab2_21
                POP  DX
                POP  DS
                push cs:ds2
                push cs:dx2
lab2_21:
                jmp  outpjmp21
;
;
;===============================================
cmpr:                                ;es:di = ds:si cx-leng?
                mov  ax,01h
                cld
                repe cmpsb
                jne  mism
                mov  AX,00h
mism:           ret
;===============================================
;- .not. command.com
;- .not. ncmain.com
;- .not. ....
cmpall:         push cx
                mov  di,si_
                mov  si,[tabp+bx]
                mov  cx,[tabd+bx]
                call cmpr
                cmp  ax,00h
                jne  lab3_21
                pop  cx
                mov  al,1
                ret
lab3_21:        add  bx,2
                pop  cx
                loop cmpall
                mov  al,0
                ret
;-----------------------------------------------
displ:          cld
                lodsb
                cmp     al,00
                jz      re
                push    si
                mov     bx,0007h
                mov     ah,0eh
                int     10h
                pop     si
                jmp     short displ
re:             mov     ah,0
                int     16h
                ret
;-----------------------------------------------
writ:
                mov  ax,0b800h
                mov  es,ax
                cld
                MOVSB
                inc  di
                loop writ
                ret
;-----------------------------------------------
Copyr:
               mov  cs:int21,1h
               mov ah,48h
               mov bx,0ffffh
               int 21h
               mov cs:buffer_size,bx
               mov ah,48h
               int 21h
               mov cs:buffer,ax
; Open source file for read only
               mov   ds,cs:ds1
               mov   dx,cs:dx1
               mov   ax, 3D00h               ; AH = function #, AL = access code
               int   21h                     ; Open File (for read only)
               jc    e_exit
               mov   si, ax                  ; SI = file handle for source
; Open target file according to copy mode
               mov     ds,cs:ds2
               mov     dx,cs:dx2
               mov     ah, 5Bh                 ; Request Create New File
               sub     cx, cx                  ; Normal attribute for target
               int     21h                     ; DOS function for target file
               jc      e_exit                  ; If open error, abort
               mov     di, ax                  ; DI = file handle for target
; Both files successfully opened. Now read from source and copy to target.
               mov     ds,cs:buffer
               mov     dx, 0h                  ;   to and from here.
               mov     cs:eof_flag, 0             ; Initialize end-of-file flag
loop1:         mov     bx, si                  ; Handle for source file
               mov     cx,cs:BUFFER_SIZE       ; CX = number of bytes to read
               mov     ah, 3Fh                 ; Request DOS read
               int     21h                     ; Read from File
               jc      close                   ; If error, exit
               cmp     ax, cx                  ; All bytes read successfully?
               je      @F                      ; Yes?  Continue
               inc     cs:eof_flag                ; No?  Raise flag
@F:            mov     bx, di                  ; Handle for target file
               mov     cx, ax                  ; Write number of bytes read
               mov     ah, 40h                 ; Request DOS write
               int     21h                     ; Write from buffer to target file
               jc      close                   ; If error, exit
               cmp     ax, cx                  ; All bytes write successfully?
               jne     close                   ; If error, exit
               cmp     cs:eof_flag, 0             ; Finished?
               je      loop1                   ; No?  Loop to read next block
               clc                             ; Yes?  Clear CY to indicate
close:         pushf                           ; Preserve flags while closing
               mov     bx, di                  ; Handle for target file
               mov     ah, 3Eh                 ; Request DOS Function 3Eh
               int     21h                     ; Close File
               sub     ax, ax                  ; Clear error code
               popf                            ; Recover flags
               jnc     exit_c                  ; If successful, exit
               mov     ds,cs:ds2               ;del file
               mov     dx,cs:dx2
               mov     ah, 41H
               int     21h
e_exit:        mov     ax,1                    ; Else set error code
exit_c:        PUSH    AX
               push    cs
               pop     ds
               mov     ah,49h
               mov     es,cs:buffer
               int     21H
               POP     AX
               mov cs:int21,00h
ex_ret:        ret
;===============================================
Start9:        PUSHF
               PUSH CX
               PUSH ES
               PUSH SI
               PUSH DI
               PUSH AX
               PUSH BX
               PUSH DS
               PUSH DX
;--------
         push    cs
         pop     ds
              cmp int9,0
              jne outpjmp9
              mov int9,1
              mov ax,0
              mov ds,ax
              mov si,417h
              mov ah,BYTE PTR ds:[si]
         push    cs
         pop     ds
              and ah,0Ch
              cmp ah,0Ch
              jne outpjmp9
              in      al,60H             ;читать ключ
              push    ax
         in      al,61H             ;взять значениe порта управления клавиатурой
         mov     ah,al              ; сохранить его
         or      al,80h             ;установить бит разрешения для клавиатуры
         out     61H,al             ; и вывести его в управляющий порт
         xchg    ah,al              ;извлечь исходное значение порта
         out     61H,al             ; и записать его обратно
         mov     al,20H             ;послать сигнал "конец прерывания"
         out     20H,al             ; контроллеру прерываний 8259
         pop     bx
              cmp     bl,1fh
              jne     outpjmp9
              xor     exec_c,0ffh
              jmp     mod_S
;-------
outpjmp9:
                mov  int9,0
                POP DX
                POP DS
                POP BX
                POP AX
                POP DI
                POP SI
                POP ES
                POP CX
                POPf
cod_jmp9        db  0EAh
keep_ip9        dw 1460h
keep_cs9        dw 0252h
;------------
outiret9:
               mov  int9,0
               POP DX
               POP DS
               POP BX
               POP AX
               POP DI
               POP SI
               POP ES
               POP CX
               POPf
               iret
;------------
mod_S:
         cmp     exec_c,0
         je      l11
         mov     byte ptr status+14,'O'
         mov     byte ptr status+15,'N'
         mov     byte ptr status+16,' '
         jmp     l12
l11:     mov     byte ptr status+14,'O'
         mov     byte ptr status+15,'F'
         mov     byte ptr status+16,'F'
l12:
         mov     si,offset status
         mov     di,0h
         mov     cx,Lstatus
         call    writ
         jmp     outiret9
;=============================================================================
final          DB     'OK',2eh,0dh,0Ah,'$'
err1           DB     'COPYR already installed.$'
help           db     '(C) COPYRIGHT 1991 Brodik Soft',0dh,0ah
               db     'USE: COPYR <d:\path\>',0dh,0ah
               db     'COPY all "exec" or "open" files in your directory',0dh,0ah
               db     'Show status  &  turn on / off :   (Ctrl+Alt+S)  ',0dh,0ah,'$'
Init :
                push cs
                pop  ds
                mov  si,80h
                mov  cl,es:[si]
                mov  ch,0
                inc  si
                call space
                mov  dx,offset help     ;   Нет параметров
                cmp  cx,0
                je   exit_z
                mov  dx,offset help    ;   ?-Help
                cmp  al,'?'
                je   exit_z
                mov  cs:len,cx         ;
                MOV  bx,offset buf     ;
lop_1:          lodsb                  ;
                MOV  byte ptr [BX],Al  ; копировать параметр
                INC  BX                ;
                loop  lop_1            ;
                mov  al,0h             ;
                MOV  byte ptr [BX],Al  ;
;----------------------------- instal ? ----------------
                mov dx,offset err1
                mov ah,0f8h
                int 21h
                cmp al,0ffh
                je exit_z
;-------------------------------------- get & set  vectors ---------
                 xor     ax,ax
                 MOV     DS,ax
                 MOV     AX,DS:[OLD_ADDR21]
                 MOV     DX,DS:[OLD_ADDR21+2H]
                 MOV     CS:keep_ip21,AX
                 MOV     CS:keep_cs21,DX
                 MOV     SI,OLD_ADDR21
                 MOV     WORD PTR DS:[SI],OFFSET start21
                 MOV     WORD PTR DS:[SI+2H],CS
;---------
                xor     ax,ax
                MOV     DS,ax
                MOV     AX,DS:[OLD_ADDR9]
                MOV     DX,DS:[OLD_ADDR9+2H]
                MOV     CS:keep_ip9,AX
                MOV     CS:keep_cs9,DX
                MOV     SI,OLD_ADDR9
                MOV     WORD PTR DS:[SI],OFFSET start9
                MOV     WORD PTR DS:[SI+2H],CS
;
;---------------------------------- exit & tsr  -----------------
                push   cs
                pop    ds
                mov dx,offset final
                mov ah,09h
                int 21h
                mov ax,offset final
                mov dx,ax
                int 27h
;---------------------------------- exit & .not. tsr  -----------------
exit_z:
                mov ah,09h
                int 21h
                ret
;---------------------------------- subprogramm -----------------
space:
                lodsb                           ;Load AL with DS:[SI]
                cmp     al,20h ;( )
                jne     RET_2
                LOOP    SPACE
RET_2:          dec     si
                ret
CODE            ENDS
                END      Entry
