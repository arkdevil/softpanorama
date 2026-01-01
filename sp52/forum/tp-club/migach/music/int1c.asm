
;-------------------------------------------
; Подпрограмма низкоуровневого обработчика
; прерывания Int 1c для пакета фоновой
; музыки  Music V 1.0
;
;  (c)  1990, Мигач Ярослав
;-------------------------------------------

                EXTRN   tact : WORD ; содержит текущий такт       
                                    ; исполняемой в данный момент 
                                    ; времени мелодии             

                EXTRN   tic : WORD  ; содержит количество тиков
                                    ; по 55 мс, которые осталос
                                    ; отсчитать до переключения
                                    ; следующего такта мелодии 

                EXTRN   ton : DWORD ; указатель на массив
                                    ; тона звучания

                EXTRN   del : DWORD ; указатель на массив
                                    ; длительности звучания

                EXTRN   ptic : DWORD ; указатель на переменную
                                     ; tic

                EXTRN   ptact : DWORD ; указатель на переменную
                                      ; tact

                EXTRN   svint  : DWORD  ; вектор стандартного
                                        ; обработчика ROM-BIOS
                                        ; устанавливаемый
                                        ; процедурой init_music

CODE            SEGMENT PUBLIC         ; общий сегмент кодов
                ASSUME  CS : CODE      ; с модулем на
                                       ; турбопаскале

svds            DW      ?              ; содержит значение
                                       ; указателя сегмента DS

HZ              DW      ?              ; вспомогательная переменная
                                       ; определяющая длительность
                                       ; звучания

newint  PROC            FAR            ; заголовок процедуры
                PUBLIC  newint         ; обработчика

                ; сохранение регистров

                PUSHF
                PUSH    AX
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
                PUSH    DI
                PUSH    DS
                PUSH    ES
                PUSH    BP

                MOV     AX,svds
                MOV     DS,AX
                LDS     BX,ptic
                MOV     AX, [ BX ]
                DEC     AX
                MOV     [ BX ],AX
                CMP     AX,0
                JNZ     QUIT

                ; вызов фоновой программы

                CALL    ANALIZ
                LDS     BX,ptact
                MOV     AX, [ BX ]
                INC     AX
                MOV     [ BX ], AX

QUIT:           MOV     AL,20h         ; обработка конца прерывания
                OUT     20h,AL         ; микросхемы 8259

                ; восстановление регистров

                POP     BP
                POP     ES
                POP     DS
                POP     DI
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                POP     AX
                POPF

                IRET

newint  ENDP

ANALIZ  PROC    NEAR    ; Анализатор
        PUBLIC  ANALIZ

        LDS     BX,ptact
        MOV     CX,2
        MOV     AX, [ BX ]
        INC     AX
        MUL     CX
        LDS     BX,del
        ADD     BX,AX
        MOV     AX, [ BX ]
        CMP     AX,0
        JNZ     AN1
        LDS     BX,ptact
        MOV     AX, 1
        MOV     [ BX ], AX
        LDS     BX,ptic
        MOV     [ BX ], AX
        RET

AN1:    LDS     BX,ptic
        MOV     [ BX ],AX
        LDS     BX,ptact
        MOV     AX,[ BX ]
        MUL     CX
        LDS     BX,ton
        ADD     BX,AX
        MOV     AX, [ BX ]
        CMP     AX,0
        JNZ     AN2
        CALL    sd_off
        RET

AN2:    MOV     HZ,AX
        CALL    sd_on
        RET

ANALIZ  ENDP

        ;  Управление динамиком    

sd_on   PROC    NEAR  
        PUBLIC  sd_on  

;-----  Управление высотой звука динамика    

        MOV     AL, 10110110b    
        OUT     43H, AL         ; Установка режима для 2-го канала    
        MOV     AX, HZ          ; Выбор высоты звука    
        OUT     42H, AL    
        MOV     AL, AH    
        OUT     42H, AL         ; Занесение высоты звука в порт динамика    
        IN      AL, 61H    
        OR      AL, 3    
        OUT     61H, AL         ; Выбор режима управления динамикаом    
        RET

sd_on   ENDP

sd_off  PROC    NEAR
        PUBLIC  sd_off

        IN      AL, 61H
        AND     AL,0FDH    
        OUT     61H, AL         ; Выключение динамика    
        RET
            
sd_off  ENDP

inintr  PROC    NEAR            ; запомнить сегмент данных
        PUBLIC  inintr          ; для последующего использования
                                ; при входе по прерыванию

        MOV     AX,DS
        MOV     svds,AX
        RET

inintr  ENDP
    
CODE    ENDS    
        END    


