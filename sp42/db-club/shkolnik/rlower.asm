EXTRN                __parc:FAR,__retc:far,__parinfo:far,__ret:far
public               rlower

psl          SEGMENT 'CODE'
             ASSUME cs:psl

rlower       PROC    FAR

             push    ds
             push    si
             pushf

             xor   ax,ax
             push  ax
             call  __parinfo      
             add   sp, 2          
             or    ax,ax
             jnz   fdz
             jmp   cfs
fdz:         mov   ax, 1
             push  ax
             call  __parinfo      
             add   sp, 2          
             cmp   ax, 1
             je    fbv
             call  __ret
             jmp   cfs

fbv:         mov     ax,1
             push    ax
             call    __parc
             add     sp, 2 

             push  dx
             push  ax
             call  __retc
             add   sp,4   

             mov     ds,dx
             mov     si,ax
             push    ax
             xor     ah,ah

mg:          mov     al,[si]
             or      ax,ax
             jz      cfn
             cmp     ax,'A'
             jl      vd
             cmp     ax,'Z'
             jle     cumz
             cmp     ax,'А'
             jl      vd
             cmp     ax,'П'
             jg       cum2
cumz:        add     ax,20h
             jmp     vg
cum2:        cmp     ax,'Р'
             jl      vd
             cmp     ax,'Я'
             jg      vv0
             add     al,50h
             jmp     vg
vv0:         cmp     ax,'Ё'
             jne     vv1
             mov     al,'ё'
             jmp     vg
vv1:         cmp     ax,'Є'
             jne     vv2
             mov     al,'є'
             jmp     vg
vv2:         cmp     ax,'ў'
             jne     vv3
             mov     al,'°'
             jmp     vg
vv3:         cmp     ax,'√'
             jne     vv4
             mov     al,'№'
             jmp     vg
vv4:         cmp     ax,'¤'
             jne     vd
             mov     al,'■'
vg:          mov     [si],al
vd:          inc     si
             jmp     mg
cfn:         pop     ax
cfs:         popf
             pop     si
             pop     ds

             ret

rlower       endp
psl          ends
             end
