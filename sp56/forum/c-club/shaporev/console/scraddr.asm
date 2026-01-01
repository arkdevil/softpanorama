		TITLE	'get cursor coordinates'
		NAME	scraddr
		PAGE	55,132
;
; Function:	get current cursor coordinates
;
; Caller:	Turbo C
;
;			void scraddr (char far *);
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

		PUBLIC	_scraddr
_scraddr	PROC	prog

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

next:           mov	ah,3
		mov	bh,DGROUP:__scrpage
                int	10h

                xor     ah,ah

                lds     bx,ss:[bp+(ArgOff+0)]	; address of X
                mov     al,dl
                mov     ds:[bx],ax              ; store column

                lds     bx,ss:[bp+(ArgOff+4)]	; address of Y
                mov     al,dh
                mov     ds:[bx],ax              ; store row (Y-coord)

                pop	ds
                pop	bp
		quit

_scraddr	ENDP
_TEXT		ENDS
		END
