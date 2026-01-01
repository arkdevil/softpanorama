		NAME	CPUname
		PAGE	55,132
;
; Function:	determines CPU type.
;		Works both in real and protetcted mode
;
; Caller:	Turbo C:
;			int CPUname(void);
;
; Returns:	000b - 8086		001b - 8088
;		010b - 80186		011b - 80188
;		100b - 80286
;		110b - 80386		111b - 80386SX
;		080h - NEC V20		081h - NEC V30
;		and corresponding negative values for protected modes
;
; Source algorithm by Bob Felts, PC Tech Journal, November 1987
; Printed: "Dr.Dobb's Tollbook of 80286/80386 programming,
; M&T publishing, Inc. Redwood City, California
;
; Adapted & enhanced R.I.Akhmarov & T.V.Shaporev
; Computer Center MTO MFTI
;
; Destroys upper 16 bits of eax if executed in a 32 bit 80386 code segment.

		ifdef	__NEAR__
prog		equ	near
quit		equ	ret
		else
prog		equ	far
quit		equ	retf
		endif

CPU_8086	EQU	000b
CPU_8088	EQU	001b
CPU80186	EQU	010b
CPU80188	EQU	011b
CPU80286	EQU	100b
CPU80386	EQU	110b
_80386SX	EQU	111b
CPUNEC20	EQU	080h
CPUNEC30	EQU	081h

.286p

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT

		PUBLIC	_CPUname
_CPUname	PROC	prog

		pushf			; save original flags
;		push	cx		; and registers
		push	bp
		push	es
		mov	ax,sp		; 86/186 or 286/386
		push	sp		; 86/186 will push sp-2
		pop	cx		; others will push sp
		cmp	ax,cx
		jz	short cpu_2386	; if 80286/80386

		mov	bl,93h		; Prepare to 8018x
		mov	ax,0FFFFh	; distinguish between 86 and 186
		mov	cl,33		; 8086 will shift 32 bits
		shl	ax,cl		; 80186 will shift 0 bits
		jnz	cpu_x808x	; NZ implies 186

		mov	cx,0FFFFh	; now distinguish Intel from NEC
		push	si
		xor	si,si
		mov	es,si		; for the God's sake
		sti
		db	0F3h,026h,0ACh	; LODSB REP ES:
		pop	si
		jcxz	nec_cpu
		mov	bl,91h		; this is Intel's chip
		jmp	short cpu_x808x
nec_cpu:	mov	bl,10h		; NEC group

; The following if fine but unreliable
;		mov	bl,91h		; set Intel's chip code
;		mov	cx,sp
;		pusha
;		cmp	cx,sp
;		je	cpu_x808x
;		popa
;		mov	bl,10h		; set NEC chip code
cpu_x808x:
		std
		mov	ax,cs
		mov	es,ax
		lea	di,lenconv
		mov	ax,90h		; nop code
		mov	cx,4
		cli
		rep	stosb
		cld
		nop
		nop
		nop
		inc	ax
		nop
		nop
lenconv:	nop
		sti
		xor	al,bl
		jmp	short cpu_exit
cpu_2386:
		pushf			; 286/386 - 32 or 16 bit operand?
		mov	cx,sp		; if pushf pushed 2 bytes then
		popf			; 16 bit operand size
		inc	cx		; assume 2 bytes
		inc	cx
		cmp	cx,ax
		jnz	short cpu_386_32

		sub	sp,6		; either 286 or 386 with 16 bit oper
		mov	bp,sp		; allocate room for SGDT
		ifndef	PWORD
		sgdt	FWORD PTR ss:[bp]	; 286 assemblers
		else
		sgdt	PWORD PTR ss:[bp]	; 386 assemblers
		endif

		add	sp,4		; trash limit and base (low word)
		pop	ax
		inc	ah		; 286 stores -1, 386 stores 0 or 1
		jnz	short cpu_386_16

		mov	ax,CPU80286
		jmp	short cpu_prot	; go check for protected mode
cpu_386_32:				; 386 in 32 bit code segment
		mov	ax,4444h	; now check for 386SX
		dw	0		; mov eax,4444h
		mov	dx,ax		; mov edx,eax
		mul	ax		; mul eax
		cmp	ax,3210h	; cmp eax,12343210h
		dw	1234h
		jne	SX_32
		db	66h
		mov	ax,CPU80386	; 66h to force 16 bit move
		jmp	short cpu_prot
SX_32:		db	66h		; force 16 bit move
		mov	ax,_80386SX
		jmp	short cpu_prot
cpu_386_16:				; 386 in 16 bit code segment
		db	66h		; force 32 bit move
		mov	ax,4444h	; mov eax,4444h
		dw	0
		db	66h
		mov	dx,ax		; mov edx,eax
		db	66h
		mul	ax		; mul eax
		db	66h
		cmp	ax,3210h	; cmp eax,12343210h
		dw	1234h
		jne	SX_16
		mov	ax,CPU80386
		jmp	short cpu_prot
SX_16:		mov	ax,_80386SX
cpu_prot:
		smsw	cx		; check for protected mode
		ror	cx,1
		jnc	short cpu_exit	; if PE = 0 then real mode
		neg	ax		; else indicate protected mode
cpu_exit:
		pop	es
		pop	bp
;		pop	cx
		popf
		quit

_CPUname	ENDP

_TEXT		ENDS

		END
