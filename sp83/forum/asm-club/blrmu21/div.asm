page ,132
title div ( display interrupt vector ) as of 05/14/96 - 06:00 pm
;*-------------------------------------------------
;
;   display interrupt vector
;   for any requested interrupt
;
;   vector table syntax : ( lo-hi format )
;   offset : segment
;   (word) : (word)
;
;   display syntax :      ( hi-lo format )
;   segment : offset
;   (word)    (word)
;*-------------------------------------------------

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
         int   33
         endm
;
;*--------------------------
;*   macro pool end
;*--------------------------
;
;   equates
;
z        equ   0
mci      equ   3
four     equ   4
lf       equ   10
cr       equ   13

         .model small
         .code
;
         org   256
;
go:      jmp   divs
;
;   data area
;
stcsl    db    z                       ; save the crsr start line
stcel    db    z                       ; save the crsr end line
;
voa1     db    z                       ; vector offset address 1
voa2     db    z                       ; vector offset address 2
vsa1     db    z                       ; vector segment address 1
vsa2     db    z                       ; vector segment address 2
;
;  request vector msg
;
rvm      db    cr,lf,lf
         db    '   * key requested interrupt # ( in hex ) : '
         db    z
;
qm       db    cr,lf,lf
         db    '   * press Enter when ready to quit '
         db    z
;
;  vector address msg
;
vam      db    cr,lf,lf
         db    '   * vector address : '
         db    ' segment = '
vsv      db    'xxxx'
         db    ' , '
         db    ' offset = '
vov      db    'xxxx'
         db    z
;
cll      db    cr,lf,lf,z              ; cr, lf, lf
;
rr       db    z                       ; reg result
;
srp      db    mci dup (' ')           ; save requested pick
;
rv       db    z                       ; req value
mrv      dw    z                       ; mult req value
mbtf     dw    z                       ; work field
;
;*----------------------------
;*   keyboard parameter list
;*----------------------------
kpl      label byte
bs       db    mci                     ; buffer size
be       db    z                       ; bytes entered
kb       db    mci dup(' ')            ; keyboard buffer
;
;  temp value msg
;
tvm      db    cr,lf,lf
         db    '   * requested vector = '
rvv      db    'xx'
         db    ' , '
         db    ' mult req vector = '
mrvv     db    '    '
         db    z
;
;  code
;
divs:
         csrsv                         ; cursor save
         csroff                        ; cursor off
         call green                    ; set scrn to green

;
;   request vector in hex
;
         lm    rvm                     ; display request vector msg
;
         csron                         ; cursor on
         rk    kpl                     ; get 2 digit pick
         csroff                        ; cursor off
         pc    srp,2,32                ; clear save requested pick
         mswl  srp,kb,be               ; move requested pick
;
;  adjust ascii input to hex
;
         mov   al,srp+1                ; get lo-order byte
         call  cath                    ; call ascii to hex
         mov   rv,al                   ; save converted byte
         mov   al,srp                  ; get hi-order byte
         call  cath                    ; call ascii to hex
         shl   al,1                    ; shift
         shl   al,1                    ; the
         shl   al,1                    ; byte
         shl   al,1                    ; for or
         or    rv,al                   ; or it with saved byte
;
;   multiply interrupt # by 4
;
         mov   ah,0                    ; clear hi-order
         mov   al,rv                   ; get value
         mov   bl,four                 ; get value of 4
         mul   bl                      ; multiply
         mov   mrv,ax                  ; save result
         jmp   gad                     ; bypass displays
;
;   display requested entry
;
         mov   al,rv
         call  chta
         mov   rvv,dh
         mov   rvv+1,dl
;
         mov   ax,mrv
         mov   bx,4
         lea   si,mrvv
         call  cbwtas
;
         lm    tvm
         dci   rr
;
;     get and display
;
;   ( the interrupt vector address contents )
;   ( for the requested interrupt vector )
;
gad:
         push  es                      ; save es
;
         mov   ax,0                    ; set es
         mov   es,ax                   ; to 0
         mov   bx,mrv                  ; set bx to request
;
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
         mov   al,voa1
         call  chta
         mov   vov,dh
         mov   vov+1,dl

         mov   al,voa2
         call  chta
         mov   vov+2,dh
         mov   vov+3,dl
;
         mov   al,vsa1
         call  chta
         mov   vsv,dh
         mov   vsv+1,dl

         mov   al,vsa2
         call  chta
         mov   vsv+2,dh
         mov   vsv+3,dl

         lm    vam
         lm    qm
         dci   rr
;
         lm    cll
         csron
;
         mov   al,0         ; set cond code to 0
         mov   ah,76        ; and exit
         int   33
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
         end   go