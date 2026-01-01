		TITLE	'put character'
		NAME	scrpoke
		PAGE	55,132
;
; Function:	write character and attribute at the current position
;
; Caller:	Turbo C
;
;			void scrpoke ( unsigned );

_DATA		SEGMENT	word public 'DATA'
_DATA		ENDS

_TEXT		SEGMENT	byte public 'CODE'
_TEXT		ENDS

		ifdef	__TINY__
DGROUP		GROUP	_TEXT, _DATA
		else
DGROUP		GROUP	_DATA
		endif

		ifdef	__TINY__
__NEAR__	equ	0
		endif
		ifdef	__NEAR__
prog		equ	near
quit		equ	ret
ArgOff		equ	4
		else
prog		equ	far
quit		equ	retf
ArgOff		equ	6
		endif

		extrn	__scrpage:byte
		extrn	_scr_001:near

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT, ds:DGROUP

		PUBLIC	_scrpoke
_scrpoke	PROC	prog

                push    bp
                mov     bp,sp
                push    ds

		ifdef	__TINY__
		mov	ax,cs
		else
		mov     ax,DGROUP
		endif
                mov     ds,ax
                test    byte ptr DGROUP:__scrpage,128
                jz      next			; correct page loaded
                call	near ptr _scr_001	; store current page

next:           mov	bh,DGROUP:__scrpage
                mov     al,ss:[bp+(ArgOff+0)]	; character
                mov     bl,ss:[bp+(ArgOff+1)]	; attribute
		mov     ah,9		; write character/attribute
                mov     cx,1            ; repeat count
                int	10h

                pop	ds
		pop	bp
		quit

_scrpoke	ENDP
_TEXT		ENDS
		END
