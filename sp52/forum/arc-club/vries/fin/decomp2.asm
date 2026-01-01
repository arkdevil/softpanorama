; Copyright 1991 by Jussi Puttonen, Timo Raita and Jukka Teuhola

; Written by Jussi Puttonen, 19.4.1991 at University of Turku, Finland
; Algorithms suggested by Timo Raita and Jukka Teuhola

InFile	equ	0
OutFile	equ	1

ReadBufferSize		equ	16384
WriteBufferSize	equ	16384

stack segment stack 'stack'
		db 1024 dup (?)
stack ends

data segment para public 'data'

FailString	db	'DECOMP failed.', 10,13, '$'

		align

ReadBuffer	db	ReadBufferSize dup (?)
ReadBufferEnd	label byte
ReadEnd		dw	offset ReadBufferEnd

		align

WriteBuffer	db	WriteBufferSize dup (?)
WriteBufferEnd	label byte

nine			dw	9

data ends

table segment para public 'data'
	db	8000h dup (' ')
	db	8000h dup (' ')
table ends

code segment para public 'code'
	assume cs:code, ds:data, es:table

WriteBlock:
			push	ax
			push	bx
			push	cx
			push	dx
			mov	ah, 40h
			mov	bx, OutFile
			mov	cx, WriteBufferSize
			lea	dx, WriteBuffer
			mov	di, dx
			int	21h
			pop	dx
			pop	cx
			pop	bx
			pop	ax
			ret

FlushBuffer	proc
			mov	ah, 40h
			mov	bx, OutFile
			mov	cx, di
			lea	dx, WriteBuffer
			sub	cx, dx
			int	21h
			ret
FlushBuffer	endp


jProcessWithChecks:
			jmp	ProcessWithChecks

start:		cld
			mov	ax, data
			mov	ds, ax
			mov	ax, table
			mov	es, ax

; si contains pointer to ReadBuffer
			mov	si, offset ReadBufferEnd
; di contains pointer to WriteBuffer
			mov	di, offset WriteBuffer
; bx contains the Addr
			mov	bx, 0

ReadLoop:		mov	ax, ReadEnd
			sub	ax, si
			xor	dx, dx
			div	nine
			cmp	ax, 1
			jbe	jProcessWithChecks
			mov	dx, ax
			dec	dx

			mov	ax, offset WriteBufferEnd
			sub	ax, di
			mov	cl, 3
			shr	ax, cl
			cmp	ax, 1
			jbe	jProcessWithChecks
			dec	ax
			mov	cx, ax

			cmp	cx, dx
			jbe	MinFound
			mov	cx, dx
MinFound:

ByteLoop:		lodsb
			mov	dl, al
ProcessBit	macro
			local zerobit, over
			shl	dl, 1
			jnc	zerobit
			lodsb
			mov	es:[bx], al
			jmp	short over
zerobit:		mov	al, es:[bx]
over:		mov	bh, bl
			mov	bl, al
			mov	ds:[di], al
			inc	di
			endm

			ProcessBit
			ProcessBit
			ProcessBit
			ProcessBit
			ProcessBit
			ProcessBit
			ProcessBit
			ProcessBit

			loop	jByteLoop
			jmp	ReadLoop
jByteLoop:	jmp	ByteLoop

ProcessWithChecks:
; read a byte
		cmp	si, ReadEnd
		jb	noreadblock$1
		push	bx
		mov	dx, offset ReadBuffer
		mov	si, dx
		mov	bx, InFile
		mov	ah, 3Fh
		mov	cx, ReadBufferSize
		int	21h
		pop	bx
		jnc	readsuccess$1
		jmp	fail
readsuccess$1:
		or	ax, ax
		jne	notready$1
		jmp	ready
notready$1:
		add	ax, offset ReadBuffer
		mov	ReadEnd, ax
noreadblock$1:
		lodsb
;
		mov	dl, al
		mov	cx, 8
bitloop:
		shl	dl, 1
		jnc	zerobit
onebit:
; read a byte
		cmp	si, ReadEnd
		jb	noreadblock$2
		push	bx
		push	cx
		push	dx
		mov	dx, offset ReadBuffer
		mov	si, dx
		mov	bx, InFile
		mov	ah, 3Fh
		mov	cx, ReadBufferSize
		int	21h
		pop	dx
		pop	cx
		pop	bx
		jnc	readsuccess$2
		jmp	fail
readsuccess$2:
		or	ax, ax
		jne	notready$2
		jmp	ready
notready$2:
		add	ax, offset ReadBuffer
		mov	ReadEnd, ax
noreadblock$2:
		lodsb
;
		mov	es:[bx], al
		mov	bh, bl
		mov	bl, al
; Write a byte
		cmp	di, offset WriteBufferEnd
		jb	nowriteblock$1
		call	WriteBlock
nowriteblock$1:
		mov	ds:[di], al
		inc	di
;
		loop	bitloop
		jmp	ReadLoop

zerobit:
		mov	al, es:[bx]
		mov	bh, bl
		mov	bl, al
; Write a byte
		cmp	di, offset WriteBufferEnd
		jb	nowriteblock$2
		call	WriteBlock
nowriteblock$2:
		mov	ds:[di], al
		inc	di
;
		loop	bitloop
		jmp	ReadLoop


ready:	call	FlushBuffer

		mov	ax, 4c00h
		int	21h

fail:
		mov	dx, offset FailString
		mov	ah, 9
		int	21h
		mov	ax, 4c01h
		int	21h

code ends

	end start

