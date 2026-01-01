               page  60,132
;============================================================================
; Дpайвеp для пpинтеpа STAR NL-10 и аналогичных
; Л.З.Альперович - Л.Г.Бунич (18.02.90) 
; (Альтернативная кодировка)
; Перед запуском дpайвеpа или после него надо загpузить
; шpифты киpиллицы с помощью программы PFONT8xB.exe.
;============================================================================
code_seg       segment
               assume cs:code_seg, ds:code_seg
               org   100h

begin:         jmp   init_vectors

rom_handler_prn      label word
rom_prn_int    dd    ?
romram         db    "0"                ; киpиллица: "1"
old            db    00
ncc            dw    00
grc            db    00
tgr            db    "K",2,"L",2,"Y",2,"Z",2,"*",3,"^",3

; Таблица перекодировки
alt_prn        label byte
;       0|8  1|9  2|a  3|b  4|c  5|d  6|e  7|f
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ; 0h
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ; 1h
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ; 2h
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ; 3h
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ; 4h
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ; 5h
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ; 6h
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ; 7h
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;
   db   03fh,040h,041h,042h,043h,044h,045h,046h; 8h
   db   047h,048h,049h,04ah,04bh,04ch,04dh,04eh;
   db   04fh,050h,051h,052h,053h,054h,055h,056h; 9h
   db   057h,058h,059h,05ah,05bh,05ch,05dh,05eh;
   db   05fh,060h,061h,062h,063h,064h,065h,066h; ah
   db   067h,068h,069h,06ah,06bh,06ch,06dh,06eh;
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ; bh
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ; ch
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ; dh
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;
   db   06fh,070h,071h,072h,073h,074h,075h,076h; eh
   db   077h,078h,079h,07ah,07bh,07ch,07dh,07eh;
   db   0   ,089h,0   ,0   ,0   ,0   ,0   ,0   ; fh
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;

;==========================================================================
mm          macro k
            mov al,k
            xor ah,ah
            pushf
            call  rom_prn_int
            endm

intercept_prn_int proc far
            cmp   dx,0
            jne   cross
            cmp   ah,0
            je    pushs
cross:      jmp   fin
pushs:      push  ds
            push  si
            push  cx
            push  bx
                  push cs
                  pop  ds
            push  ax
            cmp   grc,0                ; графический режим ?
            je    nccchk               ;   (нет)
            dec   grc
            jz    gdone
            cmp   grc,1
            jne   toout
            mov   byte ptr ncc,al      ; мл. байт длины
            jmp   short toout
gdone:      mov   byte ptr ncc+1,al    ; ст. байт длины
            jmp   short toout
nccchk:     cmp   ncc,0
            je    ifesc
            dec   ncc
            jmp   short toout
ifesc:      cmp   old,1bh
            jne   small
            cmp   romram,"1"
            jne   escpost
            mov   romram,"0"           ; ESC отменяет кириллицу
            mm    25h
            mm    "0"
            mm    1bh
escpost:    mov   bl,al                ; анализ символа после ESC
            cld
            mov   cx,6
            mov   si,offset tgr
tgrline:    lodsb
            cmp   al,bl                ; ESC устанавливает графический режим ?
            je    grmode               ;   (да)
            inc   si
            loop  tgrline
            mov   al,bl
            cmp   al,"&"
            jne   toout
            mov   ncc,15
            jmp   short toout
grmode:     mov   bl,byte ptr [si]    ; позиция счетчика байтов
            mov   grc,bl
toout:      jmp   output
small:      cmp   al,3fh
            jb    output
            mov   bx,ax
            mov   cl,alt_prn[bx]
            cmp   cl,00                ; символ киpиллицы ?
            je    lat                  ;   (нет)
            pop   ax
            mov   al,cl
            push  ax
            cmp   romram,"1"           ; сейчас pежим киpиллицы ?
            je    output               ;   (да)
            mov   romram,"1"
            jmp   switch
lat:        cmp   romram,"1"           ; сейчас pежим киpиллицы ?
            jne   output               ;   (нет)
            mov   romram,"0"
switch:     mm    1bh                  ; пеpеключение pежима
            mm    25h
            mm    romram
            mm    00
output:     pop   ax
            mov   old,al
            pop   bx
            pop   cx
            pop   si
            pop   ds
fin:        jmp   cs: rom_prn_int
intercept_prn_int endp

;======================================================================
;  Инициация  вектора  прерывания.  Берет   стандартный   вектор   обработки
;  прерывания  от  клавиатуры (17h) и сравнивает адрес программы обработки с
;  адресом intercept_prn__int. Если адреса  совпали,  то  это  означает  что
;  программа NL10DRV ранее уже загружалась. В этом случае производится выход
;  в DOS по прерыванию 20. Если адреса не  совпали,  то  стандартный  вектор
;  обработки   прерывания  сохраняется,  а  вместо  него  загружается  адрес
;  программы intercept_prn_int.

init_vectors   proc  near
               push  cs
               pop   ds

               mov   ax,3517h
               int   21H

               cmp   bx,offset intercept_prn_int
               je    no_install

               mov   rom_handler_prn,bx
               mov   rom_handler_prn[2],es  ; whos es

               lea   dx,ready_string
               mov   ah,9
               int   21H

               mov   ax,2517h
               mov   dx,offset intercept_prn_int
               int   21H

               mov   dx, offset init_vectors+1
               int   27H
no_install:
               int   20H
ready_string   db    "STAR NL-10 cyrillic printer driver "
               db    "has been installed", 0dh, 0ah, '$'
init_vectors   endp

code_seg       ends
               end   begin
