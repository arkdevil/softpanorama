{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,R+,S+,V+,X-}
{$M 16384,0,655360}

Unit VTest;

Interface

const
  IBMName  : array [0..5] of string[6] = ( '(none)', 'MDA', 'CGA', 'EGA', 'MCGA', 'VGA' );
  HercName : array [0..2] of string[7] = ( 'HGC', 'HGC+', 'InColor' );
  DisplayName : array [0..5] of string[34] = (
    '(none)',
    'MDA-compatible monochrome display',
    'CGA-compatible color display',
    'EGA-compatible color display',
    'PS/2-compatible monochrome display',
    'PS/2-compatible color display'
  );

type
  TVID = record
    TVideo0, TDisplay0 : Byte;
    TVideo1, TDisplay1 : Byte;
  end;

const
  MDA                 = 1;              { типы подсистемы }
  CGA                 = 2;
  EGA                 = 3;
  MCGA                = 4;
  VGA                 = 5;
  HGC                 = $80;
  HGCPlus             = $81;
  InColor             = $82;

  MDADisplay          = 1;              { типы дисплея }
  CGADisplay          = 2;
  EGAColorDisplay     = 3;
  PS2MonoDisplay      = 4;
  PS2ColorDisplay     = 5;

var
  Video : TVID;

procedure TestVideo(var VData : TVID);

Implementation

procedure TestVideo(var VData : TVID); Assembler;
asm

        jmp     @Begin

@EGADisplays:   DB      CGADisplay      { 0000b, 0001b  (EGA switch values) }
                DB      EGAColorDisplay { 0010b, 0011b }
                DB      MDADisplay      { 0100b, 0101b }
                DB      CGADisplay      { 0110b, 0111b }
                DB      EGAColorDisplay { 1000b, 1001b }
                DB      MDADisplay      { 1010b, 1011b }

@DCCtable:      DB      0,0             { translate table for INT 10h func 1Ah }
                DB      MDA,MDADisplay
                DB      CGA,CGADisplay
                DB      0,0
                DB      EGA,EGAColorDisplay
                DB      EGA,MDADisplay
                DB      0,0
                DB      VGA,PS2MonoDisplay
                DB      VGA,PS2ColorDisplay
                DB      0,0
                DB      MCGA,EGAColorDisplay
                DB      MCGA,PS2MonoDisplay
                DB      MCGA,PS2ColorDisplay

@TestSequence:  DB      TRUE            {  это список флагов и адресов,     }
                DW      @FindPS2        {  определяющих порадок, в котором эти }
                                        {  п/п просматривают различные   }
@EGAflag:       DB      0               {  подсистемы }
                DW      @FindEGA

@CGAflag:       DB      0
                DW      @FindCGA

@Monoflag:      DB      0
                DW      @FindMono

@NumberOfTests: DB      4

{
FindPS2

        Эта подпрограмма использует INT 10H функцию 1Ah для определения видео BIOS
        и Display Combination Code (DCC) для каждой присутствующей подсистемы.
}
@FindPS2:

        mov     ax, 1A00h
        int     10h             { video BIOS info }

        cmp     al, 1Ah
        jne     @L1             { выход если функция не поддерживается,
                                  нет MCGA или VGA в системе }

{     преобразовать BIOS DCCs в конкретную систему и дисплей }

        mov     cx, bx
        xor     bh, bh          { BX := DCC для активной подсистемы }

        or      ch, ch
        jz      @L2             { переход, только одна подсистема присутствует }

        mov     bl, ch          { BX := неактивный DCC }
        add     bx, bx
        mov     ax, [bx+offset @DCCtable]

        mov     word ptr es:[di+TVID.TVideo1], ax

        mov     bl, cl
        xor     bh, bh          { BX := активный DCC }

@L2:
        add     bx, bx
        mov     ax, [bx+offset @DCCtable]
        mov     word ptr es:[di+TVID.TVideo0], ax

    { сброс флагов для подсистем, которых нет }

        mov     byte ptr [@CGAflag], FALSE
        mov     byte ptr [@EGAflag], FALSE
        mov     byte ptr [@Monoflag], FALSE

        lea     bx, es:[di+TVID.TVideo0]  { если BIOS возвратил MDA ... }
        cmp     byte ptr [bx], MDA
        je      @L3
        lea     bx, es:[di+TVID.TVideo1]
        cmp     byte ptr [bx], MDA
        jne     @L1
@L3:
        mov     word ptr [bx], 0       { ... Hercules не может быть установлен }
        mov     byte ptr @Monoflag, TRUE
@L1:
        retn

{
  FindEGA

  Look for an EGA.  This is done by making a call to an EGA BIOS function
   which doesn't exist in the default (MDA, CGA) BIOS.
}

@FindEGA:                       { Вход  :  AH = flags            }
                                { Выход :  AH = flags            }
                                { TVideo0 &                      }
                                { TDisplay0 обработаны           }

        mov     bl, 10h         { BL := 10h (EGA info)   }
        mov     ah, 12h         { AH := INT 10H номер функции   }
        int     10h             { вызов EGA BIOS                }
                                { если EGA BIOS присутствует,   }
                                {  BL <> 10H                    }
                                {  CL = установка переключателей}
        cmp     bl,10h
        je      @L22            { переход EGA BIOS не присутствует }

        mov     al, cl
        shr     al, 1           { AL := переключатели/2         }
        mov     bx, offset @EGADisplays
        xlat                    { определение типа дисплея по DIP      }
        mov     ah, al          { AH := тип дисплея }
        mov     al, EGA         { AL := тип подсистемы }
        call    @FoundDevice

        cmp     ah, MDADisplay
        je      @L21            { переход, если EGA имеет монохромный дисплей }

        mov     byte ptr @CGAflag, FALSE { нет CGA, если EGA имеет цветной дисплей }
        jmp     @L22

@L21:
        mov     byte ptr @Monoflag, FALSE
                                 {  EGA имеет моно димплей, значит MDA и }
                                 {  Hercules доступны }
@L22:
        retn

{
FindCGA

This is done by looking for the CGA's 6845 CRTC at I/O port 3D4H.
}

@FindCGA:                       { Выход:      TVID обработан }

        mov     dx, 03D4h       { DX := адрес порта CRTC }
        call    @Find6845
        jc      @L31            { переход, если отсутствует }

        mov     al, CGA
        mov     ah, CGADisplay
        call    @FoundDevice

@L31:
        retn

{
 FindMono

 This is done by looking for the MDA's 6845 CRTC at I/O port 3B4H.  If
 a 6845 is found, the subroutine distinguishes between an MDA
 and a Hercules adapter by monitoring bit 7 of the CRT Status byte.
 This bit changes on Hercules adapters but does not change on an MDA.

 The various Hercules adapters are identified by bits 4 through 6 of
 the CRT Status value:

        000b = HGC
        001b = HGC+
        101b = InColor card
}

@FindMono:                      { Выход :      TVID обработан }
        mov     dx, 03B4h       { DX := адрес порта CRTC }
        call    @Find6845
        jc      @L44            { переход, если отсутствует }

        mov     dl, 0BAh        { DX := 3BAh (порт статуса) }
        in      al, dx
        and     al, 80h
        mov     ah, al          { AH := бит 7 (вертикальная синхр на HGC) }

        mov     cx, 8000h       { сделать это 32768 раз }
@L41:
        in      al, dx
        and     al, 80h         { выделить бит 7 }
        cmp     ah, al
        loope   @L41            { ожидать изменеие 7-го бита }

        jne     @L42            { если бит 7 изменен, то это Hercules }

        mov     al, MDA         { если бит 7 не изменился, это MDA }
        mov     ah, MDADisplay
        call    @FoundDevice
        jmp     @L44
@L42:
        in      al, dx
        mov     dl, al          { DL := значение из порта статуса }

        mov     ah, MDADisplay  { считаем, что это монохромный дисплей }

        mov     al, HGC         { смотрим наличие HGC }
        and     dl, 01110000b   { маскируем биты с 4 по 6 }
        jz      @L43

        mov     al, HGCPlus     { смотрим наличие HGC+ }
        cmp     dl, 00010000b
        je      @L43            { переход, если это HGC+ }

        mov     al, InColor     { это плата InColor }
        mov     ah, EGAColorDisplay
@L43:
        call    @FoundDevice
@L44:
        retn

{
 Find6845

 This routine detects the presence of the CRTC on a MDA, CGA or HGC.
 The technique is to write and read register 0Fh of the chip (cursor
 low).  If the same value is read as written, assume the chip is
 present at the specified port addr.
}

@Find6845:                      { Вход:       DX = port addr }
                                { Выход:      cf установлен, если отсутствует }
        mov     al, 0Fh
        out     dx, al          { выбор регистра 0Fh 6845 (Cursor Low) }
        inc     dx
        in      al, dx          { AL := текущее значение Cursor Low }
        mov     ah, al          { сохраним в AH }
        mov     al, 66h         { AL := значение arbitrary }
        out     dx, al          { попытаемся писать в 6845 }

        mov     cx, 100h
@L51:
        loop    @L51            { ожидаем готовности 6845 }

        in      al, dx
        xchg    ah, al          { AH := возвращенное значение }
                                { AL := оригинальное значение }
        out     dx, al          { восстановим оригинальное значение }

        cmp     ah, 66h         { проверка готовности 6845 }
        je      @L52            { переход, если готов (cf сброшен) }

        stc                     { установтьи carry flag, если 6845 отсутсвует }
@L52:
        retn

{
 FindActive

 This subroutine stores the currently active device as Device0.  The
 current video mode determines which subsystem is active.
}

@FindActive:
        cmp     word ptr es:[di+TVID.TVideo1], 0
        je      @L63                    { выход, если только одна подсистема }

        cmp     es:[di+TVID.TVideo0], 4 { выход если присутствуют MCGA или VGA }
        jge     @L63                    {  ( INT 10H функция 1AH }
        cmp     es:[di+TVID.TVideo1], 4 {  уже отработала ) }
        jge     @L63

        mov     ah, 0Fh
        int     10h                     { AL := текущий видео режим BIOS }

        and     al, 7
        cmp     al, 7                   { переход, если монохром }
        je      @L61                    {  (режим 7 или 0Fh) }

        cmp     es:[di+TVID.TDisplay0], MDADisplay
        jne     @L63                    { выход если Display0 цветной }
        jmp     @L62
@L61:
        cmp     es:[di+TVID.TDisplay0], MDADisplay
        je      @L63                    { выход если Display0 монохромный }
@L62:
        mov     ax, word ptr es:[di+TVID.TVideo0]   { сделать активным Device0 }
        xchg    ax, word ptr es:[di+TVID.TVideo1]
        mov     word ptr es:[di+TVID.TVideo0], ax
@L63:
        retn

{
 FoundDevice

 Эта программа обрабатывает список подсистем.
}

@FoundDevice:                           { Вход:    AH = # дисплея }
                                        {          AL = # подсистемы }
                                        { Разрушает:  BX  }
        lea     bx, es:[di+TVID.TVideo0]
        cmp     byte ptr es:[bx],0
        je      @L71                    { переход если 1я подсистема }

        lea     bx, es:[di+TVID.TVideo1]   { должна быть 2я подсистема }
@L71:
        mov     es:[bx], ax                { обработать список }
        retn

@Begin:
        push    ds
        push    cs
        pop     ds

{ инициализация структур данных, содержащих результат }

        les     di, ss:[VData]
        mov     word ptr es:[di+TVID.TVideo0], 0
        mov     word ptr es:[di+TVID.TVideo1], 0

        mov     byte ptr [@CGAflag], TRUE
        mov     byte ptr [@EGAflag], TRUE
        mov     byte ptr [@Monoflag], TRUE

	mov	cl, byte ptr @NumberOfTests
        xor     ch, ch
	mov	si, offset @TestSequence
@L01:
        lodsb			{ AL := флаг }
	test	al,al
	lodsw			{ AX := адрес подпрограммы }
	jz	@L02	        { пропустить программу если флаг False }

	push	si
	push	cx
	call	ax		{ вызов процедуры для определения подсистемы }
	pop	cx
	pop	si
@L02:
        loop	@L01

{ определение активной подсистемы }

	call	@FindActive
        pop     ds
end;

{
begin
  TestVideo(Video);
}
end.