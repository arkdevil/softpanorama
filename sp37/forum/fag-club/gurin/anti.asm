code_seg_a	segment	
		assume	cs:code_seg_a, ds:code_seg_a
		org	100h

qwert		proc	far
nachalo:	
		mov	dx,offset vizitka
		mov	ah,09
		int	21h
		mov	di,82h
		mov	al,[di]
		cmp	al,'A'
		jb	a1
		jmp	a2
a1:		mov	ah,19h
		int	21h
		jmp	tst
a2:
		cmp	al,'['
		jb	menshe
		sub	al,61h
		jmp	tst
menshe:		sub	al,41h
tst:		mov	dds,al
		add	disk,al
read:		call	count
		jmp	dal

count:		
		mov	al,dds
		mov	cx,1
		mov	dx,0
		mov	bx,offset sector
		add	bx,off
		push	cs
		pop	ds

		db	0cdh		; int 25h
inter		db	25h		;but after increaced
		pop	es		;of variable inter it
		jb	err		;be int 26h
		push	cs
		pop	ds
		cmp	fol,1
		jz	wyhod
		mov	dx,offset sect
		mov	ah,09h
		int	21h
wyhod:		mov	fol,1
		db	195
err:		jmp	error

dal:		push	cs
		pop	ds
		mov	bx,offset sector
		mov	di,offset maska
		add	bx,38h
		mov	cx,4
povt:		mov	ah,[bx]
		mov	al,[di]
		cmp	ah,al
		jnz	goodpas
		inc	bx
		inc	di
		loop	povt
		sti
		jmp	bad

goodpas:	jmp	good
bad:
		mov	dx,offset virus
		mov	ah,09h
		int	21h
		mov	dx,offset rmv
		int	21h
		mov	ah,1
		int	21h
		cmp	al,'n'
		jz	exit
		cmp	al,'N'
		jz	exit
		mov	si,offset sector
		add	si,3
		mov	di,offset secta
		add	di,3
		push	cs
		pop	es
		mov	cx,30
		cld
prns:		mov	ah,byte	ptr	[si]
		mov	byte	ptr	[di],ah
		inc	si
		inc	di
		loop	prns
		add	off,512
		inc	inter		;switch read operatin at write op.
		call	count
exit:		mov	ah,0
		int	21h
		
norm:		db	0dh,'$'
norma:
		db	' OK',0dh,0ah,'$'
good:
		mov	dx,offset norma
		mov	ah,09h
		int	21h
		int	20h
error:		mov	cod,ax
		mov	ax,cod
		cmp	ax,0fh
		jnz	as1
mass:		mov	dx,offset er0f
		jmp	print

as1:		cmp	ax,13h
		jnz	as2

mas:		mov	dx,offset er13
		jmp	print

as2:		cmp	ax,1dh
		jnz	as4

as3:		mov	dx,offset er1d
		jmp	print

as4:		cmp	ax,0300h
		jz	mas
		cmp	ah,09h
		jz	mass
		cmp	ax,1bh
		jz	as3
		mov	dx,offset unkn
print:		mov	ah,09h
		int	21h
		int	20h
er0f:
		db	'Invalid drive specification',0dh,0ah,'$'
er13:
		db	0dh,'Write protect error',0dh,0ah,'$'
er1d:
		db	'Write error',0dh,0ah,'$'
unkn:
		db	'Unknown error',0dh,0ah,'$'
virus:
		db	0dh,'Found in the Boot-sector Print Screen'
		db	' virus ',07,0dh,0ah,'$'
rmv:
		db	'Remove (y/n) :$'
sect:
		db	'Scanning boot sector of disk '
disk		db	41h
		db	':$'
vizitka:
		db	'The Programm-fag of Print-Screen boot virus .',0dh,0ah
		db	'Copyright (C) 1991, Gurin A.I.',0dh,0ah,0dh,0ah,'$'
vsego		db	0
flag		db	0
flg		db	0
cod		dw	0
fol		db	0
dds		db	0
off		dw	0
maska:
		db	06h,211,224,8eh,192
sector:
	qqq	db	512	dup(0)  
secta:

;***********************************************************************
; text of the boot sector locate below
   DB 0EBh,034h,090h,04Dh,053h,044h,04Fh,053h,033h,02Eh,033h,000h,002h,002h,001h,000h
   DB 002h,070h,000h,0D0h,002h,0FDh,002h,000h,009h,000h,002h,000h,000h,000h,000h,000h
   DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,012h
   DB 000h,000h,000h,000h,001h,000h,0FAh,033h,0C0h,08Eh,0D0h,0BCh,000h,07Ch,016h,007h
   DB 0BBh,078h,000h,036h,0C5h,037h,01Eh,056h,016h,053h,0BFh,02Bh,07Ch,0B9h,00Bh,000h
   DB 0FCh,0ACh,026h,080h,03Dh,000h,074h,003h,026h,08Ah,005h,0AAh,08Ah,0C4h,0E2h,0F1h
   DB 006h,01Fh,089h,047h,002h,0C7h,007h,02Bh,07Ch,0FBh,0CDh,013h,072h,067h,0A0h,010h
   DB 07Ch,098h,0F7h,026h,016h,07Ch,003h,006h,01Ch,07Ch,003h,006h,00Eh,07Ch,0A3h,03Fh
   DB 07Ch,0A3h,037h,07Ch,0B8h,020h,000h,0F7h,026h,011h,07Ch,08Bh,01Eh,00Bh,07Ch,003h
   DB 0C3h,048h,0F7h,0F3h,001h,006h,037h,07Ch,0BBh,000h,005h,0A1h,03Fh,07Ch,0E8h,09Fh
   DB 000h,0B8h,001h,002h,0E8h,0B3h,000h,072h,019h,08Bh,0FBh,0B9h,00Bh,000h,0BEh,0D6h
   DB 07Dh,0F3h,0A6h,075h,00Dh,08Dh,07Fh,020h,0BEh,0E1h,07Dh,0B9h,00Bh,000h,0F3h,0A6h
   DB 074h,018h,0BEh,077h,07Dh,0E8h,06Ah,000h,032h,0E4h,0CDh,016h,05Eh,01Fh,08Fh,004h
   DB 08Fh,044h,002h,0CDh,019h,0BEh,0C0h,07Dh,0EBh,0EBh,0A1h,01Ch,005h,033h,0D2h,0F7h
   DB 036h,00Bh,07Ch,0FEh,0C0h,0A2h,03Ch,07Ch,0A1h,037h,07Ch,0A3h,03Dh,07Ch,0BBh,000h
   DB 007h,0A1h,037h,07Ch,0E8h,049h,000h,0A1h,018h,07Ch,02Ah,006h,03Bh,07Ch,040h,038h
   DB 006h,03Ch,07Ch,073h,003h,0A0h,03Ch,07Ch,050h,0E8h,04Eh,000h,058h,072h,0C6h,028h
   DB 006h,03Ch,07Ch,074h,00Ch,001h,006h,037h,07Ch,0F7h,026h,00Bh,07Ch,003h,0D8h,0EBh
   DB 0D0h,08Ah,02Eh,015h,07Ch,08Ah,016h,0FDh,07Dh,08Bh,01Eh,03Dh,07Ch,0EAh,000h,000h
   DB 070h,000h,0ACh,00Ah,0C0h,074h,022h,0B4h,00Eh,0BBh,007h,000h,0CDh,010h,0EBh,0F2h
   DB 033h,0D2h,0F7h,036h,018h,07Ch,0FEh,0C2h,088h,016h,03Bh,07Ch,033h,0D2h,0F7h,036h
   DB 01Ah,07Ch,088h,016h,02Ah,07Ch,0A3h,039h,07Ch,0C3h,0B4h,002h,08Bh,016h,039h,07Ch
   DB 0B1h,006h,0D2h,0E6h,00Ah,036h,03Bh,07Ch,08Bh,0CAh,086h,0E9h,08Ah,016h,0FDh,07Dh
   DB 08Ah,036h,02Ah,07Ch,0CDh,013h,0C3h,00Dh,00Ah,04Eh,06Fh,06Eh,02Dh,053h,079h,073h
   DB 074h,065h,06Dh,020h,064h,069h,073h,06Bh,020h,06Fh,072h,020h,064h,069h,073h,06Bh
   DB 020h,065h,072h,072h,06Fh,072h,00Dh,00Ah,052h,065h,070h,06Ch,061h,063h,065h,020h
   DB 061h,06Eh,064h,020h,073h,074h,072h,069h,06Bh,065h,020h,061h,06Eh,079h,020h,06Bh
   DB 065h,079h,020h,077h,068h,065h,06Eh,020h,072h,065h,061h,064h,079h,00Dh,00Ah,000h
   DB 00Dh,00Ah,044h,069h,073h,06Bh,020h,042h,06Fh,06Fh,074h,020h,066h,061h,069h,06Ch
   DB 075h,072h,065h,00Dh,00Ah,000h,049h,04Fh,020h,020h,020h,020h,020h,020h,053h,059h
   DB 053h,04Dh,053h,044h,04Fh,053h,020h,020h,020h,053h,059h,053h,000h,000h,000h,000h
   DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,055h,0AAh

qwert		endp
code_seg_a	ends
		end	qwert
