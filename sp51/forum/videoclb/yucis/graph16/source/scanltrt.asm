;
; Name:		ScanRight & ScanLeft
;
; Function:	Scan for a pixel of a given value in 16-color EGA/VGA graphics
;
; Caller:	Microsoft C:
;
;		int ScanRight(x,y);
;		int ScanLeft (x,y);
;
;		int x,y;			/* starting pixel */
;
;		extern	int __BorderValue;	/* value of border pixel */
;
;		Returns	the x-coordinate of the	right/leftmost border pixel.
;

		.model	medium

		EXTRN	PixelAddr:proc
		EXTRN	C BytesPerLine:word
					; 80 for most 16-color graphics modes
					;  (40 for 320x200 16-color)
		EXTRN	C __BorderValue:byte

		.code
		locals	L0

ByteOffsetShift	EQU	3		; used to convert pixels to byte offset

		PUBLIC	C ScanRight, C	ScanLeft
ScanRight	PROC	C uses si di , ARGx,ARGy

; calculate pixel address of (0,y)

		mov	ax,ARGy		; AX :=	y
		xor	bx,bx		; BX :=	0
		call	PixelAddr	; ES:BX -> buffer
		mov	di,bx		; ES:DI	-> buffer

; calculate offset of x	in row

		mov	ax,ARGx
		mov	si,ax		; SI,AX	:= x
		mov	cl,ByteOffsetShift
		shr	si,cl		; SI :=	offset of x in row y

		add	di,si		; DI :=	offset of x in buffer

; calculate a bit mask for the first byte to scan

		mov	cl,al
		and	cl,7		; CL :=	x & 7
		mov	ch,0FFh
		shr	ch,cl		; CH :=	bit mask for first scanned byte

; configure the	Graphics Controller

		mov	dx,3CEh		; DX :=	Graphics Controller port addr

		mov	ah,__BorderValue	; AH := pixel value for Color Compare reg
		mov	al,2		; AL :=	Color Compare Reg number
		out	dx,ax

		mov	ax,805h		; AH :=	00001000b (Read	Mode 1)
		out	dx,ax		; AL :=	Mode reg number

		mov	ax,0F07h	; AH :=	00001111b (Color Compare reg value)
		out	dx,ax		; AL :=	Color Compare reg number

; inspect the first byte for border pixels

		mov	al,es:[di]	; AL :=	nonzero	bits corresponding to
					;  border pixels
		inc	di		; ES:DI	-> next	byte to	scan
		and	al,ch		; apply	bit mask
		jnz	L01		; jump if border pixel(s) found

; scan remainder of line for border pixels

		mov	cx,BytesPerLine
		sub	cx,si		; CX :=	BytesPerLine - (byte offset of
					;  starting pixel)
		dec	cx		; CX :=	# of bytes to scan

		repe	scasb		; scan until nonzero byte read;	i.e.,
					;  border pixel(s) found

; compute x value of border pixel

		mov	al,es:[di-1]	; AL :=	last byte compared

L01:		sub	di,bx		; DI :=	offset of byte past the	one which
					;  contains a border pixel
		mov	cl,ByteOffsetShift
		shl	di,cl		; DI :=	x-coordinate of	1st pixel in byte

		mov	cx,8		; CX :=	loop limit

L02:		shl	al,1		; isolate first	border pixel
		jc	L03

		loop	L02

L03:		sub	di,cx		; DI :=	x-coordinate of	border pixel

; restore default Graphics Controller state and	return to caller

		mov	ax,2		; AH :=	0 (default Color Compare value)
		out	dx,ax		; restore Color	Compare	reg

		mov	al,5		; AH :=	0, AL := 5
		out	dx,ax		; restore Mode reg

		mov	ax,di		; AX :=	return value

		ret

ScanRight	ENDP

ScanLeft	PROC	C	uses si	di , ARGx,ARGy

; calculate pixel address of (0,y)

		mov	ax,ARGy		; AX :=	y
		xor	bx,bx		; BX :=	0
		call	PixelAddr	; ES:BX -> buffer
		mov	di,bx		; ES:DI	-> buffer

; calculate offset of x	in row

		mov	ax,ARGx
		mov	si,ax		; SI,AX	:= x
		mov	cl,ByteOffsetShift
		shr	si,cl		; SI :=	offset of x in row y

		add	di,si		; DI := offset of x in buffer

; calculate a bit mask for the first byte to scan

		and	al,7		; AL :=	x & 7
		mov	cx,0FF07h
		sub	cl,al
		shl	ch,cl		; CH := bit mask for first scanned byte

; configure the	Graphics Controller

		mov	dx,3CEh		; DX :=	Graphics Controller port addr

		mov	ah,__BorderValue; AH := pixel value for Color Compare reg
		mov	al,2		; AL :=	Color Compare Reg number
		out	dx,ax

		mov	ax,805h		; AH :=	00001000b (Read	Mode 1)
		out	dx,ax		; AL :=	Mode reg number

		mov	ax,0F07h	; AH :=	00001111b (Color Compare reg value)
		out	dx,ax		; AL :=	Color Compare reg number

; inspect the first byte for border pixels

		mov	al,es:[di]	; AL := nonzero bits corresponding to
					;  border pixels
		dec	di		; ES:DI -> next byte to scan

		and	al,ch		; apply	bit mask
		jnz	L01		; jump if border pixel(s) found

; scan remainder of line for border pixels

		mov	cx,si		; CX :=	(byte offset of	starting pixel)
					; CX :=	# of bytes to scan
		pushf
		std
		repe	scasb		; scan until nonzero byte read;	i.e.,
					;  border pixel(s) found
		popf

; compute x value of border pixel

		mov	al,es:[di+1]	; AL :=	last byte compared

L01:		sub	di,bx	    ; DI := offset of byte past	the one	which
				    ;  contains	a border pixel
		inc	di
		mov	cl,ByteOffsetShift
		shl	di,cl		; DI :=	x-coordinate of	1st pixel in byte

		mov	cx,7		; CX :=	loop limit

L02:		shr	al,1		; isolate first	border pixel
		jc	L03

		loop	L02

L03:		add	di,cx		; DI :=	x-coordinate of	border pixel

; restore default Graphics Controller state and	return to caller

		mov	ax,2		; AH :=	0 (default Color Compare value)
		out	dx,ax		; restore Color	Compare	reg

		mov	al,5		; AH :=	0, AL := 5
		out	dx,ax		; restore Mode reg

		mov	ax,di		; AX :=	return value

		ret

ScanLeft	ENDP
		END
