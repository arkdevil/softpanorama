_TEXT		segment byte public 'CODE'
		assume	cs:_TEXT

		public	_initick
_initick	proc	near
		push	ax
		in	al,61h
		and	al,0FCh
		out	61h,al
		mov	al,0B4h
		out	43h,al
		mov	al,0
		out	42h,al
		nop
		out	42h,al
		pop	ax
		retn
_initick	endp

		public	_endtick
_endtick	proc	near
		push	bx
		in	al,42h
		mov	ah,al
		in	al,42h
		xchg	al,ah
		neg	ax
		pop	bx
		retn
_endtick	endp

		public	_find87
_find87		proc	near
		int	11h
		and	ax,2	; Coprocessor installed bit
		shr	ax,1
		retn
_find87		endp

		public	_cputype
_cputype	proc	near
		push	bp
		mov	bp,sp
		pushf
		xor	ax,ax
		push	ax
		popf
		pushf
		pop	ax
		and	ax,0F000h
		cmp	ax,0F000h
		jne	cpu_l_1
		xor	ax,ax
		jmp	short cpu_return
cpu_l_1:
		push	sp
		pop	bx
		cmp	bx,sp
		je	cpu_l_2
		mov	ax,1
		jmp	short cpu_return
cpu_l_2:
		mov	ax,0F000h
		push	ax
		popf
		pushf
		pop	ax
		and	ax,0F000h
		jz	short loc_117
		mov	ax,3
		jmp	short cpu_return
loc_117:
		mov	ax,2
cpu_return:
		popf
		mov	sp,bp
		pop	bp
		retn
_cputype	endp

		public	_rep_mul
_rep_mul	proc	near
		push	bp
		mov	bp,sp
		push	di
		call	_initick
		mov	di,8000h
		mov	ax,[bp+4]
;		add	ax,99
		mov	cx,100
		div	cl			; al, ah rem = ax/reg
		mov	cl,al			; cx = (arg+99) / 100
;		nop
		in	al,61h
		mov	bl,al
		or	ax,1
		cli
		out	61h,al
loc_96:
		dw	100 dup (0E7F7h)	; mul di ; dx:ax = di * ax
		dec	cx
		jz	short loc_97
		jmp	loc_96
loc_97:
		mov	al,bl
		out	61h,al
		sti
		call	_endtick
		pop	di
		pop	bp
		retn
_rep_mul	endp

		public	_rep_cld
_rep_cld	proc	near
		push	bp
		mov	bp,sp
;		push	di
		call	_initick
;		mov	di,0
		mov	ax,[bp+4]
;		add	ax,99
		mov	cx,100
		div	cl
		mov	cl,al
;		nop
		in	al,61h
		mov	bl,al
		or	ax,1
		cli
		out	61h,al
loc_a_1:
		db	100 dup (0F8h)		; cld
		dec	cx
		jz	loc_a_2
		jmp	short loc_a_1
loc_a_2:
		mov	al,bl
		out	61h,al
		sti
		call	_endtick
;		pop	di
		pop	bp
		retn
_rep_cld	endp

		public	_repmovr
_repmovr	proc	near
		push	bp
		mov	bp,sp
;		push	di
		call	_initick
;		mov	di,0
		mov	ax,[bp+4]
;		add	ax,99
		mov	cx,100
		div	cl			; al, ah rem = ax/reg
		mov	cl,al
;		nop
		in	al,61h
		mov	bl,al
		or	ax,1
		cli
		out	61h,al
loc_98:
		dw	100 dup (0D38Bh)	; mov dx,bx
		dec	cx
		jz	short loc_99
		jmp	loc_98
loc_99:
		mov	al,bl
		out	61h,al
		sti
		call	_endtick
;		pop	di
		pop	bp
		retn
_repmovr	endp

		public	_repmovsb
_repmovsb	proc	near
		push	bp
		mov	bp,sp
		push	ds
		push	es
		push	si
		push	di
		call	_initick
                xor     si,si
                xor     di,di
		mov	cx,[bp+4]
		mov	ds,[bp+6]
		mov	es,[bp+8]
		in	al,61h
		mov	bl,al
		or	al,1
		cli
		cld
		out	61h,al
		rep	movsb
		mov	al,bl
		out	61h,al
		sti
		call	_endtick
		pop	di
		pop	si
		pop	es
		pop	ds
		pop	bp
		retn
_repmovsb	endp

		public	_repmovsw
_repmovsw	proc	near
		push	bp
		mov	bp,sp
		push	ds
		push	es
		push	si
		push	di
		call	_initick
                xor     si,si
                xor     di,di
		mov	cx,[bp+4]
		mov	ds,[bp+6]
		mov	es,[bp+8]
		in	al,61h
		mov	bl,al
		or	al,1
		cli
		cld
		out	61h,al
		rep	movsw
		mov	al,bl
		out	61h,al
		sti
		call	_endtick
		pop	di
		pop	si
		pop	es
		pop	ds
		pop	bp
		retn
_repmovsw	endp

		public	_repmovsd
_repmovsd	proc	near
		push	bp
		mov	bp,sp
		push	ds
		push	es
		push	si
                push    di
		call	_initick

                db      66h
                xor     di,di		; xor edi,edi
                db      66h
                xor     si,si		; xor esi,esi
                db      66h
                xor     cx,cx		; xor ecx,ecx

		mov	cx,[bp+4]
		mov     ds,[bp+6]
		mov     es,[bp+8]
		in	al,61h
		mov	bl,al
		or	al,1
		cli
		cld
		out	61h,al
                db      66h
		rep	movsw		; rep movsd
		mov	al,bl
		out	61h,al
		sti
		call	_endtick
		pop	di
		pop	si
		pop	es
		pop	ds
		pop	bp
		retn
_repmovsd	endp

		public	_repstosb
_repstosb	proc	near
		push	bp
		mov	bp,sp
		push	es
		push	di
		call	_initick
                xor     di,di
		mov	cx,[bp+4]
		mov     es,[bp+6]
		in	al,61h
		mov	bl,al
		or	al,1
		cli
		cld
		out	61h,al
		rep	stosb
		mov	al,bl
		out	61h,al
		sti
		call	_endtick
		pop	di
		pop	es
		pop	bp
		retn
_repstosb	endp

		public	_repstosw
_repstosw	proc	near
		push	bp
		mov	bp,sp
		push	es
		push	di
		call	_initick
                mov     ah,0		; for better screen behaviour
                xor     di,di
		mov	cx,[bp+4]
		mov	es,[bp+6]
		in	al,61h
		mov	bl,al
		or	al,1
		cli
		cld
		out	61h,al
		rep	stosw
		mov	al,bl
		out	61h,al
		sti
		call	_endtick
		pop	di
		pop	es
		pop	bp
		retn
_repstosw	endp

		public	_repstosd
_repstosd	proc	near
		push	bp
		mov	bp,sp
		push	es
                push    di
		call	_initick

                db      66h
                xor     di,di		; xor edi,edi
                db      66h
                xor     cx,cx		; xor ecx,ecx
                db      66h
                mov     ax,0700h	; mov eax,07200720h
                dw      0700h

                mov     cx,[bp+4]
                mov     es,[bp+6]
		in	al,61h
		mov	bl,al
		or	al,1
		cli
		cld
		out	61h,al
                db      66h
		rep	stosw		; rep stosd
		mov	al,bl
		out	61h,al
		sti
		call	_endtick
		pop	di
		pop	es
		pop	bp
		retn
_repstosd	endp

		public _reppusha
_reppusha	proc	near
		push	bp
		mov	bp,sp
		call	_initick
		mov	ax,[bp+4]
		cwd
		mov	cx,200
		div	cx
		mov	cx,ax
		in	al,61h
		mov	bl,al
		or	ax,1
		cli
		out	61h,al
locloop_102:
		db	25 dup (60h)		; pusha
		mov	sp,bp
		loop	locloop_102

		mov	al,bl
		out	61h,al
		sti
		call	_endtick
		mov	sp,bp
		pop	bp
		retn
_reppusha	endp

		public	_repfdiv
_repfdiv	proc	near
		push	bp
		mov	bp,sp
;		push	di
		call	_initick
;		mov	di,0
		mov	ax,[bp+4]
;		add	ax,99
		mov	cx,100
		div	cl
		mov	cl,al
		in	al,61h
		mov	bl,al
		or	al,1
		db	0DBh,0E3h	; fninit	; Initialize math uP
		db	09Bh,0D9h,0E8h	; fld1		; Push +1.0 to stack
		db	09Bh,0D9h,0E8h	; fld1		; Push +1.0 to stack
		cli
		out	61h,al
loc_104:
		rept	100
		db	09Bh,0DCh,0F9h	; fdiv st(1),st	; st(#) = st(#) / st
		endm

		dec	cx
		jz	short loc_105
		jmp	loc_104
loc_105:
		mov	al,bl
		out	61h,al
		sti
		call	_endtick
;		pop	di
		pop	bp
		retn
_repfdiv	endp

		public	_rep_daa
_rep_daa	proc	near
		push	bp
		mov	bp,sp
;		push	di
		call	_initick
;		mov	di,0
		mov	ax,[bp+4]
;		add	ax,99
		mov	cx,100
		div	cl			; al, ah rem = ax/reg
		mov	cl,al
;		nop
		in	al,61h
		mov	bl,al
		or	ax,1
		cli
		out	61h,al
loc_b_1:
		db	100 dup (27h)		; daa
		dec	cx
		jz	loc_b_2
		jmp	short loc_b_1
loc_b_2:
		mov	al,bl
		out	61h,al
		sti
		call	_endtick
;		pop	di
		pop	bp
		retn
_rep_daa	endp

		public	_repmovim
_repmovim	proc    near
                push    bp
                mov     bp,sp
;		push    di
                call    _initick
;		mov     di,0
                mov     ax,[bp+4]
;		add     ax,99
                mov     cx,100
                div     cl
                mov     cl,al
;		nop
                in      al,61h
                mov     bl,al
                or      al,1
                cli
                out     61h,al
loc_100:
                rept	100
                mov     dx,5555h
                endm
                dec     cx
                jz      short loc_101
                jmp     loc_100
loc_101:
                mov     al,bl
                out     61h,al
                sti
                call    _endtick
;		pop     di
                pop     bp
                retn
_repmovim	endp

                public  _repushla
_repushla	proc    near
                push    bp
                mov     bp,sp
                call    _initick
                mov     ax,[bp+4]
                cwd
                mov     cx,200
                div     cx			; ax,dx rem=dx:ax/reg
                mov     cx,ax
                and     sp,0FFFCh
                push    ax
                push    bp
                mov     bp,sp
                in      al,61h
                mov     bl,al
                or      ax,1
                cli
                out     61h,al
loc_c_1:
                dw      25 dup (6066h)
                mov     sp,bp
                loop    loc_c_1

                mov     al,bl
                out     61h,al
                sti
                pop     bp
                call    _endtick
                mov     sp,bp
                pop     bp
                retn
_repushla	endp

		public	_mempusha
_mempusha	proc    near
                push    bp
                push    di
                mov     bp,sp
                call    _initick
                mov     ax,[bp+6]
                cwd
                mov     cx,200
                div     cx		; ax,dx rem=dx:ax/reg
                mov     cx,ax
                in      al,61h
                mov     bl,al
                or      ax,1
                cli
                mov     dx,ss
                mov     ss,[bp+8]
                mov     sp,400
                mov     di,sp
                out     61h,al
locloop_106:
                db      25 dup (60h)		; pusha
                mov     sp,di
                loop    locloop_106

                mov     al,bl
                out     61h,al
                mov     ss,dx
                mov     sp,bp
                sti
                call    _endtick
                pop     di
                pop     bp
                retn
_mempusha	endp

		public	_mempushl
_mempushl	proc    near
                push    bp
                push    di
                mov     bp,sp
                call    _initick
                mov     ax,[bp+6]
                cwd
                mov     cx,200
                div     cx		; ax,dx rem=dx:ax/reg
                mov     cx,ax
                in      al,61h
                mov     bl,al
                or      ax,1
                cli
                mov     dx,ss
                mov     ss,[bp+8]	; buffer segment
                mov     sp,800
                mov     di,sp
                out     61h,al
loc_d_1:        dw      25 dup (6066h)
                mov     sp,di
                loop    loc_d_1
                mov     al,bl
                out     61h,al
                mov     ss,dx
                mov     sp,bp
                sti
                call    _endtick
                pop     di
                pop     bp
                retn
_mempushl	endp


ntry            equ	10

		public	_getems
_getems         proc    near
                push    bp
                push    es
                push    si
                push    di
                mov     ax,3567h
                int     21h		; get intrpt vector al in es:bx

                mov     ax,es
                or      ax,bx		; null pointer?
                jz      ems_break
                cmp     byte ptr es:[bx],0CFh	; points to iret?
		jne	ems_continue
ems_break:	jmp	no_ems
ems_continue:
                mov     cx,ntry
loc_107:
                mov     ah,40h		; EMS Memory ah=func 40h
                int     67h             ; get manager status in ah
                cmp     ah,82h
                je      loc_107
                or      ah,ah
                jz      end_107
                loop    loc_107
                jmp     short no_ems
end_107:
                mov	cx,ntry
loc_108:
                xor	bx,bx		; clear register
                mov     ah,41h		; EMS Memory ah=func 41h
                int     67h		; get page frame segment in bx
                cmp     ah,82h
                je      loc_108
                or      ah,ah
                jz      end_108
                loop    loc_108
                jmp     short no_ems
end_108:
                mov     si,bx
                mov     cx,ntry
loc_109:
                xor	bx,bx		; clear register
                mov     ah,42h		; EMS Memory ah=func 42h
                int     67h             ; get pages, bx=unused, dx=total
                cmp     ah,82h
                je      loc_109
                or      ah,ah
                jz      end_109
                loop    loc_109
                jmp     short no_ems
end_109:
                or      bx,bx
                jz      short no_ems
                mov     cx,ntry
loc_110:
                mov     ah,43h		; EMS Memory ah=func 43h
                mov     bx,1		; get handle dx, allocate pgs bx
                int     67h
                cmp     ah,82h
                je      loc_110
                or      ah,ah
                jz      end_110
                loop    loc_110
                jmp     short no_ems
end_110:
                mov	cx,ntry
loc_111:
                xor     bx,bx
                xor     al,al
                mov     ah,44h		; EMS Memory ah=func 44h
                int     67h		; map memory, dx=handle
                cmp     ah,82h
                je      loc_111
                or      ah,ah
                jz      end_111
                loop    loc_111
                jmp     short ems_fail
end_111:
                mov	ax,si		; address
                jmp     short ems_return
ems_fail:
                mov     cx,ntry
ems_release:
                mov     ah,45h		; EMS Memory ah=func 45h
                int     67h             ; release handle dx & memory
                cmp     ah,82h
                jz      no_ems
                loop    ems_release
no_ems:
                xor	ax,ax
                xor	dx,dx
ems_return:
		pop	di
                pop     si
                pop     es
                pop     bp
                retn
_getems         endp

		public	_endems
_endems		proc	near
		push	bp
                mov     bp,sp
                mov     dx,[bp+4]	; handle
ems_end:	mov     ah,45h		; EMS Memory ah=func 45h
                int     67h             ; release handle dx & memory
                cmp     ah,82h
                je      ems_end
		pop	bp
		retn
_endems		endp

		public	_cursor
_cursor		proc	near
		mov	bx,sp
		mov	cx,ss:[bx+2]
		mov	ah,1
		int	10h
		retn
_cursor		endp

_TEXT           ENDS
		END
