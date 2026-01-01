	.model large,c
	.code

	public _myfail

; void _myfail( unsigned int got, unsigned int wanted);
;
; got and wanted are number of segments requested and available.
;
; (c) by MacSoft 1990
;

_myfail	proc
	ret
_myfail	endp

	end
