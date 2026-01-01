		TITLE	'internal routine 002'
		NAME	_key_002
		PAGE	55,132
;
; Function:	check enhanced keyboard presence
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
		PUBLIC	_oldkeyboard
_oldkeyboard	db	255
_DATA		ends

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT, ds:DGROUP

		PUBLIC	_key_002
_key_002	PROC	near

		push    ds
		mov	ax,12FFh
		int	16h
		cmp	al,0FFh
		je	oldkeyb
		mov	dl,0
		jmp	short setkeyb
oldkeyb:	mov	dl,1
setkeyb:
		ifdef	__TINY__
		mov	ax,cs
		else
		mov     ax,DGROUP
		endif
                mov     ds,ax
		mov	DGROUP:_oldkeyboard,dl
                pop     ds
		ret

_key_002	ENDP
_TEXT		ENDS

		END
