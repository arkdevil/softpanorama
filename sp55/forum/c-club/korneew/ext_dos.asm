        DOSSEG
        .MODEL LARGE
;.286

        .CODE
;----------------------------------------------------------------------------

cl_fopen        PROC    FAR
                push    bp
                mov     bp,sp
                mov     dx,     ss:[bp+6]
		mov     ds,     ss:[bp+8]
		mov     ah,     4Eh
		int     21h
		mov     ax,     3D02h
		jnc     op_en
		xor     cx,     cx
		mov     ax,     3C00h
op_en:
		int     21h
		jnc     ret_op
		xor     ax,ax
ret_op: 	pop     bp
		ret
cl_fopen        Endp

;/*----------------------------------------------------------- _fclose---*/
cl_fclose       PROC    FAR
		push    bp
		mov     bp,sp
		mov     bx,     ss:[bp+6]
		mov     ah,     3eh
		int     21h
		pop     bp
		ret
cl_fclose       Endp

;/*------------------------------------------------------------ _fread---*/
cl_fread        Proc    Far
		push    bp
		mov     bp,sp
		mov     bx,     ss:[bp+6]
		mov     cx,     ss:[bp+8]
		mov     dx,     ss:[bp+10]
		mov     ds,     ss:[bp+12]
		mov     ah,     3fh
		int     21h
		jnc Ok_3f
		xor     cx, cx
	Ok_3f:  mov     ax, cx
		pop bp
		ret
cl_fread        Endp

;/*----------------------------------------------------------- _fwrite---*/
cl_fwrite       Proc    Far
		push    bp
		mov     bp,sp
		mov     bx,     ss:[bp+6]
		mov     cx,     ss:[bp+8]
		mov     dx,     ss:[bp+10]
		mov     ds,     ss:[bp+12]
		mov     ah,     40h
		int     21h
		pop bp
		ret
cl_fwrite       Endp

;/*------------------------------------------------------------ _fseek---*/
cl_fseek       Proc    Far
		push    bp
		mov     bp,sp
		mov     bx,     ss:[bp+6]
		mov     dx,     ss:[bp+8]
		mov     cx,     ss:[bp+10]
		mov     ax,     ss:[bp+12]
		mov     ah,     42h
		int     21h
		pop bp
		ret
cl_fseek        Endp

;----------------------------------------------------------------------------

Kb_To_Byte      PROC     ;переводит килобайты (АХ) в байты

	mov bx, 0400h
	mul bx

	ret

Kb_To_Byte      ENDP

;-----------------------------------------------------------------------------

Open_File       PROC
        push ds
        push offset $File_&Name
        call cl_fopen                                   ;open tmp file
        add sp, 4
        mov $My_@Hahdl, ax

        push ds
        push offset $FCB
        push 8
        push $My_@Hahdl
        call cl_fwrite                          ;write in file zero FCB
        add sp, 8
        cmp ax, 8
        jne $$$aa
        xor ax, ax

$$$aa:  ret
Open_File       ENDP

;-----------------------------------------------------------------------------

Send_to_File PROC

        mov ax, word ptr [Handle+2]
        mov bx, word ptr [Handle]

        push 0                                                  ;от начала файла
        push ax
        push bx
        push $My_@Hahdl
        call cl_fseek                                   ;ставлю указатель на начало указанного блока
        add sp, 8

        push word ptr [Arrary+2]
        push word ptr [Arrary]
        push [bp+14]                                    ;word ptr [Byte]
        push $My_@Hahdl
        call cl_fwrite                                  ;из памяти в файл
        add sp, 8
        cmp ax, [bp+14]                                 ;word ptr [Byte]
        jne %%qqq1                                              ;при ошибке при записи перехожу на конец
        xor ax, ax
        ret

%%qqq1: mov ax, 4
        ret
Send_to_File ENDP

;-----------------------------------------------------------------------------

Send_from_File  PROC

        push 0                                                  ;от начала файла
        push word ptr [Handle+2]
        push word ptr [Handle]
        push $My_@Hahdl
        call cl_fseek                                   ;ставлю указатель на начало указанного блока
        add sp, 8

        push word ptr [Arrary+2]
        push word ptr [Arrary]
        push word ptr [bp+14]           ;количество пресылаемых байт
        push $My_@Hahdl
        call cl_fread                                   ;из файла в памяь
        add sp, 8
        cmp ax, word ptr [bp+14]        ;количество пресылаемых байт
        jne %%qqq2                                              ;при ошибке при записи перехожу на конец
        xor ax, ax
        ret

%%qqq2: mov ax, 4
        ret
Send_from_File ENDP

;------------------------------------------------------------------------------

File_Free       PROC

        push 0                                                  ;0 - от начала файла, 1 - от текущего положения,
        mov ax, word ptr $Tmp
        sub ax, 0008h
        push ax ;сегмент в файле
        push [$Tmp+2]                                           ;offset in file
        push word ptr $My_@Hahdl   ;handle of file
        call cl_fseek                                   ;ставлю указатель на начало FCB указанного блока
        add sp, 8

        push ds
        push offset $FCB
        push 8
        push $My_@Hahdl                                         ;читаю FCB в память
        call cl_fread
        add sp, 8
        cmp ax, 8
        jne $$%aaQ                                                              ;при ошибке при записи перехожу на конец

        mov ax, word ptr $Tmp
        cmp ax, word ptr [$FCB+2]                       ;найден запрошенный блок?
        jne      $%%aa1                                                 ;если нет - то переход

        mov ax, [$Tmp+2]
        xor word ptr [$FCB+4], 8000h
        cmp ax, word ptr [$FCB+4]        ;найден запрошенный блок?
        je %%%aa1                                                               ;если да - то переход
$%%aa1: mov ax, 0a2h               ;иначе возвращаю ошибку
        ret

%%%aa1: mov byte ptr [$FCB+1], 0                                ;сбрасываю флаг занятости
        push 1
        push -1
        push -8
        push $My_@Hahdl
        call cl_fseek                                   ;ставлю указатель на начало FCB
        add sp, 8

        push ds
        push offset $FCB
        push 8
        push $My_@Hahdl
        call cl_fwrite                                  ;пишу исправленный FCB
        add sp, 8
        cmp ax, 8
        jne $$%aaQ                                              ;при ошибке при записи перехожу на конец
        xor ax, ax
        ret

$$%aaQ:  mov ax, 4
        ret
File_Free ENDP

;-----------------------------------------------------------------------------

;_____________________________проверка на MSDOS 5.0___________________________

       PUBLIC  _Check_Dos
_Check_Dos  PROC

       mov ax,3306h                 ;get true DOS version
       int 21h
       jc Error                     ;if DOS is't 5.0
       xor ax, ax
       jmp short zzzz
Error:   mov _DOS_KEY, 0fh

zzzz:  ret
_Check_Dos  ENDP

;------------------------------------------------------------------------------

        PUBLIC   _Check_XMS
_Check_XMS   PROC

        mov ax,4300h                 ;get status XMS
        int 2fh
        cmp al,80h                   ;XMS installed?
        jne Sory

        mov ax,4310h           ;get adres XMS handler
        int 2fh
        mov _XMS_BX,bx                ;save adres XMS handler
        mov _XMS_ES,es
        xor ax, ax
        jmp short zzzz1
Sory: mov ax,0001h

zzzz1:   ret
_Check_XMS  ENDP

;------------------------------------------------------------------------------

        PUBLIC   _Get_Free_Size
_Get_Free_Size  PROC
        mov ah,08h                 ;query free extended memeory, not counting HMA
        call DWORD PTR _XMS_BX      ;DX - total extended memory block in K
                                                                                ;AX - size of largest extended memory block in K
        mov _EMS_Error,bl
        mov _Total_EXT,dx
        cmp dx, 0000h
        jne ___end2
        xor ax, ax
___end2:        ret
_Get_Free_Size  ENDP

;------------------------------------------------------------------------------

        PUBLIC  _Enable_A20
_Enable_A20  PROC

        mov ah,07h                    ;get state A20
        call DWORD PTR _XMS_BX
        cmp ax, 0001h
        jne Continue
        mov _Flag_A20, ax            ;save state A20

Continue:
        mov ah,03h
        call DWORD PTR _XMS_BX      ;enable A20
        cmp ax,0001h               ;enable A20?
        jne Ending                 ;if not enable

        mov ah,05h                 ;local  enable A20 for direct extended memory
        call DWORD PTR _XMS_BX
        cmp ax,0000h
        je Ending
        xor ax, ax
        jmp short zzzz2

Ending:  mov al,bl

zzzz2:   ret

_Enable_A20   ENDP

;------------------------------------------------------------------------------
        PUBLIC _EMS_Close
_EMS_Close   PROC

        push $My_@Hahdl
        call cl_fclose
        add sp, 2

        mov dx, offset $File_&Name
        mov ah, 41h
        int 21h

        mov ah,06h                 ;Local disable A20
        call DWORD PTR _XMS_BX
        cmp _Flag_A20, 0000h
        xor ax, ax
        jne Tutu
        mov ah,04h
        call DWORD PTR _XMS_BX    ;global disable A20
        cmp ax,0001h
        jne _Not_Disable
        xor ax, ax
        jmp short Tutu
_Not_Disable:  mov al,bl

Tutu:   RET
_EMS_Close   ENDP

;------------------------------------------------------------------------------

        PUBLIC _EMS_Lock
_EMS_Lock   PROC

        arg     Handle:dword
        push    bp
        mov     bp,sp

        mov DX, word ptr [Handle]
        mov ah,0ch
        call DWORD PTR _XMS_BX      ;lock extended memory block
        cmp ax,0001h
        je No_Lock
        mov al, bl
        jmp short zzzz4
No_Lock: xor ax, ax
        mov _Addres_Line, bx
        mov Addres_Line, dx
zzzz4:   pop      bp            ;restore C's standard data seg
        RET
_EMS_Lock       ENDP

;------------------------------------------------------------------------------

        PUBLIC _EMS_Unlock
_EMS_Unlock   PROC

        arg     Handle:dword
        push    bp
        mov     bp,sp

        mov dx, word ptr [Handle]
        mov ah,0dh
        call DWORD PTR _XMS_BX      ;unlock extended to memory block
        cmp ax,0001h
        jne No_Unlock
        xor ax, ax
        jmp short zzzz5

No_Unlock:  mov al,bl

zzzz5:   pop      bp            ;restore C's standard data seg
        RET
_EMS_Unlock  ENDP

;------------------------------------------------------------------------------

Alloc_of_File   PROC

        ;нахожу свободный блок, или изменяю последний
        ;ДЛИННА НАЙДЕННОГО БЛОКА НЕ МЕНЬШЕ ЗАПРОШЕННОЙ -
        ;ЕСЛИ БОЛЬШЕ ТО НЕ УСЕКАЕТСЯ
        ;============================================
        xor ax, ax
        push ax                                                 ;0 - от начала файла, 1 - от текущего положения,
                                                                                ;       2 - от конца файла
        push ax                    ;сегмент в файле
        push ax                    ;offset in file
        push $My_@Hahdl   ;handle of file
        call cl_fseek                                   ;ставлю указатель на начало файла
        add sp, 8

%Find_Empty:    push ds
        push offset $FCB
        push 8
        push $My_@Hahdl                         ;читаю FCB в память
        call cl_fread
        add sp, 8
        cmp ax, 8
        je  %qqq                                                        ;при ошибке при записи перехожу на конец
        jmp $$$aa1

%qqq:   cmp [$FCB], 'Z'                         ;последний блок?
        jne %%Continu              ;если да, то переход
        jmp %End_File
%%Continu:      cmp byte ptr [$FCB+1], 1                                ;занято?
        jne %No_Using                                   ;если свободен то переход

%Find_Empty__:  push 1
        push 0
        push word ptr [$FCB+6]
        push $My_@Hahdl
        call cl_fseek                                   ;ставлю указатель на начало следующего FCB
        add sp, 8
        jmp short %Find_Empty

%No_Using:      mov ax, $Tmp            ;проверяю длину блока (in byte)
        cmp word ptr [$FCB+6], ax
        jb      %Find_Empty__           ;если найденный блок меньше - ищу следующий
                                                                                ;иначе - резервирую найденный блок:

; НАЙДЕН СВОБОДНЫЙ БЛОК НЕ МЕНЬШЕЙ ДЛИННЫ--------------------------------------
        mov byte ptr [$FCB+1], 1        ;признак занятого

        push 1
        push -1
        push -8
        push $My_@Hahdl
        call cl_fseek                                   ;ставлю указатель на начало текущего FCB
        add sp, 8

        push ds
        push offset $FCB
        push 8
        push $My_@Hahdl
        call cl_fwrite                                  ;пишу новый FCB вместо старого
        add sp, 8
        cmp ax, 8
        je %%qqq                                                        ;при ошибке при записи перехожу на конец
        jmp $$$aa1

%%qqq:  mov ax, word ptr [$FCB+4]               ;иначе - возвращаю Handle найденного блока
        mov dx, word ptr [$FCB+2]
;       xor ax, 1000000000000000b               ;ставлю признак работы с файлом
        ret     ;КОНЕЦ ДЛЯ НАЙДЕННОГО БЛОКА НЕ МЕНЬШЕЙ ДЛИННЫ------------------------

;НЕТ ПОДХОДЯЩЕГО БЛОКА - ИЗМЕНЯЮ ПОСЛЕДНИЙ====================================

%End_File:
        mov ax, $Tmp                                    ;получаю запрошенуую длинну блока (in byte)
        mov word ptr [$FCB+6], ax       ;пишу в FCB блинну блока (in byte)
        mov [$Tmp+4], ax
        mov byte ptr [$FCB], 'M'   ;ставлю признак непоследнего
        mov byte ptr [$FCB+1], 1        ;признак занятого

        xor word ptr [$FCB+4], 1000000000000000b        ;ставлю признак работы с файлом ?

        push 1
        push -1
        push -8
        push $My_@Hahdl
        call cl_fseek                                   ;ставлю указатель на начало нового FCB
        add sp, 8

        push ds
        push offset $FCB
        push 8
        push $My_@Hahdl
        call cl_fwrite                                  ;пишу новый FCB вместо старого
        add sp, 8
        cmp ax, 8
        jne $$$aa1                                              ;при ошибке при записи перехожу на конец

        push 1
        push 0
        push $Tmp
        push $My_@Hahdl
        call cl_fseek                                   ;резервирую место в файле
        add sp, 8

        mov ax, word ptr [$FCB+4]       ;save Handle найденного блока
        mov dx, word ptr [$FCB+2]
        mov $Tmp, dx
        mov [$Tmp+2], ax

        mov byte ptr [$FCB], 'Z'        ;формирую новый последний FCB
        mov ax, [$Tmp+4]                                ;длинна запрощенного блока
        add ax, 8                                               ;длинна FCB
        add word ptr [$FCB+2], ax       ;формирую смещение
        adc word ptr [$FCB+4], 0
        mov word ptr [$FCB+6], 0
        mov byte ptr [$FCB+1], 0

        push ds
        push offset $FCB
        push 8
        push $My_@Hahdl
        call cl_fwrite                                  ;пишу новый последний FCB
        add sp, 8
        cmp ax, 8
        jne $$$aa1                                              ;при ошибке при записи перехожу на конец

        mov dx, [$Tmp+2]
        mov ax, $Tmp
        ret

$$$aa1:  mov _EMS_Error, 4
        xor ax, ax
        ret
Alloc_of_File   ENDP

;------------------------------------------------------------------------------

Alloc_of_Ems    PROC
        mov ah,09h
        call DWORD PTR _XMS_BX      ;allocate extended memory in K
        cmp ax,0001h
        jne Free_memory
        mov ax,dx
        jmp short zzzz3
Free_memory:   xor ax, ax
        mov byte ptr _EMS_Error, bl
zzzz3:  ret
Alloc_of_Ems    ENDP

;------------------------------------------------------------------------------

        PUBLIC   _EMS_Alloc
_EMS_Alloc  PROC

        arg Count:word
        push    bp
        mov     bp,sp

		  cmp _DOS_KEY, 0fh
		  je $zzzz3							;if DOS is not 5.0 - goto
		  call _Get_Free_Size
        cmp ax, [Count]
        jb $zzzz3
        mov dx,[Count]
        call Alloc_of_Ems
        xor dx, dx
        pop      bp                     ;restore C's standard data seg
        RET

$zzzz3: mov ax, [Count]
        mov [$Tmp+2], ax                ;сохраняю количество килобайт
        call Kb_To_Byte                 ;перевожу килобайты в байты
        mov $Tmp, ax                    ;сохраняю длунну блока в байтах
        call Alloc_of_File
        pop bp
        RET
_EMS_Alloc  ENDP

;------------------------------------------------------------------------------

        PUBLIC   _EMS_Realloc
_EMS_Realloc   PROC

        arg     Handle:dword, Bytes:word
        push    bp
        mov     bp,sp

        mov dx,word ptr [Handle]
        mov bx, [Bytes]
        mov ah, 0fh
        call DWORD PTR _XMS_BX        ;Realloc extended memory block
        cmp ax, 0001h
        je zzzz9
        mov al, bl
        jmp short zzzz10
zzzz9:   xor ax, ax
zzzz10:   pop      bp            ;restore C's standard data seg
        RET
_EMS_Realloc    Endp

;------------------------------------------------------------------------------


        PUBLIC _EMS_Free
_EMS_Free   PROC

        arg     Handle:dword
        push    bp
        mov     bp,sp

        mov ax,word ptr [Handle+2]
        and ax, 1000000000000000b
        cmp ax, 1000000000000000b
        je %Free_File

        mov dx,word ptr [Handle]
        mov ah,0ah
        call DWORD PTR _XMS_BX      ;free extended memory block
        cmp ax,0001h
        je Konec
        mov al,bl
        jmp short zzzz6

Konec:   xor ax, ax
        jmp short zzzz6

%Free_File:     xor word ptr [Handle+2], 8000h
        mov ax, word ptr [Handle]
        mov $Tmp, ax
        mov ax, word ptr [Handle+2]
        mov [$Tmp+2], ax
        call File_Free

zzzz6:  pop      bp
        RET
_EMS_Free  ENDP


;------------------------------------------------------------------------------


        PUBLIC   _Send_To_Ext
_Send_To_Ext   proc

        arg     Handle:dword, Arrary:dword, Bytes:dword
        push    bp
        mov     bp,sp
        push    si                   ;preserve calling program's register

        mov ax, word ptr [Bytes]
        and ax, 0001h
        cmp ax, 0001h
        jne Next                    ;if [Bytes] EQU 1
        add word ptr [Bytes], 0001h

Next:   mov ax, word ptr [Handle+2]
        and ax, 1000000000000000b
        cmp ax, 1000000000000000b               ;в handle есть признак работы с файлом?
        je  %zzz                      				;если да - то переход

        mov ax, word ptr [Bytes]
        mov word ptr _EMM_Struct, ax
        mov ax, word ptr [Bytes + 2]
        mov word ptr [_EMM_Struct +2], ax
        mov word ptr [_EMM_Struct+4], 0000h
        mov ax, word ptr [Arrary+2]
        mov word ptr [_EMM_Struct+8], Ax
        mov ax, word ptr [Arrary]
        mov word ptr [_EMM_Struct+6], Ax
        mov ax, word ptr [Handle]
        mov word ptr [_EMM_Struct+0ah], ax
        mov word ptr [_EMM_Struct+0ch], 0000h
        mov word ptr [_EMM_Struct+0Eh], 0000h

        mov ah,0bh
        lea si, _EMM_Struct
        call DWORD PTR _XMS_BX      ;move to extended memory block
        cmp ax,0001h
        je No_Error_Move
        mov al, bl
        jmp short zzzz7

%zzz:   xor word ptr [Handle+2], 1000000000000000b      ;сбрасываю признак работы с файлом для работы
        call Send_to_File
        pop si
        pop bp
        ret

No_Error_Move: xor ax, ax

zzzz7:  pop      si            ;restore C's standard data seg
        pop      bp

        RET
_Send_To_Ext   ENDP

;------------------------------------------------------------------------------

        PUBLIC   _Send_To_Mem
_Send_To_Mem   proc

        arg     Handle:dword, Arrary:dword, Bytes:dword
        push    bp
        mov     bp,sp
        push    si                      ;preserve calling program's register

        mov ax, word ptr [Bytes]
        and ax, 0001h
        cmp ax, 0001h
        jne Next1                       ;if [Bytes] EQU 1
        add word ptr [Bytes], 0001h

Next1:  mov ax, word ptr [Handle+2]
        and ax, 1000000000000000b
        cmp ax, 1000000000000000b               ;в handle есть признак работы с файлом?
        je  %%zzz                     ;если да - то переход

        mov ax, word ptr [Bytes]
        mov word ptr _EMM_Struct, ax
        mov ax, word ptr [Bytes+2]
        mov word ptr [_EMM_Struct+2], ax
        mov ax,word ptr [Handle]
        mov word ptr [_EMM_Struct+4], ax
        mov word ptr [_EMM_Struct+6], 0000h
        mov word ptr [_EMM_Struct+8], 0000h
        mov word ptr [_EMM_Struct+0ah], 0000h
        mov ax, word ptr [Arrary+2]
        mov word ptr [_EMM_Struct+0Eh], ax
        mov ax, word ptr [Arrary]
        mov word ptr [_EMM_Struct+0Ch], ax

        mov ah,0bh
        lea si, _EMM_Struct
        call DWORD PTR _XMS_BX      ;move from extended memory to block
        cmp ax,0001h
        je NoErrorMove
        mov al,bl
        jmp short zzzz8

%%zzz:  xor word ptr [Handle+2], 1000000000000000b      ;сбрасываю признак работы в переменной встеке
        call Send_from_File
        pop si
        pop bp
        ret

NoErrorMove:   xor ax, ax
zzzz8:   pop      si            ;restore C's standard data seg
        pop      bp

        RET
_Send_To_Mem    Endp

;------------------------------------------------------------------------------

        PUBLIC   _Get_Handle_Info
_Get_Handle_Info   PROC

        arg     Handle:dword
        push    bp
        mov     bp,sp

        mov dx,word ptr [Handle]
        mov ah,0eh
        call DWORD PTR _XMS_BX
        cmp ax, 0001h
        je zzzz11
        mov al, bl
        jmp short zzzz12
zzzz11:   mov byte ptr _Block_Lock_Count, bh
        mov byte ptr _Num_Free_Hand_Left, bl
        mov word ptr _Block_Size, dx
        xor ax,ax
zzzz12:   pop      bp            ;restore C's standard data seg
        RET
_Get_Handle_Info    Endp

;------------------------------------------------------------------------------

        PUBLIC   _Get_XMS_Ver
_Get_XMS_Ver   PROC

        mov ah, 00h
        call DWORD PTR _XMS_BX
        mov word ptr _Internal_Rever, bx
        mov word ptr _HMA_Exist, dx

        RET
_Get_XMS_Ver    Endp

;------------------------------------------------------------------------------

        PUBLIC _EMS_Open
_EMS_Open PROC
        call _Check_Dos         ;проверка на MS DOS 5.0
        call _Check_XMS
        cmp ax,0000h
        jne ___end
        call _Enable_A20
        cmp ax,0000h
        jne ___end
        call Open_File
___end: ret
_EMS_Open       ENDP

;------------------------------------------------------------------------------
@curseg    ENDS


        .DATA
        PUBLIC   _EMS_Error
        PUBLIC   _Flag_A20
        PUBLIC   _Total_EXT
        PUBLIC   _Block_Lock_Count
        PUBLIC   _Num_Free_Hand_Left
        PUBLIC   _Block_Size
        PUBLIC   _Internal_Rever
        PUBLIC   _HMA_Exist
        PUBLIC   _EMM_Struct
        PUBLIC  _Addres_Line
_Addres_Line    DW (?)
Addres_Line     DW (?)
DB '(Library of functions of using EMS memory'
DB 'Copyright (c), 1992-93 By Maxim L.K.'
DB 'Release 2.7)'
_XMS_BX         DW (?)
_XMS_ES         DW (?)
_EMS_Error      DB 0h
_Flag_A20       DW 0ffffh
_DOS_KEY			 DB 0h
_Total_EXT      DW (?)
_EMM_Struct     DD (?)          ;number of byte to move (must be even)
                        DW (?)          ;source handle
                        DD (?)          ;offset into source block
                        DW (?)          ;destination handle
                        DD (?)          ;offset into destination block
$FCB    DB 'Z'                  ;File Control Block: признак последнего блока
                DB 0h                                           ;флаг занятости
                DD 0008h                                        ;Handle владельца
                DW 0h                ;длинна блока (in byte)
_Block_Lock_Count    DB (?)
_Num_Free_Hand_Left  DB (?)
_Block_Size          DW (?)
_Internal_Rever      DW (?)
_HMA_Exist           DW (?)
$File_&Name          DB '(▒▒)(╫╫).&&&'
                     DB 0h
$My_@Hahdl      DW (?)
$Tmp            DW (?)
                DW (?)
                DW (?)
@curseg    ENDS

        END
