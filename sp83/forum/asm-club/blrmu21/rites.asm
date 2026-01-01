page ,132
title rites ( rites of spring theme ) as of 05-14-96  04:20 pm
;
;   read through arrays of tones and durations using timer channel 2
;
;   from p. 109 - PC Resource May 1987 ( hardin brothers )
;
;   ( modifications by bud rasmussen )
;   ( tune by Igor Stravinsky        )
;
code     segment
;
         assume cs:code,ds:code
;
         org   256
;
rites:  jmp   play
;
ppipb    equ   61h                     ; PPI port b
tccr     equ   43h                     ; timer chip cmd reg
tc2      equ   42h                     ; timer channel 2
;
;
;    The following is the note table -- the calculation formula is:
;    note value = int ((1193180 / frequency) +.5)
;
;
notes    dw    9122                    ; c    1   ( c below middle c )
         dw    8609                    ; c#   2
         dw    8128                    ; d    3
         dw    7668                    ; d#   4
         dw    7240                    ; e    5
         dw    6834                    ; f    6
         dw    6450                    ; f#   7
         dw    6088                    ; g    8
         dw    5745                    ; g#   9
         dw    5424                    ; a    10
         dw    5119                    ; a#   11
         dw    4833                    ; b    12
;
         dw    4559                    ; c    13  ( middle c )
         dw    4304                    ; c#   14
         dw    4063                    ; d    15
         dw    3835                    ; d#   16
         dw    3620                    ; e    17
         dw    3417                    ; f    18
         dw    3225                    ; f#   19
         dw    3044                    ; g    20
         dw    2873                    ; g#   21
         dw    2712                    ; a    22
         dw    2559                    ; a#   23
         dw    2416                    ; b    24
;
         dw    2280                    ; c    25  ( c above middle c )
;
;
;    The following is the tune to be played.
;    The numbers are indexes into the list above.
;    The list is terminated with a -1.
;
;    to make a rest, use note of 0 in tune table and length in time table.
;
;
tune     db    23
         db    22
         db    18
         db    15
         db    22
         db    20
         db    0                       ; rest
;
         db    23
         db    22
         db    20
         db    25
         db    18
         db    20
;
         db    23
         db    22
         db    18
         db    15
         db    22
         db    20
;
         db    -1                      ; end
;
;    Each entry in the following time table
;    corresponds to one of the notes above.
;    Times are multiples of the 18.2159 Hz heartbeat.
;
;    for a rest, use 0 as note value, and specify length the normal way
;
time     db    12
         db    3
         db    3
         db    3
         db    3
         db    9
         db    9                       ; rest length
;
         db    9
         db    6
         db    3
         db    3
         db    3
         db    3
;
         db    3
         db    3
         db    3
         db    3
         db    3
         db    12
;
         db    -1                      ; end
;
;   program proper
;
play:
         mov   bx,1                    ; synchronize with the timer ticks
         call  delay                   ; by waiting for next one
         in    al,ppipb                ; get current port status
         or    al,3                    ; turn on lo 2 bits
         out   ppipb,al                ; open gate to timer
         mov   bx,0                    ; note count
         lea   di,time                 ; point to time table
;
loop:
         lea   si,tune                 ; point to tune table
         mov   al,[si][bx]             ; get tone
         mov   dl,[di][bx]             ; get duration
         mov   dh,0                    ; clear duration word
         cmp   al,-1                   ; end ?
         je    done                    ; if so, get out
         push  bx                      ; save count
         test  al,al                   ; rest ?
         jne   norest                  ; if not, carry on
         mov   bx,dx                   ; move duration
         call  rest                    ; turn speaker off
         jmp   repeat                  ; goto repeat
;
norest:
         cbw                           ; make tone a word
         dec   ax                      ; offset ftom 0
         shl   ax,1                    ; * 2 to index word table
         mov   bx,ax                   ; move to bx
         lea   si,notes                ; point to note table
         mov   cx,[si][bx]             ; get the note
         call  maketone                ; turn speaker on
         mov   bx,dx                   ; move duration
         call  delay                   ; wait while it plays
;
repeat:
         mov   bx,0                    ; break between notes
         call  rest                    ; turn spekaer off
         pop   bx                      ; retrieve count
         inc   bx                      ; + 1
         jmp   loop                    ; loop
;
;*------------------------
;*  sub routines
;*-------------------------
;
;   Enter maketone with frequency in cx
;   This routine starts the speaker going
;   Uses: AX
;
maketone:
         mov   al,10110110b            ; set up timer for ch 2
         out   tccr,al                 ; timer chip ready for count
         mov   al,cl                   ; get lsb of note
         out   tc2,al                  ; send to timer
         mov   al,ch                   ; get msb of note
         out   tc2,al                  ; now note has started
         ret
;
;   Enter delay with delay count in bx
;   This routine will pause for bx / 18.2 seconds
;   Uses: AX, CX, DX
;
delay:
         mov   ah,0                    ; timer function - get time count
         int   26                      ; timer count in cx:dx
         add   bx,dx                   ; add to delay count
delayl:
         int   26                      ; get new timer count
         cmp   bx,dx                   ; thru ?
         jne   delayl                  ; if not, carry on
         ret
;
;   Enter rest routine with count in BX
;
rest:
         in    al,ppipb                ; get current port status
         push  ax                      ; save status
         and   al,11111100b            ; turn off 2 lo bits
         out   ppipb,al                ; send out
         call  delay                   ; now wait
         pop   ax                      ; get back value
         out   ppipb,al                ; turn speaker on
         ret
;
done:
         in    al,ppipb                ; get port status
         and   al,11111100b            ; turn off 2 lo bits
         out   ppipb,al                ; send it out
         int   32                      ; get out
;
code     ends
;
         end   rites