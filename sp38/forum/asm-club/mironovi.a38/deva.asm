;		Добрый день!
;    Предлагаемый исходный текст - реализация дополнительной команды MS DOS,
; выполняющей целочисленные арифметические операции. Своего рода COMMAND.COM
; extender, поддержка которого осуществляется MS DOS, начиная с версии 3.30 .
; Можно было, конечно, оформить это в виде внешней утилиты, но на взгляд
; автора лучше пожертвовать 1K ОЗУ, чем обращаться к диску.
; Мнемоника команды /? (просто ? не идет, т.к. COMMAND.COM воспринимает это
; как шаблон). Вид последующего арифметического изложен во встроенной
; подсказке. Целые константы воспринимаются как десятичные, если не содержат
; символов A..F. Шестнадцатиричные константы содержат A..F, либо начинаются
; с 0x.
;    Что касается аналогов, то они автору не известны (Side Kick не всчет
; из-за расхода памяти.), в противном случае, он воспользовался бы одним
; из них. Поскольку программа писалась исключительно для нужд автора, то
; десятичная точка и всякие там синусы-косинусы не поддерживаются.
; Желающие могут доработать исходный текст для своих нужд, изменив
; функции Parse, Operator и Operand.
;    В DR DOS Release 5.0 программа не работает, Digital Research не
; поддерживает функции расширения COMMAND.COM (автору этого обнаружить
; не удалось).
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

		ORG	82h
OprStk		label	Word

		ORG	100h

Buffer		label	Byte
start:		jmp	begin
		db	'(C) ALEX SOFTWARE, 1991. '
		db	92 dup (0)

OpertTab	db	'(','*','/','+','-',')'
PriorTab	db	 3 , 2 , 2 , 1 , 1 , 0
OPRNUM		equ	$-PriorTab

FuncTab		dw	OpenPar
		dw	MultiLong
		dw	DivideLong
		dw	Plus
		dw	Minus

StkPtr		dw	0
CmdPtr		dw	0, 0


DecSt		db	'dec: ', 0
HexSt		db	' ,hex: ', 0
errmsg		db	'DEva: syntax error', 0

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;

GetStr		proc
		mov	di, Offset Buffer
		push	di
		mov	si, CmdPtr
GT1:		push	ds
		mov	ds, CmdPtr[2]
		call	SkipBlanks
		pop	ds
		cmp	al, 13
		jz	GT3
		cmp	al, 0
		jz	GT3
		call	IsNumber
		jnc	GT2
		push	ax
		call	Operator
		pop	ax
		jns	GT2
		or	al, ' '
		call	IsAlpha
		jnc	GT2
		cmp	al, 'x'
		jnz	GT4
GT2:		stosb
		jmp	GT1
GT3:		mov	al, ' '
		stosb
		clc
		pop	si
		ret
GT4:		stc
		pop	si
		ret
GetStr		endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;

OutChar		proc
		push	ax
		push	dx
		xchg	ax, dx
		DosCall	02h
		pop	dx
CHRet:		pop	ax
		ret
OutChar		endp

;-----------------------------------------------;
;		SUBROUTINE			;
;-----------------------------------------------;

OutStr		proc
		push	ax
OST1:		lodsb
		or	al, al
		jz	CHRet
		call	OutChar
		jmp	OST1
OutStr		endp

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
; cx:bp - long, bx - radix

_ltoa		proc
		push	bp
		push	cx
		xor	si, si
		cmp	bl, 16
		je	posit
		or	cx,cx
		jns	posit
		neg	cx
		neg	bp
		sbb	cx, si
		mov	al, '-'
		call	OutChar
posit:
		xchg	ax, bp
		jcxz	LoWord
HiWord:
		xchg	ax, cx
		xor	dx, dx
		div	bx
		xchg	ax, cx
		div	bx
		push	dx
		inc	si
		jcxz	ChkLoWord
		jmp	HiWord
LoWord:
		xor	dx, dx
		div	bx
		push	dx
		inc	si
ChkLoWord:
		or	ax, ax
		jnz	LoWord
		mov	cx, si
		jcxz	NoCopy
CopyStr:	pop	ax
		cmp	al, 10
		jb	digit
		add	al, 7
digit:		add	al, '0'
		call	OutChar
		loop	CopyStr
NoCopy:		pop	cx
		pop	bp
		ret
_ltoa		endp

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
		xor	bp, bp
		mov	cx, bp
		jmp	PRS11
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
		sbb	dx, si
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

Parse		proc
		mov	StkPtr, sp
PRS1:		call	GetStr
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
		xchg	ax, bp
		pop	ax
		pop	cx
		call	cs:FuncTab[bp]
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
error2:		stc
		jmp	short PRS12

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
		xchg	ax, bp
		pop	ax
		pop	cx
		call	cs:FuncTab[bp]
		xchg	ax, bp
		jmp	finis

PRS11:		clc
PRS12:		mov	sp, StkPtr
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
		push	ds
		push	es
		mov	Byte Ptr [si], 0	; no command

		push	cs
		pop	ds
		push	cs
		pop	es

		cld
		call	Parse
		jc	ACT1
		mov	si, Offset DecSt
		call	OutStr
		mov	bx, 10
		call	_ltoa
		mov	si, Offset HexSt
		call	OutStr
		mov	bl, 16
		call	_ltoa
		jmp	short ACTRet

ACT1:		mov	si, Offset errmsg
		call	OutStr

ACTRet:		mov	al, 13
		call	OutChar
		pop	es
		pop	ds
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		ret
Activate	endp

SkipBlanks	proc
SBL1:		lodsb
		cmp	al, ' '
		jz	SBL1
		cmp	al, 9
		jz	SBL1
		ret
SkipBlanks	endp

CheckCmd	proc
		push	ax
		push	si
		cld
		lea	si, [bx+2]
		call	SkipBlanks
		or	al, al
		jz	CHK1
		cmp	al, 13
		jz	CHK1
		dec	si
		lodsw
		cmp	ax, '?/'
		jnz	CHKRet
		cmp	Byte Ptr [si], 13
		jz	CHK1
		mov	cs:CmdPtr, si
		mov	cs:CmdPtr[2], ds
		xor	ax, ax
		jmp	short CHKRet

CHK1:		or	al, -1
CHKRet:		pop	si
		pop	ax
		ret
CheckCmd	endp

Int2F		proc	far
		cmp	dx, -1
		jnz	MP3
		cmp	ax, 0AE00h
		jnz	MP2
		call	CheckCmd
		jnz	MP1
		mov	al, dl			; support
MP1:		iret

MP2:		cmp	ax, 0AE01h
		jnz	MP4
		call	Activate
		xor	ax, ax
		iret

MP3:		cmp	ah, 0AFh
		jz	MP5
MP4:
		db	0EAh			; jump far
Old2FOfs	dw	Int2F
Old2FSgm	dw	0

MP5:		cmp	di, 'AS'
		jnz	MP4
		or	di, '  '
		mov	si, Offset Old2FOfs
		push	cs
		pop	es
		iret
Int2F		endp

;-------------------------------
; end of resident portion

coprt		db	13,10,'Copyright (c) ALEX SOFTWARE, 1991.'
		db	13,10,'DOS Evaluator.   DEva /? for help.'
		db	13,10,10,0
help            db      '─────────────────────── HELP ───────────────────────',13,10
		db	' Usage:  DEva /[U|I]',13,10
		db	' where   I - install resident',13,10
		db	'         U - uninstall',13,10,10
		db	' At the DOS prompt, enter:   /? expression',13,10,10
		db	' Calculated expression consist of',13,10
		db	'signed long integer operands, operators, parentheses',13,10,10
		db	'operand form:    mmm.. (hex), where m=0..9,a..f',13,10
		db	'               0xnnn.. (hex)',13,10
		db	'              or nnn.. (dec), where n=0..9',13,10
		db	'operators:  * , / , + , -',13,10
                db      '────────────────────────────────────────────────────',13,10,0

msg0		db	'MS DOS (PC DOS) 3.30 or higher required.',13,10,0
msg1		db	'DEva not installed.',13,10,0
msg2		db	'DEva already in memory.',13,10,0
msg3		db	'DEva removed from memory.',13,10,0
msg4		db	'DEva: invalid parameter.',13,10,0
msg5		db	13,10
		db	'DEva successfully installed.',13,10
		db	'At the DOS prompt type /? followed by '
		db	'expression you want to calculate.',13,10,0


; procedure SwapInt - swaps vectors Int2Fh and [es:si]

SwapInt		proc
		push	ds
		xor	ax, ax
		mov	ds, ax
		cli
		mov	ax, ds:[2Fh*4]
		xchg	ax, es:[si]
		mov	ds:[2Fh*4], ax
		mov	ax, ds:[2Fh*4+2]
		xchg	ax, es:[si+2]
		mov	ds:[2Fh*4+2], ax
		sti
		pop	ds
		ret
SwapInt		endp

;-----------------------------------------------;
;		INIATIALIZATION			;
;-----------------------------------------------;

begin:		DosCall	44h, 51h
		jnc	BB1
		DosCall	44h, 52h
		jnc	BB1
		DosCall	30h
		xchg	al, ah
		cmp	ax, 31Eh
		jnb	BB2
BB1:		mov	si, Offset msg0
		jmp	short BB7

BB2:		mov	si, Offset coprt
		call	OutStr
		mov	ah, 0AFh
		mov	di, 'AS'
		int	2Fh
		mov	CmdPtr[2], es
		mov	CmdPtr, si
		mov	StkPtr, di

		push	cs
		pop	es
		cld
		mov	di, 80h
		xor	cx, cx
		mov	cl, [di]
		jcxz	BB5
		inc	di
		mov	al, '/'
		repne	scasb
		jz	BB4
BB3:		mov	si, Offset msg4
		mov	al, 4
		jmp	short BB8

BB4:		mov	ax, [di]
		cmp	al, '?'
		jnz	BB6
BB5:		mov	si, Offset help
		jmp	short BB7

BB6:		or	al, ' '
		cmp	al, 'u'
		jz	Remove
		cmp	al, 'i'
		jnz	BB3
		cmp	StkPtr, 'as'
		jnz	Install
		mov	si, Offset msg2
		mov	al, 2
		jmp	short BB8

Remove:		cmp	StkPtr, 'as'
		jz	BB9
		mov	si, Offset msg1
BB7:		mov	al, 1
BB8:		call	OutStr
		DosCall	4Ch

BB9:		les	si, Dword Ptr CmdPtr	; es:si -> old int vector
		call	SwapInt
		DosCall	49h			; free block
		mov	si, Offset msg3
		mov	al, 3
		jmp	BB8

Install:	push	es
		xor	ax, ax
		mov	ds:[80h], al
		dec	ax
		xchg	ax, ds:[2Ch]
		mov	es, ax
		DosCall	49h
		pop	es
		mov	si, Offset Old2FOfs
		mov	[si+2], cs
		call	SwapInt

		mov	si, Offset msg5
		call	OutStr

		mov	dx, Offset coprt
		int	27h

		db	'by K.Mironovich'

text		ends
		end	start