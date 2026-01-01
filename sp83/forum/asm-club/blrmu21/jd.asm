page ,132
title jd ( jump directory ) as of 05/05/96 - 01:30 am
;*-------------------------------------------------------
;*
;*   this program will Jump [to the specified] Directory
;*
;*   syntax :
;*             jd dirname
;*             jd x:
;*
;*   where  :
;*             dirname = directory name
;*             x: = root
;*
;*-------------------------------------------------------

;*-----------------
;*     macros
;*-----------------

;*------------------------------
ccd      macro path
;*------------------------------
;* change current directory
;*------------------------------

         lea   dx,path
         mov   ah,59
         dc
         endm

;*------------------------------
dc       macro
;*------------------------------
;* dos call
;*------------------------------
;* interrupt 21h = dos function
;* function id must be in ah
;* prior to call
;*------------------------------

         int   33
         endm

;*------------------------------
exit     macro
;*------------------------------
;* exit from DOS program
;*------------------------------

         mov   al,0
         mov   ah,76
         dc
         endm

;*------------------------------
lm       macro msg
;*------------------------------
;* list message
;* ( by calling lmts )
;*------------------------------

         lea   ax,msg
         call  lmts
         endm

;*------------------------------
mswl     macro dest,sors,len
;*------------------------------
;* move short with length
;-------------------------------
;* dest = destination of move
;* sors = source of move
;* len  = max length of move
;-------------------------------
;* len may be from 1 to 255
;* len must be db if variable
;*------------------------------

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

;*--------------------------------------
mtz      macro dest,sors,len
         local mtzl
         local mtzx
;*--------------------------------------
;* move to zero -
;* stops when binary zero is
;* encountered in the source
;*--------------------------------------
;* dest = destination of move
;* sors = source of move
;* len  = maximum move length
;*--------------------------------------
;* length may be from 1 to 65535
;* length must be dw if variable
;*--------------------------------------

         push  ax
         push  cx
         push  di
         push  si
         mov   cx,len
         lea   si,sors
         lea   di,dest
         cld
mtzl:
         lodsb
         cmp   al,0
         je    mtzx
         stosb
         loop  mtzl
mtzx:
         pop   si
         pop   di
         pop   cx
         pop   ax
         endm

;*------------------------------
pc       macro fld,len,char
;*------------------------------
;* propagate character
;*------------------------------
;* the area named 'fld',
;* for a length of 'len'
;* will be filled with 'char'
;*------------------------------

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

;*-------------------------------
sdta     macro buffer
;*-------------------------------
;*   set disk transfer address
;*-------------------------------

         lea   dx,buffer
         mov   ah,26
         dc
         endm

;*------------------------------
srdd     macro drvno
;*------------------------------
;*   select random disk drive
;*------------------------------

         mov   dl,drvno
         mov   ah,14
         dc
         endm

;*------------------------------
was      macro  nos
         local  loop
;*------------------------------
;* wait a sec
;*------------------------------
;* nos = number of seconds
;*------------------------------

         push   ax
         push   bx
         push   cx
         push   dx

         mov    ah,44                  ; get current time
         dc                            ; dos call

         mov    bh,dh                  ; get seconds
         add    bh,nos                 ; add requested seconds
         cmp    bh,60                  ; check for max seconds
         jl     loop                   ; if lo, loop
         sub    bh,60                  ; adjust seconds
loop:
         mov    ah,44                  ; get current time
         dc                            ; dos call

         cmp    bh,dh                  ; requested delay complete ?
         jne    loop
         pop    dx
         pop    cx
         pop    bx
         pop    ax
         endm

         .lall

;*----------------------
;*     end of macros
;*----------------------

         .model small

         .code

;*--------------------
;*   common equates
;*--------------------

z        equ   0                       ; zero
lf       equ   10                      ; line feed
cr       equ   13                      ; carriage return
mfn      equ   35                      ; max file name
mpn      equ   50                      ; max path name

;*-----------------------------
;*   starting address of PSP
;*-----------------------------

         org   128
pl       db    z                       ; parm len
         db    z
pdon     db    z                       ; passed drv or name
pdc      db    z                       ; passed drv colon

;*------------------------------------
;*   starting address of com program
;*------------------------------------

         org   256

jd:
         jmp   soc                     ; jump around data

;*-----------------
;*   data section
;*-----------------

ifnl     db    z                       ; input dir name len

clna     db    mpn dup (' ')           ; cmd line dir name area
         db    z

clnf     db    z                       ; cmd line name flag

dp       db    ' * dp * '              ; directory path
dpd      db    'X'                     ; dir path drv
         db    ':\'
dpn      db    mpn dup (0)             ; dir path name
         db    z

nmrf     db    z                       ; no more recs flag
dnff     db    z                       ; dir name fnd flag

fsm      db    ' * fsn = '             ; file search msg
fsn      db    'X'                     ; file search name
         db    ':'
         db    '*.*'
         db    z

rdm      db    ' * rdp = '             ; root dir msg
rdp      db    'X'                     ; root dir path
         db    ':\'
         db    z

dn       db    z                       ; drive #

rcdp     db    'c'                     ; reset current dir path
         db    ':\'
rcpn     db    22 dup (' ')            ; reset current path name
         db    z

scdp     db    64 dup (' ')            ; save current dir path
         db    z

sodn     db    z                       ; save old drv #

drvltr   db    'x'                     ; drive letter

crlf     db    cr,lf,z                 ; cr, lf
cll      db    cr,lf,lf,z              ; cr, lf, lf

sax      dw    z                       ; save ax

ceho     dw    z                       ; critical error handler offset
cehs     dw    z                       ; critical error handler segment

;*--------------
;*   messages
;*--------------

sem1     db    ' * JD error !',z
sem1a    db    ' * syntax = :',z
sem2     db    ' * JD dirname ',z
sem2a    db    ' * JD x:      ',z
sem2b    db    ' * where :    ',z
sem3     db    ' * dirname = name of directory to jump to ',z
sem3a    db    ' * x:      = root directory to jump to ',z

rdim     db    ' * requested drive / path invalid !',z

cdem     db    ' * change directory error !',z

dnnfm    db    ' * directory name not found !',z

dnm      db    ' * directory name = ',z

rdpm     db    ' * requested drv / path = ',z

rdpem    db    ' * root dir path error : ',z

cdpem    db    ' * current directory path error !',z

axm      db    ' * AX = '
axmv     db    '    ',z

;*-------------------------------
;*   directory entry area
;*-------------------------------

dea      db    21   dup (' ')          ; directory entry area
dfaf     db    0                       ;     "     file attr flags
dfct     dw    0                       ;     "     file create time
dfcd     dw    0                       ;     "     file create date
dfsl     dw    0                       ;     "     file size lo
dfsh     dw    0                       ;     "     file size hi
dfn      db    13   dup (' ')          ;     "     file name

;*----------------------
;*   code section
;*----------------------

soc:                                   ; start of code

;*-------------------------
;* check for cmd line name
;*-------------------------

         lea   si,pl                   ; get parm len address
         mov   cl,[si]                 ; get length of cmd line name
         mov   ch,0                    ; clear high byte
         cmp   cl,0                    ; cmd line name = 0 ?
         ja    mcln                    ; if GT, jmp to move cmd line name
         mov   clnf,0                  ; clear cmd line name flag,
         jmp   cfpn                    ; and jmp to chk for passed name

;*------------------------
;*   move cmd line name
;*------------------------

mcln:

         cmp   pdc,':'                 ; root  ?
         jne   mntclna                 ; if not, carry on
         mov   al,pdon                 ; move ascii
         mov   dpd,al                  ; drv ltr

         call  cadn                    ; call cnvrt ascii drv #
         cmp   al,255                  ; err ?
         jne   sdno                    ; if not, carry on
         jmp   dsm                     ; display syntax message

sdno:

         srdd  al                      ; set random dsk drv

         ccd   dpd                     ; ch dir
         jc    jtrdi                   ; if carry set, err exit
         jmp   rtd                     ; else, normal exit

jtrdi:   jmp   rdi                     ; requested drive invalid !

;*----------------------
;*   move name to clna
;*----------------------

mntclna:
         lea   si,pdon                 ; ptr to name
         lea   di,clna                 ; ptr to cmd line name area
         cld                           ; forward
         rep   movsb                   ; repeat move

         lea   si,pl                   ; get
         mov   bl,[si]                 ; real
         sub   bl,1                    ; name len
         mov   ifnl,bl                 ; and save it

;*--------------------------
;*   process cmd line name
;*--------------------------

         mov   clnf,1                  ; set cmd line name flag
         pc    dpn,mfn,0               ; clear name to x'0'
         mswl  dpn,clna,ifnl           ; move cmd line name

cfpn:                                  ; chk for passed name

         cmp   clnf,1                  ; name passed ?
         je    init                    ; if so, carry on
         jmp   dsm                     ; display syntax msg

init:

         call  iceh                    ; install critical error handler

         call  scdap                   ; save current drv and path

         mov   drvltr,'c'              ; drive ltr = 'c'
         mov   dn,2                    ; drive no  = 'c'

         sdta  dea                     ; set dsk transfer address

;*-----------------------
;*  start of search
;*-----------------------

sos:

         mov   al,drvltr               ; pass drv ltr
         mov   fsn,al                  ; to
         mov   rdp,al                  ; all
         mov   dpd,al                  ; needed places

;*---------------------
;*  set the new drv
;*---------------------

         srdd  dn                      ; set random dsk drv

;*---------------------------------
;*  set current directory to root
;*---------------------------------

         ccd   rdp                     ; chg current directory
         jnc   carryon                 ; if ok, carry on

         cmp   ax,3                    ; path not found ?
         je    jtrnnf                  ; if so, dir not fnd msg

         cmp   ax,15                   ; invalid disk drive ?
         je    jtrnnf                  ; if so, dir not fnd msg

         cmp   ax,21                   ; drive not ready ?
         je    jtrnnf                  ; if so, dir not fnd msg

         mov   sax,ax                  ; save err code
         jmp   rdpe                    ; root dir/path err

jtrnnf:

         jmp   rnnf

carryon:

         mov   dnff,0                  ; clear
         mov   nmrf,0                  ; flags
         mov   sax,0                   ; clr save ax

         call  sfd                     ; search for directory

chdir:

         ccd   dpd                     ; ch dir
         jnc   jtrtd                   ; if carry not set, exit

         cmp   ax,3                    ; path not found ?
         je    nxtdir                  ; if so, try next directory

         cmp   ax,15                   ; invalid disk drive ?
         je    rnnf                    ; if so, drv invalid

         cmp   ax,21                   ; drive not ready ?
         je    rnnf                    ; if so, dir not fnd msg

         mov   sax,ax                  ; save err code
         jmp   dcdem                   ; and chg dir err msg

jtrtd:

         jmp   rtd                     ; jmp to ret to dos

nxtdir:

         inc   drvltr                  ; incr drv ltr
         inc   dn                      ; incr drv #
         jmp   sos                     ; try next drive

;*---------------------------
;* requested drive invalid
;*---------------------------

rdi:
         lm    crlf                    ; cr, lf
         lm    rdim                    ; requested drive invalid msg
         lm    crlf
         lm    rdpm                    ; root dir path msg
         lm    dpd                     ; path name
         lm    crlf
         jmp   rtd                     ; exit

;*---------------------------
;* requested name not found
;*---------------------------

rnnf:
         lm    crlf                    ; cr, lf
         lm    dnnfm                   ; dir name not fnd msg
         lm    crlf
         lm    dnm                     ; dir name msg
         lm    dpn                     ; dir path name
         lm    crlf
         jmp   rtde                    ; err exit

;*-------------------------
;* display syntax message
;*-------------------------

dsm:
         lm    crlf                    ; cr, lf
         lm    sem1                    ; syntax err msg 1
         lm    crlf                    ;
         lm    sem1a                   ; syntax err msg 1a
         lm    crlf
         lm    sem2                    ; syntax err msg 2
         lm    crlf
         lm    sem2a                   ; syntax err msg 2a
         lm    crlf
         lm    sem2b                   ; syntax err msg 2b
         lm    crlf
         lm    sem3                    ; synatx err msg 3
         lm    crlf
         lm    sem3a                   ; synatx err msg 3a
         lm    crlf
         was   5                       ; wait 5 secs
         jmp   rtd                     ; exit

;*---------------------------
;* root dir path error
;*---------------------------

rdpe:
         lm    crlf                    ; cr, lf
         lm    rdpem                   ; root dir path err msg
         lm    crlf
         lm    rdpm                    ; root dir path msg
         lm    dp                      ; path name
         lm    crlf
         lm    fsm                     ; file search msg
         lm    crlf
         lm    rdm                     ; root dir msg
         call  faxfm                   ; display AX
         lm    crlf
         lm    axm                     ; display AX msg
         jmp   rtde                    ; err exit

;*-------------------------
;* display ch dir err msg
;*-------------------------

dcdem:
         lm    crlf                    ; cr, lf
         lm    cdem                    ; ch dir err msg
         lm    crlf
         lm    rdpm                    ; root dir path msg
         lm    dp                      ; dir path
         lm    crlf
         lm    fsm                     ; file search msg
         lm    crlf
         lm    rdm                     ; root dir msg
         call  faxfm                   ; display AX
         lm    crlf
         lm    axm                     ; display AX msg
         jmp   rtde                    ; err exit

;*--------------------------
;*   return to DOS - error
;*--------------------------

rtde:
         call  rdap                    ; restore drive and path
         was   5                       ; wait 5 seconds

;*----------------------
;*   return to DOS
;*----------------------

rtd:

         call  rceh                    ; restore critical error handler

         exit                          ; standard exit

;*------------------------
;*   procedures
;*------------------------

;*-----------------------------
;*   convert ascii drv number
;*-----------------------------

cadn     proc  near

;*---------------------
;*   check lower case
;*---------------------

         cmp   al,122                  ; 'z' ?
         ja    cadnex                  ; if GT, err exit
         cmp   al,97                   ; 'a' ?
         jb    cfuc                    ; if LT, chk for upper case

         sub   al,97                   ; convert lower case
         ret                           ; exit

;*--------------------------
;*   check for upper case
;*--------------------------

cfuc:
         cmp   al,90                   ; 'Z' ?
         ja    cadnex                  ; if GT, err exit
         cmp   al,65                   ; 'A' ?
         jb    cadnex                  ; if LT, err exit

         sub   al,65                   ; convert upper case
         ret                           ; exit

cadnex:
         mov   al,255                  ; set err code
         ret                           ; exit

cadn     endp

;*----------------------------------------
;*   convert binary word to ascii string
;*----------------------------------------
;*  before call set :
;*
;* ax = binary number
;* bx = length of output field
;* si = pointer to output field
;*----------------------------------------

cbwtas   proc  near
         push  cx
         push  dx
         mov   cx,10
         sub   bx,1
         add   si,bx

cbtavsl:

         cmp   ax,0010
         jb    cbtavsx
         sub   dx,dx
         div   cx
         or    dl,48
         mov   [si],dl
         dec   si
         jmp   cbtavsl

cbtavsx:

         or    al,48
         mov   [si],al
         pop   dx
         pop   cx
         ret

cbwtas   endp

;*---------------------------
;*   critical error handler
;*---------------------------

ceh      proc

         mov   al,3                    ; set for 'fail'
         iret                          ; and return

ceh      endp

;*---------------------------
;*   check for names equal
;*---------------------------

cfne     proc  near

         lea   di,dfn                  ; ptr to found name
         lea   si,dpn                  ; ptr to passed name
         mov   ch,0                    ; clr hi byte
         mov   cl,ifnl                 ; get cmp len
         cld                           ; forward direction
         rep   cmpsb                   ; compare
         je    found                   ; if EQ, set dir name fnd flag
         ret                           ; return
found:
         mov   dnff,1                  ; set dir name fnd flag
         ret

cfne     endp

;*----------------------
;*   format AX for msg
;*----------------------

faxfm    proc  near

         mov   bx,4
         lea   si,axmv
         mov   ax,sax
         call  cbwtas
         ret

faxfm    endp

;*------------------------------------
;*   install critical error handler
;*------------------------------------

iceh     proc  near

         push  es                     ; save es

         mov   ax,3524h               ; get existing INT 24 vector
         int   33

         mov   ceho,bx                ; save offset
         mov   cehs,es                ; save seg

         pop   es                     ; restore es

         mov   ax,2524h               ; Set INT 24 vector
         lea   dx,ceh                 ; to point to 'ceh'
         int   33

         ret                          ; return

iceh     endp

;*-----------------------
;*   list msg to screen
;*-----------------------

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

;*-----------------------------------
;*   Restore critical error handler
;*-----------------------------------

rceh     proc

         push  ds                      ; save ds

         mov   ax,cehs                 ; get original
         mov   ds,ax                   ; segment
         mov   dx,ceho                 ; get original offset
         mov   ax,2524h                ; set original vector
         int   33

         pop   ds                      ; restore ds

         ret                           ; return

rceh     endp

;*--------------------------
;*  restore drive and path
;*--------------------------

rdap     proc  near
         push  ax
         push  dx

         srdd  sodn                    ; set random dsk drv

         ccd   rcdp                    ; chg current dir to saved dir/path

         pop   dx
         pop   ax
         ret
rdap     endp

;*-----------------------------------
;*  save current drive and path
;*-----------------------------------

scdap    proc  near
         push  ax
         push  bx
         push  cx
         push  dx
         push  si

         mov   ah,25                   ; get current drive function
         dc                            ; DOS call
         mov   dl,al                   ; save drive # for next step
         mov   sodn,al                 ; save drive # for reset
         add   al,65                   ; convert to alpha
         mov   rcdp,al                 ; move to reset current dir path
         pc    scdp,64,0               ; clear save current dir path
         mov   ah,71                   ; get current directory function
         add   dl,1                    ; adjust drive #
         lea   si,scdp                 ; point to save area
         dc                            ; DOS call
         jc    scdape                  ; if carry set, error
         pc    rcpn,22,0               ; clear reset current path name
         mtz   rcpn,scdp,22            ; move current path name to reset
         jmp   scdaprr
scdape:
         lea   ax,cll                  ; CR, LF, LF
         call  lmts                    ; list it
         lea   ax,cdpem                ; current dir path err msg
         call  lmts                    ; list it
scdaprr:
         pop   si
         pop   dx
         pop   cx
         pop   bx
         pop   ax
         ret
scdap    endp

;*------------------------
;* search for directory
;*------------------------

sfd      proc  near

         mov   cx,62                   ; all files
         lea   dx,rdp                  ; root dir path
         mov   ah,78                   ; find first file
         dc
         jnc   cfdr                    ; if no err, chk for dir rec

         mov   sax,ax                  ; save err code
         ret                           ; and return

;*-----------------------
;*   check for dir rec
;*-----------------------

cfdr:

         cmp   dfaf,16                 ; directory ?
         jne   fndr                    ; if not, keep searching

         call  cfne                    ; check passed name vs this name

         cmp   dnff,0                  ; NOT EQ ?
         je    fndr                    ; if so, try next
         ret                           ; return

;*----------------------
;*   find next dir rec
;*----------------------

fndr:

         mov   ah,79                   ; find next file
         dc
         jnc   cfdr                    ; if no err, try again
         cmp   ax,18                   ; no more recs ?
         je    nmrx                    ; if so, set that flag
         mov   sax,ax                  ; save err code

;*----------------------
;*   no more recs exit
;*----------------------

nmrx:

         mov   nmrf,1                  ; set no more recs flag
         ret

sfd      endp

;*------------------------
;*   end of procedures
;*------------------------

         end   jd