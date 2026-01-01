; Автор: Блашкин И.И.
;
; Маленькая полезная программа, использует одну недокументированную
; функцию ADM. Позволяет записывать информацию на нулевую дорожку
; при установленном драйвере ADM.SYS. Но самое интересное заключается
; в том, что эта функция не возвращает информации о текущем состоянии 
; флага защиты. Этот флаг - булевская переменная и она переключается 
; при каждом выполнении этой спецфункции. При переходе On -> Off
; es:[di] указывет на строку "*MITAC-ADM*",а при переходе Off -> On
; содержимое этих регистровне изменяется. Другие регистры: AX = 0,
; флаги Z и P = 1, остальные не изменяются. Если драйвер ADM не 
; установлен, то возвращается код ошибки 01.
;
; Turbo Assembler 1.0 or higher.
; The ADM device driver version 1.00
;
	.model	tiny
	.code
	org	100h
start:	mov	dx,offset cs:hello
	mov	ah,9
	int	21h
	mov	di,0FFFFh       ; магические числа
	mov	dx,di		;
	mov	ah,10h		; функция 10h
	int	13h
	jc	not_ins		; драйвер ADM не установлен
	mov	ax,ds
	mov	bx,es
	cmp	ax,bx		; режим секретности
	je	off
	mov	dx,offset cs:secr_on
	jmp	short print
off:	mov	dx,offset cs:sec_off
	jmp	short print
not_ins:mov	dx,offset cs:n_i
print:	mov	ah,9
	int	21h
	mov	ax,4C00h
	int	21h
hello	db	13,'Переключатель триггера защиты ADM. Автор: Блашкин И.И.'
	db	13,10,'$'
n_i	db	'Драйвер ADM не установлен.$'
sec_off db	'Защита нулевой дорожки включена.$'
secr_on	db	'Защита нулевой дорожки отключена.$'
	end	start
