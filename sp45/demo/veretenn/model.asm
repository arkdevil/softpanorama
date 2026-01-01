
        extrn       get85time:far,      setnextcall:far, linkwithdbg:far
        extrn       set85interrupt:far, adjustmodel:far, retdbg:far

        assume      cs:code,ds:data

data	segment	public
daylight db	0		;	признак день/ночь
symw	db	?		;	текущий выводимый символ
data	ends

code    segment

startpoint:                     ;       Выполнение начнется отсюда
	mov	ax,data
	mov	ds,ax
        mov     ax,offset OUT_model
        push    cs
        push    ax
        mov     ax,offset IN_model
        push    cs
        push    ax
        mov     ax,offset DAT_model
        push    cs
        push    ax
        mov     ax,offset CLK_model
        push    cs
        push    ax		;	параметры для adjustmodel занесены
        call    adjustmodel	;	передача адресов отладчику
	xor	cx,cx
	mov	dh,24
	mov	dl,79
	mov	bh,07H
	xor	al,al
	mov	ah,6
	int	10H		;	очистить экран
        call    linkwithdbg	;	выход в отладчик


IN_model proc far
        push    bp		;	ввод только из порта 0, поэтому
        mov     bp,sp           ;       номер порта не проверяется
        push    word ptr daylight;	засылка значения освещенности
        call    retdbg		;	возврат в отладчик
IN_model endp

OUT_model proc far
        push    bp
        mov     bp,sp
	cmp	byte ptr [bp+6],0;	проверка выводимого данного на ноль
	jz	ms0
	mov	symw,'▒'	;	не ноль - свлючить свет
	jmp	short mc0
ms0:	mov	symw,' '	;	ноль - выключить
mc0:	cmp	byte ptr [bp+8],1;	номер порта - 1 ?
	jne	p2
	xor	bh,bh
	mov	dh,10
	mov	dl,32
	mov	ah,2
	int	10H		;	позиционировать курсор на первом окне
	jmp	short pane	;	вывести подготовленный символ
p2:	cmp	byte ptr [bp+8],2;	все то же самое для второго порта
	jne	p3
	xor	bh,bh
	mov	dh,10
	mov	dl,35
	mov	ah,2
	int	10H
	jmp	short pane
p3:	cmp	byte ptr [bp+8],3	;	третьего
	jne	p4
	xor	bh,bh
	mov	dh,12
	mov	dl,32
	mov	ah,2
	int	10H
	jmp	short pane
p4:	cmp	byte ptr [bp+8],4	;	четвертого
	jne	pno
	xor	bh,bh
	mov	dh,12
	mov	dl,35
	mov	ah,2
	int	10H
pane:	mov	cx,1
	xor	bh,bh
	mov	al,symw
	mov	ah,0AH
	int	10H			;	вывод символа
pno:	pushf
        call    retdbg
OUT_model endp

DAT_model proc far
        push    bp
        mov     bp,sp
	not	daylight		;	инверсия значения освещенности
        pushf
        call    retdbg
DAT_model endp

CLK_model proc far
        push    bp
        mov     bp,sp
	xor	ax,ax			;	прерывание номер 0
        push    ax
	mov	ax,8			;	передать управление на адрес 8
        push    ax
        call    set85interrupt
        call    get85time		;	сколько времени (системного)
	add	ax,10000D		;	вызов через 10000 квантов
	adc	dx,0
        push    dx
        push    ax
        call    setnextcall
        pushf
        call    retdbg
CLK_model endp

code    ends

stak	segment	stack
	db 24 dup ('stack')
stak	ends

        end	startpoint
