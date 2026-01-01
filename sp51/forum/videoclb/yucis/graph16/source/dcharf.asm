;
; Name:		DisplayCharFont
;
; Function:	Display a character in native EGA and VGA graphics modes
;		with the specified font at global pointer   "far *FontTable"
;		with the size specified in global var  "int FontSize"
;
; Caller:	Microsoft C:
;
;			void DisplayCharFont(c,x,y,fgd,bkgd);
;
;			int c;			/* character code */
;
;			int x,y;		/* upper left pixel */
;
;			int fgd,bkgd;		/* foreground and background
;						    pixel values */
;

RMWbits		=	18h		; Read-Modify-Write bits

		.model medium

		EXTRN	C BytesPerLine:word, C FontSize:word
		EXTRN	C FontTable:far ptr
		EXTRN 	PixelAddr:proc
		
		.code

		PUBLIC	C DisplayCharFont
DisplayCharFont	PROC C	uses si di ds, ARGc,ARGx,ARGy,ARGfgd:byte,ARGbkgd:byte
		local	VARshift

; calculate first pixel address

		mov	ax,ARGy		; AX := y
		mov	bx,ARGx		; BX := x
		call	PixelAddr	; ES:BX -> buffer
					; CL := # bits to shift left to mask
					;  pixel
		inc	cx
		and	cl,7		; CL := # bits to shift to mask char

		mov	ch,0FFh
		shl	ch,cl		; CH := bit mask for right side of char
		mov	VARshift,cx

		push	es		; preserve video buffer segment
		mov	si,bx		; SI := video buffer offset

; set up character definition table addressing

		mov	cx,FontSize	; CX := POINTS (pixel rows in character)

		mov	ax,ARGc		; AL := character code
		les	di,FontTable	; ES:DI -> start of character table
		mul	cl		; AX := offset into char def table
					;  (POINTS * char code)
		add	di,ax		; DI := addr of char def


		pop	ds		; DS:SI -> video buffer

; set up Graphics Controller registers

		mov	dx,3CEh		; Graphics Controller address reg port

		mov	ax,0A05h	; AL :=  Mode register number
					; AH :=  Write Mode 2 (bits 0-1)
					;	 Read Mode 1 (bit 4)
		out	dx,ax

		mov	ah,RMWbits	; AH := Read-Modify-Write bits
		mov	al,3		; AL := Data Rotate/Function Select reg
		out	dx,ax

		mov	ax,0007		; AH := Color Don't Care bits
					; AL := Color Don't Care reg number
		out	dx,ax		; "don't care" for all bit planes

; select output routine depending on whether character is byte-aligned

		mov	bl,ARGfgd	; BL := foreground pixel value
		mov	bh,ARGbkgd	; BH := background pixel value

		cmp	byte ptr VARshift,0   ; test # bits to shift
		jne	L20		; jump if character is not byte-aligned


; routine for byte-aligned characters

		mov	al,8		; AL := Bit Mask register number

L10:		mov	ah,es:[di]	; AH := pattern for next row of pixels
		out	dx,ax		; update Bit Mask register
		and	[si],bl		; update foreground pixels

		not	ah
		out	dx,ax
		and	[si],bh		; update background pixels

		inc	di		; ES:DI -> next byte in char def table
		add	si,ss:BytesPerLine; increment to next line in video buffer
		loop	L10

		jmp	short Lexit


; routine for non-byte-aligned characters

L20:		push	cx		; preserve loop counter
		mov	cx,VARshift	; CH := mask for left side of character
					; CL := # bits to shift left
; left side of character

		mov	al,es:[di]	; AL := bits for next row of pixels
		xor	ah,ah
		shl	ax,cl		; AH := bits for left side of char
					; AL := bits for right side of char
		push	ax		; save bits for right side on stack
		mov	al,8		; AL := Bit Mask Register number
		out	dx,ax		; set bit mask for foreground pixels

		and	[si],bl		; update foreground pixels

		not	ch		; CH := mask for left side of char
		xor	ah,ch		; AH := bits for background pixels
		out	dx,ax		; set bit mask

		and	[si],bh		; update background pixels

; right side of character

		pop	ax
		mov	ah,al		; AH := bits for right side of char
		mov	al,8
		out	dx,ax		; set bit mask

		inc	si		; DS:SI -> right side of char in buffer

		and	[si],bl		; update foreground pixels

		not	ch		; CH := mask for right side of char
		xor	ah,ch		; AH := bits for background pixels
		out	dx,ax		; set bit mask

		and	[si],bh		; update background pixels

; increment to next row of pixels in character

		inc	di		; ES:DI -> next byte in char def table
		dec	si
		add	si,ss:BytesPerLine ; DS:SI -> next line in video buffer

		pop	cx
		loop	L20

; restore default Graphics Controller registers

Lexit:		mov	ax,0FF08h	; default Bit Mask
		out	dx,ax

		mov	ax,0005		; default Mode register
		out	dx,ax

		mov	ax,0003		; default Data Rotate/Function Select
		out	dx,ax

		mov	ax,0F07h	; default Color Don't Care
		out	dx,ax

		ret

DisplayCharFont	ENDP

		END
