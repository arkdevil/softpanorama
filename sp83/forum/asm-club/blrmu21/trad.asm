page ,132
title trad ( typematic rate and delay ) - as of 05/14/96 - 05:45 pm
;
code     segment para public 'code'
;
         org   256
;
         assume cs:code
;
go:
         jmp   trad
;
msg      db    13,10
         db    ' * setting typematic : rate = fastest, delay = shortest '
         db    13,10,'$'
;
trad:
;
         lea   dx,msg                ; ptr to msg
         mov   ah,9                  ; send
         int   33                    ; msg
;
         mov   ah,3                  ; set ah to 3
         mov   al,5                  ; set al to 5
         mov   bh,0                  ; shortest delay = 0, longest = 3
         mov   bl,0                  ; fastest rate = 0, slowest = 31
         int   22                    ; int 16h
         ret
;
code     ends
;
         end   go