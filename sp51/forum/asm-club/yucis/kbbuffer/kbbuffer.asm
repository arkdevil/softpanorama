;------------------------------------------------------------------
;	 KBBUFFER.CTL * Michael J.Mefford
;------------------------------------------------------------------
BIOS_DATA	SEGMENT	AT	40H

		ORG	1AH

BUFFER_HEAD	DW	?
BUFFER_TAIL	DW	?

		ORG	80H

BUFFER_START	DW	?
BUFFER_END	DW	?
BIOS_DATA	ENDS

_TEXT		SEGMENT	PUBLIC 'CODE'
		ASSUME	CS:_TEXT, DS:_TEXT, ES:_TEXT, SS:_TEXT

		ORG	0H
;COPYRIGHT	DB	"KBBUFFER.CTL 1.0 (c) 1990 ",CR,LF
;PROGRAMMER	DB	"Michael J. Mefford",CR,LF,CTRL_Z

;		DEVICE_HEADER

POINTER		DD	-1
ATTRIBUTE	DW	1000000000000000B
DEVICE_STRAG	DW	STRATEGY
DEVICE_INT	DW	INTERRUPT
DEVICE_NAME	DB	"BUFFERCTL"


CR		EQU	13
LF		EQU	10
CTRL_Z		EQU	26
SPACE		EQU	32
BOX		EQU	254

;------------------;

REQUEST_HEADER	STRUC

HEADER_LENGTH	DB	?
UNIT_CODE	DB	?
COMMAND_CODE	DB	?
STATUS		DW	?
RESERVED	DQ	?

REQUEST_HEADER	ENDS

DONE		EQU	0000000100000000B	;Коды состояния.
UNKNOWN		EQU	1000000000000011B

;-------------------;

INIT		STRUC

HEADER		DB	(TYPE REQUEST_HEADER) DUP(?)
UNITS		DB	?
ENDING_OFFSET	DW	?
ENDING_SEGMENT	DW	?
ARGUMENTS_OFF	DW	?
ARGUMENTS_SEG	DW	?

INIT		ENDS

REQUEST_OFFSET	DW	?
REQUEST_SEG	DW	?

;	CODE AREA

;-----------------------------------------------------------
;      STRATEGY - Сохранение указателя на новое начало
;-----------------------------------------------------------

STRATEGY	PROC	FAR

 MOV	CS:REQUEST_OFFSET,BX
 MOV	CS:REQUEST_SEG,ES
 RETF

STRATEGY	ENDP

;-------------------------------------------------------
;        INTERRUPT
;---------------------------------------------------------

INTERRUPT	PROC	FAR

 PUSH	AX
 PUSH	BX
 PUSH	CX
 PUSH	DX
 PUSH	DS
 PUSHF

 MOV	DS,CS:REQUEST_SEG	;Выборка указателя начала
 MOV	BX,CS:REQUEST_OFFSET

 OR	STATUS[BX],DONE		;сообщить DOS, что все сделано
 CMP	COMMAND_CODE[BX],0	;это команда INIT?
 JZ	MAKE_STACK		;да, продолжить
 OR	STATUS[BX],UNKNOWN	;иначе выйти
 JMP	SHORT UNKNOWN_EXIT	;и сообщить DOS

MAKE_STACK:
 MOV	CX,SS			;Сохранить DOS стек
 MOV	DX,SP
 MOV	AX,CS
 CLI
 MOV	SS,AX			;Создать новый стек
 MOV	SP,0FFFEH
 STI
 PUSH	CX			;Сохранить стиарые указатели
 PUSH	DX

 PUSH	ES
 PUSH	SI
 PUSH	BP

 CALL	INITIALIZE

 POP	BP
 POP	SI
 POP	ES

 POP	DX
 POP	CX
 CLI
 MOV	SS,CX
 MOV	SP,DX
 STI
UNKNOWN_EXIT:
 POPF
 POP	DS
 POP	DX
 POP	CX
 POP	BX
 POP	AX
 RETF
INTERRUPT	ENDP
KBBUFFER_CTL_END	LABEL	WORD
;***************  КОНЕЦ РЕЗИДЕНТНОЙ ЧАСТИ  **************

BUFFER_DEFAULT	EQU	80
BUFFER_MIN	EQU	16
BUFFER_MAX	EQU	200
HEADING		LABEL	BYTE
		DB	"KBBUFFER.CTL 1.0 (c) 1990 "
		DB	"Michael J. Mefford",CR,LF,"$"
INSTALLED_MSG	LABEL	BYTE
		DB	"Installed",CR,LF,LF
		DB	"Syntax: DEVICE = KBBUFFER.CTL [buffer size]",CR,LF
		DB	"buffer size = 16 - 200", CR,LF
		DB	"default = 80",CR,LF,LF,'$'
OUT_OF_RANGE_MSG LABEL	BYTE
		DB	"KBBUFFER.CTL is loaded greater than "
		DB	"64K from BIOS data area",CR,LF
		DB	"KBBUFFER is inactive",CR,LF
		DB	"Make sure KBBUFFER is first in SONFIG.SYS",CR,LF,LF,'$'

			;**************;
			; ПОДПРОГРАММЫ ;
			;**************;

;----------------------------------------------
;         Input: DS:BX-> requested start
;	Destroys contents of all regs
;--------------------------
INITIALIZE	PROC	NEAR
 PUSH	DS
 POP	ES
 MOV	ENDING_OFFSET[BX],OFFSET KBBUFFER_CTL_END
 MOV	ENDING_SEGMENT[BX],CS
 MOV	CX,ARGUMENTS_SEG[BX]
 MOV	SI,ARGUMENTS_OFF[BX]

 PUSH	CS
 POP	DS
 MOV	DX,OFFSET HEADING
 CALL	PRINT_STRING

 MOV	DS,CX
 CLD

;-------------------------------------
;	Просмотр второго параметра
;--------------------------------------

FIND_PARA:
 LODSB
 CMP	AL,SPACE
 JA	FIND_PARA

 DEC	SI
 XOR	BP,BP
NEXT_NUMBER:
 LODSB
 CMP	AL,CR
 JZ	CK_PARA
 CMP	AL,LF
 JZ	CK_PARA
 SUB	AL,"0"
 JC	NEXT_NUMBER
 CMP	AL,9
 JA	NEXT_NUMBER
 CBW
 XCHG	AX,BP
 MOV	CX,10
 MUL	CX
 ADD	BP,AX
 JMP	SHORT NEXT_NUMBER

;--------------------------------------
;	Check max & min parameter bounds
;--------------------------------------

CK_PARA:
 CMP	BP,BUFFER_MIN
 JA	CK_MAX
 MOV	BP,BUFFER_DEFAULT
CK_MAX:
 CMP	BP,BUFFER_MAX
 JBE	CK_SEGMENT
 MOV	BP,BUFFER_MAX

;-----------------------------------
;	Попадает ли в 64K ? Да - изм.указ.буф. , нет - выход
;-----------------------------------

CK_SEGMENT:
 INC	BP
 SHL	BP,1
 MOV	DX,OFFSET OUT_OF_RANGE_MSG
 MOV	AX,CS
 SUB	AX,SEG BIOS_DATA
 MOV	CX,4
PARA_TO_BYTES:
 SHL	AX,1
 JC	INIT_END
 LOOP	PARA_TO_BYTES
 ADD	AX,OFFSET KBBUFFER_CTL_END
 JC	INIT_END
 MOV	CX,AX
 ADD	CX,BP
 JC	INIT_END

IN_RANGE:
 ADD	ES:ENDING_OFFSET[BX],BP
 ASSUME	DS:BIOS_DATA
 MOV	DX,SEG BIOS_DATA
 MOV	DS,DX

 CLI
 MOV	BUFFER_HEAD,AX
 MOV	BUFFER_TAIL,AX
 MOV	BUFFER_START,AX
 MOV	BUFFER_END,CX
 STI

 MOV	DX,OFFSET INSTALLED_MSG

INIT_END:
 PUSH	CS
 POP	DS
 CALL	PRINT_STRING
 RET

INITIALIZE	ENDP

;----------------------;

PRINT_STRING:
 MOV	AH,9
 INT	21H
 RET

_TEXT	ENDS
	END
