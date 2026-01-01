		TITLE	'BIOS addressing cursor'
		NAME	scrgoto
		PAGE	55,132
;
; Function:	moves cursor on display page, number stored in "_scrpage"
;		common variable
;
; Caller:	Turbo C
;			void scrgoto (short, short);

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

		PUBLIC	_scrgoto
_scrgoto	PROC	prog

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

next:           mov	ah,2
		mov	bh,DGROUP:__scrpage
		mov	dl,ss:[bp+(ArgOff+0)]	; column
                mov     dh,ss:[bp+(ArgOff+2)]   ; row
                int	10h

                pop	ds
                pop	bp
		quit

_scrgoto	ENDP
_TEXT		ENDS
		END
