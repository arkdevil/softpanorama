PROG	SEGMENT
	ASSUME	cs:PROG

; This user interrupt handler is an illustration to the paper
;	"Interfacing Multi-Edit with Assembly Language"
;			by Alex Romanov
;
; Called from Multi-Edit macro IBMTOMAC
; that is one of the examples discussed in the paper.

	ORG	0
START:

TRANSLATE	PROC

	sti
	cld
xlat_loop:
	lodsb
	xlat	[bx]
	stosb
	loop	xlat_loop
	iret

TRANSLATE	ENDP

PROG	ENDS
	END	START
	END
