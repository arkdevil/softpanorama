;╔══════════════════════════════════════════════════════════════════════════╗
;║                              DIMMER 1.0                                  ║
;║                                                                          ║
;║                     Simple screen saver for VGA                          ║
;║                                                                          ║
;║                    Programmed by Arkady Moreynis                         ║
;║                                                                          ║
;║                       Compile with TASM 2.0                              ║
;║                                                                          ║
;║                           06-06-91 16:50                                 ║
;║                                                                          ║
;║                                                                          ║
;╚══════════════════════════════════════════════════════════════════════════╝

_DIMMER		equ	'd','i'

_CALL_FAR	equ	09Ah
_JMP_FAR	equ	0EAh

_DIM_CX		equ	632
_DIM_DX		equ	0

_NEVER_CX	equ	632
_NEVER_DX	equ	192

_NUM_LOOP	equ	42

_REFRESH	equ	0
_DIM		equ	1

_TRUE		equ	1
_FALSE		equ	0

_TABLE_LEN	=	256*3*2
_STACK_LEN	=	128
_TOP_STACK	=  	offset loader + _TABLE_LEN+_STACK_LEN - 2

Our_Table	equ	loader
Save_Table	equ	loader[256*3]


		locals
		jumps

prog		segment
		assume	cs:prog
		org	100h
start:
		jmp	loader

Busy		db	0
Delay		dw	0
Dim		db	_FALSE
Is_Mouse	db	_FALSE
Mouse_CX	dw	0
Mouse_DX	dw	0
Max_Delay	dw	1092*5
Never		db	_FALSE
Now		db	_FALSE
Ticks_In_Min    dw      1092
Method		db	_DIM
Old_SS		dw	0
Old_SP		dw	0
Dim_Seg		dw	0

Out_Event	label	word
Change_Mouse	db	_FALSE
Was_Key		db	_FALSE

Crit_Sect	label	word
Is_10h		db	0
Is_33h		db	0

; ds:si -> table
Write_DAC:
		cli

		mov	cx, 256*3

		xor	al, al
		mov	dx, 03C8h
		out	dx, al

		inc	dx

	@@l:
		lodsb
		out	dx, al
		loop	@@l

		sti
		ret

Dim_Now:
		cmp	cs:Method, _REFRESH
		je	@@refresh

		push	ds
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di

		cld
		mov	ax, cs
		mov	es, ax
		mov	ds, ax

		mov	ax, 1017h
		xor	bx, bx
		mov	cx, 256
		mov	dx, offset Our_Table
		pushf
		call 	dword ptr cs:Old_10h

		mov	si, dx
		mov	di, offset Save_Table
		mov	cx, 256*3
	rep	movsb

		xor	ch, ch
		mov	cl, _NUM_LOOP
@@dec:
		push	cx

		mov	si, offset Our_Table
		mov	di, offset Our_Table

		mov	cx, 256*3
@@item:
		lodsb
		mov	ah, al
		shl	ah, 1
		add	ah, al
		cmp	ah, [di+(256*3)]
		je	@@no_dec
		dec	al
	@@no_dec:
		stosb
		loop	@@item

		mov	si, offset Our_Table
		call	Write_DAC

		mov	cx, 6000
	@@t:	loop	@@t


		pop	cx

		loop	@@dec

		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds

		jmp	@@out
@@refresh:
		push	ax
		push	bx

		mov	ax, 1201h
		mov	bl, 36h
		pushf
		call 	dword ptr cs:Old_10h

		pop	bx
		pop	ax
@@out:
		ret

Dim_Out:
		cmp	cs:Method, _REFRESH
		je	@@refresh

		push	ds
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di

		mov	ax, cs
		mov	ds, ax
		mov	es, ax

		xor	ch, ch
		mov	cl, _NUM_LOOP

@@inc:
		push	cx

		mov	si, offset Our_Table
		mov	di, offset Our_Table

		mov	cx, 256*3
@@item:
		lodsb
		cmp	al, [di+(256*3)]
		je	@@no_inc
		inc	al
	@@no_inc:
		stosb
		loop	@@item

		mov	si, offset Our_Table
		call	Write_DAC

		mov	cx, 2000
	@@t:	loop	@@t


		pop	cx

		loop	@@inc

		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds

		jmp	@@out
@@refresh:
		push	ax
		push	bx

		mov	ax, 1200h
		mov	bl, 36h
		pushf
		call 	dword ptr cs:Old_10h

		pop	bx
		pop	ax
@@out:
		ret

Pres_08h	label	word
		db	_DIMMER
Int_08h:
		sti

		pushf
		db	_CALL_FAR
Old_08h		dd	0

		cli

		inc	cs:Busy
		cmp	cs:Busy, 1
		jne 	@@out

		sti

		cmp	cs:Crit_Sect, 0
		jne	@@out

		cmp	cs:Max_Delay, 0
		je	@@out

		mov	cs:Old_SP, sp
		mov	cs:Old_SS, ss

		mov	ss, cs:Dim_Seg
		mov	sp, _TOP_STACK

		cmp	cs:Is_Mouse, _FALSE
		je	@@no_mouse

		push	ax
		push	bx
		push	cx
		push	dx

		mov	cs:Change_Mouse, _FALSE
		mov	cs:Never, _FALSE
		mov	cs:Now, _FALSE

		mov	ax, 0003h
		pushf
		call 	dword ptr cs:Old_33h

		cmp	cx, _DIM_CX
		jb	@@never_check
		cmp	dx, _DIM_DX
		jne	@@never_check
		mov	cs:Now, _TRUE
		jmp	@@ord_check
@@never_check:
		cmp	cx, _NEVER_CX
		jb	@@ord_check
		cmp	dx, _NEVER_DX
		jb	@@ord_check
		mov	cs:Never, _TRUE
		mov	cs:Delay, 0
@@ord_check:
		cmp	cs:Mouse_CX, cx
		je	@@check_dx
		mov	cs:Change_Mouse, _TRUE
		jmp	@@do8

	@@check_dx:
		cmp	cs:Mouse_DX, dx
		je	@@do8
		mov	cs:Change_Mouse, _TRUE
@@do8:
		mov	cs:Mouse_CX, cx
		mov	cs:Mouse_DX, dx

		pop	dx
		pop	cx
		pop	bx
		pop	ax

@@no_mouse:
		cmp	cs:Dim, _FALSE		; bright
		je	@@check_bright
		; dimmed now

		cmp	cs:Out_Event, _FALSE
		je	@@ret

		mov	cs:Dim, _FALSE

		call	Dim_Out

		mov	cs:Delay, 0

		cmp	cs:Now, _FALSE
		je	@@ret

		cmp	cs:Is_Mouse, _FALSE
		je	@@ret

		push	ax
		push	cx
		push	dx

		mov	ax, 0004h
		mov	cx, _DIM_CX
		mov	dx, _DIM_DX + 8
		pushf
		call 	dword ptr cs:Old_33h

		pop	dx
		pop	cx
		pop	ax

		jmp	@@ret

@@check_bright:
		; bright now

		cmp	cs:Never, _TRUE
		je	@@ret

		cmp	cs:Max_Delay, 0
		je	@@ret

		cmp	cs:Now, _TRUE
		je	@@dim

		inc	cs:Delay

		push	ax
		mov	ax, cs:Max_Delay
		cmp	cs:Delay, ax
		pop	ax
		jb	@@ret

@@dim:
		mov	cs:Dim, _TRUE

		call	Dim_Now

		mov	cs:Was_Key, _FALSE
@@ret:
		mov	ss, cs:Old_SS
		mov	sp, cs:Old_SP

@@out:
		dec	cs:Busy

		iret

Pres_09h	label	word
		db	_DIMMER
Int_09h:
		pushf
		db	_CALL_FAR
Old_09h		dd	0

		cli

		inc	cs:Busy
		cmp	cs:Busy, 1
		jne	@@out

		sti

		mov	cs:Was_Key, _TRUE
		mov	cs:Delay, 0

		cmp	cs:Method, _REFRESH
		jne	@@out
		cmp	cs:DIM, _FALSE
		je	@@out

		push	ax

		mov	ah, 11h
		int	16h
		jz	@@ret

		mov	ah, 10h
		int	16h

	@@ret:
		pop	ax

@@out:
		dec	cs:Busy

		iret

Pres_10h	label	word
		db	_DIMMER
Int_10h:
		pushf
		inc	cs:Is_10h
		popf

		pushf
		db	_CALL_FAR
Old_10h		dd	0

		pushf
		dec	cs:Is_10h
		popf

		iret

Pres_2Fh	label	word
		db	_DIMMER
Int_2Fh:
		cmp	ah, 64h
		je	@@our

		db	_JMP_FAR
Old_2Fh		dd	0

@@our:
                cmp     al, 4
		ja	@@out

		push	si

		mov	si, ax
		and	si, 0FFh
		shl	si, 1
		jmp	cs:Disp[si]

Disp		dw	@@check_inst
		dw	@@dim_now
		dw	@@time
		dw	@@method
                dw      @@param

@@check_inst:
		mov	al, 0FFh
		jmp	@@ret
@@dim_now:
		mov	ax, cs:Max_Delay
		mov	cs:Delay, ax
		jmp	@@ret
@@time:
                push    dx
                mov     ax, bx
		mul	cs:Ticks_In_Min
                pop     dx
		mov	cs:Max_Delay, ax
		jmp	@@ret
@@method:
		mov	cs:Method, bl
                jmp     @@ret
@@param:
                push    dx
                xor     dx, dx
                mov     ax, cs:Max_Delay
                div     cs:Ticks_In_Min
                pop     dx
                mov     bl, cs:Method
@@ret:
		pop	si
@@out:
		iret

Int_33h:
		pushf
		inc	cs:Is_33h
		popf

		pushf
		db	_CALL_FAR
Old_33h		dd	0

		pushf
		dec	cs:Is_33h
		popf

		iret

		even


_NOT_RESIDENT	equ	0
_NOT_TOP	equ	1
_OK_RESIDENT	equ	2

_HELP		equ	0
_INSTALL	equ	2
_UNINSTALL	equ	4
_PARAM		equ	6
_ERROR		equ	8

loader:
		mov	ah, 09
		mov	dx, offset Msg_Cpr
		int	21h

		xor	dl, dl

		mov	ax, 6400h
		int	2Fh
		cmp	al, 0FFh
		jne	end_check

		mov	ax, 3508h
		int	21h
		mov	ax, es:[bx-2]
		cmp	ax, Pres_08h
		jne	p1
		inc	dl
	p1:
		mov	ax, 3509h
		int	21h
		mov	ax, es:[bx-2]
		cmp	ax, Pres_09h
		jne	p2
		inc	dl
	p2:
		mov	ax, 3510h
		int	21h
		mov	ax, es:[bx-2]
		cmp	ax, Pres_10h
		jne	p3
		inc	dl
	p3:
		mov	ax, 352Fh
		int	21h
		mov	ax, es:[bx-2]
		cmp	ax, Pres_2Fh
		jne	p4
		inc	dl
	p4:
		cmp	dl, 4
		jne	d1
		mov	Status, _OK_RESIDENT
		jmp	end_check
	d1:
		or	dl, dl
		je	end_check
		mov	Status, _NOT_TOP
	end_check:

		call	Check_Cmd_Line		; es = dimmer segment
						; if resident
						; bx = code
		mov	dx, offset Msg_Err

		jmp	Jmp_Table[bx]

Jmp_Table	dw	help
		dw	install
		dw	uninstall
		dw	param
		dw	err_exit

uninstall:
		mov	dx, offset Err_Int
		cmp	Status, _NOT_TOP
		je	err_exit
		mov	dx, offset Err_No_Res
		cmp	Status, _NOT_RESIDENT
		je	err_exit
		push	ds
		mov	ax, 2508h
		lds	dx, es:Old_08h
		int	21h
		mov	ax, 2509h
		lds	dx, es:Old_09h
		int	21h
		mov	ax, 2510h
		lds	dx, es:Old_10h
		int	21h
		mov	ax, 252Fh
		lds	dx, es:Old_2Fh
		int	21h
		cmp	es:Is_Mouse, _FALSE
		je	@@no_mouse
		mov	ax, 2533h
		lds	dx, es:Old_33h
		int	21h
	@@no_mouse:
		pop	ds

		mov	ah, 49h
		int	21h

		mov	es, es:[02Ch]
		mov	ah, 49h
		int	21h

		mov	dx, offset Msg_Uninstall
norm_exit:
		mov	ah, 09
		int	21h
		mov	ax, 4C00h
		int	21h
err_exit:
		mov	ah, 09
		int	21h
		mov	ax, 4C01h
		int	21h

install:

		cmp	Status, _NOT_RESIDENT
		je	@@do_ins

		mov	dx, offset Err_Res
		jmp	err_exit

@@do_ins:
		xor	ax, ax
		mov	es, ax

		cmp	word ptr es:[33h*4], 0
		jne	@@check_mouse
		cmp	word ptr es:[33h*4+2], 0
		jne	@@check_mouse
		jmp	@@no_mouse
@@check_mouse:
		xor	ax, ax
		int	33h
		cmp	ax, 0FFFFh
		jne	@@no_mouse

		mov	ax, 0003h
		int	33h
		mov	cs:Mouse_CX, cx
		mov	cs:Mouse_DX, dx

		mov	cs:Is_Mouse, _TRUE

		mov	ax, 3533h
		int	21h
		mov	word ptr Old_33h, bx
		mov	word ptr Old_33h[2], es
		mov	ax, 2533h
		mov	dx, offset Int_33h
		int	21h

@@no_mouse:
		mov	ax, 3508h
		int	21h
		mov	word ptr Old_08h, bx
		mov	word ptr Old_08h[2], es
		mov	ax, 2508h
		mov	dx, offset Int_08h
		int	21h

		mov	ax, 3509h
		int	21h
		mov	word ptr Old_09h, bx
		mov	word ptr Old_09h[2], es
		mov	ax, 2509h
		mov	dx, offset Int_09h
		int	21h

		mov	ax, 3510h
		int	21h
		mov	word ptr Old_10h, bx
		mov	word ptr Old_10h[2], es
		mov	ax, 2510h
		mov	dx, offset Int_10h
		int	21h

		mov	ax, 352Fh
		int	21h
		mov	word ptr Old_2Fh, bx
		mov	word ptr Old_2Fh[2], es
		mov	ax, 252Fh
		mov	dx, offset Int_2Fh
		int	21h

		mov	ah, 09
		mov	dx, offset Msg_Install
		int	21h

		mov	es, cs:[02Ch]
		mov	ah, 49h
		int	21h

		mov	Dim_Seg, cs

		mov	dx, offset loader
		add	dx, _TABLE_LEN + _STACK_LEN
		int	27h

help:
		mov	dx, offset Msg_Help

		jmp	norm_exit

param:
		cmp	Status, _NOT_RESIDENT
		jne	@@do_par

		mov	dx, offset Err_No_Res
		jmp	err_exit

	@@do_par:
		mov	ax, Max_Delay
		mov	es:Max_Delay, ax
		mov	al, Method
		mov	es:Method, al

		mov	dx, offset Msg_Par

		jmp	norm_exit

Check_Cmd_Line:
		push	es

		mov	bx, _HELP

		mov	ax, cs
		mov	es, ax

		mov    	di, 80h
		mov	al, es:[di]
		or	al, al		; no command line
		jz	@@out

		cld

		xor	ch, ch
		mov	cl, al		; cx = length

		inc	di

		mov	al, ' '
	repe	scasb

		cmp	byte ptr es:[di-1], ' '
		je	@@out

@@line:
                cmp     byte ptr es:[di-1], 'a'
                ja      @@dim
                mov     cs:Method, _REFRESH
        @@dim:
		mov	bx, _UNINSTALL
		cmp	byte ptr es:[di-1], 'r'
		je	@@out
		cmp	byte ptr es:[di-1], 'R'
		je	@@out

		mov	bx, _PARAM
		cmp	byte ptr es:[di-1], 'p'
		je	@@check
		cmp	byte ptr es:[di-1], 'P'
		je	@@check

		mov	bx, _INSTALL
		cmp	byte ptr es:[di-1], 'i'
		je	@@check
		cmp	byte ptr es:[di-1], 'I'
		je	@@check

		mov	bx, _ERROR
		jmp	@@out

@@check:
		jcxz	@@out

		push	bx

		xor	ax, ax
		xor	dh, dh
		mov	bl, 10

@@min:
		mov	dl, es:[di]
		inc	di
		cmp	dl, '0'
		jb	@@nextm
		cmp	dl, '9'
		ja	@@nextm
		sub	dl, '0'
		mul	bl
		add	ax, dx
	@@nextm:
		loop	@@min
@@end_min:
		mul	Ticks_In_Min

		mov	Max_Delay, ax

		pop	bx

@@out:
		pop	es
		ret

Status		db	_NOT_RESIDENT
Msg_Cpr 	db	'Dimmer 1.0 VGA,  Copyright (c) 1991,  Arkady Moreynis',13,10,'$'
Msg_Install 	db	'Dimmer          :  succesfully installed.',13,10,'$'
Msg_Uninstall 	db	'Dimmer          :  succesfully uninstalled.',13,10,'$'
Msg_Par		db	'Dimmer          :  parameters changed.',13,10,'$'
Msg_Err		db	'Error           :  illegal option',13,10,'$'
Msg_Help        db      'Install         :  Dimmer i{I} [minutes]',13,10
		db	'Uninstall       :  Dimmer r',13,10
                db      'Change settings :  Dimmer p{P} [minutes] (0 = off)',13,10
                db      'Method          :  {ip} dimming, {IP} disable video.',13,10,'$'
Err_Int		db	'Error           :  not a top process - cannot uninstall',13,10,'$'
Err_Res		db	'Error           :  already resident',13,10,'$'
Err_No_Res	db	'Error           :  not resident yet',13,10,'$'

prog		ends
		end	start
