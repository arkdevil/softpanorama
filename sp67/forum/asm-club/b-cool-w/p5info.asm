; -----------------------------------------------------------------------------
; P5INFO.ASM  Pentium Processor Feature Information		  Version 1.00
;
; Copyright(c) 1994 by B-coolWare.  Written by Bobby Z.
; This code is part of TMIOSDGL(tm) CPU/FPU Feature Detection Library.
; -----------------------------------------------------------------------------
; These routines also work on new Intel's 386 and 486 chips returning model
; info and features info. You should check for 5 in chip series field to
; assure this is really P5.
;
; Interpretation of the information returned by CPU is based on my research
; in Quarterdeck's Manifest 2.04. I still missing the P5 data sheet, so I
; can't make any warranty that it is correct. I just hope it is...
;
	MODEL	TPASCAL		; uncomment this for TP/BP
;	MODEL	LARGE,C		; uncomment this for C/C++ compilers
;		^^^^^ - change to preferred memory model

	.CODE

	LOCALS
	JUMPS

	INCLUDE	UNIDEF.INC

	PUBLIC	CheckP5, GetP5Features, GetP5Vendor

; GetP5Features returns word with following bitfields:

FPUonChip		equ	00000001b
EnhancedV86		equ	00000010b
IOBreakPoints		equ	00000100b
PageSizeExtensions	equ	00001000b
TimeStampCounter	equ	00010000b
ModelSpecificRegisters	equ	00100000b
MachineCheckException	equ	01000000b
CMPXCHG8BInstruction	equ	10000000b

; CheckP5 returns word with following bitfields:

chipInfo	record chipFamily:4, chipModel:4, chipStep:4

; GetP5Vendor returns word that contains following ids:

GenuineIntel	equ	0
noP5Found	equ	-1

EF_ID	equ	00200000h	; ID flag in EFLAGS

cpuid	equ	<db 0Fh,0A2h>	; P5 info instruction, also handled by new
				; 386's and 486's

CheckP5		proc

	mov	ax,sp
	push	sp
	pop	bx
	cmp	bx,ax
	jnz	@@noP5
	mov	ax,7000h
	pushf
	push	ax
	popf
	pushf
	pop	ax
	popf
	and	ax,7000h
	jz	@@noP5
	.386
	pushfd
	pop	eax
	mov	ecx,eax
	xor	eax,EF_ID
	push	eax
	popfd
	pushfd
	pop	eax
	push	ecx
	popfd
	and	eax,EF_ID
	and	ecx,EF_ID
	cmp	eax,ecx
	jz	@@noP5
	clr	eax
	inc	al
	cpuid
	jmp	@@Q
	.8086
@@noP5:
	clr	ax
@@Q:
	ret
	endp

GetP5Features	proc
	call	CheckP5
	or	ax,ax
	jz	@@Q
	xchg	dx,ax
@@Q:
	ret
	endp

GetP5Vendor	proc
	call	CheckP5
	or	ax,ax
	jnz	@@Ok
	clr	bx
	dec	bx
@@Ok:
	xchg	bx,ax
	ret
	endp

	END
