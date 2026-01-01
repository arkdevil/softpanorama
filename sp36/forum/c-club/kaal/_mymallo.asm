	.model large,c

	extrn  c _myfail:far

	.code

	public _mymalloc,_myfree,_mycoreleft

; (C) by MacSoft 1990
;
; void far *_mymalloc(long nbytes)
;
; Allocate memory from DOS's far heap.
;
_mymalloc	proc
	arg	s:dword
	les	ax,s		;get size
	mov	bx,es
	mov	ch,al		;save lsb
	mov	cl,4
	shr	ax,cl
	and	ch,15
	jz	m1
	inc	ax
m1:	xchg	bh,bl
	shl	bx,cl
	add	bx,ax
	push	bx		;keep requested
	mov	ah,48h		;DOS's alloc
	int	21h		;allocate memory
	pop	cx		;recover requested amount
	jnc	m2		;ok, return in DX
	push	cx
	push	bx
	call	_myfail		;else call error handler
	add	sp,4
	xor	ax,ax		;NULL pointer
m2:	mov	dx,ax		;segment to hi
	xor	ax,ax		;clear offset
	ret			;and return
_mymalloc	endp

; void far _myfree( void far *block)
;
; Free memory block.
;
_myfree	proc
	arg	b:dword
	les	ax,b		;segment to ES
	mov	ah,49h		;free this segment
	int	21h		;using DOS
	ret
_myfree	endp

; long far _mycoreleft(void);
;
; Return size of largest available block
;
_mycoreleft	proc
	mov	bx,0ffffh
	mov	ah,48h
	int	21h
	mov	ax,bx
	mov	cx,4
	xor	dx,dx
m3:	add	ax,ax
	adc	dx,0
	loop	m3
	ret
_mycoreleft	endp
	
	end
