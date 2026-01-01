		NAME	Is_Cache
		PAGE	55,132

; Function:	returns internal SRAM cache size
;
; Caller:	Turbo C:
;			int Is_Cache(void);
;
; Returns:	-1 no enough memory
;		-2 memofy allocation fails
;		else cache size in Kbytes
;
; Source algorithm by Victor A.Borisov
; Translated into assembler by Tim V.Shaporev

		ifdef	__NEAR__
prog		equ	near
quit		equ	ret
		else
prog		equ	far
quit		equ	retf
		endif

_TEXT		segment	byte public 'CODE'
		assume	cs:_TEXT

MaxSize		equ	8000h		; max allocated size
MinSize         equ     0200h
ChipSegs	equ	100h		; size of count quant in paragraphs
ChipSize	equ	ChipSegs*16	; size of count quant in bytes
MinDiff		equ	105		; difference betwen DRAM and SRAM

initer		label	byte
		mov	ax,cs
		mov	ds,ax
		mov 	cx,ChipSize/2
		xor	si,si
		rep	lodsw
end_initer	label	byte

initick		label	byte
                nop
                nop
		nop
		in	al,61h
		and	al,0FCh
		out	61h,al
		mov	al,0B4h
		out	43h,al
		mov	al,0
		out	42h,al
		nop
		out	42h,al
		in	al,61h
		mov	bl,al
		or	al,1
		out	61h,al
end_initick	label	byte

endtick	        label	byte
		mov	al,bl
		out	61h,al
		in	al,42h
		mov	ah,al
		in	al,42h
		xchg	al,ah
		neg	ax
		mov	cs:[0],ax
		nop
end_endtick	label	byte

size_initer	equ	end_initer-initer
size_initick	equ	end_initick-initick
size_endtick	equ	end_endtick-endtick
size_all	equ	end_endtick-initer

bufsize		equ	[bp-2]
bufseg		equ	[bp-4]
long_s		equ	[bp-6]
long_o		equ	[bp-8]

		public	_Is_Cache
_Is_Cache	proc	prog
		push	bp
		mov	bp,sp
		sub	sp,8
		push	ds
		push	es
		push	si
		push	di

                mov     ah,48h
                mov     bx,MaxSize
		mov     bufsize,bx
                int     21h
                jnc     buffer_ok
                and     bx,-ChipSegs
                cmp     bx,MinSize
                jnb     alloc_available
		mov     ax,-2		; no enough memory
                jmp     return
alloc_available:
		mov	bufsize,bx
		mov	ah,48h
		int	21h
		jnc	buffer_ok
		mov	ax,-1		; allocation fails
		jmp	return
buffer_ok:
		mov	bufseg,ax	; save segment addr
		push	cs
		pop	ds
		xor	bx,bx		; j = 0
load_loop:
		mov	es,ax   	; ptr = es:di
		sub	di,di

		lea	si,initer
		mov	cx,size_initer
		rep	movsb		; store initer code

		or	bx,bx		; first pass?
		jnz     load_jump
		mov	al,90h		; nop
		mov	cx,5
		rep	stosb
		jmp	short load_measure
load_jump:
		mov	al,0EAh		; 1st byte of the far jump
		stosb
		xor	ax,ax
		stosw
		mov	ax,es
		sub	ax,ChipSegs
		stosw
load_measure:
		lea	si,initick
		mov	cx,size_initick
		rep	movsb		; load measuring code

;		mov	ax,000EBh	; jmp $+2
;		mov     ax,0EB00h       ; add ?,?
;		mov	ax,0C009h	; or ax,ax
;		mov	ax,055B0h	; mov al,55h
		mov	ax,0D089h	; mov ax,dx
		mov	cx,(ChipSize-size_all-10)/2
		rep	stosw		; store dummy

                lea     si,endtick
                mov     cx,size_endtick
		rep     movsb		; end of measuring code

		add	bx,ChipSegs
		cmp	bx,bufsize
		jnb	loop_end

		mov	al,0EAh		; 1st byte of the far jump
		stosb
		mov	ax,size_initer+5; bypass initer code
		stosw
		mov	ax,es
		add	ax,ChipSegs
		stosw
		jmp	short load_loop
loop_end:
;		mov	ax,00EBh	; jmp $+2
;		stosw
;		stosw
		mov	al,0CBh		; retf
		stosb

		mov	word ptr long_o,0	; offset
		mov	word ptr long_s,es	; segment

		cld
		cli
		call	dword ptr long_o
		sti

		sub	si,si
		sub	di,di
		xor	bx,bx		; bx = loop variable
                mov     cx,bufsize
		sub     cx,ChipSegs	; cx = upper bound
find_loop:
		mov	ax,bufseg
		add	ax,bx
		mov	ds,ax

		mov	ax,100
		mul	word ptr ds:[ChipSize]
		mov	long_o,ax
		mov	long_s,dx
		mov	ax,ds:[0]
		mul	si
		cmp	long_s,dx
		ja	find_diff
		jb	find_next
		cmp	long_o,ax
		jbe     find_next
find_diff:
		mov	di,bx		; save loop counter
		mov	ax,long_o
		mov	dx,long_s
		div	word ptr ds:[0]
		mov	si,ax
find_next:
		add	bx,ChipSegs
		cmp	bx,cx
		jb	find_loop

		mov	es,bufseg
		mov	ah,49h
		int	21h		; release buffer

		cmp	si,MinDiff
		jb	no_cache
		mov	ax,di
		add	ax,ChipSegs
		mov	cl,6
		sar	ax,cl		; paragraph to Kbytes
		jmp	short return
no_cache:
		xor	ax,ax
return:
		pop	di
		pop	si
		pop	es
		pop	ds
		mov	sp,bp
		pop	bp
		quit
_Is_Cache	endp

_TEXT		ends
		end
