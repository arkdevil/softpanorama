		NAME	FindCMem
		PAGE	55,132
;
; Function:	Searches for conventioal memory available.
;
; Caller:	Turbo C:
;			int FindCMem(void);
;
; Returns:	amount of memory available in Kbytes.
; Author:	T.V.Shaporev, Computer Center MTO MFTI

		ifdef	__NEAR__
prog		equ	near
quit		equ	ret
		else
prog		equ	far
quit		equ	retf
		endif

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT

		PUBLIC	_FindCMem
_FindCMem	PROC	prog

		push	es

		lea	bx,cs:bottleneck-1	; critical fragment - 1
		and	bx,3FFFh	; align to 16K boundary
		mov	cl,4
		shr	bx,cl		; foreget paragraph
		mov	ax,cs
		add	ax,bx		; save-to-clear paragraph
		sub	bx,bx		; offset don't care

bottleneck	label	byte

		cli
search:		mov	es,ax
		mov	cl,es:[bx]	; get origin value
		mov	ch,cl		; duplicate it
		not	ch		; and invert
		mov	es:[bx],ch	; store changed value
		cmp	es:[bx],ch	; did it really stored?
		mov	es:[bx],cl	; restore origin
		jne	return		; disable memory block
		add	ax,0400h	; 16K increment
		cmp	ax,0A000h	; supremum
		jb	search
return:		sti
		and	ax,0FC00h	; align to 16K boundary
		mov	cl,6
		shr	ax,cl		; paragraphs to Kbytes

		pop	es
		quit

_FindCMem	ENDP

_TEXT		ENDS

		END
