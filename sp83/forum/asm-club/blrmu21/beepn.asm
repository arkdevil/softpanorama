page ,132
title beepn ( sound n beeps ) as of 05/08/96 - 02:25 pm
;
;*-------------------------------------------------
;
;        beepn
;
;        beeps n times
;
;        syntax : beepn n ( n = 1 - 9 )
;
;   error checking:
;
;        if n = 1 - 9, then n is ok
;
;        if n < 1 or n > 9, then n is set to 1
;
;        if no n, the n is set to 1
;
;*-------------------------------------------------

;*----------------------------
was      macro  nos
         local  loop
;*----------------------------
;*   wait a sec
;*----------------------------
;*   nos = number of seconds
;*----------------------------

         push  cx                     ; save cx
         mov   ah,44                  ; get current time
         int   33                     ; dos call
         mov   bh,dh                  ; get seconds
         add   bh,nos                 ; add requested seconds
         cmp   bh,60                  ; check for max seconds
         jl    loop                   ; if lo, loop
         sub   bh,60                  ; adjust seconds
loop:
         mov   ah,44                  ; get current time
         int   33                     ; dos call
         cmp   bh,dh                  ; requested delay complete ?
         jne   loop                   ; if not, carry on
         pop   cx                     ; restore cx
         endm

;*-------------------------------------
cseg     segment para public 'beepn'
;*-------------------------------------

         assume cs:cseg,ds:cseg,ss:cseg,es:cseg

         org   128

pl       db    0                       ; parm len = space + amt
         db    0                       ; space
amt      db    0,0                     ; beep amount

scl      db    0                       ; save cl

         org   256                     ; where to start
;
;    start of program
;

go:      jmp   beep                    ; jump around msg

;
;    data section
;

Beephdg  db    13,10,10
         db    '***   Beeping '
beepv    db    ' '
         db    ' Times   ***'
         db    13,10,10,'$'
;
;    start of code
;

beep:

         cmp   pl,0                    ; no parm
         je    ma1                     ; if so, make 1

         cmp  pl,2                     ; 1 digit + space ?
         je   pod                      ; if so, process one digit
         jmp  ma1                      ; if not, make 1

;
;    process one digit
;

pod:
         cld                           ; forward
         lea   si,amt                  ; ptr to amt
         lodsb                         ; put it in al
         and   al,15                   ; make ascii binary
         mov   ch,0                    ; clear ch
         mov   cl,al                   ; mov al to cl

;
;    validate amt between 1 - 9
;

         cmp   cl,1                    ; amt = 1 ?
         jb    ma1                     ; if LT, make amt 1

         cmp   cl,9                    ; amt = 9 ?
         ja    ma1                     ; if GT, make amt 1

         jmp   gti                     ; ok, go to it

ma1:

         mov   ch,0                    ; clear hi byte
         mov   cl,1                    ; make amt 1

gti:                                   ; go to it

         mov   scl,cl                  ; save beep amt

         mov   al,cl                   ; convert
         mov   bl,1                    ; it
         lea   si,beepv                ; for
         call  cbbtas                  ; msg

         lea   dx,beephdg              ; display
         mov   ah,9h                   ; the
         int   21h                     ; heading

         mov   cl,scl                  ; restore beep amt

beeploop:

         mov   dl, 7                   ; beep char
         mov   ah,2                    ; char out
         int   33                      ; send beep
         was   1                       ; wait 1 second
         loop  beeploop                ; do it n times

         mov   ax,4C00H                ; terminate with 0 ret code
         int   33                      ; exit

;*----------------------------------------
;*   convert binary byte to ascii string
;*----------------------------------------
;*   before call set :
;*
;* al = binary number
;* bl = length of output field
;* si = pointer to output field
;*----------------------------------------

cbbtas   proc  near
         push  cx
         mov   cl,10
         sub   bl,1
         mov   bh,0
         add   si,bx

cbtasl:

         cmp   al,0010
         jb    cbtasx
         sub   ah,ah
         div   cl
         or    ah,48
         mov   [si],ah
         dec   si
         jmp   cbtasl

cbtasx:

         or    al,48
         mov   [si],al
         pop   cx
         ret

cbbtas   endp

cseg     ends

         end   go