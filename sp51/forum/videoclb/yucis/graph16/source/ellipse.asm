;
; Name:		Ellipse
;
; Function:	Draw an ellipse.
;
; Caller:	Microsoft C:
;
;			void Ellipse(xc,yc,a,b,n);
;
;			int xc,yc;		/* center of ellipse */
;
;			int a,b;		/* major and minor axes */
;
;			int n;			/* pixel value */
;

RMWbits		EQU	0		; read-modify-write bits

		.model medium

		EXTRN	C BytesPerLine:word
		EXTRN	PixelAddr:proc

		.code

		PUBLIC	C Ellipse
Ellipse		PROC C	uses si di,ARGxc,ARGyc,ARGa,ARGb,ARGn
		local	ULAddr,URAddr,LLAddr,LRAddr,LMask:byte,RMask:byte,\
			VARd:dword,VARdx:dword,VARdy:dword,Asquared:dword,\
			Bsquared:dword,TwoAsquared:dword,TwoBsquared:dword

; set Graphics Controller Mode register

		mov	dx,3CEh		; DX := Graphics Controller I/O port
		mov	ax,0005h	; AL := Mode register number
					; AH := Write Mode 0 (bits 0,1)
		out	dx,ax		;	Read Mode 0 (bit 4)

; set Data Rotate/Function Select register

		mov	ah,RMWbits	; AH := Read-Modify-Write bits
		mov	al,3		; AL := Data Rotate/Function Select reg
		out	dx,ax

; set Set/Reset and Enable Set/Reset registers

		mov	ah,byte ptr ARGn		; AH := pixel value
		mov	al,0		; AL := Set/Reset reg number
		out	dx,ax

		mov	ax,0F01h	; AH := value for Enable Set/Reset (all
					;  bit planes enabled)
		out	dx,ax		; AL := Enable Set/Reset reg number

; initial constants

		mov	ax,ARGa
		mul	ax
		mov	word ptr Asquared,ax
		mov	word ptr Asquared+2,dx	; a^2
		shl	ax,1
		rcl	dx,1
		mov	word ptr TwoAsquared,ax
		mov	word ptr TwoAsquared+2,dx ; 2*a^2

		mov	ax,ARGb
		mul	ax
		mov	word ptr Bsquared,ax
		mov	word ptr Bsquared+2,dx	; b^2
		shl	ax,1
		rcl	dx,1
		mov	word ptr TwoBsquared,ax
		mov	word ptr TwoBsquared+2,dx ; 2*b^2
;
; plot pixels from (0,b) until dy/dx = -1
;

; initial buffer address and bit mask

		mov	ax,BytesPerLine	; AX := video buffer line length
		mul	ARGb		; AX := relative byte offset of b
		mov	si,ax
		mov	di,ax

		mov	ax,ARGyc	; AX := yc
		mov	bx,ARGxc	; BX := xc
		call	PixelAddr	; AH := bit mask
					; ES:BX -> buffer
					; CL := # bits to shift left
		mov	ah,1
		shl	ah,cl		; AH := bit mask for first pixel
		mov	LMask,ah
		mov	RMask,ah

		add	si,bx		; SI := offset of (0,b)
		mov	ULAddr,si
		mov	URAddr,si
		sub	bx,di		; AX := offset of (0,-b)
		mov	LLAddr,bx
		mov	LRAddr,bx

; initial decision variables

		xor	ax,ax
		mov	word ptr VARdx,ax
		mov	word ptr VARdx+2,ax	; dx = 0

		mov	ax,word ptr TwoAsquared
		mov	dx,word ptr TwoAsquared+2
		mov	cx,ARGb
		call	LongMultiply	; perform 32-bit by 16-bit mulitply
		mov	word ptr VARdy,ax
		mov	word ptr VARdy+2,dx	; dy = TwoAsquared * b

		mov	ax,word ptr Asquared
		mov	dx,word ptr Asquared+2	; DX:AX = Asquared
		sar	dx,1
		rcr	ax,1
		sar	dx,1
		rcr	ax,1		; DX:AX = Asquared/4

		add	ax,word ptr Bsquared
		adc	dx,word ptr Bsquared+2	; DX:AX = Bsquared + Asquared/4
		mov	word ptr VARd,ax
		mov	word ptr VARd+2,dx

		mov	ax,word ptr Asquared
		mov	dx,word ptr Asquared+2
		mov	cx,ARGb
		call	LongMultiply	; DX:AX = Asquared*b
		sub	word ptr VARd,ax
		sbb	word ptr VARd+2,dx; d = Bsquared - Asquared*b+Asquared/4

; loop until dy/dx >= -1

		mov	bx,ARGb		; BX := initial y-coordinate

		xor	cx,cx		; CH := 0 (initial y-increment)
					; CL := 0 (initial x-increment)
L10:		mov	ax,word ptr VARdx
		mov	dx,word ptr VARdx+2
		sub	ax,word ptr VARdy
		sbb	dx,word ptr VARdy+2
		jns	L20		; jump if dx>=dy

		call	Set4Pixels

		mov	cx,1		; CH := 0 (y-increment)
					; CL := 1 (x-increment)
		cmp	word ptr VARd+2,0
		js	L11		; jump if d < 0

		mov	ch,1		; increment in y direction
		dec	bx		; decrement current y-coordinate

		mov	ax,word ptr VARdy
		mov	dx,word ptr VARdy+2
		sub	ax,word ptr TwoAsquared
		sbb	dx,word ptr TwoAsquared+2 ; DX:AX := dy - TwoAsquared
		mov	word ptr VARdy,ax
		mov	word ptr VARdy+2,dx	; dy -= TwoAsquared

		sub	word ptr VARd,ax
		sbb	word ptr VARd+2,dx	; d -= dy

L11:		mov	ax,word ptr VARdx
		mov	dx,word ptr VARdx+2
		add	ax,word ptr TwoBsquared
		adc	dx,word ptr TwoBsquared+2 ; DX:AX := dx + TwoBsquared
		mov	word ptr VARdx,ax
		mov	word ptr VARdx+2,dx	; dx += TwoBsquared

		add	ax,word ptr Bsquared
		adc	dx,word ptr Bsquared+2	; DX:AX := dx + Bsquared
		add	word ptr VARd,ax
		adc	word ptr VARd+2,dx	; d += dx + Bsquared

		jmp	L10
;
; plot pixels from current (x,y) until y < 0
;

; initial buffer address and bit mask

L20:		push	bx		; preserve current y-coordinate
		push	cx		; preserve x- and y-increments

		mov	ax,word ptr Asquared
		mov	dx,word ptr Asquared+2
		sub	ax,word ptr Bsquared
		sbb	dx,word ptr Bsquared+2	; DX:AX := Asquared-Bsquared

		mov	bx,ax
		mov	cx,dx		; CX:BX := (Asquared-Bsquared)

		sar	dx,1
		rcr	ax,1		; DX:AX := (Asquared-Bsquared)/2
		add	ax,bx
		adc	dx,cx		; DX:AX := 3*(Asquared-Bsquared)/2

		sub	ax,word ptr VARdx
		sbb	dx,word ptr VARdx+2
		sub	ax,word ptr VARdy
		sbb	dx,word ptr VARdy+2	; DX:AX := 3*(Asquared-Bsquared)/2 - (dx+dy)

		sar	dx,1
		rcr	ax,1		; DX:AX :=
					;  ( 3*(Asquared-Bsquared)/2 - (dx+dy) )/2
		add	word ptr VARd,ax
		adc	word ptr VARd+2,dx	; update d

; loop until y < 0

		pop	cx		; CH,CL := y- and x-increments
		pop	bx		; BX := y

L21:		call	Set4Pixels

		mov	cx,100h		; CH := 1 (y-increment)
					; CL := 0 (x-increment)

		cmp	word ptr VARd+2,0
		jns	L22		; jump if d >= 0

		mov	cl,1		; increment in x direction

		mov	ax,word ptr VARdx
		mov	dx,word ptr VARdx+2
		add	ax,word ptr TwoBsquared
		adc	dx,word ptr TwoBsquared+2 ; DX:AX := dx + TwoBsquared
		mov	word ptr VARdx,ax
		mov	word ptr VARdx+2,dx	; dx += TwoBsquared

		add	word ptr VARd,ax
		adc	word ptr VARd+2,dx	; d += dx

L22:		mov	ax,word ptr VARdy
		mov	dx,word ptr VARdy+2
		sub	ax,word ptr TwoAsquared
		sbb	dx,word ptr TwoAsquared+2 ; DX:AX := dy - TwoAsquared
		mov	word ptr VARdy,ax
		mov	word ptr VARdy+2,dx	; dy -= TwoAsquared

		sub	ax,word ptr Asquared
		sbb	dx,word ptr Asquared+2	; DX:AX := dy - Asquared
		sub	word ptr VARd,ax
		sbb	word ptr VARd+2,dx	; d += Asquared - dy

		dec	bx		; decrement y
		jns	L21		; loop if y >= 0


; restore default Graphics Controller registers

Lexit:		mov	ax,0FF08h	; default Bit Mask
		mov	dx,3CEh
		out	dx,ax

		mov	ax,0003		; default Function Select
		out	dx,ax

		mov	ax,0001		; default Enable Set/Reset
		out	dx,ax
		ret

Ellipse		ENDP


Set4Pixels	PROC	near	; Call with:  CH := y-increment (0, -1)
				;	      CL := x-increment (0, 1)

		push	ax bx dx	; preserve these regs

		mov	dx,3CEh		; DX := Graphics Controller port

		xor	bx,bx		; BX := 0
		test	ch,ch
		jz	L30		; jump if y-increment = 0

		mov	bx,BytesPerLine	; BX := positive increment
		neg	bx		; BX := negative increment

L30:		mov	al,8		; AL := Bit Mask reg number

; pixels at (xc-x,yc+y) and (xc-x,yc-y)

		xor	si,si		; SI := 0
		mov	ah,LMask

		rol	ah,cl		; AH := bit mask rotated horizontally
		rcl	si,1		; SI := 1 if bit mask rotated around
		neg	si		; SI := 0 or -1

		mov	di,si		; SI,DI := left horizontal increment

		add	si,ULAddr	; SI := upper left addr + horiz incr
		add	si,bx		; SI := new upper left addr
		add	di,LLAddr
		sub	di,bx		; DI := new lower left addr

		mov	LMask,ah	; update these variables
		mov	ULAddr,si
		mov	LLAddr,di

		out	dx,ax		; update Bit Mask register

		mov	ch,es:[si]	; update upper left pixel
		mov	es:[si],ch
		mov	ch,es:[di]	; update lower left pixel
		mov	es:[di],ch


; pixels at (xc+x,yc+y) and (xc+x,yc-y)

		xor	si,si		; SI := 0
		mov	ah,RMask

		ror	ah,cl		; AH := bit mask rotated horizontally
		rcl	si,1		; SI := 1 if bit mask rotated around

		mov	di,si		; SI,DI := right horizontal increment

		add	si,URAddr	; SI := upper right addr + horiz incr
		add	si,bx		; SI := new upper right addr
		add	di,LRAddr
		sub	di,bx		; DI := new lower right addr

		mov	RMask,ah	; update these variables
		mov	URAddr,si
		mov	LRAddr,di

		out	dx,ax		; update Bit Mask register

		mov	ch,es:[si]	; update upper right pixel
		mov	es:[si],ch
		mov	ch,es:[di]	; update lower right pixel
		mov	es:[di],ch

		pop	dx bx ax
		ret

Set4Pixels	ENDP


LongMultiply	PROC	near	; Caller:	DX = u1 (hi-order word
				;		 of 32-bit number)
				;		AX = u2 (lo-order word)
				;		CX = v1 (16-bit number)
				; Returns:	DX:AX = 32-bit result)

		push	ax		; preserve u2
		mov	ax,dx		; AX :=
		mul	cx		; AX := high-order word of result
		xchg	ax,cx		; AX := v1, CX := high-order word
		pop	dx		; DX := u2
		mul	dx		; AX := low-order word of result
					; DX := carry
		add	dx,cx		; CX := high-order word of result
		ret

LongMultiply	ENDP

		END
