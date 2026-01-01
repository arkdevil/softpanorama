;                              FoxBase library
;                Made by Semuonov Leonid(SL), Simferopol,1990.
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
code 	segment
	assume 	cs:code , ds:code
;        org 100h
start   	proc	 far

		push es	
		push ax
		push bx
		push dx
		push si

		mov ax, ds
		mov es, ax

                push cs
                pop  ds
;***************************************  receive parameters		    			
                      ; es:[bx+0] - number of subroutine !!!
		mov al, es:[bx+1]
		mov byte ptr row0, al
		mov al, es:[bx+2]
		mov ah, 00h
		mov word ptr col0, ax
		mov al, es:[bx+3]
		mov byte ptr row1, al
		mov al, es:[bx+4]
		mov ah, 00h
		mov word ptr col1, ax
		mov al, es:[bx+5]
		mov byte ptr atr,  al
;---------------------------------------

 		dec byte ptr row0
		dec byte ptr col0

                push ax
		push dx
wait_status:	mov dx, 03dah
		in  al, dx 
		and al, 00001001b
		cmp al, 00001001b
		jne wait_status       ; if video not ready, loop
	        mov ax, 0b800h        ; segment adress of video memory
	        mov es, ax		
		pop dx
		pop ax

	        mov ax, 0b800h        ; segment adress of video memory
	        mov es, ax		

m1:		mov ax, 160d          ; ah = 0
		mul byte ptr row0
		add ax, word ptr col0
		add ax, word ptr col0
		add ax, 01h           ; shift to attribute
		mov bx, ax            ; addres of first byte of dark line	
 		mov ax, word ptr col0 ; 

line:                                 ; loop to paint line on screen
                push ax
		mov al, byte ptr atr 
		mov byte ptr es:[bx], al
		pop ax
		inc bx
		inc bx
		inc ax   
		cmp ax, word ptr col1
		jne line

		inc byte ptr row0               ; next line
		mov al, byte ptr row1
		cmp al, byte ptr row0
		jne m1

		pop si
 		pop dx
		pop bx
		pop ax
		pop es
                ret

row0	db	5
col0	dw	0
row1 	db	10
col1	dw	0
atr	db	113

code 	ends
	end 	start


