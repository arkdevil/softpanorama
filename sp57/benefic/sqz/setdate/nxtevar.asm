;       NXTEVAR.ASM - Jim Kyle - July 1990

.model small,c

.code

nxtevar proc    uses di, vptr:far ptr byte

        public nxtevar
; char far * nxtevar( char far * vptr );
        les     di, vptr
        mov     cx, 8000h
        xor     ax, ax      ; search for 0 and...
        mov     dx, ax      ; ...initialize return DX:AX to 0:0
repne   scasb               ; search ES:DI for char 0 in AL
        inc     cx          ; CX = 8000h if only one 0 found
        js      nev         
        mov     dx, es
        mov     ax, di
nev:    ret

nxtevar endp

        end

