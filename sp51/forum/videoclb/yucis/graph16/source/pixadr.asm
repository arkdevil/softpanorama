;
; Name:		PixelAddr
;
; Function:	Determine buffer address of pixel in RT-VGA mode:
;			800x600 16-color
;
; Caller:	AX = y-coordinate
;		BX = x-coordinate
;
; Returns:	AH = bit mask
;		BX = byte offset in buffer
;		CL = number of bits to shift left
;		ES = video buffer segment
;

OriginOffset	EQU	0		; byte offset of (0,0)
VideoBufferSeg	EQU	0A000h

		.model	medium
		EXTRN	C BytesPerLine:word
		.code

		PUBLIC	PixelAddr
PixelAddr	PROC

		mov	cl,bl		; CL := low-order byte of x

		push	dx		; preserve DX

		mov	dx,BytesPerLine	; AX := y * BytesPerLine
		mul	dx

		pop	dx
		shr	bx,1
		shr	bx,1
		shr	bx,1		; BX := x/8
		add	bx,ax		; BX := y*BytesPerLine + x/8
		add	bx,OriginOffset	; BX := byte offset in video buffer

		mov	ax,VideoBufferSeg
		mov	es,ax		; ES:BX := byte address of pixel

		and	cl,7		; CL := x & 7
		xor	cl,7		; CL := number of bits to shift left
		mov	ah,1		; AH := unshifted bit mask
		ret

PixelAddr	ENDP

		END
