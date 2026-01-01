	.model large,c
	.code

; Real time clock support for WINDOW
;
; (C) by MacSoft 1990
;
_timcount	dw	0		;number of timers
_timwhere	dd	0		;where thay are
_timold1c	dd	0		;old vector

	public _timer,_inittimer,_deinittimer

; void interrupt far __timer(void);
;
_timer	proc
	pushf			;let old
	call	cs:[_timold1c]	;handler run first
	push	cx		;preserve
	mov	cx,cs:_timcount	;get number of timers
	jcxz	eot		;skip rest if none
	push	bx		;preserve some
	push	ds		;more
	lds	bx,cs:_timwhere	;get pointer to counts
nextone:	cmp word ptr	[bx],0		;reached terminal count?
	jz	skipthis		;yep, skip this one
	dec word ptr	[bx]		;else count down
skipthis:	inc	bx		;get
	inc	bx		;next word
	loop	nextone		;and check all channels
	pop	ds		;get all
	pop	bx		;registers
eot:	pop	cx		;back
	iret			;and go home
_timer	endp

; void far __inittimer(int howmany,int far *where);
;
_inittimer	proc
	arg  count:word,where:dword
	uses ds
	mov	ax,count		;get number of channels
	or	ax,ax		;anything?
	jz	bad		;no, don't bother
	cli			;critical part
	mov	cs:_timcount,ax	;store number of channels
	lds	bx,where		;and pointer
	mov word ptr	cs:_timwhere,bx	;to first
	mov word ptr cs:_timwhere+2,ds	;channel
	sti			;no problems any more
	mov 	ax,word ptr cs:_timold1c	;get old vector
	or	ax,word ptr cs:_timold1c+2;and look if we have it
	jnz	bad		;in such case we're done
	mov	ax,351ch		;else grab
	int	21h		;original tick vector
	mov word ptr cs:_timold1c,bx	;and save
	mov word ptr cs:_timold1c+2,es	;it for later calls
	push	cs		;transfer CS
	pop	ds		;to DS
	mov	dx,offset _timer	;address of our handler
	mov	ax,251ch		;and put it there
	int	21h		;after that...
bad:	ret			;we're all done
_inittimer	endp

; void far __deinittimer(void);
;
_deinittimer	proc
	uses ds
	mov	ax,word ptr cs:_timold1c	;check vector
	or	ax,word ptr cs:_timold1c+2;to see if we have it
	jz	kaka		;nope, skip the rest
	lds	dx,cs:_timold1c	;else get original
	mov	ax,251ch		;and put it back
	int	21h		;where it was
	xor	ax,ax		;clear
	mov word ptr	cs:_timold1c,ax	;our vector
	mov word ptr	cs:_timold1c+2,ax	;for another init
kaka:	ret			;and done
_deinittimer	endp

	end
