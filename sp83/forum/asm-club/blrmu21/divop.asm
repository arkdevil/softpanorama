page ,132
title divop ( display interrupt vectors on prtr ) - 05/14/96 - 06:00 pm
;*-------------------------------------------------
;
;   display interrupt vectors on printer
;  ( either all, empty, or used )
;  ( for all interrupts from 00 to FF )
;
;   vector table syntax : ( lo-hi format )
;   offset : segment
;   (word) : (word)
;
;   display syntax :      ( hi-lo format )
;   segment : offset
;   (word)    (word)
;*-------------------------------------------------
;*   syntax :
;*            divop a  ( All int vectors )
;*            divop e  ( Empty only int vectors )
;*            divop u  ( Used only int vectors )
;*-------------------------------------------------
;
;*---------------------------
csroff   macro
;*---------------------------
;*   cursor off
;*---------------------------
;
         push  ax
         push  cx
         mov   ah,1
         mov   ch,32
         int   10h
         pop   cx
         pop   ax
         endm
;
;*---------------------------
csron    macro
;*---------------------------
;*   cursor on
;*---------------------------
         push  ax
         push  cx
         mov   ah,1
         mov   ch,stcsl                ; restore the crsr start line
         mov   cl,stcel                ; restore the crsr end line
         int   10h
         pop   cx
         pop   ax
         endm
;
;*---------------------------
csrsv    macro
;*---------------------------
;*   cursor save
;*---------------------------
         push  ax
         push  bx
         push  cx
         mov   ah,3
         mov   bh,0
         int   10h
         mov   stcsl,ch                ; save the crsr start line
         mov   stcel,cl                ; save the crsr end line
         pop   cx
         pop   bx
         pop   ax
         endm
;
;*-------------------------------------
;*   direct console input
;*-------------------------------------
dci      macro cic
         mov   ah,7
         int   21h
         mov   cic,al
         endm
;
;*----------------------------------
;*   display character on printer
;*----------------------------------
dcop     macro poc
         mov   dl,poc
         mov   ah,5
         int   33
         endm
;
;*------------------------------------
lm       macro msg
;*------------------------------------
;*  list message
;*------------------------------------
         lea   ax,msg
         call  lmts
         endm
;
;*--------------------------------------
mswl     macro dest,sors,len
;*--------------------------------------
;* move short with length
;---------------------------------------
;* dest = destination of move
;* sors = source of move
;* len  = max length of move
;--------------------------------------
;* length may be from 1 to 255
;* length must be db if variable
;*--------------------------------------
         push  cx
         push  di
         push  si
         mov   ch,0
         mov   cl,len
         lea   di,dest
         lea   si,sors
         cld
         rep   movsb
         pop   si
         pop   di
         pop   cx
         endm
;
;*------------------------------------
pc       macro fld,len,char
;*------------------------------------
;* propagate character
;*------------------------------------
;* the area named 'fld',
;* for a length of 'len'
;* will be filled with 'char'
;*------------------------------------
         push  ax
         push  cx
         push  di
         lea   di,fld
         mov   cx,len
         mov   al,char
         cld
         rep   stosb
         pop   di
         pop   cx
         pop   ax
         endm
;
;*------------------------------------
pm       macro msg
;*------------------------------------
;* print message
;* ( by calling pmtp )
;*------------------------------------
         lea   ax,msg
         call  pmtp
         endm
;
;*--------------------------------------
rk       macro kpa
;*--------------------------------------
;* read keyboard
;*--------------------------------------
;* kpa = keyboard parameter area
;* function 10 = read buffered keyboard
;*--------------------------------------
         lea   dx,kpa
         mov   ah,10
         dc
         endm
;
;   equates
;
z        equ   0
four     equ   4
lf       equ   10
tof      equ   12
cr       equ   13
mlc      equ   30
;
         .model small
         .code
;
;   parm area
;
         org   128
;
pl       db    0                       ; parm len ( includes space )
         db    0                       ; space
aeu      db    0                       ; 'a', 'e', 'u'
;
         org   256
;
go:      jmp   divs
;
;   data section
;
stcsl    db    z                       ; save the crsr start line
stcel    db    z                       ; save the crsr end line
;
voa1     db    z                       ; vector offset address 1
voa2     db    z                       ; vector offset address 2
vsa1     db    z                       ; vector segment address 1
vsa2     db    z                       ; vector segment address 2
;
;  vector address msg
;
vam      db    cr,lf
         db    ' * interrupt # = '
vin      db    'xx'
         db    ' - vector addresses : '
         db    ' segment = '
vsv      db    'xxxx'
         db    ' , '
         db    ' offset = '
vov      db    'xxxx'
         db    cr,lf,z
;
hm       db    '<===   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   ===>'
         db    0,0,0
hma      db    '<===   printed list of all   interrupt vectors   ===>'
hme      db    '<===   printed list of empty interrupt vectors   ===>'
hmf      db    '<===   printed list of used  interrupt vectors   ===>'
;
lhm      db    13,10,10
         db    ' * interrupt vectors being printed * '
         db    13,10,10,0
;
ff       db    tof,z                   ; top of form
cll      db    cr,lf,lf,z              ; cr, lf, lf
;
rr       db    z                       ; reg result
lc       db    z                       ; line count
rv       db    z                       ; req value
poc      db    z                       ; prt out char
mrv      dw    z                       ; mult req value
mbtf     dw    z                       ; work field
tolf     db    z                       ; type of list flag
;
;  code section
;
divs:
;
;   check command line
;
ccl:
         mov   tolf,'a'                ; set flag for all
         mswl  hm,hma,53               ; set msg for all
;
         cmp   pl,0                    ; parm len = 0 ?
         je    gaiv                    ; if so, default
;
;  check passed parameters
;
         cmp   aeu,'a'                 ; all ?
         je    gaiv                    ; if so, do it
         cmp   aeu,'e'                 ; empty ?
         jne   cfupp                   ; if not, chk for used
         mov   tolf,'e'                ; if so, set for empty
         mswl  hm,hme,53               ; set msg for empty
         jmp   gaiv                    ; do it
cfupp:
         cmp   aeu,'u'                 ; used ?
         jne   gaiv                    ; if not, do it
         mov   tolf,'u'                ; if so, set for used
         mswl  hm,hmf,53               ; set msg for used
         jmp   gaiv                    ; do it
;
;  get all int vectors
;
gaiv:
;
         csrsv                         ; cursor save
         csroff                        ; cursor off
         call  green                   ; set scrn to green
         call  dhr                     ; display hdg rtn
         lm    cll                     ; cr, lf, lf
         lm    lhm                     ; list hdg msg
;
;     get and display
;
;   ( the interrupt vector address contents )
;   ( for all interrupt vectors )
;
gad:
         push  es                      ; save es
;
         mov   ax,0                    ; set es
         mov   es,ax                   ; to 0
         mov   bx,mrv                  ; set bx to request
;
         cmp   tolf,'a'                ; all ?
         je    gc
;
         mov   cx,es:[bx]              ; get addresses
         mov   dx,es:[bx+2]            ; for empty/full check
;
         cmp   cx,0                    ; empty ?
         je    cdx                     ; if so, carry on
         jmp   cff                     ; else, chk full flag
cdx:
         cmp   dx,0                    ; empty ?
         je    cef                     ; if so, chk empty flag
         jmp   co                      ; else, give up
;
cef:
         cmp   tolf,'e'                ; empty ?
         je    gc                      ; if so, do it
         jmp   co                      ; give up
cff:
         cmp   tolf,'u'                ; used ?
         je    gc                      ; if so, do it
         jmp   co                      ; give up
;
gc:
         mov   al,es:[bx]              ; get contents
         mov   voa2,al                 ; of vector
         mov   al,es:[bx+1]            ; offset
         mov   voa1,al                 ; address
;
         mov   al,es:[bx+2]            ; get contents
         mov   vsa2,al                 ; of vector
         mov   al,es:[bx+3]            ; segment
         mov   vsa1,al                 ; address
;
         pop   es                      ; restore es
;
;    display vector address msg
;
         mov   al,rv
         call  chta
         mov   vin,dh
         mov   vin+1,dl
;
         mov   al,voa1
         call  chta
         mov   vov,dh
         mov   vov+1,dl
;
         mov   al,voa2
         call  chta
         mov   vov+2,dh
         mov   vov+3,dl
;
         mov   al,vsa1
         call  chta
         mov   vsv,dh
         mov   vsv+1,dl
 ;
         mov   al,vsa2
         call  chta
         mov   vsv+2,dh
         mov   vsv+3,dl
;
         pm    vam
;
         add   lc,1
         cmp   lc,mlc
         jb    co
         call  dhr
;
co:
         add   rv,1
         add   mrv,four
         cmp   mrv,1020                ; interrupt FF ?
         ja    stop
         jmp   gad
;
stop:
;
         lm    cll
         csron
         pm    cll
         pm    ff
;
         mov   al,0         ; set cond code to 0
         mov   ah,76        ; and exit
         int   33
;
;  display hdg rtn
;
dhr      proc  near
         mov   lc,0
         pm    ff
         pm    hm
         pm    cll
         ret
dhr      endp
;
;*------------------------------
;*   catb.prc
;*------------------------------
;*   convert ascii to binary
;*------------------------------
;* converts an ascii decimal
;* input number
;* pointed to by si,
;* to a dw binary output field
;* pointed to by di,
;* with the input field width
;* in bx,
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
         and   ax,000fh
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
;*-------------------------------
;   cath.prc
;*-------------------------------
;* convert ascii to hex
;* byte is in al both ways
;*-------------------------------
cath     proc  near
         sub   al,48
         jb    athe
         cmp   al,10
         jb    athx
         sub   al,39
         cmp   al,16
         jnb   athe
         cmp   al,10
         jnb   athx
athe:    mov   al,255
athx:    ret
cath     endp
;
;*-----------------------------------------------
;   cbwtas.prc
;*-----------------------------------------------
;*   convert binary word to ascii string
;*-----------------------------------------------
;*  before call set :
;*
;* ax = binary number
;* bx = length of output field
;* si = pointer to output field
;*------------------------------------------------
cbwtas   proc  near
         push  cx
         push  dx
         mov   cx,10
         sub   bx,1
         add   si,bx
;
cbtavsl:
         cmp   ax,0010
         jb    cbtavsx
         sub   dx,dx
         div   cx
         or    dl,48
         mov   [si],dl
         dec   si
         jmp   cbtavsl
;
cbtavsx:
         or    al,48
         mov   [si],al
         pop   dx
         pop   cx
         ret
cbwtas   endp
;
;*--------------------------------------
;*   chta.prc
;*--------------------------------------
;* convert hex to ascii ( 1 byte )
;*--------------------------------------
;* byte to be converted is passed in al
;* the hi nibble is passed back in dh
;* the lo nibble is passed back in dl
;*--------------------------------------
;
chta     proc  near
;   convert hi nibble
         mov   dh,al  ; move byte for hi conversion
         shr   dh,1   ; shift
         shr   dh,1   ; out
         shr   dh,1   ; lo
         shr   dh,1   ; nibble
         add   dh,48  ; add ascii zero
         cmp   dh,58  ; > than 9 ?
         jl    chtadl ; if not, carry on
         add   dh,7   ; else, convert to a-f
chtadl:
;   convert lo nibble
         mov   dl,al  ; move byte for lo conversion
         and   dl,15  ; get rid of hi nibble
         add   dl,48  ; add ascii zero
         cmp   dl,58  ; > than 9 ?
         jl    chtax  ; if not, carry on
         add   dl,7   ; else, convert to a-f
chtax:
         ret
chta     endp
;
;*-------------------------
;*   green prc
;*-------------------------
;*   change screen to
;*   white on green
;*-------------------------
;
green    proc  near
;
         mov   ah,11                   ; set color palette fct
         mov   bh,0                    ; text mode
         mov   bl,15                   ; border = white
         int   16
;
         mov   ah,2                    ; set cursor position fct
         mov   bh,0                    ; page number 0
         mov   dh,0                    ; row 0
         mov   dl,0                    ; col 0
         int   16
;
         mov   ah,9                    ; write char and attr fct
         mov   al,32                   ; char = space
         mov   bh,0                    ; page number 0
         mov   bl,47                   ; attr = green back, white crsr
         mov   cx,2000                 ; 25 * 80
         int   16
;
         ret
green    endp
;
;*------------------------------
;*     lmts.prc
;*------------------------------
;*   list msg to screen
;*------------------------------
;*   called by macro lm
;*   using ax as ptr to msg
;*------------------------------
;*  msg terminated by final zero
;*  or max 512 bytes
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
;
;*------------------------------
;*    pmtp.prc
;*------------------------------
;*   print msg (to printer)
;*------------------------------
;*   called by macro pm
;*   using ax as ptr to msg
;*------------------------------
;*  msg terminated by final zero
;*  or max 512 bytes
;*------------------------------
pmtp     proc  near
         push  ax
         push  bx
         push  cx
         push  si
         mov   bx,ax
         mov   cx,512
         mov   si,0
pmtpl:
         mov   al,[bx][si]
         cmp   al,0
         je    pmtpx
         mov   poc,al
         dcop  poc
         inc   si
         loop  pmtpl
pmtpx:
         pop   si
         pop   cx
         pop   bx
         pop   ax
         ret
pmtp     endp
;
         end   go