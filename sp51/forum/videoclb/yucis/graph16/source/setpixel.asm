;
; Name:		SetPixel
;
; Function:	Set the value of a pixel in native EGA/VGA graphics modes.
;
;		*** Write Mode 0, Set/Reset ***
;
; Caller:	Microsoft C:
;
;			void SetPixel(x,y,n);
;
;			int x,y;		/* pixel coordinates */
;
;			int n;			/* pixel value */
;
		.model	medium
		EXTRN 	PixelAddr:proc
		
		.code

RMWbits		EQU	18h		; read-modify-write bits

		PUBLIC	C SetPixel
SetPixel	PROC	C uses ,ARGx, ARGy, ARGn:byte

		mov	ax,ARGy		; AX := y
		mov	bx,ARGx		; BX := x
		call	PixelAddr	; AH := bit mask
					; ES:BX -> buffer
					; CL := # bits to shift left

; set Graphics Controller Bit Mask register

		shl	ah,cl		; AH := bit mask in proper position
		mov	dx,3CEh		; GC address register port
		mov	al,8		; AL := Bit Mask register number
		out	dx,ax

; set Graphics Controller Mode register

		mov	ax,0005h	; AL :=  Mode register number
					; AH :=  Write Mode 0 (bits 0,1)
					;	 Read Mode 0 (bit 3)
		out	dx,ax

; set Data Rotate/Function Select register

		mov	ah,RMWbits	; AH := Read-Modify-Write bits
		mov	al,3		; AL := Data Rotate/Function Select reg
		out	dx,ax

; set Set/Reset and Enable Set/Reset registers

		mov	ah,ARGn		; AH := pixel value
		mov	al,0		; AL := Set/Reset reg number
		out	dx,ax

		mov	ax,0F01h	; AH := value for Enable Set/Reset (all
					;  bit planes enabled)
					; AL := Enable Set/Reset reg number
		out	dx,ax

; set the pixel value

		or	es:[bx],al	; load latches during CPU read
					; update latches and bit planes during
					;  CPU write

; restore default Graphics Controller registers

		mov	ax,0FF08h	; default Bit Mask
		out	dx,ax

		mov	ax,0005		; default Mode register
		out	dx,ax

		mov	ax,0003		; default Function Select
		out	dx,ax

		mov	ax,0001		; default Enable Set/Reset
		out	dx,ax

		ret

SetPixel	ENDP

		END
