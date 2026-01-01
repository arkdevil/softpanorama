 	page	86,132     ;Размер страницы
	.model	small
;Драйвер контроля записи на гибкие диски
out? <.   ╔═════════════════╗>
out? <.   ║ P U _ W R C F D ║>
out? <.   ╚═════════════════╝>
; Программист: Панков Ю.И.
;
; Дата создания: 28.01.93
; Дата редакции:
;
VER_@@@	equ	<"V1.1">
DAT_@@@	equ	<"26.03.93">
NAM_@@@	equ	<"PU_WRCFD">
I___	=	0
;
name  	PU_WCRFD
;
; Формат запуска программы:
;
; PU_WCRFD [параметр параметр  ...]
;
;  Подключение сервиса
 	include	MACRO_00.INC
 	include	MACRODOS.INC
;
;     Макрокоманды генерации таблицы
; настройки программы обработчика II по месту:
;
_Index_	=	0
_MM_ equ <>
;
DwM?	Macro	Met
dw	Met
	Endm
;
EquM2?	Macro	Met
Met	equ	$-2
	Endm
;
EquM3?	Macro	Met
Met	equ	$-3
	Endm
;
Concatm? Macro
_Index_	= _Index_ + 1
	concat? _MM_,<O_f_>,%_Index_
	Endm
;
; Пометка переменного смещения $-2 настройки по месту
VarAddr? Macro
	Concatm?
	EquM2?	%_MM_
	Endm
;
; Пометка переменного смещения $-3 настройки по месту
VarAddr3? Macro
	Concatm?
	EquM3?	%_MM_
	Endm
;
; Генерация элемента таблицы настройки по месту
VarAddr_? Macro
	Concatm?
	DwM?	%_MM_
	Endm
;
;
;  Управление листингом МАКРО
;	.lall		;Полный
	.xall		;Не полный
;	.sall		;Отказ
;
;
; Заголовок драйвера (DDH)
DDH? 		STRUC
DDH_next	dd	-1	;Указатель на следующий заголовок
DDH_at     	dw	8000h	;Атрибуты - символьное устройство
DDH_str   	dw	?	;Указатель на пр. обр. стратегии
DDH_pr     	dw	?	;Указатель на пр. обр. прерываний
DDH_name   	db "PU-WRCFD"	;имя драйвера
DDH?        	ENDS
;
Stat_Ok	equ	100h		;команда выполнена
Stat_Err equ	8003h		;неправильный код команды
;
;
; Формат блока запросов (DDR)
DDR? 		STRUC
DDR_len   	db	16h	;заголовка + данных
DDR_unit   	db	0	;устройство
DDR_com   	db	0	;Код команды - инициализация
DDR_stat	dw  	Stat_Ok	;Статус - команда выполнена
DDR_rsv 	db      8 dup(0);Р е з е р в
DDR_data	db      0       ;Д а н н ы е  начало:
DDR_off		dw      ?       ;смещение конца драйвера
DDR_seg		dw      ?       ;сегмент драйвера
DDR_Line	dd      ?       ;seg:off строки запуска
DDR?        	ENDS
;
; Буфер для переноса строки параметров
BuffLine equ	1024*12
AStack	equ	BuffLine+1024*1
;
;
	.code
	assume	ds:_text
	org	100h
; Обработчик прерывания int 13h - часть II
; ┌────────────────────────────────────────────┐
; │ О с н о в н о е  т е л о   д р а й в е р а │
; └────────────────────────────────────────────┘
;
;           Настроен на смещение 100h:
;       (Настраивается по месту загрузки)
;
Int13_S2:
;Описание входов через заголовок дpайвеpа:
;вход производится по смещению cs:0
DDH?	<,,Strategy-100h,Interrupt-100h>
_Met	equ	$
;
	org	100h
; Вход для Com-программы:
Start:	jmp 	Start1
	org	_Met
SysRetf:
	retf
;
Flag	db	0	;управляющие признаки
;
Flag_A	equ	1	;программа активна
F_ke	equ	2	;сохранить блок среды
F_Help	equ	4	;выдать подсказку
PU_WRCFD equ	8	;драйвер установлен
F_PSP	equ	16	;не занимать PSP
F_NoHMA	equ	32	;не грузиться в HMA
F_NoUMB	equ	64	;не грузиться автономно в UMB
F_HMA	equ	128	;есть HMA
;
SecS	db	21	;длина буфера в секторах
Wal	db	0	;для al
Wax	dw	0	;для ax
;
;
; Выполнение функции 13h BIOS
Block?	Bios_13h
	pushf
db	9ah		;call far
Dword?	Old13
Bend?	Bios_13h
;
; Считать в буфер и сравнить
; на выходе: CF = 1 - ошибка
Block?	RComp,<si,di>
	mov	al,Wal
VarAddr?
	cmp	SecS,al		;буфер мал ?
VarAddr?
	jb	RComp1		;да
	mov	ah,2		;чтение
; ds = es;  es = cs
	PushPop? <es,ds>,<es,cs>
	mov	si,bx		;ds:si - буфер записи
	mov	bx,@O Free	;es:bx - буфер чтения
VarAddr?
	mov	di,bx		;es:di - буфер чтения
	call	Bios_13h	;ч и т а т ь  в  es:di
	jc	RComp0		;ошибка
	mov	ax,cs:Wax	;восстановим ax
VarAddr?
	xor	cx,cx
	mov	ch,cs:Wal
VarAddr?
	cmpsw?			;с л и ч а е м
	je	RComp0		;выходим, т.к. все люкс
	mov	ah,10h		;при несравнении вы-
	stc			; ставим ошибку CRC
RComp0:
Bend?	RComp
; Маловат буфер:
RComp1:	clc
	mov	ax,Wax		;восстановим ax
VarAddr?
	jmp	short RComp0
;
;
; Обработчик прерывания 13h
;═══════════════════════════
I13:
Int13_B2:
; на входе: al - кол. секторов
;           ah - функция:
;		 0 - сброс дисковода
;		 1 - выдать состояние (441h)
;                2 - чтение секторов
;                3 - запись секторов
;                4 - проверка секторов
;                5 - форматирование трека
;	    cl - N сектора
;	    ch - N цилиндра
;	    dl - N устройства (0-A, 1-B,...,80h-C,...)
;	    dh - N головки (трека)
;	 es:bx - буфер обмена

;	sti
	cmp     ah,18h		;возможно запрос ?
	jne     I13_1		;нет
	cmp     cx,"pu"		;запрос ?
	jne     I13_1		;нет
; Ответ на запрос к драйверу:
	PushPop? es,cs		;es ==> сегмент
	mov     ax,"up"		;ax = признак ответа
	mov	bx,@O Start	;смещение в сегменте
VarAddr?
	stc
	jmp	short retf2
; Обработка прерываний
I13_1:
	test    cs:Flag,Flag_A	;программа активна ?
VarAddr3?
	je      I13_2		;нет ... уходим
	cmp     ah,3		;функция 3 ?
	jne	I13_2		;да ... уходим
	cmp     dl,1		;гибкие диски ?
	jbe     I13_3		;да
I13_2:
	jmp     cs:Old13
VarAddr?
;
;───────────Запись - функция 3─────────────────
I13_3:
	or	al,al		;кол. = 0
	je	I13_2		;да
	cmp	al,21		;трек короткий ?
	ja	I13_2		;нет ... великоват
	Push_Reg? I13_3,<bx,cx,dx,es,ds>
	PushPop? ds,cs
	mov	Wal,al
VarAddr?
	call	Bios_13h	;записать
	mov	Wax,ax
VarAddr?
	jc	Exit_C1		;ошибка
	call	RComp		;сравнить
Exit_C1:
	Pop_Reg? I13_3
Retf2:	retf	2
Int13_E2:
;
;══════════════════════════════════════════════════════
Len2P	equ	(Int13_E2-Int13_S2+15)/16
Len2	equ	Len2P*16
;
; ┌───────────────────────────────────────┐
; │     Конец основного тела драйвера     │
; │                ┌───┐                  │
; │     и всего то │176│ байт кода        │
; │                └───┘┌────┐            │
; │     Весь "огород" в │3214│ байт кода  │
; │     описанного ниже └────┘            │
; │   служит лишь для загрузки основного  │
; │   тела в HMA, UMB или Conventional!!  │
; └───────────────────────────────────────┘
Free	equ	$
; конец резидентной части II
AFree	dw	Len2
;
Wes	dw	0	;сегмент
Off_Mem	dw	0	;смещение в блоке
;
;
FlagSys	db	0
;
F_Config equ	1		;запуск из CONFIG.SYS
F_Nul	equ	2		;не выводить сообщение

Gamma 	label	byte
NameP	label	byte
DBTG?	%NAM_@@@,13h
;
TextG? <.COM>,,N
;
;  Отказ от МАКРО листинга - и так должно быть все ясно
	.sall
LNameP	equ	$ - NameP-1
;
Reclama label	byte
DBTG?	%NAM_@@@
TextG? <. Copyright (c), >
DBTG? %DAT_@@@
TextG? <, PU Service Systems, >
DBTG? %VER_@@@
TextG? < >,,E
TextG? <                         Command line switches:>,,E
TextG? </off - PU_wrcFD Off │/NoHMA - No HMA autoload │/U  - unload DRV │/? - Help/Info>,,E
TextG? </on  - PU_wrcFD On  │/NoUMB - No UMB autoload │/ke - keep ENV   │/nul>,,ET
;
MsgI	label	byte
TextG? <Information:  >
DBTG?	%NAM_@@@
TextG?	< >
;
Tx_WRCFD label	Byte
TextG?	<Off, N:>
;
Tx_N label	Byte
TextG?	<xx.  >,,T
;
LoadD_UMB label	byte
DBG? <10,13>
TextG? <Resident Memory (bytes): UMB - 32, HMA - >,,T
;
LoadD_Low label byte
DBG? <10,13>
TextG? <Resident Memory (bytes): Conventional - 32, HMA - >,,T
;
LoadD_Mem label byte
DBG? <10,13>
TextG? <Resident Memory (bytes): Conventional - 96, HMA - >,,T
;
Load_HMA label byte
ResidentH label byte
TextG? <xxxxx. HMA Available - >
FreeT	label	byte
TextG? <xxxxx.>,,ET
;
No_HMA label byte
TextG? <HMA Available - >
FreeH	label	byte
TextG? <xxxxx bytes - Insufficient.>,,ET
;
Load_UMB label byte
DBG? <10,13>
TextG? <Resident Memory (bytes): UMB - >
ResidentU label byte
TextG? <xxxxx.>,,ET
;
Load_Mem label byte
DBG? <10,13>
TextG? <Resident Memory (bytes): Conventional - >
ResidentM label byte
TextG? <xxxxx.>,,ET
;
I_Addr label byte
TextG? <  Initialization at >
I_Seg	label	byte
TextG? <xxxx:>
I_Off	label	byte
TextG? <xxxx (>
I_Len	label	byte
TextG? <xxxxx bytes).>,,ET
;
TxOff	label	byte
TextG? <Off>
;
TxOn	label	byte
TextG? <On >
;
MsgU	label	byte
DBTG?	%NAM_@@@
TextG?	< unload >,,ET
;
;
; Макрокоманда описания параметра
Parm?	Macro	Addr,Text
	local	l1,l2
DBG?	<l2-l1>
I___	=	(Addr-Start+100h)
DWG?	%I___
l1	label	byte
TextG?	<Text>
l2	label	byte
	Endm
;
; Описание ключевых параметров командной строки:
;   Формат: адрес подпрограммы обработки, параметр
_Word	label	Byte
Parm?	_OFF,OFF
Parm?	_ON,ON
Parm?	_KE,KE
Parm?	_PSP,PSP
Parm?	_NoHMA,NOHMA
Parm?	_NoUMB,NOUMB
Parm?	_Nul,NUL
Parm?	_U,U
Parm?	_N,N:
Parm?	_??,?
DBG?	<0>
LGamma equ	$-Gamma
;
;  Далее неполный МАКРО листинг макрокоманд
	.xall
;
; Подключение линии A20
Block?	EnableA20,<es,bx>
	mov	ax,4310h
	int	2fh		;выдать адрес диспетчера XMS
	mov	XMSo,bx
	mov	XMSs,es
	mov	ah,7		;состояние A20 enable ?
	call	XMS_A20
	dec	ax		;ax=1 (enable) ?
	jz	EnableA200	;да
	mov	ah,5		;локальное подключение A20
	call	XMS_A20
EnableA200:
Bend?	EnableA20
;
;  Выделение числа секторов
Block?	_N,<di,cx,bx>
	PU_DECB? ,,,2,":"
	je	_N0
	cmp	al,10
	jb	_N0
	cmp	al,21
	ja	_N0
	mov	SecS,al
_N0:
Bend?	_N
;
; Выгрузка драйвера из памяти при запуске из потока:
; 1. восстановим вектор int 13h
; 2. освободим память
Block?	_U,<es,ds>
	mov	ax,es
	cmp	ax,-1		;=0ffffh - HMA ?
	je	_U0		;да ... выходим
	mov	dx,cs
	cmp	ax,dx		;es=cs ?
	je	_U0		;да ... выходим
	cmp ES@B SysRetf," " 	;запуск из потока?
	jne	_U00		;нет, из CONFIG.SYS
; запуск из потока:
	DispStr? MsgU
	mov	ax,es
	mov	ds,ax
	add	ax,10h
	mov	es,ax
	SetInt?	13h,Old13,ds
	FreMem?
_U0:
	jmp	Exit0
_U00:
Bend?	_U
;
; Отключение вывода информации
Block?	_Nul
	or	 FlagSys,F_Nul
Bend?	_Nul
;
; Отключение драйвера
Block?	_Off
	and es:Flag[bx],not Flag_A	;отключить
	and Flag,not Flag_A
Bend?	_Off
;
; Включение драйвера
Block?	_On
         or es:Flag[bx],Flag_A		;включить
         or Flag,Flag_A
Bend?	_On
;
; Сохранить среду
Block?	_Ke
         or	Flag,F_ke
Bend?	_Ke
;
; Сохранить PSP
Block?	_PSP
         or	Flag,F_PSP
Bend?	_PSP
;
; Запрет на автозагрузку в HMA
Block?	_NoHMA
	or	Flag,F_NoHMA
Bend?	_NoHMA
;
; Запрет на автозагрузку в UMB
Block?	_NoUMB
	or	Flag,F_NoUMB
Bend?	_NoUMB
;
; Выдать помощь
Block?	_??
	or	Flag,F_Help
Bend?	_??
;
; Первичная настройка программы ... контроль ....
Block?	Begin,<es>
	movm?	Wes,cs,ax
	call	GetVectors	;запомнить вектора
  	GammT?	Gamma,13h,LGamma
	test FlagSys,F_Config	;запуск из config.sys ?
	jne	Begin2		;да
	PU_CName? NameP,LNameP
	jc	Begin0		;это нехорошо!
Begin2:
	xor	ax,ax
	mov	Flag,Flag_A	;признак активности
;
	mov     ah,18h
	xor	dx,dx
	mov     cx,"pu"		;признак запроса
	int     13h		;запрос к драйверу
	PushPop? ds,cs
	cmp     ax,"up"		;драйвер  загружен ?
	jne	Begin1		;нет
;  Драйвер уже установлен:
	mov	ax,es
	mov	Wes,ax
	sub	bx,100h		;коррекция off в HMA
	mov	Off_Mem,bx	;запомним
	cmp	ax,-1		;cs=0ffffh (HMA) ?
	jne	Begin3		;нет
; Драйвер установлен в HMA по адресу: es:cx
	call	EnableA20	;подключить A20
Begin3:
	mov	bx,Off_Mem
	movm?	Flag,es:Flag[bx]
	and	Flag,not F_Help
	or	Flag,PU_WRCFD	;драйвер уже установлен
	call	IAddr		;отображение адреса
Begin1:
; Драйвер если загружен - передадим параметры
	call    GetParm
	call	GetLBuff	;определить размер буфера
	test	Flag,PU_WRCFD
Begin0:
Bend?	Begin
;
; Отображение адреса загрузки драйвера
Block?	IAddr,<es,di>
	mov	ax,es
	PushPop? es,ds
	mov	di,@O I_Seg
	call	P216
	mov	di,@O I_Off
	mov	ax,Off_Mem
	call	P216
Bend?	IAddr
;
; Перевод 2-16 слова
Block?	P216
	xchg	al,ah
	PU_B216?
	xchg	al,ah
	PU_B216?
Bend?	P216
;
; Определить размер буфера
Block?	GetLBuff,<bx>
	mov	es,Wes
	mov	bx,Off_Mem
	xor	ax,ax
	mov	ah,es:SecS[bx]
	shl	ax,1
	add	AFree,ax
	xor	ax,ax
	mov	al,es:SecS[bx]
	PushPop? es,ds
	PU_BDEC? ,Tx_N,,2
	mov	ax,AFree
	mov	di,@O ResidentH
	mov	si,di
	PU_BDEC? ,,,5
	movsb? ResidentU,,5,<si>
	movsb? I_Len,,5,<si>
Bend?	GetLBuff
;
; Перевод прописные - заглавные
Block?	Caps,<si,cx>
CapsL:	lodsb
	cmp	al,"a"
	jb	Caps1
	cmp	al,"z"
	ja	Caps1
	and	al,not 20h
	mov	@B [si-1],al
Caps1:	loop	CapsL
Bend?	Caps
;
; Перенос строки параметров и настройка программы
Block?	MovLine,<es,bx,ds,di>
	call	Nastr
        lds	si,es:DDR_Line[bx]
	PushPop? es,cs
	mov	di,BuffLine
	xor	bx,bx
	mov	cx,255
MovLine1:
	lodsb
	stosb
	inc	bx
	cmp	al,20h
	jb	MovLine2
	loop	MovLine1
MovLine0:
Bend?	MovLine
MovLine2:
	mov	si,BuffLine 	;начало параметров
	mov	cx,bx
	jmp	MovLine0
;
;
GetParmC:
	call	MovLine
	jmp	short	GetParmC1
;
; Чтение параметров и настройка программы
Block?	GetParm
	PushPop? es,cs
	test FlagSys,F_Config	;запуск из config.sys ?
	jne	GetParmC	;да
	jmp	short GetParm1	;нет
GetParm0:
Bend?	GetParm
;
GetParm1:
	mov     si,81h
	xor	cx,cx
	mov     cl,@B 80h	;длина поля параметров
GetParmC1:
	or	cx,cx		;параметры заданы ?
	je      GetParm0	;нет
	call	Caps		;заглавные
GetParm2:
	lodsb
	cmp	al,"/"
	je	GetParm3
	loop	GetParm2
	jmp	GetParm0
GetParm3:
	call	AnParm		;анализ параметра
	jmp	GetParm2
;
; Анализ параметра
; на входе:  ds:si - адрес параметра
;               cx - длина
Block?	AnParm,<si,di,cx>
	mov	di,@O _Word
	xor	bx,bx
AnParm1:
	mov	bl,@B[di]
	or	bl,bl
	je	AnParm0		;конец списка
	call	CmpParm
	lea	di,[di+bx+3]
	jmp	AnParm1
AnParm0:
Bend?	AnParm
;
; Сравнение параметра
; на входе:  ds:si - адрес параметра
;               cx - длина
;	     es:di - адрес ключа
Block?	CmpParm,<si,di,es,cx,bx>
	xor	cx,cx
	mov	cl,@B[di]
	mov	ax,@W[di+1]
	add	di,3
	cmpsb?
	jne	CmpParm0
	mov	es,Wes
	mov	bx,Off_Mem
	call	ax
CmpParm0:
Bend?	CmpParm
;
; Выдача информации
Block?	InfoD,<es,ds>
	PushPop? <es,ds>,<cs,cs>
	test	Flag,F_Help	;подсказка нужна ?
	je	InfoD1		;нет
	test	FlagSys,F_Nul	;вывод в >nul
	jne	Infod0		;да
	DispStr? Reclama
InfoD1:
	call	AnAct		;индикация активности
	DispStr? MsgI
InfoD0:
Bend?	InfoD
;
; Индикация активности
Block?	AnAct
	mov	cx,3
	mov	di,@O Tx_WRCFD
	mov	si,@O TxOn
	test	Flag,Flag_A	;активна ?
	jne	AnAct1		;да
	mov	si,@O TxOff
AnAct1:
	movsb?
Bend?	AnAct
;
; Инициализация драйвера из CONFIG.SYS
Block?	StartConfig
	or     FlagSys,F_Config	;запуск из config.sys
	call	Begin
	jc	StartConfig0	;диверсия
	je	StartConfig1	;не повторный запуск
	stc			;повторный запуск
	jmp	short StartConfig0
StartConfig1:
	or	Flag,F_Help	;отобразить подсказку
;нет никакого PSP и не зачем сохранять среду:
	and	Flag,not(F_PSP+F_ke)
	call	InfoD
	clc
StartConfig0:
Bend?	StartConfig
;
; Запомнить вектор 13h
Block?	GetVectors,<ds,es>
	PushPop? es,cs
	xor	ax,ax
	mov	ds,ax
	sti
	mov	di,@O Old13
	movsw?	,13h*4,2
	cli
Bend?	GetVectors
;
; Установить вектор 13h для запуска из config.sys
Block?	SetVectors,<es>
	xor	ax,ax
	mov	es,ax
	mov	bx,cs
	sti
	mov	ax,@O I13	;смещение
	mov	di,13h*4
	stosw
	mov	ax,bx		;сегмент
	stosw
	cli
Bend?	SetVectors
;
;══════════════════════════════════════════════════
;
Dword?	Save_Reg
Status	dw	100h
;
; Программа обработки стратегии:
Strategy:
        mov     cs:Save_RegO-100h,bx
        mov     cs:Save_RegS-100h,es
	jmp	SysRetf
;
; Программа инициализации драйвера из CONFIG.SYS
Interrupt:
Push_Reg? InterDrv,<ds,es,ax,bx,cx,dx,si,di>
; 1. согласование cs:ip = cs-10h:0  для com программ
	mov	ax,cs
	sub	ax,10h
	push	ax
	mov	ax,@O InterDrvM
	push	ax
	retf
InterDrvM:
; 2. Настройка на новый сегмент:
        cld
	PushPop? <ds,es>,<cs,cs>
; 3. Работа:
	call	CheckCom	;инициализация ?
        jne	Inter_Err	;нет
; 4. инициализация
	call	StartConfig	;запуск из COFIG.SYS
        jc	Inter_Err	;ошибка
	call	GetFree		;конец инициализации
	call	SetVectors	;установить новый вектор
Inter_Exit:
	call	FStatus		;записать статус
	Pop_Reg? InterDrv
	jmp	SysRetf		;выход
; Отработка ошибочного запроса
Inter_Err:
        mov     Status,Stat_Err
	jmp	short Inter_Exit
;
; Контроль инициализации драйвера
Block?	CheckCom,<es,bx>
	call	Nastr
        mov     al,es:DDR_Com[bx]
        or      al,al
CheckCom0:
Bend?	CheckCom
;
; Настройка на es:bx
Block?	Nastr
        les     bx,Save_Reg
Bend?	Nastr
;
; Запись статуса
Block?	FStatus,<es,bx>
	call	Nastr
        movm?   es:DDR_Stat[bx],Status,ax
Bend?	FStatus
;
; Выдача размера резидентной части драйвера из config.sys
Block?	GetFree,<es,bx,dx>
; 1. Оформим заголовок драйвера и закоротим его вход:
	stosb?	Start,-1,4
	scasw
	mov	ax,SysRetf-Start
	stosw
	stosw
; 2. Запишем смещение и сегмент конца резидента
        mov     dx,AFree
	call	Nastr
        mov     es:DDR_Off[bx],dx
        mov     ax,cs
	add	ax,10h		;откорректируем сегмент
        mov     es:DDR_Seg[bx],ax
Bend?	GetFree
;
;
St_Divers:
	mov     al,1
	jmp     Exit
Exit_D:
	call	InfoD
	DispStr? I_Addr
Exit0:
	mov     al,0
Exit:
          Exit?
;
;
; Запуск COM-программы из потока
Start1:
	cld
	mov	sp,AStack	;перенесем адрес стека
	call	Begin
	jc	St_Divers	;диверсия
	mov	@B SysRetf," "
	jne	Exit_D		;повторный запуск
	test	Flag,F_Help	;подсказка ?
	je	St1		;нет ... работа
	DispStr? Reclama
	jmp	short Exit0
St1:
	or	Flag,F_Help	;отобразить подсказку
	call	InfoD		;отобразить информацию
;
; Инициализация резидентной части программы
	mov	ah,1
	test	Flag,F_ke 	;сохранить ?
	jne	Exir___		;да
;освободить блок среды
	mov     ah,0
Exir___:
	test	Flag,F_PSP 	;сохранить PSP?
	je	Exir____	;нет
	or	ah,4
Exir____:
;
; Отладка
;	SetInt? 13h,I13
;	mov	dx,AFree
;	add	dx,100h
;	int	27h
;переместим программу в PSP:
	jmp	Resident
;
;
;
;
	assume cs:_text,ds:nothing
;
;       Обработчик прерывания int 13h - часть I
;      ┌───────────────────────────────────────┐
;      │ Д и с п е т ч е р   л и н и и   A 2 0 │
;      └───────────────────────────────────────┘
; Используется только, если обработчик II загружен в HMA
;
;              Абсолютно перемещаем
Int13_S1:
Int13_B1:
	db	60h		;pusha
	mov	ah,7		;проверка сост. A20
	call	XMS_A20		;вызов диспетчера XMS
	dec	ax		;ax=1 (enable) ?
	jz	jmp1		;да
	mov	ah,5		;локал. подключение A20
	call	XMS_A20		;вызов диспетчера XMS
jmp1:
	db	61h		;popa
	db	0eah		;jmp far Int13_2
Dword?	Int13_2
;
; Обращение к функциям XMS
Block?	XMS_A20
	db	9ah		;call far xms
Dword?	XMS
Bend?	XMS_A20
;
Int13_E1:
Len1p	equ	(Int13_E1-Int13_S1+15)/16
Len1	equ	Len1p*16
;─────────────────────────────────────────────────────
;         конец диспетчера (части I )
;
;
; Таблица настройки обработчика II (смещений) по месту
; эту таблицу генерит МАКРОАССЕМБЛЕР - я ей только пользуюсь
Tabl_Off label	word
_NNN_	=	_Index_
_Index_	=	0
; Генерация таблицы меток
	rept	_NNN_
	VarAddr_?
	Endm
dw	0 		;конец таблицы меток
;
SegmMem dw	0	;сегмент куска памяти
VerDos	db	0	;версия DOS
;
State1	db	0	;статус
State2	db	0	;статус
;
;
	assume cs:_text,ds:_text
;
; Настройка программы по месту
; используется в этой программе только при загрузке
; основного тела драйвера (часть II) в HMA.
; на входе:  bx - смещение точки загрузки программы
; на выходе: часть II готовая к загрузке
Block?	NastrMem,<si,di,bx,es>
	sub	bx,100h		;компенсация: org 100h
	mov	si,@O Tabl_Off	;начало таблицы меток
NastrMem1:
	lodsw			;очередной элемент
	or	ax,ax		;конец таблицы ?
	je	NastrMem0	;да
	xchg	di,ax		;смещение
	add	@W[di],bx	;перестроим
	jmp	short NastrMem1
NastrMem0:
	add	bx,@O Int13_B2
	mov	Int13_2O,bx	;длинный адрес
	mov	Int13_2S,es	; обработчика II
Bend?	NastrMem
;
; Подготовка программы
; на выходе: CF = 1 - грузить в основную память
Block?	Begin@
	cld
	mov	ax,cs
	mov	SegmMem,ax
	test	Flag,F_ke	;сохранить среду ?
	jne	Begin@cpu	;да
	FreMem? <@W 2ch>	;освободить ENV
	or	Flag,F_ke	;для остальных
Begin@cpu:
	call    PU_CPUT		;опр. тип процессора
	or	ax,ax		;8088 ?
	jz	Begin@C		;да ... грузим в основную
;
	mov	ax,cs
	cmp	ax,0a000h	;в верхней памяти ?
	jae	Begin@C		;да ... грузим в основную
;
	mov	ax,4300h	;himem.sys установлен ?
	int	2fh
	cmp	al,80h		;драйвер установлен ?
	jnz	Begin@C		;нет... грузим в основную
;
	mov	ax,4310h
	int	2fh		;выдать адрес диспетчера XMS
	mov	XMSo,bx		; в XMSs:XMSo
	mov	XMSs,es
	xor	ax,ax
	call	XMS_A20		;выдать информацию XMS
	test	dx,1		;HMA есть ?
	je	Begin@1
	or	Flag,F_HMA	;HMA есть
Begin@1:
	GetVer?			;DOS-Version
	mov	VerDos,al
	xchg	al,ah
	cmp	ah,9		;OS/2 ?
	ja	Begin@C		;да ... DOS загрузка
	cmp	ax,314h		;<  DOS 3.20
	jb	Begin@C		;да ... DOS загрузка
Begin@0:
Bend?	Begin@
Begin@C:
	stc			;только DOS загрузка
	jmp	short Begin@0
;
; Тестирование процессора по рекомендациям INTEL
;на выходе: ax = 0 - 8086
;                1 - 80286
;                2 - 80386 и выше
Block?	PU_CPUT,<bx>
	xor	ax,ax
	mov	bx,ax		;0 - 8086
	push	ax
	popf			;Flags = 0
	pushf
	pop	ax
	and	ax,0f000h	;проверим ст. биты
	cmp	ax,0f000h
	je	PU_CPUT0	;это 8086
;
	inc	bx		;1 - 80286
	mov	ax,0f000h	;установим ст. биты
	push	ax
	popf
	pushf
	pop	ax
	and	ax,0f000h	;проверим ст. биты
	jz	PU_CPUT0	;это 80286
;
	inc	bx		;это выше 286: 80386SX...
PU_CPUT0:
	xchg	ax,bx
Bend?	PU_CPUT
;
; Вывод строки на экран
Block?	DispStr,<ax>
	DispStr?
Bend?	DispStr
;
; Запомнить стратегии распределения памяти
Block?	SaveState
	mov	ax,5800h	;выдать стратегию распр. памяти
	int	21h
	mov	State1,al
; 0   - первый    подходящий в основной памяти
; 1   - лучший    -----"-----"-----"-----"----
; 2   - последний -----"-----"-----"-----"----
;         только для DOS 5.0 и выше:
; 40h - первый    подходящий в верхней памяти
; 41h - лучший    -----"-----"-----"-----"----
; 42h - последний -----"-----"-----"-----"----
; 80h - первый    подх. в верхн., затем в осн. памяти
; 81h - лучший    -----"-----"-----"-----"-----"-----
; 82h - последний -----"-----"-----"-----"-----"-----
;
	mov	ax,5802h	;выдать статус UMB блоков памяти:
	int     21h
	mov	State2,al	;0 - не подключены к DOS памяти
;                                1 - обслуживаются как DOS память
Bend?	SaveState
;
; Восстановить стратегии распределения памяти
Block?	RestoreState,<f,ax,bx>
	xor	bx,bx		;для > 5.0
	push	bx
	mov	bl,State2
	mov	ax,5803h	;восстановить UMB статус
	int     21h		; DOS обслуживания
;
	pop	bx
	mov	bl,State1
	mov	ax,5801h	;восст. стратегию распр. памяти
	int	21h
Bend?	RestoreState
;
;
;
;
; Выделение памяти:
; ═════════════════
;
; 1. Выделить DOS память в UMB или основной области
;    на входе:      ax - длина блока в параграфах
;    на выходе: SegMem - сегмент выделенного блока
Block?	GetMemDosUC
	mov	bx,81h		;лучший в UMB, затем в нижн.
GetMemDosUC1:
	call	GetMemDos
	jc	GetMemDosUC0	;ошибка
	call	FSegment	;оформить сегмент
	xor	ax,ax
GetMemDosUC0:
Bend?	GetMemDosUC
;
; 2. Выделить DOS память в UMB области
;    на входе:       ax - длина блока в параграфах
;    на выходе: SegMem - сегмент выделенного блока
GetMemDosU:
	mov	bx,41h		;лучший в UMB
	jc	short GetMemDosUC1
;
; 3. Выделить DOS память в основной области
;    на входе:       ax - длина блока в параграфах
;    на выходе: SegMem - сегмент выделенного блока
GetMemDosC:
	mov	bx,1h		;лучший в основной
	jc	short GetMemDosUC1
;
; 4. Выделить область памяти в верхней или основной области
;    на входе:  ax - длина блока в параграфах
;	        bx - стратегия выделения памяти
;    на выходе: ax - сегмент выделенного блока
Block?	GetMemDos
	push	ax
	push	bx
	call	SaveState	;запомнить статусы
	mov	ax,5803h	;включить UMB блоки
	mov	bx,1		; для DOS обслуживания
	int	21h
;
	mov	ax,5801h	;Установить стратегию распр памяти
	pop	bx		;стратегия
	jnc	GetMemDos1	;DOS 5.0 и выше ?
	mov	bx,1		;нет ... лучший в нижней
GetMemDos1:
	int	21h
;
	pop	bx
	GetMem?
	call	RestoreState	;восстановить State
Bend?	GetMemDos
;
; 5. Выделить UMB неподключенную к DOS памяти (Dos=High)
;    (Dos=High,umb - все блоки UMB обслуживаются DOS)
Block?	GetUMB,<dx,cx>
	push	dx
	mov	ah,10h		;выделить необходимый UMB
	call	XMS_A20
	pop	cx		;cx=dx - размер в параграфах
	cmp	ax,1		;память выделена ?
	jnz	GetUMB1		;нет
	cmp	dx,cx		;выделено достаточно ?
        jae	GetUMB2		;да
	mov	dx,bx
	mov	ah,11h		;освободить UMB
	call	XMS_A20
GetUMB1:
	stc
GetUMB0:
Bend?	GetUMB
GetUMB2:
	mov	ax,bx		;UMB-Segment
	call	FSegment	;оформить сегмент
	clc
	jmp	GetUMB0
;
; Оформить сегмент памяти
Block?	FSegment
	mov	SegmMem,ax	;сегмент блока загрузки
	dec	ax		;- длина MCB
	mov	es,ax
	inc	ax
	mov	di,8
	mov	word ptr es:[1],ax
	mov	si,DDH_name-DDH_next+100h
	mov	cx,8
	rep	movsb
Bend?	FSegment
;
;
;
;
; Загрузка программы или ее частей в память
; ═════════════════════════════════════════
;
; 1. Загрузка II части в HMA
Block?	LoadIIHMA
	mov	bx,AFree
	mov	ax,4a02h	;выделить HMA область
	int	2fh		; DOS 5.0
; на вых: es:di - адрес начала выделенного блока
	mov	bx,AFree
	call	ILenHMA		;индикация длины HMA
	mov	si,@O Int13_S2
; настройка I и II на HMA
	mov	bx,di
	call	NastrMem	;настроить по месту
	movsb?	,,Len2		;перемещение в HMA:di
Bend?	LoadIIHMA
;
; 2. Загрузка II части в UMB и установка INT 13h
Block?	LoadIIUMB,<ds>
	mov	dx,@O Load_UMB
	call	DispStr
;
	mov	es,SegmMem
	xor	di,di		;es:di - куда
	mov	si,@O Int13_S2	;ds:si - откуда
; перемещение обработчика 2 в UMB:0
	movsb?	,,Len2
; установка int 13h
	mov	ax,es
	sub	ax,10h		;загрузка в UMB:0
	mov	ds,ax
;	mov	bx,Int13_B2
	SetInt?	13h,Int13_B2
Bend?	LoadIIUMB
;
; 3. 3агрузка диспетчера по адресу es:0 и установка INT 13h
Block?	LoadIPGM,<dx,ds>
	mov	dx,@O LoadD_Low
	mov	ax,SegmMem
	cmp	ax,0a000h	;UMB ?
	jb	LoadIPGM1	;нет ... LOW
	mov	dx,@O LoadD_UMB
LoadIPGM1:
	call	DispStr
	xor	di,di
	mov	si,@O Int13_B1
	mov	es,SegmMem	;Lov или UMB
	movsb?	,,Len1		;в LOW или UMB
	mov	ax,es
	mov	ds,ax
	SetInt?	13h,0
LoadIPGM0:
Bend?	LoadIPGM
;
;
; Индикация длины HMA
; на входе: di - смещение в св. блока в HMA
;           bx - длина программы
Block?	ILenHMA,<ax,bx,dx,es,di>
	add	di,bx
	neg	di
	xchg	ax,di
	PU_BDEC? ,FreeT,cs,5
Bend?	ILenHMA
;
;
; Загрузка в UMB
Block?	Load@UMB
	mov	dx,AFree	;размер II области
	mov	cl,4
	shr	dx,cl		;в параграфах
	call	GetUMB		;выделить UMB у драйвера XMS
	jnc	Load@UMB1	;память выделена
	mov	ax,dx
	call	GetMemDosU	;выделить как DOS память
	jnc	Load@UMB1	;память выделена
	clc
Load@UMB0:
Bend?	Load@UMB
Load@UMB1:
	call	LoadIIUMB	;загрузить в UMB
Exit_Dos:
	Exit?	0		;Exit - 0
;
;
;
; Загрузка в HMA
Block?	Load@HMA
	cmp	VerDos,5	;<  DOS 5.0
	jb	Load@HMA0	;да
;
	mov	ax,4a01h	;запрос свободнго HMA блока:
	int	2fh		;на выходе:
;bx - длина выделенного HMA блока (0 - DOS нет в HMA)
;es:di - адрес выделенного HMA блока (ffff:ffff - нет)
	cmp	di,100h		;слишком много памяти ?
	jb	Load@HMA2	;да ... я не подумал об этом
	cmp	bx,AFree	;памяти хватает ?
	jb	Load@HMA2	;нет
; Загрузка II в HMA, I в UMB/Mem
	call	LoadIIHMA	;загрузка в II в HMA
	mov	dx,Len1p	;размер I области
	call	GetUMB		;попросить UMB у XMS
	jnc	Load@HMA1	;выделено
	mov	ax,Len1p
	call	GetMemDosUC	;попросить у DOS
	jc 	Load@HMA3	;нет ... выделим свою
; Загрузка диспетчера A20:
Load@HMA1:
	call	LoadIPGM	;загрузить диспетчер
	mov	dx,@O Load_HMA
	call	DispStr
	jmp	Exit_Dos	;В ы х о д
;
; Маловато места в HMA
Load@HMA2:
	mov	ax,bx
	PU_BDEC? ,FreeH,cs,5
	mov	dx,@O No_HMA
	call	DispStr
	stc
Load@HMA0:
Bend?	Load@HMA
;
; Перемещение диспетчера в начало этой программы
Load@HMA3:
	mov	ax,cs
	mov	es,ax
	mov	ds,ax
	mov	AFree,Len1+16
	mov	dx,@O LoadD_Mem
	call	DispStr
	movsb?	Start+16,Int13_B1,Len1	;переместить
	mov	dx,@O Load_HMA
	call	DispStr
	clc
	jmp	short Load@HMA0
;
;
; Перемещение программы в верхнюю память
Block?	MHight,<ax,bx,cx,dx,es,ds>
	call	Begin@		;подготовка
	jc	MConvMem	;загрузить в основную
; Автозагрузка в UMB:
	test	Flag,F_NoUMB	;запрет автозагрузки в UMB ?
	jne	MHight1		;да
	call	Load@UMB	;загрузить в UMB
	jc	MConvMem	;загрузить в основную
; Автозагрузка в HMA:
MHight1:
 	test	Flag,F_HMA	;HMA есть ?
	je	MConvMem	;нет ... загрузить в основную
	test	Flag,F_NoHMA	;запрет автозагрузки в HMA ?
	jne	MConvMem	;да ... загрузить в основную
	call	Load@HMA	;загрузить в HMA
	jnc	MHight0		;диспетчер в начале программы
; Загрузка в основную память
MConvMem:
	PushPop? es,cs
	mov	ax,AFree
	PU_BDEC? ,ResidentM,,5
	mov	dx,@O Load_Mem	;основная память
	mov	ax,cs
	cmp	ax,0a000h	;UMB ?
	jb	MConvMemM	;нет
	movsb?	ResidentU,ResidentM,5
	mov	dx,@O Load_UMB	;UMB
MConvMemM:
	call	DispStr
	stc
MHight0:
Bend?	MHight
;
; Первичная инициализация TSR в основную память:
Resident:
	or	ah,8		;в dx - длина перемещ. части
	mov	dx,Len2
	call	MHight		;переместить в High
	jc	ResidentII	;грузим обработчик II
; диспетчер A20 в начале программы:
	mov	dx,@O Start+16
	mov	@W OffI13,dx
	mov	dx,Len1+16	;длина перемещаемой части
ResidentII:
	add	AFree,100h	;длина резидента
;
;   переместить в PSP:
Exir0?	0,AFree,<<13h,I13>>
_Met_	equ	$
	org	_Met_-3
OffI13	dw	I13
	org	_Met_
	end	Start
