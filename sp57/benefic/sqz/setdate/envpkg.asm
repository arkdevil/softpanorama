;ENVPKG.ASM - Jim Kyle - July 1990

.model small,c

.data
; assumes being used from C with _psp global variable
        extrn   _psp:word

.code

curenvp proc

        public  curenvp
; char far * curenvp( void );

        mov     ax,_psp         ; get PSP seg
        mov     es,ax
        mov     dx,es:[002Ch]   ; get env address
        xor     ax,ax           ; offset is zero
        ret

curenvp endp

mstenvp proc

        public  mstenvp
; char far * mstenvp( void );

        mov     ax,352Eh        ; get INT2E vector
        int     21h             ; (master segment)
        mov     dx,es:[002Ch]   ; get env address
        xor     ax,ax           ; offset is zero
        ret

mstenvp endp

envsiz  proc    oenv:word, senv:word   

        public  envsiz
; short envsiz( char far * vptr);

        mov     ax,senv         ; get segment of env
        dec     ax              ; back up to MCB
        mov     es,ax
        mov     ax,es:[0003h]   ; get size in grafs
        ret

envsiz  endp

        end
