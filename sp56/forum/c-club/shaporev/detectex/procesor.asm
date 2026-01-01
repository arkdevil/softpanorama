		NAME	processors
		PAGE	,132
;
; Function:	determines CPU & NDP type.
;
; Caller:	Turbo C:
;			int processors(void);
;
; Returns:	AL = central processor type (see below) and
;		AL bit 7 set if protected mode (AL & 80h != 0)
;		AH = coprocessor type (if any - see below)
;
; References:
; 1) Source algorithm by Bob Felts, PC Tech Journal, November 1987
;    Printed: "Dr.Dobb's Tollbook of 80286/80386 programming,
;    M&T publishing, Inc. Redwood City, California
; 2) SI-System Information, Advanced Edition 4.50, (C) 1987-88, Peter Norton
; 3) PC Tools Deluxe R4.21
;    (C)Copyright 1985,1986,1987,1988 Central Point Software, Inc.
; 4) CHKCOP, Intel's Math CoProcessor Test Program ver 2.10                          *
;    Copyright(c) Intel Corp. 1987-1990.
; 5) HelpPC 2.10 Quick Reference Utility Copyright (c) 1991, David Jurgens
;
; Adapted & enhanced R.I.Akhmarov & T.V.Shaporev
; Computer Center MTO MFTI

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

CPU_8088	EQU	0
CPU_8086	EQU	1
CPUNEC20	EQU	2
CPUNEC30	EQU	3
CPU80188	EQU	4
CPU80186	EQU	5
CPU80286	EQU	6
CPU80386	EQU	7
CPUSX386	EQU	8
CPUDX386	EQU	9
CPU80486	EQU	10
CPUSX486	EQU	11

NDP_NONE	EQU	0
NDP_8087	EQU	1
NDP80287	EQU	2
NDPXL287	EQU	3
NDP80387	EQU	4
NDPSX387	EQU	5
NDPDX387	EQU	6

.386p

_TEXT		SEGMENT	byte use16 public 'CODE'
		ASSUME	cs:_TEXT

		PUBLIC	_processors
_processors	PROC	prog

		push	bp
		mov	bp,sp

; At first determine central processor type
		mov	ax,sp		; 86/186 or 286/386
		push	sp		; 86/186 will push sp-2
		pop	cx		; others will push sp
		cmp	ax,cx
		je	short cpu_2386	; if 80286/80386

;	Place 'inc ax' command to make the code re-enterable
		mov     byte ptr cs:critical,40h

                push    es		; Preserve for future

		mov	dl,CPU80186	; Prepare to 8018x
		mov	ax,-1		; distinguish between 86 and 186
		mov	cl,33		; 8086 will shift 33 bits
		shl	ax,cl		; 80186 will shift 1 bits
		jnz	short cpu_x808x	; NZ implies 186
;	Now distinguish Intel from NEC.
		mov	dl,CPUNEC30
		mov	cx,-1
		push	si
		xor	si,si
		mov	es,si		; for the God's sake
		sti
		db	0F3h,026h,0ACh	; REP ES: LODSB
		pop	si
		jcxz	short cpu_x808x
                mov     dl,CPU_8086
cpu_x808x:
		push	di
		push	cs
		pop	es
		lea	di,lenconv
		mov	ax,90h		; nop code
		mov	cx,4
		std
		cli
		rep	stosb
		cld
		nop
		nop
		nop
critical:	inc	ax
		nop
		nop
lenconv:	nop
		sti
                pop	di
		cmp	al,90h
		jne	short jump_cpu_ok
		add	dl,CPU_8088-CPU_8086
jump_cpu_ok:    pop     es
		jmp	cpu_ok
cpu_2386:
		mov	dl,CPU80286
		pushf			; 286/386 - 32 or 16 bit operand?
		mov	cx,sp		; if pushf pushed 2 bytes
		mov	sp,bp		; then 16 bit operand size
		inc	cx		; assume 2 bytes
		inc	cx
		sub	cx,ax
		jnz	short generic_386
;	Either 286 or 386 with 16 bit oper
		db	83h,0C4h,0FAh   ; add sp,-6 = allocate room for SGDT
		sgdt	[bp-6]
		inc	byte ptr [bp-1]	; 286 stores -1,
		mov	sp,bp		; 386 stores 0 or 1
		jz	short cpu_ok	; go check for protected mode
generic_386:				; 386 in 16 or 32 bit code segment
		mov	dl,CPU80386
		smsw	ax		; check for protected mode
		test	al,1		; if protection enable,
		jnz     short cpu_ok	; the following is impossible
		mov	dl,CPU80486	; now check for i486
		db      83h,0E4h,0FCh	; and sp,-4 = align to 4-byte boundary
		jcxz    cpu_16_bit
					; 386 in 32 bit code segment
		pushf      		; 32-bit flags
		pop	ax		; pop eax
		mov	cx,ax		; mov ecx,eax = save original flags
		btc	ax,18		; btc eax,18  = toggle bit 18
		push	ax		; push eax
		popf                    ; 32-bit flags
		pushf                   ; 32-bit flags
		pop	ax		; pop  eax
		push	cx              ; push ecx
		popf			; restore original eflags
		mov	sp,bp		; restore stack pointer
		cmp	ax,cx		; can 18th bit be changed?
		jne	short cpu_ok	; yes, it's i486
		jmp     short test_SX_cpu
cpu_16_bit:				; 386 in 16 bit code segment
		pushfd
		pop	eax
		mov	ecx,eax		; save original flags
		btc	eax,18		; toggle bit 18
		push	eax
		popfd
		pushfd
		pop	eax
		push	ecx
		popfd			; restore original flags
		mov	sp,bp		; restore stack pointer
		cmp	eax,ecx		; can 18th bit be changed?
		jne	short cpu_ok	; yes, it's i486
test_SX_cpu:                            ; let's distinguish SX and DX
		mov	dl,CPUSX386
		mov	eax,cr0
		test	al,10h		; coprocessor type flag
		jz	short cpu_is_DX
		xor	al,10h		; clear flag
		mov	cr0,eax
		mov	eax,cr0
		test	al,10h          ; if the flag can be cleared, it is DX
		jnz	short cpu_ok
re_cop_flag:	xor	al,10h
		mov	cr0,eax         ; restore the flag
cpu_is_DX:	mov	dl,CPUDX386
		jmp	short cpu_ok
cpu_ok:

; At second determine numeric coprocessor generic type
		push	cx			; reserve stack

                mov     dh,NDP_NONE
                db      0DBh,0E3h               ; fninit; Initialize math uP
		mov     byte ptr [bp-1],0
                db      0D9h,07Eh,0FEh          ; fnstcw word ptr [bp-2]
		cmp     byte ptr [bp-1],3
                jne     short ndp_done
                mov     dh,NDP_8087
		and     byte ptr [bp-2],7Fh
		db      09Bh,0D9h,06Eh,0FEh     ; fldcw word ptr [bp-2]
                db      09Bh,0DBh,0E1h          ; fdisi ; Disable Interrupts
		db      09Bh,0D9h,07Eh,0FEh     ; fstcw word ptr [bp-2]
                test    byte ptr [bp-2],80h
                jnz     short ndp_done
                mov     dh,NDP80287
                db      09Bh,0DBh,0E3h          ; finit         ; Initialize math uP
                db      09Bh,0D9h,0E8h          ; fld1          ; Push +1.0 to stack
                db      09Bh,0D9h,0EEh          ; fldz          ; Push +0.0 to stack
                db      09Bh,0DEh,0F9h          ; fdivp st(1),st; st(#)=st(#)/st, pop
                db      09Bh,0D9h,0C0h          ; fld   st      ; Push onto stack
                db      09Bh,0D9h,0E0h          ; fchs          ; Change sign in st
                db      09Bh,0DEh,0D9h          ; fcompp        ; Compare st & pop 2
                db      09Bh,0DDh,07Eh,0FEh     ; fstsw word ptr [bp-2]
                wait
		mov     ah,[bp-1]
                sahf
                jz      short ndp_done
                mov     dh,NDP80387
ndp_done:
		pop	cx			; restore stack

; At last analyse main and co-processor combination
		cmp	dh,NDP80387
		jnb	short analyse_hi
		cmp	dl,CPU80486
		jb	short cpu_prot
		mov	dl,CPUSX486
		jmp	short cpu_prot
analyse_hi:             		; i387 detected
		cmp     dl,CPU80286
		ja	short analyse_386
		je	short set_287XL
		jmp	short cpu_prot	; 387 at 8088? Wonderful!
analyse_386:
		smsw	ax
		test	al,10h		; coprocessor type flag
		jnz	short test_SX_DX
set_287XL:	mov	dh,NDPXL287
		jmp     short cpu_prot
test_SX_DX:
		cmp	dl,CPUSX386
		jne	short no_SX
		mov	dh,NDPSX387
		jmp     short cpu_prot
no_SX:
		cmp	dl,CPUDX386
		jne	short cpu_prot
		mov	dh,NDPDX387
cpu_prot:
		cmp	dl,CPU80286
		jb	short return
		smsw	ax	; check for protected mode
		shl	al,7	; if PE = 0 then real mode
		or	dl,al	; else indicate protected mode
return:
                mov	ax,dx
		pop	bp
		quit

_processors	ENDP

_TEXT		ENDS

		END
