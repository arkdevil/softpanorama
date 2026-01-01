;
; Вывод таблицы ASCII
; (возможен вывод в файл через переадресацию вывода >)
; Автор: Блашкин И.И.
; Turbo Assmebler 1.0 or higher
; MS-DOS 3.0 or higher
;
        .model  tiny
        .code
        org 	100h

main    proc    near
	lea	si,top
	mov	di,si
	mov	cx,0098h
replace:lodsb
	xor	al,32h
	stosb
	loop	replace	
        lea     si,hexsym
        mov     cx,0020h
        lea     dx,top
	mov	bp,0044h
        call    print
nextln: push    cx
        mov     ax,0020h
        sub     ax,cx
        mov     cx,8
        lea     di,line+3
nextwr: call    hexconv
        add     al,20h
        loop    nextwr
        pop     cx
        lea     dx,line
        call    print
        loop    nextln
	mov	di,word ptr lastsym+1
	mov	cx,42h
	mov	al,'▓'
	rep	stosb
	mov	ax,0A0Dh
	stosw
        mov     dx,word ptr lastsym+1
        call    print
        mov     ah,4Ch
        int     21h
main    endp

print   proc    near
	push	ax
	push	cx
	mov	cx,bp
	mov	ah,40h
	mov	bx,1
	int	21h
	pop	cx
	pop	ax
        retn
print   endp

hexconv proc    near
        push    cx
        push    ax
	cmp     ax,20h
        jae     skip
        add     ax,40h
skip:   stosb
        pop     ax
        push    ax
        mov     bl,al
        and     bl,0Fh
        sub     bh,bh
        mov     ah,[si+bx]
        mov     bl,al
        and     bl,0F0h
        mov     cl,4
        shr     bl,cl
        mov     al,[si+bx]
        add     di,2
        stosw
        add     di,3
        pop     ax
        pop     cx
        retn
hexconv endp

top     db      '▓▓▓▓▓▓ ASCII table ▓▓▓▓▓▓▓▓▓ (C)  BII  1992  '
	db	'V1.10 ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓',13,10
line    db      '▓ ^@  XX │ @  XX │ @  XX │ @  XX │ @  XX │ @ '
	db	' XX │ @  XX │ @  XX ▓',13,10
hexsym  db      '0123456789ABCDEF'
lastsym	equ	 $

        end     main
