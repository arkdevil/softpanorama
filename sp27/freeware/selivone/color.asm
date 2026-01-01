CSEG SEGMENT
	org 100h
ASSUME CS:CSEG 	;DS:CSEG
START:	JMP PRINT
CLRSCR:	MOV AX,0B800H
	MOV DS,AX
	MOV BX,1000H
	MOV CX,800H
	;	MOV AH,00010111B	 BIT 0 BLUE, BIT 1 GREEN BIT 2 RED
	MOV AL,20H	;BIT 3 HIGH INTENSITY IF 1, BITS 4-5 BACKGROUND, 7 BLINK
CYCLE:	MOV [BX],AL
	SUB BX,2H
	LOOP CYCLE
	RET
COLOR:	MOV AX,0B800H
	MOV DS,AX
	MOV BX,1001H
	MOV CX,801H
	MOV AH,00010111B	; BIT 0 BLUE, BIT 1 GREEN BIT 2 RED
 MOV AL,20H	;BIT 3 HIGH INTENSITY IF 1, BITS 4-5 BACKGROUND, 7 BLINK
CYCLE_:	MOV [BX],AH
	DEC BX
	DEC BX
	LOOP CYCLE_
	RET
PRINT:	CALL CLRSCR
	MOV AX,CS
	MOV DS,AX
	MOV DX,OFFSET R1
	MOV AH,09H
	INT 21H
	CALL COLOR
WAIT_:	MOV AH,00H
	INT 16H
	MOV BX,AX
	CMP AL,'0'
	JB WAIT_
	CMP AL,';'
	JA WAIT_
	CMP AL,'7'
	JA PASS
EXIT:	MOV AX,BX
	SUB AL,'0'
	MOV AH,4CH
	INT 21H
PASS:	MOV AH,00H
	INT 16H
	CMP AL,'d'
	JZ WELL
	CMP AL,'D'
	JNZ WAIT_
WELL:	MOV AH,00H
	INT 16H
	CMP AL,'O'
	JZ EXIT
	CMP AL,'o'
	JNZ WAIT_
	JMP EXIT
;R1 DB 0AH,0DH,0ADH,0AH,0DH,0AH,0DH
R1 DB 0AH,0DH
DB '                     ВЫХОД                     0',0dh,0ah,0dh,0ah
DB '                     Norton -> whole pack      1',0dh,0ah,0dh,0ah
DB '                     Заpплата из turbo         2',0dH,0aH,0dH,0aH
DB '                     Macro Assembler -> old nc 3',0dH,0aH,0dH,0aH
DB '                     Turbo C compiler          4',0DH,0AH,0dH,0aH
DB '                     Help non-resident         5',0dH,0aH,0dH,0aH
DB '                     Зapплата пpямой запуск    6',0dH,0aH,0dH,0aH
DB '                     Стат.талоны               7',0dh,0ah,0dH,0aH
DB '                     Circuit races             8',0DH,0AH,0dH,0aH
DB '                     Investigator              9',0DH,0AH,0dH,0aH
DB '                     Accolade rocky way        :',0DH,0AH,0dH,0aH
DB '                     Aerial mission            ;',0dh,0ah,24H
CSEG ENDS
END START
