{$A+,B-,D+,E-,F+,G-,I-,L+,N-,O+,R+,S+,V-,X-} { Turbo Pascal v6.0+ ! }
{ Из опций компилятора Вы можете изменять только $O-/$O+ - код оверлея }

{
      █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
      █                                                             █▒▒
      █                         DRVTOOLS                            █▒▒
      █                                                             █▒▒
      █             Модуль работы с дисковыми драйверами.           █▒▒
      █                                                             █▒▒
      █          (C) Copyright BZSoft,  1990 - august 1992.         █▒▒
      █   (C) Copyright GalaSoft United Group International, 1992.  █▒▒
      █                                                             █▒▒
      █                        version 3.02                         █▒▒
      █                                                             █▒▒
      █                                                             █▒▒
      █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▒▒
        ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒


  ************************ ТЕСТ ****************************************

    Этот модуль был тестирован в  MS-DOS  5.0  при  установке  различных
  драйверов.

    Тест продолжен в MS-DOS 3.30, COMPAQ DOS 3.31 и DR-DOS 6.0.

  ************************ ИСТОРИЯ ********************************

  Версия 3.02 - этот модуль выделен в самостоятельный из модуля DskTools.

  ******************************************************************
}
{$IFDEF VER60}
{$DEFINE OK}
{$ENDIF}
{$IFDEF VER70}
{$DEFINE OK}
{$ENDIF}
{$IFDEF OK}
unit DrvTools;

Interface

uses DskTools;

const GrapSign : array [0..3] of char = 'DRGP'; { Graphics signature }

{ строки для определения инсталляции ANSI.SYS }
const ConDev   : DriverName = 'CON';            { Console device     }
      AnsiDev  : DriverName = 'ANSI';           { ANSI.SYS driver    }
      MSAnsiSign:DriverName = #27'[00;00R';  {сигнатура для MS-DOS 2.x-3.x}

{ ----------- проц/функц выдачи статуса установки драйверов ---------- }

function GrafTablInstalled : boolean;
{ Graftabl - индикация наличия резидента }

function XMSDrvInstalled : boolean;
{ HIMEM.SYS, HIDOS.SYS }

function VidRAMInstalled : boolean;
{ расширение памяти DOS за счет EGA/VGA памяти }

function EGA2MemInstalled : boolean;
{ аналог VidRAM, увеличивает память DOS на 96k,  может возвращать память }
{ для проверки активности запросите размер памяти DOS (состояние ON/OFF) }

function AnsiSysInstalled : boolean;
{ ANSI.SYS драйвер }

function GraphicsInstalled : boolean;
{ GRAPHICS.COM
  не определяет НЕНОРМАЛЬНЫХ драйверов, типа из системы COMPAQ PC DOS,
  которые берут адрес 5 прерывания, сравнивают первые  N  (ў20h)  байт
  с байтами процедуры 5 прерывания в своем теле, если совпадают, то не
  устанавливается резидентом повторно. Так сигнатур на  них  не  напа-
  сешься. При необходимости  определить,  если  установлена  дибильная
  система и не срабатывает тест этой процедуры, считайте  адрес 5 пре-
  рывания:
        XOR     AX, AX
        MOV     ES, AX
        LES     DI, ES:[14h]
        MOV     AX, ES
        CMP     AX, 0F000h
  при не переопределенном прерывании сегмент кода - ПЗУ. }

function DietInstalled : boolean;
{ Программа сжатия кода DIET.EXE v1.1+ }

function _4DOSInstalled : word;
function _NDOSInstalled : word;
{ если установлены 4DOS или NDOS, возвращает номер версии - }
{ в старшем - главный, иначе возвращает 0 }

Implementation

var VER : word;

{------------------------------------------------------------------------}

function AnsiSysInstalled : boolean; assembler;
{
---------------------------------------------------------------------
INT 2F - DOS 4+ ANSI.SYS - INSTALLATION CHECK
	AX = 1A00h
Return: AL = FFh if installed
Notes:	AVATAR.SYS also responds to this call
	documented for DOS 5+, but undocumented for DOS 4.x
SeeAlso: AX=1A02h,INT 21/AX=440Ch
---------------------------------------------------------------------
INT 2F - AVATAR.SYS - INSTALLATION CHECK
	AX = 1A00h
	BX = 4156h ('AV')
	CX = 4154h ('AT')
	DX = 4152h ('AR')
Return: AL = FFh if installed
	    CF clear
	    BX = AVATAR protocol level supported
	    CX = driver type
		0000h AVATAR.SYS
		4456h DVAVATAR.COM inside DESQview window
	    DX = 0016h
Notes:	AVATAR also identifies itself as ANSI.SYS if BX, CX, or DX differ from
	  the magic values
	AVATAR.SYS is a CON replacement by George Adam Stanislav which
	  interprets AVATAR command codes in the same way that ANSI interprets
	  ANSI command codes
}
asm
        MOV     BX, 'AV'        { и ANSI.SYS и AVATAR.SYS (DVAVATAR.COM)}
        MOV     CX, 'AT'
        MOV     DX, 'AR'
        MOV     AX, 1A00h           { Для MS-DOS 4.0+ функция 1Ah прерыва- }
        INT     2Fh                 { ния 2Fh возвращает статус ANSI.SYS   }
        CMP     AL, 0FFh
        JE      @INSTALLED
        XOR     BX, BX            { специально  для  dvANSI.COM  }
        MOV     ES, BX            { из  DSQview,  устанавливает  }
        MOV     BX, 0A4h          { 29 прерывание на себя (вывод }
        MOV     AX, ES:[BX]       { символа - вн.ф.DOS) смещение }
        CMP     AX, 02E8h         { всегда 02E8h                 }
        JE      @INSTALLED
        CMP     BYTE PTR VER, 2
        JB      @NO

        PUSH    DS
        PUSH    BP
        MOV     AX, 5200h
        INT     21h
        POP     BP
        POP     DS
        LES     BX, ES:[BX+0Ch]    { ищем драйвер, где DOS указывает место }
        CMP     BX, 8              { драйвера устройства CON, там или есть }
        JAE     @SUB               { слово "ANSI", где  располагается  имя }
        MOV     AX, ES             { драйвера  (DR-DOS, MS-DOS 4.0+),  или }
        DEC     AX                 { сигнатура (для MS-DOS 2.x-3.x) }
        MOV     ES, AX             { см. MSAnsiSign }
        ADD     BX, 10h
@SUB:
        MOV     DI, BX
        SUB     DI, 8
        LEA     SI, AnsiDev        { <- в DS }
        MOV     CL, BYTE PTR [SI]  { поиск специально для DR-DOS, хотя }
        XOR     CH, CH             { это справедливо и для MS-DOS 4.0+,}
        INC     SI                 { но там обнаруживается быстрее, см.}
   REPE CMPSB                        
        JZ      @INSTALLED

        PUSH    ES                 { Block }
        PUSH    DI
        MOV     AX, 0400h          { Size - 1k }
        PUSH    AX
        XOR     AX, AX
        PUSH    AX                 { POS_ - 0 }
        LEA     AX, MSAnsiSign     { Sign - в DS }
        PUSH    DS
        PUSH    AX
        CALL    SearchStr  { AX := SearchStr(Block, 1024, 0, MSAnsiSign); }
        CMP     AX, 0FFFFh { if AX = FFFF - не найдено }
        JNE     @INSTALLED
@NO:
        XOR     AX, AX
        JMP     @QUIT
@INSTALLED:
        MOV     AX, 1
@QUIT:
end; { func AnsiSysInstalled }

function DietInstalled : boolean; assembler;
asm
        MOV     AX, 4BF0h
        STC
        INT     21h
        JC      @NO
        CMP     AX, 899Dh
        JNE     @NO
        MOV     AX, 1
        JMP     @QUIT
@NO:
        XOR     AX, AX
@QUIT:
end; { func DietInstalled }

function _4DOSInstalled : word; assembler;
asm
        MOV     AX, 0D44Dh
        XOR     BX, BX
        INT     2Fh
        CMP     AX, 44DDh
        JE      @OK
        XOR     AX, AX
        JMP     @QUIT
@OK:
        MOV     AX, BX
@QUIT:
end; { func _4DOSInstalled }

function _NDOSInstalled : word; assembler;
asm
        MOV     AX, 0E44Eh
        XOR     BX, BX
        INT     2Fh
        CMP     AX, 44EEh
        JE      @OK
        XOR     AX, AX
        JMP     @QUIT
@OK:
        MOV     AX, BX
@QUIT:
end; { func _NDOSInstalled }

function GraphicsInstalled : boolean; assembler;
{
INT 2F - DOS 4.00 GRAPHICS.COM - INSTALLATION CHECK
	AX = 1500h
Return: AX = FFFFh
	ES:DI -> ??? (graphics data?)
Note:	this installation check conflicts with the CD-ROM Extensions
	  installation check; moved to AX=AC00h in later versions
SeeAlso: AX=AC00h
}
asm
        MOV     AX, 0AC00h
        INT     2Fh
        CMP     AL, 0FFh
        JE      @INSTALLED
        MOV     AX, 3505h               { специально для DR-DOS }
        INT     21h
        XOR     DI, DI
        MOV     SI, OFFSET GrapSign
        MOV     BX, SEG GrapSign
        PUSH    DS
        MOV     DS, BX
        MOV     CX, 4
        CLD
   REPE CMPSB
        POP     DS
        JZ      @INSTALLED
        XOR     AX, AX
        JMP     @QUIT
@INSTALLED:
        MOV     AX, 1
@QUIT:
end; { func GraphicsInstalled }

function VidRAMInstalled : boolean; assembler;
asm
        MOV     AX, 0D201h
        MOV     BX, 'VI'
        MOV     CX, 'DR'
        MOV     DX, 'AM'
        INT     2Fh
        CMP     BX, 'OK'
        JE      @INSTALLED
        XOR     AX, AX
        JMP     @QUIT
@INSTALLED:
        MOV     AX, 1
@QUIT:
end; { func VidRAMInstalled }

function EGA2MemInstalled : boolean; assembler;
{ аналог VidRAM }
asm
        MOV     DX, 0360h
        MOV     AX, 8CEEh
        INT     10h
        CMP     AH, 0C8h
        JNE     @NO
        MOV     AX, 1
        JMP     @QUIT
@NO:
        XOR     AX, AX
@QUIT:
end; { func EGA2MemInstalled }

function XMSDrvInstalled : boolean; assembler;
{ HiDos.sys (DR-DOS), HiMem.sys (MS-DOS) }
asm
        MOV     AX, 4300h
        INT     2Fh
        CMP     AL, 80h
        JE      @INSTALLED
        XOR     AX, AX
        JMP     @QUIT
@INSTALLED:
        MOV     AX, 1
@QUIT:
end; { func XMSDrvInstalled }

function GrafTablInstalled : boolean; assembler;
asm
        MOV     AX, 0B000h
        INT     2Fh
        CMP     AL, 0FFh
        JE      @INSTALLED
        MOV     AX, 2E00h
        INT     2Fh
        CMP     AH, 0FFh
        JE      @INSTALLED
        XOR     AX, AX
        JMP     @QUIT
@INSTALLED:
        MOV     AX, 1
@QUIT:
end; { func GrafTablInstalled }

begin
asm
        MOV     AX, Dos_Version
        XCHG    AH, AL
        MOV     VER, AX
end;        
{$ELSE}
begin
WriteLn(^G'Вы не сможете откомпилировать этот модуль на TP версии ниже 6.0!');
{$ENDIF}
end. { Unit DrvTools }

 ************************************************************************

 Кроме примененных при написании программы, Вам наверняка будут
 интересны следующие сведения.

 ------------------------------------------------------------------------
INT 2F - DOS v5.0 DOSKEY - INSTALLATION CHECK
	AX = 4800h
Return: AL = nonzero if installed
SeeAlso: AX=4810h
 ------------------------------------------------------------------------
INT 21 - DESQview - INSTALLATION CHECK
	AH = 2Bh
	CX = 4445h ('DE')
	DX = 5351h ('SQ')
	AL = subfunction (DV v2.00+)
	    01h get version
		Return: BX = version (BH = major, BL = minor)
		Note: early copies of v2.00 return 0002h
	    02h get shadow buffer info, and start shadowing
		Return: BH = rows in shadow buffer
			BL = columns in shadow buffer
			DX = segment of shadow buffer
	    04h get shadow buffer info
		Return: BH = rows in shadow buffer
			BL = columns in shadow buffer
			DX = segment of shadow buffer
	    05h stop shadowing
Return: AL = FFh if DESQview not installed
Note:	in DESQview v1.x, there were no subfunctions; this call only
        identified whether or not DESQview was loaded
SeeAlso: INT 10/AH=FEh,INT 10/AH=FFh,INT 15/AX=1024h
 ------------------------------------------------------------------------
INT 21 - TAME v2.10+ - INSTALLATION CHECK
	AX = 2B01h
	CX = 5441h ('TA')
	DX = 4D45h ('ME')
---v2.60---
	BH = ???
	    00h skip ???, else do
Return: AL = 02h if installed
	ES:DX -> data area in TAME-RES (see below)
Note:   TAME is a shareware program by David G. Thomas which gives up CPU
        time to other partitions under a multitasker when the current
        partition's program incessantly polls the keyboard or system time
 ------------------------------------------------------------------------
INT 21 - DOS 2+ - GET ADDRESS OF INDOS FLAG
	AH = 34h
Return: ES:BX -> one-byte InDOS flag
Notes:	the value of InDOS is incremented whenever an INT 21 function begins
	  and decremented whenever one completes
	during an INT 28 call, it is safe to call some INT 21 functions even
	  though InDOS may be 01h instead of zero
	InDOS alone is not sufficient for determining when it is safe to
	  enter DOS, as the critical error handling decrements InDOS and
	  increments the critical error flag for the duration of the critical
	  error.  Thus, it is possible for InDOS to be zero even if DOS is
	  busy.
	the critical error flag is the byte immediately following InDOS in
	  DOS 2.x, and the byte BEFORE the InDOS flag in DOS 3+ (except
          COMPAQ DOS 3.0, where the critical error flag is located 1AAh
          bytes BEFORE the critical section flag)
	For DOS 3.1+, an undocumented call exists to get the address of the
	  critical error flag (see AX=5D06h)
SeeAlso: AX=5D06h,AX=5D0Bh,INT 28
 ------------------------------------------------------------------------
INT 21 - DOS 2+ - GET COUNTRY-SPECIFIC INFORMATION
	AH = 38h
--DOS 2.x--
	AL = 00h get current-country info
	DS:DX -> buffer for returned info (see below)
Return: CF set on error
	    AX = error code (02h)
	CF clear if successful
	    AX = country code (MSDOS 2.11 only)
	    buffer at DS:DX filled
--DOS 3+--
	AL = 00h for current country
	AL = 01h thru 0FEh for specific country with code <255
	AL = 0FFh for specific country with code >= 255
	   BX = 16-bit country code
	DS:DX -> buffer for returned info (see below)
Return:	CF set on error
	    AX = error code (02h)
	CF clear if successful
	    BX = country code
	    DS:DX buffer filled
SeeAlso: AH=65h,INT 10/AX=5001h,INT 2F/AX=110Ch,INT 2F/AX=1404h

Format of PCDOS 2.x country info:
Offset	Size	Description
 00h	WORD	date format  0 = USA	mm dd yy
			     1 = Europe dd mm yy
			     2 = Japan	yy mm dd
 02h	BYTE	currency symbol
 03h	BYTE	00h
 04h	BYTE	thousands separator char
 05h	BYTE	00h
 06h	BYTE	decimal separator char
 07h	BYTE	00h
 08h 24 BYTEs	reserved

Format of MSDOS 2.x,DOS 3+ country info:
Offset	Size	Description
 00h	WORD	date format (see above)
 02h  5 BYTEs	ASCIZ currency symbol string
 07h  2 BYTEs	ASCIZ thousands separator
 09h  2 BYTEs	ASCIZ decimal separator
 0Bh  2 BYTEs	ASCIZ date separator
 0Dh  2 BYTEs	ASCIZ time separator
 0Fh	BYTE	currency format
		bit 2 = set if currency symbol replaces decimal point
		bit 1 = number of spaces between value and currency symbol
		bit 0 = 0 if currency symbol precedes value
			1 if currency symbol follows value
 10h	BYTE	number of digits after decimal in currency
 11h	BYTE	time format
		bit 0 = 0 if 12-hour clock
			1 if 24-hour clock
 12h	DWORD	address of case map routine
		(FAR CALL, AL = character to map to upper case [>= 80h])
 16h  2 BYTEs	ASCIZ data-list separator
 18h 10 BYTEs	reserved

Values for country code:
 001h	United States
 002h	Canadian-French
 003h	Latin America
 01Fh	Netherlands
 020h	Belgium
 021h	France
 022h	Spain
 024h	Hungary (not supported by DR-DOS 5.0)
 026h	Yugoslavia (not supported by DR-DOS 5.0)
 027h	Italy
 029h	Switzerland
 02Ah	Czechoslovakia (not supported by DR-DOS 5.0)
 02Bh	Austria (DR-DOS 5.0)
 02Ch	United Kingdom
 02Dh	Denmark
 02Eh	Sweden
 02Fh	Norway
 030h	Poland (not supported by DR-DOS 5.0)
 031h	Germany
 037h	Brazil (not supported by DR-DOS 5.0)
 03Dh	International English [Australia in DR-DOS 5.0]
 051h	Japan (DR-DOS 5.0)
 052h	Korea (DR-DOS 5.0)
 15Fh	Portugal
 166h	Finland
 311h	Middle East (DR-DOS 5.0)
 3CCh	Israel (DR-DOS 5.0)
 ------------------------------------------------------------------------
INT 21 - DOS 3+ - SET COUNTRY CODE
	AH = 38h
	AL = 01h thru 0FEh for specific country with code <255
	AL = FFh for specific country with code >= 255
	   BX = 16-bit country code
	DX = FFFFh
Return: CF set on error
	    AX = error code (see AH=59h)
	CF clear if successful
Note:	not supported by OS/2
SeeAlso: INT 2F/AX=1403h
 ------------------------------------------------------------------------
INT 15 - SYSTEM - GET CONFIGURATION
                  (XT after 1/10/86,AT mdl 3x9,CONV,XT286,PS)
	AH = C0h
Return: CF set if BIOS doesn't support call
	CF clear on success
	    ES:BX -> ROM table (see below)
	AH = status
	    00h successful
	    86h unsupported function
Notes:	the 1/10/86 XT BIOS returns an incorrect value for the feature byte
	the configuration table is at F000h:E6F5h in 100% compatible BIOSes
	Dell machines contain the signature "DELL" or "Dell" at absolute
        FE076h and a model byte at absolute address FE845h
	Tandy 1000 machines contain 21h in the byte at F000h:C000h
	some AST machines contain the string "COPYRIGHT AST RESEARCH" one
        byte past the end of the configuration table

Format of ROM configuration table:
Offset	Size	Description
 00h	WORD	number of bytes following
 02h	BYTE	model (see below)
 03h	BYTE	submodel (see below)
 04h	BYTE	BIOS revision: 0 for first release, 1 for 2nd, etc.
 05h	BYTE	feature byte 1:
		bit 7 = DMA channel 3 used by hard disk BIOS
		bit 6 = 2nd 8259 installed
		bit 5 = Real-Time Clock installed
		bit 4 = INT 15/AH=4Fh called upon INT 9h
		bit 3 = wait for external event supported
		bit 2 = extended BIOS area allocated (usually at top of RAM)
		bit 1 = bus is Micro Channel instead of ISA
		bit 0 reserved
 06h	BYTE	feature byte 2:
		bit 7 = ???
		bit 6 = INT 16/AH=09h (keyboard functionality) supported
		bits 5-0 = ???
 07h	BYTE	feature byte 3:
		reserved (0)
 08h	BYTE	feature byte 4:
		reserved (0)
 09h	BYTE	feature byte 5:
		reserved (0) (IBM)
		??? (08h) (Phoenix 386 v1.10)
---AWARD BIOS---
 0Ah  N BYTEs	AWARD copyright notice
---Phoenix BIOS---
 0Ah	BYTE	??? (00h)
 0Bh	BYTE	major version
 0Ch	BYTE	minor version (BCD)
 0Dh  4 BYTEs	ASCIZ string "PTL" (Phoenix Technologies Ltd)

Values for model/submodel/revision:
Model  Submdl  Rev	BIOS date	System
 FFh	*	*	04/24/81	PC (original)
 FFh	*	*	10/19/81	PC (some bugfixes)
 FFh	*	*	10/27/82	PC (HD, 640K, EGA support)
 FFh	46h	***	  ???		Olivetti M15
 FEh	*	*	08/16/82	PC XT
 FEh	*	*	11/08/82	PC XT and Portable
 FEh	43h	***	  ???		Olivetti M240
 FEh	A6h	???	  ???		??? (checked for by 386MAX v6.01)
 FDh	*	*	06/01/83	PCjr
 FCh	*	*	01/10/84	AT models 068,099 6 MHz 20MB
 FCh	00h	01h	06/10/85	AT model  239	  6 MHz 30MB
 FCh	00h	<> 01h	  ???		7531/2 Industrial AT
 FCh	01h	00h	11/15/85      AT models 319,339 8 MHz, Enh Keyb, 3.5"
 FCh	01h	00h	09/17/87	Tandy 3000
 FCh	01h	00h	01/15&88	Toshiba T5200/100
 FCh	01h	00h	12/26*89	Toshiba T1200/XE
			(Those date characters are not typos)
 FCh	01h	30h	  ???		Tandy 3000NL
 FCh	01h	???	  ???		Compaq 286/386
 FCh	02h	00h	04/21/86	PC XT-286
 FCh	04h	00h	02/13/87     ** PS/2 Model 50 (10 MHz/1 ws 286)
 FCh	04h	03h	04/18/88	PS/2 Model 50Z (10 MHz/0 ws 286)
 FCh	05h	00h	02/13/87     ** PS/2 Model 60 (10 MHz 286)
 FCh	06h	???	  ???		7552 "Gearbox"
 FCh	08h	***	  ???		Epson, unknown model
 FCh	09h	00h	  ???		PS/2 Model 25 (10 MHz 286)
 FCh	09h	02h	06/28/89	PS/2 Model 30-286
 FCh	0Bh	00h	02/16/90	PS/1 Model 2011 (10 MHz 286)
 FCh	30h	***	  ???		Epson, unknown model
 FCh	31h	***	  ???		Epson, unknown model
 FCh	33h	***	  ???		Epson, unknown model
 FCh	42h	***	  ???		Olivetti M280
 FCh	45h	***	  ???		Olivetti M380 (XP 1, XP3, XP 5)
 FCh	48h	***	  ???		Olivetti M290
 FCh	4Fh	***	  ???		Olivetti M250
 FCh	50h	***	  ???		Olivetti M380 (XP 7)
 FCh	51h	***	  ???		Olivetti PCS286
 FCh	52h	***	  ???		Olivetti M300
 FCh	81h	00h	01/15/88	Phoenix 386 BIOS v1.10 10a
 FBh	00h	01h	01/10/86	PC XT, Enh Keyb, 3.5" support
 FBh	00h	02h	05/09/86	PC XT
 FBh	4Ch	***	  ???		Olivetti M200
 FAh	00h	00h	09/02/86	PS/2 Model 30 (8 MHz 8086)
 FAh	00h	01h	12/12/86	PS/2 Model 30
 FAh	01h	00h	  ???		PS/2 Model 25/25L (8 MHz 8086)
 FAh	4Eh	***	  ???		Olivetti M111
 F9h	00h	00h	09/13/85	PC Convertible
 F8h	00h	00h	03/30/87     ** PS/2 Model 80 (16MHz 386)
 F8h	01h	00h	10/07/87	PS/2 Model 80 (20MHz 386)
 F8h    04h     02h     04/11/88        PS/2 Model 70 20MHz
 ------------------------------------------------------------------------
INT 2F - DOS 3.3+ KEYB.COM internal - INSTALLATION CHECK
	AX = AD80h
Return: AL = FFh if installed
	    BX = version number (BH = major, BL = minor)
	    ES:DI -> internal data
Note:	MSDOS 3.30, PCDOS 4.01, and MSDOS 5.00 all report version 1.00.
 ------------------------------------------------------------------------
 ************************************************************************

                  ИСТОЧНИКИ ДОПОЛНИТЕЛЬНОЙ ИНФОРМАЦИИ

!  [1] - Tech Help! (v3.20, v4.01) (C) Flambeaux Software.
*  [2] - Assimbly Language database, (C) 1987 by Peter Norton Computing, Inc.
*  [3] - Interrupt List, (c) 1991 Ralf Brown, (C) 1991 Sergey Sotnikov
   [4] - Interrupt List, Release 30 4/26/92, (c) 1989-92 Ralf Brown.  {!!!}
*  [5] - Bios Technical Reference, (C) 1987-88 Wildmill Technologies Ltd.
   [6] - VidRAM.COM, (C) 1989-90 Quarterdeck Office Systems, Inc.
   [7] - EGA2MEM.COM, (C) Maxim Savchenko V., 1991 (v1.2)
   [8] - Скэнлон. Программирование на языке ассемблера.

>>
  - Знаком "*" отмечены электронные справочники, поддерживаемые
    The Norton Guides, v1.04, (c) 1987 by Peter Norton Computing, Inc.
  - Знаком "!" отмечены электронные справочники, поддерживаемые
    Help! version 4.xx. Copyright (c) 1985,89 by Flambeaux Software, Inc.

>>
    Кроме указанных выше, в программе упоминались продукты фирм :

                    Borland International.
                    Microsoft Corp.
                    Digital Research Inc.
                    IBM Corp.
                    Teddy Matsumoto

 ***********************************************************************

 Организована группа программистов GalaSoft United Group International
 (организаторы Зулин Борис, Березин Антон), цель группы - помощь в
 распространении программ, консультации по их использованию и обмен
 модулями и новой информацией.

 Если Вам удобнее, можете обращаться :

 320038, Украина г. Днепропетровск, ул. Привокзальная д.3, кв.38.
 (0562) 50-40-84 (д), 42-89-11 (сл.). Березин Антон.

 ***********************************************************************

 (C) BZSoft Inc., август 1992. (04872) 4-51-96 (д), Зулин Борис.
 Россия, Белгородская обл. г.Шебекино. ул.Ленина д.28 кв.20.


