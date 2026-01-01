
        ideal
        P286
        model  tiny

CR              equ     0Dh
LF              equ     0Ah

ColorVideoSeg   equ     0B800h              ; видеосегмент цветного режима
MonoVideoSeg    equ     0B000h              ; видеосегмент монохромного режима
ShiftStatus     equ     [byte es:0417h]     ; shift-статус клавиатуры
VideoMode       equ     [byte es:0449h]     ; номер текущего видеорежима
VideoCols       equ     [word es:044Ah]     ; длина строки экрана в символах 
VideoStart      equ     [word es:044Eh]     ; смещение начала тек. видеостр.
                                            ;
HotKey          equ     58h                 ; скан-код 'горячей клавиши' (F12)        
                                            ;
CtrlPressed     equ     04h                 ; нажата одна из клавиш Ctrl
AltPressed      equ     08h                 ; нажата одна из клавиш Alt
                                            ;
MultiplexNumber equ     0E1h                ; мультиплексный номер процесса
                                            ;
SetVerify       equ     2Eh                 ; ф-ция DOS Set/Reset Verify Mode
                                            ;
NormalColor     equ     0Bh                 ; обычный цвет таймера
VerifyColor     equ     0Ch                 ; цвет таймера при Verify ON
                                            ;
                                            ; внутренние флаги задачи :  
record  Flags   Allowed:1=1,\               ; 1 - отображение разрешено
                VerReq :1=0,\               ; 1 - есть запрос на Verify
                VisReq :1=0,\               ; 1 - есть запрос на отображение
                Timer  :1=0,\               ; 1 - активен обработчик таймера
                Verify :1=0,\               ; 1 - VERIFY = ON,
                dummy  :3                   ; выравнивание

macro   Print_Msg   msg                     ; Макрос печати сообщения
        mov     dx, offset msg              ;
        mov     ah, 09h                     ;
        int     21h                         ;
endm    Print_Msg                           ;
                                            

macro   BCD_To_ASCII    reg8, dst           ; Макрос преобразования  
        mov     al, reg8                    ; BCD в ASCII
        cbw                                 ;
        ror     ax, 4                       ;
        shr     ah, 4                       ;
        add     ax, '00'                    ;
        mov     dst, ax                     ;
endm    BCD_To_ASCII                        ;


macro   Change_Vector   vector              ; Макрос перехвата         
        mov     ax, 35&vector               ; вектора прерывания
        int     21h                         ;
        mov     [word Old&vector], bx       ;
        mov     [word Old&vector+2], es     ;
        mov     ax, 25&vector               ;
        mov     dx, offset New&vector       ;
        int     21h                         ;
endm    Change_Vector                       ;


        codeseg
        org 100h                            ; смещение для COM-файла
init:
        jmp start

CurSecond   db      0FFh                    ; текущая секунда
TimeColor   db      NormalColor             ; цвет таймера
DosFlags    dd      ?                       ; адрес флагов InDOS и DOSCritical
OurFlags    Flags   <>                      ; внутренние флаги задачи


Hrs         dw      ?                       ; 
            db      ':'                     ;
Min         dw      ?                       ;
            db      ':'                     ;
Sec         dw      ?                       ;

                                             
;============================================================================
; Процедура переключения режима верификации DOS
;============================================================================
proc    toggle_verify   near                ;
        and     [cs:OurFlags], not mask VerReq ; сбросить флаг запроса
        push    ax                          ; сохранить AX
        mov     ax, SetVerify shl 8         ; AX = 2E00h
        test    [cs:OurFlags], mask Verify  ; режим верификации был включен ?
        jnz     @@continue                  ; да - выключить верификацию
        inc     al                          ; нет - включить верификацию
@@continue:                                 ;
        int     21h                         ;
        pop     ax                          ; восстановить AX
        ret                                 ;
endp    toggle_verify                       ;


;============================================================================
; Обработчик мультиплексного прерывания DOS
;============================================================================
proc    New2Fh  far                         ;
        sti                                 ; разрешить прерывания
        cmp     ah, MultiplexNumber         ; запрос нашего мультиплексного номера ?
        jne     @@chain                     ; нет - отдать управление
        mov     al, 0FFh                    ; да - вернуть код занятости 
        iret                                ; мультиплексного номера процесса
@@chain:                                    ;
        db      0EAh                        ; первый байт инструкции jmp far
Old2Fh  dd      ?                           ; адрес старого обработчика INT 2Fh
endp    New2Fh                              ;
                                             

;============================================================================
; Обработчик прерывания DOS Idle
;============================================================================
proc    New28h  far                         ;
        sti                                 ; разрешить прерывания
        test    [cs:OurFlags], mask VerReq ; есть запрос на изменение режима верификации ?
        jz      @@chain                     ; нет - отдать управление
        call    toggle_verify               ; да - переключить режим верификации
@@chain:                                    ;
        db      0EAh                        ; первый байт инструкции jmp far
Old28h  dd      ?                           ; адрес старого обработчика INT 28h
endp    New28h                              ;
                                            
                                            
;============================================================================
; Обработчик диспетчера функций DOS
;============================================================================
proc    New21h  far                         ;
        pushf                               ; сохранить флаги
        cmp     ah, SetVerify               ; запрос на изменение режима верификации ?
        jne     @@chain                     ; нет - отдать управление
        or      al, al                      ; AL == 0 ?
        jnz     @@set_verify                ; нет - установить Verify ON
        mov     [cs:TimeColor], NormalColor ; да - изменить цвет таймера на обычный
        and     [cs:OurFlags], not mask Verify ; сбросить бит верификации в байте флагов задачи
        jmp     short @@chain               ; отдать управление по цепочке...
@@set_verify:                               ; установить Verify = ON
        mov     [cs:TimeColor], VerifyColor ; установить альтернативный цвет таймера
        or      [cs:OurFlags], mask Verify  ; установить бит верификации в байте флагов задачи
@@chain:                                    ;
        popf                                ; восстановить флаги
        db      0EAh                        ; первый байт инструкции jmp far
Old21h  dd      ?                           ; адрес старого обработчика INT 21h
endp    New21h                              ;
                                            
                                            
;============================================================================
; Обработчик прерывания клавиатуры
;============================================================================
proc    New09h  far                         ;
        push    ax                          ; сохранить AX
        in      al, 60h                     ; получить скан-код клавиши
        cmp     al, HotKey                  ; нажат 'горячий ключ' ?
        jne     @@chain                     ; нет - отдать управление
        push    es 0                        ; да - сохранить ES
        pop     es                          ; ES = 0
        test    ShiftStatus, AltPressed     ; нажата ли клавиша Alt ?
        jz      @@continue                  ; нет 
        or      [cs:OurFlags], mask VisReq  ; да - взвести флаг запроса на     
                                            ; изменение режима отображения    
@@continue:                                 ;
        test    ShiftStatus, CtrlPressed    ; нажата ли клавиша Ctrl ?
        pop     es                          ; восстановить ES
        jz      @@chain                     ; нет
        or      [cs:OurFlags], mask VerReq  ; да - взвести флаг запроса на
                                            ; изменение режима верификации DOS
@@chain:                                    ;
        pop     ax                          ; восстановить AX
        db      0EAh                        ; первый байт инструкции jmp far
Old09h  dd      ?                           ; адрес старого обработчика INT 09h
endp    New09h                              ;
                                            
                                            
;============================================================================
; Обработчик прерывания таймера
;============================================================================
proc    New08h  far                         ;
        pushf                               ; сохранить флаги
        db      9Ah                         ; первый байт инструкции call far
Old08h  dd      ?                           ; адрес старого обработчика INT 08h
        test    [cs:OurFlags], mask Timer   ; активен ли обработчик таймера ?
        jz      @@activate                  ; нет - активировать
        iret                                ; да - завершить обработку
@@activate:                                 ;
        or      [cs:OurFlags], mask Timer   ; взвести флаг активности обработчика
                                            ; таймера
        sti                                 ; разрешить прерывания
        pusha                               ; сохранить все регистры
        push    ds es                       ; включая DS и ES
        push    cs                          ; переключить DS 
        pop     ds                          ; на текущий сегмент кода
        test    [OurFlags], mask VerReq     ; есть ли запрос на изменение режима
                                            ; верификации DOS ?
        jz      @@next_step                 ; нет - продолжить                
        les     bx, [DosFlags]              ; да - ES:BX = адрес флагов 
                                            ; DOSCritical и InDOS
        cmp     [word es:bx], 0             ; хотя бы один флаг взведен ?
        jne     @@next_step                 ; да - продолжить                
        call    toggle_verify               ; нет - изменить режим верификации DOS
@@next_step:                                ;
        test    [OurFlags], mask Allowed    ; отображение времени разрешено ?
        jz      @@check_request             ; нет                      
        mov     ah, 02h                     ; получить время из микросхемы
        int     1Ah                         ; КМОП (CMOS)
        cmp     dh, [CurSecond]             ; идет текущая секунда ?
        je      @@check_request             ; да
        mov     [CurSecond], dh             ; запомнить новую текущую секунду
                                            ; преобразование времени BCD -> ASCII
        BCD_To_ASCII <ch>, <[Hrs]>          ; часы
        BCD_To_ASCII <cl>, <[Min]>          ; минуты
        BCD_To_ASCII <dh>, <[Sec]>          ; секунды
        mov     ah, [TimeColor]             ; AH = цвет для отображения времени
@@clear:                                    ;   
        xor     bx, bx                      ; 
        mov     es, bx                      ; ES = 0
        cmp     VideoMode, 3                ; это видеорежим 0..3 ? 
        ja      @@mono                      ; нет - может монохромный ?
        mov     bx, ColorVideoSeg           ; да - AX = видеосегмент
        jmp     short @@time                ; продолжить...
@@mono:                                     ;
        cmp     VideoMode, 7                ; это монохромный режим ?
        jne     @@check_request             ; нет - завершить обработку
        mov     bx, MonoVideoSeg            ; иначе AX = видеосегмент
@@time:                                     ;
        mov     si, offset Sec + 1          ; SI = последний байт строки времени
        mov     di, VideoStart              ; DI = смещение тек. видеостраницы
        mov     dx, VideoCols               ; DX = длина строки экрана в символах
        dec     dx                          ;
        shl     dx, 1                       ; DX = количество байт в видеостроке
        add     di, dx                      ; DI => на последнее слово видеостроки 
        mov     es, bx                      ; ES = видеосегмент
        mov     cx, 8                       ; длина строки для отображения
        std                                 ; сбросить флаг направления
@@next:                                     ; отображение строки времени
        lodsb                               ; 
        stosw                               ; 
        loop    @@next                      ;
@@check_request:                            ; проверка запроса на видимость
        test    [OurFlags], mask VisReq     ; был ли запрос ?
        jz      @@finish                    ; нет
        and     [OurFlags], not mask VisReq ; да, сбросить флаг запроса
        xor     [OurFlags], mask Allowed    ; переключить видимость таймера
        js      @@finish                    ; если видимость включена
        xor     ah, ah                      ; иначе стереть изображение
        jmp     short @@clear               ; строки времени
@@finish:                                   ;
        pop     es ds                       ; восстановить ES и DS
        popa                                ; а также остальные регистры
        and     [cs:OurFlags], not mask Timer ; сбросить флажок активности 
                                            ; обработчика таймера
        iret                                ;
endp New08h                                 ;
                                            

start:                                      ; 
        mov     ah, MultiplexNumber         ; свободен ли требуемый 
        int     2Fh                         ; мультиплексный номер процесса ?
        cmp     al, 0FFh                    ;
        jne     not_installed               ; да - продолжить 
        Print_Msg <Already_Msg >            ; нет - вывести сообщение 
        Print_Msg <HotKeys_Msg>             ; вывести сообщение о ключах   
        int     20h                         ; завершенить программу
not_installed:                              ;
        Print_Msg <JustNow_Msg>             ; вывести сообщение о загрузке
        Print_Msg <HotKeys_Msg>             ; вывести сообщение о ключах   
        mov     es, [word 2Ch]              ; освобождение памяти,
        mov     ah, 49h                     ; занятой Environment
        int     21h                         ;
        mov     ah, 34h                     ; получить адрес флага 
        int     21h                         ; InDOS
        dec     bx                          ; и заодно флага DOSCritical
        mov     [word DosFlags], bx         ; сохранить этот адрес
        mov     [word DosFlags+2], es       ;
        mov     ah, 54h                     ; получить текущее состояние
        int     21h                         ; режима верификации DOS
        or      al, al                      ; Verify == ON ?
        jz      go_on                       ; нет - продолжать
        or      [OurFlags], mask Verify     ; да - установить соответствующий
                                            ; бит байта внутренних флагов задачи
        mov     [TimeColor], VerifyColor    ; и цвет таймера
go_on:                                      ;
        mov     ax, 0305h                   ; 'ускорить'
        xor     bx, bx                      ; клавиатуру
        int     16h                         ;
        mov     ax, cs                      ; манипуляции по пересылке
        sub     ax, 0Ah                     ; кода резидента
        mov     es, ax                      ; в неиспользуемую часть
        mov     si, 100h                    ; PSP 
        mov     di, si                      ;
        mov     cx, offset start - init     ;
        cld                                 ;
        rep     movsb                       ;
        push    es                          ;
        pop     ds                          ;
        Change_Vector   <08h>               ; переназначение векторов
        Change_Vector   <09h>               ; прерываний, перехватываемых
        Change_Vector   <28h>               ; резидентом
        Change_Vector   <21h>               ;    
        Change_Vector   <2Fh>               ;    
        mov     dx, offset start - 160      ; за счет использования PSP  
        int     27h                         ; сэкономили 160 байт

Already_Msg db  'TIMER is already loaded.', CR, LF, '$'
JustNow_Msg db  '   TIMER (C) A.V.Gura, 1993   ', CR, LF, '$'
HotKeys_Msg db  '<Alt  F12>  toggles visibility', CR, LF  
            db  '<Ctrl F12>  toggles DOS VERIFY', CR, LF, '$'
end init
