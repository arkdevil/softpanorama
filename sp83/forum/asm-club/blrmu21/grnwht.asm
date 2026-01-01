page ,132
title grnwht ( green bak - white crsr, brdr ) 01/17/96 - 11:25 pm
;
code     segment para public 'code'
;
         org   256
;
         assume cs:code,ds:code
;
grnwht   proc  far
;
;*------------------------
;*  set border color
;*------------------------
sbc:

         mov   ah,16                   ; set color fct
         mov   al,3                    ; toggle intensity/blink bit
         mov   bl,0                    ; set for intensity
         int   16
;
         mov   ah,16                   ; set color fct
         mov   al,1                    ; set border color
         mov   bh,15                   ; set for white
         int   16

;*------------------------
;*  set cursor position
;*------------------------
scp:
         mov   ah,2                    ; set cursor position fct
         mov   bh,0                    ; page number 0
         mov   dh,0                    ; row 0
         mov   dl,0                    ; col 0
         int   16                      ; video int
;*---------------------------------
;*  write character and attribute
;*---------------------------------
wcaa:
         mov   ah,9                    ; write char and attr fct
         mov   al,32                   ; char = space
         mov   bh,0                    ; page number 0
         mov   bl,47      ; x'2f'      ; attr = green back, white crsr
         mov   cx,2000                 ; 25 * 80 = full screen
         int   16                      ; video int
;
exit:    mov   al,0                    ; return code = 0
         mov   ah,76                   ; terminate with ret code fct
         int   33                      ; dos int
;
grnwht   endp
;
code     ends
;
         end   grnwht
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