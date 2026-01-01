; #compile /ml /w+ /t /m8 /zi
; #link    nolink

						Include	LZ.ASI
;-------------------------------------------------------------
;
;	Project:	YAR compressor
;	Module:		LZU.ASM
;	Purpose:
;			Contains unpacker's critical code
;			for LZ.C
;
;	(C) 1991-92 Compact Soft
;	Written by: cs:dk
;
;-------------------------------------------------------------


; =====	Externals

.code
global	p_reader : CODEPTR
global	p_writer : CODEPTR


; =====	Local Data

.data

LenTable	db	3,	0,	1,	2
		db	4,	5,	6,	9
		db	10,	11,	12,	13
		db	14,	15,	7,	8

DistTable	db	3,	4,	5,	0
		db	1,	2,	6,	7
		db	8,	9,	10,	11
		db	12,	13,	14,	15


LenStack	label	byte
		i	= 1
		REPT	TREESIZE
			db	i
			i	= i + 1
		ENDM

DistStack	label	byte
		i	= 0
		REPT	TREESIZE
			db	i
			i	= i + 1
		ENDM

.data?

UnpackInBuffer	label	byte
		db	4096 dup (?)
UnpackInBufferSafetyEnd	label	byte
		db	6 dup (?)	; max # of bytes needed in pass
UnpackInBufferEnd	label	byte

; minimum buffer size equals (MD == 4096) + ML, we use MD + ML + MD
MaxDistance	equ	4096

UnpackOutBuffer	label	byte
		db	(MaxDistance * 2) dup (?)
SafetyEnd	label	byte
		db	(254 + TREESIZE) dup (?) ; 254 'cause 255 is EOF mark


; =====	Unpacking routines
.code

proc	FillInputBuffer
; Ensures that UnpackInBuffer is full

	; move data left at end of buffer to beginning
	push	cx di
	mov	di, offset UnpackInBuffer
	mov	cx, offset UnpackInBufferEnd
	sub	cx, si
	jcxz	@@ok
	cld
	rep	movsb
@@ok:
	mov	si, di
	pop	di cx

	push	ax bx cx dx es

	mov	dx, offset UnpackInBufferEnd
	sub	dx, si
	; dx = number of free bytes in buffer

	call	p_reader, ds si, dx
	; p_reader (const void *ptr, size_t size);

	pop	es dx cx bx ax

	lea	si, UnpackInBuffer
	cld
	ret
endp	FillInputBuffer

proc	writeBuffer
; IN:
;	dx = bytes to write

	lea	bx, UnpackOutBuffer
	call	p_writer, ds bx, dx
	; p_writer (const void *ptr, size_t size);

	ret
endp	writeBuffer

proc	MoveUnpackBuffer
; ensures that UnpackOutBuffer is flushed except dictionary size

	push	ax bx cx dx es

	mov	dx, di		; get ptr to UnpackOutBuffer
	sub	dx, (offset UnpackOutBuffer) + MaxDistance
	; get current buffer size and left MaxDistance of it

	call	writeBuffer
	pop	es dx cx bx ax

	; move rest of buffer (MaxDistance bytes)
	push	cx si
	mov	si, di
	sub	si, MaxDistance
	mov	di, offset UnpackOutBuffer
	mov	cx, MaxDistance
	cld
	rep	movsb
	pop	si cx
	; di is set authomagically, and cld stays

	ret
endp	MoveUnpackBuffer

proc	FlushUnpackBuffer

	push	ax bx cx dx es

	mov	dx, di		; get ptr to UnpackOutBuffer
	sub	dx, (offset UnpackOutBuffer)
	; get full current buffer size

	call	writeBuffer
	pop	es dx cx bx ax

	ret
endp	FlushUnpackBuffer


global	_SquoUnpack : PROC
; void	_SquoUnpack (void)

proc	_SquoUnpack

; Registers usage:
;	bp	= bit buffer
;	dx	= size of bp (in bits, 0 means empty)
;	cx	= decoded length
;	bx	= decoded distance and encoded data
;	ds:si	-> source buffer
;	es:di	-> destination buffer
;	ax	= tmp

FillBitBuffer	macro
	lodsw
	xchg	bp, ax		; = 'mov bp, ax', but shorter
	mov	dx, BITS
endm

GetBit	macro	n
	shr	bp, 1
	rcl	bx, 1
	dec	dx
	jz	GetBit$Load&n
GetBit$Cont&n:
	;; continue after filling up the bit buffer
endm

LoadBit	macro	n

	even
GetBit$Load&n:
	FillBitBuffer
	jmp	short GetBit$Cont&n
endm

	uses	bp, si, di

	push	ds
	pop	es

	lea	si, UnpackInBufferEnd
	call	FillInputBuffer
	lea	di, UnpackOutBuffer

	cld

	FillBitBuffer
	jmp	@@getLength

@@saveData:
	call	MoveUnpackBuffer
	jmp	@@ok1

@@loadData:
	call	FillInputBuffer
	jmp	@@ok2

	IRP	num,	<l1, l2, l3, l4, l5, l6, l7>
		LoadBit	num
	ENDM

@@copyChar:
	movsb
	; NOTE: implicit 'jmp @@getLength'

@@getLength:

	; purge UnpackOutBuffer if necessary
	cmp	di, offset SafetyEnd
	ja	@@saveData
@@ok1:

	; fill UnpackInBuffer if necessary
	cmp	si, offset UnpackInBufferSafetyEnd
	ja	@@loadData
@@ok2:

	xor	bx, bx

	GetBit	l1
	GetBit	l2
	or	bx, bx
	jnz	@@decodeLength	; do 01, 10, 11
	GetBit	l3
	GetBit	l4
	or	bx, bx
	jz	@@decodeLength	; do 0000
	GetBit	l5
	cmp	bx, 00100b
	jb	@@get6
	cmp	bx, 00110b
	jbe	@@decodeLength	; do 00100, 00101, 00110
@@get6:
	GetBit	l6
	cmp	bx, 000111b
	jae	@@decodeLength	; do 001110, 001111, 000111
	GetBit	l7
			; do 6 others: 0001 + [000 .. 101]
@@decodeLength:
	mov	bl, LenTable [bx]
	xor	cx, cx
	mov	cl, LenStack [bx]

	IF	BookStack
		push	cx
		mov	cx, bx
		jcxz	@@lenStackOk

		push	si di
		lea	di, LenStack [bx]
		lea	si, LenStack [bx - 1]
		std
		rep	movsb
		cld
		pop	di si

	@@lenStackOk:
		pop	cx
		mov	LenStack [0], cl
	ENDIF

	cmp	cx, 1
	je	@@copyChar
	cmp	cx, TREESIZE
	jae	@@addLen

@@getDistance:
	xor	bx, bx

	GetBit	d1
	GetBit	d2
	cmp	bx, 11b
	jae	@@decodeDistance	; do 11
	GetBit	d3
	cmp	bx, 100b
	jae	@@decodeDistance	; do 100, 101
	GetBit	d4
	cmp	bx, 0010b
	jbe	@@decodeDistance	; do 0000, 0001, 0010
	GetBit	d5
			; do 10 others: [00111 .. 01111]
@@decodeDistance:
	mov	bl, DistTable [bx]

	IF	BookStack
		push	cx si di
		lea	di, DistStack [bx]
		lea	si, DistStack [bx - 1]

		mov	cx, bx
		mov	bh, DistStack [bx]
		jcxz	@@distStackOk

		std
		rep	movsb
		cld
		mov	DistStack [0], bh

	@@distStackOk:
		pop	di si cx
	ELSE
		mov	bh, DistStack [bx]
	ENDIF

	lodsb
	mov	bl, al		; get low (distance)

	; now copy string
	inc	bx
	push	si
	mov	si, di
	sub	si, bx
	rep	movsb
	pop	si
	jmp	@@getLength

@@addLen:
	lodsb
	cmp	al, 0ffh	; !!! EOF mark
	je	@@exit
	add	cl, al
	adc	ch, 0
	jmp	@@getDistance


IRP	num,	<d1, d2, d3, d4, d5>
	LoadBit	num
ENDM

@@exit:
	call	FlushUnpackBuffer

	ret
endp	_SquoUnpack


end	; of LZU.ASM

