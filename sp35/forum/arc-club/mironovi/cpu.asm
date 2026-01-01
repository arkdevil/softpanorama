;
;	Добрый день!
;	Ниже представлен текст программы, сжимающей файлы типа *.COM.
;	Сжатие происходит за счет удаления длинных цепочек повторяющихся
;	байтов. Данный прицип используется, например, утилитой EXEPACK
;	из пакета MASM. Предлагаемая программа делает это для COM файлов,
;	используя несколько лучший формат упаковки.
;	Среди утилит MS DOS нашлось несколько, которые удалось сократить.
;	Эта программа полезна для тех, кто создает COM файлы, содержащие
;	цепочки повторяющихся байт (массивы, экранные заставки, внутренний
;	стек и проч.). Время распаковки сжатого файла субъективно не
;	ощущается.
;	Автор надеется, что данный исходный текст поможет начинающим
;	осваивать практику написания программ на Ассемблере 8086, etc.
;	Следует заметить, что коды программы можно было бы подсократить,
;	пользуясь техникой обращения к процедурам. Но в данном случае
;	преследовалась цель повышения быстродействия - поэтому коды
;	несколько развернуты. Не совсем корректно написана процедура
;	разбора командной строки  Parse.
;	Данный текст готов к употреблению. Длина получаемого COM файла (720)
;	меньше длины файла VCPU.COM, т.к. последний привит антивирусной
;	вакциной.
;	По вопросам звоните: Москва 252-1734, К.Миронович
;

MAXSIZE		equ	0FE00h
SameLimit	equ	5

Text		segment	para
		assume	cs:Text, ds:Text, es:Text

		ORG	100h

Start:		jmp	Begin

BufLen		dw	0
FilePtr		dw	0

coprt		db	' Copyright (c) ALEX SOFTWARE, 1991.',13,10
		db	' COM2COM Packing Utility. Freeware.',13,10
		db	13,10,'$'
msg1		db	'Packing error.',13,10,'$'
msg2		db	'00% packed.',13,10,'$'
msg3		db	'Input file too big.',13,10,'$'
msg4		db	'Not packed.',13,10,'$'
msg5		db	'Usage:  CPU infile outfile',13,10,'$'
msg6		db	'I/O error.',13,10,'$'
msg7		db	"'MZ' signature found.",13,10,'$'

;---------------------------------------------------------------;
;			PACKING FORMAT:				;
;	| value | count | NUL | - repeated  characters case	;
;	| Hi count | Lo count | - different characters case	;
;---------------------------------------------------------------;

; -- unpacking routine

PP1:		cmp	di, si
		jbe	done
		lodsb
		xchg	ax, cx
		lodsb
		jcxz	PP2			; NUL - rept char
		mov	ch, al
		rep	movsb
		jmp	PP1
PP2:		xchg	ax, cx
		lodsb
		rep	stosb
		jmp	PP1
done:		cld
		xchg	ax, dx
		retn
UnPakSz		equ	$-PP1

		db	0BEh			; mov	si, data
Source		dw	0
		db	0BFh			; mov	di, data
Target		dw	0
		mov	bx, 100h
		push	bx
		mov	cx, UnPakSz-1
		std
		rep	movsb
		push	di
		movsb
		dw	07C7h			; mov Word Ptr [bx], data
Storage1	dw	0
		dw	47C6h			; mov Byte Ptr [bx+2], data
		db	02h
Storage2	db	0
		xchg	ax, dx
		mov	ax, cx
		retn
UnPakSz2	equ	$-PP1


Parse		proc
Skip:		lodsb
		cmp	al, ' '
		jz	Skip
		dec	si
		push	si
Skip2:		lodsb
		cmp	al, ' '
		jz	Tail
		cmp	al, 13
		jnz	Skip2
Tail:		mov	Byte Ptr [si-1], 0
		pop	dx
		retn
Parse		endp


Begin:          mov	dx, Offset coprt
		mov	ah, 9
		int	21h
		mov	si, 80h
		xor	cx, cx
		mov	cl, ds:[si]
		mov	dx, Offset msg5
		jcxz	NoCmd
		inc	si
		call	Parse
		mov	ax, 3D00h		; open to read
		int	21h
		jnc	Opened
		mov	dx, Offset msg6
NoCmd:		mov	ah, 9
		int	21h
		jmp	Quit

Opened:		xchg	ax, bx
		xor	cx, cx
		xor	dx, dx
		mov	ax, 4202h		; seek to end
		int	21h
		jc	Error
		or	dx, dx
		jnz	BadSize
		mov	di, Offset Buffer
		add	ax, di
		cmp	ax, MAXSIZE
		jb	GoodSize
BadSize:	mov	dx, Offset msg3
		jmp	Close
Error:		mov	dx, Offset msg6
		jmp	Close

GoodSize:	mov	BufLen, ax
		xor	cx, cx
		xor	dx, dx
		mov	ax, 4200h		; seek to start
		int	21h
		jc	Error
		mov	dx, di			; Buffer
		dec	cx
		mov	ah, 3Fh			; read
		int	21h
		jc	Error
		mov	ah, 3Eh			; close
		int	21h
		call	Parse
		mov	FilePtr, dx

; Packer main routine
; 	al - char, ah - previous char
;	cx - 'same'   series count
;	dx - 'differ' series count

		mov	si, di
		xor	dx, dx

FirstLoop:	cmp	si, BufLen
		jnz	Continue
Exit:		mov	dx, Offset msg4
		jmp	Close

Continue:	lodsw
		dec	si
		cmp	al, ah
		jnz	FirstLoop
		mov	di, si
		inc	si
		mov	cx, 2
FirstSame:	cmp	si, BufLen
		jz	Exit
		lodsb
		cmp	al, ah
		jnz	NoFirstSame
		inc	cl
		jnz	FirstSame
		mov	al, 255
		stosb				; count
		inc	al
		stosb				; NUL
		inc	cl
		jmp	short SameLoop

NoFirstSame:    xchg	al, ah			; al - previous
		cmp	cl, SameLimit
		ja	NoDiffer2
		dec	si
		jmp	FirstLoop

Same:		mov	cx, 2
		sub	dx, cx
SameLoop:	cmp	si, BufLen
		jz	SameFinis
		lodsb
		cmp	al, ah
		jnz	NoSame
		inc	cl
		jnz	SameLoop
		or	dx, dx
		jz	Same1
		xchg	ax, dx
		xchg	al, ah			; MSB, then LSB
		stosw
		xchg	ax, dx
		xor	dx, dx
Same1:		stosb				; value
		mov	al, 255
		stosb				; count
		inc	al
		stosb				; NUL
		inc	cl
		jmp	SameLoop

NoSame:		xchg	al, ah			; al - previous
		or	dx, dx
		jz	NoDiffer
		cmp	cl, SameLimit
		ja	StoreSame
StoreDiffer:	add	dx, cx
		rep	stosb
		inc	dx
		jmp	short DiffLoop

StoreSame:	xchg	ax, dx
		xchg	al, ah			; MSB, then LSB
		stosw
		xchg	ax, dx
		xor	dx, dx
NoDiffer:	cmp	cl, SameLimit
		jna	StoreDiffer		; dx - zero
		stosb				; value
NoDiffer2:	mov	al, cl
		stosb				; count
		xor	al, al
		stosb				; NUL
		xor	cx, cx
		jmp	StoreDiffer

DiffLoop:	cmp	si, BufLen
		jz	DiffFinis
		lodsb
		inc	dx
		xchg	al, ah			; al - previos
		cmp	al, ah
		jz	Same
		stosb
		jmp	DiffLoop

DiffFinis:	mov	al, ah
		stosb
		xchg	ax, dx
		xchg	al, ah			;MSB, then LSB
		stosw
		jmp	short Finis

SameFinis:	cmp	cl, SameLimit
		jae	SameFinis1
		add	dx, cx
		rep	stosb
SameFinis1:	or	dx, dx
		jz	SameFinis2
		xchg	ax, dx
		xchg	al, ah
		stosw
		xchg	ax, dx
SameFinis2:	jcxz	Finis
		stosb				; value
		mov	al, cl
		stosb				; count
		xor	al, al
		stosb				; NUL

Finis:          cmp	si, di
		ja	Packed
		mov	dx, Offset msg1
		jmp	short Close

Packed:		mov	ax, Word Ptr Buffer
		cmp	ax, Word Ptr msg7+1
		jnz	NoEXE
		mov	dx, Offset msg7
		jmp	short Close

NoEXE:		mov	Storage1, ax
		mov	al, Buffer[2]
		mov	Storage2, al
		mov	ax, di
		sub	ax, (Offset Buffer)-UnPakSz+3
		mov	Byte Ptr Buffer, 0E9h	; jmp near opcode
		mov	Word Ptr Buffer[1], ax	; range
		add	ax, 102h
		mov	Source, ax
		mov	ax, si
		sub	ax, (Offset Buffer)-UnPakSz-0FFh
		mov	Target, ax
		mov	cx, UnPakSz2
		push	si
		mov	si, Offset PP1
		rep	movsb
		pop	si
		mov	dx, FilePtr
		xor	cx, cx
		mov	ah, 3Ch			; create file
		int	21h
		mov	dx, Offset msg6
		jc	Close
		xchg	ax, bx
		mov	dx, Offset Buffer
		mov	cx, di
		sub	cx, dx
		mov	ah, 40h			; write
		int	21h
		sub	si, dx
		mov	cx, 100
		mul	cx
		div	si
		sub	cx, ax
		xchg	ax, cx
		aam
		xchg	al, ah
		add	Word Ptr msg2, ax
		mov	dx, Offset msg2
Close:		mov	ah, 9
		int	21h
		mov	ah, 3Eh			; close file
		int	21h

Quit:		mov	ax, 4C00h
		int	21h

		even
Buffer		db	13,10,' by K.Mironovich'

Text		ends
		end	Start
