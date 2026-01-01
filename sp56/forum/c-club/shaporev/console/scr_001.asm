		TITLE	'internal routine 001'
		NAME	scr_001
		PAGE	55,132
;
; Function:	store current active display page into "_scrpage" common
;		variable
;

_DATA		SEGMENT	word public 'DATA'
_DATA		ENDS

_TEXT		SEGMENT	byte public 'CODE'
_TEXT		ENDS

		ifdef	__TINY__
DGROUP		GROUP	_TEXT, _DATA
		else
DGROUP		GROUP	_DATA
		endif

_DATA		SEGMENT word public 'DATA'
		PUBLIC	__scrpage
__scrpage	db	255
_DATA		ends

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT, ds:DGROUP

		PUBLIC	_scr_001
_scr_001	PROC	near

		push    ds
		mov	ah,0Fh
		int	10h
		ifdef	__TINY__
		mov	ax,cs
		else
		mov     ax,DGROUP
		endif
                mov     ds,ax
		mov	DGROUP:__scrpage,bh
                pop     ds
		ret

_scr_001	ENDP
_TEXT		ENDS

		END
