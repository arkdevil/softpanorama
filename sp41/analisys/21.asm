.radix    16
DEEP            EQU     0d0h
OLD_INT         EQU     21H
OLD_ADDR        EQU     OLD_INT*4H
OLD_INT9        EQU     9h
OLD_ADDR9       EQU     OLD_INT9*4H
CODE            SEGMENT PARA
        ASSUME CS:CODE,DS:CODE,SS:CODE,ES:CODE
        ORG 100H
START:  JMP RESIDENT
;-------------------------------------------
outjmp:
                                POP BX
                                POP AX
                                POP DX
                                POP DI
                                POP SI
                                POP DS
                                POP ES
                                POP CX
                                popf
                DB 00eAH       ;db  11101010B
WHERE1          DW 1460H
SEG_WHERE1      DW 0252H
;-------------------------------------------
FINITA:         PUSHF
                DB 009AH       ;db  11101010B
WHERE           DW 1460H
SEG_WHERE       DW 0252H
;-------------------------------------------
                                PUSHF
                                PUSH CX
                                PUSH ES
                                PUSH DS
                                PUSH SI
                                PUSH DI
                                PUSH DX
                                PUSH AX
                                PUSH BX
                                call savreg
                                push cs
                                pop  ds
                                mov  di,320d
                                mov al,'<'
                                call writreg
NUM_check:      XOR  AX,AX
                MOV  DS,AX
                MOV  AL,DS:[417H]
                TEST AL,00010000B
                JZ   NO_CHECK
                MOV  AX,CS:[AX_1 - DEEP]
                MOV  AL,AH
                CMP  AH,63H
                JA   NO_CHECK
                MOV  AH,00h
                MOV  BX,OFFSET NUM_LOCK - DEEP
                ADD  BX,AX
                MOV  AH,CS:[BX]
                CMP  AH,00H
                JZ   NO_CHECK
;                mov  al,ds:[417h]
;                and  al,40h
;waite:
;                MOV  Ah,DS:[417H]
;                and  ah,40h
;                cmp  al,ah
;                Je   waite
                 MOV  AH,0
                 INT  16H

NO_CHECK:
                                POP BX
                                POP AX
                                POP DX
                                POP DI
                                POP SI
                                POP DS
                                POP ES
                                POP CX
                                POPF
                                retf 02
;-----------------------------------------------------------------------------
PROT:
                push  ax
                mov  ax,word ptr cs:[p_flag - deep]
                cmp  ax,1
                Jne  retp
                push ds
                push bx
                mov  di,bx
                mov  cx,0
lop_p:          cmp  byte ptr [di],0
                je   protcx
                inc  cx
                inc  di
                jmp  lop_p
         ;
protcx:
               mov     cs:[int_21-deep],1
               mov     cs:[len - deep] ,cx
               push    cs
               pop     ds
               mov     dx,offset [buf - deep]
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
               mov     dx, OFFSET soob - DEEP
               mov     bx, di                  ; Handle for target file
               mov     cx, 2d                  ; Write number of bytes read
               mov     ah, 40h                 ; Request DOS write
               int     21h                     ; Write from buffer to target file
               pop     dx
               pop     ds
               mov     bx, di                  ; Handle for target file
               mov     cx, cs:[len - deep]              ; Write number of bytes read
               mov     ah, 40h                 ; Request DOS write
               int     21h                     ; Write from buffer to target file
close1:
               mov     bx, di                  ; Handle for target file
               mov     ah, 3Eh                 ; Request DOS Function 3Eh
               int     21h                     ; Close File
retp:          pop  ax
               mov cs:[int_21-deep],0
               ret
;-----------------------------------------------------------------------------
write:
                push ax
                mov  ax,word ptr cs:[w_flag - deep]
                cmp  ax,1
                Jne  retu
                mov  ax,0b800h
                mov  es,ax
                MOV  AX,bx
                cld
WRIT:           MOVSB
                MOV  BYTE PTR ES:[DI],07H
                inc  di
                INC  AX
                MOV  BL,BYTE PTR ds:[si]
                CMP  BL,0
                JNE  WRIT
                CMP   AX,50h
                jnbe  retu
lop1:
                MOV  ES:[DI],0720H
                ADD  DI,2
                INC  AX
                CMP  AX,50h
                jb   lop1
retu:           pop  ax
                ret
;-----------------------------------------------------------------------------
writcx:
                push ax
                mov  ax,word ptr cs:[w_flag - deep]
                cmp  ax,1
                Jne  retucx
                mov  ax,0b800h
                mov  es,ax
                MOV  AX,bx
                cld
WRITc:          MOVSB
                MOV  BYTE PTR ES:[DI],07H
                inc   di
                INC   AX
                loop  WRITc
                CMP   AX,50h
                jnbe  retucx
lop11:          MOV  ES:[DI],0720H
                ADD  DI,2
                INC  AX
                CMP  AX,50h
                jb   lop11
retucx:         pop  ax
                ret
;-----------------------------------------------------------------------------
REG_NAME:                       PUSH AX
                                PUSH CX
                                MOV AL,DH
                                MOV byte ptr [BX],Al
                                inc BX
                                MOV AL,DL
                                MOV byte ptr [BX],Al
                                inc BX
                                MOV byte ptr [BX],20h
                                inc BX
                                POP CX
                                POP AX
                                RET
;-------------------------------------------
savreg:
                                MOV CS:[AX_ - DEEP],AX
                                MOV CS:[DX_ - DEEP],DX
                                MOV CS:[BX_ - DEEP],BX
                                MOV CS:[CX_ - DEEP],CX
                                MOV CS:[SI_ - DEEP],SI
                                MOV CS:[DI_ - DEEP],DI
                                MOV CS:[BP_ - DEEP],BP
                                PUSH DS
                                POP AX
                                MOV CS:[DS_ - DEEP],AX
                                PUSH ES
                                POP AX
                                MOV CS:[ES_ - DEEP],AX
                                PUSH SS
                                POP DS
                                PUSH SP
                                POP  DI
                                mov ax,DS:[DI+16h]
                                sub ax,2
                                mov cs:[ip_-deep],ax
                                mov ax,DS:[DI+18h]
                                mov cs:[cs_-deep],ax
                                mov ax,DS:[DI+14h]
                                mov cs:[F_-deep],ax
                                ret
;-------------------------------------------
writreg:
                                push di
                                push ax
                                MOV BX,offset str_out - deep
                                MOV DX,'ax'
                                CALL REG_NAME
                                pop ax
                                mov byte ptr [bx-1],al
                                MOV AX,CS:[AX_ - DEEP]
                                CALL OUTPUT
                                MOV AX,CS:[BX_ - DEEP]
                                MOV DX,'bx'
                                CALL REG_NAME
                                CALL OUTPUT
                                MOV AX,CS:[CX_ - DEEP]
                                MOV DX,'cx'
                                CALL REG_NAME
                                CALL OUTPUT
                                MOV AX,CS:[DX_ - DEEP]
                                MOV DX,'dx'
                                CALL REG_NAME
                                CALL OUTPUT
                                MOV AX,CS:[SI_ - DEEP]
                                MOV DX,'si'
                                CALL REG_NAME
                                CALL OUTPUT
                                MOV AX,CS:[DI_ - DEEP]
                                MOV DX,'di'
                                CALL REG_NAME
                                CALL OUTPUT
                                MOV AX,CS:[DS_ - DEEP]
                                MOV DX,'ds'
                                CALL REG_NAME
                                CALL OUTPUT
                                MOV AX,CS:[ES_ - DEEP]
                                MOV DX,'es'
                                CALL REG_NAME
                                CALL OUTPUT
                                MOV AX,CS:[cs_ - DEEP]
                                MOV DX,'cs'
                                CALL REG_NAME
                                CALL OUTPUT
                                MOV AX,CS:[ip_ - DEEP]
                                MOV DX,'ip'
                                CALL REG_NAME
                                CALL OUTPUT
                                mov  al,0
                                mov  byte ptr [bx],al
                                mov  si,offset str_out - deep
                                pop  di
                                mov  bx,0
                                call write
                                mov  bx,offset str_out - deep
                                call prot
                                ret
;-------------------------------------------
DRIVER: ;                       int 3
                                PUSHF
                                cmp ah,0f8h     ;ah f8 - обработать
                                jne dda                    ;  al:     p  w
                                cmp al,01h                 ;
                                jne dd1                    ;      01  +  +
                                mov word ptr cs:[p_flag],1 ;
                                mov word ptr cs:[w_flag],1
                                jmp ddo
dd1:                            cmp al,02h                 ;
                                jne dd2                    ;      02  +  -
                                mov word ptr cs:[p_flag],1 ;
                                mov word ptr cs:[w_flag],0
                                jmp ddo
dd2:                            cmp al,03h                 ;
                                jne dd3                    ;
                                mov word ptr cs:[p_flag],0 ;      03  -  +
                                mov word ptr cs:[w_flag],1
                                jmp ddo
dd3:                            cmp al,04h                 ;
                                jne dd4                    ;      04  -  -
                                mov word ptr cs:[p_flag],0 ;
                                mov word ptr cs:[w_flag],0
                                jmp ddo
dd4:                            mov al,0ffh                ;
ddo:                            popf                       ;   else : al<-ff
                                iret
dda:                            PUSH CX
                                PUSH ES
                                PUSH DS
                                PUSH SI
                                PUSH DI
                                PUSH DX
                                PUSH AX
                                PUSH BX
                                cmp cs:[int_21 - deep],0
                                je  inteo
outjmp_1:                       jmp outjmp
inteo:
                                MOV CS:[AX_1 - DEEP],AX
                                call savreg
                                mov  ax,cs:[ax_1-deep]
                                 MOV  al,ah
                                 mov  ah,00h
                                 MOV  BX,OFFSET pro_int - DEEP
                                 ADD  BX,AX
                                 MOV  AH,CS:[BX]
                                 CMP  AH,00H
                                 JZ   outjmp_1
                                push cs
                                pop ds
                                mov  di,0A0H
                                mov  al,'>'
                                call writreg
                                POP BX
                                POP AX
                                PUSH AX
                                PUSH BX
                                CMP AH,63H      ;        chaNGE HERE !!!!!!!!
                                Ja  NO_NAMING
                          PUSH CS
                          POP ds
                MOV AL,AH
                MOV AH,00
                ADD AX,AX
                MOV BX,OFFSET NAMING_ADDR - DEEP
                ADD BX,AX
                MOV  si,CS:[BX]
                push si
                mov  di,0h
                mov  bx,0
                call write
                pop  bx
                call prot
;-------------------------------------------
NO_NAMING:
                                POP BX
                                POP AX
                                POP DX
                                POP DI
                                POP SI
                                POP DS
                                POP ES
                                POP CX
                                PUSH CX
                                PUSH ES
                                PUSH DS
                                PUSH SI
                                PUSH DI
                                PUSH DX
                                PUSH AX
                                PUSH BX
                CMP     AH,4BH
                JZ      DIRECT_NAME
                CMP             AH,0FH
                JZ WELL0F
                CMP             AH,10H
                JZ WELL0F
                CMP             AH,11H
                JZ WELL0F
                CMP             AH,12H
                JZ WELL0F
                CMP             AH,13H
                JZ WELL0F
                CMP             AH,14H
                JZ WELL0F
                CMP             AH,15H
                JZ WELL0F
                CMP             AH,16H
                JZ WELL0F
                CMP             AH,17H
                JZ  REN
                CMP             AH,21H
                JZ WELL0F
                CMP             AH,22H
                JZ WELL0F
                CMP             AH,23H
                JZ WELL0F
                CMP             AH,24H
                JZ WELL0F
                CMP             AH,27H
                JZ WELL0F
                CMP             AH,28H
                JZ WELL0F
                CMP             AH,39H
                JZ      DIRECT_NAME
                CMP             AH,3AH
                JZ      DIRECT_NAME
                CMP             AH,3BH
                JZ      DIRECT_NAME
                CMP             AH,3CH
                JZ      DIRECT_NAME
                CMP             AH,3DH
                JZ      DIRECT_NAME
                CMP             AH,41H
                JZ      DIRECT_NAME
                CMP             AH,4EH
                JZ      DIRECT_NAME
                CMP             AH,56H
                JZ      DS_DX_ES_DI
                JMP SCROLL_CHECK
;-------------------------------------------
WELL0F:         JMP W0F
REN:            JMP RENAME
DIRECT_NAME:    JMP DIRECT_NAME_F
DS_DX_ES_DI:    JMP DS_DX_ES_DI_F
;-------------------------------------------
DIRECT_NAME_F:
                mov  si,dx
                push si
                mov  di,0f50h
                mov  bx,50h
                call write
                pop  bx
                call prot
                jmp     scroll_check
DS_DX_ES_DI_F:
                push di
                push es
                mov  si,dx
                push si
                mov  di,0f62h
                mov  bx,3eh
                call write
                pop  bx
                call prot
                pop  ds
                pop  si
                push si
                mov  di,0f80h
                mov  bx,20h
                call write
                pop  bx
                call prot
                jmp     scroll_check
RENAME:
                PUSH DS
                PUSH DX
                MOV BX,0f62h
                CALL BUF_VISU
                POP DX
                POP DS
                ADD DX,10H
                MOV BX,0f80h
                CALL BUF_VISU
                JMP SCROLL_CHECK
W0F:
                MOV BX,0f62h
                CALL BUF_VISU
;-------------------------------------------
scroll_check:
NO_SCROLL:
                                POP BX
                                POP AX
                                POP DX
                                POP DI
                                POP SI
                                POP DS
                                POP ES
                                POP CX
                POPF
                JMP FINITA
;-------------------------------------------
buf_visu:       mov  si,dx
                inc  si
                push si
                mov  di,bx
                add  bx,50h
                sub  bx,0fa0h
                mov  cx,0bh
                call writcx
                pop  bx
                mov  cx,0bh
                call protcx
                ret
;-------------------------------------------
;-------------------------------------------
OUTPUT:
        PUSH CX
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
                        MOV byte ptr [BX],20h
                        inc bx
                POP CX
                RET
HEX:            ADD AL,30H
                CMP AL,3AH
                JB SIMPLE
                ADD AL,07H
SIMPLE:         MOV byte ptr [BX],AL
                INC BX
                RET
;-------------------------------------------
Start9:  ;     int 3
               PUSHF
               PUSH CX
               PUSH ES
               PUSH SI
               PUSH DI
               PUSH AX
               PUSH BX
               PUSH DS
               PUSH DX
;--------
              in      al,60H             ;читать ключ
              cmp     al,19h        ;p
              jne     outpjmp9
              mov ax,0
              mov ds,ax
              mov si,417h
              mov ah,BYTE PTR ds:[si]
              push    cs
              pop     ds
              and ah,0Ch
              cmp ah,0Ch
              jne outpjmp9
         in      al,61H             ;взять значениe порта управления клавиатурой
         mov     ah,al              ; сохранить его
         or      al,80h             ;установить бит разрешения для клавиатуры
         out     61H,al             ; и вывести его в управляющий порт
         xchg    ah,al              ;извлечь исходное значение порта
         out     61H,al             ; и записать его обратно
         mov     al,20H             ;послать сигнал "конец прерывания"
         out     20H,al             ; контроллеру прерываний 8259
              mov     ax,word ptr cs:[p_flag - deep]
              cmp     ax,0
              je      dda1
              mov     word ptr cs:[p_flag - deep],0
              jmp     outiret9
dda1:
              mov     word ptr cs:[p_flag-deep],1
;-------
outiret9:
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
outpjmp9:
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
;-----------------------------------------
NAMING_ADDR     DW      66H     DUP(0000H)
NUM_LOCK        DB      66H     DUP(01H)
                db '*int*'
pro_int         DB      66H     DUP(01H)
str_out         db      82d     dup(' ')
p_flag          dw      0
w_flag          dw      1
int_21          dw      0
int_9           dw      0
erra            db    0dh,0ah, 'ERORR OPEN FILE:'
buf             db    '<no file>$', 20d dup(0)  ;параметр
len             dw    00h
SOOB            DB    0dh,0ah
DX_ DW 01H
BX_ DW 01H
CX_ DW 01H
DI_ DW 01H
DS_ DW 01H
SI_ DW 01H
SP_ DW 01H
BP_ DW 01H
ES_ DW 01H
SS_ DW 01H
cs_ DW 01H
ip_ DW 01H
AX_ DW 01H
F_  DW 01H
AX_1 DW 01H
;-------------------------------------------
NAMING: DB 'INT 21:Завершить программу',00h       ;0
DB      'INT 21:ввод с клавиатуры знака с эхом проверка на Break #AL',00h;1
DB      'INT 21:DL# вывод на ст.вывод',00h;2
DB      'INT 21:вспомогательный ввод(асинхронный адаптер связи) #AL',00h;3
DB      'INT 21:DL# вспомогательный вывод(асинхронный адаптер связи)',00h;4
DB      'INT 21:DL# вывод на печать',00h;5
DB      'INT 21:DL# прямой ввод-вывод #AL',00h;6
DB      'INT 21:прямой ввод с кл. без эха и проверки на Break #AL',00h;7
DB      'INT 21:прямой ввод с кл.без эха, но с проверкой на Break #AL',00h;8
DB      'INT 21:вывод строки #[DS:DX]',00h;9
DB      'INT 21:[DS:DX]# ввод с клавиатуры через буфер',00h;0ah
DB      'INT 21:проверка стандартного уст-ва ввода и на Break #AL',00h; 0bh
DB      'INT 21:AL# очистка буфера стандартного уст-ва ввода & CALL функции AH#-1,6,7,8',00h;        0ch
DB      'INT 21:сброс диска',00h;      0dh
DB      'INT 21:DL# выбор диска, возвращает число дисков в системе #AL',00h      ;0eh
DB      'INT 21:[DS:DX]# открыть файл FCB #AL-flag',00h   ;0fh
DB      'INT 21:[DS:DX]# закрыть файл FCB #AL-flag',00h   ;10h
DB      'INT 21:[DS:DX]# поиск первого элемента FCB #AL-flag',00h ;11h
DB      'INT 21:[DS:DX]# поиск следующего элемента #AL-flag',00h      ;12h
DB      'INT 21:[DS:DX]# удалить файл #AL-flag',00h   ;13h
DB      'INT 21:[DS:DX]# последовательное чтение #AL-flag',00h        ;14h
DB      'INT 21:[DS:DX]# последовательная запись #AL-flag',00h        ;15h
DB      'INT 21:[DS:DX]# создать файл #AL-flag',00h   ;16h
DB      'INT 21:[DS:DX]# переименовать файл #AL-flag',00h     ;17h
DB      'INT 21:используется внутри DOS',00h   ;18h
DB      'INT 21:текущий диск DOS #AL',00h   ;19h
DB      'INT 21:[DS:DX]# установить область обмена с диском DTA',00h    ;1аh
DB      'INT 21:информация FAT(акт.диск)#AL-сектор/кластер#CX-длина сект.#DX-кластеров',00h       ;1bh
DB      'INT 21:информация FAT(диск #DL)#AL-сектор/кластер#CX-длина сект.#DX-кластеров',00h       ;1bh
DB      'INT 21:используется внутри DOS',00h   ;1dh
DB      'INT 21:используется внутри DOS',00h   ;1eh
DB      'INT 21:используется внутри DOS',00h   ;1fh
DB      'INT 21:используется внутри DOS',00h   ;20h
DB      'INT 21:[DS:DX]# произвольное чтение FCB #AL',00h    ;21h
DB      'INT 21:[DS:DX]# произвольная запись FCB #AL',00h    ;22h
DB      'INT 21:[DS:DX]# размер файла FCB #AL',00h   ;23h
DB      'INT 21:[DS:DX]# установить номер записи для произвольного доступа FCB ',00h     ;24h
DB      'INT 21:AL# номер [DS:DX]# адрес - установить вектор прерывания',00h       ;25h
DB      'INT 21:создать новый программный сегмент',00h       ;26h
DB      'INT 21:CX# число блоков - произвольное чтение блоков FCB #AL',00h   ;27h
DB      'INT 21:CX# число блоков - произвольнaя запись блоков FCB #AL',00h   ;28h
DB      'INT 21:DS:SI строка для анализа,ES:DI буфер для FCB -анализ имени файла #AL',00h       ;29h
DB      'INT 21:получить дату #CX-год #DH-месяц #DL-день',00h     ;2аh
DB      'INT 21:CX#-год DH#-месяц DL#-день --- установить дату#AL',00h    ;2bh
DB      'INT 21:получить время #CH-часы #CL-мин #DH-секунды #DL-сотые доли сек',00h        ;2ch
DB      'INT 21:CH#-часы CL#-мин DH#-секунды DL#-сотые доли сек---установить время#AL',00h ;2dh
DB      'INT 21:Установить/сбросить переключатель верификации',00h;          2eH
DB      'INT 21:Дать текущий DTA',00h;                                       2fH
DB      'INT 21:Дать номер версии DOS',00h;                                  30H
DB      'INT 21:Завершиться и остаться резидентным -- KEEP',00h;             31H
DB      'INT 21:Дать дисковую информацию DOS (недокументировано)',00h;       32H
DB      'INT 21:Установить/опросить уровень контроля прерывания DOS',00h;    33H
DB      'INT 21:Адрес статуса реентерабельности DOS',00h;                    34H
DB      'INT 21:AL# номер [DS:DX]# адрес -Дать вектор прерывания',00h;                                 35H
DB      'INT 21:Дать свободную память диска',00h;                            36H
DB      'INT 21:Установить/опросить символ-переключатель (недокументировано)',00h; 37H
DB      'INT 21:Дать/Установить информацию страны',00h;                      38H
DB      'INT 21:Создать новое оглавление -- MKDIR',00h;                      39H
DB      'INT 21:Удалить оглавление -- RMDIR',00h;                            3aH
DB      'INT 21:Установить умалчиваемое оглавление DOS -- CHDIR',00h;        3bH
DB      'INT 21:Создать описатель файла',00h;                                3cH
DB      'INT 21:Открыть описатель файла',00h;                                3dH
DB      'INT 21:Закрыть описатель файла',00h;                                3eH
DB      'INT 21:Читать файл через описатель',00h;                              3fH
DB      'INT 21:Писать в файл через описатель',00h;                    40H
DB      'INT 21:Удалить файл',00h;                                                             41H
DB      'INT 21:Установить указатель файла -- LSEEK',00h;              42H
DB      'INT 21:Установить/опросить атрибут файла -- CHMOD',00h;       43H
DB      'INT 21:Управление вводом-выводом устройства -- IOCTL',00h;44H
DB      'INT 21:Дублировать описатель файла -- DUP',00h;               45H
DB      'INT 21:Переназначить описатель -- FORCDUP',00h;               46H
DB      'INT 21:Дать умалчиваемое оглавление DOS',00h;                 47H
DB      'INT 21:Распределить память (дать размер памяти)',00h; 48H
DB      'INT 21:Освободить блок распределенной памяти',00h;    49H
DB      'INT 21:Сжать или расширить блок памяти',00h;                  4aH
DB      'INT 21:Выполнить или загрузить программу -- EXEC',00h;4bH
DB      'INT 21:Завершить программу -- EXIT',00h;                              4cH
DB      'INT 21:Дать код выхода программы -- WAIT',00h;                4dH
DB      'INT 21:Найти 1-й совпадающий файл',00h;                               4eH
DB      'INT 21:Найти следующий совпадающий файл',00h;                 4fH
DB      'INT 21:используется внутри DOS',00h;                                  50h
DB      'INT 21:используется внутри DOS',00h;                                  51h
DB      'INT 21:используется внутри DOS',00h;                                  52h
DB      'INT 21:используется внутри DOS',00h;                                  53h
DB      'INT 21:Дать переключатель верификации DOS',00h;               54H
DB      'INT 21:используется внутри DOS',00h;                                  55h
DB      'INT 21:Переименовать/переместить файл',00h;                   56H
DB      'INT 21:Установить/опросить время/дату файла',00h;             57H
DB      'INT 21:используется внутри DOS',00h;                                  58h
DB      'INT 21:Дать расширенную информацию об ошибке',00h;    59H
DB      'INT 21:Создать уникальный временный файл',00h;                5aH
DB      'INT 21:Создать новый файл',00h;                                               5bH
DB      'INT 21:Блокировать/разблокировать доступ к файлу',00h;5cH
DB      'INT 21:используется внутри DOS',00h;                                  5dh
DB      'INT 21:Различные сетевые функции',00h;                                5eH
DB      'INT 21:Переназначение устройств в сети',00h;                  5fH
DB      'INT 21:используется внутри DOS',00h;                                  60h
DB      'INT 21:используется внутри DOS',00h;                                  61h
DB      'INT 21:Дать адрес префикса программного сегмента',00h;62H
DB      'INT 21:используется внутри DOS',00h;                                  63h
DB      'INT 21:используется внутри DOS',00h;                                  64h
;================================================================================================
GREETING        DB 'Interruption 21h',39D,'s (DOS) functions tracer.$'
err1            DB 'Already installed.$'
hell            db  0dh,0ah,'USE: 21 [[W] [Fd:\path\file]]        ',0dh,0ah
                db          '     W(w) - Вывод на экран (вкл)    ',0dh,0ah
                db          '     F - Вывод в указанный файл(выкл)',0dh,0ah
                db          '     f - Задать файл для вывода      ',0dh,0ah
                db          'Ctrl+Alt+P - вкл./выкл. вывод в файл ',0dh,0ah,'$'
star            db  'INT 21h tracer!! ',0ah,0dh
final           DB  ' OK!',0dh,0Ah,'$'
flag            dw  00h
fl              DW  00H
;---------------------------
RESIDENT:       MOV DX,OFFSET GREETING
                MOV AH,09H
                INT 21H
;
                push cs
                pop  ds
                mov  si,80h
                mov  cl,es:[si]
                mov  ch,0
                inc  si
                mov  fl,0
param:
                call space
                mov  al,byte ptr ds:[si]
                cmp  cx,0
                jne  dali0
                mov ah,0f8h
                int 21h
                cmp al,0ffh
                jne ddal
                mov dx,offset err1
                jmp exit_z
ddal:           jmp  inst

dali0:          cmp  fl,0
                jne  fle
                mov  word ptr cs:[p_flag],0
                mov  word ptr cs:[w_flag],0
                mov  fl,1
fle:            cmp  al,'W'
                jne  dali1
                call obW
                jmp  param
dali1:
                cmp  al,'w'
                jne  dali2
                call obW
                jmp  param
dali2:
                cmp  al,'F'
                jne  dali3
                mov  word ptr cs:[p_flag],1
                call obf
                CMP AX,0
                JNE ERER_R
                jmp  param
dali3:
                mov  dx,offset hell
                cmp  al,'f'
                jne  exit_zz
                call obf
                CMP  AX,0
                JNE  ERER_R
                jmp  param
ERER_R:         JMP  ERER
exit_zz:        jmp  exit_z
;-------------------------------------- get & set  vectors ---------
inst:           push cs
                pop  ds
                mov  dx,offset final
                mov  ah,09h
                int  21h
;---------
                MOV     BX,0H
                MOV     DS,BX
                MOV     AX,DS:[OLD_ADDR]
                MOV     DX,DS:[OLD_ADDR+2H]
                MOV     CS:WHERE,AX
                MOV     CS:SEG_WHERE,DX
                MOV     CS:WHERE1,AX
                MOV     CS:SEG_WHERE1,DX
                MOV     SI,OLD_ADDR
                MOV     WORD PTR DS:[SI],OFFSET DRIVER - DEEP
                MOV     WORD PTR DS:[SI+2],CS
;---------
                cmp     word ptr cs:flag,0
                je      obxod
                MOV     AX,DS:[OLD_ADDR9]
                MOV     DX,DS:[OLD_ADDR9+2H]
                MOV     CS:keep_ip9,AX
                MOV     CS:keep_cs9,DX
                MOV     SI,OLD_ADDR9
                MOV     WORD PTR DS:[SI],OFFSET start9 - deep
                MOV     WORD PTR DS:[SI+2H],CS
;---------
obxod:          PUSH CS
                POP DS
                MOV BX,OFFSET NAMING_ADDR
                PUSH DS
                POP ES
                MOV DI,OFFSET NAMING
                MOV WORD PTR [BX],OFFSET NAMING - DEEP
                XOR DX,DX
INSTALL:        ADD BX,02H
FIND_ZERO:      MOV AL,ES:[DI]
                CMP AL,00
                JZ DO_INSTALL
                INC DI
                JMP FIND_ZERO
DO_INSTALL:     INC DI
                MOV AX,DI
                SUB AX,DEEP
                MOV WORD PTR [BX],AX
                INC DX
                CMP DX,64H      ;HERE MUST BE 55H OR SOMETHING !!!!!!!!!
                JB  INSTALL
                MOV DX,OFFSET GREETING  - DEEP
                PUSH DX
                PUSH DS
                POP ES
                MOV SI, 100H
                MOV DI, 100H    -       DEEP
                MOV CX,OFFSET GREETING + 10H - 100H
                CLD
REP             MOVSB
                POP DX
                INT 27H
;---------------------------------- exit & .not. tsr  -----------------
erer:          mov     dx,offset erra
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
;--------------
lensp:
                mov     bx,0
                cmp     cx,0
                jne     lops
                ret
lops:
                lodsb                           ;Load AL with DS:[SI]
                cmp     al,20h ;( )
                jne     RET_3
                DEC     SI
                ret
RET_3:          inc     bx
                loop    lops
                ret
;--------------
obw:
                mov     word ptr cs:[w_flag],1
                jmp     lensp
;---------------
obf:
                mov  word ptr cs:flag,1
                inc  si
                dec  cx
                push si
                call lensp
                pop  si
                PUSH CX
                MOV  CX,BX
                MOV  bx,offset buf     ;
                cmp  CX,0
                jne  lop_1
                mov  ax,1
                push si
                jmp  exit_c
lop_1:          lodsb                  ;
                MOV  byte ptr [BX],Al  ; копировать параметр
                INC  BX                ;
                loop lop_1             ;
                mov  al,0h             ;
                MOV  byte ptr [BX],Al  ;
                INC  BX                ;
                mov  al,'$'            ;
                MOV  byte ptr [BX],Al  ;
                push si
;-------------------------------------- open file ---------
ope:           mov     dx,offset buf
               mov     ah, 3Ch                 ; No?  Request Create File
               sub     cx, cx                  ; Normal attribute for target
               int     21h                     ; DOS function for target file
               jc      close                   ; If open error, abort
               mov     di, ax                  ; DI = file handle for target
               mov     dx,offset star
               mov     bx, di                  ; Handle for target file
               mov     cx, 17d                 ; Write number of bytes read
               mov     ah, 40h                 ; Request DOS write
               int     21h                     ; Write from buffer to target file
close:         pushf                           ; Preserve flags while closing
               mov     bx, di                  ; Handle for target file
               mov     ah, 3Eh                 ; Request DOS Function 3Eh
               int     21h                     ; Close File
               mov     ax,0
               popf                            ; Recover flags
               jnc     exit_c                  ; If successful, exit
               mov     dx,offset buf
               mov     ah, 41H
               int     21h
               mov     ax,1
exit_c:        pop     si
               pop     cx
               ret
CODE            ENDS
                END       START
