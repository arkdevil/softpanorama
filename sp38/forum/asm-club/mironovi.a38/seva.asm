;		Добрый день!
;    Предлагаемый исходный текст - резидентный калькулятор, выполняющий
; целочисленные арифметические операции. Понадобился автору для расчета
; адресов и перевода из одной системы счисления в другую при пользовании
; программой Quaid Analyser. Резидентом можно пользоваться только в
; текстовом режиме. Желающие могут увеличить соответствующий буфер и
; переписать видео функции для поддержки графики.
;    Кнопки активизации назначаются пользователем при загрузке. Можно
; задать любую комбинацию {Alt, Control, Left Sift, Right Shift}, включая
; пустую, и какую-нибудь другую кнопку. (Обязательно проэксперементируйте
; с ALT-CTRL-DEL) При запуске из BAT файла можно использовать ключ /is,
; задающий фиксированную активизацию.
;    Программа занимает 2.5K
;    Остальная информация в файле DEva.ASM
;    Скомпилировать исходный текст можно с помощью TASM 2.0, MASM 5.0 и др.
;					автор К. Миронович

PAGE		62, 132
text		segment
		assume cs:text , ds:text

DosCall		MACRO	value1,value2
		IFNB	<value2>
		mov	ax,value1*100h+value2
		ELSE
		mov	ah,value1
		ENDIF
		int	21h
		ENDM

		ORG	100h

start:		jmp	begin

		ORG	170h

StkTop		dw	3
OprStk		dw	30 dup (0)

OpertTab	db	'(','*','/','+','-',')'
PriorTab	db	 3 , 2 , 2 , 1 , 1 , 0
OPRNUM		equ	$-PriorTab

FuncTab		dw	OpenPar
		dw	MultiLong
		dw	DivideLong
		dw	Plus
		dw	Minus

BUSY		equ	80h
Video		equ	61h ;10h
ColrSg		equ	0B800h
MonoSg		equ	0B0h
ColrAttr	equ	30h			; black on cyan
MonoAttr	equ	70h			; black on white

SaveSP		dw	0
SaveSS		dw	0
StkPtr		dw	0

Vsegm		dw	0B800h
Voffs		dw	0
Vmode		db	0
Vpage		db	0
Vcols		dw	0
Vrows		db	24
Attribute	db	7
CursPos		dw	0
CursSiz		dw	0
Scan		db	0FFh
PopScan		db	0
KbdFlag		db	0FFh
Corner		db	0
;IntMask		db	0
ScrAddr		dw	0			; Up-Left corner address
CurStart	dw	0

Logo		db	'┌─────────────────────────── Tab, Esc ─┐'
		db	'│ Expression                           │'
		db	'│[                                    ]│'
		db      '├ Result ──────────────────────────────┤'
		db	'│ Dec:[            ] Hex:[            ]│'
;		db	'└──────────────────────────────────────┘'

LogoROWS	equ	6
LogoCOLS	equ	40
ExprLen		equ	35
ResLen		equ	11
ExprStart	equ	(Offset Logo)+2*LogoCOLS+2
ExprEnd		equ	ExprStart+ExprLen
DecStart	equ	(Offset Logo)+4*LogoCols+7
DecEnd		equ	DecStart+ResLen
HexStart	equ	(Offset Logo)+4*LogoCols+26
HexEnd		equ	HexStart+ResLen

SaveBuff	dw	LogoROWS*LogoCOLS dup (0)

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;

ChkVideo	proc
		mov	ah, 0Fh			; get video mode
		int	Video
		and	al, 7Fh
		cmp	al, 7
		ja	CKV5
		mov	dx, ColrSg
		jb	CKV1
		mov	dh, MonoSg
		jmp	short CKV2
CKV1:		cmp	al, 3
		ja	CKV5
		mov	bl, ColrAttr
		test	al, 1
		jnz	CKV3
CKV2:		mov	bl, MonoAttr
CKV3:		mov	Vmode, al
		mov	Vpage, bh
		mov	Attribute, bl
		mov	Vsegm, dx
		xor	al, al
		xchg	al, ah
		shl	ax, 1
		mov	Vcols, ax
		mov	ah, 03h			; get cursor
		int	Video
		mov	CursPos, dx
		mov	CursSiz, cx

		push	es
		mov	ax, 40h
		mov	es, ax
		mov	ax, es:[4Eh]
		mov	Voffs, ax
		mov	al, es:[84h]
		or	al, al
		jnz	CKV4
		mov	al, 24
CKV4:		mov	Vrows, al
		pop	es
		clc
		ret
CKV5:		stc
		ret
ChkVideo	endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;

CalcAddr	proc
		mov	al, Corner
		mov	dx, Vcols
		shr	dx, 1
		sub	dl, LogoCOLS
		mov	dh, Vrows
		sub	dh, LogoROWS
		test	al, 1
		jnz	CA1
		xor	dl, dl
CA1:		test	al, 2
		jnz	CA2
		xor	dh, dh
CA2:		push	dx
		mov	ax, Vcols
		mul	dh
		xor	dh, dh
		add	ax, dx
		add	ax, dx
		add	ax, Voffs
		pop	dx
		mov	ScrAddr, ax
		add	dx,202h
		mov	CurStart, dx
		ret
CalcAddr	endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;
; es:di - target, ds:si - source
; dx, bx - delta

TransScr	proc
		mov	cx, LogoROWS
SV1:		push	cx
		push	si
		push	di
		mov	cl, LogoCOLS
		rep	movsw
		pop	di
		pop	si
		add	si, bx
		add	di, dx
		pop	cx
		loop	SV1
		ret
TransScr	endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;

DrawScr		proc
		push	es
		push	cx
		push	si
		push	di
		mov	si, Offset Logo
		mov	di, ScrAddr
		mov	dx, Vcols
		mov	es, Vsegm
		mov	cx, LogoROWS-1
		mov	ah, Attribute
DV1:		push	cx
		push	di
		mov	cl, LogoCOLS
DV2:		lodsb
		stosw
		loop	DV2
		pop	di
		add	di, dx
		pop	cx
		loop	DV1
		mov	al, 0C0h
		stosw
		mov	cl, LogoCOLS-2
		mov	al, 0C4h
		rep	stosw
		mov	al, 0D9h
		stosw
		pop	di
		pop	si
		pop	cx
		pop	es
		ret
DrawScr		endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;
; si - input buffer

GetStr		proc	near
		xor	bp, bp
		mov	di, si
		mov	al, ' '
GT1:		scasb
		jnz	GT1
		dec	di
		sub	di, si			; string length
		mov	cx, 607h
		or	bx, bx
		jns	GT2
		mov	bx, di			; string ptr
GT2:		mov	ah, 01h			; shape
		int	Video

GT3:		call	DrawScr

GT4:		mov	dx, CurStart
		add	dl, bl
		push	bx
		mov	bh, Vpage
		mov	ah, 02h			; position
		int	Video
		pop	bx
GT5:
		mov	ah, 1
		int	16h
		jz	GT3
		xor	ah, ah
		int	16h
		or	al, al
		jnz	GT5a
		jmp	GT14
GT5a:
		cmp	al, 8			; BS
		jnz	GT7
		mov	bp, si
		or	bx, bx
		jz	GT5			; no action
		push	si
		add	si, bx
		dec	bx			; string ptr
GT6:		lodsb
		mov	[si-2], al
		cmp	al, ' '			; EOL
		jnz	GT6
		pop	si
		dec	di			; string length
		jmp	GT3

GT7:		cmp	al, 27			; ESC
		jz	GT8
		cmp	al, 9			; Tab
		jz	GT8
		cmp	al, 13			; CR
		jnz	GT9
		mov	bp, si
		or	di, di
		jz	GT5			; string empty
		ret
GT8:		stc
		ret

GT9:		call	IsNumber
		jnc	GT10
		push	ax
		push	bx
		call	Operator
		pop	bx
		pop	ax
		jns	GT10
		or	al, ' '
		call	IsAlpha
		jnc	GT10
		cmp	al, 'x'
		jnz	GT5			; no action
GT10:
		or	bp, bp
		jnz	GT10b
		mov	bx, di
GT10a:		mov	Byte Ptr [bx+si], ' '
		dec	bx
		jns	GT10a
		xchg	bx, bp
		mov	di, bx
GT10b:		cmp	bx, di
		jb	GT13
		cmp	di, ExprLen
GT10c:		je	GT5			; no action
GT11:		inc	di
GT12:		mov	[si+bx], al
		inc	bx
		jmp	GT3

GT13:		cmp	ch, 6			; insert mode
		jb	GT12
		cmp	di, ExprLen
		je	GT10c			; no action
		push	di
		push	si
		push	cx
		mov	cx, di
		sub	cx, bx
		add	di, si
		lea	si, [di-1]
		std
		rep	movsb
		cld
		pop	cx
		pop	si
		pop	di
		jmp	GT11

GT14:		xchg	al, ah
		cmp	al, 71			; home
		jne	GT15
		xor	bx, bx
		jmp	short GT18

GT15:		cmp	al, 79			; end
		jnz	GT16
		mov	bx, di
		jmp	short GT18

GT16:		cmp	al, 75			; left
		jnz	GT19
		dec	bx
		jns	GT18
GT17:		inc	bx
GT18:		mov	bp, si
GT18a:		jmp	GT4

GT19:		cmp	al, 77			; right
		jnz	GT20
		cmp	bx, di
		jb	GT17
		jmp	GT18

GT20:		cmp	al, 82			; ins
		jnz	GT21
		mov	bp, si
		xor	ch, 2
		jmp	GT2

GT21:		cmp	al, 83			; del
		jnz	GT18a
		mov	bp, si
		cmp	bx, di
		jz	GT18
		push	si
		add	si, bx
		inc	si
		jmp	GT6
GetStr		endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;

IsAlpha		proc
		cmp	al, 'a'
		jb	IARet
		cmp	al, 'g'
		cmc
IARet:		ret
IsAlpha		endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;

IsNumber	proc
		cmp	al, '0'
		jb	INRet
		cmp	al, ':'
		cmc
INRet:		ret
IsNumber	endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;
; return: if ZR ah - operator ID, al - priority
; NV - not found

Operator	proc
		mov	bx, OPRNUM-1
IO1:		cmp	al, OpertTab[bx]
		jz	IO2
		dec	bx
		jns	IO1
		ret
IO2:		mov	ah, bl
		mov	al, PriorTab[bx]
		ret
Operator	endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;
; si, di - string range
; cx:bp - long, bx - radix

_ltoa		proc
		push	bp
		push	cx
		mov	al, ' '
		cmp	bl, 16
		je	posit
		or	cx,cx
		jge	posit
		neg	cx
		neg	bp
		sbb	cx, 0
		mov	al, '-'
posit:
		xchg	ax, bp
		std
		jcxz	LoWord
HiWord:
		xchg	ax, cx
		xor	dx, dx
		div	bx
		xchg	ax, cx
		div	bx
		call	PutDigit
		jcxz	ChkLoWord
		jmp	HiWord
LoWord:
		xor	dx, dx
		div	bx
		call	PutDigit
ChkLoWord:
		or	ax, ax
		jnz	LoWord
		mov	ax, bp
		stosb
		mov	al, ' '
CopyStr:	stosb
		cmp	si, di
		jbe	CopyStr
		cld
		pop	cx
		pop	bp
		ret
_ltoa		endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;

PutDigit	proc
		push	ax
		mov	ax, dx
		cmp	al, 10
		jb	digit
		add	al, 7
digit:		add	al, '0'
		stosb
		pop	ax
		ret
PutDigit	endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;
; si - string ptr

Operand		proc
		push	ax
		push	di
		mov	bx, 10			; radix
		cmp	Word Ptr [si], 'x0'
		jnz	SL1
		inc	si
		inc	si
		mov	bl, 16
SL1:		mov	di, si
		xor	bp, bp
		mov	cx, bp
SL2:		lodsb
		mov	ah, '0'
		call	IsNumber
		jnc	SL4
		call	IsAlpha
		jc	SLRet
		cmp	bl, 16
		jz	SL3
		mov	si, di
		mov	bl, 16			; radix
		jmp	SL1			; once more
SL3:		mov	ah, 87
SL4:		sub	al, ah
		cbw
		cwd
		xchg	ax, bp
		call	MultiLong		; cx:bp * dx:bx -> cx:bp
		add	bp, ax
		adc	cx, 0
		jmp	SL2

SLRet:		dec	si
		cmp	si, di
		pop	di
		pop	ax
		ret
Operand		endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;
; cx:ax - long
; dx:bx - long

DivideLong	proc
		push	si
		push	di
		push	dx
		or	dx, bx
		pop	dx
		jnz	DL1
		xor	ax, ax
		mov	cx, ax
		jmp	error2
DL1:
		push	cx
		or	cx, ax
		pop	cx
		jz	DLRet
DL2:
		mov	si, cx
		test	si, si
		jns	DL3
		neg	cx
		neg	ax
		sbb	cx, 0
DL3:
		xor	si, dx
		push	si			; save sign
		xor	si, si
		test	dx, dx
		jns	DL4
		neg	dx
		neg	bx
		sbb	dx, 0
DL4:
		jnz	DL7
		test	bx, bx
		mov	di, 20h
		js	DL7
DL5:
		shl	ax, 1
		rcl	cx, 1
		rcl	si, 1
		cmp	si, bx
		jb	DL6
		sub	si, bx
		inc	ax
DL6:
		dec	di
		jnz	DL5
		jmp	short DL11
DL7:
		shr	di, 1
DL8:
		shl	ax, 1
		rcl	cx, 1
		rcl	si, 1
		cmp	si, dx
		jb	DL10
		jnz	DL9
		cmp	cx, bx
		jb	DL10
DL9:
		sub	cx, bx
		sbb	si, dx
		inc	ax
DL10:
		dec	di
		jnz	DL8
		xor	cx, cx
DL11:
		pop	si
		or	si, si			; test sign
		jns	DLRet
		neg	cx
		neg	ax
		sbb	cx, 0
DLRet:
		pop	di
		pop	si
		ret
DivideLong	endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;
; cx:ax - long
; dx:bx - long

MultiLong	proc
		push	ax
		mul	dx
		xchg	ax, cx
		mul	bx
		add	cx, ax
		pop	ax
		mul	bx
		add	cx, dx
		ret
MultiLong	endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;

Minus:		neg	dx
		neg	bx
		sbb	dx, 0
Plus:		add	ax, bx
		adc	cx, dx
OpenPar:
		ret

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;

Quant1		equ	20h
Quant2		equ	0F0h

Beep		proc
		mov	dx, 61h
		mov	bl, Quant1
		in	al, dx
		mov	ah, al
		and	al, NOT 1
BP1:		xor	al, 2
		out	dx, al
		mov	cx, Quant2
		loop	$
		dec	bl
		jnz	BP1
		mov	al, ah
		out	dx, al
		ret
Beep		endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;

Parse		proc
		mov	StkPtr, sp
		mov	bx, ExprStart-1
PRS1:		mov	si, ExprStart
		sub	bx, si
		call	GetStr
		jnc	PRS2
		ret

PRS2:		mov	di, Offset OprStk
PRS3:		cmp	Byte Ptr [si], ' '
		jz	error2
		call	Operand
		jz	PRS10
PRS4:		lodsb
		dec	si
		call	Operator		; al - prior, ah - ID
		js	error
		cmp	al, 3			; '('
		jz	error
		inc	si
PRS5:
		cmp	di, Offset OprStk
		jnz	PRS8
		cmp	al, 0			; ')'
		jnz	PRS6
		dec	si
		jmp	short error
PRS6:
		push	cx
		push	bp
		stosw
		lodsb
		dec	si
		call	Operator
		js	PRS3
		cmp	al, 3			; '('
		jnz	error
PRS7:		inc	si
		stosw
		jmp	PRS3
PRS8:
		cmp	al, [di-2]
		jg	PRS6
		cmp	Byte Ptr [di-2], 3	; '('
		jz	PRS9
		xchg	ax, [di-2]
		xchg	al, ah
		cbw
		add	ax, ax
		mov	dx, cx
		mov	bx, bp
		mov	bp, ax
		pop	ax
		pop	cx
		call	FuncTab[bp]
		xchg	ax, bp
		dec	di
		dec	di
		mov	ax, [di]
		jmp	PRS5

PRS9:		cmp	al, 0			; ')'
		jnz	PRS6
		dec	di
		dec	di
		jmp	PRS4

PRS10:		lodsb
		dec	si
		call	Operator
		js	error
		cmp	al, 3			; '('
		jz	PRS7
		test	al, 1			; '*', '/', ')'
		jz	error
		xor	cx, cx
		mov	bp, cx
		inc	si
		jmp	PRS6

error:		cmp	Byte Ptr [si], ' '
		jz	finis
error2:		call	Beep
		mov	sp, StkPtr
		mov	bx, si
		jmp	PRS1

finis:		cmp	di, Offset OprStk
		jz	PRS11
		dec	di
		dec	di
		mov	ax, [di]
		cmp	al, 3			; '('
		jz	error2
		xchg	al, ah
		cbw
		add	ax, ax
		mov	dx, cx
		mov	bx, bp
		mov	bp, ax
		pop	ax
		pop	cx
		call	FuncTab[bp]
		xchg	ax, bp
		jmp	finis

PRS11:		mov	sp, StkPtr
		clc
		ret
Parse		endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;

Activate	proc
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	bp
		push	es

		push	cs
		pop	es
		call	ChkVideo
		jc	ACTRet
ACT1:		call	CalcAddr
		mov	si, ScrAddr
		mov	di, Offset SaveBuff
		mov	bx, Vcols
		mov	dx, LogoCOLS*2
		push	ds
		mov	ds, Vsegm
		call	TransScr
		pop	ds
ACT2:
		call	Parse
		jc	ACT3
		mov	si, DecStart
		mov	di, DecEnd
		mov	bx, 10
		call	_ltoa
		mov	si, HexStart
		mov	di, HexEnd
		mov	bl, 16
		call	_ltoa
		jmp	ACT2

ACT3:		mov	di, ScrAddr		; restore screen
		mov	si, Offset SaveBuff
		mov	dx, Vcols
		mov	bx, LogoCOLS*2
		push	es
		mov	es, Vsegm
		call	TransScr
		pop	es
		cmp	al, 9			; Tab
		jnz	ACT4
		inc	Corner
		jmp	ACT1

ACT4:		mov	cx, CursSiz
		mov	ah, 01h			; set shape
		int	Video
		mov	dx, CursPos
		mov	bh, Vpage
		mov	ah, 02h			; set position
		int	Video
ACTRet:		pop	es
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		ret
Activate	endp

Int15		proc	far
		pushf
		cmp	ah, 88h
		jnz	LL1
		cmp	di, 'AS'
		jnz	LL1
		call	Dword Ptr cs:Old15Ofs
		or	di, '  '
		push	cs
		pop	es
		mov	si, Offset Old09Ofs
		iret

LL1:		popf
		jmp	Dword Ptr cs:Old15Ofs
Int15		endp

Int9		proc	far
		push	ax
		in	al, 60h
		cbw
		or	al, ah
		mov	cs:Scan, al
		cmp	al, cs:PopScan
		jnz	KB2
KB1:		push	ds
		xor	ax, ax
		mov	ds, ax
		mov	al, ds:[417h]
		and	al, 0Fh
		cmp	al, cs:KbdFlag
		jz	KB3
		pop	ds
KB2:		pop	ax
		db	0EAh			; jump far
Old09Ofs	dw	Int9
Old09Sgm	dw	0
Old15Ofs	dw	Int15
Old15Sgm	dw	0

KB3:		in	al, 61h
		mov	ah, al
		or	al, 80h
		out	61h, al			; enable kbd
		xchg	al, ah
		out	61h, al

		mov	al, 20h
		out	20h, al			; EOI
		push	cs
		pop	ds
;		in	al, 21h
;		mov	IntMask, al
;		or	al, 10111001b
;		out	21h, al
		or	KbdFlag, BUSY
		mov	SaveSS, ss
		mov	SaveSP, sp
		mov	ax, cs
		mov	ss, ax
		mov	sp, Offset StkTop
		sti
		call	Activate
		cli
		mov	ss, SaveSS
		mov	sp, SaveSP
;		mov	al, IntMask
;		out	21h, al
		and	KbdFlag, NOT BUSY
		pop	ds
		pop	ax
		iret
Int9		endp

;-------------------------------
; end of resident portion

coprt		db	13,10,'Copyright (c) ALEX SOFTWARE, 1991.'
		db	13,10,'Small Evaluator.  SEva/? for help.'
		db	13,10,10,'$'
help            db      '─────────────────────── HELP ───────────────────────',13,10
		db	' Usage:  SEva /[U|I|IS]',13,10
		db	' where   I  - install resident',13,10
		db	'         U  - uninstall',13,10
		db	'         IS - install with standard call CTRL+Enter',13,10,10
		db	' Calculated expression consist of',13,10
		db	'signed long integer operands, operators, parentheses',13,10,10
		db	'operand form:    mmm.. (hex), where m=0..9,a..f',13,10
		db	'               0xnnn.. (hex)',13,10
		db	'              or nnn.. (dec), where n=0..9',13,10
		db	'operators:  * , / , + , -',13,10
                db      '────────────────────────────────────────────────────',13,10,'$'

ScanTabA	db	80h,'1234567890-=',81h
		db	82h,'QWERTYUIOP[]',83h
		db	' ','ASDFGHJKL:"~'
		db	' ','|ZXCVBNM<>? ',84h
		db	' ',85h,86h

KS1		db	'ESC',13,10,'$'		; 80
KS2		db	'BS',13,10,'$'		; 81
KS3		db	'TAB',13,10,'$'		; 82
KS4		db	'Enter',13,10,'$'	; 83
KS5		db	'PrtSc',13,10,'$'	; 84
KS6		db	'SPACE',13,10,'$'	; 85
KS7		db	'CAPS',13,10,'$'	; 86
KS8		db	'NUM',13,10,'$'
KS9		db	'SCROLL',13,10,'$'
KS10		db	'HOME',13,10,'$'
KS11		db	'UP',13,10,'$'
KS12		db	'PgUp',13,10,'$'
KS13		db	'Grey -',13,10,'$'
KS14		db	'LEFT',13,10,'$'
KS15		db	'[5]',13,10,'$'
KS16		db	'RIGHT',13,10,'$'
KS17		db	'Grey +',13,10,'$'
KS18		db	'END',13,10,'$'
KS19		db	'DOWN',13,10,'$'
KS20		db	'PgDn',13,10,'$'
KS21		db	'INS',13,10,'$'
KS22		db	'DEL',13,10,'$'
KS23		db	'SysRq',13,10,'$'

ScanTabB	dw	Offset KS1
		dw	Offset KS2
		dw	Offset KS3
		dw	Offset KS4
		dw	Offset KS5
		dw	Offset KS6
		dw	Offset KS7
ScanTabC	dw	Offset KS8
		dw	Offset KS9
		dw	Offset KS10
		dw	Offset KS11
		dw	Offset KS12
		dw	Offset KS13
		dw	Offset KS14
		dw	Offset KS15
		dw	Offset KS16
		dw	Offset KS17
		dw	Offset KS18
		dw	Offset KS19
		dw	Offset KS20
		dw	Offset KS21
		dw	Offset KS22
		dw	Offset KS23

msg1		db	'SEva not installed.',13,10,'$'
msg2		db	'SEva already in memory.',13,10,'$'
msg3		db	'SEva removed from memory.',13,10,'$'
msg4		db	'SEva: invalid parameter.',13,10,'$'
pause		db	'Press [ALT][,CTRL][,SHIFTS] and Any Key.',13,10,'$'

msg5		db	13,10
		db	'SEva successfully installed.',13,10
		db	'Activate by  $'
msg6		db	'ShiftR+$'
msg7		db	'ShiftL+$'
msg8		db	'CTRL+$'
msg9		db	'ALT+$'
msg10		db	'   ',13,10,'$'

MsgTab		dw	msg5
		dw	msg6
		dw	msg7
		dw	msg8
		dw	msg9
LastMsg		dw	msg10

DispStr		proc
		push	ax
		DosCall	09h
		pop	ax
		ret
DispStr		endp

LookScan	proc
		dec	al
		cbw
		mov	bx, ax
		cmp	al, 58
		jnb	LSC2
		mov	bl, ScanTabA[bx]
		or	bl, bl
		js	LSC1
		mov	msg10, bl
		ret
LSC1:		shl	bl, 1
		mov	bx, ScanTabB[bx]
		mov	LastMsg, bx
		ret
LSC2:		cmp	al, 68
		jnb	LSC4
		sub	al, 9
		cmp	al, ':'
		xchg	al, ah
		mov	al, 'F'
		mov	Word Ptr msg10, ax
		jnz	LSC3
		mov	Word Ptr msg10[1], '01'
LSC3:		ret

LSC4:		cmp	al, 84
		jnb	LSC5
		sub	bl, 68
		shl	bx, 1
		mov	bx, ScanTabC[bx]
		mov	LastMsg, bx
		ret
LSC5:		cmp	al, 56h
		jnz	LSC6
		mov	Byte Ptr msg10, 'F'
		mov	Word Ptr msg10[1], '11'
		ret
LSC6:		cmp	al, 57h
		jnz	LSC7
		mov	Byte Ptr msg10, 'F'
		mov	Word Ptr msg10[1], '21'
LSC7:		ret
LookScan	endp

GetScan		proc
GSC1:		mov	ax, -1
		xchg	al, Scan
		cmp	al, ah
		jz	GSC1
		ret
GetScan		endp

; procedure SwapInt - swaps vectors Int15h and [es:si]

SwapInt		proc
		push	ds
		xor	ax, ax
		mov	ds, ax
		cli
		mov	ax, ds:[09h*4]
		xchg	ax, es:[si]
		mov	ds:[09h*4], ax
		mov	ax, ds:[09h*4+2]
		xchg	ax, es:[si+2]
		mov	ds:[09h*4+2], ax
		mov	ax, ds:[15h*4]
		xchg	ax, es:[si+4]
		mov	ds:[15h*4], ax
		mov	ax, ds:[15h*4+2]
		xchg	ax, es:[si+6]
		mov	ds:[15h*4+2], ax
		sti
		pop	ds
		ret
SwapInt		endp

;-----------------------------------------------;
;		INIATIALIZATION			;
;-----------------------------------------------;

begin:		DosCall	30h
		cmp	al, 2
		jnb	BB1
		ret
BB1:		mov	dx, Offset coprt
		call	DispStr
		; ----
;		call	Activate		; test
;		jmp	exit
		; ----
		mov	ah, 88h
		mov	di, 'AS'
		int	15h
		mov	SaveSS, es
		mov	SaveSP, si
		mov	Vsegm, di

		push	cs
		pop	es
		cld
		mov	di, 80h
		xor	cx, cx
		mov	cl, [di]
		jcxz	BB4
		inc	di
		mov	al, '/'
		repne	scasb
		jz	BB3
BB2:		mov	dx, Offset msg4
		mov	al, 4
		jmp	short BB7

BB3:		mov	ax, [di]
		cmp	al, '?'
		jnz	BB5
BB4:		mov	dx, Offset help
		jmp	short BB6

BB5:            or	ax, '  '
		cmp	al, 'u'
		jz	Remove
		cmp	al, 'i'
		jnz	BB2
		cmp	Vsegm, 'as'
		jnz	Install
		mov	dx, Offset msg2
		mov	al, 2
		jmp	short BB7

Remove:		cmp	Vsegm, 'as'
		jz	BB8
		mov	dx, Offset msg1
BB6:		mov	al, 1
BB7:		call	DispStr
exit:		DosCall	4Ch

BB8:		les	si,Dword Ptr SaveSP	; es:si -> old int vector
		call	SwapInt
		DosCall	49h			; free block
		mov	dx,Offset msg3
		mov	al,3
		jmp	BB7

Install:	cmp	ah, 's'
		jz	BB9
		mov	Word Ptr Standard, 0	; custom
BB9:		push	es
		xor	ax, ax
		mov	es, ax
		mov	ax, es:[10h*4]
		mov	es:[Video*4],ax
		mov	ax, es:[10h*4+2]
		mov	es:[Video*4+2],ax
		xchg	ax, ds:[2Ch]
		mov	es, ax
		DosCall	49h
		pop	es
		mov	si, Offset Old09Ofs
		mov	[si+2], cs
		mov	[si+6], cs
		call	SwapInt

		mov	al, Standard
		or	al, al
		jnz	BB11
		mov	dx, Offset pause
		call	DispStr
BB10:		call	GetScan
		cmp	al, 56			; Alt
		jz	BB10
		cmp	al, 29			; Ctrl
		jz	BB10
		cmp	al, 42			; LShft
		jz	BB10
		cmp	al, 54			; RShft
		jz	BB10
BB11:		mov	PopScan, al
		cli
		call	LookScan
		mov	al, Standard[1]
		and	al, 0Fh
		jnz	BB12
		push	es
		xor	ax, ax
		mov	es, ax
		mov	al, es:[417h]
		and	al, 0Fh
		pop	es
BB12:		sti
		mov	KbdFlag, al
		shl	al, 1
		or	al, 21h
		mov	cx, 6
		mov	si, Offset MsgTab
BB13:		xchg	ax, dx
		lodsw
		xchg	ax, dx
		shr	al, 1
		jnc	BB14
		call	DispStr
BB14:		loop	BB13

		mov	ds:[80h], cl
BB15:		mov	ah, 1
		int	16h
		jz	BB16
		xor	ah, ah
		int	16h
		jmp	BB15
BB16:
		mov	dx, Offset coprt
		int	27h

Standard	db	1Ch, 04h		; Enter, CTRL
		db	'by K.Mironovich'

text		ends
		end	start