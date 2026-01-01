		TITLE	'catch keyboard input'
		NAME	keycatch
		PAGE	55,132
;
; Function:	catch keyboard input and add keystrokes
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
ArgOff          equ     4
		else
prog		equ	far
quit		equ	retf
ArgOff          equ     6
		endif

		extrn	_oldkeyboard:byte

_INTR		SEGMENT	word
scale		db	0

old05           label   dword
old05o		dw	0
old05s		dw	0

old09           label   dword
old09o		dw	0
old09s		dw	0

old15           label   dword
old15o		dw	0
old15s		dw	0
_INTR		ENDS

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT, ds:DGROUP

INT05h          LABEL   BYTE
                push    ax
                push    cx
                mov     cx,3700h
                mov     ah,5
		int	16h
                pop     cx
                pop     ax
                iret

INT09h		LABEL	BYTE
		push    ds
		push	es
		push	ax

		mov	ax,_INTR
		mov	es,ax
		pushf
		call	es:[old09]	; let BIOS do it

		xor     ax,ax
		mov     ds,ax
		test    ds:0417h,70h
		jz      ret09h

		push	cx

		test    ds:417h,40h	; Caps pressed
		jz	nocaps
		test	es:scale,4	; need catch?
		jz	nocaps
                mov     cx,3A00h
		mov     ah,5		; place keystroke
		int	16h
		and     ds:417h,0BFh	; clear flag
nocaps:
		test    ds:417h,20h	; NumLock pressed
		jz	nonum
		test	es:scale,2	; need catch?
		jz	nonum
                mov     cx,4500h
		mov     ah,5		; place keystroke
		int	16h
		and	ds:417h,0DFh	; clear flag
nonum:
		test    ds:0417h,10h	; Scroll pressed
		jz	noscroll
		test    es:scale,1	; need catch?
		jz	noscroll
		mov     cx,4600h
		mov     ah,5		; place keystroke
		int	16h
		and	ds:417h,0EFh	; clear flag
noscroll:
;		mov	al,0EDh		; prepare to set indicator lamps
;		out	64h,al
;		mov	cx,2000h
;delay:		loop	delay           ; wait a little
;		mov	al,es:scale
;		xor	al,7		; LED status
;		out	64h,al

		pop     cx

ret09h:         pop     ax
		pop	es
                pop     ds
                iret

INT15h		LABEL	BYTE
                push    ax
		cmp	ax,8500h
                je      catch15h
                push    ds
                mov     ax,_INTR
                mov     ds,ax
                pushf
                call	ds:[old15]
                pop	ds
                pop	ax
                iret
catch15h:
		push	cx
                mov	cx,5400h
                mov     ah,5
                int     16h

                pop     cx
                pop     ax
                iret

		extrn	_key_002:near

		PUBLIC	_keycatch
_keycatch	PROC	prog

                push    bp
                mov     bp,sp
                push    ds
                push    es

		ifdef	__TINY__
		mov	ax,cs
		else
		mov     ax,DGROUP
		endif
                mov     ds,ax
		cmp	byte ptr DGROUP:_oldkeyboard,255
                jne	next			; keyboard aready checked
                call	near ptr _key_002

next:           test	byte ptr DGROUP:_oldkeyboard,255
		jz	install
		mov	ax,0FFFFh	; AX = -1 - error
		jmp	short retfun

install:	mov	ax,_INTR
		mov	ds,ax

		mov	ax,3505h	; read int 05h handler address
		int	21h
		mov	ds:old05o,bx    ; remember it
		mov	ds:old05s,es
		mov	ax,3509h	; read int 09h handler address
		int	21h
		mov	ds:old09o,bx	; remember it
		mov	ds:old09s,es
		mov	ax,3515h	; read int 15h handler address
		int	21h
		mov	ds:old15o,bx	; remember it
		mov	ds:old15s,es

		mov	al,ss:[bp+ArgOff]
		and	al,7
		mov	ds:scale,al
		mov	cl,4
		shl	al,cl
		not	al
		xor	ax,ax
		mov	ds,ax
		and	ds:417h,al

		mov	ax,cs
		mov	ds,ax

		test	byte ptr ss:[bp+ArgOff],7
		jz	nostat
		lea	dx,INT09h
		mov	ax,2509h	; set int 09h handler
		int	21h
nostat:
		test	byte ptr ss:[bp+ArgOff],10h
		jz	noprtsc
		lea	dx,INT05h
		mov	ax,2505h	; set int 05h handler
		int	21h
noprtsc:
		test	byte ptr ss:[bp+ArgOff],8
		jz	nosysrq
		lea	dx,INT15h
		mov	ax,2515h	; set int 15h handler
		int	21h
nosysrq:
		xor	ax,ax
retfun:
                pop	es
		pop	ds
                pop	bp
		quit

_keycatch	ENDP

		PUBLIC	_keyrecat
_keyrecat	PROC	prog

		push    ds
		push	es

		mov	ax,_INTR
		mov	es,ax

		lds	dx,es:old05
		mov	ax,2505h	; set int 05h handler
		int	21h
		lds	dx,es:old09
		mov	ax,2509h	; set int 09h handler
		int	21h
		lds	dx,es:old15
		mov	ax,2515h	; set int 15h handler
		int	21h

		pop	es
		pop	ds
		quit

_keyrecat	ENDP

_TEXT		ENDS
		END
