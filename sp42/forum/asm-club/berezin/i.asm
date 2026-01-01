;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@                                                               @
;@          Общий модуль. Инициализация + всякая польза          @
;@                                                               @
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	.Model	Small

;
; ===== Initial Module, Version 2.0, Copyright (C) 1991 by Tony Berezin
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
; ===== Экспортируем :
;
        Public  I$Init, SavRegs, StdRet, NullProc
        Public  DataSeg, PspSeg, DosVersion
        Public  McbSeg, McbOffs, HeapBase, MaxAvail

;
;--- Этот сегмент совершенно фиктивен. Не входите с ним в конфликт
PSPS	SEGMENT	AT	3333H
	ORG	2
PSPSEG_MAXAVAIL	DW	?
PSPS	ENDS

;
; ===== Переменные модуля (звездочкой отмечены глобальные)
;
        .DATA
FATALMESSAGE	DB	13,10,'Эта программа работает в DOS версии не ниже 3.00$'
PSPSEG          DW      ?          ;* Сегментный адрес PSP
DOSVERSION      DW      ?          ;* Версия ДОС, в которой запустились
MCBSEG          DW      ?          ;* Сегмент векторной таблицы связи ДОС
MCBOFFS         DW      ?          ;* Смещение векторной таблицы связи ДОС
HEAPBASE        DW      ?          ;* Базовый адрес доступной для использо-
                                   ;    вания и убивания памяти
MAXAVAIL        DW      ?          ;* Максимальный доступный для убивания адрес

;
; ===== Процедуры модуля + ма-а-аленькая переменная
;
        .CODE

DATASEG DW      DGROUP             ;* Сегментный адрес _DATA
; Эта странная переменная введена с благородной целью
;  ускорить загрузку программ, использующих этот модулечек
;  Вместо не очень маленькой и, что важнее, добавляющей
;  лишнюю работу по настройке при загрузке последователь-
;  ности вида MOV AX, DGROUP; MOV DS, AX
;  Вы используете просто MOV DS, CS:DataSeg.

;
;--- Осуществляет общую инициализацию любой программки
;     Если ДОС < 3.0, принудительно завершает программу с выдачей
;     приличествующего случаю ругательного сообщения
I$INIT  PROC
;---
; Input :
;	None
;       Лучше всего вызывать эту процедуру в самом начале программы
; Output :
;       DS установлен на DGROUP
;       AX Corrupted
;---
        MOV     AX,     SP
        PUSH    ES
        PUSH    BX
;
        PUSH    AX
        MOV     DS,     CS:DATASEG ; Установить DS на DGROUP
        ASSUME  DS: _DATA
        MOV     AH,     62H
        INT     21H                ; Получить адрес PSP
        MOV     ES,     BX
        MOV     PSPSEG, BX
	ASSUME	ES:PSPS
        MOV     AX,	ES:PSPSEG_MAXAVAIL ; Это максимум, что нам доступно
	MOV	MAXAVAIL,	AX
        POP     AX                 ; В AX - старый SP
	REPT	4
        SHR     AX,     1
	ENDM
        INC     AX
        INC     AX
        MOV     BX,     SS
        ADD     AX,     BX         ; В AX - первый свободный сегм. адр.
        MOV     HEAPBASE,          AX
        MOV     AH,     30H
        INT     21H
        MOV     DOSVERSION,        AX
	CMP	AL,	2
	JA	OK
	LEA	DX,	FATALMESSAGE
	MOV	AH,	9
	INT	21H
	MOV	AX,	PSPSEG
	PUSH	AX
	XOR	AX,	AX
	PUSH	AX
	DB	0CBH
OK:
        MOV     AH,     52H
        INT     21H
        MOV     MCBSEG, ES
        MOV     MCBOFFS,BX
;
        POP     BX
        POP     ES
        RET
I$INIT  ENDP
;
CALLADR	DW	?
;
SAVREGS	PROC
	PUSH	BP
	MOV	BP,	SP
	MOV	BP,	[BP+2]
	MOV	CS:CALLADR,	BP
	POP	BP
	ADD	SP,	2
	PUSH	DS
	PUSH	ES
	PUSH	SI
	PUSH	DI
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	BP
	JMP	CS:CALLADR
SAVREGS	ENDP
;
STDRET	PROC
	POP	BP
	POP	BP
	POP	DX
	POP	CX
	POP	BX
	POP	DI
	POP	SI
	POP	ES
	POP	DS
	RET
STDRET	ENDP
;
NULLPROC	PROC
	RET
NULLPROC	ENDP
;
END
