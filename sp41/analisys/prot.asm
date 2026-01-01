CODE      SEGMENT PARA
          ASSUME CS:CODE,DS:CODE,SS:CODE,ES:CODE
          ORG 100H
;----------------- Program Entry point --------------------------
Entry:
         jmp Init                ;go to initialization
OLD_INT21      EQU     21h
OLD_ADDR21     EQU     OLD_INT21*4H
int21          dw      00h
len            dw      00h
dx_            dw      00h
ds_            dw      00h
retop          dw      00h
finf           db     'Find file   : '
opef           db     'Open file   : '
dele           db     'Delete file : '
exec           db     'Exec file   : '
crea           db     'Create file : '
read           db     'Read file   : '
writ           db     'Write file  : '
;clos           db     'Close file  : '
fl2            dw     00h
hand           db     '  Handle:     ';14d
dati           db     0dh,0ah,'[00-00-00] [00:00:00] ' ;18h
dat_fl         dw     00h
soob           dw     00h
fl             dw     00h
fl1            dw     00h
erra           db     'ERORR OPEN FILE:  ',0
buf            db     'e:\work\protokol.txt',0,'$',15d dup(0)  ;параметр
;-------------------------------- START
Start21:     ;  int 3
               PUSHF
               PUSH CX
               PUSH SI
               PUSH DI
               PUSH AX
               PUSH ES
               PUSH BX
               PUSH DS
               PUSH DX
               cmp  cs:int21,00h
               je   dal
               jmp  outpjmp21
mod3_c1h:      jmp  mod3_ch
mod1_41h:      jmp  mod1_4h
mod1_51h:      jmp  mod1_5h
mod4_01h:      jmp  mod4_0h
;mod3_e1h:      jmp  mod3_eh
dal:
               mov  cs:fl,0h
               mov  cs:fl1,0h
;--------
                cmp  ah,3ch     ;crea_FILE
                je   mod3_c1h
                cmp  ah,5bh     ;crea_FILE
                je   mod3_c1h
                cmp  ah,5ah     ;crea_FILE
                je   mod3_c1h
                cmp  ah,14h     ;read_FILE      FCB
                je   mod1_41h
                cmp  ah,21h     ;read_FILE      FCB
                je   mod1_41h
                cmp  ah,27h     ;read_FILE      FCB
                je   mod1_41h
                cmp  ah,15h     ;writ_FILE      FCB
                je   mod1_51h
                cmp  ah,22h     ;writ_FILE      FCB
                je   mod1_51h
                cmp  ah,28h     ;writ_FILE      FCB
                je   mod1_51h
                cmp  ah,4eh     ;FIND_FIRST
                je   mod4_eh
                cmp  ah,11h     ;FIND_FIRST     FCB
                je   mod1_1h
                cmp  ah,3dh     ;OPEN_FILE
                je   mod3_dh
                cmp  ah,0fh     ;OPEN_FILE      FCB
                je   mod0_fh
                cmp  ah,41h     ;dele_FILE
                je   mod4_1h
                cmp  ah,13h     ;dele_FILE      FCB
                je   mod1_3h
                cmp  ah,16h     ;crea_FILE      FCB
                je   mod1_6h
;                cmp  ah,10h     ;clos_FILE      FCB
;                je   mod1_0h
                cmp  ah,4bh     ;exec_FILE
                je   mod4_bh
                cmp  ah,3fh     ;read_FILE
                je   mod3_fh
                cmp  ah,40h     ;writ_FILE
                je   mod4_01h
;                cmp  ah,3eh     ;close_FILE
;                je   mod3_e1h
                jmp  outpjmp21
;-------
mod4_eh:                                ;   find_first
                mov  si,offset finf
                jmp  obrint
mod1_1h:                                ;   find  first  FCB
                mov  si,offset finf
                mov  cs:fl,1h
                jmp  obrint
mod3_dh:                                ;   open_file
                mov  si,offset opef
                mov  cs:fl1,1h
                jmp  obrint
mod0_fh:                                ;   open  file   FCB
                mov  si,offset opef
                mov  cs:fl,1h
                jmp  obrint
mod4_1h:                                ;   delet file
                mov  si,offset dele
                jmp  obrint
mod1_3h:                                ;   delet file   FCB
                mov  si,offset dele
                mov  cs:fl,1h
                jmp  obrint
mod1_6h:                                ;  create file   FCB
                mov  si,offset crea
                mov  cs:fl,1h
                jmp  obrint
;mod1_0h:                                ;  close  file   FCB
;                mov  si,offset clos
;                mov  cs:fl,1h
;                jmp  obrint
mod4_bh:                                ;   exec_file
                mov  si,offset exec
                jmp  obrint
mod3_fh:                                ;  read   file
                mov  si,offset read
                mov  ax,bx
                call fhand
                mov  ax,cs
                mov  cs:ds_,ax
                mov  cs:dx_,offset hand
                mov  cs:len,0eh
                mov  cs:soob,si
                jmp  lope
mod4_0h:                                ;  write  file
                mov  si,offset writ
                mov  ax,bx
                call fhand
                mov  ax,cs
                mov  cs:ds_,ax
                mov  cs:dx_,offset hand
                mov  cs:len,0eh
                mov  cs:soob,si
                jmp  lope
;mod3_eh:                                ;  close  file
;                mov  si,offset clos
;                mov  ax,bx
;                call fhand
;                mov  ax,cs
;                mov  cs:ds_,ax
;                mov  cs:dx_,offset hand
;                mov  cs:len,0eh
;                mov  cs:soob,si
;                jmp  lope
mod1_4h:                                ;  read   file   FCB
                mov  si,offset read
                mov  cs:fl,1h
                jmp  obrint
mod1_5h:                                ;  write  file   FCB
                mov  si,offset writ
                mov  cs:fl,1h
                jmp  obrint
mod3_ch:                                ;   crea_file
                mov  si,offset crea
                mov  cs:fl1,1h
                jmp  obrint
         ;
obrint:
               mov  cs:soob,si
               MOV  cs:DX_,DX
               MOV  cs:DS_,DS
               cmp  cs:fl,0
               je   eql
               inc  cs:DX_
               mov  cs:len,0bh
               jmp  lope
eql:           mov  di,dx
               mov  cs:len,0
lop:           cmp  byte ptr [di],0
               je   lope
               inc  cs:len
               inc  di
               jmp  lop
         ;
lope:
               push  cs
               pop   ds
               mov   cs:int21,1h
               call  opend
               cmp   ah,0
               jne   ouer1
               mov     dx,cs:soob
               mov     bx, di                  ; Handle for target file
               mov     cx, 0eh                 ; Write number of bytes read
               mov     ah, 40h                 ; Request DOS write
               int     21h                     ; Write from buffer to target file
               mov     ds,cs:ds_
               mov     dx,cs:dx_
               mov     bx, di                  ; Handle for target file
               mov     cx, cs:len              ; Write number of bytes read
               mov     ah, 40h                 ; Request DOS write
               int     21h                     ; Write from buffer to target file
               call    close1
ouer1:         mov cs:int21,00h
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
                pushf
cod_jmp21       db 009Ah    ;call 09Ah
keep_ip21       dw 1460h
keep_cs21       dw 0252h
                PUSHF
                PUSH CX
                PUSH SI
                PUSH DI
                PUSH AX
                PUSH ES
                PUSH BX
                PUSH DS
                PUSH DX
               jnc dals
               jmp outiret21
dals:          cmp  cs:int21,00h
               je   dalW
               jmp  outiret21
dalW:
               cmp  cs:fl1,01h
               je   dalq
               jmp  outiret21
dalq:
               call fhand
               push  cs
               pop   ds
               mov   cs:int21,1h
               mov   cs:fl2,1h
               call  opend
               mov cs:fl2,0h
               cmp ah,0
               jne ouer2
               mov     dx, offset hand
               mov     bx, di                  ; Handle for target file
               mov     cx, 0eh                 ; Write number of bytes read
               mov     ah, 40h                 ; Request DOS write
               int     21h                     ; Write from buffer to target file
               call    close1
ouer2:         mov cs:int21,00h
outiret21:
                POP DX
                POP DS
                POP BX
                POP ES
                POP AX
                POP DI
                POP SI
                POP CX
                POPf
                retf 02h
;-------
fhand:                                       ;   ax,bx
        PUSH CX
        MOV  BX,OFFSET HAND+0AH
                 PUSH AX
                        MOV CL,04H
                        SHR AH,CL
                        MOV AL,AH
                        CALL HEX
                POP AX
                PUSH AX
                        AND AH,00001111B
                        MOV AL,AH
                        CALL HEX
                POP AX
                PUSH AX
                        MOV CL,04H
                        SHR AL,CL
                        CALL HEX
                POP AX
                        AND AL,00001111B
                        CALL HEX
                POP CX
                RET
HEX:            ADD AL,30H
                CMP AL,3AH
                JB SIMPLE
                ADD AL,07H
SIMPLE:         MOV byte ptr cs:[BX],AL
                INC BX
                RET
;-------
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
               cmp     cs:fl2,00h
               JNE     OBEZ
               mov     cx,2h
               cmp     word ptr cs:dat_fl,0
               je      reoP
               call    fdati
               mov     cx,18h
reop:          mov     dx, offset dati
               mov     bx, di                  ; Handle for target file
               mov     ah, 40h                 ; Request DOS write
               int     21h                     ; Write from buffer to target file
OBEZ:          mov     ah,0
               ret
close1:
               mov     bx, di                  ; Handle for target file
               mov     ah, 3Eh                 ; Request DOS Function 3Eh
               int     21h                     ; Close File
               mov     ah,1
               ret
;---------------
fdati:
               mov ah,2ah
               int 21h
               sub  cx,76ch
               push cx
               push dx
               mov al,dl
               mov bx,offset dati + 3h
               call dec_str
               pop  dx
               mov al,dh
               mov bx,offset dati + 6h
               call dec_str
               pop  dx
               mov al,dl
               mov bx,offset dati + 9h
               call dec_str
               mov ah,2ch
               int 21h
               push dx
               push cx
               mov al,ch
               mov bx,offset dati + 0eh
               call dec_str
               pop  dx
               mov al,dl
               mov bx,offset dati + 11h
               call dec_str
               pop  dx
               mov al,dh
               mov bx,offset dati + 14h
               call dec_str
               ret
;---------------
dec_str:                        ; al ,bx
          mov     ah,0
          mov     cl,10
          idiv    cl
          add     al,30h
          mov     byte ptr [bx],al
          inc     bx
          add     ah,30h
          mov     byte ptr [bx],ah
          inc     bx
               ret
;=============================================================================
final          DB     'OK',2eh,0dh,0Ah,'$'
hell           db     'USE: prot <[+]d:\path\file>',0dh,0ah
               db     '  {+}: disable write date & time ',0dh,0ah,'$'
star           db     'Start of protokol',0ah,0dh
Init :
                push cs
                pop  ds
                mov  si,80h
                mov  cl,es:[si]
                mov  ch,0
                inc  si
                call space
                cmp  cx,0
                je   ope
                cmp  al,'+'
                jne  dali3
                mov  word ptr dat_fl,1
                inc  si
                dec  cx
dali3:
                cmp  cx,0
                je   ope
                mov  dx,offset hell    ;   ?-Help
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
                INC  BX                ;
                mov  al,'$'            ;
                MOV  byte ptr [BX],Al  ;
                mov  cs:len,0
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
               mov     dx,offset star
               mov     bx, di                  ; Handle for target file
               mov     cx, 17d                 ; Write number of bytes read
               mov     ah, 40h                 ; Request DOS write
               int     21h                     ; Write from buffer to target file
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
exit_z:
                mov ah,09h
                int 21h
                ret
;-------------------------------------- get & set  vectors ---------
exit_c:          xor     ax,ax
                 MOV     DS,ax
                 MOV     AX,DS:[OLD_ADDR21]
                 MOV     DX,DS:[OLD_ADDR21+2H]
                 MOV     CS:keep_ip21,AX
                 MOV     CS:keep_cs21,DX
                 MOV     SI,OLD_ADDR21
                 MOV     WORD PTR DS:[SI],OFFSET start21
                 MOV     WORD PTR DS:[SI+2H],CS
;---------------------------------- exit & tsr  -----------------
                push cs
                pop ds
                mov dx,offset final
                mov ah,09h
                int 21h
                mov ax,offset final
                mov dx,ax
                int 27h
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