		.Model	Small
		.Stack 100h
		.Data

Header          DB	'Memory Control Block Info Utility Version 2.00'
		DB	13,10,'(C) 1990,1991 by Semenov Y.A., Odessa'
		DB      13,10,'  Addr Ownr Para',13,10,'$'
DosVers		DW	0
                .Code

;----- Output procedures

Space           Proc
		push	dx
                mov     dl,' '
                mov     ah,2
                int     21h
                pop	dx
                ret
Space           EndP

 TypeGSp        Proc
                mov     dl,es:[di]
                cmp     dl,20h
                jb      ExMCBT0
                cmp     dl,80h
                jae     ExMCBT0
                int     21h
                inc     di
                jmp     TypeGSp
 ExMCBT0:       ret
 TypeGSp        EndP


Translate       Proc
                 push   ds
                 push   cs
                 pop    ds
                 mov    al,dh
                 mov    cl,4
                 shr    al,cl
                 lea    bx,Trans
                 xlat
                 call   Types
                 mov    al,dh
                 and    al,00001111b
                 xlat
                 call   Types
                 pop    ds
                 ret
Trans           DB      '0123456789abcdef'
Translate       EndP

Types           Proc
                 push    ax
                 push    dx
                 mov     ah,2
                 mov     dl,al
                 int     21h
                 pop     dx
                 pop     ax
                 ret
Types           EndP

;------  MCB scanning procedures

MCBScanCur     Proc
                push    es
                jmp     Loop41
MCBScanCur     EndP

MCBScan1       Proc                       ; bp = subroutine address
                push    es
                mov     es,cs:FirstMCB
                call	bp
                cmp	byte ptr DosVers,4
                jb	LowVer
                mov	ax,es
                inc	ax
                mov	es,ax
 Loop41:        call    bp
 LowVer:        cmp     es:0,byte ptr 'Z'
                jz      ExMcbScan
                mov     ax,es
                inc     ax
                add     ax,es:3
		mov	es,ax
                jmp     Loop41
 ExMcbScan:     pop     es
                ret
MCBScan1       EndP

FirstMCBSearch Proc
                push    es
                mov	ah,52h
                int	21h
                sub	bx,2
                jnc	FMCBOK
                mov	ax,es
                sub	ax,1000h
                mov	es,ax
 FMCBOK:	mov     ax,es:[bx]
 		mov	cs:FirstMCB,ax
                pop     es
                ret
 FirstMCB       DW      0
FirstMCBSearch EndP

MCBType        Proc
                mov     dl,es:0
                cmp	dl,'M'
                jz	NonSys
                cmp	dl,'Z'
                jz	NonSys
                call	Space
 NonSys:        mov     ah,2
                int     21h
                call    Space
                mov     ax,es
                inc     ax
                push    ax
                mov     dh,ah
                call    Translate
                pop     ax
                mov     dh,al
                call    Translate
                call    Space
                mov     ax,es:1
                mov     dh,ah
                push    ax
                call    Translate
                pop     ax
                mov     dh,al
                call    Translate
                call    Space
                mov     ax,es:3
                mov     dh,ah
                push    ax
                call    Translate
                pop     ax
                push    ax
                mov     dh,al
                call    Translate
                call    Space
                cmp	byte ptr DosVers,4
                jb	LowVer1
                ; **
                mov	di,8
                mov	cx,di
                xor	si,si
 CheckName:	mov	al,es:[di]
 		or	al,al
                jz	NameOK
                cmp	al,' '
                jb	LowVer1
                cmp	al,'_'
                ja	LowVer1
 		inc	di
                inc	si
                loop	CheckName
 NameOK:	mov	di,8
 		mov	cx,si
                jcxz	LowVer1
 NameLoop:	mov	dl,es:[di]
                int	21h
                inc	di
 		loop	NameLoop
 NLoopEx:	call	Space
                ; **
 LowVer1:       pop     dx
                push    es
                push    ds
                xor     di,di
                mov     ds,di
                mov     ax,es
                inc     ax
                mov     es,ax
                add     dx,ax
                mov     cx,0dfh
                mov     bl,0
                mov     si,2
 InterrLoop:    cmp     word ptr [si],ax
                jb      ContIL
                cmp     word ptr [si],dx
                jae     ContIL
                push    ax
                push    bx
                push    cx
                push    dx
                mov     dh,bl
                call    Translate
                call    Space
                ;mov     ah,2
                ;mov     dl,'*'
                ;int     21h

                pop     dx
                pop     cx
                pop     bx
                pop     ax
 ContIL:        add     si,4
                inc     bl
                loop    InterrLoop
                cmp     word ptr es:[di],20cdh
                jnz     ExMCBT
                push    es
                mov     es,word ptr es:2ch
                xor     al,al
                mov     cx,-1
 SearchZero:    repne   scasb
                cmp     byte ptr es:[di],0
                jnz     SearchZero
                add     di,3
                mov     ah,2
                call    TypeGSp
                call    Space
                pop     es
                mov     di,100h
                mov     al,es:[di]
                cmp     al,0ebh
                jz      SJmp
                cmp     al,0e9h
                jz      UJmp
                cmp     al,0eah
                jnz     ExMCBT
                add     di,2
 UJmp:          add     di,2
 SJmp:          inc     di
                call    TypeGSp
 ExMCBT:        pop     ds
                pop     es
                mov     dl,13
                mov     ah,2
                int     21h
                mov     dl,10
                int     21h
                ret
MCBType        EndP

Start:		mov	ax,@Data
		mov	es,ax
		mov	ds,ax
                mov	ah,30h
                int	21h
                mov	DosVers,ax
                lea     dx,Header
                mov     ah,9
                int     21h
                call    FirstMCBSearch
                lea     bp,MCBType
                call    MCBScan1
		mov	ax,4c00h
		int	21h

		End 	Start