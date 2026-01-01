IFDEF __TINY__
.MODEL TINY
ELSEIFDEF __SMALL__
.MODEL TINY
ELSEIFDEF __COMPACT__
.MODEL COMPACT
ELSEIFDEF __MEDIUM__
.MODEL MEDIUM
ELSEIFDEF __LARGE__
.MODEL LARGE
ENDIF


_INIT_	segment word public 'INITDATA' ; Startup code
	db	1
	db	100
	dd	_StartUpXMS
_INIT_	ends


.CODE

PUBLIC	_XMSinstalled
PUBLIC	_XMSerror
PUBLIC	_CallXMS
PUBLIC	_StartUpXMS

XMSerror	db	?
XMSinst	dw	?
XMSfunc	label	dword
XMS_OFS	dw	?
XMS_SEG	dw	?
copyr	db	13,10,'XMS library  Copyright (c) 1992  KIV without Co',13,10

_XMSinstalled	PROC	FAR
	mov	ax,cs:XMSinst
	ret
_XMSinstalled	ENDP

_XMSerror	PROC	FAR
	xor	ax,ax
	mov	al,byte ptr cs:XMSerror
	mov	byte ptr cs:XMSerror,1
_XMSerror	ENDP

_CallXMS	PROC	FAR
	cmp	word ptr cs:XMSinst,0
	jne	dalee
	ret
	dalee:
	push	ax
	call	XMSfunc
	pop	cx
	cmp	ch,8
	jne	@@1
	mov	byte ptr cs:XMSerror,bl
	ret
	@@1:
	cmp	ax,1
	jne	@@2
	mov	byte ptr cs:XMSerror,0
	ret
	@@2:
	mov	byte ptr cs:XMSerror,bl
	ret
_CallXMS	ENDP


_StartUpXMS	PROC	FAR
	push	ds ax bx cx dx di si
	mov	ax,4300h		;есть ли XMS ?
	int	2Fh
	cmp	al,80h
	jne	no_xms
	mov	word ptr XMSinst,1	;Да!
	mov	ax,4310h
	int	2Fh			;адрес обработчика XMS
	mov	word ptr cs:XMS_SEG,es
	mov	word ptr cs:XMS_OFS,bx
	mov	byte ptr cs:XMSerror,0
	jmp	uchod
	no_xms:
	mov	word ptr cs:XMSinst,0
	uchod:
	pop si di dx cx bx ax ds
	ret
_StartUpXMS	ENDP

	END
