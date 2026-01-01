; The original text was accidentally lost and reconstructed from .COM by 
;  the author in collaboration with Sourcer(TM) 3.23
; A. I. Alesinsky, 17.04.92 8(057-2)22-73-43
; The idea of this program was proposed by A. Fainman
seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a, ss:nothing,es:seg_a
s_loc  		label 	byte
 		org  	80h
parm_len	label 	byte
		org	81h
parms		label   byte
		org	100h

aidstest	proc	far

start:		cld
		xor	cx,cx
		mov  	al,parm_len		; Length of parms in initial 
						;  command string
		mov 	cl,ssp-ai		; length of the head of command
						;  string, which will be formed
						;  by program
		mov	di,(offset parms)-(ssp-ai) ; Move this head
		mov	si,offset ai		; before initial parms
		rep 	movsb
		add	al,ssp-ai-1		; Length of command string for
						;  future int 2Eh in al and
		mov	parms-(ssp-ai),al 	;  int 2Eh require this length 
						;  in first byte of the command\
						;  string
		mov	ax,3510h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	old10s,es		; Save original int 10h handler
		mov	old10o,bx		;  segment and offset
		mov	dx,offset int_10h_entry ; Set new int 10h handler
		mov	ax,2510h		; 
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	bx,1000h		; bx=4096 paragraphs =64Kb
		push	cs
		pop	es
		mov	ax,4A00h
		int	21h			; DOS Services  ah=function 4Ah
						;  change mem allocation, bx=siz
		mov	si,offset parms-(ssp-ai); Start of the formed command
						;  string in si
		mov	sss,ss			; Save ss and sp, because
		mov	ssp,sp			;  int 2Eh will destroy it and 
						;  all other registers, except
						;  cs and ip, in all versions 
						;  of MS-DOS ( but not DR-DOS !)
		int	2Eh			; Run program, pointed by ds:si
		mov	ax,cs
		mov	ds,ax			; Restore ds,
		mov	ss,sss			;  then ss and sp
		mov	sp,ssp
		lds	dx,old10
		mov	ax,2510h		; Restore int 10h handler
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		retn				; Exit from .com
ai		db	0Dh,'aidstest.exe'
ssp		dw	0
sss		dw	0
aidstest	endp

 		assume ds:nothing

int_10h_entry	proc	far			; Propiertary int 10h handler
		or	ah,ah			; Set mode ?
		jz	loc_3			;  yes, jump to spec. handling
		db	0EAh			;  jmp far to old int10 handler
old10 		label 	dword
old10o		dw 	0
old10s		dw 	0
loc_3:
		mov	ax,4C00h		; AIDSTEST try to show 
						;  an advertisment - so we
						;  immediatly kill it
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
int_10h_entry	endp

seg_a		ends
 end start
