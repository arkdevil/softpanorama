		TITLE	'call to video function'
		NAME	scrcall
		PAGE	55,132
;
; Function:	call to video function
;
; Caller:	Turbo C
;
;		void scrcall (int, int, int, int, int, int, int, int);

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

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT

		PUBLIC	_scrcall
_scrcall	PROC	prog

                push    bp
                mov     bp,sp

                mov     ah,ss:[bp+(ArgOff+00)]
                mov     al,ss:[bp+(ArgOff+02)]
                mov     bh,ss:[bp+(ArgOff+04)]
                mov     bl,ss:[bp+(ArgOff+06)]
                mov     ch,ss:[bp+(ArgOff+08)]
                mov     cl,ss:[bp+(ArgOff+10)]
                mov     dh,ss:[bp+(ArgOff+12)]
                mov     dl,ss:[bp+(ArgOff+14)]

                int	10h

                pop	bp
		quit

_scrcall	ENDP
_TEXT		ENDS
		END
