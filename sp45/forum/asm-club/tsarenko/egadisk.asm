
;****************************************************************
DOSVars	Struc				; DOS list of lists	*
FirstDPB	dd	?		; pointer to first DPB	*
ListSFT		dd	?		; system file table	*
CLOCK$Ptr	dd	?		; CLOCK$ header		*
CONPtr		dd	?		; CON header		*
MaxBB		dw	?		; max sector size	*
BufferPtr	dd	?		; pointer to DOS buffers*
ListCDS		dd	?		; pointer to CDS array	*
ListFCB		dd	?		; pointer to FCB table	*
ProtectFCB	dw	?		; protected FCB		*
NumBlockDev	db	?		; block devices number	*
LastDrive	db	?		; LASTDRIVE value	*
ActualNUL	db	18 dup (?)	; NUL device driver	*
JoinNum		db	?		; number JOIN'ed disks	*
Ends					;			*
;****************************************************************


;****************************************************************
CDS	Struc			; Current directory structure	*
Path		db	67 dup (?)	; Path			*
Flags		dw	?		; Flags word		*
DPBpointer	dd	?		; pointer to DPB	*
StClDir		dw	?		;			*
Res1		dw	?		;			*
Res2		dw	?		;			*
PathOfs		dw	?		; offset JOIN'ed path	*
Ends					;			*
;****************************************************************

		Locals	@@
@		equ	offset

ms		segment	para
		assume	cs:ms, ds:ms
		org	0

egadisk		proc	far

;****************************************************************
;*	header - заголовок драйвера				*
;****************************************************************
header		dd	0FFFFFFFFh
		dw	0		; 2000h
		dw	strategy
		dw	commands
subunit		db	1,7 dup (0)

VideoPar	dd	0		; адрес SAVE_PTR
CurMode		db	0		; видеорежим
flag		db	0		; флаг доступа к памяти
BPB_point	dw	BPB
CheckSum	dw	0		; Сумма диска
BootSum		dw	0		; Сумма Boot-сектора
SectMap		dw	80h		; Sector/Map
VideoSeg	dw	0A800h		; Начало диска
DangerMode	db	0		; 'Опасный' видеорежим (>7)
LoadType	db	0		; 0 - CONFIG, 1 - EXE запуск

;****************************************************************
Boot		db	0		; disk boot sector	*
		dw	0AA55h		;			*
		db	'EGAdisk '	;			*
;****************************************************************
;*	BPB - BIOS parameter block	;			*
BPB		equ	$		;			*
SectSiz		dw	100h		; sector size		*
ClustSiz	db	1		; sectors in cluster	*
ResSecs		dw	1		; reserved sectors	*
FatCnt		db	1		; number of FAT		*
RootSiz		dw	40h		; max root dir entry	*
TopSecs		dw	512		; sectors in media	*
Media		db	0FEh		; media byte		*
FatSize		dw	3		; sectors on FAT	*
					; additional field:	*
TrkSecs		dw	8		; sectors per track	*
HeadCnt		dw	1		; number of heads	*
HidSec		dw	0		; hidden sectors	*
BPBLen		equ	$ - @ Boot	;			*
;****************************************************************

request		dd	0

;****************************************************************
;*	Процедура обработки видеопрерывания BIOS		*
;****************************************************************
Int10		proc	far
		cmp	ah,0EEh			; installation check ?
		jne	@@1
		not	ah
		mov	al,cs:LoadType
		mov	bx,cs
		iret
@@1:
		or	ah,ah			; set mode ?
		jnz	@@exit
		test	al,078h			; режим >7
		jz	Less7
		mov	cs:DangerMode,al
		and	cs:DangerMode,07Fh
Less7:		test	al,80h
		jnz	@@exit
		cmp	cs:VideoSeg,0A800h
		jb	NotClear
		cmp	al,0Dh
		jb	@@exit
		cmp	al,13h
		ja	@@exit
NotClear:
		or	al,80h
		pushf
		cli
		call	dword ptr cs:Vect10
		and	al,7Fh
		push	ax bx cx dx di es
		xor	bx,bx
		mov	es,bx
		and	byte ptr es:[487h],7Fh
		mov	bx,0A000h
		xor	di,di
		mov	cx,cs:VideoSeg
		sub	cx,bx
		shl	cx,1
		shl	cx,1
		shl	cx,1

		mov	dl,al
		xor	ax,ax
		cmp	dl,7
		ja	@Clear
		jne	@CGA
		mov	ax,720h
		mov	bx,0B000h
		jmp	@Clear
@CGA:		mov	bx,0B800h
		cmp	dl,3
		ja	@Clear
		mov	ax,720h
@Clear:
		mov	es,bx
		cld
		rep	stosw
		pop	es di dx cx bx ax
		iret
@@exit:		db	0EAh
Vect10		dd	0
Int10		endp

;****************************************************************
;*	Доступ к памяти EGA (A000, 4 битовые плоскости)		*
;****************************************************************
InitGraph	proc	near
		cli
		mov	dx,3C4h
		mov	ax,102h		; map mask 0
		out	dx,ax
		mov	dx,3CEh
		mov	ax,0FF08h
		out	dx,ax		; bit mask
		mov	ax,3
		out	dx,ax		; data rotate
		mov	ax,5
		out	dx,ax		; read/write mode 0
		mov	ax,4
		out	dx,ax

		xor	ax,ax
		mov	es,ax
		mov	al,byte ptr es:[449h]	; mode
		mov	cs:CurMode,al
		mov	es,cs:VideoSeg		; тест доступа к памяти
		mov	ax,0AA55h
		mov	word ptr es:[1],ax
		mov	cx,word ptr es:[1]
		cmp	ax,cx
		jne	@@1
		mov	cs:flag,1
		ret
@@1:
		mov	al,cs:CurMode
		mov	cl,0		; text mode
		cmp	al,7
		je	@@2
		cmp	al,3
		jbe	@@2
		mov	cl,1		; graph mode
@@2:
		mov	dl,0C4h
		mov	ax,604h
		out	dx,ax		; memory mode
		mov	dl,0CEh
		mov	ax,0D006h	; a000..bfff
		or	ah,cl		; +text/graph
		out	dx,ax		; miscellaneous
		ret
InitGraph	endp

;****************************************************************
;*	Восстановить состояние адаптера				*
;****************************************************************
CloseGraph	proc	near
		mov	al,cs:CurMode
		les	bx,dword ptr cs:VideoPar
		xor	ah,ah
		mov	cl,6
		shl	ax,cl
		add	bx,ax
		mov	dx,3C4h
		mov	al,2
		mov	ah,byte ptr es:[bx+6]
		out	dx,ax		; map mask
		mov	dl,0CEh
		mov	al,5
		mov	ah,byte ptr es:[bx+60]
		out	dx,ax		; read/write mode
		mov	al,4
		mov	ah,byte ptr es:[bx+59]
		out	dx,ax		; read map
		cmp	cs:flag,0
		je	@@1
		mov	cs:flag,0
		jmp	@@ret
@@1:
		mov	dl,0C4h
		mov	al,4h
		mov	ah,byte ptr es:[bx+8]
		out	dx,ax		; memory mode
		mov	dl,0CEh
		mov	al,6h
		mov	ah,byte ptr es:[bx+61]
		out	dx,ax		; miscellaneous
@@ret:
		sti
		ret
CloseGraph	endp

sub_1		proc	near
		call	InitGraph
		les	bx,dword ptr cs:request
		mov	cx,es:[bx+12h]	; count
		mov	ax,es:[bx+14h]	; sector
		ret
sub_1		endp

sub_2		proc	near
		mov	bh,0			; Map
NextMap:	cmp	ax,cs:SectMap
		jb	ThisMap
		sub	ax,cs:SectMap
		inc	bh
		jmp	NextMap
ThisMap:
		mov	bl,al
		mov	ah,al
		xor	al,al
		xchg	ch,cl
		sub	bl,byte ptr cs:SectMap
		neg	bl
		ret
sub_2		endp

;****************************************************************
;*	Процедура стратегии					*
;****************************************************************
strategy	proc	far
		mov	word ptr cs:request+2,es
		mov	word ptr cs:request,bx
		ret
strategy	endp

;****************************************************************
;*	01: Media check - проверка носителя			*
;****************************************************************
media_check:
		call	InitGraph
		xor	bx,bx
		mov	dx,3CEh
		mov	ax,4h			; read map

; ---	Менялся режим?
		cmp	cs:DangerMode,0
		jnz	CSum
; ---	нет, считаем Boot
NoDanger:	xor	di,di
		mov	cx,128
CBoot:		add	bx,es:[di]
		inc	di
		inc	di
		loop	CBoot
		cmp	bx,cs:BootSum
		jmp	CheckOut
; --- да, считаем весь диск
CSum:		xor	di,di
		out	dx,ax
		inc	ah
		mov	ch,byte ptr cs:SectMap
		xor	cl,cl
		shr	cx,1
Cntrl:
		add	bx,es:[di]
		inc	di
		inc	di
		loop	Cntrl
		cmp	ah,4
		jne	CSum

		mov	cs:DangerMode,0
		cmp	bx,cs:CheckSum
CheckOut:	les	bx,dword ptr cs:request
		jne	media_ch
		mov	byte ptr es:[bx+0Eh],1
		jmp	close

; ---	диск затерт - форматируем
media_ch:
		mov	byte ptr es:[bx+0Eh],0ffh
		jmp	f1

;****************************************************************
;*	Процедуда INTERRUPT					*
;****************************************************************
commands	proc	far
		pushf
		cld
		push	ds ax cx dx di si
;		les	bx,cs:request
		mov	al,es:[bx+2]
		cmp	al,1
		je	media_check
		cmp	al,2
		je	build_BPB
		cmp	al,4
		je	read
		cmp	al,8
		je	write
		cmp	al,9
		je	write
		or	al,al
		jne	not_a
		jmp	init
not_a:		mov	es:[bx+3],8103h
		jmp	act_none

;****************************************************************
;*	02: Build BPB -  построить BPB				*
;****************************************************************
build_BPB:
		mov	word ptr es:[bx+12h],@ BPB
		mov	es:[bx+14h],cs
		jmp	exit

;****************************************************************
;*	04: Read - чтение секторов				*
;****************************************************************
read:
		call	sub_1
		les	di,dword ptr es:[bx+0eh]	; buffer
		mov	ds,cs:VideoSeg
		call	sub_2
		mov	si,ax

@rd:		cmp	bl,ch
		jbe	@rd1
		mov	bl,ch
@rd1:
		sub	ch,bl
		xchg	bl,ch
		mov	ah,bh
		mov	al,4
		out	dx,ax

		rep	movsb
		mov	ch,bl
		or	bl,bl
		jz	close
		xor	si,si
		inc	bh
		mov	bl,byte ptr cs:SectMap
		jmp	@rd

;****************************************************************
;*	08,09: Write -  запись секторов				*
;****************************************************************
write:		call	sub_1
		lds	si,dword ptr es:[bx+0eh]	; buffer
		mov	es,cs:VideoSeg
		call	sub_2
		mov	di,ax

@wr:		cmp	bl,ch
		jbe	@wr1
		mov	bl,ch
@wr1:
		sub	ch,bl
		xchg	bl,ch
		mov	cl,bh
		mov	ah,bh			; read map
		mov	al,4
		mov	dl,0CEh
		out	dx,ax
		mov	dl,0C4h
		mov	ah,1
		shl	ah,cl			; write map
		mov	al,2
		out	dx,ax

		xor	cl,cl

		shr	cx,1
		xor	ax,ax
@Wloop:
		add	ax,ds:[si]		; New Sum
		sub	ax,es:[di]		; Old Sum
		movsw
		loop	@Wloop
		add	cs:CheckSum,ax

		mov	ch,bl
		or	bl,bl
		jz	close
		xor	di,di
		inc	bh
		mov	bl,byte ptr cs:SectMap
		jmp	@wr

close:		call	CloseGraph

rest:		les	bx,dword ptr cs:request

exit:		or	word ptr es:[bx+3],100h
act_none:
		pop	si di dx cx ax ds
		popf
		ret
commands	endp

; ************** Форматирование диска
format:
		call	InitGraph
f1:
		call	Prepare

		jmp	close

Prepare		proc	near
;  ---	Обнуляем весь диск
		mov	dx,3C4h
		mov	ax,0F02h
		out	dx,ax
		mov	es,cs:VideoSeg
		xor	di,di
		mov	ch,byte ptr cs:SectMap
		xor	cl,cl
		xor	ax,ax
		rep	stosb

;  ---	Пишем Boot, считаем CheckSum
		xor	bx,bx
		mov	ax,0102h
		out	dx,ax
		xor	di,di
		mov	ax,cs
		mov	ds,ax
		mov	si,@ Boot
		mov	cx,BPBLen/2
@WBoot:
		add	bx,[si]
		movsw
		loop	@WBoot

		mov	BootSum,bx
		add	bx,0FFFEh
		add	bx,0FFh
		mov	CheckSum,bx
		mov	word ptr es:[256],0FFFEh
		mov	byte ptr es:[258],0FFh
		ret
Endp

LastByte	equ	$		; конец кода для загрузки DEVICE=

;	DOS Drive Parameter Block
DPB		equ	$
Drive		db	?
Unit		db	0
ByteSect	dw	256
SectClust	db	0
LogBase		db	0
Reserved	dw	1
NumFAT		db	1
RootEntry	dw	40h
DataSector	dw	20
LastClust	dw	?

FATSects	db	3		; dw for DOS 4.+
RootSec		dw	4
DevHeader	dw	header,ms
MediaB		db	0FEh
AccessFlag	db	0FFh
NextDPB		dw	0FFFFh,0FFFFh
ClStFree	dw	2
ClustFree	dw	0FFFFh
DPBReserv	db	0


;****************************************************************
;*	00: Init -  инициализация драйвера			*
;****************************************************************
init:
		push	cs
		pop	ds
		mov	al,byte ptr es:[bx+16h]
		add	disk,al

		lds	si,dword ptr es:[bx+12h]
		call	TakeParam

		push	cs
		pop	ds

		call	Setup
		jnc	@@setup

		les	bx,cs:request
		mov	word ptr es:[bx+0Eh],@ Boot
		mov	es:[bx+10h],cs
		mov	byte ptr es:[bx+0Dh],0
		jmp	rest
@@setup:
		call	SetInt10
		les	bx,cs:request
		mov	word ptr es:[bx+0Eh],@ LastByte
		mov	es:[bx+10h],cs
		mov	byte ptr es:[bx+0Dh],1
		mov	word ptr es:[bx+12h],@ BPB_point
		mov	es:[bx+14h],cs

		jmp	format


;****************************************************************
;*	Setup - процедура начальной установки			*
;****************************************************************
Setup		proc	near
		mov	dx,@ Copyright
		mov	ah,9
		int	21h
		xor	ax,ax
		mov	es,ax
		mov	al,byte ptr es:[487h]
		or	al,al
		jz	not_EGA
		test	al,8
		je	EGA
not_EGA:
		mov	dx,@ error
NotInstall:	mov	ah,9
		int	21h
		stc
		ret
EGA:
		xor	ah,ah
		and	al,60h
		add	ax,20h
		shl	ax,1
		sub	ax,20h
		cmp	ax,SectMap
		jae	Ok
		mov	dx,@ m128
		jmp	NotInstall
Ok:
		mov	ax,SectMap
		shl	ax,1
		shl	ax,1
		mov	TopSecs,ax
		shl	ax,1
		shl	ax,1
		sub	ax,0B000h
		neg	ax
		mov	VideoSeg,ax
		mov	ax,SectMap
		mov	dl,42
		div	dl
		xor	ah,ah
		inc	ax
		mov	FatSize,ax
		les	di,es:[4A8h]		; save_ptr
		les	di,es:[di]
		mov	word ptr VideoPar,di
		mov	word ptr VideoPar+2,es

		mov	dx,@ param
		mov	ah,9
		int	21h
		ret
EndP

; ---	GetSet Vector 10
SetInt10	proc	near
		xor	ax,ax
		mov	es,ax
		cli
		mov	ax,es:[40h]
		mov	word ptr Vect10,ax
		mov	ax,es:[42h]
		mov	word ptr Vect10+2,ax
		mov	ax,@ int10
		mov	es:[40h],ax
		mov	ax,cs
		mov	es:[42h],ax
		sti
		ret
EndP

;****************************************************************
;*								*
;*		Start - входная точка EXE - файла		*
;*								*
;****************************************************************
Ver		db	0
DOSVar		dw	0,0

Start		proc	far
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		mov	LoadType,1
		mov	ah,52h
		int	21h
		mov	DOSVar,bx
		mov	DOSVar+2,es
		mov	ah,30h
		int	21h
		mov	dx,@ ErrVers
		cmp	al,3
		jb	@exit
		ja	@@OkVer
		cmp	ah,10
		jnb	@@OkVer
@exit:		jmp	@@exit
@@OkVer:	mov	Ver,al

		mov	si,81h
		mov	ax,cs
		sub	ax,10h
		mov	ds,ax
		mov	es,ax
		mov	di,si
		mov	cl,ds:[80h]
		mov	ch,0
		jcxz	@@nu
		mov	al,'/'
		repne	scasb
		jne	@@nu
		mov	al,[di]
		cmp	al,'r'
		je	@@unload
		cmp	al,'R'
		je	@@unload
@@nu:		jmp	@@not_unload
@@unload:
		push	cs
		pop	ds
		mov	ah,0EEh
		int	10h
		mov	dx,@ ErrCant
		cmp	ax,1101h
		jne	@exit
		mov	cx,bx
		mov	ds,bx
		xor	ax,ax
		mov	es,ax
		cmp	es:[10h*4+2],bx
		jne	@exit
		cli				; выгружаем из памяти
		mov	ax,word ptr Vect10
		mov	es:[10h*4],ax
		mov	ax,word ptr Vect10+2
		mov	es:[10h*4+2],ax
		sti
		push	cs
		pop	ds
		les	bx,dword ptr DOSVar
		dec	es:DOSVars.NumBlockDev[bx]
		mov	al,es:DOSVars.NumBlockDev[bx]
		call	GetCDS
		mov	es:CDS.Flags[bx],0
		mov	word ptr es:CDS.DPBpointer[bx],0
		mov	word ptr es:CDS.DPBpointer+2[bx],0
		les	bx,dword ptr DOSVar	; ставим DBP в список
		les	bx,es:DOSVars.FirstDPB[bx]
		mov	si,18h
		cmp	Ver,4
		jb	@@cycDPB
		inc	si
@@cycDPB:
		cmp	word ptr es:[bx+si+2],cx
		je	@@delDPB
		les	bx,dword ptr es:[bx+si]
		jmp	@@cycDPB
@@delDPB:
		mov	word ptr es:[bx+si],0FFFFh
		mov	word ptr es:[bx+si+2],0FFFFh

		les	bx,dword ptr DOSVar	; ставим драйвер в список
		add	bx,DOSVars.ActualNUL
@@cycHDR:
		cmp	word ptr es:[bx+2],cx
		je	@@delHdr
		les	bx,dword ptr es:[bx]
		jmp	@@cycHDR
@@delHDR:
		mov	word ptr es:[bx],0FFFFh
		mov	word ptr es:[bx+2],0FFFFh

		sub	cx,10h
		mov	es,cx
		mov	ah,49h
		int	21h

		mov	dx,@ MSGunload
		jmp	@@exit
@@not_unload:
		call	TakeParam
@@EmptyPar:
		push	cs
		pop	ds
		mov	ah,0EEh
		int	10h
		cmp	ah,not 0EEh
		jne	@@not_inst
		mov	dx,@ ErrAlready
		jmp	@@exit
@@not_inst:
		les	bx,dword ptr DOSVar
		mov	al,es:DOSVars.NumBlockDev[bx]
		mov	Drive,al
		add	disk,al

		push	bx es
		call	Setup
		pop	es bx
		jnc	@@Ok
		jmp	@@quit
@@Ok:
		mov	al,es:DOSVars.NumBlockDev[bx]
		cmp	al,es:DOSVars.LastDrive[bx]
		mov	dx,@ ErrLastDr
		jae	@exit1
		call	GetCDS
		test	es:CDS.Flags[bx],0F000h
		jz	@@OkCDS
		mov	dx,@ ErrSubst
@exit1:		jmp	@@exit
@@OkCDS:	mov	cx,dx
		mov	di,bx
		cld
		xor	al,al
		rep	stosb
		mov	al,disk
		mov	es:CDS.Path[bx],al
		mov	word ptr es:CDS.Path+1[bx],'\:'
		mov	es:CDS.Flags[bx],4000h
		mov	word ptr es:CDS.DPBpointer[bx],@ DPB
		mov	word ptr es:CDS.DPBpointer+2[bx],ds
		mov	ax,0FFFFh
		mov	es:CDS.StClDir[bx],ax
		mov	es:CDS.Res1[bx],ax
		mov	es:CDS.Res2[bx],ax
		mov	es:CDS.PathOfs[bx],2

		mov	ax,RootSiz		; формируем DPB
		mov	RootEntry,ax
		add	ax,7
		shr	ax,1
		shr	ax,1
		shr	ax,1
		mov	cx,ax
		mov	ax,FatSize
		mov	FatSects,al
		inc	ax
		mov	RootSec,ax
		add	ax,cx
		mov	DataSector,ax
		neg	ax
		add	ax,TopSecs
		inc	ax
		mov	LastClust,ax
		cmp	Ver,4
		jb	@@tsr
		push	cs
		pop	es
		std
		mov	di,@ DPBReserv
		mov	si,@ DPBReserv - 1
		mov	cx,DPBReserv - FATSects - 1
		rep	movsb
		mov	byte ptr [di],0
@@tsr:
		call	SetInt10
		les	bx,dword ptr DOSVar	; ставим DBP в список
		inc	es:DOSVars.NumBlockDev[bx]
		les	bx,es:DOSVars.FirstDPB[bx]
		mov	si,18h
		cmp	Ver,4
		jb	@@loopDPB
		inc	si
@@loopDPB:
		cmp	word ptr es:[bx+si],0FFFFh
		je	@@findDPB
		les	bx,dword ptr es:[bx+si]
		jmp	@@loopDPB
@@findDPB:
		mov	word ptr es:[bx+si],@ DPB
		mov	word ptr es:[bx+si+2],ds

		les	bx,dword ptr DOSVar	; ставим драйвер в список
		add	bx,DOSVars.ActualNUL
@@loopHDR:
		cmp	word ptr es:[bx],0FFFFh
		je	@@lastHdr
		les	bx,dword ptr es:[bx]
		jmp	@@loopHDR
@@lastHDR:
		mov	word ptr es:[bx],@ header
		mov	word ptr es:[bx+2],ds

		call	Prepare
		call	CloseGraph

		mov	ax,cs
		sub	ax,10h
		mov	es,ax
		mov	ax,es:[2Ch]
		mov	word ptr es:[2Ch],0
		mov	es,ax
		mov	ah,49h
		int	21h

		mov	dx,@ init
		add	dx,256+15
		shr	dx,1
		shr	dx,1
		shr	dx,1
		shr	dx,1
		mov	ax,3100h
		int	21h

@@exit:
		mov	ah,9
		int	21h
@@quit:		mov	ax,4CFFh
		int	21h
EndP

;****************************************************************
;*	GetCDS - получить адрес элемента CDS			*
;*  Input:							*
;*	AL - номер элемента					*
;*	ES:BX - DOS list og lists				*
;*  Output:							*
;*	ES:BX - адрес элемента					*
;****************************************************************
GetCDS		proc	near
		les	bx,es:DOSVars.ListCDS[bx]
		mov	dl,51h
		cmp	cs:Ver,4
		jb	@@1
		mov	dl,58h
@@1:
		xor	dh,dh
		mul	dl
		add	bx,ax
		ret
EndP

;****************************************************************
;*	TakeParam - разбор командной строки			*
;****************************************************************
TakeParam	proc	near
@@next:
		lodsb
		cmp	al,10
		je	@@ret
		cmp	al,13
		je	@@ret
		cmp	al,' '
		je	l12
		cmp	al,9
		je	l12
		jmp	@@next

; ---	Buffser size in 1K bytes
l12:		call	ReadPar
		or	cx,cx
		jnz	loc_10b
		mov	cx,128
		jmp	Rnext
loc_10b:	cmp	cx,32
		jae	loc_10a
		mov	cx,32
loc_10a:	cmp	cx,224
		jbe	loc_10
		mov	cx,224
loc_10:
		mov	ax,[si-2]
		mov	word ptr cs:BufSize+1,ax
		mov	al,[si-3]
		mov	cs:BufSize,al
Rnext:
		mov	cs:SectMap,cx

; ---	Directory entries
		call	ReadPar
		or	cx,cx
		jnz	loc_11b
		mov	cx,64
		jmp	Rend
loc_11b:	cmp	cx,8
		jae	loc_11a
		mov	cx,8
loc_11a:	cmp	cx,224
		jbe	loc_11
loc_11:
		mov	ax,[si-2]
		mov	word ptr cs:DirEntry+1,ax
		mov	al,[si-3]
		mov	cs:DirEntry,al
Rend:
		mov	cs:RootSiz,cx
@@ret:		ret
TakeParam	endp

;****************************************************************
;*	ReadPar - выборка десятичного числа			*
;****************************************************************
ReadPar		proc	near
		xor	cx,cx
@@next:		lodsb
		cmp	al,13
		je	@@ret
		cmp	al,10
		je	@@ret
		cmp	al,'0'
		jb	@@next
		cmp	al,'9'
		ja	@@next
@@2:
		cmp	al,'0'
		jb	@@ret
		cmp	al,'9'
		ja	@@ret
		sub	al,'0'
		xor	ah,ah
		xchg	ax,cx
		mov	dl,10
		mul	dl
		add	cx,ax
		lodsb
		jmp	@@2
@@ret:		dec	si
		ret
ReadPar		endp

Copyright	db	'EGAdisk P.Tsarenko (C) 1990 v4.00 EGA virtual disk '
disk		db	'A',13,10,'$'
param		db	'    Buffer size:         '
BufSize		db	'128 K',13,10
		db	'    Sector size:         256',13,10
		db	'    Directory entries:   '
DirEntry	db	' 64',13,10,'$'
Error		db	'EGAdisk: EGA card not installed',13,10,'$'
m128		db	'EGAdisk: EGA card havn''t enough memory',13,10,'$'

ErrVers		db	'DOS version 3.10 or later require',13,10,'$'
ErrSubst	db	'Remove all SUBST''ed drives and try again',13,10,'$'
ErrLastDr	db	'Increase LASTDRIVE parameter in your CONFIG.SYS file',13,10,'$'
ErrAlready	db	'EGAdisk already installed in memory',13,10,'$'
ErrCant		db	'Can''t unload EGAdisk from memory',13,10,'$'
MSGunload	db	'EGAdisk succesfully erased.',13,10,'$'

egadisk		endp

ms		ends

		end	start
