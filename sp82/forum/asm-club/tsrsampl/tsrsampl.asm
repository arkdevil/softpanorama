; This sample code will hook the timer interrupt (hardware, called 18.2 times a sec.).
;
; Downloaded from The Professional Programmers' Pages (Assembly & VBWIN) at
; http://www.fys.ruu.nl/~faber
;
; Also check out my DooM page: http://www.fys.ruu.nl/~faber/DooM.html
;
	.MODEL  TINY
	.386
	.CODE
	.STARTUP

	jmp	Install                 ; Jump over data and resident code

; Data must be in code segment so it won't be thrown away with Install code.
OldHandler	DWORD   ?               ; Address of original timer routine

NewHandler	PROC   FAR
	push	bx		; these two registers will be changed
	push	ds

	mov	bx, 0B800h	; 0B800h is the address of the VGA display
	mov	ds, bx

	mov	bx, 1		; the color attirbute of the first character of the screen
	inc	[bx]		; increase it (color will change 18.2 times a sec.)

	pop	ds		; restore the registers
	pop	bx

	jmp	cs:OldHandler	; this is the same as CALL CS:OldHandler + IRET
NewHandler	ENDP

Install	PROC
	mov	ax, 351Ch	; Request function 35h
	int     	21h		; Get vector for timer (interrupt 08)
	mov     	WORD PTR OldHandler[0], bx	; Store address of original
	mov     	WORD PTR OldHandler[2], es	;   timer interrupt
	mov     	ax, 251Ch	; Request function 25h
	mov     	dx, OFFSET NewHandler	; DS:DX points to new timer handler
	int     	21h		; Set vector with address of NewHandler

	mov     	dx, OFFSET Install      ; DX = bytes in resident section
	mov	cl, 4
	shr     	dx, cl	; Convert to number of paragraphs
	inc     	dx		;   plus one
	mov     	ax, 3100h	; Request function 31h, error code=0
	int     21h		; Terminate-and-Stay-Resident
Install	ENDP

	END
