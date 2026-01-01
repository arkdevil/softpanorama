	.model large,c

	.code

public	_myrand,_myseed

_seed	dw	5555h

; The magic numbers for 16 bit register are 4,13 and 15.
; The resulting noise period is 65535 cycles.
;
;      +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
;  +-->| 1| 2| 3| 4| 5| 6| 7| 8| 9|10|11|12|13|14|15|16|
;  |   +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
;  |              |                          |     |  |
;  |         +--+ |                     +--+ | +--+|  |
;  +---------|=1|-+                     |=1|-+ |=1|+  |
;            |  |-----------------------|  |---|  |---+
;            +--+                       +--+   +--+
;
_myrand	proc
	mov	bx,cs:[_seed]	;get seed
	mov	ax,bx		;keep it
	mov	cl,bl		;take a copy of bit 16
	shr	bx,1		;get bit 15
	xor	cl,bl		;and add mod 2
	shr	bx,1		;take bit 13
	shr	bx,1		;and
	xor	cl,bl		;make cascaded add
	shr	bh,1		;then take bit 4
	xor	cl,bh		;add it
	rcr	cl,1		;and move result to carry
	rcr	ax,1		;rotate carry to register
	mov	cs:[_seed],ax	;keep the new number
	ret			;and return
_myrand	endp

_myseed	proc
	arg s:word
	mov	ax,s		;get new seed
	or	ax,ax		;zero?
	jz	s1		;yep, just give him old one
	mov	cs:[_seed],ax	;else store new
s1:	mov	ax,cs:[_seed]	;and return the current seed
	ret
_myseed	endp

	end
