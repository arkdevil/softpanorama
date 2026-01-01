page ,132
title buk ( Beep Until Keypress ) as of 05/08/96 - 02:55 pm

;*---------------------------------
;*   check input keyboard status
;*---------------------------------

ciks     macro
         local ciksno
         local ciksyes
         local ciksx

         mov   ah,11
         int   33

         cmp   al,0                    ; no char ?
         je    ciksno

         cmp   al,255                  ; a char ?
         je    ciksyes

         jmp   ciksno

ciksyes:

         mov   ah,'y'
         jmp   ciksx

ciksno:

         mov   ah,'n'
         jmp   ciksx

ciksx:

         endm

;*---------------------------------------
;*   direct console input with echo
;* ( echo only if between space and z )
;*---------------------------------------

dciwe    macro cic
         local dciwex

         mov   ah,7
         int   33
         mov   cic,al
         cmp   al,' '
         jb    dciwex
         cmp   al,'z'
         ja    dciwex
         dcos  cic

dciwex:

         endm

;*---------------------------------
;*   display character on screen
;*---------------------------------

dcos     macro coc

         mov   dl,coc
         mov   ah,2
         int   33

         endm

;*------------------------------------
;* exit from DOS program
;*------------------------------------

exit     macro

         mov   al,0
         mov   ah,76
         int   33

         endm

;*------------------------------------
;* list message
;* ( by calling lmts )
;*------------------------------------

lm       macro msg

         lea   ax,msg
         call  lmts

         endm

;*---------------------------------
;* wait a sec
;*---------------------------------
;* nos = number of seconds
;*---------------------------------

was      macro  nos
         local  loop

         push   ax
         push   bx
         push   cx
         push   dx
         mov    ah,44                  ; get current time
         int    33                     ; dos call
         mov    bh,dh                  ; get seconds
         add    bh,nos                 ; add requested seconds
         cmp    bh,60                  ; check for max seconds
         jl     loop                   ; if lo, loop
         sub    bh,60                  ; adjust seconds

loop:

         mov    ah,44                  ; get current time
         int    33                     ; dos call
         cmp    bh,dh                  ; requested delay complete ?
         jne    loop
         pop    dx
         pop    cx
         pop    bx
         pop    ax

         endm

;*------------------
;*   end of macros
;*------------------

         .model small

         .code

         org   256                     ; where to start

go:      jmp   dbh                     ; jump around data

;
;    data section
;

Beephdg  db    13,10,10
         db    '***   Beep until any key is pressed   ***'
         db    13,10,10,0

rr       db    ' '                     ; reg reply

;
;   code section
;

dbh:                                   ; display beep hdg

         lm    beephdg

beep3:

         mov   cx,3                    ; set beep limit
         call  beeper                  ; call beep proc
         ciks                          ; chk kbd input
         cmp   ah,'n'                  ; no ?
         je    beep3                   ; if so, keep beeping
         dciwe rr                      ; else, retrieve key press
         exit                          ; and exit

;--------------------------------------
;  beep n times
;  as of
;  12/31/93
;  06:50 pm
;
;  cx must be set with # of beeps
;  prior to call
;--------------------------------------

beeper   proc  near

beepl:
         mov   dl, 7                   ; beep char
         mov   ah,2                    ; char out
         int   33                      ; send beep

         was   1                       ; wait 1 second

         loop  beepl                   ; do it cx times

         ret

beeper   endp

;*------------------------------
;*     lmts.prc
;*------------------------------
;*   list msg to screen
;*------------------------------
;*   terminated by final zero
;*   or max 512 bytes
;*------------------------------

lmts     proc  near
         push  ax
         push  bx
         push  cx
         push  si
         mov   bx,ax
         mov   cx,512
         mov   si,0

lmtsl:

         mov   al,[bx][si]
         cmp   al,0
         je    lmtsx
         int   41
         inc   si
         loop  lmtsl

lmtsx:

         pop   si
         pop   cx
         pop   bx
         pop   ax
         ret
lmts     endp

         end   go