		TITLE	'switch active display page'
		NAME	scrpage
		PAGE	55,132
;
; Function:	Switch active display page
;
; Caller:	Turbo C
;
;			void scrpage (short);

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
ArgOff		equ	2
		else
prog		equ	far
quit		equ	retf
ArgOff		equ	4
		endif

		extrn	__scrpage:byte

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT, ds:DGROUP

		PUBLIC	_scrpage

_scrpage	PROC	prog

		mov	bx,sp
                push    ds
		ifdef	__TINY__
		mov	ax,cs
		else
		mov	ax,DGROUP
		endif
		mov	ds,ax
		mov	al,ss:[bx+ArgOff]
		mov	DGROUP:__scrpage,al
                mov	ah,5
                int	10h
                pop     ds
		quit

_scrpage	ENDP
_TEXT		ENDS
		END
