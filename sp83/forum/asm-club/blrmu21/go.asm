page ,132
title go ( chg to drv and dir ) as of 05/08/96 - 04:25 pm
;*-------------------------------------------------
;
;        Go ( chg to drv and dir )
;
;        syntax :
;                 go x ddddddddd
;
;        where x = new drv, and d = directory name
;
;        or       go x:
;
;        where x = new drv, and : = root
;
;*-------------------------------------------------
;
;        same as TO except changes NO colors !
;
;*-------------------------------------------------

;*------------------------------
;*   change current directory
;*------------------------------

ccd      macro path

         lea   dx,path
         mov   ah,59
         int   33

         endm

;*-------------------
;*   write a file
;*-------------------

waf      macro handle,buffer,bytecnt

         mov   bx,handle
         mov   cx,bytecnt
         lea   dx,buffer
         mov   ah,64
         int   33

         endm

;*--------------------------------------
code     segment para public 'code'
;*--------------------------------------

         assume  cs:code,ds:code,es:code

;*------------------
;*   cmd line map
;*------------------

         org   128


pl       db    0                       ; parm len ( includes space )
         db    0                       ; space
drv      db    0                       ; x
         db    0                       ; space
dir      db    50 dup (0)              ; directory name

;*--------------------------------------
;*   start of program memory location
;*--------------------------------------

         org   256

;*---------------------
;*   pgm starts here
;*---------------------

go:
         jmp   pcl           ; jump around data

;*-------------------------
;*   data is stored here
;*-------------------------

ml       equ   3                       ; min limit

dpdm     db    ' * dir / path = '
dpd      db    0                       ; dir path drv
         db    ':\'
dpn      db    50 dup (0)              ; dir path name
         db    13,10,10
dpdml    equ   $-dpdm

sm1      db    13,10,10
         db    '  syntax :'
         db    13,10
sm1l     equ   $-sm1

sm2      db    '  to x ddddddddd'
         db    13,10
sm2l     equ   $-sm2

sm3      db    '  where x = new drv, and d = directory name'
         db    13,10
sm3l     equ   $-sm3

sm4      db    '  OR '
         db    13,10
         db    '  to x:'
         db    13,10
sm4l     equ   $-sm4

sm5      db    '  where x = new drv, and : = root'
         db    13,10
sm5l     equ   $-sm5

sm6      db    '  [  NOTE :  x must be "a - k"  ]'
         db    13,10
sm6l     equ   $-sm6

;
;  error messages
;

cdem     db    13,10,10
         db    ' * change directory error ! '
         db    13,10,10
cdeml    equ   $-cdem

dpem     db    ' * drv / path = '
dpev     db    53 dup (0)
         db    13,10,10
dpeml    equ   $-dpem

epem     db    ' * error code = '
epev     db    '  '
         db    ' * parm len = '
eplv     db    '  '
         db    13,10,10
epeml    equ   $-epem

cll      db    13,10,10                ; cr, lf, lf
spl      db    0                       ; save parm len
rr       db    ' '                     ; reg reply

;*--------------------------
;*   process command line
;*--------------------------

pcl:
         cmp   pl,0          ; parm len = 0 ?
         je    jtsx          ; if so, exit
         cmp   pl,ml         ; min limit ?
         jb    jtsx          ; if LT, get out
         mov   al,pl         ; save
         mov   spl,al        ; parm len
         jmp   gdl

jtsx:

         waf   1,sm1,sm1l
         waf   1,sm2,sm2l
         waf   1,sm3,sm3l
         waf   1,sm4,sm4l
         waf   1,sm5,sm5l
         waf   1,sm6,sm6l
         jmp   sx

;*-----------------------
;*   get drive letter
;*-----------------------

gdl:

         cmp   drv,65        ; check for bottom limit ( A )
         jb    jtsx          ; if LT, exit
         mov   al,drv        ; move drv ltr
         mov   dpd,al        ; to dir path
         call  stnd          ; set the new drv

;*-----------------------------
;*   get the name for ch dir
;*-----------------------------

         lea   si,dir        ; ptr to sors
         lea   di,dpn        ; ptr to dest
         mov   cl,spl        ; get len
         sub   cl,ml         ; adjust for extra chars
         sub   ch,ch         ; clear hi byte
         cld                 ; set direction flag to forward
         rep   movsb         ; move sors to dest
         mov   al,0          ; set extra
         mov   [di],al       ; null char at end

;*---------------------------------
;*   get the name for err display
;*---------------------------------

         lea   si,dpd        ; ptr to sors
         lea   di,dpev       ; ptr to dest
         mov   cl,spl        ; get len
         sub   ch,ch         ; clear hi byte
         cld                 ; set direction flag to forward
         rep   movsb         ; move sors to dest
         mov   al,0          ; set extra
         mov   [di],al       ; null char at end

;*-------------------
;*   do the ch dir
;*-------------------

         ccd   dpev          ; change directory
         jc    dem
         jmp   sx

;*----------------------------
;*   display error messages
;*----------------------------

dem:

         mov   bx,2          ; len of field for ax contents
         lea   si,epev       ; ptr to field
         call  cbwtas        ; convert it

         mov   al,spl        ; saved parm len
         mov   ah,0          ; clear hi byte
         mov   bx,2          ; len of field for spl contents
         lea   si,eplv       ; ptr to field
         call  cbwtas        ; convert it

         waf   1,cdem,cdeml  ; ch dir err msg
         waf   1,dpem,dpeml  ; drv / path err msg
         waf   1,dpdm,dpdml  ; real drv / path
         waf   1,epem,epeml  ; error code msg
         waf   1,cll,3       ; cr, lf, lf

         mov   al,1          ; set ret code to 1
         mov   ah,76         ; term with ret code
         int   33

sx:

         waf   1,cll,3       ; cr, lf, lf

         mov   al,0          ; set ret code = 0
         mov   ah,76         ; term with ret code
         int   33

;*--------------------
;*   set the new drv
;*--------------------

stnd     proc  near

         mov   dl,al         ; get drv ltr
         sub   dl,65         ; adjust it   ( 65 = A )
         cmp   dl,10         ; hi limit ?  ( K )
         jbe   doit          ; if LT/EQ, ok, was upper case
         sub   dl,32         ; adjust it again, was lower case letter
doit:
         mov   ah,14         ; select
         int   33            ; disk
         ret                 ; return

stnd     endp

;*---------------------------------------
;*   convert binary word to ascii string
;*---------------------------------------
;*  before call set :
;*
;* ax = binary number
;* bx = length of output field
;* si = pointer to output field
;*---------------------------------------

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

code     ends

         end   go