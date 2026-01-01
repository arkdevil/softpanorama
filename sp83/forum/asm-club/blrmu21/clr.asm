page ,132
title clr ( clear the screen ) 05/14/96 - 05:00 pm
;
         .model small
         .code
;
         org   256
;
clr      proc  far
;
;   set crsr position = 0,0
;
         mov   ah,2                    ; set cursor position fct
         mov   bh,0                    ; page 0
         mov   dh,0                    ; row 0
         mov   dl,0                    ; col 0
         int   16                      ; video int
;
;   get char and attr at crsr
;
         mov    ah,8                   ; read char and attr at crsr fct
         mov    bh,0                   ; bh = page 0
         int    16                     ; video int
         mov    ch,ah                  ; get attr
         mov    cl,al                  ; get char ( but don't use it )
;
;   wrt char and attr at crsr
;
         mov   ah,9                    ; wrt char and attr at crsr fct
         mov   al,32                   ; al = char = space
         mov   bl,ch                   ; bl = attr
         mov   bh,0                    ; bh = page 0
         mov   cx,2000                 ; max characters to wrt
         int   16                      ; video int
;
;   set crsr position = 0,0
;
         mov   ah,2                    ; set cursor position fct
         mov   bh,0                    ; page 0
         mov   dh,0                    ; row 0
         mov   dl,0                    ; col 0
         int   16                      ; video int
;
;   exit with return code = 0
;
         mov   al,0                    ; return code = 0
         mov   ah,76                   ; terminate with ret code fct
         int   33                      ; dos int
;
clr      endp
;
         end   clr