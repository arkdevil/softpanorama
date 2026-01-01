
;************************************************;
;                                                ;
;        L e c a r                               ;
;   Turbo Pascal 5.X, 6.X                        ;
;   Попросту, без чинов и Copyright-ов  1991     ;
;    Версия 1.0 от 11.11.1991 14.00.45.55        ;
;************************************************;

.MODEL TPASCAL
.CODE
        PUBLIC ANTILZ
	ASSUME CS : CODE, DS : CODE
HEADER 	 DB  020H DUP(0)
EXEIP	 DW  0				; value for IP register
RELOCS   DW  0				; segment offset of code segment
EXESP	 DW  0				; value for SP register
RELOSS	 DW  0				; segment offset of stack segment
CODE_S	 DW  0				; code size in paragraphs
OFF_S	 DW  0				; need offset in memory
PRG_S	 DW  0				; size execution code in programm
NUMREAD  DW  0                          ; number actually reading bytes
HANDLE1  DW  ?                          ; handle readeng file
HANDLE2  DW  ?                          ; handle writing file
ENPOINT  DD  0                          ; file offset on entry point
OSTATOK  DW  0
STRT_DI  DW  0				; DI до записи
STRT_ES  DW  ?
CNST	 DW  010H
MEM_FL   DB  0				; allocate memory flag
WRITE_FL DB  0				; write block flag
FLAG	 DB  0				; read word flag
NUM_B	 DW  0				; number local read byte
RELOCTI  DW  ?
RELOCNT  DW  0				; number of item in relocation table
hdrsize  dw  ?
RES      db  0
; --------------------------------------------------
BLREAD  PROC NEAR
        MOV  BX, CS:HANDLE1             ; file handle
	MOV  AH, 03FH
        jnc  @read1
        mov  cs:res, al
        jmp  Exit
@read1 :
        XOR  DX, DX                     ; DX = 0   DS:DX setup on read buffer
	INT  21H			; read buffer
        RET
ENDP BLREAD

;---------------------------------------------------
CMPREAD PROC NEAR
        CMP  SI, CS:NUMREAD		; compare with SI
        JE   @READ
	JL   @CMPARE
        JMP  @GORET
@READ :
        PUSH CX
        PUSH DX
        PUSH BX
        MOV  CX, 02000H
        CALL BLREAD                     ; else read new block
        MOV  CS:NUMREAD, AX                ;
        SUB  CS:OSTATOK, AX
        XOR  SI, SI                     ; SI=0
        POP  BX
        POP  DX
        POP  CX
	JMP  @GORET
@CMPARE :
	CMP  CS:NUM_B, 2
	JNZ  @GORET
	PUSH SI
	ADD  SI, WORD PTR CS:NUM_B
	CMP  SI, CS:NUMREAD
	JLE  @CONTIN
	MOV  CS:FLAG, 1
	POP  SI
	LODSB
	PUSH AX
        PUSH CX
        PUSH DX
        PUSH BX
        MOV  CX, 02000H
        CALL BLREAD                     ; else read new block
        MOV  CS:NUMREAD, AX
	MOV  CL, 4
	SHR  AX, CL
        SUB  CS:OSTATOK, AX
        XOR  SI, SI                     ; SI=0
        POP  BX
        POP  DX
        POP  CX
	POP  AX
        MOV  AH, DS:SI
        INC  SI
        JMP  SHORT @GORET
@CONTIN :
	MOV  CS:FLAG, 0
	POP  SI
@GORET :
        RET
ENDP CMPREAD

; -----------------------------------------------------
BLWRITE PROC NEAR
        MOV  BX, CS:HANDLE2                ; file handle
        PUSH DS                            ; save any parameters
        PUSH DX                            ;
        PUSH AX                            ;
        MOV  AX, ES
        MOV  DS, AX
        MOV  DX, WORD PTR CS:STRT_DI	;
        MOV  AX, 04000H
        INT  21H                           ; write in file
        jnc  @write
        mov  cs:res, al
        jmp  exit
@write :
        POP  AX                            ; resote savid parameters
        POP  DX
        POP  DS
        RET
ENDP BLWRITE

;-----------------------------------------------------------------------------
ANTILZ  PROC FAR
	PUSH BP
	MOV  BP, SP
	PUSH DS
	mov  word ptr cs:strt_di, 0
	mov  byte ptr cs:mem_fl, 0
	mov  byte ptr cs:write_fl, 0
	mov  byte ptr cs:flag, 0
	mov  word ptr cs:num_b, 0
	mov  word ptr cs:relocnt, 0 
	mov  word ptr cs:cnst, 10h
	MOV  AX, [BP+12]
	MOV  DS, AX
	MOV  DX, [BP+10]
	INC  DX				; DS:DX set on file name
	MOV  AX, 03D00H			; open file DS:DX
	INT  21H
	JNC  LAB_0			; if Error then exit
        mov  cs:res, al
        JMP  EXIT
LAB_0 :
	MOV  BX, AX
	MOV  CS:HANDLE1, AX		; save handle open file
	MOV  AX, CS
	MOV  DS, AX			; set DS
        MOV  ES, AX                     ; set ES
	MOV  DX, OFFSET HEADER		; DX = offset HEADER
	MOV  AH, 03FH
	MOV  CX, 020H
	INT  21H			; read header
        JNC  LAB_2
        mov  cs:res, al
	JMP  EXIT			; EXIT if Error
; ------------------- CREATE NEW FILE
LAB_2 :
	PUSH DS
        MOV  AX, [BP+8]
	MOV  DS, AX
	MOV  AX, 03C00H
        MOV  DX, [BP+6]
	INC  DX				; DS:DX set on name new file
        MOV  CX, 0
        INT  21H                         ; create new file
        JNC  CR_1
        mov  cs:res, al
        JMP  EXIT                        ; if error
CR_1 :
        MOV  CS:HANDLE2, AX              ; save new handle
	POP  DS

	MOV  BX, AX
	MOV  AX, 04000H
	MOV  CX, 01CH
	LEA  DX, HEADER
	INT  21H			; rezerv 1C BYTE

; ------------------- READ ENTRY POINT
       MOV  SI, OFFSET HEADER            ; SI setup on HEADER
       MOV  AX, [SI+8]                   ; AX = HdrSize
       MOV  WORD PTR CS:HDRSIZE, AX
       MUL  CNST
       MOV  WORD PTR ENPOINT[0], AX
       MOV  WORD PTR ENPOINT[2], DX
       MOV  AX, [SI+016H]                ; AX = ReloCS
       MUL  CNST
       ADD  WORD PTR ENPOINT[0], AX
       JNC  LABEL1
       INC  WORD PTR ENPOINT[2]
LABEL1 :
       ADD  WORD PTR ENPOINT[2], DX
       MOV  AX, [SI+014H]
       ADD  WORD PTR ENPOINT[0], AX        ; AX = ReloIP
       JNC  LABEL2
       INC  WORD PTR ENPOINT[2]
LABEL2 :

; ------------------- READ NEED PARAMETRS
	MOV  BX, HANDLE1
        MOV  CX, CS: WORD PTR ENPOINT[2]
        MOV  DX, CS: WORD PTR ENPOINT[0]
	SUB  DX, 0EH                    ; DX = offset in file on entry point
	JNC  LABEL5
	DEC  CX
LABEL5 :
	MOV  AX, 04200H
	INT  21H			; seek need offset in file
	LEA  DX, EXEIP
	MOV  CX, 14
	MOV  AH, 03FH
	INT  21H                        ; read need data from file

; ------------------------- RESTORE RELOCATION TABLE
        MOV  CX, CS: WORD PTR ENPOINT[2]
        MOV  DX, CS: WORD PTR ENPOINT[0]
        ADD  DX, 0158H
	JNC  LABEL3
	INC  CX
LABEL3 :
	SUB  DX, 0EH
	JNC  LABEL4
	DEC  CX
LABEL4 :
        MOV  AX, 04200H
        INT  21H  	                ; seek need offset in read file
        MOV  BX, WORD PTR CS:PRG_S
        SUB  BX, 0158H                  ; bx = size coding relocation
        PUSH BX
        MOV  CL, 04
        SHR  BX, CL
        INC  BX
        MOV  AX, 04800H
        INT  21H                        ; Allocate memory
        JNC  ALLOC1
        mov  cs:res, al
        JMP  EXIT                       ; go if Error
ALLOC1 :
        MOV  DS, AX                     ; set DS
        MOV  CL, 2
        SHL  BX, CL
        MOV  AX, 04800H
        INT  21H                        ; allocate memory on new relocation
        JNC  ALLOC2
        mov  cs:res, al
        JMP  EXIT
ALLOC2 :
        MOV  ES, AX                     ; set ES
        POP  CX
        MOV  AX, 03F00H
        XOR  DX, DX
        MOV  BX, CS:HANDLE1
        INT  21H                        ; read coding relocation
        JC   GODECOD
        XOR  SI, SI
        XOR  DI, DI
        XOR  BX, BX
LOC_61 :
        LODSB
        OR   AL, AL
        JZ   LOC_70
        MOV  AH, 0
LOC_72 :
        ADD  BX, AX
        MOV  AX, BX
        AND  BX, 0FH                   ; BX = i_off
        PUSH AX
        MOV  AX, BX
        STOSW
        POP  AX
        MOV  CL, 4
        SHR  AX, CL                    ;
        ADD  DX, AX                    ; dx = i_seg
        MOV  AX, DX
        STOSW
	INC  CS:RELOCNT			; determinate number relocation item
        JMP  SHORT LOC_61
LOC_70 :
        LODSW
        OR   AX, AX
        JNZ  LOC_71
        ADD  DX, 0FFFH
        JMP  SHORT LOC_61
LOC_71 :
        CMP  AX, 1
        JNE  LOC_72
GODECOD :
        PUSH DI
        ADD  DI, 1CH
        AND  DI, 0FH
        XOR  DX, DX
        SUB  DX, DI
        AND  DX, 0FH
        MOV  CX, DX
        POP  DI
        XOR  AL, AL
        REPNE STOSB
	PUSH DS
	PUSH ES
	POP  DS
        MOV  CX, DI
        MOV  BX, CS:HANDLE2
        MOV  AX, 04000H
        XOR  DX, DX
        INT  21H                                ; save new relocation
        ADD  AX, 01CH
        MOV  DX, AX                             ; save header size
        MOV  AX, 04900H
        INT  21H                                ; release memory
        POP  ES
        MOV  AX, 04900H
        INT  21H                                ; release memory

	MOV  AX, CS
	MOV  DS, AX
	MOV  ES, AX
	PUSH DX

; ------------------- RESTORE HEADER
	MOV  AX, 04200H
	XOR  CX, CX
	MOV  DX, 04H
	MOV  BX, CS:HANDLE2
	INT  21H			; set offset in result file ( 04 )
	LEA  DI, HEADER
	ADD  DI, 6
	MOV  AX, RELOCNT
	STOSW				; write ReloCnt
	POP  AX	 			; restore offset the end of header
	MOV  CL, 4
	SHR  AX, CL
	STOSW				; write HeaderSize
	XOR  AX, AX
	STOSW				; write MinMem
	DEC  AX
	STOSW				; write MaxMem
	MOV  AX, RELOSS
	STOSW				; write ReloSS
	MOV  AX, EXESP
	STOSW  				; write ExeSP
	XOR  AX, AX
	STOSW				; write ChkSum
	MOV  AX, CS:EXEIP
	STOSW				; write ExeIP
	MOV  AX, CS:RELOCS
	STOSW				; write ReloCS
	MOV  AX, 01CH
	STOSW				; write TabllOff
	XOR  AX, AX
	STOSW				; write Overlay

	MOV  AX, 04000H
	MOV  BX, HANDLE2
	MOV  CX, 016H
	LEA  DX, HEADER
	ADD  DX, 4
	INT  21H			; write new header
        jnc  go1
        mov  cs:res, al
        jmp  exit
go1 :
	XOR  DX, DX
	XOR  CX, CX
	MOV  AX, 04202H
	MOV  BX, CS:HANDLE2
	INT  21H			; set the file pointer on end of file

; ------------------- DECODING EXECUTION MODULE
        CLD
        MOV  AX, 04800H
        MOV  BX, CS:CODE_S
        ADD  BX, CS:OFF_S
        INT  21H                        ; allocat memory block
	JNC  LAB_10
        mov  cs:res, al
        JMP  EXIT                       ; if not avilabel
LAB_10 :
	INC  CS:MEM_FL
        MOV  ES, AX                     ; ES setup on code buffer
	MOV  CS:STRT_ES, AX
        MOV  AX, 04800H
        MOV  BX, 0200H
        INT  21H                        ; allocat memory block
	JNC  LAB_11
        mov  cs:res, al
        JMP  EXIT                       ; if not avilabel
LAB_11 :
	INC  CS:MEM_FL
	PUSH AX
	MOV  AX, WORD PTR CS:HDRSIZE
	MUL  CS:CNST
	MOV  BX, CS:HANDLE1
	MOV  CX, DX
	MOV  DX, AX
	POP  DS
	MOV  AH, 042H
	MOV  AL, 0
	INT  21H			; seek file position on start data

	MOV  BP, CS:CODE_S		; code size in paragraphs
	MOV  CX, BP
	CMP  CX, 0200H			; compare code size with buffer size
	JBE  READ_DATA			; if below or =
	MOV  CX, 0200H			; else CX = size of read buffer
READ_DATA :
	SUB  BP, CX			; new code size
        MOV  CS:OSTATOK, BP             ; save size of code
	MOV  AX, CX
	MOV  CL, 4
	SHL  AX, CL			; code size in byte
	MOV  CX, AX
        CALL BLREAD                     ; read CX byte from file
        JNC  LAB_6
        JMP  EXIT                       ; if Error
LAB_6 :
	INC  CS:WRITE_FL
        MOV  CS:NUMREAD, AX             ; save number reading byte
        XOR  SI, SI
        MOV  DI, SI
	MOV  CS:NUM_B, 2
        CALL CMPREAD                   ;

READ_1 :
        MOV  DL, 010H
        CMP  CS:FLAG, 1
        JZ   MOV1
        LODSW
MOV1 :
        MOV  BP, AX
LOC_50 :
        SHR  BP, 1
        DEC  DX
        JNZ  LOC_51
	PUSHF
        MOV  CS:NUM_B, 2
        CALL CMPREAD
        CMP  CS:FLAG, 1
        JZ   MOV2
        LODSW
MOV2 :
	POPF
        MOV  BP, AX
        MOV  DL, 010H;
LOC_51 :
        JNC  LOC_52
	MOV  CS:NUM_B, 1
	CALL CMPREAD
        MOVSB
        JMP  LOC_50
LOC_52 :
        XOR  CX, CX
        SHR  BP, 1
        DEC  DX
        JNZ  LOC_53
	PUSHF
        MOV  CS:NUM_B, 2
        CALL CMPREAD
        CMP  CS:FLAG, 1
        JZ   MOV3
        LODSW
MOV3 :
	POPF
        MOV  BP, AX
        MOV  DL, 010H
LOC_53 :
        JC   LOC_56
        SHR  BP, 1
        DEC  DX
        JNZ  LOC_54
	PUSHF
        MOV  CS:NUM_B, 2
        CALL CMPREAD
        CMP  CS:FLAG, 1
        JZ   MOV4
	LODSW
MOV4 :
	POPF
        MOV  BP, AX
        MOV  DL, 010H
LOC_54 :
        RCL  CX, 1
        SHR  BP, 1
        DEC  DX
        JNZ  LOC_55
	PUSHF
        MOV  CS:NUM_B, 2
        CALL CMPREAD
        CMP  CS:FLAG, 1
        JZ   MOV5
        LODSW
MOV5 :
	POPF
        MOV  BP, AX
        MOV  DL, 010H
LOC_55 :
        RCL  CX, 1
        INC  CX
        INC  CX
	PUSHF
        MOV  CS:NUM_B, 1
        CALL CMPREAD
	POPF
        LODSB
        MOV  BH, 0FFH
        MOV  BL, AL
        JMP  LOCLOOP_57
LOC_56 :
	PUSHF
        MOV  CS:NUM_B, 2
        CALL CMPREAD
        CMP  CS:FLAG, 1
        JZ   MOV6
        LODSW
MOV6 :
	POPF
        MOV  BX, AX
        MOV  CL, 3
        SHR  BH, CL
        OR   BH, 0E0H
        AND  AH, 7
        JZ   LOC_58
        MOV  CL, AH
        INC  CX
        INC  CX
LOCLOOP_57 :
        MOV  AL, ES:[BX+DI]
        STOSB
        LOOP LOCLOOP_57
        JMP  LOC_50
LOC_58 :
	PUSHF
        MOV  CS:NUM_B, 1
        CALL CMPREAD
        LODSB
	POPF
        OR   AL, AL
        JZ   EXIT
        CMP  AL, 1
        JE   LOC_59
        MOV  CL, AL
        INC  CX
        JMP  LOCLOOP_57
LOC_59 :
        MOV  CX, DI
        SUB  CX, CS:STRT_DI
        CALL BLWRITE
        MOV  BX, DI
        AND  DI, 0FH
        ADD  DI, 02000H
        MOV  CL, 04H
        SHR  BX, CL
        MOV  AX, ES
        ADD  AX, BX
        SUB  AX, 0200H
        MOV  ES, AX
        MOV  CS:STRT_DI, DI
        JMP  LOC_50

; ------------------ EXIT OPERATION
EXIT   :
	CMP  CS:WRITE_FL, 0		; compare write flag
	JZ   CLOSE			; if zero
	MOV  CX, DI			; CX = current DI
	SUB  CX, CS:STRT_DI		; CX = number decoding byte
	CALL BLWRITE 			; write CX byte in new file
	mov  ax, 4202h
	xor  cx, cx
	mov  dx, cx
	mov  bx, cs:handle2
	int  21h
	push ax
	mov  ax, 80h
	mul  dl
	mov  dx, ax
	pop  ax
	push ax
	mov  cl, 9h
	shr  ax, cl
	add  dx, ax
	pop  ax
	and  ax, 01ffh
	add  ax, bx
	mov  bx, ax
	mov  cl, 09h
	shr  ax, cl
	add  dx, ax
	and  bx, 01ffh
	jz   next1
	inc  dx
next1 :
	push dx
	mov  ax, 04200h
	mov  bx, cs:handle2
	xor  cx, cx
	mov  dx, 04h
	int  21h
	pop  cx
	mov  word ptr cs:hdrsize, cx
	push ds
	lea  dx, cs:hdrsize
	mov  ax, cs
	mov  ds, ax
	mov  cx, 02h
	mov  ax, 04000h
	int  21h
	pop  ds

CLOSE :
	cmp  cs:res, 2
	je   end_p
	MOV  AX, 03E00H 		;
	MOV  BX, CS:HANDLE1		;
	INT  21H			; close read file
	MOV  BX, CS:HANDLE2		;
	INT  21H			; close new file
	CMP  CS:BYTE PTR MEM_FL, 0	; allocate memory ?
	JL   END_P			; if no
	MOV  AX, 04900H			; free ferst block
	MOV  BX, CS:STRT_ES
	MOV  ES, BX
	INT  21H			;
	CMP  CS:BYTE PTR MEM_FL, 2	; allocate second block
	JNZ  END_P 			; if no
	MOV  AX, 04900H			;
	PUSH DS
	POP  ES
	INT  21H  			; allocate
END_P :
 	mov  bp, sp
        mov  ax, [bp+18]
        mov  es, ax
        mov  di, [bp+16]
        mov  al, cs:res
        stosb
 	POP  DS
        POP  BP
        RETF 12
ANTILZ  ENDP
END