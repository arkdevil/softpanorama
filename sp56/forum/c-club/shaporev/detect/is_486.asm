		NAME	Is_486
		PAGE	55,132

; Function:	detects presence of the 80486 CPU
;
; Caller:	Turbo C:
;			int Is_486(void);
;
; Returns:	non-zero, if 80486 found
; Note:		will hang up system on 8088/80188

.286

		ifdef	__NEAR__
prog		equ	near
quit		equ	ret
		else
prog		equ	far
quit		equ	retf
		endif

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT

intr_06h_entry	proc 	far
		enter	0,0			; create new stack frame
		xor	cx,cx			; clear flag
		add	word ptr ss:[bp+2],3	; point past invalid opcode
		leave
		iret
intr_06h_entry	endp

		PUBLIC	_Is_486
_Is_486	PROC	prog
		push	ds
		push	es
		mov	ax,3506h
		int	21h	; ES:BX => old intr 06h handler
		push	cs
		pop	ds
		lea	dx,cs:intr_06h_entry
		mov	ax,2506h
		int	21h	; set up my intr 06h handler
		mov	cx,1	; presence flag
		db	0Fh,0C0h,0D2h	; xadd dl,dl
		push	es
		pop	ds
		mov	dx,bx 	; move ES & BX to DS & DX
		mov	ax,2506h
		int	21h	; restore origin intr 06h handler
		mov	ax,cx	; return value
		pop	es
		pop	ds
		quit

_Is_486		ENDP

_TEXT		ENDS

		END

