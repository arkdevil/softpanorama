;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;									;;
;;	BOOT.ASM		=== Copyright (C) MamSoft 1988-91 ===	;;
;;									;;
;;	Ver 3.0р - Now DesqView(C), HyperDisk(C) and 386(C) aware.	;;
;;	System requirements: 286 or later or compatible.		;;
;;									;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;									;;
;;	The source code may be recompiled, rewritten, and modified	;;
;;	in any way, as long as the above copyright message is included	;;
;;	in the text.							;;
;;									;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.286

	.model	tiny

	extrn	printm:near,prints:near,prword:near,prcrlf:near

	.code

	org	100h

boot:	call	printm
	db	'Boot v3.0 ∙ MamSoft 1988-91',0
	call	prcrlf

	mov	ax,500h				; look for HyperDisk
bloo:	mov	es,ax
	mov	di,0Ah
	mov	si,offset hd_id
	mov	cx,4
	repe	cmpsw
	je	hdisk				; we found it!
	inc	ax
	or	ax,ax				; search the whole memory
	jne	bloo
	call	printm
	db	'Hyperdisk not found',0
	jmp	short rboo

hd_id	db	'CACHE$$$'

hdisk:	call	prints
	db	'Disabling HyperDisk at ',0
	mov	ax,es
	call	prword
	call	prcrlf

	mov	byte ptr es:[44h],-1		; necessary control table
	mov	byte ptr es:[47h],1		;  entries to "disable"
	mov	byte ptr es:[48h],0
	mov	byte ptr es:[4Eh],0
	mov	byte ptr es:[94h],1
	mov	word ptr es:[0A0h],0
	mov	ax,8EEEh			; HyperDisk hook
	mov	di,12h				; ES:DI is control table
	int	13h

	push	0
	pop	es
	mov	dx,es:[46Ch]
	mov	cx,es:[46Eh]
wloop:	mov	bx,es:[46Ch]			; wait 3 seconds just to
	mov	ax,es:[46Eh]			;  be sure (of what??)
	sub	ax,cx
	sbb	bx,dx
	cmp	bx,18*3
	jb	wloop

rboo:	call	prints
	db	'Rebooting...',0
	push	0
	pop	es
	mov	word ptr es:[472h],1234h	; set up for warm boot
	cli					; zero all segment regs
	xor	ax,ax				;  and SP
	mov	ds,ax
	mov	es,ax
	mov	ss,ax
	mov	sp,ax
	push	2
	push	0F000h
	push	0FFF0h
	iret					; JMP F000:FFF0

	end	boot

	end
