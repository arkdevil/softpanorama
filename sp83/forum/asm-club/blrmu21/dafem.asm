page ,132
title dafem ( display available, free, extended memory ) 05/08/96 - 04:10 pm

dv       equ   32                      ; displacement value

code     segment para public

         assume cs:code

         org   256                     ; start of COM file

go:      jmp   dafem                   ; jump around msg

;
;  available memory message
;

amm      db    13,10
         db    '   ┌────────────────────────────────────┐'
         db    13,10
mnm      db    '   │ maximum normal memory   -       kb │'
         db    13,10
nmf      db    '   │ normal memory free      -       kb │'
         db    13,10
mem      db    '   │ maximum extended memory -       kb │'
         db    13,10
aemp     db    '   │ available EMS memory    -       kb │'
         db    13,10
         db    '   └────────────────────────────────────┘'
         db    13,10,'$'

;
;    code section
;

dafem    proc  near

         mov   ah,74                   ; modify mem alloc
         mov   bx,65535                ; give me all memory
         int   33                      ; DOS call

         mov   ax,bx                   ; save paragraph value

         xor   dx,dx                   ; clear hi reg
         mov   cx,64                   ; set div value
         div   cx                      ; convert to kb

         mov   bx,3                    ; len of dest
         lea   si,nmf+dv+1             ; ptr to dest
         call  cbwtas                  ; convert
;
;   get-format normal / extended memory
;
         int   18                      ; normal memory

         mov   bx,3                    ; len of dest
         lea   si,mnm+dv+1             ; ptr to dest
         call  cbwtas                  ; convert

         mov   ah,136                  ; extended memory
         int   21

         mov   bx,4                    ; len of dest
         lea   si,mem+dv               ; ptr to dest
         call  cbwtas

         mov   ah,66                   ; expanded memory pages
         int   103                     ; int 67h

         mov   ax,bx                   ; save result

         shl   ax,1
         shl   ax,1
         shl   ax,1
         shl   ax,1

         mov   bx,5                    ; len of dest
         lea   si,aemp+dv-1            ; ptr to dest
         call  cbwtas

         lea   dx,amm                  ; point to msg
         mov   ah,9                    ; print string fct
         int   33                      ; DOS call

         mov   al,0                    ; set return code = 0
         mov   ah,76                   ; exit
         int   33                      ; DOS fct

dafem     endp

;*---------------------------------------
;*   convert binary word to ascii string
;*---------------------------------------
;*  before call set :
;*
;* ax = binary number
;* bx = length of output field
;* si = pointer to output field
;*---------------------------------------

cbwtas   proc  near
         push  cx
         push  dx
         mov   cx,10
         sub   bx,1
         add   si,bx

cbtavsl:

         cmp   ax,0010
         jb    cbtavsx
         sub   dx,dx
         div   cx
         or    dl,48
         mov   [si],dl
         dec   si
         jmp   cbtavsl

cbtavsx:

         or    al,48
         mov   [si],al
         pop   dx
         pop   cx
         ret

cbwtas   endp

code     ends

         end   go