seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a
		org	100h
start:          mov	es,ax
                mov     byte ptr es:417h,0
                retn
seg_a           ends
                end start
