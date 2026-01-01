		TITLE	'Ask current video settings'
		NAME	AskVideo
		PAGE	55,132
;
; Function:	Asks current video settings.
;
; Caller:	Turbo C
;
;			struct VideoSettings
;			{
;				union {
;					unsigned x;
;					struct {
;						unsigned char l, h;
;					} h;
;				} vs_cursor;
;				unsigned char vs_width;
;				unsigned char vs_height;
;				unsigned char vs_mode;
;				unsigned char vs_page;
;				unsigned char vs_points;
;				unsigned      vs_color:1;
;				unsigned      vs_graph:1;
;				unsigned      vs_hivid:1;
;			}
;
;			void AskVideo(struct VideoSettings far *);

		ifdef	__TINY__
__NEAR__	equ	0
		endif
		ifdef	__NEAR__
prog		equ	near
quit		equ	ret
ArgOff		equ	4
		else
prog		equ	far
quit		equ	retf
ArgOff		equ	6
		endif

VIDstruct	STRUC			; corresponds to C data structure
VS_cursor       dw      ?               ; cursor shape values
VS_segment      dw      ?               ; video buffer segment addr
VS_blocks       dw      ?		; video buffer size / 512
VS_width	db	?		; screen width in columns
VS_height	db	?		; screew height in rows
VS_mode		db	?		; current video mode number
VS_page		db	?		; current active video page
VS_points	db	?		; byte-per-character
VS_flags	db	?		; packed bit fields
VIDstruct	ENDS

_TEXT		SEGMENT	byte public 'CODE'
		ASSUME	cs:_TEXT

		PUBLIC	_AskVideo
_AskVideo	PROC	prog

		push	bp		; preserve caller registers
		mov	bp,sp
		push	ds
                push    es
		push	di

                lds     di,ss:[bp+ArgOff]	; ds:di -> result structure

		mov	ah,0Fh		; common video info
		int	10h

		mov	VS_width[di],ah	; store results
		mov	VS_mode[di],al
		mov	VS_page[di],bh
                cmp     al,15		; hi-res monochrome graphics
                je      mono
                cmp     al,7		; monochrome text
                je      mono
                cmp     al,6		; CGA monochrome graphics
                jne	color
mono:		mov	byte ptr VS_flags[di],0
		jmp	short next
color:		mov	byte ptr VS_flags[di],1
next:
		cmp	al,4		; check for graphics mode
		jb	text
		cmp	al,6
		jbe	graph
		cmp	al,10
		jb	text
graph:		or	byte ptr VS_flags[di],2
text:
		mov	ah,3		; BH = page number!
		int	10h
		mov	word ptr VS_cursor[di],cx

		mov	ax,1130h	; get character generator info
		mov	bh,0		; dummy
		mov	dl,24		; default answer if no EGA/VGA/MCGA
		mov	cl,0
		int	10h

		inc	dl
		mov	VS_height[di],dl
		mov	VS_points[di],cl
		test	cl,0FFh
		jz	low
		or	VS_flags[di],4
low:
		mov	dx,0A000h	; video area starting addr
		sub	bx,bx
findseg:	mov	es,dx
		mov	al,es:[bx]
		mov	ah,al
		not	ah
		mov	es:[bx],ah      ; store inverted value
		mov     cx,80h		; arbitrary
moment1:        loop    moment1		; wait a moment
		cmp	es:[bx],ah	; did it changed?
		mov	es:[bx],al	; restore origin
		je	seg_found	; yes, buffer found
		add	dx,20h		; next 512 bytes
		cmp	dx,0C000h	; ROM area started?
		jb	findseg		; no, continue
		mov	VS_segment[di],bx	; clear addr
		jmp	short return
seg_found:
		mov 	VS_segment[di],dx
findend:        add	dx,20h		; next 512 bytes
		cmp	dx,0C000h       ; ROM area started?
		jnb	end_found	; yes, terminate
                mov	es,dx
		mov	al,es:[bx]
		mov	ah,al
		not	ah
		mov	es:[bx],ah      ; store inverted value
                mov     cx,80h
moment2:        loop    moment2		; wait a moment
		cmp	es:[bx],ah	; did it changed?
		mov	es:[bx],al	; restore origin
		je	findend		; yes, buffer continued
end_found:
		sub	dx,VS_segment[di]
		mov	cl,5
		shr	dx,cl
		mov	VS_blocks[di],dx
return:
		pop	di
                pop     es
		pop	ds
		pop	bp
		quit

_AskVideo	ENDP
_TEXT		ENDS
		END
