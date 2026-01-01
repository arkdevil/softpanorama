page ,132
title bcr ( batch C R ) as of 05/08/96 - 02:15 pm
;*-------------------------------------------------
;
;    Batch Carriage Return
;
;        does multiple CR, LF's from batch files
;        ( usually for spacing purposes )
;
;        syntax : bcr nn ( nn = 1 - 25 )
;
;    error checking:
;
;        if n = 1 - 25, then n is ok
;
;        if n < 1 or n > 25, then n is set to 1
;
;        if no n, the n is set to 1
;
;*-------------------------------------------------

;*------------------
csroff   macro
;*------------------
;*   cursor off
;*------------------

         push  ax
         push  cx
         mov   ah,1
         mov   ch,32
         int   16
         pop   cx
         pop   ax
         endm

;*----------------
csron    macro
;*----------------
;*   cursor on
;*----------------

         push  ax
         push  cx
         mov   ah,1
         mov   ch,stcsl                ; restore the crsr start line
         mov   cl,stcel                ; restore the crsr end line
         int   16
         pop   cx
         pop   ax
         endm

;*----------------
csrsv    macro
;*----------------
;*   cursor save
;*----------------

         push  ax
         push  bx
         push  cx
         mov   ah,3
         mov   bh,0
         int   16
         mov   stcsl,ch                ; save the crsr start line
         mov   stcel,cl                ; save the crsr end line
         pop   cx
         pop   bx
         pop   ax
         endm

;*---------------------

         .model small

         .code

         org   128

pl       db    0            ; parm len = space + amt ( n = 2, nn = 3 )
         db    0            ; space
amt      db    0,0          ; C R amount

         dd    0
mbtf     dw    0            ; multiply byte temp field
tbf      dw    0            ; temp binary field
stcsl    db    0            ; save the crsr start line
stcel    db    0            ; save the crsr end line

         org   256
;
;    start of program
;
bcr:

         cmp   pl,0         ; no parm
         je    ma1          ; if so, make 1

         cmp  pl,2          ; 1 digit + space ?
         je   pod           ; if so, process one digit

         cmp  pl,3          ; 2 digits + space ?
         jne  ma1           ; if not, make amt 1

         call ptd           ; call process two digits
;
;    validate amt between 1 - 25
;
         cmp   cx,1         ; amt = 1 ?
         jl    ma1          ; if LT, make amt 1

         cmp   cx,25        ; amt = 25 ?
         jg    ma1          ; if GT, make amt 1

         jmp   sc           ; ok, do the loop
;
;    process one digit
;

pod:
         cld                ; forward
         lea   si,amt       ; ptr to amt
         lodsb              ; put it in al
         and   al,15        ; make ascii binary
         mov   ch,0         ; clear ch
         mov   cl,al        ; mov al to cl
;
;    validate amt between 1 - 9
;
         cmp   cl,1         ; amt = 1 ?
         jl    ma1          ; if LT, make amt 1

         cmp   cl,9         ; amt = 9 ?
         jg    ma1          ; if GT, make amt 1

         jmp   sc           ; ok, carry on
;
;    make amt 1
;

ma1:
         mov   cl,1
;
;   save cursor
;

sc:
         csrsv              ; crsr save
         csroff             ; crsr off
;
;   CR, LF loop
;

cll:

         mov   dl,13        ; set CR
         mov   ah,2         ; display output
         int   33           ; DOS F C

         mov   dl,10        ; set LF
         mov   ah,2         ; display output
         int   33           ; DOS F C

         loop  cll          ; nn times

         csron              ; crsr on

         mov   al,0         ; set cond code to 0
         mov   ah,76        ; exit
         int   33

;*------------------------
;*  process two digits
;*------------------------

ptd      proc  near

         lea   si,amt       ; ptr to input
         lea   di,tbf       ; ptr to ouput
         mov   bx,2         ; len of input
         mov   tbf,0        ; clear result
         call  catb
         mov   cx,tbf       ; mov result to cx
         ret

ptd      endp

;*------------------------------
;*   convert ascii to binary
;*------------------------------
;*------------------------------
;* converts an ascii decimal
;* number pointed to by si,
;* to a dw binary field pointed
;* to by di,
;* with the input field width
;* in bx,
;* and using a dw multiply
;* temporary field named mbtf
;*------------------------------

catb     proc  near

         push  ax
         push  cx
         mov   cx,10
         mov   mbtf,1
         sub   si,1

catbl:
         mov   al,[si+bx]
         and   ax,15
         mul   mbtf
         add   [di],ax
         mov   ax,mbtf
         mul   cx
         mov   mbtf,ax
         dec   bx
         jnz   catbl
         pop   cx
         pop   ax
         ret

catb     endp

         end   bcr