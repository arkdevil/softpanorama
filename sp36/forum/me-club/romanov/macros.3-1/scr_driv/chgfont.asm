;			 Change screen font utility
;			written by Alex Romanov, 1990
;	    This program can replace the RAM-resident screen font table
;	loading a font from a  disk file in memory. The  auxiliary text
;	or graphics font areas must  be assigned in the SAVE_PTR  table
;	for the RAM font table to be located.
;
CODE	SEGMENT
ASSUME	cs:CODE,ds:CODE,es:CODE

	ORG 100h
START:
	mov	ah,30h
	int	21h
	cmp	al,3
	jnb	OK_1
	mov	dx,OFFSET ERR_BAD_DOS_VERSION
	jmp	ERROR_EXIT
OK_1:
	cld
	mov	si,80h
	lodsb
	or	al,al
	jnz	OK2
	jmp	USAGE
OK2:
	mov	cl,al
	xor	ch,ch
	mov	di,si
	add	di,cx			;di -> end of filespec
	mov	word ptr [di],2400h	;0,'$'
BLANKS:
	lodsb
	cmp	al,20h
	jne	FILENAME
	loop	BLANKS
	jmp	USAGE
FILENAME:
	dec	si
	mov	dx,si			;dx -> start of filespec
	mov	ax,3D00h
	int	21h
	jnc	LOCATE_FONT
	mov	bx,di			;bx -> end of filespec
	mov	cx,di
	sub	cx,si
	mov	bp,cx			;bp = length of filespec
	mov	si,OFFSET EXTENSION
	mov	cx,3
	rep	movsw			;append default extension
	mov	ax,3D00h
	int	21h
	jnc	LOCATE_FONT
	mov	es,ds:[02Ch]		;environment
	xor	al,al
	xor	di,di
	mov	cx,7FFFh		;should be enough
ENVSCAN:
	repne	scasb
	cmp	byte ptr es:[di],0
	jne	ENVSCAN
	add	di,3
	mov	si,di			;si -> start of EXEC string
	repne	scasb
	dec	di
	std
	mov	al,'\'
	repne	scasb
	cld
	mov	cx,di
	add	cx,2
	sub	cx,si			;cx = length of EXEC path
	mov	ax,es
	mov	ds,ax
	mov	ax,cs
	mov	es,ax
	mov	di,bx
	rep	movsb			;directory from which CHGFONT was loaded
	mov	ds,ax
	mov	si,dx
	mov	cx,bp                   ;append font name
	rep	movsb
	mov	word ptr [di],2400h	;0,'$'
	mov	dx,bx
	mov	ax,3D00h
	int	21h
	jnc	LOCATE_FONT
	mov	si,OFFSET EXTENSION
	mov	cx,3
	rep	movsw			;append default extension
	mov	ax,3D00h
	int	21h
	jnc	LOCATE_FONT
	mov	dx,OFFSET ERR_FILE_NOT_FOUND
	jmp	ERROR_EXIT
LOCATE_FONT:
	mov	bx,ax			;store file handle in bx
	mov	di,dx			;store file name offset in di
	xor	ax,ax
	mov	ds,ax
	lds	si,ds:[04A8h]		;ds:si -> SAVE_PTR table
	cmp	word ptr [si+8],0
	jne	TEXT_MODE_ASSIGNED
	cmp	word ptr [si+0Ah],0
	jne	TEXT_MODE_ASSIGNED
	cmp	word ptr [si+0Ch],0
	jne	GRAPHICS_MODE_ASSIGNED
	cmp	word ptr [si+0Eh],0
	jne	GRAPHICS_MODE_ASSIGNED
	mov	dx,OFFSET ERR_RAM_FONT_NOT_FOUND
	jmp	short	CLOSE_AND_EXIT
GRAPHICS_MODE_ASSIGNED:
	lds	si,[si+0Ch]		;ds:si -> graphics mode aux font area
	inc	si
	lodsw				;ax = bytes per char
	lds	si,[si]			;ds:si -> screen font table
	jmp	short	READ_FONT_FILE
TEXT_MODE_ASSIGNED:
	lds	si,ds:[si+08h]		;ds:si -> text mode aux font area
	lodsb                           ;ax = bytes per char
	lds	si,ds:[si+6-1]	        ;ds:si -> screen font table
READ_FONT_FILE:
	mov	cl,8
	shl	ax,cl
	mov	bp,ax			;bp = font file size
	mov	ax,4202h
	xor	cx,cx
	xor	dx,dx
	int	21h
	or	dx,dx
	jnz	INVALID_SIZE
	cmp	ax,bp
	jne	INVALID_SIZE
	mov	ax,4200h
	int	21h
	mov	dx,si
	mov	ah,3Fh			;read font in
	mov	cx,bp
	int	21h
	mov	ah,3Eh			;close file
	int	21h

	mov	ax,cs
	mov	ds,ax
	mov	ax,3
	int	10h
	mov	dx,OFFSET INFO
	mov	ah,9
	int	21h
	mov	dx,OFFSET MESSAGE
	int	21h
	mov	dx,di
	int	21h
	int	20h
USAGE:
	mov	dx,OFFSET INFO
	mov	ah,9
	int	21h
	mov	dx,OFFSET USAGE_INFO
	int	21h
	jmp	short	JUST_EXIT
INVALID_SIZE:
	mov	dx,OFFSET ERR_INVALID_SIZE
CLOSE_AND_EXIT:
	mov	ah,3Eh
	int	21h
	mov	ax,cs
	mov	ds,ax
ERROR_EXIT:
	mov	ah,9
	int	21h
	mov	dx,OFFSET GENERAL_ERROR_INFO
	int	21h
JUST_EXIT:
	mov	ax,4C01h
	int	21h
USAGE_INFO		db	'Usage: chgfont font_filename$'
ERR_BAD_DOS_VERSION	db	'DOS 3.x required$'
ERR_FILE_NOT_FOUND	db	'Unable to open file$'
ERR_RAM_FONT_NOT_FOUND	db	'RAM font table not found$'
ERR_INVALID_SIZE	db	'Invalid font file size$'
GENERAL_ERROR_INFO	db	', font change aborted.',10,13,'$'
INFO		db	'Change screen font utility. Written by Alex Romanov, 1990',10,13,'$'
MESSAGE		db	'Font loaded from $'
EXTENSION	db	'.FNT',0,'$'

CODE	ENDS
END	START
