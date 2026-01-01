;			    EGA FONT LOADER v.2.0
;			written by Alex Romanov, 1990
;	    This simple  program creates  a RAM-resident  copy of  the
;	SAVE_PTR table  and assigns  the auxiliary  text and  graphics
;	modes font pointers. BIOS automatically loads the custom  8x14
;	EGA  font  with  every  mode  change.  The  list  of  modes is
;	specified in the TEXTMODAUX and GRMODAUX tables (see below).
;	    I believe this is  the smallest existing EGA  font loader.
;	It keeps in memory less than font table size (3584 bytes) plus
;	PSP size (256 bytes).
;
CODE SEGMENT
ASSUME cs:CODE,ds:CODE,es:CODE

	ORG 100h
START:		jmp	INSTALL
FONT8X14	LABEL	BYTE
INCLUDE 	FONT8X14.INC		;Include file describing bit images
					;of characters

SAVE_PTR_ADDR		EQU	04A8h
SAVE_PTR_TABLE_SIZE	EQU	14	;14 words
NEW_SAVE_PTR		EQU	82h
NEW_AUX_FONT_AREAS	EQU	NEW_SAVE_PTR+2*SAVE_PTR_TABLE_SIZE
INT10_VECT		EQU	NEW_AUX_FONT_AREAS+OFFSET AUX_AREAS_END-OFFSET AUX_FONT_AREAS+5
FONT_TABLE_OFFSET	EQU	INT10_VECT+OFFSET INT10_END_OF_HANDLER - OFFSET INT10_HANDLER


INSTALL:
	xor	ax,ax
	mov	ds,ax
	lds	si,ds:[SAVE_PTR_ADDR]		;EGA SAVE_PTR address
	mov	di,NEW_SAVE_PTR
	mov	cx,SAVE_PTR_TABLE_SIZE
	cld
	rep	movsw                          	;copy the SAVE_PTR table
	mov	ds,ax
	mov	ax,cs
	mov	word ptr ds:[SAVE_PTR_ADDR],NEW_SAVE_PTR	;store new values
	mov	ds:[SAVE_PTR_ADDR+2],ax				;at 0:04A8
	mov	ds,ax
	mov	si,OFFSET AUX_FONT_AREAS
	mov	cx,OFFSET AUX_AREAS_END - OFFSET AUX_FONT_AREAS
	rep	movsb				;relocate the aux_font_areas
	mov	si,OFFSET INT10_HANDLER
	mov	di,INT10_VECT
	mov	cx,OFFSET INT10_END_OF_HANDLER - OFFSET INT10_HANDLER
	rep	movsb				;relocate the handler code
	mov	si,OFFSET FONT8X14
	mov	di,FONT_TABLE_OFFSET
	mov	cx,3584/2
	rep	movsw				;shift the font table

	mov	word ptr ds:[SEG_TEXT_FONT-OFFSET AUX_FONT_AREAS+NEW_AUX_FONT_AREAS],ax
	mov	word ptr ds:[SEG_GR_FONT-OFFSET AUX_FONT_AREAS+NEW_AUX_FONT_AREAS],ax
	mov	word ptr ds:[NEW_SAVE_PTR+0Ah],ax
	mov	word ptr ds:[NEW_SAVE_PTR+08h],NEW_AUX_FONT_AREAS	;OFFSET TEXTMODAUX
	mov	word ptr ds:[NEW_SAVE_PTR+0Eh],ax
	mov	word ptr ds:[NEW_SAVE_PTR+0Ch],OFFSET GRMODAUX-OFFSET AUX_FONT_AREAS+NEW_AUX_FONT_AREAS
	xor	bh,bh
	mov	ah,3
	int	10h 			;save cursor position & shape
	mov	ax,3+128		;don't clear the screen
	int	10h                     ;while setting text mode
	mov	ah,1
	int	10h 			;restore cursor shape
	mov	ah,2
	int	10h 			;restore cursor position
	mov	ax,3510h
	int	21h			;get int vector 10h
	mov	byte ptr ds:[INT10_VECT-5],0EAh	;first byte of jmp far
	mov	ds:[INT10_VECT-4],bx
	mov	ds:[INT10_VECT-2],es
	mov	dx,INT10_VECT
	mov	ax,2510h
	int	21h			;set int vector 10h
        mov	dx,OFFSET MESSAGE
        mov	ah,09h          	;display message
        int	21h
	mov	ax,ds:[02Ch]		;segment of environment
	dec	ax			;segment of environment MCB
	mov	ds,ax
	mov	word ptr ds:[1],0	;disown this block
        mov	dx,3584+FONT_TABLE_OFFSET;font bitmaps + clipped PSP
        int	27h               	;terminate but stay resident
MESSAGE db	'EGA font loader v.2.0 installed.',10,13
	db	'(C) Alex Romanov, 1990',10,13,'$'

AUX_FONT_AREAS	LABEL	BYTE
TEXTMODAUX	db	0Eh		;bytes per character
		db	0		;RAM block to load
		dw	0100h		;all characters
		dw	0		;character offset (define the full set)
	  	dw	FONT_TABLE_OFFSET
SEG_TEXT_FONT  	dw	?		;Put CS here during installation
		db	0FFh		;displayable rows on screen
					;(let BIOS figure it out)
		db	00,01,02,03	;text video modes
		db	0FFh		;end of list
GRMODAUX	db	0FFh		;displayable rows on screen
					;(let BIOS figure it out)
		dw	000Eh		;bytes per character (word)
	  	dw	FONT_TABLE_OFFSET
SEG_GR_FONT  	dw	?		;Put CS here during installation
	  	db	0Eh,0Fh,10h	;graphics video modes
		db	0FFh		;end of list
AUX_AREAS_END	LABEL	BYTE

DUMMY_ENTRY:    db	5 dup (?)
INT10_HANDLER		LABEL	BYTE	;Due to some bug in EGA BIOS the
		or	ah,ah		;cursor disappears after mode reset.
		jnz	DUMMY_ENTRY	;This handler takes care of it.
		pushf
		call	dword ptr cs:[INT10_VECT-4]
		push	ax
		push	cx
		mov	cx,0607h
		mov	ah,1
		pushf
		call	dword ptr cs:[INT10_VECT-4]
		pop	cx
		pop	ax
		iret
INT10_END_OF_HANDLER	LABEL	BYTE
CODE ENDS
END START
