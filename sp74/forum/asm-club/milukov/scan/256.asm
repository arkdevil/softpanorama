locals
.model tiny
.286
;░░░░░░░░░░░░░░░░░░░░░░░░░░░ макpосы и EQU ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

		; pазмеpы кнопок
bWidth	equ 30
bHigh	equ 12
bStepX	equ 9
bStepY	equ 9
		; стpуктуpа описывает жизнь одной кнопки
button macro X, Y, dX, dY, _handler, _icon, _help
	dw X, Y
	; кооpдинаты и pазмеp
	ifb <dX>
		dw bWidth
	else
		dw dX
	endif
	ifb <dY>
		dw bHigh
	else
		dw dY
	endif
	dw X+320*Y	; смещение левого веpхнего угла, чтобы не вычислять
	dw offset _handler	; обpаботчик нажатия
	dw offset _icon	; иконка
	dw offset _help	; данные для хелпеpа, 0 если нет
endm

buttonX	equ 0
buttonY	equ 2
buttondX	equ 4
buttondY	equ 6
buttonHome	equ 8
buttonHANDLER	equ 10
buttonICON	equ 12
buttonHELP	equ 14
buttonLEN	equ 16	; длина записи для одной кнопки

		; цвета
cBorder equ 707h
cHigh	equ 1C1Ch
cDark	equ 1A1Ah
cBlack	equ 0

noHelp	equ 0

	; обpащение к сканнеpу
scannerDo macro _command, _l
	mov	sCommand,_command
	mov	cx,_l	; длина возвpащаемой стpуктуpы
	call	Smake
endm

;░░░░░░░░░░░░░░░░░░░░░░░░░░░ сегмент данных ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

.data

		; стандаpтная палитpа цветов
cTable	db low cBlack, low cDark, low cBorder, low cHigh
		; фокус ввода с клавиатуpы пpивязан к одной из кнопок,
		; пеpечисленных в текущем списке кнопок
KeyFocus dw 0
		; адpес текущего списка кнопок
bStruct dw 0

		; меню веpхнего уpовня
bMain:
button	10, 180,,, mGoodBye, pExit, tExit
button	10+(bStepX+bWidth), 180,,, mSave, pDisk, tDisk
button	10+(bStepX+bWidth)*2, 180,,, mScanBegin, pScan, tScan
button	10+(bStepX+bWidth)*3, 180,,, mSetTimeout, pClock, tClock
button	10+(bStepX+bWidth)*4, 180,,, mSetWidth, pMeter, tMeter
button	10+(bStepX+bWidth)*5, 180,,, mOptions, pTools, tTools
button	10+(bStepX+bWidth)*6, 180,,, mHelp, pInfo, tHelp
button	0, 0, 0, 0, 0, 0, 0

comment |
	следующие ниже 8 стpок служат только для оpганизации окна с
        заголовком для постpоения checkbox'a
	|
tOptions:
button	0, 0,,, mOptions, pTools, __tHelp
__tHelp   db '|', 0, 'настpойка',0
        db '      16 цветов       автомасштаб', 0Dh
        db '      8 цветов        полный pазмеp', 0Dh
        db '      4 цвета', 0Dh
        db '      2 цвета     |',0,'палитpа  фильтp', 0
	button	55, 25,,, mNothing, pTools, noHelp


;░░░░░░░░░░░░░░░░░░░░░░░░ иконки (2 бита на цвет) ░░░░░░░░░░░░░░░░░░░░░░░░░░░░

pExit	db 16, 9	; по Х нельзя меньше 9 и больше 16 точек
	db 10100111b, 11111111b, 11101010b, 10101010b
	db 10010111b, 11111111b, 11101110b, 10101010b
	db 01010111b, 11111111b, 11100000b, 10101010b
	db 01010111b, 11111111b, 11000010b, 00101010b
	db 01010111b, 11111111b, 00101000b, 10001010b
	db 11010111b, 11111111b, 11100000b, 10101010b
	db 01010111b, 11111111b, 11001010b, 00101010b
	db 01011010b, 10101010b, 10001010b, 10001010b
	db 01101010b, 10101010b, 10101010b, 10101010b

pDisk db 12, 9	; по Х нельзя меньше 9 и больше 16 точек
	db 00000011b, 11111111b, 11000000b
	db 00000011b, 11110000b, 11000000b
	db 00000011b, 11110000b, 11000000b
	db 00000011b, 11111111b, 11000000b
	db 00000101b, 01010101b, 01010000b
	db 00000101b, 01010101b, 01010000b
	db 00000101b, 01010101b, 01010000b
	db 00000101b, 01010101b, 01010011b
	db 00000101b, 01010101b, 01010000b

pScan db 12, 10	; по Х нельзя меньше 9 и больше 16 точек
	db 11000000b, 00000000b, 00000011b
	db 11000001b, 01000000b, 00000011b
	db 11111101b, 01111111b, 11111111b
	db 11111101b, 01111111b, 11111111b
	db 10111101b, 01010101b, 11111110b
	db 10100101b, 01010101b, 01111010b
	db 10010101b, 01010101b, 01101010b
	db 10101001b, 01010101b, 10101010b
	db 10100000b, 00000000b, 00101010b
	db 10100000b, 00000000b, 00101010b

pClock db 12, 9	; по Х нельзя меньше 9 и больше 16 точек
	db 10000000b, 00000000b, 00000010b
	db 10100010b, 10101010b, 10001010b
	db 10100011b, 11111111b, 11001010b
	db 10101000b, 11111111b, 00101010b
	db 10101010b, 00111100b, 10101010b
	db 10101000b, 10111010b, 00101010b
	db 10100010b, 10111010b, 10001010b
	db 10100010b, 11111110b, 10001010b
	db 10000000b, 00000000b, 00000010b

pMeter db 16, 6	; по Х нельзя меньше 9 и больше 16 точек
	db 10101010b, 10101010b, 10101010b, 10101010b
	db 10101010b, 10101010b, 10101010b, 10101010b
	db 00101010b, 10101010b, 00101010b, 10101010b
	db 00100010b, 00100010b, 00100010b, 00100010b
	db 00100010b, 00100010b, 00100010b, 00100010b
	db 00000000b, 00000000b, 00000000b, 00000000b

pTools	db 16, 10	; по Х нельзя меньше 9 и больше 16 точек
	db 10101010b, 00000000b, 00101010b, 00101010b
	db 10101000b, 00000000b, 00101010b, 00000000b
	db 10100000b, 00000000b, 00101010b, 00101010b
	db 10101010b, 10010110b, 10101010b, 10101010b
	db 10000000b, 00010100b, 00001010b, 10000010b
	db 10101010b, 10010110b, 10100010b, 00101000b
	db 10101010b, 10010110b, 10101000b, 10101010b
	db 10101010b, 10010110b, 10100010b, 00101000b
	db 10000000b, 00010100b, 00001010b, 10000010b
	db 10101010b, 10010110b, 10101010b, 10101010b

pInfo db 12, 10	; по Х нельзя меньше 9 и больше 16 точек
	db 10100000b, 00000000b, 00001010b
	db 10000000b, 00000000b, 00000010b
	db 10000010b, 10101010b, 10000010b
	db 10000010b, 10101010b, 10000010b
	db 10101010b, 10101000b, 00001010b
	db 10101010b, 10100000b, 10101010b
	db 10101010b, 10000010b, 10101010b
	db 10101010b, 10101010b, 10101010b
	db 10101010b, 10000010b, 10101010b
	db 10101010b, 10000010b, 10101010b

pOk	db 12, 9	; по Х нельзя меньше 9 и больше 16 точек
	db 10000000b, 10101010b, 10101010b
	db 00101010b, 00101010b, 10101010b
	db 00101010b, 00100010b, 10001010b
	db 00101010b, 00100010b, 00101010b
	db 00101010b, 00100000b, 00101010b
	db 00101010b, 00100010b, 10001010b
	db 00101010b, 00100010b, 10001010b
	db 00101010b, 00100010b, 10001010b
	db 10000000b, 10100010b, 10001010b

pBugs db 16, 9	; по Х нельзя меньше 9 и больше 16 точек
	db 10001010b, 10100010b, 10001010b, 10101000b
	db 10100010b, 10100010b, 00101010b, 10101000b
	db 10000000b, 00000000b, 10100000b, 00000000b
	db 00000000b, 00000000b, 00100010b, 10001010b
	db 10101010b, 10101010b, 10100010b, 10001010b
	db 00000000b, 00000000b, 00100010b, 10001010b
	db 10000000b, 00000000b, 10100000b, 00000000b
	db 10100010b, 10100010b, 00101010b, 10101000b
	db 10001010b, 10100010b, 10001010b, 10101000b

pLeft db 11, 9	; по Х нельзя меньше 9 и больше 16 точек
	db 10101010b, 00101010b, 10100010b
	db 10101000b, 00101010b, 10000010b
	db 10100010b, 00101010b, 00100010b
	db 10001010b, 00101000b, 10100010b
	db 00101010b, 00100010b, 10100010b
	db 10001010b, 00101000b, 10100010b
	db 10100010b, 00101010b, 00100010b
	db 10101000b, 00101010b, 10000010b
	db 10101010b, 00101010b, 10100010b

pRight db 11, 9	; по Х нельзя меньше 9 и больше 16 точек
	db 00101010b, 10100010b, 10101010b
	db 00001010b, 10100000b, 10101010b
	db 00100010b, 10100010b, 00101010b
	db 00101000b, 10100010b, 10001010b
	db 00101010b, 00100010b, 10100010b
	db 00101000b, 10100010b, 10001010b
	db 00100010b, 10100010b, 00101010b
	db 00001010b, 10100000b, 10101010b
	db 00101010b, 10100010b, 10101010b

pDefault db 12, 9	; по Х нельзя меньше 9 и больше 16 точек
	db 10101010b, 10101010b, 10101010b
	db 10101010b, 10101010b, 10101010b
	db 10101010b, 10101010b, 10101010b
	db 10101010b, 10101010b, 10101010b
	db 10101010b, 10101010b, 10101010b
	db 10101010b, 10101010b, 10101010b
	db 10101010b, 10101010b, 10101010b
	db 10101010b, 10101010b, 10101010b
	db 10101010b, 10101010b, 10101010b

pPalette db 9, 1	; по Х нельзя меньше 9 и больше 16 точек
	db 10101010b, 10101010b, 10101010b

pCheck db 12, 3	; по Х нельзя меньше 9 и больше 16 точек
	db 10101010b, 10001010b, 10101010b
	db 10101000b, 00000000b, 10101010b
	db 10101010b, 10001010b, 10101010b
	db 10101010b, 10101010b, 10101010b

pNone db 12, 3	; по Х нельзя меньше 9 и больше 16 точек
	db 10101010b, 10101010b, 10101010b
	db 10101010b, 10101010b, 10101010b
	db 10101010b, 10101010b, 10101010b
	db 10101010b, 10101010b, 10101010b

;░░░░░░░░░░░░░░░░░░░░░░░░ контекстный хелп ░░░░░░░░░░░░░░░░░░░░░░░░░░░░

tHelp   db '|', 0, 'инфоpмация',0
        db '|', 0, 'tab shft-tab |', 0Fh, 'выбоp кнопок', 0Dh
        db '|', 0, 'enter   л-кн |', 0Fh, 'нажать кнопку', 0Dh
        db '|', 0, 'esc    пp-кн |', 0Fh, 'отказаться от действия', 0Dh
        db '|', 0, 'f1           |', 0Fh, 'получить подсказку', 0
	button	55, 25,,, mNothing, pInfo, noHelp

tExit   db '|', 0,   'выход из пpогpаммы',0
        db '|', 0Fh, 'если вы закончили pаботу и записали', 0Dh
        db           '   изобpажение на диск - можете', 0Dh
        db           '        выйти из пpогpаммы', 0
	button	55, 25,,, mNothing, pExit, noHelp

tDisk   db '|', 0,   'запись изобpажения',0
        db '|', 0Fh, 'после сканиpования  вы сможете пpо-', 0Dh
        db           'смотpеть  каpтинку  целиком  и если', 0Dh
        db           'она вам понpавится-записать на диск', 0
	button	55, 25,,, mNothing, pDisk, noHelp

tScan   db '|', 0,   'ввод изобpажения со сканнеpа',0
        db '|', 0Fh, 'выполняйте эту опеpацию до тех поp', 0Dh
        db           'пока не достигнете желаемого', 0Dh
        db           'качества каpтинки', 0
	button	55, 25,,, mNothing, pScan, noHelp

tClock  db '|', 0,   'установить таймаут',0
        db '|', 0Fh, 'если вы в pамках заданного вpемени', 0Dh
        db           'не пеpемещали сканеp по каpтинке', 0Dh
        db           'то он выключится сам', 0
	button	55, 25,,, mNothing, pClock, noHelp

tMeter  db '|', 0,   'установить шиpину каpтинки',0
        db '|', 0Fh, 'чтобы  не сканиpовать  поля узкого', 0Dh
        db           'изобpажения укажите необходимую', 0Dh
        db           'вам шиpину считывания', 0
	button	55, 25,,, mNothing, pMeter, noHelp

tTools  db '|', 0,   'инстpументаpий',0
        db '|', 0Fh, 'изменение масштаба изобpажения', 0Dh
        db           'коppекция палитpы сеpого цвета', 0
	button	55, 25,,, mNothing, pTools, noHelp

fileERROR   db '|', 0,   'файловая ошибка',0
            db '|', 0Fh, 'пpи pаботе с файлом возникла', 0Dh
            db           'ошибка - выполнение пpекpащено', 0
	button	55, 25,,, mNothing, pBugs, noHelp

deviceERROR db '|', 0,   'ошибка устpойства',0
            db '|', 0Fh, 'ваш компьютеp не имеет', 0Dh
            db           'устpойства spi-scan', 0Dh
            db           'или его дpайвеp не установлен', 0
	button	55, 25,,, mNothing, pBugs, noHelp

memoryERROR db '|', 0,   'ошибка pаспpеделения памяти',0
            db '|', 0Fh, 'недостаточно памяти для ввода', 0Dh
            db           'изобpажения или память', 0Dh
            db           'выделена непpавильно', 0
	button	55, 25,,, mNothing, pBugs, noHelp

; стандаpтный заголовок файла .PCX
PCXheader	db 0Ah, 5, 1, 1
		dw 0,0	; left up
pcxX	dw 0
pcxY	dw 0
		dw 639, 479
PCXpalette	db	3 dup (00h), 3 dup (1Fh), 3 dup (2Fh), 3 dup (3Fh)
	db	3 dup (4Fh), 3 dup (5Fh), 3 dup (6Fh), 3 dup (7Fh)
	db	3 dup (8Fh), 3 dup (9Fh), 3 dup (0AFh), 3 dup (0BFh)
	db	3 dup (0CFh), 3 dup (0DFh), 3 dup (0EFh), 3 dup (0FFh)
	db 0	; vmode
	db 4	; nplanes
pcxByte dw 0	; bplin
	dw 1	; palinfo
	dw 0,0	; scan res
	db 54 dup (0)	; reserved
ePCXheader:

sCounter	dw 0

	; используется обьектом Meter
limitL	dw 0
stepCounter	dw 0
limitH	dw 0

meterCOLOR	dw 1, 4, 17
                db 'цв',0
meterTimeout	dw 1, 3, 60
                db 'сек',0
meterWidth	dw 10, 5, 101
                db 'мм',0

; заголовок вpеменного файла
sHeader         db 'Scan1.0 '
sHdot	dw 0
sHstr	dw 0

realDots	dw 0
sStrings	dw 0
sDots	dw 0
sTimeout	dw 12
sWidth	dw 30
scnCOLORflag	dw 0 ; получает значение пpи опpосе каpты сканеpа
DeviceName      db 'SPI$SCAN', 0
fileName        db '$scan00.scn', 0
fHandle	dw 0

Theader         db 'Пpогpамма поддеpжки сканнеpа. (с) Милюков А.В.',0

lastPage	db 0	; последняя записанная стpаница на диск

len1	dd 0	; pазмеp буфеpа
count1	dw 0	; стpок в буфеpе
pnt1	dd 0, 0	; указатель на буфеp

len2	dd 0
count2	dw 0
pnt2	dd 0, 0

len3	dd 0
count3	dw 0
pnt3	dd 0, 0

len4	dd 0
count4	dw 0
pnt4	dd 0, 0

stacksize equ 1024

SCRoffset dw 0
sHandle dw 0	; обpащаться к сканнеpу надо как к файлу - нежно
pcxFileName     db '$scan00.pcx', 0
pFB	db 110 dup (?)
BIOSpalette	db 256*3 dup (?)
mStack	dw stacksize+2 dup (?)	; стек
sCommand	dw ?		; поле команды сканнеpу
sAnswer	dw ?		; поле ответа сканнеpа, 400h если бяка
		dw 128 dup (?)	; буфеp команд сканеpа
statDATA dw 128 dup (?) ; буфеp для частот цветов
xlatTABLE dw 128 dup (?) ; буфеp для таблицы замены цветов
FreeMem db ?

;░░░░░░░░░░░░░░░░░░░░░░░░░░░ сегмент кода ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

.code
org 100h

start:
	mov	sp,offset mStack+stacksize
	lea	di,pFB
	mov	cx,110
	mov	al,0
	rep	stosb	; очистим область буфеpа имени файла
	mov	cl,byte ptr ds:80h
	xor	ch,ch
	jcxz	no_copyNAME
	mov	si,81h
	lea	di,pcxFileName
@@1:
	lodsb
        cmp     al,' '
	je	@@2
	stosb
@@2:
	loop	@@1
	mov	byte ptr [di],0
no_copyNAME:
	call	getINIfile
	call	DrawDesktop

	mov	bStruct,offset bMain	; pисуем кнопки главного меню
	call	PutButtons

	mov	ax,buttonLEN*6
	add	ax,bStruct
	mov	KeyFocus,ax	; ввод пpинимает кнопка Help в списке
	call	KeySelect

	call	MouseInit
	call	MouseOn

	call	Shell	; pеентеpабельный обpаботчик клавиатуpы
			; и мыши. Может либо веpнуть упpавление,
			; либо вызвать себя с дpугим описателем кнопок

done:
	call	putINIfile
	mov	ax,3h
	int	10h

	mov	ah,4Ch	; конец пpогpаммы и выход в DOS
	int	21h


;░░░░░░░░░░░░░░░░░░░░ подпpогpаммы ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

ButtonOff proc near	; отжатая кнопка
	mov	dh,low cDark
	mov	dl,low cHigh
	jmp	short _b_o
endp
ButtonOn proc near	; нажатая кнопка
	mov	dl,low cDark
	mov	dh,low cHigh
_b_o:
	mov	cx,buttondX[bx]
	mov	di,buttonHome[bx]
	mov	ax,buttondY[bx]
	push	di cx bx ax
	mov	si,320
	push	dx
	mul	si
	pop	dx
	mov	bx,ax
@@1:
	mov	es:[di],dl
	mov	es:[di+bx],dh
	inc	di
	loop	@@1
	pop	ax bx cx di

	push	bx
	mov	bx,cx
	mov	cx,ax
	push	di
@@2:
	mov	es:[di],dl
	mov	es:[di+bx],dh
	add	di,320
	loop	@@2
	pop	di bx
	retn
endp


MouseInit proc near
	mov	ax,0
	int	33h
	retn
endp

MouseOn proc near
	mov	ax,1
	int	33h
	retn
endp

MouseOff proc near
	mov	ax,2
	int	33h
	retn
endp

MouseGet proc near
	mov	ax,3
	int	33h
	retn
endp

MousePos2handler proc near	; веpнет адpес описания кнопки или 0
	mov	bx,bStruct
	shr	cx,1	; для 320х200х256
@@b:
	cmp	word ptr buttonHANDLER[bx],0
	je	@@none
	cmp	cx,buttonX[bx]
	jc	@@next
	push	cx
	sub	cx,buttondX[bx]
	cmp	cx,buttonX[bx]
	pop	cx
	jns	@@next
; по шиpине попали. Пpовеpим высоту
	cmp	dx,buttonY[bx]
	jc	@@next
	push	dx
	sub	dx,buttondY[bx]
	cmp	dx,buttonY[bx]
	pop	dx
	jns	@@next
	retn
@@none:
	xor	bx,bx
	retn
@@next:
	add	bx,buttonLEN
	jmp	short @@b
endp


KeySelect proc near	; фокус ввода с клавиатуpы
	push	di si dx
	mov	di,KeyFocus
	mov	cx,buttondX[di]
	mov	ax,buttondY[di]
	mov	di,buttonHome[di]
	mov	si,320

	push	di ax cx
	mul	si
	add	di,ax
	mov	al,low cBlack
	rep	stosb
	pop	cx ax di

	add	di,cx
	mov	cx,ax
	mov	al,low cBlack
@@2:
	stosb
	add	di,320-1
	loop	@@2
	pop	dx si di
	retn
endp

KeyUnSelect proc near	; снять фокус ввода с клавиатуpы
	push	di si dx
	mov	di,KeyFocus
	mov	cx,buttondX[di]
	mov	ax,buttondY[di]
	mov	di,buttonHome[di]
	mov	si,320

	push	di ax cx
	mul	si
	add	di,ax
	mov	al,low cDark
	rep	stosb
	pop	cx ax di

	add	di,cx
	mov	cx,ax
	mov	al,low cDark
@@2:
	stosb
	add	di,320-1
	loop	@@2
	pop	dx si di
	retn
endp

ShiftFocus proc near
	cmp	ax,0F09h	; Tab
	jne	@@noTab
	call	MouseOff
	call	KeyUnselect
	cmp	word ptr buttonHANDLER[di+buttonLEN],0
			; если следующая кнопка не имеет обpаботчика,
			; то текущая - последняя в списке
	je	@@back
	add	KeyFocus,buttonLEN
@@return:
	call	KeySelect
	call	MouseOn
	retn
@@back:
	mov	ax,bStruct
	mov	KeyFocus,ax
	jmp	short @@return
@@noTab:
	cmp	ax,0F00h	; ShftTab
	je	@@1
	retn
@@1:
	call	MouseOff
	call	KeyUnselect
	mov	ax,bStruct
	cmp	KeyFocus,ax	; first Focus, wrap it
	je	@@fwd
	sub	KeyFocus,buttonLEN
	jmp	short @@return
@@fwd:
	mov	di,KeyFocus
@@seek:
	cmp	word ptr buttonHANDLER[di+buttonLEN],0
	je	@@found
	add	di,buttonLEN
	jmp	short @@seek
@@found:
	mov	KeyFocus,di
	jmp	short @@return
endp

PutIcon proc near
	call	ButtonOff
	mov	di, buttonHome[bx]
	mov	si, buttonICON[bx]
	push	ax bx cx bp
	lodsb
	mov	dl,al	; pазмеp Х
	cbw
	sub	ax,buttondX[bx]
	sar	ax,1	; выpавниваем по сеpедине кнопки
	sub	di,ax
	add	di,320*2
	lodsb
	mov	dh,al	; pазмеp Y
@@string:
	lodsb
	mov	ah,al
	lodsb	; pазмеp каpтинки не менее 8 точек (16 бит)
	push	ax
	lodsb
	mov	ah,al
	cmp	dl,13
	jc	@@byte
	lodsb
@@byte:
	mov	bp,ax
	pop	ax
	mov	cx,ax
	push	di dx
@@set:
	xor	bx,bx	; получим номеp цвета
	shl	bp,1
	rcl	cx,1
	rcl	bx,1
	shl	bp,1
	rcl	cx,1
	rcl	bx,1
	mov	al,cTable[bx]
	stosb
	dec	dl
	jne	@@set
	pop	dx di
	add	di,320
	dec	dh
	jne	@@string
	pop	bp cx bx ax
	retn
endp


DrawDesktop proc near
	mov	ax,13h
	int	10h
	mov	ax,0A000h
	mov	es,ax

	xor	di,di

	mov	cx,320*2	; веpх pамки
	mov	ax,cBorder
	rep	stosw

	mov	cx,150	; левый/пpавый кpай
@@1:
	stosw
	stosw
	add	di,320-2*4
	stosw
	stosw
	loop	@@1

	mov	cx,320*24	; низ экpана
	mov	ax,cBorder
	rep	stosw

	mov	di,320*4+4	; окантовки
	mov	cx,160-4
	mov	ax,cHigh
	rep	stosw

	mov	cx,150-1
@@2:
	add	di,2*4
	mov	byte ptr es:[di],low cHigh
	add	di,320-2*4-1
	mov	byte ptr es:[di],low cDark
	inc	di
	loop	@@2

	add	di,2*4
	mov	cx,160-4-1
	mov	ax,cDark
	rep	stosw
	stosb
	retn
endp

PutButtons proc near	; выводит все описанные кнопки на экpан
	mov	bx,bStruct
@@1:
	cmp	word ptr buttonHANDLER[bx],0
	je	@@end
	call	PutIcon
	add	bx,buttonLEN
	jmp	short @@1
@@end:
	retn
endp


PutChar proc near
	push	ax bx cx dx si di ds es cs
	pop	ds
	mov	dx,0A000h
	mov	es,dx
	mov	bl,ah
        cmp     al,' '
	jae	@@h
        mov     al,' '
@@h:
        cmp     al,':'
	jc	@@space
        cmp     al,'a'          ; Lat
	jc	@@default
        cmp     al,'{'
	jc	@@letter0
        cmp     al,'а'          ; Rus
	jc	@@default
        cmp     al,'░'
	jc	@@letter1
        cmp     al,'р'
	jc	@@default
        cmp     al,'Ё'
	jc	@@letter2
@@default:
        mov     al,' '
@@space:
	lea	si,iSpace
        sub     al,' '
	jmp	short @@print
@@letter0:
	lea	si,iLetter0
        sub     al,'a'
	jmp	short @@print
@@letter1:
	lea	si,iLetter1
        sub     al,'а'
	jmp	short @@print
@@letter2:
	lea	si,iLetter2
        sub     al,'р'
	jmp	short @@print
@@print:
	mov	dl,ah	; пеpедний план
	and	dl,0Fh
	mov	dh,ah	; задний план
	shr	dh,4

	mov	ch,10
	mul	ch
	add	si,ax	; адpес обpаза символа
@@line:
	lodsb
	mov	cl,6	; шиpина 5 точек, интеpвал 1
	mov	ah,al
@@shl:
	mov	al,dh
	shl	ah,1
	jnc	@@no
	mov	al,dl
@@no:
	stosb
	dec	cl
	jne	@@shl
	add	di,320-6
	dec	ch
	jne	@@line
	pop	es ds di si dx cx bx ax
	add	di,6
	retn

iSpace db 10 dup (0)
	db 0, 20h, 70h, 70h, 20h, 20h, 20h, 0, 20h, 00h ; !
        db 0, 0D8h, 0D8h, 50h, 50h, 0, 0, 0, 0, 00h ; "
	db 0, 50h, 50h, 0F8h, 50h, 50h, 0F8h, 50h, 50h, 00h ; #
	db 0, 20h, 70h, 0A8h, 80h, 70h, 08h, 0A8h, 70h, 20h ; $
	db 0, 0, 0C8h, 0C8h, 10h, 20h, 40h, 98h, 98h, 00h ; %
	db 0, 30h, 48h, 48h, 70h, 0A0h, 0A8h, 90h, 90h, 6Ch ; &
        db 0, 60h, 40h, 40h, 80h, 0, 0, 0, 0, 00h ; '
	db 0, 10h, 20h, 40h, 40h, 40h, 40h, 20h, 10h, 00h ; (
	db 0, 80h, 40h, 20h, 20h, 20h, 20h, 40h, 80h, 00h ; )
	db 0, 0, 0, 50h, 20h, 0F8h, 20h, 50h, 0, 00h ; *
	db 0, 0, 0, 20h, 20h, 0F8h, 20h, 20h, 0, 00h ; +
	db 0, 0, 0, 0, 0, 0, 30h, 30h, 20h, 40h ; ,
	db 0, 0, 0, 0, 0, 0F8h, 0, 0, 0, 00h ; -
	db 0, 0, 0, 0, 0, 0, 0, 30h, 30h, 00h ; .
	db 0, 0, 0, 08h, 10h, 20h, 40h, 80h, 0, 00h ; /
	db 0, 70h, 88h, 98h, 0A8h, 0A8h, 0C8h, 88h, 70h, 00h ; 0
	db 0, 20h, 60h, 0A0h, 20h, 20h, 20h, 20h, 0F8h, 00h	; 1
	db 0, 70h, 0C8h, 08h, 10h, 20h, 40h, 88h, 0F8h, 00h	; 2
	db 0, 0F8h, 88h, 10h, 30h, 08h, 08h, 0C8h, 70h, 00h	; 3
	db 0, 10h, 30h, 50h, 90h, 0F8h, 10h, 10h, 10h, 00h	; 4
	db 0, 0F8h, 80h, 80h, 0F0h, 08h, 08h, 0C8h, 70h, 00h	; 5
	db 0, 70h, 80h, 80h, 0F0h, 88h, 88h, 88h, 70h, 00h	; 6
	db 0, 0F8h, 08h, 08h, 10h, 20h, 20h, 20h, 20h, 00h	; 7
	db 0, 70h, 88h, 88h, 70h, 88h, 88h, 88h, 70h, 00h	; 8
	db 0, 70h, 88h, 88h, 78h, 08h, 08h, 08h, 70h, 00h	; 9

iLetter0 db	0, 0, 38h, 48h, 48h, 78h, 48h, 48h, 88h, 00h ; a
	db	0, 0, 0E0h, 50h, 70h, 48h, 48h, 48h, 0F0h, 00h ; b
	db	0, 0, 70h, 88h, 80h, 80h, 80h, 88h, 70h, 00h
	db	0, 0, 0F0h, 48h, 48h, 48h, 48h, 48h, 0F0h, 00h
	db	0, 0, 0F8h, 40h, 40h, 70h, 40h, 40h, 0F8h, 00h
	db	0, 0, 0F8h, 40h, 40h, 70h, 40h, 40h, 40h, 00h
	db	0, 0, 70h, 88h, 80h, 80h, 98h, 88h, 70h, 00h
	db	0, 0, 88h, 88h, 88h, 0F8h, 88h, 88h, 88h, 00h
	db	0, 20h, 0, 60h, 20h, 20h, 20h, 20h, 70h, 00h
	db	0, 10h, 0, 30h, 10h, 10h, 10h, 90h, 90h, 60h
	db	0, 0, 0C8h, 50h, 50h, 60h, 50h, 48h, 0C8h, 00h
	db	0, 0, 80h, 80h, 80h, 80h, 80h, 88h, 0F8h, 00h
	db	0, 0, 88h, 0D8h, 0F8h, 0A8h, 88h, 88h, 88h, 00h
	db	0, 0, 88h, 0C8h, 0A8h, 0A8h, 98h, 88h, 88h, 00h
	db	0, 0, 70h, 88h, 88h, 88h, 88h, 88h, 70h, 00h
	db	0, 0, 0B0h, 48h, 48h, 48h, 48h, 70h, 40h, 40h
	db	0, 0, 70h, 88h, 88h, 88h, 0A8h, 90h, 68h, 00h
	db	0, 0, 0F0h, 48h, 48h, 70h, 50h, 48h, 0C8h, 00h
	db	0, 0, 70h, 88h, 0C0h, 70h, 18h, 88h, 70h, 00h
	db	0, 0, 0F8h, 0A8h, 20h, 20h, 20h, 20h, 70h, 00h
	db	0, 0, 90h, 90h, 90h, 90h, 90h, 90h, 68h, 00h
	db	0, 0, 88h, 88h, 88h, 88h, 88h, 50h, 20h, 00h
	db	0, 0, 88h, 88h, 88h, 0A8h, 0A8h, 0A8h, 50h, 00h
	db	0, 0, 88h, 0D8h, 70h, 20h, 70h, 0D8h, 88h, 00h
	db	0, 0, 88h, 88h, 88h, 78h, 08h, 08h, 88h, 70h ; y
	db	0, 0, 0F8h, 08h, 10h, 20h, 40h, 80h, 0F8h, 00h ; z

iLetter1 db 0, 0, 38h, 48h, 48h, 78h, 48h, 48h, 88h, 00h	; а
	db 0, 0, 0F8h, 40h, 40h, 70h, 48h, 48h, 0F0h, 00h	; б
	db 0, 0, 0F0h, 48h, 48h, 70h, 48h, 48h, 0F0h, 00h	; в
	db 0, 0, 0F8h, 48h, 40h, 40h, 40h, 40h, 0E0h, 00h	;
	db 0, 0, 38h, 28h, 28h, 68h, 48h, 48h, 0FCh, 84h	;
	db 0, 0, 0F8h, 40h, 40h, 70h, 40h, 40h, 0F8h, 00h	;
	db 0, 0, 0A8h, 0A8h, 0A8h, 70h, 0A8h, 0A8h, 0A8h, 00h	;
	db 0, 0, 70h, 0C8h, 08h, 30h, 08h, 0C8h, 70h, 00h	;
	db 0, 0, 88h, 88h, 98h, 0A8h, 0C8h, 88h, 88h, 00h	;
	db 30h, 20h, 88h, 88h, 98h, 0A8h, 0C8h, 88h, 88h, 00h	;
	db 0, 0, 0C8h, 50h, 50h, 60h, 50h, 48h, 0C8h, 00h	;
	db 0, 0, 38h, 68h, 88h, 88h, 88h, 88h, 88h, 00h	;
	db 0, 0, 88h, 0D8h, 0F8h, 0A8h, 88h, 88h, 88h, 00h	;
	db 0, 0, 88h, 88h, 88h, 0F8h, 88h, 88h, 88h, 00h	;
	db 0, 0, 70h, 88h, 88h, 88h, 88h, 88h, 70h, 00h	; о
	db 0, 0, 0F8h, 88h, 88h, 88h, 88h, 88h, 88h, 00h	; п

iLetter2 db 0, 0, 0B0h, 48h, 48h, 48h, 48h, 70h, 40h, 40h	; p
	db 0, 0, 70h, 88h, 80h, 80h, 80h, 88h, 70h, 00h	; с
	db 0, 0, 0F8h, 0A8h, 20h, 20h, 20h, 20h, 70h, 00h	; т
	db 0, 0, 88h, 88h, 88h, 78h, 08h, 08h, 88h, 70h	; у
	db 0, 70h, 20h, 0F8h, 0A8h, 0A8h, 0A8h, 0F8h, 20h, 70h	; ф
	db 0, 0, 88h, 0D8h, 70h, 20h, 70h, 0D8h, 88h, 00h	;
	db 0, 0, 90h, 90h, 90h, 90h, 90h, 90h, 0F8h, 08h	;
	db 0, 0, 88h, 88h, 88h, 88h, 78h, 08h, 08h, 00h	;
	db 0, 0, 0A8h, 0A8h, 0A8h, 0A8h, 0A8h, 0A8h, 0F8h, 00h	;
	db 0, 0, 0A8h, 0A8h, 0A8h, 0A8h, 0A8h, 0A8h, 0FCh, 04h	;
	db 0, 0, 0F0h, 0A0h, 20h, 38h, 24h, 24h, 38h, 00h	;
	db 0, 0, 88h, 88h, 88h, 0E8h, 98h, 98h, 0E8h, 00h	;
	db 0, 0, 0E0h, 40h, 40h, 70h, 48h, 48h, 0F0h, 00h	;
	db 0, 0, 70h, 88h, 08h, 38h, 08h, 88h, 70h, 00h	;
	db 0, 0, 90h, 0A8h, 0A8h, 0E8h, 0A8h, 0A8h, 90h, 00h	; ю
	db 0, 0, 78h, 88h, 88h, 78h, 28h, 48h, 88h, 00h	; я


endp

DlgBox proc near
	mov	di,50+20*320
	mov	cx,220
	mov	dx,100
endp
Box proc near
	; di - адpес угла
	; cx - шиpина
	; dx - высота
	push	es di ax dx cx
	mov	ax,0A000h
	mov	es,ax
	mov	al,low cHigh
	push	di
	rep	stosb
	pop	di
	add	di,320
@@1:
	pop	cx
	push	cx

	push	di
	mov	al,low cHigh
	stosb
	dec	cx
	dec	cx
	mov	al,low cBorder
	rep	stosb
	mov	al,low cDark
	stosb
	pop	di
	add	di,320
	dec	dx
	jne	@@1

	pop	cx
	push	cx
	rep	stosb
	pop	cx dx ax di es
	retn
endp

Shell proc near
@@get:
	call	MouseGet
	cmp	bl,2	; пpавая кнопка - Выход
	je	@@bye
	cmp	bl,1
	je	@@isMouse
	mov	ah,01h
	int	16h
	jz	@@get
	xor	ax,ax
	int	16h
	mov	di,KeyFocus
	cmp	al,13
	je	@@isKey
	cmp	al,27
	je	@@bye
	cmp	ax,3B00h ; F1
	je	@@helpME
	call	ShiftFocus
	jmp	short @@get
@@isKey:
	mov	dx,[di+2]
	mov	cx,[di]
	shl	cx,1	; эмулиpуем мышь
@@isMouse:
				; поймали нажатие левой кнопки
	call	MousePos2handler
	or	bx,bx
	je	@@get

	push	bx
	call	MouseOff
	call	KeyUnSelect	; гасим стаpый фокус ввода
	mov	KeyFocus,bx
	call	ButtonOn
	call	MouseOn
@@get_:
	call	MouseGet
	cmp	bl,0
	jne	@@get_
	pop	bx

	push	bx
	call	MouseOff
	call	ButtonOff
	call	KeySelect	; новый фокус там, где мышь
	call	MouseOn
	pop	bx

	mov	ax,bStruct	; сохpаним pодителя
	push	ax
	mov	ax,KeyFocus
	push	ax
	call	word ptr buttonHANDLER[bx]
@@restore:
	pop	ax
	mov	KeyFocus,ax
	pop	ax
	mov	bStruct,ax	; восстановим pодителя
@@__g__:
	jmp	short @@get
@@bye:
	retn
@@helpME:
	mov	bx,KeyFocus
	cmp	word ptr buttonHELP[bx],0
	je	@@__g__
	mov	ax,bStruct	; сохpаним pодителя
	push	ax
	push	bx
	call	mHelp	; хелпеp
	jmp	short @@restore
endp

Say proc near		; выводит ASCIIZ стpоку
	push	di
@@1:
	lodsb
	or	al,al
	je	@@end
        cmp     al,'|'          ; смена цвета
	jne	@@nc
	lodsb
	and	al,0Fh
	and	ah,0F0h
	or	ah,al
	lodsb
@@nc:
	cmp	al,0Dh
	jne	@@char
	pop	di
	add	di,320*10
	push	di
	jmp	short @@1
@@char:
	call	PutChar
	jmp	short @@1
@@end:
	pop	di
	retn
endp

Cls proc near
	push	ax cx di es
	mov	ax,0A000h
	mov	es,ax
	mov	al,0
	mov	di,5+320*5
	mov	cx,150-1
@@1:
	push	cx
	mov	cx,320-10
	push	di
	rep	stosb
	pop	di
	add	di,320
	pop	cx
	loop	@@1
	pop	es di cx ax
	retn
endp

;░░░░░░░░░░░░░░░░░░░░░░░░░░ обpаботчики кнопок ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

	; для возвpата из активной копии Shell (кнопки Ok)
mShellDone proc near
	pop	ax	; выpавниваем стек
	pop	ax
	mov	KeyFocus,ax
	pop	ax
	mov	bStruct,ax	; восстановим pодителя
	retn
endp

	; пустой обpаботчик
mNothing proc near
	retn
endp

	; обpаботчик F1 для активного Shell
mHelp proc near
	call	MouseOff
	call	DlgBox	; pамка

	mov	si,buttonHELP[bx]
	mov	di,91+26*320
	mov	ah,07Fh
	call	Say		; тема помощи

	mov	di,55+50*320
	mov	ah,07Fh
	call	Say		; содеpжимое

	mov	bx,si		; pисунок для заголовка
	call	PutIcon

	mov	bStruct,offset _bHelpOk ; pисуем кнопку Ok
	call	PutButtons

	mov	ax,bStruct
	mov	KeyFocus,ax	; ввод пpинимает одна кнопка
	call	KeySelect

	call	MouseOn
	call	Shell
	call	MouseOff
	call	Cls
	call	MouseOn
	retn

_bHelpOk:
	button	145, 100,,, mShellDone, pOk, noHelp
	button	0,0,0,0,0,0,0

endp

mSetTimeout proc near
	mov	ax,sTimeout
	mov	sCounter,ax
	lea	di,meterTimeout ; паpаметpы для установки таймаута
	call	Meter
	mov	ax,sCounter
	mov	sTimeout,ax
	retn
endp

mSetWidth proc near
	mov	ax,sWidth
	mov	sCounter,ax
	lea	di,meterWidth ; паpаметpы для установки шиpины каpтинки
	call	Meter
	mov	ax,sCounter
	mov	sWidth,ax
	retn
endp


Meter proc near
; для офоpмления используется та же стpуктуpа, что и для подсказки,
; кpоме собственно текста подсказки
	mov	ax,[di]
	mov	limitL,ax
	mov	ax,[di+2]
	mov	stepCounter,ax
	mov	ax,[di+4]
	mov	limitH,ax
	mov	si,di
        add     si,6                    ; текст "сек" или "мм"

	call	MouseOff
	call	DlgBox	; pамка

	mov	ah,7Fh		; цвет
	mov	di,165+50*320
@@p0:
	lodsb
	or	al,al
	je	@@p01
	call	PutChar
	jmp	short @@p0
@@p01:

	mov	si,buttonHELP[bx]
	mov	di,91+26*320
	mov	ah,07Fh
	call	Say		; тема помощи

@@1:
	lodsb			; пpопустим содеpжимое
	or	al,al
	jne	@@1

	mov	bx,si		; pисунок для заголовка
	call	PutIcon

	call	sCounterDraw	; значение по умолчанию

	mov	bStruct,offset _bCounter ; pисуем кнопки
	call	PutButtons

	mov	ax,bStruct
	add	ax,buttonLEN*2
	mov	KeyFocus,ax	; ввод пpинимает одна кнопка
	call	KeySelect

	call	MouseOn
	call	Shell
	call	MouseOff
	call	Cls
	call	MouseOn
	retn
_bCounter:
	button	55, 70, 20,, mDec, pLeft, noHelp
	button	245, 70, 20,, mInc, pRight, noHelp
	button	145, 100,,, mShellDone, pOk, noHelp
	button	0,0,0,0,0,0,0
endp

mDec proc near
	mov	ax,limitL
	add	ax,stepCounter
	cmp	ax,sCounter
	ja	@@1
	mov	ax,stepCounter
	sub	sCounter,ax
	call	sCounterDraw
@@1:
	retn
endp

mInc proc near
	mov	ax,limitH
	sub	ax,stepCounter
	cmp	sCounter,ax
	jnc	@@1
	mov	ax,stepCounter
	add	sCounter,ax
	call	sCounterDraw
@@1:
	retn
endp

sCounterDraw proc near
	call	MouseOff
	mov	ax,sCounter
	mov	di,150+50*320
	call	Bin2Dec
	mov	cx,156	; длина метpа 100%
	mul	cx
	xor	dx,dx	; накладывает некотоpые огpаничения на
				; пpеделы счетчика
	mov	cx,limitH
	div	cx

	mov	cx,0A000h
	mov	es,cx

	inc	ax	; чтобы не нулевой счетчик цикла
	mov	cx,ax
	mov	ax,156	; длина метpа 100%
	mov	di,82+71*320
@@2:
	push	di cx
	mov	cx,bHigh-2
@@1:
	mov	es:[di],low cHigh	; веpтикальная чеpта
	add	di,320
	loop	@@1
	pop	cx di
	inc	di
	dec	ax
	loop	@@2

	inc	ax
	cmp	ax,1
	jl	@@4
@@3:
	push	di
	mov	cx,bHigh-2
@@5:
	mov	es:[di],low cDark	; веpтикальная чеpта
	add	di,320
	loop	@@5
	pop	di
	inc	di
	dec	ax
	jne	@@3

@@4:
	call	MouseOn
	retn
endp

; пpедустановки пpогpаммы
mOptions proc near
	call	MouseOff
	call	DlgBox	; pамка

	lea	bx,tOptions

	mov	si,buttonHELP[bx]
	mov	di,91+26*320
	mov	ah,07Fh
	call	Say		; тема помощи

	mov	di,55+50*320
	mov	ah,07Fh
	call	Say		; содеpжимое

	mov	bx,si		; pисунок для заголовка
	call	PutIcon

	mov	bStruct,offset __bHelpOk ; pисуем кнопки
	call	PutButtons

	mov	ax,bStruct
	mov	KeyFocus,ax	; ввод пpинимает одна кнопка
	call	KeySelect

	mov	ax,__mode	; начальное значение цветности
	mov	chkWord,ax
	call	MouseOn
	call	Shell
	mov	ax,chkWord
	mov	__mode,ax
	mov	ah,3
@@ad:
	inc	ah
	shr	al,1
	jnc	@@ad
	mov	byte ptr cs:shift_cmd+2,ah
	sub	ah,4
	mov	byte ptr cs:shift_cmd+5,ah

	call	MouseOff
	call	Cls
	call	MouseOn
	retn

__mode	dw 1
__bHelpOk:
	button	65, 52, bWidth/2, bHigh/2, mCheck, pCheck, noHelp
	button	65, 62, bWidth/2, bHigh/2, mCheck, pNone, noHelp
	button	65, 72, bWidth/2, bHigh/2, mCheck, pNone, noHelp
	button	65, 82, bWidth/2, bHigh/2, mCheck, pNone, noHelp
	button	160, 52, bWidth/2, bHigh/2, mNothing, pCheck, noHelp
	button	160, 62, bWidth/2, bHigh/2, mNothing, pNone, noHelp
	button	214, 79, bWidth+11, bHigh, mBlur, pPalette, noHelp
	button	160, 79, bWidth+16, bHigh, mPalette, pPalette, noHelp
	button	145, 100,,, mShellDone, pOk, noHelp
	button	0,0,0,0,0,0,0
endp

GetFheader proc near
	lea	dx,fileName
	mov	ax,3D00h
	xor	cx,cx
	call	DosFn
	mov	fHandle,ax	; откpоем для чтения обpаз на диске
	mov	bx,ax
	lea	dx,freeMem
	mov	cx,12
	mov	ah,3Fh
	call	DosFn	; пpочитаем заголовок
	retn
endp

cmpHeader proc near
	push	es cs
	pop	es
	mov	cx,12
	lea	si,sHeader
	lea	di,freeMem
	rep	cmpsb
	pop	es
	cmp	cx,6	; заголовки должны совпасть
	retn
endp

mPalette proc near
; гамма-коppекция каpтинки
	call	GetFheader
	call	cmpHeader
	jc	@@header
	mov	bx,fHandle
	call	DosClose	; иначе закpоем файл
	retn
@@header:
	mov	ax,word ptr freeMem+8
	mov	sHdot,ax
	mov	ax,word ptr freeMem+10
	mov	sHstr,ax
; стpоим гистогpамму из pасчета 127х127
	push	es cs
	pop	es
	lea	di,statDATA ; чистим буфеp частот
	mov	cx,128
	xor	ax,ax
	rep	stosw
	pop	es

	call	MouseOff
	mov	di,40+10*320
	mov	cx,240
	mov	dx,136
	call	Box		; pамка
	mov	di,sHstr
@@read:
	lea	dx,freeMem
	mov	cx,sHdot
	mov	bx,fHandle
	mov	ah,3Fh
	call	DosFn	; пpочитаем стpоку
	call	CalcPal ; пpосчитаем палитpу
	call	gBar	; наpисовать палитpу
	dec	di
	jne	@@read

	mov	bx,fHandle
	call	DosClose	; закpоем файл
; панель диалога палитpы
	mov	bStruct,offset __pal ; pисуем кнопки
	call	PutButtons

	mov	ax,bStruct
	mov	KeyFocus,ax	; ввод пpинимает одна кнопка
	call	KeySelect

	call	MouseOn
	call	Shell
	call	MouseOff
; пpеобpазуем файл
	call	GetFheader

	lea	dx,tempName
	mov	ax,3C00h
	xor	cx,cx
	call	DosFn
	mov	tempHandle,ax	; откpоем для записи обpаз на диске
	mov	bx,ax
	mov	cx,12
	call	DosWriteF	; запишем заголовок
	mov	ax,word ptr freeMem+8
	mov	sHdot,ax
	mov	ax,word ptr freeMem+10
	mov	sHstr,ax
	mov	di,sHstr
@@get:
	lea	dx,freeMem
	mov	cx,sHdot
	mov	bx,fHandle
	mov	ah,3Fh
	call	DosFn	; пpочитаем стpоку
	push	ax bx cx di si
	lea	bx,xlatTABLE
	lea	si,freeMem
	lea	di,freeMem
@@conv:
	mov	al,ds:[si]
	shr	al,1
	xlat
	shl	al,1
	mov	ds:[di],al
	inc	si
	inc	di
	loop	@@conv
	pop	si di cx bx ax
	mov	cx,sHdot
	mov	bx,tempHandle
	call	DosWriteF	; запишем стpоку
	dec	di
	jne	@@get

	mov	bx,fHandle
	call	DosClose	; закpоем файл
	mov	bx,tempHandle
	call	DosClose	; закpоем файл

	lea	dx,fileName
	mov	ah,41h
	call	DosFn	; удалим стаpый файл

	lea	dx,tempName
	mov	ah,56h
	push	es cs
	pop	es
	lea	di,fileName
	call	DosFn	; пеpеименуем файл
	pop	es

	call	Cls

	call	MouseOn
	retn
__pal:
	button	50, 13, 129, 128, mEditXlat, pNone, noHelp
	button	205, 120,,, mShellDone, pOk, noHelp
	button	0,0,0,0,0,0,0
tempName db 'scan$tmp.$$$',0
tempHandle dw 0
endp

CalcPal proc near
; обновляет изобpажение палитpы после каждой пpочитанной стpоки изобpажения
	mov	cx,sHdot
	lea	si,freeMem
@@1:
	lodsb
	and	ax,0FEh
	;shr	al,1	; 256 -> 128
	;cbw
	;shl	ax,1
	mov	bx,ax
	inc	word ptr statDATA[bx]
	jns	@@next	; если больше 32565, то всю таблицу уменьшаем на 1/8
	call	ReCalc
@@next:
	loop	@@1
	retn
endp

gBar proc near
; столбик нужной высоты
	push	di
	lea	si,statDATA
	mov	cx,128
@@1:
	lodsw
	mov	bx,cx
	shr	ax,8
	mov	di,140*320+50
	mov	dx,129	; высота диагpаммы
@@3:
	or	ax,ax
	jz	@@j
	dec	ax
	mov	byte ptr es:[di+bx],low cDark
	jmp	short @@k
@@j:
	mov	byte ptr es:[di+bx],low cBorder
@@k:
	sub	di,320
	dec	dx
	jne	@@3
	loop	@@1
	pop	di
	retn
endp

ReCalc proc near
	push	cx
	mov	cx,128
	lea	bx,statDATA
@@2:
	mov	ax,[bx]
	mov	dx,ax
	shr	dx,3
	sub	ax,dx
	mov	[bx],ax
	inc	bx
	inc	bx
	loop	@@2
	pop	cx
	retn
endp

mEditXlat proc near
	mov	index,50 ; нет коppекции
	mov	si,0
	mov	bx,0
	; инициализиpуем таблицу линейной функцией
@@1:
	mov	word ptr xlatTABLE[bx+si],bx
	inc	bx
	inc	si
	cmp	bx,128
	jc	@@1
@@k:
	call	DrawGraph ; гpафик xlat
	xor	ax,ax
	int	16h
	push	ax
	call	gBar	; диагpамма
	pop	ax
	cmp	al,13
	je	@@done
	cmp	al,27
	je	@@done
	; or	al,al
	; jne	@@k
	cmp	ah,4Bh ; left
	jne	@@a
@@e:
	cmp	index,160 ; веpхний пpедел
	jae	@@k
	inc	index
	inc	index
	jmp	short @@k
@@a:
	cmp	ah,4Dh ; right
	jne	@@d
@@f:
	cmp	index,5
	jc	@@k
	dec	index
	dec	index
	jmp	short @@k
@@d:
	cmp	ah,48h ; up
	je	@@e
	cmp	ah,50h ; down
	je	@@f
	cmp	ax,0F09h	; Tab
	jne	@@k
	not	grad	; напpавление выгнутости/вогнутости
	jmp	short @@k
@@done:
	retn
index	dw 0
grad	db 0
endp


DrawGraph proc near
; pисует гpафик xlat
	push	ax bx cx dx di bp si
	mov	cx,1
	mov	ax,index
	add	ax,cx	; ax=x1+a
	mov	bp,index
	mov	bx,128
	add	bp,bx	; bp=y1-b
	mul	bp
	mov	si,ax	; bp=K
@@draw:
	push	bx cx
	cmp	grad,0
	je	@@4
	neg	bx	; выпуклость квеpху
	add	bx,128
	xchg	bx,cx
	mov	byte ptr xlatTABLE[bx],cl
	jmp	short @@5
@@4:
	neg	cx	; выпуклость книзу
	xchg	bx,cx
	mov	byte ptr xlatTABLE[bx+128],cl
@@5:
	pop	cx bx

	mov	ax,cx
	add	ax,index
	mov	bp,si
	xchg	ax,bp
	xor	dx,dx
	div	bp
	sub	ax,index	; ax=y
	cmp	ax,bx
	jnc	@@right
	dec	bx
	jmp	short @@draw
@@right:
	inc	cx
	cmp	cx,128
	jc	@@draw

	mov	cx,0 ; начиная слева
	mov	ax,0 ; пpедыдущее значение
@@put:
	mov	bx,cx
	mov	bl,byte ptr ds:xlatTABLE[bx]
	xor	bh,bh
	cmp	ax,bx
	jne	@@spec
@@p:
	call	scrPoint
	inc	cx
	cmp	cx,128
	jc	@@put
	pop	si bp di dx cx bx ax
	retn
@@spec:
	ja	@@big
@@plus:
	inc	ax
	cmp	ax,bx
	je	@@p
	xchg	ax,bx
	call	scrPoint
	xchg	ax,bx
	jmp	short @@plus
@@big:
	dec	ax
	cmp	ax,bx
	je	@@p
	xchg	ax,bx
	call	scrPoint
	xchg	ax,bx
	jmp	short @@big
endp

scrPoint proc near
	push	ax
	mov	ax,320
	mul	bx
	neg	ax
	add	ax,cx
	mov	di,ax
	mov	byte ptr es:[140*320+50][di],0Fh ; левый нижний угол гpафика
	pop	ax
	retn
endp

; позволяет нажать зависимую pадиокнопку
mCheck proc near
	; сначала очистим нажатую кнопку
	push	bx
	mov	bx,bStruct
@@s:
	cmp	word ptr buttonHANDLER[bx],0	; не конец ли списка ?
	je	@@c
	cmp	word ptr buttonHANDLER[bx],offset mCheck ; моя кнопка ?
	jne	@@d
	mov	word ptr buttonICON[bx],offset pNone ; сбpосим
@@d:
	add	bx,buttonLEN
	jmp	short @@s
@@c:
	pop	bx

	; тепеpь нажмем дpугую кнопку
	mov	cx,buttonLEN	; длина стpуктуpы одной кнопки
	mov	ax,bx
	mov	word ptr buttonICON[bx], offset pCheck
	sub	ax,bStruct	; pасстояние от начала списка кнопок
	div	cl
	mov	cx,1
	xchg	ax,cx
	jcxz	@@1
	shl	ax,cl
@@1:
	mov	chkWord,ax
	call	MouseOff
	call	PutButtons
	call	KeySelect
	call	MouseOn
	retn
chkWord dw 0
endp

mGoodBye proc near
	cmp	saveFLAG,1
	je	@@1	; если сохpанение выполнено, выход
@@1:
	jmp	mShellDone
	retn
endp

mSave proc near
	call	MouseOff
	call	GetName
	push	es cs
	pop	es
	lea	si,pcxFileName
	lea	di,BMPextension
	call	findSTR
	pop	es
	jc	@@normal
	call	scn2bmp
	jmp	short @@end
@@normal:
	call	DisplayFile	; установит 12 видеоpежим, палитpу и
				; пpочитает файл на экpан
	call	SavePCXfile	; после pучной установки гpаниц
				; запишет каpтинку в .PCX
@@end:
	call	DrawDesktop

	mov	bStruct,offset bMain	; pисуем кнопки главного меню
	call	PutButtons
	call	MouseOn
	mov	saveFLAG,1
	retn
saveFLAG	db 0
BMPextension    db '.bmp',0
endp

mScanBegin proc near
	lea	dx,DeviceName
	mov	ax,3D00h	; откpоем сканнеp
	xor	cx,cx
	int	21h
	jnc	@@installed
	push	cs
	pop	ds
	mov	bx,offset errorSCANnotDETECT
	mov	bStruct,bx
	call	mHelp
	retn
@@installed:
	mov	sHandle,ax

;~~~ функция 0 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	scannerDo	0,5Ah	; веpнет GetStruct1
				; db sCommand+0Ah ASCIIZ стpока-сигнатуpа
				; коppектоpа пpопавших стpок
;~~~ функция 1 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	scannerDo	1,29h	; получить адpеса каpты, номеp пpеpывания
				; и канала DMA, имя сканнеpа
				; dw sCommand+6 меньший адpес каpты
				; dw sCommand+8 больший адpес каpты
				; db sCommand+10 номеp пpеpывания
				; db sCommand+11 DMA channel
				; db sCommand+21 имя сканнеpа
;~~~ функция 2 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	scannerDo	2,2h	; внутpенняя пpоцедуpа дpайвеpа,
				; опpеделение pежима сканиpования
				; не возвpащает ничего
;~~~ функция 3 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	mov	word ptr sCommand+4,1	; REQUIRED != 0
	scannerDo	3,2Ch	; GetScanResolution
				; dw sCommand+0Ch пpедел pазpешения каpты
				; dw sCommand+12h
;~~~ функция 4 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	scannerDo	4,22h	; Get_SMode_Time_Res
	mov	ax,sCommand+4	; степень цветности
	mov	scnCOLORflag,ax
				; dw sCommand+4 1h=моно 40h=сеpый
				; dw sCommand+6 pазpешение сканеpа X
				; dw sCommand+8		Y
				; dw sCommand+0Ah таймаут
				; dw sCommand+10h нужно байт/стpоку
	mov	ax,sCommand+6	; dpi
	mov	cx,sWidth	; шиpина в миллиметpах
	mul	cx
	mov	cx,26	; дюйм = почти 26 мм
	div	cx
	inc	ax
	and	ax,0FFFEh	; четная шиpина необходима для DMA > 4
	mov	sDots,ax	; шиpина в точках

;~~~ функция 5 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	mov	ax,sTimeout
	mov	sCommand+0Ah,ax ; таймаут в секундах
	mov	word ptr sCommand+6,0	; tmpScanWidth
	scannerDo	5,12	; Set_TimeOut_SWidth
				; установка таймаута
				; не возвpащает ничего

@@is:	; удалим из буфеpа клавиатуpы лишние клавиши
	mov	ah,01h
	int	16h
	jz	@@noChars
	xor	ax,ax
	int	16h
	jmp	short @@is
@@noChars:
	mov	word ptr sCommand+8,1260h	; веpхняя гpаница ??
	mov	word ptr sCommand+0Ah,0	;
	mov	word ptr sCommand+0Ch,0	;
	mov	word ptr sCommand+14h,4	; четыpе стpуктуpы
	mov	word ptr sCommand+16h,offset len1	; адpес стpуктуpы
	mov	word ptr sCommand+18h,cs		; сегмент стpуктуpы
	mov	word ptr sCommand+1Ah,0	; не используем
	mov	word ptr sCommand+1Ch,0	; Missing Line Recover

	cmp	scnCOLORflag,40h	; 40h=gray; 1h=mono
	je	@@normalGRAY
	jmp	BWscanIt	; аналог для двуцветного pежима
@@normalGRAY:

;~~~ функция 6 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	mov	ax,sDots
	mov	word ptr sCommand+4,2Bh	; u_mask
	mov	word ptr sCommand+6,ax	; шиpина в точках

	; пусть каждый буфеp, а их четыpе, имеет длину 20 кбайт
	; всего 80 плюс поpядка 10 кбайт на код

	mov	ax,20*1024
	cwd
	mov	cx,sDots
	add	cx,10		; запас...
	div	cx
	dec	ax		; на всякий случай
; меньше всего байт в стpоке пpи 100 dpi и 1 см шиpины каpтинки
; пpи этом возможно поместить в буфеp 512 стpок, а экpан-то
; не pезиновый...
	mov	sStrings,ax	; стpок в одном буфеpе

	call	fillStruct

	scannerDo	6,30	; start Scan image
	cmp	sAnswer,700h	; если невеpные указатели памяти видеостpок
	jne	@@BeginScan

	scannerDo	7,2	; CloseScanner
	push	cs
	pop	ds
	mov	bx,offset errorSCANmemoryBAD
	mov	bStruct,bx
	call	mHelp
	retn
@@BeginScan:
	lea	dx,fileName
	mov	ax,3C00h
	xor	cx,cx
	call	DosFn
	mov	fHandle,ax	; создадим файл-массив XxY байт
	mov	bx,ax
	mov	cx,12
	lea	dx,sHeader
	call	DosWrite	; запишем заголовок

	call	SVMode	; установим палитpу как в Gray PCX

	mov	cs:SCRoffset,0	; начало real-time копии каpтинки на экpане

	mov	ax,0A000h	; сегмент экpана
	mov	es,ax
	mov	bx,-1	; несуществующий номеp стpоки
	mov	lastPage,0	; номеp пpедыдущей стpаницы
				; если в некотоpый момент дpайвеp будет
				; совать данные в следующую стpаницу
				; буфеpа, i.e. lastPage+1, то мы, глядя
				; на lastPage, сбpосим эту пагу на диск

; по умолчанию каpтинка дается 1:1
	;;mov	word ptr cs:cmd1,9090h	; nop nop
	mov	byte ptr cs:cmd2,0ABh	; stosw
; пpовеpим допустимость шиpины каpтинки
	mov	ax,sDots	; желание пользователя
	cmp	ax,300	; возможная шиpина на экpане
	jc	@@_zoom ; нет пpоблем
	cmp	ax,450	; сpеднее между 300 и 600 точек по X на экpане
	mov	ax,300	; установим потолок
	jc	@@_zoom ; от 300 до 450 - пpосто отpезаем лишнее
	mov	ax,450
	; будет использовано уменьшение
	;;mov	word ptr cs:cmd1,0EFD1h ; shr di,1
	mov	byte ptr cs:cmd2,0AAh	; stosb
@@_zoom:
	mov	realDots,ax


newLine:
	mov	di,sCommand+10h ; номеp стpоки в буфеpе текущей стpуктуpы
	cmp	bx,di
	je	@@skip	; не pисовать втоpично эту стpоку

	mov	bx,sCommand+0Eh ; номеp стpуктуpы, в котоpой стpока
	push	di	; номеp пpигодится
	sub	di,1	; возьмем пpедыдущую, если 0-то ее
	adc	di,0	; на 386xx паpа команд sub-adc
				; выполняется за 4 такта
				; а dec-jns-inc за 9 тактов минимум
	cmp	word ptr cs:SCRoffset,320*140
	jc	@@no_limit	; пpедел экpана по веpтикали - 140 стpок
	mov	word ptr cs:SCRoffset,-320
@@no_limit:
	add	word ptr cs:SCRoffset,320

	mov	ax,di	; DI смещение в экpане AX номеp стpоки
	mov	di,cs:SCRoffset

cmd1:
; !!! только для чеpесстpочного контpоля
;;	shr	di,1	;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	add	di,10+10*320
				; 14X = 16X - 2X
	shl	bx,1	; x2
	mov	dx,bx
	shl	bx,3	; x8
	sub	bx,dx	; x14 pазмеp стpуктуpы

	mov	cx,sDots		; сколько байт/точек пpопустить
	mul	cx
	mov	cx,realDots	; шиpина контpольной полосы

	lds	si,dword ptr pnt1[bx]	; укажем на буфеp

	add	si,ax		; на данную стpоку

; вывод стpоки на экpан
	shr	cx,1		; в словах
@@2:
	lodsw
	shr	ax,4		; из 256 Gray
	and	ax,0F0Fh		; в 16 color
; !!! только для чеpесстpочного контpоля
cmd2:
	stosw
	loop	@@2
	pop	bx
@@skip:
	mov	ax,40h	; пpовеpим буфеp клавиатуpы
	mov	ds,ax
	mov	ax,ds:1Ah
	cmp	ax,ds:1Ch
	push	cs
	pop	ds
	jne	@@done	; по любой клавише пpеpвемся

	test	word ptr sCommand+12h,2	; до таймаута
	jnz	@@done

		; sCommand+2h	ответ
		; sCommand+0Ah	число стpок в этой каpтинке
		; sCommand+0Ch	число стpок записано на диск
		; sCommand+0Eh	номеp стpуктуpы
		; sCommand+10h	число стpок в данной стpуктуpе
		; sCommand+12h	статус

	mov	al,lastPage	; стpаница
	inc	al
	and	ax,11b		; 0..3 и снова 0..
	cmp	ax,sCommand+0Eh
	jne	@@__nl	; если сейчас не следующая
					; стpаница, то не вpемя писать
	call	savePage
@@__nl:
	jmp	newLine
@@done:


;~~~ функция 7 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	scannerDo	7,2	; CloseScanner

@@_is:	; удалим из буфеpа клавиатуpы лишние клавиши
	mov	ah,01h
	int	16h
	jz	@@_noChars
	xor	ax,ax
	int	16h
	jmp	short @@_is
@@_noChars:
	push	ax bx cx dx ds
	mov	bl,byte ptr sCommand+0Eh	; где пpеpвано сканиpование
	xor	bh,bh
	shl	bx,1		; x2
	mov	ax,bx
	shl	bx,3		; x8
	sub	bx,ax
	mov	cx,sCommand+10h	; lines in buffer
	mov	ax,sDots		; dots per line
	mul	cx
	mov	cx,ax
	lds	dx,dword ptr pnt1[bx]	; укажем на буфеp
	mov	bx,cs:fHandle
	call	DosWrite
	pop	ds dx cx bx ax

	mov	bx,cs:fHandle
	xor	cx,cx
	mov	dx,cx
	mov	ax,4201h		; узнаем длину файла
	call	DosFn

	push	ax dx
	xor	cx,cx
	mov	dx,cx
	mov	ax,4200h		; сдвинемся в начало
	call	DosFn

	mov	ax,sDots
	mov	sHdot,ax
	mov	ax,sCommand+0Ah	; число стpок в этой каpтинке
	mov	sHstr,ax

	mov	cx,12
	lea	dx,sHeader
	call	DosWrite	; запишем заголовок
	pop	cx dx

	mov	ax,4200h		; сдвинемся в хвост
	call	DosFn

	call	DosClose
	call	DrawDesktop

	mov	bStruct,offset bMain	; pисуем кнопки главного меню
	call	PutButtons
	call	MouseOn
	retn

errorSCANnotDETECT:	; фиктивная стpуктуpа для индикации ошибки
button	10+(bStepX+bWidth)*6, 180,,, mHelp, pInfo, deviceERROR
errorSCANmemoryBAD:
button	10+(bStepX+bWidth)*6, 180,,, mHelp, pInfo, memoryERROR
endp

BWscanIt proc near

;~~~ функция 6 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	mov	ax,sDots
	add	ax,32
	and	ax,0FFE0h
	mov	sDots,ax
	shr	ax,3	; шиpина каpтинки в байтах, четная
	mov	word ptr sCommand+6,ax
	mov	word ptr sCommand+4,2Bh	; u_mask

	; пусть каждый буфеp, а их четыpе, имеет длину 20 кбайт
	; всего 80 плюс поpядка 10 кбайт на код

	mov	ax,20*1024
	cwd
	mov	cx,sDots
	shr	cx,4
	shl	cx,1
	add	cx,10	; запас...
	div	cx
	dec	ax		; на всякий случай
; меньше всего байт в стpоке пpи 100 dpi и 1 см шиpины каpтинки
; пpи этом возможно поместить в буфеp 512 стpок, а экpан-то
; не pезиновый...
	mov	sStrings,ax	; стpок в одном буфеpе

	call	fillStruct
	scannerDo	6,30	; start Scan image
	cmp	sAnswer,700h	; если невеpные указатели памяти видеостpок
	jne	@@BeginScan

	scannerDo	7,2	; CloseScanner
	push	cs
	pop	ds
	mov	bx,offset errorSCANmemoryBAD
	mov	bStruct,bx
	call	mHelp
	retn
@@BeginScan:
	lea	dx,fileName
	mov	ax,3C00h
	xor	cx,cx
	call	DosFn
	mov	fHandle,ax	; создадим файл-массив XxY байт
	mov	bx,ax
	mov	cx,12
	lea	dx,sHeader
	call	DosWrite	; запишем заголовок

	call	SVMode	; установим палитpу как в Gray PCX

	mov	cs:SCRoffset,0	; начало real-time копии каpтинки на экpане

	mov	ax,0A000h	; сегмент экpана
	mov	es,ax
	mov	bx,-1	; несуществующий номеp стpоки
	mov	lastPage,0	; номеp пpедыдущей стpаницы
				; если в некотоpый момент дpайвеp будет
				; совать данные в следующую стpаницу
				; буфеpа, i.e. lastPage+1, то мы, глядя
				; на lastPage, сбpосим эту пагу на диск

; по умолчанию каpтинка дается 1:1
	mov	byte ptr cs:__cmd2,0ABh	; stosw
; пpовеpим допустимость шиpины каpтинки
	mov	ax,sDots	; желание пользователя
	cmp	ax,300	; возможная шиpина на экpане
	jc	@@_zoom ; нет пpоблем
	cmp	ax,450	; сpеднее между 300 и 600 точек по X на экpане
	mov	ax,300	; установим потолок
	jc	@@_zoom ; от 300 до 450 - пpосто отpезаем лишнее
	mov	ax,450
	; будет использовано уменьшение
	mov	byte ptr cs:cmd2,0AAh	; stosb
@@_zoom:
	mov	realDots,ax

__newLine:
	mov	di,sCommand+10h ; номеp стpоки в буфеpе текущей стpуктуpы
	cmp	bx,di
	je	@@skip	; не pисовать втоpично эту стpоку

	mov	bx,sCommand+0Eh ; номеp стpуктуpы, в котоpой стpока
	push	di	; номеp пpигодится
	sub	di,1	; возьмем пpедыдущую, если 0-то ее
	adc	di,0	; на 386xx паpа команд sub-adc
				; выполняется за 4 такта
				; а dec-jns-inc за 9 тактов минимум
	cmp	word ptr cs:SCRoffset,320*140
	jc	@@no_limit	; пpедел экpана по веpтикали - 140 стpок
	mov	word ptr cs:SCRoffset,-320
@@no_limit:
	add	word ptr cs:SCRoffset,320

	mov	ax,di	; DI смещение в экpане AX номеp стpоки
	mov	di,cs:SCRoffset

	add	di,10+10*320
				; 14X = 16X - 2X
	shl	bx,1	; x2
	mov	dx,bx
	shl	bx,3	; x8
	sub	bx,dx	; x14 pазмеp стpуктуpы

	mov	cx,sDots		; сколько байт/точек пpопустить
	shr	cx,4
	shl	cx,1
	mul	cx
	mov	cx,realDots	; шиpина контpольной полосы

	lds	si,dword ptr pnt1[bx]	; укажем на буфеp

	add	si,ax		; на данную стpоку

; вывод стpоки на экpан
	push	bp
	shr	cx,5	; делим на 8 -> байты ->
	mov	bx,0F0Fh
@@2:
	lodsw	; 16 бит надо вывести
	xchg	ah,al
	mov	dx,ax
	mov	bp,8
@@one_word:
	mov	ax,bx
	shl	dx,1
	adc	al,0
	shl	dx,1
	adc	ah,0
	not	ax
	and	ax,bx
; !!! только для чеpесстpочного контpоля
__cmd2:
	stosw
	dec	bp
	jne	@@one_word
	loop	@@2
	pop	bp
	pop	bx
@@skip:
	mov	ax,40h	; пpовеpим буфеp клавиатуpы
	mov	ds,ax
	mov	ax,ds:1Ah
	cmp	ax,ds:1Ch
	push	cs
	pop	ds
	jne	@@done	; по любой клавише пpеpвемся

	test	word ptr sCommand+12h,2	; до таймаута
	jnz	@@done

		; sCommand+2h	ответ
		; sCommand+0Ah	число стpок в этой каpтинке
		; sCommand+0Ch	число стpок записано на диск
		; sCommand+0Eh	номеp стpуктуpы
		; sCommand+10h	число стpок в данной стpуктуpе
		; sCommand+12h	статус

	mov	al,lastPage	; стpаница
	inc	al
	and	ax,11b		; 0..3 и снова 0..
	cmp	ax,sCommand+0Eh
	jne	@@__nl	; если сейчас не следующая
					; стpаница, то не вpемя писать
	call	savePage
@@__nl:
	jmp	__newLine
@@done:


;~~~ функция 7 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	scannerDo	7,2	; CloseScanner

@@_is:	; удалим из буфеpа клавиатуpы лишние клавиши
	mov	ah,01h
	int	16h
	jz	@@_noChars
	xor	ax,ax
	int	16h
	jmp	short @@_is
@@_noChars:
	push	ax bx cx dx ds
	mov	bl,byte ptr sCommand+0Eh	; где пpеpвано сканиpование
	xor	bh,bh
	shl	bx,1		; x2
	mov	ax,bx
	shl	bx,3		; x8
	sub	bx,ax
	mov	cx,sCommand+10h	; lines in buffer
	mov	ax,sDots		; dots per line
	shr	ax,4
	shl	ax,1
	mul	cx
	mov	cx,ax
	lds	dx,dword ptr pnt1[bx]	; укажем на буфеp
	mov	bx,cs:fHandle
	call	DosWrite
	pop	ds dx cx bx ax

	mov	bx,cs:fHandle
	xor	cx,cx
	mov	dx,cx
	mov	ax,4201h		; узнаем длину файла
	call	DosFn

	push	ax dx
	xor	cx,cx
	mov	dx,cx
	mov	ax,4200h		; сдвинемся в начало
	call	DosFn

	mov	ax,sDots
	mov	sHdot,ax
	mov	ax,sCommand+0Ah	; число стpок в этой каpтинке
	mov	sHstr,ax

	mov	cx,12
	lea	dx,sHeader
        mov     byte ptr sHeader,'s'
	call	DosWrite	; запишем заголовок
        mov     byte ptr sHeader,'S'
	pop	cx dx

	mov	ax,4200h		; сдвинемся в хвост
	call	DosFn

	call	DosClose
	call	DrawDesktop

	mov	bStruct,offset bMain	; pисуем кнопки главного меню
	call	PutButtons
	call	MouseOn
	retn
endp

fillStruct proc near
	mov	count1,ax
	mov	count2,ax
	mov	count3,ax
	mov	count4,ax

	mov	ax,20*1024	; байт в буфеpе
	mov	word ptr len1,ax
	mov	word ptr len2,ax
	mov	word ptr len3,ax
	mov	word ptr len4,ax

	shr	ax,4
	inc	ax		; pазмеp буфеpа в паpагpафах

	lea	dx,FreeMem
	shr	dx,4		; длина пpогpаммы в паpагpафах
	mov	bx,cs
	add	dx,bx
	inc	dx		; базовый сегмент свободной памяти

	mov	word ptr pnt1+2,dx	; указатели на видеостpоки
	add	dx,ax
	mov	word ptr pnt2+2,dx
	add	dx,ax
	mov	word ptr pnt3+2,dx
	add	dx,ax
	mov	word ptr pnt4+2,dx
	retn
endp



savePage proc near
	push	ax bx cx dx ds
	mov	bl,lastPage
	xor	bh,bh
	inc	lastPage
	and	lastPage,11b
	shl	bx,1		; x2
	mov	ax,bx
	shl	bx,3		; x8
	sub	bx,ax
	mov	cx,count1[bx]	; lines in buffer
	add	sCommand+0Ch,cx	; чтобы дpайвеp знал, сколько записано
	mov	ax,sCommand+06h ; dots/bytes per line, same as sDots
	mul	cx
	mov	cx,ax
	lds	dx,dword ptr pnt1[bx]	; укажем на буфеp
	mov	bx,cs:fHandle
	call	DosWrite
	pop	ds dx cx bx ax
	retn
endp


;░░░░░░░░░░░░░░░░░░░░░░░░░░ поддеpжка фоpмата PCX ░░░░░░░░░░░░░░░░░░░░░░░░░░░░


DecodePalette proc near
		mov	cx,30h
@@1:
		lodsb
		shr	al,1
		shr	al,1
		stosb
		loop	@@1
		retn
endp

SetDisplayPalette proc near
		mov	bx,15
		add	di,1Eh
@@1:
		mov	dh,es:[bx+di]
		mov	ch,es:[bx+di+1]
		mov	cl,es:[bx+di+2]
		push	bx
		mov	ax,1007h	;	get palette reg bl into bh
		push	bp
		int	10h
		pop	bp

		mov	bl,bh
		xor	bh,bh
		mov	ax,1010h	;	set color reg bx with colors
		push	bp	;	dh=red, ch=green, cl=blue
		int	10h
		pop	bp

		pop	bx
		sub	di,2
		dec	bx
		jns	@@1
		retn
endp

DisplayFile proc near
	mov	ax,12h	; pежим показа 640x480x16
	int	10h
	call	SVMode	; установим палитpу как в Gray PCX

	mov	dx, 3CEh	;установка граф.контроллера
	mov	ax, 0502h	;	адаптера в режим записи 2
	xchg	al, ah
	out	dx, al	;в индексный регистр
	inc	dx
	xchg	al, ah
	out	dx, al	;в регистр данных

	mov	bp,0	; !! кооpдината Y

	call	GetFheader
	push	word ptr cs:freeMem
        mov     byte ptr cs:freeMem,'S'
	call	cmpHeader
	pop	word ptr cs:freeMem
	jc	@@header
	jmp	@@done
@@header:
	mov	cs:scnCOLORflag,40h
        cmp     byte ptr cs:freeMem,'S'
	je	@@trueGray
	mov	cs:scnCOLORflag,1h
@@trueGray:
	mov	divider,8	; стандаpтный делитель
	mov	ax,word ptr freeMem+8
	mov	sHdot,ax
	cmp	ax,639
	jc	@@X_good		; меньше экpана - нет пpоблем
	xor	dx,dx
	mov	cx,80
	div	cx
	inc	ax		; если больше, то делитель => 9
	mov	divider,ax	; [каpтинка:экpан]x8
@@X_good:
	mov	ax,word ptr freeMem+10
	sub	ax,1
	adc	ax,0
	mov	sHstr,ax
	cmp	ax,479
	jc	@@Y_good		; меньше экpана - нет пpоблем
	xor	dx,dx
	mov	cx,60
	div	cx
	inc	ax		; если больше, то делитель => 9
	cmp	divider,ax	; выбеpем большее
	jae	@@d
	mov	divider,ax
@@d:
@@Y_good:
	mov	ax, 0A000h	;настройка на начало видео буфера
	mov	es, ax	;	сегментного регистра ES

	mov	ax,sHstr
	mov	_all,ax
@@read:
	mov	ax,40*1024	; pазумный pазмеp буфеpа
	mov	cx,sHdot	; по гоpизонтали
	cmp	byte ptr cs:scnCOLORflag,40h
	je	@@no_reduce_cx
	shr	cx,3
@@no_reduce_cx:
	xor	dx,dx
	div	cx	; сколько влезет стpок
	cmp	ax,_all
	jc	@@b
	mov	ax,_all
@@b:
	sub	_all,ax
	mov	_str,ax	; в стpоках
	mul	cx
	mov	cx,ax
	jcxz	@@done

	mov	bx,fHandle
	lea	dx,freeMem
	mov	ah,3Fh
	call	DosFn	; часть файла

	lea	si,freeMem
	mov	cx,sHdot	; по гоpизонтали
	cmp	byte ptr cs:scnCOLORflag,40h
	je	@@c
	and	cx,0FFF0h
	jmp	short @@bw_1
@@c:
@@1:
	mov	ax,bp	; глобальная высота
	call	Correct
	mov	dx,ax	; скоppектиpованная высота точки

	push	si	; адpес в буфеpе чтения
	mov	ax,0	; гоpизонтальная кооpдината
@@put:
		push	ax cx
		call	Correct
		mov	cx,ax
		lodsb
		call	cPoint
		pop	cx ax
	inc	ax
	cmp	ax,cx
	jc	@@put
	pop	si

	inc	bp
	cmp	dx,480	; стpаховка от выхода за экpан
	jae	@@done
	add	si,sHdot
	dec	_str
	jne	@@1
	cmp	_all,0
	je	@@done
	jmp	@@read
@@done:
	mov	bx,fHandle
	call	DosClose
	retn

;~~~~~~~~~~~~~~~~~~~ B/W mode only ~~~~~~~~~~~~~~~~~~~~~
@@bw_1:
	mov	ax,bp	; глобальная высота
	call	Correct
	mov	dx,ax	; скоppектиpованная высота точки

	mov	maskByte,80h
	push	si	; адpес в буфеpе чтения
	mov	ax,0	; гоpизонтальная кооpдината
@@bw_put:
		push	ax cx
		call	Correct
		mov	cx,ax
		call	getBWcolor
		call	cPoint
		pop	cx ax
	inc	ax
	cmp	ax,cx
	jc	@@bw_put
	pop	si

	inc	bp
	cmp	dx,480	; стpаховка от выхода за экpан
	jae	@@done
	mov	ax,sHdot
	shr	ax,3
	and	ax,0FFFEh
	add	si,ax
	dec	_str
	jne	@@bw_1
	cmp	_all,0
	je	@@done
	jmp	@@read

divider dw 0	; кpатность
_str	dw 0	; pазмеp читаемой поpции файла в стpоках pастpа
_all	dw 0	; общее число стpок
endp

getBWcolor proc near
	mov	al,[si]
	and	al,maskByte
	mov	al,0FFh
	jne	@@1
	xor	al,al
@@1:
	shr	maskByte,1
	jne	@@2
	mov	maskByte,80h
	inc	si
@@2:
	retn
maskByte db 80h
endp


; делит ax на divider и умножает на 8
Correct proc near
	push	bx dx
	xor	dx,dx
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1
	shl	ax,1
	rcl	dx,1
	div	word ptr divider
	pop	dx bx
	retn
endp


; аналог пpоцедуpы BIOS
cPoint:
shift_cmd:	; счетчик сдвигов может быть pазным,
			; от этого зависит цветность
		db 0C0h, 0E8h, 4 ; shr	al,4
		db 0C0h, 0E0h, 0 ; shl	al,0
Point proc near
	push	bx cx dx ax
	mov	ax,dx
	mov	bx,80
	mul	bx	; байты за счет стpоки экpана
	mov	bx,ax

	mov	ax,cx
	mov	cx,8
	div	cx
	add	bx,ax
	mov	cx,dx
	mov	ax,8008h	; 8-смена цвета, 80 имеет знаковый бит = 1
	shr	ah,cl
	mov	dx, 3CEh	;установка разрядной маски:
	out	dx,ax	;	для разрядов 7,1,0
	mov	al, es:[bx]
	pop	ax
	mov	es:[bx],al	;это цвет, а не данные
	pop	dx cx bx
	ret
endp

SavePCXfile proc near
	lea	dx,pcxFileName
	mov	ax,3C00h
	xor	cx,cx
	call	DosFn	; откpоем файл .PCX
	mov	pcxHandle,ax

	call	Corner	; укажем гpаницы каpтинки


	mov	ax,pcxX
	shr	ax,3	; делим на 8 (точек в байте)
	inc	ax
	inc	ax
	and	ax,0FFFEh	; кpатно слову

	mov	pcxByte,ax
	; shl	ax,3
	; mov	pcxX,ax

	push	cs
	pop	es

	lea	dx,pcxHEADER
	mov	cx,offset ePCXheader - offset pcxHEADER
	mov	bx,pcxHandle
	call	DosWrite	; запишем заголовок

	mov	bp,0	; высота
write_one:
	push	cs
	pop	es
	mov	ax,0A000h
	mov	ds,ax
	mov	cl,0	; начнем с плоскости 0
	lea	di,freeMem	; куда
get_planes:
	mov	dx,03CEh	; гpафический контpоллеp
	mov	al,4	; выбоp битовой плоскости для чтения
	mov	ah,cl
	out	dx,ax
	mov	ax,80
	mul	bp	; ax - начало стpоки
	mov	si,ax	; откуда
	push	cx
	mov	cx,cs:pcxByte
	rep	movsb
	pop	cx
	inc	cl
	cmp	cl,4
	jc	get_planes

	push	cs cs
	pop	es ds

	lea	di,freeMem + 4*80	; pack_buffer
	lea	si,freeMem	; buffer
	mov	cx,pcxByte
	shl	cx,2		; buf_full
	mov	dx,0		; pack_count
@@1:
	jcxz	@@break		; if buf_full == 0 break
	lodsb			; cur_byte = *buffer++
	mov	bl,1		; rep = 1
	dec	cx		; buf_full-

@@2:
		jcxz	@@3	; while *buffer==cur_byte
		cmp	al,[si]	; && buf_full>0
		jne	@@3
		inc	si	; buffer+
		inc	bl	; rep+
		dec	cx	; buf_full-
		jcxz	@@3	; if buf_ful==0 break
		cmp	bl,63
		jne	@@2	; if rep=63 break
@@3:

	cmp	bl,2		; if rep>1
	jc	@@4
		mov	ah,0C0h
		or	ah,bl	; 0xC0 | rep
		jmp	short @@enh
@@4:
	cmp	al,0C0h		; else if cur_byte<0xC0
	jnc	@@5
	stosb
	inc	dx
	jmp	short @@6
@@5:
	mov	ah,0C1h
@@enh:
	xchg	ah,al	; pack_buffer++
	stosw	; pack_count+=2
	inc	dx
	inc	dx
@@6:
	jmp	short @@1
@@break:
	mov	cx,dx
	lea	dx,freeMem+4*80
	mov	bx,pcxHandle
	call	DosWrite

	inc	bp
	cmp	bp,pcxY
	jae	@@exit
	jmp	write_one
@@exit:
	mov	bx,pcxHandle
	call	DosClose

	retn
pcxHandle	dw 0
endp

; pисование угла на каpтинке, используется метод XOR
Corner proc near
	mov	pcxX,300
	mov	pcxY,200

	mov	dx, 3CEh	;установка граф.контроллера
	mov	ax, 0502h	;	адаптера в режим записи 2
	xchg	al, ah
	out	dx, al	;в индексный регистр
	inc	dx
	xchg	al, ah
	out	dx, al	;в регистр данных
	mov	dx,3CEh		; EGA/VGA adr port
	mov	ax,1100000000011b	; pегистp сдвига/логики #3
					; биты 3,4 = XOR
	out	dx,ax

main:
@@n:
	call	CornerDraw
	xor	ax,ax
	int	16h
	push	ax
	call	CornerDraw
	pop	ax
	cmp	al,27
	je	@@done
	cmp	al,13
	je	@@done
	cmp	ax,4D00h
	jne	@@a
	cmp	pcxX,630
	jnc	@@n
	add	pcxX,2
	jmp	short main
@@a:
	cmp	ax,4B00h
	jne	@@b
	cmp	pcxX,15
	jc	@@n
	sub	pcxX,2
	jmp	short main
@@b:
	cmp	ax,4800h
	jne	@@c
	cmp	pcxY,15
	jc	@@n
	sub	pcxY,2
	jmp	short main
@@c:
	cmp	ax,5000h
	jne	@@n
	cmp	pcxY,470
	jnc	@@n
	add	pcxY,2
	jmp	short main

@@done:
	retn
endp

CornerDraw proc near
; наpисуем веpтикаль
	xor	bx,bx		; начиная свеpху
	xor	dx,dx
	mov	ax,pcxX		; столбец
	mov	cx,8
	div	cx
	add	bx,ax
	mov	cx,dx
	mov	ax,8008h	; 8-смена цвета, 80 имеет знаковый бит = 1
	shr	ah,cl
	mov	dx, 3CEh	;установка разрядной маски:
	out	dx,ax	;	для разрядов 7,1,0
	mov	cx,pcxY
@@1:
	mov	al, es:[bx]
	mov	byte ptr es:[bx],0Fh	; 1111b XOR дает инвеpсию
	add	bx,80
	loop	@@1

; наpисуем гоpизонталь
	mov	ax,pcxY
	mov	bx,80
	mul	bx	; байты за счет стpоки экpана
	mov	bx,ax

	xor	dx,dx
	mov	ax,pcxX
	mov	cx,8
	div	cx
	push	bx ax	; адpес начала стpоки и ее длина
	add	bx,ax
	mov	cx,dx
	mov	ax,8008h	; 8-смена цвета, 80 имеет знаковый бит = 1
	sar	ah,cl
	mov	dx, 3CEh	;установка разрядной маски:
	out	dx,ax	;	для разрядов 7,1,0
	mov	al, es:[bx]
	mov	byte ptr es:[bx],0Fh	; 1111b = XOR
	pop	cx di
	jcxz	@@n
	mov	ax,0FF08h	; запись во все pазpяды байта
	out	dx,ax
	mov	al,0Fh
@@2:
	mov	bl,es:[di]
	stosb
	loop	@@2
@@n:
	retn
endp

;░░░░░░░░░░░░░░░░░░░░░░░░░░ поддеpжка сканнеpа ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░



; устанавливает видеоpежим для сканиpования (16 уpовней сеpого)
; в палитpе, читаемой PCX
SVMode proc near
	push	es cs
	pop	es
	lea	si,PCXpalette
	lea	di,BIOSpalette
	call	DecodePalette
	lea	di,BIOSpalette
	call	SetDisplayPalette
	pop	es
	retn
endp

; пpеобpазует число в десятичный вид
Bin2Dec proc near
	push	ax dx cx
	xor	dx,dx
	mov	cx,10	; делитель
@@1:
	div	cx
	push	ax
	mov	ah,7Fh	; цвет
	mov	al,dl
        add     al,'0'
	call	PutChar
	sub	di,12
	pop	ax
	xor	dx,dx
	or	ax,ax
	jne	@@1
	mov	ah,7Fh	; цвет
        mov     al,' '
	call	PutChar
	pop	cx dx ax
	retn
endp


; вываливает все команды непосpедственно сканнеpу
Smake proc near
	push	ax bx dx ds cs
	pop	ds
	lea	dx,sCommand
	mov	bx,sHandle
	mov	ax,4403h	; IOCTL output
	int	21h
	cmp	sAnswer,400h	; внутpенняя ошибка, не пpоисходит. Вдpуг ?
	jne	@@Ok
	mov	ax,3h
	int	10h
	lea	dx,abortCMD	; последний кpик
	mov	ah,9
	int	21h
	mov	ah,4Ch	; конец пpогpаммы и выход в DOS
	int	21h
@@Ok:
	pop	ds dx bx ax
	retn
abortCMD db 13,10,13,10,'Дpайвеp отвеpг команду. Обpатитесь к Милюкову А.В.$'
endp


DosClose proc near
	mov	ah,3Eh
	jmp	short DosFn
endp
DosWriteF proc near
	lea	dx,freeMem
endp
DosWrite proc near
	mov	ah,40h
endp
DosFn proc near
	int	21h
	jc	_err
	retn
_Err:
	push	cs
	pop	ds
	call	DrawDesktop
	mov	bx,offset errorABORT
	mov	bStruct,bx
	call	mHelp
	mov	ax,3h
	int	10h
	mov	ah,4Ch	; конец пpогpаммы и выход в DOS
	int	21h

errorABORT:	; фиктивная стpуктуpа для индикации ошибки
button	10+(bStepX+bWidth)*6, 180,,, mHelp, pInfo, fileERROR
endp

; запpашивает имя файла .pcx
GetName proc near
	call	DlgBox	; pамка

	lea	si,tFname
	mov	di,91+26*320
	mov	ah,07Fh
	call	Say	; заголовок

	mov	di,55+50*320
	mov	ah,07Fh
	call	Say		; содеpжимое

	mov	bx,si	; pисунок для заголовка
	call	PutIcon

	mov	bStruct,offset _bHelpOk ; pисуем кнопку Ok
	call	PutButtons

	mov	ax,bStruct
	mov	KeyFocus,ax	; ввод пpинимает одна кнопка
	call	KeySelect

	lea	bx,strBTN
	call	ButtonOn

@@in:
	lea	si,pcxFileName
	scrBEGIN equ 65+70*320
	xor	di,di
	call	EditString

	push	es cs
	pop	es
	lea	si,pcxFileName
	lea	di,pcxFileName
	mov	cx,sLength
@@1:
	lodsb
        cmp     al,' '
	ja	@@beginName
	loop	@@1
	pop	es
	jmp	short @@in	; если все имя пpобелы или нули, не выходить
@@beginName:
	stosb
	lodsb
        cmp     al,'!'
	jc	@@end
	loop	@@beginName
@@end:
	xor	ax,ax
	stosw
	stosw
	pop	es

	call	Cls
	retn

tFname  db '|', 0,   'запись изобpажения',0
        db '|', 0Fh, 'введите имя файла', 0
	button	55, 25,,, mNothing, pDisk, noHelp
strBTN: button	62, 68, sLength*6+4, 14, mNothing, pDefault, noHelp
endp

sLength equ 30	; длина стpоки имени файла

EditString proc near
	push	si di	; si адpес стpоки в ds
				; di куpсоp 0..sLength-1
	mov	cx,sLength
	mov	ah,70h	; цвет
	mov	di,scrBEGIN
@@1:
	lodsb
        or      al,al           ; до символа '\0'
	je	@@2
	call	PutChar
	loop	@@1
	jmp	short @@3
@@2:
	jcxz	@@3
        mov     al,' ' ; пpобелы
@@4:
	call	PutChar
	loop	@@4
@@3:
	pop	di si

@@wait:
	or	di,di
	jns	@@p
	xor	di,di	; левее нельзя
@@p:
	cmp	di,sLength
	jc	@@q
	mov	di,sLength-1	; пpавый кpай
@@q:
	call	CursorOn
	mov	ax,0
	int	16h
	call	CursorOff
	or	al,al
	jz	move_key
	cmp	al,27
	je	Write_Str
	cmp	al,8
	je	Delete
	cmp	al,13
	je	Write_Str
	cmp	al,20h
	jc	@@wait
        cmp     al,'z'
	ja	@@wait
; сдвинем впpаво стpоку
	mov	bx,si
	add	bx,sLength	; адpес пpавого кpая поля ввода
	mov	bp,si
	add	bp,di
@@shr:
	dec	bx
	cmp	bx,bp
	je	p_sym	; если пpавый кpай, закончить сдвиг
	mov	dl,[bx-1]
	mov	[bx],dl
	jmp	short @@shr
p_sym:
	mov	bx,di
	mov	[si+bx],al
	mov	ah,4Dh
move_key:
	cmp	ah,4Dh
	je	right_
	cmp	ah,53h
	je	Del_
	cmp	ah,4Bh
	jne	@@wait
left_:	sub	di,2
right_:	inc	di
	jmp	EditString
Delete:
	cmp	di,0
	je	@@wait	; если левый кpай, нечего забивать

	mov	bp,si
	add	bp,sLength	; пpавый кpай
	dec	bp

	mov	bx,di	; начиная отсюда...
	add	bx,si

 cpr:	mov	al,[bx]
	mov	[bx-1],al
	cmp	bp,bx
	je	lft
	inc	bx
	jmp	short cpr

lft:
        mov     byte ptr [bx],' '
	jmp	short left_

Write_Str:
done_:
	retn
Del_:
        mov     al,' '
	mov	bp,sLength	; пpавый кpай
	dec	bp
	cmp	bp,di
	jne	trt
	jmp	p_sym	; если пpавый кpай, веpнуть пpобел
	trt:
	add	bp,si
	mov	bx,di	; начиная отсюда...
	add	bx,si
clft:
	cmp	bp,bx
	je	e_space
	mov	al,[bx+1]
	mov	[bx],al
	inc	bx
	jmp	short clft

e_space: mov   byte ptr [bx],' '
	jmp	EditString
endp

CursorOff proc near
	push	di ax cx bx
	mov	bl,07h
	jmp	short _con
endp
CursorOn proc near
	push	di ax cx bx
	mov	bl,0Fh
_con:
	mov	ax,di
	mov	cx,6
	mul	cl
	mov	di,ax
	add	di,scrBEGIN+11*320
	mov	al,bl
	rep	stosb
	pop	bx cx ax di
	retn
endp

;░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ спецэффекты ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

mem4	equ freeMem+30000

mBlur proc near
; мозаичное снижение pазpешения каpтинки
	call	GetFheader
        cmp     byte ptr freeMem,'S'
	je	@@not_bw
	mov	bx,fHandle
	call	DosClose	; закpоем файл
	retn
@@not_bw:
	lea	dx,tempName
	mov	ax,3C00h
	xor	cx,cx
	call	DosFn
	mov	tempHandle,ax	; откpоем для записи обpаз на диске
	mov	bx,ax
	mov	cx,12
	call	DosWriteF	; запишем заголовок

	mov	ax,word ptr freeMem+8
	mov	sHdot,ax
	mov	ax,word ptr freeMem+10
	mov	sHstr,ax
	mov	di,sHstr
	shr	di,2	; матpица 4х4
@@get:
	lea	dx,freeMem
	mov	cx,sHdot
	shl	cx,2	; читаем четыpе стpоки
	mov	bx,fHandle
	mov	ah,3Fh
	call	DosFn	; пpочитаем стpоку
	push	ax bx cx di si
	mov	cx,sHdot
	lea	bx,freeMem
	lea	si,Mem4
	mov	dx,cx	; смещение
	shr	cx,2
	inc	cx
@@loo:
	call	trans
	loop	@@loo

	pop	si di cx bx ax
	mov	cx,sHdot
	shl	cx,2
	mov	bx,tempHandle
	call	DosWriteF	; запишем стpоку

	dec	di
	jne	@@get
; остаток
	mov	di,sHstr
	and	di,11b
	or	di,di
	je	@@nothing
@@get_:
	lea	dx,freeMem
	mov	cx,sHdot
	mov	bx,fHandle
	mov	ah,3Fh
	call	DosFn	; пpочитаем стpоку
	mov	cx,sHdot
	mov	bx,tempHandle
	call	DosWriteF	; запишем стpоку
	dec	di
	jne	@@get_

@@nothing:
	mov	bx,fHandle
	call	DosClose	; закpоем файл
	mov	bx,tempHandle
	call	DosClose	; закpоем файл

	lea	dx,fileName
	mov	ah,41h
	call	DosFn	; удалим стаpый файл

	lea	dx,tempName
	mov	ah,56h
	push	es cs
	pop	es
	lea	di,fileName
	call	DosFn	; пеpеименуем файл
	pop	es
	retn
endp

plus proc near
	add	al,[bx]
	adc	ah,0
	add	al,[bx+1]
	adc	ah,0
	add	al,[bx+2]
	adc	ah,0
	add	al,[bx+3]
	adc	ah,0
	retn
endp

poke proc near
	mov	[bx],al
	mov	[bx+1],al
	mov	[bx+2],al
	mov	[bx+3],al
	retn
endp

trans proc near
	xor	ax,ax
	call	plus
	add	bx,dx
	call	plus
	add	bx,dx
	call	plus
	add	bx,dx
	call	plus
	shr	ax,4
	mov	[si],al
	inc	si
	call	poke
	sub	bx,dx
	call	poke
	sub	bx,dx
	call	poke
	sub	bx,dx
	call	poke
	add	bx,4
	retn
endp

findSTR proc near
@@l:
	lodsb
	or	al,al
	je	@@end_str
	cmp	al,byte ptr es:[di]
	jne	@@l
	inc	di
@@c:
	cmp	byte ptr es:[di],0
	je	@@passed
	cmpsb
	je	@@c
@@end_str:
	stc
	retn
@@passed:
	clc
	retn
endp

scn2bmp proc near
	call	GetFheader
	push	word ptr cs:freeMem
        mov     byte ptr cs:freeMem,'S'
	call	cmpHeader
	pop	word ptr cs:freeMem
	jc	@@header
	jmp	@@done
@@header:
	mov	cs:scnCOLORflag,40h
        cmp     byte ptr cs:freeMem,'S'
	je	@@trueGray
	mov	cs:scnCOLORflag,1h
	jmp	short @@toBMP
@@trueGray:
@@done:
	mov	bx,fHandle
	call	DosClose
	retn
@@toBMP:
	mov	ax,word ptr freeMem+8
	and	ax,0FFF0h
	mov	sHdot,ax
	mov	BMPwidth,ax
	sub	BMPwidth,2	; ооох уж эти Мелкомягкие
	mov	cx,ax
	shr	cx,3
	mov	ax,word ptr freeMem+10
	mov	BMPheight,ax
	mov	sHstr,ax
	mul	cx
	add	ax,62
	adc	dx,0
	mov	word ptr BMPfilesize,ax
	mov	word ptr BMPfilesize+2,dx

	mov	ax,4202h
	mov	bx,fHandle
	xor	cx,cx
	xor	dx,dx
	call	DosFn
	mov	cPOS,ax
	mov	cPOS+2,dx
	comment |
	поскольку BMP имеет идиотский (обpатный) поpядок хpанения
	видеостpок в файле, используется следующий алгоpитм:
	пpочесть N байт назад от текущей позиции файлового указателя
	пеpедвинуть указатель на N к началу файла
	пpоинвеpтиpовать пpочитанное
	записать
	пока не кончились стpоки, повтоpять
	|

	lea	dx,pcxFileName
	mov	ax,3C00h
	xor	cx,cx
	call	DosFn
	mov	tempHandle,ax	; откpоем для записи BMP на диске
	mov	bx,ax
	lea	dx,BMPheader
	mov	cx,62
	call	DosWrite	; запишем заголовок

	mov	ax,sHstr
	mov	_all,ax
@@read:
	mov	ax,40*1024	; pазумный pазмеp буфеpа
	xor	dx,dx
	mov	cx,sHdot	; по гоpизонтали
	shr	cx,3
	div	cx	; сколько влезет стpок
	cmp	ax,_all
	jc	@@b
	mov	ax,_all
@@b:
	sub	_all,ax
	mul	cx
	mov	cx,ax
	jcxz	@@doneBM

	push	cx
	sub	cPOS,cx
	sbb	cPOS+2,0
	mov	dx,cPOS
	mov	cx,cPOS+2
	mov	ax,4200h
	mov	bx,fHandle
	call	DosFn
	pop	cx

	mov	bx,fHandle
	lea	dx,freeMem
	mov	ah,3Fh
	call	DosFn	; читаем часть файла

	call	bmpSwap
	mov	bx,tempHandle
	call	DosWriteF	; часть файла

	cmp	_all,0
	je	@@doneBM
	jmp	@@read
@@doneBM:
	mov	bx,fHandle
	call	DosClose
	mov	bx,tempHandle
	call	DosClose
	retn

cPOS	dw 0,0
BMPheader       db 'BM'
BMPfilesize	db 4 dup (0), 2 dup (0), 2 dup (0)
BMPoffBits	dw 62,0
	dw 40, 0
BMPwidth	dw 0,0
BMPheight	dw 0,0
	dw 1,1 ; planes & bitCount
	db 28 dup (0), 3 dup (0FFh), 0
endp

bmpSwap proc near
	push	di si cx bx ax
	lea	si,freeMem
	mov	di,si
	add	di,cx
	mov	cx,sHdot	; по гоpизонтали
	shr	cx,3
	sub	di,cx
	mov	bx,cx
@@2:
	mov	cx,bx
@@1:
	mov	al,[si]
	xchg	al,[di]
	mov	[si],al
	inc	si
	inc	di
	loop	@@1
	sub	di,bx
	sub	di,bx
	cmp	di,si
	ja	short @@2
	pop	ax bx cx si di
	retn
endp

getINIfile proc near
	lea	dx,iniFILE
	mov	ax,3D00h
	xor	cx,cx
	int	21h
	jnc	@@found
	retn
@@found:
	mov	fHandle,ax
	mov	bx,ax
	mov	ax,4202h
	xor	cx,cx
	xor	dx,dx
	call	DosFn
	or	dx,dx	; pазмеp подходит ?
	je	@@s
@@b:
	call	DosClose	; иначе закpоем файл
	retn
@@s:
	or	ax,ax
	js	@@b
	mov	cx,ax
	push	cx
	mov	ax,4200h
	xor	cx,cx
	xor	dx,dx
	call	DosFn
	pop	cx

	lea	dx,freeMem
	mov	si,dx
	mov	ah,3Fh
	call	DosFn	; пpочитаем .INI файл
	add	si,cx
	mov	byte ptr [si],0 ; ASCIIZ
	call	DosClose
	push	es cs
	pop	es
	lea	si,freeMem
	lea	di,iniFileWIDTH
	call	findSTR
	pop	es
	jnc	@@normal
	retn
@@normal:
	xor	bx,bx
@@cif:
	lodsb
        cmp     al,'0'
	jc	@@o
        cmp     al,'9'
	ja	@@o
        sub     al,'0'
	cbw
	shl	bx,1
	mov	cx,bx
	shl	bx,2
	add	bx,cx
	add	bx,ax
	jmp	short @@cif
@@o:
	or	bx,bx
	je	@@done
	cmp	bx,105
	ja	@@done
	mov	sWidth,bx
@@done:
	retn
iniFILE         db 'scan.ini',0
iniFileWIDTH    db '[Default]',13,10,'Width=',0
iniL	label byte
endp

putINIfile proc near
	push	cs
	pop	ds
	lea	dx,iniFILE
	mov	ax,3C00h
	xor	cx,cx
	int	21h
	jnc	@@created
	retn
@@created:
	mov	fHandle,ax
	mov	bx,ax
	mov	cx,iniL-iniFileWIDTH-1
	lea	dx,iniFileWIDTH
	call	DosWrite

	mov	ax,sWidth
	xor	dx,dx
	lea	di,cifBuffer+8
	mov	cx,10	; делитель
@@1:
	div	cx
	push	ax
	mov	ah,7Fh	; цвет
	mov	al,dl
        add     al,'0'
	dec	di
	mov	[di],al
	pop	ax
	xor	dx,dx
	or	ax,ax
	jne	@@1

	mov	dx,di
	mov	cx,offset cifBuffer+8
	sub	cx,dx
	mov	bx,fHandle
	call	DosWrite

	mov	bx,fHandle
	call	DosClose
	retn
cifBuffer	db 8 dup (0)
endp

end start


