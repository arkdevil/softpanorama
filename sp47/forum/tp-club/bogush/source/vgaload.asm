; Этот файл был использован для написания VGA2COM.PAS
cseg 	  segment
	  assume  cs:cseg,ds:cseg
	  org 100h
start:
  	  push    ds
	  mov ax,0
	  push    ax
	  mov dx,ds
	  jmp begin

nr	db	   86
table	db         63,63,63
	db         63,63,0
	db         63,0,63
	db         63,0,0
	db         11,63,63
	db         0,63,0
	db         0,0,63
	db         21,21,21
	db         55,50,42
	db         56,33,19
	db         36,0,42
	db         33,0,0
	db         0,45,42
	db         0,21,0
	db         0,0,42
	db         0,0,0

begin:
	cld
	lea si,table
	mov cx,15
bloop:
    	mov	ah,10h
    	mov	al,7h
    	mov	bl,cl
    	int	10h
    	mov	nr,bh
    	
    	push	cx
    	
    	lodsb
    	mov	dh,al
    	lodsb
    	mov	ch,al
    	lodsb
    	mov	cl,al
    	mov	bh,0
    	mov	bl,nr
    	mov	ah,10h
    	mov	al,10h
    	int	10h
    	
    	pop	cx
	loop    bloop

    	mov	ah,10h
    	mov	al,7h
    	mov	bl,0
    	int	10h
    	mov	nr,bh
    	
    	
    	lodsb
    	mov	dh,al
    	lodsb
    	mov	ch,al
    	lodsb
    	mov	cl,al
    	mov	bh,0
    	mov	bl,nr
    	mov	ah,10h
    	mov	al,10h
    	int	10h


	retf
	ends    cseg

	END start

	