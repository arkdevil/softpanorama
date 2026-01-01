page ,132
title ccc ( color change com ) as of 05/14/96 - 06:10 pm
;*-------------------------------------------------
;
;        Color Change Com
;
;        does color changes to:
;        foreground,
;        background,
;        edge( if not ega,vga )
;
;        syntax : ccc f=nn,b=nn,e=nn
;
;        where nn = 00-15 decimal
;
;        if no parms,
;        default to yellow on brown
;
;*-------------------------------------------------

code     segment para public 'code'

         assume  cs:code,ds:code,es:code

         org   128

pl       db    0            ; parm len ( includes space )
         db    0            ; space
ff       db    0            ; f
         db    0            ; =
f        db    0,0          ; nn
         db    0            ; ,
bb       db    0            ; b
         db    0            ; =
b        db    0,0          ; nn
         db    0            ; ,
ee       db    0            ; e
         db    0            ; =
e        db    0,0          ; nn

sf       db    0            ; save fore
sb       db    0            ; save back
se       db    0            ; save edge

mbtf     dw    1

         org   256

ccc:

         cmp   pl,0         ; parm len = 0 ?
         je    default      ; if so, default

cff:     mov   al,ff        ; get foreground key

         cmp   al,'f'       ; foreground key there ?
         je    cbb          ; if so, check background
         cmp   al,'F'       ; foreground key there ?
         je    cbb          ; if so, check background
         jmp   default      ; take default

cbb:     mov   al,bb        ; get background key

         cmp   al,'b'       ; background key there ?
         je    cee          ; if so, check edge
         cmp   al,'B'       ; background key there ?
         je    cee          ; if so, check edge
         jmp   default      ; take default

cee:     mov   al,ee        ; get edge key

         cmp   al,'e'       ; edge key there ?
         je    pp           ; if so, process parameters
         cmp   al,'E'       ; edge key there ?
         je    pp           ; if so, process parameters

default:

         mov   sf,14        ; default fore = yellow
         mov   sb,6         ; default back = brown
         mov   se,6         ; default edge = brown
         jmp   ssbc         ; and skip process parameters

pp:
         lea   si,f         ; ptr to in
         lea   di,sf        ; ptr to out
         mov   sf,0         ; clear out
         mov   bx,2         ; set in len
         call  catb         ; convert

         lea   si,b         ; ptr to in
         lea   di,sb        ; ptr to out
         mov   sb,0         ; clear out
         mov   bx,2         ; set in len
         call  catb         ; convert

         lea   si,e         ; ptr to in
         lea   di,se        ; ptr to out
         mov   se,0         ; clear out
         mov   bx,2         ; set in len
         call  catb         ; convert

;*-------------------------------
;* set sixteen background colors
;*-------------------------------
ssbc:
         mov   al,9                    ; set blink bit to intensity
         mov   dx,3d8h                 ; set color register
         out   dx,al                   ; send al to dx
;*------------------------
;*  set edge color
;*------------------------
sec:
         mov   ah,11                   ; set color palette fct
         mov   bh,0                    ; text mode
         mov   bl,se                   ; get edge color
         int   16
;*------------------------
;*  set cursor position
;*------------------------
scp:
         mov   ah,2                    ; set cursor position fct
         mov   bh,0                    ; page 0
         mov   dh,0                    ; row 0
         mov   dl,0                    ; col 0
         int   16
;*--------------------------------
;*  write character and attribute
;*--------------------------------
wcaa:
         mov   bl,sf                   ; get foreground
         mov   al,sb                   ; get background
         mov   cl,4                    ; set for shift
         shl   al,cl                   ; shift t0 left nibble
         or    bl,al                   ; OR with background
;
         mov   ah,9                    ; write char and attr
         mov   al,32                   ; space is char
         mov   bh,0                    ; page is 0
         mov   cx,2000                 ; 25 * 80 = full screen
         int   16
;
exit:    mov   al,0                    ; ret code = 0
         mov   ah,76                   ; term with ret code
         int   33
;
;*------------------------------
;*   convert ascii to binary
;*------------------------------
;*------------------------------
;* converts an ascii decimal
;* input pointed to by si,
;* to a dw binary output field
;* pointed to by di,
;* with the input width in bx,
;* and using a dw multiply
;* temporary field named mbtf
;*------------------------------
catb     proc  near
         push  ax
         push  cx
         mov   cx,10
         mov   mbtf,1
         sub   si,1
;
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
;
code     ends
;
         end   ccc

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
;---------------------------------------
