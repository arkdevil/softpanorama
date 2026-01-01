EmuB	segment
	assume	cs:EmuB,ds:EmuB,es:EmuB
	org	100h
Start:
	jmp	Start_
old13	label	word
old_13	dd	?
cur	db	00
Text	db	'Insert diskette '
Nm	db	'A'
	db	': and strike a key...',0
new13	proc	near
	cmp	dl,2
	jnc	Stand
	call	Shelk
	cmp	dl,cs:cur
	jne	C13
	cmp	dl,0
	je	Stand
	mov	dl,0
	jmp	short	Stand
C13:	call	SaveRegs
	push	cs
	pop	ds
	mov	cur,dl
	add	Nm,dl
	push	dx
	mov	si,offset Text
	call	Print
	xor	ax,ax
	int	16h
	pop	dx
	sub	Nm,dl
	call	LoadRegs
	mov	dl,00h
Stand:	jmp	dword ptr cs:[old_13]
new13	endp

Shelk	proc	near
	push	cx
	push	ax
	mov	cx,0FFh
	in	al,61h
	or	al,3
	out	61h,al
Shel:	loop	Shel
	in	al,61h
	and	al,0FCh
	out	61h,al
	pop	ax
	pop	cx
	ret
Shelk	endp

Print   proc    near     
        xor     bx,bx    
        mov     ah,02h   
        mov     dx,0     
        int     10h      
        mov     ah,0Eh   
        mov     bl,0FFh   
        cld              
print1: lodsb            
        or	al,al
	je	exp
	int     10h      
        jmp	short print1   
exp:    ret              
Print           endp     
SaveRegs        proc    near   
                pop     cs:Temp
                push    es     
                push    ds     
                push    di     
                push    si     
                push    dx     
                push    cx     
                push    bx     
                push    ax     
                jmp     cs:Temp
SaveRegs        endp           
                               
LoadRegs        proc    near   
                pop     cs:Temp
                pop     ax     
                pop     bx     
                pop     cx     
                pop     dx     
                pop     si     
                pop     di     
                pop     ds     
                pop     es     
                jmp     cs:Temp
LoadRegs        endp           
                               
Temp            dw      ?      
 
Start_:
	xor	ax,ax
	mov	ds,ax
	push	ds:[13h*4]
	push	ds:[13h*4+2]
	pop	cs:old13+2
	pop	cs:old13
	mov	ds:[13h*4],offset new13
	mov	ds:[13h*4+2],cs
	mov	dx,offset Start_
	int	27h 
EmuB	ends
	end	Start
	end