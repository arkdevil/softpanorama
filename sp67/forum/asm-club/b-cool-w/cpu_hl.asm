; -----------------------------------------------------------------------------
; CPU_HL.ASM   CPU Type detection routine for hi-level languages Version 1.14c
;
; Too-Much-In-One-So-Don't-Get-Lost(tm) CPU/FPU feature detection library
;
; Copyright(c) 1992,93,94 by B-coolWare.  Written by Bobby Z.
; -----------------------------------------------------------------------------
; This file is a port from CPU_TYPE.ASH - the assembler version of TMIOSDGL(tm)
; The history for this file is just the same as for CPU_TYPE.ASH
;
	MODEL	TPASCAL		; uncomment this to use with Turbo Pascal
;	MODEL	LARGE,C		; uncomment this to use with C/C++ compilers
;		^^^^^  change to preferred memory model

; to compile for TP/BP type
;  tasm /t/x cpu_tp
; to compile for TC/BC type
;  tasm /t/x/mx cpu_tp, cpu_c

.data
	EXTRN FPUType:BYTE

.code
	PUBLIC	CPU_Type
; function CPU_Type : Word;
; word CPU_Type(void);
; returns current CPU code (see CPUTYPE.PAS or CPUTYPE.H for details) and sets
; current FPU code in FPUType variable.

EF_AC		equ	00040000h	; AC bit in EFLAGS register
EF_ID		equ	00200000h	; ID bit in EFLAGS register
MSW_NE		equ	00000020h	; NE bit in MSW register

cpuid		equ	<db 0Fh,0A2h>	; 586 instruction


INCLUDE	UNIDEF.INC

	JUMPS
	LOCALS

CPU_Type	proc
	.8086
	push	bx cx si
	sub	bx,bx
	push	sp		; this code uses bug in chips prior to
	pop	ax		; 80286: when push sp performed, value
	cmp	ax,sp		; of sp is first decremented and then
				; placed onto the stack. 286 and up
				; handle this instruction correctly, 
				; saving value which sp have upon issue
				; of this command, not after.
	jnz	@@Ct_000	; if not equal that it is <286
	mov	ax,7000h
	pushf
	push	ax
	popf
	pushf
	pop	ax
	popf
	mov	bl,6
	and	ax,7000h	; check for flag - only 386+ has it
	jz	@@Ct_200	; if ax=0 than this is 286
	inc	bx

	.386p
	clr	si
	mov	eax,cr0
	mov	ecx,eax
	xor	eax,10h		; trying to flip ET bit in CR0
	mov	cr0,eax
	mov	eax,cr0
	mov	cr0,ecx
	xor	eax,ecx		; did ET flip ok?
	jz	@@L100
	inc	si		; 386DX/486DLC

@@L100:

;This code that distinguishes a 386 from a 486 depends on
;the 386's inability to toggle the AC bit in the EFLAGS register,
;but the 486 can. This technique is apparently blessed by Intel.

	;Distinguish between 386 and 486
	;Placed into public domain by Compaq Computers.

	.386

	mov	ax,sp
	and	sp,0FFFCh	;round down to a dword boundary
	pushfd
	pushfd
	pop	edx
	mov	ecx,edx
	xor	edx,EF_AC	;toggle AC bit
	and	ecx,EF_AC
	push	edx
	popfd
	pushfd
	pop	edx
	popfd			;restore original flags
	mov	sp,ax		;restore original stack pointer
	and	edx,EF_AC
	
	cmp	edx,ecx
	jnz	@@486		;it's a 386
	or	si,si
;	jz	@@386sl
	jz	@@L1
	inc	bx
	jmp	@@L1
;@@386sl:
;	call	check386sl
;	jnc	@@L1
;	inc	bx
;	inc	bx
;	jmp	@@L1

@@486:
	; distinguish between Cyrix 486 and Intel 486+
	mov	bx,0Ah
	push	bx
	mov	cx,8D5h
	clr	ax
	mov	dx,ax
	cmp	ax,ax
	pushf
	mov	ax,0FFFFh
	mov	bx,4
	div	bx
	pushf
	pop	ax
	pop	dx
	pop	bx
	and	ax,cx
	and	dx,cx
	cmp	ax,dx
	jnz	@@586
	inc	bx		; Cyrix 486SLC
	inc	bx
	or	si,si
	jz	@@586
	inc	bx		; Cyrix 486DLC
@@586:

; Check for Pentium or later by attempting to toggle the Id bit in EFLAGS reg:
; if we can't, it's an i486.

	; Pentium detection routine
	; Placed in public domain by Dr. Dobbs Journal

        pushfd			; get current flags
	pop	eax
	mov	ecx,eax
	xor	eax,EF_ID	; attempt to toggle ID bit
	push	eax
	popfd
	pushfd			; get new EFLAGS
	pop	eax
	push	ecx		; restore original flags
	popfd
	and	eax,EF_ID	; if we couldn't toggle ID,
	and	ecx,EF_ID	; then this is i486
	cmp	eax,ecx
	jz	@@486sdx	; do not alter BX
; It's Pentium or later. Use CPUID to get processor family.
	clr	eax		; get processor info
	inc	al
	push	bx		; cpuid destroys bx and dx registers!
	cpuid
	pop	bx
	and	ah,0Fh
	cmp	ah,4		; get processor family
	jb	@@386dx		; 386's
	je	@@486sdx2	; 486's - need to distinguish further
	cmp	bl,0Ch		; was Cyrix microcode detected?
	jb	@@P5
	cmp	bl,0Dh
	ja	@@P5
	mov	bl,0Fh		; Cyrix M1 (586)
	jmp	@@L1
@@P5:
	mov	bl,ah		; 5 means Pentium.
	add	bl,8
	jmp	@@L1
@@386dx:
	mov	bx,7		; assume 386sx
	or	si,si		; is it so?
	jz	@@L1
	inc	bx		; 386dx
	jmp	@@L1
@@486sdx2:			; we got here if cpuid works
	mov	bl,0Ah		; 486sx
	test	dx,1		; has FPU on chip?
	jz	@@sx
	inc	bx
@@sx:
	jmp	@@L1

@@486sdx:
	; distinguish between i486dx and i486sx processors
	; based on some 486sx's inability to toggle NE bit of MSW

	.486p
	call	isInOSZwei	; OS/2 won't allow to flip NE bit anyway
	jc	@@L1
	mov	eax,cr0
	mov	ecx,eax
	db	66h,83h,0E0h,0DFh
;	and	eax,0FFFFFFDFh	; flip off NE bit of MSW
	mov	cr0,eax
	mov	eax,cr0
	cmp	eax,ecx
	jnz	@@486dx
	or	eax,MSW_NE	; flip on NE bit of MSW
	mov	cr0,eax
	mov	eax,cr0
	cmp	eax,ecx
	jnz	@@486dx
	dec	bx
@@486dx:
	inc	bx
	mov	eax,ecx
	mov	cr0,eax
@@L1:
	.286p
	smsw	ax
	and	al,1
	mov	bh,al		; get the VM flag into bh
	jmp	@@Ct_200
@@Ct_000:
	mov	bl,4		; assume this is 186/188
	mov	cl,33
	clr	ax
	dec	ax
	shl	ax,cl
	jnz	@@Ct_100	; 186/188 does not actually shift
				; more that 32 bits. It shifts only
				; n mod 32 bits, where n is number of
				; bits to shift.
	mov	bl,2		; assume NEC family
	clr	cx
	dec	cx
;	rep  es: lodsb  - incorrect order of prefixes and thus would
;			  not work as repeated command on Intel's CPUs.
;			  8086/88 accepts only es: rep lodsb order. But
;			  NEC Vxx CPUs process multiple prefix repeated
;			  instructions correctly regardless of their
;			  order.

	db	0F3h,26h,0ACh
;		rep  es: lodsb

	jcxz	@@Ct_100	; was repeated cx times -> NEC V20/V30
	clr	bx		; good old 88/86
@@Ct_100:
	call	Test_Buffer
	jcxz	@@Ct_200	; prefetch buffer length < 6 bytes -> 88 / V20
	inc	bx		; prefetch buffer length = 6 bytes -> 86 / V30
@@Ct_200:
	call	FPU_Type
	mov	FPUType,dl
	mov	ax,bx
	pop	si cx bx
	ret
	endp

	db	13,10
	db	'				Too much is not enough...',13,10
	db	'            				(Deep Purple)',13,10
	db	13,10
	db	'TMIOSDGL(tm) CPU/FPU feature detection library  Version 1.14c',13,10
	db	'Copyright(c) 1992,93,94 by B-coolWare. Released as freeware.',13,10

;check386sl	proc
; CF = 1 if 386SL
; meaning of this code is unclear for me, but Diagsoft states this works
; ok. 
;	cli
;	in	ax,22h
;	mov	cx,ax
;	test	cl,1
;	jnz	@@1
;	mov	ax,8000h
;	out	23h,al
;	xchg	ah,al
;	out	22h,al
;	out	22h,ax
;	jmp	$+2
;	in	ax,22h
;	test	al,1
;	jz	@@2
;@@1:
;	mov	ax,cx
;	or	ah,1
;	out	22h,ax
;	jmp	$+2
;	jmp	$+2
;	in	ax,22h
;	test	al,1
;	jnz	@@2
;	mov	ax,8000h
;	out	23h,al
;	xchg	ah,al
;	out	22h,al
;	out	22h,ax
;	jmp	$+2
;	in	ax,22h
;	test	al,1
;	jz	@@2
;	mov	ax,cx
;	test	al,1
;	jnz	@@3
;	or	ah,1
;	out	22h,ax
;	stc
;	jmp	@@Q
;@@2:
;	mov	ax,cx
;	out	22h,ax
;@@3:
;	clc
;@@Q:
;	sti
;	ret
;	endp

Test_Buffer	proc near
	push	es di
	std
	mov	_bpcs[@@0],41h	; make this code reentrant
	push	cs
	pop	es
	ldi	@@2
	mov	al,_bpcs[@@1]
	mov	cx,3
	cli
	rep	stosb
	cld		; 1
	nop		; 2
	nop		; 3
	nop		; 4	<- 80x88 will cut here and inc cx instruction
@@0:	inc	cx	; 5	   will be overwritten by sti, else we'll get
@@1:			;	   cx = 1, which indicates 80x86
	sti		; 6
@@2:	
	sti
	pop	di es
	ret
	endp

isInOSZwei	proc	near
LOCAL	NM : BYTE : 13
	push	ax bx cx dx di
	mov	ah,64h
	mov	dx,2
	mov	cx,636Ch
	clr	bx
	lea	di,NM
	push	ss
	pop	es
	push	ax cx di
	mov	al,0FFh		; fill buffer with 0FFh
	mov	cx,13
	rep	stosb
	pop	di cx ax
	int	21h		; invoke OS/2 DOS box function "Get Session
	cmp	NM,0FFh		; Title". if it worked - we're under OS/2.
	jz	@@1
	stc
	jmp	@@Q
@@1:
	clc
@@Q:
	pop	di dx cx bx ax
	ret
	endp

fsbp0	equ	<db 0DBh,0E8h>	; IIT xC87 specific instructions
fsbp1	equ	<db 0DBh,0EBh>
fsbp2	equ	<db 0DBh,0EAh>
fmul4x4	equ	<db 0DBh,0F1h>


FPU_Type	proc near
	.8086
	.8087			; check for coprocessor
	push	ds
	push	cs
	pop	ds
	mov	dl,2		; assume no coprocessor present
	fninit
	xor	cx,cx
	jmp	$+2
	mov	fpudata1,5A5Ah
	fnstsw	fpudata1
	mov	ax,fpudata1
	or	al,al
	jnz	@@L15
	fnstcw	fpudata1
	mov	ax,fpudata1
	and	ax,103Fh
	cmp	ax,3Fh
	jne	@@L15
	mov	dl,4		; assume 8087
	fstenv	fpudata3
	fwait
	and	fpudata1,0FF7Fh
	fldcw	fpudata1
	fwait
	fdisi
	fstcw	fpudata1
	fwait
	test	fpudata1,80h
	jnz	@@L15
	mov	dl,8		; assume 80287
	.286
	.287
	fninit
	fld1
	fldz
	fdivp	st(1),st
	fld	st
	fchs
	fcompp
	fstsw	fpudata1
	fwait
	mov	ax,fpudata1
	sahf
	jz	@@L14
	mov	dl,0Ch		; assume 80387
@@L14:
	.286
	.287

	cmp	bl,09h		; 486 or up?
	jb	@@checkIIT	; IIT x87's bank switching instructions causes
	jmp	@@50		; 486s to hang... don't know why.

@@checkIIT:

	finit			; trying to perform a matrix multiplication
	fsbp1			; available on IIT xC87 math chips.
	wait
	fldz			; loading matrix coeffs in bank #1
	fld1
	fldz
	fldz
	fld1
	fldz
	fldz
	fldz
	wait
	finit
	fsbp2
	wait
	fldz			; loading matrix coeffs in bank #2
	fldz
	fldz
	fld1
	fldz
	fldz
	fld1
	fldz
	wait
	finit
	fsbp0
	wait
	fldz			; generating vector
	fld1
	fld	st(0)
	fadd	st,st(0)
	fld	st(0)
	fadd	st,st(2)
	fmul4x4			; do the multiplication,...
	wait
	fstp	iit1		; ...store results...
	fstp	iit2
	fstp	iit3
	fstp	iit4
	wait			; ...and check them.
	cmp	_wp [iit4+2],4040h
	jnz	@@50
	cmp	_wp [iit3+2],4000h
	jnz	@@50
	cmp	_wp [iit2+2],3F80h
	jnz	@@50
	cmp	_wp [iit1],0
	jnz	@@50
				; wow! it works - IIT chip
	cmp	dl,0Ch
	jz	@@300
	mov	dl,22
	jmp	@@L15
@@300:
	mov	dl,24
	jmp	@@L15
@@50:
	finit			; check of Cyrix ?C87
	fldpi
	f2xm1
	fstp	fpudata2
	cmp	_wp [fpudata2+2],3FC9h
	jne	@@L15
	or	dl,2		; this is Cyrix
@@L15:				; check for Weitek 1167 - can be installed
	cmp	bl,7		; on 386+ systems
	jb	@@L16
	.386
	clr	eax
	int	11h
	test	eax,1000000h
	.8086
	jz	@@L16
	or	dl,1		; Weitek present
@@L16:
	cmp	bl,0Eh
	jb	@@17
	and	dl,3
	or	dl,10h
	jmp	@@30
@@17:
	cmp	bl,0Bh		; 486dx ?
	jnz	@@L17
	cmp	dl,3		; no FPU so far?
	ja	@@builtin
	dec	bl		; this is 486sx - some tricky sx'es pass thru
				; sx-specific test
	jmp	@@31
@@builtin:
	and	dl,1
	or	dl,10h		; internal FPU
	jmp	@@nobuilt
@@L17:
	cmp	bl,0Eh		; Pentium or up?
	jae	@@builtin
	cmp	bl,0Dh		; Cx486dx/dlc?
	jnz	@@nobuilt
	cmp	dl,12h		; 4C87?
	jz	@@builtin
	cmp	dl,13h		; 4C87?
	jz	@@builtin
@@nobuilt:
	cmp	bl,06		; 80286?
	jnz	@@30
	cmp	dl,0Ch		; 387?
	jz	@@XL
	cmp	dl,0Dh		; 387+Weitek?
	jnz	@@30
@@XL:
	add	dl,8		; assume 80287XL - tricky
@@30:
	cmp	bl,0Ch		; Cx486slc?
	jz	@@is387
	cmp	bl,0Ah		; 486sx?
	jnz	@@31
@@is387:
	cmp	dl,0Ch		; 387?
	jz	@@487sx
	cmp	dl,0Dh
	jnz	@@31
@@487sx:
	and	dl,1
	or	dl,6	
@@31:
	cmp	dl,4		; any 87 present?
	jb	@@L18
	fldenv	fpudata3	; restore FPU environment
@@L18:
	pop	ds
	ret
	endp
fpudata1	dw	?
fpudata2	dd	?
fpudata3	db	14 dup(?)

iit1		dd	6F772049h
iit2		dd	7265646Eh
iit3		dd	20666920h
iit4		dd	00544949h
	
	END
