                .MODEL  TPASCAL

                .DATA

                EXTRN   Magic : DWORD            ; 256-DWORD array
                EXTRN   Magicon : DWORD          ; Magic constant

                .CODE

InitMagic       PROC FAR
                PUBLIC  InitMagic

                std
                push    ds
                pop     es
                mov     di,OFFSET Magic+03FEh    ; Last WORD of the array
                push    bp
                mov     bp,0FFh
im0:
                mov     cx,8
                mov     dx,bp
                xor     ax,ax
im1:
                shr     ax,1
                rcr     dx,1
                jnc     im2
                xor     dx,WORD PTR Magicon
                xor     ax,WORD PTR Magicon+2
im2:
                loop    im1
                stosw
                xchg    ax,dx
                stosw
                dec     bp
                jns     im0
                pop     bp
                ret

InitMagic       ENDP

IncCRC          PROC FAR pBuff:DWORD,Count:WORD,pCRC:DWORD
                PUBLIC  IncCRC

                les     si,pCRC
                mov     cx,es:[si]
                mov     dx,es:[si+2]
                mov     di,OFFSET Magic
                les     si,pBuff
                cld
                push    bp
                mov     bp,Count
                inc     bp
                jmp     SHORT ic1
ic0:
                xor     ax,ax
                lods    BYTE PTR es:[si]
                mov     bx,ax
                xor     bl,cl
                mov     cl,ch
                mov     ch,dl
                mov     dl,dh
                mov     dh,bh
                shl     bx,1
                shl     bx,1
                xor     cx,[bx+di]
                xor     dx,[bx+di+2]
                test    si,si
                jnz     ic1
                mov     ax,es
                add     ax,1000h
                mov     es,ax
ic1:
                dec     bp
                jnz     ic0
                pop     bp
                les     si,pCRC
                mov     es:[si],cx
                mov     es:[si+2],dx
                ret

IncCRC          ENDP

CODE            ENDS

                END



