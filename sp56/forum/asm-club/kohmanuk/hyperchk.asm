
						Include	Utils.Asi
;----------------------------------------------------------------
;
; HyperChk.Asm -- check for presense of HyperDisk cache
;    
; Purpose: primarily for batch files:
;
;	REM disable staged writes
;	hyperchk && hyperdk w
; 
; (C) 1993 Compact Soft
; written by cs:dk 
;
;-----------------------------------------------------------------

.model	tiny

.data

Header$		db	'HyperDisk is $'
Not$		db	'NOT $'
Trailer$	db	'installed.', 13, 10, '$'

ExitCode	db	0		; 1 means not installed (failure)

Marker		db	13, 10
		db	'#(@) hyperchk.asm, version 1.0, (C) 1993 by cs:dk', 0

.code

org	100h

start:
	lea	dx, Header$
	DOS	9

	; thanks to Ralf Brown
	mov	ax, 0df00h
	mov	bx, 4448h
	int	2fh
	cmp	ax, 0dfffh
	jne	@@no_hyper
	cmp	cx, 5948h	; 'YH'
	je	@@exit

@@no_hyper:
	mov	ExitCode, 1
	lea	dx, Not$
	DOS	9

@@exit:
	lea	dx, Trailer$
	DOS	9

	mov	al, ExitCode
	DOS	4ch

end	start
