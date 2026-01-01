
						Include Utils.Asi
;----------------------------------------------------------------
;
;  NoPrn -- Disable printer timeouts if no printer attached
;
;  (C) 1993 Compact Soft
;  written by: cs:dk
;
;----------------------------------------------------------------

.model	tiny
.code

org	100h

start:
	jmp	Install

Int17h	proc	far

	pushf

	tst	ah
	jnz	@@not0

;	mov	ah, 20h OR 10h OR 01h	; selected, out of paper, timeout
	; zero remains zero - turn printer into blackhole
	popf
	iret
	
@@not0:
	popf
	jmp_vect	SaveInt17h
	
Int17h	endp


TsrTop	label	near


.data

Title$	db	'NoPrn  Version 1.0  (C)', 255, ' Compact Soft, 1993', 13, 10
	db	'$'


.code

Int23h	proc	far
	iret
Int23h	endp

Install:
	lea	dx, Title$
	DOS	9h

	cli
	set_vector	23h
	get_set_vector	17h
	sti

	lea	dx, TsrTop
	int	27h

end	start
