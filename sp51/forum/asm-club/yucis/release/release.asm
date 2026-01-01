;██████████████████████████████████████████████████████████████████████████
;██								         ██
;██			        RELEASE				         ██
;██								         ██
;██████████████████████████████████████████████████████████████████████████

code		segment	byte public
		assume	cs:code, ds:code
		locals	@@
window_width	equ	28			; width
max_resids	equ	18			; max resident quantity
save_screen	equ	byte ptr ds:[5Ch]	; FCB1, FCB2, params

		org	100h

start:
		jmp	install
int_table	db	1024 dup (0)
save_ptr	dd	0

scan_code	db	13			; scan-code '='
kbd_flags	db	08h			; Alt

mcb_1st		dw	0			; DOS's 1st MCB
in_flag		db	0			; in handler flag (<>0)
normal_attr	db	1Fh
revers_attr	db	70h
current_name	db	'RELEASE.M +',0,0
up_frames	db	'╔═╗'
middle_frames	db	'║ ║'
bottom_frames	db	'╚═╝'

video_base	dd	0
video_row	db	0
video_col	db	0
selected	dw	0

other_name	db	'programs', 0
destroyed_mess	db	'???? block destroyed ?????'
destroyed_len	equ	$-offset destroyed_mess
line_bufer	db	window_width dup (' ')

prog_count	dw	0
prog_segms	dw	max_resids dup (0)	; up TO max_resids Resident
;;;;======================
segm_nonUMB	dw	0
UMBupper	dw	0
UMBstart	equ	0c000h
presEGA		db	0
OldVideoMode	db	0
;;;;======================

Int21h		proc	far
		pushf				; save flags
		cmp	ah,49h
		je	@@free_mem
		cmp	ah,4Bh
		je	@@exec
		cmp	ah,31h
		je	@@keep
		cmp	ax,0F0F0h
		je	@@check_inst
@@exit:
		popf				; Pop flags
		db	0EAh			; jmp Old 21h
Old21h		dd	0

@@check_inst:
		mov	bx,cs
		jmp	@@exit
@@exec:
		call	Starting
		jmp	@@exit
@@keep:
		call	Add_to_list
		jmp	@@exit
@@free_mem:
		call	Check_free
		jmp	@@exit
Int21h		endp


Int27h		proc	far
		pushf				; Push flags
		add	dx,0Fh
		shr	dx,1
		shr	dx,1
		shr	dx,1
		shr	dx,1
		call	Add_to_list
		shl	dx,1
		shl	dx,1
		shl	dx,1
		shl	dx,1
		popf				; Pop flags
		db	0EAh
Old27h		dd	00000h			; jmp	Old27h
Int27h		endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

Add_to_list	proc	near
		push	bp
		call	push_all
		cld				; Clear direction
		mov	ah,51h
		pushf
		call	cs:Old21h		; Get PSP
		mov	ax,bx
		dec	ax
		mov	es,ax			; ES -> MCB
		xor	di,di			; Zero register
		cmp	byte ptr es:[di],'Z'
		je	@@last			; it's last MCB
		mov	byte ptr es:[di],'Z'
;==============================================
		mov	cx,cs:UMBupper
		cmp	ax,UMBstart	; Block in UMB?
		jae	@@cont		; yes, don't get convent'l memory
;==============================================
		push	ax
		int	12h			; Put (memory size)/1K in ax
		mov	cl,6
		shl	ax,cl			; Shift w/zeros fill
;==============================================
;;	Если хотите, чтобы pазмеp свободной памяти выводился
;;	совсем уж точно, pаскомментиpуйте эти 4 стpочки
;;	Тогда pезидентный pазмеp пpогpаммы увеличится на 16 байт...
;;		cmp	cs:UMBupper,0	; present UMB?
;;		jz	@@nodec
;;		dec	ax		; yes, decrement size
;;	@@nodec:
;==============================================
		mov	cx,ax
		pop	ax
	@@cont:
		sub	cx,es:[di+1]		; Owner
		mov	es:[di+3],cx 		; Size
@@last:
		inc	ax
		add	bx,dx
		mov	es,bx			; di=0
		stosw				; Store ax to es:[di]
		push	cs
		pop	ds
		cli
		mov	bx,prog_count
		shl	bx,1
		mov	prog_segms[bx],es
		inc	prog_count

		mov	si,offset current_name
		call	copy_name

		mov	di,0Fh
		push	dx
		push	es
		mov	bp,di
		xor	al,al			; bp = counter
		stosb
		mov	bx,di			; bx = last offset
		xor	si,si
		mov	ds,si
		mov	di,offset int_table
		push	cs
		pop	es
		mov	cx,100h
		xor	dx,dx
@@cmp_loop:
		cmpsw
		jne	@@first
		cmpsw
		je	@@continue

		dec	di
		dec	di
		dec	si
		dec	si
@@first:
		pop	ds
		inc	byte ptr ds:[bp]
		mov	ds:[bx],dl
		inc	bx
		mov	ax,cs:[di-2]
		mov	ds:[bx],ax
		mov	ax,cs:[di]
		mov	ds:[bx+2],ax
		add	bx,4
		inc	di
		inc	di
		inc	si
		inc	si
		push	ds
		xor	ax,ax
		mov	ds,ax
@@continue:
		inc	dl
		loop	@@cmp_loop

		pop	ds
		pop	dx

		mov	ax,word ptr cs:save_ptr
		mov	[bx],ax
		mov	ax,word ptr cs:save_ptr+2
		mov	[bx+2],ax
		add	bx,4

		mov	cx,bx
		inc	cx
		shr	cx,1		; size in words
		xor	si,si
		xor	di,di
@@check_sum:
		lodsw
		xor	di,ax
		loop	@@check_sum
		mov	[si],di		; checking summ

		sti
		inc	bx
		inc	bx
		shr	bx,1
		shr	bx,1
		shr	bx,1
		shr	bx,1
		inc	bx
		add	dx,bx

		mov	bp,dx
		call	pop_all
		mov	dx,bp
		pop	bp
		retn
Add_to_list	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

Starting	proc	near
		cli
		call	push_all
		push	ds
		mov	cx,200h
		xor	si,si			; Zero register
		mov	di,offset int_table
		mov	ds,si
		push	cs
		pop	es
		cld
		rep	movsw			; Copy vectors
		mov	si,4A8h
		movsw
		movsw				; SAVE PTR
		sti
		pop	ds
		mov	si,dx
		push	ds
		pop	es
		cmp	byte ptr [si+1],':'
		jne	@@no_drive
		add	si,2
@@no_drive:
		mov	di,si
		xor	al,al
		xor	cx,cx
		dec	cx
		repne	scasb			; Find EOL
		neg	cx
		dec	cx
		dec	cx
		mov	di,si
		mov	al,'\'
@@find_slash:
		repne	scasb			; Find last slash
		jcxz	@@proceed
		mov	si,di
		jmp	@@find_slash
@@proceed:
		push	cs
		pop	es
		mov	di,offset current_name
		call	copy_name
		call	pop_all
		retn
Starting	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

Check_free	proc	near
		call	push_all
		mov	ax,es
		mov	bx,offset prog_count
		mov	cx,cs:[bx]		; programs counter
@@comp_loop:
		inc	bx
		inc	bx
		mov	ds,cs:[bx]		; get block segment
		cmp	ax,ds:[0]		; PSP are equals?
		je	@@found_PSP
		loop	@@comp_loop
@@exit:
		call	pop_all
		retn
@@found_PSP:
		push	cs
		pop	ds
		dec	prog_count
@@shift:
		dec	cx
		jz	@@exit
		mov	ax,[bx+2]
		mov	[bx],ax
		inc	bx
		inc	bx
		jmp	@@shift
Check_free	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

copy_name	proc	near
		push	cx
		mov	cx,12
@@loop:		lodsb				; String [si] to al
		or	al,al			; Zero ?
		stosb				; Store al to es:[di]
		loopnz	@@loop
		jz	@@exit
		mov	al,0
		stosb
@@exit:		pop	cx
		retn
copy_name	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

Int09h		proc	far
		push	ax ds
		in	al,60h
		cmp	al,cs:scan_code
		jne	@@origin
		xor	ax,ax
		mov	ds,ax
		mov	al,ds:[417h]		; keyboard flags
		mov	ah,cs:kbd_flags
		and	al,ah
		cmp	al,ah
		jne	@@origin
		push	cs
		pop	ds
		cmp	in_flag,0
		jne	@@origin
		not	in_flag
		in	al,61h
		mov	ah,al
		or	al,80h
		out	61h,al
		mov	al,ah
		out	61h,al
		mov	al,20h
		out	20h,al

		call	push_all

		call	set_videobase
		jc	@@skip
		call	hot_key
@@skip:
		call	pop_all

		not	in_flag
		pop	ds ax
		iret
@@origin:
		pop	ds ax
		db	0EAh
Old09h		dd	0

Int09h		endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

hot_key		proc	near
		lds	si,cs:video_base
		push	cs
		pop	es
		mov	di,offset save_screen
		mov	ax,104
		xor	bx,bx
		call	copy_screen		; save screen

; ------------------ Up border
		push	cs
		pop	ds
		mov	si,offset up_frames
		les	di,video_base
		call	draw_border

; ------------------- Loop for residents
		mov	bx,offset prog_count
		mov	cx,[bx]			; programs counter
;;;==================================================
		xor	dx,dx	; last non-UMB block
;;;==================================================
@@draw_loop:
		push	cx
		push	es di

		call	clear_line
		inc	bx
		inc	bx
;;======	mov	ds,[bx]
;;;==================================================
		mov	ax,[bx]
		mov	ds,ax
		cmp	ax,UMBstart
		jae	@@umb1
		mov	dx,ds
	@@umb1:
;;;==================================================
		call	check_sum
		jz	@@sum_ok

		cld
		push	cs
		pop	ds
		push	cs
		pop	es
		mov	di,offset line_bufer+1
		mov	si,offset destroyed_mess
		mov	cx,destroyed_len
		rep	movsb
		jmp	@@make_draw

@@sum_ok:
		xor	si,si
		lodsw				; String [si] to ax
		call	put_segment

		mov	di,offset line_bufer+6
		call	copy_name		; copy program name

		mov	ax,ds:[0]		; PSP address
		mov	cx,offset @@add_blocks
		call	make_all_blocks
		call	write_size

@@make_draw:
		pop	di es

		call	draw_line

		pop	cx
		loop	@@draw_loop

; ------------ Prepare last line 'programs'
		push	es di

		call	clear_line
		push	cs
		pop	es

;;;=======	mov	ds,[bx]
;;;;=========================================
		or	dx,dx		;was there non-UMB TSR?
		jnz	@@was		;yes, put its seg in ds
		mov	ax,cs:segm_nonUMB ; no, load our segm
		jmp	@@c1
   @@was:	mov	ds,dx
;;;;=========================================
		xor	si,si			; Zero register
		lodsw				; String [si] to ax
		dec	ax
		mov	ds,ax
		inc	si
		add	ax,[si]
;;;==========================================
	@@c1:
;;;==========================================
		inc	ax
		mov	ds,ax
		inc	ax
		mov	bx,ax
		call	put_segment

		push	ds
		push	cs
		pop	ds
		mov	si,offset other_name	; 'programs'
		mov	di,offset line_bufer+6
		call	copy_name
		pop	ds

		int	12h			; Put (memory size)/1K in ax
		mov	cl,6
		shl	ax,cl			; Shift w/zeros fill
		sub	ax,bx
		call	write_size		; size

		pop	di es
		call	draw_line

; ----------------- Bottom border
		push	cs
		pop	ds
		mov	si,offset bottom_frames
		call	draw_border

		mov	selected,0
@@read_loop:
		les	di,video_base
		add	di,163

		mov	al,normal_attr		; not selected
		mov	cx,prog_count
		sub	cx,selected
		call	change_attr

		mov	al,revers_attr		; selected
		mov	cx,selected
		inc	cx
		call	change_attr

		mov	dx,selected
		mov	ah,0
		int	16h
		push	cs
		pop	ds

		cmp	al,0Dh
		je	@@pressed_enter
		cmp	al,1Bh
		je	@@quit
		cmp	ax,4800h		; up code
		je	@@pressed_up
		cmp	ax,5000h		; down code
		je	@@pressed_down
		jmp	@@read_loop
@@pressed_up:
		cmp	dx,prog_count
		jge	@@read_loop
		inc	selected
		jmp	@@read_loop
@@pressed_down:
		cmp	dx,0
		jle	@@read_loop
		dec	selected			; (8017:0BF3=0)
		jmp	@@read_loop
@@pressed_enter:
		cmp	cs:selected,0
		je	@@quit			; Jump if equal

		push	cs
		pop	ds
		mov	dx,selected
		call	make_release
;;;=======	jc	@@quit

@@quit:
		les	di,cs:video_base
		push	cs
		pop	ds
		mov	si,offset save_screen
		xor	ax,ax
		mov	bx,104
		call	copy_screen		; restore screen
;;;===========================================
		xor	ax,ax
		mov	al,cs:OldVideoMode
		cmp	al,0ffh
		je	@@v1
		or	al,80h
		int	10h
	@@v1:
;;;===========================================
		ret
@@add_blocks:
		add	ax,ds:[3]
		inc	ax
		retn
hot_key		endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

make_all_blocks	proc	near
		push	ds bx dx
		mov	dx,ax
		xor	ax,ax
		mov	ds,cs:mcb_1st
@@comp_loop:
		cmp	dx,ds:[1]
		jne	@@not_owner
		call	cx
@@not_owner:
		mov	bx,ds
		cmp	byte ptr ds:[0],'M'
		je	@@e1
		cmp	byte ptr ds:[0],'Z'
		jne	@@exit
;;;==========================================================
		cmp     bx,UMBstart	; seg 'Z' in UMB?
	@@ne1:  jae	@@exit         	; yes, finish
;;;==========================================================
	@@e1:
		add	bx,ds:[3]
		inc	bx
		mov	ds,bx
		jmp	@@comp_loop
@@exit:
		pop	dx bx ds
		retn
make_all_blocks	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

copy_screen	proc	near
		cld
		mov	dx,max_resids+2+1
@@again:
		mov	cx,window_width
		rep	movsw
		add	si,ax
		add	di,bx
		dec	dx
		jnz	@@again
		retn
copy_screen	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

draw_border	proc	near
		cld
		mov	ah,normal_attr
		lodsb
		stosw
		mov	cx,window_width-2
		lodsb
		rep	stosw
		lodsb
		stosw
		add	di,104
		retn
draw_border	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

clear_line	proc	near
		cld
		push	cs			; prepare empty line
		pop	es
		mov	di,offset line_bufer
		mov	si,offset middle_frames
		movsb
		lodsb
		mov	cx,window_width-2
		rep	stosb
		movsb
		retn
clear_line	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

check_sum	proc	near
		call	push_all
		xor	cx,cx
		mov	cl,byte ptr ds:[0Fh]
		mov	ax,cx		; vectors
		shl	ax,1		; in word
		shl	ax,1		; in double
		add	cx,ax		; add vector numbers
		add	cx,16+4+2+1	; add header+SAVE_PTR+check_sum+1
		shr	cx,1
		xor	bx,bx
		xor	ax,ax
@@loop:
		xor	ax,ds:[bx]
		inc	bx
		inc	bx
		loop	@@loop
		or	ax,ax
		call	pop_all
		retn
check_sum	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

draw_line	proc	near
		push	cs
		pop	ds
		mov	si,offset line_bufer
		mov	ah,normal_attr
		mov	cx,window_width
		cld
@@write_loop:
		lodsb
		stosw
		loop	@@write_loop
		add	di,104
		retn
draw_line	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

make_release	proc	near
		cli
		mov	bx,offset prog_count
		mov	cx,[bx]
		inc	cx
		shl	cx,1
		add	bx,cx
		cld				; Clear direction
@@again:
		push	ds
		push	dx
		dec	bx
		dec	bx
		mov	ds,[bx]			; DS = program info segment

		call	check_sum
		jz	@@ok_sum

		pop	dx
		pop	ds
		sti
		stc
		retn
@@ok_sum:
		mov	si,0Fh
		xor	ax,ax
		mov	es,ax
		lodsb
		mov	cx,ax
		jcxz	@@skip_vectors
@@rest_vectors:
		xor	ax,ax
		lodsb
		shl	ax,1
		shl	ax,1
		mov	di,ax
		movsw
		movsw
		loop	@@rest_vectors

@@skip_vectors:
		mov	di,4A8h
		movsw
		movsw			; restore SAVE PTR

		mov	ax,ds:[0]		; PSP
		mov	cx,offset @@free_mem
		call	make_all_blocks

		pop	dx
		pop	ds
		dec	prog_count
		dec	dx
		jnz	@@again

		sti
		clc
		retn

@@free_mem:
		mov	ds:[1],ax		; free memory
		retn
make_release	endp



;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

put_segment	proc	near
		mov	di,offset line_bufer+1
		push	cs
		pop	es
		push	ax
		push	cx
		mov	ch,al
		mov	cl,4
		mov	al,ah
		shr	al,cl
		call	put_hex_char
		mov	al,ah
		and	al,0Fh
		call	put_hex_char
		mov	ah,ch
		mov	al,ah
		shr	al,cl
		call	put_hex_char
		mov	al,ah
		and	al,0Fh
		call	put_hex_char
		pop	cx
		pop	ax
		retn
put_segment	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

put_hex_char	proc	near
		add	al,'0'
		cmp	al,'9'
		jbe	@@skip
		add	al,7
@@skip:		stosb
		retn
put_hex_char	endp



;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

write_size	proc	near		; ax = size at paragraphs
		push	ax
		push	bx
		push	cx
		push	dx

		mov	di,offset line_bufer+26
		push	cs
		pop	es
		xor	dx,dx
		mov	bx,10h
		mul	bx
		mov	bl,0Ah
		xor	cl,cl
@@loop:
		cmp	dl,0Ah
		jb	@@less
		sub	dl,0Ah
		mov	cl,1
@@less:
		div	bx			; ax,dx rem=dx:ax/reg
		call	put_dec_char
		xor	dx,dx			; Zero register
		or	cl,cl			; Zero ?
		jz	@@skip
		xor	cl,cl			; Zero register
		mov	dx,1
		jmp	@@loop
@@skip:
		or	ax,ax
		jnz	@@loop
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
write_size	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

put_dec_char	proc	near
		std
		push	ax
		mov	al,dl
		add	al,'0'
		stosb
		pop	ax
		retn
put_dec_char	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

set_videobase	proc	near
		mov	cs:OldVideoMode,0ffh ; ff means 'mode not changed'
		xor	ax,ax
		mov	ds,ax
		mov	al,ds:[449h]
		mov	dx,0B000h
		cmp	al,7
		je	@@ok_mode
		mov	dx,0B800h
		cmp	al,3
		je	@@ok_mode
		cmp	al,2
		je	@@ok_mode
;;;;;;===============================================
		cmp	cs:presEGA,0
		jz	@@noega
		mov	cs:OldVideoMode,al
		mov	ax,3
		mov	al,83h
		push	dx
		int	10h
		pop	dx
;;;;;;===============================================
@@ok_mode:
		mov	ax,ds:[44Eh]
		push	cs
		pop	ds
		mov	word ptr video_base,ax
		mov	word ptr video_base+2,dx
		clc
		retn
;;;;;;===============================================
	@@noega:stc
		retn
;;;;;;===============================================
set_videobase	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

change_attr	proc	near
		jcxz	@@exit
		cld
@@again:
		push	cx
		mov	cx,window_width-2
@@loop:
		stosb
		inc	di
		loop	@@loop
		add	di,108
		pop	cx
		loop	@@again
@@exit:
		retn
change_attr	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

push_all	proc	near
		pop	cs:temp_addr
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	ds
		push	es
		jmp	cs:temp_addr
push_all	endp
temp_addr	dw	0

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

pop_all		proc	near
		pop	cs:temp_addr
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		jmp	cs:temp_addr
pop_all		endp


install_part:

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

up_case		proc	near
		cmp	al,'a'
		jb	@@exit
		cmp	al,'z'
		jbe	@@to_up
		cmp	al,'а'
		jb	@@exit
		cmp	al,'п'
		jbe	@@to_up
		cmp	al,'я'
		ja	@@exit
		cmp	al,'р'
		jb	@@exit
		sub	al,30h
@@to_up:	sub	al,20h
@@exit:		retn
up_case		endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

get_param	proc	near
		dec	si
@@next:
		inc	si
		mov	al,[si]
		cmp	al,0Dh
		je	@@exit
		cmp	al,' '
		je	@@next
		cmp	al,9
		je	@@next
@@exit:
		ret
get_param	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

unload_FCB	proc	near
		push	cs
		pop	es
		mov	di,offset dest_name
		mov	cx,8
		cld
		call	@@skip_blanks
		mov	al,'.'
		stosb
		mov	cx,3
		call	@@skip_blanks
		mov	byte ptr [di],0
		dec	di
		cmp	byte ptr [di],'.'
		jne	@@skip1
		mov	byte ptr [di],0
@@skip1:
		cmp	byte ptr dest_name,0
		je	@@break

		mov	ds,segment_val
		mov	cx,prog_count
		mov	dx,1
@@find_loop:
		push	ds cx dx
		mov	bx,cx
		dec	bx
		shl	bx,1
		mov	ds,ds:prog_segms[bx]	; block_adress
		mov	si,2
		cld
		mov	cx,13
		mov	di,offset dest_name
		mov	al,-1
@@comp_loop:
		or	al,al
		je	@@pop_regs
;;;=====================================================
		cmp	byte ptr es:[di],0
       	       	jz	@@pop_regs
;;;=====================================================
		lodsb
		call	up_case
		scasb
		loope	@@comp_loop
@@pop_regs:
		pop	dx cx ds
		je	@@found

		inc	dx
		loop	@@find_loop
@@break:
		mov	al,5		; invalid name or name not found
		retn

@@found:
		call	make_release
		jc	@@break
		mov	al,0
		retn

@@skip_blanks:
		push	si cx
@@skip_loop:
		lodsb
		cmp	al,' '
		stosb
		loopne	@@skip_loop
		jne	@@dones
		dec	di
@@dones:
		pop	cx si
		add	si,cx
		ret
unload_FCB	endp

dest_name	db	13 dup (0)

Setup		proc	near
		sti
		xor	cx,cx
		loop	$
		loop	$

		push	cs
		pop	ds
		mov	dx,offset int09setup
		mov	ax,2509h
		int	21h

		mov	ah,9
		mov	dx,offset setup_mess
		int	21h
@@wait:
		mov	ah,1
		int	16h
		jz	@@check
		mov	ah,0
		int	16h
@@check:
		cmp	new_scan,0
		je	@@wait

		lds	dx,Old09h
		mov	ax,2509h
		int	21h
		push	cs
		pop	ds

		cmp	new_flags,0
		je	@@exit

		mov	dx,offset new_key_mess
		mov	ah,9
		int	21h

		mov	al,new_scan
		mov	ah,new_flags
		push	ax
		call	view_hot_key
		pop	ax
		mov	scan_code,al
		mov	kbd_flags,ah

		lds	dx,release_name
		mov	ax,3D02h
		int	21h
		push	cs
		pop	ds
		jc	@@write_error
		mov	bx,ax

		mov	dx,100h
		mov	cx,offset kbd_flags+1
		sub	cx,dx
		mov	ah,40h
		int	21h
		jc	@@write_error
		cmp	ax,cx
		jne	@@write_error

		mov	ah,3Eh
		int	21h
		jc	@@write_error

		mov	ax,segment_val
		or	ax,ax
		jz	@@exit
		mov	es,ax
		mov	al,cs:new_scan
		mov	ah,cs:new_flags
		mov	es:scan_code,al
		mov	es:kbd_flags,ah
@@exit:
		ret
@@write_error:
		mov	dx,offset writing_err
		mov	ah,9
		int	21h
		jmp	@@exit

new_scan	db	0
new_flags	db	0

Setup		endp

int09setup	proc	far
		push	ax ds
		in	al,60h
		cmp	al,0
		je	@@skip
		cmp	al,0E0h
		je	@@skip
		sub	al,80h
		js	@@skip
		mov	cs:new_scan,al
		pushf
		call	dword ptr cs:Old09h
		xor	ax,ax
		mov	ds,ax
		mov	al,ds:[417h]		; keyboard flags
		and	al,0Fh
		mov	cs:new_flags,al
		jmp	@@exit
@@skip:
		pushf
		call	dword ptr cs:Old09h
@@exit:
		pop	ds ax
		iret
int09setup	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

view_hot_key	proc	near
		push	cs
		pop	es
		mov	di,offset hot_key_text
		push	di
		push	ax
		call	shift_to_text
		pop	ax
		call	scan_to_text
		pop	dx
		mov	ah,9
		int	21h
		retn
view_hot_key	endp

hot_key_text	db	40 dup ('$')

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

scan_to_text	proc	near
		cld
		push	cs
		pop	ds
		mov	si,offset key_table
		xor	cx,cx
		mov	cl,al
		mov	ah,ch
		jcxz	@@copy
@@next:
		cmp	[si],ah
		je	@@exit
@@again:
		lodsb
		or	al,al
		jnz	@@again
		loop	@@next
@@copy:
		mov	al,'<'
		stosb
@@char:
		lodsb
		or	al,al
		jz	@@done
		stosb
		jmp	@@char
@@done:
		mov	al,'>'
		stosb
@@exit:
		ret
scan_to_text	endp

key_table	equ	this byte
		db	'None',0
		db	'Esc',0
		db	'1',0
		db	'2',0
		db	'3',0
		db	'4',0
		db	'5',0
		db	'6',0
		db	'7',0
		db	'8',0
		db	'9',0
		db	'0',0
		db	'-',0
		db	'=',0
		db	'BackSp',0
		db	'Tab',0
		db	'Q',0
		db	'W',0
		db	'E',0
		db	'R',0
		db	'T',0
		db	'Y',0
		db	'U',0
		db	'I',0
		db	'O',0
		db	'P',0
		db	'[',0
		db	']',0
		db	'Enter',0
		db	'Ctrl',0
		db	'A',0
		db	'S',0
		db	'D',0
		db	'F',0
		db	'G',0
		db	'H',0
		db	'J',0
		db	'K',0
		db	'L',0
		db	';',0
		db	'''',0
		db	'`',0
		db	'LShift',0
		db	'\',0
		db	'Z',0
		db	'X',0
		db	'C',0
		db	'V',0
		db	'B',0
		db	'N',0
		db	'M',0
		db	',',0
		db	'.',0
		db	'/',0
		db	'RShift',0
		db	'PrtScr',0
		db	'Alt',0
		db	'Space',0
		db	'CapLock',0
		db	'F1',0
		db	'F2',0
		db	'F3',0
		db	'F4',0
		db	'F5',0
		db	'F6',0
		db	'F7',0
		db	'F8',0
		db	'F9',0
		db	'F10',0
		db	'NumLock',0
		db	'ScrLock',0
		db	'Home',0
		db	'Up',0
		db	'PgUp',0
		db	'Gray-',0
		db	'Left',0
		db	'Gray[5]',0
		db	'Right',0
		db	'Gray+',0
		db	'End',0
		db	'Down',0
		db	'PgDn',0
		db	'Ins',0
		db	'Del',0
		db	0


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

shift_table	equ	this byte
		db	'RightShift',0
		db	'LeftShift',0
		db	'Ctrl',0
		db	'Alt',0
		db	0

shift_to_text	proc	near
		cld
		push	cs
		pop	ds
		mov	si,offset shift_table
@@next:
		cmp	byte ptr [si],0
		je	@@done
		shr	ah,1
		jnc	@@skip

		push	ax
@@char:
		lodsb
		or	al,al
		jz	@@end_copy
		stosb
		jmp	@@char
@@end_copy:
		mov	al,'+'
		stosb
		pop	ax
		jmp	@@next

@@skip:
		push	ax
@@next_skip:	lodsb
		or	al,al
		jne	@@next_skip
		pop	ax
		jmp	@@next
@@done:
		ret
shift_to_text	endp

;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

release_name	dd	0
segment_val	dw	0

install		proc	near
		xor	ax,ax
		mov	di,ax
		mov	es,ds:[02Ch]		; окружение
		cld
@@next:		mov	cx,-1
		repnz	scasb
		cmp	al,es:[di]
		jnz	@@next
		add	di,3
		mov	word ptr release_name,di
		mov	word ptr release_name+2,es

		mov	ah,52h			; get list of lists
		int	21h
		mov	ax,es:[bx-2]
		mov	mcb_1st,ax
		mov	ax,3509h		; get vector 09
		int	21h
		mov	word ptr Old09h,bx
		mov	word ptr Old09h+2,es

		xor	bx,bx
		mov	ax,0F0F0h		; already installed?
		int	21h
		mov	segment_val,bx

		mov	si,81h
		push	si
@@up_case_loop:
		mov	al,[si]
		call	up_case
		mov	[si],al
		inc	si
		cmp	al,0Dh
		jne	@@up_case_loop

		pop	si
		call	get_param
		cmp	byte ptr [si],0Dh
		jne	@@analyze
		cmp	segment_val,0
		jne	@@already
		jmp	@@continue
@@already:
		mov	dx,offset alr_inst
		mov	ah,9
		int	21h
		mov	ds,segment_val
		mov	al,scan_code
		mov	ah,kbd_flags
		push	cs
		pop	ds
		call	view_hot_key
		mov	al,1		; allready installed
;;;=====	jmp	@@terminate
;;;==============================================
		jmp	@@typetsrs
;;;==============================================
@@analyze:
		cmp	byte ptr [si],'?'
		je	@@help
		cmp	word ptr [si],'?/'
		je	@@help
		cmp	word ptr [si],'S/'
		je	@@setup
		cmp	segment_val,0
		je	@@not_installed
		cmp	word ptr [si],'A/'
		je	@@release
		cmp	word ptr [si],'R/'
		je	@@release_all
		cmp	byte ptr [si],'/'
		je	@@help

		mov	si,5Dh		; FCB1+1 offset
		call	unload_FCB
		jmp	@@terminate
@@help:
		mov	dx,offset help_text
		mov	ah,9
		int	21h
		mov	al,0
		jmp	@@terminate

@@not_installed:
		mov	dx,offset not_inst
		mov	ah,9
		int	21h
		mov	al,2			; not installed
		jmp	@@terminate
@@release:
		mov	ds,segment_val
		mov	dx,prog_count
		dec	dx
		jmp	@@make_release
@@setup:
		call	Setup
		mov	al,0
		jmp	@@terminate

@@release_all:
		mov	ds,segment_val
		mov	dx,prog_count
@@make_release:
		cmp	dx,0
		mov	al,3
		je	@@terminate
		call	make_release
		mov	al,3			; can't unload
		jc	@@terminate
		mov	al,0
;;;;===========================================================
@@typetsrs:	push	ax
		call	type_tsrs
		pop	ax
;;;;===========================================================
@@terminate:
		mov	ah,4Ch			; yes
		int	21h			;  terminate with al=return code

@@continue:
;;;;===================================================
; Find segm_nonUMB ----------------------
		mov	ax,cs
		cmp	ax,UMBstart	; not UMB ?
		jb	@@u2		; no, OK

		mov	es,cs:mcb_1st
		mov	bx,es
	@@s1:
		mov	es,bx
		inc	bx
		mov	ax,dx		;pre-previous
		mov	dx,bx		;previous
		cmp	byte ptr es:[0],'Z'	; Last?
		je	@@u2
		add	bx,es:[3]
		cmp	bx,UMBstart		; in UMB?
		jb	@@s1
	@@u2:	mov	segm_nonUMB,ax

; Find UMBupper --------------------------
		mov	bx,ax
		dec	bx
	@@l3:	mov	es,bx		;es=bx= next MCB
		inc	bx
		cmp	byte ptr es:[0],'M'
		je	@@nxt
		cmp	byte ptr es:[0],'Z'	; Last?
		jne	@@e
		cmp     bx,UMBstart
		jb	@@nxt
		add	bx,es:[3]
		mov	UMBupper,bx
		jmp	@@e
	@@nxt:
		add	bx,es:[3]
		jmp	@@l3
	@@e:
				;Free env seg
		mov	es,ds:[2ch]
		mov	ah,49h
		int	21h
		mov	word ptr ds:[2ch],0
;;;;===================================================
		mov	dx,offset current_name
		call	Starting

		push	cs
		pop	ds
		mov	ax,3521h		; DOS Services  ah=function 35h
		int	21h			;  get intrpt vector al in es:bx
		mov	word ptr Old21h,bx
		mov	word ptr Old21h+2,es
		mov	dx,offset Int21h
		mov	ah,25h			; DOS Services  ah=function 25h
		int	21h			;  set intrpt vector al to ds:dx
		mov	ax,3527h		; DOS Services  ah=function 35h
		int	21h			;  get intrpt vector al in es:bx
		mov	word ptr Old27h,bx
		mov	word ptr Old27h+2,es
		mov	dx,offset Int27h
		mov	ah,25h			; DOS Services  ah=function 25h
		int	21h			;  set intrpt vector al to ds:dx

		mov	dx,offset Int09h
		mov	ax,2509h
		int	21h

		mov	dx,offset now_inst	; Display message
		mov	ah,9
		int	21h

		mov	al,scan_code
		mov	ah,kbd_flags
		call	view_hot_key
;;;==================================================
			; Detect EGA
		mov	ah,12h
		mov	bl,10h
		int	10h
		cmp	bl,10h
		je	@@noEGA
		mov	presEGA,1
	@@noEGA:
;;;==================================================
		mov	dx,offset install_part
		inc	dx
		int	27h			; Terminate & stay resident

install		endp

alr_inst	db	'RELEASE already installed. Activate by $'
now_inst	db	'RELEASE now installed. Activate by $'
not_inst	db	'RELEASE not installed',13,10,'$'
help_text	db	'Usage:',13,10
		db	'RELEASE /? or ?    - get Help',13,10
		db	'RELEASE            - install',13,10
		db	'RELEASE NAME.EXT   - unload NAME.EXT & all residents, loaded later',13,10
		db	'RELEASE /A         - unload All residents',13,10
		db	'RELEASE /R         - unload all with Release',13,10
		db	'RELEASE /S         - run Setup (define new hot-key)',13,10
		db	'$'
setup_mess	db	13,10,'Press hot-key combination for setup'
		db	13,10,'or single key for cancel ?$'
new_key_mess	db	13,10,'New hot key is: $'
writing_err	db	13,10,'Can''t write new configuration',13,10,'$'

;;;;======================================================================

active_mess	db	13,10,'Active resident programs:', 13,10,10
		db	'Addr   Name           Size   Interrupts', 13,10
		db	'───────────────────────────────────────────',13,10
		db	'$'


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;	       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

type_line	proc	near
		cld
		push	ax ds si
		push	cs
		pop	ds
		mov	si,offset line_bufer+1
		mov	cx,window_width-2
	@@l:	lodsb
		or	al,al
		jnz	@@no0
		mov	al,' '
	@@no0:	int	29h		; DOS display char al (undoc)
		loop	@@l
	@@ex:	pop	si ds ax
		retn
type_line	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;	       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

type_CRLF	proc	near
		push	ax
		mov	al,0Dh
		int	29h
		mov	al,0Ah
		int	29h
		pop	ax
		retn
type_CRLF	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;	       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

TypeHexAL	proc	near
		push	ax cx
		mov	ch,al
		mov	cl,4
		shr	al,cl
		call	TypeHexDigit
		mov	al,ch
		and	al,0Fh
		call	TypeHexDigit
		pop	cx ax
		retn
TypeHexDigit:
		add	al,'0'
		cmp	al,'9'
		jbe	@@loc_71
		add	al,7
@@loc_71:	int	29h
		retn
TypeHexAL	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;	       SUBROUTINE
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

type_tsrs	proc	near
		push	ds
		call	type_CRLF
		push	cs
		pop	ds
		mov	dx,offset active_mess
		mov	ah,9
		int	21h
; ------------------- Loop for residents
		mov	bx,offset prog_count
		mov	ds,segment_val
		mov	cx,[bx]			; programs counter
;;;--------------------------------------------------
		xor	dx,dx	; last non-UMB block
;;;--------------------------------------------------
@@draw_loop:
		push	cx es di

		call	clear_line
		inc	bx
		inc	bx
		push	ds
;;------	mov	ds,[bx]
;;;--------------------------------------------------
		mov	ax,[bx]
		mov	ds,ax
		cmp	ax,UMBstart
		jae	@@umb1
		mov	dx,ds
	@@umb1:
;;;--------------------------------------------------

		call	check_sum
		jz	@@sum_ok

		pop	ds	;restore stack
		cld
		push	cs
		pop	ds
		push	cs
		pop	es
		mov	di,offset line_bufer+1
		mov	si,offset destroyed_mess
		mov	cx,destroyed_len
		rep	movsb
		pop	di es

		call	type_line
		jmp	@@make_draw

@@sum_ok:
		xor	si,si
		lodsw				; String [si] to ax
		call	put_segment

		mov	di,offset line_bufer+6
		call	copy_name		; copy program name

		mov	ax,ds:[0]		; PSP address
		mov	cx,offset @@add_blocks
		call	make_all_blocks
		call	write_size
		call	type_line
					; Type Vectors
		mov	si,0fh
		cld
		lodsb
		mov	ah,0
		mov	cx,ax		;cx = n of vectors
		jcxz	@@nl1
		mov	al,' '
		int	29h
		int	29h
		int	29h
		int	29h
	lv1:	lodsb
		cmp	al,22h
		jb	l22
		cmp	al,23h
		jna	noty
	l22:	call	TypeHexAL
		mov	al,' '
		int	29h
	noty:	add	si,4
		loop	lv1
@@nl1:
		pop	ds
		pop	di es


@@make_draw:
		call	type_CRLF

		pop	cx
		loop	@@draw_loop

; ------------ Prepare last line 'programs'
		push	es di

		call	clear_line
		push	ds
		pop	es

;;;-------	mov	ds,[bx]
;;;;-----------------------------------------
		or	dx,dx		;was there non-UMB TSR?
		jnz	@@wasumb
		mov	ax,es:segm_nonUMB
		jmp	@@c1
   @@wasumb:	mov	ds,dx
;;;;-----------------------------------------
		xor	si,si
		lodsw			; ax = last TSR's PSP; si=2
		dec	ax		;ax=MCB
		mov	ds,ax		;ds=MCB
		inc	si		;si=3
		add	ax,[si]		;ax = ax + size of block
	@@c1:	inc	ax		;ax = next MCB
		mov	ds,ax
		inc	ax
		mov	bx,ax
		call	put_segment

		push	ds
		push	cs
		pop	ds
		mov	si,offset other_name	; 'programs'
		mov	di,offset line_bufer+6
		call	copy_name
		pop	ds

		int	12h			; Put (memory size)/1K in ax
		mov	cl,6
		shl	ax,cl			; Shift w/zeros fill
		sub	ax,bx
		call	write_size		; size

		pop	di es
		call	type_line
		call	type_CRLF
		pop	ds
@@quit:		ret

@@add_blocks:
		add	ax,ds:[3]
		inc	ax
		retn

type_tsrs	endp




code		ends

		end	start

