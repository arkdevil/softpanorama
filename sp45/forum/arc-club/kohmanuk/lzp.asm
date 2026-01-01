; #compile /ml /w+ /t /m8 /zi
; #link    nolink

						Include	LZ.ASI
;-------------------------------------------------------------
;
;	Project:	YAR compressor
;	Module:		LZP.ASM
;	Purpose:
;			Contains packer's critical code
;			for LZ.C
;
;	(C) 1991-92 Compact Soft
;	Written by: cs:dk
;
;-------------------------------------------------------------


; =====	Packing routines
.code

bitBuf_s	STRUC
	bits		dw	?
	bytes		db	BITS dup (?)
	freeBits	db	?
	freeBytePtr	dw	?
ENDS

treeEl	STRUC
	codeLen	db	?
	codeVal	db	?
ENDS


global	BitBuf : bitBuf_s

global	FlushBitBuf : PROC


global	_PutCode : PROC
;void	_PutCode (treeEl dptr t);

proc	_PutCode, t : DATAPTR

	uses	si, di	; a C convention

	mov	si, t
	xor	cx, cx
	mov	cl, [si].codeLen
	mov	al, [si].codeVal

	mov	bx, BitBuf.bits
	mov	dl, BitBuf.freeBits

@@loop:
	shr	al, 1
	rcr	bx, 1

	dec	dl
	jz	@@flush

@@again:
	loop	@@loop

	mov	BitBuf.bits, bx
	mov	BitBuf.freeBits, dl

	ret

@@flush:
	mov	BitBuf.bits, bx
	mov	BitBuf.freeBits, dl

	push	cx ax bx dx
	call	FlushBitBuf
	pop	dx bx ax cx

	mov	bx, BitBuf.bits
	mov	dl, BitBuf.freeBits
	jmp	@@again

endp	_PutCode


end	; of LZP.ASM

