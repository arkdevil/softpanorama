;------------------------------------------------------------------
; Автор: А.В.Медведев.
; 220090, Республика Беларусь, Минск, ул.Широкая, 36, к.716а
; т. 64-51-52 (раб.)
;
; Программа для уничтожения файла/файлов на диске.
; Содержимое файла(ов) сначала затирается (включая место за концом 
; файла до конца кластера или даже чуть больше, если кластер < 4K), 
; а затем файл(ы) удаляются простым обращением к функции ДОС 
; "удалить файл".
;
; Формат вызова:
;	KILL <имя_файла>
; В имени файла допустимо использовать обобщающие символы '?', '*'.
;
; Примеры:
;	KILL	kill.asm	- уничтожается файл kill.asm
;	KILL	kill.*		- уничтожаются файлы с именем kill
;
; Для получения выполнимого файла:
;	TASM kill
;	TLINK /x/t kill
;------------------------------------------------------------------

Write	MACRO	S
	mov	dx,offset S
	mov	ah,9
	int	21h
	ENDM

SearchRec	STRUC
  _reserved	DB	21 dup (?)
  fattr		DB	?
  ftime		DW	?
  fdate		DW	?
  fsize		DD	?
  _name		DB	13 dup (?)
	ENDS

DTA		EQU	offset	end_pb
BUFFER		EQU	DTA + 128
BLK_SIZE	EQU	1000h

MODEL	TINY
CODESEG
ORG	100h

START:
	Write	copyr
	cld
	mov	si,80h
	lodsb
	or	al,al
	jnz	@@ok1
@@err1:
	Write	prompt
	int	20h

@@ok1:
	cbw
	mov	cx,ax
	mov	di,ax
	add	di,si
	mov	bx,di
	mov	[bx],ah		; 0 в конец имени файла
@@next:
	lodsb
	cmp	al,' '
	ja	@@begin
	loop	@@next
	jmp	@@err1
@@begin:
	dec	si
	mov	path,si

	std
	push	cx
	mov	al,'\'
	repne scasb
	pop	cx
	je	@@found_bs
	mov	di,bx
	mov	al,':'
	repne scasb
	je	@@found_bs
	mov	fname,si
	jmp	short @@_2
@@found_bs:
	inc	di
	inc	di
	mov	fname,di	; указатель на начало имени
@@_2:
	mov	dx,DTA
	mov	ah,1Ah
	int	21h

	mov	di,BUFFER	; заполнить буфер символом 0F6h
	mov	cx,BLK_SIZE / 2
	cld
	mov	ax,0F6F6h
	rep stosw

	mov	ah,4Eh
	mov	cx,110B
	mov	dx,path
	int	21h
	jnc	@@ok2
	Write   fnf
	int	20h
@@ok2:
	mov	di,fname	; скопировать имя файла
	mov	si,DTA+_name
	mov	cx,13
	rep movsb

	mov	si,path
	mov	dx,si
@@type_char:
	lodsb
	or	al,al
	jz	@@eol
	mov	ah,0Eh
	int	10h
	jmp	@@type_char
@@eol:
	mov	ax,0E0Dh
	int	10h
	mov	ax,0E0Ah
	int	10h

	mov	ax,3D02h	; открыть файл для чтения/записи
	int	21h
	jnc	@@ok3
	int	20h

@@ok3:
	mov	bx,ax		; handle

	mov	ax,WORD PTR DTA+fsize
	mov	dx,WORD PTR DTA+fsize+2

	mov	cx,BLK_SIZE	; 4K - максимальный размер кластера
	div	cx
	inc	ax
	mov	di,ax		; количество блоков

	mov	dx,BUFFER

@@next_blk:
	mov	ah,40h
	int	21h
	jnc	@@ok4
	int	20h
@@ok4:
	dec	di
	jnz	@@next_blk

	mov	ah,3Eh		; закрыть файл
	int	21h

	mov	ah,41h		; удалить файл
	mov	dx,path
	int	21h

	mov	ah,4Fh
	mov	dx,DTA
	int	21h
	jnc	@@ok2

	int	20h


copyr	DB 'Уничтожение файлов. Copyright (c) 1992 Андрей Вл. Медведев', 13, 10, '$'
prompt	DB 'Использование:', 9, 'KILL <имя_файла>', 13, 10
	DB 'В имени файла допустимо использовать обобщающие символы ''*'' и ''?''.', 13, 10, '$'
fnf	DB 'Файл не найден.', 13, 10, '$'

fname	DW	0
path	DW	0

end_pb	LABEL	BYTE

END	START
