.286

_codeseg_ segment 'CODE'

public MouseKbd
MouseKbd proc far
assume CS:_codeseg_

                cmp     cs:FlagActive, 0
                jne     ResetMouse
                not     cs:FlagActive
                push    ax cx dx es cs
		pop	es
                mov     ax,0Ch    ; set my mouse handler
		mov	cx,2Bh
                lea     dx,cs:My_handle
                int     33h
                pop     es dx cx ax
                retf
ResetMouse:
                not     cs:FlagActive
                push    ax cx
                mov     ax,0Ch    ; set my mouse handler
                xor     cx,cx
                int     33h
                pop     cx ax
                retf

FlagActive      db 0

MouseKbd endp

InsChar         proc    near
		mov	bx,40h
		mov	ds,bx
		mov	bx,ds:1Ch
		mov	si,bx
		add	si,2
		cmp	si,ds:82h
		jne	loc_12
		mov	si,ds:80h
loc_12:
		cmp	si,1Ah
		je	loc_ret_13
		mov	[bx],ax
		mov	ds:1Ch,si
loc_ret_13:
		retn
InsChar		endp

My_handle:
                push    cs
                pop     ds
                test    al,02h  ; left
                jnz     l11
                test    al,08h  ; right
                jnz     l12
                test    al,20h  ; center
                jnz     l13


                shr     dx,1
                shr     dx,1
                shr     dx,1
                shr     cx,1
                shr     cx,1
                shr     cx,1

                push    cx dx
cmd1:
                sub     cx,3000h
cmd2:
                sub     dx,3000h
                pop     word ptr cs:cmd2+2
                pop     word ptr cs:cmd1+2

                xor     ax,ax
                or      cx,cx
		je	loc_4
		jg	loc_3
                mov     ah,4Bh    ; 'K'
		call	InsChar
		jmp	short loc_4
loc_3:
                mov     ah,4Dh    ; 'M'
		call	InsChar
loc_4:
                or      dx,dx
                jnz     loc_33
                retf
loc_33:
		jg	loc_5
                mov     ah,48h    ; up
		jmp	short loc_6
loc_5:
                mov     ah,50h    ; down
loc_6:
		call	InsChar
                retf
l11:
                mov    ax,1C0Dh   ; enter
                jmp    short loc_10
l12:
                mov    ax,011Bh
                jmp    short loc_10
l13:
                mov    ax,0E08h
loc_10:
		call	InsChar
loc_ret_11:
		retf

_codeseg_ ends

end
