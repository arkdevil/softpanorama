		NAME	Is_Weitek
		PAGE	,132
;
; Function:	determines Weitek co-processor presence.
;
; Caller:	Turbo C:
;			int Is_Weitek(void);
;
; Returns:	0 - absent, else present

.386p

		ifdef	__NEAR__
prog		equ	near
quit		equ	ret
		else
prog		equ	far
quit		equ	retf
		endif

_TEXT		SEGMENT	byte public 'CODE' use16
		ASSUME	cs:_TEXT

		PUBLIC	_Is_Weitek
_Is_Weitek	PROC	prog

		push	bp

		push	sp		; 86/186 or 286/386
		pop	ax		; 86/186 will push sp-2
		cmp	ax,sp		; others will push sp
		jne	short absent	; no 80286/80386

		mov	bp,sp
		db	83h,0C4h,0FAh   ; add sp,-6 = allocate room for SGDT
		sgdt	[bp-6]
		inc	byte ptr [bp-1]	; 286 stores -1,
		mov	sp,bp		; 386 stores 0 or 1
		jz	absent

		xor	eax,eax
		int	11h
		shr     eax,24
                and     ax,1
                jmp     short return
absent:         xor     ax,ax
return:		pop	bp
		quit

_Is_Weitek	ENDP

_TEXT		ENDS

		END

