#pragma inline
void keyclick(void)
 {
 asm{   cli
	push	ax
	push	bx

   }
 cycl:
 asm{
	in	al,60h
	mov	bl,al
	in	al,61h
	mov	ah,al
	or	al,80h
	out	61h,al
	xchg	ah,al
	out	61,al

	test	bl,80h
	jge    cycl
	pop	bx
	pop	ax
	sti
 }
}
void keydown(int key)
 {
 asm{
	push	ax
	push	bx

   }
 cycl:
 asm{
	in	al,60h
	mov	bl,al
	in	al,61h
	mov	ah,al
	or	al,80h
	out	61h,al
	xchg	ah,al
	out	61,al

	cmp	bl,key
	jne     cycl
	pop	bx
	pop	ax
 }
}
void ResetMachine(void){
 asm db 0xEA,0xF0,0xFF,0x00,0xF0;
}