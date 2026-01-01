kbd_tail	equ	1Ch  
kbd_head	equ	1Ah
bufer_start	equ	80h
bufer_end	equ	82h
left		equ	4Bh
right		equ	4Dh
up		equ	48h
down		equ	50h
enter_key	equ	1C0Dh
esc_key		equ	011Bh
back_sp		equ	0E08h
  
code		segment	byte public
		assume	cs:code, ds:code

		org	100h

start:
		jmp	install

handler		proc	far
		push	cs
		pop	ds
		test	al,2
		jnz	left_pressed
		test	al,8
		jnz	right_pressed
		test	al,20h
		jnz	center_pressed

		mov	ax,0Bh			; last motion
		call	old_33
		add	cx,ddx
		mov	ax,cx
		and	ax,7
		mov	ddx,ax			; rest x

		add	dx,ddy
		mov	ax,dx
		and	ax,7
		mov	ddy,ax			; rest y

		sar	cx,1
		sar	cx,1
		sar	cx,1

		sar	dx,1
		sar	dx,1
		sar	dx,1
@@loop:
		mov	ax,cx
		or	ax,dx
		jz	@@exit

		xor	ax,ax
		cmp	cx,ax
		jz	@@skip_x
		jg	@@ung_r

		mov	ah,left
		call	unget_char
		inc	cx
		jmp	@@skip_x

@@ung_r:
		mov	ah,right
		call	unget_char
		dec	cx
@@skip_x:
		cmp	dx,0
		jz	@@loop
		jg	@@ung_d
		mov	ah,up
		call	unget_char
		inc	dx
		jmp	@@loop
@@ung_d:
		mov	ah,down
		call	unget_char
		dec	dx
		jmp	@@loop

left_pressed:
		mov	ax,enter_key
		call	unget_char
		retf
right_pressed:
		mov	ax,esc_key
		call	unget_char
		retf
center_pressed:
		mov	ax,back_sp
		call	unget_char
@@exit:		retf

ddx		dw	0
ddy		dw	0

unget_char	proc	near
		mov	bx,40h
		mov	ds,bx
		mov	bx,ds:kbd_tail
		mov	si,bx
		add	si,2
		cmp	si,ds:bufer_end
		jne	@@lab
		mov	si,ds:bufer_start
@@lab:
		cmp	si,kbd_head
		je	@@done
		mov	[bx],ax
		mov	ds:kbd_tail,si
@@done:		retn
unget_char	endp

handler		endp

int_33		proc	far
		or	ax,ax
		jnz	@@turn_off
		call	old_33
		push	ax cx dx es
		push	cs
		pop	es
		mov	ax,0Ch
		mov	cx,2Bh
		mov	dx,offset handler
		call	old_33
		pop	es dx cx ax
		mov	byte ptr cs:handler,0Eh	; PUSH CS opcode
		iret
@@turn_off:
		mov	byte ptr cs:handler,0CBh ; RETF opcode
		call	old_33
		iret
int_33		endp

old_33		proc	near
		pushf
		db	9Ah
old_int33	dd	0
		retn
old_33		endp

install:
		mov	ax,3533h
		int	21h
		mov	word ptr old_int33,bx
		mov	word ptr old_int33+2,es
		mov	ax,es
		or	ax,bx
		jz	@@not_inst

		mov	ax,0
		int	33h
		or	ax,ax			; mouse installed ?
		jnz	ms_install
@@not_inst:
		mov	ah,9
		mov	dx,offset txt_bad
		int	21h
		retn
ms_install:
		mov	ah,9
		mov	dx,offset txt_msg
		int	21h

		mov	ax,2533h
		mov	dx,offset int_33
		int	21h

		mov	ax,0
		int	33h

		mov	dx,offset install
		int	27h

txt_bad		db	7,'Mouse driver not found',13,10,'$'
txt_msg		db	'Mouse driver enchancer. Mouse''s buttons are:',13,10
		db	'            Left   Center   Right',13,10
		db	'          ┌─────╖ ┌──────╖ ┌─────╖',13,10
		db	'          │Enter║ │BackSp║ │ Esc ║',13,10
		db	'          ╘═════╝ ╘══════╝ ╘═════╝',13,10
		db	' Copyright (c) 1991 by S. B. Balter, Donetsk$'

code		ends
		end	start
