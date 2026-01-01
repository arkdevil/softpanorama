page ,132
title magwht ( magenta bak - white crsr, brdr ) 01/17/96 - 11:20 pm
;
code     segment para public 'code'
;
         org   256
;
         assume cs:code
;
magwht   proc  far
;
;*-----------------------
;*   set border color
;*-----------------------
sbc:
;
         mov   ah,16                   ; set color fct
         mov   al,3                    ; toggle intensity/blink bit
         mov   bl,0                    ; set for intensity
         int   16
;
         mov   ah,16                   ; set color fct
         mov   al,1                    ; set border color
         mov   bh,15                   ; set for white
         int   16
;
;*-------------------------
;*  set cursor position
;*-------------------------
scp:
         mov   ah,2                    ; set cursor position fct
         mov   bh,0                    ; page 0
         mov   dh,0                    ; row 0
         mov   dl,0                    ; col 0
         int   16
;*----------------------------------
;*  write character and attribute
;*----------------------------------
wcaa:
         mov   ah,9                    ; write char and attr fct
         mov   al,32                   ; char = space
         mov   bh,0                    ; page 0
         mov   bl,95     ; x'5f'       ; attr = magenta back, white crsr
         mov   cx,2000                 ; 25 * 80 = full screen
         int   16
;
exit:    mov   al,0                    ; ret code = 0
         mov   ah,76                   ; term with ret code
         int   33
;
magwht   endp
;
code     ends
;
         end   magwht
;
;---------------------------------------
;  Color Chart
;---------------------------------------
;
;  Black    = 00   Light Black    = 08
;  Blue     = 01   Light Blue     = 09
;  Green    = 02   Light Green    = 10
;  Cyan     = 03   Light Cyan     = 11
;  Red      = 04   Light Red      = 12
;  Magenta  = 05   Light Magenta  = 13
;  Brown    = 06   Light Brown    = 14     ( Yellow )
;  White    = 07   Light White    = 15
;
;----------------------------------------
;