page ,132
title ff ( form feed ) as of 05/14/96 - 11:20 pm
;*-------------------------------------------------
;
;        Form Feed
;
;        does from 1 to 3 FF's
;
;        syntax : ff n ( n = 1 - 3 )
;
;   error checking:
;
;        if n = 1 - 3, then n is ok
;
;        if n < 1 or n > 3, then n is set to 1
;
;        if no n, then n is set to 1
;
;*-------------------------------------------------

code     segment para public 'code'

         assume  cs:code,ds:code,es:code

         org   128

pl       db    0            ; parm len
         db    0            ; space
amt      db    0            ; C R amount

         org   256

ff:

         cmp   pl,0         ; no n ?
         je    ma1          ; if so, make 1

         cld                ; forward
         lea   si,amt       ; ptr to amt
         lodsb              ; put it in al
         and   al,15        ; make ascii binary
         mov   ch,0         ; clear ch
         mov   cl,al        ; mov al to cl
;
;        validate amt between 1 - 3
;
         cmp   cl,1         ; amt = 1 ?
         jl    ma1          ; if LT, make amt 1

         cmp   cl,3         ; amt = 3 ?
         jg    ma1          ; if GT, make amt 1

         jmp   cll          ; ok, do the loop

ma1:
         mov   ch,0         ; clear ch
         mov   cl,1         ; make amt 1

cll:                        ; cr, lf loop

         mov   dl,12        ; set FF
         mov   ah,5         ; printer output
         int   33           ; DOS F C

         loop  cll          ; n times

         mov   al,0         ; set cond code to 0
         mov   ah,76        ; exit
         int   33           ; DOS F C

code     ends

         end   ff