page ,132
title crsr ( cursor - set off or on ) - as of 05/14/96 - 06:05 pm
;
;   this program either turns off the cursor
;   ( after saving the first and last line values )
;   ( in the space occupied by an empty interrupt address, )
;   ( such as user interrupts ( UI ) 60h thru 66h )
;
;   or turns it back on
;   ( using the first and last line values previously stored ) -
;
;   this program will check UI 60h thru 66h for you,
;   and if it finds one of them empty,
;   then it will act on the passed parameter -
;
;   if all of these UI's are being used, then this program will put out a
;   message stating such, and terminate -
;
;   crsr syntax :
;
;   crsr       ( default = turn cursor off )
;   crsr off   ( turns cursor off )
;   crsr on    ( turns cursor on  )
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
;*------------------------------------
lm       macro msg
;*------------------------------------
;*  list message
;*------------------------------------
         lea   ax,msg
         call  lmts
         endm
;
;*--------------------------
;*   macro pool end
;*--------------------------
;
         .model small
         .code
;
;  equate(s)
;
eva      equ   60h                     ; empty vector address
;
;   parm area
;
         org   128
;
pl       db    0                       ; parm len ( includes space )
         db    0                       ; space
o        db    0                       ; 'o'
nof      db    0                       ; 'n' or 'f'
;
;  starting address of com program
;
         org   256
;
crsr:
         jmp   go
;
;   data section
;
         align 2
;
voo      dw    0                       ; vector original offset
vos      dw    0                       ; vector original segment
;
doeva    label word                    ; dummy offset
stcsl    db    0                       ; save the crsr start line
stcel    db    0                       ; save the crsr end line
;
uva      db    0                       ; used vector address
evaf     db    0                       ; eva flag
spp      db    0                       ; save passed parameter
spl      db    0                       ; save parm len
;
nevm     db    13,10,10
         db    ' * no empty vectors in the group 60h thru 66h - sorry ! '
         db    13,10,10
         db    ' * press any key for termination ! '
         db    13,10,10,0
;
rr       db    0                       ; reg reply
;
;  code section
;
go:
;
         mov   al,nof                  ; save
         mov   spp,al                  ; passed parm
;
         mov   al,pl                   ; save
         mov   spl,al                  ; parm len
;
         mov   uva,eva                 ; set used vector address
;
         call  chkeva                  ; call check empty vector address
;
         cmp   evaf,0                  ; is one of the UI's empty ? )
         je    ccl                     ; if so, chk cmd line
         jmp   nev                     ; else, give up
;
;   check command line
;
ccl:
         cmp   spl,0                   ; parm len = 0 ?
         je    joff                    ; if so, default
;
;  check passed parameters
;
         cmp   spp,'f'                 ; off ?
         je    joff
         cmp   spp,'n'                 ; on ?
         je    jon
         jmp   joff                    ; if neither, take default
;
;   jumps
;
joff:     jmp   crsroff
jon:      jmp   crsron
;
;   check empty vector
;
chkeva   proc  near
;
         mov   evaf,0                  ; clear flag
chkeval:
         mov   ah,35h
         mov   al,uva                  ; used vector address
         int   21h
         mov   vos,es                  ; get segment
;
         cmp   vos,0                   ; empty ?
         jne   chkevan                 ; if not, try next entry
         ret                           ; else, ok exit
;
;   next
;
chkevan:
         add   uva,1                   ; bump to next
         cmp   uva,66h                 ; end ?
         ja    chkevaee                ; if above, error exit
         jmp   chkeval                 ; try again
;
;   chkeva err exit
;
chkevaee:
         mov   evaf,1                  ; set flag
         ret                           ; err exit
;
chkeva   endp
;
;   no empty vectors
;
nev:
         lm    nevm                    ; display msg
         dci   rr                      ; wait for keypress
         jmp   getout                  ; exit program
;
;   cursor off entrance
;
crsroff:
;
;   save cursor lines and turn off cursor
;
         csrsv                         ; crsr save
         csroff                        ; crsr off
;
;   save cursor lines in proper int address
;
         mov   ah,25h
         mov   al,uva                  ; used vector address
         mov   dx,doeva                ; ptr to stcsl and stcel
         push  ds                      ; save ds
         mov   bx,0                    ; clear
         mov   ds,bx                   ; ds
         int   21h
         pop   ds                      ; restore ds
;
         jmp   getout                  ; exit
;
;   cursor on entrance
;
crsron:
;
         mov   ah,35h
         mov   al,uva                  ; used vector address
         int   21h
         cmp   bx,0
         jne   gsas
         mov   bx,0706h                ; end line - start line
gsas:
         mov   doeva,bx                ; get stcsl and stcel
;
         csron                         ; crsr on
;
;   reset vector address ( reset proper int address to 0 )
;
         mov   ah,25h
         mov   al,uva                  ; used vector address
         mov   dx,0                    ; clear dx
         push  ds                      ; save ds
         mov   bx,0                    ; clear
         mov   ds,bx                   ; ds
         int   21h
         pop   ds                      ; restore ds
;
;    exit
;
getout:
         mov   al,0                    ; set cond code to 0
         mov   ah,76                   ; exit
         int   33
;
;*------------------------------
;*     lmts.prc
;*------------------------------
;
;*------------------------------
;*   list msg to screen
;*------------------------------
;
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
;*-----------------------
;*  end of lmts.prc
;*-----------------------
;
         end   crsr