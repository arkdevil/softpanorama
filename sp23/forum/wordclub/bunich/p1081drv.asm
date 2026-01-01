               page  60,132
;============================================================================
; Дpайвеp для пpинтеpа KX-P1081 и аналогичных
; Л.З.Альперович - Л.Г.Бунич (18.02.90) 
; (Альтернативная кодировка, 40 загружаемых кодов)
; Перед запуском дpайвеpа или после него надо загpузить
; шpифты киpиллицы с помощью программы PFONT8x9.exe.
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
tgr            db    "K",2,"L",2,"Y",2,"Z",2,"?",2,"*",3,"^",3

; Таблица перекодировки
alt_prn        label byte
;      0|8  1|9  2|a  3|b  4|c  5|d  6|e  7|f
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
   db   041h,081h,042h,083h,084h,045h,086h,033h; 8h
   db   088h,0FFh,04Bh,08Bh,04Dh,048h,04Fh,08Fh;
   db   050h,043h,054h,093h,094h,058h,096h,097h; 9h
   db   098h,099h,0FFh,0FFh,0FFh,09Dh,09Eh,09Fh;
   db   061h,0A1h,0A2h,0A3h,0A4h,065h,0A6h,0A7h; Ah
   db   0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,06Fh,06Eh;
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ; Bh
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ; Ch
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ; Dh
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;
   db   070h,063h,0E2h,079h,0E4h,078h,0E6h,0E7h; Eh
   db   0E8h,0E9h,0FFh,0EBh,0ECh,0EDh,0EEh,0EFh;
   db   0   ,089h,0   ,0   ,0   ,0   ,0   ,0   ; Fh
   db   0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ;

freesym db 27,122,0EAh                         ; освоб. 0EAh
addsym  label byte
   db  89h,27,121,0EAh, 7Eh,0,4,88h,10h,0A0h,0,7Eh,0  ; Й
   db  9Ah,27,121,0EAh, 80h,0,0FEh,0,12h,0,12h,0Ch,0  ; Ъ
   db  9Bh,27,121,0EAh, 0,0FEh,0,12h,0,12h,0Ch,0,0FEh ; Ы
   db  9Ch,27,121,0EAh, 0,0FEh,0,12h,0,12h,0,12h,0Ch  ; Ь
   db 0EAh,27,121,0EAh, 0,20h,0,3Eh,0,0Ah,0,0Ah,4     ; ъ
   db  00

;==========================================================================

intercept_prn_int proc far
	 cmp   dx,0
	 jne   cross
	 cmp   ah,0
	 je    pushs
cross:   jmp   fin
pushs:   push  ds
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
gdone:   mov   byte ptr ncc+1,al    ; ст. байт длины
	 jmp   short toout
nccchk:  cmp   ncc,0
	 je    ifesc
	 dec   ncc
	 jmp   short toout
ifesc:   cmp   old,1bh
	 jne   small
	 cmp   romram,"1"
	 jne   escpost
	 mov   romram,"0"           ; ESC отменяет кириллицу
escpost: mov   bl,al                ; анализ символа после ESC
	 cld
	 mov   cx,7
	 mov   si,offset tgr
tgrline: lodsb
	 cmp   al,bl                ; ESC устанавливает графический режим ?
	 je    grmode               ;   (да)
	 inc   si
	 loop  tgrline
	 mov   al,bl
	 cmp   al,"y"
	 jne   toout
	 mov   ncc,11
	 jmp   short toout
grmode:  mov   bl,byte ptr [si]    ; позиция счетчика байтов
	 mov   grc,bl
toout:   jmp   output
small:   cmp   al,3fh
	 jb    output
	 mov   bx,ax
	 mov   cl,alt_prn[bx]
	 cmp   cl,00                ; символ киpиллицы ?
	 je    lat                  ;   (нет)
         cmp   cl,0FFh
         jne   symdone
         mov   cx,3
         mov   si,offset freesym
         call  paddout
         mov   si,offset addsym
addloop: cmp   byte ptr 0[si],bl
         je    addout
         add   si,13
         cmp   byte ptr 0[si],00
         jne   addloop
addout:  mov   cx,12
         inc   si
         call  paddout
         mov   cl,0EAh
symdone: pop   ax
	 mov   al,cl
	 push  ax
	 cmp   romram,"1"           ; сейчас pежим киpиллицы ?
	 je    output               ;   (да)
	 mov   romram,"1"
	 jmp   output
lat:     mov   romram,"0"           ; pежим латиницы
output:  pop   ax
	 mov   old,al
	 pop   bx
	 pop   cx
	 pop   si
	 pop   ds
fin:     jmp   cs: rom_prn_int
intercept_prn_int endp

paddout  proc  near
extract: lodsb
         xor   ah,ah
         pushf
         call  rom_prn_int
         loop  extract
         ret
paddout  endp
;======================================================================
;  Инициация  вектора  прерывания.  Берет   стандартный   вектор   обработки
;  прерывания  от  клавиатуры (17h) и сравнивает адрес программы обработки с
;  адресом intercept_prn__int. Если адреса  совпали,  то  это  означает, что
;  программа драйвера ранее уже загружалась.  В этом случае происходит выход
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
ready_string   db    "KX-P1081 cyrillic printer driver "
               db    "has been installed", 0dh, 0ah, '$'
init_vectors   endp

code_seg  ends
          end   begin
