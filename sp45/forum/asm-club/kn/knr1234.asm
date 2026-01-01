seg_a		segment	byte public
                assume  cs:seg_a,ds:seg_a
		org	100h
start:          mov	es,ax
                mov     word ptr es:472h,1234h
		jmp	dword ptr cs:data_1
data_1		dd	0FFFF0000h
seg_a		ends
		end	start
