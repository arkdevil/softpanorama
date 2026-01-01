; This is file MSWITCH.ASM
;
; Copyright (C) 1991 DJ Delorie, 24 Kirsten Ave, Rochester NH 03867-2954
;
; This file is distributed under the terms listed in the document
; "copying.dj", available from DJ Delorie at the address above.
; A copy of "copying.dj" should accompany this file; if not, a copy
; should be available from where this file was obtained.  This file
; may not be distributed without a verbatim copy of "copying.dj".
;
; This file is distributed WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;

;	History:191,1
	title	switch between real and protected mode
	.386p

	include	build.inc
	include	segdefs.inc
	include tss.inc
	include gdt.inc
	include idt.inc

;------------------------------------------------------------------------

	start_data16

	extrn	_gdt:gdt_s
	extrn	_idt:idt_s
	extrn	_tss_ptr:word
	extrn	_exception:near
	extrn	_npx:byte
	extrn	_screen_seg:word

	public	_was_exception
_was_exception	dw	0	; exceptions set this to 1

	public	_dr, _dr0, _dr1, _dr2, _dr3, _dr6, _dr7
_dr	label	dword
_dr0	dd	0
_dr1	dd	0
_dr2	dd	0
_dr3	dd	0
	dd	0
	dd	0
_dr6	dd	0
_dr7	dd	0

	end_data16

;------------------------------------------------------------------------

	.286c
	start_bss

	extrn	_i_tss:tss_s
	public	_c_tss, _a_tss, _o_tss, _p_tss, _f_tss
_c_tss	label	tss_s	; for "real mode" state
	db	type tss_s dup (?)
_a_tss	label	tss_s	; for running program
	db	type tss_s dup (?)
_o_tss	label	tss_s	; for convenience functions
	db	type tss_s dup (?)
_p_tss	label	tss_s	; for page faults
	db	type tss_s dup (?)
_f_tss	label	tss_s	; for page handling
	db	type tss_s dup (?)

temp_87c	dw	1 dup (?)
temp_87s	dw	1 dup (?)

	end_bss
	.386p

;------------------------------------------------------------------------

sound	macro
	mov	al,033h
	out	061h,al
	endm

	start_code16

	extrn	__do_load_npx:near

real_stack	dd	?
real_idt	dw	0400h, 0000h, 0000h
imask1		db	?
imask2		db	?

	public	_go32
_go32	proc	near

	mov	ax,DGROUP
	mov	dx,0
	shld	dx,ax,4
	shl	ax,4
	add	ax,_tss_ptr
	adc	dx,0
	mov	_gdt[g_atss].base0,ax
	mov	_gdt[g_atss].base1,dl
	mov	_gdt[g_atss].base2,dh
	mov	bx,_tss_ptr
	and	[bx].tss_eflags,  0ffffbdffh	; clear NT flag
	and	_c_tss.tss_eflags,0ffffbdffh	; clear NT flag
	and	_i_tss.tss_eflags,0ffffbdffh	; clear NT flag
	and	_p_tss.tss_eflags,0ffffbdffh	; clear NT flag
	and	_f_tss.tss_eflags,0ffffbdffh	; clear NT flag
	or	_a_tss.tss_eflags,000000200h	; set IE flag for a_tss only

	and	_gdt[g_ctss].stype,0FDh		; clear busy flag
	and	_gdt[g_atss].stype,0FDh		; clear busy flag
	and	_gdt[g_itss].stype,0FDh		; clear busy flag
	and	_gdt[g_ptss].stype,0FDh		; clear busy flag

	mov	_was_exception,0

	; set real_stack for return from _go32
	mov	word ptr cs:real_stack,sp
	mov	word ptr cs:real_stack+2,ss
	mov	eax,0
	mov	ax,sp
	mov	esp,eax		; make sure it's OK

	cli

if TOPLINEINFO
	mov	ax,_screen_seg
	mov	es,ax
	mov	word ptr es:[0], 0b00h+'P'
	mov	word ptr es:[2], 0b00h+' '
endif

;	in	al,21h
;	mov	cs:imask1,al
;	or	al,01h
;	out	21h,al

	in	al,0a1h
	or	al,20h
	mov	cs:imask2,al
	mov	al,0dfh
	out	0a1h,al

	call	set_a20

	lgdt	fword ptr _gdt[g_gdt]
	lidt	fword ptr _gdt[g_idt]

	mov	eax,0
	mov	cr2,eax	; so we can tell INT 0D from page fault

	mov	eax,cr0
	or	al,1
	mov	cr0,eax		; we're in protected mode!
	db	0eah		; JMP
	dw	offset go_protect_far_jump
	dw	g_rcode
go_protect_far_jump:

	mov	ax,g_rdata
	mov	ds,ax
	mov	es,ax
	mov	ss,ax
	mov	ax,g_core
	mov	fs,ax
	mov	gs,ax

;	mov	bx,7870h
;	call	set_interrupt_controller

	mov	eax,_dr0
	mov	dr0,eax
	mov	eax,_dr1
	mov	dr1,eax
	mov	eax,_dr2
	mov	dr2,eax
	mov	eax,_dr3
	mov	dr3,eax
	mov	eax,_dr7
	mov	dr7,eax

	mov	bx,_tss_ptr
	mov	eax,[bx].tss_cr3
	cmp	eax,0
	je	set_paging_far_jump
	mov	cr3,eax
	mov	eax,cr0
	or	eax,80000000h
	mov	cr0,eax		; paging enabled!
	db	0eah
	dw	offset set_paging_far_jump
	dw	g_rcode
set_paging_far_jump:

	mov	bx,_tss_ptr
	cmp	bx,offset DGROUP:_a_tss
	jne	no_npx_load
	call	__do_load_npx	; in case it's stored in memory.
no_npx_load:

	mov	ax,g_ctss
	ltr	ax

	jmpt	g_atss		; load state from VCPU

_go32	endp

; _go_real_mode must follow the task jump, so a task jump to return
; is valid

	public	_go_real_mode
_go_real_mode	proc	near

	cli
	mov	ax,g_rdata
	mov	ds,ax
	mov	es,ax
	mov	fs,ax
	mov	gs,ax
	mov	ss,ax

	mov	eax,dr6
	mov	_dr6,eax

	mov	eax,cr0
	and	eax,07ffffff6h ; clear PE, TS, PG
	mov	cr0,eax

	db	0eah
	dw	offset back_to_real_far_jump
	dw	_TEXT
back_to_real_far_jump:

	lidt	fword ptr cs:real_idt
	lss	sp,cs:real_stack

;	mov	bx,0870h
;	call	set_interrupt_controller

;	mov	al,cs:imask1
;	out	21h,al
	mov	al,cs:imask2
	out	0a1h,al

if TOPLINEINFO
	mov	ax,_screen_seg
	mov	es,ax
	mov	word ptr es:[0], 0b00h+'R'
	mov	word ptr es:[2], 0b00h+' '
endif
	mov	ax,DGROUP
	mov	ds,ax
	mov	es,ax
	mov	fs,ax
	mov	gs,ax

	sti

	mov	bx,_tss_ptr
	mov	al,[bx].tss_irqn
	cmp	al,75h
	je	short not_hard	; for NPX errors
	cmp	al,79h
	je	short not_hard	; to check for ^C
	cmp	al,70h
	jb	short not_hard
	cmp	al,7fh
	ja	short not_hard
	cmp	al,78h
	jb	short no_move
	sub	al,70h
no_move:
	mov	byte ptr cs:[irq_d+1],al
	jmp	short irq_d_jmp	; to flush the queue
irq_d_jmp:
irq_d	db	0cdh,0		; generated INT opcode
	jmp	_go32
not_hard:

	ret

hexchar	db	'0123456789ABCDEF'

_go_real_mode	endp

;------------------------------------------------------------------------

dout	macro	a,d
	mov	al,d
	out	a,al
	jmp	$+2
	jmp	$+2
	endm

set_interrupt_controller:
	dout	20h,11h
	dout	0a0h,11h
	dout	21h,bh
	dout	0a1h,bl
	dout	21h,4
	dout	0a1h,2
	dout	21h,1
	dout	0a1h,1
	ret

;------------------------------------------------------------------------

set_a20	proc	near
	pushf
	cli
	mov	ax,0
	mov	fs,ax
	mov	ax,0ffffh
	mov	gs,ax
	mov	bx,fs:[0]
	mov	word ptr fs:[0],1234
	cmp	word ptr gs:[16],1234
	je	need_to_set_a20
	mov	word ptr fs:[0],4321
	cmp	word ptr gs:[16],4321
	je	need_to_set_a20
	mov	fs:[0],bx
	popf
	ret

need_to_set_a20:
	mov	fs:[0],bx
	call	waitkb
	mov	al,0d1h
	out	64h,al
	call	waitkb
;	mov	al,0d3h
	mov	al,0dfh		; Patrick
	out	60h,al
	call	waitkb
	mov	al,0ffh		; Patrick
	out	64h,al		; Patrick
	call	waitkb		; Patrick
	mov	ax,0
	mov	fs,ax
	mov	ax,0ffffh
	mov	gs,ax
	mov	bx,fs:[0]
	in	al,092h		; 092h is the system control port "A"
				; for PS/2 models
	or	al,2		; this sets the A20 bit in register al
	jmp	SHORT $+2	; forget the instruction fetch
	out	092h,al		; set the A20 bit on

wait_for_valid_a20:
	mov	word ptr fs:[0],1234
	cmp	word ptr gs:[16],1234
	je	wait_for_valid_a20
	mov	word ptr fs:[0],4321
	cmp	word ptr gs:[16],4321
	je	wait_for_valid_a20

	mov	fs:[0],bx
	popf
	ret

waitkb:
	mov	cx,0
waitkb1:
	in	al,64h
	test	al,2
	loopnz	waitkb1
	je	waitkb3
waitkb2:
	in	al,64h
	test	al,2
	loopnz	waitkb1
waitkb3:
	ret
set_a20	endp

;------------------------------------------------------------------------

	public	_cputype	; from Intel 80486 reference manual
_cputype:
	pushf
	pop	bx
	and	bx,0fffh
	push	bx
	popf
	pushf
	pop	ax
	and	ax,0f000h
	cmp	ax,0f000h
	jz	bad_cpu
	or	bx,0f000h
	push	bx
	popf
	pushf
	pop	ax
	and	ax,0f000h
	jz	bad_cpu

	smsw	ax
	test	ax,1
	jnz	bad_mode
	mov	ax,0
	ret

bad_mode:
	mov	ax,2
	ret

bad_cpu:
	mov	ax,1
	ret

;------------------------------------------------------------------------

	end_code16

;------------------------------------------------------------------------

	start_code32

	end_code32

;------------------------------------------------------------------------

	end
