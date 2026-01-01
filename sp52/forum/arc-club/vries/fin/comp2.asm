
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

FailString	db	'COMP failed.', 10,13, '$'

		align

ReadBuffer	db	ReadBufferSize dup (?)
ReadBufferEnd	label byte
ReadSize		dw	?
		align

WriteBuffer	db	WriteBufferSize dup (?)
WriteBufferEnd	label byte
ExtraWriteBuffer db 10 dup (?)

data ends

table segment para public 'data'
	db	8000h dup (' ')
	db	8000h dup (' ')
table ends

code segment para public 'code'
	assume cs:code, ds:data, es:table

; FlushBuffer must be called at the end of the program

WriteBlock:	push	ax
			push	bx
			push	cx
			push	dx
			mov	ah, 40h
			mov	bx, OutFile
			mov	cx, WriteBufferSize
			lea	dx, WriteBuffer
			int	21h

; take care of the ExtraWriteBuffer
			mov	cx, di
			mov	di, offset WriteBuffer
			sub	cx, offset WriteBufferEnd
			je	ExtraHandled
			mov	bx, offset WriteBufferEnd
ExtraCopyLoop:	mov	al, ds:[bx]
			mov	ds:[di], al
			inc	bx
			inc	di
			loop	ExtraCopyLoop
ExtraHandled:	pop	dx
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

; register use:
;   bx	address
;   si	pointer to ReadBuffer
;   di	pointer to WriteBuffer
;   dl	Bits
;   bp	SavedWriteLoc

jProcessLastBytes:
			jmp	ProcessLastBytes
Start:		cld
			mov	ax, data
			mov	ds, ax
			mov	ax, table
			mov	es, ax

			mov	bx, 0
			mov	di, offset WriteBuffer

ReadBlockLoop:	mov	dx, offset ReadBuffer
			mov	si, dx				; to be used in ProcessBlockLoop
			push	bx
			mov	bx, InFile
			mov	ah, 3Fh
			mov	cx, ReadBufferSize
			int	21h
			jnc	ReadSuccess
			jmp	fail
ReadSuccess:	pop	bx
			mov	ReadSize, ax
			mov	cl, 3
			shr	ax, cl
			je	jProcessLastBytes
			mov	cx, ax

ProcessByte	macro SourceReg,BitVal
			local over
			cmp	SourceReg, es:[bx]
			je	over
			or	dl, BitVal
			mov	es:[bx], SourceReg
			mov	ds:[di], SourceReg
			inc	di
over:		mov	bh, bl
			mov	bl, SourceReg
			endm


ProcessBlockLoop:
			mov bp, di
			inc di
			xor dl, dl
			lodsw
			ProcessByte al, 80h
			ProcessByte ah, 40h
			lodsw
			ProcessByte al, 20h
			ProcessByte ah, 10h
			lodsw
			ProcessByte al, 08h
			ProcessByte ah, 04h
			lodsw
			ProcessByte al, 02h
			ProcessByte ah, 01h

			mov	ds:[bp], dl

			cmp	di, offset WriteBufferEnd
			jb	NoWriteBlock
			call	WriteBlock
NoWriteBlock:	loop	jProcessBlockLoop
			jmp	jNext1
jProcessBlockLoop:
			jmp	ProcessBlockLoop
jNext1:		mov	ax, ReadSize
			cmp	ax, ReadBufferSize
			jne	ProcessLastBytes
			jmp	ReadBlockLoop
ProcessLastBytes:
			mov	cx, ReadSize
			and	cx, 7
			je	Finish
			mov	bp, di
			inc	di
LastByteLoop:	lodsb
			shl	dl, 1
			cmp	al, es:[bx]
			je	over
			inc	dl
			mov	es:[bx], al
			mov	ds:[di], al
			inc	di
over:		mov	bh, bl
			mov	bl, al
			loop	LastByteLoop

			mov	cx, 8
			sub	cx, ReadSize
			and	cx, 7
			je	NoShift
ShiftLoop:	shl	dl, 1
			inc	dl
			loop	ShiftLoop

NoShift:		mov	ds:[bp], dl

Finish:		call	FlushBuffer

			mov	ax, 4c00h
			int	21h

fail:		mov	dx, offset FailString
			mov	ah, 9
			int	21h
			mov	ax, 4c01h
			int	21h


			code ends

		end Start
