;
; Name:		ReadPixel
;
; Function:	Read the value of a pixel in EGA/VGA 4-plane 16-color
;						graphics modes
;
; Caller:	Microsoft C:
;
;			int ReadPixel(x,y);
;
;			int x,y;		/* pixel coordinates */
;
		.model	medium
		EXTRN	PixelAddr:proc
		.code

		PUBLIC	C ReadPixel
ReadPixel	PROC	C uses si, ARGx,ARGy

		mov	ax,ARGy		; AX := y
		mov	bx,ARGx		; BX := x
		call	PixelAddr	; AH := bit mask
					; ES:BX -> buffer
					; CL := #bits to shift

		mov	ch,ah
		shl	ch,cl		; CH := bit mask in proper position

		mov	si,bx		; ES:SI -> regen buffer byte
		xor	bl,bl		; BL is used to accumulate the pixel value

		mov	dx,3CEh		; DX := Graphics Controller port
		mov	ax,304h		; AH := initial bit plane number
					; AL := Read Map Select register number

L01:		out	dx,ax		; select bit plane
		mov	bh,es:[si]	; BH := byte from current bit plane
		and	bh,ch		; mask one bit
		neg	bh		; bit 7 of BH := 1 (if masked bit = 1)
					; bit 7 of BH := 0 (if masked bit = 0)
		rol	bx,1		; bit 0 of BL := next bit from pixel value
		dec	ah		; AH := next bit plane number
		jge	L01

		mov	al,bl		; AL := pixel value
		xor	ah,ah		; AX := pixel value

		ret

ReadPixel	ENDP

		END
