page ,132
title prt ( print multiple text files copies ) as of 05/08/96 - 11:20 pm
;*------------------------------------------
;
;    print multiple text file copies
;
;    syntax : prt n xxx.xxx
;
;    where n = 1 - 9 copies
;    where xxx.xxx = text file name
;
;*------------------------------------------

code     segment para public 'code'
         assume  cs:code,ds:code,es:code

;*------------
;*   macros
;*------------

;*--------------------
;*   close a file
;*--------------------

caf      macro handle

         mov   bx,handle
         mov   ah,62
         int   33

         endm

;*---------------------------
;*  get cursor position
;*---------------------------

gcp      macro row,col

         push  ax
         push  bx
         push  dx
         mov   ah,3
         mov   bh,0
         int   16
         mov   col,dl
         mov   row,dh
         pop   dx
         pop   bx
         pop   ax

         endm

;*-----------------------------------
;*  move file pointer for file size
;*-----------------------------------
;*   ( to find the length  )
;*   ( of a file :         )
;*   ( mfpffs handle,0,0,2 )
;*----------------------------

mfpffs   macro handle,hi,lo,method

         mov   bx,handle
         mov   cx,hi
         mov   dx,lo
         mov   al,method
         mov   ah,66
         int   33
         mov   filenlo,ax
         mov   filenhi,dx

         endm

;*--------------------------
;*   open an input file
;*--------------------------

oaif     macro path,access

         lea   dx,path
         mov   al,access
         mov   ah,61
         int   33

         endm

;*-------------------
;*   read a file
;*-------------------

raf      macro handle,buffer,bytecnt

         mov   bx,handle
         mov   cx,bytecnt
         lea   dx,buffer
         mov   ah,63
         int   33

         endm

;*-------------------------------------
;*  set cursor position
;*-------------------------------------
;*  row = y coordinate = vertical
;*  col = x coordinate = horizontal
;*-------------------------------------
;*  row may be from 0 to 24
;*  col may be from 0 to 79
;*-------------------------------------

scp      macro row,col

         push  ax
         push  bx
         push  dx
         mov   ah,2
         mov   bh,0
         mov   dh,row
         mov   dl,col
         int   16
         pop   dx
         pop   bx
         pop   ax
         endm

;*--------------------------
;* wait a sec
;*--------------------------
;* nos = number of seconds
;*--------------------------

was      macro  nos
         local  loop

         push   ax
         push   bx
         push   cx
         push   dx
         mov    ah,44                  ; get current time
         int    33                     ; dos call
         mov    bh,dh                  ; get seconds
         add    bh,nos                 ; add requested seconds
         cmp    bh,60                  ; check for max seconds
         jl     loop                   ; if lo, loop
         sub    bh,60                  ; adjust seconds
loop:
         mov    ah,44                  ; get current time
         int    33                     ; dos call
         cmp    bh,dh                  ; requested delay complete ?
         jne    loop
         pop    dx
         pop    cx
         pop    bx
         pop    ax
         endm

;*------------------
;*   end of macros
;*------------------

;*-------------
;*   equates
;*-------------

z        equ   0             ; zero
mci      equ   32            ; max characters in
mco      equ   78            ; max characters out
mfs      equ   32000         ; max file size

;*---------------------------
;   definition of cmd line
;*---------------------------

         org   128

pl       db    0             ; parm len
         db    0             ; space
amt      db    0             ; amt ( of copies )
         db    0
fn       db    70 dup (0)    ; file name

;*------------------------
;   start of pgm
;*------------------------

         org   256

go:

         jmp   prt

;*-----------------------
;    data declarations
;*-----------------------

fpm      db    ' * PRTing '
fpnc     db    'x'
         db    ' copies of '
fnv      db    50 dup (' ')
         db    '$'

fnto     db    50 dup (0)

cpm      db    ' * printing copy '
cpmv     db    '  '
         db    13,10,10
         db    '$'

sm       db    13,10,10,10,' * PRT syntax : prt n xxx.xxx'
         db    13,10,' * where n = 1 - 9, and xxx.xxx = text file name'
         db    13,10,10,'$'

fh       dw    0             ; file handle
scx      dw    0             ; save cx
abr      dw    0             ; actual bytes read
filenlo  dw    0             ; file len lo
filenhi  dw    0             ; file len hi
cfc      db    1             ; current file cnt
cba      dw    z             ; current buffer address
pih      db    mci dup (0)   ; passed input hold
ih       db    mci dup (0)   ; input hold
oh       db    mco dup (0)   ; output hold

;*--------------------
;   error messages
;*--------------------

npem     db    13,10,10,' * PRT Error - no parameters ! * $'
plem     db    13,10,10,' * PRT Error - invalid parameter length ( no file name ? ) * $'
ofem     db    13,10,10,' * PRT Error - while opening file ! * $'
rfem     db    13,10,10,' * PRT Error - while reading file ! * $'
ftlem    db    13,10,10,' * PRT Error - File Too Large ( max size = 32000 bytes ) ! * $'

em      db     13,10,10,' * error code = '
emv     db     '12'
        db     ' * $'

sdx     dw     z

;*----------------------------
;*   cursor color work areas
;*----------------------------
row      db    z                       ; row
col      db    z                       ; column
attr     db    z                       ; attribute
char     db    z                       ; character
len      dw    z                       ; length

scos     db    z                       ; save cols on scrn
sac      db    z                       ; save ascii character
sca      db    z                       ; save character attribute
sadp     db    z                       ; save active display page
srow     db    z                       ; save row
scol     db    z                       ; save column
sdm      db    z                       ; save display mode
scbc     db    z                       ; save current border color
stcsl    db    z                       ; save the cursor start line
stcel    db    z                       ; save the cursor end line
strcx    db    z                       ; save the row called x
stccy    db    z                       ; save the col called y

;*-----------------------------
;* color display memory values
;*-----------------------------

vbcf     db    z                       ; video board color flag
dma      dw    z                       ; display memory address
mdmba    dw    0b000h                  ; mono display memory base address
cdmba    dw    0b800h                  ; color   "       "    base address

;*--------------------
;   start of code
;*--------------------

prt:

         cmp   pl,0          ; no parm
         je    em1           ; if so, err 1 exit

         cmp  pl,2           ; 1 digit + space ?
         jng  em2            ; if not, err 2 exit

;
;   get file name and count for display
;

         lea   si,fn         ; ptr to srs
         lea   di,fnv        ; ptr to dest
         mov   cl,pl         ; parm len
         mov   ch,0          ; clr hi byte
         sub   cx,3          ; adjust len
         cld
         rep   movsb         ; move it
         mov   al,amt        ; get amt
         mov   fpnc,al       ; to msg

;
;   move requested file name to open asciiz area
;

         lea   si,fn         ; ptr to srs
         lea   di,fnto       ; ptr to dest
         mov   cl,pl         ; parm len
         mov   ch,0          ; clr hi byte
         sub   cx,3          ; adjust len
         cld
         rep   movsb         ; move it

         jmp   pod           ; process one digit

;
;   error routines
;

em1:

         lea  dx,npem        ; no parm err msg
         jmp  pmcex          ; and exit

em2:

         lea  dx,plem        ; parm len err msg
         jmp  pmcex          ; and exit

em3:

         lea  dx,ofem        ; open file err msg
         jmp  pmcex          ; and exit

em4:

         lea  dx,rfem        ; read file err msg
         jmp  pmcex          ; and exit

emtl:

         lea  dx,ftlem       ; file too large err msg
         jmp  pmcex          ; and exit

;
;   process one digit
;

pod:

         cld                 ; forward
         lea   si,amt        ; ptr to amt
         lodsb               ; put it in al
         and   al,15         ; make ascii binary
         mov   ch,0          ; clear ch
         mov   cl,al         ; mov al to cl

;
;        validate amt between 1 - 9
;

         cmp   cl,1          ; amt = 1 ?
         jl    ma1           ; if LT, make amt 1

         cmp   cl,9          ; amt = 9 ?
         jg    ma1           ; if GT, make amt 1

         jmp   sc            ; ok, carry on

;
;  make amt 1
;

ma1:

         mov   cl,1          ; set copy amt to 1

;
;   save cx
;

sc:

         mov   scx,cx        ; save copy amt

         oaif  fnto,0        ; open the text file

         jc    em3j          ; if carry  set, err
         mov   fh,ax         ; save file handle

;
;   check if file size too large
;

         mfpffs fh,0,0,2

         cmp   filenhi,0     ; MSH vs 0
         ja    emtlj         ; if GT, err
         cmp   filenlo,mfs   ; LSH vs 32000
         ja    emtlj         ; if GT, err

         caf   fh            ; close file
         oaif  fnto,0        ; open it again

         raf   fh,fia,mfs    ; read the text file

         jc   em4j           ; if carry set, err
         jmp   pf            ; carry on

;
;   error jumps
;

emtlj:   jmp   emtl
em3j:    jmp   em3
em4j:    jmp   em4

pf:

         mov   abr,ax        ; save actual byte read

         scp   5,5           ; row 5, col 5
         lea   dx,fpm        ; ptr to msg
         call  dasts         ; display a string to scrn

;
;   number of copies loop
;

nocl:

         mov   al,cfc        ; get current file cnt
         mov   bl,2          ; len of ascii str
         lea   si,cpmv       ; ptr to ascii str
         call  cbbtas        ; convert what is in al to ascii

         scp   8,5           ; row 8, col 5
         lea   dx,cpm        ; ptr to msg
         call  dasts         ; display a string to scrn
         add   cfc,1         ; add 1 to current file cnt

         call  tof           ; top of form

         lea   si,fia        ; ptr to file input area
         mov   cx,abr        ; set cnt to actual bytes read
         cld                 ; forward

;
;   prt out loop
;

pol:

         lodsb               ; get a byte
         mov   dl,al         ; and send it
         mov   ah,5          ; to prtr
         int   33
         loop  pol           ; abr times

         call  cr            ; CR
         call  lf            ; LF

         mov   cx,scx        ; get copies cnt
         cmp   cx,1          ; 1 ?
         je    pmcx          ; if so, thru
         dec   cx            ; cnt - 1
         mov   scx,cx        ; save it again
         jmp   nocl          ; do it again

;
;   normal exit
;

pmcx:

         call  tof           ; top of form

pmcxe:
         caf   fh            ; close the file
         mov   al,0          ; set cond code to 0
         mov   ah,76         ; exit
         int   33

;
;   error exit
;

pmcex:

         mov   sdx,dx
         call  chta
         mov   emv,dh
         mov   emv+1,dl

         mov   dx,sdx
         call  dasts         ; display passed string to scrn

         lea   dx,em
         call  dasts         ; display err code

         lea   dx,sm         ; ptr to syntax msg
         call  dasts         ; display it

         was   5             ; wait 5 seconds
         jmp   pmcxe         ; and exit

;
;    Top of Form
;

tof      proc  near
         mov   dl,12
         mov   ah,5
         int   33
         ret
tof      endp

;
;   Line Feed
;

lf       proc  near
         mov   dl,10
         mov   ah,5
         int   33
         ret
lf       endp

;
;   Carriage Return
;

cr       proc  near
         mov   dl,13
         mov   ah,5
         int   33
         ret
cr       endp

;
;   Display A String To Screen
;

dasts    proc  near
         mov   ah,9
         int   33
         ret
dasts    endp

;
;   Convert Binary Byte to Ascii String
;
;    before call set :
;
;      al = binary number
;      bl = length of output field
;      si = pointer to output field
;

cbbtas   proc  near
         push  cx
         mov   cl,10
         sub   bl,1
         mov   bh,0
         add   si,bx

cbtasl:
         cmp   al,0010
         jb    cbtasx
         sub   ah,ah
         div   cl
         or    ah,48
         mov   [si],ah
         dec   si
         jmp   cbtasl

cbtasx:
         or    al,48
         mov   [si],al
         pop   cx
         ret
cbbtas   endp


;*--------------------------------------
;* convert hex to ascii ( 1 byte )
;*--------------------------------------
;* byte to be converted is passed in al
;* the hi nibble is passed back in dh
;* the lo nibble is passed back in dl
;*--------------------------------------

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

;*-----------------------
mcr3     proc  near
;*-----------------------
;*  move cursor right 3
;*-----------------------

         push  cx
         gcp   row,col
         add   col,3
         scp   row,col
         pop   cx
         ret

mcr3     endp

;*------------------------------
;*     lmts.prc
;*------------------------------
;*   list msg to screen
;*------------------------------
;*   terminated by final zero
;*   or max 512 bytes
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
;   file input area
;

fia      db    0

code     ends

         end   go