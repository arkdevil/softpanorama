; ----------------------------------------------------------------------------
; CPU.ASM  Simple program that demonstates use of the 
;	   Too-Much-In-One-So-Don't-Get-Lost(tm) library
;
; Copyright(c) 1992,94 by B-coolWare,  Written by Bobby Z.
; All rights reserved.
; ----------------------------------------------------------------------------
;
; to assemble this:
;
; tasm /t/m cpu
; tlink /t/x cpu
; del cpu.obj
;

	model	tiny, pascal
	.code
	org	100h
	LOCALS
	JUMPS
Start:
	jmp	Prg_Begin
INCLUDE	UNIDEF.INC		; macros
INCLUDE	LSTRING.ASH		; Lstring macro
__WriteStr__	EQU	1	; compile WriteStr routine
__PRINT_CPU__	EQU	1	; compile print_CPU routine
__PRINT_FPU__	EQU	1	; compile print_FPU routine
__PRINT_STEP__	EQU	1	; compile print_Step routine
INCLUDE	CPU_TYPE.ASH		; include TMIOSDGL(tm) routines
INCLUDE	DOSINOUT.ASH		; include DOS input/output routines
Prg_Begin:
	ldx	Cprt
	call	WriteStr
	ldx	CPUIs
	call	WriteStr
	call	print_CPU
	int	20h
Lstring Cprt,<CPU Type Identifier/Asm  Version 1.14c  Copyright(c) 1992,94 by B-coolWare.>,CrLf
Lstring CPUis,<  Central Processor: >
Lstring EndLine,<>,CrLf
	end	Start
