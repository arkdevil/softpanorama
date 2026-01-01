;			    VGA FONT LOADER v.2.0
;			written by Alex Romanov, 1990
;	    This simple  program creates  a RAM-resident  copy of  the
;	SAVE_PTR table  and assigns  the auxiliary  text and  graphics
;	modes font pointers. BIOS automatically loads the custom  8x16
;	VGA  font  with  every  mode  change.  The  list  of  modes is
;	specified in the TEXTMODAUX and GRMODAUX tables (see below).
;	    I believe this is  the smallest existing VGA  font loader.
;	It keeps  in memory  only  4288 bytes, which  is actually less
;	than font table size (4096 bytes) plus PSP size (256 bytes).
;
;
CODE	SEGMENT
ASSUME	cs:CODE,ds:CODE,es:CODE

	ORG 100h
START:		jmp	INSTALL
FONT8X16	LABEL	BYTE
INCLUDE 	FONT8X16.INC		;Include file describing bit images
					;of characters
INSTALL:
	xor	ax,ax
	mov	ds,ax
	lds	si,ds:[04A8h]			;EGA SAVE_PTR address
	mov	di,82h
	mov	cx,14
	cld
	rep	movsw                          	;copy the SAVE_PTR table
	mov	ds,ax
	mov	ax,cs
	mov	word ptr ds:[04A8h],82h		;store new values
	mov	ds:[04AAh],ax			;at 0:04A8
	mov	ds,ax
	mov	si,OFFSET AUX_FONT_AREAS
	mov	cx,OFFSET AUX_AREAS_END-OFFSET AUX_FONT_AREAS
	rep	movsb				;relocate the aux_font_areas
	mov	si,OFFSET FONT8X16
	mov	di,0C0h
	mov	cx,4096/2
	rep	movsw				;shift the font table to
						;offset 0C0h
	cli
	mov	word ptr ds:[SEG_TEXT_FONT-OFFSET AUX_FONT_AREAS+82h+28],ax
	mov	word ptr ds:[SEG_GR_FONT-OFFSET AUX_FONT_AREAS+82h+28],ax
	mov	word ptr ds:[82h+0Ah],ax
	mov	word ptr ds:[82h+08h],82h+28	;OFFSET TEXTMODAUX
	mov	word ptr ds:[82h+0Eh],ax
	mov	word ptr ds:[82h+0Ch],OFFSET GRMODAUX-OFFSET AUX_FONT_AREAS+82h+28
	sti
	xor	bh,bh
	mov	ah,3
	int	10h 			;save cursor position
	mov	ax,3+128		;don't clear the screen
	int	10h                     ;while setting text mode
	mov	ah,2
	int	10h 			;restore cursor position
        mov	dx,OFFSET MESSAGE
        mov	ah,09h          	;display message
        int	21h
	mov	ax,ds:[02Ch]		;segment of environment
	dec	ax			;segment of environment MCB
	mov	ds,ax
	mov	word ptr ds:[1],0	;disown this block
        mov	dx,4096+0C0h		;font bitmaps + clipped PSP
        int	27h               	;terminate but stay resident
MESSAGE db	'VGA font loader v.2.0 installed.',10,13
	db	'(C) Alex Romanov, 1990',10,13,'$'

AUX_FONT_AREAS	LABEL	BYTE
TEXTMODAUX	db	10h		;bytes per character
		db	0		;RAM block to load
		dw	0100h		;all characters
		dw	0		;character offset (define the full set)
	  	dw	0C0h		;OFFSET FONT8X16
SEG_TEXT_FONT  	dw	?		;Put CS here during installation
		db	0FFh		;displayable rows on screen
					;(let BIOS figure it out)
		db	00,01,02,03	;text video modes
		db	0FFh		;end of list
GRMODAUX	db	0FFh		;displayable rows on screen
					;(let BIOS figure it out)
		dw	0010h		;bytes per character (word)
	  	dw	0C0h		;OFFSET FONT8X16
SEG_GR_FONT  	dw	?		;Put CS here during installation
	  	db	0Eh,0Fh,10h,11h,12h ;graphics video modes
		db	0FFh		;end of list
AUX_AREAS_END	LABEL	BYTE
CODE	ENDS
END	START
