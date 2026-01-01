		TITLE	'get character'
		NAME	scrpeek
		PAGE	55,132
;
; Function:	read character and attribute from the current position
;
; Caller:	Turbo C
;			unsigned scrpeek ( void );

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
		else
prog		equ	far
quit		equ	retf
		endif

		extrn	__scrpage:byte
		extrn	_scr_001:near

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT, ds:DGROUP

		PUBLIC	_scrpeek
_scrpeek	PROC	prog

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
		mov     ax,0800h	; be careful! AL = 0!
                int	10h             ; read character/attribute

                pop	ds
		quit

_scrpeek	ENDP
_TEXT		ENDS
		END
