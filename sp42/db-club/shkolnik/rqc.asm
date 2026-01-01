EXTRN                __parc:FAR,__retc:far,__ret:far,__parinfo:far
public               rqwerty,rcuke    ; Функции перевода QWERTY в ЦУКЕ
                                      ; и обратно на уровне символа.
rqw          SEGMENT 'CODE'
             ASSUME cs:rqw,es:rqw

rqwerty      PROC    FAR

             mov     word ptr cs:ty1[-2],offset cuk
             mov     word ptr cs:ty2[-2],1+offset cuk
             mov     word ptr cs:ty3[-2],offset qwe

pdb:         push    ds
             push    es
             push    si
             push    di
             push    cx
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
             mov     ax,cs
             mov     es,ax
             cld

mg:          mov     al,[si]
             or      al,al
             jz      cfn
             mov     di,offset cuk
ty1:         mov     cx,offset cuk-offset qwe
             repne   scasb
             sub     di,1+offset cuk
ty2:         cmp     di,42h
             jge     vav
             mov     al,es:qwe[di]
ty3:         mov     [si],al
vav:         inc     si
             jmp     mg
cfn:         pop     ax
cfs:         popf
             pop     cx
             pop     di
             pop     si
             pop     es
             pop     ds

             ret

cuk          db      "ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮЁ"
             db      "йцукенгшщзхъфывапролджэячсмитьбюё"

qwe          db      "QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?"
             db      "qwertyuiop[]asdfghjkl;'zxcvbnm,./"

rqwerty      endp

rcuke        proc    far
             mov     word ptr cs:ty1[-2],offset qwe
             mov     word ptr cs:ty2[-2],1+offset qwe
             mov     word ptr cs:ty3[-2],offset cuk
             jmp     pdb
rcuke        endp

rqw          ends
             end


