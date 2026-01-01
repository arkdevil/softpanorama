;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                               @
;@                  Всякие дисковые мелочи                       @
;@                                                               @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	.Model	Small

;
; ===== Disks, Version 1.0, Copyright (C) 1991 by Tony Berezin
;
; ===== Меня можно найти:
;
;        320038, г. Днепропетровск, ул. Привокзальная 3/38
;
;        Антон Березин
;
;        Дом. тел. 50-40-84
;        Раб. тел. 46-21-94
;

;
; ===== Списки импорта
;
        EXTW    DATASEG, DOSVERSION, MCBSEG, MCBOFFS
	EXTP	SAVREGS, STDRET

;
; ===== Экспортируется :
;
        PUBLIC  D$DRVLIST, D$DRVINFO, D$DRVNUM

;
; ===== Переменные модуля
;
	.Data
D$DRVNUM        DB      ?           ;* Число логич. дисков в системе
D$DRVLIST       DB      27 DUP (?)  ;* Их побуквеный список

;
; ===== Процедуры модуля
;
	.Code
;
;--- Заполнить D$DrvNum и D$DrvList
D$DRVINFO       PROC
	CALL	SAVREGS
;
        XOR     DX,     DX
        MOV     DS,     CS:DATASEG
        ASSUME  DS: _DATA
        MOV     AX,     DOSVERSION
        CMP     AL,     3
        JNE     DI1
        MOV     DX,     81         ; Если третья версия, то длина
                                   ;  элемента массива дисковой информации 81
DI1:
        CMP     AL,     4
        JNE     DI2
        MOV     DX,     88         ; А если четвертая, то 88
DI2:
        MOV     ES,     MCBSEG
        MOV     BX,     MCBOFFS    ; Векторная таблица связи ДОС
        MOV     SI,     ES:[BX+22]
        MOV     DS,     ES:[BX+24] ; Массив дисковой информации
        MOV     CL,     ES:[BX+33] ; LASTDRIVE из CONFIG.SYS
        XOR     CH,     CH
        CLD
        XOR     AX,     AX
        MOV     ES,     AX
	XOR	BL,	BL
        CMP     BYTE PTR ES:[504H], 1 ; Фантомный флопик ?
	JNZ	DDDD1
	INC	BL
DDDD1:
        MOV     ES,     CS:DATASEG
        ASSUME  ES: _DATA
        LEA     DI,     D$DRVLIST
        XOR     BH,     BH
        INT     11H
        TEST    AL,     1
        JZ      NOSKIP
        TEST    AL,     0CH
        JNZ     NOSKIP
        ADD     BH,     'B'        ; Случай с единственным флопиком
	SUB	BH,	BL
NOSKIP:
        MOV     AL,     'A'
        XOR     BL,     BL
CICL:
        CMP     WORD PTR [SI+71],  0 ; Диск используется ?
        JNE     WORK
        CMP     WORD PTR [SI+69],  0 ; Точно не используется ?
        JE      SKIP
WORK:
        CMP     AL,     BH
        JE      SKIP
        STOSB
        INC     BL
SKIP:
        INC     AL
        ADD     SI,     DX
        LOOP    CICL
        XOR     AL,     AL
        STOSB
        MOV     ES:D$DRVNUM,          BL
;
	CALL	STDRET
D$DRVINFO       ENDP
;
END
