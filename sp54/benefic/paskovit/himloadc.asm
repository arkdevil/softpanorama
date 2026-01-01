name    HiMemLoadCOM
		.radix	16
codseg		segment
		assume	cs:codseg, ds:codseg, ss:codseg
		org	100
start:
		jmp	beg
;----------------------------------------------------------------------
psphi		equ	0ffff
ip_hi		equ	100

mess		db	0a,0dh,0c9,45d dup (0cdh),0bbh,0a,0dh,0ba
		db	'  HiMem Load Com TSR  by Paskovaty A.O. 1992 '
		db	0ba,0a,0dh,0ba
		db	'  ph. (095) 467-9568 : modem Contact-Between '
		db	0ba,0a,0dh,0c7
		db	45d dup (0c4),0b6,0a,0dh,0ba
		db	' >himloadc nameTSR[.com] [/keys]             '
		db	0ba,0a,0dh,0c8
		db	45d dup (0cdh),0bc,0a,0dh, 0
nofil		db	0a,0dh,'ERR! TSR file is not found.',0a,0dh,0
nohimem		db	0a,0dh,'ERR! HIMEM is not installed.',0a,0dh,0
nomem		db	0a,0dh,'ERR! HIMEM is occupied.',0a,0dh,0
hrdwr		db	0a,0dh,'ERR! A20 hardware error.',0a,0dh,0
okhi		db	0a,0dh,'OK! TSR has been installed in HIMEM.',0a,0dh,0
com		db	'.COM'
v27ofs		dw	?		; буфер 27 вектора
v27seg		dw	?
v21		dd	?		; буфер 21 вектора
hndl		dw	?		; описатель файла .COM
drhiofs		dw	?		; адрес драйвера HiMem
drhiseg		dw	?
flag		db	0		; флаг загрузки TSR
;----------------------------------------------------------------------
beg:
		cld
		xor	cx,cx
		mov	di,80		; проверить наличие аргумента
		add	cl,[di]		; вызова грузила
		jnz	$20
$10:
		mov	bx,offset mess
		jmp	exit
$20:
		inc	di
		mov	al,' '
		repe	scasb		; пропустить мусор в аргументе
		jcxz	$10
		inc	cx
		mov	si,di
		dec	si
		mov	di,offset bufer
		push	cx		; перепись имени TSR
		xor	bx,bx		; признак наличия расширения
$30:
		lodsb
		cmp	al,' '		; начало аргумента
		je	$60
		cmp	al,'/'		; TSR-программы ?
		je	$60
		cmp	al,'a'
		jb	$40
		and	al,0df		; прописные буквы имени файла
		jmp	short $50
$40:
		cmp	al,'.'
		jne	$50
		mov	bx,di		; запомнить начало расширения
$50:
		stosb
		loop	$30
$60:
		pop	dx		; исходная длина аргументов
		sub	dx,cx		; длина имени файла
		mov	bp,cx		; длина оставшейся части строки
		push	si		; адрес оставшейся части
		mov	si,offset com
		mov	cx,4
		or	bx,bx
		jz	$70
		mov	di,bx		; анализ расширения, если есть
		repe	cmpsb
		jcxz	$80
		jmp	short $90
$70:
		add	dx,cx
		rep	movsb		; или дописывание, если нет его
$80:
		push	dx		; запомнить длину имени файла
		mov	ax,3d00		; открыть файл
		stosb			; обнуление конца аргумента
		mov	dx,offset bufer
		int	21
		jnc	$100
$90:
		mov	bx,offset nofil	; файл не найден или не .COM
		jmp	exit
$100:
		mov	hndl,ax		; запомнить описатель
		mov	si,dx
		mov	ax,4300		; проверить наличие
		int	2f		; HiMem
		cmp	al,80
		je	$110
		mov	bx,offset nohimem	; сообщение об отсутствии
		jmp	clsexit
$110:
		mov	ax,4310
		int	2f
		mov	drhiofs,bx	; адрес драйвера HiMem
		mov	drhiseg,es
		mov	ah,1
		mov	dx,-1		; получить память
		call	dword ptr drhiofs
		dec	ax		; ok ?
		jz	$120
		mov	bx,offset nomem	; нет - память занята
		jmp	clsexit
$120:
		mov	ah,3		; разрешить работать с ней
		call	dword ptr drhiofs
		dec	ax		; ok ?
		jz	$130
		mov	ah,2		; нет - освободить память
		call	dword ptr drhiofs
		mov	bx,offset hrdwr	; сообщение об ошибке
		jmp	clsexit
$130:
		mov	ax,ds:[2c]	; environment
		dec	ax
		mov	es,ax		; MCB environment
		mov	es:[1],psphi	; новый владелец
		mov	di,10
		mov	cx,-1
		xor	ax,ax
$140:
		repne	scasb		; найти начало строки вызова
		scasb			; (нулевое слово)
		jnz	$140
		inc	di		; пропустить резервное слово
		inc	di
		repne	scasb		; найти конец строки вызова
		std
		mov	al,'\'
		repne	scasb		; найти path
		cld
		inc	di
		inc	di
		pop	cx		; восстановить длину имени
		inc	cx		; переписать в environment
		rep	movsb		; новую "строку вызова"
		mov	bx,hndl
		mov	dx,offset bufer
		mov	cx,-1		; прочитать файл в буфер
		mov	ah,3f		; (Dos почему-то нервничает при
		int	21		; попытке прочитать сразу в HiMem)
		mov	cx,ax		; размер файла
		mov	si,dx
		mov	di,ip_hi
		mov	ax,psphi
		mov	es,ax
		rep	movsb		; переписать в HiMem
		mov	cx,100
		xor	si,si		; переписать в HiMem PSP, насколько
		mov	di,si		; это возможно (без 1-го параграфа)
		rep	movsb
		mov	di,80		; заполнить PSP аргументом
		mov	cx,bp		; его размер
		pop	si		; и адрес
		jcxz    $150		; нулевой ?
		mov	al,cl		; нет - записать размер
		stosb
		inc	cx
		dec	si
		rep	movsb		; и переписать сам аргумент
		jmp	short $160
$150:
		mov	ax,0d00		; аргумента нет
		stosw
$160:
		mov	ax,3527
		int	21
		mov	v27ofs,bx	; перехватить пути установа
		mov	v27seg,es	; TSR - 27 вектор и 31 функцию
		mov	dx,offset v27pnt
		mov	ax,2527		; для корректного возврата в Dos
		int	21
		mov	ax,3521
		int	21
		mov	word ptr v21,bx
		mov	word ptr [v21+2],es
		mov	dx,offset v21pnt
		mov	ax,2521
		int	21
		mov	bx,offset okhi	; сообщение o'key
		inc	flag		; флаг перехода на do_it
clsexit:
		push	bx
		mov	bx,hndl
		mov	ah,3e		; закрыть файл
		int	21
		pop	bx
exit:
		call	types		; нарисовать сообщение
		mov	ax,4c00
		cmp	flag,al		; флаг ?
		jnz	do_it
		int	21
do_it:
		mov	ax,psphi
		cli
		mov	ds,ax		; установка сегментных регистров
		mov	es,ax
		mov	ss,ax
		mov	sp,0fffe	; инициализация стека
		xor	ax,ax
		push	ax
		sti
	db	0ea			; jmp 0ffff:100
	dw	ip_hi, psphi
;----------------------------------------------------------------------
v21pnt:
		cmp	ah,31
		je	v27pnt
		jmp	cs:[v21]
v27pnt:
		push	cs
		pop	ds
		mov	ax,3521
		int	21
		mov	ax,es
		cmp	ax,psphi	; анализ обработчика Dos
		je	$180
$170:
		push	ds		; TSR Dos не перехватывал -
		lds	dx,v21
		mov	ax,2521		; смело восстанавливать
		int	21
		pop	ds
		jmp	short $200
$180:
		mov	di,10		; Dos function перехвачен злодеем
		mov	cx,-1		; прийдётся искать: куды он подевал
		mov	ax,offset v21pnt
		mov	bx,cs		; мой обработчик
		cld
$190:
		repne	scasb
		jcxz	$170
		cmp	es:[di],ah
		jne	$190
		cmp	es:[di+1],bx	; offset поймали, а как segment ?
		jne	$190
		dec	di
		mov	si,offset v21	; ну слава богу, попался
		movsw			; восстанавливаем в его буфере
		movsw			; обработчик Dos function
$200:
		lds	dx,dword ptr v27ofs
		mov	ax,2527
		int	21		; восстанавливаем int 27
		mov	ax,4c00
		int	21
;----------------------------------------------------------------------
types		proc	near
		mov	ah,0e
$210:
		mov	al,[bx]
		or	al,al
		jne	$220
		ret
$220:
		push	bx
		mov	bx,7
		int	10
		pop	bx
		inc	bx
		jmp	short $210
types		endp
;----------------------------------------------------------------------
bufer:
codseg		ends
		end	start
