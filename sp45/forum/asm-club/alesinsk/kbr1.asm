 JUMPS
 SMART
 LOCALS
CtrlHited	= 	04h
CapsLocked	=	40h
RLT        	=	(794Ch XOR 7C90h) ; Rus/Lat switch for indicating
					; and checking
LAT		=	4Ch
FIRST_RECODED	=	21h		; First recoded char
ParmLenPos	=	80h		; Position of parmstring
					; length in PSP
ParmsStart 	= 	81h		; Position of parmstring in PSP
OldStyleLoad	=	02h		; Old style loader request
Minimized	=	01h		; Signal about performed minimization
ifndef	micro
RESETED_VECTORS	=	3
else
RESETED_VECTORS	=	2
endif

CODE SEGMENT
     ASSUME CS:CODE

start_loc label byte
Flags db 0	; This byte contain following flags: CtrlHited in 5th bit,
		; request for old style loader in 6th bit.
		; signal about performed minimization in 7th (rightmost) bit
		; And bits 0-2 (three leftmost bits) contains offset of
		; interrupt vectors segment part from program memory
		; control block (in paragraphs)
ifndef micro
clock db 14
Cyrillic  dw 794Ch
INT08 LABEL BYTE
	dec	cs:clock
	db    	0EAh
old8o	dw	0
old8s	dw	0
	iret
else
Cyrillic equ Flags
RLT	 =   08h
endif
INT09 LABEL BYTE
	cli
	push	ax
	push	bx
	push	ds
	xor	bx,bx
	mov	ds,bx
	mov	ah,ds:417h
	pushf
	db	9Ah
old9o	dw	0
old9s	dw	0
	cli
	mov	al,ds:417h
	push	cs
	pop	ds
     ASSUME DS:CODE
;	lea	bx,Flags	; Because offset of Flags is 0 this line
				; are replaced with xor instruction
	xor	bx,bx
	and	ax,0404h
	cmp	ah,al
	ja	ax0400
	je	fut2
	or	byte ptr [bx],CtrlHited
	jmp	short bye
ax0400: test	byte ptr [bx],CtrlHited
	jz	fut2
ifndef	micro
	xor	word ptr [bx+offset Cyrillic - offset Flags],RLT
	call	indicate
else
	xor	byte ptr [bx],RLT
endif
fut2:	and	byte ptr [bx],not CtrlHited
bye:	pop	ds
	pop	bx
	pop	ax
	iret
     ASSUME DS:NOTHING
INT16 LABEL BYTE
	sti	; Необходимо, так как int запрещает прерывания, а возврат
		; будет по retf, который этот флаг не изменяет
	pushf
ifndef	micro
	test	clock,' ' ; indication requested (each 32 ticks)
	jz	noind
	and	clock,NOT ' ' ; clear indication request
	call	indicate
noind:
endif
	test	ah,0EEh
	jz	func1
	popf
	db	0EAh
old16 label dword
old16o	dw	0
old16s	dw	0
func1:
	call	cs:[old16]
	pushf
ifndef	micro
	cmp	byte ptr Cyrillic,LAT
else
	test	Cyrillic,RLT
endif
	jz	bye116
; In previous versions next piece of code was a procedure named "translate"
	push	di
	push  	es
	push	cx
	lea	di,ORDTBL-FIRST_RECODED
	or	ah,ah
	jz	notrans
	cmp	ah,35h
	ja	notrans
	cmp	al,126
	ja	notrans
	cmp	al,32
	jbe	notrans
scan_saving0 label word
	nop			; Space for mov ch,ah
	nop			;
	xor	ah,ah
	add	di,ax
	mov	al,cs:[di]
scan_saving1 label word
	nop			; Space for mov ah,ch
	nop
	xor	di,di
	mov	es,di
	test	byte ptr es:417h,CapsLocked
	jz	notrans
	push	cs
	pop	es
	lea	di,CPSTBL
	mov	cx,(install-CPSTBL)/2
	repne	scasb
	jnz	notrans
	mov	al,es:[di+(install - CPSTBL)/2 - 1]
notrans:
	pop	cx
	pop	es
	pop	di
; end of translation
bye116:
	popf
	retf	2
;translate proc near
;	ret
; Moved inline
;translate endp
ORDTBL label byte
	db     '1Э3457э90'
   	db	'8+б-ю/)!"#'
	db	'$:,.;(ЖжБ='
	db	'Ю?2ФИСВУАП'
	db	'РШОЛДЬТЩЗЙ'
	db	'КЫЕГМЦЧНЯх'
	db	'\ъ6_`фисву'
	db	'апршолдьтщ'
	db	'зйкыегмцчн'
	db	'яХ|Ъ~'
CPSTBL label byte
	db	'ХЪЖЭБЮхъжэбю'
	db	'хъжэбюХЪЖЭБЮ'
ifndef micro
indicate proc near
ind_lbl	label	byte
	push	ax
	push	bx
	push	cx
	push	dx
	mov	ah,0Fh
	int	10h
	sub	ah,3
	mov	bl,ah
	mov	ah,03h
	int	10h
	push	cx
	push	dx
	xor	cx,cx
	mov	ah,01h
	int	10h
	mov	dh,ch
	mov	dl,bl
	mov	ah,02h
	int	10h
	mov	ax,Cyrillic
	mov	bl,ah
	mov	ah,09h
	mov	cx,1
	int	10h
	pop	dx
	mov	ah,02h
	int	10h
	pop	cx
	mov	ah,01h
	int	10h
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret
indicate endp
endif
install:
	mov	bx,(end_loc-start_loc+15)/16
	mov	ah,4Ah
	int	21h
	lea	sp,end_loc
	push    es
; Check interrupt vectors 08h, 09h ,16h - for each vector
; its offset part and contents of first pointed word are checked
ifndef	micro
        mov     al,08h
	lea	di,INT08
	call	chk_vect
	mov	old8o,bx
	mov	old8s,es
endif
	mov	al,09h
	lea	di,INT09
	call	chk_vect
	mov	old9o,bx
	mov	old9s,es
	mov	al,16h
	lea	di,INT16
	call	chk_vect
	mov	old16o,bx
	mov	old16s,es
	pop	es
	; If founded_vects=0 no previously loaded copies assumed,
	; if founded_vects=3 previously loaded copy assumed with
	; no interrupt vectors re-captured. Else previously loaded
	; copy assumed with some re-captured vectors.
	cmp     founded_vects,0
	jz      cmd_chk
	lea     dx,previous_found
	call    inform
; Check command line
cmd_chk:
	xor     cx,cx
	mov	cl,ds:ParmLenPos
	mov	di,ParmsStart
	mov	al,' '
next_parm:
	jcxz    chk_load
	cld
	repe	scasb
        jz      chk_load
        cmp     byte ptr [di-1],'/'
	jnz	bad_par		;Parameters mast have leading slash
	call	chk_parm	; After chk_parm di point onto first
				; space after parameter, al contains
				; space and cx respectlivly decramented
	jmp	next_parm
chk_load:
	lea	dx,not_loaded
	cmp	founded_vects,0
	jz	load
	cmp	parms_count,0
	jz	exit
	mov	ax,4C00h
	int	21h
load:
; Check DOS version to choose allocation method
	test	Flags,OldStyleLoad
	jnz	old_loader
	mov	ah,30h
	int	21h
	xchg	ah,al
	cmp	ah,03h
	jb	old_loader
	cmp	ah,05h
	jae	DOS5_loader
	cmp	ax,031Fh		; DOS 3.31 is reported by
					; DR-DOS 5.0 and 6.0,
	   				; but they really are the DOS5 case
	jnz	new_loader
	mov	ax,4302h	; Function which exist in DR-DOS only
	push	cs
	pop	ds
	lea	dx,stack_space	; ds:dx points zero and is an empty filename
	int	21h
	cmp	ax,0Fh
	jb	new_loader	; MS-DOS return 1 or 3 				; but some additional precautions is good thing
	jmp	DOS5_loader	; DR-DOS 5.0 or 6.0
old_loader:
	mov	ax,cs
	mov	ds,ax
	sub	ax,0Ah
	mov	es,ax
	call	common_loader
ifndef	micro
	mov	cs:word ptr report_size,'84'
	mov	cs:byte ptr report_size+2,'0'
	test	ds:Flags,Minimized
	jz	offset6_set
	mov	cs:word ptr report_size,'03'
	mov	cs:byte ptr report_size+2,'4'
else
	mov	cs:word ptr report_size,'82'
	mov	cs:byte ptr report_size+2,'8'
endif
offset6_set:
	or	es:Flags,6 shl 5; Set in first fourth bits of Flags offset in
				; paragraphs program resident portion from its
				; memory control block (MCB) end
	mov	ax,cs
	sub	ax,10h
	mov	es,ax
        mov	es,es:2Ch	; Set es to segment address of program's
				; environment
        mov	ah,49h		; Free environment
	int	21h
	lea	dx,initialized
        call	inform
	mov	dx,resident_size
	add	dx,6
	mov	ax,3100h
	int	21h
exit:   call   inform
        mov    ax,4c01h
        int    21h
bad_par:
        lea	dx,invalid_parm
        jmp	exit
new_loader:
	call	new_common
	mov	ax,4C00h
	int	21h
Dos5_Loader:
	mov	ax,5802h
	int	21h
	push	ax		; Save strategy
	mov	ax,5800h
	int	21h
	push	ax		; Save UMB link state
	mov	bx,ax
	or	bx,8000h
	mov	ax,5801h
	int	21h
	jc	call_loader
	mov	ax,5803h
	mov	bx,1
	int	21h
call_loader:
	call	new_common
	pop	bx
	mov	ax,5801h
	int	21h
	pop	bx
	mov	ax,5803h
	int	21h
	mov	ax,4C00h
	int	21h

inform proc near
; ds:dx point output string
	push	ds
	push	cs
	pop	ds
	mov	ax,0900h
	int	21h
	pop	ds
	ret
inform	endp

chk_vect proc near
; On entry vector number in al, required vector offset in di
; On exit old vector in es:bx
	mov	ah,35h
	int	21h
	cmp	di,bx
	jnz	@@invalid_vect
	mov	di,cs:[di]
	cmp	di,es:[bx]
	jnz	@@invalid_vect
	inc	founded_vects
	mov	founded_seg,es
@@invalid_vect:
	ret
founded_seg	dw CODE
founded_vects	db 0
chk_vect endp

chk_parm proc near
; On entry di point on first parameter byte after slash
; and al contains space
	mov	ah,[di]
	or	ah,' '		; convert ah to lower case
	cmp	ah,'x'		; remove requested ?
	jnz	@@spar
	call	unload
@@spar:	cmp	ah,'s'		; saving of scan codes requested ?
	jnz	@@cpar
	call	save_scan
	jmp	@@par_Ok
@@cpar:	cmp	ah,'c'		; clearing of scan codes requested ?
	jnz	@@lpar
	call	clear_scan
	jmp	@@par_Ok
@@lpar:	cmp	ah,'l'		; Loading of keyboard layout requested ?
ifndef	micro
	jnz	@@mpar
else
	jnz	@@hpar
endif
	call	load_layout
	jmp	@@par_Ok
ifndef	micro
@@mpar:	cmp	ah,'m'		; Mini-version requested ?
	jnz	@@hpar
	call	mini_version
	jmp	@@par_Ok
endif
@@hpar: cmp	ah,'h'		; Help output
	jnz	@@opar
	lea	dx,help
	jmp	exit
	jmp	@@par_Ok
@@opar:	cmp	ah,'o'		; Request on old style loading registration
	jnz	@@qmpar
	cmp	founded_vects,0
	jz	@@cont
	lea	dx,only_first_time
	jmp	exit
@@cont:	or	Flags,OldStyleLoad
	jmp	@@par_Ok
@@qmpar:			; Help_output
	cmp	ah,'?'
	jnz	bad_par
	lea	dx,help
	jmp	exit
@@par_Ok:
	inc	di
	dec	cx
	mov	al,' '
	inc	parms_count
	ret
parms_count db	0
chk_parm endp

unload proc near
	cmp	founded_vects,RESETED_VECTORS
	jz	@@unloading
	lea	dx,not_unloaded
	jmp	exit
@@unloading:
	mov	es,founded_seg
	mov	ax,2516h
	lds	dx,dword ptr es:old16o
	int	21h
	mov	al,09h
	lds	dx,dword ptr es:old9o
	int	21h
	mov	al,08h
ifndef	micro
	lds	dx,dword ptr es:old8o
	int	21h
endif
	mov	ax,es
	xor	bh,bh
	mov	bl,es:Flags
	shr	bl,5		; Now in bl offset in paragraphs of resident
				; KBR1 code from its MCB
	sub	ax,bx
	dec	ax
	mov	es,ax		; For DR-DOS
	mov	es:1,cs
	inc	ax
	mov	es,ax
	mov	ah,49h
	int	21h
        jnc	@@succes
        lea	dx,not_unloaded
        jmp	@@un_inf
@@succes:
        lea    dx,unloaded
	call   inform
        mov    ax,4c00h
        int    21h
@@un_inf:
        jmp    exit
unload endp

save_scan proc near
	mov	scan_saving0,0EC8Ah	; 0EC8A -> mov ch,ah
	mov	scan_saving1,0E58Ah     ; 0E58A -> mov ah,ch
	lea	dx,scan_save
	call	inform
	ret
save_scan endp

clear_scan proc near
	mov	scan_saving0,9090h	; 9090h= nop,nop
	mov	scan_saving1,9090h
	lea	dx,scan_clea
	call	inform
	ret
clear_scan endp

load_layout proc near
; On entry al=' ', di point on byte exactly before pathname
	inc	di
	mov 	dx,di
	mov	si,di
@@next_char:
	dec	cx
	lodsb
	cmp	al,' '
	jz	@@break
	cmp	al,'/'
	jz	@@break
	jcxz	@@break
	jmp	@@next_char
@@break:
	mov	di,si
	mov	bl,al
	mov	ax,3D20h		; File open with Deny Write and
					; read acess
	mov	byte ptr [di-1],0
	int	21h
	jnc	@@success
	lea	dx,layout_err
	jmp	exit
@@success:
	mov	[di-1],bl
	mov	bx,ax
	mov	ax,4202h		; Go to end of the file to obtain its
	push	cx			; length
	xor	cx,cx
	mov	dx,cx
	int	21h
	jnc	@@succ1
@@err_with_close:
	lea	dx,layout_err
@@close_exit:
	mov	ah,3Eh
	int	21h
	jmp	exit
@@succ1:
	or	dx,dx
	jnz	@@inv_length
	cmp	ax,install-ORDTBL
	jz	@@succ2
@@inv_length:
	lea	dx,invalid_layout
	jmp	@@close_exit
@@succ2:
	push	ax
	mov	dx,cx
	mov	ax,4200h		; Goto beginning of file
	int	21h
	jc	@@err_with_close
	pop	cx
	lea	dx,ORDTBL
	push	ds
	mov	ds,founded_seg
	mov	ah,3Fh
	int	21h
	jc	@@err_with_close
	mov	ah,3Eh
	int	21h
	lea	dx,lay_loaded
	call	inform
	pop	ds
	pop	cx
	inc	cx			; Because decremented at the end
					; of chk_parm
	dec	di			; Same reasons
	dec	di
	ret
load_layout endp

common_loader proc near
	xor	si,si
	mov	di,si
        mov	cx,(install-start_loc+1)/2
	cld
	rep movsw
	push	es
	pop	ds
        cli
ifndef	micro
	lea	dx,INT08
        mov	ax,2508h
        int	21h
endif
        lea	dx,INT09
        mov	ax,2509h
	int	21h
        lea	dx,INT16
        mov	ax,2516h
        int	21h
        sti
	ret
common_loader endp

new_common proc near
	mov	ax,5800h	; Obtain memory allocation strategy
	int	21h
	jc	old_loader
	push	ax		; Store current strategy for future restoring
	not	al
	and	ax,8002h	; FirstFit and BestFit are converted to LastFit
	mov	bx,ax		; LastFit are converted to FirstFit
	mov	ax,5801h
	int	21h
	mov	bx,resident_size
	mov	ah,48h
	int	21h
	jc	old_loader
	mov	es,ax
	push	ax
	push	cs
	pop	ds
	call	common_loader
ifndef	micro
	test	ds:Flags,Minimized
	jz	offset0_set
	mov	cs:word ptr report_size,'33'
	mov	cs:byte ptr report_size+2,'6'
else
	mov	cs:word ptr report_size,'82'
	mov	cs:byte ptr report_size+2,'8'
endif
offset0_set:
;	or	es:Flags,0 shr 5; Set in first fourth bits of Flags offset in
				; paragraphs program resident portion from its
				; memory control block (MCB) end,
				; it is already 0, so command is commented
	pop	ax
	dec	ax
	mov	ds,ax
	mov	word ptr ds:1,8
	mov	ax,5801h
	pop	bx		; Restory initial strategy. This is superflous
				; because really restore it to default while
				; programm exit. But Microsoft strongly require
	int	21h		; restoring by programmer in its documentation.
	lea	dx,initialized
        call	inform
	ret
new_common endp

ifndef	micro
mini_version proc near
	cmp	founded_vects,0
	jz	@@set_mini
	push	es
	mov	es,founded_seg
	mov	al,ret_lbl
	mov	es:ind_lbl,al
	mov	bl,es:0
	shr	bl,5		; TASM translate into sequence of shr bl,1
	xor	bh,bh
	mov	ax,es
	sub	ax,bx
	push	ax
	mov	es,ax
	add	bx,(indicate-start_loc)/16+1
	mov	ah,4Ah
	int	21h
	pop	ax
	dec	ax
	mov	es,ax
	mov	word ptr es:1,8
	lea	dx,resident_minimized
	call	inform
	pop	es
ret_lbl	label	byte
	ret
@@set_mini:
	mov	resident_size,(indicate-start_loc)/16+1
	mov	al,ret_lbl
	mov	ind_lbl,al
	or	Flags,Minimized		; Set minimization flag
	ret
mini_version endp
endif

initialized  db  '╔════════════════════════════════════════════════════╗',10,13
             db  '║ Программа KBR1 (Russian keyboard) v.7.0 загружена  ║',10,13
             db  '║ Занято резидентно всего '
report_size  db  '384 байт !                 ║',10,13
             db  '║ Переключатель РУС/LAT- Ctrl (LeftCtrl)             ║',10,13
             db  '║ Введите KBR1 /x для выгрузки драйвера              ║',10,13
             db  '║ или KBR1 /? для получения помощи                   ║',10,13
             db  '║ Разработал А.И. Алесинский                         ║',10,13
             db  '║ по мотивам А.В. Козлова (В мире ПК,1988,2)         ║',10,13
             db  '║ FreeWare. Харьков, 05.04.92. т.8(057-2)22-73-43    ║',10,13
             db  '╚════════════════════════════════════════════════════╝',10,13,'$'
invalid_parm db  'Недопустимый параметр - ничего, /?, /h, /c, /lpathname, /m,'
             db  ' /o или /x',7,10,13,'$'
not_unloaded db  'Выгрузить невозможно - KBR1 не найдена',10,13
             db  'или прерывания перехвачены',7,10,13,'$'
unloaded     db  'Программа KBR1 выгружена',10,13,'$'
previous_found db 'В памяти найдена предыдущая копия программы',10,13,'$'
not_loaded   db  'Новая копия не загружается',7,10,13,'$'
scan_clea    db  'Cкэн-коды у русских букв очищаются',10,13,'$'
scan_save    db  'Cкэн-коды у русских букв сохраняются',10,13,'$'
lay_loaded    db  'Загружена новая раскладка',10,13,'$'
invalid_layout db 'Hеверная длина файла раскладки',7,10,13,'$'
layout_err   db  'Ошибка при открытии или обработке файла раскладки',7,10,13,'$'
only_first_time db 'Параметр /o применим только при загрузке'
resident_minimized db 'Резидентная часть минимизирована - индикация отброшена'
	     db  10,13,'$'
help         db  'KBR1 v.7.0',10,13
	     db  ' Вызов без параметров - загрузить'
	     db  ' и установить очистку скэн-кодов',10,13
	     db  'Параметры -',10,13
	     db  ' /?, /h - выдать этот экран',10,13
	     db  ' /c - установить очистку скэн-кодов у русских букв',10,13
	     db  ' /s - установить сохранение скэн-кодов у русских букв',10,13
	     db  ' /lpathname - загрузить раскладку из файла pathname',10,13
	     db  ' /m - минимальная резидентная часть (индикация отсутствует)',10,13
	     db  ' /o - загрузка старым способом',10,13
	     db  ' /x - выгрузить программу',10,13
	     db  'Параметры воздействуют на активную копию программы,',10,13
	     db  'а если ее нет, то на вновь загружаемую',10,13,'$'
resident_size dw  (install-start_loc+15)/16
stack_space   dw  40 dup(0)
end_loc	label byte
CODE ENDS
END install
