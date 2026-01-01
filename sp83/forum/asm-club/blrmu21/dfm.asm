page ,132
title dfm ( display free memory ) 05/14/96 - 04:25 pm
;
code     segment para public
;
         assume cs:code
;
         org   0                       ; start of PSP
sop      equ   $                       ; start of program
         org   256                     ; start of COM file
;
go:      jmp   dfm
;
;  free memory message
;
;
fmm      db    13,10,10,'===> free memory available = '
fma      db    '1234567'
         db    13,10,10,'$'
;
dfm      proc  near
;
         mov   bx,(offset eop - sop + 15) shr 4 ; calculate real length
;
         mov   ah,4ah                  ; modify memory alloc
         int   33                      ; DOS call
;
         mov   ah,4ah                  ; modify mem alloc
         mov   bx,65535                ; give me all memory
         int   33                      ; DOS call
         mov   ax,bx                   ; save what you really got
;
         xor   dx,dx                   ; clear hi reg
         mov   dl,ah                   ; save hi value
         mov   cl,4                    ; set for shift 4
         shr   dx,cl                   ; shift hi reg right
         shl   ax,cl                   ; shift lo reg left
;
         lea   bx,fma                  ; point to dest
         mov   cx,7                    ; set dest limit
;*
;* clear free memory area
;*
cfma:
         mov   byte ptr [bx],32        ; set fill character = space
         inc   bx
         loop  cfma
;
         dec   bx                      ; back down dest pointer 1
         mov   si,10                   ; set divisor value
;
dsi:
         div   si                      ; divide by 10
         or    dx,48                   ; make mem ascii
         dec   bx                      ; back down dest pointer
         mov   [bx],dl                 ; move digit
         xor   dx,dx                   ; clear hi reg
         or    ax,ax                   ; test for end
         jnz   dsi                     ; if not, carry on
;
         lea   dx,fmm                  ; point to msg
         mov   ah,9                    ; print string fct
         int   33                      ; DOS call
;
         mov   al,0                    ; set return code = 0
         mov   ah,76                   ; exit
         int   33                      ; DOS fct
;
dfm      endp
;
eop      equ   $                       ; end of program
;
code     ends
;
         end   go