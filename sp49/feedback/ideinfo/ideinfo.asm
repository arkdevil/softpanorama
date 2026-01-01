                .286c
                TITLE   IDEINF
CSEG            segment byte public 'CODE'
                assume cs:CSEG, ds:CSEG, es:CSEG, ss:CSEG
                ORG     100H
start:
                mov     bx,offset copyright
                call    out_str
                mov     bx,offset BIOS_rep
                call    out_str
                PUSH    BX
                IN      AL, 0A1H
                JMP     short $+2
                OR      AL, 40H
                OUT     0A1H, AL
                POP     DX
		mov	ax,40h
		mov	es,ax
                mov     bl,es:[75H]
                push    cs
                pop     es
                mov     hd_count,bl
		call	sub_a_03D5
		mov	bx,dx
                call    out_str
                call    test_pres
                jc      loc_a_0082
                or      byte ptr pres_flags,1
                inc     hd_found
loc_a_0082:
                mov     byte ptr drive,1
                call    test_pres
                jc      loc_a_0095
                or      byte ptr pres_flags,2
                inc     hd_found
loc_a_0095:
                mov     bx,offset scan_rep
                call    out_str
                mov     dx,bx
                mov     bl,hd_found
                call    sub_a_03D5
                mov     bx,dx
                call    out_str
                cmp     byte ptr pres_flags,2
                jne     loc_a_00B6
                mov     bx,offset warn_mes
                call    out_str
loc_a_00B6:
                test    byte ptr pres_flags,1
                jz      loc_a_00C5
                mov     byte ptr drive,0
                call    drive_info
loc_a_00C5:
                cmp     byte ptr hd_found,2
                jne     loc_a_00DA
                mov     bx,offset wkey_mes
                call    out_str
loc_a_00D2:
                call    wkey
                jz      loc_a_00D2
                call    out_str
loc_a_00DA:
                test    byte ptr pres_flags,2
                jz      loc_a_00E9
                mov     byte ptr drive,1
                call    drive_info
loc_a_00E9:
                IN      AL, 0A1H
                JMP     short $+2
                AND     AL, 10111111B
                OUT     0A1H, AL
                mov     ax,4C00h
                int     21h

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

drive_info	proc	near
                call    read_info
                STI
                jnc     loc_a_00F7
loc_a_00F4:
		jmp	loc_a_017D
loc_a_00F7:
                mov     di, offset p00
                mov     si, offset drive_mes
		mov	bx,si
		call	out_str
		mov	si,bx
                mov     bl,drive
		call	sub_a_03D5
loc_a_0110:
		mov	bx,si
		call	out_str			; (0302)
		mov	al,[bx]
		cmp	al,0FFh
		je	loc_a_0158		; Jump if equal
		mov	ah,0
		mov	di,ax
		add	di,offset p00		; (73D7:001E=0)
		inc	bx
		mov	al,[bx]
		inc	bx
		mov	si,bx
		mov	bl,al
		test	al,al
		js	loc_a_013C		; Jump if sign=1
		mov	bx,[di]
		cmp	al,3
		jne	loc_a_0137		; Jump if not equal
		shr	bx,1			; Shift w/zeros fill
loc_a_0137:
		call	convert			; (03D7)
		jmp	short loc_a_0110
loc_a_013C:
		neg	al
		mov	cx,0
		mov	cl,al
		mov	bx,di
		mov	ax,[bx]
		test	ax,ax
		jnz	loc_a_0153		; Jump if not zero
                mov     bx,offset none_mes
		call	out_str			; (0302)
		jmp	short loc_a_0110
loc_a_0153:
		call	out_info		; (02E6)
		jmp	short loc_a_0110
loc_a_0158:
		mov	bx,offset disk_size_mes	; (73D7:0AB6=0Dh)
		call	out_str			; (0302)
		push	bx
		mov	si,offset p00		; (73D7:001E=0)
		mov	dx,0
		mov	ax,[si+2]
		mul	word ptr [si+6]		; ax = data * ax
		mul	word ptr [si+0Ch]	; ax = data * ax
		mov	cx,800h
		div	cx			; ax,dx rem=dx:ax/reg
		mov	bx,ax
		call	convert			; (03D7)
		pop	bx
		call	out_str			; (0302)
		retn
loc_a_017D:
		mov	bx,offset ide_com_mes	; (73D7:0AD7=0Dh)
		call	out_str			; (0302)
		mov	bl,drive		; (73D7:000B=0)
		call	sub_a_03D5
		call	sub_a_03AA
		retn
drive_info	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

read_info	proc	near
                xor     al, al
                mov     byte ptr data_b_0010,al
                mov     byte ptr data_b_0011,al
                mov     byte ptr SDH, al
                mov     byte ptr data_b_0012, al
                mov     byte ptr data_b_0013, al
                call    set_SDH
                mov     byte ptr data_b_0015,0ECh
                call    send_com
                jc      loc_ret_a_01D4
                call    test_busy
                jc      loc_a_01D3
                call    data_request
		jc	loc_a_01D3		; Jump if carry Set
                mov     di,offset p00
                cli
                call    input_info
                sti
                call    test_error
                jc      loc_ret_a_01D4
		jmp	short loc_ret_a_01D4
loc_a_01D3:
                stc
loc_ret_a_01D4:
		retn
read_info	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

test_error	proc	near
		push	dx
		mov	dx,status_wdc		; (73D7:0004=0)
		in	al,dx			; port 0, DMA-1 bas&add ch 0
		mov	ah,al
		and	al,71h			; 'q'
		xor	al,50h			; 'P'
		jz	loc_a_01E4		; Jump if zero
		stc				; Set carry flag
loc_a_01E4:
		pop	dx
		mov	al,ah
		retn
test_error	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

test_busy	proc	near
		push	dx
		mov	dx,status_wdc		; (73D7:0004=0)
		mov	ah,data_b_000E		; (=14h)
loc_a_01F1:
		mov	cx,0
locloop_a_01F4:
		in	al,dx			; port 0, DMA-1 bas&add ch 0
		test	al,80h
		clc				; Clear carry flag
		jz	loc_a_0201		; Jump if zero
		loop	locloop_a_01F4		; Loop if cx > 0

		dec	ah
		jnz	loc_a_01F1		; Jump if not zero
		stc				; Set carry flag
loc_a_0201:
		pop	dx
		retn
test_busy	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

test_pres	proc	near
		mov	byte ptr SDH,0		; (73D7:0014=0)
		call	set_SDH			; (02C9)
		mov	dx,status_wdc		; (73D7:0004=0)
		in	al,dx			; port 0, DMA-1 bas&add ch 0
		cmp	al,0FFh
		je	loc_a_0259		; Jump if equal
		call	test_busy		; (01E8)
		jc	loc_a_0259		; Jump if carry Set
		mov	dx,status_wdc		; (73D7:0004=0)
		dec	dx
		mov	al,SDH			; (73D7:0014=0)
		out	dx,al			; port 0FFFFh
		jmp	short $+2		; delay for I/O
		jmp	short $+2		; delay for I/O
		in	al,dx			; port 0FFFFh
		cmp	al,SDH			; (73D7:0014=0)
		jne	loc_a_0259		; Jump if not equal
		sub	dx,2
		mov	al,0AAh
		out	dx,al			; port 0FFFDh
		jmp	short $+2		; delay for I/O
		jmp	short $+2		; delay for I/O
		in	al,dx			; port 0FFFDh
		cmp	al,0AAh
		jne	loc_a_0259		; Jump if not equal
		mov	al,55h			; 'U'
		out	dx,al			; port 0FFFDh
		jmp	short $+2		; delay for I/O
		jmp	short $+2		; delay for I/O
		in	al,dx			; port 0FFFDh
		cmp	al,55h			; 'U'
		jne	loc_a_0259		; Jump if not equal
		jmp	short $+2		; delay for I/O
		jmp	short $+2		; delay for I/O
		jmp	short $+2		; delay for I/O
		jmp	short $+2		; delay for I/O
		mov	dx,status_wdc		; (73D7:0004=0)
		in	al,dx			; port 0, DMA-1 bas&add ch 0
		test	al,40h			; '@'
		jnz	loc_ret_a_025A		; Jump if not zero
loc_a_0259:
		stc				; Set carry flag

loc_ret_a_025A:
		retn
test_pres	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

send_com	proc	near
		call	test_busy		; (01E8)
		jc	loc_ret_a_027B		; Jump if carry Set
		mov	al,data_b_000A		; (=0)
		mov	dx,stop_wdc		; (73D7:0008=0)
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		call	set_parameters		; (027C)
		jc	loc_ret_a_027B		; Jump if carry Set
		call	test_ready		; (02A6)
		jc	loc_ret_a_027B		; Jump if carry Set
		mov	dx,status_wdc		; (73D7:0004=0)
		mov	al,data_b_0015		; (=0)
		out	dx,al			; port 0, DMA-1 bas&add ch 0
		clc				; Clear carry flag

loc_ret_a_027B:
		retn
send_com	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

set_parameters	proc	near
		mov	dx,data_wdc		; (73D7:0006=0)
		mov	bx,offset data_b_000F	; (=0)
		mov	cx,6

locloop_a_0286:
		inc	dx
		mov	al,[bx]
		out	dx,al			; port 1, DMA-1 bas&cnt ch 0
		inc	bx
		loop	locloop_a_0286		; Loop if cx > 0

		retn
set_parameters	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

data_request	proc	near
		push	cx
		push	dx
                mov     dx,status_wdc
		mov	cx,100h

locloop_a_0297:
                in      al,dx
		test	al,8
                jnz     loc_a_02A2
                loop    locloop_a_0297

                stc
		jmp	short loc_a_02A3
loc_a_02A2:
                clc
loc_a_02A3:
		pop	dx
		pop	cx
		retn
data_request	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

test_ready	proc	near
		push	cx
		push	dx
                mov     dx,status_wdc
		mov	cx,100h

locloop_a_02AF:
                in      al,dx
                test    al,40h
                jnz     loc_a_02BA
                loop    locloop_a_02AF

                stc
		jmp	short loc_a_02BB
loc_a_02BA:
                clc
loc_a_02BB:
		pop	dx
		pop	cx
		retn
test_ready	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

input_info	proc	near
                cld
		mov	cx,100h
                mov     dx,data_wdc
                rep     insw          ; Rep when cx >0 Port dx to es:[di]
		retn
input_info	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

set_SDH		proc	near
                mov     al,drive
		and	al,1
                shl     al,4
		or	al,0A0h
                mov     ah,SDH
		and	ah,0Fh
		or	al,ah
                mov     SDH,al
                mov     dx,status_wdc
		dec	dx
                out     dx,al
		retn
set_SDH		endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

out_info	proc	near
locloop_a_02E6:
		mov	ax,[bx]
		add	bx,2
		test	ax,ax
		jz	loc_a_02F9		; Jump if zero
		xchg	al,ah
		call	out_symbol		; (0396)
		xchg	al,ah
		call	out_symbol		; (0396)
loc_a_02F9:
		loop	locloop_a_02E6		; Loop if cx > 0

		retn
out_info	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

out_str		proc	near
loc_a_0302:
		mov	al,[bx]
		inc	bx
		test	al,al
		jz	loc_ret_a_0312		; Jump if zero
		cmp	al,0FFh
		je	loc_a_0313		; Jump if equal
		call	out_symbol		; (0396)
		jmp	short loc_a_0302

loc_ret_a_0312:
		retn
loc_a_0313:
		mov	ah,[bx]
		inc	bx
		mov	al,[bx]
		inc	bx
                call    set_cursor
		jmp	short loc_a_0302
out_str		endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

out_symbol	proc	near
loc_a_0396:
		push	ax
		push	dx
		mov	dl,al
		mov	ah,2
		int	21h			; DOS Services  ah=function 02h
						;  display char dl
		pop	dx
		pop	ax
		retn
out_symbol	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

wkey		proc	near
		push	dx
		mov	ah,6
		mov	dl,0FFh
		int	21h			; DOS Services  ah=function 06h
						;  special char i/o, dl=subfunc
		pop	dx
		retn
wkey		endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

sub_a_03AA	proc	near
loc_a_03AA:
		mov	al,0Dh
		call	out_symbol		; (0396)
		mov	al,0Ah
		jmp	short loc_a_0396
sub_a_03AA	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;			       SUBROUTINE

sub_a_03D5	proc	near
		mov	bh,0

;▀▀▀▀ External Entry into Subroutine ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
convert:
		push	dx
		push	bx
		mov	dx,0FFFFh
loc_a_03DC:
		inc	dx
		sub	bx,0Ah
		jnc	loc_a_03DC		; Jump if carry=0
		add	bx,0Ah
		xchg	bx,dx
		test	bx,bx
		jz	loc_a_03EE		; Jump if zero
		call	convert			; (03D7)
loc_a_03EE:
		mov	al,dl
		add	al,30h			; '0'
		call	out_symbol		; (0396)
		pop	bx
		pop	dx
		retn
sub_a_03D5	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

set_cursor      proc    near
		mov	data_b_081E,ax		; (=0)
		push	dx
		push	bx
		mov	dx,ax
		mov	data_b_081E,ax		; (=0)
		mov	bh,data_b_0828		; (=0)
		mov	ah,2
		int	10h			; Video display   ah=functn 02h
						;  set cursor location in dx
		pop	bx
		pop	dx
		retn
set_cursor      endp
; ------------- data ---------------------------------------------------
status_wdc      dw      1f7h
data_wdc        dw      1f0h
stop_wdc        dw      3f6h
data_b_000A	db	0
drive		db	0
data_b_000C	dw	0
data_b_000E	db	14h
data_b_000F	db	0
data_b_0010     db      1
data_b_0011     db      1
data_b_0012	db	0
data_b_0013	db	0
SDH             db      0ah
data_b_0015	db	0
hd_count	db	0
hd_found	db	0
pres_flags	db	0
data_b_081E     dw      0                       ; cur_pos
data_b_0828     db      0                       ; scr_page
copyright	db	0Dh, 0Ah, 'IDE/AT Drive Identify '
		db	'Program 1.01', 0Dh, 0Ah, '(c) Cop'
		db	'yright 1991 by Thomas J. Newman '
                db      0Dh, 0Ah, 'All Rights Reserved.', 0Dh, 0Ah, 0Dh, 0Ah
		db	0
BIOS_rep	db	'The System BIOS reported ', 0
		db	' hard drive(s).', 0Dh, 0Ah, 0
scan_rep	db	'A scan of the hardware found ', 0
                db      ' IDE/AT hard drive(s).', 0Dh, 0Ah, 0
wkey_mes        db      0Dh, 0Ah, 'Press any key f'
		db	'or drive 1 information ...'
		db	 00h, 0Dh, 0Ah, 0Dh, 0Ah, 00h
warn_mes	db	0Dh, 0Ah, '*** Warning:  Only one'
		db	' drive f'
		db	'ound and it', 27h, 's addressed '
		db	'as Drive 1.'
		db	7, 0
drive_mes	db	0Dh, 0Ah, 'Drive ', 0
                db      ' Information', 0Dh, 0Ah
                db      0DH, 0AH, '   Cylinders........... ', 0
                db      02h, 02h
                db      0Dh, 0Ah, '   Heads............... ', 0
                db      06h, 02h
                db      0Dh, 0Ah, '   Sectors per track... ', 0
                db      0Ch, 02h
                db      0Dh, 0Ah, '   Bytes per track..... ', 0
                db      8, 2
                db      0Dh, 0Ah, '   Bytes per sector.... ', 0
                db      0Ah, 02h
                db      0Dh, 0Ah, '   Buffer Size......... ', 0
                db      2Ah, 03h, ' Kb'
                db      0Dh, 0Ah, '   ECC bytes........... ', 0
                db      2Ch, 02h
                db      0Dh, 0Ah, 0Dh, 0Ah, '   Model Number'
                db      '........ ', 0
                db      36h,0ECh
                db      0Dh, 0Ah, '   Firmware Revision... ', 0
		db	 2Eh,0FCh
                db      0Dh, 0Ah, '   Serial Number....... ', 0
                db      14h,0F6h, 0Dh, 0Ah
		db	 00h,0FFh
disk_size_mes   db      0Dh, 0Ah, '   Drive capacity...... ', 0
                db      ' Mb', 0Dh, 0Ah, 00h
ide_com_mes     db      0Dh, 0Ah, '*** Identify command was rejected by drive '
		db	7, 0
none_mes        db      'None', 0
p00             label byte
CSEG            ends
		end	start
