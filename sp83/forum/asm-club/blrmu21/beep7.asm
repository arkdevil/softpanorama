page ,132
title beep7 ( send 7 beeps to console) as of 05/14/96 - 04:45 pm
;*---------------------------------
was      macro  nos
         local  loop
;*---------------------------------
;*   wait a sec
;*---------------------------------
;*   nos = number of seconds
;*---------------------------------
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
;
cseg     segment para public 'beep7'
;
         assume cs:cseg,ds:cseg,ss:cseg,es:cseg
;
         org   256                     ; where to start
;
go:      jmp   beep                    ; jump around msg
;
Beephdg  db    13,10,10
         db    '***   Beeping 7 Times   ***'
         db    13,10,10,'$'
;
beep:
         lea   dx,beephdg              ; display
         mov   ah,9h                   ; the
         int   21h                     ; heading
;
         mov   cx,7                    ; set beep limit
;
beeploop:
         mov   dl, 7                   ; beep char
         mov   ah,2                    ; char out
         int   33                      ; send beep
         was   1                       ; wait 1 second
         loop  beeploop                ; do it 7 times
;
         mov   ax,4C00H                ; terminate with 0 ret code
         int   33                      ; exit
;
cseg     ends
;
         end   go