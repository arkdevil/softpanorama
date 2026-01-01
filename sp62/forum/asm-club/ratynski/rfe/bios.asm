.MODEL TINY
.CODE
LOCALS	@@

PUBLIC	PrintStr

; Input:
;   bp - string
;   bh - page
;   bl - color
;   cx - length
; Output:
;   none

PrintStr	PROC	Near
	push	ax dx es bx cx
	xor	bx, bx
	mov	ah, 3
	int	10h
	mov	ax, 1301h
	pop	cx bx
	push	cs
	pop	es
	int	10h
	pop	es dx ax
	ret
PrintStr	ENDP

END