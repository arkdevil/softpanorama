page ,132
title pbm ( put batch message ) as of 05/14/96 - 04:50 pm
;*-----------------------------------------------------------------------
;
;        Put Batch Message
;
;        sets the cursor to a specified row and column,
;        and displays the specified message.
;        ( for batch file use )
;
;        syntax : pbm r=rr,c=cc,m=amamamamamamamamamamamamamamamamamam
;
;        where rr = row ( 01-25 decimal )
;        where cc = column ( 01-80 decimal )
;        where am = ascii message
;
;        if no parms,
;        default to current row and col,
;        msg = '........................................'
;
;        if error im parms,
;        default to current row and col,
;        msg = '*  PBM  *  Parameter Syntax Error  *'
;
;*-----------------------------------------------------------------------

;*--------------------------------
mswl     macro dest,sors,length
;*--------------------------------
;   move short with length
;
;   will move the 'sors' to the
;   'dest' for 'length' value
;   ( max length = 255 )
;*--------------------------------
         push  cx                      ; save
         push  di                      ; used
         push  si                      ; regs
;
         mov   ch,0                    ; clear hi
         mov   cl,length               ; load lo
         lea   di,dest                 ; dest index
         lea   si,sors                 ; sors index
         cld                           ; set direction forward
         rep   movsb                   ; repeat move string by byte
;
         pop   si                      ; restore
         pop   di                      ; used
         pop   cx                      ; regs
         endm
;
;*-----------------------------
pc       macro fld,len,char
;*-----------------------------
;* propagate character
;*-----------------------------
;* the area named 'fld',
;* for a length of 'len'
;* will be filled with 'char'
;*-----------------------------
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
code     segment para public 'code'
;
         assume  cs:code,ds:code,es:code
;
         org   128
;
pl       db    0            ; parm len ( includes space )
         db    0            ; space
rk       db    0            ; row key
         db    0            ; =
r        db    0,0          ; rr         ( yy )
         db    0            ; ,
ck       db    0            ; column key
         db    0            ; =
c        db    0,0          ; cc         ( xx )
         db    0            ; ,
mk       db    0            ; m
         db    0            ; =
m        db    40 dup(0)    ; '1234567890123456789012345678901234567890'
;
         org   256
;
;*---------------------
;*   put message
;*---------------------
pbm:
         jmp   doit
;
cr       db    0                       ; current row
cc       db    0                       ; current column
sr       db    0                       ; save row
sc       db    0                       ; save column
um       db    40 dup(0)               ; user msg
         db    0,0,0                   ; dmy
errm     db    '*  PBM  *  Parameter Syntax Error  *    '  ; 40 byte msg
         db    0,0,0
mtf      dw    1                       ; multiply temp fld
;
doit:
;
         pc    um,40,0                 ; initialize user msg
;
;*-----------------------
;*  get cursor position
;*-----------------------
;
         mov   ah,3
         mov   bh,0
         int   16
;
         mov   cr,dh                   ; get current row
         mov   cc,dl                   ; get current col
;
         cmp   pl,0                    ; parm len = 0 ?
         je    nomsg                   ; if so, no msg
;
crk:                                   ; check row key
;
         mov   al,rk                   ; get row key
;
         cmp   al,'r'                  ; row key there ?
         je    ckc                     ; if so, check col key
         cmp   al,'R'                  ; row key there ?
         je    ckc                     ; if so, check col key
         cmp   al,32                   ; space ?
         je    nomsg                   ; if so, no msg
         jmp   errmsg                  ; else, error msg
;
ckc:                                   ; check column key
;
         mov   al,ck                   ; get column key
;
         cmp   al,'c'                  ; col key there ?
         je    cmk                     ; if so, check msg key
         cmp   al,'C'                  ; background key there ?
         je    cmk                     ; if so, check msg key
         jmp   errmsg                  ; else, error msg
;
cmk:                                   ; check msg key
;
         mov   al,mk                   ; get msg key
;
         cmp   al,'m'                  ; msg key there ?
         je    mtm                     ; if so, move the msg
         cmp   al,'M'                  ; msg key there ?
         je    mtm                     ; if so, move the msg
         jmp   errmsg                  ; else, error msg
;
mtm:                                   ; move the msg
;
         lea   si,m                    ; sors ptr
         lea   di,um                   ; dest ptr
         mov   cx,40                   ; max cnt
;
mtml:
;
         mov   al,[si]                 ; get a byte
         cmp   al,0                    ; zero ?
         je    mtmx                    ; if so, exit
         cmp   al,13                   ; CR ?
         je    mtmx                    ; if so, exit
         mov   byte ptr[di],al         ; move srs to dest
         inc   si                      ; incr srs ptr
         inc   di                      ; incr dest ptr
         loop  mtml                    ; loop
;
mtmx:                                  ; move the msg exit
;
         jmp   pp                      ; process params
;
;*---------------------
;*  no message
;*---------------------
;
nomsg:
;
         mov   al,cr                   ; current
         mov   sr,al                   ; row
         mov   al,cc                   ; current
         mov   sc,al                   ; col
         pc    um,40,'.'               ; move 40 periods to msg
         jmp   scp                     ; and skip process parameters
;
;*---------------------
;*  error message
;*---------------------
;
errmsg:
;
         mov   al,cr                   ; current
         mov   sr,al                   ; row
         mov   al,cc                   ; current
         mov   sc,al                   ; col
         mswl  um,errm,40              ; move error msg to msg
         jmp   scp                     ; and skip process parameters
;
;*----------------------
;*  process parameters
;*----------------------
;
pp:
;
         lea   si,r                    ; ptr to in
         lea   di,sr                   ; ptr to out
         mov   sr,0                    ; clear out
         mov   bx,2                    ; set in len
         call  catb                    ; convert
;
         lea   si,c                    ; ptr to in
         lea   di,sc                   ; ptr to out
         mov   sc,0                    ; clear out
         mov   bx,2                    ; set in len
         call  catb                    ; convert
;
;  check and adjust row
;
         cmp   sr,25                   ; max ?
         ja    srt1                    ; if GT, set to 1
         cmp   sr,1                    ; min ?
         jb    srt1                    ; if LT, set to 1
         jmp   asr                     ; adjust
;
srt1:
         mov   sr,1                    ; set row to 1
;
asr:                                   ; adjust saved row
;
         mov   al,sr
         dec   al
         mov   sr,al
;
;  check and adjust col
;
         cmp   sc,80                   ; max ?
         ja    sct1                    ; if GT, set to 1
         cmp   sc,1                    ; min ?
         jb    sct1                    ; if LT, set to 1
         jmp   asc
;
sct1:
         mov   sc,1                    ; set col to 1
;
asc:                                   ; adjust saved col
;
         mov   al,sc
         dec   al
         mov   sc,al
;
;*------------------------
;*  set cursor position
;*------------------------
;
scp:
         mov   ah,2                    ; set cursor position fct
         mov   bh,0                    ; page 0
         mov   dh,sr                   ; get saved row
         mov   dl,sc                   ; get saved col
         int   16
;
;*--------------------------------
;*  put user msg to the screen
;*--------------------------------
;
         lea   ax,um                   ; user msg ptr
         call  lmts                    ; list msg to scrn
;
;*--------------------
;*  return to DOS
;*--------------------
;
exit:
         mov   al,0                    ; ret code = 0
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
;* temporary field named mtf
;*------------------------------
catb     proc  near
         push  ax
         push  cx
         mov   cx,10
         mov   mtf,1
         sub   si,1
;
catbl:
         mov   al,[si+bx]
         and   ax,15
         mul   mtf
         add   [di],ax
         mov   ax,mtf
         mul   cx
         mov   mtf,ax
         dec   bx
         jnz   catbl
         pop   cx
         pop   ax
         ret
catb     endp
;
;*------------------------------
;*     lmts.prc
;*------------------------------
;*   list msg to screen
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
;*----------------------------
;
code     ends
;
         end   pbm