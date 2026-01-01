page ,132
title tonl ( turn off num lock ) - as of 05/14/96 - 04:20 pm
;
code     segment para public 'code'
;
         org   256
;
         assume cs:code
;
tonl:
;
         mov   ax,0                  ; set
         mov   ds,ax                 ; ds = 0
         mov   bx,0417h              ; ptr to Num Lock
         and   byte ptr [bx],0DFH    ; and with x'df'
         ret
;
code     ends
;
         end   tonl