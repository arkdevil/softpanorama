PAGE ,131
TITLE Cyrillic Keyboard Driver KEYBUR.COM, Copyright (c) 1991

CTRL               	equ     1Dh	; Коды клавиш
ALT                	equ     38h
L_CTRL_CTRL_BRK    	equ     1D9Dh
R_CTRL_BRK         	equ     0E09Dh
R_ALT_BRK          	equ     0E0B8h 

BIOS_DATA_SEG      	equ     40h	; Переменные BIOS
BIOS_KBD_BUF_HEAD  	equ     1Ah
BIOS_KBD_BUF_TAIL  	equ     1Ch
BIOS_KBD_STATUS    	equ     17h

LATINIC       		equ     0	; Статус драйвера
RUSSIAN       		equ     3
UKRAINIAN     		equ     1

CALL_FAR		equ     9Ah	; Коды команд
JMP_FAR			equ	0EAh
ALPHA_SHIFTS		equ	3	; Маска Shift'ов


key_seg       	segment                   
		assume  cs:key_seg 
		org     100h	

start:        	jmp     install		; На инсталяционный код

state         	db      LATINIC		; Статус драйвера
border		db	0		; Статус бордера
savescan      	label   word		; Очередь последних скан-кодов
save1         	db      0		
save2         	db      0
save3         	db      0

; Таблицы перекодировки

rtable        	db      ' !Э',0FCh,';:.э()*+б-ю/0123456789ЖжБ=Ю?"ФИСВУАПРШОЛДЬТЩ'
		db      'ЗЙКЫЕГМЦЧНЯх',0F1h,"ъ,_'фисвуапршолдьтщзйкыегмцчняХ",0F0h,'Ъ~'

rcpstable     	db      ' !э',0FCh,';:.Э()*+Б-Ю/0123456789жЖб=ю?"ФИСВУАПРШОЛДЬТЩ'
		db      'ЗЙКЫЕГМЦЧНЯХ',0F0h,"Ъ,_'фисвуапршолдьтщзйкыегмцчнях",0F1h,'ъ~'

utable        	db      ' !',0F2h,0FCh,';:.',0F3h,'()*+б-ю/0123456789ЖжБ=Ю?"ФИСВУАПРШОЛДЬТЩ'
		db      'ЗЙКЫЕГМЦЧНЯх',0F5h,"i,_'фисвуапршолдьтщзйкыегмцчняХ",0F4h,'I~'

ucpstable     	db      ' !',0F3h,0FCh,';:.',0F2h,'()*+Б-Ю/0123456789жЖб=ю?"ФИСВУАПРШОЛДЬТЩ'
		db      'ЗЙКЫЕГМЦЧНЯХ',0F4h,"I,_'фисвуапршолдьтщзйкыегмцчнях",0F5h,'i~'


; Обработчик "железного" прерывания от клавиатуры
int09         	proc    far
		push    ax
		push    bx
		push    ds

		mov     ax, BIOS_DATA_SEG
		mov     ds, ax

		cli

		in      al, 60h		; Прочитать скан-код

		mov     ah, cs:save2	; Продвинуть очередь
		mov     cs:save3, ah
		mov     ah, cs:save1
		mov     cs:savescan, ax
		cmp     cs:save3, CTRL	; Проверяем, не была ли нажата
		jne     testr_alt_brk          

		cmp     ax, R_CTRL_BRK	; и отпущена правая клавиша Ctrl
		jne     testr_alt_brk          
		mov     cs:state, RUSSIAN
		jmp     short found
       
testr_alt_brk:  cmp     cs:save3, ALT	; Проверяем, не была ли нажата
		jne     testl_ctrl_brk        
		cmp     ax, R_ALT_BRK	; и отпущена правая клавиша Alt
		jne     testl_ctrl_brk        
		mov     cs:state, UKRAINIAN     
		jmp     short found

testl_ctrl_brk: cmp     ax, L_CTRL_CTRL_BRK 	; Проверяем, не была ли нажата
		jne     found        	; и отпущена левая клавиша Ctrl
		mov     cs:state, LATINIC     

found:        	pushf			; Передаем управление BIOS
		db      CALL_FAR
old09offs     	dw      0
old09seg      	dw      0

		cmp     cs:state, LATINIC 	; Если нужно, производим перекодировку	
		jnz     translation

		pop     ds		
		pop     bx
		pop     ax
		iret

translation:   	mov     bx, BIOS_KBD_BUF_HEAD
		mov     bx, [bx]
		mov     ax, BIOS_KBD_BUF_TAIL
		cmp     bx, ax
		jz      done

		mov     ax, [bx]
		push    bx
		cmp     ax, 2368h
		jnz     normtrans

		mov     word ptr [bx], 0E0h
		pop     bx
		jmp     short done

normtrans:    	cmp     ah, 35h
		ja      notrans

		cmp     ah, 1
		jbe     notrans

		cmp     al, 20h
		jbe     notrans

		cmp     al, 7Fh
		jae     notrans

		cmp     cs:state, UKRAINIAN
		jz      ukr  
		
		mov     bx, BIOS_KBD_STATUS
		mov     bl, [bx]
		test    bl, 40h
		jz      rusnorm
		lea     bx, rcpstable
		jmp     short dotrans
rusnorm:      	lea     bx, rtable
		jmp     short dotrans
		
ukr:          	mov     bx, BIOS_KBD_STATUS
		mov     bl, [bx]

		test    bl, 40h

		jz      ukrnorm
		lea     bx, ucpstable
		jmp     short dotrans
ukrnorm:      	lea     bx, utable

dotrans:      	sub     al, 20h
		add     bl, al
		adc     bh, 0
		mov     al, cs:[bx]
		xor     ah, ah
notrans:        pop     bx
		mov     [bx], ax

done:		mov	bx, BIOS_KBD_STATUS	; Если нажат какой-нибудь Shift
		test	byte ptr [bx], ALPHA_SHIFTS	; отображаем информацию
		jnz	show			; о статусе драйвера на бордере

		cmp	border, 0
		je	exit

		xor	bh, bh
		mov	ax, 1001h
		int	10h
		mov	border, 0
		jmp	short exit

show:		mov	bh, state
		cmp	bh, border
		je	exit
		mov	ax, 1001h
		int	10h
		mov	border, bh
		
exit:		pop     ds
		pop     bx
		pop     ax
		iret

int09         	endp


; Обработчик программного прерывания клавиатуры
int16         	proc    far
		cmp     ah, 2
		jb      spec
		db      JMP_FAR
old16         	label  	dword
old16offs     	dw      0
old16seg      	dw      0

spec:         	pushf
		call    [old16]
		pushf
		or      ax, ax
		jnz     notrans2
		mov     ax, 00E0h
notrans2:     	popf
		ret	2
int16         	endp


; Инсталляционный код
install:      	mov     ax, BIOS_DATA_SEG
		mov     ds, ax
		xor     bx, bx
		and     byte ptr [bx+BIOS_KBD_STATUS],0DFh	; Гасим Num Lock

		mov     ax, cs
		mov     ds, ax 
    
		mov     ax, 3516h	; Простенькая проверка, установлен ли
		int     21h      	; наш драйвер

		cmp     bx, offset int16	
		jz      already

		mov     old16offs, bx	; Цепляемся к цепочке обработки 
		mov     old16seg, es 	; прерывания 16h

		lea     dx, int16
		mov     ax, 2516h       
		int     21h            

		mov     ax, 3509h	; Цепляемся к цепочке обработки
		int     21h            	; прерывания 9h

		mov     old09offs, bx
		mov     old09seg, es 

		lea     dx, int09
		mov     ax, 2509h
		int     21h            

		lea     dx, keymsg	; Заявляем о себе
		mov     bx, 2           
		mov     ax, 4000h       
		mov     cx, offset keymsgend
		sub     cx, dx          
		int     21h            

		lea     dx, install	; Остаемся резидентными
		mov     cl, 4           
		shr     dx, cl          
		inc     dx             
		mov     ax, 3100h       
		int     21h            

already:      	lea     dx, errmsg	; Напоминаем о себе
		mov     bx, 2           
		mov     ax, 4000h    
		mov     cx, offset errmsgend
		sub     cx, dx       
		int     21h         

		mov     ax, 4C01h
		int     21h         

keymsg        	db      'The Cyrillic Keyboard Driver for Ukrainian Republic ',0Dh,0Ah
		db      'Version 3.2 Copyright (c) 1991, Oleg P. Pilipenko',10,13
keymsgend:

errmsg        	db      7,'KEYBUR is already loaded.',10,13
		db      'Hit Right Ctrl for Russian, Right Alt for Ukrainian, Left Ctrl for Latinic',0Dh,0Ah
errmsgend:

key_seg       	ends
		end     start
