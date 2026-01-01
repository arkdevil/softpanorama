; В.С. Рабец.

; Программа распечатки экрана "Моя вторая мама"

	TITLE	my2mozer.com
CSEG	SEGMENT
	ASSUME	CS:CSEG,DS:CSEG
	ORG	0100h
MY2MOZER:
	DEC	BP      ; M
	DEC	DI      ; O
	LAHF            ; Я
	STC             ; ∙
	XCHG	AX,DX   ; Т
	INC	BP      ; E
	CWD             ; Щ
	INC	CX      ; A
	STC             ; ∙
	TEST	BYTE PTR [BP+DI+4190H],DL       ; ДУРA
	AAS                     ; ?
	OR	AX,0840ah       ; cr/lf Д
	INC	CX              ; A
	SUB	AL,020h         ; ,пробел
	INC	BP              ; E
	CWD                     ; Щ
	INC	BP              ; E
	STC                     ; ∙
	DEC	BX              ; K
	INC	CX              ; A
	DEC	BX              ; K
	INC	CX              ; A
	LAHF                    ; Я
	OR	AX,840ah        ; cr/lf Д
	INC	BP              ; E
	DEC	AX              ; H
	PUSHF                   ; Ь
	INC	BX              ; C
	DEC	BX              ; K
	DEC	DI              ; O
	TEST	AX,084f9h       ; й∙Д
	INC	BP              ; E
        DEC	AX              ; H
	PUSHF                   ; Ь
	STC                     ; ∙
	POPF                    ; Э
	XCHG	AX,DX           ; Т
	INC	CX              ; A
	STC                     ; ∙
	TEST	BYTE PTR [BP+DI+4190H],DL       ; ДУРA
	STC                ; ∙
	INC	BP         ; E
	INC	BX         ; C
	XCHG	AX,DX      ; Т
	STC                ; ∙
	POPF               ; Э
	XCHG	AX,DX      ; Т
	DEC	DI         ; O
	XCHG	AX,DX      ; Т
	STC                ; ∙
	INC	BX         ; C
	XCHG	AX,BX      ; У
	XCHG	AX,BP      ; Х
	INC	CX         ; A
	NOP                ; Р
	TEST	AL,4Bh     ; иK
	OR	AX,430ah   ; cr/lf C
	XCHG	AX,BX      ; У
	XCHG	AX,BP      ; X
	INC	CX         ; A
	NOP                ; Р
	PUSHF              ; Ь
	STC                ; ∙
	TEST	AL,0f9h    ; и∙
	POPF               ; Э
	XCHG	AX,DX      ; Т
	DEC	DI         ; O
	XCHG	AX,DX      ; Т
	STC                ; ∙
	INC	BX         ; C
	INC	CX         ; A
	XCHG	AX,BP      ; Х  
	INC	CX         ; A
	NOP                ; Р
	DEC	DI         ; O
	DEC	BX         ; K
	OR	AX,4f0ah   ; cr/lf O
	DEC	AX         ; H
	INC	CX         ; A
	STC                ; ∙
	DEC	BP         ; M
	INC	BP         ; E
	DEC	AX         ; H
	LAHF               ; Я
	STC                ; ∙
	TEST	BYTE PTR 66[BX],CL      ; ДOB
	INC	BP                      ; E
	TEST	BYTE PTR -110[DI],AL    ; ДEТ
	STC                             ; ∙
	TEST	BYTE PTR -7[BX],CL      ; ДO∙
	XCHG	AX,CX                   ; С
	DEC	BP         ; M
	INC	BP         ; E
	NOP                ; Р
	XCHG	AX,DX      ; Т
	TEST	AL,02eh	   ; и.
	OR	AX,0860ah  ; cr/lf Ж
	TEST	AL,087h    ; иЗ
        DEC AX             ; H
	PUSHF              ; Ь
	STC                ; ∙
	DEC	BP         ; M
	DEC	DI         ; O
	LAHF               ; Я
        STC                ; ∙
	POPF               ; Э
        XCHG AX,DX         ; Т
        INC CX             ; A
        SUB AX,2020h       ; - пробел пробел
        XCHG AX,BX         ; У
        SUB AX,2D86h       ; -Ж-
        INC CX             ; A
        SUB AX,2191h       ; -С!
	SUB	AL,020h    ; ,пробел
	INT	5          ; "равна" "могиле"
	OR	AX,0420ah  ; cr/lf B
	STC                ; ∙
	XCHG	AX,DX      ; Т
	SAHF               ; Ю
	NOP                ; Р
	PUSHF              ; Ь
	DEC	BP         ; M
	XCHG	AX,BX      ; У
	STC                ; ∙
	POPF               ; Э
	XCHG	AX,DX      ; Т
	XCHG	AX,BX      ; У
	STC                ; ∙
	XCHG	AX,DX      ; Т
	INC	BP         ; E
	CWD                ; Щ
	XCHG	AX,BX      ; У
	SUB	AL,087h    ; ,З
	INC	CX         ; A
	STC                ; ∙
	XCHG	AX,DX      ; Т
	INC	CX         ; A
	DEC	BX         ; K
	XCHG	AX,BX      ; У
	SAHF               ; Ю
	STC                ; ∙
	NOP                ; Р  
	INC	BP         ; E
	CBW                ; Ш
	INC	BP         ; E
	XCHG	AX,DX      ; Т
	DEC	BX         ; K
	XCHG	AX,BX      ; У
	STC                ; ∙
	RET                ; ├

	DB	197,197    ; ┼┼  (дополняет рисунок решетки, можно убрать)
CSEG	ENDS
	END	MY2MOZER
